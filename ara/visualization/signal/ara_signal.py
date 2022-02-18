from PySide6.QtCore import QObject, Signal
from graph_tool import graph_tool


class ProcessingSignalManager(QObject):
    """
        This Objects manages all the signals for ara manager and trace manager
    """

    sig_graph = Signal(graph_tool.Graph)

    # list should only contain strings
    sig_execute_chain = Signal(list)

    sig_init_done = Signal()
    # first bool indicates if there are more step
    # second bool indicates if there has been a trace
    sig_step_done = Signal(bool, bool)
    sig_finish_done = Signal()

    sig_step_dependencies_discovered = Signal()

    def __init__(self):
        super().__init__()


# Singleton
SIGNAL_MANAGER = ProcessingSignalManager()