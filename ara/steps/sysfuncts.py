"""Container for Sysfuncts."""
from ara.graph import Graph
from .step import Step
from .os import get_syscalls


class SysFuncts(Step):
    """Label system functions as such and detect the OS."""

    def get_dependencies(self):
        return ["LLVMMap"]

    def run(self, g: Graph):
        syscalls = dict(get_syscalls())

        for nod in g.functs.vertices():
            call = g.functs.vp.name[nod]
            found = call in syscalls
            g.functs.vp.syscall[nod] = found
            if found:
                os = syscalls[call]
                if g.os in [None, os]:
                    g.os = os
                else:
                    self._log.error(f"Call {call} does not fit to OS {g.os}.")

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
