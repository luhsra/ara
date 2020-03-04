/*
	FreeRTOS.org V5.0.4 - Copyright (C) 2003-2008 Richard Barry.

	This file is part of the FreeRTOS.org distribution.

	FreeRTOS.org is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	FreeRTOS.org is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with FreeRTOS.org; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

	A special exception to the GPL can be applied should you wish to distribute
	a combined work that includes FreeRTOS.org, without being obliged to provide
	the source code for any proprietary components.  See the licensing section 
	of http://www.FreeRTOS.org for full details of how and when the exception
	can be applied.

    ***************************************************************************
    ***************************************************************************
    *                                                                         *
    * SAVE TIME AND MONEY!  We can port FreeRTOS.org to your own hardware,    *
    * and even write all or part of your application on your behalf.          *
    * See http://www.OpenRTOS.com for details of the services we provide to   *
    * expedite your project.                                                  *
    *                                                                         *
    ***************************************************************************
    ***************************************************************************

	Please ensure to read the configuration and relevant port sections of the
	online documentation.

	http://www.FreeRTOS.org - Documentation, latest information, license and 
	contact details.

	http://www.SafeRTOS.com - A version that is certified for use in safety 
	critical systems.

	http://www.OpenRTOS.com - Commercial support, development, porting, 
	licensing and training services.
*/

/* FreeRTOS.org includes. */
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "semphr.h"

#include <stdint.h>


/* Declare two variables of type QueueHandle_t. Both queues are added to the same queue set. */

static QueueHandle_t xQueue1 = NULL, xQueue2 = NULL;



/* The handle of the binary semaphore. */

SemaphoreHandle_t xBinaryMutex1;
SemaphoreHandle_t xBinaryMutex2;
SemaphoreHandle_t xBinaryMutex3;

/* The queue set to which the two queues and the binary semaphore belong. */




void vSenderTask1( void *pvParameters )
{
    xSemaphoreTake(  xBinaryMutex1,1000 );
    xSemaphoreTake(  xBinaryMutex2,1000 );
    const TickType_t xBlockTime = pdMS_TO_TICKS( 100 );

    const char * const pcMessage = "Message from vSenderTask1\r\n";

    /* As per most tasks, this task is implemented within an infinite loop. */
    xSemaphoreGive(  xBinaryMutex2);
    xSemaphoreGive(  xBinaryMutex1);
   
    
    for( ;; )

    {
        /* Block for 100ms. */

        vTaskDelay( xBlockTime );

        /* Send this task's string to xQueue1. It is not necessary to use a block time, even though the queue can only hold one item. This is because the priority of the task that reads from the queue is higher than the priority of this task. As soon as this task writes to the queue, it will be preempted by the task that reads from the queue, so the queue will already be empty  again by the time the call to xQueueSend() returns. The block time is set to 0. */


    }
}

/*-----------------------------------------------------------*/

void vSenderTask2( void *pvParameters ){
    xSemaphoreTake(  xBinaryMutex2,1000 );
    xSemaphoreTake(  xBinaryMutex3,1000 );
    const TickType_t xBlockTime = pdMS_TO_TICKS( 200 );

    const char * const pcMessage = "Message from vSenderTask2\r\n";

    /* As per most tasks, this task is implemented within an infinite loop. */
    xSemaphoreGive(  xBinaryMutex3);
    xSemaphoreGive(  xBinaryMutex2);
    for( ;; )

    {

        /* Block for 200ms. */

        vTaskDelay( xBlockTime );

        /* Send this task's string to xQueue2. It is not necessary to use a block time, even though the queue can only hold one item. This is because the priority of the task that reads from the queue is higher than the priority of this task. As soon as this task writes to the queue, it will be preempted by the task that reads from the queue, so the queue will already be empty again by the time the call to xQueueSend() returns. The block time is set to 0. */


    }
    

}

void vSenderTask3( void *pvParameters ){
    xSemaphoreTake(  xBinaryMutex3,1000 );
    xSemaphoreTake(  xBinaryMutex1,1000 );
    const TickType_t xBlockTime = pdMS_TO_TICKS( 200 );

    const char * const pcMessage = "Message from vSenderTask2\r\n";

    /* As per most tasks, this task is implemented within an infinite loop. */
    xSemaphoreGive(  xBinaryMutex1);
    xSemaphoreGive(  xBinaryMutex3);
    for( ;; )

    {
        /* Block for 200ms. */
        vTaskDelay( xBlockTime );
        /* Send this task's string to xQueue2. It is not necessary to use a block time, even though the queue can only hold one item. This is because the priority of the task that reads from the queue is higher than the priority of this task. As soon as this task writes to the queue, it will be preempted by the task that reads from the queue, so the queue will already be empty again by the time the call to xQueueSend() returns. The block time is set to 0. */
    }
}

int main( void ){
    
    xBinaryMutex1 = xSemaphoreCreateMutex();
    xBinaryMutex2 = xSemaphoreCreateMutex();
    xBinaryMutex3 = xSemaphoreCreateMutex();


    /* Create the tasks that send to the queues. */
    xTaskCreate( vSenderTask1, "Sender1", 1000, NULL, 1, NULL );

    xTaskCreate( vSenderTask2, "Sender2", 1000, NULL, 1, NULL );
    
    xTaskCreate( vSenderTask3, "Sender3", 1000, NULL, 1, NULL );
    /* Start the scheduler so the created tasks start executing. */

    vTaskStartScheduler();

    /* As normal, vTaskStartScheduler() should not return, so the following lines  will never execute. */

    for( ;; );

    return 0;

}
