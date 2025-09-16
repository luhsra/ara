# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

from collections import defaultdict
from copy import copy
from dataclasses import dataclass, field
from enum import IntEnum
from itertools import chain
from typing import Any, List
from graph_tool import Graph, GraphView
from graph_tool.search import dfs_iterator

import pyllco

from ara.util import get_logger, has_path
from ara.graph import CallPath, InstanceGraph, SyscallCategory, SigType, single_check, edge_types, CFG

from .os_util import (
    syscall,
)
from .os_base import (
    CPUBounded,
    OSBase,
    OSState,
    CrossOSEvent,
    IRQ,
)

from ara.util import get_logger
logger = get_logger("BareMetal")

@dataclass(repr=False)
class Task(CrossOSEvent, CPUBounded):
    name: str

class BareMetal(OSBase):
    """BareMetal model."""

    @staticmethod
    def get_initial_state(cfg: CFG, instances: InstanceGraph) -> OSState:
        """Get the OS specific initial state.

        Arguments:
        cfg       -- the control flow graph
        instances -- the already detected global instances
        """
        raise NotImplementedError

    @staticmethod
    def get_cpu_local_contexts(context: dict, cpu_id: int, instances: InstanceGraph) -> dict:
        """Get all contexts that affect cpu_id."""
        raise NotImplementedError

    @staticmethod
    def get_global_contexts(contexts, instances):
        """Get all contexts that affect multiple CPUs."""
        raise NotImplementedError

    @staticmethod
    def handle_irq(graph, state, cpu_id, irq):
        """Handle an (asynchronous) IRQ.

        Arguments:
        graph      -- the system graph
        state      -- the current system state (see the State class)
        cpu_id     -- the CPU where the system call occurs
        irq        -- the IRQ number

        Return:
        The follow up state or None if the IRQ is invalid.
        """
        raise NotImplementedError

    @staticmethod
    def handle_exit(graph, state, cpu_id):
        """Handle an irregular exit.

        Some exits cannot be followed within the ICFG (most notably ISR exits).
        Only the OS model can handle this.

        Arguments:
        graph      -- the system graph
        state      -- the current system state (see the State class)
        cpu_id     -- the CPU where the system call occurs

        Return:
        A list of follow up states.
        """
        raise NotImplementedError

    @staticmethod
    def interpret(graph: graph_tool.Graph, state: OSState, cpu_id, categories=SyscallCategory.every) -> OSState:
        """Entry point for a synchronous os action (system call).

        Arguments:
        graph      -- the system graph
        state      -- the current system state (see the State class)
        cpu_id     -- the CPU where the system call occurs
        categories -- interpret only specific system calls (for performance)

        Return:
        The follow up state.
        """
        raise NotImplementedError()

    @staticmethod
    def schedule(state: OSState, cpus=None) -> None:
        """Schedule the current state.

        Arguments:
        state -- the current system state
        cpus  -- a list of cpu_ids, defaults to all CPUs
        """
        raise NotImplementedError()

    # For HyperSSE/Xen
    @staticmethod
    def move_context(context: dict, target_cpu_id: int) -> dict:
        """HyperSSE starts with each system thinking its running on cpu 0, 
         this function moves the context to target_cpu_id
         single core contexte mit cpu0 -> single core contexte mit cpuNEW"""

        raise NotImplementedError()
    
    def move_irqhandler(irq: IRQ, inst: InstanceGraph, target_cpu_id: int) -> None:
        """When FakeIRQ-CPUs get added in add_interrupts(...) at the beginning of MultiSSE, the 
         IRQ is generated from the InstanceGraph, which does not know the cpu_id's 
         in HyperSSE. Since Zephyr and Autosar use a different IRQ-obj an OS-wrapper is needed."""

        raise NotImplementedError()

    @staticmethod
    def find_cross_os_event(state: OSState, cpu_id: int, cb: str) -> CrossOSEvent:
        """Autosar currently only supports its Task as CrossOSEvents"""

        raise NotImplementedError()

    @staticmethod
    def trigger_cross_os_event(state: OSState, cpu_id: int, event: CrossOSEvent) -> OSState:
        """Wrapper to apply the event to the given state, currently only ActivateTask is supported."""
        
        raise NotImplementedError()