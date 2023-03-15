# SPDX-FileCopyrightText: 2022 Bastian Fuhlenriede
#
# SPDX-License-Identifier: GPL-3.0-or-later

from PySide6.QtCore import Qt, Slot, Signal
from PySide6.QtWidgets import QMainWindow, QApplication, QDockWidget, QWidget, QVBoxLayout, QTextEdit, QPushButton, \
    QLineEdit, QLabel


class GuiWindow(QMainWindow):

    sig_clear = Signal()

    def __init__(self):
        super().__init__()

        self.input_dock_widget = QDockWidget("Input")

        self.input_widget = QWidget()
        self.input_widget_layout = QVBoxLayout(self.input_widget)

        self.input_button = QPushButton("Send greetings")
        self.clear_button = QPushButton("Clear")

        self.input_field = QLineEdit()
        self.input_field.setPlaceholderText("Your Name")

        self.output_field = QLabel()
        self.output_field.setAlignment(Qt.AlignCenter)

        self.input_widget_layout.addWidget(self.input_field)
        self.input_widget_layout.addWidget(self.input_button)
        self.input_widget_layout.addWidget(self.clear_button)

        self.input_dock_widget.setWidget(self.input_widget)

        self.addDockWidget(Qt.LeftDockWidgetArea, self.input_dock_widget)

        self.setCentralWidget(self.output_field)

        self.setup_signals()

        self.setWindowTitle("Qt GUI Example")
        self.setMinimumWidth(350)

        self.input_widget.show()
        self.input_button.show()
        self.input_field.show()
        self.output_field.show()
        self.show()

    def setup_signals(self):
        self.input_button.clicked.connect(self.set_greeting)
        self.clear_button.clicked.connect(self.input_field.clear)
        self.clear_button.clicked.connect(self.output_field.clear)
        self.sig_clear.connect(self.input_field.clear)

    @Slot()
    def set_greeting(self):
        self.output_field.setText(f"Hello {self.input_field.text()}")
        self.sig_clear.emit()


application = QApplication([])

gui_window = GuiWindow()

application.exec()