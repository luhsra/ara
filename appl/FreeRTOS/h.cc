
#include "source/include/FreeRTOS.h"
#include "source/include/task.h"
#include "source/include/queue.h"
#include "source/include/semphr.h"
#include <stdint.h>


/* The number of the software interrupt used in this example. The code shown is from
the Windows project, where numbers 0 to 2 are used by the FreeRTOS Windows port
itself, so 3 is the first number available to the application. */
#define mainINTERRUPT_NUMBER 3
SemaphoreHandle_t xBinarySemaphore;

/* Before a semaphore is used it must be explicitly created. In this example a
counting semaphore is created. The semaphore is created to have a maximum count
value of 10, and an initial count value of 0. */
SemaphoreHandle_t xCountingSemaphore;

static void vPeriodicTask( void *pvParameters ){
	const TickType_t xDelay500ms = pdMS_TO_TICKS( 500UL );
	/* As per most tasks, this task is implemented within an infinite loop. */
	for( ;; ){
		/* Block until it is time to generate the software interrupt again. */
		vTaskDelay( xDelay500ms );
		/* Generate the interrupt, printing a message both before and after
		the interrupt has been generated, so the sequence of execution is evident
		from the output.
		The syntax used to generate a software interrupt is dependent on the
		FreeRTOS port being used. The syntax used below can only be used with
		the FreeRTOS Windows port, in which such interrupts are only simulated. */
		
		//vPortGenerateSimulatedInterrupt( mainINTERRUPT_NUMBER );
	
	}
}

static void vHandlerTask( void *pvParameters )
{
	/* As per most tasks, this task is implemented within an infinite loop. */
	for( ;; ){
		/* Use the semaphore to wait for the event. The semaphore was created
		before the scheduler was started, so before this task ran for the first
		time. The task blocks indefinitely, meaning this function call will only
		return once the semaphore has been successfully obtained - so there is
		no need to check the value returned by xSemaphoreTake(). */
		xSemaphoreTake( xBinarySemaphore, portMAX_DELAY );
		/* To get here the event must have occurred. Process the event (in this
		Case, just print out a message). */
	}
}

static uint32_t ulExampleInterruptHandler( void )
{
	BaseType_t xHigherPriorityTaskWoken;
	/* The xHigherPriorityTaskWoken parameter must be initialized to pdFALSE as
	it will get set to pdTRUE inside the interrupt safe API function if a
	context switch is required. */
	xHigherPriorityTaskWoken = pdFALSE;
	/* 'Give' the semaphore to unblock the task, passing in the address of
	xHigherPriorityTaskWoken as the interrupt safe API function's
	pxHigherPriorityTaskWoken parameter. */
	xSemaphoreGiveFromISR( xBinarySemaphore, &xHigherPriorityTaskWoken );
	/* Pass the xHigherPriorityTaskWoken value into portYIELD_FROM_ISR(). If
	xHigherPriorityTaskWoken was set to pdTRUE inside xSemaphoreGiveFromISR()
	then calling portYIELD_FROM_ISR() will request a context switch. If
	xHigherPriorityTaskWoken is still pdFALSE then calling
	portYIELD_FROM_ISR() will have no effect. Unlike most FreeRTOS ports, the
	Windows port requires the ISR to return a value - the return statement
	is inside the Windows version of portYIELD_FROM_ISR(). */
	//portYIELD_FROM_ISR( xHigherPriorityTaskWoken );
}


static uint32_t ulExampleInterruptHandler_additional( void )
{
	BaseType_t xHigherPriorityTaskWoken;
	/* The xHigherPriorityTaskWoken parameter must be initialized to pdFALSE as it
	will get set to pdTRUE inside the interrupt safe API function if a context switch
	is required. */
	xHigherPriorityTaskWoken = pdFALSE;
	/* 'Give' the semaphore multiple times. The first will unblock the deferred
	interrupt handling task, the following 'gives' are to demonstrate that the
	semaphore latches the events to allow the task to which interrupts are deferred
	to process them in turn, without events getting lost. This simulates multiple
	interrupts being received by the processor, even though in this case the events
	are simulated within a single interrupt occurrence. */
	xSemaphoreGiveFromISR( xCountingSemaphore, &xHigherPriorityTaskWoken );
	xSemaphoreGiveFromISR( xCountingSemaphore, &xHigherPriorityTaskWoken );
	xSemaphoreGiveFromISR( xCountingSemaphore, &xHigherPriorityTaskWoken );
	/* Pass the xHigherPriorityTaskWoken value into portYIELD_FROM_ISR(). If
	xHigherPriorityTaskWoken was set to pdTRUE inside xSemaphoreGiveFromISR() then
	calling portYIELD_FROM_ISR() will request a context switch. If
	xHigherPriorityTaskWoken is still pdFALSE then calling portYIELD_FROM_ISR() will
	have no effect. Unlike most FreeRTOS ports, the Windows port requires the ISR to
	return a value - the return statement is inside the Windows version of
	portYIELD_FROM_ISR(). */
}

int main( void )
{
	/* Before a semaphore is used it must be explicitly created.
	a binary semaphore is created. */
	xBinarySemaphore = xSemaphoreCreateBinary();
	xCountingSemaphore = xSemaphoreCreateCounting( 10, 0 );
	/* Check the semaphore was created successfully. */
	if( xBinarySemaphore != NULL ){
		/* Create the 'handler' task, which is the task to which interrupt
		processing is deferred. This is the task that will be synchronized with
		the interrupt. The handler task is created with a high priority to ensure
		it runs immediately after the interrupt exits. In this case a priority of
		3 is chosen. */
		xTaskCreate( vHandlerTask, "Handler", 1000, NULL, 3, NULL );
		/* Create the task that will periodically generate a software interrupt.
		This is created with a priority below the handler task to ensure it will
		get preempted each time the handler task exits the Blocked state. */
		xTaskCreate( vPeriodicTask, "Periodic", 1000, NULL, 1, NULL );
		/* Install the handler for the software interrupt. The syntax necessary
		to do this is dependent on the FreeRTOS port being used. The syntax
		shown here can only be used with the FreeRTOS windows port, where such
		interrupts are only simulated. */
		//vPortSetInterruptHandler( mainINTERRUPT_NUMBER, ulExampleInterruptHandler );
		/* Start the scheduler so the created tasks start executing. */
		vTaskStartScheduler();
	}
	/* As normal, the following line should never be reached. */
	for( ;; );
}
