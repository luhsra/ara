from replace_syscalls_create cimport ReplaceSyscallsCreate as CReplaceSyscallsCreate
from libc.stdint cimport uintptr_t
from cy_helper cimport get_derived_raw_pointer

from ara.steps.freertos import Task, Queue, Mutex


cdef class ReplaceSyscallsCreate(NativeStep):
    """Native/Python mixed Step for replacing create-syscalls"""

    def init(self):
        super().init()

    cdef CReplaceSyscallsCreate* _c_(self):
        return get_derived_raw_pointer[CReplaceSyscallsCreate](self._c_step)

    def run(self):
        for v in self._graph.instances.vertices():
            inst = self._graph.instances.vp.obj[v]
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
        success = deref(self._c_()).replace_mutex_create_static(self._graph.cfg.vp.entry_bb[mutex.abb], mutex.impl.head.name.encode())
        if not success:
            raise RuntimeError(f"Failed to create static create syscall for {mutex}")

    def _mutex_create_initialized(self, mutex):
        success = deref(self._c_()).replace_mutex_create_initialized(self._graph.cfg.vp.entry_bb[mutex.abb], mutex.impl.head.name.encode())
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
        success = deref(self._c_()).replace_queue_create_static(self._graph.cfg.vp.entry_bb[queue.abb], queue.impl.head.name.encode(), queue.impl.data.name.encode())
        if not success:
            raise RuntimeError(f"Failed to create static create syscall for {queue}")

    def _queue_create_initialized(self, queue):
        success = deref(self._c_()).replace_queue_create_initialized(self._graph.cfg.vp.entry_bb[queue.abb], queue.impl.head.name.encode())
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
        success = deref(self._c_()).replace_task_create_static(self._graph.cfg.vp.entry_bb[task.abb], task.impl.tcb.name.encode(), task.impl.stack.name.encode())
        if not success:
            raise RuntimeError(f"Failed to create static create syscall for {task}")

    def _task_create_initialized(self, task):
        success = deref(self._c_()).replace_task_create_initialized(self._graph.cfg.vp.entry_bb[task.abb], task.impl.tcb.name.encode())
        if not success:
            raise RuntimeError(f"Failed to create initialized create syscall for {task}")

cdef _native_step_fac_ReplaceSyscallsCreate():
    cdef unique_ptr[cstep.StepFactory] step_fac = make_step_fac[CReplaceSyscallsCreate]()
    n_step = NativeStepFactory(recipe_step=ReplaceSyscallsCreate)
    n_step._c_step_fac = move(step_fac)
    return n_step
