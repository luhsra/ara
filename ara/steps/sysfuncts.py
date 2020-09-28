"""Container for Sysfuncts."""
from ara.graph import Graph
from ara.os import get_syscalls
from .step import Step


class SysFuncts(Step):
    """Label system functions as such and detect the OS."""

    def get_single_dependencies(self):
        return ["LLVMMap"]

    def run(self):
        syscalls = dict(get_syscalls())

        for nod in self._graph.functs.vertices():
            call = self._graph.functs.vp.name[nod]
            found = call in syscalls
            self._graph.functs.vp.syscall[nod] = found
            if found:
                os = syscalls[call]
                if self._graph.os in [None, os]:
                    self._graph.os = os
                else:
                    self.fail(f"Call {call} does not fit to OS {self._graph.os}.")
        if self._graph.os is None:
            self._log.warn("OS cannot be detected. Are there any syscalls?")

        if self.dump.get():
            dump_prefix = self.dump_prefix.get()
            assert dump_prefix
            uuid = self._step_manager.get_execution_id()
            dot_file = dump_prefix + f'{uuid}.dot'
            self._step_manager.chain_step(
                {"name": "Printer",
                 "dot": dot_file,
                 "graph_name": 'CFG with syscall functions',
                 "subgraph": 'abbs'}
            )
