"""Container for Sysfuncts."""
from ara.os import get_oses
from .step import Step
from .option import Option, Bool

class SysFuncts(Step):
    """Label system functions as such and detect the OS."""

    no_stubs = Option(name="no_stubs",
                          help="Do not label system functions that are declared as stub. "
                               "This can increase the performance of the analysis if you have many stubs in your OS model.",
                          ty=Bool(),
                          default_value=False)

    def get_single_dependencies(self):
        return ["LLVMMap"]

    def is_syscall(self, syscall_name):
        """Returns True if syscall_name is a syscall for the current OS.

        This method also auto detects the OS if self._graph.os is not set.
        """
        for os in self.oses:
            if os.is_syscall(syscall_name):
                if self._graph.os in [None, os]:
                    self._graph.os = os
                else:
                    self._fail(f"Call {syscall_name} does not fit to OS {self._graph.os}.")
                return not os.detected_syscalls()[syscall_name].is_stub if self.no_stubs.get() else True
        return False

    def run(self):
        self.oses = get_oses()

        functs = self._graph.functs
        for nod in functs.vertices():
            call = functs.vp.name[nod]
            functs.vp.sysfunc[nod] = self.is_syscall(call)
        if self._graph.os is None:
            self._log.warn("OS cannot be detected. Are there any syscalls?")

        if self.dump.get():
            self._step_manager.chain_step(
                {"name": "Printer",
                 "dot": self.dump_prefix.get() + "dot",
                 "graph_name": 'CFG with syscall functions',
                 "subgraph": 'abbs'}
            )
