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
void vPrintString( const char * string );

void vPrintStringAndNumber( const char *string , int32_t number );


SemaphoreHandle_t xBinarySemaphore = NULL;


SemaphoreHandle_t xSemaphore = NULL;

/* A task that uses the semaphore. */
void vAnotherTask1( void * pvParameters )
{
    /* ... Do other things. */
    
     xSemaphoreGive( xSemaphore );  // give before take ->invalid
     
   
    if( xSemaphoreTake( xSemaphore, ( TickType_t ) 10 ) == pdTRUE )
    {
        /* We were able to obtain the semaphore and can now access the
        shared resource. */

        /* ... */

        /* We have finished accessing the shared resource.  Release the
        semaphore.*/

       
        
    }
}


/* A task that uses the semaphore. */
void vAnotherTask2( void * pvParameters )
{
    /* ... Do other things. */

   
    if( xSemaphoreTake( xSemaphore, ( TickType_t ) 10 ) == pdTRUE )
    {
        /* We were able to obtain the semaphore and can now access the
        shared resource. */

        /* ... */

        /* We have finished accessing the shared resource.  Release the
        semaphore.*/

        xSemaphoreGive( xSemaphore );
        
    }
}




void vAMoreRealisticReceiverTask( void *pvParameters )
{
	xBinarySemaphore = xSemaphoreCreateMutex();
    xSemaphoreTake( xBinarySemaphore, 0 );

}

int main( void )

{
    xSemaphore = xSemaphoreCreateMutex();
  
    /* Create the tasks that send to the queues. */
    xTaskCreate( vAnotherTask1, "1", 1000, NULL, 2, NULL );
    xTaskCreate( vAnotherTask2, "2", 1000, NULL, 2, NULL );
    /* Create the task that reads from the queue set to determine which of the two queues contain data. */

    xTaskCreate( vAMoreRealisticReceiverTask, "3", 1000, NULL, 2, NULL );

    /* Start the scheduler so the created tasks start executing. */

    vTaskStartScheduler();

    /* As normal, vTaskStartScheduler() should not return, so the following lines  will never execute. */

    for( ;; );

    return 0;

}
