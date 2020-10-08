from .base import BaseCoder
from .elements import Function, FunctionCall, FunctionDeclaration, Statement

class GenericSystemCalls(BaseCoder):
    def __init__(self):
        self._init = Function('_init', 'void', [], extern_c=True,
                              attributes=['__attribute__((weak))'])

    def generate_system_code(self):
        self.generator.source_file.function_manager.add(self._init)
        # init_board = FunctionDeclaration('InitBoard', 'void', [])
        # self.generator.source_file.function_manager.add(init_board)
        # self._init.add(FunctionCall('InitBoard',[]))

        stack_hook = Function('vApplicationStackOverflowHook', 'void',
                              [], extern_c=True, attributes=['__attribute__((weak))'])
        stack_hook.add(Statement('while (1)'))
        self.generator.source_file.function_manager.add(stack_hook)


    pass

    def generate_data_objects_queue_mem(self, queue_list, init):
        '''generate the memory for the queue heads and data'''
        self._log.debug("generate_data_objects_queue_mem: %s instances", len(queue_list))
        static_instantiation = False
        dynamic_instantiation = False
        for queue in queue_list:
            self._log.debug('Queue: %s', queue.name)
            if not queue.branch:
                queue.impl.init = init
                self.arch_rules.static_unchanged_queue(queue, initialized=(init == 'initialized'))
                static_instantiation = True
            else:
                msg = f"Can't create queue static cause it is inside a branch: {queue}"
                queue.impl.init = 'unchanged'
                dynamic_instantiation = True
                self._log.error(msg)

        overrides = self.generator.source_files['.freertos_overrides.h'].overrides
        overrides['configSUPPORT_STATIC_ALLOCATION'] = int(
            getattr(overrides, 'configSUPPORT_STATIC_ALLOCATION', False)
            or static_instantiation)
        overrides['configSUPPORT_DYNAMIC_ALLOCATION'] = int(
            getattr(overrides, 'configSUPPORT_DYNAMIC_ALLOCATION', False)
            or dynamic_instantiation)
