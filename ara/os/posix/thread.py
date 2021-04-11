import html
from dataclasses import dataclass, field
from enum import Enum, IntEnum
from typing import Any, Union, Optional, Dict
from queue import Queue
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, assign_id, Arg
from .posix_utils import POSIXInstance, debug_log, handle_soc
from .signal import Signal, SignalMask
from .locale import Locale

@dataclass
class Thread(POSIXInstance):
    entry_abb: Any
    function: Any
    threadID: int
    priority: int
    sched_policy: str
    floating_point_env: Any # TODO: check type
    current_locale: Optional[Locale]
    signal_mask: SignalMask
    pending_signals: Queue[Signal] # TODO: Do all POSIX processes and threads have a signal queue? If yes how big is the queue?
    errno: int
    partOfProcess: 'Process'

    def as_dot(self):
        wanted_attrs = ["name", "function", "priority"]
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
                                  self.priority,
                                 ]))

# TODO: remove _id_
_id_ = 1

class ThreadSyscalls:

    @syscall(categories={SyscallCategory.create},
             signature=(Arg('fildes', hint=SigType.value),
                        Arg('buf', hint=SigType.symbol),
                        Arg('nbyte', hint=SigType.value)))
    def write(graph, abb, state, args, va):

        debug_log("found write() syscall")

        global _id_
        _id_ += 1
        state = state.copy()

        # instance properties
        cp = state.call_path

        v = state.instances.add_vertex()
        state.instances.vp.label[v] = "Write"

        #new_cfg = cfg.get_entry_abb(cfg.get_function_by_name("task_function"))
        #assert new_cfg is not None
        # TODO: when do we know that this is an unique instance?
        handle_soc(state, v, graph.cfg, abb)
        state.instances.vp.obj[v] = Thread(graph.cfg, abb=None, call_path=None, name="Write_test_thread_" + str(_id_),
                                        vidx = v,
                                        entry_abb = None,
                                        function = None,
                                        threadID = 3,
                                        priority = 2,
                                        sched_policy = None,
                                        floating_point_env = None, # TODO: check type
                                        partOfTask = None,
                                        current_locale = None,
                                        signal_mask = None,
                                        pending_signals = None,
                                        errno = 0
                                        
        )

        assign_id(state.instances, v)

        state.next_abbs = []

        return state

    @syscall(categories={SyscallCategory.create},
             signature=(Arg('ptr', hint=SigType.symbol),
                        Arg('size', hint=SigType.value),
                        Arg('nitems', hint=SigType.value),
                        Arg('stream', hint=SigType.symbol)))
    def fwrite(graph, abb, state, args, va):

        debug_log("found fwrite() syscall")

        global _id_
        _id_ += 1
        state = state.copy()

        # instance properties
        cp = state.call_path

        v = state.instances.add_vertex()
        state.instances.vp.label[v] = "FWrite"

        #new_cfg = cfg.get_entry_abb(cfg.get_function_by_name("task_function"))
        #assert new_cfg is not None
        # TODO: when do we know that this is an unique instance?
        handle_soc(state, v, graph.cfg, abb)
        state.instances.vp.obj[v] = Thread(graph.cfg, abb=None, call_path=None, name="Write_test_thread_" + str(_id_) + "_Size_" + str(args.size),
                                        vidx = v,
                                        entry_abb = None,
                                        function = None,
                                        threadID = 3,
                                        priority = 2,
                                        sched_policy = None,
                                        floating_point_env = None, # TODO: check type
                                        partOfProcess = None,
                                        current_locale = None,
                                        signal_mask = None,
                                        pending_signals = None,
                                        errno = 0
        )

        assign_id(state.instances, v)

        state.next_abbs = []

        return state