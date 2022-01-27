import graph_tool
import copy
import functools

from ara.graph import ABBType, SyscallCategory, CFGView, CFType
from ara.util import get_null_logger
from ara.os.os_base import OSState, CrossCoreAction, ExecState

from collections import defaultdict
from dataclasses import dataclass

from graph_tool.topology import (dominator_tree, label_out_component,
                                 all_paths)


@dataclass
class CFGContext:
    """capture CFG specific quirks"""
    recursive: bool = False  # is this state part of a recursive function
    branch: bool = False     # is this state on a branch (behind an if)
    loop: bool = False       # is this state part of a loop
    usually_taken: bool = False  # is this state coming from a branch, where
                                 # all other branches end in an endless loop

    def copy(self):
        return CFGContext(recursive=self.recursive,
                          branch=self.branch,
                          loop=self.loop,
                          usually_taken=self.usually_taken)


class Visitor:
    PREVENT_MULTIPLE_VISITS = True
    SYSCALL_CATEGORIES = (SyscallCategory.every,)
    CFG_CONTEXT = CFGContext  # set to None if analysis should be deactivated

    def get_initial_state(self):
        raise NotImplementedError

    def init_execution(self, state):
        pass

    def is_bad_call_target(self, abb):
        return False

    def add_state(self, new_state):
        raise NotImplementedError

    def add_transition(self, source, target):
        raise NotImplementedError

    def schedule(self, new_states):
        raise NotImplementedError

    def cross_core_action(self, state, cpu_ids):
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

        self._available_irqs = self._os.get_interrupts(graph.instances)

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

    def _has_path(self, graph, source, target):
        ap = all_paths(graph, graph.vertex(source), graph.vertex(target))
        try:
            next(ap)
            return True
        except StopIteration:
            return False

    @functools.lru_cache(maxsize=32)
    def _get_func_cfg(self, func):
        """Get LCFG of function"""
        abb = self._cfg.get_entry_abb(func)
        lcfg = CFGView(self._cfg, efilt=self._cfg.ep.type.fa == CFType.lcf)
        comp = label_out_component(lcfg, lcfg.vertex(abb))
        return CFGView(lcfg, vfilt=comp)

    @functools.lru_cache(maxsize=32)
    def _create_dom_tree(self, func, ignore_endless_loops=False):
        """Create a dominator tree of the local control flow for func."""
        func_cfg = self._get_func_cfg(func)
        entry = self._cfg.get_entry_abb(func)

        # prepare LCFG, endless loops are filtered out and replaces by exit
        # blocks
        exit_map = func_cfg.vp.is_exit.copy(full=False)
        keep_edge_map = func_cfg.new_ep("bool", val=True)

        if not ignore_endless_loops:
            loops = CFGView(func_cfg, vfilt=func_cfg.vp.is_exit_loop_head)
            for v in loops.vertices():
                v = func_cfg.vertex(v)
                for e in v.in_edges():
                    if self._has_path(func_cfg, v, e.source()):
                        keep_edge_map[e] = False
                        exit_map[e.source()] = True

        patched_func_cfg = CFGView(func_cfg, efilt=keep_edge_map)

        # dom tree creation
        dom_tree = dominator_tree(patched_func_cfg,
                                  patched_func_cfg.vertex(entry))
        return dom_tree, CFGView(func_cfg, vfilt=exit_map)

    def _dominates(self, dom_tree, abb_x, abb_y):
        """Does abb_x dominate abb_y?"""
        while abb_y:
            if abb_x == abb_y:
                return True
            abb_y = dom_tree[abb_y]
        return False

    def _is_in_condition(self, abb, ignore_endless_loops=False):
        """Is abb part of a condition?"""
        func = self._graph.cfg.get_function(abb)
        dom_tree, exit_abbs = self._create_dom_tree(func,
                                                    ignore_endless_loops=ignore_endless_loops)
        res = not all([self._dominates(dom_tree, abb, x)
                      for x in exit_abbs.vertices()])
        return res

    def _is_in_loop(self, abb):
        """Is abb part of a loop?"""
        return self._cfg.vp.part_of_loop[abb]

    def _is_usually_taken(self, state, abb):
        in_cond = self._is_in_condition(abb)
        local_ut = (in_cond and not
                    self._is_in_condition(abb, ignore_endless_loops=True))
        extern_ut = self._ut_func.get(state.cpus.one().call_path, False)
        return local_ut or (extern_ut and not in_cond)

    def _assign_context(self, state, new_state, abb):
        context = self._visitor.CFG_CONTEXT
        if context is not None:
            context = context()

            abb = new_state.cpus.one().abb
            call_path = new_state.cpus.one().call_path

            # check if in a recursive function and mark accordingly
            func = self._cfg.get_function(self._cfg.vertex(abb))
            context.recursive = self._call_graph.vp.recursive[
                self._call_graph.vertex(
                    self._cfg.vp.call_graph_link[func]
                )
            ]

            context.branch = (self._cond_func.get(call_path, False) or
                              self._is_in_condition(abb))
            self._cond_func[call_path] = context.branch

            context.usually_taken = self._is_usually_taken(state, abb)
            self._ut_func[call_path] = context.usually_taken

            context.loop = (self._loop_func.get(call_path, False) or
                            self._is_in_loop(abb))
            self._loop_func[call_path] = context.loop

            new_state.analysis_context = context

    def _get_exec(self, v):
        return ExecState.from_abbtype(self._cfg.vp.type[v])

    def _trigger_irqs(self, state):
        cpu = state.cpus.one()
        irq_states = []
        if cpu.irq_on:
            for irq in self._available_irqs:
                new_state = self._os.handle_irq(self._graph, state, cpu.id, irq)
                if new_state is not None:
                    irq_states.append(new_state)
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
            try:
                new_states = self._os.interpret(
                    self._graph, state, cpu.id,
                    categories=self._visitor.SYSCALL_CATEGORIES
                )
                return new_states
            except CrossCoreAction as cca:
                self._log.debug(f"Got cross core action (CPUs: {cca.cpu_ids}).")
                self._visitor.cross_core_action(state, cca.cpu_ids)
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

                new_state = state.copy()
                new_state.cpus.one().abb = n
                new_state.cpus.one().call_path = new_call_path
                new_state.cpus.one().exec_state = self._get_exec(n)

                # SSE specific analysis context
                self._assign_context(state, new_state, abb)
                new_states.append(new_state)
                handled = True
            # if only recursive functions are found, handle the call like a
            # normal computation block
            if handled:
                return new_states
            self.log.debug("Found only edges that leads to recursion. "
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
                new_state.recursive = self._call_graph.vp.recursive[
                    self._call_graph.vertex(
                        new_state.cfg.vp.call_graph_link[func]
                    )
                ]
                new_state.cpus.one().abb = next_node
                new_state.cpus.one().call_path.pop_back()
                new_state.cpus.one().exec_state = self._get_exec(next_node)
                return [new_state]
            else:
                # ISRs are able to exit, all other CFG not
                return self._os.handle_exit(self._graph, state, cpu.id)

        # computation block handling
        # all other paths before should have returned if necessary
        self._log.debug(f"Handle computation: {self._icfg.vp.name[abb]}")
        new_states = []
        for n in self._icfg.vertex(abb).out_neighbors():
            self._log.debug(f"Neighbor {self._icfg.vp.name[n]}")
            new_state = state.copy()
            new_state.cpus.one().abb = n
            new_state.cpus.one().exec_state = self._get_exec(n)
            new_states.append(new_state)
        # Trigger all interrupts. We are _not_ deciding over interarrival times
        # here. This should be done by the operation system model.
        return new_states + self._trigger_irqs(state)

    def _system_semantic(self, state: OSState):
        # we can only handle a single core execution here
        assert(len(state.cpus) == 1)

        new_states = self._execute(state)
        for new_state in new_states:
            self._visitor.schedule(new_state)
        return new_states

    def run(self):
        stack = [self._visitor.get_initial_state()]

        counter = 0
        while stack:
            self._log.debug(f"Local SSE: Round {counter:3d}, "
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
    if logger is None:
        logger = get_null_logger()
    runner = _SSERunner(graph=graph, os=os, logger=logger,
                        visitor=visitor)
    return runner.run()
