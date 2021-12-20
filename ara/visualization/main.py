from PySide6.QtWidgets import QApplication

from PySide6.QtCore import QObject, QThread
from PySide6.QtCore import Signal
from PySide6.QtCore import Slot

from . import ara_manager
from .gui_window import GuiWindow


class Controller(QObject):

    sig_start_gui = Signal()
    sig_start_ara = Signal()

    def __init__(self, application:QApplication, *args, **kwargs):
        super().__init__(application, *args, **kwargs)

        # Setup Window
        self.gui_window = GuiWindow(None, application=application)

        # Start Signals
        self.sig_start_gui.connect(self.gui_window.init)
        self.sig_start_ara.connect(ara_manager.INSTANCE.init)

        # Gui Signals
        self.gui_window.b_start.clicked.connect(ara_manager.INSTANCE.init)
        self.gui_window.b_start.clicked.connect(self.gui_window.disable_start_button)
        #self.gui_window.b_step.clicked.connect(self.ara_manager.execute)
        self.gui_window.b_step.clicked.connect(ara_manager.INSTANCE.step)
        self.gui_window.b_step.clicked.connect(self.gui_window.disable_step_button)

        # Ara Signals
        ara_manager.INSTANCE.sig_init_done.connect(self.gui_window.enable_step_button)
        #self.ara_manager.sig_init_done.connect(self.gui_window.disable_start_button)

        ara_manager.INSTANCE.sig_graph.connect(self.gui_window.init_graph)
        ara_manager.INSTANCE.sig_step_dependencies_discovered.connect(ara_manager.INSTANCE.step)
        #self.ara_manager.sig_step_dependencies_discovered.connect(self.gui_window.enable_step_button)

        ara_manager.INSTANCE.sig_step_done.connect(self.gui_window.update)
        ara_manager.INSTANCE.sig_step_done.connect(self.gui_window.switch_step_button)

        ara_manager.INSTANCE.sig_execute_chain.connect(self.gui_window.update_right)
        #self.guiWorker.sigFinshed.connect(self.araWorker.setReady)

    @Slot(bool)
    def test_signal(self, b):
        print("Fired")


application = QApplication([])

#controller = Controller(application)

#controller.sig_start_gui.emit()

gui_window = GuiWindow(None)

# Setup ARA Thread
ara_manager = ara_manager.INSTANCE
araThread = QThread()
ara_manager.moveToThread(araThread)
araThread.start()

application.exec()
