import graph 
import os
import sys
from collections import namedtuple
import logging

#import syscalls_references

from native_step import Step


class SyscallStep(Step):
	"""Detects the syscalls from the calls and validates the arguments."""
		
	def get_dependencies(self):
		return ["LLVMStep", 'OilStep']
		
	
	syscall_dict = {}
	
	

	def select_syscalls(self,flag):
		
		if flag == 0:
			
			self.syscall_dict = { 	
				
				# quadruple of syscall id , syscall type and syscall target
				# no syscall
				#"Computation": 				[1,None,None],
				

				"OSEKOS_ActivateTask": 		[[graph.data_type.string],graph.syscall_definition_type.activate,[graph.get_type_hash("Task")]],
				"StartOS": 					[[],graph.syscall_definition_type.schedule,[graph.get_type_hash("OS")]],
				"OSEKOS_TerminateTask": 	[[graph.data_type.string],graph.syscall_definition_type.destroy,[graph.get_type_hash("RTOS")]],
				
				
				
				
				"OSEKOS_ChainTask": 		[[graph.data_type.string],graph.syscall_definition_type.activate,[graph.get_type_hash("Task")]],
				"OSEKOS_CancelAlarm":		[[graph.data_type.string],graph.syscall_definition_type.destroy,[graph.get_type_hash("Alarm")]],
				
				"OSEKOS_GetResource":				[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Resource")]],
				"OSEKOS_ReleaseResource":			[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Resource")]],
				
				"OSEKOS_DisableAllInterrupts":		[[],graph.syscall_definition_type.destroy,[graph.get_type_hash("RTOS")]],
				"OSEKOS_EnableAllInterrupts":		[[],graph.syscall_definition_type.activate,[graph.get_type_hash("RTOS")]],
				"OSEKOS_SuspendAllInterrupts":		[[],graph.syscall_definition_type.destroy,[graph.get_type_hash("RTOS")]],
				"OSEKOS_ResumeAllInterrupts":		[[],graph.syscall_definition_type.activate,[graph.get_type_hash("RTOS")]],
				"OSEKOS_SuspendOSInterrupts":		[[],graph.syscall_definition_type.destroy,[graph.get_type_hash("RTOS")]],
				"OSEKOS_ResumeOSInterrupts":		[[],graph.syscall_definition_type.activate,[graph.get_type_hash("RTOS")]],
				
				"OSEKOS_GetAlarm":					[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.receive,[graph.get_type_hash("Alarm")]],
				"OSEKOS_AdvanceCounter":			[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Counter")]],
				
				
				
				"OSEKOS_SetEvent":					[[graph.data_type.string,graph.data_type.string],graph.syscall_definition_type.enable,[graph.get_type_hash("Task")]],
				"OSEKOS_ClearEvent":				[[graph.data_type.string],graph.syscall_definition_type.destroy,[graph.get_type_hash("Event")]],
				"OSEKOS_WaitEvent":					[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Event")]],
				"OSEKOS_GetEvent":					[[graph.data_type.string,graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Task")]],
				
				"OSEKOS_SetRelAlarm":				[[graph.data_type.string,graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("Alarm")]],
				"OSEKOS_CheckAlarm":				[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Alarm")]],
				
				
				#"AcquireCheckedObject":[1,None,None],
				#"ReleaseCheckedObject":[1,None,None],
				#"ActivateDevice":[1,None,None],
				#"DeactivateDevice":[1,None,None],
				#"CheckIRQ":[1,None,None],
				#"
				}
		else:

			self.syscall_dict = { 	 	
				# no syscall
				#"Computation": 							[[],None,None] ,
			
				# all syscall which creates abstaction instances
				
				
				#TODO xTaskGenericNotify
				#"xTaskNotify": 40 ,
				#"xTaskNotifyAndQuery": 42 ,
				#"xTaskNotifyAndQueryFromISR": 43 ,
				#"xTaskNotifyFromISR": 44 ,
				#"xTaskNotifyGive": 45 ,
				#"vTaskNotifyGiveFromISR": 46 ,
				#"taskEXIT_CRITICAL_FROM_ISR": 21 ,
				#"portSWITCH_TO_USER_MODE": 4 ,
				#"vTaskGetTaskInfo": 33 ,
				
				"xTaskCreate": 							[[graph.data_type.string,graph.data_type.string,graph.data_type.integer,graph.data_type.string,graph.data_type.integer,graph.data_type.string],graph.syscall_definition_type.create,[graph.get_type_hash("Task")]],
				"xTaskCreateStatic": 					[[],graph.syscall_definition_type.create,[graph.get_type_hash("Task")]],
				"xTaskCreateRestricted":		 		[[],graph.syscall_definition_type.create,[graph.get_type_hash("Task")]],
				"xQueueGenericCreate": 					[[graph.data_type.integer,graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.create,[graph.get_type_hash("Queue")]],
				"xQueueCreateStatic": 					[[],graph.syscall_definition_type.create,[graph.get_type_hash("Queue")]],
				"xQueueCreateSet":						[[graph.data_type.integer],graph.syscall_definition_type.create, [graph.get_type_hash("QueueSet")]],
		
				"vSemaphoreCreateBinary": 				[[graph.data_type.integer,graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.create,[graph.get_type_hash("Semaphore")]],
				"xSemaphoreCreateBinary": 				[[graph.data_type.integer,graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.create,[graph.get_type_hash("Semaphore")]],
				"xSemaphoreCreateBinaryStatic": 		[[],graph.syscall_definition_type.create,[graph.get_type_hash("Semaphore")]],
				"xQueueCreateMutex": 					[[graph.data_type.integer],graph.syscall_definition_type.create,[graph.get_type_hash("Semaphore")]],
				"xSemaphoreCreateMutexStatic": 			[[],graph.syscall_definition_type.create,[graph.get_type_hash("Semaphore")]],
				"xSemaphoreCreateRecursiveMutex": 		[[graph.data_type.integer],graph.syscall_definition_type.create,[graph.get_type_hash("Semaphore")]],
				"xSemaphoreCreateRecursiveMutexStatic": [[],graph.syscall_definition_type.create,[graph.get_type_hash("Semaphore")]],
				"xQueueCreateCountingSemaphore": 		[[graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.create,[graph.get_type_hash("Semaphore")]],
				"xSemaphoreCreateCountingStatic": 		[[],graph.syscall_definition_type.create,[graph.get_type_hash("Semaphore")]],
				
				"xTimerCreate": 						[[graph.data_type.string,graph.data_type.integer,graph.data_type.integer,graph.data_type.string,graph.data_type.string],graph.syscall_definition_type.create,[graph.get_type_hash("Timer")]],
				"xTimerCreateStatic": 					[[],graph.syscall_definition_type.create,[graph.get_type_hash("Timer")]],
				"xEventGroupCreate": 					[[],graph.syscall_definition_type.create,[graph.get_type_hash("EventGroup")]],
				"xEventGroupCreateStatic": 				[[],graph.syscall_definition_type.create,[graph.get_type_hash("EventGroup")]],
				"xStreamBufferGenericCreate": 			[[graph.data_type.integer,graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.create,[graph.get_type_hash("Buffer")]],
				"xStreamBufferCreateStatic": 			[[],graph.syscall_definition_type.create,[graph.get_type_hash("Buffer")]],
				"xMessageBufferCreateStatic": 			[[],graph.syscall_definition_type.create,[graph.get_type_hash("Buffer")]],
				
				
				
				
				
				"vTaskAllocateMPURegions": 		[[graph.data_type.string,graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Task")]],
				"xTaskAbortDelay": 				[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Task")]],
				"xTaskCallApplicationTaskHook": [[graph.data_type.string,graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Task")]],
				"xTaskCheckForTimeOut": 		[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")]],
				"vTaskDelay": 					[[graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")]],
				"vTaskDelayUntil": 				[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")]],
				"vTaskDelete": 					[[graph.data_type.string],graph.syscall_definition_type.destroy,[graph.get_type_hash("Task")]],
			
				"portDISABLE_INTERRUPTS": 			[[],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")]],
				"portENABLE_INTERRUPTS": 			[[],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")]],
				"portENTER_CRITICAL": 				[[],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")]],
				"portSET_INTERRUPT_MASK_FROM_ISR": 	[[],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")]],
			
				
				"portEXIT_CRITICAL": 				[[],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")]],
				
				
				"xTaskGetApplicationTaskTag": 		[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Task")]],
				"xTaskGetCurrentTaskHandle":		[[],graph.syscall_definition_type.receive,[graph.get_type_hash("RTOS")]],
				"xTaskGetIdleTaskHandle": 			[[],graph.syscall_definition_type.receive,[graph.get_type_hash("RTOS")]],
				"xTaskGetHandle": 					[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("RTOS")]],
				"uxTaskGetNumberOfTasks": 			[[],graph.syscall_definition_type.receive,[graph.get_type_hash("RTOS")]],
				"vTaskGetRunTimeStats": 			[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("RTOS")]],
				"uxTaskGetStackHighWaterMark" : 	[[],graph.syscall_definition_type.receive,[graph.get_type_hash("RTOS")]],
				"uxTaskGetStackHighWaterMark" : 	[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Task")]],
				"eTaskGetState" : 					[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Task")]],
				"uxTaskGetSystemState" : 			[[graph.data_type.string,graph.data_type.integer,graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("RTOS")]],
				"pvTaskGetThreadLocalStoragePointer" : 		[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.receive,[graph.get_type_hash("Task")]],
				
				"pcTaskGetName" : 					[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Task")]],
				"xTaskGetTickCount" : 				[[],graph.syscall_definition_type.receive,[graph.get_type_hash("RTOS")]],
				"xTaskGetTickCountFromISR" : 		[[],graph.syscall_definition_type.receive,[graph.get_type_hash("RTOS")]],
				
				"vTaskList" : 						[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")]],
				"xTaskNotifyStateClear" : 				[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Task")]],
				"ulTaskNotifyTake" : 				[[graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")]],
				"ulTaskNotifyTake" : 				[[graph.data_type.integer,graph.data_type.integer,graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")]],
				"uxTaskPriorityGet" : 				[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Task")]],
				"vTaskPrioritySet" : 				[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("Task")]],
				"vTaskResume" : 					[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")]],
				"xTaskResumeAll" : 					[[],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")]],
				"xTaskResumeFromISR" : 				[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Task")]],
				"vTaskSetApplicationTaskTag" : 		[[graph.data_type.string,graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Task")]],
				"vTaskSetThreadLocalStoragePointer" : 		[[graph.data_type.string,graph.data_type.integer,graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Task")]],
				"vTaskSetTimeOutState" : 			[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")]],
				"vTaskStartScheduler" : 			[[],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")]],
				"vTaskStepTick" : 					[[graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")]],
				"vTaskSuspend" : 					[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Task")]],
				"vTaskSuspendAll" : 				[[],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")]],
				"portYIELD" : 						[[],graph.syscall_definition_type.commit,[graph.get_type_hash("RTOS")]],
				
				#TODO xQueueOverwrite -> third argument = 0
				"xQueueGenericSend":			[[graph.data_type.string,[graph.data_type.string,graph.data_type.integer], graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("Semaphore"),graph.get_type_hash("Queue")]],
				"xQueueGenericSendFromISR": 	[[graph.data_type.string,[graph.data_type.string,graph.data_type.integer], graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("Queue")]],
				"xQueueReceive": 				[[graph.data_type.string,[graph.data_type.string,graph.data_type.integer],graph.data_type.integer],graph.syscall_definition_type.receive,[graph.get_type_hash("Queue")]],
				"xQueueReceiveFromISR":			[[graph.data_type.string,[graph.data_type.string,graph.data_type.integer],graph.data_type.integer],graph.syscall_definition_type.receive,[graph.get_type_hash("Semaphore"),graph.get_type_hash("Queue")]],
				"xQueuePeek": 					[[graph.data_type.string,[graph.data_type.string,graph.data_type.integer],graph.data_type.integer],graph.syscall_definition_type.receive,[graph.get_type_hash("Queue")]],
				"xQueuePeekFromISR": 			[[graph.data_type.string,[graph.data_type.string,graph.data_type.integer],graph.data_type.integer],graph.syscall_definition_type.receive,[graph.get_type_hash("Queue")]],
				"xQueueIsQueueEmptyFromISR": 	[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Queue")]],
				"xQueueIsQueueFullFromISR":  	[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Queue")]],
				"uxQueueMessagesWaiting": 		[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Semaphore"),graph.get_type_hash("Queue")]],
				"uxQueueSpacesAvailable": 		[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Queue")]],
				"vQueueDelete": 				[[graph.data_type.string],graph.syscall_definition_type.destroy,[graph.get_type_hash("Semaphore"),graph.get_type_hash("Queue")]],
				"pcQueueGetName": 	   			[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Queue")]],
				"xQueueReset": 					[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.reset,[graph.get_type_hash("Semaphore"),graph.get_type_hash("Queue")]],
				"xQueueGiveFromISR":			[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("Semaphore"),graph.get_type_hash("Queue")]],
				"xQueueGetMutexHolder": 		[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Semaphore")]],
				"xQueueGetMutexHolderFromISR": 	[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Semaphore")]],
				"xQueueGiveMutexRecursive": 	[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Semaphore")]],
				"xQueueSemaphoreTake": 			[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.receive,[graph.get_type_hash("Semaphore")]],
				"xQueueTakeMutexRecursive": 	[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.receive,[graph.get_type_hash("Semaphore")]],
				
				#TODO second argument = command id xCommandID
				#define tmrCOMMAND_EXECUTE_CALLBACK_FROM_ISR 	( ( BaseType_t ) -2 )
				#define tmrCOMMAND_EXECUTE_CALLBACK				( ( BaseType_t ) -1 )
				#define tmrCOMMAND_START_DONT_TRACE				( ( BaseType_t ) 0 )
				#define tmrCOMMAND_START					    ( ( BaseType_t ) 1 )
				#define tmrCOMMAND_RESET						( ( BaseType_t ) 2 )
				#define tmrCOMMAND_STOP							( ( BaseType_t ) 3 )
				#define tmrCOMMAND_CHANGE_PERIOD				( ( BaseType_t ) 4 )
				#define tmrCOMMAND_DELETE						( ( BaseType_t ) 5 )
				#define tmrFIRST_FROM_ISR_COMMAND				( ( BaseType_t ) 6 )
				#define tmrCOMMAND_START_FROM_ISR				( ( BaseType_t ) 6 )
				#define tmrCOMMAND_RESET_FROM_ISR				( ( BaseType_t ) 7 )
				#define tmrCOMMAND_STOP_FROM_ISR				( ( BaseType_t ) 8 )
				#define tmrCOMMAND_CHANGE_PERIOD_FROM_ISR		( ( BaseType_t ) 9 )
				"xTimerGenericCommand": 			[[graph.data_type.string,graph.data_type.integer,graph.data_type.integer,graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("Timer")]],
				"xTimerGetExpiryTime": 				[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Timer")]],
				"pcTimerGetName": 					[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Timer")]],
				"xTimerGetPeriod": 					[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Timer")]],
				"xTimerGetTimerDaemonTaskHandle": 	[[],graph.syscall_definition_type.receive,[graph.get_type_hash("Timer")]],
				"pvTimerGetTimerID": 				[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Timer")]],
				"xTimerIsTimerActive": 				[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Timer")]],
				"xTimerPendFunctionCall": 			[[graph.data_type.string,graph.data_type.string,graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.receive,[graph.get_type_hash("Timer")]],
				"xTimerPendFunctionCallFromISR": 	[[graph.data_type.string,graph.data_type.string,graph.data_type.integer,graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Timer")]],
				"vTimerSetTimerID": 				[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("Timer")]],
				
				"vQueueAddToRegistry": 				[[graph.data_type.string,graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Queue")]],
				"uxQueueMessagesWaitingFromISR":	[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Queue")]],
				"xQueueAddToSet":	[[graph.data_type.string,graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Queue")]],
				"xQueueRemoveFromSet":	[[graph.data_type.string,graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Queue")]],
				"xQueueSelectFromSet":	[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("Queue")]],
				"xQueueSelectFromSetFromISR":	[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Queue")]],
				"uxQueueSpacesAvailable":	[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Queue")]],
				
				#TODO
				#xEventGroupGetBits -> second argument : 0;
				"xEventGroupClearBits": 			[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.reset,[graph.get_type_hash("EventGroup")]],
				"xEventGroupClearBitsFromISR":		[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.reset,[graph.get_type_hash("EventGroup")]],
				"vEventGroupDelete": 				[[graph.data_type.string],graph.syscall_definition_type.destroy,[graph.get_type_hash("EventGroup")]],
				"xEventGroupGetBitsFromISR": 		[[graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("EventGroup")]],
				"xEventGroupSetBits" :				[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("EventGroup")]],
				"xEventGroupSetBitsFromISR" : 		[[graph.data_type.string,graph.data_type.integer,graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("EventGroup")]],
				"xEventGroupSync" : 				[[graph.data_type.string,graph.data_type.integer,graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("EventGroup")]],
				"xEventGroupWaitBits" : 			[[graph.data_type.string,graph.data_type.integer,graph.data_type.integer,graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("EventGroup")]],
			
				"xStreamBufferBytesAvailable" : 	[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Buffer")]],
				"xStreamBufferBytesAvailable" :		[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Buffer")]],
				"vStreamBufferDelete" : 			[[graph.data_type.string],graph.syscall_definition_type.destroy,[graph.get_type_hash("Buffer")]],
				"xStreamBufferIsEmpty" : 			[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Buffer")]],
				"xStreamBufferIsFull" : 			[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Buffer")]],		
				"xStreamBufferReceive" : 			[[graph.data_type.string,graph.data_type.string,graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.receive,[graph.get_type_hash("Buffer")]],
				"xStreamBufferReceiveFromISR" : 	[[graph.data_type.string,graph.data_type.string,graph.data_type.integer,graph.data_type.string],graph.syscall_definition_type.receive,[graph.get_type_hash("Buffer")]],
				"xStreamBufferReset" : 				[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Buffer")]],
				"xStreamBufferResetFromISR" : 		[[graph.data_type.string],graph.syscall_definition_type.reset,[graph.get_type_hash("Buffer")]],
				"xStreamBufferSend" : 				[[graph.data_type.string,graph.data_type.string,graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("Buffer")]],
				"xStreamBufferSendFromISR" : 		[[graph.data_type.string,graph.data_type.string,graph.data_type.integer,graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Buffer")]],
				"xStreamBufferSetTriggerLevel" : 	[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("Buffer")]],
				"xStreamBufferSpacesAvailable" : 	[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Buffer")]],
			}
		


	

	def run(self, g: graph.PyGraph):
		
		#TODO get flag from meson file, declare syscall dict
		flag  = 1
		
		self.select_syscalls(flag)
		
			
		#iterate about the functions of the graph 
		function_list = g.get_type_vertices("Function")
		
		for function in function_list:
			
			#iterate about the abbs of the functions
			abb_list = function.get_atomic_basic_blocks()
			
			#iterate about the abbs of the function
			for abb in abb_list:
					
				#check if abb has a call
				if abb.get_call_type() == graph.call_definition_type.has_call:
					
					#get call name #TODO get call names
					call_name_list = abb.get_call_names()
					
					assert len(call_name_list) <= 1 , "more than one call in abb during syscall detection"
					
					for call_name in call_name_list:
						
						
						#check if call is a function call or a sys call
						syscall = self.syscall_dict.get(call_name.decode('ascii'), "error")
						if syscall != "error":
						
							
							assert abb.convert_call_to_syscall(call_name) == True, "could not conver call to syscall"
								
							
							function.set_has_syscall(True)
							
							expected_argument_types = graph.cast_expected_syscall_argument_types(syscall[0])
							argument_types_list = abb.get_call_argument_types()
							
							assert len(argument_types_list) <= 1, "more than one call in initial atomic basic block"
							
							
							argument_types = argument_types_list[0]
						
							success = True
							
							#verify the typeid_hash_values of the syscall arguments
							if len(expected_argument_types) != len(argument_types):
								success = False
							else:
								counter = 0
								#iterate about the expected call types list 
								for expected_type in expected_argument_types:
									if isinstance(expected_type, list):
										tmp_success = False
										for sub_expected_type in expected_type:
											if sub_expected_type == argument_types[counter]:
												tmp_success = True
										success = tmp_success
										if success == False:
											break
										
									else:
										if expected_type != argument_types[counter]:
											success = False
											break
											
									counter+=1
							
							#check if lists dont match
							if success == False:
								assert len(argument_types_list) <= 1, "unexpected argument type"
							
							abb.set_call_type(graph.call_definition_type.sys_call)
							abb.set_syscall_type(syscall[1])
							abb.set_call_target_instance(syscall[2])
							
							
						#no syscall 
						else:
							#set type to func call
							abb.set_call_type(graph.call_definition_type.func_call)
						
					

		print("I'm an SyscallStep")
	



		
		
