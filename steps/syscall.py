"""Container for Syscall."""
import graph

from native_step import Step

from .os import OS_API


class Syscall(Step):
    """Label abb call nodes as system call nodes."""

    def get_dependencies(self):
        return ["ICFG"]

    def run(self, g: graph.PyGraph):
        syscalls = [x['name'] for x in OS_API]
        abbs = g.new_graph.abbs()

        for function in abbs.children():
            if function.name in syscalls:
                function.syscall = True

        syscall_counter = 0
        for abb in abbs.vertices():
            if abb.type != graph.ABBType.computation:
                for edge in abb.out_edges():
                    if edge.type == graph.CFType.icf:
                        func = abbs.get_subgraph(edge.target())
                        if func.syscall:
                            self._log.debug(
                                f"Found syscall {func.name} in {abb.name}")
                            abb.type = graph.ABBType.syscall
                            syscall_counter += 1

        self._log.info(f"Found {syscall_counter} syscalls.")
