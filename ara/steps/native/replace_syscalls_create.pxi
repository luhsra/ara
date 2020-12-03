from replace_syscalls_create cimport ReplaceSyscallsCreate as CReplaceSyscallsCreate
from libc.stdint cimport uintptr_t
from cy_helper cimport get_derived_raw_pointer

from ara.os.freertos import Task, Queue, Mutex


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
        deref(self._c_()).replace_mutex_create(mutex)

    def handle_queue(self, queue):
        deref(self._c_()).replace_queue_create(queue)

    def handle_task(self, task):
        deref(self._c_()).replace_task_create(task)

cdef _native_step_fac_ReplaceSyscallsCreate():
    cdef unique_ptr[cstep.StepFactory] step_fac = make_step_fac[CReplaceSyscallsCreate]()
    n_step = NativeStepFactory(recipe_step=ReplaceSyscallsCreate)
    n_step._c_step_fac = move(step_fac)
    return n_step
