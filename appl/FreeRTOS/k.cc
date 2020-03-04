
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "timers.h"
#include "semphr.h"
#include "event_groups.h"
#include <stdint.h>

/* Definitions for the event bits */
#define mainFIRST_TASK_BIT (2)
#define mainSECOND_TASK_BIT (4)
#define mainISR_BIT  (5)

EventGroupHandle_t xEventGroup;

static void vEventBitSettingTask( void *pvParameters ){
	const TickType_t xDelay200ms = pdMS_TO_TICKS( 200UL ), xDontBlock = 0;
	for( ;; ){
		/* Delay for a short while before starting the next loop. */
		vTaskDelay( xDelay200ms );
		/* Print out a message to say event bit 0 is about to be set by the task,
		then set event bit 0. */
		xEventGroupSetBits( xEventGroup, mainFIRST_TASK_BIT );
		/* Delay for a short while before setting the other bit. */
		vTaskDelay( xDelay200ms );
		/* Print out a message to say event bit 1 is about to be set by the task,
		then set event bit 1. */
		xEventGroupSetBits( xEventGroup, mainSECOND_TASK_BIT );
	}
}

static void vPrintStringFromDaemonTask(){
	int tmp  = 1;
}

static uint32_t ulEventBitSettingISR( void ){
	/* The string is not printed within the interrupt service routine, but is instead
	sent to the RTOS daemon task for printing. It is therefore declared static to ensure
	the compiler does not allocate the string on the stack of the ISR, as the ISR's stack
	frame will not exist when the string is printed from the daemon task. */
	static const char *pcString = "Bit setting ISR -\t about to set bit 2.\r\n";
	BaseType_t xHigherPriorityTaskWoken = pdFALSE;
	/* Print out a message to say bit 2 is about to be set. Messages cannot be
	printed from an ISR, so defer the actual output to the RTOS daemon task by
	pending a function call to run in the context of the RTOS daemon task. */
	//TODO xTimerPendFunctionCallFromISR( vPrintStringFromDaemonTask,( void * ) pcString,0,	&xHigherPriorityTaskWoken );
	/* Set bit 2 in the event group. */
	xEventGroupSetBitsFromISR( xEventGroup, mainISR_BIT, &xHigherPriorityTaskWoken );
	/* xTimerPendFunctionCallFromISR() and xEventGroupSetBitsFromISR() both write to
	the timer command queue, and both used the same xHigherPriorityTaskWoken
	variable. If writing to the timer command queue resulted in the RTOS daemon task
	leaving the Blocked state, and if the priority of the RTOS daemon task is higher
	than the priority of the currently executing task (the task this interrupt
	interrupted) then xHigherPriorityTaskWoken will have been set to pdTRUE.
	.
	xHigherPriorityTaskWoken is used as the parameter to portYIELD_FROM_ISR(). If
	xHigherPriorityTaskWoken equals pdTRUE, then calling portYIELD_FROM_ISR() will
	request a context switch. If xHigherPriorityTaskWoken is still pdFALSE, then
	calling portYIELD_FROM_ISR() will have no effect.
	The implementation of portYIELD_FROM_ISR() used by the Windows port includes a
	return statement, which is why this function does not explicitly return a
	value. */
	//TODO portYIELD_FROM_ISR( xHigherPriorityTaskWoken );
}

void vEventBitReadingTask( void *pvParameters ){
	EventBits_t xEventGroupValue;
	const EventBits_t xBitsToWaitFor = ( mainFIRST_TASK_BIT |mainSECOND_TASK_BIT |mainISR_BIT );
	for( ;; ){
		/* Block to wait for event bits to become set within the event group. */
		xEventGroupValue = xEventGroupWaitBits( /* The event group to read. */
		xEventGroup,
		/* Bits to test. */
		xBitsToWaitFor,
		/* Clear bits on exit if the
		unblock condition is met. */
		pdTRUE,
		/* Don't wait for all bits. This
		parameter is set to pdTRUE for the
		second execution. */
		pdFALSE,
		/* Don't time out. */
		portMAX_DELAY );
		/* Print a message for each bit that was set. */
		if( ( xEventGroupValue & mainFIRST_TASK_BIT ) != 0 ){
			
		}
		if( ( xEventGroupValue & mainSECOND_TASK_BIT ) != 0 ){
		}
		if( ( xEventGroupValue & mainISR_BIT ) != 0 ){
		}
	}
}

int main( void ){
	/* Before an event group can be used it must first be created. */
	xEventGroup = xEventGroupCreate();
	/* Create the task that sets event bits in the event group. */
	
	for(int i = 0; i < 10; i++){
		xTaskCreate( vEventBitSettingTask, "Bit Setter", 1000, NULL, 1, NULL );
	};
	/* Create the task that waits for event bits to get set in the event group. */
	xTaskCreate( vEventBitReadingTask, "Bit Reader", 1000, NULL, 2, NULL );
	/* Create the task that is used to periodically generate a software interrupt. */
	//xTaskCreate( vInterruptGenerator, "Int Gen", 1000, NULL, 3, NULL );
	/* Install the handler for the software interrupt. The syntax necessary to do
	this is dependent on the FreeRTOS port being used. The syntax shown here can
	only be used with the FreeRTOS Windows port, where such interrupts are only
	simulated. */
	//TODO vPortSetInterruptHandler( 2, ulEventBitSettingISR );
	/* Start the scheduler so the created tasks start executing. */
	vTaskStartScheduler();
	/* The following line should never be reached. */
	for( ;; );
	return 0;
}
