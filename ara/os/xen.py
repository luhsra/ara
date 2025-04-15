# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

from graph_tool import Graph
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

logger = get_logger("XEN")

class XEN(OSBase):
    
    system_count: int = 0
    system_types: list[OSBase] = []
    cfg_list: list[CFG] = []
    instances_list: list[InstanceGraph] = []
    graph_list: list[Graph] = []

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
        cpus: list[CPU] = []
        # instances = InstanceGraph TODO
        for idx, s in enumerate(states):
            assert len(s.cpus) == 1, f"Tried to merge state that is already multicore {len(s.cpus)}."
            cpu: CPU = s.cpus.one()
            cpu.id = idx
            cpus.append(cpu)


        # cfg emtpy for now
        # TODO XEN [0]
        state = OSState(cpus=CPUList(cpus), cfg=states[0].cfg, instances=states[0].instances)

        for s in states:
            for k,v in s.context.items():
                logger.info(f"Adding context: {k} {v}")
                state.context[k] = v

        return state

    @staticmethod
    def get_initial_state(cfg: CFG, instances: InstanceGraph) -> OSState:
        logger.warning(f"Get inital state from {XEN.system_count} systems.")
        states: OSState = []
        for i in range(XEN.system_count):
            states.append(XEN.system_types[i].get_initial_state(
                cfg=XEN.cfg_list[i],
                instances=XEN.instances_list[i]))

        return XEN.merge_states(states)



    @staticmethod
    def get_cpu_local_contexts(context: dict, cpu_id: int, instances: InstanceGraph) -> dict:
        # since each system is single-core assume id=0
        return XEN.system_types[cpu_id].get_cpu_local_contexts(context, 0, instances)

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
    def interpret(graph: Graph, state: OSState, cpu_id, categories=SyscallCategory.every) -> OSState:
        # TODO XEN [0]

        logger.error(f"cpu_id: {cpu_id} System count: {XEN.system_count} {XEN.graph_list}\nCurrent graph: {graph}")
        return XEN.system_types[0].interpret(graph=XEN.graph_list[0], state=state, cpu_id=cpu_id, categories=categories)

    @staticmethod
    def schedule(state: OSState, cpus=None) -> None:
        # TODO XEN [0]
        XEN.system_types[0].schedule(state=state, cpus=cpus)
        # s1,s2 = split_states(state)
        # XEN.os0.schedule(s1)
        # XEN.os0.schedule(s2)
