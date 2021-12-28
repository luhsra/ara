import time

from PySide6.QtCore import Slot, Qt, QThread, Signal, QObject, QEvent
from PySide6.QtGui import QWheelEvent, QMouseEvent, QDragMoveEvent
from PySide6.QtWidgets import QGraphicsView, QGraphicsScene, QGraphicsProxyWidget, QWidget

from ara.visualization.layouter import Layouter
from ara.visualization.signal import ara_signal
from ara.visualization.signal.gui_signal import IBaseWidgetSignaling
from ara.visualization.signal.signal_combiner import SignalCombiner
from ara.visualization.util import GraphTypes
from ara.visualization.widgets.graph_elements import GraphicsObject, Subgraph, AbbNode, CallGraphNode


class GraphScene(QGraphicsScene):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def _del_widget(self, w: QWidget):
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
    sig_layout_start = Signal(GraphTypes, list, bool)

    sig_work_done = Signal(str)

    entry_points = ["main"]

    callgraph_expansion_points = ["main"]

    def __init__(self, graph_type: GraphTypes, signal_combiner: SignalCombiner):
        super().__init__()
        self.signal_combiner = signal_combiner

        self.sig_work_done.connect(self.signal_combiner.receive)

        self.layouter = Layouter()
        self.layouter_thread = QThread()

        self.layouter.moveToThread(self.layouter_thread)

        self.setScene(GraphScene())
        self.graph_type = graph_type
        self.setup_signals()

        self.dragging = False
        self.start_pos = None
        self.setDragMode(QGraphicsView.DragMode.ScrollHandDrag)

        self.setVerticalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        self.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)

        self.setViewportUpdateMode(QGraphicsView.FullViewportUpdate)

        signal_combiner.register_sender(self.graph_type.value)

        self.layouter_thread.start()

    def setup_signals(self):
        ara_signal.SIGNAL_MANAGER.sig_step_done.connect(self.start_update)
        self.sig_layout_start.connect(self.layouter.layout)
        self.layouter.sig_layout_done.connect(self.update_view)

    def wheelEvent(self, event: QWheelEvent) -> None:
        if event.angleDelta().y() > 0:
            self.scale(1.1, 1.1)
        else:
            self.scale(0.9, 0.9)

    @Slot()
    def start_update(self):
        if not self.isVisible():
            return

        if self.graph_type == GraphTypes.CALLGRAPH:
            self.sig_layout_start.emit(self.graph_type, self.callgraph_expansion_points, False)
        else:
            self.sig_layout_start.emit(self.graph_type, self.entry_points, False)

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

                self.handle_node_add(e)
            else:
                # Should only be edges
                self.scene().addItem(e)
                e.setZValue(3)
        print(f"Updating {self.graph_type}")
        self.sig_work_done.emit(self.graph_type.value)
        self.update()

    def handle_node_add(self, node):
        pass


class CallGraphView(BaseGraphView):

    def __init__(self, signal_combiner):
        super().__init__(GraphTypes.CALLGRAPH, signal_combiner)

    def handle_node_add(self, node):
        if isinstance(node, CallGraphNode):
            node.sig_selected.connect(self.selection_added)
            node.sig_unselected.connect(self.selection_removed)
            node.sig_adjacency_selected.connect(self.adjacency_expansion)
            node.sig_expansion_unselected.connect(self.expansion_retraction)

            if self.callgraph_expansion_points.__contains__(node.data.attr["label"]):
                node.widget.setProperty("expansion", "true")
                node.expansion = True
                node.reload_stylesheet()

            if self.entry_points.__contains__(node.data.attr["label"]):
                node.widget.setProperty("selected", "true")
                node.selected = True
                node.reload_stylesheet()

    @Slot()
    def update_view(self):
        super().update_view()

    @Slot(str)
    def adjacency_expansion(self, name):
        self.callgraph_expansion_points.append(name)
        self.start_update()

    @Slot(str)
    def expansion_retraction(self, name):
        if len(self.callgraph_expansion_points) == 1:
            return
        self.callgraph_expansion_points.remove(name)
        self.start_update()

    @Slot(str)
    def selection_added(self, name):
        self.entry_points.append(name)

    @Slot(str)
    def selection_removed(self, name):
        self.entry_points.remove(name)

class CFGView(BaseGraphView):
    def __init__(self, signal_combiner):
        super().__init__(GraphTypes.ABB, signal_combiner)


class InstanceGraphView(BaseGraphView):
    def __init__(self, signal_combiner):
        super().__init__(GraphTypes.INSTANCE, signal_combiner)
