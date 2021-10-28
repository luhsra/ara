"""Multicore SSE analysis."""

from .option import Option, String
from .step import Step
from .printer import mstg_to_dot
from .cfg_traversal import Visitor, run_sse
from ara.graph import MSTGraph, StateType, MSTType
from ara.os.os_base import ExecState

import os.path
import enum
import graph_tool
import dataclasses

# time counter for performance measures
c_debugging = 0  # in milliseconds

MAX_UPDATES = 2
MAX_STATE_UPDATES = 20
MIN_EMULATION_TIME = 200

sse_counter = 0


class ExecType(enum.IntEnum):
    has_length = 1
    cross_syscall = 2


class CPUList:
    """Object that behaves like a list but can have holes."""

    def __init__(self, cpus):
        self._cpus = dict([(cpu.id, cpu) for cpu in cpus])

    def ids(self):
        """Return a generator of all CPU IDs."""
        return self._cpus.keys()

    def __len__(self):
        return len(self._cpus)

    def __iter__(self):
        return iter(self._cpus.values())

    def __getitem__(self, idx):
        return self._cpus[idx]


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

    def _run_sse(self, mstg, state):
        """Run the single core SSE for the given state.

        Collects all states within a metastate and returns it.
        """
        cpu_id = next(iter(state.cpus.ids()))
        # create the metastate
        m_state = mstg.g.add_vertex()
        mstg.g.vp.type[m_state] = StateType.metastate
        mstg.g.vp.cpu_id[m_state] = cpu_id

        state_map = {}

        def _add_state(state):
            h = hash(state)
            if h in state_map:
                return False

            v = mstg.g.add_vertex()
            mstg.g.vp.type[v] = StateType.state
            mstg.g.vp.state[v] = state

            e = mstg.g.add_edge(m_state, v)
            mstg.g.ep.type[e] = MSTType.m2s
            mstg.g.ep.cpu_id[e] = cpu_id
            state_map[h] = v

            if state.cpus[cpu_id].exec_state & ExecState.with_time:
                mstg.type_map[v] = ExecType.has_length

            return True

        # add initial state
        _add_state(state)

        class SSEVisitor(Visitor):
            @staticmethod
            def get_initial_state():
                return state

            @staticmethod
            def cross_core_action(state, cpu_ids):
                mstg.cross_core_map[state_map[hash(state)]] = cpu_ids
                mstg.type_map[state_map[hash(state)]] = ExecType.cross_syscall

            @staticmethod
            def schedule(new_state):
                return self._graph.os.schedule(new_state, [cpu_id])

            @staticmethod
            def add_state(new_state):
                return _add_state(new_state)

            @staticmethod
            def add_transition(source, target):
                e = mstg.g.add_edge(state_map[hash(source)], state_map[hash(target)])
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

        return m_state

    def _get_initial_states(self, mstg):
        os_state = self._graph.os.get_initial_state(
            self._graph.cfg, self._graph.instances
        )

        metastates = []
        for cpu in os_state.cpus:
            # restrict state to this cpu
            state = os_state.copy()
            state.cpus = CPUList([cpu])

            # run single core SSE on this state
            metastates.append(self._run_sse(mstg, state))
        return metastates

    def _meta_transition(self, state_vertex, sstg):
        metastate = sstg.vp.state[state_vertex]
        for cpu_id, state_id in metastate.sync_states.items():
            for state in state_id:
                pass
                # evaluate state
                # sctg = metastate.state_graph[cpu_id]
                # sctg.vp.

                # os_state = 

                # new_states = self.graph.os.interpret(self.graph, os_state, cpu_id, SyscallCategory.every)
                # for new_state in new_states:
                #     # cross product with every state on every other cpu

        # for state_vertex
        return []

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

        mstg = MSTG(g=mstg, cross_core_map=cross_core_map, type_map=type_map)

        # initialize stack
        states = self._get_initial_states(mstg)
        stack = [states]

        # actual algorithm
        counter = 0
        while stack:
            self._log.debug(
                f"Round {counter:3d}, "
                f"Stack with {len(stack)} state(s)"
            )
            state_vertex = stack.pop(0)
            for n in self._meta_transition(state_vertex, sstg):
                new_state = self.new_vertex(sstg, n)
                sstg.add_edge(state_vertex, new_state)
                stack.append(new_state)

            counter += 1

        self._log.info(f"Analysis needed {counter} iterations.")

        self._graph.mstg = mstg
