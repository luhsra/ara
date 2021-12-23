import time

from PySide6.QtCore import Slot, Qt, QThread, Signal, QObject
from PySide6.QtWidgets import QGraphicsView, QGraphicsScene, QGraphicsProxyWidget, QWidget

from ara.visualization.layouter import Layouter
from ara.visualization.signal import ara_signal
from ara.visualization.signal.gui_signal import IBaseWidgetSignaling
from ara.visualization.signal.signal_combiner import SignalCombiner
from ara.visualization.util import GraphTypes
from ara.visualization.widgets.graph_elements import GraphicsObject, Subgraph, AbbNode


class GraphScene(QGraphicsScene):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def _del_widget(self, w:QWidget):
        for c in w.children():
            self._del_widget(c)
            w.children().remove(c)

    def clear_rec(self):
        for i in self.items():
            if isinstance(i, QGraphicsProxyWidget):
                self._del_widget(i.widget())
                self.removeItem(i)
            else:
                self.removeItem(i)


class BaseGraphView(QGraphicsView):

    sig_layout_start = Signal(GraphTypes, bool)

    sig_work_done = Signal(str)

    def __init__(self, graph_type: GraphTypes, signal_combiner:SignalCombiner):
        super().__init__()
        self.signal_combiner = signal_combiner

        self.sig_work_done.connect(self.signal_combiner.receive)

        self.layouter = Layouter()
        self.layouter_thread = QThread()

        self.layouter.moveToThread(self.layouter_thread)

        self.setScene(GraphScene())
        self.graph_type = graph_type
        self.setup_signals()

        self.setDragMode(QGraphicsView.DragMode.ScrollHandDrag)
        self.setViewportUpdateMode(QGraphicsView.FullViewportUpdate)

        signal_combiner.register_sender(self.graph_type.value)

        self.layouter_thread.start()

    def setup_signals(self):
        ara_signal.SIGNAL_MANAGER.sig_step_done.connect(self.start_update)
        self.sig_layout_start.connect(self.layouter.layout)
        self.layouter.sig_layout_done.connect(self.update_view)

    @Slot()
    def start_update(self):
        if not self.isVisible():
            return

        self.sig_layout_start.emit(self.graph_type, False)

    @Slot()
    def update_view(self):
        print(f"Starting {self.graph_type}")
        gui_data = self.layouter.get_data(self.graph_type)

        if not self.isVisible():
            return

        if len(gui_data) == 0:
            print(f"sending {self.graph_type}")
            self.sig_work_done.emit(self.graph_type.value)
            return

        self.scene().clear_rec()

        for e in gui_data:
            if isinstance(e, GraphicsObject):
                proxy = self.scene().addWidget(e)
                if isinstance(e, Subgraph):
                    proxy.setZValue(0)
                if isinstance(e, AbbNode):
                    proxy.setZValue(2)
            else:
                # Should only be edges
                self.scene().addItem(e)
                e.setZValue(3)
        print(f"Updating {self.graph_type}")
        self.sig_work_done.emit(self.graph_type.value)
        self.update()


class CallGraphView(BaseGraphView):

    def __init__(self, signal_combiner):
        super().__init__(GraphTypes.CALLGRAPH, signal_combiner)


class CFGView(BaseGraphView):
    def __init__(self, signal_combiner):
        super().__init__(GraphTypes.ABB, signal_combiner)


class InstanceGraphView(BaseGraphView):
    def __init__(self, signal_combiner):
        super().__init__(GraphTypes.INSTANCE, signal_combiner)