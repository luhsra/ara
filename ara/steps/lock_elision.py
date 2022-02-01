"""Container for Dummy."""
from ara.os.autosar import Spinlock
from ara.os.os_base import ExecState
from ara.graph import MSTType, single_check
from .step import Step


class LockElision(Step):
    """Detect lock usages within the SSTG that are not necessary."""

    # Operating system specific API to get locks
    # This is a list of tuples. One tuple is OS specific.
    # Is has the following structure:
    # (Class of lock, Function which returns the name,
    #  Function which specifies that the lock is spinning)
    LOCKS = [(Spinlock, lambda x: x.name, lambda x: x.is_spinning)]

    def _may_spin(self, state, cpu_id):
        mstg = self._graph.mstg
        st2sy = mstg.edge_type(MSTType.st2sy)
        en2ex = mstg.edge_type(MSTType.en2ex)
        handled = set()

        may_spin = False
        for sync in st2sy.vertex(state).out_neighbours():
            handled.add(sync)
            exit_sync = single_check(en2ex.vertex(sync).out_neighbours())

            for e in st2sy.vertex(exit_sync).out_edges():
                if st2sy.ep.cpu_id[e] != cpu_id:
                    continue
                dst = mstg.vertex(e.source())
                spin = mstg.vp.state[dst].cpus[cpu_id].exec_state == ExecState.waiting
                self._log.debug("%s (%s) -> %s (%s) == %s",
                                state, mstg.vp.state[state].id,
                                dst, mstg.vp.state[dst].id, spin)
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
                        if any([x.exec_state == ExecState.waiting for x in state.cpus]):
                            # the state is somehow waiting, check the global context
                            # why, find the predecessor cross point for that
                            m2sy = mstg.edge_type(MSTType.m2sy)
                            for sync_point in m2sy.vertex(ms).in_neighbors():
                                state = m2sy.vp.state[sync_point]
                                if state and obj in state.context and get_status(state.context[obj]):
                                    lock_count[get_name(obj)] += 1
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
            details[mstg.vp.state[state].id] = {
                "state": mstg.vp.state[state].id,
                "spins": spins,
            }
            handled_sync |= handled

        for res in details.values():
            s = {True: "will spin", False: "won't spin"}[res['spins']]
            self._log.warn(f"State {res['state']} {s}")


        self._set_step_data({'spin_states': lock_count,
                             'DEADLOCK': deadlock,
                             'callsites': details,
                             })
