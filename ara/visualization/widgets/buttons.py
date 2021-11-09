from PySide6.QtCore import Signal, Slot
from PySide6.QtWidgets import QPushButton

from ara.visualization.util import GraphTypes


class SelectionButton(QPushButton):

    sig_clicked = Signal(GraphTypes)

    def __init__(self, name, graph_type):
        super().__init__(name)
        self.graph_type = graph_type
        self.clicked.connect(self._click_proxy)


    @Slot()
    def _click_proxy(self):
        self.sig_clicked.emit(self.graph_type)
