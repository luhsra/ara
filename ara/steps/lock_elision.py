"""Container for Dummy."""
from ara.os.autosar import Spinlock
from ara.os.os_base import ExecState
from ara.graph import MSTType
from .step import Step


class LockElision(Step):
    """Detect lock usages within the SSTG that are not necessary."""

    # Operating system specific API to get locks
    # This is a list of tuples. One tuple is OS specific.
    # Is has the following structure:
    # (Class of lock, Function which returns the name,
    #  Function which specifies that the lock is spinning)
    LOCKS = [(Spinlock, lambda x: x.name, lambda x: x.is_spinning)]

    def get_single_dependencies(self):
        return ["MultiSSE"]

    def run(self):
        mstg = self._graph.mstg
        lock_count = {}
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
                                if 'DEADLOCK' not in lock_count:
                                    lock_count['DEADLOCK'] = {}
                                lock_count['DEADLOCK'][name] = lock_count['DEADLOCK'].get(name, 0) + 1

        for lock, amount in lock_count.items():
            self._log.warn(f"Lock {lock} spins {amount} times")

        self._set_step_data(lock_count)
