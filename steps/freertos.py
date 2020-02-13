from .os_util import syscall

import graph

from graph.argument import CallPath


# TODO make this a dataclass once we use Python 3.7
class Task:
    def __init__(self, cfg, entry_abb, name, function, stack_size, parameters,
                 priority, handle_p, abb, branch, after_scheduler,
                 is_regular=True):
        self.cfg = cfg
        self.entry_abb = entry_abb
        self.name = name
        self.function = function
        self.stack_size = stack_size
        self.parameters = parameters
        self.priority = priority
        self.handle_p = handle_p
        self.abb = abb
        self.branch = branch
        self.after_scheduler = after_scheduler
        self.is_regular = is_regular

    def __repr__(self):
        return '<' + '|'.join([str((k,v)) for k,v in self.__dict__.items()]) + '>'


class FreeRTOS:
    vertex_properties = [('label', 'string', 'instance name'),
                         ('obj', 'object', 'instance object (e.g. Task)')]
    @staticmethod
    def init(state):
        for prop in FreeRTOS.vertex_properties:
            state.instances.vp[prop[0]] = state.instances.new_vp(prop[1])

    @staticmethod
    def interpret(cfg, abb, state):
        syscall = cfg.get_syscall_name(abb)
        print("FreeRTOS Syscall:", syscall)
        return getattr(FreeRTOS, syscall)(cfg, abb, state)

    @staticmethod
    def add_normal_cfg(cfg, abb, state):
        for oedge in cfg.vertex(abb).out_edges():
            if cfg.ep.type[oedge] == graph.CFType.lcf:
                state.next_abbs.append(oedge.target())

    @syscall
    def vTaskNotifyGiveFromISR(cfg, abb, state):
        pass

    @syscall
    def xTaskCreate(cfg, abb, state):
        state = state.copy()

        # instance properties
        cp = CallPath(graph=state.callgraph, node=state.call)
        task_function = state.cfg.vp.arguments[abb][0].get(call_path=cp)
        task_name = state.cfg.vp.arguments[abb][1].get(call_path=cp)
        task_stack_size = state.cfg.vp.arguments[abb][2].get(call_path=cp)
        task_parameters = state.cfg.vp.arguments[abb][3].get(call_path=cp)
        task_priority = state.cfg.vp.arguments[abb][4].get(call_path=cp)
        task_handle_p = state.cfg.vp.arguments[abb][5].get(call_path=cp)

        v = state.instances.add_vertex()
        state.instances.vp.label[v] = task_name

        after_scheduler = hasattr(state, 'scheduler_on') and state.scheduler_on

        new_cfg = cfg.get_entry_abb(cfg.get_function_by_name(task_function))
        assert new_cfg is not None
        state.instances.vp.obj[v] = Task(cfg, new_cfg,
                                         function=task_function,
                                         name=task_name,
                                         stack_size=task_stack_size,
                                         parameters=task_parameters,
                                         priority=task_priority,
                                         handle_p=task_handle_p,
                                         abb=abb,
                                         branch=state.branch,
                                         after_scheduler=after_scheduler)
        state.next_abbs = []

        # next abbs
        FreeRTOS.add_normal_cfg(cfg, abb, state)
        return state

    @syscall
    def vTaskStartScheduler(cfg, abb, state):
        state = state.copy()
        cp = CallPath(graph=state.callgraph, node=state.call)

        v = state.instances.add_vertex()
        state.instances.vp.label[v] = '__idle_task'

        #TODO: get idle task priority from config: ( tskIDLE_PRIORITY | portPRIVILEGE_BIT )
        state.instances.vp.obj[v] = Task(cfg, None,
                                         function='prvIdleTask',
                                         name='idle_task',
                                         stack_size='configMINIMAL_STACK_SIZE',
                                         parameters=0,
                                         priority=0,
                                         handle_p=0,
                                         abb=abb,
                                         branch=state.branch,
                                         after_scheduler=False,
                                         is_regular=False)
        state.next_abbs = []
        state.scheduler_on = True
        return state
#     {
#         "name": "vTaskNotifyGiveFromISR",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xTaskCreateStatic",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.CREATE,
#     },
#     {
#         "name": "xTaskCreateRestricted",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.CREATE,
#     },
#     {
#         "name": "xQueueGenericCreate",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.CREATE,
#     },
#     {
#         "name": "xQueueCreateStatic",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.CREATE,
#     },
#     {
#         "name": "xQueueCreateSet",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.CREATE,
#     },
#     {
#         "name": "vSemaphoreCreateBinary",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.CREATE,
#     },
#     {
#         "name": "xSemaphoreCreateBinary",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.CREATE,
#     },
#     {
#         "name": "xSemaphoreCreateBinaryStatic",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.CREATE,
#     },
#     {
#         "name": "xQueueCreateMutex",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.CREATE,
#     },
#     {
#         "name": "xSemaphoreCreateMutexStatic",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.CREATE,
#     },
#     {
#         "name": "xSemaphoreCreateRecursiveMutex",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.CREATE,
#     },
#     {
#         "name": "xSemaphoreCreateRecursiveMutexStatic",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.CREATE,
#     },
#     {
#         "name": "xQueueCreateCountingSemaphore",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.CREATE,
#     },
#     {
#         "name": "xSemaphoreCreateCountingStatic",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.CREATE,
#     },
#     {
#         "name": "xTimerCreate",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.CREATE,
#     },
#     {
#         "name": "xTimerCreateStatic",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.CREATE,
#     },
#     {
#         "name": "xEventGroupCreate",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.CREATE,
#     },
#     {
#         "name": "xEventGroupCreateStatic",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.CREATE,
#     },
#     {
#         "name": "xStreamBufferGenericCreate",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.CREATE,
#     },
#     {
#         "name": "xStreamBufferCreateStatic",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.CREATE,
#     },
#     {
#         "name": "xMessageBufferCreateStatic",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.CREATE,
#     },
#     {
#         "name": "vTaskAllocateMPURegions",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xTaskAbortDelay",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xTaskCallApplicationTaskHook",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xTaskCheckForTimeOut",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "vTaskDelay",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "vTaskDelayUntil",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "vTaskDelete",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "portDISABLE_INTERRUPTS",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "portENABLE_INTERRUPTS",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "vTaskEnterCritical",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "portSET_INTERRUPT_MASK_FROM_ISR",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "vTaskExitCritical",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xTaskGetApplicationTaskTag",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xTaskGetCurrentTaskHandle",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xTaskGetIdleTaskHandle",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xTaskGetHandle",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "uxTaskGetNumberOfTasks",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "vTaskGetRunTimeStats",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "uxTaskGetStackHighWaterMark",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "eTaskGetState",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "uxTaskGetSystemState",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "pvTaskGetThreadLocalStoragePointer",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "pcTaskGetName",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xTaskGetTickCount",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xTaskGetTickCountFromISR",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "vTaskList",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xTaskNotifyStateClear",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "ulTaskNotifyTake",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "uxTaskPriorityGet",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "vTaskPrioritySet",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "vTaskResume",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xTaskResumeAll",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xTaskResumeFromISR",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "vTaskSetApplicationTaskTag",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "vTaskSetThreadLocalStoragePointer",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "vTaskSetTimeOutState",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "vTaskStartScheduler",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.START,
#     },
#     {
#         "name": "vTaskStepTick",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "vTaskSuspend",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "vTaskSuspendAll",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "portYIELD",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xQueueGenericSend",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xQueueGenericSendFromISR",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xQueueReceive",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xQueueReceiveFromISR",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xQueuePeek",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xQueuePeekFromISR",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xQueueIsQueueEmptyFromISR",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xQueueIsQueueFullFromISR",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "uxQueueMessagesWaiting",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "uxQueueSpacesAvailable",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "vQueueDelete",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "pcQueueGetName",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xQueueReset",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xQueueGiveFromISR",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xQueueSemaphoreTake",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xQueueGetMutexHolder",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xQueueGetMutexHolderFromISR",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xQueueGiveMutexRecursive",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xQueueTakeMutexRecursive",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xTimerGenericCommand",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xTimerGetExpiryTime",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "pcTimerGetName",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xTimerGetPeriod",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xTimerGetTimerDaemonTaskHandle",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "pvTimerGetTimerID",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xTimerIsTimerActive",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xTimerPendFunctionCall",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xTimerPendFunctionCallFromISR",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "vTimerSetTimerID",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "vQueueAddToRegistry",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "uxQueueMessagesWaitingFromISR",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xQueueAddToSet",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xQueueRemoveFromSet",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xQueueSelectFromSet",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xQueueSelectFromSetFromISR",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xEventGroupClearBits",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xEventGroupClearBitsFromISR",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "vEventGroupDelete",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xEventGroupGetBitsFromISR",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xEventGroupSetBits",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xEventGroupSetBitsFromISR",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xEventGroupSync",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xEventGroupWaitBits",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xStreamBufferBytesAvailable",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "vStreamBufferDelete",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xStreamBufferIsEmpty",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xStreamBufferIsFull",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xStreamBufferReceive",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xStreamBufferReceiveFromISR",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xStreamBufferReset",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xStreamBufferResetFromISR",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xStreamBufferSend",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xStreamBufferSendFromISR",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xStreamBufferSetTriggerLevel",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xStreamBufferSpacesAvailable",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "xCoRoutineCreate",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.CREATE,
#     },
#     {
#         "name": "vCoRoutineSchedule",
#         "os": OS.FreeRTOS,
#         "type": SyscallType.DEFAULT,
#     }
