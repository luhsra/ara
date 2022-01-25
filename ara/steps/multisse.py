"""Multicore SSE analysis."""

from .option import Option, String, Bool
from .step import Step
from .printer import mstg_to_dot
from .cfg_traversal import Visitor, run_sse
from ara.graph import MSTGraph, StateType, MSTType, single_check, vertex_types
from ara.util import dominates, pairwise
from ara.os.os_base import ExecState, OSState, CPUList

import os.path
import enum
import math
import graph_tool

from collections import defaultdict
from dataclasses import dataclass, field
from functools import reduce, lru_cache
from graph_tool.topology import label_out_component, dominator_tree, shortest_path
from graph_tool.search import bfs_search, BFSVisitor, StopSearch
from graph_tool import GraphView
from itertools import product, chain, permutations
from typing import List, Dict, Set, Tuple
from copy import deepcopy
from scipy.optimize import linprog

# time counter for performance measures
c_debugging = 0  # in milliseconds

MAX_UPDATES = 2
MAX_STATE_UPDATES = 20
MIN_EMULATION_TIME = 200
MAX_INT64 = 2**63 - 1

sse_counter = 0


class ExecType(enum.IntEnum):
    has_length = 1 << 0
    idle = 1 << 1
    cross_syscall = 1 << 2


@dataclass
class Metastate:
    state: graph_tool.Vertex  # vertex of the state
    entry: graph_tool.Vertex  # vertex of the entry ABB
    new_entry: bool  # is the entry point new
    is_new: bool  # is this Metastate already evaluated
    cross_points: List[int]  # does this Metastate has a new cross_point
    cpu_id: int  # cpu_id of this state

    def __repr__(self):
        return ("Metastate("
                f"state: {int(self.state)}, "
                f"entry: {int(self.entry)}, "
                f"new_entry: {self.new_entry}, "
                f"is_new: {self.is_new}, "
                f"cross_points: {[int(x) for x in self.cross_points]}, "
                f"cpu_id: {self.cpu_id})")


@dataclass(frozen=True)
class Range:
    start: graph_tool.Vertex
    end: graph_tool.Vertex

    def __repr__(self):
        def none_or_int(v):
            if v:
                return int(v)
            return None

        return ("Range("
                f"start: {none_or_int(self.start)}, "
                f"end: {none_or_int(self.end)})")


@dataclass(frozen=True)
class TimeRange:
    up: int
    to: int

    def get_overlap(self, other: "TimeRange"):
        new_up = max(self.up, other.up)
        new_to = min(self.to, other.to)
        if new_to > new_up:
            return TimeRange(up=new_up, to=new_to)
        return None

    def __add__(self, other: "TimeRange"):
        return TimeRange(up=self.up + other.up, to=self.to + other.to)


@dataclass(frozen=True)
class RelativeTime:
    """A TimeRange relative to a specific root node."""
    root: graph_tool.Vertex
    range: TimeRange

    def __repr__(self):
        return ("RelativeTime("
                f"root: {int(self.root)}, "
                f"range: {self.range})")


@dataclass(frozen=True)
class CPRange:
    root: graph_tool.Vertex
    range: Range

    def __repr__(self):
        return ("CPRange(" f"root: {int(self.root)}, " f"range: {self.range})")


@dataclass()
class CrossContext:
    """Gives a context for a specific cross syscall.

    graph  -- the local graph from a specific root of the cross syscall
    cpu_id -- the cpu_id of the cross syscall
    path   -- path from the cross syscall cp up to the root
    cores  -- the affected cores for every element of the path
    """
    graph: graph_tool.Graph
    cpu_id: int
    cross_syscall: graph_tool.Vertex
    path: List[graph_tool.Vertex] = field(default_factory=list, init=False)
    cores: Dict[graph_tool.Vertex, Set[int]] = field(default_factory=dict,
                                                     init=False)

    def append_path_elem(self, v, v_cores):
        assert v not in self.cores
        self.path.append(v)
        self.cores[v] = v_cores

    def get_edges_to(self, cp):
        "Return all edges from the cross core to the cp laying on the path." ""
        edge_path = [FakeEdge(src=self.path[0], tgt=self.cross_syscall)]
        for tgt, src in pairwise(self.path):
            if tgt == cp:
                break
            edge_path.append(self.graph.edge(src, tgt))
        return edge_path

    def __repr__(self):
        return ("CrossContext("
                f"cpu_id: {self.cpu_id}, "
                f"path: {[int(x) for x in self.path]}, "
                f"cores: {dict([(int(x), y) for x, y in self.cores.items()])}")


class Equations:
    def __init__(self):
        self._bounds = {}
        self._equalities = []
        self._v_map = {}
        self._highest = 0
        # from ara.util import get_logger
        # self._log = get_logger("Equations")

    def __repr__(self):
        return ("Equations("
                f"_bounds: {self._bounds}, "
                f"_equalities: {self._equalities}, "
                f"_v_map: {self._v_map}, "
                f"_highest: {self._highest})")

    def __str__(self):
        alphabet = 'abcdefghijklmnopqrstuvwxyz'
        assert self._highest < len(alphabet), "We have no more letters"
        ret = "Equations("
        for var, bound in self._bounds.items():
            ret += f"\n  {bound.up} < {alphabet[var]} < {bound.to}"

        for eq in self._equalities:
            left = ' + '.join(
                [alphabet[idx] for idx, elem in enumerate(eq) if elem == 1])
            right = ' + '.join(
                [alphabet[idx] for idx, elem in enumerate(eq) if elem == -1])

            ret += f"\n  {left} = {right}"
        ret += f"\n  Mapping: {[(str(e), alphabet[idx]) for e, idx in self._v_map.items()]})"
        return ret

    def _get_variable(self, edge, must_exist=False):
        if edge not in self._v_map:
            if must_exist:
                assert False, f"Edge {edge} does not exist."
            self._v_map[edge] = self._highest
            self._highest += 1
            for formula in self._equalities:
                formula.append(0)
        return self._v_map[edge]

    def _solve_for_var(self, var, minimize=True):
        def inf(num):
            return None if num == math.inf else num

        c = (self._highest) * [0]
        c[var] = int(minimize) * 2 - 1
        b_eq = len(self._equalities) * [0]
        bounds = []
        for i in range(self._highest):
            assert i in self._bounds
            time = self._bounds[i]
            bounds.append((inf(time.up), inf(time.to)))
        return linprog(c, A_eq=self._equalities, b_eq=b_eq, bounds=bounds)

    def solvable(self):
        if self._highest == 0:
            return True
        res = self._solve_for_var(0)
        return res.success

    def _has_equation(self, var):
        for equation in self._equalities:
            if equation[var] != 0:
                return True
        return False

    def _get_minimum(self, var):
        """Return the minimum time for a specific var."""
        min_res = self._solve_for_var(var)
        assert min_res.success or min_res.status == 3
        if min_res.status == 3:
            return math.inf
        else:
            return int(min_res.fun + 0.5)

    def _get_maximum(self, var):
        """Return the minimum time for a specific var."""
        max_res = self._solve_for_var(var, minimize=False)
        assert max_res.success or max_res.status == 3
        # add 0.000001 because of floating point imprecision
        if max_res.status == 3:
            return math.inf
        else:
            return int(max_res.fun * -1 + 0.0001)

    def get_interval_for(self, edge):
        """Return the solution interval for a specific edge."""
        var = self._get_variable(edge, must_exist=True)
        if self._has_equation(var):
            return TimeRange(up=self._get_minimum(var),
                             to=self._get_maximum(var))
        return self._bounds[var]

    def add_range(self, edge, time):
        assert isinstance(time, TimeRange)
        var = self._get_variable(edge)
        self._bounds[var] = time

    def add_equality(self, left_edges, right_edges):
        le = set(left_edges)
        re = set(right_edges)
        common = le & re
        formula = (self._highest) * [0]
        for left in (le - common):
            formula[self._get_variable(left, must_exist=True)] = 1
        for right in (re - common):
            formula[self._get_variable(right, must_exist=True)] = -1
        self._equalities.append(formula)

    def copy(self):
        cp = Equations()
        cp._bounds = deepcopy(self._bounds)
        cp._equalities = deepcopy(self._equalities)
        cp._v_map = dict([(e, idx) for e, idx in self._v_map.items()])
        cp._highest = self._highest
        return cp


def set_time(prop, idx, number):
    if number == math.inf:
        number = MAX_INT64
    prop[idx] = number


def get_time(prop, idx):
    number = prop[idx]
    if number == MAX_INT64:
        return math.inf
    return number


@dataclass(frozen=True)
class FakeEdge:
    src: graph_tool.Vertex
    tgt: graph_tool.Vertex

    def source(self):
        return self.src

    def target(self):
        return self.tgt

    def __repr__(self):
        def none_or_int(v):
            if v:
                return int(v)
            return None

        return f"FakeEdge({none_or_int(self.src)}, {none_or_int(self.tgt)})"


@dataclass(frozen=True)
class StateList:
    """List of pairing candidates for a cross syscall together with their
    equation system.
    """
    states: Tuple[graph_tool.Vertex]
    eqs: Equations


@dataclass
class MSTG:
    g: MSTGraph
    # store the affected cores of a cross syscall
    cross_core_map: graph_tool.PropertyMap
    # store the ecec type of a state
    type_map: graph_tool.PropertyMap
    # store which cores are affected by this synchronisation point
    cross_point_map: graph_tool.PropertyMap


class MultiSSE(Step):
    """Run the MultiCore SSE."""

    entry_point = Option(name="entry_point",
                         help="system entry point",
                         ty=String())

    with_times = Option(name="with_times",
                        help="respect ABB times within the pairing process",
                        ty=Bool(),
                        default_value=False)

    def get_single_dependencies(self):
        if self._graph.os is None:
            return ["SysFuncts"]
        deps = self._graph.os.get_special_steps()
        return deps

    def _dump_mstg(self, extra):
        # do not dump anything
        return

        dot_file = self.dump_prefix.get() + f"mstg.{extra}.dot"
        dot_path = os.path.abspath(dot_file)
        os.makedirs(os.path.dirname(dot_path), exist_ok=True)
        dot_graph = mstg_to_dot(self._mstg.g, label=f"MSTG {extra}")
        dot_graph.write(dot_path)
        self._log.info(f"Write MSTG to {dot_path}.")

    def _get_initial_state(self):
        os_state = self._graph.os.get_initial_state(self._graph.cfg,
                                                    self._graph.instances)

        # initial cross_point
        mstg = self._mstg.g
        cp = mstg.add_vertex()
        mstg.vp.type[cp] = StateType.exit_sync
        mstg.vp.state[cp] = os_state
        self._mstg.cross_point_map[cp] = [x.id for x in os_state.cpus]
        self._log.debug(f"Add initial cross point {int(cp)}")

        return cp

    def _get_single_core_states(self, multi_core_state):
        single_core_states = {}
        for cpu in multi_core_state.cpus:
            # restrict state to this cpu
            state = multi_core_state.copy()
            state.cpus = CPUList([cpu])
            state.context = self._graph.os.get_cpu_local_contexts(
                multi_core_state.context, cpu.id, state.instances)
            single_core_states[cpu.id] = state

        return single_core_states

    def _run_sse(self, cpu_id, entry):
        """Run the single core SSE for the given entry.

        Collects all states within a metastate and returns it together with
        the vertex for the init state.
        """
        to_assign_states = set()
        m_state = list()
        cross_points = list()

        def _add_state(state):
            h = hash(state)
            v = self._state_map.get(h, None)
            if v is not None:
                return False, v

            cpu = state.cpus[cpu_id]

            mstg = self._mstg.g
            v = mstg.add_vertex()
            mstg.vp.type[v] = StateType.state
            mstg.vp.state[v] = state
            mstg.vp.cpu_id[v] = cpu_id
            self._log.debug(f"Add State {state.id} (node {int(v)})")

            self._state_map[h] = v

            if cpu.exec_state == ExecState.idle:
                self._mstg.type_map[v] = ExecType.idle
            elif cpu.exec_state & ExecState.with_time:
                self._mstg.type_map[v] = ExecType.has_length

            if cpu.abb is not None:
                mstg.vp.bcet[v] = state.cfg.vp.bcet[cpu.abb]
                mstg.vp.wcet[v] = state.cfg.vp.wcet[cpu.abb]
            else:
                mstg.vp.bcet[v] = 0
                mstg.vp.wcet[v] = 0

            return True, v

        def _get_m_state(v):
            m2s = self._mstg.g.edge_type(MSTType.m2s)
            for n in m2s.vertex(v).in_neighbors():
                return n
            return None

        class SSEVisitor(Visitor):
            PREVENT_MULTIPLE_VISITS = False
            CFG_CONTEXT = None

            @staticmethod
            def get_initial_state():
                return entry

            @staticmethod
            def cross_core_action(state, cpu_ids):
                v = self._state_map[hash(state)]
                self._mstg.cross_core_map[v] = cpu_ids
                self._mstg.type_map[v] = ExecType.cross_syscall
                cross_points.append(v)

            @staticmethod
            def schedule(new_state):
                return self._graph.os.schedule(new_state, [cpu_id])

            @staticmethod
            def add_state(new_state):
                created, v = _add_state(new_state)
                if created:
                    to_assign_states.add(v)
                return created

            @staticmethod
            def add_transition(source, target):
                tgt = self._state_map[hash(target)]
                src = self._state_map[hash(source)]
                mstg = self._mstg.g
                e = mstg.add_edge(src, tgt)
                mstg.ep.type[e] = MSTType.s2s
                mstg.ep.cpu_id[e] = cpu_id
                m_state_cand = _get_m_state(tgt)
                if m_state_cand is None:
                    return
                target = mstg.vp.state[tgt]
                self._log.debug(
                    "Found a transition to an already existing metastate. "
                    f"(State {source.id} (node {int(src)}) -> "
                    f"State {target.id} (node {int(tgt)})")
                if m_state and m_state[0] == m_state_cand:
                    return
                assert (len(m_state) == 0
                        ), "Multiple transitions to multiple metastates found."
                m_state.append(m_state_cand)

            @staticmethod
            def next_step(counter):
                pass

        # add initial state
        is_new, init_v = _add_state(entry)

        # early return if state already evaluated
        if not is_new:
            metastate = self._mstg.g.get_metastate(init_v)
            return Metastate(
                state=metastate,
                cpu_id=cpu_id,
                cross_points=cross_points,
                entry=init_v,
                new_entry=False,
                is_new=False,
            )

        to_assign_states.add(init_v)

        run_sse(
            self._graph,
            self._graph.os,
            visitor=SSEVisitor(),
            # logger=self._log,
        )

        mstg = self._mstg.g

        # create the metastate
        if len(m_state) == 0:
            is_new = True
            m_state = mstg.add_vertex()
            mstg.vp.type[m_state] = StateType.metastate
            mstg.vp.cpu_id[m_state] = cpu_id
            self._log.debug(f"Add metastate {int(m_state)}")
        else:
            is_new = False
            m_state = m_state[0]
            cross_points = self._find_cross_states(m_state, init_v)

        for state in to_assign_states:
            e = mstg.add_edge(m_state, state)
            mstg.ep.type[e] = MSTType.m2s
            mstg.ep.cpu_id[e] = cpu_id

        if self.dump.get():
            self._dump_mstg(extra=f"metastate.{int(m_state)}")

        return Metastate(
            state=m_state,
            cross_points=cross_points,
            cpu_id=cpu_id,
            entry=init_v,
            new_entry=True,
            is_new=is_new,
        )

    def _find_cross_states(self, state, entry):
        """Return all syscalls that possibly affect other cores."""
        mstg = self._mstg.g
        filt_mstg = GraphView(
            mstg,
            vfilt=((mstg.vp.type.fa == StateType.metastate) +
                   (self._mstg.type_map.fa == ExecType.cross_syscall)),
        )
        s2s = GraphView(mstg, mstg.vp.type.fa == StateType.state)

        oc = label_out_component(s2s, s2s.vertex(entry))
        oc[state] = True
        filt = GraphView(filt_mstg, vfilt=oc)

        return list(filt.vertex(state).out_neighbors())

    def _find_root_cross_points(self, cp, needed_cores, sync_graph):
        # find last sync state that contains all needed cores
        root_cps = []
        stack = [sync_graph.vertex(cp)]
        visited = sync_graph.new_vp("bool")
        while stack:
            cur_cp = stack.pop()
            if visited[cur_cp]:
                continue
            visited[cur_cp] = True

            cores = set(self._mstg.cross_point_map[cur_cp])
            if cores >= needed_cores:
                root_cps.append(cur_cp)
                continue

            for n in cur_cp.in_neighbors():
                stack.append(n)
        return root_cps

    def _is_successor_of(self, orig_cp, new_cp):
        """Is new_cp a successor of orig_cp?"""
        sync_graph = self._mstg.g.edge_type(MSTType.follow_sync, MSTType.en2ex)
        _, elist = shortest_path(sync_graph, orig_cp, new_cp)
        return len(elist) > 0

    def _iterate_search_tree(self, ctx, core, cps, eqs, paths):
        def log(msg, skip=True):
            if skip:
                return
            self._log.debug("i_s_t: " + msg)

        cp = cps[core]
        mstg = self._mstg.g
        sync_graph = mstg.edge_type(MSTType.m2sy, MSTType.en2ex)
        follow_sync = mstg.edge_type(MSTType.follow_sync)

        def good_edge(e):
            if mstg.ep.type[e] == MSTType.m2sy:
                return mstg.ep.cpu_id[e] == core
            return True

        core_graph = GraphView(sync_graph, efilt=good_edge)

        paths = set([(x.source(), x) for x in chain(*paths)])

        start = core_graph.vertex(cp.range.start)
        stack = [(start, [FakeEdge(src=None, tgt=start)])]
        visited = core_graph.new_vp("bool")
        visited_entries = defaultdict(list)
        log(f"CPs: {cps}")
        log(f"Looking at CPU {int(core)} (orig CPU {int(ctx.cpu_id)})")
        while stack:
            cur, path = stack.pop(0)
            log(f"Stack element {int(cur)} with path {path}")

            if visited[cur] and path[-1] in visited_entries[cur]:
                log("Already visited, skipping...")
                continue
            visited[cur] = True
            visited_entries[cur].append(path[-1])

            # iterate
            edges = []
            for e in cur.out_edges():
                log(f"Look at {e} (Type "
                    f"{str(MSTType(self._mstg.g.ep.type[e]))}).")
                tgt = e.target()

                # skip paths where the sync points do not follow each other
                if core_graph.vp.type[cur] == StateType.metastate:
                    last_exit_cp = path[-1].target()
                    nes = set(follow_sync.vertex(last_exit_cp).out_neighbors())
                    if e.target() not in nes:
                        log(f"Skip {e}. CPs do not follow each other.")
                        continue

                # skip false paths
                if tgt == cp.range.end:
                    log(f"Skip {e}. We are not branching to ourself.")
                    continue
                if core_graph.vp.type[tgt] == StateType.entry_sync:
                    cores = set(self._mstg.cross_point_map[tgt])
                    if ctx.cpu_id in cores:
                        log(f"Skip {e}. It contains core {ctx.cpu_id}.")
                        continue
                    if cores & set(ctx.cores[cp.root]):
                        # if new cross point (tgt) share some cores with the
                        # root cross point for this path
                        if not all([
                                self._is_successor_of(cps[c].root, tgt)
                                for c in cores if c in cps
                        ]):
                            log(f"Skip {e}. No successor.")
                            continue

                # skip false edges of common paths of previous traversals
                if cur in paths and paths[cur] != e:
                    log(f"Skip {e}. Other graph.")
                    continue

                if core_graph.vp.type[cur] == StateType.metastate:
                    edges.append(e)
                    if self.with_times.get():
                        # e must have a follow_sync edge path to the last SP
                        ff_edges = self._get_fs_path(ctx.graph,
                                                     path[-1].target(),
                                                     e.target())
                        self._add_ranges(eqs, ff_edges)

                if core_graph.ep.type[e] == MSTType.en2ex:
                    stack.append((tgt, path + [e]))
                else:
                    stack.append((tgt, path))

            if (len(edges) == 0
                    and core_graph.vp.type[cur] == StateType.metastate):
                edges.append(FakeEdge(src=cur, tgt=None))

            # propagate back
            for edge in edges:
                log(f"Yielding {edge}.")
                yield edge, path

    def _get_used(self, graph, starts, paths):
        cp_map = self._mstg.cross_point_map
        all_used = {}
        for core, start in starts.items():
            # skip first node
            cur_cp = paths[start]
            used = set()
            while cur_cp != -1:
                used |= set(cp_map[cur_cp])
                cur_cp = paths[cur_cp]
            all_used[core] = used
        return all_used

    def _has_path(self, graph, start, end):
        _, elist = shortest_path(graph, start, end)
        return len(elist) > 0

    def _check_barriers(self, graph, new_barriers, old_barriers):
        for cpu, new in new_barriers.items():
            old = old_barriers[cpu]
            if old is not None:
                if self._has_path(graph, old, new):
                    new_barriers[cpu] = old

    def _get_constrained_cps(self, g, cores, new_range, old_cps=None):

        if old_cps is None:
            old_cps = defaultdict(
                lambda: CPRange(root=None, range=Range(start=None, end=None)))

        unbound = {*cores}
        new_starts = {}
        new_ends = defaultdict(lambda: None)

        class Constraints(BFSVisitor):
            def __init__(self, cp_map, cp_list, paths=None):
                self.cp_map = cp_map
                self.cp_list = cp_list
                self.paths = paths

            def discover_vertex(self, u):
                if len(unbound) == 0:
                    raise StopSearch
                u_cores = set(self.cp_map[u]) & unbound
                for core in u_cores:
                    self.cp_list[core] = u
                    unbound.remove(core)

            def tree_edge(self, e):
                if self.paths is not None:
                    self.paths[e.target()] = int(e.source())

        cp_map = self._mstg.cross_point_map

        rsync = GraphView(g, reversed=True)
        paths = rsync.new_vertex_property('int64_t', val=-1)
        bfs_search(rsync,
                   source=new_range.start,
                   visitor=Constraints(cp_map, new_starts, paths=paths))
        used = self._get_used(g, new_starts, paths)

        self._check_barriers(
            rsync, new_starts,
            dict([(x, old_cps[x].range.start) for x in cores]))

        if new_range.end:
            bfs_search(g,
                       source=new_range.end,
                       visitor=Constraints(cp_map, new_ends))

            self._check_barriers(
                g, new_ends, dict([(x, old_cps[x].range.end) for x in cores]))

        return dict([(x,
                      CPRange(root=old_cps[x].root,
                              range=Range(start=new_starts[x],
                                          end=new_ends[x])))
                     for x in cores]), used

    def _get_reachable_states(self, entry_state, exit_state=None):
        mstg = self._mstg.g
        s2s = mstg.edge_type(MSTType.s2s)

        outs = label_out_component(s2s, s2s.vertex(entry_state))
        outs[entry_state] = True

        if exit_state:
            rs2s = GraphView(s2s, reversed=True)
            ins = label_out_component(rs2s, rs2s.vertex(exit_state))
            ins[exit_state] = True
            outs.fa &= ins.fa

        return GraphView(s2s, vfilt=outs)

    def _get_path(self, graph, from_cp, to_cp):
        return shortest_path(graph, from_cp, to_cp)

    def _f_f_sync(self, iterable):
        return list(
            filter(
                lambda e: isinstance(e, FakeEdge) or self._mstg.g.ep.type[e] ==
                MSTType.follow_sync, iterable))

    def _get_fs_path(self, graph, from_cp, to_cp):
        """Return the path of follow_sync edges from from_cp to to_cp."""
        return self._f_f_sync(self._get_path(graph, from_cp, to_cp)[1])

    def _get_timed_states(self, ctx, cpu_id, root, entry_cp, exit_cp, eqs):
        mstg = self._mstg.g

        entry = mstg.get_entry_state(entry_cp, cpu_id)

        if exit_cp:
            exit_s = mstg.get_exit_state(exit_cp, cpu_id)
        else:
            exit_s = None

        reachable = self._get_reachable_states(entry, exit_state=exit_s)

        r1 = vertex_types(reachable, self._mstg.type_map, ExecType.has_length,
                          ExecType.idle)

        good_v = []
        for v in r1.vertices():
            new_eqs = eqs.copy()
            if not self.with_times.get():
                good_v.append((v, new_eqs))
                continue
            state_time = self._get_relative_time(entry_cp, cpu_id, v)
            e = FakeEdge(src=entry_cp, tgt=v)
            new_eqs.add_range(e, state_time)
            root_edges = self._f_f_sync(ctx.get_edges_to(root))
            cur_edges = self._get_fs_path(ctx.graph, root, entry_cp) + [e]
            # self._log.debug(f"GTS: V: {int(v)} Edges: "
            #                 f"{[str(e) for e in root_edges]}"
            #                 f"{[str(e) for e in cur_edges]}")
            new_eqs.add_equality(root_edges, cur_edges)
            # self._log.debug(f"GTS: EQs: {new_eqs}")
            if new_eqs.solvable():
                good_v.append((v, new_eqs))
        return good_v

    def _build_product(self, ctx, cps, eqs, cores, paths):
        """Find all combinations that are valid pairing points for the current
        cross syscall.

        Arguments:
        ctx       -- CrossContext for the cross syscall
        cps       -- dict of CPRange objects
        eqs       -- Timing Equations

        cores     -- the cores that need to be processed
        paths     -- previous decisions which cross points are taken
        """
        assert len(cores) >= 1, "False usage of _build_product."
        core = cores[0]
        root = cps[core].root

        result = set()

        # self._log.debug(f"b_p: Cores: {cores}, CPs: {cps}")

        for exit_edge, path in self._iterate_search_tree(
                ctx, core, cps, eqs, paths):
            cp_from = path[-1].target()
            cp_to = exit_edge.target()
            # self._log.debug(f"Examine metastate from SP {cp_from} to SP {cp_to} (CPU {core}).")
            states = self._get_timed_states(ctx, core, root, cp_from, cp_to,
                                            eqs)
            # self._log.debug(f"Leads to timed states: {[int(x[0]) for x in states]}.")
            for state, new_eqs in states:
                if len(cores) > 1:
                    new_cores = cores[1:]
                    new_cps, _ = self._get_constrained_cps(ctx.graph,
                                                           new_cores,
                                                           Range(start=cp_from,
                                                                 end=cp_to),
                                                           old_cps=cps)
                    others = self._build_product(ctx, new_cps, new_eqs,
                                                 new_cores, paths + [path])
                else:
                    others = {StateList(states=tuple(), eqs=new_eqs)}

                result |= set([
                    StateList(states=(x[0], *x[1].states), eqs=x[1].eqs)
                    for x in product([(state, cp_from)], others)
                ])
        # for res in result:
        #     self._log.warn([(int(x), int(y)) for x, y in res.states])
        # list of lists of pairs of computation state + entry_cp
        return result

    @lru_cache(maxsize=8)
    def _find_timed_predecessor(self, graph, cps):
        # Iterate all pairs and look if there is a path between the pair
        # elements. If so, remove all nodes except of the last one.
        predecessors = set(cps)
        src_blacklist = set()
        pair_blacklist = set()
        for src, tgt in permutations(reversed(list(cps)), 2):
            if src in src_blacklist:
                continue
            if (src, tgt) in pair_blacklist:
                continue

            vlist, _ = shortest_path(graph, src, tgt)
            for elem in vlist[:-1]:
                src_blacklist.add(elem)
                pair_blacklist.add((tgt, src))
                if elem in predecessors:
                    predecessors.remove(elem)

        assert len(predecessors) > 0
        return frozenset(predecessors)

    def _get_pred_times(self, cps, state_list, cp, cross_state):
        """Assign a new follow up time for all nodes in cp_list.

        Arguments:
        cps         -- predecessors in time of the to be create cps
        state_list  -- a StateList of all pairing candidates
        cp          -- the predecessor cp of cross_state
        cross_state -- the cross_state

        """
        loose_ends = {int(cp): int(cross_state)}
        # Assign the last state that belongs to each SP
        for state, entry in state_list.states:
            loose_ends[int(entry)] = int(state)
        timed_cps = []
        # find a new time for all cps
        for ocp in cps:
            time = state_list.eqs.get_interval_for(
                FakeEdge(src=ocp, tgt=loose_ends[int(ocp)]))
            timed_cps.append((ocp, time))
        return frozenset(timed_cps)

    def _gen_context(self, graph, cross_syscall, cpu_id, cp, root):
        vlist, _ = shortest_path(GraphView(graph, reversed=True), cp, root)
        if not vlist:
            vlist.append(cp)
        ctx = CrossContext(graph=graph,
                           cpu_id=cpu_id,
                           cross_syscall=cross_syscall)
        core_map = self._mstg.cross_point_map
        for v in vlist:
            ctx.append_path_elem(v, core_map[v])
        return ctx

    def _is_follow_cp(self, ctx, cp):
        """Check, if cp is a valid follow up cp of the cps specified by ctx."""
        cores = self._mstg.cross_point_map[cp]
        core_map = {}
        for p in reversed(ctx.path):
            nc = dict([(c, p) for c in ctx.cores[p]])
            core_map.update(nc)
        return all([
            self._has_path(ctx.graph, core_map[core], cp)
            and core is not ctx.cpu_id for core in cores
        ])

    def _is_evaluated(self, state):
        """Check, if a state is already evaluated."""
        st2sy = self._mstg.g.edge_type(MSTType.st2sy)
        return st2sy.vertex(state).out_degree() > 0

    def _has_prior_syscalls(self, ctx, cross_bcet):
        cpm = self._mstg.cross_point_map
        mstg = self._mstg.g
        cp_type = mstg.vp.type

        handled_cores = set()
        to_handle_cps = set()
        for cp in ctx.path:
            cores = set(cpm[cp])
            if cores in handled_cores:
                continue

            stack = [(cp, ())]

            while stack:
                cur_cp, path = stack.pop()
                is_entry_sync = (cp_type[cur_cp] == StateType.entry_sync)
                if is_entry_sync:
                    handled_cores |= set(cpm[cur_cp])
                elif mstg.vertex(cur_cp).out_degree() > 0:
                    to_handle_cps.add((cur_cp, path, cp))

                for e in ctx.graph.vertex(cur_cp).out_edges():
                    if is_entry_sync:
                        stack.append((e.target(), path))
                        continue
                    if not self._is_follow_cp(ctx, e.target()):
                        continue
                    stack.append((e.target(), path + (e, )))

        for cp, path, root in to_handle_cps:
            self._log.debug(f"Search cross syscalls of SP {int(cp)} for prior "
                            f"syscalls than {int(ctx.cross_syscall)}")
            cores = set(cpm[cp])
            for cpu_id in (cores - {ctx.cpu_id}):
                metastate = mstg.get_out_metastate(cp, cpu_id)
                entry = mstg.get_entry_state(cp, cpu_id)
                cross_states = self._find_cross_states(metastate, entry)
                for cross_state in filter(lambda x: not self._is_evaluated(x),
                                          cross_states):
                    self._log.debug(f"Check if {int(cross_state)} is prior to "
                                    f"{int(ctx.cross_syscall)}")
                    wcet = 0
                    for e in path:
                        wcet += get_time(mstg.ep.wcet, e)
                    wcet += self._get_relative_time(cp, cpu_id, cross_state).to
                    bcet = cross_bcet
                    for e in self._f_f_sync(ctx.get_edges_to(root)):
                        if isinstance(e, FakeEdge):
                            continue
                        bcet += get_time(mstg.ep.bcet, e)
                    if wcet < bcet:
                        return True
        return False

    def _add_ranges(self, eqs, edges):
        """Add a range to eqs for every edge in edges."""
        bcet = self._mstg.g.ep.bcet
        wcet = self._mstg.g.ep.wcet
        for e in edges:
            eqs.add_range(
                e, TimeRange(up=get_time(bcet, e), to=get_time(wcet, e)))

    def _find_timed_states(self, cross_state, cp, time, start_from=None):
        """Find all possible combinations of computation blocks that fit to
        the cross_state.
        """
        mstg = self._mstg.g
        affected_cores = self._mstg.cross_core_map[cross_state]
        current_core = mstg.vp.cpu_id[cross_state]
        needed_cores = {current_core} | set(affected_cores)

        sync_graph = GraphView(self._mstg.g.vertex_type(
            StateType.entry_sync, StateType.exit_sync),
                               efilt=self._mstg.g.ep.type.fa != MSTType.sy2sy)

        root_cps = self._find_root_cross_points(cp, needed_cores, sync_graph)

        self._log.debug(f"Find pairing candidates for node {int(cross_state)} "
                        f"(time: {time}) starting "
                        f"from cross points {[int(x) for x in root_cps]}.")
        combinations = set()
        for root in root_cps:
            reach = label_out_component(sync_graph, sync_graph.vertex(root))
            reach[root] = True
            r_graph = GraphView(sync_graph, vfilt=reach)
            self._log.debug(f"Evaluating first root cross point {int(root)}.")
            # find initial cross points for all needed cores
            # TODO is this a unique point per core?
            cps, used_cores = self._get_constrained_cps(
                r_graph, affected_cores, Range(start=cp, end=None))
            for cpu, cp_range in cps.items():
                cps[cpu] = CPRange(root=cp_range.range.start,
                                   range=cp_range.range)
            if start_from is not None:
                cps, _ = self._get_constrained_cps(r_graph,
                                                   affected_cores,
                                                   Range(start=start_from,
                                                         end=None),
                                                   old_cps=cps)
            self._log.debug(f"Starting from cross points {cps}.")
            rtime = RelativeTime(root=cp, range=time)

            ctx = self._gen_context(r_graph, cross_state, current_core, cp,
                                    root)
            eqs = Equations()
            if self.with_times.get():
                self._log.debug("Check for prior syscalls.")
                if self._has_prior_syscalls(ctx, rtime.range.up):
                    self._log.debug(f"Skip evaluations of {int(cross_state)} "
                                    f"from root {int(root)}. There are prior "
                                    "not evaluated syscalls that may affect "
                                    "this one.")
                    return set()

                # add path the root
                edges = self._get_fs_path(r_graph, root, cp)
                self._add_ranges(eqs, edges)

                eqs.add_range(FakeEdge(src=cp, tgt=cross_state), rtime.range)

                if start_from is not None:
                    edges = self._get_fs_path(r_graph, root, start_from)
                    self._add_ranges(eqs, edges)

            for state_list in self._build_product(ctx, cps, eqs,
                                                  affected_cores, []):
                # TODO apply times
                timely_cps = self._find_timed_predecessor(
                    r_graph,
                    frozenset([cp] + [x[1] for x in state_list.states]))
                # self._log.debug(
                #    f"Found time predecessors {[int(x) for x in timely_cps]}.")
                if self.with_times.get():
                    timed_pred_cps = self._get_pred_times(
                        timely_cps, state_list, cp, cross_state)
                else:
                    timed_pred_cps = frozenset([(x, TimeRange(up=0, to=0))
                                                for x in timely_cps])

                combinations.add((tuple([x[0] for x in state_list.states]),
                                  timed_pred_cps, root))
        # for a, b in combinations:
        #     self._log.warn(f"{[int(x) for x in a]} {[int(x) for x in b]}")
        return combinations

    def _create_cross_point(self, cross_state, timed_states, cp, pred_cps):
        mstg = self._mstg.g
        new_cp = mstg.add_vertex()
        mstg.vp.type[new_cp] = StateType.entry_sync
        self._log.debug(
            f"Add new entry cross point {int(new_cp)} between "
            f"{int(cross_state)} and {[int(x) for x in timed_states]}")
        cpu_ids = set()

        syncs = mstg.edge_type(MSTType.sync_neighbor)
        for old_cross in chain([cp], list(syncs.vertex(cp).all_neighbors())):
            self._log.debug(
                f"Add sy2sy edge between {int(old_cross)} and {int(new_cp)}.")
            e = mstg.add_edge(old_cross, new_cp)
            mstg.ep.type[e] = MSTType.sy2sy

        for pred_cp, time in pred_cps:
            self._log.debug(
                f"Add time edge between {int(pred_cp)} and {int(new_cp)}.")
            e = mstg.add_edge(pred_cp, new_cp)
            mstg.ep.type[e] = MSTType.follow_sync
            set_time(mstg.ep.bcet, e, time.up)
            set_time(mstg.ep.wcet, e, time.to)

        for src in chain([cross_state], timed_states):
            e = mstg.add_edge(src, new_cp)
            mstg.ep.type[e] = MSTType.st2sy
            metastate = mstg.get_metastate(src)
            cpu_id = mstg.vp.cpu_id[metastate]
            mstg.ep.cpu_id[e] = cpu_id
            cpu_ids.add(cpu_id)
            m2sy_edge = mstg.add_edge(metastate, new_cp)
            mstg.ep.type[m2sy_edge] = MSTType.m2sy
            mstg.ep.cpu_id[m2sy_edge] = cpu_id

        self._mstg.cross_point_map[new_cp] = cpu_ids

        return new_cp

    def _evaluate_crosspoint(self, cp):
        os = self._graph.os
        mstg = self._mstg.g
        cp = mstg.vertex(cp)

        # create multicore state
        states = []
        old_multi_core_state = None
        for v in cp.in_neighbors():
            obj = mstg.vp.state[v]
            ty = mstg.vp.type[v]
            if ty == StateType.exit_sync:
                old_multi_core_state = obj
            elif ty == StateType.state:
                states.append(obj)

        def _get_cross_cpu_id():
            for e in cp.in_edges():
                if self._mstg.type_map[e.source()] == ExecType.cross_syscall:
                    yield mstg.ep.cpu_id[e]

        cpu_id = single_check(_get_cross_cpu_id())

        cpus = CPUList([single_check(x.cpus) for x in states])

        context = [
            os.get_cpu_local_contexts(x.context,
                                      x.cpus.one().id, x.instances)
            for x in states
        ]
        context.append(
            os.get_global_contexts(old_multi_core_state.context,
                                   old_multi_core_state.instances))

        multi_state = OSState(cpus=cpus,
                              instances=states[0].instances,
                              cfg=states[0].cfg)
        multi_state.context = {k: v for d in context for k, v in d.items()}

        # let the model interpret the created multicore state
        new_states = os.interpret(self._graph, multi_state, cpu_id)
        for new_state in new_states:
            os.schedule(new_state)

        # add follow up cross points for the outcome
        ret = []
        for new_state in new_states:
            fcp = mstg.add_vertex()
            mstg.vp.type[fcp] = StateType.exit_sync
            self._log.debug(f"Add exit cross point {int(fcp)}")

            e = mstg.add_edge(cp, fcp)
            mstg.ep.type[e] = MSTType.en2ex
            self._mstg.cross_point_map[fcp] = self._mstg.cross_point_map[cp]

            # store state in cross_point
            mstg.vp.state[fcp] = new_state

            ret.append(fcp)

        return ret

    def _find_common_crosspoints(self, metastates):
        st2sy = self._mstg.g.edge_type(MSTType.st2sy)
        cps_lists = [
            set(st2sy.vertex(x.entry).in_neighbors())
            for x in metastates.values()
        ]
        return reduce(lambda a, b: a & b, cps_lists)

    def _link_neighbor_crosspoint(self, common_cp, cp):
        mstg = self._mstg.g

        # mark as neighbor
        e = mstg.edge(common_cp, cp, add_missing=True)
        mstg.ep.type[e] = MSTType.sync_neighbor

        # sync edges
        sy2sy = mstg.edge_type(MSTType.sy2sy)
        for v in list(sy2sy.vertex(common_cp).out_neighbors()):
            self._log.debug(
                f"Neighbor: Link sy2sy edge: {int(cp)} -> {int(v)}")
            new_e = sy2sy.edge(mstg.vertex(cp),
                               mstg.vertex(v),
                               add_missing=True)
            mstg.ep.type[new_e] = MSTType.sy2sy
        follow_sync = mstg.edge_type(MSTType.follow_sync)
        for v in list(follow_sync.vertex(common_cp).out_neighbors()):
            self._log.debug(
                f"Neighbor: Link follow_sync edge: {int(cp)} -> {int(v)}")
            new_e = follow_sync.edge(mstg.vertex(cp),
                                     mstg.vertex(v),
                                     add_missing=True)
            mstg.ep.type[new_e] = MSTType.follow_sync

    def _get_existing_cross_point(self, cross_state, timed_candidates):
        st2sy = self._mstg.g.edge_type(MSTType.st2sy)
        cps_lists = [
            set(st2sy.vertex(x).out_neighbors())
            for x in chain([cross_state], timed_candidates)
        ]
        cps = reduce(lambda a, b: a & b, cps_lists)
        if len(cps) == 0:
            return None
        else:
            return single_check(cps)

    def _get_previous_execution_time(self, cp, cpu_id, entry):
        """Calculate the previous execution time of an entry node."""
        mstg = self._mstg.g
        g1 = mstg.edge_type(MSTType.st2sy, MSTType.s2s, MSTType.en2ex)
        follow_sync = mstg.edge_type(MSTType.follow_sync)

        def good_edge(e):
            if mstg.ep.type[e] == MSTType.st2sy:
                return mstg.ep.cpu_id[e] == cpu_id
            return True

        core_graph = GraphView(g1, efilt=good_edge,
                               vfilt=self._mstg.type_map.fa != ExecType.idle)

        exec_time = TimeRange(up=0, to=0)
        exit_cp = cp
        entry_state = entry

        default = TimeRange(up=0, to=mstg.vp.wcet[entry])

        v_filter = core_graph.new_vp("bool", val=True)

        while True:
            g = GraphView(core_graph, vfilt=v_filter)
            _, elist = shortest_path(g, entry_state, exit_cp)

            if len(elist) > 2:
                # the state was somewhere blocked and is now resumed
                # currently not supported
                self._log.warn("Found an previously resumed state that is "
                               "continued. This is not supported.")
                return default

            if mstg.vertex(exit_cp).in_degree() == 0:
                # starting point, there were no previous executions
                break
            entry_cp = mstg.get_entry_cp(exit_cp)
            if len(elist) < 2:
                # the state was not executed before
                # maybe the ABB was executed before
                ecp = core_graph.vertex(entry_cp)
                if ecp.in_degree() == 0:
                    # probably coming from idle this state is new
                    break
                last_state = single_check(ecp.in_neighbors())
                assert mstg.vp.type[last_state] == StateType.state
                current_abb = mstg.vp.state[entry_state].cpus.one().abb
                old_abb = mstg.vp.state[last_state].cpus.one().abb

                if current_abb != old_abb:
                    break

                # we have the same executing ABBs
                # just handle the state as interrupted one
                interrupted_state = last_state
            else:
                interrupted_state = entry_state

            common_cps = set(interrupted_state.in_neighbors()) & set(
                follow_sync.vertex(entry_cp).in_neighbors())

            if len(common_cps) != 1:
                self._log.warn("Found a state with none or multiple common "
                               "CPs. This is not supported.")
                return default

            common_cp = single_check(common_cps)
            follow_edge = follow_sync.edge(common_cp, entry_cp)
            self._log.debug("State was executed before. Subtracting "
                            f"{follow_edge}")
            exec_time += TimeRange(up=get_time(mstg.ep.bcet, follow_edge),
                                   to=get_time(mstg.ep.wcet, follow_edge))

            v_filter[exit_cp] = False
            exit_cp = common_cp

        return exec_time

    def _get_relative_time(self, cp, cpu_id, state):
        """Return the execution time of state relative to cp."""
        mstg = self._mstg.g
        entry = mstg.get_entry_state(cp, cpu_id)
        g = self._get_reachable_states(entry, state)
        p_ins = mstg.vertex_type(StateType.exit_sync, StateType.state)
        type_map = self._mstg.type_map

        dom_tree = dominator_tree(g, g.vertex(entry))

        t_from = g.new_vp("int64_t", val=-1)
        t_to = g.new_vp("int64_t", val=-1)

        entry_bcet = 0

        # entry time
        t_from[entry] = 0
        if type_map[entry] == ExecType.idle:
            set_time(t_to, entry, math.inf)
        elif p_ins.vertex(entry).in_degree() == 1:
            # the state was maybe already executed previously
            # find out how long
            time = self._get_previous_execution_time(cp, cpu_id, entry)
            entry_bcet = mstg.vp.bcet[entry] - time.to
            set_time(t_to, entry, mstg.vp.wcet[entry] - time.up)

        def get_bcet(node):
            if type_map[node] == ExecType.idle:
                return 0
            if node == entry:
                return entry_bcet
            return g.vp.bcet[node]

        def get_wcet(node):
            if type_map[node] == ExecType.idle:
                return math.inf
            return g.vp.wcet[node]

        stack = list(g.vertex(entry).out_neighbors())

        while stack:
            cur = stack.pop(0)
            degree = cur.in_degree()
            if degree == 1:
                pred = single_check(cur.in_neighbors())
                set_time(t_from, cur, get_time(t_from, pred) + get_bcet(pred))
                set_time(t_to, cur, get_time(t_to, pred) + get_wcet(cur))
            elif degree >= 2:
                if any(
                    [dominates(dom_tree, cur, x) for x in cur.in_neighbors()]):
                    # we have a loop, find out_neighbor which belongs to loop
                    self._fail(
                        "Loops are unsupported currently. Please roll them out."
                    )
                else:
                    # we need to wait, until all predecessors have a time
                    tos = [get_time(t_to, x) for x in cur.in_neighbors()]
                    if any([x == -1 for x in tos]):
                        # skip cur, it will be added anyway
                        continue
                    froms = [
                        get_time(t_from, x) + get_bcet(x)
                        for x in cur.in_neighbors()
                    ]
                    set_time(t_from, cur, min(froms))
                    set_time(t_to, cur, max(tos) + get_wcet(cur))

            for nex in cur.out_neighbors():
                stack.append(nex)

        return TimeRange(up=get_time(t_from, state), to=get_time(t_to, state))

    def _do_full_pairing(self, cp, metastate, start_from=None):
        exits = []
        reeval = set()

        if not metastate.is_new:
            metastate.cross_points = self._find_cross_states(
                metastate.state, metastate.entry)

        self._log.debug("Search for candidates for the cross syscalls: "
                        f"{[int(x) for x in metastate.cross_points]} "
                        f"(starting cross point {int(cp)}).")
        for cross_state in metastate.cross_points:
            if self.with_times.get():
                time = self._get_relative_time(cp, metastate.cpu_id,
                                               cross_state)
            else:
                time = TimeRange(up=0, to=0)
            for timed_candidates, pred_cps, root in self._find_timed_states(
                    cross_state, cp, time, start_from=start_from):
                self._log.debug(
                    f"Evaluating cross point between {int(cross_state)} and "
                    f"{[int(x) for x in timed_candidates]}")
                other_cp = self._get_existing_cross_point(
                    cross_state, timed_candidates)
                modified = False
                if other_cp:
                    mstg = self._mstg.g
                    # just link the new cp to it, if it is new
                    self._log.debug(
                        f"Link from {int(root)} to existing cross point "
                        f"{int(other_cp)} ({int(cross_state)} with "
                        f"{[int(x) for x in timed_candidates]}).")
                    exists = mstg.edge(root, other_cp)
                    if not exists:
                        m2sy_edge = mstg.add_edge(root, other_cp)
                        mstg.ep.type[m2sy_edge] = MSTType.sy2sy
                        modified = True
                    else:
                        self._log.warn("Already exists.")

                    follow_sync = mstg.edge_type(MSTType.follow_sync)
                    for pred_cp, time in pred_cps:
                        self._log.debug(
                            f"Time link from {int(pred_cp)} to existing "
                            f"cross point {int(other_cp)}")
                        exists = follow_sync.edge(pred_cp, other_cp)
                        if not exists:
                            m2sy_edge = mstg.add_edge(pred_cp, other_cp)
                            mstg.ep.type[m2sy_edge] = MSTType.follow_sync
                            set_time(mstg.ep.bcet, m2sy_edge, time.up)
                            set_time(mstg.ep.wcet, m2sy_edge, time.to)
                        else:
                            self._log.warn("Time link already exists.")
                else:
                    other_cp = self._create_cross_point(
                        cross_state, timed_candidates, root, pred_cps)
                    exits += [(x, None)
                              for x in self._evaluate_crosspoint(other_cp)]
                    modified = True

                if modified:
                    current_cpus = set(self._mstg.cross_point_map[cp])
                    other_cpus = set(self._mstg.cross_point_map[other_cp])

                    unready = current_cpus - other_cpus
                    if unready:
                        g = GraphView(
                            self._mstg.g.vertex_type(StateType.entry_sync,
                                                     StateType.exit_sync),
                            efilt=self._mstg.g.ep.type.fa != MSTType.sy2sy)
                        new_cps, _ = self._get_constrained_cps(
                            g, unready, Range(start=other_cp, end=None))
                        on_stack = defaultdict(list)
                        for core, ran in new_cps.items():
                            on_stack[ran.range.start].append(core)
                        for i_cp, cores in on_stack.items():
                            self._log.debug(
                                f"Current cross point {int(other_cp)} may add "
                                "more pairing possibilities to the cross syscall "
                                f"for CPUs {cores} (starting from {int(i_cp)})"
                            )
                            reeval.add((i_cp, (other_cp, frozenset(cores))))
        return exits, reeval

    def run(self):
        entry_label = self.entry_point.get()
        if not entry_label:
            self._fail("Entry point must be given.")
        self._log.info(f"Analyzing entry point: '{entry_label}'")

        # create graph
        mstg = MSTGraph()
        # store the affected other cores of this syscall
        cross_core_map = mstg.new_vp("vector<int32_t>")
        # mark states with a length and witch trigger a cross core action
        type_map = mstg.new_vp("int")
        # cores which are connected with a cross point
        cross_point_map = mstg.new_vp("vector<int32_t>")

        # handled = mstg.new_vp("bool")

        self._state_map = {}

        self._mstg = MSTG(g=mstg,
                          cross_core_map=cross_core_map,
                          type_map=type_map,
                          cross_point_map=cross_point_map)

        # initialize stack
        cross_point = self._get_initial_state()

        # stack consisting of the current exit cross point
        stack = [(cross_point, None)]
        reevaluates = set()

        # actual algorithm
        counter = 0
        while stack:
            cp, reevaluate_ids = stack.pop(0)
            if (cp, reevaluate_ids) in reevaluates:
                self._log.debug(f"Skip {int(cp)}. Is in reevaluates.")
                continue

            # if counter == 8:
            #     self._fail("foo")

            self._log.debug(
                f"Round {counter:3d}, handle cross point {int(cp)}. "
                f"Stack with {len(stack)} state(s)")
            if self.dump.get():
                self._dump_mstg(extra=f"round.{counter:03d}")
            counter += 1

            # if handled[cp]:
            #     continue
            # handled[cp] = True
            if reevaluate_ids:
                new_cp, reevaluate_ids = reevaluate_ids
                self._log.debug(
                    f"Node {int(cp)} is already evaluated but some new know"
                    f"ledge exists. Reevaluating CPUs {list(reevaluate_ids)}.")
                st2sy = mstg.edge_type(MSTType.st2sy)
                for cpu_id in reevaluate_ids:
                    sts = GraphView(st2sy, efilt=st2sy.ep.cpu_id.fa == cpu_id)
                    entry = single_check(sts.vertex(cp).out_neighbors())
                    to_stack, reeval = self._do_full_pairing(
                        cp,
                        Metastate(state=mstg.get_metastate(entry),
                                  entry=entry,
                                  new_entry=False,
                                  is_new=False,
                                  cross_points=[],
                                  cpu_id=cpu_id),
                        start_from=new_cp)
                    stack += to_stack
                    reevaluates |= reeval
                continue

            # handle current cross point
            states = self._get_single_core_states(self._mstg.g.vp.state[cp])

            metastates = {}

            for cpu_id, state in states.items():
                metastate = self._run_sse(cpu_id, state)

                # add m2sy edge
                e = mstg.add_edge(cp, metastate.state)
                mstg.ep.type[e] = MSTType.m2sy
                mstg.ep.cpu_id[e] = metastate.cpu_id

                # add st2sy edge
                e = mstg.add_edge(cp, metastate.entry)
                mstg.ep.type[e] = MSTType.st2sy
                mstg.ep.cpu_id[e] = metastate.cpu_id

                metastates[cpu_id] = metastate

            if self.dump.get():
                self._dump_mstg(extra=f"round.{counter:03d}.wm")

            # handle the next cross points
            for cpu_id, metastate in metastates.items():
                self._log.debug(
                    f"Evaluate cross points of metastate {metastate}.")
                if metastate.new_entry:
                    self._log.debug(
                        "Metastate has a new entry. Do a full pairing.")
                    to_stack, reeval = self._do_full_pairing(cp, metastate)
                    stack += to_stack
                    reevaluates |= reeval
                    continue

                others = set(metastates.keys()) - {cpu_id}
                if any([metastates[x].is_new for x in others]):
                    self._log.debug(
                        "At least one pairing state is new. Do a full pairing."
                    )
                    to_stack, reeval = self._do_full_pairing(cp, metastate)
                    stack += to_stack
                    reevaluates |= reeval
                    continue

                if any([metastates[x].new_entry for x in others]):
                    self._log.debug(
                        "At least one pairing state has a new entry. Do a full pairing."
                    )
                    to_stack, reeval = self._do_full_pairing(cp, metastate)
                    stack += to_stack
                    reevaluates |= reeval
                    continue

                common_cps = self._find_common_crosspoints(metastates) - {cp}
                good_cps = False
                for common_cp in common_cps:
                    if set(self._mstg.cross_point_map[common_cp]) == set(
                            metastates.keys()):
                        good_common_cp = common_cp
                        self._log.debug(
                            f"Metastate is not new. Find an equal common cp {int(good_common_cp)}."
                        )
                        self._link_neighbor_crosspoint(common_cp, cp)
                        good_cps = True

                if good_cps:
                    continue
                else:
                    self._log.debug("No equal common cp.")

                self._log.debug(
                    "Found already existing but unconnected metastates. Do a full pairing."
                )
                to_stack, reeval = self._do_full_pairing(cp, metastate)
                stack += to_stack
                reevaluates |= reeval

            if not stack:
                self._log.debug("Stack empty. Beginning with reevaluations")
                stack = list(set(reevaluates))
                reevaluates = set()

        self._log.info(f"Analysis needed {counter} iterations.")

        self._graph.mstg = mstg

        self._log.debug(
            f"Cache of find_timed_predecessor: {self._find_timed_predecessor.cache_info()}"
        )

        if self.dump.get():
            self._step_manager.chain_step({
                "name": "Printer",
                "dot": self.dump_prefix.get() + "mstg.dot",
                "graph_name": "MSTG",
                "subgraph": "mstg",
            })
            self._step_manager.chain_step({
                "name": "Printer",
                "dot": self.dump_prefix.get() + "mstg.reduced.dot",
                "graph_name": "Reduced MSTG",
                "subgraph": "reduced_mstg",
            })
