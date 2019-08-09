"""Container for Syscall."""
import graph

from native_step import Step

from .os import OS_API


class Syscall(Step):
    """Label abb call nodes as system call nodes."""

    def get_dependencies(self):
        return ["LLVMMap"]

    def run(self, g: graph.PyGraph):
        syscalls = [x['name'] for x in OS_API]
        abbs = g.new_graph.abbs()
        syscall_counter = 0
        for abb in abbs.vertices():
            if abb.type != graph.ABBType.computation:
                if abb.get_call() in syscalls:
                    self._log.debug(
                        f"Found syscall {abb.get_call()} in {abb.name}")
                    abb.type = graph.ABBType.syscall
                    syscall_counter += 1
        self._log.info(f"Found {syscall_counter} syscalls.")
