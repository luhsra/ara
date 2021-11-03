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
    else:
        rs = "0x" + colour[1:3]
        gs = "0x" + colour[3:5]
        bs = "0x" + colour[5:7]
        r = int(rs, base=16)
        g = int(gs, base=16)
        b = int(bs, base=16)
        return QColor.fromRgb(r, g, b)


class GuiWorker(QObject):

    sigGuiWorkFinished = Signal()
    sigFinshed = Signal()

    def __init__(self, parent, application:QApplication=None, araWorker = None, *args, **kwargs, ):
        super().__init__(parent, *args, **kwargs)
        self.araWorker=araWorker
        self.layouter = Layouter(entry_point="main")
        self.app = application
        self._func = {}
        self._nodes = {}
        self._edges = {}

    def parseJson(self, jsonStr):
        # Debug Purpose
        if jsonStr is None:
            path = "cfg.json0"
            file = QFile(path)
            if not file.open(QIODevice.ReadOnly | QIODevice.Text):
                print("Could not open File")
                return

            jsonStr = file.readAll()
            file.close()

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
                self.graphScene.add_func(func)
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
                self.graphScene.add_node(node)

        for e in jsonDocument.object().get("edges"):

            pos = []
            label = ""
            labelPos = {"x": 0, "y": 0}

            if e.__contains__("label"):
                label = e["label"]
                labelPos["x"] = e["lp"].split(",")[0]
                labelPos["y"] = e["lp"].split(",")[1]

            rawEdges = e["pos"].split(",")
            del rawEdges[0] # The First Char inside the position string is an e, which has to be removed

            edges = []
            for re in rawEdges:
                for s in re.split(" "):
                    edges.append(float(s))

            for i in range(2, len(edges) - 1, 2):
                pos.append({"x":edges[i], "y":edges[i+1]})

            pos.append({"x":edges[0], "y":edges[1]})

            edge = DEdge(
                pos,
                label,
                get_colour(e["color"]),
                "solid",
                e["_gvid"],
                e["tail"],
                e["head"],
                labelPos
            )
            self.graphScene.add_edge(edge)

    @Slot()
    def run(self):
        self.graphScene = GraphScene()
        self.graphView = QGraphicsView(self.graphScene)
        self.graphView.resize(1200, 800)
        self.graphView.setRenderHint(QPainter.Antialiasing)
        self.graphView.show()

        #jsonStr = self.layouter.layout("test", self.app)
        #self.parseJson(jsonStr)
        #self.graphScene.updateScene()
        #self.graphScene.update()
        #self.graphView.update()

    @Slot(str, name="update")
    def update(self):
        jsonStr = self.layouter.layout("abbs", self.app)
        self.parseJson(jsonStr)
        self.graphScene.updateScene()
        self.graphScene.update()
        self.graphView.update()
        self.sigFinshed.emit()

    @Slot(graph_tool.Graph)
    def init_graph(self,g):
        self.layouter.set_graph(g)
        self.araWorker.setRReady()


class ARAWorker(QObject):

    sigDataUpdated = Signal()
    sigInitGraph = Signal(graph_tool.Graph)

    def __init__(self):
        super().__init__()
        self.ready = False

    @Slot()
    def run(self):
        #self.sigDataUpdated.emit()
        sys.argv.append("--visualization")
        _ara.main(araWorker = self)

    @Slot()
    def setReady(self):
        print("set Ready")
        self.ready = True


    def setRReady(self):
        print("set RReady")
        self.ready = True

    def isReady(self):
        if self.ready:
            self.ready = False
            return True
        return False


class Controller(QObject):

    sigStartGui = Signal()
    sigStartAra = Signal()

    def __init__(self, application:QApplication, *args, **kwargs):
        super().__init__(application, *args, **kwargs)
        self.araWorker = ARAWorker()
        self.guiWorker = GuiWorker(application, araWorker=self.araWorker)
        self.araThread = QThread(application)
        self.guiThread = QThread(None)

        self.araWorker.moveToThread(self.araThread)
        #self.guiWorker.moveToThread(self.guiThread)

        self.sigStartGui.connect(self.guiWorker.run)
        self.sigStartAra.connect(self.araWorker.run)

        self.araWorker.sigDataUpdated.connect(self.guiWorker.update)
        self.araWorker.sigInitGraph.connect(self.guiWorker.init_graph)

        self.guiWorker.sigFinshed.connect(self.araWorker.setReady)

        self.araThread.start()
        #self.guiThread.start()


def initGraph(g: graph_tool.Graph):
    controller.araWorker.sigInitGraph.emit(g)

application = QApplication([])

controller = Controller(application)

controller.sigStartAra.emit()
controller.sigStartGui.emit()

application.exec()

