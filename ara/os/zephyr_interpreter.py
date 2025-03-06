import os
import copy
from typing import Annotated
import ara.os.zephyr_adapters as za
from pyirinterpreter import PyIRModuleInterpreter
import struct


#sys.path.append("../subprojects/ara/subprojects/irx/")
#sys.path.append("../subprojects/irx")

import zephyr
from proxy import StructProxy, ArraySize



def try_find_file(paths):
    for p in paths:
        if os.path.isfile(p):
            return p
    raise RuntimeError(f"File not found: {paths}")
        

class ZephyrInterpreter:

    ALIASES_DISABLE=False


    def __init__(self, config):
        self.irm = None
        self.config = config
        self.proxy = None

        self._thread_dummy = None
        self._kernel: zephyr.z_kernel = None
        self.z_main_thread = None
        self.z_idle_threads = None
        self.timeout_list = []
        self.slice_timeouts = None

        self.curr_tick = None

        self.force_native_sim = False
    
    def init(self, llvmirfile, kernel_ll):
        self.irm = PyIRModuleInterpreter()

        llvmir_dirpath = os.path.dirname(llvmirfile)
        basename = os.path.basename(llvmirfile)
        name = os.path.splitext(basename)[0]

        if not kernel_ll:
            kernel_ll = os.path.join(llvmir_dirpath, f"{name}-kernel.ll")

        paths = [
             os.path.join(llvmir_dirpath, f"{name}.ll"), # application + thread definitions
             kernel_ll, # load the full kernel code
        ]
        build_native_sym = 'CONFIG_BOARD' in self.config and self.config['CONFIG_BOARD'] == 'native_sim' or self.force_native_sim
        if build_native_sym:
            paths += [try_find_file([
                'subprojects/ara/subprojects/irx/native_runner/runner.ll',
                'subprojects/irx/native_runner/runner.ll'
            ])]

        if not self.irm.parseIRFiles(paths):
            raise FileNotFoundError(f"Failed to parse LLVM-IR file {str(paths)}")
        
        # if irm.hasExternal("nsi_simu_time"):
            # irm.setInitializer("nsi_simu_time", "i64 0")
        
        if not self.irm.createInterpreter():
            raise RuntimeError("Failed to create interpreter")
        
        
        self.reset()

    def reset(self):
        self.irm.reset()
        self.proxy = StructProxy(self.irm)

        self._thread_dummy = self.proxy.Global(zephyr.k_thread, '_thread_dummy')
        self._kernel = self.proxy.Global(zephyr.z_kernel, '_kernel')
        self.z_main_thread = self.proxy.Global(zephyr.k_thread, 'z_main_thread')
        self.z_idle_threads = self.proxy.Global(Annotated[list[zephyr.k_thread], ArraySize(1)], 'z_idle_threads')
        self.timeout_list = self.proxy.Global(zephyr._dnode, 'timeout_list')
        self.slice_timeouts = self.proxy.Global(zephyr._timeout, 'slice_timeouts')

        # self.curr_tick = proxy.Global(zephyr.UInt64, 'curr_tick')
        self.curr_tick = self.irm.irx_get_global_var('curr_tick')

    def run_function(self, function_name, args, arg_type_hints, finish=False):
        print(f"run_function {function_name}")
        if not self.irm.runFunction(function_name.encode("ascii"), args, arg_type_hints):
            raise RuntimeError(f"Failed to run LLVM Interpreter for function {function_name}")
        if finish:
            self.finish_function()
        
        ret = self.irm.getExitValue()

        return ret
    
    def resume(self):
        if not self.irm.resume():
            raise RuntimeError("Failed to run LLVM Interpreter for function")
    
    def finish_function(self):
        while self.irm.isRunnable():
            self.resume()
    
    def z_sys_init_run_level(self, level):
            # does not work if ALIASES_DISABLE is set and sections are not created with data.
        if ZephyrInterpreter.ALIASES_DISABLE:
            if level == 0:
                # emulate it
                if self.config['CONFIG_BOARD'] == 'native_sim' or self.force_native_sim:
                    self.run_function("set_realtime_default", [], [])
        else:
            self.run_function("z_sys_init_run_level", [level], ['APInt32'])

    def sys_clock_driver_init(self):
        if ZephyrInterpreter.ALIASES_DISABLE:
            if self.config['CONFIG_BOARD'] == 'native_sim' or self.force_native_sim:
                self.irm.irx_global_set('hw_counter_timer', struct.pack('Q', 1000))
                self.irm.irx_global_set('nsi_simu_time', struct.pack('Q', 1000))
                self.irm.irx_global_set('tick_period', struct.pack('Q', 1000))
                self.irm.irx_global_set('last_tick_time', struct.pack('Q', 1000))
        else:
            self.run_function("sys_clock_driver_init", [], []) # require ALIASES_DISABLE unset

    def z_cstart(self):
        irm = self.irm
        proxy = self.proxy

        self.z_sys_init_run_level(0)
        if self.config['CONFIG_BOARD'] == 'native_sim' or self.force_native_sim:
            self.run_function("arch_kernel_init", [], [])
        self.run_function("z_dummy_thread_init", [self._thread_dummy.ptr], ['PTR'])
        self.run_function("z_device_state_init", [], [])
        # self.z_sys_init_run_level(1)
        if self.config['CONFIG_BOARD'] == 'native_sim' or self.force_native_sim:
            self.run_function("posix_arch_console_init", [], [])
            self.sys_clock_driver_init()
        # self.z_sys_init_run_level(2)
        irm.skip(['arch_new_thread', 'memset'])

        #self.run_function("prepare_multithreading", [], [])
        # stack_ptr = irm.getExitValue()['PointerVal']
        # do prepare_multithreading "manually" to prevent to queue z_main_thread
        self.run_function("z_sched_init", [], [])

        # to simplify:
        # we will not treat the main thread special and initialize it with all other threads
        #self.run_function('z_mark_thread_as_started', [self.z_main_thread.ptr], ['PTR'])
        #self.run_function('z_ready_thread', [self.z_main_thread.ptr], ['PTR'])

        # self.irm.set_print_llvmir(True)

        self.irm.stop(["setup_thread_stack", "strncpy"])
        self.run_function("z_init_cpu", [0], ['APInt32'])

        if self.irm.getCurrentCallFunctionName() == "strncpy":
            self.irm.putReturnValue(0, 'PTR')

        if self.irm.getCurrentCallFunctionName() == "setup_thread_stack":
            self.irm.putReturnValue(0, 'APInt32')
        
        while self.irm.isRunnable():
            self.resume()

        # self.irm.set_print_llvmir(False)


        #proxy.get(self._kernel)
        #self._kernel.ready_q.cache.ptr = self.z_main_thread.ptr
        #self._kernel.ready_q.cache.ptr = self._thread_dummy.ptr
        #self._kernel.cpus[0].current.ptr = self._kernel.ready_q.cache.ptr
        #proxy.put(self._kernel)

        # self.irm.irx_global_set('slice_ticks', struct.pack('i', 1000)) # enable time slicing for debugging 

    def bg_thread_main(self):
        self.run_function("z_init_static_threads", [], []) # currently does not work
        # if this is fixed. it would be possible to run schedulers with z_main_thread

    def z_init_static_threads(self):
        # TODO emulate it or fix interpreter
        pass

    def z_setup_new_thread(self, t: zephyr.k_thread, prio: int):
        self.irm.stop(["setup_thread_stack"])

        self.run_function("z_setup_new_thread", [
              t.ptr,
              0x50000000, # stack (nonzero)
              4096,
              0x50000000, # entry (nonzero)
              0,
              0,
              0,
              prio,
              0,
              0, # name
        ], [
              'PTR',
              'PTR',
              'APInt32',
              'PTR',
              'PTR',
              'PTR',
              'PTR',
              'APInt32',
              'APInt32',
              'PTR',
        ])

        if self.irm.getCurrentCallFunctionName() == "setup_thread_stack":
            self.irm.putReturnValue(0, 'APInt32')
        
        while self.irm.isRunnable():
            self.resume()
        
        self.proxy.get(t)
        self.proxy.get_member(t, ['join_queue'])
        self.proxy.get_member(t, ['join_queue', 'waitq'])
        self.proxy.get_member(t, ['base', 'qnode_dlist'])
        self.run_function('z_waitq_init', [t.join_queue.ptr], ['PTR'], True)
        # self.run_function('z_waitq_init', [t.base.qnode_dlist.ptr], ['PTR'], True)
        self.proxy.get(t)

    def thread_schedule_new(self, t: zephyr.k_thread, delay: int):
        """ static inline void thread_schedule_new(struct k_thread *thread, k_timeout_t delay) """
        # k_timeout_t is optimized to a single i64 so we can just use it like that
        #self.irm.set_print_llvmir(True)
        self.run_function("thread_schedule_new", [t.ptr, delay], ['PTR', 'APInt64'])
        #self.irm.set_print_llvmir(False)

    def helper_manual_create_thread(self, status):
        t = zephyr.k_thread()

        #t.status = status
        t.base.thread_state = status

        t.join_queue.waitq.head.cache = self.proxy.cache_offset(t, ['join_queue', 'waitq'])
        t.join_queue.waitq.tail.cache = self.proxy.cache_offset(t, ['join_queue', 'waitq'])
        t.base.qnode_dlist.head.cache = self.proxy.cache_offset(t, ['base', 'qnode_dlist'])
        t.base.qnode_dlist.tail.cache = self.proxy.cache_offset(t, ['base', 'qnode_dlist'])

        self.proxy.put(t)
        
        return t

    def helper_create_thread(self, prio: int = 10):
        t = zephyr.k_thread()
        self.proxy.put(t)
        self.z_setup_new_thread(t, prio)
        # self.proxy.get(t)
        # ##print("Thread status after enqueue", za.ThreadStateAdapter(t.base.thread_state))
        # t.base.thread_state = int(status)

        # # usually not needed, but since thread may be "started" make sure to init the dlist
        # # z_setup_new_thread won't do it for us
        # t.base.qnode_dlist.head.ptr = t.ptr
        # t.base.qnode_dlist.next.ptr = t.ptr
        # t.base.qnode_dlist.tail.ptr = t.ptr
        # t.base.qnode_dlist.prev.ptr = t.ptr

        # self.proxy.put(t)

        self.z_mark_thread_as_started(t)
        return t
    
    def helper_threads_enqueue(self, threads, delay: int = 0):
        # self.k_sched_lock()
        # self.irm.skip(["z_reschedule"])
        for t in threads:
            # if t.base.thread_state & za.ThreadStateAdapter._THREAD_PRESTART:
            #     continue

            if self.z_idle_threads[0].ptr == t.ptr:
                continue

            # self.queue_thread(t) # is inlined
            # self.thread_schedule_new(t, delay) # does not add thread if queued bit is set
            #if t.base.thread_state & za.ThreadStateAdapter._THREAD_QUEUED:
            #    print("trying to add a thread that has the queued bit set. this will not work!")
            self.z_mark_thread_as_started(t)
            self.ready_thread(t)
    
    def helper_threads_ready(self, threads):
        for t in threads:
            self.ready_thread(t)

    def helper_get_objs(self, objs):
        for o in objs:
            self.proxy.get(o)

    def unready_thread(self, t: zephyr.k_thread):
        self.run_function("unready_thread", [t.ptr], ['PTR'])

    def ready_thread(self, t: zephyr.k_thread):
        # self.run_function("ready_thread", [t.ptr], ['PTR'])
        # ready_thread will resort the ready_q
        # therefore force for the sorting as is
        self.run_function("move_thread_to_end_of_prio_q", [t.ptr], ['PTR']) # work around

    def z_mark_thread_as_started(self, t: zephyr.k_thread):
        self.run_function("z_mark_thread_as_started", [t.ptr], ['PTR'])
    
    # def queue_thread(self, t: zephyr.k_thread):
    #     # does not check if already has the state queued
    #     self.run_function("queue_thread", [t.ptr], ['PTR'])
    
    # def k_sched_lock(self):
    #     self.run_function("k_sched_lock", [], [])

    def z_add_thread_timeout(self, t: zephyr.k_thread, ticks: int):
        """ add thread timeout """
        self.run_function("z_add_thread_timeout", [t.ptr, ticks], ['PTR', 'APInt64'])

    def z_add_timeout(self, t: zephyr.k_thread, fn: int, ticks: int):
        """ add thread timeout """
        self.run_function("z_add_timeout", [t.ptr, fn, ticks], ['PTR', 'PTR', 'APInt64'])

    def update_ptr(self, obj, attrs):
        target = obj
        for attr2 in attrs:
            target = getattr(target, attr2)
        if target.ptr is None:
            self.proxy.update_ptr(obj, attrs)
        return target
    
    def dlist_itr_ptr(self, obj, attrs):
        target = self.update_ptr(obj, attrs)
        return self.dlist_itr(target)

    def dlist_itr_2_ptr(self, obj, attrs):
        target = self.update_ptr(obj, attrs)
        return self.dlist_2_itr(target)

    def dlist_itr(self, node: zephyr._dnode):
        for _, _next in self.dlist_2_itr(node):
            yield _next
        
    def dlist_2_itr(self, node: zephyr._dnode):
        current = node

        assert node.ptr != 0
        
        for _ in range(0, 10000): # upper limit
            if current.head.ptr == node.ptr: # same as current.next
                break
            if current.head.ptr == 0 or node.tail.ptr == 0: # uninitialized?
                break
            yield copy.copy(current.prev), copy.copy(current.head) # same as current.next
            current = self.proxy.deref_no_cache(current.head) # same as current.next
        else:
            raise RuntimeError("dlist corrupted or max depth exceeded")


    def wait_q_t_itr_ptr(self, config, obj, attrs):
        if 'CONFIG_WAITQ_SCALABLE' in config:
            raise NotImplementedError
        else:
            return self.dlist_itr_ptr(obj, attrs)

    def wait_q_t_itr(self, config, wait_q: zephyr._wait_q_t):
        if 'CONFIG_WAITQ_SCALABLE' in config:
            raise NotImplementedError
        else:
            # dnode = self.proxy.get_member(wait_q, ['waitq']) # _wait_q_t is not emitted to LLVM-IR
            dnode = self.proxy.deref_no_cache(wait_q.__ptr__)
            return self.dlist_itr(dnode)

    def z_unpend1_no_timeout(self, wait_q: zephyr._wait_q_t) -> zephyr.k_thread:
        """ get the next thread in queue.
        warning: this operation is destructive, the thread will be removed from the queue """
        
        self.run_function("z_unpend1_no_timeout", [wait_q.ptr], ['PTR', True])

    def k_timer_init(self, timer: zephyr.k_timer, expiry_fn, stop_fn):
        expiry_addr = 0
        stop_addr = 0
        if expiry_fn:
            expiry_addr = self.irm.find_function_named(expiry_fn)
        if stop_fn:
            stop_addr = self.irm.find_function_named(stop_fn)
        self.run_function("k_timer_init", [timer.ptr, expiry_addr, stop_addr], ['PTR', 'PTR', 'PTR'], True)
