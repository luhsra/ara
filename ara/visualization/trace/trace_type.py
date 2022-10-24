from collections import deque
from typing import List
from ara.visualization.util import SUPPORT_FOR_GUI

if SUPPORT_FOR_GUI:
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

        def add_element(self,
                        element: List[BaseTraceElement],
                        log_message: str = None):
            """Adds a new trace.
            
            element can be a single trace element or multiple trace elements in a list
            log_message will be printed on terminal while displaying the trace
            """
            self.trace_elements.append(LogTraceElement(element, log_message))

        def get_amount_of_traces(self):
            return len(self.trace_elements)

        def get_next_element(self) -> LogTraceElement:
            return self.trace_elements.popleft()

        def has_next_element(self) -> bool:
            return len(self.trace_elements) > 0

        def destroy(self):
            """Called after step is gone"""
            pass

else:
    # stub
    class AlgorithmTrace:
        def __init__(self, callgraph, cfg, instances, svfg):
            pass

        def add_element(self, element: any, log_message: str = None):
            pass

        def destroy(self):
            pass