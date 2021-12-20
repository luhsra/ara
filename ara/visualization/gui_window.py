from PySide6.QtWidgets import QApplication, QPushButton, QHBoxLayout, QVBoxLayout, QGraphicsView, QLabel, QWidget, \
    QMainWindow, QDockWidget, QToolBar

from PySide6.QtCore import Signal
from PySide6.QtCore import Slot

from PySide6.QtGui import QPainter, Qt

import graph_tool

from . import ara_manager, layouter
from .layouter import Layouter
from .signal import ara_signal
from .util import GraphTypes
from .widgets.graph_views import CFGView, CallGraphView, InstanceGraphView


class GuiWindow(QMainWindow):
    sigGuiWorkFinished = Signal()
    sigFinshed = Signal()

    sigUpdateDone = Signal()

    def __init__(self, parent):
        super().__init__(parent)

        self.layouter = Layouter(entry_point="main")

        self._func = {}
        self._nodes = {}
        self._edges = {}

        self.graph_scene = None
        self.graph_view = None

        self.b_start = QPushButton("Initialize Ara")
        self.b_step = QPushButton("Next Step")

        self.w_buttons = None
        self.w_center = None
        self.w_right = None
        self.w_graph_selection = None

        self.l_buttons = None
        self.l_window = None
        self.l_center = None
        self.l_right = None
        self.l_graph_selection = None

        self.v_graph_type = GraphTypes.ABB

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

        ara_signal.SIGNAL_MANAGER.sig_step_done.connect(self.update)
        ara_signal.SIGNAL_MANAGER.sig_step_done.connect(self.switch_step_button)

        ara_signal.SIGNAL_MANAGER.sig_execute_chain.connect(self.update_right)

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

    def init(self):
        self.l_window = QHBoxLayout(self)

        # Widget Setup
        self.w_center = QWidget()
        self.w_buttons = QWidget()
        self.w_right = QWidget()
        self.w_graph_selection = QWidget()

        # Layout Setup
        self.l_center = QVBoxLayout(self.w_center)
        self.l_buttons = QHBoxLayout(self.w_buttons)
        self.l_right = QVBoxLayout(self.w_right)
        self.l_graph_selection = QHBoxLayout(self.w_graph_selection)

        # Graph Views
        cfg_dock_widget = QDockWidget("CFG View", self)
        callgraph_dock_widget = QDockWidget("CallGraph View", self)
        instance_dock_widget = QDockWidget("Instance View", self)

        cfg_dock_widget.setAllowedAreas(Qt.AllDockWidgetAreas)
        callgraph_dock_widget.setAllowedAreas(Qt.AllDockWidgetAreas)
        instance_dock_widget.setAllowedAreas(Qt.AllDockWidgetAreas)

        cfg_dock_widget.setWidget(CFGView())
        callgraph_dock_widget.setWidget(CallGraphView())
        instance_dock_widget.setWidget(InstanceGraphView())

        cfg_dock_widget.widget().setRenderHint(QPainter.Antialiasing)
        callgraph_dock_widget.widget().setRenderHint(QPainter.Antialiasing)
        instance_dock_widget.widget().setRenderHint(QPainter.Antialiasing)

        self.addDockWidget(Qt.TopDockWidgetArea, cfg_dock_widget)
        self.addDockWidget(Qt.BottomDockWidgetArea, callgraph_dock_widget)
        self.addDockWidget(Qt.TopDockWidgetArea, instance_dock_widget)

        #self.graph_scene = GraphScene()
        #self.graph_view = QGraphicsView(self.graph_scene)
        #self.graph_view.setRenderHint(QPainter.Antialiasing)

        self.b_step.setDisabled(True)


        # Toolbar Setup
        toolbar = QToolBar()

        toolbar.addWidget(self.b_start)
        toolbar.addWidget(self.b_step)

        self.addToolBar(Qt.BottomToolBarArea, toolbar)

        toolbar2 = QToolBar()
        toolbar2.addWidget(self.w_right)

        self.addToolBar(Qt.LeftToolBarArea, toolbar2)

        # # Right Setup
        # self.l_right.setAlignment(Qt.AlignTop)
        # self.w_right.setMinimumSize(200, 500)
        # self.w_right.setMaximumSize(200, 1000)

        # # Button Setup
        # self.l_buttons.addWidget(self.b_start)
        # self.l_buttons.addWidget(self.b_step)
#
        # # Center setup
        # self.l_center.addWidget(self.w_graph_selection)
        # self.l_center.addWidget(self.graph_view)
        # self.l_center.addWidget(self.w_buttons)

        # for e in GraphTypes:
        #     button = SelectionButton(e.value, e)
        #     button.sig_clicked.connect(self.set_graph_type)
        #     self.l_graph_selection.addWidget(button)

        # Window Setup
        # self.l_window.addWidget(self.w_right)
        # self.l_window.addWidget(self.w_center)

        self.resize(1200, 800)
        self.show()

    @Slot(bool)
    def update(self, steps_available):
        # self.children().clear()

        if not steps_available:
            self.b_step.setDisabled(True)

        #self.graph_scene.clear_rec()
#
        #self.layouter.layout(self.v_graph_type)
        #gui_data = self.layouter.get_data(self.v_graph_type)

        #print(self.layouter.cfg_view)

        #for e in gui_data:
        #    if isinstance(e, GraphicsObject):
        #        proxy = self.graph_scene.addWidget(e)
        #        if isinstance(e, Subgraph):
        #            proxy.setZValue(0)
        #        if isinstance(e, AbbNode):
        #            proxy.setZValue(2)
        #    else:
        #        self.graph_scene.addItem(e)
        #        e.setZValue(3)

        #self.graph_view.update()
        #self.sigFinshed.emit()

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
