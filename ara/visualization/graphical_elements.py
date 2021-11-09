from PySide6.QtCore import Qt
from PySide6.QtWidgets import QGraphicsRectItem
from PySide6.QtGui import QPen


class EdgeLayer(QGraphicsRectItem):
    """
        This element handles the drawing of the graph edges.
    """

    def __init__(self, x, y, w, h, paths=None):
        super().__init__(x, y, w, h)
        self._paths = []
        self._edges = []

    def paint(self, painter, option, widget) -> None:

        for i in range(0, len(self._paths)-1):
            painter.setPen(QPen(self._edges[i].colour, 2, Qt.SolidLine, Qt.RoundCap, Qt.RoundJoin))
            painter.drawPath(self._paths[i])
            painter.setPen(Qt.black)

    def add_path(self, path):
        self._paths.append(path)

    def add_edge(self, edge):
        self._edges.append(edge)

    def clear(self):
        self._edges.clear()
        self._paths.clear()
