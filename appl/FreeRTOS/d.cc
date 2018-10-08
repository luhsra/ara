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
#include <stdint.h>

/* Used as a loop counter to create a very crude delay. */
#define mainDELAY_LOOP_COUNT		( 0xffffff )

void vPrintString( const char * string );
void vTask1( void *pvParameters );
void vTask2( void *pvParameters );

/* Declare a variable that is used to hold the handle of Task 2. */
TaskHandle_t xTask2Handle = NULL;

/* Declare a variable that will be incremented by the hook function. */
volatile uint32_t ulIdleCycleCount = 0UL;
/* Idle hook functions MUST be called vApplicationIdleHook(), take no parameters,and return void. */

//Idle task 
void vApplicationIdleHook( void )
{
    /* This hook function does nothing but increment a counter. */
    ulIdleCycleCount++;
}

/*-----------------------------------------------------------*/


void vTask1( void *pvParameters )
{
    const TickType_t xDelay100ms = pdMS_TO_TICKS( 100UL );

    for( ;; )
    {
        /* Print out the name of this task. */
        vPrintString( "Task 1 is running" );
        /* Create task 2 at a higher priority.  Again the task parameter is not 
        used so is set to NULL - BUT this time the task handle is required so
        the address of xTask2Handle is passed as the last parameter.    */
        xTaskCreate( vTask2, "Task 2", 1000, NULL, 2, &xTask2Handle );
        /* The task handle is the last parameter  ^^^^^^^^^^^^^ */
        /* Task 2 has/had the higher priority, so for Task 1 to reach here Task
        * 2 must have already executed and deleted itself.  Delay for 100 milliseconds. */
        vTaskDelay( xDelay100ms );
    }
}


void vTask2( void *pvParameters )
{
    /* 
    Task 2does nothing but delete itself.  To do this it could call vTaskDelete() using NULL as the 
    parameter, but instead, and purely for demonst ration purposes, it calls vTaskDelete() passing its own task handle. */
    vPrintString( "Task 2 is running and about to delete itself" );
    vTaskDelete( xTask2Handle );
}

int main( void )
{
    /* Create the first task at priority 1.  The task parameter is not used 
    so is set to NULL.  The task handle is also not used so likewise is set 
    to NULL. */
    xTaskCreate( vTask1, "Task 1", 1000, NULL, 1, NULL );
    /* The task is created at priority 1 ^. */
    /* Start the scheduler so the task starts executing. */
    vTaskStartScheduler();    
    /* main()should never reach here as the scheduler has been started. */
    for( ;; );
}
