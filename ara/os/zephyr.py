from .os_util import syscall, get_argument
from .os_base import OSBase
from ara.util import get_logger
from ara.graph import SyscallCategory, SigType
from dataclasses import dataclass
import ara.graph as _graph
import pyllco
import html

logger = get_logger("ZEPHYR")

class ZephyrInstance:
    def attribs_to_dot(self, attribs: [str]):
        return "<br/>".join([f"<i>{a}</i>: {html.escape(str(getattr(self, a)))}" for a in attribs])

    def instance_dot(self, attribs: [str], color: str):
        return {
            "shape": "box",
            "fillcolor": color,
            "style": "filled",
            "sublabel": self.attribs_to_dot(attribs)
        }

# SSE finds suitable entrypoints by using isinstance (_iterate_tasks(). This reuquries hashability).
# There are two way this can be achieved with dataclasses. Either mark them as frozen
# (== immutable) or use unsafe_hash to generate a hash that might break if fields change.
#@dataclass(unsafe_hash=True)
@dataclass(frozen=True)
class Thread(ZephyrInstance):
    # Pointer to uninitialized struct k_thread.
    data: object
    # Pointer to the stack space.
    stack: object
    # Stack size in bytes.
    stack_size: int
    # Thread entry function.
    entry: object
    # Name of the entry function
    entry_name: str
    # The first abb of the entry function. Used to ensure the required 
    # compatability with the freertos.Tasks. SSE depends on it.
    entry_abb: object
    # 3 parameters that are passed to the entry function.
    # NOTE This has to be a tuple, lists are not hashable
    entry_params: (object, object, object)
    # Thread priority.
    priority: int
    # Thread options.
    options: int
    # Scheduling delay, or K_NO_WAIT (for no delay).
    delay: int

    def as_dot(self):
        attribs = ["entry_name", "stack_size", "entry_params", "priority", "options", "delay"]
        return self.instance_dot(attribs, "#6fbf87")

# Interrupt service routine. Like every other kernel resource, these can be created
# dynamically via irq_connect_dynamic() (which is not a syscall) or statically by 
# using the IRQ_CONNECT macro. The latter might be harder to detect since the actual 
# implementation is arch dependend.
# Most of the embedded architectures like riscv and arm seem to use Z_ISR_DECLARE()
# internally.
@dataclass(frozen=True)
class ISR(ZephyrInstance):
    # The irq line number
    irq_number: int
    # The priority. Might be ignored if the architecture's interrupt controller does not support
    # that
    priority: int
    # The handler function
    handler: object
    # The name of the hander function
    handler_name: str
    # The first abb of the handler function. Needed for SSE (see Thread.entry_abb)
    entry_abb: object
    # Parameter for the handler
    handler_param: object
    # Architecture specific flags
    flags: int

    def as_dot(self):
        attribs = ["irq_number", "priority", "handler_name", "flags"]
        return self.instance_dot(attribs, "#6fbf87")

# There are actually two types of semaphores: k_sems are kernelobjects that are
# managed via the k_sem_* syscalls while sys_sems live in user memory (provided
# user mode is enabled). Right now, only k_sems can be detected.
@dataclass
class Semaphore(ZephyrInstance):
    # Pointer to unitialized struct k_sem
    data: object
    # The internal counter
    count: int
    # The maximum permitted count
    limit: int

    def as_dot(self):
        attribs = ["count", "limit"]
        return self.instance_dot(attribs, "#6fbf87")

@dataclass
class Mutex(ZephyrInstance):
    #The k_mutex object
    data: object

    def as_dot(self):
        attribs = []
        return self.instance_dot(attribs, "#6fbf87")

# The zephyr kernel offers two kinds of queues: FIFO and LIFO which both use queues internally
# They are created via separate "functions" k_{lifo,fifo}_init
# Both of those are just macros wrapping the actual k_queue_init syscall which makes them
# hard to detect. For now, we do not diffrentiate between types of queues.
# On a positive note, since these are macros no action is needed to make ARA detect the
# underlying k_queue_init sycalls. Were they functions, they might not be contained in libapp
# TODO: Think about detection of lifo and fifo queues.
@dataclass
class Queue(ZephyrInstance):
    # The k_queue object
    data: object

    def as_dot(self):
        attribs = []
        return self.instance_dot(attribs, "#6fbf87")

# Stacks are created via the k_stack_alloc_init syscall which allocates an internal buffer.
# However, it is also possible to initialize a stack with a given buffer with k_stack_init 
# which is NOT a syscall.
# TODO: Find out if k_stack_init should be detected as well.
@dataclass
class Stack(ZephyrInstance):
    # The k_stack object
    stack: object
    # The buffer where elements are stacked
    data: object
    # The max number of entries that this stack can hold
    max_entries: int

    def as_dot(self):
        attribs = ["max_entries"]
        return self.instance_dot(attribs, "#6fbf87")

@dataclass
class Empty(ZephyrInstance):
    def as_dot(self):
        attribs = []
        return self.instance_dot(attribs, "#6fbf87")

class ZEPHYR(OSBase):
    vertex_properties = [('label', 'string', 'instance name'),
                         ('obj', 'object', 'instance object (e.g. Task)'),
                         ('test', 'string', 'Something'),
                         ]
    edge_properties = [('label', 'string', 'syscall name')]

    @staticmethod
    def get_special_steps():
        return []

    @staticmethod
    def add_normal_cfg(cfg, abb, state):
        for oedge in cfg.vertex(abb).out_edges():
            if cfg.ep.type[oedge] == _graph.CFType.lcf:
                state.next_abbs.append(oedge.target())

    @staticmethod
    def init(state):
        for prop in ZEPHYR.vertex_properties:
            state.instances.vp[prop[0]] = state.instances.new_vp(prop[1])
        for prop in ZEPHYR.edge_properties:
            state.instances.ep[prop[0]] = state.instances.new_ep(prop[1])

    @staticmethod
    def interpret(cfg, abb, state, categories=SyscallCategory.every):
        syscall = cfg.get_syscall_name(abb)
        logger.info(f"Interpreting syscall: {syscall}")
        return getattr(ZEPHYR, syscall)(cfg, abb, state)

    # k_tid_t k_thread_create(struct k_thread *new_thread, k_thread_stack_t *stack, size_t stack_size, 
    #   k_thread_entry_t entry, void *p1, void *p2, void *p3, int prio, uint32_t options,
    #   k_timeout_t delay)
    @syscall(categories={SyscallCategory.create},
             signature=(SigType.symbol, SigType.symbol, SigType.value,
                        SigType.symbol, SigType.value, SigType.value,
                        SigType.value, SigType.value, SigType.value,
                        SigType.value))
    def k_thread_create(cfg, abb, state):
        state = state.copy()
        v = state.instances.add_vertex()
        state.instances.vp.label[v] = "Thread"

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        stack = get_argument(cfg, abb, state.call_path, 1, ty=pyllco.Value)
        stack_size = get_argument(cfg, abb, state.call_path, 2)
        entry = get_argument(cfg, abb, state.call_path, 3, ty=pyllco.Function)
        entry_name = entry.get_name()
        entry_abb = cfg.get_entry_abb(cfg.get_function_by_name(entry_name))
        p1 = get_argument(cfg, abb, state.call_path, 4)
        p2 = get_argument(cfg, abb, state.call_path, 5)
        p3 = get_argument(cfg, abb, state.call_path, 6)
        entry_params = (p1, p2, p3)
        priority = get_argument(cfg, abb, state.call_path, 7)
        options = get_argument(cfg, abb, state.call_path, 8)
        delay = get_argument(cfg, abb, state.call_path, 9)

        instance = Thread(
            data,
            stack,
            stack_size,
            entry,
            entry_name,
            entry_abb,
            entry_params,
            priority,
            options,
            delay
        )

        state.instances.vp.obj[v] = instance

        state.next_abbs = []

        ZEPHYR.add_normal_cfg(cfg, abb, state)
        return state
    
    # int irq_connect_dynamic(unsigned int irq, unsigned int priority, 
    #   void (*routine)(const void *parameter), const void *parameter, uint32_t flags)
    @syscall(categories={SyscallCategory.create},
             signature=(SigType.value, SigType.value, SigType.symbol,
                        SigType.value, SigType.value))
    def irq_connect_dynamic(cfg, abb, state):
        state = state.copy()
        v = state.instances.add_vertex()
        state.instances.vp.label[v] = "ISR"

        irq_number = get_argument(cfg, abb, state.call_path, 0)
        priority = get_argument(cfg, abb, state.call_path, 1)
        handler = get_argument(cfg, abb, state.call_path, 2, ty=pyllco.Function)
        handler_name = handler.get_name()
        entry_abb = cfg.get_entry_abb(cfg.get_function_by_name(handler_name))
        handler_param = get_argument(cfg, abb, state.call_path, 3)
        flags = get_argument(cfg, abb, state.call_path, 4)
        
        instance = ISR(
            irq_number,
            priority,
            handler,
            handler_name,
            entry_abb,
            handler_param,
            flags
        )

        state.instances.vp.obj[v] = instance

        state.next_abbs = []

        ZEPHYR.add_normal_cfg(cfg, abb, state)
        return state

    # int k_sem_init(struct k_sem *sem, unsigned int initial_count, unsigned int limit)
    @syscall(categories={SyscallCategory.create},
            signature=(SigType.symbol, SigType.value, SigType.value))
    def k_sem_init(cfg, abb, state):
        state = state.copy()
        v = state.instances.add_vertex()
        state.instances.vp.label[v] = "Semaphore"

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        count = get_argument(cfg, abb, state.call_path, 1)
        limit = get_argument(cfg, abb, state.call_path, 2)

        instance = Semaphore(
            data,
            count,
            limit
        )

        state.instances.vp.obj[v] = instance
        state.next_abbs = []

        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # int k_mutex_init(struct k_mutex *mutex)
    @syscall(categories={SyscallCategory.create},
            signature=(SigType.symbol))
    def k_mutex_init(cfg, abb, state):
        state = state.copy()
        v = state.instances.add_vertex()
        state.instances.vp.label[v] = "Mutex"

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)

        instance = Mutex(
            data
        )

        state.instances.vp.obj[v] = instance
        state.next_abbs = []

        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # void k_queue_init(struct k_queue *queue)
    # k_lifo_init(lifo)
    # k_fifo_init(fifo)
    @syscall(categories={SyscallCategory.create},
            signature=(SigType.symbol))
    def k_queue_init(cfg, abb, state):
        state = state.copy()
        v = state.instances.add_vertex()
        state.instances.vp.label[v] = "Queue"

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)

        instance = Queue(
            data
        )

        state.instances.vp.obj[v] = instance
        state.next_abbs = []

        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # void k_stack_init(struct k_stack *stack, stack_data_t *buffer, uint32_t num_entries)
    @syscall(categories={SyscallCategory.create},
            signature=(SigType.symbol, SigType.value))
    def k_stack_alloc_init(cfg, abb, state):
        state = state.copy()
        v = state.instances.add_vertex()
        state.instances.vp.label[v] = "Stack"

        stack = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        #data = get_argument(cfg, abb, state.call_path, 1, ty=pyllco.Value)
        max_entries = get_argument(cfg, abb, state.call_path, 1)

        instance = Stack(
            stack,
            # When creating a stack with k_stack_alloc_init() the buffer is created in kernel
            # address space
            None,
            max_entries
        )

        state.instances.vp.obj[v] = instance
        state.next_abbs = []

        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

