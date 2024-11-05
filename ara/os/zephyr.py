# SPDX-FileCopyrightText: 2021 Kenny Albes
# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2022 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

from ara.steps.instance_graph_stats import MissingInteractions
from .os_util import (
    UnknownArgument,
    AutoDotInstance,
    Arg,
    syscall,
    set_next_abb,
    connect_from_here,
    connect_instances,
    add_self_edge,
    find_instance_node,
    find_return_value
)
from .os_base import OSBase, ControlInstance, CPUList, CPU, OSState, ExecState, TaskStatus, ControlContext, IRQ
from ara.util import get_logger
from ara.graph import SyscallCategory, SigType, CallPath, CFG, Graph
from ara.steps import get_native_component
# from ara.stepmanager import StepManager
from dataclasses import dataclass, field
from graph_tool import Vertex
from enum import IntEnum
from collections.abc import Iterable

import pyllco
import html
import re
import copy
from ara.steps.cfg_traversal import AnalysisContext

from collections import defaultdict
from typing import Iterator, List, Annotated
import attr

from pyirinterpreter import PyIRModuleInterpreter
from diff import diff
from proxy import PTR
import zephyr # irx.zephyr (in future: generated)

import ara.os.zephyr_adapters as za
from ara.os.zephyr_adapters import ThreadContext
from ara.os.zephyr_interpreter import ZephyrInterpreter


logger = get_logger("Zephyr")
ValueAnalyzer = get_native_component("ValueAnalyzer")
ValueAnalyzerResult = get_native_component("ValueAnalyzerResult")



class ZephyrOptions:
    """This static class contains the values of all OS Model options.

    All options can be set as step options for ZephyrStaticPost.
    """
    enable_missing_interaction_count: bool = None


@dataclass(eq=False)
class ZephyrInstance(AutoDotInstance):
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

    wanted_attrs = ["heap_size"]
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#e1d5e7",
        "color": "#9673a6",
        "style": "filled"
    }

    queue: int = 0

    def __hash__(self):
        return hash(("ZephyrKernel", self.heap_size, self.symbol, self.queue))


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
    # Name of the thread
    name: str

    # Where will the thread start from?
    start_in_init: bool = field(default=True)

    wanted_attrs = ["entry_name", "stack_size", "priority", "options", "delay"]
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#dae8fc",
        "color": "#6c8ebf",
        "style": "filled"
    }

    def __hash__(self):
        return hash(("Thread", self.function, self.artificial, self.symbol, self.stack, self.stack_size,
        self.entry_name, self.entry_params, self.priority, self.options, self.delay))


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

    wanted_attrs = ["irq_number", "priority", "entry_name", "flags"]
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#dae8fc",
        "color": "#6c8ebf",
        "style": "filled"
    }

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

    wanted_attrs = ["count", "limit"]
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#f8cecc",
        "color": "#b85450",
        "style": "filled"
    }

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

    wanted_attrs = []
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#f8cecc",
        "color": "#b85450",
        "style": "filled"
    }

    def __hash__(self):
        return hash(("Mutex", self.symbol))


class QueueType(IntEnum):
    normal = 0
    lifo = 1
    fifo = 2


# The zephyr kernel offers two kinds of queues: FIFO and LIFO which both use queues internally
# They are created via separate "functions" k_{lifo,fifo}_init
# Both of those are just macros wrapping the actual k_queue_init syscall which makes them
# hard to detect. For now, we do not differentiate between types of queues in dynamic detection. Static detection will work.
# On a positive note, since these are macros no action is needed to make ARA detect the
# underlying k_queue_init sycalls. Were they functions, they might not be contained in libapp
# TODO: Think about detection of lifo and fifo queues.
@dataclass
class Queue(ZephyrInstance):
    # The k_queue object
    symbol: object
    # Queue type. Attention: Currently this field is only set for static initialized Queues.
    queue_type: QueueType
    # A fake getElementPtr (this one is not available in LLVM IR) with offset 0 from this Queue.
    # This field is only set for static Queues.
    # We need this field to assign static lifo/fifo-Queues directly to k_queue LLVM value instead of k_lifo/k_fifo in ZephyrStaticPost.
    fake_gep: pyllco.GetElementPtrInst

    wanted_attrs = []
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#f8cecc",
        "color": "#b85450",
        "style": "filled"
    }

    def __hash__(self):
        return hash(("Queue", self.symbol, self.queue_type, self.fake_gep))


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

    wanted_attrs = ["max_entries"]
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#f8cecc",
        "color": "#b85450",
        "style": "filled"
    }

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

    wanted_attrs = ["size"]
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#f8cecc",
        "color": "#b85450",
        "style": "filled"
    }

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

    wanted_attrs = ["limit"]
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#f8cecc",
        "color": "#b85450",
        "style": "filled"
    }

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

    wanted_attrs = ["msg_size", "max_msgs"]
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#f8cecc",
        "color": "#b85450",
        "style": "filled"
    }

    def __hash__(self):
        return hash(("MSGQ", self.symbol, self.msg_size, self.max_msgs))


class ZephyrEdgeType(IntEnum):
    interaction = 0
    create = 1

    """Special edge type to show that an instance has the same symbol than the instance this edge is pointing to."""
    same_symbol_than = 2







class Zephyr(OSBase):
    '''
        Vertex and edge properties:
        vertex_properties = [('label', 'string', 'instance name'),
                            ('obj', 'object', 'instance object (e.g. Task)'),
                            ]
        edge_properties = [('label', 'string', 'syscall name')]
    '''

    """type class of interactions.

    This object is accessed by instance_graph.py test script to translate the integer value to a string.
    """
    EdgeType = ZephyrEdgeType

    """The kernel node"""
    kernel = None

    """A dict<str, int> that stores the number of times an identifier was requested."""
    id_count = {}

    """Current LLVM-IR File (hacky way)"""
    llvm_ir_file = ""

    """ should sse run? """
    enable_sse = False

    """ idle threads map: cpu_id -> vertex of thread """
    idle_threads = {}

    @staticmethod
    def get_special_steps():
        return ["ZephyrStaticPost", "LoadKernelLL"]

    @staticmethod
    def has_dynamic_instances():
        return True

    @staticmethod
    def get_unique_id(ident: str) -> str:
        """Generate a unique id by taking the actual one and appending a number to deduplicate"""
        count = Zephyr.id_count.get(ident)
        if count is None:
            Zephyr.id_count[ident] = 1
        else:
            Zephyr.id_count[ident] = count + 1
            ident = f"{ident}.{count}"

        return ident

    @staticmethod
    def get_symbol(value: ValueAnalyzerResult) -> pyllco.Value:
        """Get symbol of ValueAnalyzerResult"""
        return value.value.symbol if isinstance(value.value, ZephyrInstance) else value.value

    @staticmethod
    def create_instance(cfg: CFG, state: OSState, cpu_id: int, va: ValueAnalyzer, label: str, obj: ZephyrInstance, symbol: ValueAnalyzerResult, call: str, ident: str = None):
        """
        Adds a new instance and an edge for the create syscall to the instance graph.
        If there already exists an instance that is matched to the same symbol another one will be
        created and will inherit all interactions from his siblings. All future comm syscalls will
        add edges to all instances that share the same symbol. There is currently no way to
        distinguish between them. Those rules also apply to instances that add entry points (Thread, ISR).
        If you have an instance that has no symbol field (e.g. ISR), set symbol to None and provide an identifier string via ident instead."""
        if ident is None:
            if symbol is not None:
                ident = Zephyr.get_symbol(symbol).get_name()
            else:
                assert False, "ident and symbol are both None!"

        instances = state.instances
        v = instances.add_vertex()
        instances.vp.label[v] = label
        instances.vp.obj[v] = obj
        instances.vp.id[v] = Zephyr.get_unique_id(ident)

        cpu = state.cpus[cpu_id]
        abb = cpu.abb
        ana_context = cpu.analysis_context

        if isinstance(ana_context, AnalysisContext):
            instances.vp.branch[v] = ana_context.branch
            instances.vp.loop[v] = ana_context.loop
            instances.vp.recursive[v] = ana_context.recursive
            instances.vp.usually_taken[v] = ana_context.usually_taken
            # Creating an instance from a thread that is not unique will result in a non unique instance
            instances.vp.unique[v] = (not (ana_context.branch or ana_context.loop or ana_context.recursive)) and instances.vp.unique[cpu.control_instance]
        instances.vp.after_scheduler[v] = True # In Zephyr the scheduler is always on for dynamic instances
        instances.vp.soc[v] = abb
        instances.vp.llvm_soc[v] = cfg.vp.llvm_link[cfg.get_single_bb(abb)]
        instances.vp.file[v] = cfg.vp.files[abb][0]
        instances.vp.line[v] = cfg.vp.lines[abb][0]
        instances.vp.specialization_level[v] = ""
        instances.vp.is_control[v] = isinstance(obj, ControlInstance)

        # Ignore the steps below for instances that have no symbol (e.g. ISR)
        if symbol is None:
            return

        if isinstance(symbol.value, pyllco.Value):
            from ara.steps import get_native_component # avoid dependency conflicts, therefore import dynamically
            ValuesUnknown = get_native_component("ValuesUnknown")
            try:
                va.assign_system_object(symbol.value,
                                        state.instances.vp.obj[v],
                                        symbol.offset,
                                        symbol.callpath)
            except ValuesUnknown as va_unknown_exc:
                logger.warning(f"ValueAnalyzer could not assign Instance {obj} to argument {symbol}. Exception: \"{va_unknown_exc}\"")
                return
        else:
            if type(symbol) == UnknownArgument:
                logger.warning(f"ValueAnalyzer could not assign Instance {obj} to argument. ValueAnalyzer exception: \"{symbol.exception}\" ")
            assert isinstance(symbol.value, ZephyrInstance), "symbol.value does not hold a ZephyrInstance!"
            # If we have some siblings, clone all edges
            logger.warning(f"Multiple init calls to same symbol: {obj.symbol}")
            assert obj.symbol == symbol.value.symbol
            predecessor_v = find_instance_node(state.instances, symbol.value)
            to_add = []
            for c in predecessor_v.out_edges():
                edge_type = state.instances.ep.type[c]
                edge_abb = state.instances.ep.syscall[c]
                if not edge_type == ZephyrEdgeType.same_symbol_than:
                    to_add.append(((v, c.target()), instances.ep.label[c], edge_type, edge_abb))
            for c in predecessor_v.in_edges():
                # Ignore syscalls that created the predecessor
                edge_type = state.instances.ep.type[c]
                edge_abb = state.instances.ep.syscall[c]
                if edge_type == ZephyrEdgeType.interaction:
                    to_add.append(((c.source(), v), instances.ep.label[c], edge_type, edge_abb))
            for ((s, t), label, edge_type, edge_abb) in to_add:
                connect_instances(instances, v, s, edge_abb, label, ty=edge_type)
            # Same symbol edge
            connect_instances(instances, v, predecessor_v, abb, "same symbol than", ty=ZephyrEdgeType.same_symbol_than)

        connect_from_here(state, cpu_id, v, call, ty=ZephyrEdgeType.create)

        return v

    @staticmethod
    def find_instance_by_symbol(state: OSState, symbol: pyllco.Value) -> Vertex:
        """Returns an iterator over all instance vertices with the given symbol"""
        if symbol is None:
            return []
        return filter(lambda v: state.instances.vp.obj[v].symbol == symbol,
                state.instances.vertices())

    @staticmethod
    def _missing_interaction(state: OSState, cpu_id: int, expected_instance: str):
        cpu = state.cpus[cpu_id]
        if expected_instance == None:
            logger.error("Fatal error: missing interaction and no expected_instance set in add_instance_comm(). Now we have undetected missing interactions!")
            MissingInteractions.add_undetected()
            return
        if ZephyrOptions.enable_missing_interaction_count:
            MissingInteractions.add(expected_instance, cpu.abb)
        # luckily we do not need add_imprecise() currently in Zephyr.

    @staticmethod
    def add_instance_comm(state: OSState, cpu_id: int, symbol: ValueAnalyzerResult, call: str, expected_instance: str=None):
        """Adds an interaction (edge) with the given callname to all instances with the given symbol"""
        if type(symbol) == UnknownArgument:
            logger.error(f"No matching instance for {call}() found. ValueAnalyzer Exception: \"{symbol.exception}\". Skipping.")
            Zephyr._missing_interaction(state, cpu_id, expected_instance)
            return
        instance = symbol.value if type(symbol) == ValueAnalyzerResult else symbol
        if not isinstance(instance, ZephyrInstance):
            logger.error(f"No matching instance for {call}() found. Skipping.")
            Zephyr._missing_interaction(state, cpu_id, expected_instance)
            return
        if not hasattr(instance, "symbol"):
            logger.error(f"Instance of type {type(instance)} from {call}() has no \"symbol\" field. "
            "add_instance_comm() can not work with this instance. Skipping.")
            Zephyr._missing_interaction(state, cpu_id, expected_instance)
            return

        matches = list(Zephyr.find_instance_by_symbol(state, instance.symbol))
        if len(matches) == 0:
            logger.error(f"No matching instance for {call}() found. Skipping.\n{type(instance.symbol)}\n{instance.symbol}")
            Zephyr._missing_interaction(state, cpu_id, expected_instance)
        else:
            if len(matches) > 1:
                logger.warning(f"Multiple matching instances found: {[state.instances.vp.id[v] for v in matches]}")
            for match in matches:
                connect_from_here(state, cpu_id, match, call, ty=ZephyrEdgeType.interaction)

    @staticmethod
    def add_kernel_comm(state: OSState, cpu_id: int, call: str):
        """Adds an interaction (edge) with the given callname to the ZephyrKernel instance"""
        connect_from_here(state, cpu_id, Zephyr.kernel, call, ty=ZephyrEdgeType.interaction)

    @staticmethod
    def get_thread_ccs(state) -> Iterator[ThreadContext]:
        """get all instance threads ThreadContext"""
        threads = [(v, obj) for v, obj in state.instances.get(Thread)]
        for v, obj in threads:
            if obj not in state.context:
                logger.warning("Tried to access non available context: %s", obj.entry_name)
                # thread may not be created yet
                continue
            yield state.context[obj]

    @staticmethod
    def debug_print_threads(state, vertices_thread_map = {}):
        for v, obj in state.instances.get(Thread):
            if obj in state.context:
                ctx = state.context[obj]
                status_name = TaskStatus(ctx.status).name
                index = state.instances.vertex_index[v]
                ptr = 0
                if v in vertices_thread_map:
                    ptr = vertices_thread_map[v]
                ts = za.ThreadStateAdapter(ctx.thread_state).name
                print(index, obj.name, obj.entry_name, status_name, hex(ptr), ptr, ctx.thread_state, ts)

    @staticmethod
    def get_kernel_context(state) -> za.ZephyrKernelContext:
        # return state.context[state.instances.vp.obj[Zephyr.kernel]]
        return state.context[Zephyr.kernel]
    
    @staticmethod
    def set_kernel_context(state, kernel):
        # state.context[state.instances.vp.obj[Zephyr.kernel]] = kernel
        state.context[Zephyr.kernel] = kernel

    @staticmethod
    def get_initial_state(cfg, instances):
        running_tasks = []
        cpu_id = 0
        threads = [(v, obj) for v, obj in instances.get(Thread) if obj.start_in_init]

        prio_vert, prio_thread = None, None

        if Zephyr.config['CONFIG_SCHED_DUMB']:
            # start with main thread, because it is the first one spawnig
            threads.sort(key=lambda t: t[1].priority, reverse=True)
            threads.sort(key=lambda t: int(t[1].entry_name != "main")) # move main to front
            prio_vert, prio_thread = threads[0]
            # ready_q_iter = ready_q_dumb_iter() # no need for special iterators, as kernel will decide (restores sorting on requeue)
        elif Zephyr.config['CONFIG_SCHED_SCALABLE']:
            raise NotImplementedError
        elif Zephyr.config['CONFIG_SCHED_MULTIQ']:
            # ready_q_iter = ready_q_multiq_iter() # no need for special iterators, as kernel will decide (restores sorting on requeue)
            raise NotImplementedError
        else:
            prio_vert, prio_thread = max(threads, key=lambda t: t[1].priority)
            # raise RuntimeError("no scheduler configured")
            logger.warning("no scheduler configured in kconfig")

        if prio_vert == None or prio_thread == None:
            raise RuntimeError("First starting thread not found")




        entry_abb = cfg.get_entry_abb(prio_thread.function)

        n_cpus = int(Zephyr.config['CONFIG_MP_MAX_NUM_CPUS'])

        assert n_cpus == 1

        cpus = [
            CPU(
                id=cpu_id,
                irq_on=True,
                control_instance=prio_vert,
                abb=entry_abb,
                call_path=CallPath(),
                exec_state=ExecState.from_abbtype(cfg.vp.type[entry_abb]),
                analysis_context=None,
            )
        ]

        running_tasks.append(prio_thread)

        # logger.debug(
        #     f"Initial: Choose {instances.vp.obj[instances.vertex(prio_vert)]} for CPU {cpu_id}."
        # )

        logger.debug(f"CFG: {cfg}")

        state = OSState(cpus=CPUList(cpus), instances=instances, cfg=cfg)

        Zephyr.set_kernel_context(state, za.ZephyrKernelContext())
        kernel = Zephyr.get_kernel_context(state)
        kernel.cache = prio_vert


        for v, obj in threads:
            # FIXME: Actual the thread entry is wrapped by z_thread_entry
            # something like: abb=cfg.get_entry_abb(z_thread_entry(obj.function, p1, p2, p3))
            # z_thread_entry = cfg.get_function_by_name("__ara_mock_z_thread_entry") # "z_thread_entry"
            # entry = obj.z_thread_entry
            entry = obj.function
            abb = cfg.get_entry_abb(entry)
            # if cfg.has_abbs(entry):
            #     abb = cfg.get_entry_abb(entry)

            logger.debug(f"instances: cpu_id:{v} obj:{obj}")
            logger.debug(f"instances: function:{obj.function}")
            prio = obj.priority

            status = TaskStatus.ready

            state.context[obj] = ThreadContext(
                status=status,
                abb=abb,
                call_path=CallPath(),
                dyn_prio=[prio],
                # thread_state=za.ThreadStateAdapter(0)
            )

            kernel.ready_q.append(v)

            obj.cpu_id = 0 # put everything on the first cpu

        for task in running_tasks:
            ctx = state.context[task]
            ctx.status = TaskStatus.running
            ctx.abb = None
            ctx.call_path = CallPath()

        for cpu in cpus:
            idle_thread_vertex = Zephyr.idle_threads[cpu.id]
            obj = state.instances.vp.obj[idle_thread_vertex]
            state.context[obj] = ThreadContext(
                status=TaskStatus.ready,
                abb=None, # don't schedule on idle thread
                call_path=CallPath(),
                dyn_prio=[obj.priority],
            )

        # task_to_shed = running_tasks
        # for cpu in cpus:
        #     task = task_to_shed.pop()
        #     if task is None:
        #         break
        #     task.cpu_id = cpu.id

        Zephyr.debug_print_threads(state)


        za.InterpreterContext.Zephyr = Zephyr
        za.InterpreterContext.config = Zephyr.config

        return state

    @staticmethod
    def is_interaction(ty) -> bool:
        return ty in [ZephyrEdgeType.interaction, ZephyrEdgeType.create, 0]

    @staticmethod
    def handle_exit(graph: Graph, state: OSState, cpu_id: int):
        # we do not handle Interrupts in a special way currently
        return []

    @staticmethod
    def syscall_in_category(syscall, categories):
        """Checks wether a syscall interpreter belongs to the given category"""
        syscall_category = syscall.categories
        if isinstance(categories, SyscallCategory):
            categories = set((categories,))
        return SyscallCategory.every in categories or (syscall_category | categories) == syscall_category
        #eval = SyscallCategory.every in categories or (syscall_category | categories) == syscall_category
        #print(eval)
        #ret = SyscallCategory.every in categories
        #ret1 = SyscallCategory.every not in categories
        ## ret2 = (syscall_category | categories) == syscall_category
        ## ret3 = syscall_category | categories != syscall_category
        ## print(ret, ret2, ret3)
        #print(ret, ret1)
        #
        #if SyscallCategory.every not in categories:
        #    if syscall_category | categories != syscall_category:
        #        return False
        #return True

    @staticmethod
    def interpret(graph, state, cpu_id, categories=None):
        if not categories:
            categories = {SyscallCategory.every}
        cfg = graph.cfg
        abb = state.cpus[cpu_id].abb
        syscall_name = cfg.get_syscall_name(abb)
        logger.debug(f"Get syscall: {syscall_name}, ABB: {cfg.vp.name[abb]}"
                     f" (in {cfg.vp.name[cfg.get_function(abb)]})")

        syscall = getattr(Zephyr, syscall_name)

        if Zephyr.syscall_in_category(syscall, categories):
            logger.info(f"Interpreting syscall: {syscall_name}")
            new_states = syscall(graph, state, cpu_id)
            if isinstance(new_states, Iterable):
                return new_states
            return [new_states]
        else:
            state = state.copy()
            state.next_abbs = []
            set_next_abb(state, cpu_id)
            return [state]

    @staticmethod
    def schedule(state, cpus=None):
        if cpus is None:
            cpus = [cpu.id for cpu in state.cpus]

        logger.debug(f"Scheduling state {state} on CPUs: {cpus}")
        # logger.warn(f"state: {state}")
        # logger.warn(f"context: {state.context}")

        Zephyr.debug_print_threads(state)

        kernel = Zephyr.get_kernel_context(state)

        # if len(kernel.ready_q) <= 0:
        #     logger.warning(f"no thread in ready list")
        #     return
        # new_vertex = kernel.ready_q[0]

        if kernel.cache is None:
            logger.warning("no thread in set in cache")
            return

        if len(kernel.ready_q) <= 0:
            logger.warning("no threads in ready list")
            za.InterpreterContext.sys_clock_announce(state, 0) # trigger a timeout from the list

        new_vertex = kernel.cache

        cpu_id = 0
        # if the idle thread is active (new_vertex = idle_thread) -> activate next timeout in queue
        if new_vertex == Zephyr.idle_threads[cpu_id]:
            logger.debug("no threads in ready list -> fire timeout")

            if len(kernel.timeout_list) > 0:
                logger.debug("found queued timeout")


        for cpu_id in cpus:
            cpu_ctx = state.cpus[cpu_id].analysis_context
            if cpu_ctx:
                logger.debug(f"cpu {cpu_id}: interpreter _kernel.cpus[{cpu_id}].current ->"
                             f" {cpu_ctx.current}")

        for cpu in filter(lambda cpu: cpu.id in cpus, state.cpus):
            logger.warning(f"cpu.id: {cpu.id}")

            assert cpu.id == 0 # only support one cpu

            new_vertex = state.instances.vertex(new_vertex)
            new_label = state.instances.vp.label[new_vertex]
            new_obj = state.instances.vp.obj[new_vertex]
            new_entry_name = new_obj.entry_name
            new_ctx = state.context[new_obj]

            # not coming from idle
            if cpu.control_instance:
                old_vertex = state.instances.vertex(cpu.control_instance)
                old_task = state.instances.vp.obj[old_vertex]
                old_label = state.instances.vp.label[old_vertex]
                old_entry_name = old_task.entry_name
            else:
                old_vertex = None
                old_task = None
                old_label = "Idle state"
                old_entry_name = None

            logger.debug(
                f"Schedule on CPU {cpu.id}: " f"From {old_label}({old_entry_name}) " f"to {new_label}({new_entry_name})"
            )

            # shortcut for same task
            if new_vertex == old_vertex:
                old_abb = cpu.abb
                new_abb = None if new_ctx is None else new_ctx.abb
                if old_abb == new_abb:
                    logger.debug(
                        "CPU %s: Skip schedule, since the task is the same.", cpu.id
                    )
                    continue

            # write old values back to instance only if running or blocked
            if old_vertex:
                old_ctx = state.context[old_task]
                #if old_ctx.status in [TaskStatus.running, TaskStatus.blocked, TaskStatus.terminated]:
                old_ctx.abb = state.cfg.vertex(cpu.abb)
                old_ctx.call_path = cpu.call_path
                if old_ctx.status == TaskStatus.running:
                    old_ctx.status = TaskStatus.ready


            if new_vertex:
                cpu.abb = state.cfg.vertex(new_ctx.abb)
                cpu.call_path = new_ctx.call_path
                new_ctx.status = TaskStatus.running
                # "reset" context values, they are irrelevant now
                new_ctx.abb = None
                new_ctx.call_path = CallPath()

                cpu.control_instance = state.instances.vertex(new_vertex)
                cpu.exec_state = ExecState.from_abbtype(state.cfg.vp.type[cpu.abb])
            else:
                cpu.abb = None
                cpu.call_path = CallPath()
                cpu.control_instance = None
                cpu.exec_state = ExecState.idle
            

            # TODO: if is exit (get_exit_abb), call k_thread_abort()

        Zephyr.debug_print_threads(state)


    @staticmethod
    def handle_exit(graph, state, cpu_id):
        state = state.copy()
        # handle only IRQs
        # isr = state.cur_control_inst(cpu_id)
        # if isinstance(isr, ISR):
        #     # an ISR exit is like a TerminateTask
        #     new_state = state.copy()
        #     new_state.context[isr] = # TODO
        #     return [new_state]

        kernel = Zephyr.get_kernel_context(state)

        # if kernel.cache != Zephyr.idle_threads[cpu_id]:
        #     new_state = state.copy()
        #     return [new_state]



        v = state.cpus[cpu_id].control_instance
        

        ic = za.InterpreterContext(state, cpu_id)
        proxy = ic.proxy
        thread_ptr = ic.vertices_thread_map[v]
        thread = proxy.deref(PTR(zephyr.k_thread, thread_ptr))
        join_queue = proxy.get_member(thread, ['join_queue', 'waitq']) # if not config['CONFIG_WAITQ_SCALABLE']
        proxy.get(join_queue)

        # old_threads = [copy.copy(x) for x in ic.threads]
        # old_threads = [copy.copy(x) for x in Zephyr.get_thread_ccs(state)]

        # ic.zi.irm.set_print_llvmir(True)
        ic.zi.irm.stop(["arch_swap"])
        ic.zi.irm.skip(["clear_halting"])
        # ic.zi.run_function("z_thread_abort", [thread_ptr], ['PTR'])
        ic.zi.run_function("z_unpend_all", [join_queue.ptr], ['PTR'])
        # ic.zi.run_function("unpend_thread_no_timeout", [join_queue.ptr], ['PTR'])
        # ic.zi.run_function("update_cache", [0], ['APInt32'])

        # if ic.zi.irm.getCurrentCallFunctionName() == "arch_swap":
        #     ic.zi.irm.putReturnValue(0, 'APInt32') # emulate that the callee returned 0

        # ic.zi.irm.set_print_llvmir(False)
        ic.update()

        Zephyr.debug_print_threads(state, ic.vertices_thread_map)


        # for i, t in enumerate(Zephyr.get_thread_ccs(state)):
        #     changes = diff(old_threads[i], t)
        #     for x in changes:
        #         print(f"{x.path_str():30s}: {x.obj1} => {x.obj2}")

        if kernel.cache != Zephyr.idle_threads[cpu_id]:
            cur = state.cpus[cpu_id].control_instance

            add_self_edge(state, cpu_id, "k_thread_abort", ty=ZephyrEdgeType.interaction)

            return [state]

        return []

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
                        Arg("delay", hint=SigType.value))) # TODO: Allow interpretation of delay type (This is a macro controlled struct type)
    def k_thread_create(graph, state, cpu_id, args, va):
        state = state.copy()
        cfg = graph.cfg

        entry_name = args.entry.get_name()
        entry_params = (args.p1, args.p2, args.p3)

        # instance = state.instances.get_node(args.symbol.value)

        instance = None

        if isinstance(args.symbol.value, Thread):
            instance = args.symbol.value

        # instance = va.get_assignments(args.symbol.value)

        if instance is None:
            instance = Thread(
                # cpu_id=-1,
                cpu_id=0,
                cfg=cfg,
                artificial=False,
                function=cfg.get_function_by_name(entry_name), # fixme: z_thread_entry
                symbol=Zephyr.get_symbol(args.symbol),
                stack=args.stack,
                stack_size=args.stack_size,
                entry_name=entry_name,
                entry_params=entry_params,
                priority=args.priority,
                options=args.options,
                delay=args.delay,
                name="",
                start_in_init=False
            )

            logger.debug("k_thread_create: %s", instance.entry_name)

            v = Zephyr.create_instance(cfg, state, cpu_id, va, "Thread", instance, args.symbol, "k_thread_create")

        if Zephyr.enable_sse:

            # z_impl_k_thread_create
            #  z_setup_new_thread
            #   setup_thread_stack
            #  schedule_new_thread

            ic = za.InterpreterContext(state, cpu_id)
            zi = ic.zi
            irm = zi.irm
            proxy = zi.proxy

            #thread = proxy.Global(zephyr.k_thread, args.symbol.value.symbol.get_name())
            # stack = proxy.Global(zephyr.stack?, args.stack.value.symbol.get_name()) # don't need a stack anyway...
            # entry = args.entry.get_name() # won't run anyway...

            # ic.threads.append(thread)
            # threads_map[thread.ptr] = args.symbol.value
            # threads_vertex_map[thread.ptr] = find_instance_node(state.instances, args.symbol)
            # threads_vertex_map[thread.ptr] = v
            # threads = [(v, obj) for v, obj in state.instances.get(Thread) if not obj.start_in_init]
            v = state.instances.get_node(args.symbol.value)
            # ic.threads_vertex_map[thread.ptr] = v

            thread = PTR(zephyr.k_thread, ic.vertices_thread_map[v])

            irx_args = [
                thread.ptr,
                0,
                args.stack_size,
                0,
                0,
                0,
                0,
                args.priority,
                args.options,
                args.delay,
            ]

            type_hints = [
                'PTR',                  # struct k_thread *new_thread,
			    'PTR',                  # k_thread_stack_t *stack,
			    'APInt32',              # size_t stack_size,
                'PTR',                  # k_thread_entry_t entry,
			    'PTR', 'PTR', 'PTR',    # void *p1, void *p2, void *p3,
			    'APInt32',              # int prio,
                'APInt32',              # uint32_t options,
                'APInt64',              # k_timeout_t delay
            ]

            irm.stop(["arch_swap"])
            irm.skip(['arch_new_thread'])
            zi.run_function("z_impl_k_thread_create", irx_args, type_hints)

            if irm.getCurrentCallFunctionName() == "arch_swap":
                irm.putReturnValue(0, 'APInt32') # emulate that the callee returned 0

            zi.finish_function()

            # if cfg.has_abbs(instance.function): # ABB only available in SSE, but not in SIA ?
            status = TaskStatus.ready
            prio = instance.priority
            entry_abb = cfg.get_entry_abb(instance.function)

            state.context[instance] = ThreadContext(
                status=status,
                abb=entry_abb,
                call_path=CallPath(),
                dyn_prio=[prio],
            )

            ic.threads_map[thread.ptr] = state.context[instance]

            ic.update()

        return state

    # int irq_connect_dynamic(unsigned int irq, unsigned int priority,
    #   void (*routine)(const void *parameter), const void *parameter, uint32_t flags)
    @syscall(categories={SyscallCategory.create},
             signature=(Arg("irq_number", hint=SigType.value),
                        Arg("priority", hint=SigType.value),
                        Arg("entry", hint=SigType.symbol, ty=pyllco.Function),
                        Arg("handler_param", hint=SigType.value),
                        Arg("flags", hint=SigType.value)))
    def irq_connect_dynamic(graph, state, cpu_id, args, va):
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

        Zephyr.create_instance(cfg, state, cpu_id, va, "ISR", instance, None, "irq_connect_dynamic", entry_name)
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
            Zephyr.get_symbol(args.symbol),
            args.count,
            args.limit
        )

        Zephyr.create_instance(cfg, state, cpu_id, va, "KernelSemaphore", instance, args.symbol, "k_sem_init")

        # set_next_abb(state, cpu_id)

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
            Zephyr.get_symbol(args.symbol),
            args.count,
            args.limit
        )

        # TODO if needed sem has a wait queue kernel/sem.c:58

        Zephyr.create_instance(cfg, state, cpu_id, va, "UserSemaphore", instance, args.symbol, "sys_sem_init")
        return state

    # int k_mutex_init(struct k_mutex *mutex)
    @syscall(categories={SyscallCategory.create},
             signature=(Arg("symbol", hint=SigType.instance), ))
    def k_mutex_init(graph, state, cpu_id, args, va):
        state = state.copy()
        cfg = graph.cfg

        instance = Mutex(
            Zephyr.get_symbol(args.symbol)
        )

        Zephyr.create_instance(cfg, state, cpu_id, va, "Mutex", instance, args.symbol, "k_mutex_init")
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
            Zephyr.get_symbol(args.symbol),
            QueueType.normal.value,
            None
        )

        Zephyr.create_instance(cfg, state, cpu_id, va, "Queue", instance, args.symbol, "k_queue_init")
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
            Zephyr.get_symbol(args.symbol),
            args.buf,
            args.max_entries
        )

        Zephyr.create_instance(cfg, state, cpu_id, va, "Stack", instance, args.symbol, "k_stack_init")
        return state

    # int32_t k_stack_alloc_init(struct k_stack *stack, uint32_t num_entries)
    @syscall(categories={SyscallCategory.create},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("max_entries", hint=SigType.value)))
    def k_stack_alloc_init(graph, state, cpu_id, args, va):
        state = state.copy()
        cfg = graph.cfg

        instance = Stack(
            Zephyr.get_symbol(args.symbol),
            # When creating a stack with k_stack_alloc_init() the buffer is created in kernel
            # address space
            None,
            args.max_entries
        )

        Zephyr.create_instance(cfg, state, cpu_id, va, "Stack", instance, args.symbol, "k_stack_alloc_init")
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
            Zephyr.get_symbol(args.symbol),
            args.size
        )

        Zephyr.create_instance(cfg, state, cpu_id, va, "Pipe", instance, args.symbol, "k_pipe_init")
        return state

    # int k_pipe_alloc_init(struct k_pipe *pipe, size_t size)
    @syscall(categories={SyscallCategory.create},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("size", hint=SigType.value)))
    def k_pipe_alloc_init(graph, state, cpu_id, args, va):
        state = state.copy()
        cfg = graph.cfg

        instance = Pipe(
            Zephyr.get_symbol(args.symbol),
            args.size
        )

        Zephyr.create_instance(cfg, state, cpu_id, va, "Pipe", instance, args.symbol, "k_pipe_alloc_init")
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
            Zephyr.get_symbol(args.symbol),
            args.limit
        )

        Zephyr.create_instance(cfg, state, cpu_id, va, "Heap", instance, args.symbol, "k_heap_init")
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
            Zephyr.get_symbol(args.symbol),
            args.msg_size,
            args.max_msgs
        )

        Zephyr.create_instance(cfg, state, cpu_id, va, "MSGQ", instance, args.symbol, "k_msgq_init")
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
            Zephyr.get_symbol(args.symbol),
            args.msg_size,
            args.max_msgs
        )

        Zephyr.create_instance(cfg, state, cpu_id, va, "MSGQ", instance, args.symbol, "k_msgq_alloc_init")
        return state

    #
    # Syscall.comm
    #


    # TODO: we need to make sure as long as the timeout is not empty a new state is returned
    # probably need to return two states as soon as a timeout is pending, one with expired timeout and own with active timeout


    #
    # Thread
    #


    # int k_thread_join(struct k_thread *thread, k_timeout_t timeout)
    @staticmethod
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Thread),
                        Arg("timeout", hint=SigType.value)))
    def k_thread_join(graph, state, cpu_id, args, va):
        state = state.copy()

		#add_to_waitq_locked(_current, &thread->join_queue);
        # - unready_thread(thread)
        #  - dequeue_thread(&_kernel.ready_q.runq, thread);
        #   - sys_dlist_remove(&thread->base.qnode_dlist);
        # - z_mark_thread_as_pending(thread)
		#add_thread_timeout(_current, timeout);
		#ret = z_swap(&sched_spinlock, key);
        # - arch_swap # CONFIG_USE_SWITCH: arch_switch => z_x86_switch
        # z_swap does not return, and switches to an other thread....
        #     ..... update_cache(): next_up()
        # swap in thread from z_kernel.ready_q.cache /* always contains next thread to run: cannot be NULL */
        # - sys_dlist_t OR struct _priq_rb OR struct _priq_mq

        # - next_up()
        #  - thread = _priq_run_best(&_kernel.ready_q.runq); --> _priq_dumb_best OR z_priq_rb_best OR ...q
        #  -


        if Zephyr.enable_sse:
            kernel = Zephyr.get_kernel_context(state)

            if len(kernel.ready_q) <= 0:
                logging.warning("len(kernel.ready_q) <= 0")
                return

            ic = za.InterpreterContext(state, cpu_id)

            thread = ic.thread_sym_2_ptr(args.symbol)
            timeout = za.to_timeout_value(args.timeout)

            ic.run_function_with_arch_swap("k_thread_join", [thread.ptr, timeout], ['PTR', 'APInt64'])

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_thread_join", "Thread")
        return state

    # int32_t k_sleep(k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("timeout", hint=SigType.value),))
    def k_sleep(graph, state, cpu_id, args, va):
        state = state.copy()



        add_self_edge(state, cpu_id, "k_sleep", ty=ZephyrEdgeType.interaction)
        return state

    # int32_t k_msleep(int32_t ms)
    @staticmethod
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("ms", hint=SigType.value),))
    def k_msleep(graph, state, cpu_id, args, va):
        old_state = state
        state = state.copy()

        vertices_thread_map = {}

        if Zephyr.enable_sse:
            # handle: K_FOREVER: Thread suspends, calls: k_thread_suspend(_current);

            # calls: ticks = z_tick_sleep(ticks);

            # sched.c:z_impl_k_sleep: calls k_thread_suspend: remove from queue, z_mark_thread_as_suspended, z_reschedule_unlocked
            # .... include/kswap.h:do_swap(...)
            # - z_get_next_ready_thread
            # - wait_for_switch(new_thread);
            # - arch_switch();

            kernel = Zephyr.get_kernel_context(state)

            if len(kernel.ready_q) <= 0:
                return old_state

            ic = za.InterpreterContext(state, cpu_id)
            irm = ic.zi.irm

            irm.stop(["arch_swap"]) # z_swap(inlined) CONF: arch_swap or with SMP: arch_switch

            # CONFIG_TIMEOUT_64BIT, todo fix k_timeout_t, load into struct, but llvm is i64
            # TODO: check the function signature in ir code, and remove the args_hints
            irm.set_print_llvmir(True)
            ic.zi.run_function("z_impl_k_sleep", [args.ms], ['APInt64'])

            if irm.getCurrentCallFunctionName() == "arch_swap":
                # za.InterpreterContext.debug_irx_print_kernel_objects(zi, threads, idle_thread, threads_map)
                irm.putReturnValue(0, 'APInt32') # emulate that the callee returned 0

            ic.zi.finish_function()

            vertices_thread_map = ic.vertices_thread_map

            ic.update()

        Zephyr.debug_print_threads(state, vertices_thread_map)


        add_self_edge(state, cpu_id, "k_msleep", ty=ZephyrEdgeType.interaction)
        return state

    # int32_t k_usleep(int32_t us)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("us", hint=SigType.value),))
    def k_usleep(graph, state, cpu_id, args, va):
        state = state.copy()

        add_self_edge(state, cpu_id, "k_usleep", ty=ZephyrEdgeType.interaction)
        return state

    # void k_busy_wait(uint32_t usec_to_wait)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("us", hint=SigType.value),))
    def k_busy_wait(graph, state, cpu_id, args, va):
        state = state.copy()

        add_self_edge(state, cpu_id, "k_busy_wait", ty=ZephyrEdgeType.interaction)
        return state

    # void k_yield(void)
    @syscall(categories={SyscallCategory.comm})
    def k_yield(graph, state, cpu_id, args, va):
        state = state.copy()

        ic = za.InterpreterContext(state, cpu_id)
        ic.run_function_with_arch_swap("z_impl_k_yield", [], [])

        add_self_edge(state, cpu_id, "k_yield", ty=ZephyrEdgeType.interaction)
        return state

    # void k_wakeup(k_tid_t thread)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("thread", hint=SigType.value), ))
    def k_wakeup(graph, state, cpu_id, args, va):
        state = state.copy()

        add_self_edge(state, cpu_id, "k_wakeup", ty=ZephyrEdgeType.interaction)
        return state

    # k_tid_t k_current_get(void)
    @syscall(categories={SyscallCategory.comm})
    def k_current_get(graph, state, cpu_id, args, va):
        state = state.copy()

        cpu = state.cpus[cpu_id]

        k_thread_t = find_return_value(cpu.abb, cpu.call_path, va)

        logger.debug("k_current_get: %s", k_thread_t.value.get_name())
        logger.debug("k_current_get: %s", k_thread_t.value)
        logger.debug("k_current_get: %s", k_thread_t)

        cur_task = state.cur_control_inst(cpu_id)
        #va.assign_system_object(k_thread_t.value, cur_task)

        add_self_edge(state, cpu_id, "k_current_get", ty=ZephyrEdgeType.interaction)
        return state


    # k_ticks_t k_thread_timeout_expires_ticks(struct k_thread *t)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Thread),))
    def k_thread_timeout_expires_ticks(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_thread_timeout_expires_ticks", "Thread")
        return state

    # k_ticks_t k_thread_timeout_remaining_ticks(struct k_thread *t)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Thread),))
    def k_thread_timeout_remaining_ticks(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_thread_timeout_remaining_ticks", "Thread")
        return state

    # void k_sched_time_slice_set(int32_t slice, int prio)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("time_slice", hint=SigType.value),
                        Arg("prio", hint=SigType.value)))
    def k_sched_time_slice_set(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_kernel_comm(state, cpu_id, "k_sched_time_slice_set")
        return state

    # void k_sched_lock(void)
    @syscall(categories={SyscallCategory.comm})
    def k_sched_lock(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_kernel_comm(state, cpu_id, "k_sched_lock")
        return state

    # void k_sched_unlock(void)
    @syscall(categories={SyscallCategory.comm})
    def k_sched_unlock(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_kernel_comm(state, cpu_id, "k_sched_unlock")
        return state

    # void k_thread_custom_data_set(void *value)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("custom_data", hint=SigType.symbol, ty=pyllco.Value),))
    def k_thread_custom_data_set(graph, state, cpu_id, args, va):
        state = state.copy()

        add_self_edge(state, cpu_id,  "k_thread_custom_data_set", ty=ZephyrEdgeType.interaction)
        return state

    # void *k_thread_custom_data_get(void)
    @syscall(categories={SyscallCategory.comm})
    def k_thread_custom_data_get(graph, state, cpu_id, args, va):
        state = state.copy()

        add_self_edge(state, cpu_id, "k_thread_custom_data_get", ty=ZephyrEdgeType.interaction)
        return state

    #
    # ISR
    #

    # bool k_is_in_isr(void)
    @syscall(categories={SyscallCategory.comm})
    def k_is_in_isr(graph, state, cpu_id, args, va):
        state = state.copy()

        add_self_edge(state, cpu_id, "k_is_in_isr", ty=ZephyrEdgeType.interaction)
        return state

    # int k_is_preempt_thread(void)
    @syscall(categories={SyscallCategory.comm})
    def k_is_preempt_thread(graph, state, cpu_id, args, va):
        state = state.copy()

        add_self_edge(state, cpu_id, "k_is_preempt_thread", ty=ZephyrEdgeType.interaction)
        return state

    # bool k_is_pre_kernel(void)
    @syscall(categories={SyscallCategory.comm})
    def k_is_pre_kernel(graph, state, cpu_id, args, va):
        state = state.copy()

        add_self_edge(state, cpu_id, "k_is_pre_kernel", ty=ZephyrEdgeType.interaction)
        return state

    #
    # Semaphore
    #

    # int k_sem_take(struct k_sem *sem, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=KernelSemaphore),
                        Arg("timeout", hint=SigType.value)))
    def k_sem_take(graph, state, cpu_id, args, va):
        state = state.copy()


        # check did_swap value
        # check return value


        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_sem_take", "KernelSemaphore")
        return state

    # void k_sem_give(struct k_sem *sem)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=KernelSemaphore),))
    def k_sem_give(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_sem_give", "KernelSemaphore")
        return state

    # void k_sem_reset(struct k_sem *sem)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=KernelSemaphore),))
    def k_sem_reset(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_sem_reset", "KernelSemaphore")
        return state

    # unsigned int k_sem_count_get(struct k_sem *sem)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),))
    def k_sem_count_get(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_sem_count_get", "KernelSemaphore")
        return state

    # int sys_sem_take(struct sys_sem *sem, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("timeout", hint=SigType.value, ty=UserSemaphore)))
    def sys_sem_take(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "sys_sem_take", "UserSemaphore")
        return state

    # int sys_sem_give(struct sys_sem *sem)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=UserSemaphore),))
    def sys_sem_give(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "sys_sem_give", "UserSemaphore")
        return state

    # unsigned int sys_sem_count_get(struct sys_sem *sem)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=UserSemaphore),))
    def sys_sem_count_get(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "sys_sem_count_get", "UserSemaphore")
        return state

    #
    # Mutex
    #

    # int k_mutex_lock(struct k_mutex *mutex, k_timeout_t timeout)
    # NOTE: The thread that has locked a mutex is eligible for priority inheritance.
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Mutex),
                        Arg("timeout", hint=SigType.value)))
    def k_mutex_lock(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_mutex_lock", "Mutex")
        return state

    # int k_mutex_unlock(struct k_mutex *mutex)
    # Unlock should only ever be called by the locking thread.
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Mutex),))
    def k_mutex_unlock(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_mutex_unlock", "Mutex")
        return state

    #
    # Queue: FIFO and LIFO functions are just macro wrappers around the generic queue functions
    #

    # void k_queue_cancel_wait(struct k_queue *queue)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Queue),))
    def k_queue_cancel_wait(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_queue_cancel_wait", "Queue")
        return state

    # void k_queue_append(struct k_queue *queue, void *data)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Queue),
                        Arg("item", hint=SigType.value)))
    def k_queue_append(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_queue_append", "Queue")
        return state

    # int32_t k_queue_alloc_append(struct k_queue *queue, void *data)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Queue),
                        Arg("item", hint=SigType.value)))
    def k_queue_alloc_append(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_queue_alloc_append", "Queue")
        return state

    # void k_queue_prepend(struct k_queue *queue, void *data)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Queue),
                        Arg("item", hint=SigType.value)))
    def k_queue_prepend(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_queue_prepend", "Queue")
        return state

    # void k_queue_alloc_prepend(struct k_queue *queue, void *data)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Queue),
                        Arg("item", hint=SigType.value)))
    def k_queue_alloc_prepend(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_queue_alloc_prepend", "Queue")
        return state

    # void k_queue_insert(struct k_queue *queue, void *prev, void *data)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Queue),
                        Arg("prev", hint=SigType.value),
                        Arg("item", hint=SigType.value)))
    def k_queue_insert(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_queue_insert", "Queue")
        return state

    # int k_queue_append_list(struct k_queue *queue, void *head, void *tail)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Queue),
                        Arg("head", hint=SigType.value),
                        Arg("tail", hint=SigType.value)))
    def k_queue_append_list(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_queue_append_list", "Queue")
        return state

    # int k_queue_merge_slist(struct k_queue *queue, sys_slist_t *list)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Queue),
                        Arg("other", hint=SigType.symbol)))
    def k_queue_merge_slist(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_queue_merge_list", "Queue")
        return state

    # void *k_queue_get(struct k_queue *queue, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Queue),
                        Arg("into", hint=SigType.value)))
    def k_queue_get(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_queue_get", "Queue")
        return state

    # bool k_queue_remove(struct k_queue *queue, void *data)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Queue),
                        Arg("other", hint=SigType.symbol)))
    def k_queue_remove(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_queue_remove", "Queue")
        return state

    # bool k_queue_unique_append(struct k_queue *queue, void *data)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Queue),
                        Arg("other", hint=SigType.symbol)))
    def k_queue_unique_append(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_queue_unique_append", "Queue")
        return state

    # int k_queue_is_empty(struct k_queue *queue)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Queue),))
    def k_queue_is_empty(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_queue_is_empty", "Queue")
        return state

    # void *k_queue_peek_head(struct k_queue *queue)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Queue),))
    def k_queue_peek_head(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_queue_peek_head", "Queue")
        return state

    # void *k_queue_peek_tail(struct k_queue *queue)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Queue),))
    def k_queue_peek_tail(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_queue_peek_tail", "Queue")
        return state

    #
    # Stack
    #

    # int k_stack_cleanup(struct k_stack *stack)
    # NOTE: Should only be used if allocated with stack_alloc_init.
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Stack),))
    def k_stack_cleanup(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_stack_cleanup", "Stack")
        return state

    # int k_stack_push(struct k_stack *stack, stack_data_t data)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Stack),
                        Arg("item", hint=SigType.value)))
    def k_stack_push(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_stack_push", "Stack")
        return state

    # int k_stack_pop(struct k_stack *stack, stack_data_t *data, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Stack),
                        Arg("into", hint=SigType.value),
                        Arg("timeout", hint=SigType.value)))
    def k_stack_pop(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_stack_pop", "Stack")
        return state

    #
    # Pipe
    #

    # int k_pipe_cleanup(struct k_pipe *pipe)
    # NOTE: Should only be used if allocated with pipe_alloc_init.
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Pipe),))
    def k_pipe_cleanup(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_pipe_cleanup", "Pipe")
        return state

    # int k_pipe_put(struct k_pipe *pipe, void *data, size_t bytes_to_write, size_t *bytes_written,
    # size_t min_xfer, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Pipe), # TODO: why was here raw_value=True ?
                        Arg("item", hint=SigType.symbol, ty=pyllco.Value),
                        Arg("item_size", hint=SigType.value),
                        Arg("bytes_written", hint=SigType.symbol), # Does not really make sense as a value, since at call time this contains garbage
                        Arg("min_bytes_to_write", hint=SigType.value),
                        Arg("timeout", hint=SigType.value)))
    def k_pipe_put(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_pipe_put", "Pipe")
        return state

    # int k_pipe_get(struct k_pipe *pipe, void *data, size_t bytes_to_read, size_t *bytes_read,
    # size_t min_xfer, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Pipe),
                        Arg("item", hint=SigType.symbol),
                        Arg("item_size", hint=SigType.value),
                        Arg("bytes_read", hint=SigType.symbol),
                        Arg("min_bytes_to_read", hint=SigType.value),
                        Arg("timeout", hint=SigType.value)))
    def k_pipe_get(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_pipe_get", "Pipe")
        return state

    # void k_pipe_block_put(struct k_pipe *pipe, struct k_mem_block *block, size_t size, struct
    # k_sem *sem)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Pipe),
                        Arg("item", hint=SigType.value),
                        Arg("item_size", hint=SigType.value),
                        Arg("sem", hint=SigType.instance, ty=KernelSemaphore))) # TODO: why was sem index 4 instead of the correct 3 ? (Check this)
    def k_pipe_block_put(graph, state, cpu_id, args, va):
        # This syscall actually works on more than one instance. It writes to a pipe and
        # calls give() on sem (which is OPTIONAL).
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_pipe_block_put", "Pipe")
        # For now just add a k_sem_give from the thread to the given semaphore, if present.
        # This should work, because sem has to be created externally

        if isinstance(args.sem, ZephyrInstance):
            Zephyr.add_instance_comm(state, cpu_id, args.sem, "k_sem_give", "KernelSemaphore")

        return state

    # size_t k_pipe_read_avail(struct k_pipe *pipe)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Pipe),))
    def k_pipe_read_avail(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_pipe_read_avail", "Pipe")
        return state

    # size_t k_pipe_write_avail(struct k_pipe *pipe)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Pipe),))
    def k_pipe_write_avail(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_pipe_write_avail", "Pipe")
        return state

    # void *k_heap_alloc(struct k_heap *h, size_t bytes, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Heap),
                        Arg("size", hint=SigType.value),
                        Arg("timeout", hint=SigType.value)))
    def k_heap_alloc(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_heap_alloc", "Heap")
        return state

    # void k_heap_free(struct k_heap *h, void *mem)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Heap),
                        Arg("mem", hint=SigType.symbol)))
    def k_heap_free(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_heap_free", "Heap")
        return state

    # void *k_malloc(size_t size)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("size", hint=SigType.value),))
    def k_malloc(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_kernel_comm(state, cpu_id, "k_malloc")
        return state

    # void k_free(void *ptr)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("mem", hint=SigType.symbol),))
    def k_free(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_kernel_comm(state, cpu_id, "k_free")
        return state

    # void *k_calloc(size_t nmemb, size_t size)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("num_elements", hint=SigType.value),
                        Arg("element_size", hint=SigType.value)))
    def k_calloc(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_kernel_comm(state, cpu_id, "k_calloc")
        return state

    # int k_msgq_cleanup(struct k_msgq *msgq)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=MSGQ),))
    def k_msgq_cleanup(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_msgq_cleanup", "MSGQ")
        return state

    # int k_msgq_put(struct k_msgq *msgq, const void *data, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=MSGQ),
                        Arg("item", hint=SigType.symbol, ty=pyllco.Value),
                        Arg("timeout", hint=SigType.value)))
    def k_msgq_put(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_msgq_put", "MSGQ")
        return state

    # int k_msgq_get(struct k_msgq *msgq, void *data, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=MSGQ),
                        Arg("item", hint=SigType.symbol, ty=pyllco.Value),
                        Arg("timeout", hint=SigType.value)))
    def k_msgq_get(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_msgq_get", "MSGQ")
        return state

    # int k_msgq_peek(struct k_msgq *msgq, void *data)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=MSGQ),
                        Arg("item", hint=SigType.symbol, ty=pyllco.Value)))
    def k_msgq_peek(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_msgq_peek", "MSGQ")
        return state

    # void k_msgq_purge(struct k_msgq *msgq)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=MSGQ),))
    def k_msgq_purge(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_msgq_purge", "MSGQ")
        return state

    # uint32_t k_msgq_num_free_get(struct k_msgq *msgq)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=MSGQ),))
    def k_msgq_num_free_get(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_msgq_num_free_get", "MSGQ")
        return state

    # void k_msgq_get_attrs(struct k_msgq *msgq, struct k_msgq_attrs *attrs)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=MSGQ),
                        Arg("attributes", hint=SigType.symbol, ty=pyllco.Value)))
    def k_msgq_get_attrs(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_msgq_get_attrs", "MSGQ")
        return state


    # uint32_t k_msgq_num_used_get(struct k_msgq *msgq)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=MSGQ),))
    def k_msgq_num_used_get(graph, state, cpu_id, args, va):
        state = state.copy()

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_msgq_num_used_get", "MSGQ")
        return state

    # ...
    # TODO: Add more syscalls

    @staticmethod
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Thread),
                        Arg("str", hint=SigType.symbol, ty=pyllco.Value)))
    def k_thread_name_set(graph, state, cpu_id, args, va):
        state = state.copy()
        cur_task = state.cur_control_inst(cpu_id)
        # args.symbol.value
        #state.instances[]
        # args.str.value

        return state


    class InstanceEdge(IntEnum):
        have = 1 << 1
        trigger = 1 << 2
        activate = 1 << 3
        chain = 1 << 4
        nestable = 1 << 5
        terminate = 1 << 6
        get = 1 << 7
        release = 1 << 8
        sete = 1 << 9
        wait = 1 << 10
        interrupts = 1 << 11

    # void k_thread_abort(k_tid_t thread)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("thread", hint=SigType.instance, ty=Thread),))
    def k_thread_abort(graph, state, cpu_id, args, va):
        state = state.copy()

        # Zephyr.create_instance(cfg, state, cpu_id, va, "Thread", instance, args.thread, k_thread_abort.__name__)

        # Zephyr.add_instance_comm(state, cpu_id, args.thread, k_thread_abort.__name__, "Thread")
        # return state

        cur_task = state.cur_control_inst(cpu_id)
        assert isinstance(cur_task, Thread), "thread_terminate must be called in a thread"

        # if state.context[cur_task].in_critical_section:
        #     logger.debug(f"TerminateTask {cur_task.name} holding a spinlock")
        #     set_next_abb(state, cpu_id)
        #     return state
        
        v = state.instances.get_node(args.thread)

        cur = state.cpus[cpu_id].control_instance
        connect_from_here(
            state, cpu_id, cur, "k_thread_abort", ty=Zephyr.InstanceEdge.terminate
        )
        return state
