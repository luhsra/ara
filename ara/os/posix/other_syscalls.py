import html
from dataclasses import dataclass, field
from enum import Enum, IntEnum
from typing import Any, Union, Optional, Dict
from queue import Queue
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, assign_id, Arg
from .posix_utils import POSIXInstance, logger, handle_soc, do_not_interpret_syscall

class OtherSyscalls:

    @syscall(categories={SyscallCategory.comm})
    def pause(graph, abb, state, args, va):
        logger.debug("found pause() syscall")
        return do_not_interpret_syscall(graph, abb, state)