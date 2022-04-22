#!/usr/bin/env python3
import importlib
import json
import logging
import sys
from versuchung.types import String
from versuchung.experiment import Experiment
from versuchung.tex import DatarefDict

def fake_step_module():
    """Fake the step module into the correct package."""
    import graph_tool
    def load(what, where):
        module = importlib.import_module(what)
        sys.modules[where] = module

    load("graph_data", "ara.graph.graph_data")
    load("py_logging", "ara.steps.py_logging")
    load("step", "ara.steps.step")


fake_step_module()

from ara.stepmanager import StepManager
from ara.graph.graph import Graph
from ara.os import get_os_model_by_name, get_os_model_names

class InstanceGraphExperiment(Experiment):
    inputs = {"llvm_ir" : String(), # path to llvm_ir
              "custom_step_settings": String(), # path to custom step settings file (optional)
              "os": String(), # using os model (optional. Default is auto)
              }
              # TODO: Add support for --oilfile
              # No --manual-corrections support
    outputs = {"results": DatarefDict(filename=f"output.dref")}

    def _get_config(self, i_file):
        """Return the default common config."""
        return {'log_level': logging.getLevelName(logging.root.level).lower(), # Loglevel is set by versuchung (you can control it with: -v)
                'dump_prefix': '../dumps/{step_name}',
                'dump': False,
                'runtime_stats': True,
                'runtime_stats_file': 'logger',
                'runtime_stats_format': 'human',
                'entry_point': 'main',
                'input_file': i_file}

    def _json_to_dref_rec(self, json_dict: dict, masterkey: str=""):
        if masterkey != "":
            masterkey = masterkey + "/"
        for key, value in json_dict.items():
            if type(value) == dict:
                self._json_to_dref_rec(value, f"{masterkey}{key}")
            else:
                logging.info(f"\drefset{{{masterkey}{key}}}{{{value}}}")
                self.outputs.results[f"{masterkey}{key}"] = value

    def _json_to_dref(self, path: str, masterkey: str=""):
        """Read data of JSON file and convert to /drefset{} commands in .dref output"""
        with open(path, 'r') as json_file:
            json_dump = json.load(json_file)
            self._json_to_dref_rec(json_dump, masterkey)

    def _is_arg_set(self, arg):
        return type(arg.value) == str and arg.value != ""

    def run(self):
        if not self._is_arg_set(self.inputs.llvm_ir):
            logging.error("No LLVM IR file provided! Please set --llvm_ir")
            raise RuntimeError("No LLVM IR file provided!")
        conf = self._get_config(self.inputs.llvm_ir.value)
        if self._is_arg_set(self.inputs.custom_step_settings):
            with open(self.inputs.custom_step_settings.value, 'r') as json_file:
                step_settings = json.load(json_file)
        else:
            step_settings = {"CFGStats": {"dump": True}, "InteractionAnalysis": {"dump": True}, "InstanceGraphStats": {"dump": True}}
        logging.debug(f"Apply conf: {conf}")
        logging.debug(f"Apply step_settings: {step_settings}")

        g = Graph()
        if self._is_arg_set(self.inputs.os):
            if self.inputs.os.value not in get_os_model_names():
                logging.error(f"Unknown os model {self.inputs.os.value}!")
                raise RuntimeError("Unknown os model {self.inputs.os.value}!")
            g.os = get_os_model_by_name(self.inputs.os.value)
        s_manager = StepManager(g)    
        s_manager.execute(conf, step_settings, {"CFGStats", "InstanceGraphStats"} if not self._is_arg_set(self.inputs.custom_step_settings) else None)
        self._json_to_dref("../dumps/CFGStats.json", masterkey="CFGStats")
        self._json_to_dref("../dumps/InstanceGraphStats.json")

if __name__ == "__main__":
    experiment = InstanceGraphExperiment()
    experiment(sys.argv)
    