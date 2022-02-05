from queue import PriorityQueue

import traceback

from ara.visualization.trace import trace_lib
from ara.visualization.widgets.graph_elements import CallgraphNodeSetting, CallgraphEdgeSetting


class TraceContext:

    def __init__(self, callgraph, cfg, instances):
        self._current_node = None
        self._current_edge = None

        self.cfg = cfg
        self.callgraph = callgraph
        self.instances = instances

    def set_current_node(self, node):
        self._current_node = node

    def get_current_node(self):
        return self._current_node

    def set_current_edge(self, edge):
        self._current_edge = edge

    def get_current_edge(self):
        return self._current_edge


class IndexFactory:

    def __init__(self):
        self.value = 0

    def get_value_and_increment(self):
        temp = self.value
        self.value += 1
        return temp


class BaseTraceElement:

    global_index  = IndexFactory()

    def __init__(self):
        self.index = self.global_index.get_value_and_increment()
        self.gui_element_settings = dict()
        self.extension_points = set()

    def get_graphical_handling(self):
        return self.gui_element_settings

    def get_extension_points(self):
        return self.extension_points

    def apply_changes(self, context:TraceContext):
        pass

    def print_debug(self, context:TraceContext):
        pass

    def __gt__(self, other):
        if not isinstance(other, BaseTraceElement):
            return False

        return self.index > other.index

    def __lt__(self, other):
        if not isinstance(other, BaseTraceElement):
            return False

        return self.index < other.index


class CallgraphNodeHighlightTraceElement(BaseTraceElement):

    def __init__(self, node, callgraph, color=trace_lib.Color.RED):
        super().__init__()
        self.node_id = callgraph.vp.function_name[node]
        self.color = color

    def apply_changes(self, context:TraceContext):
        try:
            self.gui_element_settings[self.node_id] = CallgraphNodeSetting(self.node_id,
                                                                           highlighting=True,
                                                                           highlight_color=self.color)
            self.extension_points.add(self.node_id)
        except Exception as e:
            print(e)
            print(traceback.format_exc())

    def print_debug(self, context):
        print(f"Highlighting node: {self.node_id}")


class CallgraphPathHighlightTraceElement(BaseTraceElement):

    def __init__(self):
        super().__init__()
        self.path = PriorityQueue()
        self.edge_index = 0

    def add_edge(self, edge, callgraph, color=trace_lib.Color.RED):
        self.path.put((self.index, callgraph.ep.callsite_name[edge]),block=False)
        self.edge_index += 1
        self.color = color

    def apply_changes(self, context:TraceContext):
        try:
            while not self.path.empty():
                current_edge = self.path.get(block=False)[1]
                edge = context.callgraph.get_edge_for_callsite_name(current_edge)
                self.extension_points.add(context.callgraph.vp.function_name[edge.source()])
                self.extension_points.add(context.callgraph.vp.function_name[edge.target()])
                self.gui_element_settings[current_edge] = CallgraphEdgeSetting(current_edge, highlighting=True,
                                                                               highlighting_color=self.color)
        except Exception as e:
            print(e)
            print(traceback.format_exc())

    def print_debug(self, context:TraceContext):
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

    def __init__(self, element):
        super().__init__()
        self.element = element


class ResetChangesTraceElement(BaseTraceElement):

    def __init__(self):
        super().__init__()
