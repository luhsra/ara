import graph
import os


#import syscalls_references

from native_step import Step



class SyscallStep(Step):
	"""Reads an oil file and writes all information to the graph."""
	
	def get_dependencies(self):
		
		return ["LLVMStep", 'OilStep']

	def run(self, g: graph.PyGraph):
		
		syscall_dict = {}
		flag  = 1
		
		for element in graph.syscall_definition_type:
			print(element.name)
		
		if flag == 0:
			
			syscall_dict = { 	
					# quadruple of syscall id , syscall type and syscall target
					# no syscall
					"Computation": 		[1,None,None],
					

					"ActivateTask": 	[2,graph.syscall_definition_type.create,type(graph.Task)],
					"StartOS": 			[3,graph.syscall_definition_type.activate,type(graph.Task)],
					#"Idle": 			[4,graph.syscall_definition_type.schedule,type(graph.OS)],
					#"iret": 			[5,graph.syscall_definition_type.schedule,type(graph.OS)],
					"kickoff": 			[6,None,None],
					"TerminateTask": 	[7,graph.syscall_definition_type.delete,type(graph.Task)],
					"ChainTask": 		[8,graph.syscall_definition_type.schedule,type(graph.Task)],
					"CancelAlarm":		[9,graph.syscall_definition_type.delete,type(graph.Alarm)],
					"GetResource":		[10,graph.syscall_definition_type.access,type(graph.Resource)],
					"ReleaseResource":	[11,graph.syscall_definition_type.release,type(graph.Resource)],
					
					
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
					"xTaskCreate": 							[2,graph.syscall_definition_type.create,type(graph.Task)],
					"xTaskCreateStatic": 					[3,graph.syscall_definition_type.create,type(graph.Task)],
					"xTaskCreateRestricted":		 		[4,graph.syscall_definition_type.create,type(graph.Task)],
					#"xQueueCreate": 						[5,graph.syscall_definition_type.create,type(graph.Queue)],
					#"xQueueCreateSet": 						[6,graph.syscall_definition_type.create,type(graph.Queue)],
					#"xQueueCreateStatic": 					[7,graph.syscall_definition_type.create,type(graph.Queue)],
					#"vSemaphoreCreateBinary": 				[8,graph.syscall_definition_type.create,type(graph.Semaphore)],
					#"xSemaphoreCreateBinary": 				[9,graph.syscall_definition_type.create,type(graph.Semaphore)],
					#"xSemaphoreCreateBinaryStatic": 		[10,graph.syscall_definition_type.create,type(graph.Semaphore)],
					#"xSemaphoreCreateCounting": 			[11,graph.syscall_definition_type.create,type(graph.Counter)],
					#"xSemaphoreCreateCountingStatic": 		[12,graph.syscall_definition_type.create,type(graph.Counter)],
					#"xSemaphoreCreateMutex": 				[13,graph.syscall_definition_type.create,type(graph.Semaphore)],
					#"xSemaphoreCreateMutexStatic": 		[14,graph.syscall_definition_type.create,type(graph.Semaphore)],
					#"xSemaphoreCreateRecursiveMutex": 		[15,graph.syscall_definition_type.create,type(graph.Semaphore)],
					#"xSemaphoreCreateRecursiveMutexStatic": [16,graph.syscall_definition_type.create,type(graph.Semaphore)],
					#"xTimerCreate": 						[17,graph.syscall_definition_type.create,type(graph.Timer)],
					#"xTimerCreateStatic": 					[18,graph.syscall_definition_type.create,type(graph.Timer)],
					#"xEventGroupCreate": 					[19,graph.syscall_definition_type.create,type(graph.Event)],
					#"xEventGroupCreateStatic": 			[20,graph.syscall_definition_type.create,type(graph.Event)],
					#"xStreamBufferCreate": 				[21,graph.syscall_definition_type.create,type(graph.Buffer)],
					#"xStreamBufferCreateStatic": 			[22,graph.syscall_definition_type.create,type(graph.Buffer)],
					#"xMessageBufferCreate": 				[23,graph.syscall_definition_type.create,type(graph.Buffer)],
					#"xMessageBufferCreateStatic": 			[24,graph.syscall_definition_type.create,type(graph.Buffer)],
					
					
					
					
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
		function_list = g.get_type_vertices(type(graph.Function))
		
		for function in function_list:
			
			#iterate about the abbs of the functions
			abb_list = function.get_atomic_basic_blocks()
			
			#for abb in abb_list:
					
					#if abb.get_call_type() == graph.call_definition_type.has_call:
						
						#print("TEST")
						
					#check if abb contains call
					# TODO check if call is listed in the syscall_dictionary
					# TODO set the corresponding flag 
				
				
	
		print("I'm an SyscallStep")
	


		
		
