# SPDX-FileCopyrightText: 2021 Kenny Albes
# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2022 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

from ara.steps.instance_graph_stats import MissingInteractions
from ara.steps.multisse_helper.common import get_single_core_states
from .xen import XEN
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
from .os_base import CPUBounded, CrossOSEvent, OSBase, ControlInstance, CPUList, CPU, OSState, ExecState, TaskStatus, ControlContext, IRQ, IRQContext
from ara.util import get_logger
from ara.graph import SyscallCategory, SigType, CallPath, CFG, Graph, InstanceGraph
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

from diff import diff
from proxy import PTR
import zephyr # irx.zephyr (in future: generated)

import ara.os.zephyr_adapters as za
from ara.os.zephyr_adapters import ThreadContext

from ara.graph.mix import CFType


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
    # used by HyperSSE for different domains, in SSE/MultiSSE the kernel is global and this does not matter
    cpu_id: int
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

    def __str__(self):
        """Prettyprint selected content."""
        # \33 escape sequenze, 1 for bold, 36 for color, m for end of sequenze
        if XEN.system_count:
            return f"\33[1;36mZephyrKernel\033[0m: cpu_id={self.cpu_id} heap_size={self.heap_size}, symbol={self.symbol}, queue={self.queue}"
        else:
            return f"\33[1;36mZephyrKernel\033[0m: heap_size={self.heap_size}, symbol={self.symbol}, queue={self.queue}"

@dataclass
class ZephyrIRQ(IRQ):
    symbol: object = None

    wanted_attrs = ["symbol"]

    def __hash__(self):
        return hash(("ZephyrIRQ", self.symbol))


@dataclass
class Timer(ZephyrInstance):

    expiry_fn: str

    stop_fn: str

    symbol: object = None

    wanted_attrs = ["expiry_fn", "stop_fn"]
    
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#e1d5e7",
        "color": "#9673a6",
        "style": "filled"
    }

    def __hash__(self):
        return hash(("Timer", self.symbol, self.expiry_fn, self.stop_fn))
    

@dataclass
class Thread(ZephyrInstance, ControlInstance, CrossOSEvent):
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
    
    def __str__(self):
        """Prettyprint selected content."""
        # \33 escape sequenze, 1 for bold, 36 for color, m for end of sequenze
        try:
            cfg_name = self.cfg.name
        except AttributeError:
            cfg_name = "?"
        return f"\33[1;36mThread-{self.name}\033[0m: cpu_id={self.cpu_id}/{cfg_name}, priority={self.priority}, entry_name={self.entry_name}"


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
    
    def __str__(self):
        """Prettyprint selected content."""
        # \33 escape sequenze, 1 for bold, 36 for color, m for end of sequenze
        return f"\33[1;36mMSGQ\033[0m: msg_size={self.msg_size}, max_msgs={self.max_msgs}"


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
    llvm_ir_kernel_file = None

    """LLVM-IR Interpreter instance"""
    irx = None

    """ should sse run? """
    enable_sse = False

    """ idle threads map: cpu_id -> vertex of thread """
    idle_threads = {}

    """ whether IRQs shall be triggered only once and then disabled automatically """
    analyze_irqs_once = False

    @staticmethod
    def get_special_steps():
        return ["ZephyrStaticPost"] # "LoadKernelLL" not required for INA/SIA, enable via config

    @staticmethod
    def has_dynamic_instances():
        return True

    @staticmethod
    def get_cpu_local_contexts(context, cpu_id, instances):
        # Zephyr model is mostly singlecore, for this the whole context can be returend
        # for now we are single core only, whole context is in here, also for IRQCPUS that all target CPU 0
        # return context

        # HyperSSE needs multicore contexts, some ZephyrInstance are Zephyr wide global, so they are always needed!
        # TODO this breaks IRQ CPU, because they are not found
        local_contexts = []
        # logger.error(f"CPU_ID: {cpu_id}\n")
        # for inst, ctx in context.items():
        #     logger.info(f"{inst}  ---  {ctx}")
        for inst, ctx in context.items():
            if getattr(inst, "cpu_id", None) == cpu_id or isinstance(inst, ZephyrKernel):
                local_contexts.append((inst, ctx))
            # TODO find targets of IRQ if they belong to this local context

        # logger.error("\n")
        # for inst, ctx in local_contexts:
        #     logger.info(f"{inst}  ---  {ctx}")
        # logger.error("\n")
        return dict(local_contexts)

    @staticmethod
    def get_global_contexts(context, instances):
        return {}

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
    def create_or_get_instance(cfg: CFG, state: OSState, cpu_id: int, va: ValueAnalyzer, label: str, obj: ZephyrInstance, symbol: ValueAnalyzerResult, call: str, ident: str = None):
        if not isinstance(symbol.value, pyllco.Value): # we are in SSE step
            v = state.instances.get_node(symbol.value)
            if v is not None:
                if isinstance(symbol.value, type(obj)):
                    return v
        # if isinstance(symbol.value, pyllco.GlobalVariable):
        #     v = state.instances.get_node(symbol.value.get())
        #     if v is not None:
        #         if isinstance(symbol.value, type(obj)):
        #             return v
        return Zephyr.create_instance(cfg, state, cpu_id, va, label, obj, symbol, call, ident)
    
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
    def debug_print_threads(state, ic: za.InterpreterContext = None):
        for v, obj in state.instances.get(Thread):
            if obj in state.context:
                ctx = state.context[obj]
                status_name = TaskStatus(ctx.status).name
                index = state.instances.vertex_index[v]
                thread = None
                if ic:
                    thread = ic.thread_vertex_2_ptr(v)
                ts = za.ThreadStateAdapter(ctx.thread_state).name
                print(index, obj.name, obj.entry_name, status_name, thread, ctx.thread_state, ts)

    @staticmethod
    def get_kernel_context(state) -> za.ZephyrKernelContext:
        return state.context[state.instances.vp.obj[Zephyr.kernel]]

    @staticmethod
    def set_kernel_context(state, kernel):
        state.context[state.instances.vp.obj[Zephyr.kernel]] = kernel

    @staticmethod
    def get_timeout_llvm_type():
        """depending on the architecture, the LLVM type of struct timeout can be different"""
        if 'CONFIG_ARM' in Zephyr.config:
            return 'PTR' # actually it is a [i32 x 1]
        else:
            return 'APInt64'

    @staticmethod
    def get_initial_state(cfg, instances):
        running_tasks = []
        cpu_id = 0
        all_threads = [(v, obj) for v, obj in instances.get(Thread) if obj.start_in_init and not obj.artificial]
        threads = []

        prio_vert, prio_thread = None, None

        if not 'CONFIG_SCHED_DUMB' in Zephyr.config and Zephyr.enable_sse:
            raise RuntimeError("only CONFIG_SCHED_DUMB supported by SSE")

        # start with main thread, because it is the first one spawnig
        threads = [x for x in filter(lambda t: t[1].delay == 0, all_threads)]
        threads.sort(key=lambda t: int(t[1].entry_name != "main")) # move main to front
        threads.sort(key=lambda t: t[1].priority)
        
        prio_vert, prio_thread = threads[0]

        if prio_vert == None or prio_thread == None:
            raise RuntimeError("First starting thread not found")


        threads = [(v, obj) for v, obj in instances.get(Thread) if obj.start_in_init and not obj.artificial]


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
                analysis_context=za.ZephyrCPUAnalysisContext(), # current=prio_vert
                cfg=cfg
            )
        ]

        running_tasks.append(prio_thread)

        # logger.debug(
        #     f"Initial: Choose {instances.vp.obj[instances.vertex(prio_vert)]} for CPU {cpu_id}."
        # )

        # logger.debug(f"CFG: {cfg}")

        state = OSState(cpus=CPUList(cpus), instances=instances, cfg=cfg)

        Zephyr.set_kernel_context(state, za.ZephyrKernelContext())
        kernel = Zephyr.get_kernel_context(state)
        kernel.cache = prio_vert

        for v, obj in filter(lambda t: t[1].delay > 0, all_threads):
            kernel.timeout_list.append(za.Timeout(v, '', obj.delay))


        for v, obj in threads:
            # FIXME: Actual the thread entry is wrapped by z_thread_entry
            # something like: abb=cfg.get_entry_abb(z_thread_entry(obj.function, p1, p2, p3))
            # z_thread_entry = cfg.get_function_by_name("__ara_mock_z_thread_entry") # "z_thread_entry"
            # entry = obj.z_thread_entry
            entry = obj.function
            skip = True
            edges = cfg.vertex(entry).out_edges()
            for e in edges:
                is_entry = cfg.ep.is_entry[e]
                f2a = cfg.ep.type[e] == CFType.f2a
                if is_entry and f2a:
                    skip = False
            if skip:
                continue
            abb = cfg.get_entry_abb(entry)
            # if cfg.has_abbs(entry):
            #     abb = cfg.get_entry_abb(entry)

            # logger.debug(f"instances: cpu_id:{v} obj:{obj}")
            # logger.debug(f"instances: function:{obj.function}")
            prio = obj.priority

            thread_state = za.ThreadStateAdapter._THREAD_QUEUED
            status = TaskStatus.ready
            if obj.delay != 0:
                thread_state = za.ThreadStateAdapter._THREAD_PRESTART
                status = TaskStatus.terminated

            state.context[obj] = ThreadContext(
                status=status,
                abb=abb,
                call_path=CallPath(),
                dyn_prio=[prio],
                # thread_state=za.ThreadStateAdapter(0)
                preempt=(prio & 0x00FF) | ((0 << 8) & 0xFF00),
                thread_state=thread_state,
            )

            if obj.artificial:
                continue
            
            if obj.delay == 0:
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
            # if isinstance(obj, Thread):
            state.context[obj] = ThreadContext(
                status=TaskStatus.ready,
                abb=None, # don't schedule on idle thread
                call_path=CallPath(),
                dyn_prio=[obj.priority],
                preempt=(obj.priority & 0x00FF) | ((0 << 8) & 0xFF00)
            )
            # this case is for a bug with hypersse, where the wrong vertex is found
            # else:
            #     priority = 0
            #     state.context[obj] = ThreadContext(
            #         status=TaskStatus.ready,
            #         abb=None, # don't schedule on idle thread
            #         call_path=CallPath(),
            #         dyn_prio=[0],
            #         preempt=(0 & 0x00FF) | ((0 << 8) & 0xFF00)
            #     )

        # task_to_shed = running_tasks
        # for cpu in cpus:
        #     task = task_to_shed.pop()
        #     if task is None:
        #         break
        #     task.cpu_id = cpu.id

        for v, obj in instances.get(Semaphore):
            state.context[obj] = za.SemaphoreContext([], obj.count, obj.limit)

        for v, obj in instances.get(Mutex):
            state.context[obj] = za.MutexContext()
        
        for v, obj in instances.get(MSGQ):
            state.context[obj] = za.MSGQContext(
                msg_size=obj.msg_size,
                max_msgs=obj.max_msgs,
            )

        for v, obj in instances.get(Timer):
            state.context[obj] = za.TimerContext(
                obj.expiry_fn,
                obj.stop_fn
            )

        za.InterpreterContext.Zephyr = Zephyr
        za.InterpreterContext.config = Zephyr.config

        # Zephyr.debug_print_threads(state)

        # TODO add ISR for timeout list
        # Zephyr.create_instance(cfg, state, cpu_id, va, "ISR", instance, args.symbol, "sys_clock_announce")

        for _, obj in instances.get(IRQ):
            status = TaskStatus.running if obj.active else TaskStatus.blocked
            if obj.function:
                abb = cfg.get_entry_abb(obj.function)
            else:
                abb = None # TODO find sys_clock_announce?!
            state.context[obj] = IRQContext(
                status=status, abb=abb, call_path=CallPath(), dyn_prio=[-1] # neg. prio: not yet enabled IRQ
            )

        return state

    @staticmethod
    def is_interaction(ty) -> bool:
        return ty in [ZephyrEdgeType.interaction, ZephyrEdgeType.create, 0]

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

        if not hasattr(Zephyr, syscall_name):
            logger.info("Skipping syscall, since from hypervisor")
            state = state.copy()
            set_next_abb(state, cpu_id)
            return state
        
        syscall = getattr(Zephyr, syscall_name)

        if Zephyr.syscall_in_category(syscall, categories):
            logger.info(f"Interpreting syscall: {syscall_name}")
            za.InterpreterContext.set_last_state_id(state.id)
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

        # logger.debug(f"Scheduling state {state} on CPUs: {cpus}")
        # logger.warn(f"state: {state}")
        # logger.warn(f"context: {state.context}")

        # Zephyr.debug_print_threads(state)

        # logger.error(f"{state}")
        kernel = Zephyr.get_kernel_context(state)

        if len(kernel.ready_q) <= 0:
            logger.warning(f"no thread in ready list")
            #return
        # new_vertex = kernel.ready_q[0]

        if kernel.cache is None:
            logger.warning("no thread in set in cache")
            return

        # # TODO: use ISR and IRQ: return cpu.state = idle, to trigger IRQ, and handle in ISR
        # if len(kernel.ready_q) <= 0:
        #     logger.warning("no threads in ready list")
        #     if len(kernel.timeout_list) > 0:
        #         # better: use 'next_timeout' zephyr function,
        #         # or alternatively search in python for the next timeout: min(dticks).
        #         # since it is expected to be sorted anyway, this is fine to. unless it is modified and not sorted
        #         timeout = kernel.timeout_list[0]
        #         za.InterpreterContext.sys_clock_announce(Zephyr.irx, state, 0, timeout) # trigger a timeout from the list
        #     # TODO instead: cpu.exec_state = ExecState.idle

        new_vertex = kernel.cache # todo use _current instead of cache

        # for cpu_id in cpus:
        #     cpu_ctx = state.cpus[cpu_id].analysis_context
        #     if cpu_ctx:
        #         logger.debug(f"cpu {cpu_id}: interpreter _kernel.cpus[{cpu_id}].current ->"
        #                      f" {cpu_ctx.current}")

        for cpu in filter(lambda cpu: cpu.id in cpus, state.cpus):
            # logger.debug(f"cpu.id: {cpu.id}")

            # TODO: temporary disabled for HyperSSE
            if cpu.id != 0:
                logger.warning("HyperSSE disabled check for only 1 cpu, this might crash!")
            # assert cpu.id == 0 # only support one cpu

            # # if the idle thread is active (new_vertex = idle_thread) -> activate next timeout in queue
            # if new_vertex == Zephyr.idle_threads[cpu.id]:
            #     logger.warning("no threads in ready list -> fire timeout")

            #     if len(kernel.timeout_list) > 0:
            #         logger.debug("found queued timeout")

            new_vertex = state.instances.vertex(new_vertex)
            new_label = state.instances.vp.label[new_vertex]
            new_obj = state.instances.vp.obj[new_vertex]
            new_entry_name = new_obj.entry_name
            new_ctx = state.context[new_obj]

            # if isinstance(new_obj, ISR):
                # print("ISR", new_obj)

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


            if new_vertex != Zephyr.idle_threads[cpu.id]:
                cpu.abb = state.cfg.vertex(new_ctx.abb)
                cpu.call_path = new_ctx.call_path
                new_ctx.status = TaskStatus.running
                # "reset" context values, they are irrelevant now
                new_ctx.abb = None
                new_ctx.call_path = CallPath()

                cpu.control_instance = state.instances.vertex(new_vertex)
                cpu.exec_state = ExecState.from_abbtype(state.cfg.vp.type[cpu.abb])

                # cpu.analysis_context.current = cpu.control_instance
            else:
                cpu.abb = None
                cpu.call_path = CallPath()
                cpu.control_instance = None
                cpu.exec_state = ExecState.idle

        # Zephyr.debug_print_threads(state)


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

        # if is exit (get_exit_abb), call k_thread_abort() to reschedule to a new thread

        kernel = Zephyr.get_kernel_context(state)

        # if kernel.cache != Zephyr.idle_threads[cpu_id]:
        #     new_state = state.copy()
        #     return [new_state]

        cpu = state.cpus[cpu_id]
        v = cpu.control_instance
        old_obj = state.instances.vp.obj[v]

        if isinstance(old_obj, ISR):
            # handle user defined ISR

            # ISR could change the ready queue, but for cooperative it should resume the interrupted thread
            new_vertex = kernel.ready_q[0] # probably better to store this information in the ISR context instead of guessing here
            new_obj = cpu.analysis_context.interrupted_thread
            if new_obj and new_obj.priority < 0: # if a cooperative thread was interrupted
                new_vertex = state.instances.get_node(new_obj)
            new_obj = state.instances.vp.obj[new_vertex]
            old_ctx: za.ISRContext = state.cur_context(cpu_id)

            # we can probably just drop the context
            if old_ctx:
                old_ctx.abb = state.cfg.vertex(cpu.abb)
                old_ctx.call_path = cpu.call_path

            new_ctx = state.context[new_obj]

            cpu.abb = state.cfg.vertex(new_ctx.abb)
            cpu.call_path = new_ctx.call_path
            cpu.control_instance = state.instances.vertex(new_vertex)
            cpu.exec_state = ExecState.from_abbtype(state.cfg.vp.type[cpu.abb])
            cpu.analysis_context.nested -= 1
            cpu.irq_on = cpu.analysis_context.nested == 0

            kernel.cache = new_vertex

            # return from ISR complete, and resume interrupted thread

            return [state]


        ic = za.InterpreterContext(Zephyr.irx, state, cpu_id)
        proxy = ic.proxy
        thread = ic.thread_vertex_2_ptr(v)
        join_queue = proxy.get_member(thread, ['join_queue', 'waitq']) # if not config['CONFIG_WAITQ_SCALABLE']
        proxy.get(join_queue)

        # old_threads = [copy.copy(x) for x in ic.threads]
        # old_threads = [copy.copy(x) for x in Zephyr.get_thread_ccs(state)]

        # ic.zi.irm.set_print_llvmir(True)
        ic.zi.irm.stop(["arch_swap"])
        ic.zi.irm.skip(["memset"])
        # ic.zi.irm.set_print_llvmir(True)
        ic.run_function_with_arch_swap("z_impl_k_thread_suspend", [thread.ptr], ['PTR'], True)
        # ic.zi.run_function("z_unpend_all", [join_queue.ptr], ['PTR'])
        # ic.zi.run_function("unpend_thread_no_timeout", [join_queue.ptr], ['PTR'])
        # ic.zi.run_function("update_cache", [0], ['APInt32'])

        # if ic.zi.irm.getCurrentCallFunctionName() == "arch_swap":
        #     ic.zi.irm.putReturnValue(0, 'APInt32') # emulate that the callee returned 0

        # ic.zi.irm.set_print_llvmir(False)
        ic.update()

        # Zephyr.debug_print_threads(state, ic)


        # for i, t in enumerate(Zephyr.get_thread_ccs(state)):
        #     changes = diff(old_threads[i], t)
        #     for x in changes:
        #         print(f"{x.path_str():30s}: {x.obj1} => {x.obj2}")

        if True or kernel.cache != Zephyr.idle_threads[cpu_id]: # return the idle state?
            cur = state.cpus[cpu_id].control_instance

            add_self_edge(state, cpu_id, "k_thread_abort", ty=ZephyrEdgeType.interaction)

            return [state]

        return []


    # ------------------------- Xen HyperSSE ------------------------------

    def move_context(context: dict, target_cpu_id: int) -> dict:
        """HyperSSE starts with each system thinking its running on cpu 0, 
         this function moves the context to target_cpu_id
         single core contexte mit cpu0 -> single core contexte mit cpuNEW"""

        logger.info(f"Moved context to CPU {target_cpu_id} for HyperSSE.")
        new_context = {}
        for k,v in context.items():
            if isinstance(k, CPUBounded):
                k.cpu_id = target_cpu_id
                new_context[k] = v
            else:
                # ZephyrKernel is global, can not be moved?
                # Same for MSGQ?
                new_context[k] = v

        # TODO running on another cpu currently needs to move the idle thread
        # for k,v in Zephyr.idle_threads.items():
        #     print(type(k))
        #     print(type(v))
        # This does not work, because the idle_thread is not found later
        Zephyr.idle_threads[target_cpu_id] = Zephyr.idle_threads[0]
            
        return new_context
    
    def move_irqhandler(irq: IRQ, inst: InstanceGraph, target_cpu_id: int) -> None:
        """When FakeIRQ-CPUs get added in add_interrupts(...) at the beginning of MultiSSE, the IRQ
         are generated from the InstanceGraph, which does not know the cpu_id's in HyperSSE.
         Since Zephyr and Autosar use a different IRQ-obj an OS-wrapper is needed."""

        # in Zephyr isr_handler should be of type Zephyr.ISR
        irq.isr_handler.cpu_id = target_cpu_id

    @staticmethod
    def find_cross_os_event(state: OSState, cpu_id: int, cb: str) -> CrossOSEvent:
        """Zephyr currently does no support any CrossOSEvents"""
        
        # k: ZephyrCrossOS = ZephyrCrossOS(cpu_id=cpu_id, function_name=cb)
        # state.context[k] = 1

        for k, _ in state.context.items():
            if isinstance(k, CrossOSEvent):
                if k.entry_name == cb:
                    return k
        return None

    @staticmethod
    def trigger_cross_os_event(state: OSState, cpu_id: int, event: CrossOSEvent) -> OSState:
        """Wrapper to apply the event to the given state, currently only ActivateTask is supported."""

        assert isinstance(event, Thread), "Zephyr currently only supports Threads as event!"

        # prepare right instance graph
        if state.system_count:
            state.instances = state.instances_list[cpu_id]

        # workarround because zephyr cant multicore
        states = get_single_core_states(state, XEN)
        state = states[cpu_id].copy()


        # state.context[event] = ThreadContext(
        #     status=TaskStatus.ready,
        #     abb=None, # don't schedule on idle thread
        #     call_path=CallPath(),
        #     dyn_prio=[obj.priority],
        #     preempt=(obj.priority & 0x00FF) | ((0 << 8) & 0xFF00)
        # )

        
        # similar to k_thread_start
        if Zephyr.enable_sse:
            start_abb = state.cfg.get_entry_abb(state.cfg.get_function_by_name(event.entry_name))
            state.context[event].abb = start_abb

            ic = za.InterpreterContext(Zephyr.irx, state, cpu_id)
            thread = ic.thread_sym_2_ptr(event)
            # ic.zi.queue_thread(thread)
            ic.zi.z_mark_thread_as_started(thread)
            ic.zi.ready_thread(thread)
            # ic.zi.irm.skip(["memcpy", "memset"])
            # ic.run_function_with_arch_swap("z_impl_k_thread_start", [thread.ptr], ['PTR'])

            ic.zi.irm.stop(["arch_swap"])
            ic.zi.irm.skip(["memset"])
            # ic.zi.irm.set_print_llvmir(True)
            ic.run_function_with_arch_swap("z_impl_k_thread_resume", [thread.ptr], ['PTR'], True)
            ic.update()

        # TODO do not have a real zephyr interrupt here, can not connect in instance graph
        # but does work without it
        # add_self_edge(state, cpu_id, "k_thread_start", ty=ZephyrEdgeType.interaction)

        # workarround because zephyr cant multicore
        states[cpu_id] = state
        state_list = []
        for s in states:
            # mantain order of states
            state_list.insert(s, states[s])

        # merged =  XEN.merge_states(state_list, tmp=False)
        merged =  XEN.merge_states(state_list)
        return merged


    # ------------------------------- Syscalls -----------------------------------

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
            name=Zephyr.get_symbol(args.symbol).get_name(), # TODO: implement k_thread_set_name
            start_in_init=False
        )

        logger.debug("k_thread_create: %s , %s", instance.entry_name, instance.symbol.get_name())

        v = Zephyr.create_or_get_instance(cfg, state, cpu_id, va, "Thread", instance, args.symbol, "k_thread_create")

        if Zephyr.enable_sse:
            ic = za.InterpreterContext(Zephyr.irx, state, cpu_id)
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
            obj = state.instances.vp.obj[v]
            # ic.threads_vertex_map[thread.ptr] = v

            thread = ic.thread_vertex_2_ptr(v)

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
                za.to_timeout_value(args.delay),
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
            irm.skip(['arch_new_thread', 'memset'])
            zi.run_function("z_impl_k_thread_create", irx_args, type_hints)

            if irm.getCurrentCallFunctionName() == "arch_swap":
                irm.putReturnValue(0, 'APInt32') # emulate that the callee returned 0

            zi.finish_function()

            status = TaskStatus.ready
            prio = instance.priority
            entry_abb = cfg.get_entry_abb(instance.function)

            proxy.get(thread)

            state.context[obj] = ThreadContext(
                status=status,
                abb=entry_abb,
                call_path=CallPath(),
                dyn_prio=[prio],
                preempt=thread.base.preempt,
                thread_state=thread.base.thread_state,
                order_key=thread.base.order_key,
            )

            ic.add_kobj(thread, state.context[obj], v)

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

        v = Zephyr.create_or_get_instance(cfg, state, cpu_id, va, "KernelSemaphore", instance, args.symbol, "k_sem_init")

        if Zephyr.enable_sse:
            obj = state.instances.vp.obj[v]
            state.context[obj] = za.SemaphoreContext([], obj.count, obj.limit)

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

        v = Zephyr.create_or_get_instance(cfg, state, cpu_id, va, "UserSemaphore", instance, args.symbol, "sys_sem_init")
        
        if Zephyr.enable_sse:
            obj = state.instances.vp.obj[v]
            state.context[obj] = za.SemaphoreContext([], obj.count, obj.limit)

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

        v = Zephyr.create_or_get_instance(cfg, state, cpu_id, va, "Mutex", instance, args.symbol, "k_mutex_init")

        obj = state.instances.vp.obj[v]
        state.context[obj] = za.MutexContext()

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

        v = Zephyr.create_or_get_instance(cfg, state, cpu_id, va, "MSGQ", instance, args.symbol, "k_msgq_init")
        obj = state.instances.vp.obj[v]

        state.context[obj] = za.MSGQContext(
            msg_size=args.msg_size,
            max_msgs=args.max_msgs,
        )

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

        v = Zephyr.create_or_get_instance(cfg, state, cpu_id, va, "MSGQ", instance, args.symbol, "k_msgq_alloc_init")
        obj = state.instances.vp.obj[v]

        state.context[obj] = za.MSGQContext(
            msg_size=args.msg_size,
            max_msgs=args.max_msgs,
        )

        return state

    #
    # Syscall.comm
    #


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

            ic = za.InterpreterContext(Zephyr.irx, state, cpu_id)

            thread = ic.thread_sym_2_ptr(args.symbol)
            timeout = za.to_timeout_value(args.timeout)
            
            # ic.zi.irm.set_print_llvmir(True)
            ret, did_swap = ic.run_function_with_arch_swap("k_thread_join", [thread.ptr, timeout], ['PTR', Zephyr.get_timeout_llvm_type()])
            logger.debug(f"k_thread_join ret: {ret['IntVal']['S']} {did_swap}")
        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_thread_join", "Thread")
        return state

    # int32_t k_sleep(k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("timeout", hint=SigType.value),))
    def k_sleep(graph, state, cpu_id, args, va):
        state = state.copy()

        if Zephyr.enable_sse:
            ic = za.InterpreterContext(Zephyr.irx, state, cpu_id)
            timeout = za.to_timeout_value(args.timeout)
            ic.run_function_with_arch_swap("z_impl_k_sleep", [timeout], [Zephyr.get_timeout_llvm_type()])

        add_self_edge(state, cpu_id, "k_sleep", ty=ZephyrEdgeType.interaction)
        return state

    # int32_t k_msleep(int32_t ms)
    @staticmethod
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("ms", hint=SigType.value),))
    def k_msleep(graph, state, cpu_id, args, va):
        old_state = state
        state = state.copy()

        ic = None

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

            ic = za.InterpreterContext(Zephyr.irx, state, cpu_id)
            irm = ic.zi.irm

            stop = [
                "arch_swap",
                # "elapsed"
            ]
            irm.stop(stop) # z_swap(inlined) CONF: arch_swap or with SMP: arch_switch

            # CONFIG_TIMEOUT_64BIT, todo fix k_timeout_t, load into struct, but llvm is i64
            # TODO: check the function signature in ir code, and remove the args_hints
            # irm.set_print_llvmir(True)

            ms = za.to_timeout_value(args.ms)

            ic.zi.run_function("z_impl_k_sleep", [ms], ['APInt64'])

            # arm kernel / non native_sim
            # if irm.getCurrentCallFunctionName() == "elapsed":
            #     irm.putReturnValue(0, 'APInt32')
            #     ic.zi.resume()

            if irm.getCurrentCallFunctionName() == "arch_swap":
                irm.putReturnValue(0, 'APInt32') # emulate that the callee returned 0

            ic.zi.finish_function()

            ic.update()

        # Zephyr.debug_print_threads(state, ic)


        add_self_edge(state, cpu_id, "k_msleep", ty=ZephyrEdgeType.interaction)
        return state

    # int32_t k_usleep(int32_t us)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("us", hint=SigType.value),))
    def k_usleep(graph, state, cpu_id, args, va):
        state = state.copy()

        if Zephyr.enable_sse:
            ic = za.InterpreterContext(Zephyr.irx, state, cpu_id)
            ic.run_function_with_arch_swap("z_impl_k_usleep", [args.us], ['APInt32'])

        add_self_edge(state, cpu_id, "k_usleep", ty=ZephyrEdgeType.interaction)
        return state

    # void k_busy_wait(uint32_t usec_to_wait)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("us", hint=SigType.value),))
    def k_busy_wait(graph, state, cpu_id, args, va):
        state = state.copy()

        add_self_edge(state, cpu_id, "k_busy_wait", ty=ZephyrEdgeType.interaction)
        return state
    
    @staticmethod
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Thread),))
    def k_thread_start(graph, state, cpu_id, args, va):
        state = state.copy()

        if Zephyr.enable_sse:
            ic = za.InterpreterContext(Zephyr.irx, state, cpu_id)
            thread = ic.thread_sym_2_ptr(args.symbol)
            ic.zi.irm.skip(["memcpy", "memset"])
            ic.run_function_with_arch_swap("z_impl_k_thread_start", [thread.ptr], ['PTR'])

        add_self_edge(state, cpu_id, "k_thread_start", ty=ZephyrEdgeType.interaction)
        return state

    @staticmethod
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Thread),))
    def k_thread_resume(graph, state, cpu_id, args, va):
        state = state.copy()

        if Zephyr.enable_sse:
            ic = za.InterpreterContext(Zephyr.irx, state, cpu_id)
            thread = ic.thread_sym_2_ptr(args.symbol)
            ic.zi.irm.skip(["memcpy", "memset"])
            ic.run_function_with_arch_swap("z_impl_k_thread_resume", [thread.ptr], ['PTR'])
            ic.update()

        add_self_edge(state, cpu_id, "k_thread_resume", ty=ZephyrEdgeType.interaction)
        return state

    @staticmethod
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Thread),))
    def k_thread_suspend(graph, state, cpu_id, args, va):
        state = state.copy()

        if Zephyr.enable_sse:
            ic = za.InterpreterContext(Zephyr.irx, state, cpu_id)
            thread = ic.thread_sym_2_ptr(args.symbol)
            ic.zi.irm.skip(["memcpy", "memset"])
            ic.run_function_with_arch_swap("z_impl_k_thread_suspend", [thread.ptr], ['PTR'])
            ic.update()

        add_self_edge(state, cpu_id, "k_thread_suspend", ty=ZephyrEdgeType.interaction)
        return state

    @staticmethod
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Thread),))
    def k_wakeup(graph, state, cpu_id, args, va):
        state = state.copy()

        if Zephyr.enable_sse:
            ic = za.InterpreterContext(Zephyr.irx, state, cpu_id)
            thread = ic.thread_sym_2_ptr(args.symbol)
            ic.zi.irm.skip(["memcpy", "memset"])

            ic.zi.z_mark_thread_as_started(thread)
            # FIXME: z_impl_k_wakeup doesn't remove _THREAD_PRESTART 
            # ic.run_function_with_arch_swap("z_impl_k_wakeup", [thread.ptr], ['PTR'])
            ic.update()

        add_self_edge(state, cpu_id, "k_wakeup", ty=ZephyrEdgeType.interaction)
        return state

    # void k_yield(void)
    @syscall(categories={SyscallCategory.comm})
    def k_yield(graph, state, cpu_id, args, va):
        state = state.copy()

        if Zephyr.enable_sse:
            ic = za.InterpreterContext(Zephyr.irx, state, cpu_id)
            ic.run_function_with_arch_swap("z_impl_k_yield", [], [])

        add_self_edge(state, cpu_id, "k_yield", ty=ZephyrEdgeType.interaction)
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

        if Zephyr.enable_sse:
            ic = za.InterpreterContext(Zephyr.irx, state, cpu_id)
            ic.run_function_with_arch_swap("k_sched_lock", [], [])

        Zephyr.add_kernel_comm(state, cpu_id, "k_sched_lock")
        return state

    # void k_sched_unlock(void)
    @syscall(categories={SyscallCategory.comm})
    def k_sched_unlock(graph, state, cpu_id, args, va):
        state = state.copy()

        if Zephyr.enable_sse:
            ic = za.InterpreterContext(Zephyr.irx, state, cpu_id)
            ic.run_function_with_arch_swap("k_sched_unlock", [], [])

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

    @staticmethod
    def x_sem_take(graph, state, cpu_id, args, va):
        assert 'CONFIG_USERSPACE' not in Zephyr.config # userspace is not implemented
        ic = za.InterpreterContext(Zephyr.irx, state, cpu_id)
        # symbol = Zephyr.get_symbol(args.symbol)
        v = state.instances.get_node(args.symbol)
        if v == None:
            raise RuntimeError("Vertex to semaphore not found")
        sem = ic.get_semaphore(v)
        timeout = za.to_timeout_value(args.timeout)

        ret, did_swap = ic.run_function_with_arch_swap("z_impl_k_sem_take", [sem.ptr, timeout], ['PTR', Zephyr.get_timeout_llvm_type()])

        print("z_impl_k_sem_take:", ret["IntVal"]["S"], did_swap)
    
    @staticmethod
    def x_sem_give(graph, state, cpu_id, args, va):
        assert 'CONFIG_USERSPACE' not in Zephyr.config # userspace is not implemented
        ic = za.InterpreterContext(Zephyr.irx, state, cpu_id)
        v = state.instances.get_node(args.symbol)
        sem = ic.get_semaphore(v)

        ret, did_swap = ic.run_function_with_arch_swap("z_impl_k_sem_give", [sem.ptr], ['PTR'])

        print("z_impl_k_sem_give:", ret["IntVal"]["S"], did_swap)
    

    # int k_sem_take(struct k_sem *sem, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=KernelSemaphore),
                        Arg("timeout", hint=SigType.value)))
    def k_sem_take(graph, state, cpu_id, args, va):
        state = state.copy()

        if Zephyr.enable_sse:
            Zephyr.x_sem_take(graph, state, cpu_id, args, va)


        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_sem_take", "KernelSemaphore")
        return state

    # void k_sem_give(struct k_sem *sem)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=KernelSemaphore),))
    def k_sem_give(graph, state, cpu_id, args, va):
        state = state.copy()

        if Zephyr.enable_sse:
            Zephyr.x_sem_give(graph, state, cpu_id, args, va)

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
             signature=(Arg("symbol", hint=SigType.instance, ty=UserSemaphore),
                        Arg("timeout", hint=SigType.value)))
    def sys_sem_take(graph, state, cpu_id, args, va):
        state = state.copy()

        if Zephyr.enable_sse:
            Zephyr.x_sem_take(graph, state, cpu_id, args, va)

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "sys_sem_take", "UserSemaphore")
        return state

    # int sys_sem_give(struct sys_sem *sem)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=UserSemaphore),))
    def sys_sem_give(graph, state, cpu_id, args, va):
        state = state.copy()

        if Zephyr.enable_sse:
            Zephyr.x_sem_give(graph, state, cpu_id, args, va)

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

        if Zephyr.enable_sse:
            ic = za.InterpreterContext(Zephyr.irx, state, cpu_id)
            timeout = za.to_timeout_value(args.timeout)
            v = state.instances.get_node(args.symbol)
            kobj_mutex = ic.get_kobj_from_vertex(v)
            # ic.zi.irm.set_print_llvmir(True)
            ic.run_function_with_arch_swap("z_impl_k_mutex_lock", [kobj_mutex.ptr, timeout], ['PTR', Zephyr.get_timeout_llvm_type()])
            # ic.zi.irm.set_print_llvmir(False)

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_mutex_lock", "Mutex")
        return state

    # int k_mutex_unlock(struct k_mutex *mutex)
    # Unlock should only ever be called by the locking thread.
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=Mutex),))
    def k_mutex_unlock(graph, state, cpu_id, args, va):
        state = state.copy()

        if Zephyr.enable_sse:
            ic = za.InterpreterContext(Zephyr.irx, state, cpu_id)
            v = state.instances.get_node(args.symbol)
            kobj_mutex = ic.get_kobj_from_vertex(v)
            ic.run_function_with_arch_swap("z_impl_k_mutex_unlock", [kobj_mutex.ptr], ['PTR'])

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

        if Zephyr.enable_sse:
            ic = za.InterpreterContext(Zephyr.irx, state, cpu_id)
            timeout = za.to_timeout_value(args.timeout)
            v = state.instances.get_node(args.symbol)
            kobj_msgq = ic.get_kobj_from_vertex(v)
            ic.zi.irm.skip(["memcpy", "memset"])
            ic.run_function_with_arch_swap("z_impl_k_msgq_put", [kobj_msgq.ptr, 0x00, timeout], ['PTR', 'PTR', Zephyr.get_timeout_llvm_type()])

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "k_msgq_put", "MSGQ")
        return state

    # int k_msgq_get(struct k_msgq *msgq, void *data, k_timeout_t timeout)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance, ty=MSGQ),
                        Arg("item", hint=SigType.symbol, ty=pyllco.Value),
                        Arg("timeout", hint=SigType.value)))
    def k_msgq_get(graph, state, cpu_id, args, va):
        state = state.copy()

        if Zephyr.enable_sse:
            ic = za.InterpreterContext(Zephyr.irx, state, cpu_id)
            timeout = za.to_timeout_value(args.timeout)
            v = state.instances.get_node(args.symbol)
            kobj_msgq = ic.get_kobj_from_vertex(v)
            ic.zi.irm.skip(["memcpy", "memset"])
            ic.run_function_with_arch_swap("z_impl_k_msgq_get", [kobj_msgq.ptr, 0x00, timeout], ['PTR', 'PTR', Zephyr.get_timeout_llvm_type()])

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

        if Zephyr.enable_sse:
            ic = za.InterpreterContext(Zephyr.irx, state, cpu_id)
            v = state.instances.get_node(args.symbol)
            kobj_msgq = ic.get_kobj_from_vertex(v)
            ic.run_function_with_arch_swap("z_impl_k_msgq_purge", [kobj_msgq.ptr], ['PTR'])

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
            state, cpu_id, cur, "k_thread_abort", ty=ZephyrEdgeType.interaction
        )
        return state


    
    # Timer API

    @syscall(categories={SyscallCategory.create},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("expiry_fn", hint=SigType.symbol),
                        Arg("stop_fn", hint=SigType.symbol)))
    def k_timer_init(graph, state, cpu_id, args, va):
        state = state.copy()
        cfg = graph.cfg

        # in the zephyr_post step both functions will be created with an ISR instance
        instance = Timer(
            args.expiry_fn.value.get_name(),
            args.stop_fn.value.get_name(),
            Zephyr.get_symbol(args.symbol),
        )

        v = Zephyr.create_or_get_instance(cfg, state, cpu_id, va, "Timer", instance, args.symbol, "k_timer_init")

        state.context[args.symbol.value] = za.TimerContext(
            args.expiry_fn.value.get_name(),
            args.stop_fn.value.get_name()
        )

        return state
    
    @staticmethod
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("duration", hint=SigType.value),
                        Arg("period", hint=SigType.value)))
    def k_timer_start(graph, state, cpu_id, args, va):
        state = state.copy()
        cfg = graph.cfg

        # FIXME: value analyzer fails to get a value for args.period of the type %struct.k_timeout_t { u64 } = K_NO_WAIT
        if Zephyr.enable_sse:
            timer = state.context[args.symbol.value]
            v = state.instances.get_node(args.symbol.value)

            timer.period = za.to_timeout_value(args.period)
            timer.status = 0
            timer.timeout = za.Timeout(v, 'z_timer_expiration_handler', za.to_timeout_value(args.duration))

            kernel = Zephyr.get_kernel_context(state)
            kernel.timeout_list.append(timer.timeout)

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "z_impl_k_timer_start", "Timer")
        return state

    @staticmethod
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("symbol", hint=SigType.instance),))
    def k_timer_stop(graph, state, cpu_id, args, va):
        state = state.copy()
        v = state.instances.get_node(args.symbol.value)

        if Zephyr.enable_sse:
            # this function could reschedule, so run interpreter...
            ic = za.InterpreterContext(Zephyr.irx, state, cpu_id)
            kobj_timer = ic.get_kobj_from_vertex(v)
            # ic.zi.irm.set_print_llvmir(True)
            ic.run_function_with_arch_swap("z_impl_k_timer_stop", [kobj_timer.ptr], ['PTR'])

        Zephyr.add_instance_comm(state, cpu_id, args.symbol, "z_impl_k_timer_stop", "Timer")
        return state

    # int k_mem_slab_init(struct k_mem_slab *slab, void *buffer,
	#		   size_t block_size, uint32_t num_blocks);
    @syscall(categories={SyscallCategory.create},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("buf", hint=SigType.symbol, ty=pyllco.Value),
                        Arg("block_size", hint=SigType.value),
                        Arg("num_blocks", hint=SigType.value)))
    def k_mem_slab_init(graph, state, cpu_id, args, va):
        state = state.copy()
        cfg = graph.cfg
        return state

    #int k_mem_slab_alloc(struct k_mem_slab *slab, void **mem,
    #			    k_timeout_t timeout);
    @syscall(categories={SyscallCategory.create},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("mem", hint=SigType.symbol),
                        Arg("timeout", hint=SigType.value)))
    def k_mem_slab_alloc(graph, state, cpu_id, args, va):
        state = state.copy()
        cfg = graph.cfg
        return state

    #int void k_mem_slab_free(struct k_mem_slab *slab, void *mem);
    @syscall(categories={SyscallCategory.create},
             signature=(Arg("symbol", hint=SigType.instance),
                        Arg("mem", hint=SigType.symbol)))
    def k_mem_slab_free(graph, state, cpu_id, args, va):
        state = state.copy()
        cfg = graph.cfg
        return state

    @staticmethod
    def _find_isr_by_entry_name(state, entry_name):
        for v, isr_obj in state.instances.get(ISR):
            if entry_name == isr_obj.entry_name:
                return v, isr_obj
        return None

    @staticmethod
    def _find_irq_by_id(state, id):
        for v, isr_obj in state.instances.get(IRQ):
            if id == isr_obj.id:
                return v, isr_obj
        return None

    # void arch_irq_enable(unsigned int irq)
    # irq_enable is just a macro to the arch_ function
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("irq", hint=SigType.value),))
    def arch_irq_enable(graph, state, cpu_id, args, va):
        state = state.copy()
        cfg = graph.cfg

        v, obj = Zephyr._find_irq_by_id(state, args.irq)
        state.context[obj].status = TaskStatus.running
        state.context[obj].dyn_prio = [1]

        return state

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("irq", hint=SigType.value),))
    def arch_irq_disable(graph, state, cpu_id, args, va):
        state = state.copy()
        cfg = graph.cfg

        v, obj = Zephyr._find_irq_by_id(state, args.irq)
        state.context[obj].status = TaskStatus.blocked
        state.context[obj].dyn_prio = [-1]

        return state

    @staticmethod
    def handle_irq(graph, state, cpu_id, irq):
        # states=[]
        if irq.active == False:
            return None

        root_state = state
        if irq.name == 'sys_clock_announce':
            kernel = Zephyr.get_kernel_context(state)
            # currently: only the top most timeout triggers
            for to in kernel.timeout_list: # since we dont have any time infomrmation we could trigger all "combinations" and return an array
                # TODO seperate timer and system sleep
                state = root_state.copy()
                interrupted_thread = state.cur_control_inst(cpu_id)
                callback_fn_name = za.InterpreterContext.sys_clock_announce(Zephyr.irx, state, cpu_id, to) # TODO it is better to handle this in handle_exit since we can return multiple states
                if callback_fn_name != None: # handle apllication callback ISR
                    cpu = state.cpus[cpu_id]

                    # FIXME: since multiple timeouts can have the same entrypoint name this solution may fail for that case
                    # its most certently the top most timeout that will be triggered
                    new_vertex, new_obj = Zephyr._find_isr_by_entry_name(state, callback_fn_name)
                    old_ctx = state.cur_context(cpu_id)

                    if old_ctx:
                        old_ctx.abb = state.cfg.vertex(cpu.abb)
                        old_ctx.call_path = cpu.call_path

                    isr_function = graph.cfg.get_function_by_name(new_obj.entry_name)
                    abb = graph.cfg.get_entry_abb(isr_function)

                    new_ctx = za.ISRContext(
                        status=TaskStatus.running,
                        abb=abb,
                        call_path=CallPath(),
                        dyn_prio=[],
                    )

                    state.context[new_obj] = new_ctx

                    cpu.abb = state.cfg.vertex(new_ctx.abb)
                    cpu.call_path = new_ctx.call_path
                    cpu.control_instance = state.instances.vertex(new_vertex)
                    cpu.exec_state = ExecState.from_abbtype(state.cfg.vp.type[cpu.abb])
                    cpu.analysis_context.nested += 1
                    # cpu.analysis_context.interrupted_thread = state.cur_control_inst(cpu_id)
                    if isinstance(interrupted_thread, Thread):
                        cpu.analysis_context.interrupted_thread = interrupted_thread
                    cpu.irq_on = False

                    kernel = Zephyr.get_kernel_context(state)
                    kernel.cache = new_vertex

                # states.append(state)
                return state

            # return states if len(states) > 0 else None
            # at this point sys_clock_announce must have handeled a sleep timeout or a sem timeout
            return state
        if irq.name == 'z_time_slice': # "virtual ISR", sys_clock_announce would handle this normally
            # TODO maybe schedule in as an ISR ?
            state = root_state.copy()
            ic = za.InterpreterContext(Zephyr.irx, state, cpu_id)
            kernel = Zephyr.get_kernel_context(state)

            # TODO check with thread_is_sliceable if we schould yield the thread
            thread = ic.get_kobj_from_vertex(kernel.cache)
            ret = ic.zi.run_function("thread_is_sliceable", [thread.ptr], ['PTR'], True)

            if ret['IntVal']['Z'] != 0:
                # in the ISR update_cache() is executed but does not reschedule, but will reschedule on interrupt return
                # this will just update the state.kernel.cache vertex
                # ic.zi.irm.set_print_llvmir(True)
                ic.run_function_with_arch_swap("move_thread_to_end_of_prio_q", [thread.ptr], ['PTR'])
                # ic.run_function_with_arch_swap("z_impl_k_yield", [thread.ptr], ['PTR'])
                return state

            return None

        if irq.name.startswith('IRQCONNECT'): # user declared ISRs, # mostly same as sys_clock_announce
            kernel = Zephyr.get_kernel_context(state)
            state = root_state.copy()

            interrupted_thread = state.cur_control_inst(cpu_id)

            isr_fn_name = irq.isr_handler.entry_name
            if isr_fn_name != None: # handle application ISR
                cpu = state.cpus[cpu_id]

                if state.context[irq].dyn_prio[0] < 0 or state.context[irq].status == TaskStatus.blocked:
                    logger.info(f"{irq.name} not ready (prio: {state.context[irq].dyn_prio} status {state.context[irq].status})")
                    return None
                else:
                    logger.info(f"{irq.name} running")
                    if Zephyr.analyze_irqs_once:
                        state.context[irq].status = TaskStatus.blocked
                        state.context[irq].dyn_prio = [-1]

                new_vertex, new_obj = Zephyr._find_isr_by_entry_name(state, isr_fn_name)
                old_ctx = state.cur_context(cpu_id)

                if old_ctx:
                    old_ctx.abb = state.cfg.vertex(cpu.abb)
                    old_ctx.call_path = cpu.call_path

                isr_function = graph.cfg.get_function_by_name(new_obj.entry_name)
                abb = graph.cfg.get_entry_abb(isr_function)

                new_ctx = za.ISRContext(
                    status=TaskStatus.running,
                    abb=abb,
                    call_path=CallPath(),
                    dyn_prio=[],
                )

                state.context[new_obj] = new_ctx

                cpu.abb = state.cfg.vertex(new_ctx.abb)
                cpu.call_path = new_ctx.call_path
                cpu.control_instance = state.instances.vertex(new_vertex)
                cpu.exec_state = ExecState.from_abbtype(state.cfg.vp.type[cpu.abb])

                if cpu.analysis_context == None:
                    cpu.analysis_context = za.ZephyrCPUAnalysisContext()
                cpu.analysis_context.nested += 1
                # cpu.analysis_context.interrupted_thread = state.cur_control_inst(cpu_id)
                if isinstance(interrupted_thread, Thread):
                    cpu.analysis_context.interrupted_thread = interrupted_thread
                cpu.irq_on = False

                kernel = Zephyr.get_kernel_context(state)
                kernel.cache = new_vertex

                # states.append(state)
                return state

        raise NotImplementedError
