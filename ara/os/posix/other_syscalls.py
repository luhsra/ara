import html
from dataclasses import dataclass, field
from enum import Enum, IntEnum
from typing import Any, Union, Optional, Dict
from queue import Queue
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, assign_id, Arg
from .posix_utils import POSIXInstance, debug_log, handle_soc

class OtherSyscalls:

    @syscall(categories={SyscallCategory.comm})
    def pause(graph, abb, state, args, va):

        debug_log("found pause() syscall")
        return state