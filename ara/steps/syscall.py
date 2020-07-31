"""Container for Syscall."""
from ara.graph import ABBType, CFType, Graph
from .step import Step
from .option import Option, String
from .os import get_syscalls


class Syscall(Step):
    """Label abb call nodes as system call nodes.

    The analysis is only for ABBs reachable by the entry point.
    """
    entry_point = Option(name="entry_point",
                         help="system entry point",
                         ty=String())

    def get_single_dependencies(self):
        return ["ICFG", "FakeEntryPoint", "SysFuncts"]

    def run(self):
        entry_label = self.entry_point.get()
        entry_func = self._graph.cfg.get_function_by_name(entry_label)

        syscall_counter = 0

        for abb in self._graph.cfg.reachable_abbs(entry_func):
            if self._graph.cfg.vp.type[abb] == ABBType.call:
                for func in self._graph.cfg.get_call_targets(abb):
                    if self._graph.cfg.vp.syscall[func]:
                        self._log.debug(f"Found syscall {self._graph.cfg.vp.name[func]} "
                                        f"in {self._graph.cfg.vp.name[abb]}")
                        self._graph.cfg.vp.type[abb] = ABBType.syscall
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
