import sys
import time
from builtins import str
from time import sleep

from PySide6.QtWidgets import QApplication
from PySide6 import QtWidgets

from PySide6.QtCore import QJsonDocument
from PySide6.QtCore import QFile
from PySide6.QtCore import QIODevice
from PySide6.QtCore import Signal
from PySide6.QtCore import Slot

from PySide6.QtGui import QColor
from PySide6.QtGui import QColorConstants

import graph_tool
from matplotlib.cbook import contiguous_regions

import ara.ara as _ara
from .graph_scene import *
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

    def parse_json(self, jsonStr):
        # Debug Purpose
        #if jsonStr is None:
        #    path = "cfg.json0"
        #    file = QFile(path)
        #    if not file.open(QIODevice.ReadOnly | QIODevice.Text):
        #        print("Could not open File")
        #        return
#
        #    jsonStr = file.readAll()
        #    file.close()

        jsonDocument = QJsonDocument.fromJson(jsonStr)

        for o in jsonDocument.object().get("objects"):
            o: dict
            # Cluster
            if o.__contains__("bb"):  # bb = boundingBox, this is exclusive to cluster
                pos = o["bb"].split(",")
                lp = o["lp"].split(",")
                height = (float(pos[1]) - float(pos[3]))
                width = (float(pos[2]) - float(pos[0]))
                Dpos = {"x": float(pos[0]), "y": float(pos[3])}  # upper point of bounding box
                Lpos = {"x": float(lp[0]), "y": float(lp[1])}
                style = "solid"
                if o.__contains__("style"):
                    style = o["style"]

                colour = QColorConstants.Black
                if o.__contains__("color"):
                    colour = get_colour(o["color"])

                func = DFunc(
                    Dpos,
                    o["label"],
                    colour,
                    style,
                    o["_gvid"],
                    o["name"],
                    height,
                    width,
                    "box",
                    Lpos
                )
                self.graph_scene.add_func(func)
            else:
                pos = o["pos"].split(",")
                x = float(pos[0]) - 0.5 * float(
                    o["width"]) * 74  # 96 Width is in inches and has to be converted into pixel <.<
                y = float(pos[1]) - 0.5 * float(o["height"]) * 74
                Dpos = {"x": x, "y": y}
                Lpos = {"x": float(pos[0]), "y": float(pos[1])}

                style = "solid"
                if o.__contains__("style"):
                    style = o["style"]

                colour = QColorConstants.Black

                if o.__contains__("color"):
                    colour = get_colour(o["color"])

                node = DNode(
                    Dpos,
                    o["label"],
                    colour,
                    style,
                    o["_gvid"],
                    o["name"],
                    float(o["height"]) * 74,  # Should be 96 but that is a bit to large
                    float(o["width"]) * 74,
                    o["shape"],
                    Lpos
                )
                self.graph_scene.add_node(node)

        for e in jsonDocument.object().get("edges"):

            pos = []
            label = ""
            labelPos = {"x": 0, "y": 0}

            if e.__contains__("label"):
                label = e["label"]
                labelPos["x"] = e["lp"].split(",")[0]
                labelPos["y"] = e["lp"].split(",")[1]

            rawEdges = e["pos"].split(",")
            del rawEdges[0]  # The First Char inside the position string is an e, which has to be removed

            edges = []
            for re in rawEdges:
                for s in re.split(" "):
                    edges.append(float(s))

            for i in range(2, len(edges) - 1, 2):
                pos.append({"x": edges[i], "y": edges[i + 1]})

            pos.append({"x": edges[0], "y": edges[1]})

            colour = QColorConstants.Black
            if e.__contains__("color"):
                colour = get_colour(e["color"])

            edge = DEdge(
                pos,
                label,
                colour,
                "solid",
                e["_gvid"],
                e["tail"],
                e["head"],
                labelPos
            )
            self.graph_scene.add_edge(edge)

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
        print("update")

        if not steps_available:
            self.b_step.setDisabled(True)

        jsonStr = self.layouter.layout(self.v_graph_type, self.app)
        self.parse_json(jsonStr)
        self.graph_scene.updateScene()
        self.graph_scene.update()
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
