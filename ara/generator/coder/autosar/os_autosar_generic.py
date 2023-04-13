import os

from .os_generic import GenericOS
from ..elements.IncludeManager import Include

from .arch_posix import PosixArch

from .syscall_generic import GenericSystemCalls
from .syscall_specialized import SpecializedSystemCalls
from .implementations import add_impl as _add_impl

from ..elements import CodeTemplate, Function

from ara.os.autosar import Resource, Task, Event



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
        return SpecializedSystemCalls

    def get_arch_rules(self, arch):
        return self.arch_choices[arch]


    @staticmethod
    def add_impl(instance):
        _add_impl(instance)


class TaskListTemplate(CodeTemplate):
    def __init__(self, rules):
        CodeTemplate.__init__(self, rules.generator, self.template_file())
        self.rules = rules
        self.ara_graph = self.generator.ara_graph

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
        task_vertex = self.ara_graph.instances.get_node(self._subtask)
        vertex_neighbors = task_vertex.out_neighbors()
        objects = [self.ara_graph.instances.vp.obj[n] for n in vertex_neighbors]
        if any([isinstance(n, Event) for n in objects]):
            return self.expand_snippet(args[0])
        return ""

    def if_not_preemptable(self, snippet, args):
        if not self._subtask.schedule:
            return self.expand_snippet(args[0])
        return ""

    def scheduler_prio(self, snippet, args):
        task_list_prio = [task.priority for v, task in self.ara_graph.instances.get(Task)]
        return str(max(task_list_prio)+1)

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
        return str(self._subtask.impl.task_id)

    def foreach_subtask(self, snippet, args):
        body = args[0]
        def do(subtask):
            self._subtask = subtask
            return self.expand_snippet(body)
        return self.rules.foreach_subtask(do)

    def if_not_preemptable(self, snippet, args):
        if not self._subtask.schedule:
            return self.expand_snippet(args[0])
        return ""
