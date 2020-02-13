"""Container for Syscall."""
import graph
from graph import ABBType, CFType

from native_step import Step

from .os import get_syscalls


class Syscall(Step):
    """Label abb call nodes as system call nodes."""

    def get_function(self, cfg, abb):
        func = [x.target() for x in abb.out_edges()
                if cfg.ep.type[x] == graph.CFType.a2f]
        assert len(func) == 1
        return func[0]

    def get_dependencies(self):
        return ["ICFG"]

    def run(self, g: graph.Graph):
        syscalls = dict(get_syscalls())

        syscall_counter = 0

        for nod in g.functs.vertices():
            call = g.functs.vp.name[nod]
            found = call in syscalls
            g.functs.vp.syscall[nod] = found
            if found:
                os = syscalls[call]
                if g.os in [None, os]:
                    g.os = os
                else:
                    self._log.error("Call {call} does not fit to OS {g.os}.")
        for nod in g.cfg.vertices():
            if g.cfg.vp.is_function[nod]:
                continue
            if g.cfg.vp.type[nod] != ABBType.computation:
                for edge in nod.out_edges():
                    if g.cfg.ep.type[edge] == CFType.icf:
                        func = self.get_function(g.cfg, edge.target())
                        if g.cfg.vp.syscall[func]:
                            self._log.debug(
                                f"Found syscall {g.cfg.vp.name[func]} " +
                                f"in {g.cfg.vp.name[nod]}")
                            g.cfg.vp.type[nod] = ABBType.syscall
                            syscall_counter += 1

        if self.dump.get():
            dump_prefix = self.dump_prefix.get()
            assert dump_prefix
            uuid = self._step_manager.get_execution_id()
            dot_file = dump_prefix + f'{uuid}.dot'
            self._step_manager.chain_step({"name": "Printer",
                                           "dot": dot_file,
                                           "graph_name": 'CFG with syscalls',
                                           "subgraph": 'abbs'})

        self._log.info(f"Found {syscall_counter} syscalls.")
