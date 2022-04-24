from dataclasses import dataclass
from ara.graph import SyscallCategory, SigType
from ara.os.posix.mutex import Mutex

from ..os_util import syscall, Arg
from .posix_utils import IDInstance, StaticInitInstance, assign_instance_to_argument, register_instance, add_edge_from_self_to

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

    def _create_cond(graph, state, cpu_id, args, va, edge_label):
        """Creates a new ConditionVariable instance."""
        new_cond = ConditionVariable(name=None)
        state = register_instance(new_cond, new_cond.name, edge_label, graph, cpu_id, state)
        assign_instance_to_argument(va, args.cond, new_cond)
        return state

    # int pthread_cond_init(pthread_cond_t *restrict cond,
    #   const pthread_condattr_t *restrict attr);
    @syscall(categories={SyscallCategory.create},
             signature=(Arg('cond', hint=SigType.instance),
                        Arg('attr', hint=SigType.symbol)))
    def pthread_cond_init(graph, state, cpu_id, args, va):
        return CondSyscalls._create_cond(graph, state, cpu_id, args, va, "pthread_cond_init()")

    # int pthread_cond_broadcast(pthread_cond_t *cond);
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg('cond', hint=SigType.instance, ty=ConditionVariable),))
    def pthread_cond_broadcast(graph, state, cpu_id, args, va):
        return add_edge_from_self_to(state, args.cond, "pthread_cond_broadcast()", cpu_id, expected_instance='ConditionVariable')

    # int pthread_cond_signal(pthread_cond_t *cond);
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg('cond', hint=SigType.instance, ty=ConditionVariable),))
    def pthread_cond_signal(graph, state, cpu_id, args, va):
        return add_edge_from_self_to(state, args.cond, "pthread_cond_signal()", cpu_id, expected_instance='ConditionVariable')

    # int pthread_cond_wait(pthread_cond_t *restrict cond,
    #   pthread_mutex_t *restrict mutex);
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg('cond', hint=SigType.instance, ty=ConditionVariable),
                        Arg('mutex', hint=SigType.instance, ty=Mutex)))
    def pthread_cond_wait(graph, state, cpu_id, args, va):
        state = add_edge_from_self_to(state, args.cond, "pthread_cond_wait()", cpu_id, expected_instance='ConditionVariable')
        # Create also edge to Mutex:
        return add_edge_from_self_to(state, args.mutex, "pthread_cond_wait()", cpu_id, expected_instance='Mutex')