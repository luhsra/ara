
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "timers.h"
#include "semphr.h"
#include "event_groups.h"
#include "stream_buffer.h"
#include "message_buffer.h"

#include <stdint.h>

/* Definitions for the event bits */
#define mainFIRST_TASK_BIT (2)
#define mainSECOND_TASK_BIT (4)
#define mainISR_BIT  (5)

void portSAVE_CONTEXT();
void portRESTORE_CONTEXT();
void portYIELD_FROM_ISR();

EventGroupHandle_t xEventGroup;

void tmp(void *) __attribute__((interrupt("IRQ")));

void tmp(void *){
	int a = 0;
}
/* Declare the wrapper function using the naked attribute.*/
void vASwitchCompatibleISR_Wrapper( void ) __attribute__ ((naked));

/* Declare the handler function as an ordinary function.*/
void vASwitchCompatibleISR_Handler( void );

int test();
/* The handler function is just an ordinary function. */
void vASwitchCompatibleISR_Handler( void )
{
	long lSwitchRequired = pdFALSE;

	
	/* ISR code comes here.  If the ISR wakes a task then
		lSwitchRequired should be set to 1. */


	/* If the ISR caused a task to unblock, and the priority 
	of the unblocked task is higher than the priority of the
	interrupted task then the ISR should return directly into 
	the unblocked task.  portYIELD_FROM_ISR() is used for this 
	purpose. */
	if( lSwitchRequired )
	{
		portYIELD_FROM_ISR();
	}
}

void vASwitchCompatibleISR_Wrapper( void )
{
	/* Save the context of the interrupted task. */
	//portSAVE_CONTEXT();
	
	/*Call the handler function.  This must be a separate 
	function unless you can guarantee that handling the 
	interrupt will never use any stack space. */
	//vASwitchCompatibleISR_Handler();

	/* Restore the context of the task that is going to 
	execute next. This might not be the same as the originally 
	interrupted task.*/
	//portRESTORE_CONTEXT();
}


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


void vAFunction( void )
{
StreamBufferHandle_t xStreamBuffer;
const size_t xStreamBufferSizeBytes = 100, xTriggerLevel = 10;

    /* Create a stream buffer that can hold 100 bytes.  The memory used to hold
    both the stream buffer structure and the data in the stream buffer is
    allocated dynamically. */
    xStreamBuffer = xStreamBufferCreate( xStreamBufferSizeBytes, xTriggerLevel );

    if( xStreamBuffer == NULL )
    {
        /* There was not enough heap memory space available to create the
        stream buffer. */
    }
    else
    {
        /* The stream buffer was created successfully and can now be used. */
    }
}




void vBFunction( void ){
	MessageBufferHandle_t xMessageBuffer;
	const size_t xMessageBufferSizeBytes = 100;

    /* Create a message buffer that can hold 100 bytes.  The memory used to hold
    both the message buffer structure and the data in the message buffer is
    allocated dynamically. */
    xMessageBuffer = xMessageBufferCreate( xMessageBufferSizeBytes );

    if( xMessageBuffer == NULL )
    {
        /* There was not enough heap memory space available to create the
        message buffer. */
    }
    else
    {
        /* The message buffer was created successfully and can now be used. */
    }
}

int fake_create() {
	xTaskCreate( vEventBitSettingTask, "Bit Setter", 1000, NULL, 1, NULL );
	test();
}

int test1();

int test(){
	test1();
	fake_create();
}

int test1(){
	test();
}

int main( void ){
	/* Before an event group can be used it must first be created. */
	xEventGroup = xEventGroupCreate();
	/* Create the task that sets event bits in the event group. */
	
	for(int i = 0; i < 10; i++){
		for(int j = 0; j < 10; j++){
			xTaskCreate( vEventBitSettingTask, "Bit Setter", 1000, NULL, 1, NULL );
		}
	};
	

	
	for(int i = 0; i < 10 ; ++i){
		fake_create();
		
	}
	
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
