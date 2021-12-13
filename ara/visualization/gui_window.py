from PySide6.QtWidgets import QApplication, QPushButton, QHBoxLayout, QVBoxLayout, QGraphicsView, QLabel

from PySide6.QtCore import Signal
from PySide6.QtCore import Slot

from PySide6.QtGui import QColor, QPainter, Qt
from PySide6.QtGui import QColorConstants

import graph_tool

from .graph_scene import *
from .graphical_elements import GraphicsObject, Subgraph, AbbNode
from .layouter import Layouter
from .util import GraphTypes
from .widgets.buttons import SelectionButton


def get_colour(colour):
    """
        Converts the Colour String given by graphviz to a usable
        colour object.
        The String could contain colour names as well as a rgb
        string in the format of #FFFFFF.
    """
    if colour == "blue":
        return QColorConstants.Blue
    elif colour == "green":
        return QColorConstants.Green
    elif colour == "red":
        return QColorConstants.Red
    elif colour == "black":
        return QColorConstants.Black
    else:
        rs = "0x" + colour[1:3]
        gs = "0x" + colour[3:5]
        bs = "0x" + colour[5:7]
        r = int(rs, base=16)
        g = int(gs, base=16)
        b = int(bs, base=16)
        return QColor.fromRgb(r, g, b)



class GuiWindow(QWidget):
    sigGuiWorkFinished = Signal()
    sigFinshed = Signal()

    sigUpdateDone = Signal()

    # b_start_pressed
    # b_step_pressed



    def __init__(self, parent, application: QApplication = None, araWorker=None, *args, **kwargs, ):
        super().__init__(parent, *args, **kwargs)
        self.araWorker = araWorker

        self.layouter = Layouter(entry_point="main")

        self.app = application

        self._func = {}
        self._nodes = {}
        self._edges = {}

        self.graph_scene = None
        self.graph_view = None

        self.b_start = QPushButton("Initialize Ara")
        self.b_step = QPushButton("Next Step")

        self.w_buttons = None
        self.w_center = None
        self.w_right = None
        self.w_graph_selection = None

        self.l_buttons = None
        self.l_window = None
        self.l_center = None
        self.l_right = None
        self.l_graph_selection = None

        self.v_graph_type = GraphTypes.ABB

        self.proxies = []

    @Slot()
    def enable_start_button(self):
        self.b_start.setEnabled(True)

    @Slot()
    def enable_step_button(self):
        self.b_step.setEnabled(True)

    @Slot()
    def disable_start_button(self):
        self.b_start.setDisabled(True)

    @Slot()
    def disable_step_button(self):
        self.b_step.setDisabled(True)

    @Slot(bool)
    def switch_step_button(self, b):
        if b:
            self.b_step.setEnabled(True)
        else:
            self.b_step.setDisabled(True)

    @Slot()
    def init(self):
        self.l_window = QHBoxLayout(self)

        # Widget Setup
        self.w_center = QWidget()
        self.w_buttons = QWidget()
        self.w_right = QWidget()
        self.w_graph_selection = QWidget()

        # Layout Setup
        self.l_center = QVBoxLayout(self.w_center)
        self.l_buttons = QHBoxLayout(self.w_buttons)
        self.l_right = QVBoxLayout(self.w_right)
        self.l_graph_selection = QHBoxLayout(self.w_graph_selection)

        # Graph View
        self.graph_scene = GraphScene()
        self.graph_view = QGraphicsView(self.graph_scene)
        self.graph_view.setRenderHint(QPainter.Antialiasing)

        self.b_step.setDisabled(True)

        # Right Setup
        self.l_right.setAlignment(Qt.AlignTop)
        self.w_right.setMinimumSize(200, 500)
        self.w_right.setMaximumSize(200, 1000)

        # Button Setup
        self.l_buttons.addWidget(self.b_start)
        self.l_buttons.addWidget(self.b_step)

        # Center setup
        self.l_center.addWidget(self.w_graph_selection)
        self.l_center.addWidget(self.graph_view)
        self.l_center.addWidget(self.w_buttons)

        for e in GraphTypes:
            button = SelectionButton(e.value, e)
            button.sig_clicked.connect(self.set_graph_type)
            self.l_graph_selection.addWidget(button)

        # Window Setup
        self.l_window.addWidget(self.w_right)
        self.l_window.addWidget(self.w_center)

        self.resize(1200, 800)
        self.show()

    @Slot(bool)
    def update(self, steps_available):
        self.children().clear()

        if not steps_available:
            self.b_step.setDisabled(True)

        self.graph_scene.clear_rec()

        self.layouter.layout(self.v_graph_type)
        gui_data = self.layouter.get_data(self.v_graph_type)

        #print(self.layouter.cfg_view)

        for e in gui_data:
            if isinstance(e, GraphicsObject):
                proxy = self.graph_scene.addWidget(e)
                if isinstance(e, Subgraph):
                    proxy.setZValue(0)
                if isinstance(e, AbbNode):
                    proxy.setZValue(2)
            else:
                self.graph_scene.addItem(e)
                e.setZValue(3)

        self.graph_view.update()
        self.sigFinshed.emit()

    @Slot(list)
    def update_right(self, l:list):

        while self.l_right.count():
            widget = self.l_right.itemAt(0).widget()
            self.l_right.removeWidget(widget)
            widget.deleteLater()

        for item in l[::-1]:
            label = QLabel()
            label.setText(item.name)
            self.l_right.addWidget(label)

    @Slot(graph_tool.Graph, name="init_graph")
    def init_graph(self, g):
        self.layouter.set_graph(g)

    @Slot(GraphTypes)
    def set_graph_type(self, s):
        self.v_graph_type = s
        self.update(True)
