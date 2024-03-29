# SPDX-FileCopyrightText: 2022 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2022 Domenik Kuhn
# SPDX-FileCopyrightText: 2022 Jan Neugebauer
# SPDX-FileCopyrightText: 2023 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Container for SIA."""

from ara.graph import ABBType, CFGView, SyscallCategory, CallPath, Callgraph, CFType
from dataclasses import dataclass
from ara.util import dominates, has_path, is_recursive
from ara.visualization.trace.tracer_api.tracer import GraphNode, GraphPath, init_fast_trace
from ara.graph.mix import GraphType, ARA_ENTRY_POINT

from .step import Step
from .option import Option, String


from ara.os.os_base import CPU, ExecState

from graph_tool import GraphView
from graph_tool.topology import all_paths, dominator_tree, label_out_component
from graph_tool.util import find_vertex
from itertools import chain

import functools


@dataclass
class SIAContext:
    """Analysis Context for SIA´s fake CPU in OSState"""
    callg: Callgraph
    branch: bool  # is this state coming from a branch
    loop: bool  # is this state coming from a loop
    recursive: bool  # is this state executing on a recursive path
    usually_taken: bool  # is this state coming from a branch where
    # all other branches ends in an endless loop
    scheduler_on: bool  # Is the global scheduler on

    def copy(self):
        return SIAContext(callg=self.callg,
                          branch=self.branch,
                          loop=self.loop,
                          recursive=self.recursive,
                          usually_taken=self.usually_taken,
                          scheduler_on=self.scheduler_on)


class FlatAnalysis(Step):
    """Flat Analysis"""

    def get_single_dependencies(self):
        raise NotImplementedError

    def _get_os_specific_deps(self):
        if self._graph.os is None:
            return ['SysFuncts']
        return self._graph.os.get_special_steps()

    @functools.lru_cache(maxsize=32)
    def _get_func_cfg(self, func):
        """Get LCFG of function"""
        abb = self._graph.cfg.get_entry_abb(func)
        comp = label_out_component(self._graph.lcfg,
                                   self._graph.lcfg.vertex(abb))
        return CFGView(self._graph.lcfg, vfilt=comp)

    @functools.lru_cache(maxsize=32)
    def _create_dom_tree(self, func, respect_endless_loops=True):
        """Create a dominator tree of the local control flow for func.

        Return the dominator tree and a list of exit blocks for the function.
        """
        func_cfg = self._get_func_cfg(func)
        entry = self._graph.cfg.get_entry_abb(func)

        # prepare LCFG:
        # If respect_endless_loops is set (the default), endless loops are
        # considered as possible exit blocks.
        # This is done by detecting and replacing them with real exit blocks.
        exit_map = func_cfg.vp.is_exit.copy(full=False)
        keep_edge_map = func_cfg.new_ep("bool", val=True)

        if respect_endless_loops:
            # iterate all exit loops (AKA endless loops)
            loops = CFGView(func_cfg, vfilt=func_cfg.vp.is_exit_loop_head)
            for loop_head in loops.vertices():
                loop_head = func_cfg.vertex(loop_head)
                for e in loop_head.in_edges():
                    loop_end = e.source()
                    if loop_head == loop_end or \
                       has_path(func_cfg, loop_head, loop_end):
                        # if edge that is a part of the loop
                        # drop it
                        keep_edge_map[e] = False
                        exit_map[loop_end] = True

        patched_func_cfg = CFGView(func_cfg, efilt=keep_edge_map)

        # dom tree creation
        dom_tree = dominator_tree(patched_func_cfg,
                                  patched_func_cfg.vertex(entry))
        return dom_tree, CFGView(func_cfg, vfilt=exit_map)

    def _is_in_condition(self, abb, respect_endless_loops=True):
        """Is abb part of a condition?"""
        # Algorithm: abb must not dominate all exits
        func = self._graph.cfg.get_function(abb)
        dom_tree, exit_abbs = self._create_dom_tree(
            func, respect_endless_loops=respect_endless_loops)
        return not all(
            [dominates(dom_tree, abb, x) for x in exit_abbs.vertices()])

    def _is_usually_taken(self, abb):
        """Is this abb usually taken?

        Usually taken means that the abb is part of a branch, where all sibling
        branches end in an endless loop.

        Consider this example:
         1o
          |`--.
          |   v
         2o  3o <.
              |  |
              v  |
             4o--´
        The node 2 is usually taken.
        """
        return (self._is_in_condition(abb, respect_endless_loops=True) and
                not self._is_in_condition(abb, respect_endless_loops=False))

    def _is_chained_analysis(self):
        return self.get_name() in {
            x.name
            for x in self._step_manager.get_history()
        }

    def _set_flags(self, analysis_context: SIAContext, abb):
        analysis_context.branch |= self._is_in_condition(abb)
        analysis_context.loop |= self._graph.cfg.vp.part_of_loop[abb]
        analysis_context.usually_taken = (self._is_usually_taken(abb) or
                                          (analysis_context.usually_taken
                                           and not self._is_in_condition(abb)))

    def _dump_names(self):
        raise NotImplementedError

    def _search_category(self):
        raise NotImplementedError

    def _get_entry_points(self):
        raise NotImplementedError

    def _trigger_new_steps(self):
        pass

    def is_traceable(self):
        return True and self.trace_algorithm.get()

    def run(self):
        cfg = self._graph.cfg
        callg = self._graph.callgraph
        os = self._graph.os
        instances = self._graph.instances

        entry_points = self._get_entry_points()

        if self.trace_algorithm.get():
            init_fast_trace(self)
            sia_entity = self.tracer.get_entity("SIA_entity")

        # actual algorithm
        syscalls = CFGView(cfg, vfilt=cfg.vp.type.fa == ABBType.syscall)
        for syscall in syscalls.vertices():
            sys_name = cfg.get_syscall_name(syscall)
            if self._search_category() not in os.syscalls[sys_name].categories:
                continue

            cfg_function = cfg.get_function(syscall)
            function = callg.vertex(cfg.vp.call_graph_link[cfg_function])

            if self.trace_algorithm.get():
                abb = cfg.vertex(syscall)
                syscall_node = [
                    x.target() for x in abb.out_edges()
                    if cfg.ep.type[x] == CFType.icf
                ]
                syscall_cfg_func = cfg.get_function(syscall_node[0])

                syscall_func = callg.vertex(
                    cfg.vp.call_graph_link[syscall_cfg_func])
                self.tracer.entity_on_node(sia_entity, [
                    GraphNode(abb, GraphType.ABB),
                    GraphNode(syscall_func, GraphType.CALLGRAPH)
                ])

            rev_cg = GraphView(callg, reversed=True)
            init_state = os.get_initial_state(cfg, instances)
            for entry_point, inst in entry_points:
                if inst is not None:
                    inst = instances.vertex(inst)
                    branch = instances.vp.branch[inst]
                    loop = instances.vp.loop[inst]
                    cpu_id = instances.vp.obj[inst].cpu_id
                    if cpu_id < 0:
                        cpu_id = 0
                else:
                    branch = False
                    loop = False
                    cpu_id = 0

                self._log.debug(f"Handle {sys_name} with entry_point "
                                f"{callg.vp.function_name[entry_point]}")

                path_to_self = [[]] if entry_point == function else []
                for path in chain(
                        all_paths(rev_cg, function, entry_point, edges=True),
                        path_to_self):

                    if self.trace_algorithm.get():
                        self.tracer.entity_is_looking_at(
                            sia_entity, GraphPath(path, GraphType.CALLGRAPH))

                    abb = cfg.vertex(syscall)
                    state = init_state.copy()

                    state.cpus[cpu_id] = CPU(
                        id=state.cpus[cpu_id].id,
                        irq_on=False,
                        control_instance=inst,
                        abb=abb,
                        call_path=CallPath(),
                        exec_state=ExecState.from_abbtype(cfg.vp.type[abb]),
                        analysis_context=SIAContext(
                            callg=callg,
                            branch=branch,
                            loop=loop,
                            recursive=False,
                            usually_taken=False,
                            scheduler_on=self._is_chained_analysis()))
                    fake_cpu = state.cpus[cpu_id]
                    for edge in reversed(path):
                        abb = cfg.vertex(callg.ep.callsite[edge])
                        fake_cpu.call_path.add_call_site(callg, edge)
                        self._set_flags(fake_cpu.analysis_context, abb)
                        if not fake_cpu.analysis_context.recursive:
                            fake_cpu.analysis_context.recursive = is_recursive(callg, edge.target())

                    self._set_flags(fake_cpu.analysis_context, syscall)
                    if not fake_cpu.analysis_context.recursive:
                        fake_cpu.analysis_context.recursive = is_recursive(callg, function)

                    os.interpret(self._graph,
                                 state,
                                 0,
                                 categories=self._search_category())

        self._trigger_new_steps()
        self._log.debug(is_recursive.cache_info())

        if self.dump.get():
            spec, graph_name = self._dump_names()
            dot_file = f'{self.dump_prefix.get()}.{spec}.dot'
            self._step_manager.chain_step({
                "name": "Printer",
                "dot": dot_file,
                "graph_name": graph_name,
                "subgraph": 'instances'
            })


class SIA(FlatAnalysis):
    """Static Instance Analysis: Find all application instances."""
    entry_point = Option(name="entry_point",
                         help="system entry point",
                         ty=String())

    def get_single_dependencies(self):
        deps = [{"name": "Syscall", "entry_point": self.entry_point.get()}]
        deps += self._get_os_specific_deps()
        return deps

    def _trigger_new_steps(self):
        step_data = self._get_step_data(set)

        for entry, _ in self._graph.instances.iterate_control_entry_points():
            func_name = self._graph.cfg.vp.name[entry]
            if func_name not in step_data and func_name != ARA_ENTRY_POINT:
                self._step_manager.chain_step({
                    "name": self.get_name(),
                    "entry_point": func_name
                })
                step_data.add(func_name)

    def _get_entry_points(self):
        # find entry point in callgraph
        self.ep_name = self.entry_point.get()
        callgraph = self._graph.callgraph
        entry_points = find_vertex(callgraph, callgraph.vp.function_name,
                                   self.ep_name)
        if len(entry_points) != 1:
            self._fail(f"Entry Point {self.ep_name} cannot be found")
        entry_point = entry_points[0]

        # find instance that belongs to this point
        cfg_func = self._graph.cfg.vertex(callgraph.vp.function[entry_point])

        instances = [
            v for func, v in self._graph.instances.iterate_control_entry_points()
            if func == cfg_func
        ]

        result = [(entry_point, x) for x in instances]
        if result:
            return result
        return [(entry_point, None)]

    def _dump_names(self):
        return self.ep_name, 'Instances'

    def _search_category(self):
        return SyscallCategory.create


class InteractionAnalysis(FlatAnalysis):
    """Find the flow insensitive interactions between instances."""

    def get_single_dependencies(self):
        deps = self._get_os_specific_deps()
        if self._graph.os.has_dynamic_instances():
            deps.append('SIA')
        return deps

    def _dump_names(self):
        return '', 'Interactions'

    def _search_category(self):
        return SyscallCategory.comm

    def _get_entry_points(self):
        cfg = self._graph.cfg
        cg = self._graph.callgraph
        return [(cg.vertex(cfg.vp.call_graph_link[x]), v)
                for x, v in self._graph.instances.iterate_control_entry_points()]
