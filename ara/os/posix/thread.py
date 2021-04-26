import html
from dataclasses import dataclass, field
from enum import Enum, IntEnum
from typing import Any, Union, Optional, Dict
from queue import Queue
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, assign_id, Arg
from .posix_utils import POSIXInstance, debug_log, handle_soc

@dataclass
class Thread(POSIXInstance):
    entry_abb: Any
    function: Any
    threadID: int
    priority: int
    sched_policy: str
    #floating_point_env: Any # TODO: check type
    #current_locale: Optional[Locale]
    #signal_mask: SignalMask
    pending_signals: Queue # of Type: Queue[Signal]; TODO: Do all POSIX processes and threads have a signal queue? If yes how big is the queue?
    errno: int

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

class ThreadSyscalls:
    pass