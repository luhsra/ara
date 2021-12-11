"""Container for ApplyTimings."""
from .step import Step
from .option import Option, String
from ara.graph import ABBType

import json


class ApplyTimings(Step):
    """Apply timing behavior to atomic basic blocks."""
    timings = Option(name="timings",
                     help="JSON file with timing information (use create_timings for initial creation)",
                     ty=String())
    create_timings = Option(name="create_timings",
                            help="This step can create an example timing file. Set create_timings to its path.",
                            ty=String())

    def get_single_dependencies(self):
        return ['CreateABBs']

    def run(self):
        create_timings = self.create_timings.get()
        timings = self.timings.get()

        # register self as successor of CreateABBs
        step_config = {"name": self.get_name()}
        if create_timings:
            step_config["create_timings"] = create_timings
        if timings:
            step_config["timings"] = timings
        self._step_manager.chain_step(step_config, after="CreateABBs")

        abbs = self._graph.abbs
        cfg = self._graph.cfg

        # handle creation
        if create_timings:
            self._log.info("Create an example timing file.")

            with open(create_timings, 'w') as f:
                f.write("{\n")
                first = True
                for abb in abbs.vertices():
                    if abbs.vp.type[abb] != ABBType.computation:
                        continue
                    if not first:
                        f.write(',\n')
                    func = cfg.get_function(cfg.vertex(abb))
                    f.write(f'\t"{abbs.vp.name[abb]}": {{"function": "{cfg.vp.name[func]}", "time": 0}}')
                    first = False
                f.write("\n}")
            return

        # assign times
        pass
