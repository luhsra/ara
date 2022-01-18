from queue import Queue, PriorityQueue

import graph_tool

from ara.graph import Callgraph
from ara.visualization.trace.trace_components import BaseTraceElement, ResetPartialChangesTraceElement


class AlgorithmTrace:

    def __init__(self, callgraph, cfg, instances):
        self.trace_elements = PriorityQueue()
        self.callgraph = callgraph
        self.cfg = cfg
        self.instances = instances

    def add_element(self, element:BaseTraceElement):
        self.trace_elements.put((element.index, element), block=False)

    def add_removable_element(self, element:BaseTraceElement):
        self.trace_elements.put((element.index, element), block=False)
        remove = ResetPartialChangesTraceElement(element)
        self.trace_elements.put((remove.index, remove), block=False)

    def get_next_element(self) -> BaseTraceElement:
        return self.trace_elements.get(block=False)[1]

    def has_next_element(self) -> bool:
        return not self.trace_elements.empty()

