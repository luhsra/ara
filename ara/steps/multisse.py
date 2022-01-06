"""Multicore SSE analysis."""

from .option import Option, String
from .step import Step
from .printer import mstg_to_dot
from .cfg_traversal import Visitor, run_sse
from ara.graph import MSTGraph, StateType, MSTType, single_check
from ara.os.os_base import ExecState, OSState, CPUList

import os.path
import enum
import graph_tool
import dataclasses

from collections import defaultdict
from dataclasses import dataclass
from functools import reduce, lru_cache
from graph_tool.topology import label_out_component, dominator_tree, shortest_path
from graph_tool.search import bfs_search, BFSVisitor, StopSearch
from graph_tool import GraphView
from itertools import product, chain, permutations
from typing import List

# time counter for performance measures
c_debugging = 0  # in milliseconds

MAX_UPDATES = 2
MAX_STATE_UPDATES = 20
MIN_EMULATION_TIME = 200

sse_counter = 0


class ExecType(enum.IntEnum):
    has_length = 1
    cross_syscall = 2


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


@dataclasses.dataclass(frozen=True)
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


@dataclasses.dataclass(frozen=True)
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


@dataclasses.dataclass
class MSTG:
    g: MSTGraph
    cross_core_map: graph_tool.PropertyMap
    type_map: graph_tool.PropertyMap
    cross_point_map: graph_tool.PropertyMap


class MultiSSE(Step):
    """Run the MultiCore SSE."""

    entry_point = Option(name="entry_point",
                         help="system entry point",
                         ty=String())

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

            mstg = self._mstg.g
            v = mstg.add_vertex()
            mstg.vp.type[v] = StateType.state
            mstg.vp.state[v] = state
            mstg.vp.cpu_id[v] = cpu_id
            self._log.debug(f"Add State {state.id} (node {int(v)})")

            self._state_map[h] = v

            if state.cpus[cpu_id].exec_state & ExecState.with_time:
                self._mstg.type_map[v] = ExecType.has_length

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
        sync_graph = GraphView(
            self._mstg.g,
            efilt=((self._mstg.g.ep.type.fa &
                    (MSTType.follow_sync | MSTType.en2ex) > 0)))

        _, elist = shortest_path(sync_graph, orig_cp, new_cp)
        return len(elist) > 0

    def _iterate_search_tree(self, cp, orig_core, core, cps, other_paths,
                             used_cores):
        def log(msg, skip=True):
            if skip:
                return
            self._log.debug("i_s_t: " + msg)

        mstg = self._mstg.g
        sync_graph = mstg.edge_type(MSTType.m2sy, MSTType.en2ex)
        follow_sync = mstg.edge_type(MSTType.follow_sync)

        def good_edge(e):
            if mstg.ep.type[e] == MSTType.m2sy:
                return mstg.ep.cpu_id[e] == core
            return True

        core_graph = GraphView(sync_graph, efilt=good_edge)

        other_paths = set([(x.source(), x) for x in chain(*other_paths)])

        start = core_graph.vertex(cps[core].start)
        stack = [(start, [FakeEdge(src=None, tgt=start)])]
        visited = core_graph.new_vp("bool")
        visited_entries = defaultdict(list)
        log(f"Looking at CPU {int(core)} (orig CPU {int(orig_core)})")
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
                if tgt == cps[core].end:
                    log(f"Skip {e}. We are not branching to ourself.")
                    continue
                if core_graph.vp.type[tgt] == StateType.entry_sync:
                    cores = set(self._mstg.cross_point_map[tgt])
                    if orig_core in cores:
                        log(f"Skip {e}. It contains core {orig_core}.")
                        continue
                    if cores & used_cores[core]:
                        if not self._is_successor_of(cp, tgt):
                            log(f"Skip {e}. No successor.")
                            continue

                # skip false edges of common paths of previous traversals
                if cur in other_paths and other_paths[cur] != e:
                    log(f"Skip {e}. Other graph.")
                    continue

                if core_graph.vp.type[cur] == StateType.metastate:
                    edges.append(e)

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

    def _get_constrained_cps(self, cores, new_range):
        sync_graph = GraphView(
            self._mstg.g,
            efilt=((self._mstg.g.ep.type.fa &
                    (MSTType.follow_sync | MSTType.en2ex) > 0)))

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

        rsync = GraphView(sync_graph, reversed=True)
        paths = rsync.new_vertex_property('int64_t', val=-1)
        bfs_search(rsync,
                   source=new_range.start,
                   visitor=Constraints(cp_map, new_starts, paths=paths))
        used = self._get_used(sync_graph, new_starts, paths)

        if new_range.end:
            bfs_search(sync_graph,
                       source=new_range.end,
                       visitor=Constraints(cp_map, new_ends))

        return dict([(x, Range(start=new_starts[x], end=new_ends[x]))
                     for x in cores]), used

    def _get_timed_states(self, metastate, entry_cp, exit_cp):
        mstg = self._mstg.g
        m2s = mstg.edge_type(MSTType.m2s)
        st2sy = mstg.edge_type(MSTType.st2sy)
        s2s = mstg.edge_type(MSTType.s2s)

        states = set(m2s.vertex(metastate).out_neighbors())

        reachable_map = mstg.new_vp("bool")
        for state in states:
            reachable_map[state] = True

        entries = set(st2sy.vertex(entry_cp).out_neighbors())
        entry = single_check(entries & states)

        local = GraphView(s2s, vfilt=reachable_map)
        outs = label_out_component(local, local.vertex(entry))
        r1 = GraphView(local,
                       vfilt=(self._mstg.type_map.fa == ExecType.has_length))
        r2 = GraphView(r1, vfilt=outs)

        if exit_cp:
            exits = set(st2sy.vertex(exit_cp).in_neighbors())
            exit_s = single_check(exits & states)

            rlocal = GraphView(local, reversed=True)
            ins = label_out_component(rlocal, rlocal.vertex(exit_s))

            r3 = GraphView(r2, vfilt=ins)
        else:
            r3 = r2

        return [(x, entry_cp) for x in r3.vertices()]

    def _build_product(self, cp, current_core, cores, cps, used_cores, paths):
        assert len(cores) >= 1, "False usage of _build_product."
        core = cores[0]

        result = set()

        for exit_edge, path in self._iterate_search_tree(
                cp, current_core, core, cps, paths, used_cores):
            # self._log.debug(f"Examine edge {exit_edge} with path {path}.")
            if len(cores) > 1:
                new_cores = cores[1:]
                new_cps, _ = self._get_constrained_cps(
                    new_cores,
                    Range(start=path[-1].source(), end=exit_edge.target()))
                others = self._build_product(cp, current_core, new_cores,
                                             new_cps, used_cores,
                                             paths + [path])
            else:
                others = [tuple()]
            states = self._get_timed_states(exit_edge.source(),
                                            path[-1].target(),
                                            exit_edge.target())
            # self._log.debug(f"Leads to timed states: {[int(x[0]) for x in states]}.")

            result |= set([(x[0], *x[1]) for x in product(states, others)])
        # for res in result:
        #     self._log.warn([(int(x), int(y)) for x,y in res])
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

    def _find_timed_states(self, cross_state, cp, start_from=None):
        mstg = self._mstg.g
        affected_cores = self._mstg.cross_core_map[cross_state]
        current_core = mstg.vp.cpu_id[cross_state]
        needed_cores = {current_core} | set(affected_cores)

        # graph only with follow_sync and en2ex edges
        sync_graph = GraphView(
            self._mstg.g,
            efilt=((self._mstg.g.ep.type.fa &
                    (MSTType.follow_sync | MSTType.en2ex) > 0)))

        root_cps = self._find_root_cross_points(cp, needed_cores, sync_graph)

        self._log.debug(
            f"Find pairing candidates for node {int(cross_state)} starting "
            f"from cross points {[int(x) for x in root_cps]}.")
        combinations = set()
        for root in root_cps:
            self._log.debug(f"Evaluating first root cross point {int(root)}.")
            # find initial cross points for all needed cores
            cps, used_cores = self._get_constrained_cps(
                affected_cores, Range(start=cp, end=None))
            if start_from is not None:
                cps, _ = self._get_constrained_cps(
                    affected_cores, Range(start=start_from, end=None))
            self._log.debug(f"Starting from cross points {cps}.")
            for states in self._build_product(cp, current_core, affected_cores,
                                              cps, used_cores, []):
                timely_cps = self._find_timed_predecessor(
                    sync_graph, frozenset([cp] + [x[1] for x in states]))
                # self._log.debug(
                #    f"Found time predecessors {[int(x) for x in timely_cps]}.")
                combinations.add((tuple([x[0] for x in states]), timely_cps, root))
        # for a, b in combinations:
        #     self._log.warn(f"{[int(x) for x in a]} {[int(x) for x in b]}")
        return combinations

    def _create_cross_point(self, cross_state, timed_states, cp, timely_cps):
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

        for timely_cp in timely_cps:
            self._log.debug(
                f"Add time edge between {int(timely_cp)} and {int(new_cp)}.")
            e = mstg.add_edge(timely_cp, new_cp)
            mstg.ep.type[e] = MSTType.follow_sync

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
                                      x.cpus.one().id,
                                      x.instances) for x in states
        ]
        context.append(os.get_global_contexts(old_multi_core_state.context,
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
            for timed_candidates, timely_cps, root in self._find_timed_states(
                    cross_state, cp, start_from=start_from):
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
                    for timely_cp in timely_cps:
                        self._log.debug(
                            f"Time link from {int(timely_cp)} to existing "
                            f"cross point {int(other_cp)}")
                        exists = follow_sync.edge(timely_cp, other_cp)
                        if not exists:
                            m2sy_edge = mstg.add_edge(timely_cp, other_cp)
                            mstg.ep.type[m2sy_edge] = MSTType.follow_sync
                        else:
                            self._log.warn("Time link already exists.")
                else:
                    other_cp = self._create_cross_point(
                        cross_state, timed_candidates, root, timely_cps)
                    exits += [(x, None)
                              for x in self._evaluate_crosspoint(other_cp)]
                    modified = True

                if modified:
                    current_cpus = set(self._mstg.cross_point_map[cp])
                    other_cpus = set(self._mstg.cross_point_map[other_cp])

                    unready = current_cpus - other_cpus
                    if unready:
                        new_cps, _ = self._get_constrained_cps(
                            unready, Range(start=other_cp, end=None))
                        on_stack = defaultdict(list)
                        for core, ran in new_cps.items():
                            on_stack[ran.start].append(core)
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

            self._log.debug(
                f"Round {counter:3d}, handle cross point {int(cp)}. "
                f"Stack with {len(stack)} state(s)")
            if self.dump.get():
                self._dump_mstg(extra=f"round.{counter:03d}")
            counter += 1

            # if counter == 5:
            #     self._fail("foo")

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
