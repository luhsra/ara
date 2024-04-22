# SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2022 Domenik Kuhn
# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

import copy

from collections import defaultdict
from collections.abc import Iterable
from dataclasses import dataclass

from ara.graph import SyscallCategory
from ara.util import get_child_logger_or_none
from ara.steps.util import is_recursive, is_in_condition, is_usually_taken
from ara.os.os_base import (
        OSState,
        CrossCoreAction,
        IRQ,
        ExecState,
        InterruptMissing
)


@dataclass(kw_only=True)
class AnalysisContext:
    """capture CFG specific quirks"""
    recursive: bool = False  # is this state part of a recursive function
    branch: bool = False     # is this state on a branch (behind an if)
    loop: bool = False       # is this state part of a loop
    usually_taken: bool = False  # is this state coming from a branch, where
                                 # all other branches end in an endless loop

    def copy(self):
        return AnalysisContext(recursive=self.recursive,
                               branch=self.branch,
                               loop=self.loop,
                               usually_taken=self.usually_taken)


class Visitor:
    PREVENT_MULTIPLE_VISITS = True
    HANDLE_INTERRUPTS = True
    SYSCALL_CATEGORIES = (SyscallCategory.every,)
    HANDLE_ANALYSIS_CONTEXT = False

    def get_initial_state(self):
        raise NotImplementedError

    def init_execution(self, state):
        pass

    def is_bad_call_target(self, abb):
        return False

    def add_state(self, new_state):
        """Handle a newly created state.

        Must return true, if the state is new, false otherwise.
        """
        raise NotImplementedError

    def add_transition(self, source, target):
        raise NotImplementedError

    def schedule(self, new_state):
        """Schedule the new_state.

        Does not return anything.
        """
        raise NotImplementedError

    def cross_core_action(self, state, cpu_ids, irq=None):
        """Handle a cross core action.

        state   -- the state, which triggers the action
        cpu_ids -- the affected CPUs
        irq     -- the number of the irq that triggers the action.
        """
        pass

    def interrupt_missing(self, state, irq_vertex):
        """Handle a missing IRQ.

        state      -- the state, which triggers the action
        irq_vertex -- the affected IRQ in the instance graph
        """
        pass

    def next_step(self, state_id):
        pass


class _SSERunner:
    def __init__(self, graph, os, logger, visitor):
        self._graph = graph
        self._cfg = graph.cfg
        self._icfg = graph.icfg
        self._lcfg = graph.lcfg
        self._call_graph = graph.callgraph
        self._os = os
        self._log = logger
        self._visitor = visitor
        # callpath aware counting of visits of an ABB
        self._visited = defaultdict(lambda: defaultdict(lambda: 0))

        # statistics
        self._max_call_depth = 0

        # analysis flags
        self._cond_func = {}
        self._ut_func = {}
        self._loop_func = {}

    def _fail(self, msg, error=RuntimeError):
        """Print msg to as error and raise error."""
        self._log.error(msg)
        raise error(msg)

    def _extend_call_path(self, call_path, abb):
        """Return a new call path extected with the current abb's callsite."""
        edge = self._call_graph.get_edge_for_callsite(abb)
        if edge is None:
            abb_name = self._cfg.vp.name[abb]
            self._fail(f"Cannot find call path for ABB {abb_name}.")
        new_call_path = copy.copy(call_path)
        new_call_path.add_call_site(self._call_graph, edge)
        return new_call_path

    def _is_usually_taken(self, state, abb):
        in_cond = is_in_condition(self._cfg, abb)
        local_ut = is_usually_taken(self._cfg, abb)
        extern_ut = self._ut_func.get(state.cpus.one().call_path, False)
        return local_ut or (extern_ut and not in_cond)

    def _assign_context(self, state):
        if self._visitor.HANDLE_ANALYSIS_CONTEXT:
            # old_context = old_state.cpus.one().analysis_context
            # context = old_context.copy()
            context = state.cpus.one().analysis_context
            call_path = state.cpus.one().call_path
            abb = state.cpus.one().abb

            # recursive flag
            func = self._cfg.get_function(self._cfg.vertex(abb))
            func_vert = self._call_graph.vertex(
                self._cfg.vp.call_graph_link[func]
            )
            context.recursive = is_recursive(self._call_graph, func_vert)

            # branch
            context.branch = (self._cond_func.get(call_path, False) or
                              is_in_condition(self._cfg, abb))

            # usually_taken
            context.usually_taken = self._is_usually_taken(state, abb)

            # loop
            context.loop = (self._loop_func.get(call_path, False) or
                            self._cfg.vp.part_of_loop[abb])

    def _set_context_caches(self, state, call_path):
        """When is a call, set the caches properly."""
        if self._visitor.HANDLE_ANALYSIS_CONTEXT:
            context = state.cpus.one().analysis_context
            self._cond_func[call_path] = context.branch
            self._loop_func[call_path] = context.loop
            self._ut_func[call_path] = context.usually_taken

    def _get_exec(self, v):
        return ExecState.from_abbtype(self._cfg.vp.type[v])

    def _trigger_irqs(self, state):
        # should we handle interrupts after all?
        if not self._visitor.HANDLE_INTERRUPTS:
            return []

        cpu = state.cpus.one()
        if not cpu.irq_on:
            return []

        irq_states = []
        for _, irq in state.instances.get(IRQ):
            try:
                i_st = self._os.handle_irq(self._graph, state, cpu.id, irq)
                if isinstance(i_st, list):
                    for s in i_st:
                        irq_states.append(s)
                elif i_st is not None:
                    irq_states.append(i_st)
            except CrossCoreAction as cca:
                self._log.error(f"Cross core action for IRQ {irq} (CPUs. "
                                f"{cca.cpu_ids}). This should not happen")
                raise cca
                self._visitor.cross_core_action(state, cca.cpu_ids, irq=irq)
                # end analysis on this path
                return []
        return irq_states

    def _execute(self, state):
        self._visitor.init_execution(state)
        cpu = state.cpus.one()

        abb = cpu.abb
        call_path = cpu.call_path

        # check handling of already visited vertices
        if self._visitor.PREVENT_MULTIPLE_VISITS:
            visit_count = self._visited[call_path][abb]
            if visit_count > 0:
                return []
            self._visited[call_path][abb] += 1

        self._log.debug(f"Handle state {state}")

        # statistics
        call_depth = len(call_path) if call_path else 0
        if self._max_call_depth < call_depth:
            self._max_call_depth = call_depth

        if cpu.exec_state in [ExecState.waiting, ExecState.idle]:
            # Trigger all interrupts. We are _not_ deciding over interarrival
            # times here. This should be done by the operation system model.
            self._log.debug("Handle idle. Trigger all interrupts.")
            return self._trigger_irqs(state)

        elif cpu.exec_state == ExecState.syscall:
            name = self._cfg.vp.name[abb]
            syscall_name = self._cfg.get_syscall_name(abb)
            self._log.debug(f"Handle syscall: {name} ({syscall_name})")
            self._assign_context(state)
            try:
                new_state = self._os.interpret(
                    self._graph, state, cpu.id,
                    categories=self._visitor.SYSCALL_CATEGORIES
                )
                assert isinstance(new_states, Iterable)
                return new_states
            except CrossCoreAction as cca:
                self._log.debug(f"Got cross core action (CPUs: {cca.cpu_ids}).")
                self._visitor.cross_core_action(state, cca.cpu_ids)
                # end analysis on this path
                return []
            except InterruptMissing as inm:
                self._log.debug("Got a missing irq for isr %s",
                                inm.irq_vertex)
                self._visitor.interrupt_missing(state, inm.irq_vertex)
                # end analysis on this path
                return []

        elif cpu.exec_state == ExecState.call:
            func = self._cfg.vp.name[self._cfg.get_function(abb)]
            self._log.debug(f"Handle call: {self._icfg.vp.name[abb]} in {func}")
            handled = False
            new_states = []
            for n in self._icfg.vertex(abb).out_neighbors():
                if self._visitor.is_bad_call_target(n):
                    continue

                new_call_path = self._extend_call_path(call_path, abb)

                # prevent recursion
                if new_call_path.is_recursive():
                    self._log.debug("Reentry of recursive function. "
                                    f"Callpath {new_call_path}")
                    continue

                # context handling
                self._assign_context(state)
                self._set_context_caches(state, new_call_path)

                new_state = state.copy()
                new_state.cpus.one().abb = n
                new_state.cpus.one().call_path = new_call_path
                new_state.cpus.one().exec_state = self._get_exec(n)
                new_states.append(new_state)
                handled = True
            # if only recursive functions are found, handle the call like a
            # normal computation block
            if handled:
                return new_states
            self._log.debug("Found only edges that leads to recursion. "
                            "Handle as computation.")

        # exit handling
        elif self._icfg.vp.is_exit[abb]:
            self._log.debug(f"Handle exit: {self._icfg.vp.name[abb]}")
            if self._icfg.vertex(abb).out_degree() > 0:
                new_state = state.copy()
                callsite = new_state.cpus.one().call_path[-1]
                call = self._call_graph.ep.callsite[callsite]
                neighbors = self._lcfg.vertex(call).out_neighbors()
                next_node = next(neighbors)
                func = new_state.cfg.get_function(
                    new_state.cfg.vertex(next_node)
                )

                func_vert = self._call_graph.vertex(
                    self._cfg.vp.call_graph_link[func]
                )
                new_state.recursive = is_recursive(self._call_graph, func_vert)

                new_state.cpus.one().abb = next_node
                new_state.cpus.one().call_path.pop_back()
                new_state.cpus.one().exec_state = self._get_exec(next_node)
                return [new_state]
            else:
                # The OS must decide what happens at the end
                return self._os.handle_exit(self._graph, state, cpu.id)

        # computation block handling
        # all other paths before should have returned if necessary
        self._log.debug(f"Handle computation: {self._lcfg.vp.name[abb]}")
        new_states = []
        for n in self._lcfg.vertex(abb).out_neighbors():
            self._log.debug(f"Neighbor {self._lcfg.vp.name[n]}")
            new_state = state.copy()
            new_state.cpus.one().abb = self._icfg.vertex(n)
            new_state.cpus.one().exec_state = self._get_exec(n)
            new_states.append(new_state)
        # Trigger all interrupts. We are _not_ deciding over interarrival times
        # here. This should be done by the operation system model.
        new_states += self._trigger_irqs(state)
        self._log.debug("New states with ABBs: %s",
                        ', '.join(self._cfg.vp.name[x.cpus.one().abb] for x in new_states))
        return new_states

    def _system_semantic(self, state: OSState):
        # we can only handle a single core execution here
        assert len(state.cpus) == 1

        new_states = self._execute(state)
        for new_state in new_states:
            self._visitor.schedule(new_state)
        return new_states

    def run(self):
        init_state = self._visitor.get_initial_state()
        self._set_context_caches(init_state, init_state.cpus.one().call_path)
        cpu = init_state.cpus.one()
        stack = [init_state]

        counter = 0
        while stack:
            self._log.debug(f"Local SSE (CPU {cpu.id}): Round {counter:3d}, "
                            f"Stack with {len(stack)} state(s)")
            state = stack.pop(0)
            for new_state in self._system_semantic(state):
                is_new = self._visitor.add_state(new_state)
                self._visitor.add_transition(state, new_state)

                if is_new:
                    stack.append(new_state)

            counter += 1
            self._visitor.next_step(counter)

        self._log.info(f"Local SSE: Analysis needed {counter} iterations.")


def run_sse(graph, os, visitor=Visitor(), logger=None):
    # we new a lot of state during the analyiss, so pass the handling to an
    # object that can hold the data
    logger = get_child_logger_or_none(logger, "cfg_trav")
    runner = _SSERunner(graph=graph, os=os, logger=logger,
                        visitor=visitor)
    return runner.run()
