"""Container for Sysfuncts."""
from ara.os import get_oses
from .step import Step


class SysFuncts(Step):
    """Label system functions as such and detect the OS."""

    def get_single_dependencies(self):
        return ["LLVMMap"]

    def is_syscall(self, syscall_name):
        for os in self.oses:
            if os.is_syscall(syscall_name):
                if self._graph.os in [None, os]:
                    self._graph.os = os
                else:
                    self._fail(f"Call {syscall_name} does not fit to OS {self._graph.os}.")
                return True
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
