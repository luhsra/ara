import os

from ..os_generic import GenericOS
from ..elements.IncludeManager import Include

from .arch_posix import PosixArch

from .syscall_generic import GenericSystemCalls
from .implementations import add_impl as _add_impl

from ..elements import CodeTemplate, Function

from ara.os.autosar import Resource, Task



class AUTOSARGenericOS(GenericOS):
    def __init__(self):
        super(AUTOSARGenericOS, self).__init__()

        self.return_variables = {}

    arch_choices = {'posix':PosixArch}


    def set_generator(self, generator):
        super().set_generator(generator)

        generator.template_base = os.path.abspath(os.path.join(
            os.path.dirname( __file__ ), "../../../../libs/autosar"))

        # These template slots are used by the system call layer
        self.task_list = TaskListTemplate
        self.scheduler = SchedulerTemplate

    @staticmethod
    def get_dependencies():
        return ['AutosarGeneratorIR']

    def get_syscall_rules(self):
        return GenericSystemCalls

    def get_arch_rules(self, arch):
        return self.arch_choices[arch]

    def generate_data_objects(self):
        pass
        #TODO copy from dosek

    def generate_system_code(self):
        pass

    @staticmethod
    def add_impl(instance):
        _add_impl(instance)


class TaskListTemplate(CodeTemplate):
    def __init__(self, rules):
        CodeTemplate.__init__(self, rules.generator, self.template_file())
        self.rules = rules
        self.ara_graph = self.generator.ara_graph
        #TODO where is the data in the graph
        # self.idle = self.ara_graph.find(Function, "Idle")

    def template_file(self):
        return "os/scheduler/tasklist-unencoded.h.in"

    def subtask(self, snippet, args):
        return self._subtask.name

    def subtask_id(self, snippet, args):
        return str(self._subtask.impl.task_id)

    def subtask_desc(self, snippet, args):
        return self._subtask.impl.task_descriptor.name

    def foreach_subtask(self, snippet, args):
        body = args[0]
        def do(subtask):
            self._subtask = subtask
            return self.expand_snippet(body)
        return self.rules.foreach_subtask(do)

    def if_events(self, snippet, args):
        # TODO support events in tasks
        if len(self._subtask.events) > 0:
            return self.expand_snippet(args[0])
        return ""

    def if_not_preemptable(self, snippet, args):
        if not self._subtask.conf.preemptable:
            return self.expand_snippet(args[0])
        return ""

    def scheduler_prio(self, snippet, args):
        return "0" #TODO
        RES_SCHEDULER = self.system_graph.get(Resource, "RES_SCHEDULER")
        str(RES_SCHEDULER.conf.static_priority)



class SchedulerTemplate(CodeTemplate):
    def __init__(self, rules):
        CodeTemplate.__init__(self, rules.generator, self.template_file())
        self.rules = rules
        self.ara_graph = self.generator.ara_graph

    def template_file(self):
        return "os/scheduler/scheduler.h.in"

    def subtask_desc(self, snippet, args):
        return self._subtask.impl.task_descriptor.name

    def subtask_id(self, snippet, args):
        return self._subtask.name

    def foreach_subtask(self, snippet, args):
        body = args[0]
        def do(subtask):
            self._subtask = subtask
            return self.expand_snippet(body)
        return self.rules.foreach_subtask(do)

    def if_not_preemptable(self, snippet, args):
        if not self._subtask.conf.preemptable:
            return self.expand_snippet(args[0])
        return ""
