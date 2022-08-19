from .common import TimeRange, CrossExecState, get_reachable_states, FakeEdge
from .equations import Equations

from ara.graph import StateType, MSTType, single_check
from ara.util import dominates, get_logger, ContinueSignal

import math

from graph_tool import GraphView
from graph_tool.topology import shortest_path, dominator_tree

MAX_INT64 = 2**63 - 1


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
    def __init__(self, mstg, type_map):
        self._log = get_logger("MultiSSE.WCET", inherit=True)
        self._mstg = mstg
        self._type_map = type_map


    def _calculate_entry_execution_time(self, eqs, sp, cpu_id, entry,
                                        entry_must_be_over=True):
        """Calculate the execution time of an entry node.

        The entry could have been executed before. Add this and the remaining
        time to the given equation system.

        If entry_must_be_over is set, the function calculates the equation
        system so that the entry node is already executed otherwise it returns
        the equation system that the entry is currently in execution.
        """
        mstg = self._mstg
        g1 = mstg.edge_type(MSTType.st2sy, MSTType.s2s, MSTType.en2ex)
        follow_sync = mstg.edge_type(MSTType.follow_sync)

        def good_edge(e):
            if mstg.ep.type[e] == MSTType.st2sy:
                return mstg.ep.cpu_id[e] == cpu_id
            return True

        core_graph = GraphView(g1, efilt=good_edge,
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
        # SP where entry really starts
        while True:
            g = GraphView(core_graph, vfilt=v_filter)
            _, elist = shortest_path(g, entry_state, exit_sp)

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
            entry_sp = mstg.get_entry_cp(exit_sp)
            if len(elist) < 2:
                # the state was not executed before
                # maybe the ABB was executed before
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
                interrupted_state = last_state
            else:
                # the same state was executed before
                interrupted_state = entry_state

            common_sps = set(interrupted_state.in_neighbors()) & set(
                follow_sync.vertex(entry_sp).in_neighbors())

            if len(common_sps) != 1:
                self._log.warn("Found a state with none or multiple common "
                               "SPs. This is not supported.")
                eqs.add_range(entry_edge, default_range)
                return

            common_sp = single_check(common_sps)
            follow_edge = follow_sync.edge(common_sp, entry_sp)
            eqs.add_range(follow_edge,
                          TimeRange(up=get_time(mstg.ep.bcet, follow_edge),
                                    to=get_time(mstg.ep.wcet, follow_edge)))
            to_substract.add(follow_edge)
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
            eqs.add_equality({whole_entry}, to_substract | {entry_edge})

    def get_relative_time(self, sp, cpu_id, state, eqs=None):
        """Return the execution time of state relative to the SP sp.

        Since the current state can be a continuation (same ABB) of
        a previous executed state, the relative time is given back as equation
        system (for lazy evaluation).

        Please use result.get_interval_for(FakeEdge(src=sp, tgt=state)) if you
        need the concrete interval.

        If eqs is not given a new Equation object will be returned otherwise
        the equation are appended to eqs.
        """
        mstg = self._mstg
        entry = mstg.get_entry_state(sp, cpu_id)
        s2s = mstg.edge_type(MSTType.s2s)
        g = get_reachable_states(s2s, entry, exit_state=state)
        type_map = self._type_map

        self._log.debug("Searching for timings of state %d (CPU %d, coming "
                        "from SP %d)", state, cpu_id, sp)

        if not eqs:
            eqs = Equations()

        inf_time = [CrossExecState.idle, CrossExecState.waiting]

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

        target_edge = FakeEdge(src=sp, tgt=state)

        if type_map[entry] in inf_time:
            inf = True
            eqs.add_range(target_edge, TimeRange(up=0, to=math.inf))
        else:
            # add the actual execution time of the first node
            self._calculate_entry_execution_time(eqs, sp, cpu_id, entry,
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
