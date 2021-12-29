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
from functools import reduce
from graph_tool.topology import label_out_component
from itertools import product, chain

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
    cross_points: []  # does this Metastate has a new cross_point
    cpu_id: int  # cpu_id of this state

    def __repr__(self):
        return ("Metastate("
                f"state: {int(self.state)}, "
                f"entry: {int(self.entry)}, "
                f"new_entry: {self.new_entry}, "
                f"is_new: {self.is_new}, "
                f"cross_points: {[int(x) for x in self.cross_points]}, "
                f"cpu_id: {self.cpu_id})")


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
        self._log.debug(f"Add initial cross point {int(cp)}")

        return cp

    def _get_single_core_states(self, multi_core_state):
        single_core_states = {}
        for cpu in multi_core_state.cpus:
            # restrict state to this cpu
            state = multi_core_state.copy()
            state.cpus = CPUList([cpu])
            state.context = self._graph.os.get_cpu_local_contexts(
                multi_core_state.context, cpu.id)
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
            logger=self._log,
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
        filt_mstg = graph_tool.GraphView(
            mstg,
            vfilt=((mstg.vp.type.fa == StateType.metastate) +
                   (self._mstg.type_map.fa == ExecType.cross_syscall)),
        )
        s2s = graph_tool.GraphView(mstg, mstg.vp.type.fa == StateType.state)

        oc = label_out_component(s2s, s2s.vertex(entry))
        oc[state] = True
        filt = graph_tool.GraphView(filt_mstg, vfilt=oc)

        return list(filt.vertex(state).out_neighbors())

    def _get_cores(self, exit_cp):
        st2sy = self._mstg.g.edge_type(MSTType.st2sy)
        return set(
            [st2sy.ep.cpu_id[e] for e in st2sy.vertex(exit_cp).out_edges()])

    def _find_timed_states(self, cross_state, cp):
        mstg = self._mstg.g
        affected_cores = self._mstg.cross_core_map[cross_state]
        needed_cores = set([mstg.vp.cpu_id[cross_state]]) | set(affected_cores)

        # graph only with sy2sy and follow_up edges
        sync_graph = graph_tool.GraphView(
            mstg,
            efilt=((mstg.ep.type.fa &
                    (MSTType.sy2sy | MSTType.follow_up) > 0)))

        # find last sync state that contains all needed cores
        init_cps = []
        stack = [sync_graph.vertex(cp)]
        visited = sync_graph.new_vp("bool")
        while stack:
            cur_cp = stack.pop()
            if visited[cur_cp]:
                continue
            visited[cur_cp] = True

            cores = self._get_cores(cur_cp)

            if cores >= needed_cores:
                init_cps.append(cur_cp)
                continue

            for n in cur_cp.in_neighbors():
                stack.append(n)

        def is_not_ending_state(v):
            return not (v not in init_cps
                        and set(self._mstg.cross_point_map[v]) >= needed_cores)

        # find all possible timed states per core
        cpu_graph = graph_tool.GraphView(
            mstg,
            efilt=((mstg.ep.type.fa &
                    (MSTType.st2sy | MSTType.follow_up | MSTType.s2s) > 0)),
            vfilt=is_not_ending_state)

        timed_states = defaultdict(list)

        for core in affected_cores:

            def good_edge(e):
                return not (mstg.ep.type[e] == MSTType.st2sy
                            and mstg.ep.cpu_id[e] != core)

            core_graph = graph_tool.GraphView(cpu_graph, efilt=good_edge)

            for init_cp in init_cps:
                reachable_states = label_out_component(
                    core_graph, core_graph.vertex(init_cp))
                r1 = graph_tool.GraphView(
                    mstg,
                    vfilt=(self._mstg.type_map.fa == ExecType.has_length))
                r2 = graph_tool.GraphView(r1, vfilt=reachable_states)
                r3 = graph_tool.GraphView(
                    r2, vfilt=(r2.vp.type.fa == StateType.state))
                timed_states[core] += list(r3.vertices())

        return product(*timed_states.values())

    def _create_cross_point(self, cross_state, timed_states, cp):
        mstg = self._mstg.g
        new_cp = mstg.add_vertex()
        mstg.vp.type[new_cp] = StateType.entry_sync
        self._log.debug(
            f"Add new entry cross point {int(new_cp)} between "
            f"{int(cross_state)} and {[int(x) for x in timed_states]}"
        )
        cpu_ids = set()

        syncs = mstg.edge_type(MSTType.sync_neighbor)
        for old_cross in chain([cp], list(syncs.vertex(cp).all_neighbors())):
            e = mstg.add_edge(old_cross, new_cp)
            mstg.ep.type[e] = MSTType.sy2sy

        for src in chain([cross_state], timed_states):
            e = mstg.add_edge(src, new_cp)
            mstg.ep.type[e] = MSTType.st2sy
            metastate = mstg.get_metastate(src)
            cpu_id = mstg.vp.cpu_id[metastate]
            mstg.ep.cpu_id[e] = cpu_id
            cpu_ids.add(cpu_id)
            m2sy_edge = mstg.add_edge(metastate, new_cp)
            mstg.ep.type[m2sy_edge] = MSTType.m2sy

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
                                      x.cpus.one().id) for x in states
        ]
        context.append(os.get_global_contexts(old_multi_core_state.context))

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
            mstg.ep.type[e] = MSTType.follow_up
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
            new_e = mstg.edge(mstg.vertex(cp),
                              mstg.vertex(v),
                              add_missing=True)
            mstg.ep.type[new_e] = MSTType.sy2sy

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

    def _do_full_pairing(self, cp, metastate):
        exits = []

        if not metastate.is_new:
            metastate.cross_points = self._find_cross_states(
                metastate.state, metastate.entry)

        for cross_state in metastate.cross_points:
            for timed_candidates in self._find_timed_states(cross_state, cp):
                other_cp = self._get_existing_cross_point(
                    cross_state, timed_candidates)
                if other_cp:
                    mstg = self._mstg.g
                    # just link the new cp to it
                    self._log.debug(
                        f"Link from {int(cp)} to existing cross point "
                        f"{int(other_cp)} ({int(cross_state)} with "
                        f"{[int(x) for x in timed_candidates]}).")
                    m2sy_edge = mstg.edge(cp, other_cp, add_missing=True)
                    mstg.ep.type[m2sy_edge] = MSTType.sy2sy
                else:
                    new_entry_cp = self._create_cross_point(
                        cross_state, timed_candidates, cp)
                    exits += self._evaluate_crosspoint(new_entry_cp)
        return exits

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
        stack = [cross_point]

        # actual algorithm
        counter = 0
        while stack:
            cp = stack.pop(0)
            self._log.debug(
                f"Round {counter:3d}, handle cross point {int(cp)}. "
                f"Stack with {len(stack)} state(s)")
            # if handled[cp]:
            #     continue
            # handled[cp] = True

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
                self._dump_mstg(extra=f"round.{counter:03d}")

            # handle the next cross points
            for cpu_id, metastate in metastates.items():
                self._log.debug(
                    f"Evaluate cross points of metastate {metastate}.")
                if metastate.new_entry:
                    self._log.debug(
                        "Metastate has a new entry. Do a full pairing.")
                    stack += self._do_full_pairing(cp, metastate)
                    continue

                others = set(metastates.keys()) - {cpu_id}
                if any([metastates[x].is_new for x in others]):
                    self._log.debug(
                        "At least one pairing state is new. Do a full pairing."
                    )
                    stack += self._do_full_pairing(cp, metastate)
                    continue

                if any([metastates[x].new_entry for x in others]):
                    self._log.debug(
                        "At least one pairing state has a new entry. Do a full pairing."
                    )
                    stack += self._do_full_pairing(cp, metastate)

                common_cps = self._find_common_crosspoints(metastates) - {cp}
                for common_cp in common_cps:
                    if self._get_cores(common_cp) == set(metastates.keys()):
                        self._log.debug(
                            f"Metastate is not new. Find an equal common cp {int(common_cp)}."
                        )
                        self._link_neighbor_crosspoint(common_cp, cp)
                    else:
                        self._fail("Unequal common cp")

                if common_cps:
                    continue

                self._log.debug(
                    "Found already existing but unconnected metastates. Do a full pairing."
                )
                stack += self._do_full_pairing(cp, metastate)

            counter += 1

        self._log.info(f"Analysis needed {counter} iterations.")

        self._graph.mstg = mstg

        if self.dump.get():
            self._step_manager.chain_step({
                "name": "Printer",
                "dot": self.dump_prefix.get() + "mstg.dot",
                "graph_name": "MSTG",
                "subgraph": "mstg",
            })
