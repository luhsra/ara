import os
import sys
import copy
from typing import Annotated
import ara.os.zephyr_adapters as za
from pyirinterpreter import PyIRModuleInterpreter

sys.path.append("../subprojects/ara/subprojects/irx/")
sys.path.append("../subprojects/irx")

import zephyr
from diff import diff
from proxy import StructProxy, ArraySize
import ara.os.zephyr_adapters as za

import os.path


def try_find_file(paths):
    for p in paths:
        if os.path.isfile(p):
            return p
    raise RuntimeError(f"File not found: {paths}")
        

class ZephyrInterpreter:

    def __init__(self, config):
        self.irm = PyIRModuleInterpreter()
        self.proxy = StructProxy(self.irm)
        self.config = config

        self._thread_dummy = None
        self._kernel = None
        self.z_main_thread = None
        self.z_idle_threads = None
    
    def init(self, llvmirfile):
        irm = self.irm
        proxy = self.proxy

        llvmir_dirpath = os.path.dirname(llvmirfile)
        basename = os.path.basename(llvmirfile)
        name = os.path.splitext(basename)[0]
        paths = [
             os.path.join(llvmir_dirpath, f"{name}.ll"), # application + thread definitions
             os.path.join(llvmir_dirpath, f"{name}-kernel.ll"), # load the full kernel code
        ]
        build_native_sym = 'CONFIG_BOARD' in self.config and self.config['CONFIG_BOARD'] == 'native_sim'
        if build_native_sym:
            paths += [try_find_file([
                'subprojects/ara/subprojects/irx/native_runner/runner.ll',
                'subprojects/irx/native_runner/runner.ll'
            ])]

        if not irm.parseIRFiles(paths):
            raise FileNotFoundError(f"Failed to parse LLVM-IR file {str(paths)}")
        
        # if irm.hasExternal("nsi_simu_time"):
            # irm.setInitializer("nsi_simu_time", "i64 0")

        if not irm.createInterpreter():
            raise RuntimeError("Failed to create interpreter")
        
        self._thread_dummy = proxy.Global(zephyr.k_thread, '_thread_dummy')
        self._kernel = proxy.Global(zephyr.z_kernel, '_kernel')
        self.z_main_thread = proxy.Global(zephyr.k_thread, 'z_main_thread')
        self.z_idle_threads = proxy.Global(Annotated[list[zephyr.k_thread], ArraySize(1)], 'z_idle_threads')
        self.timeout_list = proxy.Global(zephyr._dnode, 'timeout_list')


    def run_function(self, function_name, args, arg_type_hints):
        if not self.irm.runFunction(function_name.encode("ascii"), args, arg_type_hints):
            raise RuntimeError(f"Failed to run LLVM Interpreter for function {function_name}")
    
    def resume(self):
        if not self.irm.resume():
            raise RuntimeError("Failed to run LLVM Interpreter for function")
        
    def z_cstart(self):
        irm = self.irm
        proxy = self.proxy

        self.run_function("z_sys_init_run_level", [0], ['APInt32'])
        self.run_function("arch_kernel_init", [], [])
        self.run_function("z_dummy_thread_init", [self._thread_dummy.ptr], ['PTR'])
        self.run_function("z_device_state_init", [], [])
        
        print('initlevel: PTR: ', hex(irm.irx_get_global_addr('initlevel')))

        # if not irm.runFunction(b"z_sys_init_run_level", [1], ['APInt32']):
        #     raise RuntimeError("Failed to run LLVM Interpreter for function z_sys_init_run_level")
        
        self.run_function("posix_arch_console_init", [], [])
        self.run_function("sys_clock_driver_init", [], [])
        
        #if not irm.runFunction(b"z_sys_init_run_level", [2], ['APInt32']):
        #    raise RuntimeError("Failed to run LLVM Interpreter for function z_sys_init_run_level")
        
        irm.skip(['arch_new_thread'])


        #self.run_function("prepare_multithreading", [], [])
        # stack_ptr = irm.getExitValue()['PointerVal']
        # do prepare_multithreading "manually" to prevent to queue z_main_thread
        self.run_function("z_sched_init", [], [])

        # to simplify:
        # we will not thread the main thread special and initialize it with all other threads
        #self.run_function('z_mark_thread_as_started', [self.z_main_thread.ptr], ['PTR'])
        #self.run_function('z_ready_thread', [self.z_main_thread.ptr], ['PTR'])

        self.run_function("z_init_cpu", [0], ['APInt32'])


        #proxy.get(self._kernel)
        #self._kernel.ready_q.cache.ptr = self.z_main_thread.ptr
        #self._kernel.ready_q.cache.ptr = self._thread_dummy.ptr
        #self._kernel.cpus[0].current.ptr = self._kernel.ready_q.cache.ptr
        #proxy.put(self._kernel)

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
              0,
              4096,
              0, # entry
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

    def helper_create_thread(self, status, prio: int = 10):
        t = zephyr.k_thread()
        self.proxy.put(t)
        self.z_setup_new_thread(t, prio)
        #self.proxy.get(t)
        ##print("Thread status after enqueue", za.ThreadStateAdapter(t.base.thread_state))
        #t.base.thread_state = int(status)
        #self.proxy.put(t)
        return t
    
    def helper_threads_enqueue(self, threads, delay: int = 0):
        # self.k_sched_lock()
        for t in threads:
            #self.z_mark_thread_as_started(t)
            self.thread_schedule_new(t, delay) # todo replace with z_mark_thread_as_started
    
    def helper_threads_ready(self, threads):
        for t in threads:
            self.z_ready_thread(t)

    def helper_get_objs(self, objs):
        for o in objs:
            self.proxy.get(o)

    def unready_thread(self, t: zephyr.k_thread):
        self.run_function("unready_thread", [t.ptr], ['PTR'])

    def z_ready_thread(self, t: zephyr.k_thread):
        self.run_function("z_ready_thread", [t.ptr], ['PTR'])

    def z_mark_thread_as_started(self, t: zephyr.k_thread):
        self.run_function("z_mark_thread_as_started", [t.ptr], ['PTR'])
    
    # def k_sched_lock(self):
    #     self.run_function("k_sched_lock", [], [])



    def dlist_itr_ptr(self, obj, attrs):
        target = obj
        for attr2 in attrs:
            target = getattr(target, attr2)
        if target.ptr is None:
            self.proxy.update_ptr(obj, attrs)
        
        return self.dlist_itr(target)

    def dlist_itr(self, node: zephyr._dnode):
        current = node

        assert node.ptr != 0
        
        for _ in range(0, 10000): # upper limit
            if current.head.ptr == node.ptr: # same as current.next
                break
            yield copy.copy(current.head) # same as current.next
            current = self.proxy.deref_no_cache(current.head) # same as current.next
        else:
            raise RuntimeError("dlist currupted or max depth exceeded")

