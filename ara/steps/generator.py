"""Container for Generator."""
import os
import sys

from ara.graph import Graph
from .step import Step
from .option import Option, Choice, String, Bool

from ara.generator import *
from ara.generator.Generator import Generator as GenImpl

from ara.os.freertos import FreeRTOS
from ara.generator.coder.freertos import FreeRTOSGenericOS



class Generator(Step):
    """Generate whole OS code based on the previous analyses."""

    os_choices = {FreeRTOS: FreeRTOSGenericOS}

    arch_choices = []
    for os in os_choices.values():
        arch_choices += os.arch_choices.keys()

    arch = Option(name="arch",
                  help='the hardware architecture',
                  ty=Choice(*arch_choices))
    out_file = Option('generator_output',
                        help='file to write the generated OS into',
                        ty=String())
    dep_file = Option('dependency_file',
                      help='file to write make-style dependencies into for build system integration',
                      ty=String())
    passthrough = Option('passthrough',
                         help='disable all changes, just pipe IR code unchanged',
                         ty=Bool(),
                         default_value=False)

    def get_single_dependencies(self):
        if self.passthrough.get():
            return ['IRReader', 'SysFuncts']
        deps = ['SIA', 'ManualCorrections', 'SysFuncts']
        if self.get_os():
            deps += self.get_os().get_dependencies()
        return deps

    def get_os(self):
        if self._graph.os:
            return self.os_choices[self._graph.os]
        else:
            return None

    def run(self):
        # self._log.info("Executing Generator step.")
        # opt = self.dummy_option.get()
        # if opt:
        #     self._log.info(f"Option is {opt}.")
        assert self.out_file.get(), "No output folder given"

        os_rules = self.get_os()()
        arch_rules = os_rules.get_arch_rules(self.arch.get())()
        syscall_rules = os_rules.get_syscall_rules()()
        gen = GenImpl(ara_graph=self._graph,
                      ara_step=self,
                      arch_rules=arch_rules,
                      os_rules=os_rules,
                      syscall_rules=syscall_rules,
                      _log=self._log)

        gen.generate(self.out_file.get(), passthrough=self.passthrough.get())

        dep_file = self.dep_file.get()
        if dep_file:
            self._log.info("generate depfile: %s", dep_file)
            ara_file = sys.modules['ara'].__file__
            base_path = os.path.dirname(ara_file)
            src_files = [getattr(m, '__file__') for m in sys.modules.values()
                         if base_path in (getattr(m, '__file__', '') or "")]
            src_files += gen.get_dependencies()
            if self._step_manager._config.program['step_settings']:
                src_files += self._step_manager._config.program['step_settings']
            with open(dep_file, 'w') as fd:
                fd.write(gen.file_prefix + ": ")
                fd.write("\\\n".join(src_files))

        if self.dump.get():
            self._step_manager.chain_step({"name": "Printer",
                                           "dot": self.dump_prefix.get(),
                                           "graph_name": 'Generated Instances',
                                           "subgraph": 'instances'})
