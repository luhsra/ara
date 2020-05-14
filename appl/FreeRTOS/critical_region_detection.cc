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


inline void tmp_function(int b){
    int a = b;
    b = a + 1243;
}

void tmp_function_2(int b){
    
   taskEXIT_CRITICAL( );
}


void tmp_function_1(int b){
    
    if(b == 23){
        taskEXIT_CRITICAL( );
        tmp_function(346);
    }
    else tmp_function(23);
}   

/* A task that uses the semaphore. */
void Task1( void * pvParameters )
{   
    taskENTER_CRITICAL();
    
    //critical region is not leaft certainly ->ERROR
    tmp_function_1(34);
 
    vPrintStringAndNumber( "TEST" , 12345667 );
}

 void Task2( void *pvParameters ){
    
    taskENTER_CRITICAL();
    
 	//critical area is not leaft ->ERROR
}



 void Task3( void *pvParameters ){
    
    taskENTER_CRITICAL();
 	
    //abbs in critical area
    
    tmp_function(23);
    taskEXIT_CRITICAL();
    //critical area is leaft ->NO ERROR
}


 void Task4( void *pvParameters ){
    
    taskENTER_CRITICAL();
 	
    //abbs in critical area
    
    tmp_function(23);
}
    
void Task5( void *pvParameters ){
    
    taskENTER_CRITICAL();
 	
    //abbs in critical area
    
    tmp_function_2(342);

    //critical area is leaft ->NO ERROR
}

 void Task6( void *pvParameters ){
    
    taskENTER_CRITICAL();
 	
    //abbs in critical area
    
    tmp_function_1(23);
    vPrintStringAndNumber( "TEST" , 12345667 );
}


int main( void ){
    


    xTaskCreate( Task1, "Task1", 100, NULL, 1, NULL );
    xTaskCreate( Task2, "Task2", 100, NULL, 2, NULL );
    xTaskCreate( Task3, "Task3", 100, NULL, 1, NULL );
    xTaskCreate( Task4, "Task4", 100, NULL, 2, NULL );
    xTaskCreate( Task5, "Task5", 100, NULL, 2, NULL );
    xTaskCreate( Task6, "Task6", 100, NULL, 2, NULL );
    vTaskStartScheduler();
    

    for( ;; );

    return 0;

}
