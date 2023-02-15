from dataclasses import dataclass
from typing import List, Set, Tuple
from itertools import chain, permutations, product
from collections import defaultdict

import graph_tool
from graph_tool.topology import shortest_path

from ara.graph import StateType, MSTType, vertex_types, single_check
from ara.util import get_logger, has_path, pairwise

from .equations import Equations
from .constrained_sps import get_constrained_sps
from .common import (Range, SPRange, FakeEdge, get_reachable_states,
                     CrossExecState, TimeRange)
from .wcet_calculation import TimingCalculator, get_time


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
    pred_sps: Tuple[TimedVertex]
    # the root SP for this candidate set
    root_sp: graph_tool.Vertex

    @staticmethod
    def set_without_candidates(sp, time):
        """Return a set without other candidates for the given SP."""
        return TimeCandidateSet(candidates=[],
                                pred_sps=[TimedVertex(vertex=sp,
                                                      range=time)],
                                root_sp=sp)


@dataclass(frozen=True)
class StateList:
    """List of pairing candidates for a cross syscall together with their
    equation system.
    """
    states: Tuple[RootedState]
    eqs: Equations


class _PairingPartnerSearch:
    """Find possible pairing partner for a given cross syscall."""

    def __init__(self,
                 mstg: graph_tool.Graph,
                 core_map: graph_tool.VertexPropertyMap,
                 type_map: graph_tool.VertexPropertyMap,
                 path: List[graph_tool.Vertex],
                 cross_state: graph_tool.Vertex,
                 affected_cores: Set[int],
                 restrictions: List[Range],
                 timing_calc: TimingCalculator = None,
                 time: Equations = None):
        """Initializes the search.

        mstg           -- The MSTG
        path           -- A path from the root SP to the last SP.
        cross_state    -- The current cross syscall.
        affected_cores -- A set of cores with which should be paired.
        restrictions   -- A list of restrictions in the search corridor.
        timing_calc    -- A TimingCalculator instance, if timing is wanted.
                          None, otherwise.
        """
        self._log = get_logger("MultiSSE.PPS", inherit=True)
        self._mstg = mstg
        self._core_map = core_map
        self._type_map = type_map
        self._affected_cores = affected_cores
        self._path = path
        self._restrictions = restrictions
        self._timings = timing_calc
        self._time = time

        root = path[0]
        self._root = root
        self._last_sp = path[-1]
        self._cross_state = cross_state
        self._cpu_id = self._mstg.vp.cpu_id[self._cross_state]

        sp_graph = graph_tool.GraphView(
                mstg.vertex_type(StateType.entry_sync,
                                 StateType.exit_sync),
                efilt=mstg.ep.type.fa != MSTType.sy2sy)
        reach = get_reachable_states(sp_graph, root)
        cut_history = mstg.new_ep("bool", val=True)
        for edge in mstg.vertex(root).in_edges():
            cut_history[edge] = False
        self._sp_graph = graph_tool.GraphView(reach, efilt=cut_history)

        # do the actual work
        self._log.debug(f"Evaluating cross state {int(self._cross_state)} "
                        f"(State {self._mstg.vp.state[self._cross_state].id}) "
                        f" with path {[int(x) for x in self._path]}"
                        " from the root SP to the last SP.")

        corridor = self._get_corridor()
        self._log.debug(f"Starting from SPs (format: {{cpu_id: range}}) {corridor}.")

        if self._timings:
            assert time, "Timings are requested but not given"
            self._log.debug(f"The time of SP {int(self._cross_state)} to"
                            f" cross state {int(self._last_sp)} is"
                            f" {self._time}.")
            eqs = self._build_equations(time)
        else:
            eqs = None

        # 3. Build the actual product from each possible sync point
        #    (while respecting time constraints if given.
        self._combinations = set()
        for state_list in self._build_product(corridor, eqs,
                                              self._affected_cores, []):
            # we now have a set of candidates for a new SP
            # next step is to calculate the predecessors in time for the
            # new SP
            timely_sps = self._find_timed_predecessor(
                self._sp_graph,
                frozenset([self._last_sp] + [x.root for x in state_list.states]))
            # self._log.debug(
            #    f"Found time predecessors {[int(x) for x in timely_sps]}.")
            if self._timings:
                timed_pred_sps = self._get_pred_times(
                    timely_sps, state_list, self._last_sp, self._cross_state)
            else:
                timed_pred_sps = frozenset([TimedVertex(vertex=x, range=TimeRange(up=0, to=0))
                                            for x in timely_sps])

            self._combinations.add(TimeCandidateSet(candidates=tuple([x.state for x in state_list.states]),
                                                    pred_sps=timed_pred_sps,
                                                    root_sp=self._root))

    def get_result(self):
        return self._combinations

    def _is_successor_of(self, orig_sp, new_sp):
        """Is new_sp a successor of orig_sp?"""
        sync_graph = self._mstg.edge_type(MSTType.follow_sync, MSTType.en2ex)
        _, elist = shortest_path(sync_graph, orig_sp, new_sp)
        return len(elist) > 0

    def _get_path(self, graph, from_sp, to_sp):
        return shortest_path(graph, from_sp, to_sp)[1]

    def _add_ranges(self, eqs, edges):
        """Add a range to eqs for every edge in edges."""
        bcet = self._mstg.ep.bcet
        wcet = self._mstg.ep.wcet
        for e in edges:
            eqs.add_range(
                e, TimeRange(up=get_time(bcet, e), to=get_time(wcet, e)))

    def _get_timed_states(self, cpu_id, root_sp, entry_sp, exit_sp, eqs):
        """Return all states that are within a feasible time.

        So basically, there are several states on the way from the entry SP to
        the exit SP that need time to execute.

        This function return them either entirely (if timings are not
        considered) or only that ones that fit to the given timings (by eqs).

        Arguments:
        cpu_id -- The cpu_id for which the search should take place.
        root_sp -- The root SP for the current search.
        entry_sp -- The entry SP that must dominate all states.
        exit_sp -- An optional exit_sp.
        eqs -- The current equation system.
        """
        mstg = self._mstg

        entry = mstg.get_entry_state(entry_sp, cpu_id)

        if exit_sp:
            exit_s = mstg.get_exit_state(exit_sp, cpu_id)
        else:
            exit_s = None

        s2s = mstg.edge_type(MSTType.s2s)
        reachable = get_reachable_states(s2s, entry, exit_state=exit_s)

        r1 = vertex_types(reachable, self._type_map, CrossExecState.with_time)

        good_v = []
        for v in r1.vertices():
            self._log.debug("Check if %d is a good candidate", v)
            if not self._timings:
                # shortcut if timings are not relevant
                good_v.append((v, None))
                continue
            new_eqs = eqs.copy()
            self._timings.get_relative_time(entry_sp, v, eqs=new_eqs)
            root_edges = self._get_edges_to(root_sp)
            e = FakeEdge(src=entry_sp, tgt=v)
            cur_edges = self._get_followsync_path(entry_sp) + [e]
            self._add_ranges(new_eqs, cur_edges[:-1])
            new_eqs.add_equality(root_edges, cur_edges)
            if new_eqs.solvable():
                good_v.append((v, new_eqs))
        return good_v

    def _get_initial_sps(self):
        """Return a mapping for each core which SP belongs to it.

        Therefore, it uses the globally defined cores and path.

        Assuming this path of SPs (the numbers denoting the cores).

        SP1: [ 0 | 1 | 2 ]
                   |
                   v
        SP2: [ 0 | 1 ]
                   |
                   v
        SP3:     [ 1 | 2 ]

        For cores={0,1,2} and path=["SP1", "SP2", "SP3"], this would result in
        { 0: SPRange(root=SP1, range=(start=SP2, end=None),
          1: SPRange(root=SP1, range=(start=SP3, end=None),
          2: SPRange(root=SP1, range=(start=SP3, end=None) }

        Additionally, it outputs the other cores that are synchronized on the
        way to this core:

        { 0: {1, 2},
          1: {},
          2: {} }
        """
        core_map = self._core_map
        cores = set(self._affected_cores)
        handled_cores = set()
        sps = {}
        used = {}
        for x in reversed(self._path):
            assert self._mstg.vp.type[x] == StateType.exit_sync
            x_cores = set(core_map[int(x)]) & cores
            for core in x_cores - handled_cores:
                sps[core] = SPRange(root=self._root,
                                    range=Range(start=x, end=None))
                used[core] = set(handled_cores)
            handled_cores |= x_cores
            if len(cores - handled_cores) == 0:
                break
        return sps, used

    def _get_corridor(self):
        # get the last SPs for each core
        sps, used_cores = self._get_initial_sps()
        sps[self._cpu_id] = SPRange(root=self._root,
                                    range=Range(start=self._last_sp, end=None))

        # restrict it further, if we have a starting point
        for restriction in self._restrictions:
            sps = get_constrained_sps(self._sp_graph,
                                      self._core_map,
                                      self._affected_cores,
                                      restriction,
                                      old_sps=sps)
        return sps

    def _build_equations(self, eqs):
        # If time should be considered, build the (initial) equation
        # system.
        # add all SPs on the path to the root to the equation system
        follow_sync = self._mstg.edge_type(MSTType.follow_sync)
        edges = [follow_sync.edge(src, self._mstg.get_entry_sp(tgt))
                 for src, tgt in pairwise(self._path)]
        self._add_ranges(eqs, edges)

        for restriction in self._restrictions:
            # add all edges on the path from the root SP to start_from
            edges = self._get_followsync_path(restriction.start)
            self._add_ranges(eqs, edges)
        return eqs

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

    def _iterate_search_tree(self, core, sps, eqs, paths):
        """Return all valid entry SPs for the given context and core.

        For the search of pairing partners, all possible pairing states must
        be iterated per core. They are restricted by SPs which are iterated
        with this function.

        Arguments:
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
        mstg = self._mstg
        sync_graph = mstg.edge_type(MSTType.m2sy, MSTType.en2ex)
        follow_sync = mstg.edge_type(MSTType.follow_sync)

        def this_core(e):
            if mstg.ep.type[e] == MSTType.m2sy:
                return mstg.ep.cpu_id[e] == core
            return True

        core_graph = graph_tool.GraphView(sync_graph, efilt=this_core)

        paths = set([(x.source(), x) for x in chain(*paths)])

        start = core_graph.vertex(sp.range.start)
        stack = [(start, [FakeEdge(src=-1, tgt=start)])]

        visited = core_graph.new_vp("bool")
        visited_entries = defaultdict(list)

        log(f"SPs: {sps}")
        log(f"Looking at CPU {int(core)} (orig CPU {int(self._cpu_id)})")
        while stack:
            cur, path = stack.pop(0)
            log(f"Stack element {int(cur)} with path {path}")

            if visited[cur] and path[-1] in visited_entries[cur]:
                log("Already visited, skipping...")
                continue
            visited[cur] = True
            visited_entries[cur].append(path[-1])
            last_exit_sp = path[-1].target()

            # iterate
            edges = []
            for e in cur.out_edges():
                log(f"Look at {e} (Type "
                    f"{str(MSTType(self._mstg.ep.type[e]))}).")
                tgt = e.target()

                # skip paths where the sync points do not follow each other
                if core_graph.vp.type[cur] == StateType.metastate:
                    nes = set(follow_sync.vertex(last_exit_sp).out_neighbors())
                    if e.target() not in nes:
                        log(f"Skip {e}. SPs do not follow each other.")
                        continue

                # skip false paths
                if tgt == sp.range.end:
                    log(f"Skip {e}. We are not branching to ourself.")
                    continue
                if core_graph.vp.type[tgt] == StateType.entry_sync:
                    cores = set(self._core_map[tgt])
                    if self._cpu_id in cores:
                        log(f"Skip {e}. It contains core {self._cpu_id}.")
                        continue
                    if cores & set(self._core_map[sp.root]):
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
                    if self._timings:
                        # e must have a follow_sync edge path to the last SP
                        ff_edges = self._get_followsync_path(e.target(),
                                                             from_sp=last_exit_sp)
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

    def _filtered_follow_sync(self, iterable):
        """Return a list of edges of iterable filtered by follow sync."""
        return list(
            filter(
                lambda e: isinstance(e, FakeEdge) or self._mstg.ep.type[e] ==
                MSTType.follow_sync, iterable))

    def _get_followsync_path(self, to_sp, from_sp=None):
        """Return the path of follow_sync edges from from_sp to to_sp.

        If from_sp is None it is assumed to be the root SP.
        """
        if from_sp:
            return self._filtered_follow_sync(self._get_path(self._sp_graph,
                                                             from_sp,
                                                             to_sp))
        # the chain from the cross syscall sp to root is given
        # so try to find a path from the last possible point in this chain
        for exit_sp in self._path:
            p = self._get_path(self._sp_graph, exit_sp, to_sp)
            if p:
                return self._filtered_follow_sync(p)
        return []

    def _build_product(self, sps, eqs, cores, paths):
        """Find all combinations that are valid pairing points for the current
        cross syscall.

        This function is recursive and calls itself core times. It works by
        choosing all valid pairing points for one core and then calls itself
        again to combine that to the rest of the combinations.

        Arguments:
        sps       -- dict of SPRange objects
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
                core, sps, eqs, paths):
            sp_from = path[-1].target()
            # self._log.debug(f"Examine metastate from SP {sp_from} to SP {sp_to} (CPU {core}).")
            states = self._get_timed_states(core, root, sp_from, sp_to, eqs)
            # self._log.debug(f"Leads to timed states: {[int(x[0]) for x in states]}.")
            for state, new_eqs in states:
                if len(cores) > 1:
                    new_cores = cores[1:]
                    new_cps = get_constrained_sps(self._sp_graph,
                                                  self._core_map,
                                                  new_cores,
                                                  Range(start=sp_from,
                                                        end=sp_to),
                                                  old_sps=sps)
                    others = self._build_product(new_cps, new_eqs,
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

    def _is_follow_sp(self, sp):
        """Check, if sp is a valid follow up SP of the given SPs."""
        core_map = {}
        for p in reversed(self._path):
            nc = dict([(c, p) for c in self._core_map[p]])
            core_map.update(nc)
        cores = set(self._core_map[sp]) & set(core_map.keys())
        # check for every core, if there exists a path between the last SP that
        # synchronizes this core and sp
        return all([
            has_path(self._sp_graph, core_map[core], sp)
            and core is not self._cpu_id for core in cores
        ])

    def _is_evaluated(self, state):
        """Check, if a state is already evaluated."""
        st2sy = self._mstg.edge_type(MSTType.st2sy)
        return st2sy.vertex(state).out_degree() > 0

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

    def _get_edges_to(self, sp):
        "Return all edges from the cross core to the SP laying on the path." ""
        edge_path = [FakeEdge(src=self._last_sp, tgt=self._cross_state)]
        for tgt, src in pairwise(reversed(self._path)):
            if tgt == sp:
                break
            edge_path.append(
                single_check(
                    filter(lambda e: self._mstg.ep.type[e] == MSTType.follow_sync,
                           self._mstg.edge(src, self._mstg.get_entry_sp(tgt),
                                           all_edges=True))))
        return edge_path

    def __repr__(self):
        return ("_PairingPartnerSearch("
                f"cpu_id: {self._cpu_id}, "
                f"cross_state: {int(self._cross_state)}, "
                f"path: {[int(x) for x in self._path]}")


def search_for_pairing_partners(mstg: graph_tool.Graph,
                                core_map: graph_tool.VertexPropertyMap,
                                type_map: graph_tool.VertexPropertyMap,
                                path: List[graph_tool.Vertex],
                                cross_state: graph_tool.Vertex,
                                affected_cores: Set[int],
                                restrictions: List[Range],
                                timing_calc: TimingCalculator = None,
                                time: Equations = None):
    """Search pairing partners.

    Wrapper function for _PairingPartnerSearch.
    """
    p = _PairingPartnerSearch(mstg, core_map, type_map, path, cross_state,
                              affected_cores, restrictions,
                              timing_calc=timing_calc, time=time)
    return p.get_result()
