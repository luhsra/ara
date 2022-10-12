from ara.visualization.trace import trace_lib
from graph_tool.libgraph_tool_core import Vertex, Edge
from datetime import datetime
from ara.visualization.trace.trace_components import BaseTraceElement, CFGNodeHighlightTraceElement, CallgraphNodeHighlightTraceElement, NodeHighlightTraceElement, ResetPartialChangesTraceElement
from dataclasses import dataclass
from pathlib import Path
from typing import List
from ara.graph.graph import CFG, SVFG, Callgraph, InstanceGraph

from ara.visualization.trace.trace_type import AlgorithmTrace
from ara.graph.mix import GraphTypes


@dataclass
class Entity:
    #id: int
    name: str
    color: trace_lib.Color
    undo_previous_elems: ResetPartialChangesTraceElement  # Reset operation to undo all changes made by the entity on its last trace


def _value_to_graphtypes(value):
    if type(value) != GraphTypes:
        if type(value) != int:
            assert False, f"Unknown GraphTypes type. type is {type(value)}"
        value = GraphTypes(value)
    return value


@dataclass
class GraphNode:
    node: Vertex
    graph: GraphTypes

    def __post_init__(self):
        self.graph = _value_to_graphtypes(self.graph)

    def __str__(self):
        return f"node {self.node} in {self.graph.name}"


@dataclass
class GraphPath:
    path: List[Edge]  # argument will be copied
    graph: GraphTypes

    def __post_init__(self):
        self.graph = _value_to_graphtypes(self.graph)
        self.path = self.path.copy()

    def __str__(self):
        output_str = "path ["
        first_run = True
        for edge in self.path:
            if not first_run:
                output_str += ", "
            output_str += str(edge)
            first_run = False
        output_str += f"] in {self.graph.name}"
        return output_str


class Tracer:

    def __init__(self,
                 trace_name: str,
                 callgraph,
                 cfg,
                 instances,
                 svfg,
                 low_level_trace: AlgorithmTrace = None):
        self.trace_name = trace_name
        if low_level_trace == None:
            self.low_level_trace = AlgorithmTrace(callgraph, cfg, instances,
                                                  svfg)
        else:
            self.low_level_trace = low_level_trace

    def _format_trace_output(self, entity: Entity, output: str):
        line = f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')} {self.trace_name:{10}} {entity.name:{15}} {output}\n"
        print(line, end='')
        return line

    def _format_list_output(self, ent: Entity, objects: List[GraphNode],
                            msg: str) -> str:
        output_str = ""
        for obj in objects:
            output_str += self._format_trace_output(ent, msg + str(obj))
        return output_str

    def _highlight_nodes(self,
                         nodes: List[GraphNode],
                         color=trace_lib.Color.RED) -> List[BaseTraceElement]:
        highlight_node_elems = []
        for node in nodes:
            if node.graph == GraphTypes.CALLGRAPH:
                highlight_node_elems.append(
                    CallgraphNodeHighlightTraceElement(
                        node.node, self.low_level_trace.callgraph, color))
            elif node.graph == GraphTypes.ABB:
                highlight_node_elems.append(
                    CFGNodeHighlightTraceElement(
                        node.node, self.low_level_trace.cfg,
                        self.low_level_trace.callgraph, color))
            else:
                highlight_node_elems.append(
                    NodeHighlightTraceElement(node.node, node.graph, color))
        return highlight_node_elems

    def _handle_entity_reset(self, ent: Entity,
                             actions: List[BaseTraceElement]):
        """Fill actions with undo operation of all changes from last trace of the entity.
        
        Also updates the undo_previous_elems field with the changes in actions
        """
        undo_previous_elems = ent.undo_previous_elems
        ent.undo_previous_elems = ResetPartialChangesTraceElement(
            actions.copy())
        if undo_previous_elems != None:
            # undo previous change:
            actions.insert(0, undo_previous_elems)

    def get_entity(self, name: str):
        """Creates a new entity on this trace"""
        # TODO: choose multiple colors automatically
        return Entity(name, trace_lib.Color.GREEN, None)

    def entity_on_node(self, ent: Entity, nodes: List[GraphNode]):
        if isinstance(nodes, GraphNode):
            nodes = [nodes]
        actions = self._highlight_nodes(nodes, ent.color)
        self._handle_entity_reset(ent, actions)
        self.low_level_trace.add_element(
            actions, self._format_list_output(ent, nodes, "is on "))

    def entity_is_looking_at(self, ent: Entity, paths: List[GraphPath]):
        # TODO: handle null elements and None
        if isinstance(paths, GraphPath):
            paths = [paths]
        self.low_level_trace.add_element(
            None, self._format_list_output(ent, paths, "is looking at "))

    def go_to_node(self, ent: Entity, path: GraphPath, forward: bool = True):
        """go the path to a node
        
        ent:        Entity to highlight
        path:       path to highlight
        forward:    True if path is followed in forward direction:
                        In this case the destination node is the target of the last edge in path.
                    If you follow input edges, set forward to False:
                        In this case the destination node is the source of the last edge in path.
        """
        self.low_level_trace.add_element(
            None,
            self._format_trace_output(
                ent,
                f"goes to node {path.path[-1].target() if forward else path.path[-1].source()} via {path}"
            ))

    def duplicate(self, old_entity: Entity, new_name: str) -> Entity:
        # just do a new entity there is no connection to the old entity that can be copied in some way
        return self.get_entity(
            new_name if new_name != None else f"{old_entity.name}_clon")

    def change_status(self, ent: Entity, status: str):
        self.low_level_trace.add_element(
            None,
            self._format_trace_output(ent, f"changes status to '{status}'"))

    def get_subtrace(self, name: str):
        return Tracer(self.trace_name + ":" + name,
                      None,
                      None,
                      None,
                      None,
                      low_level_trace=self.low_level_trace)

    def add_element(self,
                    element: List[BaseTraceElement],
                    log_message: str = None):
        """Direct interface to low level trace API.
        
        Just calls self.low_level_trace.add_element().
        """
        return self.low_level_trace.add_element(element, log_message)

    def _get_graph_by_type(self, graph_type: int):
        if graph_type == GraphTypes.SVFG.value:
            return self.low_level_trace.svfg
        elif graph_type == GraphTypes.CALLGRAPH.value:
            return self.low_level_trace.callgraph
        elif graph_type == GraphTypes.INSTANCE.value:
            return self.low_level_trace.instances
        elif graph_type == GraphTypes.ABB.value:
            return self.low_level_trace.cfg
        assert False
        return None

    def get_vertex_by_id(self, v_id: int, graph_type: int) -> Vertex:
        """Used by C++ wrapper to get a vertex object by id"""
        return self._get_graph_by_type(graph_type).vertex(v_id)

    def get_edge_by_nodes(self, source: int, target: int,
                          graph_type: int) -> Edge:
        """Used by C++ wrapper to get an edge object by its source and target nodes"""
        return self._get_graph_by_type(graph_type).edge(
            source, target
        )  # TODO: improve performance by e.g. not using Edge object directly


def init_fast_trace(step, name: str = None):
    """Same as init_trace() but without graph copies"""
    if name == None:
        name = step.get_name()
    graph = step._graph
    step.trace = Tracer(name, graph.callgraph, graph.cfg, graph.instances,
                        graph.svfg)


def init_trace(step, name: str = None):
    """Initializes a new visualization trace. Called on startup of traceable steps.
    Call it with the current step that is running e.g. ini_trace(self)"""
    if name == None:
        name = step.get_name()
    graph = step._graph
    step.trace = Tracer(name, Callgraph(graph.cfg, graph=CFG(graph.callgraph)),
                        CFG(graph.cfg), InstanceGraph(graph.instances),
                        SVFG(graph.svfg))
