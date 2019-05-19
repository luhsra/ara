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
    the source code for any proprietary componene licensing section
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
#include "source/include/queue.h"
#include "source/include/semphr.h"
#include "source/include/task.h"

#include <stdint.h>
void vPrintString(const char* string);

void vPrintStringAndNumber(const char* string, int32_t number);

inline void tmp_function(int b) {
	int a = b;
	b = a + 1243;
}

/* A task that uses the semaphore. */
void Task1(void* pvParameters) {
	// abbs have after scheduler relation
	tmp_function(34);
}

void start_scheduler_func(int b) {
	if (b == 100)
		vTaskStartScheduler();

	// abbs have uncertain scheduler relation
	tmp_function(45);

	vTaskStartScheduler();

	// abbs have after scheduler relation
	tmp_function(45);

	return;
}

int main(void) {
	int a = 4;
	// abbs have before scheduler relation
	tmp_function(435);

	if (23423 == a) {
		// abbs have before scheduler relation
		start_scheduler_func(324);
	}

	// abbs have uncertain scheduler relation
	tmp_function(324);

	xTaskCreate(Task1, "Task1", 1000, NULL, 1, NULL);

	vTaskStartScheduler();

	// abbs have certain scheduler relation after start scheduler
	tmp_function(435);

	for (;;)
	return 0;
}
