import graph
import os
import sys
from collections import namedtuple
from collections import Iterable

import logging

#import syscalls_references

from native_step import Step


class SyscallStep(Step):
    """Detects the syscalls from the abb calls and validates the arguments.
    Each syscall are information about semantik, type of arguments, target abstraction class and index of handler argument given."""

    def get_dependencies(self):
        return ['LLVMStep']

    def select_syscalls(self, os):

        if os == "OSEK":

            self.syscall_dict = {

                # quadruple of syscall id , syscall type and syscall target
                # no syscall
                #"Computation": 				[1,None,None],


                "OSEKOS_ActivateTask": 		[[graph.data_type.string],graph.syscall_definition_type.activate,[graph.get_type_hash("Task")],0],
                "OSEKOS_StartOS": 			[[graph.data_type.string],graph.syscall_definition_type.start_scheduler,[graph.get_type_hash("RTOS")],0],
                "OSEKOS_ShutdownOS": 		[[],graph.syscall_definition_type.end_scheduler,[graph.get_type_hash("RTOS")],0],
                "OSEKOS_TerminateTask": 	[[],graph.syscall_definition_type.destroy,[graph.get_type_hash("RTOS")],0],




                "OSEKOS_ChainTask": 		[[graph.data_type.string],graph.syscall_definition_type.chain,[graph.get_type_hash("Task")],0],
                "OSEKOS_CancelAlarm":		[[graph.data_type.string],graph.syscall_definition_type.destroy,[graph.get_type_hash("Timer")],0],

                "OSEKOS_GetResource":				[[graph.data_type.string],graph.syscall_definition_type.take,[graph.get_type_hash("Mutex")],0],
                "OSEKOS_ReleaseResource":			[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Mutex")],0],

                "OSEKOS_DisableAllInterrupts":		[[],graph.syscall_definition_type.disable,[graph.get_type_hash("RTOS")],0],
                "OSEKOS_EnableAllInterrupts":		[[],graph.syscall_definition_type.enable,[graph.get_type_hash("RTOS")],0],
                "OSEKOS_SuspendAllInterrupts":		[[],graph.syscall_definition_type.suspend,[graph.get_type_hash("RTOS")],0],
                "OSEKOS_ResumeAllInterrupts":		[[],graph.syscall_definition_type.resume,[graph.get_type_hash("RTOS")],0],
                "OSEKOS_SuspendOSInterrupts":		[[],graph.syscall_definition_type.suspend,[graph.get_type_hash("RTOS")],0],
                "OSEKOS_ResumeOSInterrupts":		[[],graph.syscall_definition_type.resume,[graph.get_type_hash("RTOS")],0],

                "OSEKOS_GetAlarm":					[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.receive,[graph.get_type_hash("Timer")],0],
                "OSEKOS_AdvanceCounter":			[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Counter")],0],



                "OSEKOS_SetEvent":					[[graph.data_type.string,graph.data_type.string],graph.syscall_definition_type.enable,[graph.get_type_hash("Task")],0],
                "OSEKOS_ClearEvent":				[[graph.data_type.string],graph.syscall_definition_type.destroy,[graph.get_type_hash("Event")],0],
                "OSEKOS_WaitEvent":					[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Event")],0],
                "OSEKOS_GetEvent":					[[graph.data_type.string,graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Task")],0],

                "OSEKOS_SetRelAlarm":				[[graph.data_type.string,graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("Timer")],0],
                "OSEKOS_CheckAlarm":				[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Timer")],0],


                #"AcquireCheckedObject":[1,None,None],
                #"ReleaseCheckedObject":[1,None,None],
                #"ActivateDevice":[1,None,None],
                #"DeactivateDevice":[1,None,None],
                #"CheckIRQ":[1,None,None],
                #"
                }
        elif os == "FreeRTOS":

            self.syscall_dict = {

                # all syscall which creates abstaction instances


                #TODO xTaskGenericNotify
                #"xTaskNotify": 40 ,
                #"xTaskNotifyAndQuery": 42 ,
                #"xTaskNotifyAndQueryFromISR": 43 ,
                #"xTaskNotifyFromISR": 44 ,
                #"xTaskNotifyGive": 45 ,
                "vTaskNotifyGiveFromISR": [[graph.data_type.string,graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Task")],0],
                #"taskEXIT_CRITICAL_FROM_ISR": 21 ,
                #"portSWITCH_TO_USER_MODE": 4 ,
                #"vTaskGetTaskInfo": 33 ,
                #"ulTaskNotifyTake" : 				[[graph.data_type.integer,graph.data_type.integer,graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")],0],

                "xTaskCreate": 							[[graph.data_type.string,graph.data_type.string,graph.data_type.integer,graph.data_type.string,graph.data_type.integer,graph.data_type.string],graph.syscall_definition_type.create,[graph.get_type_hash("Task")],0],
                "xTaskCreateStatic": 					[[],graph.syscall_definition_type.create,[graph.get_type_hash("Task")],0],
                "xTaskCreateRestricted":		 		[[],graph.syscall_definition_type.create,[graph.get_type_hash("Task")],0],
                "xQueueGenericCreate": 					[[graph.data_type.integer,graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.create,[graph.get_type_hash("Queue")],0],
                "xQueueCreateStatic": 					[[],graph.syscall_definition_type.create,[graph.get_type_hash("Queue")],0],
                "xQueueCreateSet":						[[graph.data_type.integer],graph.syscall_definition_type.create, [graph.get_type_hash("QueueSet")],0],

                "vSemaphoreCreateBinary": 				[[graph.data_type.integer,graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.create,[graph.get_type_hash("Semaphore")],0],
                "xSemaphoreCreateBinary": 				[[graph.data_type.integer,graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.create,[graph.get_type_hash("Semaphore")],0],
                "xSemaphoreCreateBinaryStatic": 		[[],graph.syscall_definition_type.create,[graph.get_type_hash("Mutex")],0],
                "xQueueCreateMutex": 					[[graph.data_type.integer],graph.syscall_definition_type.create,[graph.get_type_hash("Mutex")],0],
                "xSemaphoreCreateMutexStatic": 			[[],graph.syscall_definition_type.create,[graph.get_type_hash("Mutex")],0],
                "xSemaphoreCreateRecursiveMutex": 		[[graph.data_type.integer],graph.syscall_definition_type.create,[graph.get_type_hash("Mutex")],0],
                "xSemaphoreCreateRecursiveMutexStatic": [[],graph.syscall_definition_type.create,[graph.get_type_hash("Mutex")],0],
                "xQueueCreateCountingSemaphore": 		[[graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.create,[graph.get_type_hash("Semaphore")],0],
                "xSemaphoreCreateCountingStatic": 		[[],graph.syscall_definition_type.create,[graph.get_type_hash("Semaphore")],0],

                "xTimerCreate": 						[[graph.data_type.string,graph.data_type.integer,graph.data_type.integer,graph.data_type.string,graph.data_type.string],graph.syscall_definition_type.create,[graph.get_type_hash("Timer")],0],
                "xTimerCreateStatic": 					[[],graph.syscall_definition_type.create,[graph.get_type_hash("Timer")],0],
                "xEventGroupCreate": 					[[],graph.syscall_definition_type.create,[graph.get_type_hash("Event")],0],
                "xEventGroupCreateStatic": 				[[],graph.syscall_definition_type.create,[graph.get_type_hash("Event")],0],
                "xStreamBufferGenericCreate": 			[[graph.data_type.integer,graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.create,[graph.get_type_hash("Buffer")],0],
                "xStreamBufferCreateStatic": 			[[],graph.syscall_definition_type.create,[graph.get_type_hash("Buffer")],0],
                "xMessageBufferCreateStatic": 			[[],graph.syscall_definition_type.create,[graph.get_type_hash("Buffer")],0],





                "vTaskAllocateMPURegions": 		[[graph.data_type.string,graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Task")],0],
                "xTaskAbortDelay": 				[[graph.data_type.string],graph.syscall_definition_type.delay,[graph.get_type_hash("Task")],0],
                "xTaskCallApplicationTaskHook": [[graph.data_type.string,graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Task")],0],
                "xTaskCheckForTimeOut": 		[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")],0],
                "vTaskDelay": 					[[graph.data_type.integer],graph.syscall_definition_type.delay,[graph.get_type_hash("RTOS")],9999],
                "vTaskDelayUntil": 				[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")],9999],
                "vTaskDelete": 					[[graph.data_type.string],graph.syscall_definition_type.destroy,[graph.get_type_hash("Task")],0],

                "portDISABLE_INTERRUPTS": 			[[],graph.syscall_definition_type.disable,[graph.get_type_hash("RTOS")],0],
                "portENABLE_INTERRUPTS": 			[[],graph.syscall_definition_type.enable,[graph.get_type_hash("RTOS")],0],
                "vTaskEnterCritical": 				[[],graph.syscall_definition_type.enter_critical,[graph.get_type_hash("RTOS")],0],
                "portSET_INTERRUPT_MASK_FROM_ISR": 	[[],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")],0],


                "vTaskExitCritical": 				[[],graph.syscall_definition_type.exit_critical,[graph.get_type_hash("RTOS")],0],


                "xTaskGetApplicationTaskTag": 		[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Task")],0],
                "xTaskGetCurrentTaskHandle":		[[],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")],0],
                "xTaskGetIdleTaskHandle": 			[[],graph.syscall_definition_type.receive,[graph.get_type_hash("RTOS")],0],
                "xTaskGetHandle": 					[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("RTOS")],0],
                "uxTaskGetNumberOfTasks": 			[[],graph.syscall_definition_type.receive,[graph.get_type_hash("RTOS")],0],
                "vTaskGetRunTimeStats": 			[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("RTOS")],0],
                "uxTaskGetStackHighWaterMark" : 	[[],graph.syscall_definition_type.receive,[graph.get_type_hash("RTOS")],0],
                "uxTaskGetStackHighWaterMark" : 	[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Task")],0],
                "eTaskGetState" : 					[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Task")],0],
                "uxTaskGetSystemState" : 			[[graph.data_type.string,graph.data_type.integer,graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("RTOS")],0],
                "pvTaskGetThreadLocalStoragePointer" : 		[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.receive,[graph.get_type_hash("Task")],0],

                "pcTaskGetName" : 					[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Task")],0],
                "xTaskGetTickCount" : 				[[],graph.syscall_definition_type.receive,[graph.get_type_hash("RTOS")],0],
                "xTaskGetTickCountFromISR" : 		[[],graph.syscall_definition_type.receive,[graph.get_type_hash("RTOS")],0],

                "vTaskList" : 						[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")],0],
                "xTaskNotifyStateClear" : 				[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Task")],0],
                "ulTaskNotifyTake" : 				[[graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")],0],
                "uxTaskPriorityGet" : 				[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Task")],0],
                "vTaskPrioritySet" : 				[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.set_priority,[graph.get_type_hash("Task")],0],
                "vTaskResume" : 					[[graph.data_type.string],graph.syscall_definition_type.resume,[graph.get_type_hash("RTOS")],0],
                "xTaskResumeAll" : 					[[],graph.syscall_definition_type.resume,[graph.get_type_hash("RTOS")],0],
                "xTaskResumeFromISR" : 				[[graph.data_type.string],graph.syscall_definition_type.resume,[graph.get_type_hash("Task")],0],
                "vTaskSetApplicationTaskTag" : 		[[graph.data_type.string,graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Task")],0],
                "vTaskSetThreadLocalStoragePointer" : 		[[graph.data_type.string,graph.data_type.integer,graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Task")],0],
                "vTaskSetTimeOutState" : 			[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")],0],
                "vTaskStartScheduler" : 			[[],graph.syscall_definition_type.start_scheduler,[graph.get_type_hash("RTOS")],0],
                "vTaskStepTick" : 					[[graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")],0],
                "vTaskSuspend" : 					[[graph.data_type.string],graph.syscall_definition_type.suspend,[graph.get_type_hash("Task")],0],
                "vTaskSuspendAll" : 				[[],graph.syscall_definition_type.suspend,[graph.get_type_hash("RTOS")],0],
                "portYIELD" : 						[[],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")],0],

                #TODO xQueueOverwrite -> third argument = 0
                "xQueueGenericSend":			[[graph.data_type.string,[graph.data_type.string,graph.data_type.integer], graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("Mutex"),graph.get_type_hash("Queue"),graph.get_type_hash("Semaphore")],0],
                "xQueueGenericSendFromISR": 	[[graph.data_type.string,[graph.data_type.string,graph.data_type.integer], graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("Queue")],0],
                "xQueueReceive": 				[[graph.data_type.string,[graph.data_type.string,graph.data_type.integer],graph.data_type.integer],graph.syscall_definition_type.receive,[graph.get_type_hash("Queue")],0],
                "xQueueReceiveFromISR":			[[graph.data_type.string,[graph.data_type.string,graph.data_type.integer],graph.data_type.integer],graph.syscall_definition_type.receive,[graph.get_type_hash("Mutex"),graph.get_type_hash("Queue"),graph.get_type_hash("Semaphore")],0],
                "xQueuePeek": 					[[graph.data_type.string,[graph.data_type.string,graph.data_type.integer],graph.data_type.integer],graph.syscall_definition_type.receive,[graph.get_type_hash("Queue")],0],
                "xQueuePeekFromISR": 			[[graph.data_type.string,[graph.data_type.string,graph.data_type.integer],graph.data_type.integer],graph.syscall_definition_type.receive,[graph.get_type_hash("Queue")],0],
                "xQueueIsQueueEmptyFromISR": 	[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Queue")],0],
                "xQueueIsQueueFullFromISR":  	[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Queue")],0],
                "uxQueueMessagesWaiting": 		[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Semaphore"),graph.get_type_hash("Queue")],0],
                "uxQueueSpacesAvailable": 		[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Queue")],0],
                "vQueueDelete": 				[[graph.data_type.string],graph.syscall_definition_type.destroy,[graph.get_type_hash("Mutex"),graph.get_type_hash("Queue"),graph.get_type_hash("Semaphore")],0],
                "pcQueueGetName": 	   			[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Queue")],0],
                "xQueueReset": 					[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.reset,[graph.get_type_hash("Queue")],0],
                "xQueueGiveFromISR":			[[graph.data_type.string,[graph.data_type.integer,graph.data_type.string],0],graph.syscall_definition_type.commit,[graph.get_type_hash("Mutex"),graph.get_type_hash("Queue"),graph.get_type_hash("Semaphore")],0],
                "xQueueSemaphoreTake": 			[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.take,[graph.get_type_hash("Mutex"),graph.get_type_hash("Queue"),graph.get_type_hash("Semaphore")],0],
                "xQueueGetMutexHolder": 		[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Mutex")],0],
                "xQueueGetMutexHolderFromISR": 	[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Mutex")],0],
                "xQueueGiveMutexRecursive": 	[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Mutex")],0],
                "xQueueTakeMutexRecursive": 	[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.take,[graph.get_type_hash("Mutex")],0],


                "xTimerGenericCommand": 			[[graph.data_type.string,graph.data_type.integer,graph.data_type.integer,graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("Timer")],0],
                "xTimerGetExpiryTime": 				[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Timer")],0],
                "pcTimerGetName": 					[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Timer")],0],
                "xTimerGetPeriod": 					[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Timer")],0],
                "xTimerGetTimerDaemonTaskHandle": 	[[],graph.syscall_definition_type.receive,[graph.get_type_hash("Timer")],0],
                "pvTimerGetTimerID": 				[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Timer")],0],
                "xTimerIsTimerActive": 				[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Timer")],0],
                "xTimerPendFunctionCall": 			[[graph.data_type.string,graph.data_type.string,graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.receive,[graph.get_type_hash("Timer")],0],
                "xTimerPendFunctionCallFromISR": 	[[graph.data_type.string,graph.data_type.string,graph.data_type.integer,graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Timer")],0],
                "vTimerSetTimerID": 				[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("Timer")],0],

                "vQueueAddToRegistry": 				[[graph.data_type.string,graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Queue")],0],
                "uxQueueMessagesWaitingFromISR":	[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Queue")],0],
                "xQueueAddToSet":	[[graph.data_type.string,graph.data_type.string],graph.syscall_definition_type.add,[graph.get_type_hash("QueueSet")],1],
                "xQueueRemoveFromSet":	[[graph.data_type.string,graph.data_type.string],graph.syscall_definition_type.take_out,[graph.get_type_hash("QueueSet")],0],
                "xQueueSelectFromSet":	[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.receive,[graph.get_type_hash("QueueSet")],0],
                "xQueueSelectFromSetFromISR":	[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("QueueSet")],0],
                "uxQueueSpacesAvailable":	[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Queue")],0],


                "xEventGroupClearBits": 			[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.reset,[graph.get_type_hash("Event")],0],
                "xEventGroupClearBitsFromISR":		[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.reset,[graph.get_type_hash("Event")],0],
                "vEventGroupDelete": 				[[graph.data_type.string],graph.syscall_definition_type.destroy,[graph.get_type_hash("Event")],0],
                "xEventGroupGetBitsFromISR": 		[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Event")],0],
                "xEventGroupSetBits" :				[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("Event")],0],
                "xEventGroupSetBitsFromISR" : 		[[graph.data_type.string,graph.data_type.integer,graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Event")],0],
                "xEventGroupSync" : 				[[graph.data_type.string,graph.data_type.integer,graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.synchronize,[graph.get_type_hash("Event")],0],
                "xEventGroupWaitBits" : 			[[graph.data_type.string,graph.data_type.integer,graph.data_type.integer,graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.wait,[graph.get_type_hash("Event")],0],

                "xStreamBufferBytesAvailable" : 	[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Buffer")],0],
                "xStreamBufferBytesAvailable" :		[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Buffer")],0],
                "vStreamBufferDelete" : 			[[graph.data_type.string],graph.syscall_definition_type.destroy,[graph.get_type_hash("Buffer")],0],
                "xStreamBufferIsEmpty" : 			[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Buffer")],0],
                "xStreamBufferIsFull" : 			[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Buffer")],0],
                "xStreamBufferReceive" : 			[[graph.data_type.string,graph.data_type.string,graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.receive,[graph.get_type_hash("Buffer")],0],
                "xStreamBufferReceiveFromISR" : 	[[graph.data_type.string,graph.data_type.string,graph.data_type.integer,graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Buffer")],0],
                "xStreamBufferReset" : 				[[graph.data_type.string],graph.syscall_definition_type.reset,[graph.get_type_hash("Buffer")],0],
                "xStreamBufferResetFromISR" : 		[[graph.data_type.string],graph.syscall_definition_type.reset,[graph.get_type_hash("Buffer")],0],
                "xStreamBufferSend" : 				[[graph.data_type.string,graph.data_type.string,graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("Buffer")],0],
                "xStreamBufferSendFromISR" : 		[[graph.data_type.string,graph.data_type.string,graph.data_type.integer,graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Buffer")],0],
                "xStreamBufferSetTriggerLevel" : 	[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("Buffer")],0],
                "xStreamBufferSpacesAvailable" : 	[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Buffer")],0],

                "xCoRoutineCreate" : 	[[graph.data_type.string,graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.create,[graph.get_type_hash("CoRoutine")],9999],
                "vCoRoutineSchedule" : 	[[],graph.syscall_definition_type.schedule,[graph.get_type_hash("CoRoutine")],0],

            }

    def run(self, g: graph.PyGraph):
        #get information which os is used
        os =  self._config["os"]

        if os == "osek":
            g.set_os_type(graph.os_type.OSEK)
        elif os == "freertos":
            g.set_os_type(graph.os_type.FreeRTOS)

        self.select_syscalls(os)

        #iterate about the functions of the graph
        function_list = g.get_type_vertices("Function")

        for function in function_list:

            #iterate about the abbs of the functions
            abb_list = function.get_atomic_basic_blocks()

            #iterate about the abbs of the function
            for abb in abb_list:

                #check if abb has a call
                if abb.get_call_type() == graph.call_definition_type.has_call:

                    #get call name
                    call_name = abb.get_call_name()


                    #check if call is a function call or a sys call
                    syscall = self.syscall_dict.get(call_name.decode('ascii'), "error")
                    if syscall != "error":


                        assert abb.convert_call_to_syscall(call_name) == True, "could not convert call to syscall"


                        function.set_has_syscall(True)

                        expected_argument_types = graph.cast_expected_syscall_argument_types(syscall[0])

                        #different_calles_argument_types = abb.get_call_argument_types()

                        #assert len(different_calles_argument_types) <= 1, "more than one call in initial atomic basic block"


                        #specific_call_argument_types = different_calles_argument_types[0]

                        specific_call_argument_types = abb.get_call_argument_types()

                        success = True
                        counter = 0



                        #verify the typeid_hash_values of the syscall arguments
                        if len(expected_argument_types) != len(specific_call_argument_types):
                            success = False

                        else:



                            #iterate about the expected call types list
                            for expected_type in expected_argument_types:
                                #get argument types for this argument
                                argument_types = specific_call_argument_types[counter]

                                #iterate about the types
                                for argument_type in argument_types:
                                    tmp_success = False
                                    #check if type is in expected types

                                    if isinstance(expected_type, Iterable):
                                        for tmp_expected_type in expected_type:
                                            #check if argument type is equal to expected type
                                            if tmp_expected_type == argument_type:

                                                tmp_success = True
                                                break
                                    else:
                                        if expected_type == argument_type:
                                            tmp_success = True



                                    success = tmp_success
                                    if success == False:
                                        break

                                if success == False:
                                    break

                                counter+=1



                        #check if lists dont match
                        if success == False:
                            print("TODO",call_name,counter)
                            #sys.exit("unexpected argument type")
                            #abb.print_information();

                        abb.set_call_type(graph.call_definition_type.sys_call)
                        abb.set_syscall_type(syscall[1])
                        abb.set_call_target_instance(syscall[2])
                        abb.set_handler_argument_index(syscall[3])


                    #no syscall
                    else:
                         #set type to func call
                         abb.set_call_type(graph.call_definition_type.func_call)










