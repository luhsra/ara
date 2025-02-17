# SPDX-FileCopyrightText: 2024 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""All common functions regarding interrupt handling in the models."""
import math

from ara.graph import NodeLevel, ABBType, CFType, SyscallCategory
from ara.util import get_child_logger_or_none

from .os_base import IRQCPU, TaskStatus, ExecState

class IntrSyscall:
    categories = {SyscallCategory.intr}
    is_stub = True


# def fake_interrupt_function(temp_printer, cfg, callgraph, os, name, alarmtime, cycletime):
def fake_interrupt_function(cfg, callgraph, os, name, alarmtime_ms, cycletime_ms):
    """Fake an interrupt control flow.

    Apply the interrupt interarrival time (iit) if given.
    """

    # Autosar increments counter with a 1 kHz Timer, but other timing measurement is done with us precision
    alarmtime_us = alarmtime_ms * 1000
    cycletime_us = cycletime_ms * 1000

    syscall_name = name + '.sc'

    # Block of this fake interrupt control flow
    func_v = cfg.add_vertex()
    cfg.vp.artificial[func_v] = True
    cfg.vp.name[func_v] = name
    cfg.vp.level[func_v] = NodeLevel.function


    # Add a vertex as startpoint, its time is defined by "alarmtime", the time before the alarm is first triggered
    startup_v = cfg.add_vertex()
    cfg.vp.artificial[startup_v] = True
    cfg.vp.name[startup_v] = "Startup(Alarmtime)"
    cfg.vp.level[startup_v] = NodeLevel.abb
    cfg.vp.type[startup_v] = ABBType.computation
    # add edge to func
    fa = cfg.add_edge(func_v, startup_v)
    cfg.ep.type[fa] = CFType.f2a
    # set as entry
    cfg.ep.is_entry[fa] = True

    # set time with a fake bb
    alarmtime_bb = cfg.add_vertex()
    cfg.vp.artificial[alarmtime_bb] = True
    cfg.vp.name[alarmtime_bb] = "alarmtime_bb"
    cfg.vp.level[alarmtime_bb] = NodeLevel.bb
    cfg.set_bcet(alarmtime_bb, alarmtime_us)
    cfg.set_wcet(alarmtime_bb, alarmtime_us)
    fl = cfg.add_edge(startup_v, alarmtime_bb)
    cfg.ep.type[fl] = CFType.a2b

    

    # Add a vertex that starts the loop
    loop_v = cfg.add_vertex()
    cfg.vp.artificial[loop_v] = True
    cfg.vp.name[loop_v] = "Loop"
    cfg.vp.level[loop_v] = NodeLevel.abb
    cfg.vp.type[loop_v] = ABBType.computation
    # add edge to func
    fl = cfg.add_edge(func_v, loop_v)
    cfg.ep.type[fl] = CFType.f2a
    # loop properties
    cfg.vp.is_exit_loop_head[loop_v] = True
    cfg.vp.part_of_loop[loop_v] = True
    cfg.vp.loop_head[loop_v] = True
    # connect incoming
    l_is_l = cfg.add_edge(startup_v, loop_v)
    cfg.ep.type[l_is_l] = CFType.lcf
    l_is_i = cfg.add_edge(startup_v, loop_v)
    cfg.ep.type[l_is_i] = CFType.icf
    

    # Add a vertex that adds the iit inside the loop
    cycletime_v = cfg.add_vertex()
    cfg.vp.artificial[cycletime_v] = True
    cfg.vp.name[cycletime_v] = "Cycletime"
    cfg.vp.level[cycletime_v] = NodeLevel.abb
    cfg.vp.type[cycletime_v] = ABBType.computation
    # add edge to func
    fl = cfg.add_edge(func_v, cycletime_v)
    cfg.ep.type[fl] = CFType.f2a
    # loop properties
    cfg.vp.part_of_loop[cycletime_v] = True
    # connect incoming
    c_is_l = cfg.add_edge(loop_v, cycletime_v)
    cfg.ep.type[c_is_l] = CFType.lcf
    c_is_i = cfg.add_edge(loop_v, cycletime_v)
    cfg.ep.type[c_is_i] = CFType.icf

    # set time with a fake bb
    cycletime_bb = cfg.add_vertex()
    cfg.vp.artificial[cycletime_bb] = True
    cfg.vp.name[cycletime_bb] = "alarmtime_bb"
    cfg.vp.level[cycletime_bb] = NodeLevel.bb
    cfg.set_bcet(cycletime_bb, cycletime_us)
    cfg.set_wcet(cycletime_bb, cycletime_us)
    fl = cfg.add_edge(cycletime_v, cycletime_bb)
    cfg.ep.type[fl] = CFType.a2b
    
    # Add the green syscall box
    sc_v = cfg.add_vertex()
    cfg.vp.artificial[sc_v] = True
    cfg.vp.name[sc_v] = syscall_name
    cfg.vp.level[sc_v] = NodeLevel.abb
    cfg.vp.type[sc_v] = ABBType.syscall
    # add edge to func
    fs = cfg.add_edge(func_v, sc_v)
    cfg.ep.type[fs] = CFType.f2a
    # loop
    cfg.vp.part_of_loop[sc_v] = True
    # connections ingoing
    s_is_l = cfg.add_edge(cycletime_v, sc_v)
    cfg.ep.type[s_is_l] = CFType.lcf
    s_is_i = cfg.add_edge(cycletime_v, sc_v)
    cfg.ep.type[s_is_i] = CFType.icf
    # connections outgoing
    si_l = cfg.add_edge(sc_v, loop_v)
    cfg.ep.type[si_l] = CFType.lcf


    # Add the grey Box
    sys_func = cfg.add_vertex()
    cfg.vp.artificial[sys_func] = True
    cfg.vp.name[sys_func] = syscall_name
    cfg.vp.level[sys_func] = NodeLevel.function
    cfg.vp.implemented[sys_func] = False
    cfg.vp.sysfunc[sys_func] = True


    # Add the node inside the grey box
    empty_sys_func = cfg.add_vertex()
    cfg.vp.artificial[empty_sys_func] = True
    cfg.vp.name[empty_sys_func] = 'empty'
    cfg.vp.level[empty_sys_func] = NodeLevel.abb
    cfg.vp.type[empty_sys_func] = ABBType.not_implemented
    # we introduced a new syscall here and must tell the OS about it
    os.syscalls[syscall_name] = IntrSyscall()
    # connections ingoing
    si_i = cfg.add_edge(sc_v, empty_sys_func)
    cfg.ep.type[si_i] = CFType.icf
    sfsa = cfg.add_edge(sys_func, empty_sys_func)
    cfg.ep.type[sfsa] = CFType.f2a
    # connections outgoing
    sc_i = cfg.add_edge(empty_sys_func, loop_v)
    cfg.ep.type[sc_i] = CFType.icf
    # set as entry
    cfg.ep.is_entry[sfsa] = True

    # Temp print the graph
    # temp_printer.print_xbbs(False)

    # call graph
    icn_v = callgraph.add_vertex()
    callgraph.vp.artificial[icn_v] = True
    callgraph.vp.function[icn_v] = func_v
    callgraph.vp.function_name[icn_v] = name
    cfg.vp.call_graph_link[func_v] = icn_v
    callgraph.vp.syscall_category_every[icn_v] = True

    scn_v = callgraph.add_vertex()
    callgraph.vp.artificial[scn_v] = True
    callgraph.vp.function[scn_v] = sys_func
    callgraph.vp.function_name[icn_v] = syscall_name
    cfg.vp.call_graph_link[sys_func] = scn_v
    callgraph.vp.syscall_category_intr[scn_v] = True
    callgraph.vp.syscall_category_every[scn_v] = True

    sc_e = callgraph.add_edge(icn_v, scn_v)
    callgraph.ep.callsite[sc_e] = sc_v
    callgraph.ep.callsite_name[sc_e] = syscall_name

    return func_v


def irq_schedule(state, logger=None):
    """Schedule an IRQCPU"""
    logger = get_child_logger_or_none(logger, "irq_schedule")

    for cpu in filter(lambda x: isinstance(x, IRQCPU),
                      state.cpus):
        ctx = state.context[cpu.irq]
        if ctx.status == TaskStatus.running and cpu.abb is None:
            # unmask interrupt
            cpu.abb = ctx.abb
            cpu.exec_state = ExecState.computation
            logger.debug("Unmask interrupt %i", cpu.irq.id)
        elif (ctx.status != TaskStatus.running and
                cpu.abb is not None):
            # mask interrupt
            ctx.abb = cpu.abb
            cpu.abb = None
            cpu.exec_state = ExecState.idle
            logger.debug("Mask interrupt %i", cpu.irq.id)
