import pyllco
from dataclasses import dataclass, field
from enum import Enum, IntEnum
from typing import Any, Union, Optional, Dict
from queue import Queue
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, assign_id, Arg
from .posix_utils import POSIXInstance, IDInstance, logger, register_instance, do_not_interpret_syscall

# SIA and InteractionAnalysis requires a Hash for the Thread/Task instance.
# We provide one but allow the class to be mutable because register_instance() needs 
# to add some info to the instances before they can be registered in the InstanceGraph.
# A modification of instances later on is not designated.
@dataclass(unsafe_hash = True)
class Thread(IDInstance):
    entry_abb: Any
    function: Any
    #priority: int
    #sched_policy: str
    #floating_point_env: Any # TODO: check type
    #current_locale: Optional[Locale]
    #signal_mask: SignalMask
    #pending_signals: Queue # of Type: Queue[Signal]; TODO: Do all POSIX processes and threads have a signal queue? If yes how big is the queue?
    #errno: int
    is_regular: bool = True # Always True if this thread is not the main thread.

    wanted_attrs = ["name", "function", "num_id"]
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#6fbf87",
        "style": "filled"
    }

    def __post_init__(self):
        super().__init__()


class ThreadSyscalls:
    
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
        new_thread = Thread(entry_abb = graph.cfg.get_entry_abb(graph.cfg.get_function_by_name(func_name)),
                            function = func_name,
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
        #print(args.thread)
        return do_not_interpret_syscall(graph, abb, state)