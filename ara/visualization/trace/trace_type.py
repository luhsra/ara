from queue import PriorityQueue

from ara.visualization.trace.trace_components import BaseTraceElement


class AlgorithmTrace:
    """
        The algorithm trace contains the element of a graph which should be modified by the gui.
    """

    def __init__(self, callgraph, cfg, instances):
        # A priority queue is used to allow a peek at the next object which is not natively support by
        # the normal queue. It does this by taking the element out and adding it back with the same priority
        self.trace_elements = PriorityQueue()
        self.callgraph = callgraph
        self.cfg = cfg
        self.instances = instances

    def add_element(self, element:BaseTraceElement):
        self.trace_elements.put((element.index, element), block=False)


    def get_next_element(self) -> BaseTraceElement:
        return self.trace_elements.get(block=False)[1]

    def has_next_element(self) -> bool:
        return not self.trace_elements.empty()

