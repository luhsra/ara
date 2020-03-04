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
#include "semphr.h"
#include <stdint.h>

/* Used as a loop counter to create a very crude delay. */
#define mainDELAY_LOOP_COUNT		( 0xffffff )

SemaphoreHandle_t xBinarySemaphore;

void vTaskFunction( void *pvParameters )
{
    char *pcTaskName;
    TickType_t xLastWakeTime;
    const TickType_t xDelay250ms = pdMS_TO_TICKS( 250);
    volatile uint32_t ul;
    /* 
    volatile to ensure ul is not optimized away. */
    /* The string to print out is passed in via the parameter.  Cast this to a
    character pointe
    r. */
    pcTaskName = ( char * ) pvParameters;
    /* As per most tasks, this task is implemented in an infinite loop. */
    for( ;; )
    {
        /*
        Delay for a perio
        d. */
        for( ul = 0; ul < mainDELAY_LOOP_COUNT; ul++ )
        {
            /* This loop is just a very crude delay implementation.  There is
            nothing to do in here.  Later exercises will replace this crude
            loop with a proper delay/sleep function. */
        }
        xSemaphoreTake(xBinarySemaphore, 12323);
        vTaskDelay(xDelay250ms );
        vTaskDelayUntil( &xLastWakeTime, pdMS_TO_TICKS( 250 )); 
        
        
    }
        
}
/*-----------------------------------------------------------*/


/* Define the strings that will be passed
in as the task parameters.  These are
defined const and 
not on
the stack to ensure they remain valid when the tasks are
executing. */
static 
const char *pcTextForTask1 = "Task 1 is running";
static const char *pcTextForTask2 = "Task 2 is running";

double a = 10;

void isr_sub_function_2();
void isr_sub_function();
//functions to ilustrate recursion
void isr_sub_function_1(){
    isr_sub_function_2();
  
    
};

void isr_entry_function(){
    
    isr_sub_function_1();
    xSemaphoreGive( xBinarySemaphore );
}

void isr_sub_function_2(){
     isr_sub_function_1();
     isr_sub_function();
}; 

void isr_sub_function(){
     BaseType_t xHigherPriorityTaskWoken;
    /* The xHigherPriorityTaskWoken parameter must be initialized to pdFALSE as
    it will get set to pdTRUE inside the interrupt safe API function if a
    context switch is required. */
    xHigherPriorityTaskWoken = pdFALSE;
    /* 'Give' the semaphore to unblock the task, passing in the address of
    xHigherPriorityTaskWoken as the interrupt safe API function's
    pxHigherPriorityTaskWoken parameter. */
    xSemaphoreGiveFromISR( xBinarySemaphore,&xHigherPriorityTaskWoken );
    /* Pass the xHigherPriorityTaskWoken value into portYIELD_FROM_ISR(). If
    xHigherPriorityTaskWoken was set to pdTRUE inside xSemaphoreGiveFromISR()
    then calling portYIELD_FROM_ISR() will request a context switch. If
    xHigherPriorityTaskWoken is still pdFALSE then calling
    portYIELD_FROM_ISR() will have no effect. Unlike most FreeRTOS ports, the
    Windows port requires the ISR to return a value - the return statement
    is inside the Windows version of portYIELD_FROM_ISR(). */
     xSemaphoreGive( xBinarySemaphore );
};

int main( void )
{
    
    xBinarySemaphore = xSemaphoreCreateBinary();
    /* Create one of the two tasks. */
    xTaskCreate(    vTaskFunction,      /* Pointer to the function that implement the task. */
    "Task 1",       /* Text name for the task.  This is to facilitate debugging only. */
    1000,           /* Stack depth-     small     microcontrollers    will use much less stack    than this. */
    NULL,    /*    Pass the text to be printed into the     task     using the task parameter   . */
    1,                    /* This task will run at priority 1. */
    NULL );          /*     The task handle is not used in this     example    . */
    /* Create the other task in    exactly the same way.  Note this time that     multiple
    tasks     are being created     from     the SAME task    implementation (vTaskFunction).  Only     the
    value passed in the parameter is different. Two instances of the same     task are being created.     */
    xTaskCreate( vTaskFunction, "Task 2", 1000,     NULL   , 1, NULL );
    /* Start the scheduler so the tasks start executing. */
    vTaskStartScheduler();    
    /* If all is well then main() will never reach here as the scheduler will 
    now be running the tasks.  If main() does reach here then it is likely that 
    there was insufficient heap memory available for the idle task to be created. 
    Chapter    2    provides more information on     heap     memory management. */
    for( ;; );
}

