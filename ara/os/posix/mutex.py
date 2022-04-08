from dataclasses import dataclass
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, Arg
from .posix_utils import IDInstance, StaticInitInstance, assign_instance_to_argument, register_instance, add_edge_from_self_to

@dataclass(eq = False)
class Mutex(IDInstance, StaticInitInstance):
    wanted_attrs = ["name", "num_id"]
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#2980b9",
        "style": "filled"
    }

    def __post_init__(self):
        super().__init__()

class MutexSyscalls:

    def _create_mutex(graph, state, cpu_id, args, va, edge_label):
        """Creates a new Mutex instance."""
        new_mutex = Mutex(name=None)
        state = register_instance(new_mutex, new_mutex.name, edge_label, graph, cpu_id, state)
        assign_instance_to_argument(va, args.mutex, new_mutex)
        return state

    # int pthread_mutex_init(pthread_mutex_t *restrict mutex,
    #   const pthread_mutexattr_t *restrict attr);
    @syscall(aliases={"__pthread_mutex_init"},
             categories={SyscallCategory.create},
             signature=(Arg('mutex', hint=SigType.instance),
                        Arg('attr', hint=SigType.symbol)))
    def pthread_mutex_init(graph, state, cpu_id, args, va):
        return MutexSyscalls._create_mutex(graph, state, cpu_id, args, va, "pthread_mutex_init()")

    # int pthread_mutex_lock(pthread_mutex_t *mutex);
    @syscall(aliases={"__pthread_mutex_lock"},
             categories={SyscallCategory.comm},
             signature=(Arg('mutex', hint=SigType.instance),))
    def pthread_mutex_lock(graph, state, cpu_id, args, va):
        return add_edge_from_self_to(state, args.mutex.value, "pthread_mutex_lock()", cpu_id)

    # int pthread_mutex_unlock(pthread_mutex_t *mutex);
    @syscall(aliases={"__pthread_mutex_unlock"},
             categories={SyscallCategory.comm},
             signature=(Arg('mutex', hint=SigType.instance),))
    def pthread_mutex_unlock(graph, state, cpu_id, args, va):
        return add_edge_from_self_to(state, args.mutex.value, "pthread_mutex_unlock()", cpu_id)