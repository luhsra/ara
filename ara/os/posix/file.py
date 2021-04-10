
import html
from dataclasses import dataclass, field
from enum import Enum, IntEnum
from typing import Any, Union, Optional, Dict
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, assign_id, Arg
from .posix_utils import POSIXInstance, debug_log, handle_soc


class FileType(Enum):
    REGULAR = 0
    DIRECTORY = 1
    # TODO: Add all file types

@dataclass
class File(POSIXInstance):
    absolute_pathname: str
    file_type: FileType
    # TODO: Add further file mode data

@dataclass
class FileDescriptor(POSIXInstance):
    value: int
    connected_to_file: Optional[File]


class FileSyscalls:
    pass