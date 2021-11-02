"""Container for Dummy."""
from ara.os.autosar import Spinlock
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
            for state_vert in mstg.vertex(ms).out_neighbors():
                state = mstg.vp.state[state_vert]
                for lock_type, get_name, get_status in LockElision.LOCKS:
                    for inst, obj in state.instances.get(lock_type):
                        name = get_name(obj)
                        if name not in lock_count:
                            lock_count[name] = 0
                        if obj in state.context and get_status(state.context[obj]):
                            lock_count[get_name(obj)] += 1

        for lock, amount in lock_count.items():
            self._log.warn(f"Lock {lock} spins {amount} times")

        self._set_step_data(lock_count)
