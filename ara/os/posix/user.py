from __future__ import annotations # Activate Postponed Evaluation of Annotations

import html
from dataclasses import dataclass, field
from enum import Enum, IntEnum
from typing import Any, Union, Optional, Dict
from queue import Queue
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, assign_id, Arg
from .posix_utils import POSIXInstance, debug_log, handle_soc

@dataclass
class Group(POSIXInstance):
    """ This object describes an UserGroup """
    group_id: int
    allowed_users: list[User]

@dataclass
class User(POSIXInstance):
    userID: int
    init_group: Group
    init_working_dir: str
    init_user_program: str

class UserSyscalls:
    pass

class GroupSyscalls:
    pass