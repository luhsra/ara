import enum

from ara.os.os_base import TaskStatus
from pyirinterpreter import PyIRModuleInterpreter
from diff import diff
from proxy import PTR
import zephyr # irx.zephyr (in future: generated)
from ara.os.zephyr_interpreter import ZephyrInterpreter
from ara.util import get_logger
from dataclasses import dataclass, field
from graph_tool import Vertex
from typing import Iterator, List, Annotated
from .os_base import OSBase, ControlInstance, CPUList, CPU, OSState, ExecState, TaskStatus, ControlContext, IRQ
from copy import copy
from graph_tool import Vertex

logger = get_logger("ZephyrAdapters")

def BIT(bit: int) -> int:
    return 1 << bit


@dataclass(frozen=True)
class Timeout:
    v: Vertex # thread vertex
    fn: int
    dticks: int

    def __hash__(self) -> int:
        return hash((__class__.__name__, self.v, self.v, self.dticks))

@dataclass # (frozen=True)
class ZephyrKernelContext:
    """Kernel Object Representation"""

    # Zephyr: .kernel.ready_q.runq (_dnode)
    ready_q: List[Vertex] = field(default_factory=lambda: []) # list of thread vertices

    # Zephyr: .kernel.ready_q.cache (*k_thread)
    cache: Vertex = field(default=None) # list of next thread vertex


    # simple also put global variables here:

    """ timeout_list, keep this sorted """
    timeout_list: List[Timeout] = field(default_factory=lambda: [])

    def __repr__(self) -> str:
        threads = []
        for v in self.ready_q:
            threads.append(str(v))
        s = "[ready_q: "
        s += ", ".join(threads)
        s += "]"
        return s

    def __copy__(self):
        return type(self)(
            ready_q=list(self.ready_q),
            cache=self.cache,
            timeout_list=list(self.timeout_list),
        )

    def __hash__(self) -> int:
        ready_q_hash = 0
        timeout_list_hash = 0
        for v in self.timeout_list:
            timeout_list_hash += hash(v)
        for v in self.ready_q:
            ready_q_hash += hash(v)
        return hash((__class__.__name__, ready_q_hash, self.cache, timeout_list_hash))



@dataclass
class ZephyrCPUAnalysisContext:
    current: object = None

    def copy(self):
        return ZephyrCPUAnalysisContext(self.current)


@dataclass
class ThreadContext(ControlContext):
    pended_on: Vertex = field(default=None)
    join_queue: List[Vertex] = field(default_factory=lambda: [])
    thread_state: int = 0
    preempt: int = 0
    order_key: int = 0

    def __hash__(self):
        join_queue_hash = 0
        for v in self.join_queue:
            join_queue_hash += hash(v)
        return hash(
            (
                "ThreadContext",
                self.status,
                self.abb,
                self.call_path,
                self.pended_on,
                join_queue_hash,
                self.thread_state,
                self.preempt,
                self.order_key,
            )
        )

    def __copy__(self):
        return ThreadContext(
            status=self.status,
            abb=self.abb,
            call_path=copy(self.call_path),
            dyn_prio=list(self.dyn_prio),
            pended_on=self.pended_on,
            join_queue=list(self.join_queue),
            thread_state=self.thread_state,
            preempt=self.preempt,
            order_key=self.order_key,
        )


# FIXME: move this to e.g. zephyr.adapters?
# counterpart of ara.os.os_base.TaskStatus
class ThreadStateAdapter(enum.IntFlag):
    # from include/zephyr/kernel_struct.h
    _THREAD_DUMMY = BIT(0)
    _THREAD_PENDING = BIT(1)
    _THREAD_PRESTART = BIT(2)
    _THREAD_DEAD = BIT(3)
    _THREAD_SUSPENDED = BIT(4)
    _THREAD_ABORTING = BIT(5)
    _THREAD_SUSPENDING = BIT(6)
    _THREAD_QUEUED = BIT(7)


    @staticmethod
    def fromZephyr(state: int) -> TaskStatus:
        ZephyrMap = {
            0: TaskStatus.running,
            ThreadStateAdapter._THREAD_DUMMY: TaskStatus.terminated,
            ThreadStateAdapter._THREAD_PENDING: TaskStatus.running,
            ThreadStateAdapter._THREAD_PRESTART: TaskStatus.blocked,
            ThreadStateAdapter._THREAD_DEAD: TaskStatus.terminated,
            ThreadStateAdapter._THREAD_SUSPENDED: TaskStatus.suspended,
            ThreadStateAdapter._THREAD_ABORTING: TaskStatus.terminated,
            ThreadStateAdapter._THREAD_SUSPENDING: TaskStatus.suspended,
            ThreadStateAdapter._THREAD_QUEUED: TaskStatus.ready,

            # blocked: if not in ready queue ... not as simple as a map... for example waiting for a kernel object / e.g. sem
        }

        # TODO parse the zephyr state variable and create the corresponding TaskStatus
        #return TaskStatus.running

        # need more information than just the thread.state
        # _z_kernel for the queues ...
        if state in ZephyrMap:
            return ZephyrMap[state]
        return state

    @staticmethod
    def fromAbSS(state: TaskStatus) -> int:
        # AbSSMap = {v: k for k, v in ZephyrMap.items()}
        AbSSMap = {
            TaskStatus.running: 0,
            TaskStatus.blocked: ThreadStateAdapter._THREAD_PENDING,
            TaskStatus.ready: ThreadStateAdapter._THREAD_QUEUED,
            TaskStatus.suspended: ThreadStateAdapter._THREAD_SUSPENDING,
            TaskStatus.terminated: ThreadStateAdapter._THREAD_DEAD,
        }
        return AbSSMap[state]




def to_timeout_value(timeout):
    if timeout == -1:
        if InterpreterContext.Zephyr.config['CONFIG_TIMEOUT_64BIT']:
            timeout = 0xFFFFFFFFFFFFFFFF
        else:
            timeout = 0xFFFFFFFF
    return timeout


class InterpreterContext:

    Zephyr = None
    config = None

    def __init__(self, state, cpu_id):
        self.state = state
        self.cpu_id = cpu_id
        self.threads = []
        self.threads_ready = []
        self.threads_map = {}
        self.threads_vertex_map = {}

        self.zi = ZephyrInterpreter(InterpreterContext.Zephyr.config)
        self.proxy = self.zi.proxy
        self.threads, self.idle_thread, self.threads_map, self.threads_vertex_map \
            = InterpreterContext._prepare(self.zi, state, cpu_id)

        self.vertices_thread_map = {v: k for k, v in self.threads_vertex_map.items()}

        self.kernel = InterpreterContext.Zephyr.get_kernel_context(state)



        self.dot_it("prepare")


    def thread_sym_2_ptr(self, symbol):
        # obj = state.instances.vp.obj[symbol]
        tctx = self.state.context[symbol]
        inv_threads_map = {v: k for k, v in self.threads_map.items()}
        ptr = inv_threads_map[tctx]
        return self.proxy.deref(PTR(zephyr.k_thread, ptr)) # or search in threads variable

    def run_function_with_arch_swap(self, function_name, args, hints, update=True):
        self.zi.irm.stop(["arch_swap"]) # z_swap(inlined) CONF: arch_swap or with SMP: arch_switch
        self.zi.run_function(function_name, args, hints)

        if self.zi.irm.getCurrentCallFunctionName() == "arch_swap":
            self.zi.irm.putReturnValue(0, 'APInt32') # emulate that the callee returned 0

        self.zi.finish_function()

        if update:
            self.update()

    @staticmethod
    def sys_clock_announce(state, cpu_id):
        """ call sys_clock_announce with the ticks value of the next timeout to trigger it"""
        kernel = InterpreterContext.Zephyr.get_kernel_context(state)

        if len(kernel.timeout_list) > 0:
            # better: use 'next_timeout' zephyr function,
            # or alternativaly search in python for the next timeout: min(dticks).
            # since it is expected to be sorted anyway, this is fine to. unless it is modified and not sorted
            timeout = kernel.timeout_list[0]

            zi = ZephyrInterpreter(InterpreterContext.Zephyr.config)

            threads, idle_thread, threads_map, threads_vertex_map = InterpreterContext._prepare(zi, state, cpu_id)

            #zi.irm.set_print_llvmir(True)
            zi.run_function("sys_clock_announce", [timeout.dticks], ['APInt64'])
            #zi.irm.set_print_llvmir(False)
            zi.finish_function()

            InterpreterContext._update(zi, state, cpu_id, threads, idle_thread, threads_map, threads_vertex_map)

            # zi.run_function("update_cache", [0], ['APInt32'])
            return True
        return False

    @staticmethod
    def debug_irx_print_kernel_objects(zi, threads, idle_thread, threads_map):
        irm = zi.irm
        proxy = zi.proxy
        _kernel = zi._kernel

        print(irm.getCallStack())
        print(irm.getCurrentCallFunctionName())
        print(irm.getCurrentCallArgs())
        for old in [idle_thread, _kernel] + threads:
            print("\n", type(old), old.__ptr__)
            new = type(old)()
            new.ptr = old.ptr
            proxy.get(new)
            changes = diff(old, new)
            for x in changes:
                print(f"{x.path_str():30s}: {x.obj1} => {x.obj2}")

        # new_z_kernel = zephyr.z_kernel()
        # new_z_kernel.ptr = _kernel.ptr
        # proxy.get(new_z_kernel)
        # print("ready_q.cache (za):", za.ThreadStateAdapter.fromZephyr(new_z_kernel.ready_q.cache))

        for old in threads:
            new = type(old)()
            new.ptr = old.ptr
            proxy.get(new)
            abSSTState = ThreadStateAdapter.fromZephyr(new.base.thread_state)
            abSSTStateName = str(abSSTState)
            if isinstance(abSSTState, TaskStatus):
                abSSTStateName = abSSTState.name
            print(type(old), old.__ptr__)
            print("\n base.thread_state (za):", abSSTStateName)
            print("\n AbSS:", threads_map[old.ptr])

    @staticmethod
    def _thread_vertex_2_ptr(v, threads_vertex_map, proxy):
        inv_threads_vertex_map = {v: k for k, v in threads_vertex_map.items()}
        ptr = inv_threads_vertex_map[v]
        return proxy.deref(PTR(zephyr.k_thread, ptr))

    def thread_vertex_2_ptr(self, v):
        ptr = self.vertices_thread_map[v]
        return self.proxy.deref(PTR(zephyr.k_thread, ptr))

    @staticmethod
    def _prepare(zi: ZephyrInterpreter, state, cpu_id):
        kernel = InterpreterContext.Zephyr.get_kernel_context(state)

        # zi.init(graph.os.llvm_ir_file)
        zi.init(InterpreterContext.Zephyr.llvm_ir_file)
        zi.z_cstart()
        # zi.bg_thread_main()

        proxy = zi.proxy
        _kernel = zi._kernel
        timeout_list = zi.timeout_list

        # # remove main thread from ready queue
        # z_main_thread = proxy.Global(zephyr.k_thread, 'z_main_thread')
        # zi.unready_thread(z_main_thread)

        proxy.get(_kernel)
        proxy.get(timeout_list)


        # irm.set_print_llvmir(True)
        # zi.unready_thread(threads[0])

        print("cache:       ", _kernel.ready_q.cache)
        print("current:     ", _kernel.cpus[cpu_id].current)
        print("idle_thread: ", _kernel.cpus[cpu_id].idle_thread)

        timeout_threads_vertices = [t.v for t in kernel.timeout_list]

        threads = []
        threads_ready = []
        threads_map = {}
        threads_vertex_map = {}

        from .zephyr import Thread
        for v, obj in state.instances.get(Thread):
            ctx = ThreadContext(TaskStatus.ready, None, None, []) # dummy context
            # if v in state.instances.vp.obj:
            if obj in state.context:
                ctx = state.context[obj]

            # TODO: maybe search for the k_thread global, instead of creation new ones...
            # t = zi.helper_create_thread(ThreadStateAdapter.fromAbSS(ctx.status))
            t = zi.helper_create_thread()

            threads.append(t)
            threads_map[t.ptr] = ctx
            threads_vertex_map[t.ptr] = v

        vertices_thread_map = {v: k for k, v in threads_vertex_map.items()}

        for v, obj in state.instances.get(Thread):
            ptr = vertices_thread_map[v]
            t = proxy.deref(PTR(zephyr.k_thread, ptr))

            wait_q = proxy.get_member(t, ['join_queue', 'waitq'])
            proxy.get(wait_q)

            # restore join_queue
            if obj in state.context:
                ctx = state.context[obj]
                for jv in ctx.join_queue:
                    zi.run_function('add_to_waitq_locked', [vertices_thread_map[jv], wait_q.ptr], ['PTR', 'PTR'])


        for v, obj in state.instances.get(Thread):
            ptr = vertices_thread_map[v]
            t = proxy.deref(PTR(zephyr.k_thread, ptr))
            ctx = ThreadContext(TaskStatus.ready, None, None, []) # dummy context
            if obj in state.context:
                ctx = state.context[obj]
            proxy.get(t)

            t.base.thread_status = ctx.thread_state & ~ThreadStateAdapter._THREAD_QUEUED
            t.base.preempt = ctx.preempt
            t.base.order_key = ctx.order_key

            if obj in state.context:
                ctx = state.context[obj]

                # restore pended_on
                if ctx.pended_on is not None:
                    obj = state.instances.vp.obj[ctx.pended_on]
                    pended_on_thread_ptr = vertices_thread_map[ctx.pended_on]
                    pended_on_thread = proxy.deref(PTR(zephyr.k_thread, pended_on_thread_ptr))
                    join_queue = proxy.get_member(pended_on_thread, ['join_queue', 'waitq'])
                    t.pended_on = join_queue.ptr

            proxy.put(t)



        # # for tctx in Zephyr.get_thread_ccs(state):
        # for v in kernel.ready_q + timeout_threads_vertices:
        #     # tctx = ControlContext(TaskStatus.ready, None, None, []) # dummy context
        #     # if v in state.instances.vp.obj:
        #     obj = state.instances.vp.obj[v]
        #     tctx = state.context[obj]
        #     print("AbSS Thread context:", tctx)

        #     # TODO: maybe search for the k_thread global, instead of creation new ones...

        #     t = zi.helper_create_thread(ThreadStateAdapter.fromAbSS(tctx.status))
        #     threads.append(t)
        #     # threads_ready.append(t)
        #     threads_map[t.ptr] = tctx
        #     threads_vertex_map[t.ptr] = v

        # for v in timeout_threads_vertices:
        #     obj = state.instances.vp.obj[v]
        #     tctx = state.context[obj]
        #     t = zi.helper_create_thread(za.ThreadStateAdapter.fromAbSS(tctx.status))
        #     threads.append(t)
        #     threads_map[t.ptr] = tctx
        #     threads_vertex_map[t.ptr] = v



        for v in kernel.ready_q:
            t = proxy.deref(PTR(zephyr.k_thread, vertices_thread_map[v]))
            threads_ready.append(t)
            index = state.instances.vertex_index[v]
            print(f"ready thread: vertex idx: {index}")


        # get current thread
        current_thread = zi.z_idle_threads[cpu_id]
        #current_thread = _kernel.cpus[cpu_id].idle_thread

        if len(kernel.ready_q) > 0:
            # TODO: this should be the kernel.cache thread, but they are equal, aren't they?
            current_thread = threads_ready[0]

        _kernel.cpus[cpu_id].current.ptr = current_thread.ptr

        zi.run_function('z_mark_thread_as_started', [current_thread.ptr], ['PTR'])
        if len(kernel.ready_q) > 0: # if not idle thread  # only if SMP is anabled
            zi.run_function('z_ready_thread', [current_thread.ptr], ['PTR'])



        proxy.get(_kernel)

        for ptr in zi.dlist_itr_ptr(_kernel, ["ready_q", "runq"]): # only for CONFIG_SCHED_DUMB
            ptr.cls = zephyr.k_thread # "cast" *dlist to *k_thread" (shortcut)
            print("dlist_itr ready_q", ptr)

        # irm.set_print_llvmir(True)
        # zi.unready_thread(threads[0])

        # print('_kernel.ready_q.cache', _kernel.ready_q.cache)
        # print('_kernel.cpus[0].current', _kernel.cpus[cpu_id].current)
        # print('_kernel.cpus[0].idle_thread', _kernel.cpus[cpu_id].idle_thread)
        print('z_main_thread', zi.z_main_thread.__ptr__)
        print('_thread_dummy', zi._thread_dummy.__ptr__)
        print('_kernel.ready_q.runq.next', _kernel.ready_q.runq.next)
        proxy.get_member(_kernel, ['ready_q', 'runq'])
        print('_kernel.ready_q.runq', _kernel.ready_q.runq)


        # switch_to_main_thread
        _kernel.ready_q.cache.ptr = current_thread.ptr # will be updated from z_ready_thread()
        _kernel.cpus[cpu_id].current.ptr = current_thread.ptr
        #_kernel.cpus[0].idle_thread.ptr = idle_thread.ptr

        proxy.put(_kernel)

        # zi.helper_threads_enqueue(threads_ready[1:])
        zi.helper_threads_enqueue(threads_ready)
        # zi.helper_threads_ready(threads)

        proxy.get(_kernel)


        print("current:     ", _kernel.cpus[cpu_id].current)
        InterpreterContext.Zephyr.debug_print_threads(state, vertices_thread_map)

        #zi.helper_get_objs([idle_thread] + threads)
        #idle_thread = zi.helper_create_thread(za.ThreadStateAdapter.fromAbSS(TaskStatus.ready), False)
        idle_thread = zi.z_idle_threads[cpu_id]
        idle_thread_base = proxy.get_member(idle_thread, ['base'])
        idle_qnode_dlist = proxy.get_member(idle_thread_base, ['qnode_dlist'])
        proxy.get(idle_thread)
        proxy.get(idle_thread_base)
        proxy.get(idle_qnode_dlist)
        threads_map[idle_thread.ptr] = None
        threads_vertex_map[idle_thread.ptr] = InterpreterContext.Zephyr.idle_threads[cpu_id]


        # restore thread timeouts:
        for to in kernel.timeout_list:
            fn = zi.irm.find_function_named(to.fn)
            if fn == 0:
                logger.warning(f"function name {to.fn} could not be found in LLVM module")

            timeout_thread = InterpreterContext._thread_vertex_2_ptr(to.v, threads_vertex_map, proxy)
            to = proxy.get_member(timeout_thread, ['base', 'timeout'])
            zi.z_add_timeout(
                to,
                fn,
                to.dticks
            )



        return threads, idle_thread, threads_map, threads_vertex_map

    def update(self):
        """ Pull variables from irx into AbSS state"""
        InterpreterContext._update(self.zi, self.state, self.cpu_id,
                                   self.threads, self.idle_thread, self.threads_map, self.threads_vertex_map)

        self.dot_it("postupdate")


    @staticmethod
    def _update(zi, state, cpu_id, threads, idle_thread, threads_map, threads_vertex_map):
        kernel: ZephyrKernelContext = InterpreterContext.Zephyr.get_kernel_context(state)

        proxy = zi.proxy
        _kernel = zi._kernel
        timeout_list = zi.timeout_list

        for old in [idle_thread, _kernel, timeout_list] + threads:
            print("\n", type(old), old.__ptr__)
            new = type(old)()
            new.ptr = old.ptr
            proxy.get(new)
            changes = diff(old, new)
            for x in changes:
                print(f"{x.path_str():30s}: {x.obj1} => {x.obj2}")

        proxy.get(timeout_list)
        proxy.get(_kernel)

        # update timeout_list
        kernel.timeout_list.clear()
        for ptr in zi.dlist_itr(timeout_list):
            print("dlist_itr", ptr)
            timeout_base_thread = proxy.container_of_ptr(ptr, zephyr._thread_base, 'timeout')
            timeout_thread = proxy.container_of(timeout_base_thread, zephyr.k_thread, 'base')
            print("timeout_thread: ", timeout_thread.__ptr__)
            timeout = proxy.get_member(timeout_base_thread, ['timeout'])

            v = threads_vertex_map[timeout_thread.ptr]
            to = Timeout(v, zi.irm.find_function_by_vvptr(timeout.fn), timeout.dticks)
            kernel.timeout_list.append(to)

        # calculate missing ptr address as it is embedded in a structure
        #_kernel.ready_q.runq.ptr = _kernel.ptr + proxy.offset_of(_kernel, ['ready_q', 'runq'])
        #proxy.update_ptr(_kernel, ['ready_q', 'runq'])


        # TODO: replace with next_up() or runq_best() and runq_remove
        kernel.ready_q.clear()
        for ptr in zi.dlist_itr_ptr(_kernel, ["ready_q", "runq"]): # only for CONFIG_SCHED_DUMB
            ptr.cls = zephyr.k_thread # "cast" *dlist to *k_thread" (shortcut)
            print("dlist_itr ready_q", ptr)

            v = threads_vertex_map[ptr.ptr]
            kernel.ready_q.append(v)

        # update next thread
        if _kernel.ready_q.cache.ptr in threads_vertex_map:
            kernel.cache = threads_vertex_map[_kernel.ready_q.cache.ptr]
        else:
            kernel.cache = None
            raise RuntimeError(f"could not find the scheduled irx thread {_kernel.ready_q.cache} in AbSS")

        inv_threads_vertex_map = {v: k for k, v in threads_vertex_map.items()}
        InterpreterContext.Zephyr.debug_print_threads(state, inv_threads_vertex_map)

        for t in threads:
            proxy.get(t)
            abSSTState = ThreadStateAdapter.fromZephyr(t.base.thread_state)
            if isinstance(abSSTState, TaskStatus):
                threads_map[t.ptr].status = abSSTState
            else:
                logger.warning(f"Unknown state returned abSSTState: {abSSTState}")
                threads_map[t.ptr].status = TaskStatus.blocked
                #raise RuntimeError("Unknown state returned")

            threads_map[t.ptr].thread_state = int(t.base.thread_state)

            join_queue = threads_map[t.ptr].join_queue
            join_queue.clear()
            for ptr in zi.wait_q_t_itr_ptr(InterpreterContext.config, t, ["join_queue", "waitq"]):
                ptr.cls = zephyr.k_thread # "cast" *dlist to *k_thread" (shortcut)
                v = threads_vertex_map[ptr.ptr]
                join_queue.append(v)


            ptr = t.base.pended_on
            if ptr.ptr != 0:
                # x = zi.irm.get_global_value_at_address(ptr.ptr)
                # print(x)
                waitq = proxy.deref(ptr)
                # thread = proxy.deref(waitq.next)
                # thread_base = proxy.container_of(waitq, zephyr._thread_base, 'pended_on')
                #print(waitq)
                t1 = proxy.container_of_ptr(waitq, zephyr.k_thread, 'join_queue', 'waitq')
                # print(thread_base.ptr)

                v = threads_vertex_map[t1.ptr]
                threads_map[t.ptr].pended_on = v





        # TODO: make a dirty flag to prevent from unnecessarily get
        # proxy.get(zi._kernel)

        # cpu = state.cpus[cpu_id]
        # cpu.analysis_context = ZephyrCPUAnalysisContext()
        # cpu.analysis_context.current = threads_map[zi._kernel.cpus[cpu_id].current.ptr]




    def dot_it(self, postfix="unnamed"):
        str = """digraph Kernel {
            rankdir=TB;
            node [shape=record];
        """
        for t in self.threads:
            self.proxy.get(t)
            ctx = self.threads_map[t.ptr]
            v = self.threads_vertex_map[t.ptr]
            obj = self.state.instances.vp.obj[v]
            index = self.state.instances.vertex_index[v]

            join_queue = self.proxy.get_member(t, ['join_queue', 'waitq'])

            z_status = ThreadStateAdapter(t.base.thread_state).name

            is_current = self.zi._kernel.cpus[self.cpu_id].current.ptr == t.ptr
            is_cache = self.zi._kernel.ready_q.cache.ptr == t.ptr

            texts = []
            texts.append(f"Thread")
            texts.append(f"{hex(t.ptr)}")
            texts.append(f"{t.ptr}")
            texts.append(f"name: {obj.name}")
            texts.append(f"entry_name: {obj.entry_name}")
            texts.append(f"v:{index} current:{is_current} cache:{is_cache}")
            texts.append(f"{bin(t.base.thread_state)}")
            texts.append(f"{z_status}")

            attrs = [] 
            attrs.append("\\n".join(texts))
            attrs.append(f"<qnode_dlist_prev> dlist.prev\\n={t.base.qnode_dlist.head} | <qnode_dlist_next> dlist.next\\n={t.base.qnode_dlist.tail}")
            attrs.append(f"<pended_on> pended_on")
            attrs.append(f"{{ <join_queue> join_queue\\n{join_queue.vvptr} | {{ <join_queue_prev> prev | <join_queue_next> next }} }}")
            label = " | ".join(attrs)
            str += f'{t.ptr} [label="{label}"];\n'

            if t.base.pended_on.ptr != 0:
                pended_on_thread = self.proxy.container_of_ptr(t.base.pended_on, zephyr.k_thread, 'join_queue', 'waitq')
                str += f"{t.ptr}:pended_on -> {pended_on_thread.ptr}:join_queue;\n"
            
            node = self.proxy.get_member(t, ['join_queue', 'waitq'])
            waitq = [x for x in self.zi.wait_q_t_itr_ptr(InterpreterContext.config, t, ["join_queue", "waitq"])]
            self.proxy.get(node)
            if node.ptr == node.tail.ptr:
                # next = self.proxy.container_of_ptr(node.head, zephyr.k_thread, 'join_queue', 'waitq')
                # prev = self.proxy.container_of_ptr(node.tail, zephyr.k_thread, 'join_queue', 'waitq')
                str += f'{t.ptr}:join_queue_next -> {t.ptr}:join_queue_prev;\n'
                str += f'{t.ptr}:join_queue_prev -> {t.ptr}:join_queue_next;\n'
            else:
                #     next = self.proxy.container_of_ptr(node.head, zephyr.k_thread, 'base', 'qnode_dlist')
                #     prev = self.proxy.container_of_ptr(node.tail, zephyr.k_thread, 'base', 'qnode_dlist')
                # curr = self.proxy.container_of_ptr(node.__ptr__, zephyr.k_thread, 'join_queue', 'waitq')
                for n in [node.__ptr__] + waitq:
                    n = PTR(zephyr._dnode, n.ptr)
                    n = self.proxy.deref_no_cache(n)
                    # next = self.proxy.container_of_ptr(n.head, zephyr.k_thread, 'base', 'qnode_dlist')
                    # prev = self.proxy.container_of_ptr(n.tail, zephyr.k_thread, 'base', 'qnode_dlist')
                    # next = self.proxy.container_of_ptr(ptr, zephyr.k_thread, 'base', 'qnode_dlist')
                    str += f'{n.ptr}:join_queue_next -> {n.head.ptr}:qnode_dlist_prev;\n'
                    str += f'{n.ptr}:join_queue_prev -> {n.tail.ptr}:qnode_dlist_next;\n'
                    # curr = n
        
        node = self.proxy.get_member(self.zi._kernel, ['ready_q', 'runq'])
        str += f'{node.ptr} [label="kernel_ready_q\\n{hex(node.ptr)} | <qnode_dlist_prev> dlist.prev | <qnode_dlist_next> dlist.next "];\n'
        ready_q = [x for x in self.zi.dlist_itr_ptr(self.zi._kernel, ["ready_q", "runq"])] # only for CONFIG_SCHED_DUMB]
        for n in [node.__ptr__] + ready_q:
            n = self.proxy.deref_no_cache(n)
            str += f'{n.ptr}:qnode_dlist_next -> {n.head.ptr}:qnode_dlist_prev;\n'
            str += f'{n.ptr}:qnode_dlist_prev -> {n.tail.ptr}:qnode_dlist_next;\n'
            

        str += "}\n"
        with open(f"/tmp/zephyr-kernel-{postfix}.dot", "w", -1, 'utf-8') as f:
            f.write(str)
            f.flush()

        return str