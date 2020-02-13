from .arch_generic import GenericArch
from .elements import (
    CodeTemplate,
    DataObject,
    DataObjectArray,
    InstanceDataObject,
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
        self.logger.debug("Generating stack for %s", task)
        stack = DataObjectArray("StackType_t",
                                f'{task.name}_static_stack',
                                f'{task.stack_size}',
                                extern_c = True)
        self.generator.source_file.data_manager.add(stack)
        task.impl.stack = stack
        return stack

    def static_unchanged_tcb(self, task, initialized):
        self.logger.debug("Generating TCB mem for %s", task)
        if initialized:
            tcb = self.TCB(task, initialized, extern_c=True)
        else:
            tcb = DataObject("StaticTask_t",
                             f'{task.name}_tcb',
                             extern_c = True)
        self.generator.source_file.data_manager.add(tcb)
        task.impl.tcb = tcb
        return tcb

    def initialized_stack(self, task):
        self.logger.debug("Generating initialized stack for %s", task)
        stack = InstanceDataObject("InitializedStack_t",
                                   f'{task.name}_static_stack',
                                   [f'{task.stack_size}'],
                                   [f'(void *){task.function}'],
                                   extern_c = False)
        self.generator.source_file.data_manager.add(stack)
        task.impl.stack = stack
        stack.tos = f"((StackType_t*)&{stack.name}) + {task.stack_size} - 17"
        return stack

    def generate_startup_code(self):
        if True:
            startup_asm = StartupCodeTemplate(self).expand()
        else:
            with self.generator.open_template('arch/arm/stm32F103xb/startup_stm32f103xb.s') as infile:
                startup_asm = infile.read()

        with self.generator.open_file(".startup.s") as fd:
            fd.write(startup_asm)

class StartupCodeTemplate(CodeTemplate):

    def __init__(self, arm, debug=True):
        super().__init__(arm.generator, 'arch/arm/stm32F103xb/startup_stm32f103xb.s')
        self.arm = arm
        self.ara_graph = arm.ara_graph
        self.debug = debug

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
                ret.append(f'  movs r0, #{ord(letter)} // {letter}')
                ret.append(f'  bl _ZN6Serial7putcharEc //call Serial::putchar({letter})')
                ret.append(f'  b DEFAULT_{t}')
                ret.append(f'.thumb_set {t},DEFAULT_{t}\n')
            else:
                ret.append(f'.thumb_set {t},Default_Handler\n')
        return "\n".join(ret)
