
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
SemaphoreHandle_t xBinaryḾutex;
/* Before a semaphore is used it must be explicitly created. In this example a
counting semaphore is created. The semaphore is created to have a maximum count
value of 10, and an initial count value of 0. */
SemaphoreHandle_t xCountingSemaphore;

SemaphoreHandle_t xMutex;
static void prvNewPrintString( const char *pcString )
{
	
	 
	/* The mutex is created before the scheduler is started, so already exists by the
	time this task executes.
	Attempt to take the mutex, blocking indefinitely to wait for the mutex if it is
	not available straight away. The call to xSemaphoreTake() will only return when
	the mutex has been successfully obtained, so there is no need to check the
	function return value. If any other delay period was used then the code must
	check that xSemaphoreTake() returns pdTRUE before accessing the shared resource
	(which in this case is standard out). As noted earlier in this book, indefinite
	time outs are not recommended for production code. */
	xSemaphoreTake( xMutex, portMAX_DELAY );
	
	xSemaphoreGive( xMutex );
}

static void prvPrintTask( void *pvParameters ){
	char *pcStringToPrint;
	const TickType_t xMaxBlockTimeTicks = 0x20;
	
	
	 TickType_t xTicksToWait = 120;
	 
	 vTaskDelay( ( xTicksToWait ) );
	 
	 xTicksToWait = 1230;
	/* Two instances of this task are created. The string printed by the task is
	passed into the task using the task’s parameter. The parameter is cast to the
	required type. */
	pcStringToPrint = ( char * ) pvParameters;
	for( ;; ){
		/* Print out the string using the newly defined function. */
		prvNewPrintString( pcStringToPrint );
		/* Wait a pseudo random time. Note that rand() is not necessarily reentrant,
		but in this case it does not really matter as the code does not care what
		value is returned. In a more secure application a version of rand() that is
		known to be reentrant should be used - or calls to rand() should be protected
		using a critical section. */
		vTaskDelay( ( xMaxBlockTimeTicks ) );
	}
}


/* Recursive mutexes are variables of type SemaphoreHandle_t. */
SemaphoreHandle_t xRecursiveMutex;

/* The implementation of a task that creates and uses a recursive mutex. */
void vTaskFunction( void *pvParameters ){
	const TickType_t xMaxBlock20ms = pdMS_TO_TICKS( 20 );
	/* Before a recursive mutex is used it must be explicitly created. */
	xRecursiveMutex = xSemaphoreCreateRecursiveMutex();
	/* Check the semaphore was created successfully.
	section 11.2. */
	configASSERT( xRecursiveMutex );
	//configASSERT() is described in
	/* As per most tasks, this task is implemented as an infinite loop. */
	for( ;; )
	{
		/* ... */
		/* Take the recursive mutex. */
		if( xSemaphoreTakeRecursive( xRecursiveMutex, xMaxBlock20ms ) == pdPASS ){
			/* The recursive mutex was successfully obtained. The task can now access
			the resource the mutex is protecting. At this point the recursive call
			count (which is the number of nested calls to xSemaphoreTakeRecursive())
			is 1, as the recursive mutex has only been taken once. */
			/* While it already holds the recursive mutex, the task takes the mutex
			again. In a real application, this is only likely to occur inside a sub-
			function called by this task, as there is no practical reason to knowingly
			take the same mutex more than once. The calling task is already the mutex
			holder, so the second call to xSemaphoreTakeRecursive() does nothing more
			than increment the recursive call count to 2. */
			xSemaphoreTakeRecursive( xRecursiveMutex, xMaxBlock20ms );
			/* ... */
			/* The task returns the mutex after it has finished accessing the resource
			the mutex is protecting. At this point the recursive call count is 2, so
			the first call to xSemaphoreGiveRecursive() does not return the mutex.
			Instead, it simply decrements the recursive call count back to 1. */
			xSemaphoreGiveRecursive( xRecursiveMutex );
			/* The next call to xSemaphoreGiveRecursive() decrements the recursive call
			count to 0, so this time the recursive mutex is returned.*/
			xSemaphoreGiveRecursive( xRecursiveMutex );
			/* Now one call to xSemaphoreGiveRecursive() has been executed for every
			proceeding call to xSemaphoreTakeRecursive(), so the task is no longer the
			mutex holder.*/
			
			
		}
	}
}


int main( void )
{
	/* Before a semaphore is used it must be explicitly created.
	a binary semaphore is created. */
	xBinaryḾutex =  xSemaphoreCreateMutex( );
	xMutex =  xSemaphoreCreateMutex( );
	xBinarySemaphore = xSemaphoreCreateBinary();
	
	prvNewPrintString( "TEST");
	
	xCountingSemaphore = xSemaphoreCreateCounting( 10, 0 );
	/* Check the semaphore was created successfully. */
	if( xBinarySemaphore != NULL ){
		/* Create the 'handler' task, which is the task to which interrupt
		processing is deferred. This is the task that will be synchronized with
		the interrupt. The handler task is created with a high priority to ensure
		it runs immediately after the interrupt exits. In this case a priority of
		3 is chosen. */
		const configSTACK_DEPTH_TYPE  test = 100;
		
		xTaskCreate( vTaskFunction, "Handler", test, NULL, 3, NULL );
		/* Create the task that will periodically generate a software interrupt.
		This is created with a priority below the handler task to ensure it will
		get preempted each time the handler task exits the Blocked state. */
		xTaskCreate( prvPrintTask, "Periodic", 1000, NULL, 1, NULL );
		
		
		/* Install the handler for the software interrupt. The syntax necessary
		to do this is dependent on the FreeRTOS port being used. The syntax
		shown here can only be used with the FreeRTOS windows port, where such
		interrupts are only simulated. */
		//vPortSetInterruptHandler( mainINTERRUPT_NUMBER, ulExampleInterruptHandler );
		/* Start the scheduler so the created tasks start executing. */
		vTaskStartScheduler();
		
		
	
	}
	xTaskCreate( prvPrintTask, "AFTER SCHEDULER", 1000, NULL, 1, NULL );
	
	/* As normal, the following line should never be reached. */
	for( ;; );
}
