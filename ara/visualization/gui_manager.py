from PySide6.QtWidgets import QApplication
from PySide6 import QtWidgets

from PySide6.QtCore import QJsonDocument
from PySide6.QtCore import QFile
from PySide6.QtCore import QIODevice

from PySide6.QtGui import QColorConstants

from .graphics_graph_view import *
from .layouter import Layouter

def update(jsonStr):
    if graphScene is None:
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

    print(jsonDocument.isNull())


    for o in jsonDocument.object().get("objects"):
        o:dict
        # Cluster
        if o.__contains__("bb"): # bb = boundingBox, this is exclusive to cluster
            pos = o["bb"].split(",")
            lp = o["lp"].split(",")
            height = (float(pos[1]) - float(pos[3]))
            width = (float(pos[2]) - float(pos[0]))
            Dpos = {"x": float(pos[0]), "y": float(pos[3])} # upper point of bounding box
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
            graphScene.add_func(func)
        else:
            pos = o["pos"].split(",")
            x = float(pos[0]) - 0.5 * float(o["width"]) * 80 # 96 Width is in inches and has to be converted into pixel <.<
            y = float(pos[1]) - 0.5 * float(o["height"]) * 80
            Dpos = {"x": x, "y": y}
            Lpos = {"x": float(pos[0]), "y": float(pos[1])}

            node = DNode(
                Dpos,
                o["label"],
                QColorConstants.Black,
                o["_gvid"],
                o["name"],
                float(o["height"]) * 80, # Should be 96 but that is a bit to large
                float(o["width"]) * 80,
                o["shape"],
                Lpos
            )
            graphScene.add_node(node)



def init_gui_manager(g):
    layouter.set_graph(g)



layouter = Layouter()
app = QtWidgets.QApplication([])

graphScene = GraphScene()

import os

print(os.getcwd())


out = layouter.layout("test", app)

#print(out)

graphView = QGraphicsView(graphScene)
graphView.resize(1200, 800)


update(out)
graphScene.updateScene()
graphView.show()

app.exec()
