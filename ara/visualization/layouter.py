import traceback

from PySide6.QtCore import Slot, QObject, Signal
from pygraphviz import AGraph

from ara.graph import ABBType, CFType
from ara.visualization import ara_manager
from ara.visualization.signal import ara_signal

from ara.visualization.widgets.graph_elements import AbbNode, GraphEdge, Subgraph, CallGraphNode, InstanceNode
from ara.visualization.util import GraphTypes

def set_graph_for_layouter(graph):
    Layouter.graph = graph


class Layouter(QObject):
    """ Layout the components for the Graphical Visualization """

    SHAPES = {
        ABBType.computation: ("oval", "blue"),
        ABBType.call: ("box", "red"),
        ABBType.syscall: ("diamond", "green")
    }

    subgraphs = ("abbs", "instances", "callgraph")

    sig_layout_done = Signal()

    def __init__(self):
        super().__init__()
        self.call_graph_view = AGraph(strict=False, directed=True)
        self.cfg_view = AGraph(strict=False, directed=True)
        self.instance_graph_view = AGraph(strict=False, directed=True)

        self._graph = ara_manager.INSTANCE.graph

    def _fail(self, message):
        print(message)

    def _update_call_graph_view(self, entry_points=None):
        try:
            call_graph = self._graph.callgraph

            cfg = call_graph.gp.cfg

            nodes = []
            edges = []

            for node in call_graph.get_vertices_for_entries_bfs(entry_points, 1):
                # Create Node
                if call_graph.vp.recursive[node]:
                    # Set Information about recursive
                    pass
                self.call_graph_view.add_node(
                    str(hash(node)),
                    height=0.75,
                    width=5,
                    shape="box",
                    label=cfg.vp.name[call_graph.vp.function[node]])

                nodes.append(node)

            for node in nodes:
                for edge in node.all_edges():
                    if edges.__contains__(edge):
                        continue
                    edges.append(edge)

                    # Discover adjacency nodes
                    if not nodes.__contains__(edge.source()):
                        self.call_graph_view.add_node(
                            str(hash(edge.source())),
                            height=0.75,
                            width=4,
                            shape="box",
                            adjacency="true",
                            label=cfg.vp.name[call_graph.vp.function[edge.source()]])
                    elif not nodes.__contains__(edge.target()):
                        self.call_graph_view.add_node(
                            str(hash(edge.target())),
                            height=0.75,
                            width=4,
                            shape="box",
                            adjacency="true",
                            label=cfg.vp.name[call_graph.vp.function[edge.target()]])

                    self.call_graph_view.add_edge(
                        str(hash(edge.source())),
                        str(hash(edge.target())),
                        label=cfg.vp.name[call_graph.ep.callsite[edge]]
                    )

        except Exception as e:
            print(e)
            print(traceback.format_exc())

    def _update_cfg_view(self, entry_point="main"):
        if not self._graph.cfg.contains_function_by_name(entry_point) or self._graph.callgraph.num_vertices() <= 0:
            return

        entry_func = self._graph.cfg.get_function_by_name(entry_point)
        functions = self._graph.cfg.reachable_functs(entry_func, self._graph.callgraph)

        cfg = self._graph.cfg
        nodes = set()
        for function in functions:
            function = cfg.vertex(function)
            subgraph = self.cfg_view.add_subgraph(
                name= "cluster_" + cfg.vp.name[function],
                label=cfg.vp.name[function])

            for abb in cfg.get_abbs(function):
                    subgraph.add_node(
                        str(hash(abb)),
                        label=cfg.vp.name[abb],
                        shape="box",
                        type="Abb",
                        subtype=cfg.vp.type[abb],
                        width=1.5,
                        height=0.75
                    )
                    nodes.add(str(hash(abb)))
        for edge in cfg.edges():
            if cfg.ep.type[edge] not in [CFType.lcf, CFType.icf]:
                continue

            if not all([str(hash(x)) in nodes
                        for x in [edge.source(), edge.target()]]):
                continue

            self.cfg_view.add_edge(str(hash(edge.source())),
                                   str(hash(edge.target())),
                                   edge_type=cfg.ep.type[edge])

    def _update_instance_graph_view(self):
        instance_graph = self._graph.instances

        for instance in instance_graph.vertices():
            inst_obj = instance_graph.vp.obj[instance]

            id = instance_graph.vp.id[instance]

            label_parts = id.split(".")

            label = label_parts[0]
            sublabel = label_parts[1] if len(label_parts) > 1 else ""

            self.instance_graph_view.add_node(
                str(hash(instance)),
                shape="box",
                label=label,
                sublabel=sublabel,
                width=1.5,
                height=0.75)
        for edge in self._graph.instances.edges():
            self.instance_graph_view.add_edge(
                str(hash(edge.source())),
                str(hash(edge.target())),
                label=instance_graph.ep.label[edge])

    def _create_return_data(self, graph:AGraph, return_list, graph_type:GraphTypes=GraphTypes.ABB):
        for n in graph.nodes():
            if graph_type == GraphTypes.ABB:
                if n.attr["subtype"] == "0":
                    # The CallGraphNode is used here, to save making a second generic node
                    return_list.append(CallGraphNode(n))
                else:
                    return_list.append(AbbNode(n))
            if graph_type == GraphTypes.CALLGRAPH:
                return_list.append(CallGraphNode(n))
            if graph_type == GraphTypes.INSTANCE:
                return_list.append(InstanceNode(n))

        for e in graph.edges():
            return_list.append(GraphEdge(e))

        for g in graph.subgraphs():
            return_list.append(Subgraph(g))
            self._create_return_data(g, return_list)

    def get_data(self, graph_type:GraphTypes):
        if not GraphTypes.__contains__(graph_type):
            print(f"The subgraph { graph_type } does not exist")
            return
        return_data = []

        if graph_type == GraphTypes.ABB:
            self._create_return_data(
                self.cfg_view,
                return_data,
                graph_type)

        if graph_type == GraphTypes.CALLGRAPH:
            self._create_return_data(
                self.call_graph_view,
                return_data,
                graph_type)
        if graph_type == GraphTypes.INSTANCE:
            self._create_return_data(
                self.instance_graph_view,
                return_data,
                graph_type)

        return return_data

    @Slot(GraphTypes, list, bool)
    def layout(self, graph_type, entry_points, layout_only = False):
        """
            Build the internal graph views.
        """

        print(f"Layouting {graph_type}")

        if not GraphTypes.__contains__(graph_type):
            print(f"The subgraph { graph_type } does not exist")
            return

        if not layout_only:
            if graph_type == GraphTypes.ABB:
                self.cfg_view.clear()
                self._update_cfg_view()
            if graph_type == GraphTypes.CALLGRAPH:
                self.call_graph_view.clear()
                self._update_call_graph_view(entry_points)
            if graph_type == GraphTypes.INSTANCE:
                self.instance_graph_view.clear()
                self._update_instance_graph_view()

        if graph_type == GraphTypes.ABB:
            self.cfg_view.layout("dot")
            # self.cfg_view.write("./debug.dot")
        if graph_type == GraphTypes.CALLGRAPH:
            self.call_graph_view.layout("dot")
        if graph_type == GraphTypes.INSTANCE:
            self.instance_graph_view.layout("dot")

        self.sig_layout_done.emit()
