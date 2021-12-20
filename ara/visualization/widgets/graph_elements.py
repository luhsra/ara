from math import sqrt, cos, sin

from PySide6.QtCore import Qt
from PySide6.QtUiTools import QUiLoader
from PySide6.QtWidgets import QGraphicsPathItem, QWidget, QVBoxLayout
from PySide6.QtGui import QPen, QPainterPath
from pygraphviz import Node, Edge
from pygraphviz import AGraph

from ara.graph import CFType

DPI_LEVEL = 72 # Todo move to a more fitting file

class GraphicsObject(QWidget):

    loader = QUiLoader()

    def __init__(self, path_to_ui_file):
        super().__init__()
        self.widget = GraphicsObject.loader.load(path_to_ui_file)
        layout = QVBoxLayout(self)
        layout.setContentsMargins(0,0,0,0)
        self.layout().addWidget(self.widget)


class AbstractNode(GraphicsObject):
    def __init__(self, node:Node, ui_path="../resources/node.ui"):
        super().__init__(ui_path)

        self.data = node
        pos = self.data.attr["pos"].split(",")

        width = float(self.data.attr["width"]) * DPI_LEVEL
        height = float(self.data.attr["height"]) * DPI_LEVEL

        x = float(pos[0]) - 0.5 * width
        y = -float(pos[1]) - 0.5 * height

        self.setGeometry(int(x), int(y), int(width), int(height))

class AbbNode(AbstractNode):

    subtypes = {"1" : "syscall", "2" : "call", "4" : "comp" }

    def __init__(self, node:Node):
        super().__init__(node, "../resources/node.ui")

        self.widget.label_text.setText(self.data.attr["label"])
        self.widget.subtype_text.setText(str(self.subtypes[self.data.attr["subtype"]]))
        self.widget.type_text.setText(str(self.data.attr["type"]))


class CallGraphNode(AbstractNode):
    def __init__(self, node:Node):
        super().__init__(node, "../resources/callgraph_node.ui")
        self.widget.label_text.setText(str(self.data.attr["label"]))


class InstanceNode(AbstractNode):
    def __init__(self, node:Node):
        super().__init__(node, "../resources/instance_node.ui")
        self.widget.label_text.setText(str(self.data.attr["label"]))
        self.widget.sublabel_text.setText(str(self.data.attr["sublabel"]))


class Subgraph(GraphicsObject):
    def __init__(self, subgraph:AGraph):
        super().__init__("../resources/subgraph.ui")
        self.data = subgraph

        x_min = 100000000
        x_max = 0

        y_min = 100000000

        y_max = 0

        for n in self.data.nodes():
            pos = n.attr["pos"].split(",")
            width = float(n.attr["width"]) * DPI_LEVEL
            height = float(n.attr["height"]) * DPI_LEVEL

            x = float(pos[0]) - 0.5 * width
            y = float(pos[1]) + 0.5 * height

            x_min = x if x < x_min else x_min
            y_min = y - height if y - height < y_min else y_min
            x_max = (x + width) if (x + width) > x_max else x_max
            y_max = y if y > y_max else y_max

        height = y_max - y_min + 50
        width = x_max - x_min + 20

        x = x_min - 10
        y = - (y_max + 40 )

        self.widget.subgraph_label_text.setText(
            self.data.graph_attr["label"])  # Todo Export children Names into a lib class

        self.setGeometry(x, y, width, height)


class GraphEdge(QGraphicsPathItem):
    def __init__(self, edge: Edge):
        super().__init__()

        self.data = edge
        self.path = QPainterPath()

        pos = []
        edges = []

        rawEdges = self.data.attr["pos"].split(",")
        del rawEdges[0]  # The First Char inside the position string is an e, which has to be removed

        for re in rawEdges:
            for s in re.split(" "):
                edges.append(float(s))

        # This ignores the first edge, because this is the end point of the edge
        for i in range(2, len(edges) - 1, 2):
            pos.append({"x": edges[i], "y": edges[i + 1]})

        # Add the end point
        pos.append({"x": edges[0], "y": edges[1]})

        self.path.moveTo(pos[0]["x"], - pos[0]["y"])
        i = 0
        for i in range(1, len(pos) - 1, 3):
            self.path.cubicTo(pos[i]["x"], - pos[i]["y"],
                         pos[i + 1]["x"], - pos[i + 1]["y"],
                         pos[i + 2]["x"], - pos[i + 2]["y"])

        self.setPath(self.path)

        pen_color = Qt.black
        if self.data.attr.__contains__("edge_type"):
            if self.data.attr["edge_type"] == str(CFType.lcf.value):
                pen_color = Qt.blue
            elif self.data.attr["edge_type"] == str(CFType.icf.value):
                pen_color = Qt.red

        self.setPen(QPen(pen_color, 2, Qt.SolidLine, Qt.RoundCap, Qt.RoundJoin))


    def draw_arrow_tip(self, x1, y1, x2, y2, theta):
        L1 = sqrt(pow(x2-x1,2)+pow(y2-y1,2))
        L2 = 1
        old_x2 = x2
        old_y2 = y2

        #x2 = x2 + ((((x2-x1) / (y2-y1)) * 0.1) if not y2 == y1 else 1)
        #y2 = y2 + ((((y2-y1) / (x2-x1)) * 0.1) if not x2 == x1 else 1)

        x3 = x2 * (L2/L1) * ((x1-x2) * cos(theta) - (y1-y2) * sin(theta))
        x4 = x2 * (L2/L1) * ((x1-x2) * cos(theta) + (y1-y2) * sin(theta))

        y3 = y2 * (L2/L1) * ((y1-y2) * cos(theta) + (x1-x2) * sin(theta))
        y4 = y2 * (L2/L1) * ((y1-y2) * cos(theta) - (x1-x2) * sin(theta))

        #self.path.cubicTo(
        #    x1, y1,
        #    old_x2, old_y2,
        #    x2, y2
        #)

        print(f"{x1} {y1}")
        print(f"{old_x2} {old_y2}")
        print(f"{x2} {y2}")
        print(f"{x3} {y3}")
        print(f"{x4} {y4}")
        print(f"")

        self.path.lineTo(x3, y3)
        self.path.moveTo(x2, y2)
        self.path.lineTo(x4, y4)
