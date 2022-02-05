import time

from PySide6.QtCore import Slot, Qt, QThread, Signal, QObject
from PySide6.QtGui import QWheelEvent, QPainter
from PySide6.QtWidgets import QGraphicsView, QGraphicsScene, QGraphicsProxyWidget, QWidget

from ara.visualization.layouter import Layouter
from ara.visualization.signal import ara_signal
from ara.visualization.signal.signal_combiner import SignalCombiner
from ara.visualization.trace import trace_handler
from ara.visualization.util import GraphTypes, StepMode
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


class GraphViewContext(QObject):

    entry_points = set()

    callgraph_expansion_points = set()

    callgraph_soft_expansion_points = set()

    sig_update_graphview = Signal(GraphTypes)

    sig_expansion_point_updated = Signal(str)

    sig_entry_points_update = Signal(str)

    def __init__(self):
        self.entry_points.add("main")
        self.callgraph_expansion_points.add("main")
        super().__init__()

    def setup_signals(self):
        trace_handler.INSTANCE.sig_extension_points_discovered.connect(self.register_expansion_points)
        trace_handler.INSTANCE.sig_extension_points_reset.connect(self.reset_soft_expansion_points)

    @Slot(set, str)
    def register_expansion_points(self, points:set, source):
        self.callgraph_soft_expansion_points.update(points)
        self.sig_expansion_point_updated.emit( source)

    @Slot(set, str)
    def set_expansion_points(self, points, source):
        self.callgraph_expansion_points = points
        self.sig_expansion_point_updated.emit( source)

    @Slot(str, str)
    def register_expansion_point(self, point, source):
        self.callgraph_expansion_points.add(point)
        self.sig_expansion_point_updated.emit( source)

    @Slot(str, str)
    def remove_expansion_point(self, point, source):
        self.callgraph_expansion_points.remove(point)
        self.sig_expansion_point_updated.emit( source)

    @Slot(str, str)
    def register_entry_point(self, point, source):
        self.entry_points.add(point)
        self.sig_entry_points_update.emit(source)

    @Slot(str, str)
    def remove_entry_point(self, point, source):
        self.entry_points.remove(point)
        self.sig_entry_points_update.emit(source)

    @Slot(str, str)
    def switch_entry_point(self, point, source):
        if self.entry_points.__contains__(point):
            self.entry_points.remove(point)
        else:
            self.entry_points.add(point)
        self.sig_update_graphview.emit(GraphTypes.CALLGRAPH)
        self.sig_update_graphview.emit(GraphTypes.ABB)

    @Slot()
    def reset_soft_expansion_points(self):
        self.callgraph_soft_expansion_points.clear()
        self.sig_expansion_point_updated.emit("")

    def get_expansion_points(self):
        return self.callgraph_expansion_points | self.callgraph_soft_expansion_points


CONTEXT = GraphViewContext()


class BaseGraphView(QGraphicsView):
    sig_layout_start = Signal(GraphTypes, set, bool, StepMode)

    sig_work_done = Signal(str)

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

        self.setRenderHints(QPainter.Antialiasing)

        signal_combiner.register_sender(self.graph_type.value)

        self.mode = StepMode.DEFAULT

        self.layouter_thread.start()

    def setup_signals(self):
        ara_signal.SIGNAL_MANAGER.sig_step_done.connect(self.start_update)
        self.sig_layout_start.connect(self.layouter.layout)
        self.layouter.sig_layout_done.connect(self.update_view)
        CONTEXT.sig_update_graphview.connect(self._internal_update)

    def wheelEvent(self, event: QWheelEvent) -> None:
        if event.angleDelta().y() > 0:
            self.scale(1.1, 1.1)
        else:
            self.scale(0.9, 0.9)

    @Slot(GraphTypes)
    def _internal_update(self, type):
        if type == self.graph_type:
            self.start_update(False, False)

    @Slot(bool, bool)
    def start_update(self, steps_available, trace_available):
        print("Start Update")
        if not self.isVisible():
            return

        if self.graph_type == GraphTypes.CALLGRAPH:
            self.sig_layout_start.emit(self.graph_type, CONTEXT.get_expansion_points(), False, self.mode)
        else:
            self.sig_layout_start.emit(self.graph_type, CONTEXT.entry_points, False, self.mode)

    @Slot()
    def update_view(self):
        print(f"Starting {self.graph_type}")
        self.scene().clear_rec()

        gui_data = self.layouter.get_data(self.graph_type)

        if not self.isVisible():
            return

        if len(gui_data) == 0:
            print(f"sending {self.graph_type}")
            self.sig_work_done.emit(self.graph_type.value)
            return

        for obj in gui_data:
            if isinstance(obj, GraphicsObject):
                proxy = self.scene().addWidget(obj)
                if isinstance(obj, Subgraph):
                    proxy.setZValue(0)
                if isinstance(obj, AbbNode):
                    proxy.setZValue(2)

                self.handle_node_add(obj)
            else:
                # Should only be edges
                self.scene().addItem(obj)
                obj.setZValue(3)
                self.handle_edge_add(obj)

        print(f"Updating {self.graph_type}")
        self.sig_work_done.emit(self.graph_type.value)
        #self.centerOn(0,0)
        self.update()

    @Slot(StepMode)
    def set_mode(self, mode):
        self.mode = mode

    # Abstract
    def handle_node_add(self, node):
        pass

    def handle_edge_add(self, edge):
        pass


class CallGraphView(BaseGraphView):

    sig_entry_point_selected = Signal(set, str)

    sig_entry_point_deselected = Signal(set, str)

    sig_expansion_point_selected = Signal(str, str)

    sig_expansion_points_deselected = Signal(str, str)

    def __init__(self, signal_combiner):
        super().__init__(GraphTypes.CALLGRAPH, signal_combiner)

    def handle_node_add(self, node):
        if isinstance(node, CallGraphNode):
            node.sig_selected.connect(self.selection_added)
            node.sig_unselected.connect(self.selection_removed)
            node.sig_adjacency_selected.connect(self.adjacency_expansion)
            node.sig_expansion_unselected.connect(self.expansion_retraction)

            if trace_handler.INSTANCE.gui_element_settings.__contains__(node.id):
                print(f"Applying settings for {node.id}")
                print(f"{trace_handler.INSTANCE.gui_element_settings}")
                trace_handler.INSTANCE.gui_element_settings[node.id].apply(node)

            if CONTEXT.get_expansion_points().__contains__(node.data.attr["label"]):
                node.widget.setProperty("expansion", "true")
                node.expansion = True
                node.reload_stylesheet()

            if CONTEXT.entry_points.__contains__(node.data.attr["label"]):
                node.widget.setProperty("selected", "true")
                node.selected = True
                node.reload_stylesheet()

    def handle_edge_add(self, edge):
        if trace_handler.INSTANCE.gui_element_settings.__contains__(edge.id):
            print(f"Edge {edge} -- {edge.id}")
            trace_handler.INSTANCE.gui_element_settings[edge.id].apply(edge)

    def setup_signals(self):
        super().setup_signals()
        trace_handler.INSTANCE.sig_extension_points_discovered.connect(self.expansion_points_discovered)
        trace_handler.INSTANCE.sig_extension_points_reset.connect(self.expansion_points_reset)

        self.sig_entry_point_selected.connect(CONTEXT.register_entry_point)
        self.sig_entry_point_deselected.connect(CONTEXT.remove_entry_point)

        self.sig_expansion_point_selected.connect(CONTEXT.register_expansion_point)
        self.sig_expansion_points_deselected.connect(CONTEXT.remove_expansion_point)

        CONTEXT.sig_expansion_point_updated.connect(self.handle_expansion_points_update)

    @Slot(str)
    def handle_expansion_points_update(self, source):
        print(f"\t Start Updating Callgraph with source: {source}")
        if source == "CallGraph":
            return
        print(f"\t Updating Callgraph - {source}")
        self.start_update(False, False)

    @Slot()
    def update_view(self):
        super().update_view()

    @Slot(str)
    def adjacency_expansion(self, name):
        self.sig_expansion_point_selected.emit(name, "CallGraph")
        self.start_update(False, False)

    @Slot(str)
    def expansion_retraction(self, name):
        if len(CONTEXT.callgraph_expansion_points) == 1:
            return
        self.sig_expansion_points_deselected.emit(name, "CallGraph")
        self.start_update(False, False)

    @Slot(set)
    def expansion_points_discovered(self, points):
        CONTEXT.callgraph_soft_expansion_points.update(points)
        #self._CONTEXT.sig_update_graphview.emit(GraphTypes.ABB)

    @Slot()
    def expansion_points_reset(self):
        CONTEXT.callgraph_soft_expansion_points.clear()

    @Slot(str)
    def selection_added(self, name):
        self.sig_entry_point_selected.emit(name, "CallGraph")
        CONTEXT.sig_update_graphview.emit(GraphTypes.ABB)

    @Slot(str)
    def selection_removed(self, name):
        self.sig_entry_point_deselected.emit(name, "CallGraph")
        CONTEXT.sig_update_graphview.emit(GraphTypes.ABB)


class CFGView(BaseGraphView):
    def __init__(self, signal_combiner):
        super().__init__(GraphTypes.ABB, signal_combiner)


class InstanceGraphView(BaseGraphView):
    def __init__(self, signal_combiner):
        super().__init__(GraphTypes.INSTANCE, signal_combiner)
