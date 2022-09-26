from dataclasses import dataclass
from queue import PriorityQueue

import traceback
from ara.graph.graph import CFG, Callgraph
from graph_tool.libgraph_tool_core import Vertex

from ara.visualization.trace import trace_lib
from ara.visualization.util import GraphTypes
from ara.visualization.widgets.graph_elements import NodeSetting, CallgraphEdgeSetting


class TraceContext:
    """
        This objects holds the data which is needed for the processing of the trace.
    """

    def __init__(self, callgraph, cfg, instances, svfg):
        self.cfg = cfg
        self.callgraph = callgraph
        self.instances = instances
        self.svfg = svfg


class IndexFactory:
    """
        Factory to easily create an index.
        Might be overkill.
    """

    def __init__(self):
        self.value = 0

    def get_value_and_increment(self):
        temp = self.value
        self.value += 1
        return temp


class BaseTraceElement:
    """
        Base class which every trace element should extend to be able to be processed.
    """

    global_index = IndexFactory()

    def __init__(self):
        self.index = self.global_index.get_value_and_increment()
        self.gui_element_settings = dict()
        self.extension_points = set()
        self.entry_points = set()

    def get_graphical_handling(self):
        return self.gui_element_settings

    def get_extension_points(self):
        return self.extension_points

    def get_entry_points(self):
        return self.entry_points

    def apply_changes(self, context: TraceContext):
        pass

    def print_debug(self, context: TraceContext):
        pass

    def undo_changes(self, gui_element_settings: dict):
        pass

    def __gt__(self, other):
        if not isinstance(other, BaseTraceElement):
            return False

        return self.index > other.index

    def __lt__(self, other):
        if not isinstance(other, BaseTraceElement):
            return False

        return self.index < other.index


@dataclass
class LogTraceElement:
    trace_elem: BaseTraceElement  # Can also be of type list to contain more elements
    log_line: str


class NodeHighlightTraceElement(BaseTraceElement):
    """
        Trace element which highlights a call graph node.
    """

    def __init__(self,
                 node: Vertex,
                 graph: GraphTypes,
                 color=trace_lib.Color.RED):
        super().__init__()
        self.node = node
        self.graph = graph
        self.color = color

    def apply_changes(self, context: TraceContext):
        try:
            trace_setting = trace_lib.TraceElementSetting(
                True, self.graph,
                self.node if isinstance(self.node, str) else int(self.node))
            self.gui_element_settings[trace_setting] = NodeSetting(
                highlighting=True, highlight_color=self.color)
        except Exception as e:
            print(e)
            print(traceback.format_exc())

    def undo_changes(self, gui_element_settings: dict):
        try:
            trace_setting = trace_lib.TraceElementSetting(
                True, self.graph, self.node)
            del gui_element_settings[trace_setting]
        except Exception as e:
            print(traceback.format_exc())

    def print_debug(self, context):
        print(f"Highlighting node: {self.node}")


class CFGNodeHighlightTraceElement(NodeHighlightTraceElement):

    def __init__(self,
                 node: Vertex,
                 cfg: CFG,
                 callgraph: Callgraph,
                 color=trace_lib.Color.RED):
        super().__init__(node, GraphTypes.ABB, color)
        self.cfg = cfg
        self.callgraph = callgraph

    def apply_changes(self, context: TraceContext):
        super().apply_changes(context)
        try:
            cfg_function = self.cfg.get_function(self.node)
            function = self.callgraph.vertex(
                self.cfg.vp.call_graph_link[cfg_function])
            if function != None:
                func_name = self.callgraph.vp.function_name[function]
                if isinstance(func_name, str) and len(func_name) > 0:
                    self.entry_points.add(func_name)
        except Exception as e:
            print(e)
            print(traceback.format_exc())


class CallgraphNodeHighlightTraceElement(NodeHighlightTraceElement):
    """
        Trace element which highlights a call graph node.
    """

    def __init__(self,
                 node: Vertex,
                 callgraph: Callgraph,
                 color=trace_lib.Color.RED):
        super().__init__(callgraph.vp.function_name[node],
                         GraphTypes.CALLGRAPH, color)

    def apply_changes(self, context: TraceContext):
        super().apply_changes(context)
        # TODO: filter by graph on extension points
        try:
            self.extension_points.add(self.node)
        except Exception as e:
            print(e)
            print(traceback.format_exc())

    def undo_changes(self, gui_element_settings: dict):
        super().undo_changes(gui_element_settings)
        # TODO: handle extension point remove


class CallgraphPathHighlightTraceElement(BaseTraceElement):
    """
        Trace element which highlights a path out of edges.
    """

    def __init__(self):
        super().__init__()
        self.path = PriorityQueue()
        self.edge_index = 0

    def add_edge(self, edge, callgraph, color=trace_lib.Color.RED):
        self.path.put((self.index, callgraph.ep.callsite_name[edge]),
                      block=False)
        self.edge_index += 1
        self.color = color

    def apply_changes(self, context: TraceContext):
        try:
            while not self.path.empty():
                current_edge = self.path.get(block=False)[1]
                edge = context.callgraph.get_edge_for_callsite_name(
                    current_edge)
                self.extension_points.add(
                    context.callgraph.vp.function_name[edge.source()])
                self.extension_points.add(
                    context.callgraph.vp.function_name[edge.target()])
                self.gui_element_settings[current_edge] = CallgraphEdgeSetting(
                    current_edge,
                    highlighting=True,
                    highlighting_color=self.color)
        except Exception as e:
            print(e)
            print(traceback.format_exc())

    def print_debug(self, context: TraceContext):
        print(f"\n\nPrint Path {self.path} ")

        tmp = []

        while not self.path.empty():
            element = self.path.get(block=False)
            tmp.append(element)
            current_edge = element[1]
            edge = context.callgraph.get_edge_for_callsite_name(current_edge)
            print(f" {context.callgraph.vp.function_name[edge.source()]} "
                  f"-> {context.callgraph.vp.function_name[edge.target()]}")

        for e in tmp:
            self.path.put(e, block=False)


class ResetPartialChangesTraceElement(BaseTraceElement):
    """
        Element to reset partial changes.
        Undoes all containing trace elements.
    """

    def __init__(self, elements):
        super().__init__()
        self.elements = elements

    def undo_changes(self, gui_element_settings: dict):
        """Calls undo_changes() on all trace elements in elements."""
        for element in self.elements:
            element.undo_changes(gui_element_settings)


class ResetChangesTraceElement(BaseTraceElement):
    """
        Trace element which is used to tell the trace handle to reset the current changes.
    """

    def __init__(self):
        super().__init__()
