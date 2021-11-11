from ..syscall_generic import GenericSystemCalls as _GenericSystemCalls
from ..elements import (DataObjectArray, DataObject, Function, FunctionCall,
                       Statement, Include, CPPStatement,
                       FunctionDeclaration)
from ara.os.freertos import Mutex, Queue, Task

class GenericSystemCalls(_GenericSystemCalls):
    def __init__(self):
        self._init = Function('_init', 'void', [], extern_c=True,
                              attributes=['__attribute__((weak))'])

    def generate_system_code(self):
        self.generator.source_file.function_manager.add(self._init)

        stack_hook = Function('vApplicationStackOverflowHook', 'void',
                              [], extern_c=True, attributes=['__attribute__((weak))'])
        stack_hook.add(Statement('while (1)'))
        self.generator.source_file.function_manager.add(stack_hook)

        task_list = [self.ara_graph.instances.vp.obj[v]
                     for v in self.ara_graph.instances.vertices()
                     if isinstance(self.ara_graph.instances.vp.obj[v], Task)]
        all_instances = [self.ara_graph.instances.vp.obj[v]
                         for v in self.ara_graph.instances.vertices()]
        self.mark_init_support(all_instances)
        self.generator.source_file.includes.add(Include('FreeRTOS.h'))
        if len(all_instances) > 1: # 1 is the idle task
            self.generator.ara_step._step_manager.chain_step({'name':'ReplaceSyscallsCreate'})

        if self.ara_graph.os.specialization_level == 'static':
            self.generate_system_code_init_idle_task(task_list)
        if self.ara_graph.os.specialization_level == 'initialized':
            self.generate_system_code_declare_task_functions(task_list)



    def generate_system_code_declare_task_functions(self, task_list):
        idle_task = self.ara_graph.os.idle_task
        for task in task_list:
            if task == idle_task:
                continue
            self._log.debug("declaring task function for %s", task)
            start_func = FunctionDeclaration(task.function,
                                             'void',
                                             ['void *'],
                                             extern_c=True)
            self.generator.source_file.function_manager.add(start_func)


    def generate_system_code_init_idle_task(self, task_list):
        self.generator.source_file.includes.add(Include('task.h'))
        idle_task = self.ara_graph.os.idle_task
        assert idle_task, "IdleTask not found"
        mem_f = Function('vApplicationGetIdleTaskMemory',
                         'void',
                         ['StaticTask_t **',
                          'StackType_t **',
                          'uint32_t *',
                          ],
                         attributes=[
                             "__attribute__((always_inline))",
                         ],
                         extern_c=True)
        mem_f.add(Statement(f"*arg0 = &{idle_task.impl.tcb.name}"))
        mem_f.add(Statement(f"*arg1 = &({idle_task.impl.stack.name}[0])"))
        mem_f.add(Statement(f"*arg2 = {idle_task.stack_size}"))
        self.generator.source_file.function_manager.add(mem_f)





    def generate_data_objects(self):
        '''generate the data objects for tasks and queues'''
        #TODO: QueueStorage
        #TODO: Queue Verwaltungsstruktur
        self.generator.source_file.includes.add(Include('task.h'))
        self.generator.source_file.includes.add(Include('queue.h'))
        # self._log.critical("level: %s", self.ara_graph.os.specialization_level)
        if self.ara_graph.os.specialization_level == 'initialized':
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
        self.generate_data_objects_task_stacks(task_list)
        self.generate_data_objects_tcb_mem(task_list)
        self.generate_data_objects_queue_mem(queue_list)
        self.generate_data_objects_queue_mem(mutex_list)
        if self.ara_graph.os.specialization_level in ['static', 'initialized']:
            self.generate_limitation_warnings()
        if self.ara_graph.os.specialization_level == 'initialized':
            self.generate_data_objects_ready_list(task_list)


    def generate_data_objects_queue_mem(self, queue_list):
        '''generate the memory for the queue heads and data'''
        self._log.debug("generate_data_objects_queue_mem: %s instances", len(queue_list))
        for queue in queue_list:
            if queue.specialization_level == 'unchanged':
                continue
            self._log.debug('Queue: %s', queue.name)
            self.arch_rules.static_unchanged_queue(queue)

    def generate_data_objects_task_stacks(self, task_list):
        '''generate the stack space for the tasks'''
        for task in task_list:
            self.arch_rules.specialized_stack(task)

    def generate_data_objects_tcb_mem(self, task_list):
        '''generate the memory for the tcbs'''
        for task in task_list:
            if task.specialization_level == 'unchanged':
                continue
            elif task.specialization_level in ['static', 'initialized']:
                self.arch_rules.static_unchanged_tcb(task)
            else:
                assert False, "Unknown specialization level"

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






    def generate_limitation_warnings(self):
        self.generator.source_file.declarations += [
            CPPStatement("if","(configCHECK_FOR_STACK_OVERFLOW > 1)"),
            CPPStatement('error','(configCHECK_FOR_STACK_OVERFLOW > 1) '
                         'is currently not supported for statically generated'
                         ' and initialized FreeRTOS system object instances'),
            CPPStatement("endif", '// if configCHECK_FOR_STACK_OVERFLOW' ),
            ]
