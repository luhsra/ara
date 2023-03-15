# SPDX-FileCopyrightText: 2021 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Container for ApplyTimings."""
from .step import Step
from ara.graph import ABBType, CFGView

import hashlib


class FakeTimings(Step):
    """Apply fake timings (and fake loop bounds) to all relevant ABBs."""

    def _get_unique_numbers(self, seed: bytes):
        """Return up to 255 unique numbers from 0 to 255."""
        pool = hashlib.sha256(seed).digest()
        already_used = set()
        for i in range(0, 256):
            cand = pool[i]
            if cand in already_used:
                continue
            already_used.add(cand)
            yield cand

    def get_dependencies(self, step_history):
        name = self.get_name()
        steps = set([x["name"] for x in step_history])
        if name in steps:
            self._first_execution = False
            mlh = None
            for step in reversed(step_history):
                if step["name"] == "MarkLoopHead":
                    mlh = step['config']['entry_point']
                    continue
                elif step["name"] == "CreateABBs":
                    ep = step['config']['entry_point']
                    if mlh is not None and mlh == ep:
                        return []
                    return [{"name": "MarkLoopHead", "entry_point": ep}]
            self._fail("No CreateABBs step found. This must not happen.")
        self._first_execution = True
        return []

    def run(self):
        if self._first_execution:
            name = self.get_name()
            self._log.debug(f"Register {name} as successor of CreateABBs.")
            step_config = {"name": name}
            self._step_manager.chain_step(step_config, after="CreateABBs")
            return

        abbs = self._graph.abbs
        comps = CFGView(abbs, vfilt=abbs.vp.type.fa == ABBType.computation)

        for abb in comps.vertices():
            abb_name = comps.vp.name[abb]
            unique_number = self._get_unique_numbers(abb_name.encode('UTF-8'))
            a = next(unique_number)
            b = next(unique_number)

            bcet = min(a, b)
            wcet = max(a, b)

            self._log.debug(f"Assign BCET {bcet} and WCET {wcet} to ABB {abb_name}")
            abbs.vp.bcet[abb] = bcet
            abbs.vp.wcet[abb] = wcet

            if abbs.vp.loop_head[abb]:
                lb = next(unique_number) % 10
                self._log.debug(f"Assign the loop bound {lb} to ABB {abb_name}")
                abbs.vp.loop_bound[abb] = lb
