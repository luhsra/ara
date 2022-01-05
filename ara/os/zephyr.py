from .os_util import find_instance_node, syscall, Arg, find_return_value, set_next_abb, connect_from_here, add_self_edge
from .os_base import OSBase, ControlInstance, CPUList, CPU, OSState, ExecState
from ara.util import get_logger
from ara.graph import SyscallCategory, SigType, CallPath, CFG
from ara.steps import get_native_component
from dataclasses import dataclass
import pyllco
import html
import re

logger = get_logger("ZEPHYR")
ValueAnalyzer = get_native_component("ValueAnalyzer")
ValueAnalyzerResult = get_native_component("ValueAnalyzerResult")

@dataclass(eq=False)
class ZephyrInstance:
    def attribs_to_dot(self, attribs: [str]):
        return "<br/>".join([f"<i>{a}</i>: {html.escape(str(getattr(self, a)))}" for a in attribs])

    def instance_dot(self, attribs: [str], color: str, border_color: str = "#000000"):
        return {
            "shape": "box",
            "fillcolor": color,
            "color": border_color,
            "style": "filled",
            "sublabel": self.attribs_to_dot(attribs)
        }

    def __eq__(self, other):
        return hash(self) == hash(other)


# The node representing the Zehpyr kernel. This should only exist once in the instance graph.
# It it used for syscalls that do not operate on user created instances but rather on ones
# that are build into the kernel e.g. the scheduler or the system heap.
@dataclass
class ZephyrKernel(ZephyrInstance):
    # Size of the system heap. Zero if not present
    heap_size: int
    # Always none, but required
    symbol: object = None

    def as_dot(self):
        attribs = ["heap_size"]
        return self.instance_dot(attribs, "#e1d5e7", "#9673a6")

    def __hash__(self):
        return hash(("ZephyrKernel", self.heap_size, self.symbol))

@dataclass
class Thread(ZephyrInstance, ControlInstance):
    # Pointer to uninitialized struct k_thread.
    symbol: object
    # Pointer to the stack space.
    stack: object
    # Stack size in bytes.
    stack_size: int
    # Name of the entry function
    entry_name: str
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
        attribs = ["entry_name", "stack_size", "priority", "options", "delay"]
        return self.instance_dot(attribs, "#dae8fc", "#6c8ebf")

    def __hash__(self):
        return hash(("Thread", self.function, self.artificial, self.symbol, self.stack,
                     self.stack_size, self.entry_name, self.entry_params, self.priority, self.options, self.delay))

# Interrupt service routine. Like every other kernel resource, these can be created
# dynamically via irq_connect_dynamic() (which is not a syscall) or statically by 
# using the IRQ_CONNECT macro. The latter might be harder to detect since the actual 
# implementation is arch dependend.
# Most of the embedded architectures like riscv and arm seem to use Z_ISR_DECLARE()
# internally.
@dataclass
class ISR(ZephyrInstance, ControlInstance):
    # The irq line number
    irq_number: int
    # The priority. Might be ignored if the architecture's interrupt controller does not support
    # that
    priority: int
    # The name of the handler function
    entry_name: str
    # Parameter for the handler
    handler_param: object
    # Architecture specific flags
    flags: int
    # Always none but required for all zephyr instances
    symbol: object = None

    def as_dot(self):
        attribs = ["irq_number", "priority", "entry_name", "flags"]
        return self.instance_dot(attribs, "#dae8fc", "#6c8ebf")

    def __hash__(self):
        return hash(("ISR", self.function, self.artificial, self.irq_number, self.priority,
                     self.entry_name, self.handler_param, self.flags, self.symbol))

# There are actually two types of semaphores: k_sems are kernelobjects that are
# managed via the k_sem_* syscalls while sys_sems live in user memory (provided
# user mode is enabled). Right now, only k_sems can be detected.
@dataclass
class Semaphore(ZephyrInstance):
    # Pointer to unitialized struct k_sem
    symbol: object
    # The internal counter
    count: int
    # The maximum permitted count
    limit: int

    def as_dot(self):
        attribs = ["count", "limit"]
        return self.instance_dot(attribs, "#f8cecc", "#b85450")
    
    def __hash__(self):
        return hash((self.__class__.__name__, self.symbol, self.count, self.limit))

@dataclass
class KernelSemaphore(Semaphore):
    def __hash__(self):
        return super().__hash__()

@dataclass
class UserSemaphore(Semaphore):
    def __hash__(self):
        return super().__hash__()

@dataclass
class Mutex(ZephyrInstance):
    #The k_mutex object
    symbol: object

    def as_dot(self):
        attribs = []
        return self.instance_dot(attribs, "#f8cecc", "#b85450")

    def __hash__(self):
        return hash(("Mutex", self.symbol))

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
    symbol: object

    def as_dot(self):
        attribs = []
        return self.instance_dot(attribs, "#f8cecc", "#b85450")

    def __hash__(self):
        return hash(("Queue", self.symbol))

# Stacks are created via the k_stack_alloc_init syscall which allocates an internal buffer.
# However, it is also possible to initialize a stack with a given buffer with k_stack_init 
# which is NOT a syscall.
# TODO: Find out if k_stack_init should be detected as well.
@dataclass
class Stack(ZephyrInstance):
    # The k_stack object
    symbol: object
    # The buffer where elements are stacked
    buf: object
    # The max number of entries that this stack can hold
    max_entries: int

    def as_dot(self):
        attribs = ["max_entries"]
        return self.instance_dot(attribs, "#f8cecc", "#b85450")

    def __hash__(self):
        return hash(("Stack", self.symbol, self.buf, self.max_entries))

# Pipes can be created with two syscalls, k_pipe_init requries a user allocted buffer, 
# while k_pipe_alloc_init creates one from the internal memory pool.
@dataclass
class Pipe(ZephyrInstance):
    # The k_pipe object
    symbol: object
    # The size of the backing ring buffer in bytes
    size: int

    def as_dot(self):
        attribs = ["size"]
        return self.instance_dot(attribs, "#f8cecc", "#b85450")

    def __hash__(self):
        return hash(("Pipe", self.symbol, self.size))

# Heaps are created by the user as neccessary and can be shared between threads.
# However, using k_malloc and k_free, threads also have access to a system memory pool.
@dataclass
class Heap(ZephyrInstance):
    # The k_heap object, None for the system memory pool since it cannot be referecend by app code.
    symbol: object
    # The max size
    limit: int

    def as_dot(self):
        attribs = ["limit"]
        return self.instance_dot(attribs, "#f8cecc", "#b85450")

    def __hash__(self):
        return hash(("Heap", self.symbol, self.limit))

@dataclass
class MSGQ(ZephyrInstance):
    # The k_msgq object
    symbol: object
    # The size of a single message
    msg_size: int
    # This max number of messages that fit into the buffer
    max_msgs: int

    def as_dot(self):
        attribs = ["msg_size", "max_msgs"]
        return self.instance_dot(attribs, "#f8cecc", "#b85450")

    def __hash__(self):
        return hash(("MSGQ", self.symbol, self.msg_size, self.max_msgs))

llvm_suffix = re.compile(".+\.\d+")

class ZEPHYR(OSBase):
    vertex_properties = [('label', 'string', 'instance name'),
                         ('obj', 'object', 'instance object (e.g. Task)'),
                         ]
    edge_properties = [('label', 'string', 'syscall name')]

    """The kernel node"""
    kernel = None

    """A dict<str, int> that stores the number of times an identifier was requested."""
    id_count = {}

    @staticmethod
    def get_special_steps():
        return ["ZephyrStaticPost"]

    @staticmethod
    def has_dynamic_instances():
        return True

    @staticmethod
    def drop_llvm_suffix(name: str) -> str:
        """Removes the llvm suffix from a name"""
        if llvm_suffix.match(name) is not None:
            return name.rsplit('.', 1)[0]
        return name

    @classmethod
    def is_syscall(cls, function_name: str) -> bool:
        """
        Returns true if the given name belongs to a syscall, ignoring a potential llvm suffix.
        This overrides the behaviour of OSBase
        """
        # Drop the llvm suffix for all functions. Should not pose a problem since they can't occur
        # in regular C identifiers
        alias_name = function_name
        function_name = ZEPHYR.drop_llvm_suffix(function_name)

        if hasattr(cls, function_name) and hasattr(getattr(cls, function_name), 'syscall'):
            if alias_name != function_name:
                getattr(cls, function_name).aliases.append(alias_name)
            return True
        return False

    @staticmethod
    def get_unique_id(ident: str) -> str:
        """Generate a unique id by taking the actual one and appending a number to deduplicate"""
        count = ZEPHYR.id_count.get(ident)
        if count is None:
            ZEPHYR.id_count[ident] = 1
        else:
            ZEPHYR.id_count[ident] = count + 1
            ident = f"{ident}.{count}"

        return ident

    @staticmethod
    def create_instance(cfg: CFG, state: OSState, cpu_id: int, va: ValueAnalyzer, label: str, obj: ZephyrInstance, symbol: ValueAnalyzerResult, call: str, ident: str = None):
        """
        Adds a new instance and an edge for the create syscall to the instance graph.
        If there already exists an instance that is matched to the same symbol another one will be
        created and will inherit all interactions from his sibling. All future comm syscalls will
        add edges to all instances that share the same symbol. There is currently no way to
        distinguish between them. Those rules also apply to instances that add entry points (Thread, ISR).
        An exception is made for instances that share entry points. Adding one of those will mark
        add new info to the instance graph."""
        if ident is None:
            if symbol is not None:
                ident = symbol.value.get_name()
            else:
                assert False, "ident and symbol are both None!"

        if isinstance(obj, ControlInstance):
            # For now assume that no entry points are shared between different instance types
            entry_point = [cfg_v for cfg_v, inst_v in state.instances.iterate_control_entry_points() if cfg_v == obj.function]
            if len(entry_point) > 1:
                assert len(entry_point) == 1
                original = entry_point[0]
                logger.warning(f"Creation of instance with already known entry point, marking as non unique. {obj}")
                clones = [original]
                # Mark the clone and all his created instances as non unique.
                while len(clones) > 0:
                    clone = clones.pop(0)
                    state.instances.vp.unique[clone] = False
                    for e, n in zip(clone.out_edges(), clone.out_neighbors()):
                        syscall = getattr(ZEPHYR, state.instances.ep.label[e])
                        if ZEPHYR.syscall_in_category(syscall, SyscallCategory.create):
                            state.instances.vp.unique[n] = False
                            # If we find an instance which is now non-unique and adds an entry point we
                            # need to repeat the process for its node.
                            if clone.has_entry():
                                clones.append(n)

                return

        siblings = list(ZEPHYR.find_instance_by_symbol(state, obj.symbol))

        instances = state.instances
        v = instances.add_vertex()
        instances.vp.label[v] = label
        instances.vp.obj[v] = obj
        instances.vp.id[v] = ZEPHYR.get_unique_id(ident)

        cpu = state.cpus[cpu_id]
        abb = cpu.abb
        ana_context = cpu.analysis_context

        instances.vp.branch[v] = ana_context.branch
        instances.vp.loop[v] = ana_context.loop
        instances.vp.after_scheduler[v] = ana_context.scheduler_on
        # Creating an instance from a thread that is not unique will result in a non unique instance
        instances.vp.unique[v] = not (ana_context.branch or ana_context.loop) and instances.vp.unique[cpu.control_instance]
        instances.vp.soc[v] = abb
        instances.vp.llvm_soc[v] = cfg.vp.llvm_link[cfg.get_single_bb(abb)]
        instances.vp.file[v] = cfg.vp.files[abb][0]
        instances.vp.line[v] = cfg.vp.lines[abb][0]
        instances.vp.specialization_level[v] = ""
        instances.vp.is_control[v] = isinstance(obj, ControlInstance)

        if symbol:
            va.assign_system_object(symbol.value,
                                    state.instances.vp.obj[v],
                                    symbol.offset,
                                    symbol.callpath)

        # If we have some siblings, clone all edges
        to_add = []
        if len(siblings) > 0:
            logger.warning(f"Multiple init calls to same symbol: {obj.symbol}")
            for c in siblings[0].out_edges():
                to_add.append(((v, c.target()), instances.ep.label[c]))
            for c in siblings[0].in_edges():
                # Ignore the syscall that created the siblings
                syscall = getattr(ZEPHYR, state.instances.ep.label[c])
                if not ZEPHYR.syscall_in_category(syscall, SyscallCategory.create):
                    to_add.append(((c.source(), v), instances.ep.label[c]))
            for ((s, t), label) in to_add:
                e = instances.add_edge(s, t)
                instances.ep.label[e] = label
        connect_from_here(state, cpu_id, v, call)

    @staticmethod
    def find_instance_by_symbol(state: OSState, symbol: pyllco.Value):
        """Returns an iterator over all instances with the given symbol"""
        if symbol is None:
            return []
        return filter(lambda v: state.instances.vp.obj[v].symbol == symbol,
                state.instances.vertices())

    @staticmethod
    def add_instance_comm(state: OSState, cpu_id: int, instance, call: str):
        """Adds an interaction (edge) with the given callname to all instances with the given symbol"""
        
        # TODO: Rewrite this code to allow connection of multiple instances 
            #matches = list(ZEPHYR.find_instance_by_symbol(state, symbol))
            #if len(matches) == 0:
            #    logger.error(f"No matching instance found. Skipping.\n{type(symbol)}\n{symbol}")
            #else:
            #    if len(matches) > 1:
            #        logger.warning(f"Multiple matching instances found.\n{[state.instances.vp.id[v] for v in matches][0]}")
            #    for match in matches:
            #        connect_from_here(state, cpu_id, match, call)

        # For now this should work:
        connect_from_here(state, cpu_id, find_instance_node(state.instances, instance), call)

    @staticmethod
    def add_kernel_comm(state: OSState, cpu_id: int, call: str):
        """Adds an interaction (edge) with the given callname to the ZephyrKernel instance"""
        connect_from_here(state, cpu_id, ZEPHYR.kernel, call)

    @staticmethod
    def init(state):
        pass

    @staticmethod
    def get_initial_state(cfg, instances):
        return OSState(cpus=CPUList([CPU(id=0,
                                         irq_on=True,
                                         control_instance=None,
                                         abb=None,
                                         call_path=CallPath(),
                                         exec_state=ExecState.idle,
                                         analysis_context=None)]),
                       instances=instances, cfg=cfg)

    @staticmethod
    def syscall_in_category(syscall, category):
        """Checks wether a syscall interpreter belongs to the given category"""
        syscall_category = syscall.categories
        categories = set((category,))
        return SyscallCategory.every in categories or (syscall_category | categories) == syscall_category

    @staticmethod
    def interpret(graph, state, cpu_id, categories=SyscallCategory.every):
        cfg = graph.cfg
        abb = state.cpus[cpu_id].abb
        syscall_name = cfg.get_syscall_name(abb)
        syscall_name = ZEPHYR.drop_llvm_suffix(syscall_name)
        logger.debug(f"Get syscall: {syscall_name}, ABB: {cfg.vp.name[abb]}"
                     f" (in {cfg.vp.name[cfg.get_function(abb)]})")

        syscall = getattr(ZEPHYR, syscall_name)

        if ZEPHYR.syscall_in_category(syscall, categories):
            logger.info(f"Interpreting syscall: {syscall_name}")
            return syscall(graph, state, cpu_id)
        else:
            state = state.copy()
            state.next_abbs = []
            set_next_abb(state, cpu_id)
            return state

    # k_tid_t k_thread_create(struct k_thread *new_thread, k_thread_stack_t *stack, size_t stack_size, 
    #   k_thread_entry_t entry, void *p1, void *p2, void *p3, int prio, uint32_t options,
    #   k_timeout_t delay)
    @syscall(categories={SyscallCategory.create},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("stack", hint=SigType.symbol, ty=pyllco.Value),
                        Arg("stack_size", hint=SigType.value),
                        Arg("entry", hint=SigType.symbol, ty=pyllco.Function),
                        Arg("p1", hint=SigType.value),
                        Arg("p2", hint=SigType.value),
                        Arg("p3", hint=SigType.value),
                        Arg("priority", hint=SigType.value),
                        Arg("options", hint=SigType.value),
                        Arg("delay", hint=SigType.value)))
    def k_thread_create(graph, state, cpu_id, args, va):
        state = state.copy()
        cfg = graph.cfg

        entry_name = args.entry.get_name()
        entry_params = (args.p1, args.p2, args.p3)

        instance = Thread(
            cpu_id=-1,
            cfg=cfg,
            artificial=False,
            function=cfg.get_function_by_name(entry_name),
            symbol=args.symbol.value,
            stack=args.stack,
            stack_size=args.stack_size,
            entry_name=entry_name,
            entry_params=entry_params,
            priority=args.priority,
            options=args.options,
            delay=args.delay
        )

        ZEPHYR.create_instance(cfg, state, cpu_id, va, "Thread", instance, args.symbol, "k_thread_create")
        return state

    # int irq_connect_dynamic(unsigned int irq, unsigned int priority, 
    #   void (*routine)(const void *parameter), const void *parameter, uint32_t flags)
    @syscall(categories={SyscallCategory.create},
             signature=(Arg("irq_number", hint=SigType.value),
                        Arg("priority", hint=SigType.value),
                        Arg("entry", hint=SigType.symbol, ty=pyllco.Function),
                        Arg("handler_param", hint=SigType.value),
                        Arg("flags", hint=SigType.value)))
    def irq_connect_dynamic(graph, state, cpu_id, args, va): # TODO: Test this syscall
        state = state.copy()
        cfg = graph.cfg

        entry_name = args.entry.get_name()

        instance = ISR(
            cpu_id=-1,
            cfg=cfg,
            artificial=False,
            function=cfg.get_function_by_name(entry_name),
            irq_number=args.irq_number,
            priority=args.priority,
            entry_name=entry_name,
            handler_param=args.handler_param,
            flags=args.flags
        )

        ZEPHYR.create_instance(cfg, state, cpu_id, va, "ISR", instance, None, "irq_connect_dynamic", entry_name)
        return state

    # int k_sem_init(struct k_sem *sem, unsigned int initial_count, unsigned int limit)
    @syscall(categories={SyscallCategory.create},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("count", hint=SigType.value),
                        Arg("limit", hint=SigType.value)))
    def k_sem_init(graph, state, cpu_id, args, va):
        state = state.copy()
        cfg = graph.cfg

        instance = KernelSemaphore(
            args.symbol.value,
            args.count,
            args.limit
        )

        ZEPHYR.create_instance(cfg, state, cpu_id, va, "KernelSemaphore", instance, args.symbol, "k_sem_init")
        return state

    # int sys_sem_init(struct sys_sem *sem, unsigned int initial_count, unsigned int limit)
    @syscall(categories={SyscallCategory.create},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("count", hint=SigType.value),
                        Arg("limit", hint=SigType.value)))
    def sys_sem_init(graph, state, cpu_id, args, va):
        state = state.copy()
        cfg = graph.cfg

        instance = UserSemaphore(
            args.symbol.value,
            args.count,
            args.limit
        )

        ZEPHYR.create_instance(cfg, state, cpu_id, va, "UserSemaphore", instance, args.symbol, "sys_sem_init")
        return state

    # int k_mutex_init(struct k_mutex *mutex)
    @syscall(categories={SyscallCategory.create},
             signature=(Arg("symbol", hint=SigType.instance), ))
    def k_mutex_init(graph, state, cpu_id, args, va):
        state = state.copy()
        cfg = graph.cfg

        instance = Mutex(
            args.symbol.value
        )

        ZEPHYR.create_instance(cfg, state, cpu_id, va, "Mutex", instance, args.symbol, "k_mutex_init")
        return state

    # void k_queue_init(struct k_queue *queue)
    # k_lifo_init(lifo)
    # k_fifo_init(fifo)
    @syscall(categories={SyscallCategory.create},
             signature=(Arg("symbol", hint=SigType.instance), ))
    def k_queue_init(graph, state, cpu_id, args, va):
        state = state.copy()
        cfg = graph.cfg

        instance = Queue(
            args.symbol.value
        )

        ZEPHYR.create_instance(cfg, state, cpu_id, va, "Queue", instance, args.symbol, "k_queue_init")
        return state

    # void k_stack_init(struct k_stack *stack, stack_data_t *buffer, uint32_t num_entries)
    @syscall(categories={SyscallCategory.create},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("buf", hint=SigType.symbol, ty=pyllco.Value),
                        Arg("max_entries", hint=SigType.value)))
    def k_stack_init(graph, state, cpu_id, args, va):
        state = state.copy()
        cfg = graph.cfg

        instance = Stack(
            args.symbol.value,
            args.buf,
            args.max_entries
        )

        ZEPHYR.create_instance(cfg, state, cpu_id, va, "Stack", instance, args.symbol, "k_stack_init")
        return state

    # void k_stack_init(struct k_stack *stack, stack_data_t *buffer, uint32_t num_entries)
    @syscall(categories={SyscallCategory.create},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("buf", ty=pyllco.Value),
                        Arg("max_entries", hint=SigType.value))) # TODO: Check why we do not use the buffer. And override it with max_entries ?
    def k_stack_alloc_init(graph, state, cpu_id, args, va):
        state = state.copy()
        cfg = graph.cfg

        #symbol = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        # TODO: Check why we do not use the buffer. And override it with max_entries ?
        #buf = get_argument(cfg, abb, state.call_path, 1, ty=pyllco.Value)
        #max_entries = get_argument(cfg, abb, state.call_path, 1)

        instance = Stack(
            args.symbol.value,
            # When creating a stack with k_stack_alloc_init() the buffer is created in kernel
            # address space
            None,
            args.max_entries
        )

        ZEPHYR.create_instance(cfg, state, cpu_id, "Stack", instance, args.symbol, "k_stack_alloc_init")
        return state

    # void k_pipe_init(struct k_pipe *pipe, unsigned char *buffer, size_t size)
    @syscall(categories={SyscallCategory.create},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("buf", hint=SigType.symbol, ty=pyllco.Value),
                        Arg("size", hint=SigType.value)))
    def k_pipe_init(graph, state, cpu_id, args, va):
        state = state.copy()
        cfg = graph.cfg

        instance = Pipe(
            args.symbol.value,
            args.size
        )

        ZEPHYR.create_instance(cfg, state, cpu_id, va, "Pipe", instance, args.symbol, "k_pipe_init")
        return state

    # int k_pipe_alloc_init(struct k_pipe *pipe, size_t size)
    @syscall(categories={SyscallCategory.create},
             signature=(Arg("symbol", hint=SigType.instance), 
                        Arg("size", hint=SigType.value)))
    def k_pipe_alloc_init(graph, state, cpu_id, args, va):
        state = state.copy()
        cfg = graph.cfg

        instance = Pipe(
            args.symbol.value,
            args.size
        )

        ZEPHYR.create_instance(cfg, state, cpu_id, va, "Pipe", instance, args.symbol, "k_pipe_alloc_init")
        return state

    # void k_heap_init(struct k_heap *h, void *mem, size_t bytes)
    @syscall(categories={SyscallCategory.create},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("buf", hint=SigType.symbol, ty=pyllco.Value), 
                        Arg("limit", hint=SigType.value)))
    def k_heap_init(graph, state, cpu_id, args, va):
        state = state.copy()
        cfg = graph.cfg

        instance = Heap(
            args.symbol.value,
            args.limit
        )

        ZEPHYR.create_instance(cfg, state, cpu_id, va, "Heap", instance, args.symbol, "k_heap_init")
        return state

    # void k_msgq_init(struct k_msgq *q, char *buffer, size_t msg_size, uint32_t max_msgs)
    @syscall(categories={SyscallCategory.create},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("buf", hint=SigType.symbol, ty=pyllco.Value),
                        Arg("msg_size", hint=SigType.value),
                        Arg("max_msgs", hint=SigType.value)))
    def k_msgq_init(graph, state, cpu_id, args, va):
        state = state.copy()
        cfg = graph.cfg

        instance = MSGQ(
            args.symbol.value,
            args.msg_size,
            args.max_msgs
        )

        ZEPHYR.create_instance(cfg, state, cpu_id, va, "MSGQ", instance, args.symbol, "k_msgq_init")
        return state

    # int k_msgq_alloc_init(struct k_msgq *msgq, size_t msg_size, uint32_t max_msgs)
    @syscall(categories={SyscallCategory.create},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("msg_size", hint=SigType.value),
                        Arg("max_msgs", hint=SigType.value)))
    def k_msgq_alloc_init(graph, state, cpu_id, args, va):
        state = state.copy()
        cfg = graph.cfg

        instance = MSGQ(
            args.symbol.value,
            args.msg_size,
            args.max_msgs
        )

        ZEPHYR.create_instance(cfg, state, cpu_id, va, "MSGQ", instance, args.symbol, "k_msgq_alloc_init")
        return state

    #
    # Syscall.comm
    #

    #
    # Thread
    #

    # int k_thread_join(struct k_thread *thread, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance), 
                        Arg("timeout", hint=SigType.value)))
    def k_thread_join(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_thread_join")
        return state

    # int32_t k_sleep(k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("timeout", hint=SigType.value),))
    def k_sleep(graph, state, cpu_id, args, va):
        state = state.copy()

        add_self_edge(state, cpu_id, "k_sleep")
        return state

    # int32_t k_msleep(int32_t ms)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("ms", hint=SigType.value),))
    def k_msleep(graph, state, cpu_id, args, va):
        state = state.copy()

        add_self_edge(state, cpu_id, "k_msleep")
        return state

    # int32_t k_usleep(int32_t us)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("us", hint=SigType.value),))
    def k_usleep(graph, state, cpu_id, args, va):
        state = state.copy()

        add_self_edge(state, cpu_id, "k_usleep")
        return state

    # void k_busy_wait(uint32_t usec_to_wait)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("us", hint=SigType.value),))
    def k_busy_wait(graph, state, cpu_id, args, va):
        state = state.copy()

        add_self_edge(state, cpu_id, "k_busy_wait")
        return state

    # void k_yield(void)
    @syscall(categories={SyscallCategory.comm})
    def k_yield(graph, state, cpu_id, args, va):
        state = state.copy()

        add_self_edge(state, cpu_id, "k_yield")
        return state

    # void k_wakeup(k_tid_t thread)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("thread", hint=SigType.value), ))
    def k_wakeup(graph, state, cpu_id, args, va):
        state = state.copy()

        add_self_edge(state, cpu_id, "k_wakeup")
        return state

    # k_tid_t k_current_get(void)
    @syscall(categories={SyscallCategory.comm})
             # TODO: find out why this have a signature ?
             #signature=(SigType.value, ))
    def k_current_get(graph, state, cpu_id, args, va):
        state = state.copy()

        # TODO: find out why we try to find a return value here and repair this: 
        #tid = find_return_value(cfg, abb, state.call_path)

        add_self_edge(state, cpu_id, "k_current_get")
        return state


    # k_ticks_t k_thread_timeout_expires_ticks(struct k_thread *t)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),))
    def k_thread_timeout_expires_ticks(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_thread_timeout_expires_ticks")
        return state

    # k_ticks_t k_thread_timeout_remaining_ticks(struct k_thread *t)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),))
    def k_thread_timeout_remaining_ticks(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_thread_timeout_remaining_ticks")
        return state

    # void k_sched_time_slice_set(int32_t slice, int prio)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("time_slice", hint=SigType.value),
                        Arg("prio", hint=SigType.value)))
    def k_sched_time_slice_set(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_kernel_comm(state, cpu_id, "k_sched_time_slice_set")
        return state

    # void k_sched_lock(void)
    @syscall(categories={SyscallCategory.comm})
    def k_sched_lock(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_kernel_comm(state, cpu_id, "k_sched_lock")
        return state

    # void k_sched_unlock(void)
    @syscall(categories={SyscallCategory.comm})
    def k_sched_unlock(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_kernel_comm(state, cpu_id, "k_sched_unlock")
        return state

    # void k_thread_custom_data_set(void *value)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("custom_data", hint=SigType.symbol, ty=pyllco.Value),))
    def k_thread_custom_data_set(graph, state, cpu_id, args, va):
        state = state.copy()

        add_self_edge(state, cpu_id,  "k_thread_custom_data_set")
        return state

    # void *k_thread_custom_data_get(void)
    @syscall(categories={SyscallCategory.comm})
    def k_thread_custom_data_get(graph, state, cpu_id, args, va):
        state = state.copy()

        add_self_edge(state, cpu_id, "k_thread_custom_data_get")
        return state

    #
    # ISR
    #

    # bool k_is_in_isr(void)
    @syscall(categories={SyscallCategory.comm})
    def k_is_in_isr(graph, state, cpu_id, args, va):
        state = state.copy()

        add_self_edge(state, cpu_id, "k_is_in_isr")
        return state

    # int k_is_preempt_thread(void)
    @syscall(categories={SyscallCategory.comm})
    def k_is_preempt_thread(graph, state, cpu_id, args, va):
        state = state.copy()

        add_self_edge(state, cpu_id, "k_is_preempt_thread")
        return state

    # bool k_is_pre_kernel(void)
    @syscall(categories={SyscallCategory.comm})
    def k_is_pre_kernel(graph, state, cpu_id, args, va):
        state = state.copy()

        add_self_edge(state, cpu_id, "k_is_pre_kernel")
        return state

    #
    # Semaphore
    #

    # int k_sem_take(struct k_sem *sem, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("timeout", hint=SigType.value)))
    def k_sem_take(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_sem_take")
        return state

    # void k_sem_give(struct k_sem *sem)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),))
    def k_sem_give(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_sem_give")
        return state

    # void k_sem_reset(struct k_sem *sem)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),))
    def k_sem_reset(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_sem_reset")
        return state

    # unsigned int k_sem_count_get(struct k_sem *sem)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),))
    def k_sem_count_get(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_sem_count_get")
        return state

    # int sys_sem_take(struct sys_sem *sem, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("timeout", hint=SigType.value)))
    def sys_sem_take(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "sys_sem_take")
        return state

    # int sys_sem_give(struct sys_sem *sem)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),))
    def sys_sem_give(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "sys_sem_give")
        return state

    # unsigned int sys_sem_count_get(struct sys_sem *sem)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),))
    def sys_sem_count_get(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "sys_sem_count_get")
        return state

    #
    # Mutex
    #

    # int k_mutex_lock(struct k_mutex *mutex, k_timeout_t timeout)
    # NOTE: The thread that has locked a mutex is eligible for priority inheritance.
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("timeout", hint=SigType.value)))
    def k_mutex_lock(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_mutex_lock")
        return state

    # int k_mutex_unlock(struct k_mutex *mutex)
    # Unlock should only ever be called by the locking thread.
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),))
    def k_mutex_unlock(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_mutex_unlock")
        return state

    #
    # Queue: FIFO and LIFO functions are just macro wrappers around the generic queue functions
    #

    # void k_queue_cancel_wait(struct k_queue *queue)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),))
    def k_queue_cancel_wait(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_queue_cancel_wait")
        return state

    # void k_queue_append(struct k_queue *queue, void *data)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("item", hint=SigType.value)))
    def k_queue_append(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_queue_append")
        return state

    # int32_t k_queue_alloc_append(struct k_queue *queue, void *data)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("item", hint=SigType.value)))
    def k_queue_alloc_append(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_queue_alloc_append")
        return state

    # void k_queue_prepend(struct k_queue *queue, void *data)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("item", hint=SigType.value)))
    def k_queue_prepend(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_queue_prepend")
        return state

    # void k_queue_alloc_prepend(struct k_queue *queue, void *data)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("item", hint=SigType.value)))
    def k_queue_alloc_prepend(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_queue_alloc_prepend")
        return state

    # void k_queue_insert(struct k_queue *queue, void *prev, void *data)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("prev", hint=SigType.value),
                        Arg("item", hint=SigType.value)))
    def k_queue_insert(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_queue_insert")
        return state

    # int k_queue_append_list(struct k_queue *queue, void *head, void *tail)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("head", hint=SigType.value),
                        Arg("tail", hint=SigType.value)))
    def k_queue_append_list(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_queue_append_list")
        return state

    # int k_queue_merge_slist(struct k_queue *queue, sys_slist_t *list)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("other", hint=SigType.symbol)))
    def k_queue_merge_slist(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_queue_merge_list")
        return state

    # void *k_queue_get(struct k_queue *queue, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("into", hint=SigType.value)))
    def k_queue_get(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_queue_get")
        return state

    # bool k_queue_remove(struct k_queue *queue, void *data)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("other", hint=SigType.symbol)))
    def k_queue_remove(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_queue_remove")
        return state

    # bool k_queue_unique_append(struct k_queue *queue, void *data)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("other", hint=SigType.symbol)))
    def k_queue_unique_append(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_queue_unique_append")
        return state

    # int k_queue_is_empty(struct k_queue *queue)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),))
    def k_queue_is_empty(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_queue_is_empty")
        return state

    # void *k_queue_peek_head(struct k_queue *queue)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),))
    def k_queue_peek_head(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_queue_peek_head")
        return state

    # void *k_queue_peek_tail(struct k_queue *queue)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),))
    def k_queue_peek_tail(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_queue_peek_tail")
        return state

    #
    # Stack
    #

    # int k_stack_cleanup(struct k_stack *stack)
    # NOTE: Should only be used if allocated with stack_alloc_init.
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),))
    def k_stack_cleanup(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_stack_cleanup")
        return state

    # int k_stack_push(struct k_stack *stack, stack_data_t data)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("item", hint=SigType.value)))
    def k_stack_push(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_stack_push")
        return state

    # int k_stack_pop(struct k_stack *stack, stack_data_t *data, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("into", hint=SigType.value),
                        Arg("timeout", hint=SigType.value)))
    def k_stack_pop(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_stack_pop")
        return state

    #
    # Pipe
    #

    # int k_pipe_cleanup(struct k_pipe *pipe)
    # NOTE: Should only be used if allocated with pipe_alloc_init.
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),))
    def k_pipe_cleanup(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_pipe_cleanup")
        return state

    # int k_pipe_put(struct k_pipe *pipe, void *data, size_t bytes_to_write, size_t *bytes_written,
    # size_t min_xfer, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, raw_value=True),
                        Arg("item", hint=SigType.symbol, ty=pyllco.Value),
                        Arg("item_size", hint=SigType.value),
                        Arg("bytes_written", hint=SigType.symbol), # Does not really make sense as a value, since at call time this contains garbage
                        Arg("min_bytes_to_write", hint=SigType.value),
                        Arg("timeout", hint=SigType.value)))
    def k_pipe_put(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_pipe_put")
        return state

    # int k_pipe_get(struct k_pipe *pipe, void *data, size_t bytes_to_read, size_t *bytes_read,
    # size_t min_xfer, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("item", hint=SigType.symbol), # X
                        Arg("item_size", hint=SigType.value),
                        Arg("bytes_read", hint=SigType.symbol), # X
                        Arg("min_bytes_to_read", hint=SigType.value), # X
                        Arg("timeout", hint=SigType.value)))
    # TODO: Figure out why those (marked with X) destroy the value analysis
    def k_pipe_get(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_pipe_get")
        return state

    # void k_pipe_block_put(struct k_pipe *pipe, struct k_mem_block *block, size_t size, struct
    # k_sem *sem)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance), 
                        Arg("item", hint=SigType.value),
                        Arg("item_size", hint=SigType.value),
                        Arg("sem", hint=SigType.instance))) # TODO: why was sem index 4 instead of the correct 3 ? (Check this)
    def k_pipe_block_put(graph, state, cpu_id, args, va):
        # This syscall actually works on more than one instance. It writes to a pipe and
        # calls give() on sem (which is OPTIONAL).
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_pipe_block_put")
        # For now just add a k_sem_give from the tread to the given semaphore, if present.
        # This should work, because sem has to be created externally
        
        # TODO: check if None is valid here!
        if args.sem != None:
            ZEPHYR.add_instance_comm(state, cpu_id, args.sem.value, "k_sem_give")

        return state

    # size_t k_pipe_read_avail(struct k_pipe *pipe)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),))
    def k_pipe_read_avail(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_pipe_read_avail")
        return state

    # size_t k_pipe_write_avail(struct k_pipe *pipe)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),))
    def k_pipe_write_avail(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_pipe_write_avail")
        return state

    # void *k_heap_alloc(struct k_heap *h, size_t bytes, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("size", hint=SigType.value),
                        Arg("timeout", hint=SigType.value)))
    def k_heap_alloc(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_heap_alloc")
        return state

    # void k_heap_free(struct k_heap *h, void *mem)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("mem", hint=SigType.symbol))) # TODO: why was mem commented out?
    def k_heap_free(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_heap_free")
        return state

    # void *k_malloc(size_t size)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("size", hint=SigType.value),))
    def k_malloc(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_kernel_comm(state, cpu_id, "k_malloc")
        return state

    # void k_free(void *ptr)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("mem", hint=SigType.symbol),))
    def k_free(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_kernel_comm(state, cpu_id, "k_free")
        return state

    # void *k_calloc(size_t nmemb, size_t size)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("num_elements", hint=SigType.value),
                        Arg("element_size", hint=SigType.value)))
    def k_calloc(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_kernel_comm(state, cpu_id, "k_calloc")
        return state

    # int k_msgq_cleanup(struct k_msgq *msgq)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),))
    def k_msgq_cleanup(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_msgq_cleanup")
        return state

    # int k_msgq_put(struct k_msgq *msgq, const void *data, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("item", hint=SigType.symbol, ty=pyllco.Value),
                        Arg("timeout", hint=SigType.value)))
    def k_msgq_put(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_msgq_put")
        return state

    # int k_msgq_get(struct k_msgq *msgq, void *data, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("item", hint=SigType.symbol, ty=pyllco.Value),
                        Arg("timeout", hint=SigType.value)))
    def k_msgq_get(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_msgq_get")
        return state

    # int k_msgq_peek(struct k_msgq *msgq, void *data)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("item", hint=SigType.symbol, ty=pyllco.Value)))
    def k_msgq_peek(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_msgq_peek")
        return state

    # void k_msgq_purge(struct k_msgq *msgq)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),))
    def k_msgq_purge(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_msgq_purge")
        return state

    # uint32_t k_msgq_num_free_get(struct k_msgq *msgq)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),))
    def k_msgq_num_free_get(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_msgq_num_free_get")
        return state

    # void k_msgq_get_attrs(struct k_msgq *msgq, struct k_msgq_attrs *attrs)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("attributes", hint=SigType.symbol, ty=pyllco.Value)))
    def k_msgq_get_attrs(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_msgq_get_attrs")
        return state


    # uint32_t k_msgq_num_used_get(struct k_msgq *msgq)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),))
    def k_msgq_num_used_get(graph, state, cpu_id, args, va):
        state = state.copy()

        ZEPHYR.add_instance_comm(state, cpu_id, args.symbol.value, "k_msgq_num_used_get")
        return state

