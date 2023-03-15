# SPDX-FileCopyrightText: 2019 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2022 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2022 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

from PySide6.QtWidgets import QApplication

from PySide6.QtCore import QThread, QTimer

from . import ara_manager
from .trace import trace_handler
from .gui_window import GuiWindow
import signal

application = QApplication([])


# stop ARA on CTRL+C
def kill_ara(signal, _):
    application.quit()


signal.signal(signal.SIGINT, kill_ara)
signal.signal(signal.SIGTERM, kill_ara)

# send events constantly to make sure python is reacting to signals
timer = QTimer()
timer.timeout.connect(lambda: None)
timer.start(300)

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
