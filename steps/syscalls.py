import graph
import os


#import syscalls_references

from native_step import Step



class SyscallStep(Step):
	"""Reads an oil file and writes all information to the graph."""
	
	def get_dependencies(self):
		
		return ["LLVMStep", 'OilStep']

	def run(self, g: graph.PyGraph):
		
		#declare syscall dict
		syscall_dict = {}
		flag  = 1
		
	
		
		if flag == 0:
			
			syscall_dict = { 	
					# quadruple of syscall id , syscall type and syscall target
					# no syscall
					"Computation": 		[1,None,None],
					

					"ActivateTask": 	[2,0,type(graph.Task)],
					"StartOS": 			[3,0,type(graph.Task)],
					#"Idle": 			[4,graph.syscall_definition_type.schedule,type(graph.OS)],
					#"iret": 			[5,graph.syscall_definition_type.schedule,type(graph.OS)],
					"kickoff": 			[6,None,None],
					"TerminateTask": 	[7,0,type(graph.Task)],
					"ChainTask": 		[8,0,type(graph.Task)],
					"CancelAlarm":		[9,0,type(graph.Alarm)],
					"GetResource":		[10,0,type(graph.Resource)],
					"ReleaseResource":	[11,0,type(graph.Resource)],
					
					
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
					"Computation": 							[[],None,None] ,
				
					# all syscall which creates abstaction instances
					"xTaskCreate": 							[[],graph.syscall_definition_type.create,[graph.get_type_hash("Task")]],
					"xTaskCreateStatic": 					[[],graph.syscall_definition_type.create,[graph.get_type_hash("Task")]],
					"xTaskCreateRestricted":		 		[[],graph.syscall_definition_type.create,[graph.get_type_hash("Task")]],
					
					"xQueueGenericCreate": 					[[],graph.syscall_definition_type.create,[graph.get_type_hash("Queue")]],
					"xQueueCreateSet": 						[[],graph.syscall_definition_type.create,[graph.get_type_hash("Queue")]],
					"xQueueCreateStatic": 					[[],graph.syscall_definition_type.create,[graph.get_type_hash("Queue")]],
					
					"xQueueCreateSet":						[[],graph.syscall_definition_type.create, [graph.get_type_hash("QueueSet")]],
					
					"vSemaphoreCreateBinary": 				[[],graph.syscall_definition_type.create,[graph.get_type_hash("Semaphore")]],
					"xSemaphoreCreateBinary": 				[[],graph.syscall_definition_type.create,[graph.get_type_hash("Semaphore")]],
					"xSemaphoreCreateBinaryStatic": 		[[],graph.syscall_definition_type.create,[graph.get_type_hash("Semaphore")]],
					"xQueueCreateMutex": 					[[],graph.syscall_definition_type.create,[graph.get_type_hash("Semaphore")]],
					"xSemaphoreCreateMutexStatic": 			[[],graph.syscall_definition_type.create,[graph.get_type_hash("Semaphore")]],
					"xSemaphoreCreateRecursiveMutex": 		[[],graph.syscall_definition_type.create,[graph.get_type_hash("Semaphore")]],
					"xSemaphoreCreateRecursiveMutexStatic": [[],graph.syscall_definition_type.create,[graph.get_type_hash("Semaphore")]],
					"xQueueCreateCountingSemaphore": 		[[],graph.syscall_definition_type.create,[graph.get_type_hash("Semaphore")]],
					"xSemaphoreCreateCountingStatic": 		[[],graph.syscall_definition_type.create,[graph.get_type_hash("Semaphore")]],
					
					"xTimerCreate": 						[[],graph.syscall_definition_type.create,[graph.get_type_hash("Timer")]],
					"xTimerCreateStatic": 					[[],graph.syscall_definition_type.create,[graph.get_type_hash("Timer")]],
					"xEventGroupCreate": 					[[],graph.syscall_definition_type.create,[graph.get_type_hash("EventGroup")]],
					"xEventGroupCreateStatic": 				[[],graph.syscall_definition_type.create,[graph.get_type_hash("EventGroup")]],
					"xStreamBufferGenericCreate": 			[[],graph.syscall_definition_type.create,[graph.get_type_hash("Buffer")]],
					"xStreamBufferCreateStatic": 			[[],graph.syscall_definition_type.create,[graph.get_type_hash("Buffer")]],
					"xMessageBufferCreateStatic": 			[[],graph.syscall_definition_type.create,[graph.get_type_hash("Buffer")]],
					
					
					
					
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

					
					#TODO second argument command id xCommandID
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
				
					
					
										
					#"vQueueAddToRegistry": 			[65,graph.syscall_definition_type.commit,graph.get_type_hash("Task")],
					#"uxQueueMessagesWaitingFromISR":[65,graph.syscall_definition_type.receive,graph.get_type_hash("Queue")],
					#"uxQueueMessagesWaiting":[65,graph.syscall_definition_type.receive,graph.get_type_hash("Queue")],
					#"xQueueAddToSet":	   			[65,graph.syscall_definition_type.commit,graph.get_type_hash("QueueSet")],
					#"xQueueRemoveFromSet":			[65,graph.syscall_definition_type.destroy,graph.get_type_hash("Queue")],
					#"xQueueSelectFromSet": 88 ,
					#"xQueueSelectFromSetFromISR": 89 ,
					#"uxQueueSpacesAvailable": 95 ,
					
					
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
					syscall = syscall_dict.get(call_name.decode('ascii'), "error")
					if syscall != "error":
						abb.set_call_type(graph.call_definition_type.sys_call)
						abb.set_syscall_type(syscall[1])
						abb.set_call_target_instance(syscall[2])
						abb.set_expected_syscall_argument_types(syscall[0])
						
						argument_types = abb.get_expected_syscall_argument_types()
						print(syscall[0])
					else:
						abb.set_call_type(graph.call_definition_type.func_call)
						
					
						
				
				
	
		print("I'm an SyscallStep")
	


		
		
