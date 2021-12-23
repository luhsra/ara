from PySide6.QtWidgets import QApplication, QPushButton, QHBoxLayout, QVBoxLayout, QGraphicsView, QLabel, QWidget, \
    QMainWindow, QDockWidget, QToolBar

from PySide6.QtCore import Signal
from PySide6.QtCore import Slot

from PySide6.QtGui import QPainter, Qt

import graph_tool

from . import ara_manager, layouter
from .layouter import Layouter
from .signal import ara_signal
from .signal.signal_combiner import SignalCombiner
from .util import GraphTypes
from .widgets.graph_views import CFGView, CallGraphView, InstanceGraphView


class GuiWindow(QMainWindow):
    sigGuiWorkFinished = Signal()
    sigFinshed = Signal()

    sigUpdateDone = Signal()

    def __init__(self, parent):
        super().__init__(parent)

        self.b_start = QPushButton("Initialize Ara")
        self.b_step = QPushButton("Next Step")

        self.w_right = QWidget()
        self.l_right = QVBoxLayout(self.w_right)

        self.v_graph_type = GraphTypes.ABB

        self.cfg_dock_widget = QDockWidget("CFG View", self)
        self.callgraph_dock_widget = QDockWidget("CallGraph View", self)
        self.instance_dock_widget = QDockWidget("Instance View", self)

        self.proxies = []

        self.init()
        self.setup_signals()


    def setup_signals(self):
        self.b_start.clicked.connect(ara_manager.INSTANCE.init)
        self.b_start.clicked.connect(self.disable_start_button)

        self.b_step.clicked.connect(ara_manager.INSTANCE.step)
        self.b_step.clicked.connect(self.disable_step_button)

        ara_signal.SIGNAL_MANAGER.sig_init_done.connect(self.enable_step_button)
        ara_signal.SIGNAL_MANAGER.sig_step_dependencies_discovered.connect(ara_manager.INSTANCE.step)

        #ara_signal.SIGNAL_MANAGER.sig_step_done.connect(self.update)
        #ara_signal.SIGNAL_MANAGER.sig_step_done.connect(self.switch_step_button)

        #self.cfg_dock_widget.widget().sig_work_done.connect(self.enable_step_button)
        #self.callgraph_dock_widget.widget().sig_work_done.connect(self.enable_step_button)
        #self.instance_dock_widget.widget().sig_work_done.connect(self.enable_step_button)

        ara_signal.SIGNAL_MANAGER.sig_execute_chain.connect(self.update_right)

    def init(self):
        # Graph Views
        self.cfg_dock_widget.setAllowedAreas(Qt.AllDockWidgetAreas)
        self.callgraph_dock_widget.setAllowedAreas(Qt.AllDockWidgetAreas)
        self.instance_dock_widget.setAllowedAreas(Qt.AllDockWidgetAreas)

        signal_combiner = SignalCombiner(self.enable_step_button)

        self.cfg_dock_widget.setWidget(CFGView(signal_combiner))
        self.callgraph_dock_widget.setWidget(CallGraphView(signal_combiner))
        self.instance_dock_widget.setWidget(InstanceGraphView(signal_combiner))

        self.cfg_dock_widget.widget().setRenderHint(QPainter.Antialiasing)
        self.callgraph_dock_widget.widget().setRenderHint(QPainter.Antialiasing)
        self.instance_dock_widget.widget().setRenderHint(QPainter.Antialiasing)

        self.addDockWidget(Qt.TopDockWidgetArea, self.cfg_dock_widget)
        self.addDockWidget(Qt.BottomDockWidgetArea, self.callgraph_dock_widget)
        self.addDockWidget(Qt.TopDockWidgetArea, self.instance_dock_widget)

        self.b_step.setDisabled(True)

        # Toolbar Setup
        toolbar = QToolBar()

        toolbar.addWidget(self.b_start)
        toolbar.addWidget(self.b_step)

        self.addToolBar(Qt.BottomToolBarArea, toolbar)

        toolbar2 = QToolBar()
        toolbar2.addWidget(self.w_right)

        self.addToolBar(Qt.LeftToolBarArea, toolbar2)

        self.resize(1200, 800)
        self.show()

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

    @Slot(bool)
    def update(self, steps_available):

        if not steps_available:
            self.b_step.setDisabled(True)

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
