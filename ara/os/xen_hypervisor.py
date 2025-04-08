# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

from ara.util import get_logger

from .os_util import (
    syscall,
    Arg,
    set_next_abb,
    connect_from_here,
    find_instance_node,
    Parenthesis,
)
from ara.graph import CFG, InstanceGraph, SyscallCategory
from .os_base import (
    OSBase,
    OSState,
    CPUList,
    CPU,
    ControlInstance,
    TaskStatus,
    ControlContext,
    CrossCoreAction,
    ExecState,
    CPUBounded,
    IRQ,
    IRQContext,
    InterruptMissing,
)

logger = get_logger("AUTOSAR")


class XEN_HYPERVISOR(OSBase):
    
    system_count: int
    system_types: list[OSBase]
    # cfgs: list[CFG]
    # instances: list[InstanceGraph]

    # @classmethod
    # def is_syscall(cls, function_name):
    #     """Return whether a function name is a system call of this OS."""
    #     if hasattr(cls, function_name):
    #         return hasattr(getattr(cls, function_name), "syscall")
    #     return False

    @classmethod
    def is_interaction(cls, ty) -> bool:
        """Return whether an edge type is an interaction in this OS."""
        return True

    # @staticmethod
    # def get_special_steps():
    #     """Return OS specific preprocessing steps."""
    #     from ara.steps import get_native_component
    #     ValueAnalyzer = get_native_component("ValueAnalyzer")
    #     return ValueAnalyzer.get_dependencies()

    @staticmethod
    def has_dynamic_instances():
        """Does this OS create instances at runtime?"""
        raise NotImplementedError

    @staticmethod
    def merge_states(states: list[OSState]) -> OSState:
        cpus = []
        context = {}
        # instances = InstanceGraph TODO
        for s in states:
            assert(len(s.cpus) == 1, "Tried to merge state that is already multicore.")
            cpus.append(s.cpus)

            for c in s.context:
                logger.error(f"Found context: {c}")

        # cfg emtpy for now
        state = OSState(cpus=cpus, cfg=None, instances=states[0].instances)

    @staticmethod
    def get_initial_state(cfg: CFG, instances: InstanceGraph):
        states: OSState = []
        for i in range(XEN_HYPERVISOR.system_count):
            states.append(XEN_HYPERVISOR.system_types[i].get_initial_state())

        return XEN_HYPERVISOR.merge_states(states)



    @staticmethod
    def get_cpu_local_contexts(contexts, cpu_id, instances):
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
    def interpret(graph, state, cpu_id, categories=SyscallCategory.every):
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
    def schedule(state, cpus=None):
        pass
        # s1,s2 = split_states(state)
        # XEN_HYPERVISOR.os0.schedule(s1)
        # XEN_HYPERVISOR.os0.schedule(s2)
