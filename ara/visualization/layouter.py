import traceback

from PySide6.QtCore import Slot, QObject, Signal
from pydot import call_graphviz
from pygraphviz import AGraph

from ara.graph import ABBType, CFType, Graph
from ara.visualization import ara_manager
from ara.visualization.signal import ara_signal
from ara.visualization.trace import trace_handler

from ara.visualization.widgets.graph_elements import AbbNode, GraphEdge, Subgraph, CallGraphNode, InstanceNode
from ara.visualization.util import GraphTypes, StepMode

VALID_EDGE_TYPE = [CFType.lcf, CFType.icf]


def set_graph_for_layouter(graph):
    Layouter.graph = graph


def text_to_len(txt):
    txt_len = len(txt)
    if txt_len < 5:
        return txt_len * 0.25
    elif txt_len < 10:
        return txt_len * 0.2
    elif txt_len < 15:
        return txt_len * 0.17
    else:
        return txt_len * 0.15


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

        self.call_graph_view.graph_attr["overlap"] = "false"

        self._graph = ara_manager.INSTANCE.graph

    def _fail(self, message):
        print(message)

    def _update_call_graph_view(self, entry_points=None, mode=StepMode.DEFAULT):
        try:
            if mode is StepMode.TRACE:
                call_graph = trace_handler.INSTANCE.context.callgraph
            else:
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
                    width=text_to_len(call_graph.vp.function_name[node]),
                    shape="box",
                    id=call_graph.vp.function_name[node],
                    label=call_graph.vp.function_name[node])

                nodes.append(node)

            for node in nodes:
                for edge in node.all_edges():
                    if edges.__contains__(edge):
                        continue
                    edges.append(edge)

                    # Discover adjacency nodes
                    discovered_node = None
                    if not nodes.__contains__(edge.source()):
                        discovered_node = edge.source()

                    elif not nodes.__contains__(edge.target()):
                        discovered_node = edge.target()

                    if not (discovered_node is None):
                        self.call_graph_view.add_node(
                            str(hash(discovered_node)),
                            height=0.75,
                            width=text_to_len(call_graph.vp.function_name[discovered_node]),
                            shape="box",
                            adjacency="true",
                            id=call_graph.vp.function_name[discovered_node],
                            label=call_graph.vp.function_name[discovered_node])

                    self.call_graph_view.add_edge(
                        str(hash(edge.source())),
                        str(hash(edge.target())),
                        id=call_graph.ep.callsite_name[edge],
                        label=call_graph.ep.callsite_name[edge]
                    )

        except Exception as e:
            print(e)
            print(traceback.format_exc())

    def _update_cfg_view(self, entry_points=None, mode=StepMode.DEFAULT):
        try:

            if mode is StepMode.TRACE:
                cfg = trace_handler.INSTANCE.context.cfg
            else:
                cfg = self._graph.cfg

            if self._graph.callgraph.num_vertices() <= 0:
                return

            functions = set()

            for entry in entry_points:
                functions.add(self._graph.cfg.get_function_by_name(entry))

            nodes = set()
            extended_nodes = set()
            edges = set()
            for function in functions:
                function = cfg.vertex(function)
                subgraph = self.cfg_view.add_subgraph(
                    name="cluster_" + cfg.vp.name[function],
                    height=1.75,
                    widht=text_to_len(cfg.vp.name[function]),
                    label=cfg.vp.name[function])

                cfg_nodes = cfg.get_abbs(function)
                node_type = "ABB"
                if len(list(cfg_nodes)) == 0:
                    cfg_nodes = cfg.get_function_bbs(function)
                    node_type = "BB"
                else:
                    cfg_nodes = cfg.get_abbs(function)

                for node in cfg_nodes:
                    subgraph.add_node(
                        str(hash(node)),
                        label=cfg.vp.name[node],
                        id=cfg.vp.name[node],
                        shape="box",
                        type=node_type,
                        subtype=cfg.vp.type[node],
                        width=1.5,
                        height=0.75
                    )
                    nodes.add(node)

            for node in nodes:
                for edge in node.all_edges():
                    if edges.__contains__(edge):
                        continue
                    edges.add(edge)

                    type = cfg.ep.type[edge]
                    if not VALID_EDGE_TYPE.__contains__(type):
                        continue

                    discovered_node = None

                    if not nodes.__contains__(edge.target()):
                        discovered_node = edge.target()

                    if not (discovered_node is None):
                        function = cfg.get_function(discovered_node)
                        if not (function is None):
                            subgraph = self.cfg_view.add_subgraph(
                                name="cluster_" + cfg.vp.name[function],
                                height=1.75,
                                widht=text_to_len(cfg.vp.name[function]),
                                label=cfg.vp.name[function])

                            subgraph.add_node(
                                str(hash(discovered_node)),
                                label=cfg.vp.name[discovered_node],
                                id=cfg.vp.name[discovered_node],
                                shape="box",
                                type="ABB",
                                subtype=cfg.vp.type[discovered_node],
                                width=1.5,
                                height=0.75
                            )
                            extended_nodes.add(discovered_node)

                    if not (nodes|extended_nodes).__contains__(edge.source()) or \
                            not (nodes|extended_nodes).__contains__(edge.target()):
                        continue

                    self.cfg_view.add_edge(str(hash(edge.source())),
                                           str(hash(edge.target())),
                                           edge_type=cfg.ep.type[edge])

        except Exception as e:
            print(e)
            print(traceback.format_exc())

    def _update_instance_graph_view(self, mode=StepMode.DEFAULT):

        if mode is StepMode.TRACE:
            instance_graph = trace_handler.INSTANCE.context.instances
        else:
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

    def _create_return_data(self, graph: AGraph, return_list, graph_type: GraphTypes = GraphTypes.ABB):
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

    def get_data(self, graph_type: GraphTypes):
        if not GraphTypes.__contains__(graph_type):
            print(f"The subgraph {graph_type} does not exist")
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

    @Slot(GraphTypes, set, bool, StepMode)
    def layout(self, graph_type, entry_points, layout_only=False, mode=StepMode.DEFAULT):
        """
            Build the internal graph views.
        """

        try:

            print(f"Layouting {graph_type} - {entry_points}")

            if not GraphTypes.__contains__(graph_type):
                print(f"The subgraph {graph_type} does not exist")
                return

            if not layout_only:
                if graph_type == GraphTypes.ABB:
                    self.cfg_view.clear()
                    self._update_cfg_view(entry_points, mode)
                if graph_type == GraphTypes.CALLGRAPH:
                    self.call_graph_view.clear()
                    self.call_graph_view.graph_attr["overlap"] = "false"
                    self.call_graph_view.graph_attr["splines"] = "true"
                    self._update_call_graph_view(entry_points, mode)
                if graph_type == GraphTypes.INSTANCE:
                    self.instance_graph_view.clear()
                    self._update_instance_graph_view(mode)

            if graph_type == GraphTypes.ABB:
                self.cfg_view.layout("dot")
                #self.cfg_view.write("./debug.dot")
            if graph_type == GraphTypes.CALLGRAPH:
                self.call_graph_view.layout("dot")
            if graph_type == GraphTypes.INSTANCE:
                self.instance_graph_view.layout("dot")


        except Exception as e:
            print(e)
            print(traceback.format_exc())

        self.sig_layout_done.emit()

    @Slot(Graph)
    def set_graph(self, graph):
        self._graph = graph