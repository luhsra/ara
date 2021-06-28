import pyllco
from dataclasses import dataclass
from typing import Any
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, Arg
from .posix_utils import IDInstance, logger, register_instance, add_edge_from_self_to, static_init_detection, StaticInitSyscalls
from .mutex import Mutex, create_mutex

@dataclass(eq = False)
class ConditionVariable(IDInstance):
    wanted_attrs = ["name", "num_id"]
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#a138bb",
        "style": "filled"
    }

    def __post_init__(self):
        super().__init__()
        
class CondSyscalls:

    def _create_cond(graph, abb, state, args, va):
        """Creates a new ConditionVariable instance."""
        new_cond = ConditionVariable(name=None)
        args.cond = new_cond
        return register_instance(new_cond, f"{new_cond.name}", graph, abb, state)

    # int pthread_cond_init(pthread_cond_t *restrict cond,
    #   const pthread_condattr_t *restrict attr);
    @syscall(categories={SyscallCategory.create},
             signature=(Arg('cond', hint=SigType.instance),
                        Arg('attr', hint=SigType.symbol)))
    def pthread_cond_init(graph, abb, state, args, va):
        return CondSyscalls._create_cond(graph, abb, state, args, va)

    # int pthread_cond_broadcast(pthread_cond_t *cond);
    @syscall(categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('cond', hint=SigType.instance, ty=[ConditionVariable, pyllco.GlobalVariable]),))
    def pthread_cond_broadcast(graph, abb, state, args, va):
        return static_init_detection(CondSyscalls._create_cond,
                    lambda graph, abb, state, args, va:
                        add_edge_from_self_to(state, args.cond, "pthread_cond_broadcast()"),
                    args.cond, graph, abb, state, args, va)

    # int pthread_cond_signal(pthread_cond_t *cond);
    @syscall(categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('cond', hint=SigType.instance, ty=[ConditionVariable, pyllco.GlobalVariable]),))
    def pthread_cond_signal(graph, abb, state, args, va):
        return static_init_detection(CondSyscalls._create_cond,
                    lambda graph, abb, state, args, va:
                        add_edge_from_self_to(state, args.cond, "pthread_cond_signal()"),
                    args.cond, graph, abb, state, args, va)

    # int pthread_cond_wait(pthread_cond_t *restrict cond,
    #   pthread_mutex_t *restrict mutex);
    @syscall(categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('cond', hint=SigType.instance, ty=[ConditionVariable, pyllco.GlobalVariable]),
                        Arg('mutex', hint=SigType.instance, ty=[Mutex, pyllco.GlobalVariable])))
    def pthread_cond_wait(graph, abb, state, args, va):

        state = static_init_detection(CondSyscalls._create_cond,
                    lambda graph, abb, state, args, va:
                        add_edge_from_self_to(state, args.cond, "pthread_cond_wait()"),
                    args.cond, graph, abb, state, args, va)

        # Create also edge to Mutex:
        return static_init_detection(create_mutex,
                    lambda graph, abb, state, args, va:
                        add_edge_from_self_to(state, args.mutex, "pthread_cond_wait()"),
                    args.mutex, graph, abb, state, args, va)

StaticInitSyscalls.add_comms([CondSyscalls.pthread_cond_broadcast, CondSyscalls.pthread_cond_signal, CondSyscalls.pthread_cond_wait])