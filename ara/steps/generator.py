"""Container for Generator."""
import os
import sys

from ara.graph import Graph
from .step import Step
from .option import Option, Choice, String

from ara.generator import *
from ara.generator.Generator import Generator as GenImpl

from ara.generator.coder.freertos import FreeRTOSGenericOS



class Generator(Step):
    """Generate whole OS code based on the previous analyses."""

    os_choices = {'freertos': FreeRTOSGenericOS}

    arch_choices = []
    instantiation_choices = []
    interaction_choices = []
    for os in os_choices.values():
        arch_choices += os.arch_choices.keys()
        instantiation_choices += os.instantiation_choices
        interaction_choices += os.interaction_choices


    arch = Option(name="arch",
                  help='the hardware architecture',
                  ty=Choice(*arch_choices))
    os = Option(name="os",
                help='the os api',
                ty=Choice(*os_choices))
    instantiation_style = Option(name="instantiation_style",
                           help='style of resulting instantiation syscalls',
                           ty=Choice(*instantiation_choices))
    interaction_style = Option(name="interaction_style",
                           help='style of resulting interaction syscalls',
                           ty=Choice(*interaction_choices))
    out_file = Option('generator_output',
                        help='file to write the generated OS into',
                        ty=String())
    dep_file = Option('dependency_file',
                      help='file to write make-style dependencies into for build system integration',
                      ty=String())

    def get_single_dependencies(self):
        self._log.warn("get_dependencies: style: %s", self.instantiation_style.get())
        if self.instantiation_style.get() == 'passthrough':
            return ['IRReader']
        return ['SIA', 'ManualCorrections']

    def run(self):
        # self._log.info("Executing Generator step.")
        # opt = self.dummy_option.get()
        # if opt:
        #     self._log.info(f"Option is {opt}.")
        assert self.out_file.get(), "No output folder given"

        os_rules = self.os_choices[self.os.get()]()
        arch_rules = os_rules.arch_choices[self.arch.get()]()
        instantiation_rules =os_rules.instantiation_choices[self.instantiation_style.get()]()
        interaction_rules = os_rules.interaction_choices[self.interaction_style.get()]()
        gen = GenImpl(ara_graph=self._graph,
                      ara_step=self,
                      arch_rules=arch_rules,
                      os_rules=os_rules,
                      instantiation_rules=instantiation_rules,
                      interaction_rules=interaction_rules,
                      _log=self._log)

        gen.generate(self.out_file.get(), passthrough=self.instantiation_style.get()=='passthrough')

        dep_file = self.dep_file.get()
        if dep_file:
            self._log.info("generate depfile: %s", dep_file)
            ara_file = sys.modules['ara'].__file__
            base_path = os.path.dirname(ara_file)
            src_files = [getattr(m, '__file__') for m in sys.modules.values()
                         if base_path in (getattr(m, '__file__', '') or "")]
            src_files += gen.get_dependencies()
            with open(dep_file, 'w') as fd:
                fd.write(gen.file_prefix + ": ")
                fd.write("\\\n".join(src_files))

        if self.dump.get():
            self._step_manager.chain_step({"name": "Printer",
                                           "dot": self.dump_prefix.get(),
                                           "graph_name": 'Generated Instances',
                                           "subgraph": 'instances'})
