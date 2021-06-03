import pyllco
from dataclasses import dataclass, field
from enum import Enum, IntEnum
from typing import Any, Union, Optional, Dict
from queue import Queue
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, assign_id, Arg
from .posix_utils import POSIXInstance, IDInstance, logger, register_instance, do_not_interpret_syscall, add_edge_from_self_to

# SIA and InteractionAnalysis requires a Hash for the Thread/Task instance.
# We provide an id based implementation and allow the class to be mutable.
# Make sure to not alter the num_id field of a Thread.
@dataclass(eq = False)
class Thread(IDInstance):
    entry_abb: Any
    function: Any
    attr: Any
    arg: Any
    #priority: int
    #sched_policy: str
    #floating_point_env: Any # TODO: check type
    #current_locale: Optional[Locale]
    #signal_mask: SignalMask
    #pending_signals: Queue # of Type: Queue[Signal]; TODO: Do all POSIX processes and threads have a signal queue? If yes how big is the queue?
    #errno: int
    is_regular: bool = True # Always True if this thread is not the main thread.

    wanted_attrs = ["name", "function", "attr", "arg", "num_id"]
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#6fbf87",
        "style": "filled"
    }

    def __post_init__(self):
        super().__init__()

    def __hash__(self):
        return hash(self.num_id)


class ThreadSyscalls:

    entry_points = set()

    # int pthread_create(pthread_t *restrict thread,
    #                    const pthread_attr_t *restrict attr,
    #                    void *(*start_routine)(void*), void *restrict arg);
    @syscall(aliases={"__pthread_create"},
             categories={SyscallCategory.create},
             signature=(Arg('thread', hint=SigType.instance),
                        Arg('attr', hint=SigType.symbol),
                        Arg('start_routine', hint=SigType.symbol, ty=pyllco.Function),
                        Arg('arg', hint=SigType.symbol)))
    def pthread_create(graph, abb, state, args, va):
        
        # Name is not working:
        #thread_name = args.thread.get_name()

        func_name = args.start_routine.get_name()
        if func_name in ThreadSyscalls.entry_points:
            logger.error(f"There is already an thread with the entry point {func_name}! Ignore ...")
            return do_not_interpret_syscall(graph, abb, state)
        ThreadSyscalls.entry_points.add(func_name)
        
        new_thread = Thread(entry_abb = graph.cfg.get_entry_abb(graph.cfg.get_function_by_name(func_name)),
                            function = func_name,
                            attr=args.attr,
                            arg=args.arg,
                            name=None
        )
        
        args.thread = new_thread
        return register_instance(new_thread, f"{new_thread.name} ({func_name})", graph, abb, state, va)


    # int pthread_join(pthread_t thread, void **value_ptr);
    @syscall(aliases={"__pthread_join"},
             categories={SyscallCategory.comm},
             signature=(Arg('thread', hint=SigType.instance),
                        Arg('value_ptr', hint=SigType.symbol)))
    def pthread_join(graph, abb, state, args, va):
        return add_edge_from_self_to(graph, abb, state, args.thread, "pthread_join()")