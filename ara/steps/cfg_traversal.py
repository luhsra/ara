import graph_tool
import copy
import functools

from ara.graph import ABBType, SyscallCategory, CFGView, CFType
from ara.util import get_null_logger
from ara.os.os_base import OSState, CPU, CrossCoreAction

from collections import defaultdict
from dataclasses import dataclass

from graph_tool.topology import (dominator_tree, label_out_component,
                                 all_paths, all_circuits)


@dataclass
class SSEContext:
    recursive: bool # is this state part of a recursive function
    branch: bool # is this state on a branch (behind an if)
    loop: bool # is this state part of a loop
    usually_taken: bool # is this state coming from a branch, where all other
                        # branches end in an endless loop

    def copy(self):
        return SSEContext(recursive=self.recursive,
                          branch=self.branch,
                          loop=self.loop,
                          usually_taken=self.usually_taken)


class Visitor:
    PREVENT_MULTIPLE_VISITS = True
    SYSCALL_CATEGORIES = (SyscallCategory.every,)
    CONTEXT = SSEContext

    def get_initial_state(self):
        raise NotImplementedError

    def init_execution(self, state):
        raise NotImplementedError

    def is_bad_call_target(self, abb):
        raise NotImplementedError

    def schedule(self, new_states):
        raise NotImplementedError


class _SSERunner:
    def __init__(self, cfg, call_graph, os, logger, visitor):
        self._cfg = cfg
        self._icfg = CFGView(self._cfg, efilt=self._cfg.ep.type.fa == CFType.icf)
        self._lcfg = CFGView(self._cfg, efilt=self._cfg.ep.type.fa == CFType.lcf)
        self._call_graph = call_graph
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
        extern_ut = self._ut_func.get(state.call_path, False)
        return local_ut or (extern_ut and not in_cond)

    def _assign_context(self, state, new_state, abb):
        # check if in a recursive function and mark accordingly
        context = self._visitor.CONTEXT()

        abb = new_state.cpus[0].abb
        call_path = new_state.cpus[0].call_path
        func = self._cfg.get_function(self._cfg.vertex(abb))
        context.recursive = self._call_graph.vp.recursive[
            self._call_graph.vertex(
                self._cfg.vp.call_graph_link[func]
            )
        ]

        new_state.branch = (self._cond_func.get(call_path, False) or
                            self._is_in_condition(abb))
        self._cond_func[new_state.call_path] = new_state.branch

        new_state.usually_taken = self._is_usually_taken(state, abb)
        self._ut_func[new_state.call_path] = new_state.usually_taken

        new_state.loop = (self._loop_func.get(call_path, False) or
                          self._is_in_loop(abb))
        self._loop_func[new_state.call_path] = new_state.loop

        new_state.analysis_context = context

    def _execute(self, state):
        self._visitor.init_execution(state)

        abb = state.cpus[0].abb
        call_path = state.cpus[0].call_path

        # check handling of already visited vertices
        visit_count = self._visited[call_path][abb]
        if visit_count > 0:
            if self._visitor.PREVENT_MULTIPLE_VISITS:
                return
            else:
                raise NotImplementedError #TODO
        self._visited[call_path][abb] +=1

        self._log.debug(f"Handle state {state}")

        # statistics
        call_depth = len(call_path)
        if self._max_call_depth < call_depth:
            self._max_call_depth = call_depth

        # syscall handling
        if self._cfg.vp.type[abb] == ABBType.syscall:
            name = self._cfg.vp.name[abb]
            syscall_name = self._cfg.get_syscall_name(abb)
            self._log.debug(f"Handle syscall: {name} ({syscall_name})")
            try:
                new_states = self._os.interpret(
                    self._graph, abb, state,
                    categories=self._visitor.SYSCALL_CATEGORIES
                )
                return new_states
            except CrossCoreAction as e:
                # end analysis on this path
                return []

        # call handling
        elif self._icfg.vp.type[abb] == ABBType.call:
            func = self._cfg.vp.name[self._cfg.get_function(abb)]
            self._log.debug(f"Handle call: {self._icfg.vp.name[abb]} in {func}")
            handled = False
            new_states = []
            for n in self._icfg.vertex(abb).out_neighbors():
                if self._visitor.is_bad_call_target(n):
                    continue

                new_call_path = self._extend_call_path(state.call_path, abb)

                # prevent recursion
                if new_call_path.is_recursive():
                    self._log.debug(f"Reentry of recursive function. Callpath {new_call_path}")
                    continue

                new_state = state.copy()
                new_state.cpu[0].abb = n
                new_state.cpu[0].call_path = new_call_path

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
        elif (self._icfg.vp.is_exit[abb] and
              self._icfg.vertex(abb).out_degree() > 0):
            self._log.debug(f"Handle exit: {self._icfg.vp.name[abb]}")
            new_state = state.copy()
            callsite = new_state.call_path[-1]
            call = new_state.callgraph.ep.callsite[callsite]
            neighbors = self._lcfg.vertex(call).out_neighbors()
            next_node = next(neighbors)
            func = new_state.cfg.get_function(
                new_state.cfg.vertex(next_node)
            )
            new_state.recursive = new_state.callgraph.vp.recursive[
                new_state.callgraph.vertex(
                    new_state.cfg.vp.call_graph_link[func]
                )
            ]
            new_state.next_abbs = [next_node]
            new_state.call_path.pop_back()
            return [new_state]

        # computation block handling
        # all other paths before should have returned if necessary
        self._log.debug(f"Handle computation: {self._icfg.vp.name[abb]}")
        new_states = []
        for n in self._icfg.vertex(abb).out_neighbors():
            new_state = state.copy()
            new_state.next_abbs = [n]
            new_states.append(new_state)
        return new_states


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
            self._log.debug(f"Round {counter:3d}, "
                            f"Stack with {len(stack)} state(s): "
                            f"{stack}")
            state = stack.pop(0)
            for new_state in self._system_semantic(state):
                self._visitor.add_state(new_state)
                self._visitor.add_transition(state, new_state)

                if new_state not in stack:
                    stack.append(new_state)
            counter += 1

        self._log.info(f"Analysis needed {counter} iterations.")


def run_sse(cfg, call_graph, os, visitor=Visitor(), logger=get_null_logger()):
    # we new a lot of state during the analyiss, so pass the handling to an
    # object that can hold the data
    runner = _SSERunner(cfg=cfg, call_graph=call_graph, os=os, logger=logger,
                        visitor=visitor)
    return runner.run()
