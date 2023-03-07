from ara.os.autosar import *

class BaseImpl:
    def __init__(self, instance):
        self.instance = instance
    def __repr__(self):
        return '<' + '|'.join([str((k,v)) for k,v in self.__dict__.items() if k != 'instance']) + '>'

class TaskImpl(BaseImpl):
    task_id_counter = 1
    def __init__(self, instance):
        super().__init__(instance)
        # Stack
        self.stack = None
        self.stackptr = None
        self.stacksize = None
        self.task_id = TaskImpl.task_id_counter
        TaskImpl.task_id_counter+=1
        self.entry_function = None
        self.task_descriptor = None
        self.tcb_descriptor = None
        self.present = None


        self.generated_functions = []
class SpinlockImpl(BaseImpl):
    def __init__(self, instance):
        super().__init__(instance)

class TaskGroupImpl(BaseImpl):
    def __init__(self, instance):
        super().__init__(instance)

class EventImpl(BaseImpl):
    def __init__(self, instance):
        super().__init__(instance)
        self.event_mask = None
        self.name = None

class AlarmImpl(BaseImpl):
    def __init__(self, instance):
        super().__init__(instance)
        self.alarm_id   = None
        self.name = None
        self.alarm_desc = None

def add_impl(instance):
    if isinstance(instance, Task):
        instance.impl = TaskImpl(instance)
    elif isinstance(instance, Spinlock):
        instance.impl = SpinlockImpl(instance)
    elif isinstance(instance, TaskGroup):
        instance.impl = TaskGroupImpl(instance)
    elif isinstance(instance, Event):
        instance.impl = EventImpl(instance)
    elif isinstance(instance, Alarm):
        instance.impl = AlarmImpl(instance)
    else:
        raise ValueError("Unknown Type:", type(instance))
