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
#include "source/include/FreeRTOS.h"
#include "source/include/task.h"
#include "source/include/queue.h"
#include "source/include/semphr.h"

#include <stdint.h>


/* The handle of the queue from which character pointers are received. */

QueueHandle_t xCharPointerQueue;

/* The handle of the queue from which uint32_t values are received.*/

QueueHandle_t xUint32tQueue;

/* The handle of the binary semaphore. */

SemaphoreHandle_t xBinaryMutex1;


/* The queue set to which the two queues and the binary semaphore belong. */


void Task3( void *pvParameters ){

 	struct AMessage *pxMessage;

}

void Task2( void *pvParameters )
{
    xSemaphoreTake(  xBinaryMutex1,1000 );

    const char * const pcMessage = "Message from vSenderTask1\r\n";

    /* As per most tasks, this task is implemented within an infinite loop. */
   
    for( ;; )

    {
        /* Block for 100ms. */

        vTaskDelay( xBlockTime );

         xSemaphoreGive( xBinaryMutex1);
    }
}

/*-----------------------------------------------------------*/

void Task1( void *pvParameters )
{
    xSemaphoreTake(  xBinaryMutex1,1000 );
    
    const char * const pcMessage = "Message from vSenderTask2\r\n";
  
    /* As per most tasks, this task is implemented within an infinite loop. */
    for( ;; )

    {

     

        vTaskDelay( xBlockTime );

        xSemaphoreGive( xBinaryMutex1);
        

    }
    

}




int main( void ){
    
    xBinaryMutex1 = xSemaphoreCreateMutex();

    
	
   
    /* Create the tasks */

    xTaskCreate( Task1, "Task1", 1000, NULL, 1, NULL );
    xTaskCreate( Task2, "Task2", 1000, NULL, 3, NULL );
    
    //a Task with lower priority than taks 2 exists in application, that does not the binarymutex1 
    xTaskCreate( Task3, "Task3", 1000, NULL, 2, NULL );
    
    
    
    
    
    

    /* Start the scheduler so the created tasks start executing. */

    vTaskStartScheduler();

    /* As normal, vTaskStartScheduler() should not return, so the following lines  will never execute. */

    for( ;; );

    return 0;

}
