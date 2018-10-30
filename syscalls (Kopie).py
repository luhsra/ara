import graph
import os
from enum import Enum
from enumerations import Vertex_Type, Syscall_Type
#import syscalls_references

from native_step import Step

import teszt



class SyscallStep(Step):
	"""Reads an oil file and writes all information to the graph."""
	
	def get_dependencies(self):
		
		return ["LLVMStep"]

	def run(self, g: graph.PyGraph):
		
		syscall_dict = {}
		flag  = 1
		
		if flag == 0:
			
			syscall_dict = { 	
					# quadruple of syscall id , syscall type and syscall target
					# no syscall
					"Computation": 		[1,None,None]
					

					"ActivateTask": 	[2,Syscall_Type.create,Vertex_Type.task],
					"StartOS": 			[3,Syscall_Type.activate,Vertex_Type.tas],
					"Idle": 			[4,Syscall_Type.schedule,Vertex_Type.os],
					"iret": 			[5,Syscall_Type.schedule,Vertex_Type.os],
					"kickoff": 			[6,None,None],
					"TerminateTask": 	[7,Syscall_Type.delete,Vertex_Type.task],
					"ChainTask": 		[8,Syscall_Type.schedule,Vertex_Type.tas],
					"CancelAlarm":		[9,Syscall_Type.delete,Vertex_Type.alarm],
					"GetResource":		[10,Syscall_Type.access,Vertex_Type.resource],
					"ReleaseResource":	[11,Syscall_Type.release,Vertex_Type.resource],
					
					
					#"DisableAllInterrupts":[1,None,None],
					#"EnableAllInterrupts":[1,None,None],
					#"SuspendAllInterrupts":[1,None,None],
					#"SuspendOSInterrupts":[1,None,None],
					#"ResumeOSInterrupts":[1,None,None],
					#"GetAlarm":[1,None,None],
					#"AdvanceCounter":[1,None,None],
					#"AcquireCheckedObject":[1,None,None],
					#"ReleaseCheckedObject":[1,None,None],
					#"SetEvent":[1,None,None],
					#"ClearEvent":[1,None,None],
					#"WaitEvent":[1,None,None],
					#"GetEvent":[1,None,None],
					#"ActivateDevice":[1,None,None],
					#"ActivateTask":[1,None,None],
					#"DeactivateDevice":[1,None,None],
					#"SetRelAlarm":[1,None,None],
					#"CheckAlarm":[1,None,None],
					#"CheckIRQ":[1,None,None],
					#"ResumeAllInterrupts"[1,None,None]
					}
		else:

			syscall_dict = { 	 	
					# no syscall
					"Computation": [1,None,None] ,
				
					# all syscall which creates abstaction instances
					"xTaskCreate": 							[2,Syscall_Type.create,Vertex_Type.task],
					"xTaskCreateStatic": 					[3,Syscall_Type.create,Vertex_Type.task],
					"xTaskCreateRestricted":		 		[4,Syscall_Type.create,Vertex_Type.task],
					"xQueueCreate": 						[5,Syscall_Type.create,Vertex_Type.queue],
					"xQueueCreateSet": 						[6,Syscall_Type.create,Vertex_Type.queue],
					"xQueueCreateStatic": 					[7,Syscall_Type.create,Vertex_Type.queue],
					"vSemaphoreCreateBinary": 				[8,Syscall_Type.create,Vertex_Type.semaphore],
					"xSemaphoreCreateBinary": 				[9,Syscall_Type.create,Vertex_Type.semaphore],
					"xSemaphoreCreateBinaryStatic": 		[10,Syscall_Type.create,Vertex_Type.semaphore],
					"xSemaphoreCreateCounting": 			[11,Syscall_Type.create,Vertex_Type.counter],
					"xSemaphoreCreateCountingStatic": 		[12,Syscall_Type.create,Vertex_Type.counter],
					"xSemaphoreCreateMutex": 				[13,Syscall_Type.create,Vertex_Type.semaphore],
					"xSemaphoreCreateMutexStatic": 			[14,Syscall_Type.create,Vertex_Type.semaphore],
					"xSemaphoreCreateRecursiveMutex": 		[15,Syscall_Type.create,Vertex_Type.semaphore],
					"xSemaphoreCreateRecursiveMutexStatic": [16,Syscall_Type.create,Vertex_Type.semaphore],
					"xTimerCreate": 						[17,Syscall_Type.create,Vertex_Type.timer],
					"xTimerCreateStatic": 					[18,Syscall_Type.create,Vertex_Type.timer],
					"xEventGroupCreate": 					[19,Syscall_Type.create,Vertex_Type.event],
					"xEventGroupCreateStatic": 				[20,Syscall_Type.create,Vertex_Type.event],
					"xStreamBufferCreate": 					[21,Syscall_Type.create,Vertex_Type.buffer],
					"xStreamBufferCreateStatic": 			[22,Syscall_Type.create,Vertex_Type.buffer],
					"xMessageBufferCreate": 				[23,Syscall_Type.create,Vertex_Type.buffer],
					"xMessageBufferCreateStatic": 			[24,Syscall_Type.create,Vertex_Type.buffer],
					
					
					
					
					#"portSWITCH_TO_USER_MODE": 4 ,
					#"vTaskAllocateMPURegions": 5 ,
					#"xTaskAbortDelay": 6 ,
					#"xTaskCallApplicationTaskHook": 7 ,
					#"xTaskCheckForTimeOut": 8 ,
					#"vTaskDelay": 12 ,
					#"vTaskDelayUntil": 13 ,
					#"vTaskDelete": 14 ,
					#"taskDISABLE_INTERRUPTS": 16 ,
					#"taskENABLE_INTERRUPTS": 17 ,
					#"taskENTER_CRITICAL": 18 ,
					#"taskENTER_CRITICAL_FROM_ISR": 19 ,
					#"taskEXIT_CRITICAL": 20 ,
					#"taskEXIT_CRITICAL_FROM_ISR": 21 ,
					#"xTaskGetApplicationTaskTag": 22 ,
					#"xTaskGetCurrentTaskHandle": 23 ,
					#"xTaskGetIdleTaskHandle": 24 ,
					#"xTaskGetHandle": 25 ,
					#"uxTaskGetNumberOfTasks": 26 ,
					#"vTaskGetRunTimeStats": 27 ,
					#"xTaskGetSchedulerState": 28 ,
					#"uxTaskGetStackHighWaterMark": 29 ,
					#"eTaskGetState": 30 ,
					#"uxTaskGetSystemState": 32 ,
					#"vTaskGetTaskInfo": 33 ,
					#"pvTaskGetThreadLocalStoragePointer": 34 ,
					#"pcTaskGetName": 36 ,
					#"xTaskGetTickCount": 37 ,
					#"xTaskGetTickCountFromISR": 38 ,
					#"vTaskList": 39 ,
					#"xTaskNotify": 40 ,
					#"xTaskNotifyAndQuery": 42 ,
					#"xTaskNotifyAndQueryFromISR": 43 ,
					#"xTaskNotifyFromISR": 44 ,
					#"xTaskNotifyGive": 45 ,
					#"vTaskNotifyGiveFromISR": 46 ,
					#"xTaskNotifyStateClear": 47 ,
					#"ulTaskNotifyTake": 48 ,
					#"xTaskNotifyWait": 49 ,
					#"uxTaskPriorityGet": 50 ,
					#"vTaskPrioritySet": 51 ,
					#"vTaskResume": 52 ,
					#"xTaskResumeAll": 53 ,
					#"xTaskResumeFromISR": 54 ,
					#"vTaskSetApplicationTaskTag": 55 ,
					#"vTaskSetThreadLocalStoragePointer": 56 ,
					#"vTaskSetTimeOutState": 57 ,
					#"vTaskStartScheduler": 58 ,
					#"vTaskStepTick": 59 ,
					#"vTaskSuspend": 61 ,
					#"vTaskSuspendAll": 62 ,
					#"taskYIELD": 63 ,
					
					#"vQueueAddToRegistry": 65 ,
					#"xQueueAddToSet": 66 ,
					#"vQueueDelete": 71 ,
					#"pcQueueGetName": 73 ,
					#"xQueueIsQueueEmptyFromISR": 74 ,
					#"xQueueIsQueueFullFromISR": 75 ,
					#"uxQueueMessagesWaiting": 76 ,
					#"uxQueueMessagesWaitingFromISR": 77 ,
					#"xQueueOverwrite": 78 ,
					#"xQueueOverwriteFromISR": 79 ,
					#"xQueuePeek": 80 ,
					#"xQueuePeekFromISR": 82 ,
					#"xQueueReceive": 83 ,
					#"xQueueReceiveFromISR": 85 ,
					#"xQueueRemoveFromSet": 86 ,
					#"xQueueReset": 87 ,
					#"xQueueSelectFromSet": 88 ,
					#"xQueueSelectFromSetFromISR": 89 ,
					#"xQueueSend": 90,
					#"xQueueSendToFront":91,
					#"xQueueSendToBack": 90 ,
					#"xQueueSendToBackFromISR": 90 ,
					#"xQueueSendFromISR": 91,
					#"xQueueSendToBackFromISR,": 92 ,
					#"xQueueSendToFrontFromISR": 94 ,
					#"uxQueueSpacesAvailable": 95 ,
					
					#"vSemaphoreDelete": 105 ,
					#"uxSemaphoreGetCount": 106 ,
					#"xSemaphoreGetMutexHolder": 107 ,
					#"xSemaphoreGive": 108 ,
					#"xSemaphoreGiveFromISR": 109 ,
					#"xSemaphoreGiveRecursive": 110 ,
					#"xSemaphoreTake": 111 ,
					#"xSemaphoreTakeFromISR": 112 ,
					#"xSemaphoreTakeRecursive": 113 ,
					
					#"xTimerChangePeriod": 114 ,
					#"xTimerChangePeriodFromISR": 115 ,
					#"xTimerDelete": 118 ,
					#"xTimerGetExpiryTime": 119 ,
					#"pcTimerGetName": 120 ,
					#"xTimerGetPeriod": 121 ,
					#"xTimerGetTimerDaemonTaskHandle": 122 ,
					#"pvTimerGetTimerID": 123 ,
					#"xTimerIsTimerActive": 124 ,
					#"xTimerPendFunctionCall": 125 ,
					#"xTimerPendFunctionCallFromISR": 126 ,
					#"xTimerReset": 128 ,
					#"xTimerResetFromISR": 129 ,
					#"vTimerSetTimerID": 130 ,
					#"xTimerStart": 131 ,
					#"xTimerStartFromISR": 132 ,
					#"xTimerStop": 133 ,
					#"xTimerStopFromISR": 134 ,
					
					#"xEventGroupClearBits": 135 ,
					#"xEventGroupClearBitsFromISR": 136 ,
					#"vEventGroupDelete": 139 ,
					#"xEventGroupGetBits": 140 ,
					#"xEventGroupGetBitsFromISR": 141 ,
					#"xEventGroupSetBits": 142 ,
					#"xEventGroupSetBitsFromISR": 143 ,
					#"xEventGroupSync": 144 ,
					#"xEventGroupWaitBits": 146 ,
					
					#"xStreamBufferBytesAvailable": 147 ,
					#"vStreamBufferDelete": 150 ,
					#"xStreamBufferIsEmpty": 151 ,
					#"xStreamBufferIsFull": 152 ,
					#"xStreamBufferReceive": 153 ,
					#"xStreamBufferReceiveFromISR": 154 ,
					#"xStreamBufferReset": 155 ,
					#"xStreamBufferSend": 156 ,
					#"xStreamBufferSendFromISR": 157 ,
					#"xStreamBufferSetTriggerLevel": 158 ,
					#"xStreamBufferSpacesAvailable": 159 ,

					#"vMessageBufferDelete": 162 ,
					#"xMessageBufferIsEmpty":163,
					#"xMessageBufferIsFull":164,
					#"xMessageBufferReceive" : 165,
					#"xMessageBufferReceiveFromISR" : 166,
					#"xMessageBufferReset" : 167,
					#"xMessageBufferSend" : 168,
					#"xMessageBufferSendFromISR" : 169,
					#"xMessageBufferSpacesAvailable": 170
				}
			
			
			
		print("HELLO!$")
		
		#iterate about the functions of the graph 
		function_list = g.get_type_vertices(Vertex_Type.function)
		
		for function in function_list:
			
			
			print(function.get_name())
			

			
			#cast vertex pointer to function pointer
			
			#TODO iterate about the abbs of the functions
			
				#TODO get_atomic_basic_blocks();
				#check if abb contains call
					# TODO check if call is listed in the syscall_dictionary
					# TODO set the corresponding flag 
				
				
	
		print("I'm an SyscallStep")
	


		
		
