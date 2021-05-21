import html
from dataclasses import dataclass, field
from enum import Enum, IntEnum
from typing import Any, Union, Optional, Dict
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, assign_id, Arg
from .posix_utils import POSIXInstance, logger, handle_soc

@dataclass
class Mutex(POSIXInstance):
    pass

class MutexSyscalls:
    pass