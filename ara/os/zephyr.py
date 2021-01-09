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
class KernelSemaphore(Semaphore):
    pass

@dataclass
class UserSemaphore(Semaphore):
    pass

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
    data: object
    # The buffer where elements are stacked
    buf: object
    # The max number of entries that this stack can hold
    max_entries: int

    def as_dot(self):
        attribs = ["max_entries"]
        return self.instance_dot(attribs, "#6fbf87")

# Pipes can be created with two syscalls, k_pipe_init requries a user allocted buffer, 
# while k_pipe_alloc_init creates one from the internal memory pool.
@dataclass
class Pipe(ZephyrInstance):
    # The k_pipe object
    data: object
    # The size of the backing ring buffer in bytes
    size: int
    def as_dot(self):
        attribs = ["size"]
        return self.instance_dot(attribs, "#6fbf87")

# Heaps are created by the user as neccessary and can be shared between threads.
# However, using k_malloc and k_free, threads also have access to a system memory pool.
@dataclass
class Heap(ZephyrInstance):
    # The k_heap object, None for the system memory pool since it cannot be referecend by app code.
    data: object
    # The max size
    limit: int

    def as_dot(self):
        attribs = ["limit"]
        return self.instance_dot(attribs, "#6fbf87")

@dataclass
class MSGQ(ZephyrInstance):
    # The k_msgq object
    data: object
    # The size of a single message
    msg_size: int
    # This max number of messages that fit into the buffer
    max_msgs: int
    def as_dot(self):
        attribs = ["msg_size", "max_msgs"]
        return self.instance_dot(attribs, "#6fbf87")

@dataclass
class Empty(ZephyrInstance):
    def as_dot(self):
        attribs = []
        return self.instance_dot(attribs, "#6fbf87")

class ZEPHYR(OSBase):
    vertex_properties = [('label', 'string', 'instance name'),
                         ('obj', 'object', 'instance object (e.g. Task)'),
                         ]
    edge_properties = [('label', 'string', 'syscall name')]

    @staticmethod
    def get_special_steps():
        return ["ZephyrStaticPost"]

    @staticmethod
    def add_normal_cfg(cfg, abb, state):
        for oedge in cfg.vertex(abb).out_edges():
            if cfg.ep.type[oedge] == _graph.CFType.lcf:
                state.next_abbs.append(oedge.target())

    @staticmethod
    def create_instance(cfg, abb, state, label: str, obj: ZephyrInstance, ident: str, call: str):
        instances = state.instances
        v = instances.add_vertex()
        instances.vp.label[v] = label
        instances.vp.obj[v] = obj
        instances.vp.id[v] = ident
        instances.vp.branch[v] = state.branch
        instances.vp.loop[v] = state.loop
        instances.vp.after_scheduler[v] = state.scheduler_on
        instances.vp.unique[v] = not (state.branch or state.loop)
        instances.vp.soc[v] = abb
        instances.vp.llvm_soc[v] = cfg.vp.entry_bb[abb]
        instances.vp.file[v] = cfg.vp.file[abb]
        instances.vp.line[v] = cfg.vp.line[abb]
        instances.vp.specialization_level[v] = ""
        ZEPHYR.add_comm(state, v, call)

    @staticmethod
    def find_instance_by_symbol(state, instance):
        return filter(lambda v: state.instances.vp.obj[v].data == instance,
                state.instances.vertices())

    # Temporary way of adding a vertex in the instance graph for the main function.
    # TODO: Make this a proper thread later.
    main = None
    @staticmethod
    def add_main_instance(state):
        if ZEPHYR.main != None:
            return
        instances = state.instances
        #entry_abb = cfg.get_entry_abb(cfg.get_function_by_name("main"))
        v = instances.add_vertex()
        instances.vp.label[v] = "Main()"
        instances.vp.obj[v] = Mutex(None) 
        instances.vp.id[v] = "main"
        instances.vp.branch[v] = False
        instances.vp.loop[v] = False
        instances.vp.after_scheduler[v] = True
        instances.vp.unique[v] = True
        #instances.vp.soc[v] = entry_abb
        #instances.vp.llvm_soc[v] = cfg.vp.entry_bb[entry_abb]
        #instances.vp.file[v] = cfg.vp.file[entry_abb]
        #instances.vp.line[v] = cfg.vp.line[entry_abb]

        ZEPHYR.main = v

    system_heap = None
    @staticmethod
    def get_system_heap(state) -> int:
        if ZEPHYR.system_heap != None:
            return ZEPHYR.system_heap
        instances = state.instances
        v = instances.add_vertex()
        instances.vp.label[v] = "System Heap"
        instances.vp.obj[v] = Heap(None, None) 
        instances.vp.id[v] = "__system_heap"
        instances.vp.branch[v] = False
        instances.vp.loop[v] = False
        instances.vp.after_scheduler[v] = True
        instances.vp.unique[v] = True
        ZEPHYR.system_heap = v
        return ZEPHYR.system_heap

    @staticmethod
    def add_comm(state, to, call: str):
            instance = state.running
            if instance == None:
                logger.warn("syscall but no running instance. Maybe from main()?")
                ZEPHYR.add_main_instance(state)
                instance = ZEPHYR.main
            e = state.instances.add_edge(instance, to)
            state.instances.ep.label[e] = call

    @staticmethod
    def add_instance_comm(state, instance, call: str):
        matches = list(ZEPHYR.find_instance_by_symbol(state, instance))
        if len(matches) == 0:
            logger.warning(f"No matching instance found. Skipping.\n{type(instance)}\n{instance}")
        elif len(matches) > 1:
            logger.warning("Multiple matching instances found. Skipping.")
        else:
            match = matches[0]
            ZEPHYR.add_comm(state, match, call)

    @staticmethod
    def add_self_comm(state, call: str):
        ZEPHYR.add_comm(state, state.running, call)

    @staticmethod
    def init(state):
        pass

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

        ZEPHYR.create_instance(cfg, abb, state, "Thread", instance, data.get_name(), "k_thread_create")
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

        ZEPHYR.create_instance(cfg, abb, state, "ISR", instance, handler_name, "irq_connect_dynamic")

        state.next_abbs = []

        ZEPHYR.add_normal_cfg(cfg, abb, state)
        return state

    # int k_sem_init(struct k_sem *sem, unsigned int initial_count, unsigned int limit)
    @syscall(categories={SyscallCategory.create},
            signature=(SigType.symbol, SigType.value, SigType.value))
    def k_sem_init(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        count = get_argument(cfg, abb, state.call_path, 1)
        limit = get_argument(cfg, abb, state.call_path, 2)

        instance = KernelSemaphore(
            data,
            count,
            limit
        )

        ZEPHYR.create_instance(cfg, abb, state, "KernelSemaphore", instance, data.get_name(), "k_sem_init")
        state.next_abbs = []

        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # int sys_sem_init(struct sys_sem *sem, unsigned int initial_count, unsigned int limit)
    @syscall(categories={SyscallCategory.create},
            signature=(SigType.symbol, SigType.value, SigType.value))
    def sys_sem_init(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        count = get_argument(cfg, abb, state.call_path, 1)
        limit = get_argument(cfg, abb, state.call_path, 2)

        instance = UserSemaphore(
            data,
            count,
            limit
        )

        ZEPHYR.create_instance(cfg, abb, state, "UserSemaphore", instance, data.get_name(), "sys_sem_init")
        state.next_abbs = []

        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # int k_mutex_init(struct k_mutex *mutex)
    @syscall(categories={SyscallCategory.create},
            signature=(SigType.value))
    def k_mutex_init(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)

        instance = Mutex(
            data
        )

        ZEPHYR.create_instance(cfg, abb, state, "Mutex", instance, data.get_name(), "k_mutex_init")
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

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)

        instance = Queue(
            data
        )

        ZEPHYR.create_instance(cfg, abb, state, "Queue", instance, data.get_name(), "k_queue_init")
        state.next_abbs = []

        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # void k_stack_init(struct k_stack *stack, stack_data_t *buffer, uint32_t num_entries)
    @syscall(categories={SyscallCategory.create},
            signature=(SigType.symbol, SigType.symbol, SigType.value))
    def k_stack_init(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        buf = get_argument(cfg, abb, state.call_path, 1, ty=pyllco.Value)
        max_entries = get_argument(cfg, abb, state.call_path, 1)

        instance = Stack(
            data,
            buf,
            max_entries
        )

        ZEPHYR.create_instance(cfg, abb, state, "Stack", instance, data.get_name(), "k_stack_init")
        state.next_abbs = []

        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # void k_stack_init(struct k_stack *stack, stack_data_t *buffer, uint32_t num_entries)
    @syscall(categories={SyscallCategory.create},
            signature=(SigType.symbol, SigType.value))
    def k_stack_alloc_init(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        #buf = get_argument(cfg, abb, state.call_path, 1, ty=pyllco.Value)
        max_entries = get_argument(cfg, abb, state.call_path, 1)

        instance = Stack(
            data,
            # When creating a stack with k_stack_alloc_init() the buffer is created in kernel
            # address space
            None,
            max_entries
        )

        ZEPHYR.create_instance(cfg, abb, state, "Stack", instance, data.get_name(), "k_stack_alloc_init")
        state.next_abbs = []

        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

# void k_pipe_init(struct k_pipe *pipe, unsigned char *buffer, size_t size)
    @syscall(categories={SyscallCategory.create},
            signature=(SigType.symbol, SigType.symbol, SigType.value))
    def k_pipe_init(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        buf = get_argument(cfg, abb, state.call_path, 1, ty=pyllco.Value)
        size = get_argument(cfg, abb, state.call_path, 2)

        instance = Pipe(
            data,
            size
        )

        ZEPHYR.create_instance(cfg, abb, state, "Pipe", instance, data.get_name(), "k_pipe_init")
        state.next_abbs = []

        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # int k_pipe_alloc_init(struct k_pipe *pipe, size_t size)
    @syscall(categories={SyscallCategory.create},
            signature=(SigType.symbol, SigType.value))
    def k_pipe_alloc_init(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        size = get_argument(cfg, abb, state.call_path, 1)

        instance = Pipe(
            data,
            size
        )

        ZEPHYR.create_instance(cfg, abb, state, "Pipe", instance, data.get_name(), "k_pipe_alloc_init")
        state.next_abbs = []

        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # void k_heap_init(struct k_heap *h, void *mem, size_t bytes)
    @syscall(categories={SyscallCategory.create},
            signature=(SigType.symbol, SigType.symbol, SigType.value))
    def k_heap_init(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        #buf = get_argument(cfg, abb, state.call_path, 1, ty=pyllco.Value)
        limit = get_argument(cfg, abb, state.call_path, 2)

        instance = Heap(
            data,
            limit
        )

        ZEPHYR.create_instance(cfg, abb, state, "Heap", instance, data.get_name(), "k_heap_init")
        state.next_abbs = []

        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # void k_msgq_init(struct k_msgq *q, char *buffer, size_t msg_size, uint32_t max_msgs)
    @syscall(categories={SyscallCategory.create},
            signature=(SigType.symbol, SigType.symbol, SigType.value, SigType.value))
    def k_msgq_init(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        #buf = get_argument(cfg, abb, state.call_path, 1, ty=pyllco.Value)
        msg_size = get_argument(cfg, abb, state.call_path, 2)
        max_msgs = get_argument(cfg, abb, state.call_path, 3)

        instance = MSGQ(
            data,
            msg_size,
            max_msgs
        )

        ZEPHYR.create_instance(cfg, abb, state, "MSGQ", instance, data.get_name(), "k_msgq_init")
        state.next_abbs = []

        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # int k_msgq_alloc_init(struct k_msgq *msgq, size_t msg_size, uint32_t max_msgs)
    @syscall(categories={SyscallCategory.create},
            signature=(SigType.symbol, SigType.value, SigType.value))
    def k_msgq_alloc_init(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        msg_size = get_argument(cfg, abb, state.call_path, 1)
        max_msgs = get_argument(cfg, abb, state.call_path, 2)

        instance = MSGQ(
            data,
            msg_size,
            max_msgs
        )

        ZEPHYR.create_instance(cfg, abb, state, "MSGQ", instance, data.get_name(), "k_msgq_alloc_init")
        state.next_abbs = []

        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    #
    # Syscall.comm
    #

    #
    # Thread
    #

    @syscall(categories={SyscallCategory.create},
             signature=(SigType.value,))
    def k_msleep(cfg, abb, state):
        state = state.copy()
        ZEPHYR.add_self_comm(state, "k_msleep")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state


    @syscall(categories={SyscallCategory.create})
    def k_yield(cfg, abb, state):
        state = state.copy()
        ZEPHYR.add_self_comm(state, "k_yield")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)
        return state

    @syscall(categories={SyscallCategory.create},
            signature=(SigType.symbol, SigType.value))
    def k_thread_join(cfg, abb, state):
        state = state.copy()
        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        ZEPHYR.add_instance_comm(state, data, "k_thread_join")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)
        return state

    #
    # Semaphore
    #

    # int k_sem_take(struct k_sem *sem, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.value))
    def k_sem_take(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        timeout = get_argument(cfg, abb, state.call_path, 1)
        ZEPHYR.add_instance_comm(state, data, "k_sem_take")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # void k_sem_give(struct k_sem *sem)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, ))
    def k_sem_give(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)

        ZEPHYR.add_instance_comm(state, data, "k_sem_give")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # void k_sem_reset(struct k_sem *sem)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, ))
    def k_sem_reset(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)

        ZEPHYR.add_instance_comm(state, data, "k_sem_reset")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # unsigned int k_sem_count_get(struct k_sem *sem)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, ))
    def k_sem_count_get(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)

        ZEPHYR.add_instance_comm(state, data, "k_sem_count_get")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # int sys_sem_take(struct sys_sem *sem, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.value))
    def sys_sem_take(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        timeout = get_argument(cfg, abb, state.call_path, 1)
        ZEPHYR.add_instance_comm(state, data, "sys_sem_take")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # int sys_sem_give(struct sys_sem *sem)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, ))
    def sys_sem_give(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)

        ZEPHYR.add_instance_comm(state, data, "sys_sem_give")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # unsigned int sys_sem_count_get(struct sys_sem *sem)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, ))
    def sys_sem_count_get(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)

        ZEPHYR.add_instance_comm(state, data, "sys_sem_count_get")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    #
    # Mutex
    #

    # int k_mutex_lock(struct k_mutex *mutex, k_timeout_t timeout)
    # NOTE: The thread that has locked a mutex is eligible for priority inheritance.
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.value))
    def k_mutex_lock(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        timeout = get_argument(cfg, abb, state.call_path, 1)

        ZEPHYR.add_instance_comm(state, data, "k_mutex_lock")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # int k_mutex_unlock(struct k_mutex *mutex)
    # Unlock should only ever be called by the locking thread.
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, ))
    def k_mutex_unlock(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)

        ZEPHYR.add_instance_comm(state, data, "k_mutex_unlock")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    #
    # Queue: FIFO and LIFO functions are just macro wrappers around the generic queue functions
    #

    # void k_queue_cancel_wait(struct k_queue *queue)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol))
    def k_queue_cancel_wait(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)

        ZEPHYR.add_instance_comm(state, data, "k_queue_cancel_wait")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # void k_queue_append(struct k_queue *queue, void *data)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.value))
    def k_queue_append(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        item = get_argument(cfg, abb, state.call_path, 1)

        ZEPHYR.add_instance_comm(state, data, "k_queue_append")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # int32_t k_queue_alloc_append(struct k_queue *queue, void *data)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.value))
    def k_queue_alloc_append(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        item = get_argument(cfg, abb, state.call_path, 1)

        ZEPHYR.add_instance_comm(state, data, "k_queue_alloc_append")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # void k_queue_prepend(struct k_queue *queue, void *data)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.value))
    def k_queue_prepend(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        item = get_argument(cfg, abb, state.call_path, 1)

        ZEPHYR.add_instance_comm(state, data, "k_queue_prepend")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # void k_queue_alloc_prepend(struct k_queue *queue, void *data)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.value))
    def k_queue_alloc_prepend(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        item = get_argument(cfg, abb, state.call_path, 1)

        ZEPHYR.add_instance_comm(state, data, "k_queue_alloc_prepend")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # void k_queue_insert(struct k_queue *queue, void *prev, void *data)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.value, SigType.value))
    def k_queue_insert(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        prev = get_argument(cfg, abb, state.call_path, 1)
        item = get_argument(cfg, abb, state.call_path, 2)

        ZEPHYR.add_instance_comm(state, data, "k_queue_insert")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # int k_queue_append_list(struct k_queue *queue, void *head, void *tail)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.value, SigType.value))
    def k_queue_append_list(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        head = get_argument(cfg, abb, state.call_path, 1)
        tail = get_argument(cfg, abb, state.call_path, 2)

        ZEPHYR.add_instance_comm(state, data, "k_queue_append_list")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # int k_queue_merge_slist(struct k_queue *queue, sys_slist_t *list)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.symbol))
    def k_queue_merge_slist(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        other = get_argument(cfg, abb, state.call_path, 1)

        ZEPHYR.add_instance_comm(state, data, "k_queue_merge_list")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # void *k_queue_get(struct k_queue *queue, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.value))
    def k_queue_get(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        into = get_argument(cfg, abb, state.call_path, 1)

        ZEPHYR.add_instance_comm(state, data, "k_queue_get")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # bool k_queue_remove(struct k_queue *queue, void *data)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.value))
    def k_queue_remove(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        other = get_argument(cfg, abb, state.call_path, 1)

        ZEPHYR.add_instance_comm(state, data, "k_queue_remove")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # bool k_queue_unique_append(struct k_queue *queue, void *data)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.value))
    def k_queue_unique_append(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        other = get_argument(cfg, abb, state.call_path, 1)

        ZEPHYR.add_instance_comm(state, data, "k_queue_unique_append")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # int k_queue_is_empty(struct k_queue *queue)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol))
    def k_queue_is_empty(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)

        ZEPHYR.add_instance_comm(state, data, "k_queue_is_empty")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # void *k_queue_peek_head(struct k_queue *queue)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol))
    def k_queue_peek_head(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)

        ZEPHYR.add_instance_comm(state, data, "k_queue_peek_head")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # void *k_queue_peek_tail(struct k_queue *queue)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol))
    def k_queue_peek_tail(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)

        ZEPHYR.add_instance_comm(state, data, "k_queue_peek_tail")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    #
    # Stack
    #

    # int k_stack_cleanup(struct k_stack *stack)
    # NOTE: Should only be used if allocated with stack_alloc_init.
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, ))
    def k_stack_cleanup(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)

        ZEPHYR.add_instance_comm(state, data, "k_stack_cleanup")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # int k_stack_push(struct k_stack *stack, stack_data_t data)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.value))
    def k_stack_push(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        item = get_argument(cfg, abb, state.call_path, 1)

        ZEPHYR.add_instance_comm(state, data, "k_stack_push")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # int k_stack_pop(struct k_stack *stack, stack_data_t *data, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.value, SigType.value))
    def k_stack_pop(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        into = get_argument(cfg, abb, state.call_path, 1)
        timeout = get_argument(cfg, abb, state.call_path, 2)

        ZEPHYR.add_instance_comm(state, data, "k_stack_pop")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    #
    # Pipe
    #

    # int k_pipe_cleanup(struct k_pipe *pipe)
    # NOTE: Should only be used if allocated with pipe_alloc_init.
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, ))
    def k_pipe_cleanup(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)

        ZEPHYR.add_instance_comm(state, data, "k_pipe_cleanup")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # int k_pipe_put(struct k_pipe *pipe, void *data, size_t bytes_to_write, size_t *bytes_written,
    # size_t min_xfer, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.value, SigType.value, SigType.symbol, SigType.value,
                 SigType.value))
    def k_pipe_put(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        item = get_argument(cfg, abb, state.call_path, 1)
        item_size = get_argument(cfg, abb, state.call_path, 2)
        # Does not really make sense as a value, since at call time this contains garbage
        #bytes_written = get_argument(cfg, abb, state.call_path, 3)
        min_bytes_to_write = get_argument(cfg, abb, state.call_path, 4)
        timeout = get_argument(cfg, abb, state.call_path, 5)

        ZEPHYR.add_instance_comm(state, data, "k_pipe_put")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # int k_pipe_get(struct k_pipe *pipe, void *data, size_t bytes_to_read, size_t *bytes_read,
    # size_t min_xfer, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.symbol, SigType.value, SigType.symbol, SigType.value,
                 SigType.value))
    def k_pipe_get(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        #item = get_argument(cfg, abb, state.call_path, 1)
        item_size = get_argument(cfg, abb, state.call_path, 2)
        # Does not really make sense as a value, since at call time this contains garbage
        #bytes_read = get_argument(cfg, abb, state.call_path, 3)
        min_bytes_to_read = get_argument(cfg, abb, state.call_path, 4)
        timeout = get_argument(cfg, abb, state.call_path, 5)

        ZEPHYR.add_instance_comm(state, data, "k_pipe_get")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # void k_pipe_block_put(struct k_pipe *pipe, struct k_mem_block *block, size_t size, struct
    # k_sem *sem)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.value, SigType.value, SigType.symbol))
    def k_pipe_block_put(cfg, abb, state):
        # This syscall actually works on more than one instance. It writes to a pipe and
        # calls give() on sem (which is OPTIONAL).
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        item = get_argument(cfg, abb, state.call_path, 1)
        item_size = get_argument(cfg, abb, state.call_path, 2)
        sem = get_argument(cfg, abb, state.call_path, 4)

        ZEPHYR.add_instance_comm(state, data, "k_pipe_block_put")
        # For now just add a k_sem_give from the tread to the given semaphore, if present.
        # This should work, because sem has to be created externally
        if sem != None:
            ZEPHYR.add_instance_comm(state, sem, "k_sem_give")

        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # size_t k_pipe_read_avail(struct k_pipe *pipe)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, ))
    def k_pipe_read_avail(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)

        ZEPHYR.add_instance_comm(state, data, "k_pipe_read_avail")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # size_t k_pipe_write_avail(struct k_pipe *pipe)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, ))
    def k_pipe_write_avail(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)

        ZEPHYR.add_instance_comm(state, data, "k_pipe_write_avail")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # void *k_heap_alloc(struct k_heap *h, size_t bytes, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.value, SigType.value))
    def k_heap_alloc(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        size = get_argument(cfg, abb, state.call_path, 1)
        timeout = get_argument(cfg, abb, state.call_path, 2)

        ZEPHYR.add_instance_comm(state, data, "k_heap_alloc")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # void k_heap_free(struct k_heap *h, void *mem)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.symbol))
    def k_heap_free(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        #mem = get_argument(cfg, abb, state.call_path, 1)

        ZEPHYR.add_instance_comm(state, data, "k_heap_free")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # void *k_malloc(size_t size)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.value, ))
    def k_malloc(cfg, abb, state):
        state = state.copy()

        size = get_argument(cfg, abb, state.call_path, 0)

        ZEPHYR.add_comm(state, ZEPHYR.get_system_heap(state), "k_malloc")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # void k_free(void *ptr)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, ))
    def k_free(cfg, abb, state):
        state = state.copy()

        mem = get_argument(cfg, abb, state.call_path, 0)

        ZEPHYR.add_comm(state, ZEPHYR.get_system_heap(state), "k_free")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # void *k_calloc(size_t nmemb, size_t size)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.value, SigType.value))
    def k_calloc(cfg, abb, state):
        state = state.copy()

        num_elements = get_argument(cfg, abb, state.call_path, 0)
        element_size = get_argument(cfg, abb, state.call_path, 1)

        ZEPHYR.add_comm(state, ZEPHYR.get_system_heap(state), "k_calloc")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # int k_msgq_cleanup(struct k_msgq *msgq)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol,))
    def k_msgq_cleanup(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)

        ZEPHYR.add_instance_comm(state, data, "k_msgq_cleanup")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # int k_msgq_put(struct k_msgq *msgq, const void *data, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.symbol, SigType.value))
    def k_msgq_put(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        item = get_argument(cfg, abb, state.call_path, 1, ty=pyllco.Value)
        timeout = get_argument(cfg, abb, state.call_path, 2)

        ZEPHYR.add_instance_comm(state, data, "k_msgq_put")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # int k_msgq_get(struct k_msgq *msgq, void *data, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.symbol, SigType.value))
    def k_msgq_get(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        item = get_argument(cfg, abb, state.call_path, 1, ty=pyllco.Value)
        timeout = get_argument(cfg, abb, state.call_path, 2)

        ZEPHYR.add_instance_comm(state, data, "k_msgq_get")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # int k_msgq_peek(struct k_msgq *msgq, void *data)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.symbol))
    def k_msgq_peek(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        item = get_argument(cfg, abb, state.call_path, 1, ty=pyllco.Value)

        ZEPHYR.add_instance_comm(state, data, "k_msgq_peek")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # void k_msgq_purge(struct k_msgq *msgq)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol,))
    def k_msgq_purge(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)

        ZEPHYR.add_instance_comm(state, data, "k_msgq_purge")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # uint32_t k_msgq_num_free_get(struct k_msgq *msgq)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol,))
    def k_msgq_num_free_get(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)

        ZEPHYR.add_instance_comm(state, data, "k_msgq_num_free_get")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

    # void k_msgq_get_attrs(struct k_msgq *msgq, struct k_msgq_attrs *attrs)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.symbol))
    def k_msgq_get_attrs(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        attributes = get_argument(cfg, abb, state.call_path, 1, ty=pyllco.Value)

        ZEPHYR.add_instance_comm(state, data, "k_msgq_get_attrs")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state


    # uint32_t k_msgq_num_used_get(struct k_msgq *msgq)
    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol,))
    def k_msgq_num_used_get(cfg, abb, state):
        state = state.copy()

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)

        ZEPHYR.add_instance_comm(state, data, "k_msgq_num_used_get")
        state.next_abbs = []
        ZEPHYR.add_normal_cfg(cfg, abb, state)

        return state

