#!/usr/bin/env python3
import importlib
import json
import logging
import sys
from versuchung.types import String
from versuchung.experiment import Experiment
from versuchung.tex import DatarefDict
from versuchung.files import File

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

class ColoredFormatter(logging.Formatter):
    """Formatter that can be used to log with ARAs loglevel colors"""
    LOGLEVEL_COLOR = {
        "WARNING": "\033[1;33mWARNING \033[1;0m",
        "ERROR":   "\033[1;41mERROR   \033[1;0m",
        "DEBUG":   "\033[1;32mDEBUG   \033[1;0m",
        "INFO":    "\033[1;34mINFO    \033[1;0m"
    }
    def format(self, record):
        old_levelname = record.levelname
        record.levelname = self.LOGLEVEL_COLOR[old_levelname]
        output = logging.Formatter.format(self, record)
        record.levelname = old_levelname
        return output

class InstanceGraphExperiment(Experiment):
    inputs = {"llvm_ir" : String(), # path to llvm_ir
              "custom_step_settings": String(), # path to custom step settings file (This file must not contain a steps field) (optional)
              "os": String(), # using os model (optional. Default is auto)
              "log_file": String("output.log"), # path to the log file in which log output is to be redirected
              }
              # TODO: Add support for --oilfile
              # No --manual-corrections support
    outputs = {"results": DatarefDict(filename=f"results.dref"),
               "graph": File("graph.dot")} # path to the instance graph to be generated

    def _init_logging(self):
        """Redefines root logger to output in ARA fashion and write log output to log_file"""
        file_handler = logging.FileHandler(self.inputs.log_file.value)
        stdout_handler = logging.StreamHandler(sys.stdout)
        max_l = max([len(logging.getLevelName(l)) for l in range(logging.CRITICAL)])
        format_str = f'%(asctime)s %(levelname)-{max_l}s %(name)-{20+1}s %(message)s'
        formatter = logging.Formatter(format_str)
        color_formatter = ColoredFormatter(format_str)
        file_handler.setFormatter(formatter)
        stdout_handler.setFormatter(color_formatter)
        logging.root.handlers.clear()
        logging.root.addHandler(stdout_handler)
        logging.root.addHandler(file_handler)
        self.logger = logging.getLogger(self.__class__.__name__)

    def _get_config(self, i_file: str):
        """Return the default common config."""
        return {'log_level': logging.getLevelName(logging.root.level).lower(), # Loglevel is set by versuchung (you can control it with: -v)
                'dump_prefix': self.dump_prefix,
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
                self.logger.info(f"\drefset{{{masterkey}{key}}}{{{value}}}")
                self.outputs.results[f"{masterkey}{key}"] = value

    def _json_to_dref(self, path: str, masterkey: str=""):
        """Read data of JSON file and convert to /drefset{} commands in .dref output"""
        with open(path, 'r') as json_file:
            json_dump = json.load(json_file)
            self._json_to_dref_rec(json_dump, masterkey)

    def _is_arg_set(self, arg):
        return type(arg.value) == str and arg.value != ""

    def _get_dump_path(self, step: str, suffix: str):
        return self.dump_prefix.replace('{step_name}', step) + suffix

    def run(self):
        self._init_logging()
        if not self._is_arg_set(self.inputs.llvm_ir):
            self.logger.error("No LLVM IR file provided! Please set --llvm_ir")
            raise RuntimeError("No LLVM IR file provided!")
        self.dump_prefix = '../dumps/Experiment.' + self.metadata["experiment-hash"] + '.{step_name}'
        conf = self._get_config(self.inputs.llvm_ir.value)
        step_settings = dict()
        if self._is_arg_set(self.inputs.custom_step_settings):
            with open(self.inputs.custom_step_settings.value, 'r') as json_file:
                step_settings = json.load(json_file)
        assert "steps" not in step_settings, "Do not provide steps field in custom step settings"
        # explicitly run the InteractionAnalysis to trigger it before the statistic steps
        step_settings["steps"] = list([dict({"name": x, "dump": True}) for x in ["InteractionAnalysis",
                                                                                 "CFGStats",
                                                                                 "CallGraphStats",
                                                                                 "InstanceGraphStats"]])
        self.logger.debug(f"Apply conf: {conf}")
        self.logger.debug(f"Apply step_settings: {step_settings}")

        g = Graph()
        if self._is_arg_set(self.inputs.os):
            if self.inputs.os.value not in get_os_model_names():
                self.logger.error(f"Unknown os model {self.inputs.os.value}!")
                raise RuntimeError("Unknown os model {self.inputs.os.value}!")
            g.os = get_os_model_by_name(self.inputs.os.value)
        s_manager = StepManager(g)    
        s_manager.execute(conf, step_settings, None)
        self._json_to_dref(self._get_dump_path("CFGStats", ".json"), masterkey="CFGStats")
        self._json_to_dref(self._get_dump_path("CallGraphStats", ".json"), masterkey="CallGraphStats")
        self._json_to_dref(self._get_dump_path("InstanceGraphStats", ".json"))
        self.outputs.graph.copy_contents(self._get_dump_path("InteractionAnalysis", "..dot"))
        print(f"collected data is in {self.path}")

if __name__ == "__main__":
    experiment = InstanceGraphExperiment()
    experiment(sys.argv)
