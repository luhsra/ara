# SPDX-FileCopyrightText: 2023 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Container for Dummy."""
from collections import defaultdict

from ara.graph import CFG
from ara.os.os_util import Parenthesis
from .step import Step


class PairwiseCheck(Step):
    """Check, on the instance graph, if necessary interactions are pairwise."""

    def get_single_dependencies(self):
        return ["InteractionAnalysis"]

    def run(self):
        instances = self._graph.instances
        cfg = self._graph.cfg
        os = self._graph.os

        resources = defaultdict(int)
        res_val = {Parenthesis.LEFT: 1,
                   Parenthesis.RIGHT: -1}

        for interaction in instances.edges():
            syscall_abb = instances.ep.syscall[interaction]
            if syscall_abb == CFG.INVALID_ABB:
                continue
            sys_name = cfg.get_syscall_name(syscall_abb)
            m_syscall = os.syscalls[sys_name]
            if isinstance(m_syscall.parenthesis, Parenthesis):
                insts = (interaction.source(), interaction.target())
                resources[insts] += res_val[m_syscall.parenthesis]
        for val in resources.values():
            if val != 0:
                self._fail("Some resource was not taken pairwise.")
