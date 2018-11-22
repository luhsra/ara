import graph
import os
import sys
from collections import namedtuple
import logging
#import syscalls_references

from native_step import Step


MergeCandidates = namedtuple('MergeCandidates', 'entry_abb exit_abb inner_abbs')


def find_branches_to_merge(abb):
	successors = abb.get_successors()
	if not len(successors) == 2:
		return None

	left_succ = successors[0]
	right_succ = successors[1]

	#   O abb
	#  | \
	#  | O right_succ
	#  | /
	#   O left_succ
	#
	if right_succ.has_single_successor():
		rss = right_succ.get_single_successor()
		if rss.get_seed() == left_succ.get_seed():
			return MergeCandidates(entry_abb = abb, exit_abb = left_succ, inner_abbs = set([right_succ]))

	#   O abb
	#  /|
	# O | left_succ
	# \ |
	#  O  right_succ
	#
	if left_succ.has_single_successor():
		lss = left_succ.get_single_successor()
		if lss.get_seed() == right_succ.get_seed():
			return MergeCandidates(entry_abb = abb, exit_abb = right_succ, inner_abbs = set([left_succ]))

	#
	#   O abb
	#  / \
	# O   O right_succ
	#  \ /
	#   O rss/lss
	if left_succ.has_single_successor() and right_succ.has_single_successor():
		lss = left_succ.get_single_successor()
		rss = right_succ.get_single_successor()
		if lss.get_seed() == rss.get_seed():
			return MergeCandidates(entry_abb = abb, exit_abb = lss, inner_abbs = set([right_succ, left_succ]))

	return None

def merge_branches(graph):
	"""
	Try to merge if - else branches with the following pattern:
			O      O
			/ \     |\
			O  O     |O
			\/      |/
			O       O
	"""
	anyChanges = True
	while anyChanges:
		anyChanges = False
		for abb in graph.get_type_vertices("ABB"):
			mc = find_branches_to_merge(abb)
			if mc and can_be_merged(mc.entry_abb, mc.exit_abb, mc.inner_abbs):
				do_merge(mc.entry_abb, mc.exit_abb, mc.inner_abbs)
				anyChanges = True


	#self.merge_stats.after_branch_merge = len(self.system_graph.abbs)

def find_loops_to_merge(abb):
	# |
	# o<--->o
	# |
	successors = abb.successors()
	if not len(successors) == 2:
		return None

	left_succ = successors[0]
	right_succ = successors[1]

	if left_succ.has_single_successor():
		succ = left_succ.get_single_successor()
		if succ.get_seed() == abb.get_seed():
			return MergeCandidates(entry_abb = abb, exit_abb = abb,inner_abbs = {left_succ})
	if right_succ.has_single_successor():
		succ = right_succ.get_single_successor()
		if succ.get_seed() == abb.get_seed():
			return MergeCandidates(entry_abb = abb, exit_abb = abb,inner_abbs = {right_succ})

	return None

def merge_loops(graph):
	anyChanges = True
	while anyChanges:
		anyChanges = False
		for abb in graph.get_type_vertices("ABB"):
			mc = find_loops_to_merge(abb)
			if mc and can_be_merged(mc.entry_abb, mc.exit_abb, mc.inner_abbs):
				do_merge(mc.entry_abb, mc.exit_abb, mc.inner_abbs)
				anyChanges = True

	#self.merge_stats.after_loop_merge = len(g.get_type_vertices("ABB"))
        
def do_merge( entry_abb, exit_abb, inner_abbs = set()):
	#print('Trying to merge:', inner_abbs, exit_abb, 'into', entry_abb)
	#assert not entry_abb == exit_abb, 'Entry ABB cannot merge itself into itself'
	#assert not entry_abb in inner_abbs
	#assert exit_abb.function and entry_abb.function, 'ABBs must reside in any function'
	#assert not entry_abb.relevant_callees and not exit_abb.relevant_callees, 'Mergeable ABBs may not call relevant functions'

	parent_function = entry_abb.get_parent_function()
	
	
	# adopt basic blocks and call sites
	for abb in (inner_abbs | {exit_abb}) - {entry_abb}:
		
		entry_abb.append_basic_blocks(abb)
		# Collect all call sites
		entry_abb.expend_call(abb)
		
		
	# We merge everything into the entry block of a region.
	# Therefore, we just update the exit node of the entry to
	# preserve a correct entry/exit region
	
	entry_abb.adapt_exit_bb(exit_abb)

	# adopt outgoing edges
	for target in exit_abb.get_ABB_successors():
		exit_abb.remove_successor(target)
		seed = target.get_seed()
		if not seed == entry_abb.get_seed(): # omit self loop
			entry_abb.set_successor(target)

	# Remove edges between entry and inner_abbs/exit
	for abb in inner_abbs | {entry_abb}:
		for target in abb.get_ABB_successors():
			seed = target.get_seed()
			for element in inner_abbs | {exit_abb}:
				if element.get_seed() == seed:
					abb.remove_successor(target)

	for abb in (inner_abbs | {exit_abb}):
		# Adapt exit ABB in corresponding function
		#TODO check if possible more exit blocks
		if parent_function.get_exit_abb().get_seed() == abb.get_seed():
			parent_function.set_exit_abb(entry_abb)


	# Remove merged successors from any existing list
	for abb in (inner_abbs | {exit_abb}) - {entry_abb}:
		
		if not parent_function.remove_abb(abb.get_seed()):
			sys.exit("abb could not removed from function")
			
		if not graph.remove_vertex(abb.get_seed()):
			sys.exit("abb could not removed from graph")
		
		

	#print("Merged: ", successor, "into:", abb)
	#print(abb.outgoing_edges)
	

def can_be_merged( entry_abb, exit_abb, inner_abbs = set()):

	#Checks if a set of ABBs can be merged 
	for abb in inner_abbs | {entry_abb, exit_abb}:
		# Check if any ABB can actually be merged, that is not invoking any system call
		if not abb.is_mergeable():
			return False

	if entry_abb != exit_abb:
		for exit_successor in exit_abb.get_ABB_successors():
			# The exit node may not have any edge to an inner ABB
			seed = exit_successor.get_seed()
			for element in inner_abbs:
				if seed == element.get_seed():
					return False

		for exit_predecessor in exit_abb.get_ABB_predecessors():
			# The exit node may not be reachable from the outside
			seed = exit_predecessor.get_seed()
			for element in inner_abbs | {entry_abb}:
				if element.get_seed() == seed:
					return False

		for entry_successor in entry_abb.get_ABB_successors():
			# The entry node may only be followed by any inner ABB or the exit ABB
			seed = entry_successor.get_seed()
			flag = False
			for element in inner_abbs | {exit_abb}:
				if seed == element.get_seed():
					flag = True
				
			if flag == False:
				return False
			
	else: # entry_abb == exit_abb
		pass
		# Intentionally left blank:
		# We can only check if "some" predecessors are within the inner_abb region

	for inner_abb in inner_abbs:
		# Any inner ABB may only succeed any other inner ABB or the entry ABB
		for inner_predecessor in inner_abb.get_ABB_predecessor():
			seed = inner_predecessor.get_seed()
			for element in inner_abbs | {entry_abb}:
				if element.get_seed() == seed:
					return False

	return True



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
					#"Idle": 			[4,graph.syscall_definition_type.schedule,type(graph.RTOS)],
					#"iret": 			[5,graph.syscall_definition_type.schedule,type(graph.RTOS)],
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
					"xStreamBufferReset" : 				[[graph.data_type.string],graph.syscall_definition_type.reset,[graph.get_type_hash("Buffer")]],
					"xStreamBufferSend" : 				[[graph.data_type.string,graph.data_type.string,graph.data_type.integer,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("Buffer")]],
					"xStreamBufferSendFromISR" : 		[[graph.data_type.string,graph.data_type.string,graph.data_type.integer,graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Buffer")]],
					"xStreamBufferSetTriggerLevel" : 	[[graph.data_type.string,graph.data_type.integer],graph.syscall_definition_type.commit,[graph.get_type_hash("Buffer")]],
					"xStreamBufferSpacesAvailable" : 	[[graph.data_type.string],graph.syscall_definition_type.commit,[graph.get_type_hash("Buffer")]],
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
					
					#get call name #TODO get call names
					call_name_list = abb.get_call_names()
					
					assert len(call_name_list) == 1 , "more than one call in abb during syscall detection"
					
					for call_name in call_name_list:
						#check if call is a function call or a sys call
						syscall = syscall_dict.get(call_name.decode('ascii'), "error")
						if syscall != "error":
							
							abb.convert_call_to_syscall(call_name)
							
							function.set_has_syscall(True)
							
							expected_argument_types = graph.cast_expected_syscall_argument_types(syscall[0])
							
							argument_types = abb.get_syscall_argument_types()
							
							
							
							success = True
							
							if len(expected_argument_types) != len(argument_types):
								success = False
							else:
								counter = 0
								for expected_type in expected_argument_types:
									if isinstance(expected_type, list):
										tmp_success = False
										for sub_expected_type in expected_type:
											if sub_expected_type == argument_types[counter]:
												tmp_success = True
										success = tmp_success
										
									else:
										if expected_type != argument_types[counter]:
											success = False
									counter+=1
							
							if success == False:
								print(call_name, "does not match the expected arguments")
							
							abb.set_call_type(graph.call_definition_type.sys_call)
							abb.set_expected_syscall_argument_types(syscall[0])
							abb.set_syscall_type(syscall[1])
							abb.set_call_target_instance(syscall[2])
							
							
							
						else:
							abb.set_call_type(graph.call_definition_type.func_call)
						
					
		function_list = g.get_type_vertices("Function")
		abb_list = g.get_type_vertices("ABB")
		
		initial_abb_count = len(function_list)
				
		#TODO validate
		for function in function_list:
			if function.get_has_syscall() == False:
				#iterate about the abbs of the function
				already_visited = []
				function_list = []
				
				function_list.append(function)
				for tmp_function in reversed(function_list):
					success = False
					
					if not tmp_function.get_name() in already_visited:
						already_visited.append(tmp_function.get_name())
						
						abb_list = tmp_function.get_atomic_basic_blocks()
						
						for abb in abb_list:
							if abb.get_call_type() == graph.call_definition_type.func_call:
								called_functions = abb.get_called_functions()
								for called_function in called_functions:
									function_list.append(called_function)
								
							elif abb.get_call_type() == graph.call_definition_type.sys_call:
								function.set_has_syscall(True)
								success = True
								break
							
					if success == True:
						break
					
		initial_abb_count = len(abb_list)
		current_size = None
		
		"""
		while current_size != initial_abb_count:
			
			tmp_abb_list = g.get_type_vertices("ABB")
			current_size = len(tmp_abb_list)
		
			anyChanges = True

			while anyChanges:
				anyChanges = False
				# copy original dict
				for abb in tmp_abb_list: # Iterate over list of abbs dict KeysView
					
					successor_list = abb.get_ABB_successors()
					
					
					#for successor in successor_list:
						#TODO inner abbs wrong argument
						#if successor and can_be_merged(abb, successor):
							#do_merge(abb, successor)
						#anyChanges = False
							
		"""

		print("I'm an SyscallStep")
	



		
		
