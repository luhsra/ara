from .base import BaseCoder
from .elements import StructDataObject, DataObjectArray, DataObject

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
        end = prev
        for index, task in enumerate(self.tasks):
            task.impl.tcb['xStateListItem']['pxPrevious'] = prev.address
            task.impl.tcb['xStateListItem']['pxContainer'] = self.address
            print(prev)
            prev['pxNext'] = task.impl.tcb['xStateListItem'].address
            prev = task.impl.tcb['xStateListItem']
        self.tasks[-1].impl.tcb['xStateListItem']['pxNext'] = self['xListEnd'].address
        self['xListEnd']['pxPrevious'] = self.tasks[-1].impl.tcb['xStateListItem'].address


class VanillaTasksLists(DataObjectArray):
    def __init__(self, name, max_prio, tasks):
        DataObjectArray.__init__(self,
                                 "PRIVILEGED_DATA List_t",
                                 name,
                                 max_prio)
        self.tasks = tasks
        self.current_tcb = None
        self.used_prios = []
        for prio in range(max_prio):
            p_tasks = [t for t in tasks if t.priority == prio]
            self[prio] = self.arch.TaskList(p_tasks, self, prio)
            #print('after insert', self[prio]['xListEnd'].address)
            if p_tasks:
                self.current_tcb = p_tasks[-1].impl.tcb
                self.used_prios.append(prio)

    @property
    def top_ready_prio(self):
        #TODO: get prio encoding from config: configUSE_PORT_OPTIMISED_TASK_SELECTION
        #assume we encode port optimized
        is_bit_encoded = True
        if(is_bit_encoded):
            return " | ".join([f"1 << {p}" for p in self.used_prios])
        return str(max(self.used_prios))



class VanillaTCB(StructDataObject):
    def __init__(self, task, initialized, **kwargs):
        StructDataObject.__init__(self,
                                    "TCB_t", f"{task.name}_tcb",
                                  **kwargs)
        self.task = task
        task.impl.tcb = self

        if not initialized:
            return
        self['uxPriority'] = task.priority
        self['pxTopOfStack'] = task.impl.stack.tos
        self['pxStack'] = f"(StackType_t*) &{task.impl.stack.name}"
        self['pcTaskName'] = f'"{task.name}"'
        self['uxBasePriority'] = f"{task.priority}"
        self['xStateListItem'] = self.arch.ListItem('xStateListItem')
        self['xEventListItem'] = self.arch.ListItem('xEventListItem')

class VanillaListItem(StructDataObject):
    def __init__(self, name, mini=False):
        tn = 'MiniListItem_t' if mini else 'ListItem_t'
        StructDataObject.__init__(self, tn, name)
        self.mini = mini
        self['pxNext'] = DataObject('ListItem_t *', 'pxNext', 'NULL')
        self['pxPrevious'] = DataObject('ListItem_t *', 'pxPrevious', 'NULL')
        if mini:
            return
        self['xItemValue'] = 0
        self['pvOwner'] = lambda:self.container.address
        self['pvContainer'] = 'NULL'

    def static_initializer(self, indent=2):
        self['pxNext'].do_cast = True
        self['pxPrevious'].do_cast = True
        return StructDataObject.static_initializer(self, indent)


class GenericArch(BaseCoder):
    ListItem = VanillaListItem
    TaskList = VanillaTaskList
    TasksLists = VanillaTasksLists
    TCB = VanillaTCB

    def __init__(self):
        BaseCoder.__init__(self)
        self.ListItem.arch = self
        self.TaskList.arch = self
        self.TasksLists.arch = self
        self.TCB.arch = self


    def generate_linkerscript(self):
        self.logger.warning("generate_linkerscript not implemented: %s",
                            self)

    def generate_default_interrupt_handlers(self):
        self.logger.warning("generate_default_interrupt_handlers not implemented: %s",
                            self)

    def generate_startup_code(self):
        self.logger.warning("generate_startup_code not implemented: %s", self)



    pass
