import graph_tool

import copy
import enum

from dataclasses import dataclass, field
from typing import List, Any

from ara.graph import SyscallCategory, CallPath, CFG, CFType


class TaskStatus(enum.Enum):
    running = 1,
    blocked = 2,
    ready = 3,
    suspended = 4


class CrossCoreAction(Exception):
    """The OS has detected a cross core action that cannot be handled."""


@dataclass
class ControlInstance:
    """All operating system instances (system objects) that contain control
    flow should inherit from this class. Typically, these are threads, tasks,
    ISRs.
    """
    status: TaskStatus
    abb: graph_tool.Vertex
    cfg: CFG
    call_path: CallPath


@dataclass
class CPU:
    id: int
    irq_on: bool # in a more general form, this would be the hardware state
    control_instance: graph_tool.Vertex
    abb: graph_tool.Vertex
    call_path: CallPath
    analysis_context: Any # analysis specific context information

    def copy(self):
        new_ac = None if not self.analysis_context else self.analysis_context.copy()
        return CPU(id=self.id,
                   irq_on=self.irq_on,
                   control_instance=self.control_instance,
                   abb=self.abb,
                   call_path=copy.copy(self.call_path),
                   analysis_context=new_ac)

_state_id = 0
def _get_id():
    global _state_id
    _state_id += 1
    return _state_id

@dataclass
class OSState:
    id: int = field(init=False, default_factory=_get_id)
    cpus: List[CPU]
    instances: graph_tool.Graph

    def copy(self):
        new_cpus = [cpu.copy() for cpu in self.cpus]
        return OSState(cpus=new_cpus, instances=self.instances.copy())


class OSBase:
    config = {}

    @classmethod
    def get_name(cls):
        """Get the name of the operating System."""
        return cls.__name__

    @staticmethod
    def get_special_steps():
        """Return OS specific preprocessing steps."""
        from ara.steps import get_native_component
        ValueAnalyzer = get_native_component("ValueAnalyzer")
        return ValueAnalyzer.get_dependencies()

    @staticmethod
    def has_dynamic_instances():
        """Does this OS create instances at runtime?"""
        raise NotImplementedError

    @staticmethod
    def get_initial_state(instances):
        """Get the OS specific initial state.

        Arguments:
        instances -- the already detected global instances
        """
        instances
        raise NotImplementedError

    @staticmethod
    def interpret(graph, state, cpu, categories=SyscallCategory.every):
        """Entry point for a synchronous os action (system call).

        Arguments:
        graph      -- the system graph
        state      -- the current system state (see the State class)
        cpu        -- the CPU where the system call occurs
        categories -- interpret only specific system calls (for performance)

        Return:
        A list of follow up states.

        TODO: signaling an external action
        """
        raise NotImplementedError()

    @staticmethod
    def schedule(state, cpus=None):
        """Schedule the current state.

        Arguments:
        state -- the current system state
        cpus  -- a list of cpu_ids, defaults to all CPUs
        """
        raise NotImplementedError()

    @staticmethod
    def _add_normal_cfg(state, cpu_id, icfg):
        abb = state.cpus[cpu_id].abb
        neighbors = list(icfg.vertex(abb).out_neighbors())
        assert len(neighbors) == 1, "Multiple ABBs follow a syscall."
        state.cpus[cpu_id].abb = neighbors[0]
