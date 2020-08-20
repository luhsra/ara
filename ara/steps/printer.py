"""Container for Printer."""
from ara.graph import ABBType, CFType, Graph

from .option import Option, String, Choice, Bool
from .step import Step

import pydot
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

        dot_graph = pydot.Dot(graph_type='digraph', label=name)
        for function in self._graph.cfg.vertices():
            if not self._graph.cfg.vp.is_function[function]:
                continue
            dot_func = pydot.Cluster(self._graph.cfg.vp.name[function],
                                     label=self._graph.cfg.vp.name[function])
            dot_graph.add_subgraph(dot_func)
            for edge in function.out_edges():
                if self._graph.cfg.ep.type[edge] != CFType.f2a:
                    continue
                abb = edge.target()
                if self._graph.cfg.vp.type[abb] == ABBType.not_implemented:
                    assert not self._graph.cfg.vp.implemented[function]
                    dot_abb = pydot.Node(str(hash(abb)),
                                         label="",
                                         shape="box")
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
                dot_func.add_node(dot_abb)
        for edge in self._graph.cfg.edges():
            if self._graph.cfg.ep.type[edge] not in [CFType.lcf, CFType.icf]:
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

        dot_graph = pydot.Dot(graph_type='digraph', label=name)
        for instance in self._graph.instances.vertices():
            dot_node = pydot.Node(
                str(hash(instance)),
                label=self._graph.instances.vp.label[instance],
            )
            dot_graph.add_node(dot_node)
        for edge in self._graph.instances.edges():
            dot_graph.add_edge(pydot.Edge(
                str(hash(edge.source())),
                str(hash(edge.target())),
                label=self._graph.instances.ep.label[edge]))
        self._write_dot(dot_graph)

    def print_callgraph(self):
        # name = self._print_init()

        # dot_graph = pydot.Dot(graph_type='digraph', label=name)
        # for instance in self._graph.instances.vertices():
        #     dot_node = pydot.Node(
        #         str(hash(instance)),
        #         label=self._graph.instances.vp.label[instance],
        #     )
        #     dot_graph.add_node(dot_node)
        # for edge in self._graph.instances.edges():
        #     dot_graph.add_edge(pydot.Edge(
        #         str(hash(edge.source())),
        #         str(hash(edge.target())),
        #         label=self._graph.instances.ep.label[edge]))
        # self._write_dot(dot_graph)

    def run(self):
        subgraph = self.subgraph.get()
        if subgraph == 'abbs':
            self.print_abbs()
        if subgraph == 'instances':
            self.print_instances()
        if subgraph == 'callgraph':
            self.print_callgraph()
