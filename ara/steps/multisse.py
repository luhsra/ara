# SPDX-FileCopyrightText: 2020 Fredo Nowak
# SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2022 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2023 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Multicore SSE analysis."""
import copy
import os.path

from collections import defaultdict
from dataclasses import dataclass, field
from functools import reduce
from itertools import chain, islice
from typing import List, Dict, Set

import graph_tool

from graph_tool.topology import all_paths, shortest_path

from ara.graph import (MSTGraph, StateType, MSTType, CallPath, single_check,
                       edge_types)
from ara.util import pairwise, has_path
from ara.os.os_base import (OSState, CPUList, CPU, IRQ, CrossCoreAction,
                            IRQContext, TaskStatus)
from ara.os.os_util import set_next_abb

from .option import Option, String, Bool
from .step import Step
from .util import open_with_dirs
from .printer import mstg_to_dot, sp_mstg_to_dot
from .cfg_traversal import Visitor, run_sse
from .multisse_helper.common import (CrossExecState, FakeEdge,
                                     find_cross_syscalls)
from .multisse_helper.constrained_sps import get_constrained_sps
from .multisse_helper.equations import TimeRange
from .multisse_helper.pairing_partner_search import (
    search_for_pairing_partners, Range, TimeCandidateSet)
from .multisse_helper.wcet_calculation import (TimingCalculator,
                                               set_time)


@dataclass(frozen=True)
class NewNodeReevaluation:
    """Store necessary data for the reevaluation of a new node."""
    from_sp: graph_tool.Vertex
    cores: Set[int]


@dataclass(frozen=True)
class NewEdgeReevaluation:
    """Store necessary data for the reevaluation of a new edge."""
    root: graph_tool.Vertex  # the root sync point


@dataclass
class IRQCPU(CPU):
    irq: IRQ
    reference_cpu_id: int

    def __hash__(self):
        return hash((self.irq, super().__hash__()))

    def copy(self):
        new_ac = None if not self.analysis_context else self.analysis_context.copy()
        return IRQCPU(id=self.id,
                      irq_on=self.irq_on,
                      control_instance=self.control_instance,
                      abb=self.abb,
                      call_path=copy.copy(self.call_path),
                      analysis_context=new_ac,
                      exec_state=self.exec_state,
                      irq=self.irq,
                      reference_cpu_id=self.reference_cpu_id)


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
    cross_syscalls: List[graph_tool.Vertex]  # new sync points of Metastate
    cpu_id: int  # cpu_id of this state

    def __repr__(self):
        return ("Metastate("
                f"state: {int(self.state)}, "
                f"entry: {int(self.entry)}, "
                f"new_entry: {self.new_entry}, "
                f"is_new: {self.is_new}, "
                f"cross_syscalls: {[int(x) for x in self.cross_syscalls]}, "
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
                           self.mstg.edge(src, self.mstg.get_entry_sp(tgt),
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
    sync_point_map: graph_tool.VertexPropertyMap


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
        cpu_idx = max([x.id for x in os_state.cpus]) + 1
        instances = os_state.instances
        # add interrupts
        for irq in self._graph.os.get_interrupts(instances,
                                                 cfg=self._graph.cfg):
            # every irq gets an own CPU
            cur_abb = self._graph.cfg.get_entry_abb(irq.function)
            irq_cpu = IRQCPU(id=cpu_idx,
                             irq=irq,
                             reference_cpu_id=irq.cpu_id,
                             irq_on=True,
                             control_instance=instances.get_node(irq),
                             abb=cur_abb,
                             call_path=CallPath(),
                             exec_state=CrossExecState.computation,
                             analysis_context=None)
            os_state.cpus[irq_cpu.id] = irq_cpu
            irq.cpu_id = irq_cpu.id
            irq_ctx = IRQContext(status=TaskStatus.running,
                                 abb=None,  # already "coded" in the CPU
                                 call_path=CallPath(),
                                 dyn_prio=[1])
            os_state.context[irq] = irq_ctx
            cpu_idx += 1

        # initial sync point
        mstg = self._mstg.g
        sp = mstg.add_vertex()
        mstg.vp.type[sp] = StateType.exit_sync
        mstg.vp.state[sp] = os_state
        self._mstg.sync_point_map[sp] = [x.id for x in os_state.cpus]
        self._log.debug(f"Add initial sync point {int(sp)}")

        return sp

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
            HANDLE_INTERRUPTS = False
            CFG_CONTEXT = None

            @staticmethod
            def get_initial_state():
                return entry

            @staticmethod
            def cross_core_action(state, cpu_ids, irq=None):
                assert irq is None, "Wrong interrupt model."
                v = self._state_map[hash(state)]
                self._mstg.cross_core_map[v] = cpu_ids
                self._mstg.type_map[v] = CrossExecState.cross_syscall
                cross_syscalls.append(v)

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

        # we have introduced the fake interrupts so we must handle it with a
        # fake OS
        class IRQOS(self._graph.os):
            @staticmethod
            def interpret(graph, state, cpu_id, categories):
                if isinstance(state.cpus[cpu_id], IRQCPU):
                    raise CrossCoreAction(
                        {state.cpus[cpu_id].reference_cpu_id, })
                return self._graph.os.interpret(graph, state, cpu_id,
                                                categories=categories)

        # add initial state
        is_new, init_v = _add_state(entry)

        # early return if state already evaluated
        if not is_new:
            metastate = self._mstg.g.get_metastate(init_v)
            return Metastate(
                state=metastate,
                cpu_id=cpu_id,
                cross_syscalls=cross_syscalls,
                entry=init_v,
                new_entry=False,
                is_new=False,
            )

        to_assign_states.add(init_v)

        run_sse(
            self._graph,
            IRQOS,
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
            cpu_id=cpu_id,
            entry=init_v,
            new_entry=True,
            is_new=is_new,
        )

    def _get_only_affected(self, path, affected_cores):
        """Filter an SP path so it only contains SP that synchronize any of
        the affected cores.
        """
        return tuple([
            int(x)
            for x in path
            if set(self._mstg.sync_point_map[x]) & set(affected_cores)
        ])

    def _find_root_sync_points(self, sp, current_core, affected_cores, only_root=None):
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
        g = graph_tool.GraphView(g2, vfilt=lambda v:
                                 g2.vp.cpu_id[v] == current_core
                                 if g2.vp.type[v] == StateType.metastate
                                 else True)

        sp_graph = self._get_sp_graph()

        # property map to indicate for every SP if it affects the current_core
        not_core = sp_graph.new_vp("bool", val=False)
        for v in sp_graph.vertices():
            if current_core not in self._mstg.sync_point_map[v]:
                not_core[v] = True

        sp_follow = mstg.edge_type(MSTType.follow_sync, MSTType.sy2sy)
        follow_sync = mstg.edge_type(MSTType.follow_sync)
        # self._log.debug(f"FR: {int(sp)}, {current_core}, {affected_cores}")

        # calculate roots and the successors for each node
        root_sps = []
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

            cores = set(self._mstg.sync_point_map[cur_sp])
            if cores >= wanted_cores:
                root_sps.append(cur_sp)
                continue

            entry_sp = g.vertex(mstg.get_entry_sp(cur_sp))
            assert sp_graph.edge(entry_sp, cur_sp)
            for n in chain.from_iterable(map(lambda x: x.in_neighbors(),
                                             entry_sp.in_neighbors())):
                assert mstg.vp.type[n] == StateType.exit_sync
                if sp_follow.edge(n, entry_sp):
                    # it may be that to SPs are connected via a metastate but
                    # do not have a direct follow_edge between them but several
                    # follow edges that synchronize other cores. Check for a
                    # path between them under this conditions.
                    if not follow_sync.edge(n, entry_sp):
                        lc = not_core.copy()
                        lc[entry_sp] = True
                        lc[n] = True
                        nc = graph_tool.GraphView(sp_graph, vfilt=lc)
                        if not has_path(nc, n, entry_sp):
                            continue
                    succs[n].add(cur_sp)
                    stack.append(n)

        # self._log.debug(f"FR: roots {[int(x) for x in root_sps]}")
        # self._log.debug(f"FR: succs {sorted([(int(x), [int(z) for z in y]) for x, y in succs.items()])}")
        # self._log.debug(f"Current core: {current_core}")
        if only_root:
            root_sps = {only_root} & set(root_sps)
            self._log.debug(f"Evaluation only {[int(x) for x in root_sps]} as "
                            f"root SP. We only inspect {int(only_root)}.")

        # calculate all paths to the roots
        # We do not need the root SPs only, we also need all paths that lead
        # to them.The algorithm starts at the root node and iterates all
        # successors that was stored previously. Whenever multiple successors
        # exist, the path is split into two.
        ret = []
        for root in root_sps:
            paths = [[root]]
            i = 0
            while i < len(paths):
                self._log.debug(f"Calculating root paths, index: {i}, paths: {len(paths)}")
                assert len(paths) < 50000, "Too much"
                path = paths[i]
                last = path[-1]
                if last == sp:
                    # the path is ready
                    i += 1
                    continue
                nexts = set(map(int, succs[last]))
                # remove loops in the path
                nexts -= set(map(int, path))

                # calculate all paths between the last (the current end of the
                # path) and nex (the successor given by succs)
                # append all those paths to next_paths

                # self._log.debug(f"Path: {[int(x) for x in path]}")
                # self._log.debug(f"Cores of Path: {[list(self._mstg.sync_point_map[x]) for x in path]}")
                # self._log.debug(f"Nexts: {[int(x) for x in nexts]}")
                if not nexts:
                    # invalid path
                    paths[i] = None
                    i += 1
                    continue
                next_paths = []
                for nex in nexts:
                    # It is possible that the current path and nex are not
                    # connected via follow_sync edges because they are sharing
                    # a sy2sy edge only. However, in this case, there must be
                    # at least one path of follow_sync edges between them. We
                    # need to find the paths in this case.
                    entry_sp = mstg.get_entry_sp(nex)
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
                    # extent next_paths by all paths consisting of exit SPs
                    # without the first element going from last to nex
                    nc = graph_tool.GraphView(sp_graph, vfilt=lc)
                    nnp = map(
                        lambda p: list(islice(
                                filter(lambda v: mstg.vp.type[v] == StateType.exit_sync, p),
                                1,
                                None)),
                        all_paths(nc, last, nex))
                    # the paths does not contain the current core but may go
                    # about SPs that does not contain any affected core. The
                    # order of these SPs does not have any effect therefore we
                    # filter them out (deduplicate and keep only one)
                    nnp_dedups = {
                        self._get_only_affected(path, affected_cores): path
                        for path in sorted(nnp,
                                           key=lambda x: len(x),
                                           reverse=True)
                    }
                    next_paths.extend(nnp_dedups.values())
                assert next_paths, "No paths between last and all nexts. Not possible."
                # put all other elements to new paths
                for n in next_paths[1:]:
                    paths.append(list(chain(path, n)))
                # put first element to the current path
                path.extend(next_paths[0])
            ret.extend(
                filter(lambda x: x is not None and len(x) == len(set(x)),
                       paths)
            )
        # additional sanity check
        for path in ret:
            assert len(path) == len(set(path))
        return ret

    def _get_sp_graph(self):
        """Return a graph consisting only of SPs that follow in the time domain."""
        g = self._mstg.g.vertex_type(StateType.entry_sync, StateType.exit_sync)
        return edge_types(g, self._mstg.g.ep.type, MSTType.en2ex,
                          MSTType.follow_sync)

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
        # 1. Find all root sync points (which forms the root for the
        #    following searches)
        mstg = self._mstg.g
        affected_cores = self._mstg.cross_core_map[cross_state]
        current_core = mstg.vp.cpu_id[cross_state]

        time = None
        if self.with_times.get():
            time = self._timings.get_relative_time(last_sp, cross_state)

        if self._mstg.type_map[cross_state] & CrossExecState.irq:
            # we have a core local interrupt, so the candidate
            # set is empty and we need to pair with ourselves
            tr = TimeRange(up=0, to=0)
            if time:
                tr = time.get_interval_for(FakeEdge(src=last_sp, tgt=cross_state))
            return [TimeCandidateSet.set_without_candidates(last_sp, tr)]

        root_paths = self._find_root_sync_points(last_sp, current_core,
                                                 affected_cores,
                                                 only_root=only_root)

        combinations = set()
        self._log.info("New pairing partner search over %d paths",
                       len(root_paths))
        # self._log.debug(f"Cur core {current_core}")
        # self._log.debug(f"Affected cores {list(affected_cores)}")
        # for path in root_paths:
        #     self._log.debug([int(x) for x in path])
        #     self._log.debug([(int(x), set(self._mstg.sync_point_map[x])) for x in path])
        assert len(root_paths) < 20000, "Too much"
        for path in root_paths:
            # self._log.debug([int(x) for x in path])
            self._log.debug("Find pairing candidates for node %d (time: %s) "
                            "starting from root SP %d", cross_state, time, path[0])
            # 2. For each root sync point get the actual affected following
            #    sync points.
            #    They can be restricted by the set of affected cores or by an
            #    explicitly given starting point.
            starts = []
            if start_from:
                starts.append(Range(start=start_from, end=None))
            combs = search_for_pairing_partners(self._mstg.g,
                                                self._mstg.sync_point_map,
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

    def _create_multicore_state(self, in_sps, root):
        """Construct a multi core state out of several single core states and
        one root node."""
        os = self._graph.os
        mstg = self._mstg.g

        states = []
        for v in in_sps:
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
        return multi_state

    def _create_sync_point(self, multi_state, cross_state, timed_states, root_sp, pred_sps):
        """Create a new synchronisation point.

        It synchronizes cross_state with timed_states.
        Its root is root_sp. Its predecessors in time are pred_sps.

        It returns the new SP.
        """
        mstg = self._mstg.g
        new_sp = mstg.add_vertex()
        mstg.vp.type[new_sp] = StateType.entry_sync
        mstg.vp.state[new_sp] = multi_state
        self._log.debug(
            f"Add new entry sync point {int(new_sp)} between "
            f"{int(cross_state)} and {[int(x) for x in timed_states]}")

        # link SP with states
        cpu_ids = set()
        for src in chain([cross_state], timed_states):
            e = mstg.add_edge(src, new_sp)
            mstg.ep.type[e] = MSTType.st2sy
            metastate = mstg.get_metastate(src)
            cpu_id = mstg.vp.cpu_id[metastate]
            mstg.ep.cpu_id[e] = cpu_id
            cpu_ids.add(cpu_id)
            m2sy_edge = mstg.add_edge(metastate, new_sp)
            mstg.ep.type[m2sy_edge] = MSTType.m2sy
            mstg.ep.cpu_id[m2sy_edge] = cpu_id

        # irq handling
        cpu = mstg.vp.state[cross_state].cpus.one()
        if isinstance(cpu, IRQCPU):
            syscall_edge = mstg.edge(cross_state, new_sp)
            assert mstg.ep.type[syscall_edge] == MSTType.st2sy
            mstg.ep.irq[syscall_edge] = cpu.irq.id

        self._mstg.sync_point_map[new_sp] = cpu_ids

        # link SP with other SPs
        self._link_sp_with_pred_sps(new_sp, root_sp, pred_sps)

        return new_sp

    def _evaluate_syncpoint(self, sp, cpu_id, multi_state,
                            irq_exit_state=None):
        """Evaluate an entry sync point.

        The algorithm in principle works as following:
        Interpret the state if necessary.
        Make an exit sync point of every outcome.

        Return a list of exit sync points.
        """
        os = self._graph.os
        mstg = self._mstg.g
        sp = mstg.vertex(sp)

        # let the model interpret the created multicore state
        new_states = []
        if irq_exit_state:
            new_states = [irq_exit_state]
        else:
            for new_state in os.interpret(self._graph, multi_state, cpu_id):
                os.schedule(new_state)
                new_states.append(new_state)

        # add follow up sync points for the outcome
        ret = []
        for new_state in new_states:
            exit_sp = mstg.add_vertex()
            mstg.vp.type[exit_sp] = StateType.exit_sync
            self._log.debug(f"Add exit sync point {int(exit_sp)}")

            e = mstg.add_edge(sp, exit_sp)
            mstg.ep.type[e] = MSTType.en2ex
            spm = self._mstg.sync_point_map
            spm[exit_sp] = spm[sp]

            # store state in sync point
            mstg.vp.state[exit_sp] = new_state

            ret.append(exit_sp)

        return ret

    def _find_common_sync_points(self, metastates):
        """Return all common sync points of this specific set of metastates."""
        st2sy = self._mstg.g.edge_type(MSTType.st2sy)
        sps_lists = [
            set(st2sy.vertex(x.entry).in_neighbors())
            for x in metastates.values()
        ]
        return reduce(lambda a, b: a & b, sps_lists)

    def _link_neighbor_syncpoint(self, sp, neighbor_sp):
        """Make SP to a neighbor of neighbor_sp.

        The idea is that a neighbor sp results in the same set of metastates
        so all its outgoing edges can be overtaken.
        Additionally, the neighbors are marked as such with a special edge.
        """
        mstg = self._mstg.g

        # mark as neighbor
        e = mstg.edge(neighbor_sp, sp, add_missing=True)
        mstg.ep.type[e] = MSTType.sync_neighbor

        # sync edges
        sy2sy = mstg.edge_type(MSTType.sy2sy)
        for v in list(sy2sy.vertex(neighbor_sp).out_neighbors()):
            self._log.debug(
                f"Neighbor: Link sy2sy edge: {int(sp)} -> {int(v)}")
            new_e = sy2sy.edge(mstg.vertex(sp),
                               mstg.vertex(v),
                               add_missing=True)
            mstg.ep.type[new_e] = MSTType.sy2sy
        follow_sync = mstg.edge_type(MSTType.follow_sync)
        for v in list(follow_sync.vertex(neighbor_sp).out_neighbors()):
            self._log.debug(
                f"Neighbor: Link follow_sync edge: {int(sp)} -> {int(v)}")
            new_e = follow_sync.edge(mstg.vertex(sp),
                                     mstg.vertex(v),
                                     add_missing=True)
            mstg.ep.type[new_e] = MSTType.follow_sync

    def _get_existing_sync_point(self, cross_state, timed_candidates):
        """Return an existing sync point.

        It has to link exactly cross_state and timed_candidates.
        """
        st2sy = self._mstg.g.edge_type(MSTType.st2sy)
        sps_lists = [
            set(st2sy.vertex(x).out_neighbors())
            for x in chain([cross_state], timed_candidates)
        ]
        sps = reduce(lambda a, b: a & b, sps_lists)
        if len(sps) == 0:
            return None
        # More than one synchronisation point to this states is forbidden.
        return single_check(sps)

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
                self._log.debug(f"Add follow_sync edge: {str(m2sy_edge)}")
                mstg.ep.type[m2sy_edge] = MSTType.follow_sync
                set_time(mstg.ep.bcet, m2sy_edge, pred_sp.range.up)
                set_time(mstg.ep.wcet, m2sy_edge, pred_sp.range.to)

        return reeval

    def _find_new_sps(self, sp, metastate, start_from=None, only_root=None):
        """Try to find the next sync points coming from metastate.

        sp         -- root sync point (entry for the metastate)
        metastate  -- the metastate for which new SPs are searched
        start_from -- starting sync point (narrows the search space, make
                      reevaluations more efficient)
        only_root  -- respect only this SP as root SP.

        The function returns a pair:
        1. A list of new exit sync points.
        2. A Set of sync points that need a reevaluation.
           This is a list of pairs, which denotes the sync point and the
           reason why a reevaluation is needed.
        """
        # container for the return values
        # list of new exit sync points
        exits = []
        # list of sync points that need reevaluation
        reeval = set()

        if not metastate.is_new:
            cross_syscalls = find_cross_syscalls(self._mstg.g,
                                                 self._mstg.type_map,
                                                 metastate.state,
                                                 metastate.entry)
        else:
            cross_syscalls = list(metastate.cross_syscalls)

        sf = f", start from {int(start_from)}" if start_from else ''
        self._log.debug("Search for candidates for the cross syscalls: "
                        f"{[int(x) for x in metastate.cross_syscalls]} "
                        f"(last sync point {int(sp)}{sf})")
        while cross_syscalls:
            cross_state = cross_syscalls.pop(0)
            it = self._find_pairing_partners(cross_state, sp,
                                             start_from=start_from,
                                             only_root=only_root)

            for cands in it:
                root_sp = cands.root_sp
                self._log.debug(
                    f"Evaluating sync point between {int(cross_state)} and "
                    f"{[int(x) for x in cands.candidates]}")
                existing_sp = self._get_existing_sync_point(
                    cross_state, cands.candidates)
                if existing_sp:
                    self._log.debug(
                        f"Link from {int(root_sp)} to existing sync point "
                        f"{int(existing_sp)} ({int(cross_state)} with "
                        f"{[int(x) for x in cands.candidates]}).")
                    reeval.update(self._link_sp_with_pred_sps(existing_sp, cands.root_sp, cands.pred_sps, exists=True))
                else:
                    # first create the multicore state
                    # if this is an IRQ triggered SP, it can be incomplete
                    multi_state = self._create_multicore_state(
                        [cross_state] + list(cands.candidates), root_sp)
                    sc_cpu = self._mstg.g.vp.state[cross_state].cpus.one()

                    # interrupt handling
                    irq_exit_state = None
                    if isinstance(sc_cpu, IRQCPU):
                        try:
                            os = self._graph.os
                            irq_exit_state = os.handle_irq(self._graph,
                                                           multi_state,
                                                           sc_cpu.reference_cpu_id,
                                                           sc_cpu.irq)
                            if irq_exit_state is None:
                                # just skip the rest, the interrupt does not
                                # do anything, so we omit the SP
                                continue
                            # advance the virtual interrupt CPU
                            set_next_abb(irq_exit_state, sc_cpu.id)
                            os.schedule(irq_exit_state)
                        except CrossCoreAction as cca:
                            # we need other pairing partners
                            ccm = self._mstg.cross_core_map
                            ccm[cross_state] = set(chain(ccm[cross_state],
                                                         cca.cpu_ids))
                            # reevaluate
                            cross_syscalls.append(cross_state)
                            # We have the assumption here that every irq that
                            # needs an additional core as pairing partner (not
                            # just the one where the IRQ triggers) does that
                            # regardless where it interrupts (i.e. what the
                            # pairing partner is). Therefore we quit the
                            # further pairing process here to newly begin with
                            # an extended set of affected cores. This holds for
                            # AUTOSAR interrupts, TODO: check, if this is the
                            # case for other operating systems as well.
                            break

                    new_sp = self._create_sync_point(
                        multi_state, cross_state, cands.candidates, root_sp, cands.pred_sps)
                    exits += self._evaluate_syncpoint(new_sp, sc_cpu.id,
                                                      multi_state,
                                                      irq_exit_state=irq_exit_state)

                    # trigger a reevaluation if necessary
                    current_cpus = set(self._mstg.sync_point_map[sp])
                    new_cpus = set(self._mstg.sync_point_map[new_sp])
                    unsynced_cpus = current_cpus - new_cpus

                    if unsynced_cpus:
                        sp_graph = self._get_sp_graph()
                        new_sps = get_constrained_sps(
                            sp_graph, self._mstg.sync_point_map,
                            unsynced_cpus, Range(start=new_sp, end=None))
                        on_stack = defaultdict(list)
                        for core, ran in new_sps.items():
                            on_stack[ran.range.start].append(core)
                        for i_sp, cores in on_stack.items():
                            self._log.debug(
                                f"Current sync point {int(new_sp)} may add "
                                "more pairing possibilities to the cross syscall "
                                f"for CPUs {cores} (starting from {int(i_sp)})"
                            )
                            reeval.add((i_sp,
                                        NewNodeReevaluation(
                                            from_sp=new_sp,
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

        # cores which are connected with a sync point
        sync_point_map = mstg.new_vp("vector<int32_t>")

        return MSTG(g=mstg,
                    cross_core_map=cross_core_map,
                    type_map=type_map,
                    sync_point_map=sync_point_map)

    def _reevaluate_sync_point(self, sp, reeval_info):
        """Perform a reevaluation of SP which was already evaluated.

        reeval_info gives additional hints why the reevaluation is needed.
        """
        if isinstance(reeval_info, NewNodeReevaluation):
            start_from = reeval_info.from_sp
            cores = reeval_info.cores
            kwargs = {"start_from": start_from}
            debug = f" starting from {int(start_from)}"
        else:
            root = reeval_info.root
            cores = self._mstg.sync_point_map[sp]
            kwargs = {"only_root": root}
            debug = f" evaluating only {int(root)}"

        self._log.debug(
            f"Node {int(sp)} is already evaluated but some new "
            f"knowledge exists. Reevaluating CPUs {list(cores)} "
            f"{debug}.")

        st2sy = self._mstg.g.edge_type(MSTType.st2sy)
        stack = []
        reevaluates = set()
        for cpu_id in cores:
            sts = graph_tool.GraphView(st2sy,
                                       efilt=st2sy.ep.cpu_id.fa == cpu_id)
            entry = single_check(sts.vertex(sp).out_neighbors())
            to_stack, reeval = self._find_new_sps(
                sp,
                Metastate(state=self._mstg.g.get_metastate(entry),
                          entry=entry,
                          new_entry=False,
                          is_new=False,
                          cross_syscalls=[],
                          cpu_id=cpu_id),
                **kwargs)
            stack.extend(to_stack)
            reevaluates |= reeval
        return stack, reevaluates

    def _calculate_new_metastates(self, sp):
        """Calculate new metastates from an existing sync point."""
        states = self._get_single_core_states(self._mstg.g.vp.state[sp])
        mstg = self._mstg.g

        metastates = {}

        for cpu_id, state in states.items():
            metastate = self._run_sse(cpu_id, state)

            # add m2sy edge
            e = mstg.add_edge(sp, metastate.state)
            mstg.ep.type[e] = MSTType.m2sy
            mstg.ep.cpu_id[e] = metastate.cpu_id

            # add st2sy edge
            e = mstg.add_edge(sp, metastate.entry)
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
                                             self._mstg.sync_point_map)
        else:
            self._timings = None

        # map between a state (the hash of it) and the vertex in the MSTG
        self._state_map = {}

        # initialize stack
        sync_point = self._get_initial_state()

        # stack consisting of the current exit sync point
        stack = [(sync_point, None)]
        # store sync_point that need a reevaluation
        reevaluates = set()

        # actual algorithm
        counter = 0
        while stack:
            # sp: the current sync point
            # reeval_info: information if a reevaluation is needed, of type
            #              NewNodeReevaluation or NewEdgeReevaluation or None
            sp, reeval_info = stack.pop(0)
            if (sp, reeval_info) in reevaluates:
                # we don't need to analyse sync points that are reevaluated
                # later on anyway.
                self._log.debug(f"Skip {int(sp)}. It is already marked for "
                                "reevaluation.")
                continue

            # if counter == 8:
            #     self._fail("foo")

            self._log.debug(
                f"Round {counter:3d}, handle SP {int(sp)}. "
                f"Stack with {len(stack)} state(s)")
            if self.dump.get():
                self._dump_mstg(extra=f"round.{counter:03d}")
            counter += 1

            if reeval_info:
                t_stack, reevals = self._reevaluate_sync_point(sp,
                                                                reeval_info)
                stack.extend([(x, None) for x in t_stack])
                reevaluates.update(reevals)
                continue

            # handle current sync point
            metastates = self._calculate_new_metastates(sp)

            if self.dump.get():
                self._dump_mstg(extra=f"round.{counter:03d}.wm")

            # handle the next sync points
            # we need a new pairing for all CPUs, if somewhere is a new entry,
            # or the entire metastate is_new
            new_entry = any([x.new_entry for x in metastates.values()])
            is_new = any([x.is_new for x in metastates.values()])

            # Check for shortcut. If the metastates are not new and we find
            # another already existing sync point that results in the exact
            # same metastates than this sync point, we can just link its
            # already existing outgoing edges.
            neighbor_found_and_linked = False
            if not (new_entry or is_new):
                common_sps = self._find_common_sync_points(metastates) - {sp}
                for common_sp in common_sps:
                    if set(self._mstg.sync_point_map[common_sp]) == set(
                            metastates.keys()):
                        self._log.debug(
                            "Metastate is not new. Found an equal common "
                            f"sp {int(common_sp)}."
                        )
                        self._link_neighbor_syncpoint(sp, common_sp)
                        neighbor_found_and_linked = True

            # we don't find a neighbor so do a full pairing across all
            # metastates
            if not neighbor_found_and_linked:
                for _, metastate in metastates.items():
                    self._log.debug(
                        f"Evaluate sync points of metastate {metastate}.")
                    to_stack, reeval = self._find_new_sps(sp, metastate)
                    stack.extend([(x, None) for x in to_stack])
                    reevaluates.update(reeval)

            # The stack is empty. Copy the sync points that need a
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
