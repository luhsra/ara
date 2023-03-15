# SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2021 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Container for RegisterTaskEntry."""
from .step import Step

from ara.os.autosar import Task


class RegisterTaskEntry(Step):
    """Register the correct entry point (ABB) of all AUTOSAR Tasks."""
    def get_single_dependencies(self):
        return ["LoadOIL"]

    def run(self):
        instances = self._graph.instances
        for instance in instances.vertices():
            task = instances.vp.obj[instance]
            if isinstance(task, Task):
                task.abb = self._graph.cfg.get_entry_abb(task.function)
