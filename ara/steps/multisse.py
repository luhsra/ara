"""Multicore SSE analysis."""

from .option import Option, String, Bool
from .step import Step
from .util import open_with_dirs
from .printer import mstg_to_dot, sp_mstg_to_dot
from .cfg_traversal import Visitor, run_sse
from .multisse_helper.common import CrossExecState, FakeEdge, find_irqs, find_cross_syscalls
from .multisse_helper.constrained_sps import get_constrained_sps
from .multisse_helper.equations import TimeRange
from .multisse_helper.pairing_partner_search import search_for_pairing_partners, Range, TimeCandidateSet
from .multisse_helper.wcet_calculation import TimingCalculator, get_time, set_time
from ara.graph import MSTGraph, StateType, MSTType, single_check, edge_types
from ara.util import pairwise
from ara.os.os_base import OSState, CPUList

import os.path
import graph_tool

from collections import defaultdict
from dataclasses import dataclass, field
from functools import reduce
from graph_tool.topology import label_out_component, shortest_path, all_paths
from graph_tool import GraphView
from itertools import product, chain, islice
from typing import List, Dict, Set, Tuple, Optional


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
    cross_syscalls: List[graph_tool.Vertex]  # new cross points of Metastate
    irqs: List[Tuple[graph_tool.Vertex, int]]  # new (cross) irqs of MS
    cpu_id: int  # cpu_id of this state

    def __repr__(self):
        return ("Metastate("
                f"state: {int(self.state)}, "
                f"entry: {int(self.entry)}, "
                f"new_entry: {self.new_entry}, "
                f"is_new: {self.is_new}, "
                f"cross_syscalls: {[int(x) for x in self.cross_syscalls]}, "
                f"irqs: {[(int(x), y) for x, y in self.irqs]}, "
                f"cpu_id: {self.cpu_id})")


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
        cross_syscalls = list()
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
                    cross_syscalls.append(v)
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
                cross_syscalls=cross_syscalls,
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
            cross_syscalls = find_cross_syscalls(self._mstg.g,
                                                 self._mstg.type_map,
                                                 m_state, init_v)

        for state in to_assign_states:
            e = mstg.add_edge(m_state, state)
            mstg.ep.type[e] = MSTType.m2s
            mstg.ep.cpu_id[e] = cpu_id

        if self.dump.get():
            self._dump_mstg(extra=f"metastate.{int(m_state)}")

        return Metastate(
            state=m_state,
            cross_syscalls=cross_syscalls,
            irqs=irqs,
            cpu_id=cpu_id,
            entry=init_v,
            new_entry=True,
            is_new=is_new,
        )

    def _find_root_cross_points(self, sp, current_core, affected_cores, only_root=None):
        """Find all last SPs that contains all needed cores.

        Returns a list of paths. Each path starts at a root node and contains
        all exit nodes up to the current one.

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
            ret.extend(paths)
        return ret

    def _get_sp_graph(self):
        """Return a graph consisting only of SPs that follow in the time domain."""
        return GraphView(
                self._mstg.g.vertex_type(StateType.entry_sync,
                                         StateType.exit_sync),
                efilt=self._mstg.g.ep.type.fa != MSTType.sy2sy)

    def _find_pairing_partners(self, cross_state, last_sp,
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

        time = None
        if self.with_times.get():
            time = self._timings.get_relative_time(last_sp, current_core,
                                                   cross_state)

        if self._mstg.type_map[cross_state] & CrossExecState.irq:
            # we have a core local interrupt, so the candidate
            # set is empty and we need to pair with ourselves
            tr = TimeRange(up=0, to=0)
            if time:
                tr = time.get_interval_for(FakeEdge(src=last_sp, tgt=cross_state))
            return [TimeCandidateSet.set_without_candidates(last_sp, tr)]

        root_paths = self._find_root_cross_points(last_sp, current_core,
                                                  affected_cores,
                                                  only_root=only_root)

        combinations = set()
        for path in root_paths:
            self._log.debug("Find pairing candidates for node %d (time: %s) "
                            "starting from root SP %d", cross_state, time, path[0])
            # 2. For each root cross point get the actual affected following
            #    cross points.
            #    They can be restricted by the set of affected cores or by an
            #    explicitly given starting point.
            starts = []
            if start_from:
                starts.append(Range(start=start_from, end=None))
            combs = search_for_pairing_partners(self._mstg.g,
                                                self._mstg.cross_point_map,
                                                self._mstg.type_map,
                                                path,
                                                cross_state,
                                                affected_cores,
                                                starts,
                                                timing_calc=self._timings,
                                                time=time)
            combinations.update(combs)

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
            cross_syscalls = find_cross_syscalls(self._mstg.g,
                                                 self._mstg.type_map,
                                                 metastate.state,
                                                 metastate.entry)
            irqs = find_irqs(self._mstg.g, self._mstg.type_map,
                             metastate.state, metastate.entry)
        else:
            cross_syscalls = metastate.cross_syscalls
            irqs = metastate.irqs

        cross_list += [CrossState(state=x, irq=y) for x, y in irqs]
        cross_list += [CrossState(state=x) for x in cross_syscalls]

        sf = f", start from {int(start_from)}" if start_from else ''
        self._log.debug("Search for candidates for the cross syscalls: "
                        f"{[int(x) for x in metastate.cross_syscalls]} "
                        f"(last sync point {int(cp)}{sf})")
        for cross_state in cross_list:
            c_state = cross_state.state

            it = self._find_pairing_partners(c_state, cp,
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
                        new_cps = get_constrained_sps(
                            sp_graph, self._mstg.cross_point_map,
                            unsynced_cpus, Range(start=new_sp, end=None))
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
                          cross_syscalls=[],
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

        if self.with_times.get():
            self._timings = TimingCalculator(mstg, self._mstg.type_map,
                                             self._mstg.cross_point_map)
        else:
            self._timings = None

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
                f"Round {counter:3d}, handle SP {int(cp)}. "
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
