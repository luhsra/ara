"""Container for Generator."""
import os
import sys

from ara.graph import Graph
from .step import Step
from .option import Option, Choice, String

from ara.generator import *
from ara.generator.Generator import Generator as GenImpl



class Generator(Step):
    """Generate whole OS code based on the previous analyses."""

    arch_choices = {'arm':ArmArch}

    os_choices = {'freertos': FreeRTOSGenericOS}

    syscall_choices= {'vanilla': VanillaSystemCalls,
                      'generic_static': StaticFullSystemCalls,
                      'generic_initialized': InitializedFullSystemCalls,
                      'passthrough': VanillaSystemCalls,
                      'instance_specialized': lambda: exec('raise NotImplementedError()'),
    }

    arch = Option(name="arch",
                  help='the hardware architecture',
                  ty=Choice(*arch_choices.keys()))
    os = Option(name="os",
                help='the os api',
                ty=Choice(*os_choices.keys()))
    syscall_style = Option(name="syscall_style",
                           help='style of resulting syscalls',
                           ty=Choice(*syscall_choices.keys()))
    out_file = Option('generator_output',
                        help='file to write the generated OS into',
                        ty=String())
    dep_file = Option('dependency_file',
                      help='file to write make-style dependencies into for build system integration',
                      ty=String())

    def get_single_dependencies(self):
        self._log.warn("get_dependencies: style: %s", self.syscall_style.get())
        if self.syscall_style.get() == 'passthrough':
            return ['IRReader']
        return ['InstanceGraph']

    def run(self):
        # self._log.info("Executing Generator step.")
        # opt = self.dummy_option.get()
        # if opt:
        #     self._log.info(f"Option is {opt}.")
        assert self.out_file.get(), "No output folder given"

        arch_rules = self.arch_choices[self.arch.get()]()
        os_rules = self.os_choices[self.os.get()]()
        syscall_rules = self.syscall_choices[self.syscall_style.get()]()
        gen = GenImpl(ara_graph=self._graph,
                      ara_step=self,
                      arch_rules=arch_rules,
                      os_rules=os_rules,
                      syscall_rules=syscall_rules,
                      _log=self._log)

        gen.generate(self.out_file.get(), passthrough=self.syscall_style.get()=='passthrough')

        dep_file = self.dep_file.get()
        if dep_file:
            self._log.info("generate depfile: %s", dep_file)
            ara_file = sys.modules['ara'].__file__
            base_path = os.path.dirname(ara_file)
            src_files = [getattr(m, '__file__') for m in sys.modules.values()
                         if base_path in (getattr(m, '__file__', '') or "")]
            with open(dep_file, 'w') as fd:
                fd.write(gen.file_prefix + ": ")
                fd.write("\\\n".join(src_files))
