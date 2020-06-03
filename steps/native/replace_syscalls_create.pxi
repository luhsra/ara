from replace_syscalls_create cimport ReplaceSyscallsCreate as CReplaceSyscallsCreate
from steps.freertos import Task, Queue, Mutex

from libc.stdint cimport uintptr_t
cimport ir

cdef class ReplaceSyscallsCreate(NativeStep):
    """Native/Python mixed Step for replacing create-syscalls"""

    cdef CReplaceSyscallsCreate* _c_
    cdef cgraph.Graph gwrap
    cdef g

    def init(self):
        super().init()
        self._c_ = <CReplaceSyscallsCreate*> self._c_pass

    def run(self, g):
        self.g = g
        cdef llvm_data.PyLLVMData llvm_w = g._llvm_data
        self.gwrap = cgraph.Graph(g, llvm_w._c_data)

        for v in g.instances.vertices():
            inst = g.instances.vp.obj[v]
            if isinstance(inst, Queue):
                self.handle_queue(inst)
            elif isinstance(inst, Task):
                self.handle_task(inst)
            elif isinstance(inst, Mutex):
                self.handle_mutex(inst)
            else:
                self._log.error("unknown instance: %s %s", type(inst), inst)

    def handle_mutex(self, mutex):
        if mutex.impl.init == 'static':
            self._mutex_create_static(mutex)
        elif mutex.impl.init == 'initialized':
            self._mutex_create_initialized(mutex)
        else:
            raise RuntimeError("unknown init: %s || %s", mutex.impl.init, mutex)

    def _mutex_create_static(self, mutex):
        success = self._c_.replace_mutex_create_static(self.gwrap, self.g.cfg.vp.entry_bb[mutex.abb], mutex.impl.head.name.encode())
        if not success:
            raise RuntimeError(f"Failed to create static create syscall for {mutex}")

    def _mutex_create_initialized(self, mutex):
        success = self._c_.replace_mutex_create_initialized(self.gwrap, self.g.cfg.vp.entry_bb[mutex.abb], mutex.impl.head.name.encode())
        if not success:
            raise RuntimeError(f"Failed to create static create syscall for {mutex}")


    def handle_queue(self, queue):
        if queue.impl.init == 'static':
            self._queue_create_static(queue)
        elif queue.impl.init == 'initialized':
            self._queue_create_initialized(queue)
        else:
            raise RuntimeError("inknown init: %s", queue.impl.init)

    def _queue_create_static(self, queue):
        success = self._c_.replace_queue_create_static(self.gwrap, self.g.cfg.vp.entry_bb[queue.abb], queue.impl.head.name.encode(), queue.impl.data.name.encode())
        if not success:
            raise RuntimeError(f"Failed to create static create syscall for {queue}")

    def _queue_create_initialized(self, queue):
        success = self._c_.replace_queue_create_initialized(self.gwrap, self.g.cfg.vp.entry_bb[queue.abb], queue.impl.head.name.encode())
        if not success:
            raise RuntimeError(f"Failed to create static create syscall for {queue}")

    def handle_task(self, task):
        if task.impl.init == 'static':
            self._task_create_static(task)
        elif task.impl.init == 'initialized':
            self._task_create_initialized(task)
        else:
            raise RuntimeError("inknown init: %s", task.impl.init)

    def _task_create_static(self, task):
        success = self._c_.replace_task_create_static(self.gwrap, self.g.cfg.vp.entry_bb[task.abb], task.impl.tcb.name.encode(), task.impl.stack.name.encode())
        if not success:
            raise RuntimeError(f"Failed to create static create syscall for {task}")

    def _task_create_initialized(self, task):
        success = self._c_.replace_task_create_initialized(self.gwrap, self.g.cfg.vp.entry_bb[task.abb], task.impl.tcb.name.encode())
        if not success:
            raise RuntimeError(f"Failed to create initialized create syscall for {task}")

cdef _native_fac_ReplaceSyscallsCreate():
    """Construct a NativeStep. Expects an already constructed C++-Step pointer.
    This pointer can be retrieved with step_fac[...]().

    Don't use this function. Use provide_steps to get all steps.
    """
    cdef cstep.Step* step = step_fac[CReplaceSyscallsCreate]()
    n_step = ReplaceSyscallsCreate()
    n_step._c_pass = step
    n_step.init()
    return n_step
