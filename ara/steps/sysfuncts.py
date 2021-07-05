"""Container for Sysfuncts."""
from ara.os import get_syscalls
from .step import Step


class SysFuncts(Step):
    """Label system functions as such and detect the OS."""

    def get_single_dependencies(self):
        return ["LLVMMap"]

    def run(self):
        syscalls = dict(get_syscalls())

        functs = self._graph.functs
        for nod in functs.vertices():
            call = functs.vp.name[nod]
            found = call in syscalls
            functs.vp.sysfunc[nod] = found
            if found:
                os = syscalls[call]
                if self._graph.os in [None, os]:
                    self._graph.os = os
                else:
                    self.fail(f"Call {call} does not fit to OS {self._graph.os}.")
        if self._graph.os is None:
            self._log.warn("OS cannot be detected. Are there any syscalls?")

        if self.dump.get():
            self._step_manager.chain_step(
                {"name": "Printer",
                 "dot": self.dump_prefix.get() + "dot",
                 "graph_name": 'CFG with syscall functions',
                 "subgraph": 'abbs'}
            )
