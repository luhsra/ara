"""Container for Printer."""
from ara.graph import ABBType, CFType, Graph, NodeLevel, CFGView

import pydot
import html
import os
import os.path

import graph_tool.draw


class Printer:
    """Print graphs to dot."""

    SHAPES = {
        ABBType.computation: ("oval", "blue"),
        ABBType.call: ("box", "red"),
        ABBType.syscall: ("diamond", "green")
    }

   # dot = Option(name="dot",
   #              help="Path to a dot file, '-' will write to stdout.",
   #              ty=String())
   # graph_name = Option(name="graph_name",
   #                     help="Name of the graph.",
   #                     ty=String())
   # subgraph = Option(name="subgraph",
   #                   help="Choose, what subgraph should be printed.",
   #                   ty=Choice("abbs", "instances", "callgraph",
   #                             "multistates", "sstg_full", "sstg_simple"))
   # entry_point = Option(name="entry_point",
   #                      help="system entry point",
   #                      ty=String())
   # from_entry_point = Option(name="from_entry_point",
   #                           help="Print only from the given entry point.",
   #                           ty=Bool(),
   #                           default_value=False)

    def __init__(self, g,  subgraph, entry_point, dotPath="./temp.dot",graph_name="DotGraph", from_entry_point = "true"):
        self._graph = g
        self.subgraph = subgraph
        self.entry_point = entry_point
        self.dot = dotPath
        self.graph_name = graph_name
        self.from_entry_point = from_entry_point

    def _fail(self, message):
        print(message)

    def _print_init(self):
        dot = self.dot
        if not dot:
            self._fail("dot file path must be given.")

        name = self.graph_name
        if not name:
            name = ''
        return name

    def _write_dot(self, dot):
        dot_path = self.dot
        assert dot_path
        dot_path = os.path.abspath(dot_path)
        os.makedirs(os.path.dirname(dot_path), exist_ok=True)
        dot.write(dot_path)
        #self._log.info(f"Write {self.subgraph.get()} to {dot_path}.")

    #def _gen_html_file(self, filename):
    #    try:
    #        from pygments import highlight
    #        from pygments.lexers import CppLexer
    #        from pygments.formatters import HtmlFormatter
    #    except ImportError:
    #        #self._log.warn("Pygments not found, skip source code linking")
    #        return None
#
    #    filename = os.path.abspath(filename)
#
    #    if filename in self._graph.file_cache:
    #        return self._graph.file_cache[filename]
#
    #    hfile = os.path.join(os.path.dirname(self.dump_prefix.get()),
    #                         'html_files',
    #                         os.path.basename(filename) + ".html")
    #    hfile = os.path.realpath(hfile)
    #    self._graph.file_cache[filename] = hfile
#
    #    with open(filename) as f:
    #        code = f.read()
#
    #    os.makedirs(os.path.dirname(hfile), exist_ok=True)
    #    with open(hfile, 'w') as g:
    #        g.write(highlight(code, CppLexer(),
    #                          HtmlFormatter(linenos='inline',
    #                                        lineanchors='line', full=True)))
    #    return hfile

    def print_abbs(self):
        name = self._print_init()

        cfg = self._graph.cfg

        entry_label = self.entry_point.get()
        if self.from_entry_point:
            entry_func = self._graph.cfg.get_function_by_name(entry_label)
            functions = self._graph.cfg.reachable_functs(entry_func)
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
            for abb in cfg.get_abbs(function):
                if cfg.vp.type[abb] == ABBType.not_implemented:
                    assert not cfg.vp.implemented[function]
                    dot_abb = pydot.Node(str(hash(abb)),
                                         label="",
                                         shape="box")
                    dot_nodes.add(str(hash(abb)))
                    dot_func.set('style', 'filled')
                    dot_func.set('color', '#eeeeee')
                else:
                    dot_abb = pydot.Node(
                        str(hash(abb)),
                        label=cfg.vp.name[abb],
                        shape=self.SHAPES[self._graph.cfg.vp.type[abb]][0],
                        color=self.SHAPES[self._graph.cfg.vp.type[abb]][1]
                    )
                    if cfg.vp.part_of_loop[abb]:
                        dot_abb.set('style', 'dashed')
                    dot_nodes.add(str(hash(abb)))
                dot_func.add_node(dot_abb)
        for edge in cfg.edges():
            if cfg.ep.type[edge] not in [CFType.lcf, CFType.icf]:
                continue
            if not all([str(hash(x)) in dot_nodes
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

            #if self.gen_html_links.get():
            #    src_file = instances.vp.file[instance]
            #    src_line = instances.vp.line[instance]
            #    if (src_file != '' and src_line != 0):
            #        hfile = self._gen_html_file(src_file)
            #        if hfile is not None:
            #            attrs["URL"] = f"file://{hfile}#line-{src_line}"

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

        cfg = CFGView(self._graph.cfg, efilt=lambda x: self._graph.cfg.ep.type[x] == CFType.icf
                                                       or self._graph.cfg.ep.type[x] == CFType.lcf)

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

    def run(self, subgraph):
        if subgraph == 'abbs':
            self.print_abbs()
        if subgraph == 'instances':
            self.print_instances()
        if subgraph == 'sstg_full':
            self.print_sstg_full()
        if subgraph == 'sstg_simple':
            self.print_sstg_simple()
        if subgraph == 'multistates':
            self.print_multistates()
        if subgraph == 'callgraph':
            self.print_callgraph()
