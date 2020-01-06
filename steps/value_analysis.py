"""Container for Value Anaylsis."""
import graph

import pyllco

import graph_tool

from native_step import Step
from .option import Option, Integer


class ValueAnalysis(Step):
    """Perform a value analysis for all system calls.

    This is actually a post processing step that proper repacks the arguments.
    The real work is done within the ValueAnalysisCore step.
    """

    def get_dependencies(self):
        return ["ValueAnalysisCore"]

    def run(self, g: graph.Graph):
        for v in filter(lambda x: g.cfg.vp.type[x] == graph.ABBType.syscall,
                        g.cfg.vertices()):
            args = g.cfg.vp.arguments[v]
            assert type(args) is list

            self._log.debug(f"Processing node {g.cfg.vp.name[v]}.")

            g.cfg.vp.arguments[v] = [graph.Argument(x[0], x[1]) for x in args]
