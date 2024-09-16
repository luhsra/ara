# SPDX-FileCopyrightText: 2023 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Container for CreateISR."""
from .step import Step
from .option import Option, String, Bool


class CreateISR(Step):
    """Create an ISR given by its entry_point.

    Do not call this step by yourself but use SIA/ISRCall to trigger it.
    """

    entry_point = Option(name="entry_point",
                         help="system entry point",
                         ty=String())

    mixed_method_fail = Option(name="mixed_method_fail",
                               help="Fail, when normal syscalls are called in ISR functions.",
                               ty=Bool(),
                               default_value=True)

    def get_single_dependencies(self):
        return [{"name": "CreateABBs", "entry_point": self.entry_point.get()}]

    def run(self):
        cfg = self._graph.cfg
        os = self._graph.os

        entry_label = self.entry_point.get()

        self._log.debug("Register ISR: %s", entry_label)

        # currently, we need that step only for FreeRTOS
        if os.get_name() == "FreeRTOS":
            os.register_isr(self._graph.instances,
                            cfg,
                            entry_label,
                            self.mixed_method_fail.get())
