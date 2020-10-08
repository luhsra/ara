"""Container for Printer."""
from ara.graph import ABBType, CFType, Graph

from .option import Option, String, Choice, Bool
from .step import Step

import pydot
import html
import os.path

import graph_tool.draw


class Printer(Step):
    """Print graphs to dot."""

    SHAPES = {
        ABBType.computation: ("oval", "", "blue"),
        ABBType.call: ("box", "", "red"),
        ABBType.syscall: ("box", "rounded", "green")
    }

    dot = Option(name="dot",
                 help="Path to a dot file, '-' will write to stdout.",
                 ty=String())
    graph_name = Option(name="graph_name",
                        help="Name of the graph.",
                        ty=String())
    subgraph = Option(name="subgraph",
                      help="Choose, what subgraph should be printed.",
                      ty=Choice("abbs", "instances", "callgraph"))
    entry_point = Option(name="entry_point",
                         help="system entry point",
                         ty=String())
    from_entry_point = Option(name="from_entry_point",
                              help="Print only from the given entry point.",
                              ty=Bool(),
                              default_value=False)


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

    def print_abbs(self):
        name = self._print_init()

        entry_label = self.entry_point.get()
        if self.from_entry_point.get():
            entry_func = self._graph.cfg.get_function_by_name(entry_label)
            functions = self._graph.cfg.reachable_funcs(entry_func)
        else:
            functions = self._graph.functs.vertices()

        dot_nodes = set()
        dot_graph = pydot.Dot(graph_type='digraph', label=name)
        for function in functions:
            dot_func = pydot.Cluster(self._graph.cfg.vp.name[function],
                                     label=self._graph.cfg.vp.name[function])
            dot_graph.add_subgraph(dot_func)
            for edge in self._graph.cfg.vertex(function).out_edges():
                if self._graph.cfg.ep.type[edge] != CFType.f2a:
                    continue
                abb = edge.target()
                if self._graph.cfg.vp.type[abb] == ABBType.not_implemented:
                    assert not self._graph.cfg.vp.implemented[function]
                    dot_abb = pydot.Node(str(hash(abb)),
                                         label="",
                                         shape="box")
                    dot_nodes.add(str(hash(abb)))
                    dot_func.set('style', 'filled')
                    dot_func.set('color', '#eeeeee')
                else:
                    dot_abb = pydot.Node(
                        str(hash(abb)),
                        label=self._graph.cfg.vp.name[abb],
                        shape=self.SHAPES[self._graph.cfg.vp.type[abb]][0],
                        style=self.SHAPES[self._graph.cfg.vp.type[abb]][1],
                        color=self.SHAPES[self._graph.cfg.vp.type[abb]][2]
                    )
                    dot_nodes.add(str(hash(abb)))
                dot_func.add_node(dot_abb)
        for edge in self._graph.cfg.edges():
            if self._graph.cfg.ep.type[edge] not in [CFType.lcf, CFType.icf]:
                continue
            if not all([str(hash(x)) in dot_nodes
                    for x in [edge.source(), edge.target()]]):
                continue
            color = "black"
            if self._graph.cfg.ep.type[edge] == CFType.lcf:
                color = "red"
            if self._graph.cfg.ep.type[edge] == CFType.icf:
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
            dot_graph.add_node(dot_node)
        for edge in callgraph.edges():
            dot_graph.add_edge(pydot.Edge(
                str(hash(edge.source())),
                str(hash(edge.target())),
                label=cfg.vp.name[callgraph.ep.callsite[edge]]))
        self._write_dot(dot_graph)

    def run(self):
        subgraph = self.subgraph.get()
        if subgraph == 'abbs':
            self.print_abbs()
        if subgraph == 'instances':
            self.print_instances()
        if subgraph == 'callgraph':
            self.print_callgraph()
