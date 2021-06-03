from dataclasses import dataclass
from typing import Any
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, Arg
from .posix_utils import IDInstance, logger, register_instance

@dataclass
class Mutex(IDInstance):
    attr: Any
    wanted_attrs = ["name", "attr", "num_id"]
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#6fbf87",
        "style": "filled"
    }

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