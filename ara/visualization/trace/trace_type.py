from collections import deque

from ara.visualization.trace.trace_components import BaseTraceElement, LogTraceElement


class AlgorithmTrace:
    """
        The algorithm trace contains the element of a graph which should be modified by the gui.
    """

    def __init__(self, callgraph, cfg, instances, svfg):
        self.trace_elements = deque()
        self.callgraph = callgraph
        self.cfg = cfg
        self.instances = instances
        self.svfg = svfg

    def add_element(self, element:BaseTraceElement, log_message:str=None):
        self.trace_elements.append(LogTraceElement(element, log_message))

    def get_amount_of_traces(self):
        return len(self.trace_elements)

    def get_next_element(self) -> LogTraceElement:
        return self.trace_elements.popleft()

    def has_next_element(self) -> bool:
        return len(self.trace_elements) > 0

