import html
import pyllco
from dataclasses import dataclass, field
from enum import Enum, IntEnum
from typing import Any, Union, Optional, Dict
from queue import Queue
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, assign_id, Arg
from .posix_utils import POSIXInstance, debug_log, register_instance

# SIA and InteractionAnalysis requires a Hash for the Thread/Task instance.
# We provide one but allow the class to be mutable because register_instance() needs 
# to add some info to the instances before they can be registered in the InstanceGraph.
# A modification of instances later on is not designated.
@dataclass(unsafe_hash = True)
class Thread(POSIXInstance):
    entry_abb: Any
    function: Any
    threadID: int
    #priority: int
    #sched_policy: str
    #floating_point_env: Any # TODO: check type
    #current_locale: Optional[Locale]
    #signal_mask: SignalMask
    #pending_signals: Queue # of Type: Queue[Signal]; TODO: Do all POSIX processes and threads have a signal queue? If yes how big is the queue?
    #errno: int
    is_regular: bool = True # Always True if this thread is not the main thread.

    def as_dot(self):
        wanted_attrs = ["name", "function"]
        attrs = [(x, str(getattr(self, x))) for x in wanted_attrs]
        sublabel = '<br/>'.join([f"<i>{k}</i>: {html.escape(v)}"
                                    for k, v in attrs])

        return {
            "shape": "box",
            "fillcolor": "#6fbf87",
            "style": "filled",
            "sublabel": sublabel
        }

    def get_maximal_id(self):
        # TODO: use a better max_id
        return '.'.join(map(str, ["Thread",
                                  self.name,
                                  self.function,
                                  #self.priority,
                                 ]))

class ThreadSyscalls:
    
    # int pthread_create(pthread_t *restrict thread,
    #                    const pthread_attr_t *restrict attr,
    #                    void *(*start_routine)(void*), void *restrict arg);
    @syscall(categories={SyscallCategory.create},
             signature=(Arg('thread', hint=SigType.instance),
                        Arg('attr', hint=SigType.symbol),
                        Arg('start_routine', hint=SigType.symbol, ty=pyllco.Function),
                        Arg('arg', hint=SigType.symbol)))
    def pthread_create(graph, abb, state, args, va):
        
        thread_name = args.thread.get_name()
        func_name = args.start_routine.get_name()
        new_thread = Thread(name = f"Thread: {thread_name}",
                            entry_abb = graph.cfg.get_entry_abb(graph.cfg.get_function_by_name(func_name)),
                            function = func_name,
                            threadID = args.thread,
        )
        
        args.thread = new_thread
        return register_instance(new_thread, f"Thread: {thread_name} ({func_name})", graph, abb, state, va)
