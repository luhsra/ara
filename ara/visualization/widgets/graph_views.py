from PySide6.QtCore import Slot, Qt
from PySide6.QtWidgets import QGraphicsView, QGraphicsScene, QGraphicsProxyWidget, QWidget

from ara.visualization.layouter import Layouter
from ara.visualization.signal import ara_signal
from ara.visualization.signal.gui_signal import IBaseWidgetSignaling
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


class BaseGraphView(QGraphicsView, IBaseWidgetSignaling):
    layouter = Layouter()

    def __init__(self, type:GraphTypes):
        super().__init__()
        self.setScene(GraphScene())
        self.type = type
        self.setup_signals()

        self.setDragMode(QGraphicsView.DragMode.ScrollHandDrag)
        self.setViewportUpdateMode(QGraphicsView.FullViewportUpdate)

    def setup_signals(self):
        ara_signal.SIGNAL_MANAGER.sig_step_done.connect(self.update_view)

    @Slot()
    def update_view(self):
        if not self.isVisible():
            return

        self.scene().clear_rec()

        self.layouter.layout(self.type)
        gui_data = self.layouter.get_data(self.type)

        for e in gui_data:
            if isinstance(e, GraphicsObject):
                proxy = self.scene().addWidget(e)
                if isinstance(e, Subgraph):
                    proxy.setZValue(0)
                if isinstance(e, AbbNode):
                    proxy.setZValue(2)
            else:
                self.scene().addItem(e)
                e.setZValue(3)

        self.update()


class CallGraphView(BaseGraphView):

    def __init__(self):
        super().__init__(GraphTypes.CALLGRAPH)


class CFGView(BaseGraphView):
    def __init__(self):
        super().__init__(GraphTypes.ABB)


class InstanceGraphView(BaseGraphView):
    def __init__(self):
        super().__init__(GraphTypes.INSTANCE)