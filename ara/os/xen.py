# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

from graph_tool import Graph
from ara.util import get_logger

from copy import copy

from .os_util import (
    syscall,
    Arg,
    set_next_abb,
    connect_from_here,
    find_instance_node,
    Parenthesis,
)
from ara.graph import CFG, InstanceGraph, SyscallCategory, SigType
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
    IRQCPU,
    IRQContext,
    InterruptMissing,
)
from ara.steps.multisse_helper.common import CrossExecState

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
        # instances = InstanceGraph 
        for idx, s in enumerate(states):
            assert len(s.cpus) == 1, f"Tried to merge state that is already multicore {len(s.cpus)}."
            cpu: CPU = s.cpus.one()
            cpu.id = idx
            cpus.append(cpu)

        state = OSState(cpus=CPUList(cpus), cfg=None, instances=None)
        state.hypersse_state(system_count=XEN.system_count, cfg_list=XEN.cfg_list, 
                             instances_list=XEN.instances_list)

        for i, s in enumerate(states):
            new_context = XEN.system_types[i].move_context(s.context, i)
            for k,v in new_context.items():
                state.context[k] = v

        return state

    @staticmethod
    # iterate over all systems and find each local interrupts
    def add_interrupts(state: OSState):
        cpu_idx = max([x.id for x in state.cpus]) + 1
        for idx, instances in enumerate(XEN.instances_list):
            tmp_instances_list = []
            for _, irq in instances.get(IRQ):
                # every irq gets an own CPU
                ctx = state.context[irq]
                if ctx.status == TaskStatus.running:
                    exec_state = CrossExecState.computation
                    cur_abb = ctx.abb
                else:
                    exec_state = CrossExecState.idle
                    cur_abb = None
                irq_cpu = IRQCPU(id=cpu_idx,
                                irq=irq,
                                reference_cpu_id=irq.cpu_id,
                                irq_on=False,
                                control_instance=instances.get_node(irq),
                                abb=cur_abb,
                                call_path=copy(ctx.call_path),
                                exec_state=exec_state,
                                analysis_context=None)
                state.cpus[irq_cpu.id] = irq_cpu
                # reassign irq
                irq.cpu_id = irq_cpu.id
                cpu_idx += 1
                
                XEN.cfg_list.append(XEN.cfg_list[idx])
                XEN.graph_list.append(XEN.graph_list[idx])
                XEN.system_types.append(XEN.system_types[idx])
                XEN.system_count += 1

                # das ist alles ein bissel yikes
                # IRQ Handling needs to find cpu core
                XEN.instances_list[idx].vp.obj[irq.isr_handler].cpu_id = idx


                tmp_instances_list.append(XEN.instances_list[idx])
        XEN.instances_list += tmp_instances_list


    @staticmethod
    def get_initial_state(cfg: CFG, instances: InstanceGraph) -> OSState:
        logger.info(f"Get inital state from {XEN.system_count} systems.")
        states: OSState = []
        for i in range(XEN.system_count):
            states.append(XEN.system_types[i].get_initial_state(
                cfg=XEN.cfg_list[i],
                instances=XEN.instances_list[i])
                )

        return XEN.merge_states(states)

    @staticmethod
    def find_system_id(state: OSState):
        for idx, cfg in enumerate(XEN.cfg_list):
            if cfg == state.cfg:
                logger.info(f"Scheduling on cpu: {idx}.")

    # used by MultiSSE in _get_single_core_states, to split multicore into singlecore states 
    @staticmethod
    def state_copy_index(old_state: OSState, system_id: int) -> OSState:

        # TODO what happens when alarm is 2nd cpu and there is a third one
        # so the alarm is not the last cpu

        # if system_id >= XEN.system_count:
        #     logger.info("Copy index out of range, only okay for irqcpu.")
            
        #     for inst, ctx in old_state.context.items():
        #         if isinstance(inst, IRQ):
        #             id = inst.cpu_id
        #             matching_cfg = inst.cfg

        #     for idx, cfg in enumerate(XEN.cfg_list):
        #         if cfg == matching_cfg:
        #             new_state = OSState(cpus=copy.copy(old_state.cpus),
        #                     instances=XEN.instances_list[idx],
        #                     cfg=XEN.cfg_list[idx])
        #             break
        # else:
            
        new_state = OSState(cpus=copy(old_state.cpus),
                                instances=old_state.instances_list[system_id],
                                cfg=old_state.cfg_list[system_id])
        # new context for control instances
        for inst, ctx in old_state.context.items():
            new_state.context[inst] = copy(ctx)
        return new_state


    @staticmethod
    def get_cpu_local_contexts(context: dict, cpu_id: int, instances: InstanceGraph) -> dict:
        # since each system is single-core assume id=0
        # here we have to translate back again that each system thinks it has cpu_id 0
        # instances is already set to the right graph


        # if cpu_id >= XEN.system_count:
        #     logger.info("get_cpu_local_contexts index out of range, okay for irqcpu.")
        #     # TODO how do handle different interupts from different os
        #     new_context = XEN.system_types[0].get_cpu_local_contexts(context, cpu_id, instances)

        # else:
            # TODO what happens when context contains 
        new_context = XEN.system_types[cpu_id].get_cpu_local_contexts(context, cpu_id, instances)

        # for k, v in new_context.items():
        #    logger.info(f"{k} : {v}")

        return new_context


    @staticmethod
    def get_global_contexts(contexts, cpu_idinstances):
        """Get all contexts that affct multiple CPUs."""
        

        local_contexts = []
        for inst, ctx in contexts.items():

            # weird case of locks for one core
            # if isinstance(inst, Spinlock):
            #     cpus = AUTOSAR.get_cpus_of_spinlock(inst, instances)
            #     if len(cpus) == 1:
            #         continue
            if not hasattr(inst, "cpu_id"):
                local_contexts.append((inst, ctx))
        return dict(local_contexts)

    @staticmethod
    def handle_irq(graph, state, cpu_id, irq):
        return XEN.system_types[cpu_id].handle_irq(graph, state, cpu_id, irq)
        """Handle an (asynchronous) IRQ.

        Arguments:
        graph      -- the system graph
        state      -- the current system state (see the State class)
        cpu_id     -- the CPU where the system call occurs
        irq        -- the IRQ number

        Return:
        The follow up state or None if the IRQ is invalid.
        """
        #raise NotImplementedError

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
        return XEN.system_types[cpu_id].handle_exit(graph, state, cpu_id)
        raise NotImplementedError

    @staticmethod
    def interpret(graph: Graph, state: OSState, cpu_id, categories=SyscallCategory.every) -> OSState:

        logger.info(f"Interpret: cpu_id: {cpu_id} System count: {XEN.system_count} {XEN.graph_list}\nCurrent graph: {graph}")
        syscall = state.get_syscall_name(cpu_id)


        if XEN.is_syscall(syscall):
            logger.warning(f"Interpret a xen syscall: {syscall}")
            syscall_function = getattr(XEN, syscall)
        
            return syscall_function(graph, state, cpu_id)
        else:
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
            for idx, cfg in enumerate(XEN.cfg_list):
                if cfg == state.cfg:
                    logger.info(f"Scheduling on cpu: {idx}.")
                    XEN.system_types[idx].schedule(state=state, cpus=cpus)
                    break

        else:
            logger.error(f"TODO Tried to schedule multicore cpu with: {cpus} cores.") 
            states = XEN.split_states(state=state)

            for idx, sc_state in enumerate(states):

                # TODO XEN [0]
                XEN.system_types[idx].schedule(state=sc_state, cpus=cpus)


    @syscall(categories={SyscallCategory.comm}, signature=tuple())
    def XEN_test_sender_event_channel(graph: Graph, state: OSState, cpu_id: int, args, va) -> OSState:
        
        # TODO 
        pass
        
        return state


    @syscall(categories={SyscallCategory.comm}, signature=tuple())
    def XEN_test_notify_evtchn(graph: Graph, state: OSState, cpu_id: int, args, va) -> OSState:
        # TODO aus args den port ziehen
        # aus args
        target_id = 1
        pass
        # handle_irq()
        # TODO require an ActivateTask from each os
        # XEN.system_types[cpu_id].ActivateTask()

        # cpuid sagt mit welchem Kern syncen
        # welchen Callback auf diesem Kern

        # TODO brauchen Callback obj -> steht im state.ctx drinnen als mögliches event (aus args) 
        #raise CrossCoreAction(set([cpu_id]))
        pass
        # todo sync point mit zieltask machen
        return state


    @syscall(categories={SyscallCategory.comm}, signature=tuple())
    def XEN_test_recive_event_channel(graph: Graph, state: OSState, cpu_id: int, args, va) -> OSState:
        # TODO 
        pass
        return state
