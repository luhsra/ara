from .syscall_generic import GenericSystemCalls
from .elements import (DataObjectArray, DataObject, Function, FunctionCall,
                       Statement,
                       FunctionDeclaration)
from steps.freertos import Task

class StaticFullSystemCalls(GenericSystemCalls):


    def generate_data_objects(self):
        '''generate the data objects for tasks and queues'''
        #TODO: Stack Speicher global
        #TODO: TCB Speicher global
        #TODO: QueueStorage
        #TODO: Queue Verwaltungsstruktur
        self.generate_dataobjects_task_stacks()
        self.generate_data_objects_tcb_mem()

    def generate_dataobjects_task_stacks(self):
        '''generate the stack space for the tasks'''
        for v in self.ara_graph.instances.vertices():
            task = self.ara_graph.instances.vp.obj[v]
            self.arch_rules.static_stack(task)

    def generate_data_objects_tcb_mem(self):
        '''generate the memory for the tcbs'''
        for v in self.ara_graph.instances.vertices():
            task = self.ara_graph.instances.vp.obj[v]
            self.arch_rules.static_unchanged_tcb(task)


    def generate_system_code(self):
        self.generate_system_code_init_tasks()


    def generate_system_code_init_tasks(self):
        init_func = Function("init_static_system_objects",
                             'void',
                             [],
                             extern_c=True,
                             attributes=['__attribute__((constructor))'])
        idle_task = None
        for v in self.ara_graph.instances.vertices():
            task = self.ara_graph.instances.vp.obj[v]
            if not task.is_regular:
                if task.name == 'idle_task':
                    idle_task = task
                    self.logger.debug("IdleTask: %s", task)
                continue
            self.logger.debug("Generating init function call for %s", task)
            init_func.add(FunctionCall("xTaskCreateStatic",
                                       [f'{task.function}',
                                        f'{task.name}',
                                        f'{task.stack_size}',
                                        f'{task.parameters}',
                                        f'{task.priority}',
                                        f'{task.impl.stack.name}',
                                        f'&{task.impl.tcb.name}',
                                       ]))
            start_func = FunctionDeclaration(task.function,
                                             'void *',
                                             ['void *'],
                                             extern_c=True)
            self.generator.source_file.function_manager.add(start_func)

        self.generator.source_file.function_manager.add(init_func)


        if idle_task:
            mem_f = Function('vApplicationGetIdleMemory',
                                         'void',
                                         ['StaticTask_t **',
                                          'StackType_t *',
                                          'uint32_t *',
                                         ],
                             extern_c=True)
            mem_f.add(Statement(f"*arg0 = &{idle_task.impl.tcb.name}"))
            mem_f.add(Statement(f"*arg1 = {idle_task.impl.stack.name}"))
            mem_f.add(Statement(f"*arg1 = {idle_task.stack_size}"))
            self.generator.source_file.function_manager.add(mem_f)

        dummy_xTaskCreate = Function('xTaskCreate',
                                     'BaseType_t',
                                     ['TaskFunction_t',
                                      'const char *',
                                      'const uint16_t',
                                      'voic * const',
                                      'UBaseType_t',
                                      'TaskHandle_t *'
                                      ])
        dummy_xTaskCreate.add(Statement("return pdPASS"))
        self.generator.source_file.function_manager.add(dummy_xTaskCreate)
