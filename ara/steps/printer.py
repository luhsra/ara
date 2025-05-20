# SPDX-FileCopyrightText: 2020 Fredo Nowak
# SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2022 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2023 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2023 Jan Neugebauer
# SPDX-FileCopyrightText: 2023 Andreas Kässens
# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Container for Printer."""
from ara.graph import (ABBType, CFType, CFG, CFGView, HSTGraph, HSTType, HyperStateType, MSTType, StateType,
                       single_check, vertex_types)
from ara.os.os_base import ExecState, IRQCPU

from .option import Option, String, Choice, Bool
from .step import Step
from .util import open_with_dirs, has_path

from graph_tool import GraphView

import pydot
import html
import os
import os.path

from itertools import chain

from ..os.zephyr import Thread as ZephyrThread # TODO remove this...

_sysshort = {
    "AUTOSAR_GetSpinlock": "GL",
    "AUTOSAR_TryToGetSpinlock": "TGL",
    "AUTOSAR_ReleaseSpinlock": "RL",
    "AUTOSAR_ActivateTask": "AT",
    "AUTOSAR_ChainTask": "CT",
    "AUTOSAR_SetEvent": "SE",
    "AUTOSAR_WaitEvent": "WE",
    "AUTOSAR_SetRelAlarm": "SRA",
    "AUTOSAR_GetAlarm": "GA",
    "AUTOSAR_CancelAlarm": "CA",

}

# from ara.util import get_logger
# log = get_logger("Printer")


def _abb_name(cfg: CFG | list[CFG], abb) -> str:
    """Get an ABB as str."""
    if abb is None:
        return 'None'
    # Xen os does not have one complete cfg, therefore it passes a list of cfgs
    if isinstance(cfg, list):
        for cfg in cfg:
            for v in cfg.vertices():
                if v == abb:
                    return cfg.vp.name[abb]
        return "ERROR-ABB-NAME"
    else:
        return cfg.vp.name[abb]

def remap(x, in_min=0.0, in_max=1.0, out_min=0.0, out_max=1.0):
    '''remap taken from https://stackoverflow.com/a/43567380'''
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min

def with_color(value, color, min=0.0, max=1.0):
    '''Picks a color and wraps the value in a XML tag with the color attribute'''
    return f"<font color='{remap(color, float(min), float(max))} 0.700 0.800'>\"{value}\"</font>"


from ara.os.zephyr import Zephyr
from ara.os.autosar import AUTOSAR

def _sstg_state_as_dot(sstg, state_vert, os=AUTOSAR):
    attrs = {"fontsize": 14}
    size = 12

    obj = sstg.vp.state[state_vert]
    cfg = obj.cfg
    label = f"State {obj.id}"
    cpu = obj.cpus.one()
    thread_info = []

    if os == Zephyr:
        kernel_obj = obj.instances.vp.obj[Zephyr.kernel]
        kernel = obj.context[kernel_obj]
    else:
        kernel = None

    if cpu.control_instance:
        instance = obj.instances.vp.label[obj.instances.vertex(cpu.control_instance)]
        #is_exit = cfg.vp.is_exit[cpu.abb]
        thread = obj.cur_control_inst(cpu.id)

        if os == Zephyr and hasattr(thread, 'name'):
            thread_list = [(v, obj) for v, obj in obj.instances.get(ZephyrThread)]
            thread_names = list(map(lambda x: x[1].name, thread_list))
            thread_count = len(thread_list)
            thread_idx = -1
            idstr = ""
            if thread.name in thread_names:
                thread_idx = thread_names.index(thread.name)
                v = thread_list[thread_idx][0]
                idstr = f"{str(v)}"
            thread_info.append(("thread", with_color(thread.name, thread_idx, -1, thread_count) + " " + idstr))

            context = obj.context[thread]
            thread_info.append(("preempt", context.preempt))
            thread_info.append(("thread_state", bin(context.thread_state)))
            vertices = [str(obj.instances.vertex_index[v]) for v in context.join_queue]
            timeouts = [str(obj.instances.vertex_index[to.v]) for to in kernel.timeout_list]
            thread_info.append(("join_queue", ", ".join(vertices)))
            thread_info.append(("timeout_list", ", ".join(timeouts)))

    else:
        instance = "Idle"
    if cpu.abb:
        syscall = cfg.get_syscall_name(cpu.abb)
        if syscall != "":
            syscall = f" ({syscall})"
        abb = f"{cfg.vp.name[cpu.abb]} {syscall}"
        xcet = [("bcet/wcet", f"{cfg.vp.bcet[cpu.abb]}/{cfg.vp.wcet[cpu.abb]}")]
    else:
        abb = "None"
        xcet = []

    graph_attrs = "<br/>".join(
        [
            f"<i>{k}</i>: {html.escape(str(v))}"
            for k, v in [
                # ("irq_on", cpu.irq_on),
                ("instance", instance),
                # ("call_path", cpu.call_path),
                ("type", ExecState(cpu.exec_state).name),
                ("abb", abb),
                # ("kernel", str(kernel)),
            ] #+ xcet
        ] + [
            f"<i>{k}</i>: {str(v)}"
            for k, v in [
                # attr that should not be escaped
            ] + thread_info
        ]
    )
    graph_attrs = f"<font point-size='{size}'>{graph_attrs}</font>"
    attrs["label"] = f"<{label}<br/>{graph_attrs}>"
    tooltip = str(state_vert)
    # if cpu.abb:
    #     code = "\r".join([str(cfg.get_llvm_obj(bb))
    #                       for bb in cfg.get_bbs(cpu.abb)])
    #     code = code.replace('\n', '\r')
    #     tooltip = f'<{tooltip + code}>'

    attrs["tooltip"] = tooltip

    if cpu.exec_state & ExecState.with_time:
        attrs["color"] = "green"
    elif cpu.exec_state & ExecState.syscall:
        attrs["color"] = "blue"
        attrs["shape"] = "box"

    return attrs


def sstg_to_dot(sstg, label="SSTG", reduced=False, os=AUTOSAR):
    dot_graph = pydot.Dot(graph_type="digraph", label=label)

    for state_vert in sstg.vertices():
        attrs = _sstg_state_as_dot(
            sstg, state_vert, os
        )
        dot_state = pydot.Node(str(state_vert), **attrs)
        dot_graph.add_node(dot_state)
    if "reduced" in sstg.ep and not reduced:
        sstg = GraphView(sstg, efilt=sstg.ep.reduced.fa != True)
    for edge in sstg.edges():
        label = f"{sstg.ep.bcet[edge]} - {sstg.ep.wcet[edge]}"
        dot_graph.add_edge(
            pydot.Edge(
                str(edge.source()),
                str(edge.target()),
                color="black",
                label=label,
            )
        )

    return dot_graph


def reduced_mstg_to_dot(mstg, cfg, label="MSTG"):
    def _to_str(v):
        return str(int(v))

    core_map = {}

    def _draw_sync(sync, edges, entry=None):
        cols = []
        cores = set()
        for e in edges:
            if mstg.ep.type[e] == MSTType.st2sy:
                cpu_id = mstg.ep.cpu_id[e]
                cores.add(cpu_id)
                cpu_name = f"CPU {cpu_id}"
                cpu = mstg.vp.state[sync].cpus[cpu_id]
                if isinstance(cpu, IRQCPU):
                    cpu_name = ("\u26A1" + f"{cpu.reference_cpu_id} " +
                                f"({cpu_id}, {cpu.irq.name})")
                abb_name = _abb_name(cfg, cpu.abb)
                cols.append((f"<TD PORT=\"c{cpu_id}\">{cpu_name}</TD>",
                             f"<TD PORT=\"a{cpu_id}\">{abb_name}</TD>"))
        if cols:
            cpus, abbs = zip(*sorted(cols))
            label = '<<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">' \
                    '<TR>{}</TR>' \
                    '<TR>{}</TR>' \
                    '</TABLE>>'.format(''.join(cpus), ''.join(abbs))
            shape = "plaintext"
        else:
            label = "undiscovered"
            shape = "box"
        if entry:
            core_map[int(entry)] = cores
        core_map[int(sync)] = cores
        return pydot.Node(_to_str(sync), label=label,
                          shape=shape,
                          tooltip=_to_str(sync))

    dot_graph = pydot.Dot(graph_type="digraph", label=label)
    # draw initial sync node
    for init in mstg.get_sync_points(exit=True).vertices():
        init = mstg.vertex(init)
        if init.in_degree() == 0:
            dot_graph.add_node(_draw_sync(init, init.out_edges()))

    en2ex = mstg.edge_type(MSTType.en2ex)

    for sync_point in mstg.get_sync_points(exit=False).vertices():
        sync_point = mstg.vertex(sync_point)
        if en2ex.vertex(sync_point).out_degree() > 1:
            sync_m = pydot.Cluster("Metasync" + _to_str(sync_point), label="")
            dot_graph.add_subgraph(sync_m)
            # draw entry_sync
            sync_m.add_node(_draw_sync(sync_point, sync_point.in_edges()))
            # draw exit_sync
            for follow in sync_point.out_neighbors():
                sync_m.add_node(_draw_sync(follow, follow.out_edges()))
        else:
            # draw only the exit_sync
            exit_s = single_check(sync_point.out_neighbors())
            dot_graph.add_node(_draw_sync(exit_s, exit_s.out_edges(),
                                          entry=sync_point))

    time_sync = mstg.edge_type(MSTType.follow_sync, MSTType.en2ex)
    time_sync = vertex_types(time_sync, time_sync.vp.type,
                             StateType.entry_sync, StateType.exit_sync)
    ms_sync = mstg.edge_type(MSTType.m2sy, MSTType.en2ex)
    sy2sy = mstg.edge_type(MSTType.sy2sy)
    added_edges = set()

    def _sync_str(v, cpu_id, port):
        return f"{_to_str(v)}:{port}{cpu_id}"

    def _add_edge(from_sp, to_sp, core):
        exit_state = mstg.get_exit_state(to_sp, core)
        syscall_name = mstg.get_syscall_name(exit_state)
        irq = None
        sys_e = mstg.edge(exit_state, to_sp)
        assert mstg.ep.type[sys_e] == MSTType.st2sy
        if mstg.ep.irq[sys_e] >= 0:
            irq = f"\u26A1 {syscall_name}"

        attrs = {"color": "black"}
        if mstg.get_exec_state(exit_state) == ExecState.waiting:
            attrs["color"] = "limegreen"
        elif irq:
            attrs["label"] = irq
            attrs["color"] = "royalblue3"
        elif syscall_name:
            attrs["label"] = _sysshort[syscall_name]
            attrs["color"] = "darkred"

        # merge entry and exit sync states
        f_to_sp = en2ex.vertex(to_sp)
        if f_to_sp.out_degree() == 1:
            n_tgt = single_check(f_to_sp.out_neighbors())
        else:
            n_tgt = to_sp

        # examine start and end for the dot edge
        dot_tgt = _sync_str(n_tgt, core, 'c')
        dot_src = _sync_str(from_sp, core, 'a')
        if (dot_src, dot_tgt) in added_edges:
            return None
        added_edges.add((dot_src, dot_tgt))
        return pydot.Edge(dot_src, dot_tgt, **attrs)

    # edge printing
    # we want to find the edges to the last core-local root SP
    # we therefore first retrieve the parent
    for entry_sp in mstg.get_sync_points(exit=False).vertices():
        for parent_sp in sy2sy.vertex(entry_sp).in_neighbors():
            cores = set(core_map[int(entry_sp)])
            counter = 1
            # We want to connect every core of the SP (entry_sp) with all
            # predecessors (I name it pred_sp). This predecessor depends on
            # four things:
            #   1. There is a connection of entry_sp and pred_sp over exactly
            #      one metastate specific for this core.
            #   2. At the same time entry_sp and pred_sp have an SP connection
            #      in the time domain.
            #   3. pred_sp has a path to the parent_sp.

            def _has_cores(v):
                if int(v) == int(entry_sp) or int(v) == int(parent_sp):
                    return True
                if set(core_map[int(v)]) >= cores:
                    return False
                return True

            core_graph = GraphView(time_sync, vfilt=_has_cores)

            for core in cores:
                def good_edge(e):
                    if mstg.ep.type[e] == MSTType.m2sy:
                        return mstg.ep.cpu_id[e] == core
                    return True
                cg = GraphView(ms_sync, efilt=good_edge)
                # condition 1
                cands = [x.in_neighbors()
                         for x in cg.vertex(entry_sp).in_neighbors()]
                for cand in chain(*cands):
                    try:
                        core_graph.vertex(cand)
                    except ValueError:
                        continue
                    # condition 2 and 3
                    if (has_path(core_graph, parent_sp, cand) and
                            has_path(core_graph, cand, entry_sp)):
                        edge = _add_edge(cand, entry_sp, core)
                        if edge:
                            dot_graph.add_edge(edge)

    for edge in en2ex.edges():
        src = edge.source()
        if src.out_degree() > 1:
            dot_graph.add_edge(pydot.Edge(_to_str(src),
                                          _to_str(edge.target())))

    return dot_graph


def mstg_to_dot(self, label="MSTG"):
    mstg = self._graph.mstg
    def _to_str(v):
        return str(int(v))

    def _draw_sync(sync, edges):
        cols = []
        for e in edges:
            if mstg.ep.type[e] == MSTType.st2sy:
                cpu_id = mstg.ep.cpu_id[e]
                cols.append(f"<TD PORT=\"c{cpu_id}\">{self.domain_type.get()} {cpu_id}</TD>")
        if cols:
            label = '<<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">' \
                    '<TR>{}</TR>' \
                    '</TABLE>>'.format(''.join(sorted(cols)))
            shape = "plaintext"
        else:
            label = "undiscovered"
            shape = "box"
        return pydot.Node(_to_str(sync), label=label,
                          shape=shape,
                          tooltip=_to_str(sync))

    dot_graph = pydot.Dot(graph_type="digraph", label=label)

    m2s = mstg.edge_type(MSTType.m2s)
    m2sy = mstg.edge_type(MSTType.m2sy)

    ms_done = set()
    # draw initial sync node
    for init in mstg.get_sync_points(exit=True).vertices():
        init = mstg.vertex(init)
        if init.in_degree() == 0:
            dot_graph.add_node(_draw_sync(init, init.out_edges()))
        # draw metastates
        for metastate in sorted(m2sy.vertex(init).out_neighbors(),
                                key=lambda x: mstg.vp.cpu_id[x]):
            metastate = mstg.vertex(metastate)
            if metastate in ms_done:
                continue
            ms_done.add(metastate)
            m2s = mstg.edge_type(MSTType.m2s)
            cpu_id = mstg.vp.cpu_id[metastate]

            dot_m = pydot.Cluster(_to_str(metastate),
                                  label=f"M{int(metastate)} ({self.domain_type.get()} {cpu_id})")
            dot_graph.add_subgraph(dot_m)

            for state in m2s.vertex(metastate).out_neighbors():
                attrs = _sstg_state_as_dot(mstg, state)
                dot_state = pydot.Node(_to_str(state), **attrs)
                dot_m.add_node(dot_state)

    for sync_point in mstg.get_sync_points(exit=False).vertices():
        sync_point = mstg.vertex(sync_point)
        sync_m = pydot.Cluster("Metasync" + _to_str(sync_point), label="")
        dot_graph.add_subgraph(sync_m)
        # draw entry_sync
        sync_m.add_node(_draw_sync(sync_point, sync_point.in_edges()))
        # draw exit_sync
        for follow in sync_point.out_neighbors():
            sync_m.add_node(_draw_sync(follow, follow.out_edges()))

    flow = GraphView(mstg, efilt=mstg.ep.type.fa != MSTType.m2s)

    def _sync_str(v, e):
        return f"{_to_str(v)}:c{flow.ep.cpu_id[e]}"

    for edge in flow.edges():
        src = edge.source()
        tgt = edge.target()
        attrs = {"color": "black"}
        if flow.ep.type[edge] == MSTType.st2sy:
            if flow.vp.type[src] == StateType.exit_sync:
                src = _sync_str(src, edge)
                tgt = _to_str(tgt)
            elif flow.vp.type[tgt] == StateType.entry_sync:
                src = _to_str(src)
                tgt = _sync_str(tgt, edge)
            else:
                assert False
        else:
            if flow.ep.type[edge] == MSTType.sy2sy:
                attrs = {"color": "darkred",
                         "style": "dashed"}
            if flow.ep.type[edge] == MSTType.follow_sync:
                attrs = {"color": "darkgreen",
                         "style": "dotted",
                         "label": f"{flow.ep.bcet[edge]} - {flow.ep.wcet[edge]}"}
            if flow.ep.type[edge] in [MSTType.sync_neighbor, MSTType.m2sy]:
                continue
            src = _to_str(src)
            tgt = _to_str(tgt)

        dot_graph.add_edge(pydot.Edge(src, tgt, **attrs))

    if self.add_legend.get():
        # add a new cluster with the legend
        legend = pydot.Cluster(graph_name="legend", label="Legend")
        dot_graph.add_subgraph(legend)

        metastate = pydot.Cluster(graph_name="metastate", label="Metastate - core local control flow")
        legend.add_subgraph(metastate)

        state = pydot.Node(name="state", label="OS-State\n(e.g. Computation)", color="green")
        metastate.add_node(state)
        syscall = pydot.Node(name="syscall", label="Syscall\n(e.g. Terminate Task)", shape="box", color="blue")
        metastate.add_node(syscall)

        state2 = pydot.Node(name="state2", label="OSState\n(e.g Idle)", color="green")
        metastate.add_node(state2)
        flow2 = pydot.Edge(src='syscall', dst='state2')
        metastate.add_edge(flow2)

        flow = pydot.Edge(src='state', dst='syscall')
        metastate.add_edge(flow)


        # TODO add syncpoints

    return dot_graph


def hstg_to_dot(hstg: HSTGraph, label: str ="HSTG") -> pydot.Dot:
    def _to_str(v):
        return str(int(v))

    def _draw_sync(sync, edges):
        cols = []
        for e in edges:
            if hstg.ep.type[e] == HSTType.st2sy:
                cpu_id = hstg.ep.cpu_id[e]
                cols.append(f"<TD PORT=\"c{cpu_id}\">CPU {cpu_id}</TD>")
        if cols:
            label = '<<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">' \
                    '<TR>{}</TR>' \
                    '</TABLE>>'.format(''.join(sorted(cols)))
            shape = "plaintext"
        else:
            label = "undiscovered"
            shape = "box"
        return pydot.Node(_to_str(sync), label=label,
                          shape=shape,
                          tooltip=_to_str(sync))

    dot_graph = pydot.Dot(graph_type="digraph", label=label)

    m2s = hstg.edge_type(HSTType.m2s)
    m2sy = hstg.edge_type(HSTType.m2sy)

    ms_done = set()
    # draw initial sync node
    for init in hstg.get_sync_points(exit=True).vertices():
        init = hstg.vertex(init)
        if init.in_degree() == 0:
            dot_graph.add_node(_draw_sync(init, init.out_edges()))
        # draw metastates
        for metastate in sorted(m2sy.vertex(init).out_neighbors(),
                                key=lambda x: hstg.vp.cpu_id[x]):
            metastate = hstg.vertex(metastate)
            if metastate in ms_done:
                continue
            ms_done.add(metastate)
            m2s = hstg.edge_type(HSTType.m2s)
            cpu_id = hstg.vp.cpu_id[metastate]

            dot_m = pydot.Cluster(_to_str(metastate),
                                  label=f"M{int(metastate)} (CPU {cpu_id})")
            dot_graph.add_subgraph(dot_m)

            for state in m2s.vertex(metastate).out_neighbors():
                attrs = _sstg_state_as_dot(hstg, state)
                dot_state = pydot.Node(_to_str(state), **attrs)
                dot_m.add_node(dot_state)

    for sync_point in hstg.get_sync_points(exit=False).vertices():
        sync_point = hstg.vertex(sync_point)
        sync_m = pydot.Cluster("Metasync" + _to_str(sync_point), label="")
        dot_graph.add_subgraph(sync_m)
        # draw entry_sync
        sync_m.add_node(_draw_sync(sync_point, sync_point.in_edges()))
        # draw exit_sync
        for follow in sync_point.out_neighbors():
            sync_m.add_node(_draw_sync(follow, follow.out_edges()))

    flow = GraphView(hstg, efilt=hstg.ep.type.fa != HSTType.m2s)

    def _sync_str(v, e):
        return f"{_to_str(v)}:c{flow.ep.cpu_id[e]}"

    for edge in flow.edges():
        src = edge.source()
        tgt = edge.target()
        attrs = {"color": "black"}
        if flow.ep.type[edge] == HSTType.st2sy:
            if flow.vp.type[src] == HyperStateType.exit_sync:
                src = _sync_str(src, edge)
                tgt = _to_str(tgt)
            elif flow.vp.type[tgt] == HyperStateType.entry_sync:
                src = _to_str(src)
                tgt = _sync_str(tgt, edge)
            else:
                assert False
        else:
            if flow.ep.type[edge] == HSTType.sy2sy:
                attrs = {"color": "darkred",
                         "style": "dashed"}
            if flow.ep.type[edge] == HSTType.follow_sync:
                attrs = {"color": "darkgreen",
                         "style": "dotted",
                         "label": f"{flow.ep.bcet[edge]} - {flow.ep.wcet[edge]}"}
            if flow.ep.type[edge] in [HSTType.sync_neighbor, HSTType.m2sy]:
                continue
            src = _to_str(src)
            tgt = _to_str(tgt)

        dot_graph.add_edge(pydot.Edge(src, tgt, **attrs))

    return dot_graph


def sp_mstg_to_dot(mstg, cfg, label="SyncPoints MSTG"):
    legend = '<br/>'.join([html.escape(x) for x in [
        "state format:",
        "$entry sync point$ -> $exit sync point$",
        "coreX, stateY (trggering syscall)",
        "abbs of entry SP",
        "abbs of exit SP",
        "",
        "edge format:",
        "dashed, red: sy2sy (sync point to sync point)",
        "dotted, green: follow_sync (following SPs in time)",
        ]])
    label = f"<{html.escape(str(label))}<br/><br/>{legend}>"
    dot_graph = pydot.Dot(graph_type="digraph", label=label)

    def _dsp(vertex, label=None):
        if label is None:
            label = [str(int(vertex))]
        return pydot.Node(str(int(vertex)), shape="box",
                          label="<{}>".format('<br/>'.join([html.escape(str(x)) for x in label])))

    def _prettify_abbs(abbs):
        return ', '.join([_abb_name(cfg, x) for x in abbs])

    # draw initial sync node
    for init in mstg.get_sync_points(exit=True).vertices():
        init = mstg.vertex(init)
        if init.in_degree() == 0:
            dot_graph.add_node(_dsp(init))

    en2ex = mstg.edge_type(MSTType.en2ex)

    for sync_point in mstg.get_sync_points(exit=False).vertices():
        sync_point = mstg.vertex(sync_point)
        sys_state, core, irq = mstg.get_syscall_state(sync_point)
        entry_abbs = mstg.get_synchronized_abbs(sync_point)
        entry_lbl = "en: " + _prettify_abbs(entry_abbs)
        label = f"c{core}, s{int(sys_state)}"
        if irq >= 0:
            irq_name = mstg.vp.state[sys_state].instances.vp.obj[irq].name
            label += " (\u26A1" + f"{irq_name})"
        else:
            sys_name = mstg.get_syscall_name(sys_state)
            label += f" ({_sysshort[sys_name]})"
        if en2ex.vertex(sync_point).out_degree() > 1:
            sync_m = pydot.Cluster("Metasync" + str(int(sync_point)),
                                   label="")
            dot_graph.add_subgraph(sync_m)
            # draw entry_sync
            sync_m.add_node(_dsp(sync_point, label=[
                str(int(sync_point)),
                entry_lbl,
                label
            ]))
            # draw exit_sync
            for follow in sync_point.out_neighbors():
                exit_abbs = mstg.get_synchronized_abbs(follow)
                sync_m.add_node(_dsp(follow, label=[
                    str(int(follow)),
                    "ex: " + _prettify_abbs(exit_abbs)
                ]))
        else:
            # draw only the exit_sync
            exit_s = single_check(sync_point.out_neighbors())
            title = f"{str(int(sync_point))}->{str(int(exit_s))}"
            dot_graph.add_node(_dsp(exit_s, label=[
                title,
                entry_lbl,
                "ex: " + _prettify_abbs(mstg.get_synchronized_abbs(exit_s)),
                label
            ]))

    sp_e = mstg.edge_type(MSTType.follow_sync, MSTType.sy2sy)
    for e in sp_e.edges():
        src = e.source()
        tgt = e.target()
        if en2ex.vertex(tgt).out_degree() == 1:
            tgt = single_check(en2ex.vertex(tgt).out_neighbors())
        if mstg.ep.type[e] == MSTType.sy2sy:
            attrs = {"color": "darkred",
                     "style": "dashed"}
        elif mstg.ep.type[e] == MSTType.follow_sync:
            attrs = {"color": "darkgreen",
                     "style": "dotted"}
            bcet = mstg.ep.bcet[e]
            wcet = mstg.ep.wcet[e]
            if bcet > 0 or wcet > 0:
                attrs['xlabel'] = f"{bcet}-{wcet}"
        else:
            assert False
        dot_graph.add_edge(pydot.Edge(
            str(int(src)),
            str(int(tgt)),
            **attrs))

    return dot_graph




class Printer(Step):
    """Print graphs to dot."""

    SHAPES = {
        ABBType.computation: ("oval", "blue"),
        ABBType.call: ("box", "red"),
        ABBType.syscall: ("diamond", "green")
    }

    dot = Option(name="dot",
                 help="Path to a dot file, '-' will write to stdout.",
                 ty=String())
    graph_name = Option(name="graph_name",
                        help="Name of the graph.",
                        ty=String())
    subgraph = Option(name="subgraph",
                      help="Choose, what subgraph should be printed.",
                      ty=Choice("bbs", "abbs", "instances", "sysrel_callgraph",
                                "callgraph", "multistates", "sstg",
                                "reduced_sstg", "mstg", "hstg", "reduced_mstg",
                                "sp_mstg"))
    entry_point = Option(name="entry_point",
                         help="system entry point",
                         ty=String())
    from_entry_point = Option(name="from_entry_point",
                              help="Print only from the given entry point.",
                              ty=Bool(),
                              default_value=False)
    gen_html_links = Option(name="gen_html_links",
                            help="Generate source code links (with Pygments)",
                            ty=Bool(),
                            default_value=True)
    add_legend = Option(name="add_legend",
                            help="Add a legend pydot cluster to the graph. Currently only supports CFGs and MSTGs",
                            ty=Bool(),
                            default_value=False)

    domain_type = Option(name="domain_type",
                            help="Used to create a multi OS hypersse hstg, or a multicore multisse mstg.",
                            ty=Choice("CPU", "Dom"),
                            default_value="CPU")


    def _print_init(self) -> str:
        dot = self.dot.get()
        if not dot:
            self._fail("dot file path must be given.")

        name = self.graph_name.get()
        # Overwrite name here
        # name = "ABBs-dom1"
        if not name:
            name = ''
        return name

    def _write_dot(self, dot: pydot.Dot) -> None:
        dot_path = self.dot.get()
        assert dot_path
        dot_path = os.path.abspath(dot_path)
        with open_with_dirs(dot_path):
            dot.write(dot_path)
        self._log.info(f"Write {self.subgraph.get()} to {dot_path}.")

    def _gen_html_file(self, filename):
        try:
            from pygments import highlight
            from pygments.lexers import CppLexer
            from pygments.formatters import HtmlFormatter
        except ImportError:
            self._log.warn("Pygments not found, skip source code linking")
            return None

        filename = os.path.abspath(filename)

        if filename in self._graph.file_cache:
            return self._graph.file_cache[filename]

        if not os.path.exists(filename):
            self._log.warn(f"file {filename} not found, skip source code linking")
            return None

        hfile = os.path.join(os.path.dirname(self.dump_prefix.get()),
                             'html_files',
                             os.path.basename(filename) + ".html")
        hfile = os.path.realpath(hfile)
        self._graph.file_cache[filename] = hfile

        with open(filename) as f:
            code = f.read()

        with open_with_dirs(hfile, 'w') as g:
            g.write(highlight(code, CppLexer(),
                              HtmlFormatter(linenos='inline',
                                            lineanchors='line', full=True)))
        return hfile

    def print_xbbs(self, bbs=False):
        name = self._print_init()

        cfg = self._graph.cfg

        entry_label = self.entry_point.get()
        if self.from_entry_point.get():
            entry_func = cfg.get_function_by_name(entry_label)
            functions = cfg.reachable_functs(entry_func, self._graph.callgraph)
        else:
            functs = self._graph.functs
            functions = functs.vertices()

        dot_nodes = set()
        dot_graph = pydot.Dot(graph_type='digraph', label=name)
        for function in functions:
            function = cfg.vertex(function)
            dot_func = pydot.Cluster(cfg.vp.name[function].replace('.', '_'),
                                     label=cfg.vp.name[function])
            dot_graph.add_subgraph(dot_func)

            if bbs:
                nodes = cfg.get_function_bbs(function)
            else:
                nodes = cfg.get_abbs(function)

            for block in nodes:
                tooltip = str(int(block))
                if bbs:
                    current_bbs = [block]
                else:
                    current_bbs = cfg.get_bbs(block)
                    tooltip += f" ({','.join([cfg.vp.name[b] for b in current_bbs])})"
                code = "\r".join([str(cfg.get_llvm_obj(bb))
                                  for bb in current_bbs])
                code = code.replace('\n', '\r')
                tooltip += f'\rbcet/wcet: {cfg.vp.bcet[block]} / {cfg.vp.wcet[block]}\r'
                # tooltip += code
                tooltip = f'<{html.escape(tooltip)}>'  # seems to be added automagically

                if cfg.vp.type[block] == ABBType.not_implemented:
                    assert not cfg.vp.implemented[function]
                    dot_abb = pydot.Node(str(hash(block)),
                                         label="",
                                         tooltip=tooltip,
                                         shape="box")
                    dot_nodes.add(int(block))
                    dot_func.set('style', 'filled')
                    dot_func.set('color', '#eeeeee')
                else:
                    color = self.SHAPES[cfg.vp.type[block]][1]
                    if cfg.vp.is_exit[block]:
                        color = "violet"
                    dot_abb = pydot.Node(
                        str(hash(block)),
                        label=cfg.vp.name[block],
                        tooltip=tooltip,
                        shape=self.SHAPES[cfg.vp.type[block]][0],
                        color=color
                    )
                    if cfg.vp.is_exit_loop_head[block]:
                        dot_abb.set('style', 'bold')
                    elif cfg.vp.loop_head[block]:
                        dot_abb.set('style', 'dotted')
                    elif cfg.vp.part_of_loop[block]:
                        dot_abb.set('style', 'dashed')
                    dot_nodes.add(int(block))
                dot_func.add_node(dot_abb)
        for edge in cfg.edges():
            if cfg.ep.type[edge] not in [CFType.lcf, CFType.icf]:
                continue
            if not all([int(x) in dot_nodes
                       for x in [edge.source(), edge.target()]]):
                continue
            color = "black"
            if cfg.ep.type[edge] == CFType.lcf:
                color = "red"
            if cfg.ep.type[edge] == CFType.icf:
                color = "blue"
            dot_graph.add_edge(pydot.Edge(str(hash(edge.source())),
                                          str(hash(edge.target())),
                                          color=color))
        
        if self.add_legend.get():
            # add a new cluster with the legend
            legend = pydot.Cluster(graph_name="legend", label="CFG-Legend\n(Each box is a function)")
            dot_graph.add_subgraph(legend)
            
            comp = pydot.Node(name="comp", label="Computation Block", shape=self.SHAPES[ABBType.computation][0], 
                                 color=self.SHAPES[ABBType.computation][1])
            legend.add_node(comp)
            syscall = pydot.Node(name="syscall", label="Syscall",  shape=self.SHAPES[ABBType.syscall][0], 
                                 color=self.SHAPES[ABBType.syscall][1])
            legend.add_node(syscall)

            icf = pydot.Edge(src='comp', dst='syscall', label='Interprocedural\nControl\nFlow', color='blue')
            legend.add_edge(icf)

            exit_node = pydot.Node(name="exit", label="Exit Node", shape="oval", 
                                 color="violet")
            legend.add_node(exit_node)
            
            lcf = pydot.Edge(src='syscall', dst='exit', label='Local\nControl\nFlow', color='red')
            legend.add_edge(lcf)

            # TODO add loop
            
        self._write_dot(dot_graph)

    def print_instances(self):
        name = self._print_init()

        instances = self._graph.instances

        dot_graph = pydot.Dot(graph_type='digraph', label=name)

        default_fontsize = 14
        default_fontsize_diff = 2

        def p_str(p_map, key):
            """Convert to a pretty string"""
            value = p_map[key]
            if p_map.python_value_type() == bool:
                value = bool(value)
            return html.escape(str(value))

        for instance in instances.vertices():
            inst_obj = instances.vp.obj[instance]
            if inst_obj and hasattr(inst_obj, 'as_dot'):
                attrs = inst_obj.as_dot()
            else:
                attrs = {}
            if "label" in attrs:
                del attrs["label"]
            attrs["fontsize"] = attrs.get("fontsize", 14)
            attrs["tooltip"] = str(int(instance))

            if self.gen_html_links.get():
                src_file = instances.vp.file[instance]
                src_line = instances.vp.line[instance]
                if (src_file != '' and src_line != 0):
                    hfile = self._gen_html_file(src_file)
                    if hfile is not None:
                        attrs["URL"] = f"file://{hfile}#line-{src_line}"

            size = attrs["fontsize"] - default_fontsize_diff
            label = instances.vp.label[instance]
            graph_attrs = '<br/>'.join([f"<i>{k}</i>: {p_str(v, instance)}"
                                        for k, v in instances.vp.items()
                                        if k not in ["label", "obj"]])
            graph_attrs = f"<font point-size='{size}'>{graph_attrs}</font>"
            label = f"<{label}<br/>{graph_attrs}<br/><br/>{{}}>"
            sublabel = attrs.get("sublabel", "")
            if len(sublabel) > 0:
                sublabel = f"<font point-size='{size}'>{sublabel}</font>"
            label = label.format(sublabel)
            if "sublabel" in attrs:
                del attrs["sublabel"]

            dot_node = pydot.Node(
                str(hash(instance)),
                label=label,
                **attrs
            )
            dot_graph.add_node(dot_node)
        for edge in self._graph.instances.edges():
            dot_graph.add_edge(pydot.Edge(
                str(hash(edge.source())),
                str(hash(edge.target())),
                label=self._graph.instances.ep.label[edge]))
        self._write_dot(dot_graph)

    def print_sstg(self, reduced=False):
        name = self._print_init()
        os = self._graph.os

        if reduced:
            sstg = self._graph.reduced_sstg
        else:
            sstg = self._graph.sstg

        dot_graph = sstg_to_dot(sstg, name, reduced, os)
        self._write_dot(dot_graph)

    def print_mstg(self):
        name = self._print_init()
        dot_graph = mstg_to_dot(self, name)
        self._write_dot(dot_graph)

    def print_reduced_mstg(self):
        name = self._print_init()
        dot_graph = reduced_mstg_to_dot(self._graph.mstg,
                                        self._graph.cfg,
                                        name)
        self._write_dot(dot_graph)

    def print_sp_mstg(self):
        name = self._print_init()
        dot_graph = sp_mstg_to_dot(self._graph.mstg, self._graph.cfg, name)
        self._write_dot(dot_graph)


    def print_hstg(self) -> None:
        name = self._print_init()
        self._log.info(f"Writing HSTG to {self.dot.get()}.")
        dot_graph = hstg_to_dot(hstg=self._graph.hstg, label=name)
        self._write_dot(dot_graph)


    def print_callgraph(self, only_systemrelevant=False):
        name = self._print_init()

        shapes = {
            True: ("box", "green"),
            False: ("box", "black")
        }

        dot_graph = pydot.Dot(graph_type='digraph', label=name)
        callgraph = self._graph.callgraph

        cfg = callgraph.gp.cfg
        if only_systemrelevant:
            callgraph = callgraph.get_syscalls()
        for node in callgraph.vertices():
            dot_node = pydot.Node(
                str(hash(node)),
                label=cfg.vp.name[callgraph.vp.function[node]],
                shape=shapes[callgraph.vp.syscall_category_every[node]][0],
                color=shapes[callgraph.vp.syscall_category_every[node]][1]
            )
            if callgraph.vp.recursive[node]:
                dot_node.set('style', 'dashed')
            dot_graph.add_node(dot_node)
        for edge in callgraph.edges():
            dot_graph.add_edge(pydot.Edge(
                str(hash(edge.source())),
                str(hash(edge.target())),
                label=cfg.vp.name[callgraph.ep.callsite[edge]]))
        self._write_dot(dot_graph)

    def print_sstg_full(self):
        sstg = self._graph.sstg
        if not sstg:
            self._fail("Graph must be given when choosing sstg.")

        name = self._print_init()
        dot_graph = pydot.Dot(graph_type='digraph', label=name, compound=True)

        cfg = CFGView(g.cfg, efilt=lambda x: g.cfg.ep.type[x] == CFType.icf or g.cfg.ep.type[x] == CFType.lcf)

        # print all metastates as clusters
        for state_node in sstg.vertices():
            # print cluster
            metastate = sstg.vp.state[state_node]
            dot_cluster = pydot.Cluster(
                str(hash(state_node)),
                label="Metastate",
                style="rounded"
            )
            dot_graph.add_subgraph(dot_cluster)

            for cpu, state_graph in metastate.state_graph.items():
                subg = pydot.Subgraph(
                    str(hash(state_node)) + "_" + str(cpu),
                    label=str(cpu)
                )
                dot_cluster.add_subgraph(subg)

                # print state vertices in cluster
                for vertex in state_graph.vertices():
                    state = state_graph.vp.state[vertex]
                    dot_node = pydot.Node(
                        str(hash(state_node)) + "_" + str(cpu) + "_" + str(hash(vertex)),
                        label=state.__repr__()
                    )
                    subg.add_node(dot_node)

                # print state edges in cluster
                for edge in state_graph.edges():
                    dot_edge = pydot.Edge(
                        str(hash(state_node)) + "_" + str(cpu) + "_" + str(hash(edge.source())),
                        str(hash(state_node)) + "_" + str(cpu) + "_" + str(hash(edge.target()))
                    )
                    subg.add_edge(dot_edge)

        # print all edges
        for edge in sstg.edges():
            color = "blue"
            state = sstg.vp.state[edge.source()]
            cpu_list = list(state.state_graph.keys())
            cpu = cpu_list[0]
            graph = state.state_graph[cpu]
            s_vertex = graph.vertex(len(graph.get_vertices()) // 2)

            t_state = sstg.vp.state[edge.target()]
            graph = t_state.state_graph[cpu]
            t_vertex = graph.vertex(len(graph.get_vertices()) // 2)

            dot_graph.add_edge(pydot.Edge(
                str(hash(edge.source())) + "_" + str(cpu) + "_" + str(hash(s_vertex)),
                str(hash(edge.target())) + "_" + str(cpu) + "_" + str(hash(t_vertex)),
                color=color,
                lhead="cluster_" + str(hash(edge.target())),
                ltail="cluster_" + str(hash(edge.source()))
            ))

        self._write_dot(dot_graph)

    def print_sstg_simple(self):
        sstg = self._graph.sstg
        if not sstg:
            self._fail("Graph must be given when choosing sstg.")

        name = self._print_init()
        dot_graph = pydot.Dot(graph_type='digraph', label=name)

        # print all vertices
        for vertex in sstg.vertices():
            metastate = sstg.vp.state[vertex]
            label = ""

            for cpu, graph in metastate.state_graph.items():
                # get name of first vertex
                v = graph.get_vertices()[0]
                state = graph.vp.state[v]
                label += f'{state} | '

            label = label[:-2]
            label += " -- " + str(hash(vertex))

            node = pydot.Node(
                str(hash(vertex)),
                label=label
            )
            dot_graph.add_node(node)

        # print all edges
        for edge in sstg.edges():
            dot_graph.add_edge(
                pydot.Edge(
                    str(hash(edge.source())),
                    str(hash(edge.target()))
                )
            )

        self._write_dot(dot_graph)

    def print_multistates(self):
        sstg = self._graph.sstg
        if not sstg:
            self._fail("Graph must be given when choosing sstg.")

        name = self._print_init()
        dot_graph = pydot.Dot(graph_type='digraph', label=name)

        # print all metastates as clusters
        for state_node in sstg.vertices():
            # print cluster
            metastate = sstg.vp.state[state_node]
            dot_cluster = pydot.Cluster(
                str(hash(state_node)),
                label="Metastate " + str(hash(state_node)),
                style="rounded"
            )
            dot_graph.add_subgraph(dot_cluster)

            for cpu, state_graph in metastate.state_graph.items():
                subg = pydot.Subgraph(
                    str(hash(state_node)) + "_" + str(cpu),
                    label=str(cpu)
                )
                dot_cluster.add_subgraph(subg)

                # print state vertices in cluster
                for vertex in state_graph.vertices():
                    state = state_graph.vp.state[vertex]
                    dot_node = pydot.Node(
                        str(hash(state_node)) + "_" + str(cpu) + "_" + str(hash(vertex)),
                        label=state.__repr__()
                    )
                    subg.add_node(dot_node)

                # print state edges in cluster
                for edge in state_graph.edges():
                    color = "black"
                    if state_graph.ep.is_timed_event[edge]:
                        color = "green"
                    if state_graph.ep.is_isr[edge]:
                        color = "red"
                    dot_edge = pydot.Edge(
                        str(hash(state_node)) + "_" + str(cpu) + "_" + str(hash(edge.source())),
                        str(hash(state_node)) + "_" + str(cpu) + "_" + str(hash(edge.target())),
                        color=color
                    )
                    subg.add_edge(dot_edge)
        self._write_dot(dot_graph)

    def run(self):
        subgraph: str = self.subgraph.get()
        if subgraph == 'bbs':
            self.print_xbbs(bbs=True)
        if subgraph == 'abbs':
            self.print_xbbs(bbs=False)
        if subgraph == 'instances':
            self.print_instances()
        if subgraph == 'sstg':
            self.print_sstg()
        if subgraph == 'mstg':
            self.print_mstg()
        if subgraph == 'hstg':
            self.print_hstg()
        if subgraph == 'reduced_sstg':
            self.print_sstg(reduced=True)
        if subgraph == 'reduced_mstg':
            self.print_reduced_mstg()
        if subgraph == 'sp_mstg':
            self.print_sp_mstg()
        if subgraph == 'multistates':
            self.print_multistates()
        if subgraph == 'callgraph':
            self.print_callgraph()
        if subgraph == 'sysrel_callgraph':
            self.print_callgraph(only_systemrelevant=True)
