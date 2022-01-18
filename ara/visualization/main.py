from PySide6.QtWidgets import QApplication

from PySide6.QtCore import QObject, QThread
from PySide6.QtCore import Signal
from PySide6.QtCore import Slot

from . import ara_manager
from .trace import trace_handler
from .gui_window import GuiWindow


application = QApplication([])

#controller = Controller(application)

#controller.sig_start_gui.emit()

gui_window = GuiWindow(None)

# Setup ARA Thread
ara_manager = ara_manager.INSTANCE
araThread = QThread()
ara_manager.moveToThread(araThread)
araThread.start()

# Setup Trace Handler Thread
trace_handler = trace_handler.INSTANCE
trace_handler_thread = QThread()
trace_handler.moveToThread(trace_handler_thread)
trace_handler_thread.start()

application.exec()
