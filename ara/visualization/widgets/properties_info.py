
from PySide6.QtWidgets import QTableView
from PySide6.QtCore import QAbstractTableModel, Qt, QSize
from graph_tool.libgraph_tool_core import Vertex
from ara.visualization.util import SMALL_WIDGET_HEIGHT, SMALL_WIDGET_WIDTH

class PropertiesInfo(QTableView):
    class PropertiesInfoModel(QAbstractTableModel):
        def __init__(self, data):
            super().__init__()
            self._data = data

        def data(self, index, role):
            if role == Qt.DisplayRole:
                return self._data[index.row()][index.column()]

        def rowCount(self, index):
            return len(self._data)

        def columnCount(self, index):
            return len(self._data[0])
    
    def __init__(self):
        super().__init__()
        self.show_no_data()

    def set_data(self, data):
        self.setModel(self.PropertiesInfoModel(data))

    def show_no_data(self):
        self.set_data([["no node selected"]])

    def set_node_data(self, graph, node: Vertex, extra_data: list = None):
        if type(extra_data) == list:
            data = extra_data
        else:
            data = list()
        for key in graph.vp.keys():
            data.append([key, str(graph.vp[key][node])])
        self.set_data(data)

    # Override method of QDockWidget
    def sizeHint(self) -> QSize:
        return QSize(SMALL_WIDGET_WIDTH + 60, SMALL_WIDGET_HEIGHT)

    def setup_signals(self):
        pass # TODO

    # construct in gui_window.py
    globalInfo: 'PropertiesInfo' = None
