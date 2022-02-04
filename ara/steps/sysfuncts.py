"""Container for Sysfuncts."""

from ara.graph import Graph
from ara.os import get_oses

from .step import Step
from .option import Option, Bool

class SysFuncts(Step):
    """Label system functions as such and detect the OS."""

    no_stubs = Option(name="no_stubs",
                      help="Do not label system functions that are declared as stub. "
                            "This can increase the performance of the analysis if you have many stubs in your OS model. "
                            "Set this option also for SystemRelevantFunctions or set the commandline argument --no-stubs.",
                      ty=Bool(),
                      default_value=False)

    def get_single_dependencies(self):
        return ["LLVMMap"]

    def is_syscall(self, syscall_name):
        """Returns True if syscall_name is a syscall for the current OS.

        This method also auto detects the OS if self._graph.os is not set.
        """
        def return_if_no_stub(os, syscall_name):
            return not os.detected_syscalls()[syscall_name].is_stub if self.no_stubs.get() else True
        
        if self._graph.os is not None:
            if self._graph.os.is_syscall(syscall_name):
                return return_if_no_stub(self._graph.os, syscall_name)
        else:
            # TODO: improve auto os detection to run with syscalls in multiple oses (like memcpy) 
            for os in self.oses:
                if os.is_syscall(syscall_name):
                    self._graph.os = os
                    return return_if_no_stub(os, syscall_name)
        return False

    def run(self):
        self.oses = get_oses()

        for nod in self._graph.functs.vertices():
            call = self._graph.functs.vp.name[nod]
            self._graph.functs.vp.sysfunc[nod] = self.is_syscall(call)
        if self._graph.os is None:
            self._log.warn("OS cannot be detected. Are there any syscalls?")

        if self.dump.get():
            self._step_manager.chain_step(
                {"name": "Printer",
                 "dot": self.dump_prefix.get() + "dot",
                 "graph_name": 'CFG with syscall functions',
                 "subgraph": 'abbs'}
            )
