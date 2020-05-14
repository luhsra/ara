from steps.freertos import Task, Queue

class TaskImpl:
    def __init__(self):
        self.stack = None
        self.stackptr = None
        self.tcb = None
        self.tcbptr = None
        self.init = None

class QueueImpl:
    def __init__(self):
        self.head = None
        self.data = None
        self.init = None


def add_impl(instance):
    if isinstance(instance, Task):
        instance.impl = TaskImpl()
    elif isinstance(instance, Queue):
        instance.impl = QueueImpl()
    else:
        raise ValueError("Unknown Type:", type(instance))
