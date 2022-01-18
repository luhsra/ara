import traceback
from itertools import chain

from PySide6.QtCore import QObject, Slot, Signal

from ara.visualization import ara_manager
from ara.visualization.signal import ara_signal
from ara.visualization.trace.trace_components import BaseTraceElement, TraceContext, ResetChangesTraceElement
from ara.visualization.trace.trace_type import AlgorithmTrace


class TraceHandler(QObject):

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
                self.trace.instances
            )

        except Exception as e:
            print(e)
            print(traceback.format_exc())

    @Slot()
    def step(self):
        print("Trace Step")
        try:
            current_element = self.trace.get_next_element()
            if isinstance(current_element, ResetChangesTraceElement):
                self.gui_element_settings.clear()
                self.sig_extension_points_reset.emit()
            else:
                #current_element.print_debug(self.context)
                current_element.apply_changes(self.context)

                self.gui_element_settings.update(current_element.gui_element_settings)
                self.sig_extension_points_discovered.emit(current_element.extension_points)
        except Exception as e:
            print(e)
            print(traceback.format_exc())

        ara_signal.SIGNAL_MANAGER.sig_step_done.emit(not self.trace.trace_elements.empty(), False)

    def get_gui_element_settings(self):
        return self.gui_element_settings

    def finish(self):
        pass

    @Slot()
    def reset(self):
        self.gui_element_settings.clear()


INSTANCE = TraceHandler()
