from steps.freertos import Task, Queue, Mutex
import logging

class BaseImpl:
    def __init__(self, instance):
        self.instance = instance
        self.init = None
    def __repr__(self):
        return '<' + '|'.join([str((k,v)) for k,v in self.__dict__.items() if k != 'instance']) + '>'

class TaskImpl(BaseImpl):
    def __init__(self, instance):
        super().__init__(instance)
        self.stack = None
        self.stackptr = None
        self.tcb = None
        self.tcbptr = None

class QueueImpl(BaseImpl):
    def __init__(self, instance):
        super().__init__(instance)
        self.head = None
        self.data = None

class MutexImpl(QueueImpl):
    pass


def add_impl(instance):
    if isinstance(instance, Task):
        instance.impl = TaskImpl(instance)
    elif isinstance(instance, Queue):
        instance.impl = QueueImpl(instance)
    elif isinstance(instance, Mutex):
        instance.impl = MutexImpl(instance)
    else:
        raise ValueError("Unknown Type:", type(instance))
