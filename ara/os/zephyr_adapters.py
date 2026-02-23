""" Adapter Layer between AbSS and Interpreter"""
import enum
from dataclasses import dataclass, field
from typing import List, TypedDict, Dict, Generator, Iterable, Tuple
from copy import copy
from graph_tool import Vertex
import zephyr # irx.zephyr (in future: generated)
from diff import diff
from ara.os.zephyr_interpreter import ZephyrInterpreter
from ara.os.os_base import TaskStatus
from ara.util import get_logger
from proxy import PTR
from .os_base import TaskStatus, ControlContext

logger = get_logger("ZephyrAdapters")

def BIT(bit: int) -> int:
    return 1 << bit


@dataclass(frozen=True)
class Timeout:
    v: Vertex # thread vertex
    fn: str
    dticks: int

    def __hash__(self) -> int:
        return hash((__class__.__name__, self.v, self.fn, self.dticks))


@dataclass
class TimerContext:
    expiry_fn: str
    stop_fn: str
    timeout: Timeout = field(default=Timeout(None, 'z_timer_expiration_handler', 0))
    period: int = 0
    status: int = 0

    def __hash__(self) -> int:
        return hash((__class__.__name__, self.expiry_fn, self.stop_fn, self.timeout, self.period, self.status))

@dataclass # (frozen=True)
class ZephyrKernelContext:
    """Kernel Object Representation"""

    # cpus are found in state.cpus[].analysis_context

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
        s += f", cache: {int(self.cache)}]"
        return s

    def __copy__(self):
        return type(self)(
            ready_q=list(self.ready_q),
            cache=self.cache,
            timeout_list=list(self.timeout_list),
        )

    def __hash__(self) -> int:
        return hash((__class__.__name__, tuple(self.timeout_list), self.cache, tuple(self.ready_q)))


@dataclass
class MutexContext:
    wait_q: List[Vertex] = field(default_factory=lambda: [])
    owner: Vertex = None
    lock_count: int = 0
    owner_orig_prio: int = 0

    def __copy__(self):
        return MutexContext(
            wait_q=list(self.wait_q),
            owner=self.owner,
            lock_count=self.lock_count,
            owner_orig_prio=self.owner_orig_prio,
        )

    def __hash__(self) -> int:
        return hash((__class__.__name__, tuple(self.wait_q), self.owner, self.lock_count, self.owner_orig_prio))


@dataclass
class ZephyrCPUAnalysisContext:
    current: object = None
    nested: int = 0 # if ISR in usually non zero
    interrupted_thread: object = None # resume thread after ISR exit, make this an array to support nested interrupts

    def copy(self):
        return ZephyrCPUAnalysisContext(self.current, self.nested, self.interrupted_thread)

    def __hash__(self) -> int:
        return hash((__class__.__name__, self.current, self.nested, self.interrupted_thread))


@dataclass
class ThreadContext(ControlContext):
    pended_on: Vertex = field(default=None) # is pointer to waitq, can be any object with a waitq
    join_queue: List[Vertex] = field(default_factory=lambda: [])
    thread_state: int = 0
    preempt: int = 0
    order_key: int = 0
    sched_locked: int = 0

    def __hash__(self):
        return hash(
            (
                "ThreadContext",
                self.status,
                self.abb,
                self.call_path,
                self.pended_on,
                tuple(self.join_queue),
                self.thread_state,
                self.preempt,
                self.order_key,
                self.sched_locked,
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
            sched_locked=self.sched_locked,
        )

@dataclass
class ISRContext(ControlContext):
    def __hash__(self):
        return hash(
            (
                "ISRContext",
                self.status,
                self.abb,
                self.call_path,
            )
        )

    def __copy__(self):
        return ISRContext(
            status=self.status,
            abb=self.abb,
            call_path=copy(self.call_path),
            dyn_prio=[],
        )


@dataclass #(frozen=True)
class SemaphoreContext:
    # the actually used data structure in the zephyr kernel does not matter,
    # as it is restored using function that will know about what data structure to use
    wait_q: List[Vertex] # list of threads as vertices
    count: int
    limit: int

    def __hash__(self) -> int:
        return hash((__class__.__name__, self.count, self.limit, tuple(self.wait_q)))

    def __copy__(self):
        return SemaphoreContext(list(self.wait_q), self.count, self.limit)


@dataclass
class MSGQContext:
    wait_q: List[Vertex] = field(default_factory=lambda: []) # list of threads as vertices
    lock: int = field(default=0)
    msg_size: int = field(default=0)
    max_msgs: int = field(default=0)
    used_msgs: int = field(default=0)
    flags: int = field(default=0)

    def __hash__(self):
        return hash(("MSGQ",
            tuple(self.wait_q),
            self.lock,
            self.msg_size,
            self.max_msgs,
            self.used_msgs,
            self.flags,
        ))
    
    def __copy__(self):
        return MSGQContext(
            wait_q=list(self.wait_q),
            lock=self.lock,
            msg_size=self.msg_size,
            max_msgs=self.max_msgs,
            used_msgs=self.used_msgs,
            flags=self.flags,
        )

    def __str__(self):
        """Prettyprint selected content."""
        # \33 escape sequenze, 1 for bold, 36 for color, m for end of sequenze
        return f"wait_q={self.wait_q}, lock={self.lock}, used_msgs={self.used_msgs}"

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
            ThreadStateAdapter._THREAD_DEAD : TaskStatus.terminated,
            ThreadStateAdapter._THREAD_DEAD | ThreadStateAdapter._THREAD_QUEUED: TaskStatus.terminated,
            ThreadStateAdapter._THREAD_SUSPENDED: TaskStatus.suspended,
            ThreadStateAdapter._THREAD_SUSPENDED | ThreadStateAdapter._THREAD_PRESTART: TaskStatus.suspended,
            ThreadStateAdapter._THREAD_ABORTING: TaskStatus.terminated,
            ThreadStateAdapter._THREAD_SUSPENDING: TaskStatus.suspended,
            ThreadStateAdapter._THREAD_QUEUED: TaskStatus.ready,
            ThreadStateAdapter._THREAD_QUEUED | ThreadStateAdapter._THREAD_SUSPENDED: TaskStatus.ready,

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
    if not isinstance(timeout, int): # test for unknown value
        raise ValueError("Unknown timeout cannot be SSEd")
    # return MAX-1 aka K_FOREVER
    if timeout == -1:
        if InterpreterContext.Zephyr.config['CONFIG_TIMEOUT_64BIT']:
            timeout = 0xFFFFFFFFFFFFFFFF
        else:
            timeout = 0xFFFFFFFF
    return timeout


@dataclass(frozen=True)
class KObjectMapEntry:
    kobj: object
    context: object
    v: Vertex
    # obj: object


class KObjectMap(Dict[type, Dict[int, KObjectMapEntry]]):

    def v(self) -> Generator[Tuple[int, Vertex], None, None]:
        for k in self:
            yield k, self[k].v

    def kobjs(self) -> Generator[Tuple[int, object], None, None]:
        for k in self:
            yield k, self[k].kobj

    def contexts(self) -> Generator[Tuple[int, object], None, None]:
        for k in self:
            yield k, self[k].context


class InterpreterContext:

    Zephyr = None
    config = None

    def __init__(self, zi: ZephyrInterpreter, state, cpu_id):
        self.zi = zi
        self.zi.reset()
        self.proxy = self.zi.proxy

        self.state = state
        self.cpu_id = cpu_id

        self.threads_ready = []

        # list of kobj
        self.kobjs = {
            object: [],
            zephyr.k_thread: [],
            zephyr.k_sem: [],
            zephyr.k_timer: [],
            zephyr.k_mutex: [],
            zephyr.k_msgq: [],
        }

        # ptr => kobj
        self.kobj_maps = {
            object: KObjectMap(),
            zephyr.k_thread: KObjectMap(),
            zephyr.k_sem: KObjectMap(),
            zephyr.k_timer: KObjectMap(),
            zephyr.k_mutex: KObjectMap(),
            zephyr.k_msgq: KObjectMap(),
        }

        # Vertex => ptr
        self.vertex_maps = {
            object: {},
            zephyr.k_thread: {},
            zephyr.k_sem: {},
            zephyr.k_timer: {},
            zephyr.k_mutex: {},
            zephyr.k_msgq: {},
        }

        self._prepare()

        self.kernel = InterpreterContext.Zephyr.get_kernel_context(state)

        self.dot_it("prepare")


    def thread_sym_2_ptr(self, symbol):
        # obj = state.instances.vp.obj[symbol]
        tctx = self.state.context[symbol]
        inv_threads_map = {v: k for k, v in self.threads_map.items()}
        ptr = inv_threads_map[tctx]
        return self.proxy.deref(PTR(zephyr.k_thread, ptr)) # or search in threads variable

    def run_function_with_arch_swap(self, function_name, args, hints, update=True) -> tuple[int, bool]:
        did_swap = False
        self.zi.irm.stop(["arch_swap"]) # z_swap(inlined) CONF: arch_swap or with SMP: arch_switch
        self.zi.run_function(function_name, args, hints)

        if self.zi.irm.getCurrentCallFunctionName() == "arch_swap":
            did_swap = True
            self.zi.irm.putReturnValue(0, 'APInt32') # emulate that the callee returned 0

        self.zi.finish_function()

        ret = self.zi.irm.getExitValue()

        if update:
            self.update()
        
        if ret['IntVal']['S'] != 0:
            logger.warning(f"warning: {function_name} did not return 0, ret = {ret['IntVal']['S']}")

        return ret, did_swap


    # move to ZephyrInterpreter
    @staticmethod
    def sys_clock_announce(zi: ZephyrInterpreter, state, cpu_id, timeout):
        """ call sys_clock_announce with the ticks value of the next timeout to trigger it"""
        from .zephyr import ISR
        ic = InterpreterContext(zi, state, cpu_id)

        active_isr = []

        for v, isr_obj in state.instances.get(ISR): # maybe filter for Timer Instances rather than for all ISR
            active_isr.append(isr_obj.entry_name)
        ic.zi.irm.stop(active_isr)

        # zi.irm.set_print_llvmir(True)
        ic.zi.run_function("sys_clock_announce", [timeout.dticks], ['APInt64'], False)
        # zi.irm.set_print_llvmir(False)

        isr_function_name = ic.zi.irm.getCurrentCallFunctionName()

        if ic.zi.irm.isRunnable() and isr_function_name in active_isr:
            # triggered a ISR callback

            # probably should let interpreter finish, since z_timer_expiration_handler need to do more work to be correct
            # first thread in the waitq of the timer should become ready

            ic.update() # save ISR lock (cpus[].nested)
            return isr_function_name

        ic.zi.finish_function()
        zi.run_function("update_cache", [0], ['APInt32'], True) # do we need to run this ?
        ic.update()

        return None

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

    def thread_vertex_2_ptr(self, v):
        ptr = self.vertex_maps[zephyr.k_thread][v]
        return self.proxy.deref(PTR(zephyr.k_thread, ptr))

    @staticmethod
    def _create_thread():
        pass

    def _create_semaphore(self, v, obj):
        sem_ctx: SemaphoreContext = self.state.context[obj]
        sem = zephyr.k_sem()
        self.proxy.put(sem)
        self.zi.run_function("z_impl_k_sem_init", [sem.ptr, sem_ctx.count, sem_ctx.limit], ['PTR', 'APInt32', 'APInt32'], True)
        self.proxy.get(sem)

        wait_q = self.proxy.get_member(sem, ['wait_q'])

        for thread_v in sem_ctx.wait_q:
            thread = self.thread_vertex_2_ptr(thread_v)
            self.zi.run_function('add_to_waitq_locked', [thread.ptr, wait_q.ptr], ['PTR', 'PTR'], True)

        return sem
    
    def _create_mutex(self, v, obj):
        mutex_ctx: MutexContext = self.state.context[obj]
        mutex = zephyr.k_mutex()
        self.proxy.put(mutex)
        self.zi.run_function("z_impl_k_mutex_init", [mutex.ptr], ['PTR'], True)

        wait_q = self.proxy.get_member(mutex, ['wait_q'])

        for thread_v in mutex_ctx.wait_q:
            thread = self.thread_vertex_2_ptr(thread_v)
            self.zi.run_function('add_to_waitq_locked', [thread.ptr, wait_q.ptr], ['PTR', 'PTR'], True)
        
        self.proxy.get(mutex)
        if mutex_ctx.owner:
            owner_thread = self.get_kobj_from_vertex(mutex_ctx.owner)
            mutex.owner.ptr = owner_thread.ptr
        mutex.lock_count = mutex_ctx.lock_count
        mutex.owner_orig_prio = mutex_ctx.owner_orig_prio
        self.proxy.put(mutex)

        return mutex
    
    def _create_msgq(self, v, obj):
        msgq_ctx: MSGQContext = self.state.context[obj]
        msgq = zephyr.k_msgq()
        self.proxy.put(msgq)
        self.zi.run_function('k_msgq_init',
                                [msgq.ptr, 0x00, obj.msg_size, obj.max_msgs],
                                ['PTR', 'PTR', 'APInt32', 'APInt32'], True)
        self.proxy.get(msgq)
        msgq.used_msgs = msgq_ctx.used_msgs
        self.proxy.put(msgq)

        wait_q = self.proxy.get_member(msgq, ['wait_q'])

        for thread_v in msgq_ctx.wait_q:
            thread = self.thread_vertex_2_ptr(thread_v)
            self.zi.run_function('add_to_waitq_locked', [thread.ptr, wait_q.ptr], ['PTR', 'PTR'], True)

        return msgq

    def get_semaphore(self, v: Vertex):
        ptr = self.vertex_maps[zephyr.k_sem][v]
        return self.proxy.deref(PTR(zephyr.k_sem, ptr))
    
    def _create_timer(self, v, obj):
        timer_ctx = self.state.context[obj]
        timer = zephyr.k_timer()
        self.proxy.put(timer)
        # timeout_list will handle enqueuing timeout in initialization ... no need to do anything here
        return timer

    def get_kobj_from_vertex(self, v):
        for cls, vertices_map in self.vertex_maps.items():
            if v in vertices_map:
                ptr = vertices_map[v]
                kobj = self.proxy.deref(PTR(cls, ptr))
                self.proxy.get(kobj)
                return kobj

        raise RuntimeError("Can't find kobj from vertex")

    def add_kobj(self, kobj, ctx, v):
        cls = type(kobj)
        if cls not in self.kobjs:
            cls = object
        if kobj.ptr in self.kobjs:
            logger.warning("kobjs already added ... refusing to add")
            return

        self.kobjs[cls].append(kobj)
        self.kobj_maps[cls][kobj.ptr] = KObjectMapEntry(kobj, ctx, v)
        self.vertex_maps[cls][v] = kobj.ptr

    def get_threads(self):
        from .zephyr import Thread
        state = self.state
        for v, obj in state.instances.get(Thread):
            if obj.artificial:
                continue
            # ctx = ThreadContext(TaskStatus.ready, None, None, []) # dummy context
            # if v in state.instances.vp.obj:
            if obj not in state.context:
                continue

            ctx = state.context[obj]

            yield v, obj, ctx

    def _prepare(self):
        from .zephyr import Thread, Semaphore, Zephyr, Timer, Mutex, MSGQ, ISR
        zi = self.zi
        state = self.state
        cpu_id = self.cpu_id

        # FIXME: temporäry HyperSSE fix, warum ist hier ein array wenn es ehe nur 1ne CPU gibt?
        true_cpu_id = cpu_id
        self.true_cpu_id = cpu_id
        self.cpu_id, cpu_id = 0, 0

        kernel = InterpreterContext.Zephyr.get_kernel_context(state)
        # zi.irm.set_print_llvmir(True)
        zi.z_cstart()
        # zi.bg_thread_main()

        proxy = zi.proxy
        _kernel = zi._kernel
        timeout_list = zi.timeout_list

        self.add_kobj(_kernel, _kernel, Zephyr.get_kernel(state))
        self.add_kobj(timeout_list, kernel.timeout_list, None)

        # # remove main thread from ready queue
        # z_main_thread = proxy.Global(zephyr.k_thread, 'z_main_thread')
        # zi.unready_thread(z_main_thread)

        proxy.get(_kernel)
        proxy.get(timeout_list)


        # irm.set_print_llvmir(True)
        # zi.unready_thread(threads[0])

        # print("cache:       ", _kernel.ready_q.cache)
        # print("current:     ", _kernel.cpus[cpu_id].current)
        # print("idle_thread: ", _kernel.cpus[cpu_id].idle_thread)

        timeout_threads_vertices = [t.v for t in kernel.timeout_list]

        # threads = []
        threads_ready = []
        threads_map = {}
        # threads_vertex_map = {}
        threads_kernel_vertex_map = {}

        #zi.helper_get_objs([idle_thread] + threads)
        #idle_thread = zi.helper_create_thread(za.ThreadStateAdapter.fromAbSS(TaskStatus.ready), False)
        # threads_vertex_map[]
        # idle_thread = zi.z_idle_threads[cpu_id]
        # idle_thread_base = proxy.get_member(idle_thread, ['base'])
        # idle_qnode_dlist = proxy.get_member(idle_thread_base, ['qnode_dlist'])
        # proxy.get(idle_thread)
        # proxy.get(idle_thread_base)
        # proxy.get(idle_qnode_dlist)
        
        # true_cpu_id Zephyr assumes to run as cpu_id 0, but with HyperSSE other ids exist
        v = InterpreterContext.Zephyr.get_idleThreadVertex(state.instances, true_cpu_id)
        obj = state.instances.vp.obj[v]
        idle_thread = zi.z_idle_threads[cpu_id]
        # idle_thread = threads_kernel_vertex_map[v]
        # threads_map[vertices_thread_map[v]] = state.context[obj]
        # threads.append(idle_thread)
        threads_map[idle_thread.ptr] = state.context[obj]
        threads_kernel_vertex_map[v] = idle_thread
        # threads_vertex_map[idle_thread.ptr] = InterpreterContext.Zephyr.idle_threads[cpu_id]
        # idle_thread = threads_map[vertices_thread_map[v]]

        self.add_kobj(idle_thread, state.context[obj], v)

        for v, obj in state.instances.get(Thread):
        # for v, obj, ctx in self.get_threads(): # can't do this since k_thread_Create would need to resolve not yet existing threads to pointers
            if obj.artificial:
                continue
            ctx = ThreadContext(TaskStatus.ready, None, None, []) # dummy context
            # if v in state.instances.vp.obj:
            if obj in state.context:
                ctx = state.context[obj]

            # TODO: maybe search for the k_thread global, instead of creation new ones...
            # t = zi.helper_create_thread(ThreadStateAdapter.fromAbSS(ctx.status))
            priority = (ctx.preempt & 0xFF)
            t = zi.helper_create_thread(priority)
            proxy.get(t)

            # threads.append(t)
            threads_map[t.ptr] = ctx
            threads_kernel_vertex_map[v] = t

            self.add_kobj(t, ctx, v)

        # for v, obj in state.instances.get(Thread):
        for v, obj, ctx in self.get_threads():
            t = self.thread_vertex_2_ptr(v)

            wait_q = proxy.get_member(t, ['join_queue', 'waitq'])
            proxy.get(wait_q)

            # restore join_queue
            if obj in state.context:
                ctx = state.context[obj]
                for jv in ctx.join_queue:
                    jt = self.thread_vertex_2_ptr(jv)
                    zi.run_function('add_to_waitq_locked', [jt.ptr, wait_q.ptr], ['PTR', 'PTR'])


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
            t = self.thread_vertex_2_ptr(v)
            threads_ready.append(t)
            # index = state.instances.vertex_index[v]
            # print(f"ready thread: vertex idx: {index}")


        # get current thread
        current_thread = zi.z_idle_threads[cpu_id]
        #current_thread = _kernel.cpus[cpu_id].idle_thread

        # if state.cpus[cpu_id].analysis_context.current:
        #     current_thread = self.get_kobj_from_vertex(state.cpus[cpu_id].analysis_context.current)

        # TODO: confirm that ISR, that have an empty ready queue still work
        cache = kernel.cache
        cache_obj = state.instances.vp.obj[cache]
        if isinstance(cache_obj, ISR): # maybe dont set the cache variable to the ISR vertex
            cache_ctx = state.context[cache_obj]
            if isinstance(cache_ctx, ISRContext):
                # if state.cpus[cpu_id].analysis_context.interrupted_thread:
                cache = state.instances.get_node(state.cpus[cpu_id].analysis_context.interrupted_thread)
            # TODO: else we should fall back to the idle thread

        current_thread = self.get_kobj_from_vertex(cache)

        _kernel.cpus[cpu_id].current.ptr = current_thread.ptr

        #zi.run_function('z_mark_thread_as_started', [current_thread.ptr], ['PTR'])
        #if len(kernel.ready_q) > 0: # if not idle thread  # only if SMP is anabled
        #    zi.ready_thread(current_thread)

        proxy.get(_kernel)

        for ptr in zi.dlist_itr_ptr(_kernel, ["ready_q", "runq"]): # only for CONFIG_SCHED_DUMB
            ptr.cls = zephyr.k_thread # "cast" *dlist to *k_thread" (shortcut)
            #print("dlist_itr ready_q", ptr)

        # irm.set_print_llvmir(True)
        # zi.unready_thread(threads[0])

        # print('_kernel.ready_q.cache', _kernel.ready_q.cache)
        # print('_kernel.cpus[0].current', _kernel.cpus[cpu_id].current)
        # print('_kernel.cpus[0].idle_thread', _kernel.cpus[cpu_id].idle_thread)
        # print('z_main_thread', zi.z_main_thread.__ptr__)
        # print('_thread_dummy', zi._thread_dummy.__ptr__)
        # print('_kernel.ready_q.runq.next', _kernel.ready_q.runq.next)
        # proxy.get_member(_kernel, ['ready_q', 'runq'])
        # print('_kernel.ready_q.runq', _kernel.ready_q.runq)


        # switch_to_main_thread
        _kernel.ready_q.cache.ptr = current_thread.ptr # will be updated from z_ready_thread()
        _kernel.cpus[cpu_id].current.ptr = current_thread.ptr
        #_kernel.cpus[0].idle_thread.ptr = idle_thread.ptr


        # print("current:     ", _kernel.cpus[cpu_id].current)
        # InterpreterContext.Zephyr.debug_print_threads(state, self)

        for v, obj in state.instances.get(Timer):
            timer = self._create_timer(v, obj)
            ctx: TimerContext = self.state.context[obj]
            self.add_kobj(timer, ctx, v)
            self.zi.k_timer_init(timer, ctx.expiry_fn, ctx.stop_fn)
            proxy.get(timer)


        # restore thread timeouts:
        for to in kernel.timeout_list:
            fn = zi.irm.find_function_named(to.fn)
            if fn == 0:
                logger.warning(f"function name {to.fn} could not be found in LLVM module")

            timeout_kobj = self.get_kobj_from_vertex(to.v)
            if isinstance(timeout_kobj, zephyr.k_thread):
                to = proxy.get_member(timeout_kobj, ['base', 'timeout'])
            elif isinstance(timeout_kobj, zephyr.k_timer):
                to = proxy.get_member(timeout_kobj, ['timeout'])
            else:
                raise NotImplementedError
        
            zi.z_add_timeout(
                to,
                fn,
                to.dticks
            )


        self.idle_thread, self.threads_map \
            = idle_thread, threads_map

        for v, obj in state.instances.get(Semaphore):
            sem = self._create_semaphore(v, obj)
            ctx = self.state.context[obj]
            self.add_kobj(sem, ctx, v)
        
        for v, obj in state.instances.get(Mutex):
            mutex = self._create_mutex(v, obj)
            ctx = self.state.context[obj]
            self.add_kobj(mutex, ctx, v)
        
        for v, obj in state.instances.get(MSGQ):
            ctx = self.state.context[obj]
            msgq = self._create_msgq(v, obj)
            self.add_kobj(msgq, ctx, v)

        # self.vertices_semaphore_map = {v: k for k, v in self.semaphores_vertex_map.items()}

        # finalize threads

        for v, obj, ctx in self.get_threads():
            t = self.thread_vertex_2_ptr(v)

            proxy.get(t)
            t.base.thread_state = int(ctx.thread_state & ~ThreadStateAdapter._THREAD_QUEUED)
            t.base.preempt = ctx.preempt
            t.base.order_key = ctx.order_key
            t.base.sched_locked = ctx.sched_locked
            proxy.put(t)
            proxy.get(t)

            if obj in state.context:
                ctx = state.context[obj]

                # restore pended_on
                if ctx.pended_on is not None:
                    obj = state.instances.vp.obj[ctx.pended_on]
                    pended_on_kobj = self.get_kobj_from_vertex(ctx.pended_on)
                    if isinstance(pended_on_kobj, zephyr.k_thread):
                        waitq = proxy.get_member(pended_on_kobj, ['join_queue', 'waitq'])
                        t.pended_on = waitq.ptr
                    elif type(pended_on_kobj) in [zephyr.k_sem, zephyr.k_mutex, zephyr.k_msgq]:
                        waitq = proxy.get_member(pended_on_kobj, ['wait_q', 'waitq'])
                        t.pended_on = waitq.ptr
                    else:
                        raise NotImplementedError("unexpected kernel object type")


        proxy.put(_kernel)

        # zi.helper_threads_enqueue(threads_ready[1:])
        zi.helper_threads_enqueue(threads_ready)
        # zi.helper_threads_ready(threads)

        proxy.get(_kernel)
        # FIXME: temporäry HyperSSE fix
        # cpu = state.cpus[cpu_id]
        cpu = state.cpus[true_cpu_id]
        _kernel.cpus[cpu_id].nested = cpu.analysis_context.nested # restore ISR lock
        proxy.put(_kernel)
        proxy.get(_kernel)


    def update(self):
        """ Pull variables from irx into AbSS state"""
        self._update()

        self.dot_it("postupdate")

    def kernel_object_to_vertex(self, kobj, child = None):
        if isinstance(kobj, zephyr.k_thread):
            # thread = proxy.deref(waitq.next)
            # thread_base = proxy.container_of(waitq, zephyr._thread_base, 'pended_on')
            if isinstance(child, zephyr._wait_q_t):
                t1 = self.proxy.container_of_ptr(child, zephyr.k_thread, 'join_queue', 'waitq')
                return self.kobj_maps[zephyr.k_thread][t1.ptr].v
            return self.kobj_maps[zephyr.k_thread][kobj.ptr].v
        elif type(kobj) in [zephyr.k_sem, zephyr.k_mutex, zephyr.k_timer, zephyr.k_msgq]:
            return self.kobj_maps[type(kobj)][kobj.ptr].v
        else:
            raise RuntimeError(f"No object is associated with PTR {kobj.ptr}")

    def find_container_object(self, ptr: int):
        for cls, kmap in self.kobjs.items():
            for obj in kmap:
                size = self.zi.irm.get_alloc_size("struct." + type(obj).__name__)
                if ptr >= obj.ptr and ptr < (obj.ptr + size):
                    return obj
        return None

    def ptr_to_container_vertex(self, ptr: PTR):
        if ptr.ptr == 0:
            return None
        owner_container = self.find_container_object(ptr.ptr)
        # return self.kernel_object_to_vertex(owner_container, self.proxy.deref(ptr))
        return self.kernel_object_to_vertex(owner_container)
    
    def _update(self):
        zi = self.zi
        state = self.state
        threads = self.kobjs[zephyr.k_thread]
        threads_map = {k: v for k, v in self.kobj_maps[zephyr.k_thread].contexts()}
        idle_thread = self.idle_thread
        kernel: ZephyrKernelContext = InterpreterContext.Zephyr.get_kernel_context(state)

        proxy = zi.proxy
        _kernel = zi._kernel
        timeout_list = zi.timeout_list

        for old in [idle_thread, _kernel, timeout_list] + threads:
            #print(type(old), old.__ptr__)
            new = type(old)()
            new.ptr = old.ptr
            proxy.get(new)
            changes = diff(old, new)
            #for x in changes:
            #    print(f"{x.path_str():30s}: {x.obj1} => {x.obj2}")

        proxy.get(timeout_list)
        proxy.get(_kernel)

        # update timeout_list
        kernel.timeout_list.clear()
        for _timeout in zi.dlist_itr(timeout_list):
            if zi.slice_timeouts and _timeout.ptr == zi.slice_timeouts.ptr:
                continue # ignore the timeout for time slicing, since separate ISR is used
            
            container = self.find_container_object(_timeout.ptr)
            #v = self.kernel_object_to_vertex(container, timeout)
            v = None
            timeout = None

            if isinstance(container, zephyr.k_thread):
                timeout_base_thread = proxy.container_of_ptr(_timeout, zephyr._thread_base, 'timeout')
                timeout_thread = proxy.container_of(timeout_base_thread, zephyr.k_thread, 'base')
                #print("timeout_thread: ", timeout_thread.__ptr__)
                timeout = proxy.get_member(timeout_base_thread, ['timeout'])
                assert _timeout.ptr == timeout.ptr

                v = self.kernel_object_to_vertex(container)
            elif isinstance(container, zephyr.k_timer):
                kobj = proxy.container_of_ptr(_timeout, zephyr.k_timer, 'timeout')
                timeout = proxy.get_member(kobj, ['timeout'])
                assert _timeout.ptr == timeout.ptr
                v = self.kernel_object_to_vertex(container)
            else:
                raise NotImplementedError
            
            # v = self.kobj_maps[zephyr.k_thread][timeout_thread.ptr].v
            to = Timeout(v, zi.irm.find_function_by_vvptr(timeout.fn), timeout.dticks)
            kernel.timeout_list.append(to)

        # TODO: replace with next_up() or runq_best() and runq_remove
        kernel.ready_q.clear()
        for ptr in zi.dlist_itr_ptr(_kernel, ["ready_q", "runq"]): # only for CONFIG_SCHED_DUMB
            ptr.cls = zephyr.k_thread # "cast" *dlist to *k_thread" (shortcut)
            #print("dlist_itr ready_q", ptr)

            v = self.kobj_maps[zephyr.k_thread][ptr.ptr].v
            kernel.ready_q.append(v)

        # update next thread
        cache_obj = state.instances.vp.obj[kernel.cache] # cpus[].control_instance
        # TODO: block rescheduling in ISR unless ISR has higher priority
        from .zephyr import ISR
        if isinstance(cache_obj, ISR): # is the kernel in a ISR? / or check .nested != 0
            logger.info(f"Reschedule in ISR {cache_obj}")
        elif _kernel.ready_q.cache.ptr in self.kobj_maps[zephyr.k_thread]:
            kernel.cache = self.kobj_maps[zephyr.k_thread][_kernel.ready_q.cache.ptr].v
        else:
            kernel.cache = None
            raise RuntimeError(f"could not find the scheduled irx thread {_kernel.ready_q.cache} in AbSS")

        #InterpreterContext.Zephyr.debug_print_threads(state, self)

        for t in threads:
            proxy.get(t)
            abSSTState = ThreadStateAdapter.fromZephyr(t.base.thread_state)
            if isinstance(abSSTState, TaskStatus):
                threads_map[t.ptr].status = abSSTState
            else:
                logger.warning(f"Unknown state returned abSSTState: {abSSTState}")
                threads_map[t.ptr].status = TaskStatus.blocked
                raise RuntimeError("Unknown state returned")

            threads_map[t.ptr].thread_state = ThreadStateAdapter(t.base.thread_state)
            threads_map[t.ptr].preempt = int(t.base.preempt)

            join_queue = threads_map[t.ptr].join_queue
            join_queue.clear()
            for ptr in zi.wait_q_t_itr_ptr(InterpreterContext.config, t, ["join_queue", "waitq"]):
                ptr.cls = zephyr.k_thread # "cast" *dlist to *k_thread" (shortcut)
                v = self.kobj_maps[zephyr.k_thread][ptr.ptr].v
                join_queue.append(v)


            ptr = t.base.pended_on
            if ptr.ptr != 0:
                container = self.find_container_object(ptr.ptr)
                if type(container) in [zephyr.k_thread, zephyr.k_mutex, zephyr.k_sem, zephyr.k_msgq]:
                    # x = zi.irm.get_global_value_at_address(ptr.ptr)
                    waitq = proxy.deref(ptr)
                    container = self.find_container_object(waitq.ptr)
                    v = self.kernel_object_to_vertex(container, waitq)
                    threads_map[t.ptr].pended_on = v
                else:
                    raise NotImplementedError


        for sem in self.kobjs[zephyr.k_sem]:
            proxy.get(sem)
            sem_ctx: SemaphoreContext = self.kobj_maps[zephyr.k_sem][sem.ptr].context
            sem_ctx.limit = sem.limit
            sem_ctx.count = sem.count
            sem_ctx.wait_q.clear()
            wait_q = proxy.get_member(sem, ["wait_q", "waitq"])
            wait_q = proxy.deref_no_cache(wait_q.__ptr__)
            for ptr in zi.wait_q_t_itr(InterpreterContext.config, wait_q):
                ptr.cls = zephyr.k_thread
                thread_v = self.kobj_maps[zephyr.k_thread][ptr.ptr].v
                sem_ctx.wait_q.append(thread_v)
            

        for mutex in self.kobjs[zephyr.k_mutex]:
            proxy.get(mutex)
            mutex_ctx: MutexContext = self.kobj_maps[zephyr.k_mutex][mutex.ptr].context
            mutex_ctx.lock_count = mutex.lock_count
            mutex_ctx.owner_orig_prio = mutex.owner_orig_prio
            mutex_ctx.owner = self.ptr_to_container_vertex(mutex.owner)
            mutex_ctx.wait_q.clear()
            wait_q = proxy.get_member(mutex, ["wait_q", "waitq"])
            wait_q = proxy.deref_no_cache(wait_q.__ptr__)
            for ptr in zi.wait_q_t_itr(InterpreterContext.config, wait_q):
                ptr.cls = zephyr.k_thread
                thread_v = self.kobj_maps[zephyr.k_thread][ptr.ptr].v
                mutex_ctx.wait_q.append(thread_v)
        

        for msgq in self.kobjs[zephyr.k_msgq]:
            proxy.get(msgq)
            msgq_ctx: MSGQContext = self.kobj_maps[zephyr.k_msgq][msgq.ptr].context
            # msgq_ctx.lock = zephr.k_spinlock(msgq.lock)
            msgq_ctx.msg_size = msgq.msg_size
            msgq_ctx.max_msgs = msgq.max_msgs
            msgq_ctx.flags = msgq.flags
            msgq_ctx.used_msgs = msgq.used_msgs
            msgq_ctx.wait_q.clear()
            wait_q = proxy.get_member(msgq, ["wait_q", "waitq"])
            wait_q = proxy.deref_no_cache(wait_q.__ptr__)
            for ptr in zi.wait_q_t_itr(InterpreterContext.config, wait_q):
                ptr.cls = zephyr.k_thread
                thread_v = self.kobj_maps[zephyr.k_thread][ptr.ptr].v
                msgq_ctx.wait_q.append(thread_v)
        
        # FIXME: temporäry HyperSSE fix
        # cpu = state.cpus[self.cpu_id]
        cpu = state.cpus[self.true_cpu_id]
        # restore irq lock (nested)
        # cpu.analysis_context.current = threads_map[zi._kernel.cpus[cpu_id].current.ptr]
        
        proxy.get(_kernel)
        cpu.analysis_context.nested = _kernel.cpus[self.cpu_id].nested # save ISR lock
        cpu.irq_on = cpu.analysis_context.nested == 0


    def update_wait_q(self, wait_q: zephyr._wait_q_t):
        pass
    
    
    @dataclass
    class DotObject:
        kobj: any

        extras: List[str] = field(default_factory=lambda: [])

        def attr(self):
            texts = [str(type(self.kobj).__name__)]
            texts.append(str(self.kobj.__ptr__))
            texts.append(str(self.kobj.ptr))
            for attr, value in self.kobj.__dict__.items():
                v = str(value).replace(",", ",\\n")
                texts.append(f"{attr}={v}")
            
            attrs = []
            attrs.append("\\n".join(texts + self.extras))
            return attrs
    
        def dot(self):
            attrs = self.attr()
            label = " | ".join(attrs)

            return f'{self.kobj.ptr} [label="{label}"];\n'
        
        def __repr__(self):
            return self.dot()

    def dot_it(self, postfix="unnamed"):
        dotstr = """digraph Kernel {
            rankdir=TB;
            node [shape=record];
        """
        disabled = False
        fn = ''
        if self.state.cpus.one().abb:
            fn = self.state.cfg.get_syscall_name(self.state.cpus.one().abb)
        if fn == '':
            disabled = True
        if disabled:
            return
        
        proxy = self.proxy

        for t in self.kobjs[zephyr.k_thread]:
            self.proxy.get(t)
            ctx = self.kobj_maps[zephyr.k_thread][t.ptr]
            v = self.kobj_maps[zephyr.k_thread][t.ptr].v
            obj = self.state.instances.vp.obj[v]
            index = self.state.instances.vertex_index[v]
            color = f'color="{InterpreterContext.remap(index, 0, len(self.state.instances))} 0.800 0.900"'

            join_queue = self.proxy.get_member(t, ['join_queue', 'waitq'])

            z_status = ThreadStateAdapter(t.base.thread_state).name
            if z_status:
                z_status = z_status.replace("|", "\\|")

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
            texts.append(f"preempt: {t.base.preempt}")

            node = self.proxy.get_member(t, ['join_queue', 'waitq'])
            self.proxy.get(node)

            attrs = []
            attrs.append("\\n".join(texts))
            attrs.append(f"<qnode_dlist_prev> dlist.prev\\n={t.base.qnode_dlist.head} | <qnode_dlist_next> dlist.next\\n={t.base.qnode_dlist.tail}")
            attrs.append(f"<pended_on> pended_on")
            attrs.append(f"{{ <join_queue> join_queue\\n{join_queue.vvptr} | {{ <join_queue_prev> prev\\n={node.prev} | <join_queue_next> next\\n={node.next} }} }}")
            label = " | ".join(attrs)

            thread_color = "black"
            if is_current:
                thread_color = "red"
            elif is_cache:
                thread_color = "blue"

            dotstr += f'{t.ptr} [label="{label}" color="{thread_color}"];\n'

            dest_next = self.find_container_object(t.base.qnode_dlist.head.ptr)
            dest_prev = self.find_container_object(t.base.qnode_dlist.tail.ptr)
            if(dest_next):
                dotstr += f'{t.ptr}:qnode_dlist_next -> {dest_next.ptr}:qnode_dlist_prev [{color}];\n'
            if(dest_prev):
                dotstr += f'{t.ptr}:qnode_dlist_prev -> {dest_prev.ptr}:qnode_dlist_next [{color}];\n'

            if t.base.pended_on.ptr != 0:
                waitq = self.proxy.deref(t.base.pended_on)
                pended_on_thread = self.find_container_object(waitq.ptr)
                # v = self.kernel_object_to_vertex(container, waitq)
                # pended_on_thread = self.proxy.container_of_ptr(t.base.pended_on, zephyr.k_thread, 'join_queue', 'waitq')
                dotstr += f"{t.ptr}:pended_on -> {pended_on_thread.ptr}:pended_on [{color}];\n"

            if node.ptr == node.tail.ptr:
                dotstr += f'{t.ptr}:join_queue_next -> {t.ptr}:join_queue_prev [{color}];\n'
                dotstr += f'{t.ptr}:join_queue_prev -> {t.ptr}:join_queue_next [{color}];\n'
            else:
                dest_next = self.find_container_object(node.head.ptr)
                dest_prev = self.find_container_object(node.tail.ptr)
                if dest_next:
                    dotstr += f'{t.ptr}:join_queue_next -> {dest_next.ptr}:qnode_dlist_prev [{color}];\n'
                if dest_prev:
                    dotstr += f'{t.ptr}:join_queue_prev -> {dest_prev.ptr}:qnode_dlist_next [{color}];\n'

        node = self.proxy.get_member(self.zi._kernel, ['ready_q', 'runq'])
        self.proxy.get(node)
        dotstr += f'{self.zi._kernel.ptr} [label="Kernel\\n{hex(self.zi._kernel.ptr)} | <ready_q> ready_q\\n{hex(node.ptr)}\\n{(node.ptr)} | <qnode_dlist_prev> dlist.prev |'
        dotstr += f' <qnode_dlist_next> dlist.next"];\n'
        # str += f'{node.ptr} [label="kernel_ready_q\\n{hex(node.ptr)} | <qnode_dlist_prev> dlist.prev | <qnode_dlist_next> dlist.next "];\n'

        dest_next = self.find_container_object(node.head.ptr)
        dest_prev = self.find_container_object(node.tail.ptr)

        dotstr += f'{self.zi._kernel.ptr}:qnode_dlist_next -> {dest_next.ptr}:qnode_dlist_prev [color=black];\n'
        dotstr += f'{self.zi._kernel.ptr}:qnode_dlist_prev -> {dest_prev.ptr}:qnode_dlist_next [color=black];\n'

        for sem in self.kobjs[zephyr.k_sem]:
           dotstr += self.sem_dot(sem)


        # for t in self.zi.timeout_list]:
        # TODO make _dnode iteratable
        timeout_list = self.zi.timeout_list
        proxy.get(timeout_list)
        dotstr += f'{timeout_list.ptr} [label="timeout_list\\n{timeout_list.__ptr__} | {{ <waitq> dnode | {{ <prev> prev\\n={timeout_list.prev} | <next> next\\n={timeout_list.next} }} }}"];\n'
        dest_next = self.find_container_object(timeout_list.head.ptr)
        if dest_next:
            dotstr += f"{timeout_list.ptr}:next -> {dest_next.ptr}:waitq;\n"
        dest_prev = self.find_container_object(timeout_list.tail.ptr)
        if dest_prev:
            dotstr += f"{timeout_list.ptr}:prev -> {dest_prev.ptr}:waitq;\n"

        for t in self.kobjs[zephyr.k_timer]:
            proxy.get(t)
            dotstr += f'{t.ptr} [label="k_timer\\n{t.__ptr__} | ' + \
                f'{{ <waitq> waitq | {{ <waitq_prev> prev\\n= {t.wait_q.waitq.head} | <waitq_next> next\\n= {t.timeout.node.head} }} }} | ' + \
                f'{{ <dnode> dnode | {{ <dnode_prev> prev\\n= {t.wait_q.waitq.tail} | <dnode_next> next\\n= {t.timeout.node.tail} }} }} "];\n'
            dest_next = self.find_container_object(t.timeout.node.head.ptr)
            dest_prev = self.find_container_object(t.timeout.node.tail.ptr)
            if dest_next:
                dotstr += f"{t.ptr}:dnode_next -> {dest_next.ptr}:dnode_prev;\n"
            if dest_prev:
                dotstr += f"{t.ptr}:prev -> {dest_prev.ptr}:dnode_next;\n"
            dest_next = self.find_container_object(t.wait_q.waitq.head.ptr)
            dest_prev = self.find_container_object(t.wait_q.waitq.tail.ptr)
            if dest_next:
                dotstr += f"{t.ptr}:waitq_next -> {dest_next.ptr}:waitq_prev;\n"
            if dest_prev:
                dotstr += f"{t.ptr}:prev -> {dest_prev.ptr}:waitq_next;\n"


        for cls in [zephyr.k_mutex, zephyr.k_msgq]:
            for t in self.kobjs[cls]:
                dot = InterpreterContext.DotObject(t)
                v = self.kobj_maps[cls][t.ptr].v
                index = self.state.instances.vertex_index[v]
                dot.extras.append(f"v: {index}")
                dotstr += str(dot)
        
        dotstr += f'{self.state.id} [label="self.state.id\\nid: {InterpreterContext.last_state_id:05d} to {self.state.id:05d}"];\n'

        dotstr += "}\n"
        with open(f"/tmp/zephyr-kernel-{postfix}.dot", "w", -1, 'utf-8') as f:
            f.write(dotstr)
            f.flush()
        
        create_dir("/tmp/kernel_states")

        with open(f"/tmp/kernel_states/{InterpreterContext.last_state_id:05d}-{postfix}.dot", "w", -1, 'utf-8') as f:
            f.write(dotstr)

        return dotstr

    @staticmethod
    def remap(x, in_min=0.0, in_max=1.0, out_min=0.0, out_max=1.0):
        '''remap taken from https://stackoverflow.com/a/43567380'''
        return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min

    last_state_id = 0

    @staticmethod
    def set_last_state_id(state_id):
        InterpreterContext.last_state_id = state_id

    def sem_dot(self, sem):
        from .zephyr import Semaphore
        self.proxy.get(sem)
        v = self.kobj_maps[zephyr.k_sem][sem.ptr].v
        obj: Semaphore = self.state.instances.vp.obj[v]
        label: Semaphore = self.state.instances.vp.label[v]
        sem_ctx: SemaphoreContext = self.state.context[obj]

        texts = []
        texts.append(label)
        texts.append(f"{hex(sem.ptr)}")
        texts.append(f"{sem.ptr}")
        texts.append(f"limit: {sem.limit}")
        texts.append(f"count: {sem.count}")
        texts.append(f"name: {obj.symbol.get_name()}")

        attrs = []
        attrs.append("\\n".join(texts))
        attrs.append(f"<qnode_dlist_prev> dlist.prev\\n={sem.wait_q.waitq.tail} | <qnode_dlist_next> dlist.next\\n={sem.wait_q.waitq.head}")

        label = " | ".join(attrs)

        con = ""
        con = f"{sem.ptr}:qnode_dlist_prev -> {sem.wait_q.waitq.head.ptr}:qnode_dlist_next [color=\"0.7 1 1\"];\n"
        con = f"{sem.ptr}:qnode_dlist_next -> {sem.wait_q.waitq.tail.ptr}:qnode_dlist_prev [color=\"0.5 1 1\"];\n"

        return f'{sem.ptr} [label="{label}"];\n{con}\n'


def create_dir(dir):
    import os
    if not os.path.exists(dir):
        os.makedirs(dir)
