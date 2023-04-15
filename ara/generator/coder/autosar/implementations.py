from ara.os.autosar import *


class BaseImpl:

    def __init__(self, instance):
        self.instance = instance

    def __repr__(self):
        return '<' + '|'.join(
            [str((k, v))
             for k, v in self.__dict__.items() if k != 'instance']) + '>'


class TaskImpl(BaseImpl):
    task_id_counter = 1

    def __init__(self, instance):
        super().__init__(instance)
        # Stack
        self.stack = None
        self.stackptr = None
        self.stacksize = None
        self.task_id = TaskImpl.task_id_counter
        TaskImpl.task_id_counter += 1
        self.entry_function = None
        self.task_descriptor = None
        self.tcb_descriptor = None
        self.present = None

        self.generated_functions = []


class SpinlockImpl(BaseImpl):
    spinlock_id_counter = 0

    def __init__(self, instance):
        super().__init__(instance)
        self.id = 1 << SpinlockImpl.spinlock_id_counter
        SpinlockImpl.spinlock_id_counter += 1


class EventImpl(BaseImpl):

    def __init__(self, instance):
        super().__init__(instance)
        self.name = None


class AlarmImpl(BaseImpl):

    def __init__(self, instance):
        super().__init__(instance)
        self.alarm_id = None
        self.name = None
        self.alarm_desc = None
        self.counter = None
        self.event = None
        self.task = None
        self.armed = None


class ResourceImpl(BaseImpl):

    def __init__(self, instance):
        super().__init__(instance)
        self.static_priority = None
        self.prev_prio = None


def add_impl(instance):
    if isinstance(instance, Task):
        instance.impl = TaskImpl(instance)
    elif isinstance(instance, Spinlock):
        instance.impl = SpinlockImpl(instance)
    elif isinstance(instance, TaskGroup):
        instance.impl = None
    elif isinstance(instance, Event):
        instance.impl = EventImpl(instance)
    elif isinstance(instance, Alarm):
        instance.impl = AlarmImpl(instance)
    elif isinstance(instance, IRQ):
        instance.impl = None
    elif isinstance(instance, ISR):
        instance.impl = None
    elif isinstance(instance, Resource):
        instance.impl = ResourceImpl(instance)
    elif isinstance(instance, Counter):
        instance.impl = None
    else:
        raise ValueError("Unknown Type:", type(instance))
