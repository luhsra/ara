import pyllco
from dataclasses import dataclass
from typing import Any
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, Arg
from .posix_utils import IDInstance, StaticInitInstance, assign_instance_to_argument, register_instance, add_edge_from_self_to, static_init_detection, StaticInitSyscalls
from .mutex import Mutex, create_mutex

@dataclass(eq = False)
class ConditionVariable(IDInstance, StaticInitInstance):
    wanted_attrs = ["name", "num_id"]
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#a138bb",
        "style": "filled"
    }

    def __post_init__(self):
        super().__init__()
        
class CondSyscalls:

    def _create_cond(graph, state, cpu_id, args, va, register_instance=register_instance):
        """Creates a new ConditionVariable instance."""
        new_cond = ConditionVariable(name=None)
        state = register_instance(new_cond, f"{new_cond.name}", graph, cpu_id, state)
        assign_instance_to_argument(va, args.cond, new_cond)
        return state

    # int pthread_cond_init(pthread_cond_t *restrict cond,
    #   const pthread_condattr_t *restrict attr);
    @syscall(categories={SyscallCategory.create},
             signature=(Arg('cond', hint=SigType.instance),
                        Arg('attr', hint=SigType.symbol)))
    def pthread_cond_init(graph, state, cpu_id, args, va):
        return CondSyscalls._create_cond(graph, state, cpu_id, args, va)

    # int pthread_cond_broadcast(pthread_cond_t *cond);
    @syscall(categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('cond', hint=SigType.instance),))
    def pthread_cond_broadcast(graph, state, cpu_id, args, va):
        return static_init_detection(CondSyscalls._create_cond,
                    lambda graph, state, cpu_id, args, va:
                        add_edge_from_self_to(state, args.cond.value, "pthread_cond_broadcast()", cpu_id),
                    args.cond, graph, state, cpu_id, args, va)

    # int pthread_cond_signal(pthread_cond_t *cond);
    @syscall(categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('cond', hint=SigType.instance),))
    def pthread_cond_signal(graph, state, cpu_id, args, va):
        return static_init_detection(CondSyscalls._create_cond,
                    lambda graph, state, cpu_id, args, va:
                        add_edge_from_self_to(state, args.cond.value, "pthread_cond_signal()", cpu_id),
                    args.cond, graph, state, cpu_id, args, va)

    # int pthread_cond_wait(pthread_cond_t *restrict cond,
    #   pthread_mutex_t *restrict mutex);
    @syscall(categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('cond', hint=SigType.instance),
                        Arg('mutex', hint=SigType.instance)))
    def pthread_cond_wait(graph, state, cpu_id, args, va):

        state = static_init_detection(CondSyscalls._create_cond,
                    lambda graph, state, cpu_id, args, va:
                        add_edge_from_self_to(state, args.cond.value, "pthread_cond_wait()", cpu_id),
                    args.cond, graph, state, cpu_id, args, va)

        # Create also edge to Mutex:
        return static_init_detection(create_mutex,
                    lambda graph, state, cpu_id, args, va:
                        add_edge_from_self_to(state, args.mutex.value, "pthread_cond_wait()", cpu_id),
                    args.mutex, graph, state, cpu_id, args, va)

StaticInitSyscalls.add_comms([CondSyscalls.pthread_cond_broadcast, CondSyscalls.pthread_cond_signal, CondSyscalls.pthread_cond_wait])