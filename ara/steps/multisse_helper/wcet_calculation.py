import math

from dataclasses import dataclass
from typing import Union
from graph_tool import GraphView, Edge
from graph_tool.topology import shortest_path, dominator_tree

from ara.graph import StateType, MSTType, single_check, vertex_types
from ara.util import dominates, get_logger, ContinueSignal

from .common import TimeRange, CrossExecState, get_reachable_states, FakeEdge
from .equations import Equations

MAX_INT64 = 2**63 - 1


@dataclass(frozen=True)
class TimedEdge:
    """An arbitrary graph vertex associated with a time."""
    edge: Union[Edge, FakeEdge]
    range: TimeRange

    def __repr__(self):
        return ("TimedEdge("
                f"edge: {str(self.edge)}, "
                f"range: {self.range})")


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


class TimingCalculator():
    def __init__(self, mstg, type_map, sp_core_map):
        self._log = get_logger("MultiSSE.WCET", inherit=True)
        self._mstg = mstg
        self._type_map = type_map
        self._sp_core_map = sp_core_map

    def _timed_follow_edges(self, *edges):
        """Return only follow sync edges together with their time."""
        mstg = self._mstg
        for edge in edges:
            if mstg.ep.type[edge] != MSTType.follow_sync:
                continue
            o_edges = filter(lambda x: mstg.ep.type[x] == MSTType.follow_sync,
                             mstg.edge(edge.source(), edge.target(), all_edges=True))
            o_edge = single_check(o_edges)
            yield TimedEdge(edge=o_edge,
                            range=TimeRange(up=get_time(mstg.ep.bcet, edge),
                                            to=get_time(mstg.ep.wcet, edge)))

    def _calculate_entry_execution_time(self, eqs, sp, cpu_id, entry,
                                        recursion_depth,
                                        entry_must_be_over=True):
        """Calculate the execution time of an entry node.

        The entry could have been executed before. Add this and the remaining
        time to the given equation system.

        If entry_must_be_over is set, the function calculates the equation
        system so that the entry node is already executed otherwise it returns
        the equation system that the entry is currently in execution.

        The function is recursive. recursive_depth stores the length of the
        call chain and allows to break hard.
        """
        mstg = self._mstg
        st2sy = mstg.edge_type(MSTType.st2sy)
        follow_sync_tmp = mstg.edge_type(MSTType.follow_sync, MSTType.en2ex)
        # graph that consists of follow_sync, en2ex edges and SPs only
        follow_sync = vertex_types(follow_sync_tmp, mstg.vp.type,
                                   StateType.entry_sync, StateType.exit_sync)

        g1 = mstg.edge_type(MSTType.st2sy, MSTType.s2s, MSTType.en2ex)

        def core_graph_good_edge(e):
            if mstg.ep.type[e] == MSTType.st2sy:
                return mstg.ep.cpu_id[e] == cpu_id
            return True

        # graph that consists of st2sy s2s and en2ex edges which are specific
        # for the current cpu_id and excludes all idle states
        core_graph = GraphView(g1, efilt=core_graph_good_edge,
                               vfilt=self._type_map.fa != CrossExecState.idle)

        # default case, worst case, the entry is executed as a whole before
        # or nothing at all
        entry_edge = FakeEdge(src=sp, tgt=entry)
        default_range = TimeRange(up=0, to=self._mstg.vp.wcet[entry])

        v_filter = core_graph.new_vp("bool", val=True)

        self._log.debug("State %d may have been executed before (coming from "
                        "SP %d). Starting with eqs %s", entry, sp, eqs)

        exit_sp = sp
        entry_state = entry
        to_substract = set()
        after_hook = None
        # SP where entry really starts
        while True:
            # start with the complete core_graph and narrow it down while
            # exploring the graph
            g = GraphView(core_graph, vfilt=v_filter)

            # basic idea: We search loops in the graph. An entry state (i.e. a
            # state that follows an exit SP) that is continued also leads
            # somehow to this exit SP.
            # We expect
            # - no path if it is not continued
            # - a path of 2 edges (entry state - entry SP - exit SP) when it
            #   is continued.
            _, elist = shortest_path(g, entry_state, exit_sp)

            # sanity handling
            if len(elist) > 2:
                # the state was somewhere blocked and is now resumed
                # currently not supported
                self._log.warn("Found an previously resumed state that is "
                               "continued. This is not supported. Aborting...")
                eqs.add_range(entry_edge, default_range)
                return

            if mstg.vertex(exit_sp).in_degree() == 0:
                # starting point, there were no previous executions
                break

            # determine the interrupted state, i.e. the exact state that was
            # interrupted by the exit SP
            entry_sp = mstg.get_entry_sp(exit_sp)
            if len(elist) < 2:
                # the state was not executed before
                # maybe the ABB was executed before (this also reduces time)
                esp = core_graph.vertex(entry_sp)
                if esp.in_degree() == 0:
                    # probably coming from idle, we found the end
                    break
                last_state = single_check(esp.in_neighbors())
                assert mstg.vp.type[last_state] == StateType.state
                current_abb = mstg.vp.state[entry_state].cpus.one().abb
                old_abb = mstg.vp.state[last_state].cpus.one().abb

                if current_abb != old_abb:
                    # ABBs do not fit, ending here, we found the end
                    break

                # we have the same executing ABBs
                # just handle the state as interrupted one
                self._log.debug("Found an SP (%s) that interrupted the "
                                "execution of an ABB while breaking its "
                                "execution into two states.", exit_sp)
                interrupted_state = last_state
            else:
                # the same state was executed before
                interrupted_state = entry_state

            # Try to find the common SPs, i.e. the SPs that are predecessors
            # of time the interrupting SP and also directly lead to
            # interrupted state. Multiple of them are not supported, if it is
            # exactly one, the follow edge between to common SP and the exit
            # SP specifies the correct time.
            state_sps = set(st2sy.vertex(interrupted_state).in_neighbors())
            sp_sps = set(follow_sync.vertex(entry_sp).in_neighbors())
            common_sps = state_sps & sp_sps

            if len(common_sps) > 1:
                self._log.warn("Found a state with none or multiple common "
                               "SPs. This is not supported.")
                eqs.add_range(entry_edge, default_range)
                return

            if len(common_sps) == 0:
                # no common SP between interrupted state and predecessors in
                # time of the current SP, trying to search a path over the SPs
                # that do not belong to the current core.
                # The idea here is that maybe not a direct follow sync
                # connection between exists but a connection going over
                # multiple other SPs that does not synchronize the current
                # state.

                def follow_sync_good_vertex(v):
                    if v in state_sps:
                        return True
                    if v == entry_sp:
                        return True
                    return cpu_id not in self._sp_core_map[v]

                fs_non_core = GraphView(follow_sync,
                                        vfilt=follow_sync_good_vertex)

                found = None
                for state_sp in state_sps:
                    assert mstg.vp.type[state_sp] == StateType.exit_sync
                    _, sp_list = shortest_path(fs_non_core, state_sp, entry_sp)
                    if len(sp_list) > 0:
                        if found:
                            self._log.warn("Multiple paths to state SPs found."
                                           "This is not supported.")
                            eqs.add_range(entry_edge, default_range)
                            return
                        found = (state_sp, sp_list)
                if found:
                    # the interrupted state starts at an SP and found contains
                    # our path
                    self._log.debug("Found a previous execution fitting to the"
                                    " path %s.", list(map(str, found[1])))
                    to_substract.update(self._timed_follow_edges(*found[1]))
                    # prepare next loop iteration
                    # the current exit_sp is handled, set the new one to the
                    # start of the path
                    v_filter[exit_sp] = False
                    exit_sp = found[0]
                    continue
                else:
                    # the interrupted state does not begin at an SP
                    if len(sp_sps) > 1:
                        self._log.warn("The requested entry is continued but "
                                       "not an entry in the previous metastate."
                                       " The SP that interrupts the entry also "
                                       "has multiple predecessors in time. We "
                                       "are not able to handle this, currently.")
                        eqs.add_range(entry_edge, default_range)
                        return
                    if recursion_depth > 5:
                        # TODO: this actually skips all previous calculations.
                        # be more fine grained by keeping them
                        self._log.warn("Got a recursion depth greater than "
                                       "five. While there might be a tighter "
                                       "solution at higher depths, it does "
                                       "not justify the additional "
                                       "computation time, so falling back to "
                                       "default in this case.")
                        eqs.add_range(entry_edge, default_range)
                        return
                    # we have an entry that is continued but is not the entry
                    # state in the previous metastate. So get the relative
                    # time up until that entry. Our original search must end
                    # here.
                    prev_sp = single_check(sp_sps)
                    if (mstg.vp.cpu_id[interrupted_state]
                            not in self._sp_core_map[prev_sp]):
                        # TODO: this may be a bug, investigate further
                        self._log.warn("Found for the current SP only a "
                                       "predecessor in time that synchronizes "
                                       "another core set than the interupted "
                                       "state. We cannot handle this.")
                        eqs.add_range(entry_edge, default_range)
                        return

                    self.get_relative_time(prev_sp,
                                           interrupted_state, eqs=eqs,
                                           include_self=False,
                                           recursion_depth=recursion_depth + 1)
                    # edge calculated with get_relative_time
                    grt_edge = FakeEdge(src=prev_sp, tgt=interrupted_state)
                    # get_relative_set calculates the time up to the entry of
                    # interrupted_state. However, we need an additional edge
                    # for the interval of interrupted_state itself. We are
                    # doing that by an edge from the interrupted state to
                    # itself (or an additional following state).
                    #
                    # we have the following situation
                    #           ´-- i_state_part --`
                    # |-- grt --.-- interrupted_ --|----- _state ---------|
                    # |         . to_substract[1] .|.. to_substract[0] ...|
                    # prev_sp                     entry_sp
                    exit_sp = interrupted_state
                    i_state_part = FakeEdge(src=interrupted_state,
                                            tgt=entry_sp)
                    to_substract.add(TimedEdge(edge=i_state_part,
                                               range=TimeRange(up=0,
                                                               to=math.inf)))
                    f_edge = follow_sync.edge(prev_sp, entry_sp)
                    eqs.add_range(f_edge,
                                  TimeRange(up=get_time(mstg.ep.bcet, f_edge),
                                            to=get_time(mstg.ep.wcet, f_edge)))
                    # we need to add the equality delayed since the range of
                    # i_state_part is currently undefined
                    after_hook = (lambda:
                            eqs.add_equality({f_edge}, {grt_edge, i_state_part}))
                    break

            common_sp = single_check(common_sps)
            follow_edge = follow_sync.edge(common_sp, entry_sp)
            to_substract.update(self._timed_follow_edges(follow_edge))
            self._log.debug("Found a previous execution fitting to edge %s.",
                            follow_edge)

            v_filter[exit_sp] = False
            exit_sp = common_sp

        # add the remaining equalities
        # We have one of the following situations:
        #
        # to_substract is empty:
        #     |-- entry --|
        #     |
        # SP == exit_sp
        #
        # to_substract is not empty:
        # |---- prev_entry -----|-- entry_remaining --|
        # |.. to_substract[0] ..|
        # exit_sp               SP

        whole_entry = FakeEdge(src=exit_sp, tgt=entry)
        start_time = 0
        if entry_must_be_over:
            start_time = get_time(mstg.vp.bcet, entry)
        eqs.add_range(whole_entry,
                      TimeRange(up=start_time,
                                to=get_time(mstg.vp.wcet, entry)))
        if to_substract:
            # entry is splitted, add the remaining part
            eqs.add_range(entry_edge,
                          TimeRange(up=0,
                                    to=get_time(mstg.vp.wcet, entry)))
            for t_edge in to_substract:
                eqs.add_range(t_edge.edge, t_edge.range)
            eqs.add_equality({whole_entry}, set(map(lambda x: x.edge, to_substract)) | {entry_edge})
        if after_hook:
            after_hook()

    def get_relative_time(self, sp, state, eqs=None, include_self=True,
                          recursion_depth=0):
        """Return the execution time of state relative to the SP sp.

        Since the current state can be a continuation (same ABB) of
        a previous executed state, the relative time is given back as equation
        system (for lazy evaluation).

        Please use result.get_interval_for(FakeEdge(src=sp, tgt=state)) if you
        need the concrete interval.

        If eqs is not given a new Equation object will be returned otherwise
        the equation are appended to eqs.

        If include_self is set, the relative time from the SP sp to the point
        in time _after_ the execution of the State state is calculated else
        the point in time _directly before_ the execution of the State state.

        recursion_depth specifies the current recursion depth and is set
        internally. Do not set it by yourself.
        """
        mstg = self._mstg
        cpu_id = mstg.vp.cpu_id[state]
        entry = mstg.get_entry_state(sp, cpu_id)
        s2s = mstg.edge_type(MSTType.s2s)
        g = get_reachable_states(s2s, entry, exit_state=state)
        type_map = self._type_map

        self._log.debug("Searching for timings of state %d (CPU %d, coming "
                        "from SP %d)", state, cpu_id, sp)

        if not eqs:
            eqs = Equations()

        target_edge = FakeEdge(src=sp, tgt=state)

        # early return when no work is given
        if not include_self and state == entry:
            eqs.add_range(target_edge, TimeRange(up=0, to=0))
            return eqs

        inf_time = [CrossExecState.idle, CrossExecState.waiting]

        def get_bcet(node):
            if type_map[node] in inf_time:
                return 0
            if node == entry:
                return entry_bcet
            return g.vp.bcet[node]

        def get_wcet(node):
            if not include_self and state == node:
                return 0
            if type_map[node] in inf_time:
                return math.inf
            return g.vp.wcet[node]

        dom_tree = dominator_tree(g, g.vertex(entry))

        t_from = g.new_vp("int64_t", val=-1)
        t_to = g.new_vp("int64_t", val=-1)

        entry_bcet = 0

        # do we have an infinite execution time?
        # If yes, we can skip WCET calculations.
        inf = False

        # entry time
        # it always null since it is tracked by an extra formula in the
        # equations.
        t_from[entry] = 0
        t_to[entry] = 0

        if type_map[entry] in inf_time:
            inf = True
            eqs.add_range(target_edge, TimeRange(up=0, to=math.inf))
        else:
            # add the actual execution time of the first node
            self._calculate_entry_execution_time(eqs, sp, cpu_id, entry,
                                                 recursion_depth,
                                                 entry_must_be_over=(entry != state))

        self._log.debug("Timings of entry state %d (CPU %d, coming from SP %d): %s",
                        entry, cpu_id, sp, eqs)

        if entry != state:
            stack = list(g.vertex(entry).out_neighbors())

            while stack:
                cur = stack.pop(0)
                # self._log.debug(f"GRT: Looking at {int(cur)}")
                degree = cur.in_degree()
                if degree == 1:
                    pred = single_check(cur.in_neighbors())
                    set_time(t_from, cur, get_time(t_from, pred) + get_bcet(pred))
                    new_t = get_time(t_to, pred) + get_wcet(cur)
                    if not inf:
                        inf = new_t == math.inf or inf
                        set_time(t_to, cur, new_t)
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
                        froms = []
                        try:
                            for in_neighbor in cur.in_neighbors():
                                t = get_time(t_from, in_neighbor)
                                if t == -1:
                                    # skip cur, it will be added anyway
                                    raise ContinueSignal
                                froms.append(t + get_bcet(in_neighbor))
                        except ContinueSignal:
                            continue
                        set_time(t_from, cur, min(froms))

                        if not inf:
                            tos = [get_time(t_to, x) for x in cur.in_neighbors()]
                            new_t = max(tos) + get_wcet(cur)
                            inf = new_t == math.inf or inf
                            set_time(t_to, cur, new_t)

                for nex in cur.out_neighbors():
                    stack.append(nex)

            to_time = math.inf if inf else get_time(t_to, state)
            t = TimeRange(up=get_time(t_from, state), to=to_time)
            assert t.up >= 0 and t.to >= t.up

            self._log.debug("Remaining relative time from SP %d to state %d "
                            "(without the entry state) is %s",
                            int(sp), int(state), t)

            entry_edge = FakeEdge(src=sp, tgt=entry)
            t_edge = FakeEdge(src=entry, tgt=state)

            # Fill the equation system.
            # We have the following situation:
            #  |-- prev_entry--|-- entry --|--- t ---|
            #  |- follow_sync--|---- target_edge ----|
            # oldSP           SP                   state
            # It holds:
            # 1. prev_entry + entry = complete_time_of_entry_ABB
            #    prev_entry = follow_sync
            #    (given by get_previous_execution_time)
            # 2. entry + t = target_edge

            eqs.add_range(FakeEdge(src=entry, tgt=state), t)
            # unrestricted range, it is restricted by the other equations
            eqs.add_range(target_edge, TimeRange(up=0, to=math.inf))
            eqs.add_equality({target_edge}, {entry_edge, t_edge})
        self._log.debug("Final timing calculation: %s", eqs)
        return eqs
