"""Container for Value Anaylsis."""
import graph

import pyllco

import graph_tool
import graph_tool.util

from native_step import Step
from .option import Option, Integer


class ValueAnalysis(Step):
    """Perform a value analysis for all system calls.

    This is actually a post processing step that proper repacks the arguments.
    The real work is done within the ValueAnalysisCore step.
    """

    def get_dependencies(self):
        return ["ValueAnalysisCore"]

    def _convert_to_abbs(self, g, call_path):
        cp = []
        for bb_ptr in call_path:
            v = graph_tool.util.find_vertex(g.cfg, g.cfg.vp.entry_bb, bb_ptr)
            assert v is not None
            cp.append(v)
        return tuple(v)

    def run(self, g: graph.Graph):
        for v in filter(lambda x: g.cfg.vp.type[x] == graph.ABBType.syscall,
                        g.cfg.vertices()):
            args = g.cfg.vp.arguments[v]
            assert type(args) is list

            self._log.debug(f"Processing node {g.cfg.vp.name[v]}.")

            new_args = []
            for arg in args:
                consts = dict([(tuple(x), y) for x, y in arg[1]])
                new_arg = graph.Argument(arg[0], consts[tuple()])
                if len(consts) > 1:
                    for key, value in consts.items():
                        if key == tuple():
                            continue
                        call_path = self._convert_to_abbs(g, key)
                        new_arg.add_variant(call_path, value)
                self._log.debug(f"Retrieved argument {new_arg}")
                new_args.append(new_arg)
            g.cfg.vp.arguments[v] = new_args
