from ..syscall_generic import GenericSystemCalls
from ..elements import (DataObjectArray, DataObject, Function, FunctionCall,
                       CPPStatement,
                       Statement, Include, InstanceDataObject, StructDataObject,
                       FunctionDeclaration)
from ara.os.freertos import Task, Queue, Mutex






class SystemCallsInstantiationInitialized(GenericSystemCalls):

    def generate_data_objects(self):
        '''generate the data objects for tasks and queues'''
        #TODO: QueueStorage
        #TODO: Queue Verwaltungsstruktur
        self.generator.source_file.includes.add(
            Include('InitializedFreeRTOSObjects.h'))
        task_list = [self.ara_graph.instances.vp.obj[v]
                     for v in self.ara_graph.instances.vertices()
                     if isinstance(self.ara_graph.instances.vp.obj[v], Task)]
        queue_list = [self.ara_graph.instances.vp.obj[v]
                     for v in self.ara_graph.instances.vertices()
                     if isinstance(self.ara_graph.instances.vp.obj[v], Queue)]
        mutex_list = [self.ara_graph.instances.vp.obj[v]
                     for v in self.ara_graph.instances.vertices()
                     if isinstance(self.ara_graph.instances.vp.obj[v], Mutex)]
        self.mark_specialization_depth()
        self.generate_dataobjects_task_stacks(task_list)
        self.generate_data_objects_tcb_mem(task_list)
        self.generate_data_objects_ready_list(task_list)
        self.generate_data_objects_queue_mem(queue_list, 'initialized')
        self.generate_data_objects_queue_mem(mutex_list, 'initialized')
        self.generator.source_file.includes.add(Include('queue.h'))
        self.generate_limitation_warnings()

    def mark_specialization_depth(self):
        for v in self.ara_graph.instances.vertices():
            inst = self.ara_graph.instances.vp.obj[v]
            if inst.unique:
                inst.specialization_level = 'initialized'
            else:
                inst.specialization_level = 'unchanged'
            self._log.debug("mark depth: %015s (unique: %s, branch: %s, loop: %s) ==> %s",
                            inst.name,
                            inst.unique,
                            inst.branch,
                            inst.loop,
                            inst.specialization_level)

    def generate_dataobjects_task_stacks(self, task_list):
        '''generate the stack space for the tasks'''
        for task in task_list:
            self.arch_rules.specialized_stack(task)

    def generate_data_objects_tcb_mem(self, task_list):
        '''generate the memory for the tcbs'''
        for task in task_list:
            if task.specialization_level in ['initialized', 'static']:
                self.arch_rules.static_unchanged_tcb(task)
            else:
                continue
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
        queue_list = [self.ara_graph.instances.vp.obj[v]
                      for v in self.ara_graph.instances.vertices()
                      if isinstance(self.ara_graph.instances.vp.obj[v], Queue)]
        mutex_list = [self.ara_graph.instances.vp.obj[v]
                     for v in self.ara_graph.instances.vertices()
                     if isinstance(self.ara_graph.instances.vp.obj[v], Mutex)]
        all_instances = [self.ara_graph.instances.vp.obj[v]
                         for v in self.ara_graph.instances.vertices()]
        self.generate_system_code_init_tasks(task_list)
        self.mark_init_support(all_instances)
        if len(all_instances) > 0:
            self.generator.ara_step._step_manager.chain_step({'name':'ReplaceSyscallsCreate'})
        else:
            self._log.warning("Neither Tasks nor Queues")

    def mark_init_support(self, instance_list):
        static_instantiation = any([inst.specialization_level in ['initialized', 'static']
                                    for inst in instance_list])
        dynamic_instantiation = any([inst.specialization_level == 'unchanged'
                                     for inst in instance_list])

        overrides = self.generator.source_files['.freertos_overrides.h'].overrides
        overrides['configSUPPORT_STATIC_ALLOCATION'] = int(
            getattr(overrides, 'configSUPPORT_STATIC_ALLOCATION', False)
            or static_instantiation)
        overrides['configSUPPORT_DYNAMIC_ALLOCATION'] = int(
            getattr(overrides, 'configSUPPORT_DYNAMIC_ALLOCATION', False)
            or dynamic_instantiation)



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


    def generate_data_objects_ready_list(self, tasks):
        max_prio = self.ara_graph.os.config.get('configMAX_PRIORITIES').get()

        # ready_lists = DataObjectArray("PRIVILEGED_DATA List_t", "pxReadyTasksLists", 'configMAX_PRIORITIES')
        prio_is_bit_encoded = bool(self.ara_graph.os.config['configUSE_PORT_OPTIMISED_TASK_SELECTION'].get())
        ready_lists = self.arch_rules.TasksLists("pxReadyTasksLists",
                                                 max_prio,
                                                 tasks,
                                                 prio_is_bit_encoded=prio_is_bit_encoded,
                                                 )
        self.generator.source_file.data_manager.add(ready_lists)


        self.generator.source_file.data_manager.add(
            DataObject('PRIVILEGED_DATA TCB_t * volatile',
                       'pxCurrentTCB',
                       ready_lists.current_tcb.address))
        self.generator.source_files['.freertos_overrides.h'].overrides['ARA_INITIALIZED'] = 1

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
