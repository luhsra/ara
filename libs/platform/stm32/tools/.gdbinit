# Command "freertos_show_threads"
# Shows tasks table: handle(xTaskHandle) and name
define freertos_show_threads
	set $thread_list_size = 0
	set $thread_list_size = uxCurrentNumberOfTasks
	set $current_thread = pxCurrentTCB
	set $tasks_found = 0
	set $idx = 0

	set $task_list = pxReadyTasksLists
	set $task_list_size = sizeof(pxReadyTasksLists)/sizeof(pxReadyTasksLists[0])
	while ($idx < $task_list_size)
	  printf "ReadyList %d\n", $idx
	  _freertos_show_thread_list $task_list[$idx]
	  set $idx = $idx + 1
	end

	printf "\nxDelayedTasksList1\n"
	_freertos_show_thread_list xDelayedTaskList1
	printf "\nxDelayedTasksList2\n"
	_freertos_show_thread_list xDelayedTaskList2
	printf "\nxPendingReadyList\n"
	_freertos_show_thread_list xPendingReadyList

	# set $VAL_dbgFreeRTOSConfig_suspend = dbgFreeRTOSConfig_suspend_value
	# if ($VAL_dbgFreeRTOSConfig_suspend != 0)
	#   _freertos_show_thread_item xSuspendedTaskList
	# end

	# set $VAL_dbgFreeRTOSConfig_delete = dbgFreeRTOSConfig_delete_value
	# if ($VAL_dbgFreeRTOSConfig_delete != 0)
	#   _freertos_show_thread_item xTasksWaitingTermination
	# end
end

# # Command "freertos_switch_to_task"
# # Switches debugging context to specified task, argument - task handle
# define freertos_switch_to_task
# 	set var dbgPendingTaskHandle = $arg0
# 	set $current_IPSR_val = $xpsr & 0xFF
# 	if (($current_IPSR_val >= 1) && ($current_IPSR_val <= 15))
# 		echo Switching from system exception context isn''t supported
# 	else
# 		set $VAL_dbgPendSVHookState = dbgPendSVHookState
# 		if ($VAL_dbgPendSVHookState == 0)
# 			set $last_PRIMASK_val = $PRIMASK
# 			set $last_SCB_ICSR_val = *((volatile unsigned long *)0xE000ED04)
# 			set $last_SYSPRI2_val = *((volatile unsigned long *)0xE000ED20)
# 			set $last_SCB_CCR_val = *((volatile unsigned long *)0xE000ED14)
# 			set $running_IPSR_val = $current_IPSR_val
# 			set $PRIMASK = 0
# 			# *(portNVIC_SYSPRI2) &= ~(255 << 16) // temporary increase PendSV priority to highest
# 				set {unsigned int}0xe000ed20 = ($last_SYSPRI2_val & (~(255 << 16)))
# 			# set SCB->CCR NONBASETHRDENA bit (allows processor enter thread mode from at any execution priority level)
# 			set {unsigned int}0xE000ED14 = (1) | $last_SCB_CCR_val
# 			set var dbgPendSVHookState = 1
# 		end
# 		# *(portNVIC_INT_CTRL) = portNVIC_PENDSVSET
# 			set {unsigned int}0xe000ed04 = 0x10000000
# 		continue
# 		# here we stuck at "bkpt" instruction just before "bx lr" (in helper's xPortPendSVHandler)
# 		# force returning to thread mode with process stack
# 		set $lr = 0xFFFFFFFD
# 		stepi
# 		stepi
# 		# here we get rewound to task
# 	end
# end

# # Command "freertos_restore_running_context"
# # Restores context of running task
# define freertos_restore_running_context
# 	set $VAL_dbgPendSVHookState = dbgPendSVHookState
# 	if ($VAL_dbgPendSVHookState == 0)
# 		echo Current task is RUNNING, ignoring command...
# 	else
# 		set var dbgPendingTaskHandle = (void *)pxCurrentTCB
# 		# *(portNVIC_INT_CTRL) = portNVIC_PENDSVSET
# 			set {unsigned int}0xe000ed04 = 0x10000000
# 		continue
# 		# here we stuck at "bkpt" instruction just before "bx lr" (in helper's xPortPendSVHandler)
# 		# check what execution mode was in context we started to switch from
# 		if ($running_IPSR_val == 0)
# 			# force returning to thread mode with process stack
# 			set $lr = 0xFFFFFFFD
# 		else
# 			# force returning to handler mode
# 			set $lr = 0xFFFFFFF1
# 		end
# 		stepi
# 		stepi
# 		# here we get rewound to running task at place we started switching
# 		# restore processor state
# 		set $PRIMASK = $last_PRIMASK_val
# 		set {unsigned int}0xe000ed20 = $last_SYSPRI2_val
# 		set {unsigned int}0xE000ED14 = $last_SCB_CCR_val
# 		if ($last_SCB_ICSR_val & (1 << 28))
# 			set {unsigned int}0xe000ed04 = 0x10000000
# 		end
# 		set var dbgPendSVHookState = 0
# 	end
# end

# Command "show_broken_backtrace"
# Workaround of issue when context is being stuck in the middle of function epilogue (i.e., in vTaskDelay())
# This solution is applied to following situation only:
### ... function body end
### xxxxxxxx+0: add.w r7, r7, #16
### xxxxxxxx+4: mov sp, r7        ; <- debug current instruction pointer
### xxxxxxxx+6: pop {r7, pc}
### }
# (Otherwise it will crash !)
# define show_broken_backtrace
# 	# cancel effect of xxxxxxxx+4 instruction twice (because we will step it to update eclipse views)
# 	set $r7 = $r7 - 16 - 16
# 	set $pc = $pc - 4
# 	stepi
# end


#######################
# Internal functions
define _freertos_show_thread_list
	set $pending_items = $arg0.uxNumberOfItems
	set $current_item = $arg0.xListEnd->pxNext
	while (($pending_items > 0))
	  set $current_tcb = (TCB_t*) $current_item->pvOwner
	  set $current_name = &$current_tcb->pcTaskName
	  set $running = $current_tcb == pxCurrentTCB
	  printf "0x%x\t%s\t%d\n", $current_tcb, $current_name, $running
	  set $current_item = $current_item->pxNext
	  set $pending_items -= 1
	end
end
