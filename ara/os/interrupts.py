# SPDX-FileCopyrightText: 2024 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""All common functions regarding interrupt handling in the models."""
import math

from ara.graph import NodeLevel, ABBType, CFType, SyscallCategory
from ara.util import get_child_logger_or_none

from .os_base import IRQCPU, TaskStatus, ExecState


class IntrSyscall:
    categories = [SyscallCategory.intr]
    is_stub = True


def fake_interrupt_function(cfg, callgraph, os, name, iit=0):
    """Fake an interrupt control flow.

    Apply the interrupt interarrival time (iit) if given.
    """
    # add the nodes
    func_v = cfg.add_vertex()
    cfg.vp.artificial[func_v] = True
    cfg.vp.name[func_v] = name
    cfg.vp.level[func_v] = NodeLevel.function

    iit_v = cfg.add_vertex()
    cfg.vp.artificial[iit_v] = True
    cfg.vp.name[iit_v] = name + '.iit'
    cfg.vp.level[iit_v] = NodeLevel.abb
    cfg.vp.type[iit_v] = ABBType.computation
    cfg.vp.is_exit_loop_head[iit_v] = True
    cfg.vp.part_of_loop[iit_v] = True
    cfg.vp.loop_head[iit_v] = True
    cfg.set_bcet(iit_v, iit)
    cfg.set_wcet(iit_v, math.inf)

    sc_v = cfg.add_vertex()
    cfg.vp.artificial[sc_v] = True
    syscall_name = name + '.sc'
    cfg.vp.name[sc_v] = syscall_name
    cfg.vp.level[sc_v] = NodeLevel.abb
    cfg.vp.type[sc_v] = ABBType.syscall
    cfg.vp.part_of_loop[iit_v] = True

    sys_func = cfg.add_vertex()
    cfg.vp.artificial[sys_func] = True
    cfg.vp.name[sys_func] = syscall_name
    cfg.vp.level[sys_func] = NodeLevel.function
    cfg.vp.implemented[sys_func] = False
    cfg.vp.sysfunc[sys_func] = True

    empty_sys_func = cfg.add_vertex()
    cfg.vp.artificial[empty_sys_func] = True
    cfg.vp.name[empty_sys_func] = 'empty'
    cfg.vp.level[empty_sys_func] = NodeLevel.abb
    cfg.vp.type[empty_sys_func] = ABBType.not_implemented
    # we introduced a new syscall here and must tell the OS about it
    os.syscalls[syscall_name] = IntrSyscall()

    # link them
    fi = cfg.add_edge(func_v, iit_v)
    cfg.ep.type[fi] = CFType.f2a
    cfg.ep.is_entry[fi] = True

    fs = cfg.add_edge(func_v, sc_v)
    cfg.ep.type[fs] = CFType.f2a

    is_l = cfg.add_edge(iit_v, sc_v)
    cfg.ep.type[is_l] = CFType.lcf
    is_i = cfg.add_edge(iit_v, sc_v)
    cfg.ep.type[is_i] = CFType.icf

    si_l = cfg.add_edge(sc_v, iit_v)
    cfg.ep.type[si_l] = CFType.lcf
    si_i = cfg.add_edge(sc_v, empty_sys_func)
    cfg.ep.type[si_i] = CFType.icf

    sc_i = cfg.add_edge(empty_sys_func, iit_v)
    cfg.ep.type[sc_i] = CFType.icf

    sfsa = cfg.add_edge(sys_func, empty_sys_func)
    cfg.ep.type[sfsa] = CFType.f2a
    cfg.ep.is_entry[sfsa] = True

    fs = cfg.add_edge(func_v, sc_v)
    cfg.ep.type[fs] = CFType.f2a

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
