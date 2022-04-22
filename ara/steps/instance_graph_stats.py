import json
from .step import Step

class InstanceGraphStats(Step):
    """Gather statistics about the Instance Graph."""

    def get_single_dependencies(self):
        return ["InteractionAnalysis"]

    def run(self):
        output_dict = {"instances": {"type": {}},
                       "interactions": {"to_instance_type": {},
                                        "accumulate_number_field": {"to_instance_type": {}}}, # handle number field for this data
                      }

        # Instances
        instances = self._graph.instances
        for instance in instances.vertices():
            inst_obj = instances.vp.obj[instance]
            inst_type_str = type(inst_obj).__name__
            if inst_type_str in output_dict["instances"]["type"]:
                output_dict["instances"]["type"][inst_type_str]["num"] += 1
            else:
                output_dict["instances"]["type"][inst_type_str] = {"num": 1}

        # Interactions
        for edge in instances.edges():
            # Filter special edge types like "same_symbol_than" in Zephyr
            if instances.ep.type[edge] not in [0, "interaction", "create"]:
                continue
            number_prop = instances.ep.number[edge]
            assert number_prop >= 1
            target = instances.vp.obj[edge.target()]
            target_type_str = type(target).__name__
            if target_type_str in output_dict["interactions"]["to_instance_type"]:
                output_dict["interactions"]["to_instance_type"][target_type_str]["num"] += 1
                assert target_type_str in output_dict["interactions"]["accumulate_number_field"]["to_instance_type"]
                output_dict["interactions"]["accumulate_number_field"]["to_instance_type"][target_type_str]["num"] += number_prop
            else:
                output_dict["interactions"]["to_instance_type"][target_type_str] = {"num": 1}
                assert target_type_str not in output_dict["interactions"]["accumulate_number_field"]["to_instance_type"]
                output_dict["interactions"]["accumulate_number_field"]["to_instance_type"][target_type_str] = {"num": number_prop}

        self._log.info(f"Collected data: {output_dict}")

        if self.dump.get():
            with open(self.dump_prefix.get() + '.json', 'w') as f:
                json.dump(output_dict, f, indent=4)
