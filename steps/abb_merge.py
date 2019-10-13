"""Container for ABBMerge."""
import graph

from native_step import Step
from .option import Option, Integer
from graph import ABBType

import functools


class ABBMerge(Step):
    """Merge ABBs into maximal ABBs."""

    def get_dependencies(self):
        return ["Syscall"]

    def get_called_functions(self, abb):
        if abb.type == graph.ABBType.call or abb.type == graph.ABBType.syscall:
            return [self.abbs.get_subgraph(x.target())
                    for x in abb.out_edges()
                    if x.type == graph.CFType.icf]
        return []

    def add_function(self, function):
        if function not in self.function_list:
            self._log.debug(f"Add function {function} to callgraph.")
            self.function_list[function] = self.callgraph.add_vertex()
        return self.function_list[function]

    def add_to_callgraph(self, function):
        vert = self.add_function(function)
        for abb in map(function.local_to_global, function.vertices()):
            for called_function in self.get_called_functions(abb):
                other_vert = self.add_function(called_function)
                self.callgraph.add_edge(vert, other_vert)

    def run(self, g: graph.PyGraph):
        self.abbs = g.new_graph.abbs()
        self.callgraph = graph.create_graph()
        self.function_list = {}

        # build callgraph
        for function in self.abbs.children():
            self.add_to_callgraph(function)

        # find system relevant functions
        syscalls = [x for x in self.abbs.children() if x.syscall]
        system_relevant = set()

        for edge in self.callgraph.edges():
            for x,y in self.function_list.items():
                if (y == edge.source()):
                    s = x
                if (y == edge.target()):
                    t = x
            print(edge.source(), s, edge.target(), t)


        for function in self.abbs.children():
            for syscall in syscalls:
                if self.callgraph.is_connected(self.function_list[function],
                                               self.function_list[syscall]):
                    self._log.debug(f"{function} is system relevant.")
                    system_relevant.add(function)
                    break

        # mark calls to system irrelevant functions as computation
        for function in self.abbs.children():
            for abb in map(function.local_to_global, function.vertices()):
                for called_function in self.get_called_functions(abb):
                    if called_function not in system_relevant:
                        self._log.debug(f"Set {abb} (calling {called_function}) to computation")
                        abb.type = ABBType.computation
