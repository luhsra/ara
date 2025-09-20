# SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Container for BareMetal."""
from ara.graph import Graph
from .step import Step
from .option import Option, Integer, String


class BareMetal(Step):
    """Template for a new Python step."""

    entry_point = Option(name="entry_point",
                         help="system entry point",
                         ty=String(),
                         default_value="")

    def get_dependencies(self, _):
        return []

    def run(self):
        self._log.info("Executing BareMetal step.")
        opt = self.entry_point.get()
        if opt:
            self._log.debug(f"Option is {opt}.")

            self._step_manager.chain_step(
                {"name": "Syscall", "entry_point": opt}
            )
