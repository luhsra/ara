from PySide6.QtWidgets import QApplication

from PySide6.QtCore import QObject, QThread
from PySide6.QtCore import Signal
from PySide6.QtCore import Slot

import graph_tool

from .ara_manager import ARAManager
from .gui_window import GuiWindow


class Controller(QObject):

    sig_start_gui = Signal()
    sig_start_ara = Signal()

    def __init__(self, application:QApplication, *args, **kwargs):
        super().__init__(application, *args, **kwargs)

        # Create Ara
        self.ara_manager = ARAManager()
        self.araThread = QThread(application)
        self.ara_manager.moveToThread(self.araThread)

        # Setup Window
        self.gui_window = GuiWindow(None, application=application)

        # Start Signals
        self.sig_start_gui.connect(self.gui_window.init)
        self.sig_start_ara.connect(self.ara_manager.init)

        # Gui Signals
        self.gui_window.b_start.clicked.connect(self.ara_manager.init)
        self.gui_window.b_start.clicked.connect(self.gui_window.disable_start_button)
        #self.gui_window.b_step.clicked.connect(self.ara_manager.execute)
        self.gui_window.b_step.clicked.connect(self.ara_manager.step)
        self.gui_window.b_step.clicked.connect(self.gui_window.disable_step_button)

        # Ara Signals
        self.ara_manager.sig_init_done.connect(self.gui_window.enable_step_button)
        #self.ara_manager.sig_init_done.connect(self.gui_window.disable_start_button)

        self.ara_manager.sig_graph.connect(self.gui_window.init_graph)
        self.ara_manager.sig_step_dependencies_discovered.connect(self.ara_manager.step)
        #self.ara_manager.sig_step_dependencies_discovered.connect(self.gui_window.enable_step_button)

        self.ara_manager.sig_step_done.connect(self.gui_window.update)
        self.ara_manager.sig_step_done.connect(self.gui_window.switch_step_button)

        self.ara_manager.sig_execute_chain.connect(self.gui_window.update_right)
        #self.guiWorker.sigFinshed.connect(self.araWorker.setReady)

        self.araThread.start()

    @Slot(bool)
    def test_signal(self, b):
        print("Fired")

def initGraph(g: graph_tool.Graph):
    controller.araWorker.sigInitGraph.emit(g)

application = QApplication([])

controller = Controller(application)

controller.sig_start_gui.emit()

application.exec()
