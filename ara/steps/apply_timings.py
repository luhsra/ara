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

        if timings is not None and create_timings is not None:
            self._fail("specify either timings or create_timings")

        # register self as successor of CreateABBs
        step_config = {"name": self.get_name()}
        # TODO specifying only the config of this execution does not work,
        # check why
        # {"steps": ["LoadOIL", {"name":"ApplyTimings", "create_timings": "' +  app['full_name'] +'.empty_timing.json"}]}
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
                    f.write(f'  "{abbs.vp.name[abb]}": {{"function": "{cfg.vp.name[func]}", "bcet": 0, "wcet": 0}}')
                    first = False
                f.write("\n}\n")
            return

        # assign times
        if timings:
            # TODO avoid duplicate assignments if step is executed multiple
            # times
            self._log.debug("Assign times.")
            abb_map = dict([(abbs.vp.name[x], x) for x in abbs.vertices()
                            if abbs.vp.type[x] == ABBType.computation])
            with open(timings, 'r') as f:
                times = json.load(f)

            for abb_name, attrs in times.items():
                abb = abb_map.get(abb_name, None)
                if abb is None:
                    continue

                func = cfg.vp.name[cfg.get_function(cfg.vertex(abb))]
                if func != attrs["function"]:
                    self._fail(f"Function {func} does not match {attrs['function']} for ABB {abb_name}")

                self._log.debug(f"Assign BCET {attrs['bcet']} and WCET {attrs['wcet']} to ABB {abb_name}")
                abbs.vp.bcet[abb] = attrs["bcet"]
                abbs.vp.wcet[abb] = attrs["wcet"]
