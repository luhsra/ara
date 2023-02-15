from ara.os.autosar import Task, Spinlock, TaskGroup

class BaseImpl:
    def __init__(self, instance):
        self.instance = instance
    def __repr__(self):
        return '<' + '|'.join([str((k,v)) for k,v in self.__dict__.items() if k != 'instance']) + '>'

class TaskImpl(BaseImpl):
    def __init__(self, instance):
        super().__init__(instance)
        self.stack = None
        self.stackptr = None
        self.tcb = None
        self.tcbptr = None

class SpinlockImpl(BaseImpl):
    def __init__(self, instance):
        super().__init__(instance)

class TaskGroupImpl(BaseImpl):
    def __init__(self, instance):
        super().__init__(instance)

def add_impl(instance):
    if isinstance(instance, Task):
        instance.impl = TaskImpl(instance)
    elif isinstance(instance, Spinlock):
        instance.impl = SpinlockImpl(instance)
    elif isinstance(instance, TaskGroup):
        instance.impl = TaskGroupImpl(instance)
    else:
        raise ValueError("Unknown Type:", type(instance))
