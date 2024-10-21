import enum

from ara.os.os_base import TaskStatus

def BIT(bit: int) -> int:
    return 1 << bit

# FIXME: move this to e.g. zephyr.adapters?
# counterpart of ara.os.os_base.TaskStatus
class ThreadStateAdapter(enum.IntFlag):
    # from include/zephyr/kernel_struct.h
    _THREAD_DUMMY = BIT(0)
    _THREAD_PENDING = BIT(1)
    _THREAD_PRESTART = BIT(2)
    _THREAD_DEAD = BIT(3)
    _THREAD_SUSPENDED = BIT(4)
    _THREAD_ABORTING = BIT(5)
    _THREAD_SUSPENDING = BIT(6)
    _THREAD_QUEUED = BIT(7)


    @staticmethod
    def fromZephyr(state: int) -> TaskStatus:
        ZephyrMap = {
            0: None,
            ThreadStateAdapter._THREAD_DUMMY: TaskStatus.terminated,
            ThreadStateAdapter._THREAD_PENDING: TaskStatus.running,
            ThreadStateAdapter._THREAD_PRESTART: TaskStatus.blocked,
            ThreadStateAdapter._THREAD_DEAD: TaskStatus.terminated,
            ThreadStateAdapter._THREAD_SUSPENDED: TaskStatus.suspended,
            ThreadStateAdapter._THREAD_ABORTING: TaskStatus.terminated,
            ThreadStateAdapter._THREAD_SUSPENDING: TaskStatus.suspended,
            ThreadStateAdapter._THREAD_QUEUED: TaskStatus.ready,

            # blocked: if not in ready queue ... not as simple as a map... for example waiting for a kernel object / e.g. sem
        }

        # TODO parse the zephyr state variable and create the corresponding TaskStatus
        #return TaskStatus.running

        # need more information than just the thread.state
        # _z_kernel for the queues ...
        if state in ZephyrMap:
            return ZephyrMap[state]
        return state

    @staticmethod
    def fromAbSS(state: TaskStatus) -> int:
        # AbSSMap = {v: k for k, v in ZephyrMap.items()}
        AbSSMap = {
            TaskStatus.running: ThreadStateAdapter._THREAD_QUEUED,
            TaskStatus.blocked: ThreadStateAdapter._THREAD_PENDING,
            TaskStatus.ready: ThreadStateAdapter._THREAD_QUEUED,
            TaskStatus.suspended: ThreadStateAdapter._THREAD_SUSPENDING,
            TaskStatus.terminated: ThreadStateAdapter._THREAD_DEAD,
        }
        return AbSSMap[state]
