/* Definitions for the event bits*/
#define mainFIRST_TASK_BIT ( 1UL << 0UL)
#define mainSECOND_TASK_BIT ( 1UL << 1UL)
#define mainISR_BIT ( 1UL << 2UL)                                                                                                                                                                                

#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "semphr.h"
#include "event_groups.h"
#include <stdint.h>

void vPrintString(char const *string);
EventGroupHandle_t xEventGroup;
EventGroupHandle_t xEventGroupWaitForALL;

static void vEventBitSettingTask( void *pvParameters )
{
    const TickType_t xDelay200ms = pdMS_TO_TICKS( 200UL ), xDontBlock = 0;
    for( ;; )
    {
        /* Delay for a short while before starting the next loop. */
        vTaskDelay( xDelay200ms );
        /* Print out a message to say event bit 0 is about to be set by the task,then set event bit 0. */
        vPrintString( "Bit setting task -\t about to set bit 0.\r\n" );
        xEventGroupSetBits( xEventGroup, mainFIRST_TASK_BIT );
        /* Delay for a short while before setting the other bit. */
        vTaskDelay( xDelay200ms );
        /* Print out a message to say event bit 1 is about to be set by the task, then set event bit 1. */
        vPrintString( "Bit setting task -\t about to set bit 1.\r\n" );
        xEventGroupSetBits( xEventGroup, mainSECOND_TASK_BIT );
       xEventGroupSync( xEventGroupWaitForALL, 0x08, 0x0A, 100 );
    }
}

uint32_t ulEventBitSettingISR( void )
{
    /* The string is not printed within the interrupt service routine, but is instead
    sent to the RTOS daemon task for printing. It is therefore declared static to ensure
    the compiler does not allocate the string on the stack of the ISR, as the ISR's stack
    frame will not exist when the string is printed from the daemon task. */

    static const char *pcString = "Bit setting ISR -\t about to set bit 2.\r\n";
    BaseType_t xHigherPriorityTaskWoken = pdFALSE;

    /* Print out a message to say bit 2 is about to be set. Messages cannot be
    printed from an ISR, so defer the actual output to the RTOS daemon task by
    pending a function call to run in the context of the RTOS daemon task. */

   

    /* Set bit 2 in the event group. */

    xEventGroupSetBitsFromISR( xEventGroup, mainSECOND_TASK_BIT, &xHigherPriorityTaskWoken );

    /* xTimerPendFunctionCallFromISR() and xEventGroupSetBitsFromISR() both write to
    the timer command queue, and both used the same xHigherPriorityTaskWoken
    variable. If writing to the timer command queue resulted in the RTOS daemon task
    leaving the Blocked state, and if the priority of the RTOS daemon task is higher
    than the priority of the currently executing task (the task this interrupt
    interrupted) then xHigherPriorityTaskWoken will have been set to pdTRUE.
    . xHigherPriorityTaskWoken is used as the parameter to portYIELD_FROM_ISR(). If
    xHigherPriorityTaskWoken equals pdTRUE, then calling portYIELD_FROM_ISR() will
    request a context switch. If xHigherPriorityTaskWoken is still pdFALSE, then
    calling portYIELD_FROM_ISR() will have no effect.
    The implementation of portYIELD_FROM_ISR() used by the Windows port includes a
    return statement, which is why this function does not explicitly return a
    value. */
    
     xEventGroupSetBitsFromISR( xEventGroupWaitForALL, 0x02,&xHigherPriorityTaskWoken );
    
    
    return 1;

}



static void vEventBitReadingTask( void *pvParameters )
{
    EventBits_t xEventGroupValue;
    const EventBits_t xBitsToWaitFor = ( mainFIRST_TASK_BIT |mainSECOND_TASK_BIT | mainISR_BIT );
    
    for( ;; )
    {
        /* Block to wait for event bits to become set within the event group. */
        xEventGroupValue = xEventGroupWaitBits( /* The event group to read. */    xEventGroup,    /* Bits to test. */     xBitsToWaitFor,    /* Clear bits on exit if the unblock condition is met. */   pdTRUE,    /* Don't wait for all bits. This    parameter is set to pdTRUE for the second execution. */   pdTRUE,  /* Don't time out. */ portMAX_DELAY );
        
        xEventGroupValue = xEventGroupWaitBits( /* The event group to read. */    xEventGroupWaitForALL,    /* Bits to test. */     0x04,    /* Clear bits on exit if the unblock condition is met. */   pdTRUE,    /* Don't wait for all bits. This    parameter is set to pdTRUE for the second execution. */   pdFALSE,  /* Don't time out. */ portMAX_DELAY );
    
        /* Print a message for each bit that was set. */
        if( ( xEventGroupValue & mainFIRST_TASK_BIT ) != 0 )
        {
        vPrintString( "Bit reading task -\t Event bit 0 was set\r\n" );
        }
        if( ( xEventGroupValue & mainSECOND_TASK_BIT ) != 0 )
        {
        vPrintString( "Bit reading task -\t Event bit 1 was set\r\n" );
        }
        if( ( xEventGroupValue & mainISR_BIT ) != 0 )
        {
        vPrintString( "Bit reading task -\t Event bit 2 was set\r\n" );
        }
    }
}

int main( void )
{
    /* Before an event group can be used it must first be created. */

    xEventGroup = xEventGroupCreate();
    
    
    xEventGroupWaitForALL = xEventGroupCreate();

    
    /* Create the task that sets event bits in the event group. */

    xTaskCreate( vEventBitSettingTask, "Bit Setter", 1000, NULL, 1, NULL );

    /* Create the task that waits for event bits to get set in the event group. */

    xTaskCreate( vEventBitReadingTask, "Bit Reader", 1000, NULL, 2, NULL );

    /* Create the task that is used to periodically generate a software interrupt. */

    //xTaskCreate( vInterruptGenerator, "Int Gen", 1000, NULL, 3, NULL );

    /* Install the handler for the software interrupt. The syntax necessary to do
    this is dependent on the FreeRTOS port being used. The syntax shown here can
    only be used with the FreeRTOS Windows port, where such interrupts are only
    simulated. */

    //vPortSetInterruptHandler( mainINTERRUPT_NUMBER, ulEventBitSettingISR );

    /* Start the scheduler so the created tasks start executing. */

    vTaskStartScheduler();

    /* The following line should never be reached. */
    for( ;; );
    return 0;
}
