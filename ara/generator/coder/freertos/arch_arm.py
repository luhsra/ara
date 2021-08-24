from .arch_generic import GenericArch
from ..elements import (
    CodeTemplate,
    DataObject,
    DataObjectArray,
    Include,
    InstanceDataObject,
    StructDataObject,
)

default_traps = [
    'NMI_Handler',
    'HardFault_Handler',
    'MemManage_Handler',
    'BusFault_Handler',
    'UsageFault_Handler',
    'SVC_Handler',
    'DebugMon_Handler',
    'PendSV_Handler',
    'WWDG_IRQHandler',
    'PVD_IRQHandler',
    'TAMPER_IRQHandler',
    'RTC_IRQHandler',
    'FLASH_IRQHandler',
    'RCC_IRQHandler',
    'EXTI0_IRQHandler',
    'EXTI1_IRQHandler',
    'EXTI2_IRQHandler',
    'EXTI3_IRQHandler',
    'EXTI4_IRQHandler',
    'DMA1_Channel1_IRQHandler',
    'DMA1_Channel2_IRQHandler',
    'DMA1_Channel3_IRQHandler',
    'DMA1_Channel4_IRQHandler',
    'DMA1_Channel5_IRQHandler',
    'DMA1_Channel6_IRQHandler',
    'DMA1_Channel7_IRQHandler',
    'ADC1_2_IRQHandler',
    'USB_HP_CAN1_TX_IRQHandler',
    'USB_LP_CAN1_RX0_IRQHandler',
    'CAN1_RX1_IRQHandler',
    'CAN1_SCE_IRQHandler',
    'EXTI9_5_IRQHandler',
    'TIM1_BRK_IRQHandler',
    'TIM1_UP_IRQHandler',
    'TIM1_TRG_COM_IRQHandler',
    'TIM1_CC_IRQHandler',
    'TIM2_IRQHandler',
    'TIM3_IRQHandler',
    'TIM4_IRQHandler',
    'I2C1_EV_IRQHandler',
    'I2C1_ER_IRQHandler',
    'I2C2_EV_IRQHandler',
    'I2C2_ER_IRQHandler',
    'SPI1_IRQHandler',
    'SPI2_IRQHandler',
    'USART1_IRQHandler',
    'USART2_IRQHandler',
    'USART3_IRQHandler',
    'EXTI15_10_IRQHandler',
    'RTC_Alarm_IRQHandler',
    'USBWakeUp_IRQHandler',
]



class ArmArch(GenericArch):

    def static_stack(self, task):
        self._log.debug("Generating stack for %s", task.name)
        stack = DataObjectArray("StackType_t",
                                f't{task.name}_{task.uid}_static_stack',
                                f'{task.stack_size}',
                                extern_c = True)
        self.generator.source_file.data_manager.add(stack)
        task.impl.stack = stack
        return stack

    def static_unchanged_tcb(self, task):
        self._log.debug("Generating TCB mem for %s", task.name)
        if task.specialization_level == 'initialized':
            name_length = self.ara_graph.os.config['configMAX_TASK_NAME_LEN'].get()
            try:
                tcb = self.TCB(task, True, extern_c=True, name_length=name_length)
            except:
                task.specialization_level == 'static'
                return self.static_unchanged_tcb(task)
        else:
            tcb = DataObject("StaticTask_t",
                             f't{task.name}_{task.uid}_tcb',
                             extern_c = True)
        self.generator.source_file.data_manager.add(tcb)
        task.impl.tcb = tcb
        return tcb

    def specialized_stack(self, task):
        cts = self.ara_graph.cfg.get_call_targets(task.abb)
        funcs = [self.ara_graph.cfg.vp.name[f] for f in cts]
        if 'xTaskCreateStatic' in funcs:
            task.specialization_level = 'unchanged'
        if task.specialization_level == 'initialized':
            return self.initialized_stack(task)
        elif task.specialization_level == 'static':
            return self.static_stack(task)
        elif task.specialization_level == 'unchanged':
            return None
        else:
            self._log.error(f"unknown init type: {task.specialization_level} for {task}")

    def initialized_stack(self, task):
        self._log.debug("Generating initialized stack for %s", task.name)
        try:
            task_parameters = int(task.parameters)
        except TypeError:
            task.specialization_level = 'static'
            return self.static_stack(task)
        stack = InstanceDataObject("InitializedStack_t",
                                   f't{task.name}_{task.uid}_static_stack',
                                   [f'{task.stack_size}'],
                                   [f'(void *){task.function}', f'(void *){task_parameters}'],
                                   extern_c = False)
        self.generator.source_file.data_manager.add(stack)
        task.impl.stack = stack
        stack.tos = f"((StackType_t*)&{stack.name}) + {task.stack_size} - 17"
        return stack

    def static_unchanged_queue(self, queue):
        self._log.debug("Generating Queue: %s", queue.name)
        if queue.size is None or queue.length is None or not queue.unique:
            queue.specialization_level = 'unchanged'
            return
        if int(queue.size) == 0 or int(queue.length) == 0:
            self._log.debug("queue size/length = 0: %s", queue)
            queue.impl.data = self.generator.source_file.data_manager.get_nullptr()
        else:
            try:
                size = queue.size * queue.length
                name = f'queue_data_{queue.name}_{queue.uid}'
            except:
                queue.specialization_level = 'unchanged'
                return
            data = DataObjectArray('uint8_t', name, size)
            self.generator.source_file.data_manager.add(data)
            queue.impl.data = data
        head = self.QUEUE(queue, extern_c=True)
        self.generator.source_file.data_manager.add(head)
        queue.impl.head = head

    def generate_startup_code(self):
        startup_asm = StartupCodeTemplate(self)
        with self.generator.open_file(".startup.s") as fd:
            fd.write(startup_asm.expand())

        self.generator.source_file.includes.add(Include('time_markers.h'))
        for marker in startup_asm.time_markers:
            m = StructDataObject('__time_marker_t', f'__time_{marker}',
                                 attributes=['section(".data.__time_markers")'],
                                 extern_c=True)
            m['name'] = f'"{marker}"'
            self.generator.source_file.data_manager.add(m)

    def generate_default_interrupt_handlers(self):
        pass

    def generate_linkerscript(self):
        pass


class StartupCodeTemplate(CodeTemplate):

    def __init__(self, arm, debug=True):
        super().__init__(arm.generator, 'arch/arm/stm32F103xb/startup_stm32f103xb.s')
        self.arm = arm
        self.ara_graph = arm.ara_graph
        self.debug = debug
        self.time_markers = []

    def default_trap_handlers(self, snippet, args):
        ret = []
        letters = [chr(x) for x in range(ord('a'), ord('z'))]
        letters += [chr(x) for x in range(ord('A'), ord('Z'))]
        letters += [chr(x) for x in range(ord('0'), ord('9'))]
        for i,t in enumerate(default_traps):
            ret.append(f'.weak {t}')
            if self.debug:
                letter = letters[i]
                ret.append(f'DEFAULT_{t}:')
                ret.append(f'  movs r1, #{ord(letter)} // {letter}')
                ret.append(f'  bl _ZN6Serial7putcharEc //call Serial::putchar({letter})')
                ret.append(f'DEFAULT_{t}_loop:')
                ret.append(f'  b DEFAULT_{t}_loop')
                ret.append(f'.thumb_set {t},DEFAULT_{t}\n')
            else:
                ret.append(f'.thumb_set {t},Default_Handler\n')
        return "\n".join(ret)

    def timing_print_init(self, snippet, args):
        #TODO: get option from config
        enable_debug_timing = True
        if not enable_debug_timing:
            return ""
        ret = [
            '/* Enable DWT_CYCCOUNT */',
            'ldr r2, =0xe000edfc             //;address of DEMCR',
            'ldr  r3, [r2, #0]                       //;load DEMCR',
            'orr.w r3, r3, #16777216         //;DEMCR_TRCENA == 0x1000000',
            'str r3, [r2, #0]                        //;write back',
            '',
            'ldr r3, =0xe0001004                     //;address of DWT_CYCCNT',
            'mov r2, #0',
            'str r2, [r3, #0]                        //;clear DWT_CYCCNT',
            '',
            'ldr r2, =0xe0001000                     //;address of DWT_CTRL',
            'ldr r3, [r2, #0]                        //;load DWT_CTRL',
            'orr.w r3, r3, #1                        //;set CYCCNTENA',
            'str r3, [r2, #0]                        //;write back',
        ]
        return '\n'.join(ret)

    def store_DWT_CYCCNT(self, target):
        #TODO: get option from config
        enable_debug_timing = True
        if not enable_debug_timing:
            return ""
        self.time_markers.append(target)
        return "\n".join([
            f'.global __time_{target}',
            f'ldr r0, =0xe0001004  // address of DWT_CYCCNT',
            f'ldr r0, [r0, #0]     // load value of DWT_CYCCNT',
            f'ldr r1, =__time_{target}    //address of target symbol',
            f'str r0, [r1, #0]     //store {target} = r0',
        ])

    def done_marker(self, snippet, args):
        return self.store_DWT_CYCCNT(f'startup_{args[0]}')

    def sparse_init(self, snippet, args):
        return "bl sparse_init"
