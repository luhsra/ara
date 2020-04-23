from replace_syscalls_create cimport ReplaceSyscallsCreate as CReplaceSyscallsCreate
from steps.freertos import Task, Queue

from libc.stdint cimport intptr_t
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
        self.handle_queues(g)


    def handle_queues(self, g):
        self.g = g
        queue_list = [g.instances.vp.obj[v]
                      for v in g.instances.vertices()
                      if isinstance(g.instances.vp.obj[v], Queue)]

        for queue in queue_list:
            if queue.impl.init == 'static':
                self._create_queue_static(queue)

    def _create_queue_static(self, queue):
        self._c_.replace_queue_create_static(self.gwrap, self.g.cfg.vp.entry_bb[queue.abb], queue.impl.head.name.encode(), queue.impl.data.name.encode())
        pass

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
