# SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2021 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Container for RecursiveFuntions."""
from ara.graph import Graph, CFGView
from .option import Option, Bool
from .step import Step

from graph_tool.topology import all_paths
import numpy

from ara.util import LEVEL

class RecursiveFunctions(Step):
    """Mark all function that are in the Callgraph as recursive or not."""

    no_recursive_funcs = Option(name="no_recursive_funcs",
                                help="Disables this step. True means: this step does nothing.",
                                ty=Bool())

    def get_single_dependencies(self):
        return ["CallGraph"]

    def run(self):
        
        #####
        if self.no_recursive_funcs.get():
            self._log.info("RecursiveFunctions is disabled!")
            return
        #####

        callgraph = self._graph.callgraph
        cfg = self._graph.cfg

        to_visit = callgraph.new_vp("bool")
        to_visit.a = numpy.invert(callgraph.vp.recursive.a)
        callgraph.set_vertex_filter(to_visit)

        for v in callgraph.vertices():
            path_nodes = []
            for path in all_paths(callgraph, v, v):
                for circuit_node in path:
                    cn = callgraph.vertex(circuit_node)
                    callgraph.vp.recursive[cn] = True
                    path_nodes.append(cn)
            for n in path_nodes + [v]:
                to_visit[n] = False
            callgraph.set_vertex_filter(to_visit)

        callgraph.clear_filters()

        if self.dump.get():
            self._step_manager.chain_step(
                {"name": "Printer",
                 "dot": self.dump_prefix.get() + '.dot',
                 "graph_name": 'Recusive functions',
                 "subgraph": 'callgraph'}
            )
