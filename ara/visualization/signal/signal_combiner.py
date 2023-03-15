# SPDX-FileCopyrightText: 2022 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2022 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

from PySide6.QtCore import QObject, Signal, Slot


class SignalCombiner(QObject):
    """
        This class is used to combine multiple signal sources into one output. This is done
        by tracking the sources which have triggered and which haven't. If a signal was
        received from every source a new output signal is emitted.
        The signal sources are tracked individual to prevent an output being triggered by
        just a singular source which might send multiple signals.
    """

    sig_emit = Signal()

    def __init__(self, consumer):
        super().__init__()
        self.senders = {}
        self.sig_emit.connect(consumer)

    def register_sender(self, id):
        """
        Adds an object identified by id to this signal combiner.
        """
        assert not self.senders.__contains__(id)
        self.senders[id] = False

    @Slot(type)
    def receive(self, id):
        """
            Receives a signal from a registered sender.
            Further signals send are ignored until every sender has send one.
        """
        self.senders[id] = True
        if not (False in self.senders.values()):
            self.sig_emit.emit()
            for key in self.senders.keys():
                self.senders[key] = False
