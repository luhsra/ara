import graph
import os
from enum import Enum
#from enumerations import Type
#import syscalls_references

from native_step import Step

import test



class SyscallStep(Step):
	"""Reads an oil file and writes all information to the graph."""
	
	def get_dependencies(self):
		
		return ["LLVMStep"]

	def run(self, g: graph.PyGraph):
		
		print("Run ", self.get_name())
		
		syscall_dict = {}
		flag  = 1
		
		if flag == 0:
			
			syscall_dict = { 	
					# no syscall
					"Computation": 1,
					
					# activate task
					"ActivateTask":41,
					
					"StartOS":2,
					"Idle":3,
					"iret":6,
					"kickoff":19,
					"TerminateTask":21,
					"ChainTask":22,
					"CancelAlarm":24,
					"GetResource":25,
					"ReleaseResource":26,
					"DisableAllInterrupts":27,
					"EnableAllInterrupts":28,
					"SuspendAllInterrupts":29,
					"SuspendOSInterrupts":31,
					"ResumeOSInterrupts":32,
					"GetAlarm":33,
					"AdvanceCounter":34,
					"AcquireCheckedObject":35,
					"ReleaseCheckedObject":36,
					"SetEvent":37,
					"ClearEvent":38,
					"WaitEvent":39,
					"GetEvent":40,
					"ActivateDevice":41,
					"ActivateTask":41,
					"DeactivateDevice":42,
					"SetRelAlarm":None,
					"CheckAlarm":None,
					"CheckIRQ":None,
					"ResumeAllInterrupts":None}
		else:

			syscall_dict = { 	 	
					# no syscall
					"Computation": 1 ,
				
					# all syscall which creates abstaction instances
					"xTaskCreate": 2,
					"xTaskCreateStatic": 3 ,
					"xTaskCreateRestricted": 4 ,
					"xQueueCreate": 5 ,
					"xQueueCreateSet": 6 ,
					"xQueueCreateStatic": 7 ,
					"vSemaphoreCreateBinary": 8 ,
					"xSemaphoreCreateBinary": 9 ,
					"xSemaphoreCreateBinaryStatic": 10 ,
					"xSemaphoreCreateCounting": 11 ,
					"xSemaphoreCreateCountingStatic": 12 ,
					"xSemaphoreCreateMutex": 13 ,
					"xSemaphoreCreateMutexStatic": 14 ,
					"xSemaphoreCreateRecursiveMutex": 15 ,
					"xSemaphoreCreateRecursiveMutexStatic": 16 ,
					"xTimerCreate": 17 ,
					"xTimerCreateStatic": 18 ,
					"xEventGroupCreate": 19 ,
					"xEventGroupCreateStatic": 20 ,
					"xStreamBufferCreate": 21 ,
					"xStreamBufferCreateStatic": 22 ,
					"xMessageBufferCreate": 23 ,
					"xMessageBufferCreateStatic": 24 ,
					
					
					
					
					"portSWITCH_TO_USER_MODE": 4 ,
					"vTaskAllocateMPURegions": 5 ,
					"xTaskAbortDelay": 6 ,
					"xTaskCallApplicationTaskHook": 7 ,
					"xTaskCheckForTimeOut": 8 ,
					"vTaskDelay": 12 ,
					"vTaskDelayUntil": 13 ,
					"vTaskDelete": 14 ,
					"taskDISABLE_INTERRUPTS": 16 ,
					"taskENABLE_INTERRUPTS": 17 ,
					"taskENTER_CRITICAL": 18 ,
					"taskENTER_CRITICAL_FROM_ISR": 19 ,
					"taskEXIT_CRITICAL": 20 ,
					"taskEXIT_CRITICAL_FROM_ISR": 21 ,
					"xTaskGetApplicationTaskTag": 22 ,
					"xTaskGetCurrentTaskHandle": 23 ,
					"xTaskGetIdleTaskHandle": 24 ,
					"xTaskGetHandle": 25 ,
					"uxTaskGetNumberOfTasks": 26 ,
					"vTaskGetRunTimeStats": 27 ,
					"xTaskGetSchedulerState": 28 ,
					"uxTaskGetStackHighWaterMark": 29 ,
					"eTaskGetState": 30 ,
					"uxTaskGetSystemState": 32 ,
					"vTaskGetTaskInfo": 33 ,
					"pvTaskGetThreadLocalStoragePointer": 34 ,
					"pcTaskGetName": 36 ,
					"xTaskGetTickCount": 37 ,
					"xTaskGetTickCountFromISR": 38 ,
					"vTaskList": 39 ,
					"xTaskNotify": 40 ,
					"xTaskNotifyAndQuery": 42 ,
					"xTaskNotifyAndQueryFromISR": 43 ,
					"xTaskNotifyFromISR": 44 ,
					"xTaskNotifyGive": 45 ,
					"vTaskNotifyGiveFromISR": 46 ,
					"xTaskNotifyStateClear": 47 ,
					"ulTaskNotifyTake": 48 ,
					"xTaskNotifyWait": 49 ,
					"uxTaskPriorityGet": 50 ,
					"vTaskPrioritySet": 51 ,
					"vTaskResume": 52 ,
					"xTaskResumeAll": 53 ,
					"xTaskResumeFromISR": 54 ,
					"vTaskSetApplicationTaskTag": 55 ,
					"vTaskSetThreadLocalStoragePointer": 56 ,
					"vTaskSetTimeOutState": 57 ,
					"vTaskStartScheduler": 58 ,
					"vTaskStepTick": 59 ,
					"vTaskSuspend": 61 ,
					"vTaskSuspendAll": 62 ,
					"taskYIELD": 63 ,
					
					"vQueueAddToRegistry": 65 ,
					"xQueueAddToSet": 66 ,
					"vQueueDelete": 71 ,
					"pcQueueGetName": 73 ,
					"xQueueIsQueueEmptyFromISR": 74 ,
					"xQueueIsQueueFullFromISR": 75 ,
					"uxQueueMessagesWaiting": 76 ,
					"uxQueueMessagesWaitingFromISR": 77 ,
					"xQueueOverwrite": 78 ,
					"xQueueOverwriteFromISR": 79 ,
					"xQueuePeek": 80 ,
					"xQueuePeekFromISR": 82 ,
					"xQueueReceive": 83 ,
					"xQueueReceiveFromISR": 85 ,
					"xQueueRemoveFromSet": 86 ,
					"xQueueReset": 87 ,
					"xQueueSelectFromSet": 88 ,
					"xQueueSelectFromSetFromISR": 89 ,
					"xQueueSend": 90,
					"xQueueSendToFront":91,
					"xQueueSendToBack": 90 ,
					"xQueueSendToBackFromISR": 90 ,
					"xQueueSendFromISR": 91,
					"xQueueSendToBackFromISR,": 92 ,
					"xQueueSendToFrontFromISR": 94 ,
					"uxQueueSpacesAvailable": 95 ,
					
					"vSemaphoreDelete": 105 ,
					"uxSemaphoreGetCount": 106 ,
					"xSemaphoreGetMutexHolder": 107 ,
					"xSemaphoreGive": 108 ,
					"xSemaphoreGiveFromISR": 109 ,
					"xSemaphoreGiveRecursive": 110 ,
					"xSemaphoreTake": 111 ,
					"xSemaphoreTakeFromISR": 112 ,
					"xSemaphoreTakeRecursive": 113 ,
					
					"xTimerChangePeriod": 114 ,
					"xTimerChangePeriodFromISR": 115 ,
					"xTimerDelete": 118 ,
					"xTimerGetExpiryTime": 119 ,
					"pcTimerGetName": 120 ,
					"xTimerGetPeriod": 121 ,
					"xTimerGetTimerDaemonTaskHandle": 122 ,
					"pvTimerGetTimerID": 123 ,
					"xTimerIsTimerActive": 124 ,
					"xTimerPendFunctionCall": 125 ,
					"xTimerPendFunctionCallFromISR": 126 ,
					"xTimerReset": 128 ,
					"xTimerResetFromISR": 129 ,
					"vTimerSetTimerID": 130 ,
					"xTimerStart": 131 ,
					"xTimerStartFromISR": 132 ,
					"xTimerStop": 133 ,
					"xTimerStopFromISR": 134 ,
					
					"xEventGroupClearBits": 135 ,
					"xEventGroupClearBitsFromISR": 136 ,
					"vEventGroupDelete": 139 ,
					"xEventGroupGetBits": 140 ,
					"xEventGroupGetBitsFromISR": 141 ,
					"xEventGroupSetBits": 142 ,
					"xEventGroupSetBitsFromISR": 143 ,
					"xEventGroupSync": 144 ,
					"xEventGroupWaitBits": 146 ,
					
					"xStreamBufferBytesAvailable": 147 ,
					"vStreamBufferDelete": 150 ,
					"xStreamBufferIsEmpty": 151 ,
					"xStreamBufferIsFull": 152 ,
					"xStreamBufferReceive": 153 ,
					"xStreamBufferReceiveFromISR": 154 ,
					"xStreamBufferReset": 155 ,
					"xStreamBufferSend": 156 ,
					"xStreamBufferSendFromISR": 157 ,
					"xStreamBufferSetTriggerLevel": 158 ,
					"xStreamBufferSpacesAvailable": 159 ,

					"vMessageBufferDelete": 162 ,
					"xMessageBufferIsEmpty":163,
					"xMessageBufferIsFull":164,
					"xMessageBufferReceive" : 165,
					"xMessageBufferReceiveFromISR" : 166,
					"xMessageBufferReset" : 167,
					"xMessageBufferSend" : 168,
					"xMessageBufferSendFromISR" : 169,
					"xMessageBufferSpacesAvailable": 170
				}
			
			
			
		
		
		#iterate about the functions of the graph 
		function_list = g.get_type_vertices(type(graph.Function))
		
		for function in function_list:
			print("HELLO!$")
			
			#print(function.get_name())
			

			
			#cast vertex pointer to function pointer
			
			#TODO iterate about the abbs of the functions
			
				#TODO get_atomic_basic_blocks();
				#check if abb contains call
					# TODO check if call is listed in the syscall_dictionary
					# TODO set the corresponding flag 
				
				
	
		
	


		
		
