from .syscall_generic import GenericSystemCalls
from .elements import (DataObjectArray, DataObject, Function, FunctionCall,
                       CPPStatement,
                       Statement, Include, InstanceDataObject, StructDataObject,
                       FunctionDeclaration)
from steps.freertos import Task






class InitializedFullSystemCalls(GenericSystemCalls):

    def generate_data_objects(self):
        '''generate the data objects for tasks and queues'''
        #TODO: QueueStorage
        #TODO: Queue Verwaltungsstruktur
        self.generator.source_file.includes.add(
            Include('InitializedFreeRTOSObjects.h'))
        task_list = [self.ara_graph.instances.vp.obj[v]
                     for v in self.ara_graph.instances.vertices()
                     if isinstance(self.ara_graph.instances.vp.obj[v], Task)]
        self.generate_dataobjects_task_stacks(task_list)
        self.generate_data_objects_tcb_mem(task_list)
        self.generate_data_objects_ready_list(task_list)
        self.generate_limitation_warnings()

    def generate_dataobjects_task_stacks(self, task_list):
        '''generate the stack space for the tasks'''
        for task in task_list:
            self.arch_rules.initialized_stack(task)

    def generate_data_objects_tcb_mem(self, task_list):
        '''generate the memory for the tcbs'''
        for task in task_list:
            self.arch_rules.static_unchanged_tcb(task, initialized=True)
            if not task.is_regular and task.name == 'idle_task':
                self.generator.source_file.data_manager.add(
                    DataObject('PRIVILEGED_DATA TaskHandle_t',
                               'xIdleTaskHandle',
                               task.impl.tcb.address))


    def generate_system_code(self):
        super().generate_system_code()
        task_list = [self.ara_graph.instances.vp.obj[v]
                     for v in self.ara_graph.instances.vertices()
                     if isinstance(self.ara_graph.instances.vp.obj[v], Task)]
        self.generate_system_code_init_tasks(task_list)


    def generate_system_code_init_tasks(self, task_list):
        self.generator.source_file.includes.add(Include('task.h'))
        idle_task = None
        for task in task_list:
            if not task.is_regular:
                if task.name == 'idle_task':
                    idle_task = task
                    self._log.debug("IdleTask: %s", task)
                continue
            self._log.debug("Generating init function call for %s", task)
            start_func = FunctionDeclaration(task.function,
                                             'void',
                                             ['void *'],
                                             extern_c=True)
            self.generator.source_file.function_manager.add(start_func)

        dummy_xTaskCreate = Function('xTaskCreate',
                                     'BaseType_t',
                                     ['TaskFunction_t',
                                      'const char *',
                                      'const uint32_t',
                                      'void * const',
                                      'UBaseType_t',
                                      'TaskHandle_t *'
                                      ])
        dummy_xTaskCreate.add(Statement("return pdPASS"))
        self.generator.source_file.function_manager.add(dummy_xTaskCreate)

    def generate_data_objects_ready_list(self, tasks):
        #TODO: max prio from analyzer
        #max_prio = self.ara_graph.get_config('configMAX_PRIORITIES')
        max_prio = 5

        # ready_lists = DataObjectArray("PRIVILEGED_DATA List_t", "pxReadyTasksLists", 'configMAX_PRIORITIES')
        ready_lists = self.arch_rules.TasksLists("pxReadyTasksLists",
                                                 max_prio,
                                                 tasks)
        self.generator.source_file.data_manager.add(ready_lists)


        self.generator.source_file.data_manager.add(
            DataObject('PRIVILEGED_DATA TCB_t * volatile',
                       'pxCurrentTCB',
                       ready_lists.current_tcb.address))

        self.generator.source_file.data_manager.add(
            DataObject('PRIVILEGED_DATA volatile UBaseType_t',
                       'uxTopReadyPriority',
                       ready_lists.top_ready_prio))


        self.generator.source_file.data_manager.add(
            DataObject('PRIVILEGED_DATA UBaseType_t',
                       'uxTaskNumber',
                       str(len(tasks))))

        self.generator.source_file.data_manager.add(
            DataObject('PRIVILEGED_DATA UBaseType_t',
                       'uxCurrentNumberOfTasks',
                       str(len(tasks))))

        list_names = ['xDelayedTaskList1',
                      'xDelayedTaskList2',
                      'xPendingReadyList',
                      'xSuspendedTaskList',
        ]
        lists = {}
        for name in list_names:
            list_head = self.arch_rules.ListHead(name)
            lists[name] = list_head
            self.generator.source_file.data_manager.add(list_head)

        self.generator.source_file.data_manager.add(
            DataObject('PRIVILEGED_DATA List_t *',
                       'pxDelayedTaskList',
                       static_initializer=lists['xDelayedTaskList1'].address))
        self.generator.source_file.data_manager.add(
            DataObject('PRIVILEGED_DATA List_t *',
                       'pxOverflowDelayedTaskList',
                       static_initializer=lists['xDelayedTaskList2'].address))


    def generate_limitation_warnings(self):
        self.generator.source_file.declarations += [
            CPPStatement("if","(configCHECK_FOR_STACK_OVERFLOW > 1)"),
            CPPStatement('error','(configCHECK_FOR_STACK_OVERFLOW > 1) '
                         'is currently not supported for statically generated'
                         ' and initialized FreeRTOS system object instances'),
            CPPStatement("endif", '// if configCHECK_FOR_STACK_OVERFLOW' ),
            ]
        pass
