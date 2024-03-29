/**
  ******************************************************************************
  * @file      startup_stm32f10x_md.s
  * @author    MCD Application Team / Angus Peart
  * @version   V3.1.2
  * @date      09/28/2009
  * @brief     STM32F10x Medium Density Devices vector table for RIDE7 toolchain.
  *            This module performs:
  *                - Set the initial SP
  *                - Set the initial PC == Reset_Handler,
  *                - Set the vector table entries with the exceptions ISR address
  *                - Branches to main in the C library (which eventually
  *                  calls main()).
  *            After Reset the Cortex-M3 processor is in Thread mode,
  *            priority is Privileged, and the Stack is set to Main.
  *******************************************************************************
  * @copy
  *
  * THE PRESENT FIRMWARE WHICH IS FOR GUIDANCE ONLY AIMS AT PROVIDING CUSTOMERS
  * WITH CODING INFORMATION REGARDING THEIR PRODUCTS IN ORDER FOR THEM TO SAVE
  * TIME. AS A RESULT, STMICROELECTRONICS SHALL NOT BE HELD LIABLE FOR ANY
  * DIRECT, INDIRECT OR CONSEQUENTIAL DAMAGES WITH RESPECT TO ANY CLAIMS ARISING
  * FROM THE CONTENT OF SUCH FIRMWARE AND/OR THE USE MADE BY CUSTOMERS OF THE
  * CODING INFORMATION CONTAINED HEREIN IN CONNECTION WITH THEIR PRODUCTS.
  *
  * <h2><center>&copy; COPYRIGHT 2009 STMicroelectronics</center></h2>
  */
    
  .syntax unified
  .cpu cortex-m3
  .fpu softvfp
  .thumb

.global  g_pfnVectors
.global  Default_Handler
.global  xPortIncreaseHeapSize
.global  Stack_Change

/* start address for the initialization values of the .data section. 
defined in linker script */
.word  _sidata
/* start address for the .data section. defined in linker script */  
.word  _sdata
/* end address for the .data section. defined in linker script */
.word  _edata
/* start address for the .bss section. defined in linker script */
.word  _sbss
/* end address for the .bss section. defined in linker script */
.word  _ebss

.equ  BootRAM, 0xF108F85F
/**
 * @brief  This is the code that gets called when the processor first
 *          starts execution following a reset event. Only the absolutely
 *          necessary set is performed, after which the application
 *          supplied main() routine is called. 
 * @param  None
 * @retval : None
*/

    .section  .text.Reset_Handler
  .weak  Reset_Handler
  .type  Reset_Handler, %function
Reset_Handler:
  /* Enable DWT_CYCCOUNT */
ldr r2, =0xe000edfc             //;address of DEMCR
ldr  r3, [r2, #0]                       //;load DEMCR
orr.w r3, r3, #16777216         //;DEMCR_TRCENA == 0x1000000
str r3, [r2, #0]                        //;write back

ldr r3, =0xe0001004                     //;address of DWT_CYCCNT
mov r2, #0
str r2, [r3, #0]                        //;clear DWT_CYCCNT

ldr r2, =0xe0001000                     //;address of DWT_CTRL
ldr r3, [r2, #0]                        //;load DWT_CTRL
orr.w r3, r3, #1                        //;set CYCCNTENA
str r3, [r2, #0]                        //;write back

/*
 * From COrtex-M3 reference manual:
 * - Handler IRQ always use SP_main
 * - Process use SP_main or SP_process
 * Here, we will use beginning of SRAM for IRQ (SP_main)
 * and end of heap for initialization (SP_process).
 * Once the schedule starts, all threads will use their own stack
 * from heap and NOBOBY should use SP_process again.
 */
 /* Do set/reset the stack pointers */
  LDR r0, =_irq_stack_top
  MSR msp, r0
  LDR r2, =_init_stack_top
  MSR psp, r2
  /* check if irq and init stack are the same */
  /* if they are, we don't do stack swap */
  /* and lets bypass the monitoring as well for now */
  cmp  r0, r2
  beq SectionBssInit
/* DO
 * - stay in thread process mode
 * - stay in privilege level
 * - use process stack
 */
  movs r0, #2
  MSR control, r0
  ISB
/* Fill IRQ stack for watermark monitoring */
  ldr  r2, =_irq_stack_end
  b  LoopFillIRQStack

FillIRQStack:
  movw  r3, #0xA5A5
  str  r3, [r2], #4

LoopFillIRQStack:
  ldr  r3, = _irq_stack_top
  cmp  r2, r3
  bcc  FillIRQStack

SectionBssInit:
/* Copy the data segment initializers from flash to SRAM */  
  movs  r1, #0
  b  LoopCopyDataInit

CopyDataInit:
  ldr  r3, =_sidata
  ldr  r3, [r3, r1]
  str  r3, [r0, r1]
  adds  r1, r1, #4
    
LoopCopyDataInit:
  ldr  r0, =_sdata
  ldr  r3, =_edata
  adds  r2, r0, r1
  cmp  r2, r3
  bcc  CopyDataInit

/* data init done */
.global __time_startup_data_copy
ldr r0, =0xe0001004  // address of DWT_CYCCNT
ldr r0, [r0, #0]     // load value of DWT_CYCCNT
ldr r1, =__time_startup_data_copy    //address of target symbol
str r0, [r1, #0]     //store startup_data_copy = r0

  ldr  r2, =_sbss
  b  LoopFillZerobss
/* Zero fill the bss segment. */  
FillZerobss:
  movs  r3, #0
  str  r3, [r2], #4
    
LoopFillZerobss:
  ldr  r3, = _ebss
  cmp  r2, r3
  bcc  FillZerobss

/* bss done */
.global __time_startup_bss_zero
ldr r0, =0xe0001004  // address of DWT_CYCCNT
ldr r0, [r0, #0]     // load value of DWT_CYCCNT
ldr r1, =__time_startup_bss_zero    //address of target symbol
str r0, [r1, #0]     //store startup_bss_zero = r0


/* init sparse data structures */
  bl init_sparserle2
.global __time_startup_sparse_init
ldr r0, =0xe0001004  // address of DWT_CYCCNT
ldr r0, [r0, #0]     // load value of DWT_CYCCNT
ldr r1, =__time_startup_sparse_init    //address of target symbol
str r0, [r1, #0]     //store startup_sparse_init = r0

  /* call the c++ constructors */
  bl __libc_init_array
.global __time_startup_libc_init_array_calls
ldr r0, =0xe0001004  // address of DWT_CYCCNT
ldr r0, [r0, #0]     // load value of DWT_CYCCNT
ldr r1, =__time_startup_libc_init_array_calls    //address of target symbol
str r0, [r1, #0]     //store startup_libc_init_array_calls = r0
/* Call the application's entry point.*/
  bl  main
/* will never return here */
  bx  lr
.size  Reset_Handler, .-Reset_Handler

/**
 * @brief  This is the code that swaps stack (from end of heap to irq_stack).
 *         Also reclaim the heap that was used as a stack.
 * @param  None
 * @retval : None
*/
  .section  .text.Stack_Change
  .weak  Stack_Change
  .type  Stack_Change, %function
Stack_Change:
  mov r4, lr
/* Switches stack back momentarily to MSP */
  movs r0, #0
  msr control, r0
Heap_Reclaim:
/* add heap_post_rtos to the heap (if the capability/function exist) */
/* Also claim the unused memory (between end of heap to end of memory */
/* CAREFULL: the heap section must be the last section in RAM in order this to work */
  ldr r0, = _init_stack_size
  ldr r1, = _eheap_post_rtos
  ldr r2, = _eram
  subs r2, r2, r1
  adds r0, r0, r2
  bl xPortIncreaseHeapSize
  bx r4
  .size  Stack_Change, .-Stack_Change


/**
 * @brief  This is the code that gets called when the processor receives an
 *         unexpected interrupt.  This simply enters an infinite loop, preserving
 *         the system state for examination by a debugger.
 *
 * @param  None
 * @retval : None
*/
    .section  .text.Default_Handler,"ax",%progbits
Default_Handler:
Infinite_Loop:
  b  Infinite_Loop
  .size  Default_Handler, .-Default_Handler
/******************************************************************************
*
* The minimal vector table for a Cortex M3.  Note that the proper constructs
* must be placed on this to ensure that it ends up at physical address
* 0x0000.0000.
*
******************************************************************************/    
   .section  .isr_vector,"a",%progbits
  .type  g_pfnVectors, %object
  .size  g_pfnVectors, .-g_pfnVectors
    
    
g_pfnVectors:
  .word  _irq_stack_top
  .word  Reset_Handler
  .word  NMI_Handler
  .word  HardFault_Handler
  .word  MemManage_Handler
  .word  BusFault_Handler
  .word  UsageFault_Handler
  .word  0
  .word  0
  .word  0
  .word  0
  .word  vPortSVCHandler
  .word  DebugMon_Handler
  .word  0
  .word  xPortPendSVHandler
  .word  xPortSysTickHandler
  .word  WWDG_IRQHandler
  .word  PVD_IRQHandler
  .word  TAMPER_IRQHandler
  .word  RTC_IRQHandler
  .word  FLASH_IRQHandler
  .word  RCC_IRQHandler
  .word  EXTI0_IRQHandler
  .word  EXTI1_IRQHandler
  .word  EXTI2_IRQHandler
  .word  EXTI3_IRQHandler
  .word  EXTI4_IRQHandler
  .word  DMA1_Channel1_IRQHandler
  .word  DMA1_Channel2_IRQHandler
  .word  DMA1_Channel3_IRQHandler
  .word  DMA1_Channel4_IRQHandler
  .word  DMA1_Channel5_IRQHandler
  .word  DMA1_Channel6_IRQHandler
  .word  DMA1_Channel7_IRQHandler
  .word  ADC1_2_IRQHandler
  .word  USB_HP_CAN1_TX_IRQHandler
  .word  USB_LP_CAN1_RX0_IRQHandler
  .word  CAN1_RX1_IRQHandler
  .word  CAN1_SCE_IRQHandler
  .word  EXTI9_5_IRQHandler
  .word  TIM1_BRK_IRQHandler
  .word  TIM1_UP_IRQHandler
  .word  TIM1_TRG_COM_IRQHandler
  .word  TIM1_CC_IRQHandler
  .word  TIM2_IRQHandler
  .word  TIM3_IRQHandler
  .word  TIM4_IRQHandler
  .word  I2C1_EV_IRQHandler
  .word  I2C1_ER_IRQHandler
  .word  I2C2_EV_IRQHandler
  .word  I2C2_ER_IRQHandler
  .word  SPI1_IRQHandler
  .word  SPI2_IRQHandler
  .word  USART1_IRQHandler
  .word  USART2_IRQHandler
  .word  USART3_IRQHandler
  .word  EXTI15_10_IRQHandler
  .word  RTCAlarm_IRQHandler
  .word  USBWakeUp_IRQHandler
  .word  0
  .word  0
  .word  0
  .word  0
  .word  0
  .word  0
  .word  0
  .word  BootRAM          /* @0x108. This is for boot in RAM mode for
                            STM32F10x Medium Density devices. */
   
/*******************************************************************************
*
* Provide weak aliases for each Exception handler to the Default_Handler. 
* As they are weak aliases, any function with the same name will override 
* this definition.
*
*******************************************************************************/
    .section  .text.Default_Handler_all,"ax",%progbits

  .weak  NMI_Handler
NMI_Handler_l:
	b NMI_Handler_l
.thumb_set NMI_Handler, NMI_Handler_l

//  .weak  HardFault_Handler
//HardFault_Handler_l:
// 	b HardFault_Handler_l
//.thumb_set HardFault_Handler, HardFault_Handler_l

  .weak  MemManage_Handler
MemManage_Handler_l:
	b MemManage_Handler_l
.thumb_set MemManage_Handler, MemManage_Handler_l

  .weak  BusFault_Handler
BusFault_Handler_l:
	b BusFault_Handler_l
.thumb_set BusFault_Handler, BusFault_Handler_l

  .weak  UsageFault_Handler
UsageFault_Handler_l:
	b UsageFault_Handler_l
.thumb_set UsageFault_Handler, UsageFault_Handler_l

  .weak  SVC_Handler
SVC_Handler_l:
	b SVC_Handler_l
.thumb_set SVC_Handler, SVC_Handler_l

  .weak  DebugMon_Handler
DebugMon_Handler_l:
	b DebugMon_Handler_l
.thumb_set DebugMon_Handler, DebugMon_Handler_l

  .weak  PendSV_Handler
PendSV_Handler_l:
	b PendSV_Handler_l
.thumb_set PendSV_Handler, PendSV_Handler_l

  .weak  SysTick_Handler
SysTick_Handler_l:
	b SysTick_Handler_l
.thumb_set SysTick_Handler, SysTick_Handler_l

  .weak  WWDG_IRQHandler
WWDG_IRQHandler_l:
	b WWDG_IRQHandler_l
.thumb_set WWDG_IRQHandler, WWDG_IRQHandler_l

  .weak  PVD_IRQHandler
PVD_IRQHandler_l:
	b PVD_IRQHandler_l
.thumb_set PVD_IRQHandler, PVD_IRQHandler_l

  .weak  TAMPER_IRQHandler
TAMPER_IRQHandler_l:
	b TAMPER_IRQHandler_l
.thumb_set TAMPER_IRQHandler, TAMPER_IRQHandler_l

  .weak  RTC_IRQHandler
RTC_IRQHandler_l:
	b RTC_IRQHandler_l
.thumb_set RTC_IRQHandler, RTC_IRQHandler_l

  .weak  FLASH_IRQHandler
FLASH_IRQHandler_l:
	b FLASH_IRQHandler_l
.thumb_set FLASH_IRQHandler, FLASH_IRQHandler_l

  .weak  RCC_IRQHandler
RCC_IRQHandler_l:
	b RCC_IRQHandler_l
.thumb_set RCC_IRQHandler, RCC_IRQHandler_l

  .weak  EXTI0_IRQHandler
EXTI0_IRQHandler_l:
	b EXTI0_IRQHandler_l
.thumb_set EXTI0_IRQHandler, EXTI0_IRQHandler_l

  .weak  EXTI1_IRQHandler
EXTI1_IRQHandler_l:
	b EXTI1_IRQHandler_l
.thumb_set EXTI1_IRQHandler, EXTI1_IRQHandler_l

  .weak  EXTI2_IRQHandler
EXTI2_IRQHandler_l:
	b EXTI2_IRQHandler_l
.thumb_set EXTI2_IRQHandler, EXTI2_IRQHandler_l

  .weak  EXTI3_IRQHandler
EXTI3_IRQHandler_l:
	b EXTI3_IRQHandler_l
.thumb_set EXTI3_IRQHandler, EXTI3_IRQHandler_l

  .weak  EXTI4_IRQHandler
EXTI4_IRQHandler_l:
	b EXTI4_IRQHandler_l
.thumb_set EXTI4_IRQHandler, EXTI4_IRQHandler_l

  .weak  DMA1_Channel1_IRQHandler
DMA1_Channel1_IRQHandler_l:
	b DMA1_Channel1_IRQHandler_l
.thumb_set DMA1_Channel1_IRQHandler, DMA1_Channel1_IRQHandler_l

  .weak  DMA1_Channel2_IRQHandler
DMA1_Channel2_IRQHandler_l:
	b DMA1_Channel2_IRQHandler_l
.thumb_set DMA1_Channel2_IRQHandler, DMA1_Channel2_IRQHandler_l

  .weak  DMA1_Channel3_IRQHandler
DMA1_Channel3_IRQHandler_l:
	b DMA1_Channel3_IRQHandler_l
.thumb_set DMA1_Channel3_IRQHandler, DMA1_Channel3_IRQHandler_l

  .weak  DMA1_Channel4_IRQHandler
DMA1_Channel4_IRQHandler_l:
	b DMA1_Channel4_IRQHandler_l
.thumb_set DMA1_Channel4_IRQHandler, DMA1_Channel4_IRQHandler_l

  .weak  DMA1_Channel5_IRQHandler
DMA1_Channel5_IRQHandler_l:
	b DMA1_Channel5_IRQHandler_l
.thumb_set DMA1_Channel5_IRQHandler, DMA1_Channel5_IRQHandler_l

  .weak  DMA1_Channel6_IRQHandler
DMA1_Channel6_IRQHandler_l:
	b DMA1_Channel6_IRQHandler_l
.thumb_set DMA1_Channel6_IRQHandler, DMA1_Channel6_IRQHandler_l

  .weak  DMA1_Channel7_IRQHandler
DMA1_Channel7_IRQHandler_l:
	b DMA1_Channel7_IRQHandler_l
.thumb_set DMA1_Channel7_IRQHandler, DMA1_Channel7_IRQHandler_l

  .weak  ADC1_2_IRQHandler
ADC1_2_IRQHandler_l:
	b ADC1_2_IRQHandler_l
.thumb_set ADC1_2_IRQHandler, ADC1_2_IRQHandler_l

  .weak  USB_HP_CAN1_TX_IRQHandler
USB_HP_CAN1_TX_IRQHandler_l:
	b USB_HP_CAN1_TX_IRQHandler_l
.thumb_set USB_HP_CAN1_TX_IRQHandler, USB_HP_CAN1_TX_IRQHandler_l

  .weak  USB_LP_CAN1_RX0_IRQHandler
USB_LP_CAN1_RX0_IRQHandler_l:
	b USB_LP_CAN1_RX0_IRQHandler_l
.thumb_set USB_LP_CAN1_RX0_IRQHandler, USB_LP_CAN1_RX0_IRQHandler_l

  .weak  CAN1_RX1_IRQHandler
CAN1_RX1_IRQHandler_l:
	b CAN1_RX1_IRQHandler_l
.thumb_set CAN1_RX1_IRQHandler, CAN1_RX1_IRQHandler_l

  .weak  CAN1_SCE_IRQHandler
CAN1_SCE_IRQHandler_l:
	b CAN1_SCE_IRQHandler_l
.thumb_set CAN1_SCE_IRQHandler, CAN1_SCE_IRQHandler_l

  .weak  EXTI9_5_IRQHandler
EXTI9_5_IRQHandler_l:
	b EXTI9_5_IRQHandler_l
.thumb_set EXTI9_5_IRQHandler, EXTI9_5_IRQHandler_l

  .weak  TIM1_BRK_IRQHandler
TIM1_BRK_IRQHandler_l:
	b TIM1_BRK_IRQHandler_l
.thumb_set TIM1_BRK_IRQHandler, TIM1_BRK_IRQHandler_l

  .weak  TIM1_UP_IRQHandler
TIM1_UP_IRQHandler_l:
	b TIM1_UP_IRQHandler_l
.thumb_set TIM1_UP_IRQHandler, TIM1_UP_IRQHandler_l

  .weak  TIM1_TRG_COM_IRQHandler
TIM1_TRG_COM_IRQHandler_l:
	b TIM1_TRG_COM_IRQHandler_l
.thumb_set TIM1_TRG_COM_IRQHandler, TIM1_TRG_COM_IRQHandler_l

  .weak  TIM1_CC_IRQHandler
TIM1_CC_IRQHandler_l:
	b TIM1_CC_IRQHandler_l
.thumb_set TIM1_CC_IRQHandler, TIM1_CC_IRQHandler_l

  .weak  TIM2_IRQHandler
TIM2_IRQHandler_l:
	b TIM2_IRQHandler_l
.thumb_set TIM2_IRQHandler, TIM2_IRQHandler_l

  .weak  TIM3_IRQHandler
TIM3_IRQHandler_l:
	b TIM3_IRQHandler_l
.thumb_set TIM3_IRQHandler, TIM3_IRQHandler_l

  .weak  TIM4_IRQHandler
TIM4_IRQHandler_l:
	b TIM4_IRQHandler_l
.thumb_set TIM4_IRQHandler, TIM4_IRQHandler_l

  .weak  I2C1_EV_IRQHandler
I2C1_EV_IRQHandler_l:
	b I2C1_EV_IRQHandler_l
.thumb_set I2C1_EV_IRQHandler, I2C1_EV_IRQHandler_l

  .weak  I2C1_ER_IRQHandler
I2C1_ER_IRQHandler_l:
	b I2C1_ER_IRQHandler_l
.thumb_set I2C1_ER_IRQHandler, I2C1_ER_IRQHandler_l

  .weak  I2C2_EV_IRQHandler
I2C2_EV_IRQHandler_l:
	b I2C2_EV_IRQHandler_l
.thumb_set I2C2_EV_IRQHandler, I2C2_EV_IRQHandler_l

  .weak  I2C2_ER_IRQHandler
I2C2_ER_IRQHandler_l:
	b I2C2_ER_IRQHandler_l
.thumb_set I2C2_ER_IRQHandler, I2C2_ER_IRQHandler_l

  .weak  SPI1_IRQHandler
SPI1_IRQHandler_l:
	b SPI1_IRQHandler_l
.thumb_set SPI1_IRQHandler, SPI1_IRQHandler_l

  .weak  SPI2_IRQHandler
SPI2_IRQHandler_l:
	b SPI2_IRQHandler_l
.thumb_set SPI2_IRQHandler, SPI2_IRQHandler_l

  .weak  USART1_IRQHandler
USART1_IRQHandler_l:
	b USART1_IRQHandler_l
.thumb_set USART1_IRQHandler, USART1_IRQHandler_l

  .weak  USART2_IRQHandler
USART2_IRQHandler_l:
	b USART2_IRQHandler_l
.thumb_set USART2_IRQHandler, USART2_IRQHandler_l

  .weak  USART3_IRQHandler
USART3_IRQHandler_l:
	b USART3_IRQHandler_l
.thumb_set USART3_IRQHandler, USART3_IRQHandler_l

  .weak  EXTI15_10_IRQHandler
EXTI15_10_IRQHandler_l:
	b EXTI15_10_IRQHandler_l
.thumb_set EXTI15_10_IRQHandler, EXTI15_10_IRQHandler_l

  .weak  RTCAlarm_IRQHandler
RTCAlarm_IRQHandler_l:
	b RTCAlarm_IRQHandler_l
.thumb_set RTCAlarm_IRQHandler, RTCAlarm_IRQHandler_l

  .weak  USBWakeUp_IRQHandler
USBWakeUp_IRQHandler_l:
	b USBWakeUp_IRQHandler_l
.thumb_set USBWakeUp_IRQHandler, USBWakeUp_IRQHandler_l

  .size  Default_Handler_all, .-Default_Handler_all

