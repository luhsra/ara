import pyllco
from dataclasses import dataclass
from typing import Any
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, Arg
from .posix_utils import IDInstance, do_not_interpret_syscall, logger, register_instance, add_edge_from_self_to, CurrentSyscallCategories

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

    # Toggle detection of PTHREAD_MUTEX_INITIALIZER.
    # Sometimes it is useful to disable this feature.
    # E.g. if the value analyzer can not retrieve the Mutex handle.
    # In this case every Mutex interaction call creates a new useless Mutex in the Interaction Graph.
    ENABLE_STATIC_INITIALIZER_DETECTION = True

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


    def mutex_interaction_impl(graph, abb, state, args, va, edge_label: str):
        """The Implementation of all Mutex Interaction Calls"""

        action_done = False
        
        # If Category "Create": Create a new Mutex object if args.mutex is a pyllco.GlobalVariable (args.mutex = PTHREAD_MUTEX_INITIALIZER)
        if SyscallCategory.create in CurrentSyscallCategories.get():
            if MutexSyscalls.ENABLE_STATIC_INITIALIZER_DETECTION and type(args.mutex) == pyllco.GlobalVariable:
                new_mutex = Mutex(attr=None,
                                  name=None
                )
                args.mutex = new_mutex
                state = register_instance(new_mutex, f"{new_mutex.name}", graph, abb, state, va)
                action_done = True

        # If Category "comm": Handle the edge creation in a normal way.
        if SyscallCategory.comm in CurrentSyscallCategories.get():
            if type(args.mutex) != pyllco.GlobalVariable or not MutexSyscalls.ENABLE_STATIC_INITIALIZER_DETECTION:
                state = add_edge_from_self_to(graph, abb, state, args.mutex, edge_label)
                action_done = True
            else:
                logger.warning("Could not create Mutex interaction edge. args.mutex is of type pyllco.GlobalVariable. Probably there was an error in the PTHREAD_MUTEX_INITIALIZER detection.")

        # Do not interpret the syscall if no action was done.
        if not action_done:
            return do_not_interpret_syscall(graph, abb, state)
        return state

    # int pthread_mutex_lock(pthread_mutex_t *mutex);
    @syscall(aliases={"__pthread_mutex_lock"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('mutex', hint=SigType.instance, ty=[Mutex, pyllco.GlobalVariable]),))
    def pthread_mutex_lock(graph, abb, state, args, va):
        return MutexSyscalls.mutex_interaction_impl(graph, abb, state, args, va, "pthread_mutex_lock()")


    # int pthread_mutex_trylock(pthread_mutex_t *mutex);
    @syscall(aliases={"__pthread_mutex_trylock"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('mutex', hint=SigType.instance, ty=[Mutex, pyllco.GlobalVariable]),))
    def pthread_mutex_trylock(graph, abb, state, args, va):
        return MutexSyscalls.mutex_interaction_impl(graph, abb, state, args, va, "pthread_mutex_trylock()")


    # int pthread_mutex_timedlock(pthread_mutex_t *restrict mutex,
    #   const struct timespec *restrict abstime);
    @syscall(aliases={"__pthread_mutex_timedlock"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('mutex', hint=SigType.instance, ty=[Mutex, pyllco.GlobalVariable]),
                        Arg('abstime', hint=SigType.symbol),))
    def pthread_mutex_timedlock(graph, abb, state, args, va):
        return MutexSyscalls.mutex_interaction_impl(graph, abb, state, args, va, "pthread_mutex_timedlock()") # TODO: decode abstime


    # int pthread_mutex_unlock(pthread_mutex_t *mutex);
    @syscall(aliases={"__pthread_mutex_unlock"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('mutex', hint=SigType.instance, ty=[Mutex, pyllco.GlobalVariable]),))
    def pthread_mutex_unlock(graph, abb, state, args, va):
        return MutexSyscalls.mutex_interaction_impl(graph, abb, state, args, va, "pthread_mutex_unlock()")