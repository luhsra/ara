# SPDX-FileCopyrightText: 2022 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2022 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

from PySide6.QtGui import Qt, QColor

from ara.visualization.trace import trace_lib

# This file just contains util functions or objects

trace_color_to_qt_color = {
    trace_lib.Color.RED: Qt.red,
    trace_lib.Color.AQUA: QColor.fromRgb(0, 255, 255),
    trace_lib.Color.GREEN: Qt.green,
    trace_lib.Color.ORANGE: QColor.fromRgb(255, 165, 0),
    trace_lib.Color.PURPLE: QColor.fromRgb(128, 0, 128),
    trace_lib.Color.YELLOW: QColor.fromRgb(255, 255, 0),
    trace_lib.Color.BLUE: QColor.fromRgb(0, 0, 255),
}
