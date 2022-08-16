from .common import TimeRange, CrossExecState, get_reachable_states

from ara.graph import StateType, MSTType, single_check
from ara.util import dominates, get_logger

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
        self._log = get_logger("MultiSSE.WCET")
        self._mstg = mstg
        self._type_map = type_map

    def _get_previous_execution_time(self, sp, cpu_id, entry):
        """Calculate the previous execution time of an entry node."""
        mstg = self._mstg
        g1 = mstg.edge_type(MSTType.st2sy, MSTType.s2s, MSTType.en2ex)
        follow_sync = mstg.edge_type(MSTType.follow_sync)

        def good_edge(e):
            if mstg.ep.type[e] == MSTType.st2sy:
                return mstg.ep.cpu_id[e] == cpu_id
            return True

        core_graph = GraphView(g1, efilt=good_edge,
                               vfilt=self._type_map.fa != CrossExecState.idle)

        exec_time = TimeRange(up=0, to=0)
        exit_sp = sp
        entry_state = entry

        default = TimeRange(up=0, to=mstg.vp.wcet[entry])

        v_filter = core_graph.new_vp("bool", val=True)

        self._log.debug("State %d may have been executed before (coming from "
                        "SP %d). Starting with time %s", entry, sp, exec_time)

        while True:
            g = GraphView(core_graph, vfilt=v_filter)
            _, elist = shortest_path(g, entry_state, exit_sp)

            if len(elist) > 2:
                # the state was somewhere blocked and is now resumed
                # currently not supported
                self._log.warn("Found an previously resumed state that is "
                               "continued. This is not supported.")
                return default

            if mstg.vertex(exit_sp).in_degree() == 0:
                # starting point, there were no previous executions
                break
            entry_cp = mstg.get_entry_cp(exit_sp)
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
            exec_time += TimeRange(up=get_time(mstg.ep.bcet, follow_edge),
                                   to=get_time(mstg.ep.wcet, follow_edge))
            self._log.debug("Found a previous execution fitting to edge %s."
                            " New time is %s", follow_edge, exec_time)

            v_filter[exit_sp] = False
            exit_sp = common_cp

        return exec_time

    def get_relative_time(self, sp, cpu_id, state):
        """Return the execution time of state relative to the SP sp."""
        mstg = self._mstg
        entry = mstg.get_entry_state(sp, cpu_id)
        s2s = mstg.edge_type(MSTType.s2s)
        g = get_reachable_states(s2s, entry, exit_state=state)
        type_map = self._type_map

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
            time = self._get_previous_execution_time(sp, cpu_id, entry)
            entry_bcet = max(mstg.vp.bcet[entry] - time.to, 0)
            set_time(t_to, entry, mstg.vp.wcet[entry] - time.up)
        self._log.debug("WCET of entry state %d (CPU %d, coming from SP %d): %s",
                        entry, cpu_id, sp, get_time(t_to, entry))

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

        self._log.debug(f"Relative time from SP %d to state %d is %s",
                        int(sp), int(state), t)
        return t
