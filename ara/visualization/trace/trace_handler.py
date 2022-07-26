import traceback

from PySide6.QtCore import QObject, Slot, Signal

from ara.visualization import ara_manager
from ara.visualization.signal import ara_signal
from ara.visualization.trace.trace_components import LogTraceElement, TraceContext, ResetChangesTraceElement
from ara.visualization.trace.trace_type import AlgorithmTrace


class TraceHandler(QObject):
    """
        This class processes a trace which has been generated by a step.
    """

    sig_extension_points_discovered = Signal(set)
    sig_extension_points_reset = Signal()

    def __init__(self):
        super().__init__()

        self.trace:AlgorithmTrace = None

        self.context = None

        self.gui_element_settings = {}

    @Slot()
    def init(self):
        try:
            self.trace = ara_manager.INSTANCE.get_trace()
            self.context = TraceContext(
                self.trace.callgraph,
                self.trace.cfg,
                self.trace.instances,
                self.trace.svfg
            )
            self.trace_amount = self.trace.get_amount_of_traces()
            self.trace_id = 0

        except Exception as e:
            print(e)
            print(traceback.format_exc())

    def _print_trace_log(self, element: LogTraceElement):
        print(f"--- Display Trace {self.trace_id + 1} of {self.trace_amount} ---")
        # print log line of trace to terminal:
        if element.log_line != None:
            print(element.log_line, end='')

    @Slot()
    def step(self):
        """
            Process a trace element.
        """
        try:
            current_element = self.trace.get_next_element()
            self._print_trace_log(current_element)
            current_element = current_element.trace_elem
            if current_element != None:
                if isinstance(current_element, ResetChangesTraceElement):
                    self.gui_element_settings.clear()
                    self.sig_extension_points_reset.emit()
                else:
                    current_element.apply_changes(self.context)

                    self.gui_element_settings.update(current_element.gui_element_settings)
                    self.sig_extension_points_discovered.emit(current_element.extension_points)
        except Exception as e:
            print(e)
            print(traceback.format_exc())

        self.trace_id += 1
        ara_signal.SIGNAL_MANAGER.sig_step_done.emit(self.trace.has_next_element(), False)

    def get_gui_element_settings(self):
        return self.gui_element_settings

    def finish(self):
        pass

    @Slot()
    def reset(self):
        self.gui_element_settings.clear()


INSTANCE = TraceHandler()
