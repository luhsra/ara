import pyllco
from dataclasses import dataclass
from typing import Any
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, Arg
from .posix_utils import IDInstance, register_instance, add_edge_from_self_to, static_init_detection, StaticInitSyscalls

@dataclass(eq = False)
class Mutex(IDInstance):
    wanted_attrs = ["name", "num_id"]
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#2980b9",
        "style": "filled"
    }

    def __post_init__(self):
        super().__init__()

def create_mutex(graph, abb, state, args, va):
    """Creates a new Mutex instance."""
    new_mutex = Mutex(name=None)
    args.mutex = new_mutex
    return register_instance(new_mutex, f"{new_mutex.name}", graph, abb, state)

class MutexSyscalls:

    # int pthread_mutex_init(pthread_mutex_t *restrict mutex,
    #   const pthread_mutexattr_t *restrict attr);
    @syscall(aliases={"__pthread_mutex_init"},
             categories={SyscallCategory.create},
             signature=(Arg('mutex', hint=SigType.instance),
                        Arg('attr', hint=SigType.symbol)))
    def pthread_mutex_init(graph, abb, state, args, va):
        return create_mutex(graph, abb, state, args, va)

    # int pthread_mutex_lock(pthread_mutex_t *mutex);
    @syscall(aliases={"__pthread_mutex_lock"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('mutex', hint=SigType.instance, ty=[Mutex, pyllco.GlobalVariable]),))
    def pthread_mutex_lock(graph, abb, state, args, va):
        return static_init_detection(create_mutex, 
                    lambda graph, abb, state, args, va:
                        add_edge_from_self_to(state, args.mutex, "pthread_mutex_lock()"), 
                    args.mutex, graph, abb, state, args, va)

    # int pthread_mutex_unlock(pthread_mutex_t *mutex);
    @syscall(aliases={"__pthread_mutex_unlock"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('mutex', hint=SigType.instance, ty=[Mutex, pyllco.GlobalVariable]),))
    def pthread_mutex_unlock(graph, abb, state, args, va):
        return static_init_detection(create_mutex, 
                    lambda graph, abb, state, args, va: 
                        add_edge_from_self_to(state, args.mutex, "pthread_mutex_unlock()"), 
                    args.mutex, graph, abb, state, args, va)

StaticInitSyscalls.add_comms([MutexSyscalls.pthread_mutex_lock, MutexSyscalls.pthread_mutex_unlock])