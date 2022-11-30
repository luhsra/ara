"""All common functions regarding interrupt handling in the models."""
import math

from ara.graph import NodeLevel, ABBType, CFType


def fake_interrupt_function(cfg, name, iit=0):
    """Fake an interrupt control flow.

    Apply the interrupt interarrival time (iit) if given.
    """
    # add the nodes
    func_v = cfg.add_vertex()
    cfg.vp.name[func_v] = name
    cfg.vp.level[func_v] = NodeLevel.function

    iit_v = cfg.add_vertex()
    cfg.vp.name[iit_v] = name + '.iit'
    cfg.vp.level[iit_v] = NodeLevel.abb
    cfg.vp.type[iit_v] = ABBType.computation
    cfg.vp.is_exit_loop_head[iit_v] = True
    cfg.vp.part_of_loop[iit_v] = True
    cfg.vp.loop_head[iit_v] = True
    cfg.set_bcet(iit_v, iit)
    cfg.set_wcet(iit_v, math.inf)

    sc_v = cfg.add_vertex()
    cfg.vp.name[sc_v] = name + '.sc'
    cfg.vp.level[sc_v] = NodeLevel.abb
    cfg.vp.type[sc_v] = ABBType.syscall
    cfg.vp.part_of_loop[iit_v] = True

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
    si_i = cfg.add_edge(sc_v, iit_v)
    cfg.ep.type[si_i] = CFType.icf

    return func_v
