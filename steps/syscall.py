"""Container for Syscall."""
import graph
from graph import ABBType, CFType

from native_step import Step

from .os import OS_API


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
        syscalls = [x['name'] for x in OS_API]

        syscall_counter = 0

        for nod in g.functs.vertices():
            g.functs.vp.syscall[nod] = (g.functs.vp.name[nod] in syscalls)
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

        self._log.info(f"Found {syscall_counter} syscalls.")
