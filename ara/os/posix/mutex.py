from dataclasses import dataclass
from typing import Any
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, Arg
from .posix_utils import IDInstance, logger, register_instance, add_edge_from_self_to

@dataclass
class Mutex(IDInstance):
    attr: Any
    wanted_attrs = ["name", "attr", "num_id"]
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#2980b9",
        "style": "filled"
    }

    def __post_init__(self):
        super().__init__()

class MutexSyscalls:

    # int pthread_mutex_init(pthread_mutex_t *restrict mutex,
    #   const pthread_mutexattr_t *restrict attr);
    @syscall(aliases={"__pthread_mutex_init"},
             categories={SyscallCategory.create},
             signature=(Arg('mutex', hint=SigType.instance),
                        Arg('attr', hint=SigType.symbol)))
    def pthread_mutex_init(graph, abb, state, args, va):
        
        new_mutex = Mutex(attr=args.attr,
                          name=None
        )
        
        args.mutex = new_mutex
        return register_instance(new_mutex, f"{new_mutex.name}", graph, abb, state, va)


    # int pthread_mutex_lock(pthread_mutex_t *mutex);
    @syscall(aliases={"__pthread_mutex_lock"},
             categories={SyscallCategory.comm},
             signature=(Arg('mutex', hint=SigType.instance),))
    def pthread_mutex_lock(graph, abb, state, args, va):
        return add_edge_from_self_to(graph, abb, state, args.mutex, "pthread_mutex_lock()")


    # int pthread_mutex_trylock(pthread_mutex_t *mutex);
    @syscall(aliases={"__pthread_mutex_trylock"},
             categories={SyscallCategory.comm},
             signature=(Arg('mutex', hint=SigType.instance),))
    def pthread_mutex_trylock(graph, abb, state, args, va):
        return add_edge_from_self_to(graph, abb, state, args.mutex, "pthread_mutex_trylock()")


    # int pthread_mutex_timedlock(pthread_mutex_t *restrict mutex,
    #   const struct timespec *restrict abstime);
    @syscall(aliases={"__pthread_mutex_timedlock"},
             categories={SyscallCategory.comm},
             signature=(Arg('mutex', hint=SigType.instance),
                        Arg('abstime', hint=SigType.symbol),))
    def pthread_mutex_timedlock(graph, abb, state, args, va):
        return add_edge_from_self_to(graph, abb, state, args.mutex, "pthread_mutex_timedlock()") # TODO: decode abstime


    # int pthread_mutex_unlock(pthread_mutex_t *mutex);
    @syscall(aliases={"__pthread_mutex_unlock"},
             categories={SyscallCategory.comm},
             signature=(Arg('mutex', hint=SigType.instance),))
    def pthread_mutex_unlock(graph, abb, state, args, va):
        return add_edge_from_self_to(graph, abb, state, args.mutex, "pthread_mutex_unlock()")