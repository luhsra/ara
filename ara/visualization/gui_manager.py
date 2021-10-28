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

from PySide6.QtGui import QColorConstants

import graph_tool
from matplotlib.cbook import contiguous_regions

import ara.ara as _ara
from .graphics_graph_view import *
from .layouter import Layouter

class GuiWorker(QObject):

    sigGuiWorkFinished = Signal()
    sigFinshed = Signal()

    def __init__(self, parent, application:QApplication=None, araWorker = None, *args, **kwargs, ):
        super().__init__(parent, *args, **kwargs)
        self.araWorker=araWorker
        self.layouter = Layouter(entry_point="main")
        self.app = application

    def parseJson(self, jsonStr):
        if self.graphScene is None:
            return

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
                func = DFunc(
                    Dpos,
                    o["label"],
                    QColorConstants.Black,
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
                    o["width"]) * 80  # 96 Width is in inches and has to be converted into pixel <.<
                y = float(pos[1]) - 0.5 * float(o["height"]) * 80
                Dpos = {"x": x, "y": y}
                Lpos = {"x": float(pos[0]), "y": float(pos[1])}

                node = DNode(
                    Dpos,
                    o["label"],
                    QColorConstants.Black,
                    o["_gvid"],
                    o["name"],
                    float(o["height"]) * 80,  # Should be 96 but that is a bit to large
                    float(o["width"]) * 80,
                    o["shape"],
                    Lpos
                )
                self.graphScene.add_node(node)

    @Slot(name="run")
    def run(self):
        self.graphScene = GraphScene()
        self.graphView = QGraphicsView(self.graphScene)
        self.graphView.resize(1200, 800)
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

