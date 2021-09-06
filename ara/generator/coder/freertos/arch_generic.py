from ..base import BaseCoder
from ..elements import StructDataObject, DataObjectArray, DataObject
from ara.os.freertos import Queue, Mutex

class VanillaTaskList(StructDataObject):
    def __init__(self, tasks, container, index):
        StructDataObject.__init__(self, "PRIVILEGED_DATA List_t", str(index))
        self.container = container
        self.tasks = tasks
        self['xListEnd'] = self.arch.ListItem('xListEnd', mini=True)
        self['uxNumberOfItems'] = str(len(tasks))
        self['pxIndex'] = f'(ListItem_t*) {self["xListEnd"].address}'

        self.enqueue_tasks()

    def enqueue_tasks(self):
        if not self.tasks:
            return
        prev = self['xListEnd']
        for index, task in enumerate(self.tasks):
            task.impl.tcb['xStateListItem']['pxPrevious'] = prev.address
            task.impl.tcb['xStateListItem']['pxContainer'] = self.address
            #print(prev)
            prev['pxNext'] = task.impl.tcb['xStateListItem'].address
            prev = task.impl.tcb['xStateListItem']
        self.tasks[-1].impl.tcb['xStateListItem']['pxNext'] = self['xListEnd'].address
        self['xListEnd']['pxPrevious'] = self.tasks[-1].impl.tcb['xStateListItem'].address


class VanillaTasksLists(DataObjectArray):
    def __init__(self, name, max_prio, tasks, prio_is_bit_encoded):
        DataObjectArray.__init__(self,
                                 "PRIVILEGED_DATA List_t",
                                 name,
                                 max_prio)
        self.tasks = tasks
        self.current_tcb = None
        self.prio_is_bit_encoded = prio_is_bit_encoded
        self.used_prios = []
        for prio in range(max_prio):
            # skip tasks where xTaskCreate is called after the scheduler starts
            p_tasks = [t for t in tasks if (t.priority == prio
                                            and t.specialization_level == 'initialized'
                                            and not t.after_scheduler)]
            self[prio] = self.arch.TaskList(p_tasks, self, prio)
            #print('after insert', self[prio]['xListEnd'].address)
            if p_tasks:
                self.current_tcb = p_tasks[-1].impl.tcb
                self.used_prios.append(prio)

    @property
    def top_ready_prio(self):
        if(self.prio_is_bit_encoded):
            return " | ".join([f"1 << {p}" for p in self.used_prios])
        return str(max(self.used_prios))



class VanillaTCB(StructDataObject):
    def __init__(self, task, initialized, name_length, **kwargs):
        StructDataObject.__init__(self,
                                    "TCB_t", f"t{task.name}_{task.uid}_tcb",
                                  **kwargs)
        self.task = task
        task.impl.tcb = self

        if not initialized:
            return
        self['uxPriority'] = task.priority
        self['pxTopOfStack'] = task.impl.stack.tos
        self['pxStack'] = f"(StackType_t*) &{task.impl.stack.name}"
        name = [f"'{task.name[i]}'" for i in range(min(len(task.name), name_length-1))]
        name.append('0')
        self['pcTaskName'] = "{" + ", ".join(name) + "}"
        self['uxBasePriority'] = f"{task.priority}"
        self['xStateListItem'] = self.arch.ListItem('xStateListItem')
        self['xEventListItem'] = self.arch.ListItem('xEventListItem')

class VanillaListItem(StructDataObject):
    def __init__(self, name, mini=False):
        tn = 'MiniListItem_t' if mini else 'ListItem_t'
        StructDataObject.__init__(self, tn, name)
        self.mini = mini
        # empty lists are mini loops
        self['pxNext'] = DataObject('ListItem_t *', 'pxNext', lambda: self.address)
        self['pxPrevious'] = DataObject('ListItem_t *', 'pxPrevious', lambda: self.address)
        if mini:
            return
        self['xItemValue'] = 0
        self['pvOwner'] = lambda:self.container.address
        self['pvContainer'] = 'NULL'

    def static_initializer(self, indent=2):
        self['pxNext'].do_cast = True
        self['pxPrevious'].do_cast = True
        return StructDataObject.static_initializer(self, indent)

class VanillaListHead(StructDataObject):
    def __init__(self, name):
        StructDataObject.__init__(self, 'List_t', name)
        self['pxIndex'] = DataObject('ListItem_t *', 'pxIndex')
        self['xListEnd'] = self.arch.ListItem('xListEnd', mini=True)
        self['xListEnd']['xItemValue'] = 'portMAX_DELAY'
        self['xListEnd']['pxNext'] = lambda: self['xListEnd'].address
        self['xListEnd']['pxPrevious'] = lambda: self['xListEnd'].address
        self['uxNumberOfItems'] = 0
        self['pxIndex'] = lambda: self['xListEnd'].address
        self['pxIndex'].do_cast = True
        self['xListEnd']['pxNext'].do_cast = True
        self['xListEnd']['pxPrevious'].do_cast = True

class VanillaQueue(StructDataObject):
    def __init__(self, queue, **kwargs):
        StructDataObject.__init__(self,
                                  "Queue_t", f"__queue_head_{queue.name}{queue.uid}",
                                  **kwargs)
        self.queue = queue
        queue.impl.head = self

        assert queue.specialization_level != 'unchanged' , "Queue is to be generated but is marked as 'unchanged': %s"
        if queue.specialization_level == 'static':
            return
        try:
            length = queue.length
            size = queue.size
        except Error as e:
            queue.specialization_level = 'unchanged'
            self.arch._log.warning("Queue: fallback to unchanged: %s", e)
            return
        self['pcHead'] = DataObject('int8_t*', 'pcHead')
        self['pcWriteTo'] = DataObject('int8_t*', 'pcWriteTo')
        if isinstance(queue, Queue):
            self['pcWriteTo'] = queue.impl.data.address
            self['pcHead'] = queue.impl.data.address
            self['u'] = StructDataObject("NONE", 'u')
            self['u']['xQueue'] = StructDataObject('QueuePointers_t', 'xQueue')
            self['u']['xQueue']['pcTail'] = DataObject('int8_t*', 'pcTail')
            self['u']['xQueue']['pcTail'] = (f"{queue.impl.data.address} +"
                                             f"({length} * {size})")
            self['u']['xQueue']['pcTail'].do_cast = True
            self['u']['xQueue']['pcReadFrom'] = DataObject('int8_t*', 'pcReadFrom')
            self['u']['xQueue']['pcReadFrom'] = (f"{queue.impl.data.address} +"
                                                 f"(({length} - 1U) *"
                                                 f"{size})")
            self['u']['xQueue']['pcReadFrom'].do_cast = True
        elif isinstance(queue, Mutex):
            self['u'] = StructDataObject("NONE", 'u')
            self['u']['xSemaphore'] = StructDataObject("NONE", "xSemaphore")
            self['u']['xSemaphore']['xMutexHolder'] = 'NULL'
            self['u']['xSemaphore']['uxRecursiveCallCount'] = 0
            self['pcHead'] = 'NULL' # aka. uxQueueType = 'queueQUEUE_IS_MUTEX'
            self['pcWriteTo'] = 'nullptr'
            self['uxMessagesWaiting'] = 1 # aka. xQueueGenericSend()
        else:
            raise RuntimeError(f"unknown queue type: {type(queue)}")
        self['xTasksWaitingToSend'] = VanillaListHead("xTasksWaitingToSend")
        self['xTasksWaitingToReceive'] = VanillaListHead("xTasksWaitingToReceive")
        self['uxLength'] = length
        self['uxItemSize'] = size
        self['cRxLock'] = "queueUNLOCKED"
        self['cTxLock'] = "queueUNLOCKED"
        self['pcHead'].do_cast = True
        self['pcWriteTo'].do_cast = True


class GenericArch(BaseCoder):
    ListItem = VanillaListItem
    ListHead = VanillaListHead
    TaskList = VanillaTaskList
    TasksLists = VanillaTasksLists
    TCB = VanillaTCB
    QUEUE = VanillaQueue

    def __init__(self):
        BaseCoder.__init__(self)
        self.ListHead.arch = self
        self.ListItem.arch = self
        self.TaskList.arch = self
        self.TasksLists.arch = self
        self.TCB.arch = self
        self.QUEUE.arch = self


    def generate_linkerscript(self):
        self._log.error("generate_linkerscript not implemented: %s",
                            self)

    def generate_default_interrupt_handlers(self):
        self._log.error("generate_default_interrupt_handlers not implemented: %s",
                            self)

    def generate_startup_code(self):
        self._log.error("generate_startup_code not implemented: %s", self)

    def generate_data_objects(self):
        pass
    def generate_system_code(self):
        pass
