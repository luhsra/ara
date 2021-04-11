""" This module contains all process related objects and syscalls.

    Session > ProcessGroup > Process > [Thread]
                   ^
                Terminal
"""
from __future__ import annotations # Activate Postponed Evaluation of Annotations

import html
from dataclasses import dataclass, field
from enum import Enum, IntEnum
from typing import Any, Union, Optional, Dict
from queue import Queue
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, assign_id, Arg
from .posix_utils import POSIXInstance, debug_log, handle_soc
from .user import User, Group
from .file import FileDescriptor
from .signal import Signal
from .thread import Thread
from .locale import Locale

@dataclass
class Session(POSIXInstance):
    """ This a list of ProcessGroups """
    process_groups: list[ProcessGroup] # TODO: Init to []
    session_leader: Process
    controlling_terminal: Optional[Terminal]
    # TODO: init this class

@dataclass
class Terminal(POSIXInstance):
    foreground_process_group: Optional[ProcessGroup]
    canonical_mode_input_processing: bool # If true the terminal read in lines.

@dataclass
class ProcessGroup(POSIXInstance):
    process_group_ID: int = field(init=False)
    process_group_leader: Process
    session_membership: Session
    processes: list[Process] = field(init=False)

    def __post_init__(self):
        self.process_group_ID = self.process_group_leader
        self.processes = list(self.process_group_leader)

@dataclass
class Process(POSIXInstance):
    process_id: int
    parent_process: Process
    process_group: ProcessGroup
    #session_membership: Session # TODO: investigate: Can a process change its session membership without changing the process group
    real_user: User
    effective_user: User
    saved_user: User
    real_group: Group
    effective_group: Group
    saved_group: Group
    supplementary_groups: list[Group]
    working_dir: str
    root_dir: str
    file_mode_creation_mask: Any # TODO: determine type of this field
    file_descriptors: list[FileDescriptor] # TODO: Init to []
    global_locale: Locale
    controlling_terminal: Optional[Terminal]
    pending_signals: Queue[Signal] # TODO: Do all POSIX processes and threads have a signal queue? If yes how big is the queue?
    threads: list[Thread] # TODO: Init to []
    is_living: bool = True

    def as_dot(self):
        pass

class ProcessSyscalls:
    pass

class ProcessGroupSyscalls:
    pass

class TerminalSyscalls:
    pass

class SessionSyscalls:
    pass
