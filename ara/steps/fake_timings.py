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

    def get_single_dependencies(self):
        return ['CreateABBs']

    def run(self):
        # register self as successor of CreateABBs
        step_config = {"name": self.get_name()}
        self._step_manager.chain_step(step_config, after="CreateABBs")

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
