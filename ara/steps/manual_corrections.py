"""Container for ManualCorrections."""
from ara.graph import Graph
from .step import Step
from .option import Option, String

import json


class ManualCorrections(Step):
    """Apply manual corrections to the automatically extracted instances."""
    manual_corrections = Option(name="manual_corrections",
                                help="JSON file with instance corrections",
                                ty=String())

    def get_single_dependencies(self):
        return ['SIA']

    def run(self):
        file_name = self.manual_corrections.get()
        if not file_name:
            self._log.warn("manual_corrections argument not set. Skipping...")
            return
        with open(file_name) as f:
            corrections = json.load(f)

        instances = self._graph.instances

        for instance in instances.vertices():
            i_id = instances.vp.id[instance]
            if i_id in corrections:
                self._log.info(f"Modifying {instances.vp.label[instance]} ({i_id})")
                correction = corrections[i_id]
                for prop in correction:
                    if prop == "obj":
                        fail("obj attribute cannot be modified.")
                    self._log.debug(f"Setting {prop} to {correction[prop]}")
                    instances.vp[prop][instance] = correction[prop]

        if self.dump.get():
            self._step_manager.chain_step({"name": "Printer",
                                           "dot": self.dump_prefix.get(),
                                           "graph_name": 'Corrected Instances',
                                           "subgraph": 'instances'})
