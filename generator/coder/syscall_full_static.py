from .syscall_generic import GenericSystemCalls
from .elements import (DataObjectArray, DataObject, Function, FunctionCall,
                       Statement, Include,
                       FunctionDeclaration)
from steps.freertos import Task

class StaticFullSystemCalls(GenericSystemCalls):


    def generate_data_objects(self):
        '''generate the data objects for tasks and queues'''
        #TODO: Stack Speicher global
        #TODO: TCB Speicher global
        #TODO: QueueStorage
        #TODO: Queue Verwaltungsstruktur
        task_list = [self.ara_graph.instances.vp.obj[v]
                     for v in self.ara_graph.instances.vertices()
                     if isinstance(self.ara_graph.instances.vp.obj[v], Task)]
        self.generate_dataobjects_task_stacks(task_list)
        self.generate_data_objects_tcb_mem(task_list)

    def generate_dataobjects_task_stacks(self, task_list):
        '''generate the stack space for the tasks'''
        for task in task_list:
            self.arch_rules.static_stack(task)

    def generate_data_objects_tcb_mem(self, task_list):
        '''generate the memory for the tcbs'''
        for task in task_list:
            self.arch_rules.static_unchanged_tcb(task, initialized=False)


    def generate_system_code(self):
        super().generate_system_code()
        task_list = [self.ara_graph.instances.vp.obj[v]
                     for v in self.ara_graph.instances.vertices()
                     if isinstance(self.ara_graph.instances.vp.obj[v], Task)]
        self.generate_system_code_init_tasks(task_list)


    def generate_system_code_init_tasks(self, task_list):
        self.generator.source_file.includes.add(Include('task.h'))
        init_func = Function("init_static_system_objects",
                             'void',
                             [],
                             extern_c=True,
        )
        idle_task = None
        for task in task_list:
            if not task.is_regular:
                if task.name == 'idle_task':
                    idle_task = task
                    self.logger.debug("IdleTask: %s", task)
                continue
            self.logger.debug("Generating init function call for %s", task)
            init_func.add(FunctionCall("xTaskCreateStatic",
                                       [f'{task.function}',
                                        f'"{task.name}"',
                                        f'{task.stack_size}',
                                        f'{task.parameters}',
                                        f'{task.priority}',
                                        f'{task.impl.stack.name}',
                                        f'&{task.impl.tcb.name}',
                                       ]))
            start_func = FunctionDeclaration(task.function,
                                             'void',
                                             ['void *'],
                                             extern_c=True)
            self.generator.source_file.function_manager.add(start_func)

        self.generator.source_file.function_manager.add(init_func)


        if idle_task:
            mem_f = Function('vApplicationGetIdleTaskMemory',
                                         'void',
                                         ['StaticTask_t **',
                                          'StackType_t **',
                                          'uint32_t *',
                                         ],
                             extern_c=True)
            mem_f.add(Statement(f"*arg0 = &{idle_task.impl.tcb.name}"))
            mem_f.add(Statement(f"*arg1 = &({idle_task.impl.stack.name}[0])"))
            mem_f.add(Statement(f"*arg2 = {idle_task.stack_size}"))
            self.generator.source_file.function_manager.add(mem_f)

        dummy_xTaskCreate = Function('xTaskCreate',
                                     'BaseType_t',
                                     ['TaskFunction_t',
                                      'const char *',
                                      'const uint16_t',
                                      'void * const',
                                      'UBaseType_t',
                                      'TaskHandle_t *'
                                      ])
        dummy_xTaskCreate.add(Statement("return pdPASS"))
        self.generator.source_file.function_manager.add(dummy_xTaskCreate)

        dummy_xTaskCreateStatic = FunctionDeclaration('xTaskCreateStatic',
                                                      'TaskHandle_t',
                                                      ['TaskFunction_t',
                                                       'const char *',
                                                       'const uint16_t',
                                                       'void * const',
                                                       'UBaseType_t',
                                                       'StackType_t *',
                                                       'StaticTask_t *'
                                                      ],
                                                      extern_c=True)
        self.generator.source_file.function_manager.add(dummy_xTaskCreateStatic)

        self._init.add(FunctionCall('init_static_system_objects',[]))
