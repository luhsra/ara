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

#ifndef FREERTOS_CONFIG_H
#define FREERTOS_CONFIG_H

//#include <i86.h>
//#include <conio.h>

/*-----------------------------------------------------------
 * Application specific definitions.
 *
 * These definitions should be adjusted for your particular hardware and
 * application requirements.
 *
 * THESE PARAMETERS ARE DESCRIBED WITHIN THE 'CONFIGURATION' SECTION OF THE
 * FreeRTOS API DOCUMENTATION AVAILABLE ON THE FreeRTOS.org WEB SITE. 
 *
 * See http://www.freertos.org/a00110.html.
 *----------------------------------------------------------*/

#define configUSE_PREEMPTION			1
#define configUSE_IDLE_HOOK				0
#define configUSE_TICK_HOOK				0
#define configTICK_RATE_HZ				(  1000 )
#define configMINIMAL_STACK_SIZE		(  256 ) /* This can be made smaller if required. */
#define configTOTAL_HEAP_SIZE			( ( size_t ) ( 32 * 1024 ) ) 
#define configMAX_TASK_NAME_LEN			( 16 )
#define configUSE_TRACE_FACILITY    	1
#define configUSE_16_BIT_TICKS      	1
#define configIDLE_SHOULD_YIELD			1
#define configUSE_CO_ROUTINES 			0
#define configUSE_MUTEXES				1
#define configUSE_COUNTING_SEMAPHORES	1
#define configUSE_ALTERNATIVE_API		1
#define configUSE_RECURSIVE_MUTEXES		1
#define configCHECK_FOR_STACK_OVERFLOW	0 /* Do not use this option on the PC port. */
#define configUSE_APPLICATION_TASK_TAG	1
#define configQUEUE_REGISTRY_SIZE		0

#define configMAX_PRIORITIES		( 10 )
#define configMAX_CO_ROUTINE_PRIORITIES ( 2 )

/* Set the following definitions to 1 to include the API function, or zero
to exclude the API function. */

#define INCLUDE_vTaskPrioritySet        	1
#define INCLUDE_uxTaskPriorityGet       	1
#define INCLUDE_vTaskDelete             	1
#define INCLUDE_vTaskCleanUpResources   	1
#define INCLUDE_vTaskSuspend            	1
#define INCLUDE_vTaskDelayUntil		        1
#define INCLUDE_vTaskDelay			1
#define INCLUDE_uxTaskGetStackHighWaterMark 0 /* Do not use this option on the PC port. */

#endif /* FREERTOS_CONFIG_H */

#ifdef configUSE_PREEMPTION
	int FreeRTOS_configUSE_PREEMPTION = configUSE_PREEMPTION;
#else
	int FreeRTOS_configUSE_PREEMPTION = -1;
#endif

#ifdef configUSE_PORT_OPTIMISED_TASK_SELECTION
	int FreeRTOS_configUSE_PORT_OPTIMISED_TASK_SELECTION = configUSE_PORT_OPTIMISED_TASK_SELECTION;
#else
	int FreeRTOS_configUSE_PORT_OPTIMISED_TASK_SELECTION = -1;
#endif

#ifdef configUSE_TICKLESS_IDLE
	int FreeRTOS_configUSE_TICKLESS_IDLE = configUSE_TICKLESS_IDLE;
#else
	int FreeRTOS_configUSE_TICKLESS_IDLE = -1;
#endif

#ifdef configCPU_CLOCK_HZ
	int FreeRTOS_configCPU_CLOCK_HZ = configCPU_CLOCK_HZ;
#else
	int FreeRTOS_configCPU_CLOCK_HZ = -1;
#endif

#ifdef configTICK_RATE_HZ
	int FreeRTOS_configTICK_RATE_HZ = configTICK_RATE_HZ;
#else
	int FreeRTOS_configTICK_RATE_HZ = -1;
#endif

#ifdef configMAX_PRIORITIES
	int FreeRTOS_configMAX_PRIORITIES = configMAX_PRIORITIES;
#else
	int FreeRTOS_configMAX_PRIORITIES = -1;
#endif

#ifdef configMINIMAL_STACK_SIZE
	int FreeRTOS_configMINIMAL_STACK_SIZE = configMINIMAL_STACK_SIZE;
#else
	int FreeRTOS_configMINIMAL_STACK_SIZE = -1;
#endif

#ifdef configMAX_TASK_NAME_LEN
	int FreeRTOS_configMAX_TASK_NAME_LEN = configMAX_TASK_NAME_LEN;
#else
	int FreeRTOS_configMAX_TASK_NAME_LEN = -1;
#endif

#ifdef configUSE_16_BIT_TICKS
	int FreeRTOS_configUSE_16_BIT_TICKS = configUSE_16_BIT_TICKS;
#else
	int FreeRTOS_configUSE_16_BIT_TICKS = -1;
#endif

#ifdef configIDLE_SHOULD_YIELD
	int FreeRTOS_configIDLE_SHOULD_YIELD = configIDLE_SHOULD_YIELD;
#else
	int FreeRTOS_configIDLE_SHOULD_YIELD = -1;
#endif

#ifdef configUSE_TASK_NOTIFICATIONS
	int FreeRTOS_configUSE_TASK_NOTIFICATIONS = configUSE_TASK_NOTIFICATIONS;
#else
	int FreeRTOS_configUSE_TASK_NOTIFICATIONS = -1;
#endif

#ifdef configUSE_MUTEXES
	int FreeRTOS_configUSE_MUTEXES = configUSE_MUTEXES;
#else
	int FreeRTOS_configUSE_MUTEXES = -1;
#endif

#ifdef configUSE_RECURSIVE_MUTEXES
	int FreeRTOS_configUSE_RECURSIVE_MUTEXES = configUSE_RECURSIVE_MUTEXES;
#else
	int FreeRTOS_configUSE_RECURSIVE_MUTEXES = -1;
#endif

#ifdef configUSE_COUNTING_SEMAPHORES
	int FreeRTOS_configUSE_COUNTING_SEMAPHORES = configUSE_COUNTING_SEMAPHORES;
#else
	int FreeRTOS_configUSE_COUNTING_SEMAPHORES = -1;
#endif

#ifdef configUSE_ALTERNATIVE_API
	int FreeRTOS_configUSE_ALTERNATIVE_API = configUSE_ALTERNATIVE_API;
#else
	int FreeRTOS_configUSE_ALTERNATIVE_API = -1;
#endif

#ifdef configQUEUE_REGISTRY_SIZE
	int FreeRTOS_configQUEUE_REGISTRY_SIZE = configQUEUE_REGISTRY_SIZE;
#else
	int FreeRTOS_configQUEUE_REGISTRY_SIZE = -1;
#endif

#ifdef configUSE_QUEUE_SETS
	int FreeRTOS_configUSE_QUEUE_SETS = configUSE_QUEUE_SETS;
#else
	int FreeRTOS_configUSE_QUEUE_SETS = -1;
#endif

#ifdef configUSE_TIME_SLICING
	int FreeRTOS_configUSE_TIME_SLICING = configUSE_TIME_SLICING;
#else
	int FreeRTOS_configUSE_TIME_SLICING = -1;
#endif

#ifdef configUSE_NEWLIB_REENTRANT
	int FreeRTOS_configUSE_NEWLIB_REENTRANT = configUSE_NEWLIB_REENTRANT;
#else
	int FreeRTOS_configUSE_NEWLIB_REENTRANT = -1;
#endif

#ifdef configENABLE_BACKWARD_COMPATIBILITY
	int FreeRTOS_configENABLE_BACKWARD_COMPATIBILITY = configENABLE_BACKWARD_COMPATIBILITY;
#else
	int FreeRTOS_configENABLE_BACKWARD_COMPATIBILITY = -1;
#endif

#ifdef configNUM_THREAD_LOCAL_STORAGE_POINTERS
	int FreeRTOS_configNUM_THREAD_LOCAL_STORAGE_POINTERS = configNUM_THREAD_LOCAL_STORAGE_POINTERS;
#else
	int FreeRTOS_configNUM_THREAD_LOCAL_STORAGE_POINTERS = -1;
#endif

#ifdef configSUPPORT_STATIC_ALLOCATION
	int FreeRTOS_configSUPPORT_STATIC_ALLOCATION = configSUPPORT_STATIC_ALLOCATION;
#else
	int FreeRTOS_configSUPPORT_STATIC_ALLOCATION = -1;
#endif

#ifdef configSUPPORT_DYNAMIC_ALLOCATION
	int FreeRTOS_configSUPPORT_DYNAMIC_ALLOCATION = configSUPPORT_DYNAMIC_ALLOCATION;
#else
	int FreeRTOS_configSUPPORT_DYNAMIC_ALLOCATION = -1;
#endif

#ifdef configTOTAL_HEAP_SIZE
	int FreeRTOS_configTOTAL_HEAP_SIZE = configTOTAL_HEAP_SIZE;
#else
	int FreeRTOS_configTOTAL_HEAP_SIZE = -1;
#endif

#ifdef configAPPLICATION_ALLOCATED_HEAP
	int FreeRTOS_configAPPLICATION_ALLOCATED_HEAP = configAPPLICATION_ALLOCATED_HEAP;
#else
	int FreeRTOS_configAPPLICATION_ALLOCATED_HEAP = -1;
#endif

#ifdef configUSE_IDLE_HOOK
	int FreeRTOS_configUSE_IDLE_HOOK = configUSE_IDLE_HOOK;
#else
	int FreeRTOS_configUSE_IDLE_HOOK = -1;
#endif

#ifdef configUSE_TICK_HOOK
	int FreeRTOS_configUSE_TICK_HOOK = configUSE_TICK_HOOK;
#else
	int FreeRTOS_configUSE_TICK_HOOK = -1;
#endif

#ifdef configCHECK_FOR_STACK_OVERFLOW
	int FreeRTOS_configCHECK_FOR_STACK_OVERFLOW = configCHECK_FOR_STACK_OVERFLOW;
#else
	int FreeRTOS_configCHECK_FOR_STACK_OVERFLOW = -1;
#endif

#ifdef configUSE_MALLOC_FAILED_HOOK
	int FreeRTOS_configUSE_MALLOC_FAILED_HOOK = configUSE_MALLOC_FAILED_HOOK;
#else
	int FreeRTOS_configUSE_MALLOC_FAILED_HOOK = -1;
#endif

#ifdef configUSE_DAEMON_TASK_STARTUP_HOOK
	int FreeRTOS_configUSE_DAEMON_TASK_STARTUP_HOOK = configUSE_DAEMON_TASK_STARTUP_HOOK;
#else
	int FreeRTOS_configUSE_DAEMON_TASK_STARTUP_HOOK = -1;
#endif

#ifdef configGENERATE_RUN_TIME_STATS
	int FreeRTOS_configGENERATE_RUN_TIME_STATS = configGENERATE_RUN_TIME_STATS;
#else
	int FreeRTOS_configGENERATE_RUN_TIME_STATS = -1;
#endif

#ifdef configUSE_TRACE_FACILITY
	int FreeRTOS_configUSE_TRACE_FACILITY = configUSE_TRACE_FACILITY;
#else
	int FreeRTOS_configUSE_TRACE_FACILITY = -1;
#endif

#ifdef configUSE_STATS_FORMATTING_FUNCTIONS
	int FreeRTOS_configUSE_STATS_FORMATTING_FUNCTIONS = configUSE_STATS_FORMATTING_FUNCTIONS;
#else
	int FreeRTOS_configUSE_STATS_FORMATTING_FUNCTIONS = -1;
#endif

#ifdef configUSE_CO_ROUTINES
	int FreeRTOS_configUSE_CO_ROUTINES = configUSE_CO_ROUTINES;
#else
	int FreeRTOS_configUSE_CO_ROUTINES = -1;
#endif

#ifdef configMAX_CO_ROUTINE_PRIORITIES
	int FreeRTOS_configMAX_CO_ROUTINE_PRIORITIES = configMAX_CO_ROUTINE_PRIORITIES;
#else
	int FreeRTOS_configMAX_CO_ROUTINE_PRIORITIES = -1;
#endif

#ifdef configUSE_TIMERS
	int FreeRTOS_configUSE_TIMERS = configUSE_TIMERS;
#else
	int FreeRTOS_configUSE_TIMERS = -1;
#endif

#ifdef configTIMER_TASK_PRIORITY
	int FreeRTOS_configTIMER_TASK_PRIORITY = configTIMER_TASK_PRIORITY;
#else
	int FreeRTOS_configTIMER_TASK_PRIORITY = -1;
#endif

#ifdef configTIMER_QUEUE_LENGTH
	int FreeRTOS_configTIMER_QUEUE_LENGTH = configTIMER_QUEUE_LENGTH;
#else
	int FreeRTOS_configTIMER_QUEUE_LENGTH = -1;
#endif

#ifdef configTIMER_TASK_STACK_DEPTH
	int FreeRTOS_configTIMER_TASK_STACK_DEPTH = configTIMER_TASK_STACK_DEPTH;
#else
	int FreeRTOS_configTIMER_TASK_STACK_DEPTH = -1;
#endif

#ifdef configKERNEL_INTERRUPT_PRIORITY
	int FreeRTOS_configKERNEL_INTERRUPT_PRIORITY = configKERNEL_INTERRUPT_PRIORITY;
#else
	int FreeRTOS_configKERNEL_INTERRUPT_PRIORITY = -1;
#endif

#ifdef configMAX_SYSCALL_INTERRUPT_PRIORITY
	int FreeRTOS_configMAX_SYSCALL_INTERRUPT_PRIORITY = configMAX_SYSCALL_INTERRUPT_PRIORITY;
#else
	int FreeRTOS_configMAX_SYSCALL_INTERRUPT_PRIORITY = -1;
#endif

#ifdef configMAX_API_CALL_INTERRUPT_PRIORITY
	int FreeRTOS_configMAX_API_CALL_INTERRUPT_PRIORITY = configMAX_API_CALL_INTERRUPT_PRIORITY;
#else
	int FreeRTOS_configMAX_API_CALL_INTERRUPT_PRIORITY = -1;
#endif

#ifdef configINCLUDE_APPLICATION_DEFINED_PRIVILEGED_FUNCTIONS
	int FreeRTOS_configINCLUDE_APPLICATION_DEFINED_PRIVILEGED_FUNCTIONS = configINCLUDE_APPLICATION_DEFINED_PRIVILEGED_FUNCTIONS;
#else
	int FreeRTOS_configINCLUDE_APPLICATION_DEFINED_PRIVILEGED_FUNCTIONS = -1;
#endif
