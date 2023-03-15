# SPDX-FileCopyrightText: 2019 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2022 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2022 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

import enum

from PySide6.QtUiTools import QUiLoader
from PySide6.QtWidgets import QApplication, QPushButton, QHBoxLayout, QVBoxLayout, QGraphicsView, QLabel, QWidget, \
    QMainWindow, QDockWidget, QToolBar, QListWidgetItem, QListWidget

from PySide6.QtCore import Signal, QItemSelectionModel
from PySide6.QtCore import Slot

from PySide6.QtGui import QPainter, Qt

from . import ara_manager
from ara.graph.mix import GraphType
from .signal import ara_signal
from .signal.signal_combiner import SignalCombiner
from .trace import trace_handler
from .util import RESOURCE_PATH, StepMode
from .widgets import graph_views
from .widgets.graph_views import CFGView, CallGraphView, InstanceGraphView, SVFGView

loader = QUiLoader()


class GuiWindow(QMainWindow):
    """
        Main class for the Applications window.
        Contains all the logic for controlling the flow of the processing.
    """
    sig_exec_step = Signal()

    sig_init_trace_handler = Signal()

    sig_exec_trace_step = Signal()

    sig_change_mode = Signal(StepMode)

    sig_reset_trace_handler = Signal()

    # Selected call graph nodes
    # Source of the changes - used for synchronization with the function list and call graph view
    sig_expansion_point_selected = Signal(set, str)

    sig_entry_point_selected = Signal(str, str)

    def __init__(self, parent):
        super().__init__(parent)

        self.mode = StepMode.DEFAULT

        self.current_trace = None

        self._send_updates = True

        self.b_start = QPushButton("Initialize Ara")
        self.b_step = QPushButton("Next Step")
        self.b_step_trace = QPushButton("Next Trace Step")

        self.w_right = QWidget()
        self.l_right = QVBoxLayout(self.w_right)

        self.v_graph_type = GraphType.ABB

        self.dw_cfg = QDockWidget("CFG View", self)
        self.dw_callgraph = QDockWidget("CallGraph View", self)
        self.dw_instance_graph = QDockWidget("Instance View", self)
        self.dw_svfg = QDockWidget("SVFG View", self)

        self.dw_cfg.setFeatures(QDockWidget.DockWidgetMovable
                                | QDockWidget.DockWidgetFloatable)
        self.dw_callgraph.setFeatures(QDockWidget.DockWidgetMovable
                                      | QDockWidget.DockWidgetFloatable)
        self.dw_instance_graph.setFeatures(QDockWidget.DockWidgetMovable
                                           | QDockWidget.DockWidgetFloatable)
        self.dw_svfg.setFeatures(QDockWidget.DockWidgetMovable
                                 | QDockWidget.DockWidgetFloatable)

        self.dw_step_queue = loader.load(RESOURCE_PATH.get() + "step_queue.ui")
        self.dw_function_search = loader.load(RESOURCE_PATH.get() +
                                              "function_list_search.ui")

        self.proxies = []

        center_widget = QWidget()
        center_widget.setMaximumSize(1, 1)
        self.setCentralWidget(center_widget)
        self.init()
        self.setup_signals()

    def setup_signals(self):
        self.b_start.clicked.connect(ara_manager.INSTANCE.init)
        self.b_start.clicked.connect(self.disable_start_button)

        self.b_step.clicked.connect(self.handle_step_clicked)
        self.b_step.clicked.connect(self.disable_step_button)
        self.b_step.clicked.connect(self.disable_step_trace_button)

        self.b_step_trace.clicked.connect(self.handle_step_trace_clicked)
        self.b_step_trace.clicked.connect(self.disable_step_trace_button)
        self.b_step_trace.clicked.connect(self.disable_step_button)

        self.sig_exec_step.connect(ara_manager.INSTANCE.step)

        self.sig_init_trace_handler.connect(trace_handler.INSTANCE.init)

        self.sig_exec_trace_step.connect(trace_handler.INSTANCE.step)

        ara_signal.SIGNAL_MANAGER.sig_init_done.connect(
            self.handle_button_activation)
        ara_signal.SIGNAL_MANAGER.sig_step_dependencies_discovered.connect(
            ara_manager.INSTANCE.step)

        ara_signal.SIGNAL_MANAGER.sig_step_done.connect(self.handle_step_done)

        ara_signal.SIGNAL_MANAGER.sig_execute_chain.connect(
            self.update_step_list)

        self.sig_change_mode.connect(self.dw_cfg.widget().set_mode)
        self.sig_change_mode.connect(self.dw_callgraph.widget().set_mode)
        self.sig_change_mode.connect(self.dw_instance_graph.widget().set_mode)
        self.sig_change_mode.connect(self.dw_svfg.widget().set_mode)

        self.sig_reset_trace_handler.connect(trace_handler.INSTANCE.reset)
        self.sig_reset_trace_handler.connect(
            self.dw_callgraph.widget().expansion_points_reset)

        ##

        self.dw_function_search.listSearchBar.textChanged.connect(
            self.update_function_list)
        self.dw_function_search.listSearch.itemSelectionChanged.connect(
            self.update_callgraph_selection)

        self.sig_expansion_point_selected.connect(
            graph_views.CONTEXT.set_expansion_points)

        graph_views.CONTEXT.sig_expansion_point_updated.connect(
            self.refresh_function_list_selection)

        self.dw_function_search.listSearch.itemDoubleClicked.connect(
            self.add_entry_point)

        self.sig_entry_point_selected.connect(
            graph_views.CONTEXT.switch_entry_point)

    def init(self):
        # Graph Views
        self.dw_cfg.setAllowedAreas(Qt.AllDockWidgetAreas)
        self.dw_callgraph.setAllowedAreas(Qt.AllDockWidgetAreas)
        self.dw_instance_graph.setAllowedAreas(Qt.AllDockWidgetAreas)
        self.dw_svfg.setAllowedAreas(Qt.AllDockWidgetAreas)

        self.dw_step_queue.setAllowedAreas(Qt.AllDockWidgetAreas)
        self.dw_function_search.setAllowedAreas(Qt.AllDockWidgetAreas)

        signal_combiner = SignalCombiner(self.handle_button_activation)

        self.dw_cfg.setWidget(CFGView(signal_combiner))
        self.dw_callgraph.setWidget(CallGraphView(signal_combiner))
        self.dw_instance_graph.setWidget(InstanceGraphView(signal_combiner))
        self.dw_svfg.setWidget(SVFGView(signal_combiner))

        self.dw_cfg.widget().setRenderHint(QPainter.Antialiasing)
        self.dw_callgraph.widget().setRenderHint(QPainter.Antialiasing)
        self.dw_instance_graph.widget().setRenderHint(QPainter.Antialiasing)
        self.dw_svfg.widget().setRenderHint(QPainter.Antialiasing)

        self.addDockWidget(Qt.TopDockWidgetArea, self.dw_cfg)
        self.addDockWidget(Qt.BottomDockWidgetArea, self.dw_callgraph)
        self.addDockWidget(Qt.TopDockWidgetArea, self.dw_instance_graph)
        self.addDockWidget(Qt.BottomDockWidgetArea, self.dw_svfg)
        self.addDockWidget(Qt.TopDockWidgetArea, self.dw_step_queue)
        self.addDockWidget(Qt.BottomDockWidgetArea, self.dw_function_search)

        self.b_step.setDisabled(True)
        self.b_step_trace.setDisabled(True)

        # Toolbar Setup
        toolbar = QToolBar()

        toolbar.addWidget(self.b_start)
        toolbar.addWidget(self.b_step)
        toolbar.addWidget(self.b_step_trace)

        self.addToolBar(Qt.BottomToolBarArea, toolbar)

        self.resize(1200, 800)
        self.show()

    @Slot(QListWidgetItem)
    def add_entry_point(self, item):
        self.sig_entry_point_selected.emit(item.text(), "List")

    @Slot()
    def update_callgraph_selection(self):
        items = set()

        if self._send_updates:

            current_extension_points = graph_views.CONTEXT.get_expansion_points(
            )

            for point in current_extension_points:
                if len(
                        self.dw_function_search.listSearch.findItems(
                            point, Qt.MatchFlag.MatchExactly)) == 0:
                    items.add(point)

            for item in self.dw_function_search.listSearch.selectedItems():
                items.add(item.text())

            self.sig_expansion_point_selected.emit(items, "List")

    @Slot(str)
    def refresh_function_list_selection(self, source):
        if source == "List":
            return

        self._send_updates = False

        for item in self.dw_function_search.listSearch.findItems(
                "", Qt.MatchFlag.MatchContains):
            if item.text() in graph_views.CONTEXT.get_expansion_points():
                self.dw_function_search.listSearch.setCurrentItem(
                    item, QItemSelectionModel.Select)
            else:
                self.dw_function_search.listSearch.setCurrentItem(
                    item, QItemSelectionModel.Deselect)

        self._send_updates = True

    @Slot()
    def handle_step_clicked(self):
        if self.mode == StepMode.TRACE:
            self.mode = StepMode.DEFAULT
            self.sig_change_mode.emit(self.mode)
            self.sig_reset_trace_handler.emit()

        self.sig_exec_step.emit()

    @Slot()
    def handle_step_trace_clicked(self):
        if self.mode == StepMode.DEFAULT:
            self.mode = StepMode.TRACE
            self.sig_change_mode.emit(self.mode)
            self.sig_init_trace_handler.emit()

        self.sig_exec_trace_step.emit()

    @Slot(bool, bool)
    def handle_step_done(self, steps_available, trace_available):
        if self.mode == StepMode.TRACE and not steps_available:
            self.mode = StepMode.DEFAULT
            self.sig_change_mode.emit(self.mode)
            self.b_step_trace.setDisabled(True)

        self.update_function_list()

        if not steps_available:
            self.b_step.setDisabled(True)

        if trace_available:
            self.b_step_trace.setEnabled(True)

    @Slot(str)
    def update_function_list(self, txt=""):

        self._send_updates = False

        source_graph = ara_manager.INSTANCE.graph.callgraph
        if self.mode == StepMode.TRACE:
            source_graph = trace_handler.INSTANCE.context.callgraph

        function_list: QListWidget = self.dw_function_search.listSearch

        function_list.clear()

        selection_list = graph_views.CONTEXT.get_expansion_points()

        for vertex in source_graph.vertices():
            name = source_graph.vp.function_name[vertex]
            if txt not in name:
                continue
            item = QListWidgetItem(name, function_list)
            if name in selection_list:
                function_list.setCurrentItem(item)

        function_list.sortItems()

        self.refresh_function_list_selection("")

        self._send_updates = True

    @Slot()
    def enable_start_button(self):
        self.b_start.setEnabled(True)

    @Slot()
    def disable_step_button(self):
        self.b_step.setDisabled(True)

    @Slot()
    def disable_step_trace_button(self):
        self.b_step_trace.setDisabled(True)

    @Slot()
    def disable_start_button(self):
        self.b_start.setDisabled(True)

    @Slot()
    def handle_button_activation(self):
        self.b_step.setEnabled(True)
        if self.mode == StepMode.TRACE:
            self.b_step_trace.setEnabled(True)

    @Slot(list)
    def update_step_list(self, step_list: list):
        item_list_widget = self.dw_step_queue.listWidget

        item_list_widget.clear()

        for item in step_list[::-1]:
            QListWidgetItem(item.name, item_list_widget)
