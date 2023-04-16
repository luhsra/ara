# SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2022 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2023 Andreas Kässens
#
# SPDX-License-Identifier: GPL-3.0-or-later
"""Container for LockElision."""
from ara.os.autosar import Spinlock
from ara.os.os_base import ExecState
from ara.graph import MSTType, StateType
from .step import Step

from .option import Option, Bool


class LockElision(Step):
    """Detect lock usages within the SSTG that are not necessary."""

    fail_on_deadlock = Option(
        name="fail_on_deadlock",
        help="Step will fail if at least one deadlock is detected",
        ty=Bool(),
        default_value=False)

    # Operating system specific API to get locks
    # This is a list of tuples. One tuple is OS specific.
    # Is has the following structure:
    # (Class of lock, Function which returns the name,
    #  Function which specifies that the lock is spinning)
    LOCKS = [(Spinlock, lambda x: x.name,
              lambda x: x.on_hold and len(x.wait_for) > 0)]

    def _can_elide(self, state, cpu_id):
        mstg = self._graph.mstg
        st2sy = mstg.edge_type(MSTType.st2sy)
        follow_sync = mstg.edge_type(MSTType.follow_sync)

        def get_abb(state):
            return mstg.vp.state[state].cpus.one().abb

        def get_next_state(state):
            return [v for v in mstg.vertex(state).out_neighbors()].pop()

        def get_syscall_args_spinlock(state):
            syscall_name = mstg.get_syscall_name(state)
            abb = get_abb(state)
            if (syscall_name) not in [
                    "AUTOSAR_GetSpinlock", "AUTOSAR_TryToGetSpinlock",
                    "AUTOSAR_ReleaseSpinlock"
            ]:
                spinlock = None
            else:
                spinlock = self._graph.cfg.vp.arguments[abb].spinlock
            return spinlock

        def get_predecessor_states(state):
            return [
                mstg.vertex(e.source())
                for e in st2sy.vertex(state).in_edges()
            ]

        def get_cpuid(state):
            return mstg.vp.state[state].cpus.one().id

        def is_spinning_or_trying(state):
            if mstg.get_syscall_name(state) == "AUTOSAR_TryToGetSpinlock":
                return True
            return mstg.get_exec_state(state) == ExecState.waiting

        def get_successor_sps(entry_sp):
            exit_sp = get_next_state(entry_sp)
            return follow_sync.vertex(exit_sp).out_neighbors()

        queue = [get_next_state(state)]
        visited = []
        elide = True
        spinlock = get_syscall_args_spinlock(state)
        self._log.debug(f"GetSpinlock({spinlock.name}) in {state}")
        release_abb = None

        while queue:
            curr_sp = queue.pop(0)  # FIFO -> BFS
            visited.append(curr_sp)
            stop_search_subtree = False

            if mstg.vp.type[curr_sp] != StateType.entry_sync:
                self._log.warning(f"Not an entry SP {curr_sp}")
                continue

            for p in get_predecessor_states(curr_sp):

                if not get_syscall_args_spinlock(p) == spinlock:
                    continue  # irrelevant predecessor

                # Find ReleaseSpinlock on same cpu id with same spinlock
                if cpu_id == get_cpuid(p) and mstg.get_syscall_name(
                        p) == "AUTOSAR_ReleaseSpinlock":
                    self._log.debug(
                        f"matching ReleaseSpinlock({spinlock.name}) in {p} -> {curr_sp}"
                    )
                    stop_search_subtree = True
                    # store where the lock is released
                    release_abb = get_abb(p)

                if is_spinning_or_trying(p):
                    elide = False
                    self._log.debug(f"{p} -> {curr_sp} spins")

            if not stop_search_subtree:
                for next_sp in get_successor_sps(curr_sp):
                    if next_sp not in visited and next_sp not in queue:
                        queue.append(next_sp)

        return elide, release_abb

    def _may_spin(self, state, cpu_id):
        mstg = self._graph.mstg
        st2sy = mstg.edge_type(MSTType.st2sy)
        en2ex = mstg.edge_type(MSTType.en2ex)
        handled = set()

        may_spin = False
        for sync in st2sy.vertex(state).out_neighbours():
            handled.add(sync)

            for exit_sync in en2ex.vertex(sync).out_neighbors():
                for e in st2sy.vertex(exit_sync).out_edges():
                    if st2sy.ep.cpu_id[e] != cpu_id:
                        continue
                    dst = mstg.vertex(e.source())
                    spin = mstg.vp.state[dst].cpus[
                        cpu_id].exec_state == ExecState.waiting
                    self._log.debug("%s (%s) -> %s (%s) == %s", state,
                                    mstg.vp.state[state].id, dst,
                                    mstg.vp.state[dst].id, spin)
                    may_spin |= spin
        return may_spin, handled

    def get_single_dependencies(self):
        return ["MultiSSE"]

    def run(self):
        mstg = self._graph.mstg
        lock_count = {}
        deadlock = {}
        for ms in mstg.get_metastates().vertices():
            m2s_g = mstg.edge_type(MSTType.m2s)
            for state_vert in m2s_g.vertex(ms).out_neighbors():
                state = mstg.vp.state[state_vert]
                for lock_type, get_name, get_status in LockElision.LOCKS:
                    for inst, obj in state.instances.get(lock_type):
                        name = get_name(obj)
                        if name not in lock_count:
                            lock_count[name] = 0
                        if any([
                                x.exec_state == ExecState.waiting
                                for x in state.cpus
                        ]):
                            # the state is somehow waiting, check the global context
                            # why, find the predecessor cross point for that
                            m2sy = mstg.edge_type(MSTType.m2sy)
                            for sync_point in m2sy.vertex(ms).in_neighbors():
                                state = m2sy.vp.state[sync_point]
                                if state and obj in state.context and get_status(
                                        state.context[obj]):
                                    self._log.debug(
                                        f"Lock {name} spins in state {state_vert} ({state.context[obj]})"
                                    )
                                    lock_count[name] += 1
                            if len(list(m2sy.vertex(ms).out_neighbors())) == 0:
                                deadlock[name] = deadlock.get(name, 0) + 1

        for lock, amount in lock_count.items():
            self._log.warn(f"Lock {lock} spins {amount} times")

        handled_sync = set()
        details = {}
        for sync in mstg.get_sync_points().vertices():
            if sync in handled_sync:
                continue
            state, cpu_id, irq = mstg.get_syscall_state(sync)
            syscall_name = mstg.get_syscall_name(state)
            if syscall_name != 'AUTOSAR_GetSpinlock':
                continue
            spins, handled = self._may_spin(state, cpu_id)
            elide, release_abb = self._can_elide(state, cpu_id)
            details[mstg.vp.state[state].id] = {
                "state": mstg.vp.state[state].id,
                "abb": mstg.vp.state[state].cpus.one().abb,
                "spins": spins,
                "elide": elide,
                "release_abb": release_abb
            }
            handled_sync |= handled

        for res in details.values():
            s = {True: "will spin", False: "won't spin"}[res['spins']]
            e = {True: "can elide", False: "cannot elide"}[res['elide']]
            abb_name = self._graph.cfg.vp.name[res['abb']]
            self._log.warn(f"State {res['state']} ({abb_name}) {s}")
            self._log.warn(f"State {res['state']} ({abb_name}) {e}")

        if deadlock:
            if self.fail_on_deadlock.get():
                self._fail(f"Deadlock detected {deadlock}")
            else:
                self._log.warn(f"Deadlock detected {deadlock}")

        self._set_step_data({
            'spin_states': lock_count,
            'DEADLOCK': deadlock,
            'callsites': details,
        })
