"""Multicore SSE analysis."""

from .option import Option, String, Bool
from .step import Step
from .util import open_with_dirs
from .printer import mstg_to_dot, sp_mstg_to_dot
from .cfg_traversal import Visitor, run_sse
from ara.graph import MSTGraph, StateType, MSTType, single_check, vertex_types, edge_types
from ara.util import dominates, pairwise, has_path
from ara.os.os_base import ExecState, OSState, CPUList

import os.path
import enum
import math
import graph_tool

from collections import defaultdict
from dataclasses import dataclass, field
from functools import reduce, lru_cache
from graph_tool.topology import label_out_component, dominator_tree, shortest_path, all_paths
from graph_tool.search import bfs_search, BFSVisitor, StopSearch
from graph_tool import GraphView
from itertools import product, chain, permutations, islice
from typing import List, Dict, Set, Tuple, Optional
from copy import deepcopy
from scipy.optimize import linprog

# time counter for performance measures
c_debugging = 0  # in milliseconds

MAX_UPDATES = 2
MAX_STATE_UPDATES = 20
MIN_EMULATION_TIME = 200
MAX_INT64 = 2**63 - 1

sse_counter = 0


class CrossExecState(enum.IntEnum):
    """Execution state of an MSTG state.

    It extends the normal ExecState.
    """
    idle = ExecState.idle
    computation = ExecState.computation
    waiting = ExecState.waiting

    with_time = ExecState.with_time

    call = ExecState.call
    syscall = ExecState.syscall

    __max = max(int(x) for x in ExecState).bit_length()
    cross_syscall = 1 << __max
    cross_irq = 1 << __max + 1
    irq = 1 << __max + 2

    no_time = ExecState.no_time | cross_syscall


@dataclass(frozen=True)
class CrossState:
    # state within the metastate that triggers a new cross point
    state: graph_tool.Vertex
    # optional IRQ that is responsible for the trigger
    irq: Optional[int] = None


@dataclass(frozen=True)
class NewNodeReevaluation:
    """Store necessary data for the reevaluation of a new node."""
    from_cp: graph_tool.Vertex
    cores: Set[int]


@dataclass(frozen=True)
class NewEdgeReevaluation:
    """Store necessary data for the reevaluation of a new edge."""
    root: graph_tool.Vertex  # the root cross point


@dataclass
class Metastate:
    """Representaion of a Metastate.

    In the final MSTG, the Metastate is stored as vertex only.
    However, this dataclass captures analysis specific attributes.
    """
    state: graph_tool.Vertex  # vertex of the state
    entry: graph_tool.Vertex  # vertex of the entry ABB
    new_entry: bool  # is the entry point new
    is_new: bool  # is this Metastate new or already evaluated
    cross_points: List[graph_tool.Vertex]  # new cross points of Metastate
    irqs: List[Tuple[graph_tool.Vertex, int]]  # new (cross) irqs of MS
    cpu_id: int  # cpu_id of this state

    def __repr__(self):
        return ("Metastate("
                f"state: {int(self.state)}, "
                f"entry: {int(self.entry)}, "
                f"new_entry: {self.new_entry}, "
                f"is_new: {self.is_new}, "
                f"cross_points: {[int(x) for x in self.cross_points]}, "
                f"irqs: {[(int(x), y) for x, y in self.irqs]}, "
                f"cpu_id: {self.cpu_id})")


@dataclass(frozen=True)
class FakeEdge:
    """Represents an edge that don't exist in the graph."""
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
class RootedState:
    """A state and its belonging root SP."""
    root: graph_tool.Vertex
    state: graph_tool.Vertex

    def __repr__(self):
        return ("RootedState("
                f"root: {int(self.root)}, "
                f"state: {int(self.state)})")


@dataclass(frozen=True)
class Range:
    """A range between two vertices."""
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
class CPRange:
    root: graph_tool.Vertex
    range: Range

    def __repr__(self):
        return ("CPRange(" f"root: {int(self.root)}, " f"range: {self.range})")


@dataclass(frozen=True)
class TimeRange:
    """Represent a time range.

    Normally, this is a range between BCET (best-case execution time) and WCET
    (worst-case execution time).
    Sometimes, it is also a range between BCST (best-case starting time) and
    WCST (worst-case starting time). In this range the ABB or SP definitely
    starts.
    """
    up: int
    to: int

    def get_overlap(self, other: "TimeRange") -> "TimeRange":
        """Return a new TimeRange specifying the overlap between two ranges."""
        new_up = max(self.up, other.up)
        new_to = min(self.to, other.to)
        if new_to > new_up:
            return TimeRange(up=new_up, to=new_to)
        return None

    def __add__(self, other: "TimeRange"):
        return TimeRange(up=self.up + other.up, to=self.to + other.to)


@dataclass(frozen=True)
class TimedVertex:
    """An arbitrary graph vertex associated with a time."""
    vertex: graph_tool.Vertex
    range: TimeRange

    def __repr__(self):
        return ("TimedVertex("
                f"vertex: {int(self.vertex)}, "
                f"range: {self.range})")


@dataclass(frozen=True)
class TimeCandidateSet:
    """Container for a set of candidates fitting to a cross state."""
    # a list of other candidate vertices
    candidates: List[graph_tool.Vertex]
    # a list of predecessor SPs. For each pred SP a time range is given, which
    # denotes the time between candidate and pred SP.
    pred_cps: Tuple[TimedVertex]
    # the root SP for this candidate set
    root_cp: graph_tool.Vertex


@dataclass()
class CrossContext:
    """Gives a context for a specific cross syscall.

    graph  -- an SP graph (see _get_sp_graph()) that is additionally filtered
              to only contain all reachable SPs from the specified root of the
              cross syscall
    mstg   -- the MSTG
    cpu_id -- the cpu_id of the cross syscall
    path   -- path from the cross syscall SP up to the root (all exit SPs)
    cores  -- the affected cores for every element of the path
    """
    graph: graph_tool.Graph
    mstg: graph_tool.Graph
    cpu_id: int
    cross_syscall: graph_tool.Vertex
    path: List[graph_tool.Vertex] = field(default_factory=list, init=False)
    cores: Dict[graph_tool.Vertex, Set[int]] = field(default_factory=dict,
                                                     init=False)

    def append_path_elem(self, v, v_cores):
        assert v not in self.cores
        self.path.append(v)
        self.cores[v] = v_cores

    def get_edges_to(self, sp):
        "Return all edges from the cross core to the SP laying on the path." ""
        edge_path = [FakeEdge(src=self.path[0], tgt=self.cross_syscall)]
        for tgt, src in pairwise(self.path):
            if tgt == sp:
                break
            edge_path.append(
                single_check(
                    filter(lambda e: self.mstg.ep.type[e] == MSTType.follow_sync,
                           self.mstg.edge(src, self.mstg.get_entry_cp(tgt),
                                          all_edges=True))))
        return edge_path

    def __repr__(self):
        return ("CrossContext("
                f"cpu_id: {self.cpu_id}, "
                f"path: {[int(x) for x in self.path]}, "
                f"cores: {dict([(int(x), y) for x, y in self.cores.items()])}")


class Equations:
    """Equation system for calculation of possible pairing partners."""

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
        """Return, if the equation system has a solution."""
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

    def add_range(self, edge: graph_tool.Edge, time: TimeRange):
        """Store that the specified edge lives only in the range time.

        Basically store for edge e the equation: up < time_e < to
        """
        assert isinstance(time, TimeRange)
        assert time.to >= time.up and time.up >= 0
        var = self._get_variable(edge)
        self._bounds[var] = time

    def add_equality(self, left_edges, right_edges):
        """Store that the left_edges sum must be equal to the right_edges sum.

        Store an equation like: a_left + b_left + c_left = d_right + e_right
        """
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
    """Set the time number to the property prop at index idx."""
    # translate infinity
    if number == math.inf:
        number = MAX_INT64
    prop[idx] = number


def get_time(prop, idx):
    """Get the time at the property prop at index idx."""
    number = prop[idx]
    # translate infinity
    if number == MAX_INT64:
        return math.inf
    return number


@dataclass(frozen=True)
class StateList:
    """List of pairing candidates for a cross syscall together with their
    equation system.
    """
    states: Tuple[RootedState]
    eqs: Equations


@dataclass
class MSTG:
    g: MSTGraph

    # store the affected cores of a cross syscall
    # contains a vector[int]
    cross_core_map: graph_tool.VertexPropertyMap

    # store the ecec type of a state
    # contains a mask of CrossExecState
    type_map: graph_tool.VertexPropertyMap

    # store which cores are affected by this synchronisation point
    # contains a vector[int]
    cross_point_map: graph_tool.VertexPropertyMap


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
        dot_graph = mstg_to_dot(self._mstg.g, label=f"MSTG {extra}")
        with open_with_dirs(dot_path):
            dot_graph.write(dot_path)
        self._log.info(f"Write MSTG to {dot_path}.")

        dot_file = self.dump_prefix.get() + f"mstg.{extra}.sp.dot"
        dot_path = os.path.abspath(dot_file)
        dot_graph = sp_mstg_to_dot(self._mstg.g, label=f"SP MSTG {extra}")
        with open_with_dirs(dot_path):
            dot_graph.write(dot_path)
        self._log.info(f"Write SP MSTG to {dot_path}.")

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
        irqs = list()

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

            self._mstg.type_map[v] = cpu.exec_state

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
            def cross_core_action(state, cpu_ids, irq=None):
                v = self._state_map[hash(state)]
                self._mstg.cross_core_map[v] = cpu_ids
                if irq is None:
                    self._mstg.type_map[v] = CrossExecState.cross_syscall
                    cross_points.append(v)
                else:
                    self._mstg.type_map[v] |= CrossExecState.cross_irq
                    irqs.append((v, irq))

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
            def add_irq_state(old_state, new_state, irq):
                v = self._state_map[hash(old_state)]
                self._mstg.cross_core_map[v] = []
                self._mstg.type_map[v] |= CrossExecState.irq
                irqs.append((v, irq))

                return False

            @staticmethod
            def add_transition(source, target):
                src = self._state_map[hash(source)]
                tgt = self._state_map[hash(target)]
                mstg = self._mstg.g
                e = mstg.add_edge(src, tgt)
                mstg.ep.type[e] = MSTType.s2s
                mstg.ep.cpu_id[e] = cpu_id
                m_state_cand = _get_m_state(tgt)
                if m_state_cand is None:
                    return
                target = mstg.vp.state[tgt]
                self._log.debug(
                    "Found a transition to an already existing metastate "
                    f"(State {source.id} (node {int(src)}) -> "
                    f"State {target.id} (node {int(tgt)})).")
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
                irqs=irqs,
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
            irqs=irqs,
            cpu_id=cpu_id,
            entry=init_v,
            new_entry=True,
            is_new=is_new,
        )

    def _find_cross(self, metastate, entry, cross_type):
        """Find all states of type cross_type coming for a given metastate
        coming from entry.
        """
        mstg = self._mstg.g
        s2s = mstg.vertex_type(StateType.state)

        # the algorithm works a follows:
        # 1. Mark all reachable states coming from entry (within the same
        #    metastate).
        # 2. Filter this set for the given cross_type.
        oc = label_out_component(s2s, s2s.vertex(entry))
        oc[metastate] = True

        type_filtered = GraphView(
            mstg,
            vfilt=(((mstg.vp.type.fa == StateType.metastate) +
                    (self._mstg.type_map.fa & cross_type) > 0)),
        )
        reachable_filtered = GraphView(type_filtered, vfilt=oc)

        return list(reachable_filtered.vertex(metastate).out_neighbors())

    def _find_cross_states(self, metastate, entry):
        """Return all syscalls that possibly affect other cores."""
        return self._find_cross(metastate, entry, CrossExecState.cross_syscall)

    def _find_irqs(self, state, entry):
        """Return all IRQs that possibly affect other cores."""
        ists = self._find_cross(state, entry,
                                CrossExecState.cross_irq | CrossExecState.irq)
        mstg = self._mstg.g
        st2sy = mstg.edge_type(MSTType.st2sy)
        out = []
        for irq_state in ists:
            # every state must have be evaluated before
            # so check their irqs iterating the out edges
            irq = set([mstg.ep.irq[e]
                       for e in st2sy.vertex(irq_state).out_edges()]) - {-1}
            out.extend(product([irq_state], irq))
        return out

    def _find_root_cross_points(self, sp, current_core, affected_cores, only_root=None):
        """Find the last SP that contains all needed cores.

        sp             -- The starting SP
        current_core   -- The core for which we are looking (must be
                          synchronized by sp
        affected_cores -- All cores that need to be in the follow up SP.
        only_root      -- Respect only this root SP regardless how much are found.
        """
        # Idea: We search the chain of metastates + SPs for the current core
        # as long as we find an SP that also affects affected_cores.
        mstg = self._mstg.g
        wanted_cores = {current_core} | set(affected_cores)
        # First construct a graph that consists of SPs and Metastates for
        # current_core only
        g1 = mstg.vertex_type(StateType.entry_sync,
                              StateType.exit_sync,
                              StateType.metastate)
        g2 = edge_types(g1, mstg.ep.type, MSTType.m2sy, MSTType.en2ex)
        g = GraphView(g2, vfilt=lambda v:
                      g2.vp.cpu_id[v] == current_core
                      if g2.vp.type[v] == StateType.metastate
                      else True)

        sp_graph = self._get_sp_graph()

        # property map to indicate for every SP if it affects the current_core
        not_core = sp_graph.new_vp("bool", val=False)
        for v in sp_graph.vertices():
            if current_core not in self._mstg.cross_point_map[v]:
                not_core[v] = True

        sp_follow = mstg.edge_type(MSTType.follow_sync, MSTType.sy2sy)
        follow_sync = mstg.edge_type(MSTType.follow_sync)
        # self._log.debug(f"FR: {int(sp)}, {current_core}, {affected_cores}")

        # calculate roots and the successors for each node
        root_cps = []
        stack = [g.vertex(sp)]
        succs = defaultdict(set)
        visited = g.new_vp("bool")
        # perform a BFS for the root cores.
        # The reason why we don't use graph_tool's DFS is that the graph_tool
        # DFS visitor has not possibility to stop the search for the current
        # branch but continue with other parts, see
        # https://archives.skewed.de/hyperkitty/list/graph-tool@skewed.de/thread/MDMNBV7XPQJKSHBTX2ARPKU6F7PQR4L2/
        while stack:
            cur_sp = stack.pop(0)
            assert mstg.vp.type[cur_sp] == StateType.exit_sync
            if visited[cur_sp]:
                continue
            visited[cur_sp] = True

            cores = set(self._mstg.cross_point_map[cur_sp])
            if cores >= wanted_cores:
                root_cps.append(cur_sp)
                continue

            entry_sp = g.vertex(mstg.get_entry_cp(cur_sp))
            for n in chain.from_iterable(map(lambda x: x.in_neighbors(),
                                             entry_sp.in_neighbors())):
                assert mstg.vp.type[n] == StateType.exit_sync
                if sp_follow.edge(n, entry_sp):
                    succs[n].add(cur_sp)
                    stack.append(n)

        # self._log.debug(f"FR: roots {[int(x) for x in root_cps]}")
        # self._log.debug(f"FR: succs {succs}")
        if only_root:
            root_cps = {only_root} & set(root_cps)
            self._log.debug(f"Evaluation only {[int(x) for x in root_cps]} as "
                            f"root SP. We only inspect {int(only_root)}.")

        # calculate all paths to the roots
        # We do not need the root SPs only, we also need all paths that lead
        # to them.The algorithm starts at the root node and iterates all
        # successors that was stored previously. Whenever multiple successors
        # exist, the path is split into two.
        ret = []
        for root in root_cps:
            paths = [[root]]
            i = 0
            while i < len(paths):
                path = paths[i]
                last = path[-1]
                if last == sp:
                    # the path is ready
                    i += 1
                    continue
                nexts = succs[last]
                # check for loops in the path
                if last in path[:-1]:
                    nexts -= set(path[:-1])

                next_paths = []
                for nex in nexts:
                    # It is possible that the current path and nex are not
                    # connected via follow_sync edges because they are sharing
                    # a sy2sy edge only. However, in this case, there must be
                    # at least one path of follow_sync edges between them. We
                    # need to find the pathes in this case.
                    entry_sp = mstg.get_entry_cp(nex)
                    if follow_sync.edge(last, entry_sp):
                        # direct edge, just append
                        next_paths.append([nex])
                        continue
                    # restrict graph to contain not sps of the current_core
                    # the follow_sync edges must only contain other cores
                    lc = not_core.copy()
                    lc[last] = True
                    lc[entry_sp] = True
                    lc[nex] = True
                    nc = GraphView(sp_graph, vfilt=lc)
                    next_paths.extend(map(lambda p: islice(filter(lambda v: mstg.vp.type[v] == StateType.exit_sync, p), 1, None), all_paths(nc, last, nex)))
                # put all other elements to new paths
                for n in next_paths[1:]:
                    paths.append(list(chain(path, n)))
                # put first element to the current path
                if next_paths:
                    path.extend(next_paths[0])
            ret.extend(product([root], paths))
        return ret, g

    def _is_successor_of(self, orig_cp, new_cp):
        """Is new_cp a successor of orig_cp?"""
        sync_graph = self._mstg.g.edge_type(MSTType.follow_sync, MSTType.en2ex)
        _, elist = shortest_path(sync_graph, orig_cp, new_cp)
        return len(elist) > 0

    def _iterate_search_tree(self, ctx, core, sps, eqs, paths):
        """Return all valid entry SPs for the given context and core.

        For the search of pairing partners, all possible pairing states must
        be iterated per core. They are restricted by SPs which are iterated
        with this function.

        Arguments:
        ctx   -- General search context
        core  -- Find SPs for this core.
        sps   -- Current SP corridor.
        eqs   -- The equation system for the current search.
        paths -- The history of already evaluated paths.
        """
        def log(msg, skip=True):
            if skip:
                return
            self._log.debug("i_s_t: " + msg)

        sp = sps[core]
        mstg = self._mstg.g
        sync_graph = mstg.edge_type(MSTType.m2sy, MSTType.en2ex)
        follow_sync = mstg.edge_type(MSTType.follow_sync)

        def this_core(e):
            if mstg.ep.type[e] == MSTType.m2sy:
                return mstg.ep.cpu_id[e] == core
            return True

        core_graph = GraphView(sync_graph, efilt=this_core)

        paths = set([(x.source(), x) for x in chain(*paths)])

        start = core_graph.vertex(sp.range.start)
        stack = [(start, [FakeEdge(src=None, tgt=start)])]

        visited = core_graph.new_vp("bool")
        visited_entries = defaultdict(list)

        log(f"SPs: {sps}")
        log(f"Looking at CPU {int(core)} (orig CPU {int(ctx.cpu_id)})")
        while stack:
            cur, path = stack.pop(0)
            log(f"Stack element {int(cur)} with path {path}")

            if visited[cur] and path[-1] in visited_entries[cur]:
                log("Already visited, skipping...")
                continue
            visited[cur] = True
            visited_entries[cur].append(path[-1])
            last_exit_cp = path[-1].target()

            # iterate
            edges = []
            for e in cur.out_edges():
                log(f"Look at {e} (Type "
                    f"{str(MSTType(self._mstg.g.ep.type[e]))}).")
                tgt = e.target()

                # skip paths where the sync points do not follow each other
                if core_graph.vp.type[cur] == StateType.metastate:
                    nes = set(follow_sync.vertex(last_exit_cp).out_neighbors())
                    if e.target() not in nes:
                        log(f"Skip {e}. SPs do not follow each other.")
                        continue

                # skip false paths
                if tgt == sp.range.end:
                    log(f"Skip {e}. We are not branching to ourself.")
                    continue
                if core_graph.vp.type[tgt] == StateType.entry_sync:
                    cores = set(self._mstg.cross_point_map[tgt])
                    if ctx.cpu_id in cores:
                        log(f"Skip {e}. It contains core {ctx.cpu_id}.")
                        continue
                    if cores & set(ctx.cores[sp.root]):
                        # if the new sync point (tgt) share some cores with the
                        # root sync point for this path
                        if not all([
                                self._is_successor_of(sps[c].root, tgt)
                                for c in cores if c in sps
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
                        ff_edges = self._get_followsync_path(ctx, e.target(),
                                                             from_sp=last_exit_cp)
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
                log(f"Yielding {edge.target()}.")
                yield edge.target(), path

    def _get_initial_cps(self, cores, path):
        """Return a mapping for each core which SP belongs to it depending on
        a given path.

        Assuming this path of SPs (the numbers denoting the cores).

        SP1: [ 0 | 1 | 2 ]
                   |
                   v
        SP2: [ 0 | 1 ]
                   |
                   v
        SP3:     [ 1 | 2 ]

        For cores={0,1,2} and path=["SP1", "SP2", "SP3"], this would result in
        { 0: CPRange(root=SP1, range=(start=SP2, end=None),
          1: CPRange(root=SP1, range=(start=SP3, end=None),
          2: CPRange(root=SP1, range=(start=SP3, end=None) }

        Additionally, it outputs the other cores that are synchronized on the
        way to this core:

        { 0: {1, 2},
          1: {},
          2: {} }
        """
        mstg = self._mstg.g
        core_map = self._mstg.cross_point_map
        cores = set(cores)
        handled_cores = set()
        cps = {}
        used = {}
        for x in reversed(path):
            assert mstg.vp.type[x] == StateType.exit_sync
            x_cores = set(core_map[int(x)]) & cores
            for core in x_cores - handled_cores:
                cps[core] = CPRange(root=path[0],
                                    range=Range(start=x, end=None))
                used[core] = set(handled_cores)
            handled_cores |= x_cores
            if len(cores - handled_cores) == 0:
                break
        return cps, used

    def _check_barriers(self, graph, new_barriers, old_barriers):
        """Check, if new_barriers are tighter than old_barriers.

        Internally, this work by calculating a path from old_barriers to
        new_barriers for each core. If such a path exists new_barriers is not
        tighter.

        The function corrects this directly in new_barriers.
        """
        for cpu, new in new_barriers.items():
            old = old_barriers[cpu]
            if old is not None:
                if has_path(graph, old, new):
                    new_barriers[cpu] = old

    def _get_constrained_sps(self, g, cores, new_range, old_sps=None):
        """Get the SPs that restricted by new_range.

        Arguments:
        g --         A graph of SPs.
        cores --     All affected cores (to respect only SPs that include these
                     cores.
        new_range -- A range of SPs within the search must take place.
        old_sps --   An already restricted set of SPs

        Example:
        cores={0,1,2}
        new_range={start=SP4, end=None}
        old_sps:
        { 0: CPRange(root=SP1, range=(start=SP2, end=None),
          1: CPRange(root=SP1, range=(start=SP2, end=None),
          2: CPRange(root=SP1, range=(start=SP1, end=None) }

        Given this history:

        SP1: [ 0 | 1 | 2 | 3 ]
                   |
                   v
        SP2: [ 0 | 1 ]
                   |         <- Here are the "bounds" of old_sps
                   v
        SP3:     [ 1 | 2 ]
                       |
                       v
        SP4:         [ 2 | 3 ]

        the result would be a new dict of SPs:
        { 0: CPRange(root=SP1, range=(start=SP2, end=None),
          1: CPRange(root=SP1, range=(start=SP3, end=None),
          2: CPRange(root=SP1, range=(start=SP4, end=None) }

        The algorithm works by doing a BFS from the start point of the new
        range backwards and a BFS from the end point of the range forward until
        it has found an SP for all affected cores to find all new bounds.
        """
        if old_sps is None:
            old_sps = defaultdict(
                lambda: CPRange(root=None, range=Range(start=None, end=None)))

        unbound = {*cores}
        new_starts = {}
        new_ends = defaultdict(lambda: None)

        class Constraints(BFSVisitor):
            def __init__(self, sp_map, sp_list):
                self.sp_map = sp_map
                self.sp_list = sp_list

            def discover_vertex(self, u):
                if len(unbound) == 0:
                    raise StopSearch
                u_cores = set(self.sp_map[u]) & unbound
                for core in u_cores:
                    self.sp_list[core] = u
                    unbound.remove(core)

        sp_map = self._mstg.cross_point_map

        # first find the new starting SPs
        rsync = GraphView(g, reversed=True)
        bfs_search(rsync,
                   source=new_range.start,
                   visitor=Constraints(sp_map, new_starts))

        # TODO, check why this is necessary
        self._check_barriers(
            rsync, new_starts,
            dict([(x, old_sps[x].range.start) for x in cores]))

        # then find the new ending SPs, if necessary
        if new_range.end:
            bfs_search(g,
                       source=new_range.end,
                       visitor=Constraints(sp_map, new_ends))

            self._check_barriers(
                g, new_ends, dict([(x, old_sps[x].range.end) for x in cores]))

        return dict([(x,
                      CPRange(root=old_sps[x].root,
                              range=Range(start=new_starts[x],
                                          end=new_ends[x])))
                     for x in cores])

    def _get_reachable_states(self, entry_state, exit_state=None):
        """Return a graph of all reachable states given an entry_state.

        The search applies only to state within the same metastate.
        If an exit state is given only states are returned which have a path
        to this exit state.
        """
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
        return shortest_path(graph, from_cp, to_cp)[1]

    def _filtered_follow_sync(self, iterable):
        """Return a list of edges of iterable filtered by follow sync."""
        return list(
            filter(
                lambda e: isinstance(e, FakeEdge) or self._mstg.g.ep.type[e] ==
                MSTType.follow_sync, iterable))

    def _get_followsync_path(self, ctx, to_sp, from_sp=None):
        """Return the path of follow_sync edges from from_sp to to_sp.

        If from_sp is None it is assumed to be the root SP.
        """
        if from_sp:
            return self._filtered_follow_sync(self._get_path(ctx.graph,
                                                             from_sp,
                                                             to_sp))
        # the chain from the cross syscall sp to root is given
        # so try to find a path from the last possible point in this chain
        for exit_sp in ctx.path:
            p = self._get_path(ctx.graph, exit_sp, to_sp)
            if p:
                return self._filtered_follow_sync(p)
        return []

    def _get_timed_states(self, ctx, cpu_id, root_sp, entry_sp, exit_sp, eqs):
        """Return all states that are within a feasible time.

        So basically, there are several states on the way from the entry SP to
        the exit SP that need time to execute.

        This function return them either entirely (if timings are not
        considered) or only that ones that fit to the given timings (by eqs).

        Arguments:
        ctx -- The context of the current search.
        cpu_id -- The cpu_id for which the search should take place.
        root_sp -- The root SP for the current search.
        entry_sp -- The entry SP that must dominate all states.
        exit_sp -- An optional exit_sp.
        eqs -- The current equation system.
        """
        mstg = self._mstg.g

        entry = mstg.get_entry_state(entry_sp, cpu_id)

        if exit_sp:
            exit_s = mstg.get_exit_state(exit_sp, cpu_id)
        else:
            exit_s = None

        reachable = self._get_reachable_states(entry, exit_state=exit_s)

        r1 = vertex_types(reachable, self._mstg.type_map, CrossExecState.with_time)

        good_v = []
        for v in r1.vertices():
            new_eqs = eqs.copy()
            if not self.with_times.get():
                # shortcut if timings are not relevant
                good_v.append((v, new_eqs))
                continue
            state_time = self._get_relative_time(entry_sp, cpu_id, v)
            e = FakeEdge(src=entry_sp, tgt=v)
            new_eqs.add_range(e, state_time)
            root_edges = ctx.get_edges_to(root_sp)
            cur_edges = self._get_followsync_path(ctx, entry_sp) + [e]
            # self._log.debug(f"GTS: V: {int(v)} Edges: "
            #                 f"{[str(e) for e in root_edges]}"
            #                 f"{[str(e) for e in cur_edges]}")
            new_eqs.add_equality(root_edges, cur_edges)
            # self._log.debug(f"GTS: EQs: {new_eqs}")
            if new_eqs.solvable():
                good_v.append((v, new_eqs))
        return good_v

    def _build_product(self, ctx, sps, eqs, cores, paths):
        """Find all combinations that are valid pairing points for the current
        cross syscall.

        This function is recursive and calls itself core times. It works by
        choosing all valid pairing points for one core and then calls itself
        again to combine that to the rest of the combinations.

        Arguments:
        ctx       -- CrossContext for the cross syscall
        sps       -- dict of CPRange objects
        eqs       -- Timing Equations

        cores     -- the cores that need to be processed
        paths     -- previous decisions which sync points are taken (the path
                     consists of edges between SPs)
        """
        assert len(cores) >= 1, "False usage of _build_product."
        core = cores[0]
        root = sps[core].root

        result = set()

        # self._log.debug(f"b_p: Cores: {cores}, SPs: {sps}")

        for sp_to, path in self._iterate_search_tree(
                ctx, core, sps, eqs, paths):
            sp_from = path[-1].target()
            # self._log.debug(f"Examine metastate from SP {sp_from} to SP {sp_to} (CPU {core}).")
            states = self._get_timed_states(ctx, core, root, sp_from, sp_to,
                                            eqs)
            # self._log.debug(f"Leads to timed states: {[int(x[0]) for x in states]}.")
            for state, new_eqs in states:
                if len(cores) > 1:
                    new_cores = cores[1:]
                    new_cps = self._get_constrained_sps(ctx.graph,
                                                        new_cores,
                                                        Range(start=sp_from,
                                                              end=sp_to),
                                                        old_sps=sps)
                    others = self._build_product(ctx, new_cps, new_eqs,
                                                 new_cores, paths + [path])
                else:
                    # break condition
                    others = {StateList(states=tuple(), eqs=new_eqs)}

                # combine our state with all others (found recursively)
                result |= set([
                    StateList(states=(x[0], *x[1].states), eqs=x[1].eqs)
                    for x in product([RootedState(root=sp_from, state=state)],
                                     others)
                ])
        # for res in result:
        #     self._log.warn([(int(x), int(y)) for x, y in res.states])

        # list of lists of pairs of computation state + entry_cp
        return result

    @lru_cache(maxsize=8)
    def _find_timed_predecessor(self, graph, sps):
        """Calculate possible predecessors in time for a given SP set.

        For its working, the function calculates a path between each SP pair.
        If one exists, it removes every element except of the last one.
        """
        predecessors = set(sps)
        src_blacklist = set()
        pair_blacklist = set()
        for src, tgt in permutations(reversed(list(sps)), 2):
            if src in src_blacklist:
                continue
            if (src, tgt) in pair_blacklist:
                continue

            vlist, _ = shortest_path(graph, src, tgt)
            # src is dominated in time by tgt
            # remove every element in the path except of the last one
            for elem in vlist[:-1]:
                src_blacklist.add(elem)
                pair_blacklist.add((tgt, src))
                if elem in predecessors:
                    predecessors.remove(elem)

        assert len(predecessors) > 0
        return frozenset(predecessors)

    def _get_pred_times(self, sps, state_list: StateList, sp, cross_state):
        """Assign a new follow up time for all nodes in state_list.

        We have found a candidate set for the cross state but the time is
        missing yet. So calculate the correct time between all candidates (a
        state) and its predecessor SP.

        Arguments:
        sps         -- predecessors in time of the to be create SPs
        state_list  -- a StateList of all pairing candidates
        sp          -- the predecessor sp of cross_state
        cross_state -- the current cross state

        """
        loose_ends = {int(sp): int(cross_state)}
        # Assign the last state that belongs to each SP
        for state in state_list.states:
            loose_ends[int(state.root)] = int(state.state)
        timed_sps = []
        # find a time for all SPs
        for other_sp in sps:
            time = state_list.eqs.get_interval_for(
                FakeEdge(src=other_sp, tgt=loose_ends[int(other_sp)]))
            timed_sps.append(TimedVertex(vertex=other_sp, range=time))
        return frozenset(timed_sps)

    def _gen_context(self, graph, cross_syscall, cpu_id, cp, root, path):
        """Generates a cross context for easier parameter handling."""
        ctx = CrossContext(graph=graph,
                           mstg=self._mstg.g,
                           cpu_id=cpu_id,
                           cross_syscall=cross_syscall)
        core_map = self._mstg.cross_point_map
        for v in reversed(path):
            ctx.append_path_elem(v, core_map[v])
        return ctx

    def _is_follow_sp(self, ctx, sp):
        """Check, if sp is a valid follow up SP of the SPs specified by ctx."""
        core_map = {}
        for p in reversed(ctx.path):
            nc = dict([(c, p) for c in ctx.cores[p]])
            core_map.update(nc)
        cores = set(self._mstg.cross_point_map[sp]) & set(core_map.keys())
        # check for every core, if there exists a path between the last SP that
        # synchronizes this core and sp
        return all([
            has_path(ctx.graph, core_map[core], sp)
            and core is not ctx.cpu_id for core in cores
        ])

    def _is_evaluated(self, state):
        """Check, if a state is already evaluated."""
        st2sy = self._mstg.g.edge_type(MSTType.st2sy)
        return st2sy.vertex(state).out_degree() > 0

    def _has_prior_syscalls(self, ctx, cross_bcst):
        """Check for an unevaluated prior syscall.

        Therefore, check all syscalls laying on the path between the current
        cross syscall and the root SP.

        Arguments:
        ctx -- The context of the current cross syscall that we need to find
               pairing partners for.
        cross_bcst -- The BCST of the current cross syscall
        """
        cpm = self._mstg.cross_point_map
        mstg = self._mstg.g

        handled_cores = set()
        to_handle_sps = set()
        # first, collect all SPs that are possibly before the current SP.
        for exit_sp in ctx.path:
            cores = set(cpm[exit_sp])
            if cores in handled_cores:
                continue

            stack = [(exit_sp, ())]

            while stack:
                cur_sp, path = stack.pop()
                is_entry_sync = (mstg.vp.type[cur_sp] == StateType.entry_sync)
                if is_entry_sync:
                    handled_cores |= set(cpm[cur_sp])
                elif mstg.vertex(cur_sp).out_degree() > 0:
                    # if an exit SP has already connected metastates, it can
                    # lead to unevaluated syscalls.
                    to_handle_sps.add((cur_sp, path, exit_sp))

                # all edges to SPs that follow in time
                for e in ctx.graph.vertex(cur_sp).out_edges():
                    if is_entry_sync:
                        stack.append((e.target(), path))
                        continue
                    if not self._is_follow_sp(ctx, e.target()):
                        # if there is no connection between the found SP and
                        # the current path.
                        continue
                    stack.append((e.target(), path + (e, )))

        # then, check all syscalls following of theses SPs if they are prior
        # to the current one.
        for sp, path, root in to_handle_sps:
            self._log.debug(f"Search cross syscalls of SP {int(sp)} for prior "
                            f"syscalls than {int(ctx.cross_syscall)}")
            cores = set(cpm[sp])
            for cpu_id in (cores - {ctx.cpu_id}):
                metastate = mstg.get_out_metastate(sp, cpu_id)
                entry = mstg.get_entry_state(sp, cpu_id)
                cross_states = self._find_cross_states(metastate, entry)
                for cross_state in filter(lambda x: not self._is_evaluated(x),
                                          cross_states):
                    self._log.debug(f"Check, if {int(cross_state)} is prior to "
                                    f"{int(ctx.cross_syscall)}")
                    # check, if the WCST of the other syscall is lower than
                    # the BCST of our own syscall.
                    # In this case, the starting time of the other syscall is
                    # definitely before this one.
                    wcst = 0
                    for e in path:
                        wcst += get_time(mstg.ep.wcet, e)
                    wcst += self._get_relative_time(sp, cpu_id, cross_state).to
                    bcst = cross_bcst
                    for e in ctx.get_edges_to(root):
                        if isinstance(e, FakeEdge):
                            continue
                        bcst += get_time(mstg.ep.bcet, e)
                    if wcst < bcst:
                        return True
        return False

    def _add_ranges(self, eqs, edges):
        """Add a range to eqs for every edge in edges."""
        bcet = self._mstg.g.ep.bcet
        wcet = self._mstg.g.ep.wcet
        for e in edges:
            eqs.add_range(
                e, TimeRange(up=get_time(bcet, e), to=get_time(wcet, e)))

    def _get_sp_graph(self):
        """Return a graph consisting only of SPs that follow in the time domain."""
        return GraphView(
                self._mstg.g.vertex_type(StateType.entry_sync,
                                         StateType.exit_sync),
                efilt=self._mstg.g.ep.type.fa != MSTType.sy2sy)

    def _find_timed_states(self, cross_state, last_sp, time,
                           start_from=None, only_root=None):
        """Find all possible combinations of computation blocks that fit to
        the cross_state.

        cross_state -- the state that triggers a new SP
        last_sp     -- the SP that leads to cross_state
        time        -- The BCST and WCST of cross_state relative to last_sp.
        start_from  -- An optional SP where the search should start from.
        only_root   -- Respect only this SP as root SP.
        """
        # 1. Find all root cross points (which forms the root for the
        #    following searches)
        mstg = self._mstg.g
        affected_cores = self._mstg.cross_core_map[cross_state]
        current_core = mstg.vp.cpu_id[cross_state]

        sp_graph = self._get_sp_graph()
        follow_sync = mstg.edge_type(MSTType.follow_sync)

        root_cps, core_graph = self._find_root_cross_points(last_sp, current_core,
                                                            affected_cores,
                                                            only_root=only_root)

        self._log.debug(f"Find pairing candidates for node {int(cross_state)} "
                        f"(time: {time}) starting from "
                        f"root cross points {[int(x[0]) for x in root_cps]}.")
        combinations = set()
        for root, path in root_cps:
            # 2. For each root cross point get the actual affected following
            #    cross points.
            #    They can be restricted by the set of affected cores or by an
            #    explicitly given starting point.

            # build a restricted graph that only sees the history coming from
            # the root vertex
            reach = label_out_component(sp_graph, sp_graph.vertex(root))
            reach[root] = True
            cut_history = mstg.new_ep("bool", val=True)
            for edge in mstg.vertex(root).in_edges():
                cut_history[edge] = False
            r_graph = GraphView(sp_graph, vfilt=reach, efilt=cut_history)

            self._log.debug(f"Evaluating root cross point {int(root)} "
                            f"with path {[int(x) for x in path]}.")

            # get the last SPs for each core
            cps, used_cores = self._get_initial_cps(affected_cores, path)
            cps[current_core] = CPRange(root=root,
                                        range=Range(start=last_sp, end=None))
            # restrict it further, if we have a starting point
            if start_from is not None:
                cps = self._get_constrained_sps(r_graph,
                                                affected_cores,
                                                Range(start=start_from,
                                                      end=None),
                                                old_sps=cps)
            self._log.debug(f"Starting from cross points {cps}.")

            ctx = self._gen_context(r_graph, cross_state, current_core, last_sp,
                                    root, path)
            # If time should be considered, build the (initial) equation
            # system.
            eqs = Equations()
            if self.with_times.get():
                self._log.debug("Check for prior syscalls.")
                # TODO check, if this is really necessary or is we can come to
                # a point where syscalls are evaluated (mostly) in order.
                if self._has_prior_syscalls(ctx, time.up):
                    self._log.debug(f"Skip evaluations of {int(cross_state)} "
                                    f"from root {int(root)}. There are prior "
                                    "not evaluated syscalls that may affect "
                                    "this one.")
                    return set()

                # add all SPs on the path to the root to the equation system
                edges = [follow_sync.edge(src, mstg.get_entry_cp(tgt))
                         for src, tgt in pairwise(path)]
                self._add_ranges(eqs, edges)

                # add the time range of the cross_state to eqs
                eqs.add_range(FakeEdge(src=last_sp, tgt=cross_state), time)

                if start_from is not None:
                    # add all edges on the path from the root SP to start_from
                    edges = self._get_followsync_path(ctx, start_from)
                    self._add_ranges(eqs, edges)

            # 3. Build the actual product from each possible cross point
            #    (while respecting time constraints if given.
            for state_list in self._build_product(ctx, cps, eqs,
                                                  affected_cores, []):
                # we now have a set of candidates for a new SP
                # next step is to calculate the predecessors in time for the
                # new SP
                timely_cps = self._find_timed_predecessor(
                    r_graph,
                    frozenset([last_sp] + [x.root for x in state_list.states]))
                # self._log.debug(
                #    f"Found time predecessors {[int(x) for x in timely_cps]}.")
                if self.with_times.get():
                    timed_pred_cps = self._get_pred_times(
                        timely_cps, state_list, last_sp, cross_state)
                else:
                    timed_pred_cps = frozenset([TimedVertex(vertex=x, range=TimeRange(up=0, to=0))
                                                for x in timely_cps])

                combinations.add(TimeCandidateSet(candidates=tuple([x.state for x in state_list.states]),
                                                  pred_cps=timed_pred_cps,
                                                  root_cp=root))
        # for a, b in combinations:
        #     self._log.warn(f"{[int(x) for x in a]} {[int(x) for x in b]}")
        return combinations

    def _create_sync_point(self, cross_state, timed_states, root_sp, pred_sps, irq):
        """Create a new synchronisation point.

        It synchronizes cross_state with timed_states.
        Its root is root_sp. Its predecessors in time are pred_sps.

        It returns the new SP.
        """
        mstg = self._mstg.g
        new_sp = mstg.add_vertex()
        mstg.vp.type[new_sp] = StateType.entry_sync
        self._log.debug(
            f"Add new entry cross point {int(new_sp)} between "
            f"{int(cross_state)} and {[int(x) for x in timed_states]}")

        # link SP with states
        cpu_ids = set()
        for src in chain([cross_state], timed_states):
            e = mstg.add_edge(src, new_sp)
            if irq and src == cross_state:
                mstg.ep.irq[e] = irq
            mstg.ep.type[e] = MSTType.st2sy
            metastate = mstg.get_metastate(src)
            cpu_id = mstg.vp.cpu_id[metastate]
            mstg.ep.cpu_id[e] = cpu_id
            cpu_ids.add(cpu_id)
            m2sy_edge = mstg.add_edge(metastate, new_sp)
            mstg.ep.type[m2sy_edge] = MSTType.m2sy
            mstg.ep.cpu_id[m2sy_edge] = cpu_id

        self._mstg.cross_point_map[new_sp] = cpu_ids

        # link SP with other SPs
        self._link_sp_with_pred_sps(new_sp, root_sp, pred_sps)

        return new_sp

    def _evaluate_syncpoint(self, sp, root, cross_state):
        """Evaluate an entry sync point.

        The algorithm in principle works as following:
        Get a multicore state out of the single core states.
        Interpret that state.
        Make an exit sync point of every outcome.

        The root SP is necessary to get the core independent context.
        The cross_state simplifies the search for the originator of the SP.

        Return a list of exit sync points.
        """
        os = self._graph.os
        mstg = self._mstg.g
        sp = mstg.vertex(sp)
        st2sy = mstg.edge_type(MSTType.st2sy)

        # create multicore state
        cpu_id = mstg.vp.cpu_id[cross_state.state]

        states = []
        for v in st2sy.vertex(sp).in_neighbors():
            obj = mstg.vp.state[v]
            states.append(obj)

        cpus = CPUList([single_check(x.cpus) for x in states])

        context = {}
        for state in states:
            context.update(os.get_cpu_local_contexts(
                state.context,
                state.cpus.one().id, state.instances))

        old_multi_core_state = mstg.vp.state[root]
        context.update(os.get_global_contexts(old_multi_core_state.context,
                                              old_multi_core_state.instances))

        multi_state = OSState(cpus=cpus,
                              instances=states[0].instances,
                              cfg=states[0].cfg)
        multi_state.context = context

        # let the model interpret the created multicore state
        if cross_state.irq is None:
            new_states = os.interpret(self._graph, multi_state, cpu_id)
        else:
            new_states = [os.handle_irq(self._graph, multi_state, cpu_id, cross_state.irq)]
        for new_state in new_states:
            os.schedule(new_state)

        # add follow up cross points for the outcome
        ret = []
        for new_state in new_states:
            exit_sp = mstg.add_vertex()
            mstg.vp.type[exit_sp] = StateType.exit_sync
            self._log.debug(f"Add exit cross point {int(exit_sp)}")

            e = mstg.add_edge(sp, exit_sp)
            mstg.ep.type[e] = MSTType.en2ex
            cpm = self._mstg.cross_point_map
            cpm[exit_sp] = cpm[sp]

            # store state in cross_point
            mstg.vp.state[exit_sp] = new_state

            ret.append(exit_sp)

        return ret

    def _find_common_crosspoints(self, metastates):
        """Return all common cross points of this specific set of metastates."""
        st2sy = self._mstg.g.edge_type(MSTType.st2sy)
        cps_lists = [
            set(st2sy.vertex(x.entry).in_neighbors())
            for x in metastates.values()
        ]
        return reduce(lambda a, b: a & b, cps_lists)

    def _link_neighbor_crosspoint(self, cp, neighbor_cp):
        """Make cp to a neighbor of neighbor_cp.

        The idea is that a neighbor cp results in the same set of metastates
        so all its outgoing edges can be overtaken.
        Additionally, the neighbors are marked as such with a special edge.
        """
        mstg = self._mstg.g

        # mark as neighbor
        e = mstg.edge(neighbor_cp, cp, add_missing=True)
        mstg.ep.type[e] = MSTType.sync_neighbor

        # sync edges
        sy2sy = mstg.edge_type(MSTType.sy2sy)
        for v in list(sy2sy.vertex(neighbor_cp).out_neighbors()):
            self._log.debug(
                f"Neighbor: Link sy2sy edge: {int(cp)} -> {int(v)}")
            new_e = sy2sy.edge(mstg.vertex(cp),
                               mstg.vertex(v),
                               add_missing=True)
            mstg.ep.type[new_e] = MSTType.sy2sy
        follow_sync = mstg.edge_type(MSTType.follow_sync)
        for v in list(follow_sync.vertex(neighbor_cp).out_neighbors()):
            self._log.debug(
                f"Neighbor: Link follow_sync edge: {int(cp)} -> {int(v)}")
            new_e = follow_sync.edge(mstg.vertex(cp),
                                     mstg.vertex(v),
                                     add_missing=True)
            mstg.ep.type[new_e] = MSTType.follow_sync

    def _get_existing_sync_point(self, cross_state, timed_candidates):
        """Return an existing cross point.

        It has to link exactly cross_state and timed_candidates.
        """
        st2sy = self._mstg.g.edge_type(MSTType.st2sy)
        cps_lists = [
            set(st2sy.vertex(x).out_neighbors())
            for x in chain([cross_state], timed_candidates)
        ]
        cps = reduce(lambda a, b: a & b, cps_lists)
        if len(cps) == 0:
            return None
        else:
            # More than one synchronisation point to this states is forbidden.
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
                               vfilt=self._mstg.type_map.fa != CrossExecState.idle)

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

        inf_time = [CrossExecState.idle, CrossExecState.waiting]

        # entry time
        t_from[entry] = 0
        if type_map[entry] in inf_time:
            set_time(t_to, entry, math.inf)
        else:
            # the state was maybe already executed previously
            # find out how long
            time = self._get_previous_execution_time(cp, cpu_id, entry)
            entry_bcet = max(mstg.vp.bcet[entry] - time.to, 0)
            set_time(t_to, entry, mstg.vp.wcet[entry] - time.up)
            # self._log.debug("GRT: Got a previous execution time of entry "
            #                 f"{int(entry)} of {time}. The new execution time "
            #                 f"is {entry_bcet} to {get_time(t_to, entry)}.")


        def get_bcet(node):
            if type_map[node] in inf_time:
                return 0
            if node == entry:
                return entry_bcet
            return g.vp.bcet[node]

        def get_wcet(node):
            if type_map[node] in inf_time:
                return math.inf
            return g.vp.wcet[node]

        stack = list(g.vertex(entry).out_neighbors())

        while stack:
            cur = stack.pop(0)
            # self._log.debug(f"GRT: Looking at {int(cur)}")
            degree = cur.in_degree()
            if degree == 1:
                pred = single_check(cur.in_neighbors())
                set_time(t_from, cur, get_time(t_from, pred) + get_bcet(pred))
                set_time(t_to, cur, get_time(t_to, pred) + get_wcet(cur))
                # self._log.debug(f"GRT: iter t_to = {get_time(t_to, pred)} + {get_wcet(cur)}, "
                #                 f"t_from = {get_time(t_from, pred)} + {get_bcet(pred)}")
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

        t = TimeRange(up=get_time(t_from, state), to=get_time(t_to, state))
        assert t.up >= 0 and t.to >= t.up
        return t

    def _link_sp_with_pred_sps(self, sp, root_sp, pred_sps, exists=False):
        """Links a synchronisation point with a new set of predecessor SPs.

        In detail, it links the SP with a new root SP and the given
        predecessor SPs in time.

        exists specifies the sp as already existent so this function tracks
        also possible reevaluations and returns it.
        """
        mstg = self._mstg.g
        reeval = set()

        # link root SP and its neighbors
        syncs = mstg.edge_type(MSTType.sync_neighbor)
        for root in chain([root_sp], list(syncs.vertex(root_sp).all_neighbors())):
            if mstg.edge(root, sp):
                self._log.warn("Analysis found a sync point that already "
                               "exists. While this does not lead to false "
                               "behavior it is probably unwanted.")
            else:
                self._log.debug(
                    f"Add sy2sy edge between {int(root)} and {int(sp)}.")
                e = mstg.add_edge(root, sp)
                mstg.ep.type[e] = MSTType.sy2sy

                if exists:
                    # trigger a reevaluation
                    self._log.debug(
                        f"New edge between {int(root_sp)} and {int(sp)}"
                        " can lead to new syscall execution orders. "
                        f"Trigger a reevaluation for {int(sp)}"
                    )
                    en2ex = mstg.edge_type(MSTType.en2ex)
                    for exit_sp in en2ex.vertex(sp).out_neighbors():
                        reeval.add((exit_sp, NewEdgeReevaluation(root=root)))

        # link pred SPs
        follow_sync = mstg.edge_type(MSTType.follow_sync)
        for pred_sp in pred_sps:
            self._log.debug(
                f"Time link from {int(pred_sp.vertex)} to "
                f"existing sync point {int(sp)}")
            if follow_sync.edge(pred_sp.vertex, sp):
                self._log.warn("Analysis found an existing follow "
                               "sync relation.While this does not "
                               "lead to false behavior it is "
                               "probably unwanted.")
            else:
                m2sy_edge = mstg.add_edge(pred_sp.vertex, sp)
                mstg.ep.type[m2sy_edge] = MSTType.follow_sync
                set_time(mstg.ep.bcet, m2sy_edge, pred_sp.range.up)
                set_time(mstg.ep.wcet, m2sy_edge, pred_sp.range.to)

        return reeval

    def _find_new_cps(self, cp, metastate, start_from=None, only_root=None):
        """Try to find the next cross points coming from metastate.

        cp         -- root cross point (entry for the metastate)
        metastate  -- the metastate for which new CPs are searched
        start_from -- starting cross point (narrows the search space, make
                      reevaluations more efficient)
        only_root  -- respect only this SP as root SP.

        The function returns a pair:
        1. A list of new exit cross points.
        2. A Set of cross points that need a reevaluation.
           This is a list of pairs, which denotes the cross point and the
           reason why a reevaluation is needed.
        """
        # container for the return values
        # list of new exit cross points
        exits = []
        # list of cross points that need reevaluation
        reeval = set()

        cross_list = []
        if not metastate.is_new:
            cross_points = self._find_cross_states(metastate.state,
                                                   metastate.entry)
            irqs = self._find_irqs(metastate.state, metastate.entry)
        else:
            cross_points = metastate.cross_points
            irqs = metastate.irqs

        cross_list += [CrossState(state=x, irq=y) for x, y in irqs]
        cross_list += [CrossState(state=x) for x in cross_points]

        sf = f", start from {int(start_from)}" if start_from else ''
        self._log.debug("Search for candidates for the cross syscalls: "
                        f"{[int(x) for x in metastate.cross_points]} "
                        f"(last sync point {int(cp)}{sf})")
        for cross_state in cross_list:
            c_state = cross_state.state
            if self.with_times.get():
                time = self._get_relative_time(cp, metastate.cpu_id,
                                               c_state)
            else:
                time = TimeRange(up=0, to=0)

            if self._mstg.type_map[c_state] & CrossExecState.irq:
                # we have a core local interrupt, so the candidate
                # set is empty and we need to pair with ourselves
                it = [TimeCandidateSet(candidates=[],
                                       pred_cps=[TimedVertex(vertex=cp,
                                                             range=time)],
                                       root_cp=cp)]
            else:
                it = self._find_timed_states(c_state, cp, time,
                                             start_from=start_from,
                                             only_root=only_root)

            for cands in it:
                root_cp = cands.root_cp
                self._log.debug(
                    f"Evaluating cross point between {int(c_state)} and "
                    f"{[int(x) for x in cands.candidates]}")
                existing_sp = self._get_existing_sync_point(
                    c_state, cands.candidates)
                if existing_sp:
                    self._log.debug(
                        f"Link from {int(root_cp)} to existing cross point "
                        f"{int(existing_sp)} ({int(c_state)} with "
                        f"{[int(x) for x in cands.candidates]}).")
                    reeval.update(self._link_sp_with_pred_sps(existing_sp, cands.root_cp, cands.pred_cps, exists=True))
                else:
                    new_sp = self._create_sync_point(
                        c_state, cands.candidates, root_cp, cands.pred_cps, cross_state.irq)
                    exits += self._evaluate_syncpoint(new_sp, root_cp, cross_state)

                    # trigger a reevaluation if necessary
                    current_cpus = set(self._mstg.cross_point_map[cp])
                    new_cpus = set(self._mstg.cross_point_map[new_sp])
                    unsynced_cpus = current_cpus - new_cpus

                    if unsynced_cpus:
                        sp_graph = self._get_sp_graph()
                        new_cps = self._get_constrained_sps(
                            sp_graph, unsynced_cpus, Range(start=new_sp, end=None))
                        on_stack = defaultdict(list)
                        for core, ran in new_cps.items():
                            on_stack[ran.range.start].append(core)
                        for i_cp, cores in on_stack.items():
                            self._log.debug(
                                f"Current cross point {int(new_sp)} may add "
                                "more pairing possibilities to the cross syscall "
                                f"for CPUs {cores} (starting from {int(i_cp)})"
                            )
                            reeval.add((i_cp,
                                        NewNodeReevaluation(
                                            from_cp=new_sp,
                                            cores=frozenset(cores))))
        return exits, reeval

    def create_mstg(self):
        """Prepares a MSTG object.

        It contains of the MSTGraph itself together with various analysis
        specific property maps.
        """
        # create graph
        mstg = MSTGraph()

        # store the affected other cores of this syscall
        cross_core_map = mstg.new_vp("vector<int32_t>")

        # mark states with a length and which triggers a cross core action
        # contains a mask of CrossExecState
        type_map = mstg.new_vp("int")

        # cores which are connected with a cross point
        cross_point_map = mstg.new_vp("vector<int32_t>")

        return MSTG(g=mstg,
                    cross_core_map=cross_core_map,
                    type_map=type_map,
                    cross_point_map=cross_point_map)

    def _reevaluate_cross_point(self, cp, reeval_info):
        """Perform a reevaluation of cp which was already evaluated.

        reeval_info gives additional hints why the reevaluation is needed.
        """
        if isinstance(reeval_info, NewNodeReevaluation):
            start_from = reeval_info.from_cp
            cores = reeval_info.cores
            kwargs = {"start_from": start_from}
            debug = f" starting from {int(start_from)}"
        else:
            root = reeval_info.root
            cores = self._mstg.cross_point_map[cp]
            kwargs = {"only_root": root}
            debug = f" evaluating only {int(root)}"

        self._log.debug(
            f"Node {int(cp)} is already evaluated but some new "
            f"knowledge exists. Reevaluating CPUs {list(cores)} "
            f"{debug}.")

        st2sy = self._mstg.g.edge_type(MSTType.st2sy)
        stack = []
        reevaluates = set()
        for cpu_id in cores:
            sts = GraphView(st2sy, efilt=st2sy.ep.cpu_id.fa == cpu_id)
            entry = single_check(sts.vertex(cp).out_neighbors())
            to_stack, reeval = self._find_new_cps(
                cp,
                Metastate(state=self._mstg.g.get_metastate(entry),
                          entry=entry,
                          new_entry=False,
                          is_new=False,
                          cross_points=[],
                          irqs=[],
                          cpu_id=cpu_id),
                **kwargs)
            stack.extend(to_stack)
            reevaluates |= reeval
        return stack, reevaluates

    def _calculate_new_metastates(self, cp):
        """Calculate new metastates from an existing cross point."""
        states = self._get_single_core_states(self._mstg.g.vp.state[cp])
        mstg = self._mstg.g

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

        return metastates

    def run(self):
        entry_label = self.entry_point.get()
        if not entry_label:
            self._fail("Entry point must be given.")
        self._log.info(f"Analyzing entry point: '{entry_label}'")

        self._mstg = self.create_mstg()
        mstg = self._mstg.g

        # map between a state (the hash of it) and the vertex in the MSTG
        self._state_map = {}

        # initialize stack
        cross_point = self._get_initial_state()

        # stack consisting of the current exit cross point
        stack = [(cross_point, None)]
        # store cross_point that need a reevaluation
        reevaluates = set()

        # actual algorithm
        counter = 0
        while stack:
            # cp: the current cross point
            # reeval_info: information if a reevaluation is needed, of type
            #              NewNodeReevaluation or NewEdgeReevaluation or None
            cp, reeval_info = stack.pop(0)
            if (cp, reeval_info) in reevaluates:
                # we don't need to analyse cross points that are reevaluated
                # later on anyway.
                self._log.debug(f"Skip {int(cp)}. It is already marked for "
                                "reevaluation.")
                continue

            # if counter == 8:
            #     self._fail("foo")

            self._log.debug(
                f"Round {counter:3d}, handle cross point {int(cp)}. "
                f"Stack with {len(stack)} state(s)")
            if self.dump.get():
                self._dump_mstg(extra=f"round.{counter:03d}")
            counter += 1

            if reeval_info:
                t_stack, reevals = self._reevaluate_cross_point(cp,
                                                                reeval_info)
                stack.extend([(x, None) for x in t_stack])
                reevaluates.update(reevals)
                continue

            # handle current cross point
            metastates = self._calculate_new_metastates(cp)

            if self.dump.get():
                self._dump_mstg(extra=f"round.{counter:03d}.wm")

            # handle the next cross points
            # we need a new pairing for all CPUs, if somewhere is a new entry,
            # or the entire metastate is_new
            new_entry = any([x.new_entry for x in metastates.values()])
            is_new = any([x.is_new for x in metastates.values()])

            # Check for shortcut. If the metastates are not new and we find
            # another already existing cross point that results in the exact
            # same metastates than this cross point, we can just link its
            # already existing outgoing edges.
            neighbor_found_and_linked = False
            if not (new_entry or is_new):
                common_cps = self._find_common_crosspoints(metastates) - {cp}
                for common_cp in common_cps:
                    if set(self._mstg.cross_point_map[common_cp]) == set(
                            metastates.keys()):
                        self._log.debug(
                            "Metastate is not new. Found an equal common "
                            f"cp {int(common_cp)}."
                        )
                        self._link_neighbor_crosspoint(cp, common_cp)
                        neighbor_found_and_linked = True

            # we don't find a neighbor so do a full pairing across all
            # metastates
            if not neighbor_found_and_linked:
                for cpu_id, metastate in metastates.items():
                    self._log.debug(
                        f"Evaluate cross points of metastate {metastate}.")
                    to_stack, reeval = self._find_new_cps(cp, metastate)
                    stack.extend([(x, None) for x in to_stack])
                    reevaluates.update(reeval)

            # The stack is empty. Copy the cross points that need a
            # reevaluation back to the stack and perform the next round.
            if not stack:
                self._log.debug("Stack empty. Beginning with reevaluations")
                stack.extend(list(set(reevaluates)))
                reevaluates.clear()

        self._log.info(f"Analysis needed {counter} iterations.")

        self._graph.mstg = mstg

        self._log.debug(
            "Cache of find_timed_predecessor: "
            f"{self._find_timed_predecessor.cache_info()}"
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
            self._step_manager.chain_step({
                "name": "Printer",
                "dot": self.dump_prefix.get() + "mstg.sps.dot",
                "graph_name": "SP MSTG",
                "subgraph": "sp_mstg",
            })
        step_data = {"rounds": counter,
                     "vertices": len(list(mstg.vertices())),
                     "edges": len(list(mstg.edges())),
                     }
        self._set_step_data(step_data)
