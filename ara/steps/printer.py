"""Container for Printer."""
from ara.graph import ABBType, CFType, CFGView, MSTType, StateType, single_check
from ara.os.os_base import ExecState

from .option import Option, String, Choice, Bool
from .step import Step

from graph_tool import GraphView
from graph_tool.topology import all_paths

import pydot
import html
import os
import os.path


def _sstg_state_as_dot(sstg, state_vert):
    attrs = {"fontsize": 14}
    size = 12

    obj = sstg.vp.state[state_vert]
    cfg = obj.cfg
    label = f"State {obj.id}"
    cpu = obj.cpus.one()
    if cpu.control_instance:
        instance = obj.instances.vp.label[obj.instances.vertex(cpu.control_instance)]
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
                ("irq_on", cpu.irq_on),
                (
                    "instance",
                    instance,
                ),
                ("call_path", cpu.call_path),
                ("type", str(cpu.exec_state)),
                ("abb", abb),
            ] + xcet
        ]
    )
    graph_attrs = f"<font point-size='{size}'>{graph_attrs}</font>"
    attrs["label"] = f"<{label}<br/>{graph_attrs}>"
    tooltip = str(state_vert)
    if cpu.abb:
        code = "\r".join([str(cfg.get_llvm_obj(bb))
                          for bb in cfg.get_bbs(cpu.abb)])
        code = code.replace('\n', '\r')
        tooltip = f'<{tooltip + code}>'

    attrs["tooltip"] = tooltip

    if cpu.exec_state & ExecState.with_time:
        attrs["color"] = "green"
    elif cpu.exec_state & ExecState.syscall:
        attrs["color"] = "blue"
        attrs["shape"] = "box"

    return attrs


def sstg_to_dot(sstg, label="SSTG"):
    dot_graph = pydot.Dot(graph_type="digraph", label=label)

    for state_vert in sstg.vertices():
        attrs = _sstg_state_as_dot(
            sstg, state_vert
        )
        dot_state = pydot.Node(str(state_vert), **attrs)
        dot_graph.add_node(dot_state)
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


def reduced_mstg_to_dot(mstg, label="MSTG"):
    shorten = {
            "AUTOSAR_GetSpinlock": "GL",
            "AUTOSAR_ReleaseSpinlock": "RL",
            "AUTOSAR_ActivateTask": "AT",
            "AUTOSAR_ChainTask": "CT",
            "AUTOSAR_SetEvent": "SE",
            "AUTOSAR_WaitEvent": "WE",

    }

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
                cols.append(f"<TD PORT=\"c{cpu_id}\">CPU {cpu_id}</TD>")
        if cols:
            label = '<<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">' \
                    '<TR>{}</TR>' \
                    '</TABLE>>'.format(''.join(sorted(cols)))
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
    ms_sync = mstg.edge_type(MSTType.m2sy, MSTType.en2ex)
    time_sync.set_reversed(True)
    sy2sy = mstg.edge_type(MSTType.sy2sy)
    added_edges = set()

    def _sync_str(v, cpu_id):
        return f"{_to_str(v)}:c{cpu_id}"

    def _add_edge(from_sp, to_sp, core):
        exit_state = mstg.get_exit_state(to_sp, core)
        syscall_name = mstg.get_syscall_name(exit_state)

        attrs = {"color": "black"}
        if mstg.get_exec_state(exit_state) == ExecState.waiting:
            attrs["color"] = "limegreen"
        elif syscall_name:
            attrs["label"] = shorten[syscall_name]
            attrs["color"] = "darkred"

        # merge entry and exit sync states
        f_to_sp = en2ex.vertex(to_sp)
        if f_to_sp.out_degree() == 1:
            n_tgt = single_check(f_to_sp.out_neighbors())
        else:
            n_tgt = to_sp

        # examine start and end for the dot edge
        dot_tgt = _sync_str(n_tgt, core)
        dot_src = _sync_str(from_sp, core)
        if (dot_src, dot_tgt) in added_edges:
            return None
        added_edges.add((dot_src, dot_tgt))
        return pydot.Edge(dot_src, dot_tgt, **attrs)

    # edge printing
    # we want to find the edges to the last core-local root SP
    # we therefore first retrieve the root
    for entry_sp in mstg.get_sync_points(exit=False).vertices():
        for parent_sp in sy2sy.vertex(entry_sp).in_neighbors():
            # now we can iterate all pathes from the SP to the root
            cores = core_map[int(entry_sp)]
            for path in all_paths(time_sync, entry_sp, parent_sp):
                # every path of follow_sync edges between the SP and its
                # root SP must also have a path for each core. Otherwise the
                # path is not valid.
                # We therefore also check the metastates for each core.
                handled_cores = set()
                for x in path[1:]:
                    if mstg.vp.type[x] == StateType.entry_sync:
                        continue
                    x_cores = core_map[int(x)] & cores
                    invalid = False
                    for core in x_cores - handled_cores:
                        # there must be a connection via metastates, otherwise
                        # the path is not valid
                        def good_edge(e):
                            if mstg.ep.type[e] == MSTType.m2sy:
                                return mstg.ep.cpu_id[e] == core
                            return True
                        cg = GraphView(ms_sync, efilt=good_edge)
                        ms1 = set(cg.vertex(entry_sp).in_neighbors())
                        ms2 = set(cg.vertex(x).out_neighbors())
                        if len(ms2) > 0 and ms1 != ms2:
                            # this is an invalid path
                            invalid = True
                            break
                        edge = _add_edge(x, entry_sp, core)
                        if edge:
                            dot_graph.add_edge(edge)
                    if invalid:
                        break
                    handled_cores |= x_cores
                    if len(cores - handled_cores) == 0:
                        break

    for edge in en2ex.edges():
        src = edge.source()
        if (src.out_degree() > 1):
            dot_graph.add_edge(pydot.Edge(_to_str(src),
                                          _to_str(edge.target())))

    return dot_graph


def mstg_to_dot(mstg, label="MSTG"):
    def _to_str(v):
        return str(int(v))

    def _draw_sync(sync, edges):
        cols = []
        for e in edges:
            if mstg.ep.type[e] == MSTType.st2sy:
                cpu_id = mstg.ep.cpu_id[e]
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
                                  label=f"M{int(metastate)} (CPU {cpu_id})")
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
                      ty=Choice("bbs", "abbs", "instances", "callgraph",
                                "multistates", "sstg", "reduced_sstg", "mstg",
                                "reduced_mstg", "sp_mstg"))
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

    def _print_init(self):
        dot = self.dot.get()
        if not dot:
            self._fail("dot file path must be given.")

        name = self.graph_name.get()
        if not name:
            name = ''
        return name

    def _write_dot(self, dot):
        dot_path = self.dot.get()
        assert dot_path
        dot_path = os.path.abspath(dot_path)
        os.makedirs(os.path.dirname(dot_path), exist_ok=True)
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

        hfile = os.path.join(os.path.dirname(self.dump_prefix.get()),
                             'html_files',
                             os.path.basename(filename) + ".html")
        hfile = os.path.realpath(hfile)
        self._graph.file_cache[filename] = hfile

        with open(filename) as f:
            code = f.read()

        os.makedirs(os.path.dirname(hfile), exist_ok=True)
        with open(hfile, 'w') as g:
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
            dot_func = pydot.Cluster(cfg.vp.name[function],
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
                tooltip += code
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
                    if cfg.vp.loop_head[block]:
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

        if reduced:
            sstg = self._graph.reduced_sstg
        else:
            sstg = self._graph.sstg

        dot_graph = sstg_to_dot(sstg, name)
        self._write_dot(dot_graph)

    def print_mstg(self):
        name = self._print_init()
        dot_graph = mstg_to_dot(self._graph.mstg, name)
        self._write_dot(dot_graph)

    def print_reduced_mstg(self):
        name = self._print_init()
        dot_graph = reduced_mstg_to_dot(self._graph.mstg, name)
        self._write_dot(dot_graph)

    def print_sp_mstg(self):
        shorten = {
                "AUTOSAR_GetSpinlock": "GL",
                "AUTOSAR_ReleaseSpinlock": "RL",
                "AUTOSAR_ActivateTask": "AT",
                "AUTOSAR_ChainTask": "CT",
                "AUTOSAR_SetEvent": "SE",
                "AUTOSAR_WaitEvent": "WE",

        }
        name = self._print_init()
        dot_graph = pydot.Dot(graph_type="digraph", label=name)
        mstg = self._graph.mstg

        def _dsp(vertex, label=None):
            if label is None:
                label = [str(int(vertex))]
            return pydot.Node(str(int(vertex)), shape="box",
                              label="<{}>".format('<br/>'.join([html.escape(str(x)) for x in label])))

        # draw initial sync node
        for init in mstg.get_sync_points(exit=True).vertices():
            init = mstg.vertex(init)
            if init.in_degree() == 0:
                dot_graph.add_node(_dsp(init))

        en2ex = mstg.edge_type(MSTType.en2ex)

        for sync_point in mstg.get_sync_points(exit=False).vertices():
            sync_point = mstg.vertex(sync_point)
            sys_state, core, irq = mstg.get_syscall_state(sync_point)
            label = f"c{core}, s{int(sys_state)}"
            if irq > 0:
                label += u" (\u26A1" + f"{irq})"
            else:
                sys_name = mstg.get_syscall_name(sys_state)
                label += f" ({shorten[sys_name]})"
            if en2ex.vertex(sync_point).out_degree() > 1:
                sync_m = pydot.Cluster("Metasync" + str(int(sync_point)),
                                       label="")
                dot_graph.add_subgraph(sync_m)
                # draw entry_sync
                sync_m.add_node(_dsp(sync_point, label=[str(int(sync_point)),
                                                        label]))
                # draw exit_sync
                for follow in sync_point.out_neighbors():
                    sync_m.add_node(_dsp(sync_point))
            else:
                # draw only the exit_sync
                exit_s = single_check(sync_point.out_neighbors())
                title = f"{str(int(sync_point))}->{str(int(exit_s))}"
                dot_graph.add_node(_dsp(
                    exit_s,
                    label=[title, label]
                ))

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

        self._write_dot(dot_graph)

    def print_callgraph(self):
        name = self._print_init()

        shapes = {
            True: ("box", "green"),
            False: ("box", "black")
        }

        dot_graph = pydot.Dot(graph_type='digraph', label=name)
        callgraph = self._graph.callgraph

        cfg = callgraph.gp.cfg
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
        subgraph = self.subgraph.get()
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
