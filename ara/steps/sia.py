# SPDX-FileCopyrightText: 2022 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2022 Domenik Kuhn
# SPDX-FileCopyrightText: 2022 Jan Neugebauer
# SPDX-FileCopyrightText: 2023 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Container for SIA."""

from ara.graph import ABBType, CFGView, SyscallCategory, CallPath, Callgraph, CFType
from dataclasses import dataclass
from ara.visualization.trace.tracer_api.tracer import GraphNode, GraphPath, init_fast_trace
from ara.graph.mix import GraphType, ARA_ENTRY_POINT

from .cfg_traversal import Visitor, run_sse, AnalysisContext
from .step import Step
from .option import Option, String, Choice
from .util import is_in_condition, is_usually_taken, is_recursive


from ara.os.os_base import CPU, ExecState, NotOSHandledInterrupts

from graph_tool import GraphView, Vertex
from graph_tool.topology import all_paths
from graph_tool.util import find_vertex
from itertools import chain


@dataclass(kw_only=True)
class SIAContext(AnalysisContext):
    """Analysis Context for SIA´s fake CPU in OSState"""
    callg: Callgraph
    scheduler_on: bool  # Is the global scheduler on

    def copy(self):
        return SIAContext(callg=self.callg,
                          branch=self.branch,
                          loop=self.loop,
                          recursive=self.recursive,
                          usually_taken=self.usually_taken,
                          scheduler_on=self.scheduler_on)


@dataclass
class FakeStateCtx:
    """Context for creating a fake state."""
    cpu_id: int
    branch: bool
    loop: bool
    instance: Vertex


class FlatAnalysis(Step):
    """Flat Analysis"""
    traversal_mode = Option(name="traversal_mode",
                            help="Set the traversal method.",
                            default_value="mixed",
                            ty=Choice("flowsensitive",
                                      "flowinsensitive",
                                      "mixed"))

    def get_single_dependencies(self):
        raise NotImplementedError

    def _get_os_specific_deps(self):
        if self._graph.os is None:
            return ['SysFuncts']
        return self._graph.os.get_special_steps()

    def _is_chained_analysis(self):
        return self.get_name() in {
            x.name
            for x in self._step_manager.get_history()
        }

    def _set_flags(self, analysis_context: SIAContext, abb):
        analysis_context.branch |= is_in_condition(self._graph.cfg, abb)
        analysis_context.loop |= self._graph.cfg.vp.part_of_loop[abb]
        analysis_context.usually_taken = (
                is_usually_taken(self._graph.cfg, abb) or
                (analysis_context.usually_taken and not
                 is_in_condition(self._graph.cfg, abb)))

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

    def _prepare_fake_states(self, instance):
        instances = self._graph.instances
        if instance is not None:
            instance = instances.vertex(instance)
            branch = instances.vp.branch[instance]
            loop = instances.vp.loop[instance]
            cpu_id = instances.vp.obj[instance].cpu_id
            cpu_id = max(cpu_id, 0)
        else:
            branch = False
            loop = False
            cpu_id = 0

        return FakeStateCtx(cpu_id=cpu_id,
                            branch=branch,
                            loop=loop,
                            instance=instance)

    def _fake_state(self, abb, path, init_state, function, ctx):
        cfg = self._graph.cfg
        callg = self._graph.callgraph

        state = init_state.copy()
        state.cpus[ctx.cpu_id] = CPU(
            id=state.cpus[ctx.cpu_id].id,
            irq_on=False,
            control_instance=ctx.instance,
            abb=abb,
            call_path=CallPath(),
            exec_state=ExecState.from_abbtype(cfg.vp.type[abb]),
            analysis_context=SIAContext(
                callg=callg,
                branch=ctx.branch,
                loop=ctx.loop,
                recursive=False,
                usually_taken=False,
                scheduler_on=self._is_chained_analysis()))
        fake_cpu = state.cpus[ctx.cpu_id]
        for edge in path:
            new_abb = cfg.vertex(callg.ep.callsite[edge])
            fake_cpu.call_path.add_call_site(callg, edge)
            self._set_flags(fake_cpu.analysis_context, new_abb)
            if not fake_cpu.analysis_context.recursive:
                fake_cpu.analysis_context.recursive = is_recursive(callg, edge.target())

        self._set_flags(fake_cpu.analysis_context, abb)
        if not fake_cpu.analysis_context.recursive:
            fake_cpu.analysis_context.recursive = is_recursive(callg, function)

        return state

    def _run_flow_sensitive(self, function, path, instance):
        cfg = self._graph.cfg
        callg = self._graph.callgraph

        entry_func = cfg.vertex(callg.vp.function[function])
        entry = cfg.get_entry_abb(entry_func)

        ctx = self._prepare_fake_states(instance)
        state = self._fake_state(entry, path,
                                 self._graph.os.get_initial_state(
                                     cfg, self._graph.instances
                                 ),
                                 function,
                                 ctx)

        categories = set([self._search_category()])

        traversed_syscalls = set()

        class SIAVisitor(Visitor):
            HANDLE_INTERRUPTS = False
            SYSCALL_CATEGORIES = categories
            HANDLE_ANALYSIS_CONTEXT = True

            def get_initial_state(self):
                return state

            def add_state(self, new_state):
                abb = new_state.cpus[ctx.cpu_id].abb
                if cfg.vp.type[abb] == ABBType.syscall:
                    traversed_syscalls.add(abb)
                return True

            def add_transition(self, source, target):
                pass

            def schedule(self, new_state):
                pass

        run_sse(graph=self._graph,
                os=self._graph.os,
                visitor=SIAVisitor(),
                logger=self._log)

        return traversed_syscalls

    def _run_flow_insensitive(self, mixed_mode=False):
        @dataclass
        class SyscallInfo:
            """Helper to handle atomic syscalls."""
            is_atomic: bool
            syscall: Vertex

        cfg = self._graph.cfg
        callg = self._graph.callgraph
        os = self._graph.os
        instances = self._graph.instances

        entry_points = self._get_entry_points()

        if self.trace_algorithm.get():
            init_fast_trace(self)
            sia_entity = self.tracer.get_entity("SIA_entity")

        # actual algorithm
        flow_sensitive = []
        flow_insensitive = []
        syscalls = CFGView(cfg, vfilt=cfg.vp.type.fa == ABBType.syscall)
        for syscall in syscalls.vertices():
            sys_name = cfg.get_syscall_name(syscall)
            m_syscall = os.syscalls[sys_name]
            if self._search_category() not in m_syscall.categories:
                continue

            if mixed_mode and not m_syscall.atomic:
                flow_sensitive.append(SyscallInfo(is_atomic=False,
                                                  syscall=syscall))
            else:
                flow_insensitive.append(SyscallInfo(is_atomic=True,
                                                    syscall=syscall))

        traversed_syscalls = set()
        for syscall_info in chain(flow_sensitive, flow_insensitive):
            if syscall_info.syscall in traversed_syscalls:
                continue

            sys_name = cfg.get_syscall_name(syscall_info.syscall)

            cfg_function = cfg.get_function(syscall_info.syscall)
            function = callg.vertex(cfg.vp.call_graph_link[cfg_function])

            if self.trace_algorithm.get():
                abb = cfg.vertex(syscall_info.syscall)
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
                self._log.debug(f"Handle {sys_name} with entry_point "
                                f"{callg.vp.function_name[entry_point]}")

                non_atomic_call = mixed_mode and not syscall_info.is_atomic
                if not non_atomic_call:
                    fake_state_ctx = self._prepare_fake_states(inst)

                path_to_self = [[]] if entry_point == function else []
                for path in chain(
                        all_paths(rev_cg, function, entry_point, edges=True),
                        path_to_self):

                    if self.trace_algorithm.get():
                        self.tracer.entity_is_looking_at(
                            sia_entity, GraphPath(path, GraphType.CALLGRAPH))

                    abb = cfg.vertex(syscall_info.syscall)

                    if non_atomic_call:
                        traversed_syscalls |= self._run_flow_sensitive(
                                cfg_function,
                                reversed(path),
                                inst
                        )
                        import sys
                        sys.exit(1)

                    state = self._fake_state(abb, reversed(path),
                                             init_state,
                                             function,
                                             fake_state_ctx)
                    os.interpret(self._graph,
                                 state,
                                 0,
                                 categories=self._search_category())

    def run(self):
        if self.traversal_mode.get() == "flowsensitive":
            for entry_func, instance in self._get_entry_points():
                self._run_flow_sensitive(entry_func,
                                         [],
                                         instance)
        elif self.traversal_mode.get() == "flowinsensitive":
            self._run_flow_insensitive()
        else:
            assert self.traversal_mode.get() == "mixed"
            self._run_flow_insensitive(mixed_mode=True)

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
        # there may be entry points missing due to unrecognized interrupts
        try:
            self._graph.os.get_interrupts(self._graph.instances)
        except NotOSHandledInterrupts:
            self._step_manager.chain_step({"name": "ISRSearch"})

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
