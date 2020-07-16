"""Container for Value Anaylsis."""
import pyllco

import graph_tool
import graph_tool.util

import ara.graph

from .step import Step
from .option import Option, String

def p_print(obj):
    import pprint
    pp = pprint.PrettyPrinter(indent=4)
    pp.pprint(obj)

class ValueAnalysis(Step):
    """Perform a value analysis for all system calls.

    This is actually a post processing step that proper repacks the arguments.
    The real work is done within the ValueAnalysisCore step.
    """
    entry_point = Option(name="entry_point",
                         help="Entry point for Value analysis",
                         ty=String())

    def get_single_dependencies(self):
        return [{"name": "ValueAnalysisCore",
                 "entry_point": self.entry_point.get()}]

    def _convert_to_abbs(self, call_path):
        """Convert a call_path consisting of pointer to LLVM basic blocks to a
        tuple of vertices in the ARA cfg."""
        cp = []
        for bb_ptr in call_path:
            v = graph_tool.util.find_vertex(self._graph.cfg,
                                            self._graph.cfg.vp.entry_bb,
                                            bb_ptr)
            assert v is not None and len(v) == 1
            cp += v
        return tuple(cp)

    def run(self):
        entry_label = self.entry_point.get()
        entry_func = self._graph.cfg.get_function_by_name(entry_label)

        for abb in self._graph.cfg.reachable_abbs(entry_func):
            if self._graph.cfg.vp.type[abb] != ara.graph.ABBType.syscall:
                continue

            args = self._graph.cfg.vp.arguments[abb]
            ## to pretty-print args structure
            #p_print(args)
            assert type(args) is list

            self._log.debug(f"Processing node {self._graph.cfg.vp.name[abb]}.")

            new_args = ara.graph.Arguments()
            for i, arg in enumerate(args):
                # Argument construction
                new_arg = None
                if arg is not None:
                    consts = dict([(tuple(x), y) for x, y in arg[1]])
                    new_arg = ara.graph.Argument(arg[0], consts[tuple()])
                    if len(consts) > 1:
                        for key, value in consts.items():
                            if key == tuple():
                                continue
                            call_path = self._convert_to_abbs(key)
                            new_arg.add_variant(call_path, value)
                # assignment
                if i == 0:
                    self._log.debug(f"Retrieved return value {new_arg}")
                    new_args.set_return_value(new_arg)
                else:
                    self._log.debug(f"Retrieved argument: Argument(")
                    for cp, value in new_arg:
                        self._log.debug(f"  {cp}, {value}")
                    self._log.debug(f")")

                    new_args.append(new_arg)
            self._graph.cfg.vp.arguments[abb] = new_args
