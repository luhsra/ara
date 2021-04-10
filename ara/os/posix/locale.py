import html
from dataclasses import dataclass, field
from enum import Enum, IntEnum
from typing import Any, Union, Optional, Dict
from queue import Queue
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, assign_id, Arg
from .posix_utils import POSIXInstance, debug_log, handle_soc

@dataclass
class Locale(POSIXInstance):
    pass    # Save only the name for now.
            # The POSIX locale is called "POSIX" or "C".
            # The default locale is implementation defined.

class LocaleSyscalls:
    pass