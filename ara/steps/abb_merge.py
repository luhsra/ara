"""Container for ABBMerge."""

from ara.graph import ABBType, CFType, Graph
from native_step import Step
from .option import Option, Integer

import functools
import graph_tool


class ABBMerge(Step):
    """Merge ABBs into maximal ABBs."""

    def _is_call_connected(self, source, target):
        if source == target:
            return True
        for _ in graph_tool.topology.all_paths(self.callgraph, source, target):
            return True
        return False

    def get_dependencies(self):
        return ["Syscall"]

    def get_called_functions(self, abb):
        called_functions = []
        if self.cfg.vp.type[abb] in [ABBType.call, ABBType.syscall]:
            called_abbs = [x.target() for x in abb.out_edges()
                           if self.cfg.ep.type[x] == CFType.icf]
            for abb in called_abbs:
                called_function = [x.target() for x in abb.out_edges()
                                   if self.cfg.ep.type[x] == CFType.a2f]
                assert len(called_function) == 1
                called_functions.append(self.cfg.vp.name[called_function[0]])
        return called_functions

    def add_function(self, function):
        if function not in self.function_list:
            self._log.debug(f"Add function {function} to callgraph.")
            self.function_list[function] = self.callgraph.add_vertex()
        return self.function_list[function]

    def add_to_callgraph(self, function):
        vert = self.add_function(self.cfg.vp.name[function])
        for abb in [x.target() for x in function.out_edges()
                    if self.cfg.ep.type[x] == CFType.f2a]:
            for called_function in self.get_called_functions(abb):
                other_vert = self.add_function(called_function)
                self.callgraph.add_edge(vert, other_vert)

    def run(self, g: Graph):
        self.cfg = g.cfg
        self.callgraph = graph_tool.Graph()
        self.function_list = {}

        # build callgraph
        for function in g.cfg.vertices():
            if g.cfg.vp.is_function[function]:
                self.add_to_callgraph(function)

        self.callgraph.save("callgraph.dot")

        # find system relevant functions
        syscalls = [g.functs.vp.name[x] for x in g.functs.vertices()
                    if g.functs.vp.syscall[x]]
        system_relevant = set()

        for function in g.functs.vertices():
            function = g.functs.vp.name[function]
            for syscall in syscalls:
                if self._is_call_connected(self.function_list[function],
                                           self.function_list[syscall]):
                    self._log.debug(f"{function} is system relevant.")
                    system_relevant.add(function)
                    break

        # mark calls to system irrelevant functions as computation
        for abb in g.cfg.vertices():
            if g.cfg.vp.is_function[abb]:
                continue
            for called_function in self.get_called_functions(abb):
                if called_function not in system_relevant:
                    self._log.debug(f"Set {g.cfg.vp.name[abb]} (calling " +
                                    f"{called_function}) to computation")
                    g.cfg.vp.type[abb] = ABBType.computation

        # TODO: discuss
        # # delete functions
        # deletions = []
        # print(system_relevant)
        # for func in g.functs.vertices():
        #     if g.functs.vp.name[func] not in system_relevant:
        #         print(g.functs.vp.name[func])
        #         print([g.cfg.vp.name[x] for x in g.cfg.get_abbs(func)])
        #         deletions += [x for x in g.cfg.get_abbs(func)]
        #         deletions.append(g.cfg.vertex(func))
        # self._log.info(f"Remove {len(deletions)} not system relevant nodes.")
        # g.cfg.remove_vertex(deletions)

        if self.dump.get():
            dump_prefix = self.dump_prefix.get()
            assert dump_prefix
            uuid = self._step_manager.get_execution_id()
            dot_file = dump_prefix + f'{uuid}.dot'
            self._step_manager.chain_step({"name": "Printer",
                                           "dot": dot_file,
                                           "graph_name": 'CFG after ABB merge',
                                           "subgraph": 'abbs'})
