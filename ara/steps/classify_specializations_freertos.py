"""Container for ClassifySpecializationsFreeRTOS"""
from ara.graph import Graph
from .step import Step
from .option import Option, Bool
from ara.os.freertos import FreeRTOS, Mutex, Queue, StreamBuffer, Task
import pyllco


def is_castable(obj, classes):
    if not isinstance(classes, list):
        classes = [classes]
    for clazz in classes:
        if isinstance(obj, clazz):
            return True
        try:
            clazz(obj)
            return True
        except:
            pass
    return False



class ClassifySpecializationsFreeRTOS(Step):
    """Classify the FreeRTOS OS Objects by the specialization to be applied."""
    graceful_degrade = Option(name="graceful_degrade",
                              help="Allow to leave syscalls unspecialized. If set to false, non-feasable specialization attempts result in hard errors. (default=True)",
                              default_value=True,
                              ty=Bool())
    static_memory = Option(name="static_memory",
                           help="Is static memory allocation allowed (default=False)",
                           default_value=False,
                           ty=Bool())
    initialized_memory = Option(name="initialized_memory",
                                help="Is initialization of the static memory allowed. Implies static_memory=True",
                                default_value=False,
                                ty=Bool())
    allow_runtime_init = Option(name="allow_runtime_init",
                                help="Allow run-time initialization of single values and structures. Like run-time determination of a task's priority",
                                default_value=False,
                                ty=Bool())


    def get_single_dependencies(self):
        return ["SIA"]

    def run(self):
        self._log.setLevel(0)
        self.classify_os()
        for v in self._graph.instances.vertices():
            obj = self._graph.instances.vp.obj[v]
            ty = type(obj).__name__.lower()
            self._log.debug("Classifying %s '%s': %s", ty, obj.name, obj)
            classifier = getattr(self, f"classify_{ty}",
                                 self.not_implemented_classifier)
            classifier(obj)
            assert obj.specialization_level
            self._log.debug("Classified %s '%s' as %s", ty, obj.name, obj.specialization_level)


    def not_implemented_classifier(self, obj):
        if self.graceful_degrade:
            self._log.error("Classification of %s not implemented. %s --> degrade to unchanged", type(obj), obj)
            obj.specialization_level = "unchanged"
        else:
            self._log.critical("Classification of %s not implemented. %s", type(obj), obj)

    def degrade(self, desired, degraded, obj, prop):
        if self.graceful_degrade:
            self._log.debug("Can't determine %s of %s. Found %s", prop, obj, getattr(obj, prop, None))
            self._log.debug("degrade to %s", degraded)
            obj.specialization_level = degraded
        else:
            self._log.critical("Specialization is not possible and graceful degrade is not allowed")

    def classify_os(self):
        if self.initialized_memory.get():
            self._graph.os.specialization_level = 'initialized'
        elif self.static_memory.get():
            self._graph.os.specialization_level = 'static'
        else:
            self._graph.os.specialization_level = 'unchanged'
        self._graph.os.config['scheduler'] = 'vanilla'

    def classify_task(self, obj):
        if not obj.unique:
            return self.degrade('any', 'unchanged', obj, 'unique')
        prio_known = is_castable(obj.priority, int)
        stack_size_known = is_castable(obj.stack_size, int)
        func_known = is_castable(obj.function, [pyllco.Constant, str])
        parameters_known = is_castable(obj.parameters, [pyllco.Constant, int, str])
        targets = self._graph.cfg.get_call_targets(obj.abb) if obj.abb else None
        names = [self._graph.cfg.vp.name[f] for f in targets] if targets else None
        if 'xTaskCreateStatic' in names:
            return self.degrade('any', 'unchanged', obj, 'already static')
        if not stack_size_known:
            return self.degrade('any', 'unchanged', obj, 'stack_size')
        if self.initialized_memory.get():
            if self.allow_runtime_init.get():
                obj.specialization_level = 'initialized'
            else:
                if not prio_known:
                    return self.degrade('initialized', 'static', obj, 'priority')
                elif not func_known:
                    return self.degrade('initialized', 'static', obj, 'function')
                elif not parameters_known:
                    return self.degrade('initialized', 'static', obj, 'parameters')
                else:
                    obj.specialization_level = 'initialized'
        elif self.static_memory.get():
            obj.specialization_level = 'static'
        else:
            obj.specialization_level = 'unchanged'

    def classify_queue(self, obj):
        if not obj.unique:
            return self.degrade('any', 'unchanged', obj, 'unique')
        size_known = is_castable(obj.size, int)
        length_known = is_castable(obj.length, int)
        if not length_known:
            return self.degrade('any', 'unchanged', obj, 'length')
        if not length_known:
            return self.degrade('any', 'unchanged', obj, 'length')
        if self.initialized_memory.get():
            obj.specialization_level = 'initialized'
        elif self.static_memory.get():
            obj.specialization_level = 'static'
        else:
            obj.specialization_level = 'unchanged'

    def classify_mutex(self, obj):
        return self.classify_queue(obj)
