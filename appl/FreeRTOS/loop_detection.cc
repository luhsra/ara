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
void vPrintString( const char * string );

void vPrintStringAndNumber( const char *string , int32_t number );


/* Declare two variables of type QueueHandle_t. Both queues are added to the same queue set. */

static QueueHandle_t xQueue1 = NULL, xQueue2 = NULL;



/* The handle of the queue from which character pointers are received. */

QueueHandle_t xCharPointerQueue;

/* The handle of the queue from which uint32_t values are received.*/

QueueHandle_t xUint32tQueue;

/* The handle of the binary semaphore. */

SemaphoreHandle_t xBinaryMutex1;
SemaphoreHandle_t xBinaryMutex2;
SemaphoreHandle_t xBinaryMutex3;
SemaphoreHandle_t xBinarySemaphore;

/* The queue set to which the two queues and the binary semaphore belong. */
void vSenderTask2( void *pvParameters );
void test_function_2();
void test_function_3();

void test_function_1(){
    
    test_function_2();
}

void test_function_2(){
    
    test_function_3();
}

void test_function_3(){
    
    vSenderTask2(nullptr);
}

void vSenderTask1( void *pvParameters )
{
    for( ;; )
    {
        xQueue1 = xQueueCreate( 100,1);
        
        test_function_1();
    }
}

void vSenderTask2( void *pvParameters )
{
    xQueue2 = xQueueCreate( 100,1);
}

int main( void ){
    
   

    /* Create the tasks that send to the queues. */

    xTaskCreate( vSenderTask1, "Task1", 1000, NULL, 1, NULL );
    
    
    xTaskCreate( vSenderTask2, "Task2", 1000, NULL, 1, NULL );

    vTaskStartScheduler();

    /* As normal, vTaskStartScheduler() should not return, so the following lines  will never execute. */

    for( ;; );

    return 0;

}
