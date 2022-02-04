"""Container for Syscall."""
from ara.graph import ABBType, CFType, Graph
from .step import Step
from .option import Option, String


class Syscall(Step):
    """Label abb call nodes as system call nodes.

    The analysis is only for ABBs reachable by the entry point.
    """
    entry_point = Option(name="entry_point",
                         help="system entry point",
                         ty=String())

    def get_single_dependencies(self):
        return [{"name": "ICFG", "entry_point": self.entry_point.get()},
                {"name": "CreateABBs", "entry_point": self.entry_point.get()},
                "FakeEntryPoint",
                "SysFuncts"]

    def run(self):
        entry_label = self.entry_point.get()
        entry_func = self._graph.cfg.get_function_by_name(entry_label)

        syscall_counter = 0

        for abb in self._graph.cfg.reachable_abbs(entry_func,
                                                  self._graph.callgraph):
            if self._graph.cfg.vp.type[abb] == ABBType.call:
                for func in self._graph.cfg.get_call_targets(abb):
                    if self._graph.cfg.vp.sysfunc[func]:
                        self._log.debug(f"Found syscall {self._graph.cfg.vp.name[func]} "
                                        f"in {self._graph.cfg.vp.name[abb]}")
                        self._graph.cfg.vp.type[abb] = ABBType.syscall
                        syscall_counter += 1

        if self.dump.get():
            dot_file = self.dump_prefix.get() + f'{entry_label}.dot'
            name = f"CFG with syscalls (Function: {entry_label})"
            self._step_manager.chain_step({"name": "Printer",
                                            "dot": dot_file,
                                            "graph_name": name,
                                            "entry_point": entry_label,
                                            "from_entry_point": True,
                                            "subgraph": 'abbs'})

        self._log.info(f"Found {syscall_counter} syscalls.")
