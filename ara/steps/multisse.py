"""Multicore SSE analysis."""

from .option import Option, String
from .step import Step
from .printer import mstg_to_dot
from .cfg_traversal import Visitor, run_sse
from ara.graph import MSTGraph, StateType, MSTType, ABBType

import os.path
import enum

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

    def dump_mstg(self, mstg, type_map, extra):
        dot_file = self.dump_prefix.get() + f"mstg.{extra}.dot"
        dot_path = os.path.abspath(dot_file)
        os.makedirs(os.path.dirname(dot_path), exist_ok=True)
        dot_graph = mstg_to_dot(mstg, type_map=type_map, label=f"MSTG {extra}")
        dot_graph.write(dot_path)
        self._log.info(f"Write MSTG to {dot_path}.")

    def _fill_type_map(self, type_map, v, cfg, abb):
        """
        Checks the current ABB and fills the type map accordingly

        Arguments:
        type_map -- the type map
        v        -- the vertex of the current state
        cfg      -- the CFG
        abb      -- the current ABB
        """
        if abb is None:
            # Idle
            type_map[v] = ExecType.has_length
            return
        abb_type = cfg.vp.type[abb]
        if abb_type == ABBType.computation:
            type_map[v] = ExecType.has_length
        elif abb_type == ABBType.syscall:
            self._log.warn("syscall")
            syscall = getattr(self._graph.os, cfg.get_syscall_name(abb))
            self._log.warn(syscall)
            if syscall.has_time:
                type_map[v] = ExecType.has_length

    def _run_sse(self, mstg, cross_core_map, type_map, state):
        """Run the single core SSE for the given state.

        Collects all states within a metastate and returns it.
        """
        cpu_id = next(iter(state.cpus.ids()))
        # create the metastate
        m_state = mstg.add_vertex()
        mstg.vp.type[m_state] = StateType.metastate

        state_map = {}

        def _add_state(state):
            h = hash(state)
            if h in state_map:
                return False

            v = mstg.add_vertex()
            mstg.vp.type[v] = StateType.state
            mstg.vp.state[v] = state

            e = mstg.add_edge(m_state, v)
            mstg.ep.type[e] = MSTType.m2s
            mstg.ep.cpu_id[e] = cpu_id
            state_map[h] = v

            self._fill_type_map(type_map, v, state.cfg, state.cpus[cpu_id].abb)

            return True

        # add initial state
        _add_state(state)

        class SSEVisitor(Visitor):
            @staticmethod
            def get_initial_state():
                return state

            @staticmethod
            def cross_core_action(state, cpu_ids):
                cross_core_map[state_map[hash(state)]] = cpu_ids
                type_map[state_map[hash(state)]] = ExecType.cross_syscall

            @staticmethod
            def schedule(new_state):
                return self._graph.os.schedule(new_state, [cpu_id])

            @staticmethod
            def add_state(new_state):
                return _add_state(new_state)

            @staticmethod
            def add_transition(source, target):
                e = mstg.add_edge(state_map[hash(source)], state_map[hash(target)])
                mstg.ep.type[e] = MSTType.st2sy
                mstg.ep.cpu_id[e] = cpu_id

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
            color_code = {0: "black",
                          ExecType.cross_syscall: "blue",
                          ExecType.has_length: "red"}
            self.dump_mstg(mstg, type_map=(type_map, color_code),
                           extra=f"metastate.{int(m_state)}")

        return m_state

    def _get_initial_states(self, mstg, cross_core_map, type_map):
        os_state = self._graph.os.get_initial_state(
            self._graph.cfg, self._graph.instances
        )

        metastates = []
        for cpu in os_state.cpus:
            # restrict state to this cpu
            state = os_state.copy()
            state.cpus = CPUList([cpu])

            # run single core SSE on this state
            metastates.append(self._run_sse(mstg, cross_core_map, type_map, state))
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

        mstg = MSTGraph()
        cross_core_map = mstg.new_vp("vector<int32_t>")
        type_map = mstg.new_vp("int")

        states = self._get_initial_states(mstg, cross_core_map, type_map)

        stack = [states]

        counter = 0
        while stack:
            self._log.debug(
                f"Round {counter:3d}, "
                f"Stack with {len(stack)} state(s): "
                f"{[sstg.vp.state[v] for v in stack]}"
            )
            state_vertex = stack.pop(0)
            for n in self._meta_transition(state_vertex, sstg):
                new_state = self.new_vertex(sstg, n)
                sstg.add_edge(state_vertex, new_state)
                stack.append(new_state)

            counter += 1

        self._log.info(f"Analysis needed {counter} iterations.")

        self._graph.sstg = sstg
