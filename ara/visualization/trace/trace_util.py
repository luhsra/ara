from PySide6.QtGui import Qt, QColor

from ara.visualization.trace import trace_lib

# This file just contains util functions or objects

trace_color_to_qt_color = {
    trace_lib.Color.RED: Qt.red,
    trace_lib.Color.AQUA: QColor.fromRgb(0,255,255),
    trace_lib.Color.GREEN: Qt.green,
    trace_lib.Color.ORANGE: QColor.fromRgb(255, 165, 0)
}