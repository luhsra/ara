from PySide6.QtCore import QObject, Signal
from graph_tool import graph_tool


class ARASignalManager(QObject):
    """
        This Objects holds all the signals send from ara
    """

    sig_graph = Signal(graph_tool.Graph)

    sig_execute_chain = Signal(list)

    sig_init_done = Signal()
    sig_step_done = Signal(bool)
    sig_finish_done = Signal()

    sig_step_dependencies_discovered = Signal()

    def __init__(self):
        super().__init__()


SIGNAL_MANAGER = ARASignalManager()