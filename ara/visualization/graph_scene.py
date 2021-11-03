from PySide6.QtCharts import QSplineSeries, QChart
from PySide6.QtWidgets import *
from PySide6.QtCore import *
from PySide6.QtGui import QColorConstants, QPainter
from PySide6.QtGui import QPainterPath
from PySide6.QtGui import QPen

from ara.visualization.graphical_elements import EdgeLayer


class DObject:
    """
        Basic Drawable Object.
    """

    def __init__(self, pos, label, colour, style):
        self.pos = pos
        self.label = label
        self.colour = colour
        self.style = style


class DEdge(DObject):
    """
        Drawable Object for a Edge.
    """

    def __init__(self, pos, label, colour, style, id, tail, head, labelPos):
        super().__init__(pos, label, colour, style)
        self.id = id
        self.tail = tail
        self.head = head
        self.labelPos = labelPos


class DNode(DObject):
    """
        Drawable Object for a Node.
    """

    def __init__(self, pos, label, colour, style, id, name, height, width, shape, labelPos):
        super().__init__(pos, label, colour, style)
        self.id = id
        self.name = name
        self.height = height
        self.width = width
        self.shape = shape
        self.labelPos = labelPos
        self._edges = {}

    def add_edge(self, DEdge):
        self._edges[DEdge.id] = DEdge


class DFunc(DNode):
    """
        Drawable Object for a Function.
    """

    def __init__(self, pos, label, colour, style, id,  name, height, width, shape, labelPos):
        super().__init__(pos, label, colour, style, id, name, height, width, shape, labelPos)
        self._nodes = {}

    def add_node(self, DNode):
        self._nodes[DNode.id] = DNode

    @Slot()
    def event(self):
        print(f"Pos: {self.pos}")

class GraphScene(QGraphicsScene):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._func = {}
        self._nodes = {}
        self._edges = {}
        self._graphicsObjects = []
        self._edgeLayer = EdgeLayer(0, 0, 0, 0)
        self._edgeLayer.setZValue(0)
        self._edgeLayer.setBrush(Qt.gray)
        self.addItem(self._edgeLayer)
        self._edgeLayer.show()


    def updateScene(self):
        for f in self._func.values():
            item = QGraphicsRectItem(QRectF(f.pos["x"], f.pos["y"], f.width, f.height))
            self._graphicsObjects.append(item)
            label = QGraphicsTextItem(item)
            label.setX(f.pos["x"])
            label.setY(f.pos["y"])
            
            if f.style == "solid":
                item.setPen(QPen(f.colour, 1, Qt.SolidLine, Qt.RoundCap, Qt.RoundJoin))
            elif f.style == "dashed":
                item.setPen(QPen(f.colour, 1, Qt.DashLine, Qt.RoundCap, Qt.RoundJoin))
            elif f.style == "filled":
                item.setPen(Qt.NoPen)
                item.setBrush(f.colour)

            self.addItem(item)
            #self.addItem(label)
            label.setPlainText(f.label)
            label.show()
            item.setZValue(1.0)
            label.setZValue(2.0)
            item.show()

        for n in self._nodes.values():
            item = None
            if n.shape == "box":
                item = QGraphicsRectItem(QRectF(n.pos["x"], n.pos["y"], n.width, n.height))
            elif n.shape == "oval":
                item = QGraphicsEllipseItem(QRectF(n.pos["x"], n.pos["y"], n.width, n.height))
            elif n.shape == "diamond":
                item = QGraphicsRectItem(QRectF(n.pos["x"], n.pos["y"], n.width, n.height))
                item.setBrush(QColorConstants.Red)
            else:
                print(f"Unknown Shape{ n.shape }")
                continue

            if n.style == "solid":
                item.setPen(QPen(n.colour, 2, Qt.SolidLine, Qt.RoundCap, Qt.RoundJoin))
            elif n.style == "dashed":
                item.setPen(QPen(n.colour, 2, Qt.DashLine, Qt.RoundCap, Qt.RoundJoin))
            
            item.setZValue(1.0)
            label = QGraphicsTextItem(item)
            label.setX(n.labelPos["x"] - 25)
            label.setY(n.labelPos["y"] - 10)
            label.setZValue(3.0)
            self.addItem(item)
            #self.addItem(label)

            label.setPlainText(n.label)

            self._graphicsObjects.append(item)

            item.show()
            label.show()

        self._edgeLayer.setRect(0, 0, self.width(), self.height())
        for e in self._edges.values():
            path = QPainterPath()
            path.moveTo(e.pos[0]["x"], e.pos[0]["y"])
            for i in range(1, len(e.pos)-1,3):
                path.cubicTo(e.pos[i]["x"], e.pos[i]["y"],
                             e.pos[i+1]["x"], e.pos[i+1]["y"],
                             e.pos[i+2]["x"], e.pos[i+2]["y"])

            self._edgeLayer.add_edge(e)
            self._edgeLayer.add_path(path)




    def clear(self):
        for f in self._func:
            f.hide()
            del f
        self._func.clear()

        for n in self._nodes:
            n.hide()
            del n
        self._nodes.clear()

        for e in self._edges:
            e.hide()
            del e
        self._edges.clear()

    def add_func(self, func: DFunc):
        self._func[func.id] = func

    def add_node(self, node: DNode):
        self._nodes[node.id] = node

    def add_edge(self, edge: DEdge):
        self._edges[edge.id] = edge
        self._nodes[edge.tail].add_edge(edge)
        self._nodes[edge.head].add_edge(edge)
