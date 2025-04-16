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


        # for 
        # cfg emtpy for now
        # TODO XEN [0]
        state = OSState(cpus=CPUList(cpus), cfg=states[1].cfg, instances=states[1].instances)
        state.hypersse_state(system_count=XEN.system_count, cfg_list=XEN.cfg_list, 
                             instances_list=XEN.instances_list)

        for i, s in enumerate(states):
            new_context = XEN.system_types[i].move_context(s.context, i)
            for k,v in new_context.items():
                state.context[k] = v

        return state

    @staticmethod
    def get_initial_state(cfg: CFG, instances: InstanceGraph) -> OSState:
        logger.warning(f"Get inital state from {XEN.system_count} systems.")
        states: OSState = []
        for i in range(XEN.system_count):
            states.append(XEN.system_types[i].get_initial_state(
                cfg=XEN.cfg_list[i],
                instances=XEN.instances_list[i])
                )

        return XEN.merge_states(states)


    @staticmethod
    def get_cpu_local_contexts(context: dict, cpu_id: int, instances: InstanceGraph) -> dict:
        # since each system is single-core assume id=0
        # here we have to translate back again that each system thinks it has cpu_id 0
        # instances is already set to the right graph


        # TODO what happens when context contains 
        new_context = XEN.system_types[cpu_id].get_cpu_local_contexts(context, cpu_id, instances)

        # for k, v in new_context.items():
        #    logger.info(f"{k} : {v}")

        return new_context


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
        logger.warning(f"Interpret: cpu_id: {cpu_id} System count: {XEN.system_count} {XEN.graph_list}\nCurrent graph: {graph}")
        return XEN.system_types[cpu_id].interpret(graph=XEN.graph_list[cpu_id], state=state, cpu_id=cpu_id, categories=categories)

    @staticmethod
    def split_states(state: OSState) -> list[OSState]:
        
        states: list[OSState] = []
        cpus: list[CPU] = [cpu.id for cpu in state.cpus]

        logger.debug(f"Splitting state into {len(cpus)} states.")

        # instances = InstanceGraph TODO
        for idx, cpu in enumerate(cpus):
            states.append(OSState(cpus=CPUList(cpus=cpu), cfg=XEN.cfg_list[idx].cfg, instances=XEN.instances_list[idx].instances))

        # see _get_single_core_states in MultiSSE
        return states
    
            
    
    @staticmethod
    def schedule(state: OSState, cpus=None) -> None:

        if cpus is None:
            cpus = [cpu.id for cpu in state.cpus]

        if len(cpus) == 1:
            XEN.system_types[0].schedule(state=state, cpus=cpus)

        else:

            states = XEN.split_states(state=state)

            for idx, sc_state in enumerate(states):

                # TODO XEN [0]
                XEN.system_types[idx].schedule(state=sc_state, cpus=cpus)

