"""Container for CFGStats."""
from ara.graph import ABBType, CFGView, CFType, Graph, SyscallCategory
from .step import Step
from graph_tool.topology import label_components
from ara.os import get_syscalls

import graph_tool
import json
import sys
import numpy
import statistics

class CallGraphStats(Step):
    """Gather statistics about the Control Flow Graph."""

    def get_single_dependencies(self):
        return ["CallGraph"]

    def run(self):
        callgraph = self._graph.callgraph

        num_functions = callgraph.num_vertices()
        num_callees = callgraph.num_edges()

        self._log.info(f"Number of function: {num_functions}")
        self._log.info(f"Number of callees: {num_callees}")

        if self.dump.get():
            uuid = self._step_manager.get_execution_id()
            stat_file = f'{uuid}.json'
            stat_file = self.dump_prefix.get() + stat_file

            with open(stat_file, 'w') as f:
                values = {"num_functions": num_functions,
                          "num_callees": num_callees}
                json.dump(values, f, indent=4)
