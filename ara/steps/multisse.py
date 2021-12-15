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

from itertools import product, chain
from functools import reduce
from dataclasses import dataclass
from graph_tool.topology import label_out_component
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
    is_new: bool  # is this Metastate already evaluated
    cpu_id: int = -1


class MultiSSE(Step):
    """Run the MultiCore SSE."""

    entry_point = Option(name="entry_point", help="system entry point",
                         ty=String())

    def get_single_dependencies(self):
        if self._graph.os is None:
            return ["SysFuncts"]
        deps = self._graph.os.get_special_steps()
        return deps

    def dump_mstg(self, mstg, extra):
        dot_file = self.dump_prefix.get() + f"mstg.{extra}.dot"
        dot_path = os.path.abspath(dot_file)
        os.makedirs(os.path.dirname(dot_path), exist_ok=True)
        dot_graph = mstg_to_dot(mstg, label=f"MSTG {extra}")
        dot_graph.write(dot_path)
        self._log.info(f"Write MSTG to {dot_path}.")

    def _run_sse(self, mstg, init_state):
        """Run the single core SSE for the given init_state.

        Collects all states within a metastate and returns it together with
        the vertex for the init state.
        """
        # early return if state already evaluated
        init_h = hash(init_state)
        if init_h in self.state_map:
            init_v = self.state_map[init_h]
            metastate = mstg.g.get_metastate(init_v)

            return Metastate(state=metastate, entry=init_v, is_new=False)

        cpu_id = single_check(iter(init_state.cpus.ids()))
        # create the metastate
        m_state = mstg.g.add_vertex()
        mstg.g.vp.type[m_state] = StateType.metastate
        mstg.g.vp.cpu_id[m_state] = cpu_id
        self._log.debug(f"Add metastate {int(m_state)}")

        def _add_state(state):
            h = hash(state)
            if h in self.state_map:
                return False

            v = mstg.g.add_vertex()
            mstg.g.vp.type[v] = StateType.state
            mstg.g.vp.state[v] = state
            self._log.debug(f"Add State {state.id} (node {int(v)})")

            e = mstg.g.add_edge(m_state, v)
            mstg.g.ep.type[e] = MSTType.m2s
            mstg.g.ep.cpu_id[e] = cpu_id
            self.state_map[h] = v

            if state.cpus[cpu_id].exec_state & ExecState.with_time:
                mstg.type_map[v] = ExecType.has_length

            return True

        # add initial state
        _add_state(init_state)

        class SSEVisitor(Visitor):
            PREVENT_MULTIPLE_VISITS = False
            CFG_CONTEXT = None

            @staticmethod
            def get_initial_state():
                return init_state

            @staticmethod
            def cross_core_action(state, cpu_ids):
                mstg.cross_core_map[self.state_map[hash(state)]] = cpu_ids
                mstg.type_map[self.state_map[hash(state)]] = ExecType.cross_syscall

            @staticmethod
            def schedule(new_state):
                return self._graph.os.schedule(new_state, [cpu_id])

            @staticmethod
            def add_state(new_state):
                return _add_state(new_state)

            @staticmethod
            def add_transition(source, target):
                e = mstg.g.add_edge(self.state_map[hash(source)], self.state_map[hash(target)])
                mstg.g.ep.type[e] = MSTType.s2s
                mstg.g.ep.cpu_id[e] = cpu_id

            @staticmethod
            def next_step(counter):
                pass

        run_sse(
            self._graph,
            self._graph.os,
            visitor=SSEVisitor(),
            logger=self._log,
        )

        if self.dump.get():
            self.dump_mstg(mstg.g,
                           extra=f"metastate.{int(m_state)}")

        return Metastate(state=m_state, entry=self.state_map[init_h], is_new=True)

    def _create_metastates(self, mstg, multi_cpu_state, cp):
        """Split a state with multiple CPUs and run a single core SSE on each
        of them.

        Return the list of new metastates
        """
        metastates = []
        for cpu in multi_cpu_state.cpus:
            # restrict state to this cpu
            state = multi_cpu_state.copy()
            state.cpus = CPUList([cpu])
            state.context = self._graph.os.get_cpu_local_contexts(multi_cpu_state.context, cpu.id)

            # run single core SSE on this state
            metastate = self._run_sse(mstg, state)
            metastate.cpu_id = cpu.id

            # add m2sy edge
            e = mstg.g.add_edge(cp, metastate.state)
            mstg.g.ep.type[e] = MSTType.m2sy
            mstg.g.ep.cpu_id[e] = metastate.cpu_id

            # add st2sy edge
            e = mstg.g.add_edge(cp, metastate.entry)
            mstg.g.ep.type[e] = MSTType.st2sy
            mstg.g.ep.cpu_id[e] = metastate.cpu_id

            metastates.append(metastate)
        return metastates

    def _get_initial_states(self, mstg):
        os_state = self._graph.os.get_initial_state(
            self._graph.cfg, self._graph.instances
        )

        # initial cross_point
        cp = mstg.g.add_vertex()
        mstg.g.vp.type[cp] = StateType.exit_sync
        mstg.g.vp.state[cp] = self._graph.os.get_global_contexts(os_state.context)
        self._log.debug(f"Add initial cross point {int(cp)}")

        metastates = self._create_metastates(mstg, os_state, cp)

        return cp, metastates

    def _find_cross_state(self, mstg, states, src_cp):
        """Return all syscalls that possibly affect other cores."""
        filt_mstg = graph_tool.GraphView(
            mstg.g,
            vfilt=((mstg.g.vp.type.fa == StateType.metastate) +
                   (mstg.type_map.fa == ExecType.cross_syscall))
        )
        s2s = graph_tool.GraphView(mstg.g, mstg.g.vp.type.fa == StateType.state)

        for state in states:
            oc = label_out_component(s2s, s2s.vertex(state.entry))
            oc[state.state] = True
            filt = graph_tool.GraphView(filt_mstg, vfilt=oc)

            for cross_point in list(filt.vertex(state.state).out_neighbors()):
                yield mstg.g.vertex(cross_point)

    def _find_timed_states(self, mstg, cross_state, states):
        """Return all states with a time that are possibly affected by other
        cores.
        """
        affected_cores = mstg.cross_core_map[cross_state]
        affected_states = [s for s in states
                           if mstg.g.vp.cpu_id[s.state] in affected_cores]

        filt_mstg = graph_tool.GraphView(
            mstg.g,
            vfilt=((mstg.g.vp.type.fa == StateType.metastate) +
                   (mstg.type_map.fa == ExecType.has_length))
        )
        s2s = graph_tool.GraphView(mstg.g, mstg.g.vp.type.fa == StateType.state)

        def to_iter(state):
            oc = label_out_component(s2s, s2s.vertex(state.entry))
            oc[state.state] = True
            filt = graph_tool.GraphView(filt_mstg, vfilt=oc)
            return list(filt.vertex(state.state).out_neighbors())

        return product(*[to_iter(x) for x in affected_states])

    def _create_cross_point(self, mstg, cross_state, timed_states, old_cp):
        cp = mstg.g.add_vertex()
        mstg.g.vp.type[cp] = StateType.entry_sync
        self._log.debug(f"Add cross point {int(cp)}")

        syncs = mstg.g.edge_type(MSTType.sync_neighbor)
        for old_cross in chain([old_cp],
                               list(syncs.vertex(old_cp).all_neighbors())):
            e = mstg.g.add_edge(old_cross, cp)
            mstg.g.ep.type[e] = MSTType.sy2sy

        for src in chain([cross_state], timed_states):
            e = mstg.g.add_edge(src, cp)
            mstg.g.ep.type[e] = MSTType.st2sy
            metastate = mstg.g.get_metastate(src)
            mstg.g.ep.cpu_id[e] = mstg.g.vp.cpu_id[metastate]
            m2sy_edge = mstg.g.add_edge(metastate, cp)
            mstg.g.ep.type[m2sy_edge] = MSTType.m2sy

        return cp

    def _evaluate_crosspoint(self, mstg, cp):
        os = self._graph.os
        cp = mstg.g.vertex(cp)

        # create multicore state
        states = []
        old_ctx = None
        for v in cp.in_neighbors():
            obj = mstg.g.vp.state[v]
            ty = mstg.g.vp.type[v]
            if ty == StateType.exit_sync:
                old_ctx = obj
            elif ty == StateType.state:
                states.append(obj)

        def _get_cross_cpu_id():
            for e in cp.in_edges():
                if mstg.type_map[e.source()] == ExecType.cross_syscall:
                    yield mstg.g.ep.cpu_id[e]
        cpu_id = single_check(_get_cross_cpu_id())

        cpus = CPUList([single_check(x.cpus) for x in states])

        context = [os.get_cpu_local_contexts(x.context, x.cpus.one().id)
                   for x in states]
        context.append(old_ctx)

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
            fcp = mstg.g.add_vertex()
            mstg.g.vp.type[fcp] = StateType.exit_sync
            self._log.debug(f"Add exit cross point {int(fcp)}")

            e = mstg.g.add_edge(cp, fcp)
            mstg.g.ep.type[e] = MSTType.follow_up

            # store global context in cross_point
            mstg.g.vp.state[fcp] = os.get_global_contexts(new_state.context)

            # calculate follow up metastates
            metastates = self._create_metastates(mstg, new_state, fcp)

            ret.append((fcp, metastates))

        return ret

    def _double_evaluated_state(self, mstg, old_cp, states: List[Metastate]):
        """Check for already evaluated states and handle them.

        Return true, if the state is already evaluated.
        """
        mstg_g = mstg.g
        if any([x.is_new for x in states]):
            # at least one node is new
            return False

        # check, if the states have another common crosspoint
        # than the current one
        m2sy = mstg_g.edge_type(MSTType.m2sy)
        cps_lists = [set(m2sy.vertex(x.state).in_neighbors())
                     for x in states]
        # list of crosspoint that are predecessors of all states
        cps = reduce(lambda a, b: a & b, cps_lists) - {old_cp}
        if not cps:
            # no other common cross point found
            return False

        # check, if the states (not the metastates) are the same
        st2sy = mstg_g.edge_type(MSTType.st2sy)
        entries = set([x.entry for x in states])
        for cp in cps:
            for n in st2sy.vertex(cp).out_neighbors():
                if n not in entries:
                    return False

        # transfer sy2sy edges from already evaluated cross point and mark as
        # neighbor
        for cp in cps:
            # mark as neighbor
            e = mstg_g.add_edge(old_cp, mstg_g.vertex(cp))
            mstg_g.ep.type[e] = MSTType.sync_neighbor

            # sync edges
            sy2sy = mstg_g.edge_type(MSTType.sy2sy)
            for e in list(sy2sy.vertex(cp).out_neighbors()):
                new_e = mstg_g.add_edge(mstg_g.vertex(old_cp),
                                        mstg_g.vertex(e))
                mstg_g.ep.type[new_e] = MSTType.sy2sy

        return True

    def _is_existing_crosspoint(self, mstg, cross_state, timed_states, src_cp):
        st2sy = mstg.g.edge_type(MSTType.st2sy)
        for vertex in st2sy.vertex(cross_state).out_neighbors():
            is_equal = True

            for t_test in vertex.in_neighbors():
                if t_test != cross_state and t_test not in timed_states:
                    is_equal = False
                    break
            if is_equal:
                e = mstg.g.add_edge(src_cp, vertex)
                mstg.g.ep.type[e] = MSTType.sy2sy
                return True
        return False

    def run(self):
        entry_label = self.entry_point.get()
        if not entry_label:
            self._fail("Entry point must be given.")
        self._log.info(f"Analyzing entry point: '{entry_label}'")

        # create graph
        @dataclasses.dataclass
        class MSTG:
            g: MSTGraph
            cross_core_map: graph_tool.PropertyMap
            type_map: graph_tool.PropertyMap

        mstg = MSTGraph()
        cross_core_map = mstg.new_vp("vector<int32_t>")
        type_map = mstg.new_vp("int")

        self.state_map = {}

        mstg = MSTG(g=mstg, cross_core_map=cross_core_map, type_map=type_map)

        # initialize stack
        cp, states = self._get_initial_states(mstg)

        # stack consisting of pairs of a cross point + the metastate that
        # follow this cross point
        stack = [(cp, states)]

        if self.dump.get():
            self.dump_mstg(mstg.g, extra="init")

        # actual algorithm
        counter = 0
        while stack:
            self._log.debug(
                f"Round {counter:3d}, "
                f"Stack with {len(stack)} state(s)"
            )
            old_cp, states = stack.pop(0)

            if self._double_evaluated_state(mstg, old_cp, states):
                continue

            for cross_state in self._find_cross_state(mstg, states, old_cp):
                for timed_states in self._find_timed_states(mstg, cross_state, states):
                    if self._is_existing_crosspoint(mstg, cross_state, timed_states, old_cp):
                        continue
                    # create new cross point
                    cp = self._create_cross_point(mstg, cross_state, timed_states, old_cp)
                    follow_up_states = self._evaluate_crosspoint(mstg, cp)
                    stack += follow_up_states
                    if self.dump.get():
                        self.dump_mstg(mstg.g, extra=f"round.{counter:03d}")
            counter += 1

        self._log.info(f"Analysis needed {counter} iterations.")

        self._graph.mstg = mstg.g

        if self.dump.get():
            self._step_manager.chain_step(
                {
                    "name": "Printer",
                    "dot": self.dump_prefix.get() + "mstg.dot",
                    "graph_name": "MSTG",
                    "subgraph": "mstg",
                }
            )
