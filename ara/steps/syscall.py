"""Container for Syscall."""
from ara.graph import ABBType, CFType, Graph
from .step import Step
from .option import Option, String
from .os import get_syscalls


class Syscall(Step):
    """Label abb call nodes as system call nodes.

    The analysis is only for ABBs reachable by the entry point.
    """

    def _fill_options(self):
        self.entry_point = Option(name="entry_point",
                                  help="system entry point",
                                  step_name=self.get_name(),
                                  ty=String())
        self.opts.append(self.entry_point)

    def get_dependencies(self):
        return ["ICFG", "SysFuncts"]

    def run(self, g: Graph):
        entry_label = self.entry_point.get()
        entry_func = g.cfg.get_function_by_name(entry_label)

        syscall_counter = 0

        for abb in g.cfg.reachable_abbs(entry_func):
            if g.cfg.vp.type[abb] == ABBType.call:
                for func in g.cfg.get_call_targets(abb):
                    if g.cfg.vp.syscall[func]:
                        self._log.debug(f"Found syscall {g.cfg.vp.name[func]} "
                                        f"in {g.cfg.vp.name[abb]}")
                        g.cfg.vp.type[abb] = ABBType.syscall
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
