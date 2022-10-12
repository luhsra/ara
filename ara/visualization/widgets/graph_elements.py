from PySide6.QtCore import Qt, Signal
from PySide6.QtUiTools import QUiLoader
from PySide6.QtWidgets import QGraphicsPathItem, QWidget, QVBoxLayout, QGraphicsTextItem
from PySide6.QtGui import QPen, QPainterPath, QMouseEvent
from pygraphviz import Node, Edge
from pygraphviz import AGraph
from graph_tool.libgraph_tool_core import Vertex

from ara.graph import CFType
from ara.visualization.trace import trace_lib, trace_util
from ara.visualization.util import RESOURCE_PATH

DPI_LEVEL = 72


class GraphicsObject(QWidget):
    """
        Base class for graph elements.
    """

    loader = QUiLoader()

    def __init__(self, path_to_ui_file):
        super().__init__()
        self.widget = GraphicsObject.loader.load(path_to_ui_file)
        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        self.layout().addWidget(self.widget)


class AbstractNode(GraphicsObject):
    """
        Base class for graph nodes. Loads a ui file for the design.
    """

    def __init__(self, node: Node, ui_path=RESOURCE_PATH.get() + "node.ui"):
        super().__init__(ui_path)

        self.data = node
        self.id = self.data.attr["id"]
        pos = self.data.attr["pos"].split(",")

        width = float(self.data.attr["width"]) * DPI_LEVEL
        height = float(self.data.attr["height"]) * DPI_LEVEL

        x = float(pos[0]) - 0.5*width
        y = -float(pos[1]) - 0.5*height

        self.setGeometry(int(x), int(y), int(width), int(height))
        self.highlighting = False

    def reload_stylesheet(self):
        """
            Reloads the stylesheet of the widget. This needs to be done, if a property is changed after the creation
            of the object, otherwise the design doesn't update.
        """
        self.widget.setStyleSheet(self.widget.styleSheet())

    def set_highlighted(self, color=trace_lib.Color.RED):
        self.highlighting = True
        self.widget.setProperty("highlighted", color.value)
        self.reload_stylesheet()


class AdjacencyNode(AbstractNode):
    """Node able to be adjacent to a an expansion point"""

    def __init__(self, node: Node, ui_path=RESOURCE_PATH.get() + "node.ui"):
        super().__init__(node, ui_path)
        self.adjacency = False
        self.widget.setProperty("adjacency", "false")
        if self.data.attr["adjacency"] == "True":
            self.adjacency = True
            self.widget.setProperty("adjacency", "true")
        self.reload_stylesheet()

    def set_adjacency(self, adj: bool):
        self.adjacency = adj
        self.widget.setProperty("adjacency", "true" if adj else "")
        self.reload_stylesheet()


class AbbNode(AbstractNode):
    """
        Node of a cfg.
    """

    subtypes = {"": "UNK", "1": "syscall", "2": "call", "4": "comp"}

    def __init__(self, node: Node):
        super().__init__(node, RESOURCE_PATH.get() + "node.ui")

        self.widget.label_text.setText(self.data.attr["label"])
        self.widget.subtype_text.setText(
            str(self.subtypes[self.data.attr["subtype"]]))
        self.widget.type_text.setText(str(self.data.attr["type"]))

    def mousePressEvent(self, event: QMouseEvent) -> None:
        print("Do Something with the clicks")


class CallGraphNode(AdjacencyNode):
    """
        Node of a call graph. Contains all signals to make a graph selection and handle the expansion of the graph.
    """

    sig_adjacency_selected = Signal(str)

    sig_expansion_unselected = Signal(str)

    sig_selected = Signal(str)

    sig_unselected = Signal(str)

    def __init__(self, node: Node):
        super().__init__(node, RESOURCE_PATH.get() + "callgraph_node.ui")

        self.widget.label_text.setText(str(self.data.attr["label"]))

        self.selected = False
        self.expansion = False

    def mousePressEvent(self, event: QMouseEvent) -> None:
        if event.button() == Qt.LeftButton:
            if self.adjacency:
                self.sig_adjacency_selected.emit(self.data.attr["label"])
                return

            self.selected = not self.selected

            if self.selected:
                self.sig_selected.emit(self.data.attr["label"])
                self.widget.setProperty("selected", "true")
            else:
                self.sig_unselected.emit(self.data.attr["label"])
                self.widget.setProperty("selected", "false")

            self.reload_stylesheet()

            return

        if event.button(
        ) == Qt.RightButton and self.expansion and not self.selected:
            self.expansion = False
            self.sig_expansion_unselected.emit(self.data.attr["label"])
            return


class InstanceNode(AbstractNode):
    """
        Node of the instance graph.
    """

    def __init__(self, node: Node):
        super().__init__(node, RESOURCE_PATH.get() + "instance_node.ui")
        self.widget.label_text.setText(str(self.data.attr["label"]))
        self.widget.sublabel_text.setText(str(self.data.attr["sublabel"]))


class SVFGNode(AdjacencyNode):
    """
        Node of the SVFG.
    """

    sig_adjacency_selected = Signal(Vertex)

    def __init__(self, node: Node):
        super().__init__(node, RESOURCE_PATH.get() + "svfg_node.ui")

        self.widget.label_text.setText(str(self.data.attr["label"]))
        self.widget.label_text.setWordWrap(True)

    def mousePressEvent(self, event: QMouseEvent) -> None:
        if event.button() == Qt.LeftButton:
            if self.adjacency:
                self.sig_adjacency_selected.emit(self.id)
                return


class Subgraph(GraphicsObject):
    """
        A subgraph of the cfg which surrounds ABB nodes.
    """

    def __init__(self, subgraph: AGraph):
        super().__init__(RESOURCE_PATH.get() + "subgraph.ui")
        self.data = subgraph

        x_min = 100000000
        x_max = 0

        y_min = 100000000

        y_max = 0

        for n in self.data.nodes():
            pos = n.attr["pos"].split(",")
            width = float(n.attr["width"]) * DPI_LEVEL
            height = float(n.attr["height"]) * DPI_LEVEL

            x = float(pos[0]) - 0.5*width
            y = float(pos[1]) + 0.5*height

            x_min = x if x < x_min else x_min
            y_min = y - height if y - height < y_min else y_min
            x_max = (x + width) if (x + width) > x_max else x_max
            y_max = y if y > y_max else y_max

        height = y_max - y_min + 50
        width = x_max - x_min + 20

        x = x_min - 10
        y = -(y_max + 40)

        self.widget.subgraph_label_text.setText(self.data.graph_attr["label"])

        self.widget.subgraph_label_text.setMaximumWidth(int(width))
        self.widget.subgraph_label_text.setToolTip(
            self.data.graph_attr["label"])

        self.setGeometry(x, y, width, height)


class GraphEdge(QGraphicsPathItem):
    """
        A edge of a graph.
    """

    def __init__(self, edge: Edge):
        super().__init__()

        self.data = edge
        self.path = QPainterPath()

        self.id = self.data.attr["id"]

        self.text = list()

        pos = []
        edges = []

        rawEdges = self.data.attr["pos"].split(",")
        del rawEdges[
            0]  # The First Char inside the position string is an e, which has to be removed

        for re in rawEdges:
            for s in re.split(" "):
                edges.append(float(s))

        # This ignores the first edge, as this is the end point of the edge
        for i in range(2, len(edges) - 1, 2):
            pos.append({"x": edges[i], "y": edges[i + 1]})

        # Add the end point
        pos.append({"x": edges[0], "y": edges[1]})

        self.path.moveTo(pos[0]["x"], -pos[0]["y"])
        i = 0
        for i in range(1, len(pos) - 1, 3):
            self.path.cubicTo(pos[i]["x"], -pos[i]["y"], pos[i + 1]["x"],
                              -pos[i + 1]["y"], pos[i + 2]["x"],
                              -pos[i + 2]["y"])

        self._draw_arrow_tip(edges[0], -edges[1], 20, 30)

        # Generate the labels
        if self.data.attr.__contains__("label") and not (
                self.data.attr["label"] is None):
            text_item = QGraphicsTextItem()
            pos = self.data.attr["lp"].split(",")
            label = self.data.attr["label"]
            text_item.setPos(
                float(pos[0]) - len(label) * 6, -float(pos[1]) - 12)
            text_item.setPlainText(label)
            self.text.append(text_item)

        self.setPath(self.path)

        pen_color = Qt.black
        if self.data.attr.__contains__("edge_type"):
            if self.data.attr["edge_type"] == str(CFType.lcf.value):
                pen_color = Qt.red
            elif self.data.attr["edge_type"] == str(CFType.icf.value):
                pen_color = Qt.blue

        self.path.setFillRule(Qt.WindingFill)
        self.setPen(
            QPen(pen_color, 1.5, Qt.SolidLine, Qt.RoundCap, Qt.RoundJoin))

    def _draw_arrow_tip(self, x, y, size, theta):
        # Bounding Box Parameter
        box_x = x - size/2
        box_y = y - size/2

        # Finish the line
        self.path.moveTo(x, y)

        current_degree = self.path.angleAtPercent(1)

        self.path.arcTo(box_x, box_y, size, size, current_degree - 180 + theta,
                        0)
        edge_point = self.path.pointAtPercent(1)

        self.path.moveTo(x, y)

        self.path.arcTo(box_x, box_y, size, size, current_degree - 180 - theta,
                        0)
        self.path.lineTo(edge_point)


class NodeSetting:
    """
        This is used by the trace system to set the visual design of a node.
    """

    def __init__(self,
                 highlighting: bool,
                 highlight_color=trace_lib.Color.RED):
        self.highlighting = highlighting
        self.highlight_color = highlight_color

    def apply(self, node):
        if self.highlighting:
            node.set_highlighted(self.highlight_color)


class CallgraphEdgeSetting:
    """
        This is used by the trace system to set the visual design of a call graph edge.
    """

    def __init__(self,
                 edge_id,
                 highlighting: bool,
                 highlighting_color=trace_lib.Color.RED):
        self.edge_id = edge_id
        self.highlighting = highlighting
        self.highlight_color = highlighting_color

    def apply(self, edge):
        if self.highlighting:
            edge.setPen(
                QPen(trace_util.trace_color_to_qt_color[self.highlight_color],
                     4, Qt.SolidLine, Qt.RoundCap, Qt.RoundJoin))
