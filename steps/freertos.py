from .os_util import syscall, SyscallCategory

import graph
import logging

from graph.argument import CallPath


logger = logging.getLogger("FreeRTOS")


# TODO make this a dataclass once we use Python 3.7
class Task:
    uid_counter = 0
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
        self.uid = Task.uid_counter
        Task.uid_counter += 1

    def __repr__(self):
        return '<' + '|'.join([str((k,v)) for k,v in self.__dict__.items()]) + '>'

# TODO make this a dataclass once we use Python 3.7
class Queue:
    uid_counter = 0
    def __init__(self, cfg, name, handler, length, size, abb, branch,
                 after_scheduler):
        self.cfg = cfg
        self.name = name
        self.handler = handler
        self.length = length
        self.size = size
        self.abb = abb
        self.branch = branch
        self.after_scheduler = after_scheduler
        self.uid = Queue.uid_counter
        Queue.uid_counter += 1

    def __repr__(self):
        return '<' + '|'.join([str((k,v)) for k,v in self.__dict__.items()]) + '>'


# TODO make this a dataclass once we use Python 3.7
class Mutex:
    uid_counter = 0
    def __init__(self, cfg, name, handler, m_type, abb, branch, after_scheduler):
        self.cfg = cfg
        self.name = name
        self.handler = handler
        self.m_type = m_type
        self.abb = abb
        self.branch = branch
        self.after_scheduler = after_scheduler
        self.uid = Queue.uid_counter
        self.size = 0
        self.length = 1
        Mutex.uid_counter += 1

    def __repr__(self):
        return '<' + '|'.join([str((k,v)) for k,v in self.__dict__.items()]) + '>'


class FreeRTOS:
    vertex_properties = [('label', 'string', 'instance name'),
                         ('obj', 'object', 'instance object (e.g. Task)')]
    edge_properties = [('label', 'string', 'syscall name')]
    config = {}

    @staticmethod
    def init(state):
        for prop in FreeRTOS.vertex_properties:
            state.instances.vp[prop[0]] = state.instances.new_vp(prop[1])
        for prop in FreeRTOS.edge_properties:
            state.instances.ep[prop[0]] = state.instances.new_ep(prop[1])
        state.scheduler_on = False

    @staticmethod
    def interpret(cfg, abb, state, categories=SyscallCategory.ALL):
        syscall = cfg.get_syscall_name(abb)
        logger.debug(f"Get syscall: {syscall}")

        syscall_function = getattr(FreeRTOS, syscall)

        if isinstance(categories, SyscallCategory):
            categories = set((categories,))

        if SyscallCategory.ALL not in categories:
            sys_cat = syscall_function.categories
            if sys_cat | categories != sys_cat:
                # do not interpret this syscall
                state = state.copy()
                state.next_abbs = []
                FreeRTOS.add_normal_cfg(cfg, abb, state)
                return state
        return getattr(FreeRTOS, syscall)(cfg, abb, state)

    @staticmethod
    def add_normal_cfg(cfg, abb, state):
        for oedge in cfg.vertex(abb).out_edges():
            if cfg.ep.type[oedge] == graph.CFType.lcf:
                state.next_abbs.append(oedge.target())

    @syscall(SyscallCategory.CREATE)
    def xTaskCreate(cfg, abb, state):
        state = state.copy()

        # instance properties
        cp = CallPath(graph=state.callgraph, node=state.call)
        task_function = state.cfg.vp.arguments[abb][0].get(call_path=cp)
        task_name = state.cfg.vp.arguments[abb][1].get(call_path=cp)
        task_stack_size = state.cfg.vp.arguments[abb][2].get(call_path=cp)
        task_parameters = state.cfg.vp.arguments[abb][3].get(call_path=cp)
        task_priority = state.cfg.vp.arguments[abb][4].get(call_path=cp)
        task_handle_p = state.cfg.vp.arguments[abb][5].get(call_path=cp, raw=True)

        v = state.instances.add_vertex()
        state.instances.vp.label[v] = task_name

        new_cfg = cfg.get_entry_abb(cfg.get_function_by_name(task_function))
        assert new_cfg is not None
        # TODO: when do we know that this is an unique instance?
        state.instances.vp.obj[v] = Task(cfg, new_cfg,
                                         function=task_function,
                                         name=task_name,
                                         stack_size=task_stack_size,
                                         parameters=task_parameters,
                                         priority=task_priority,
                                         handle_p=task_handle_p,
                                         abb=abb,
                                         branch=state.branch,
                                         after_scheduler=state.scheduler_on)
        state.next_abbs = []

        # next abbs
        FreeRTOS.add_normal_cfg(cfg, abb, state)
        return state

    @syscall(SyscallCategory.CREATE)
    def vTaskStartScheduler(cfg, abb, state):
        state = state.copy()

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

    @syscall(SyscallCategory.CREATE)
    def xQueueGenericCreate(cfg, abb, state):
        state = state.copy()

        # instance properties
        cp = CallPath(graph=state.callgraph, node=state.call)
        queue_handler = state.cfg.vp.arguments[abb].get_return_value()
        handler_name = queue_handler.get(raw=True).get_name()
        queue_len = state.cfg.vp.arguments[abb][0].get(call_path=cp)
        queue_item_size = state.cfg.vp.arguments[abb][1].get(call_path=cp)

        v = state.instances.add_vertex()
        state.instances.vp.label[v] = f"{handler_name}"

        # TODO: when do we know that this is an unique instance?
        state.instances.vp.obj[v] = Queue(cfg,
                                          name=handler_name,
                                          handler=queue_handler,
                                          length=queue_len,
                                          size=queue_item_size,
                                          abb=abb,
                                          branch=state.branch,
                                          after_scheduler=state.scheduler_on)
        state.next_abbs = []
        FreeRTOS.add_normal_cfg(cfg, abb, state)
        return state

    @syscall(SyscallCategory.CREATE)
    def xQueueCreateMutex(cfg, abb, state):
        state = state.copy()
        # instance properties
        cp = CallPath(graph=state.callgraph, node=state.call)
        mutex_handler = state.cfg.vp.arguments[abb].get_return_value()
        handler_name = mutex_handler.get(raw=True).get_name()
        mutex_type = state.cfg.vp.arguments[abb][0].get(call_path=cp)

        v = state.instances.add_vertex()
        state.instances.vp.label[v] = f"{handler_name}"

        state.instances.vp.obj[v] = Mutex(cfg,
                                          name=handler_name,
                                          handler=mutex_handler,
                                          m_type=mutex_type,
                                          abb=abb,
                                          branch=state.branch,
                                          after_scheduler=state.scheduler_on)

        state.next_abbs = []
        FreeRTOS.add_normal_cfg(cfg, abb, state)
        return state

    @syscall(SyscallCategory.COMM)
    def vTaskDelay(cfg, abb, state):
        state = state.copy()

        cp = CallPath(graph=state.callgraph, node=state.call)
        ticks = state.cfg.vp.arguments[abb][0].get(call_path=cp)

        if state.running is None:
            # TODO proper error handling
            logger.error("ERROR: vTaskDelay called without running Task")

        e = state.instances.add_edge(state.running, state.running)
        state.instances.ep.label[e] = f"vTaskDelay({ticks})"

        state.next_abbs = []
        FreeRTOS.add_normal_cfg(cfg, abb, state)
        return state

    @syscall(SyscallCategory.COMM)
    def xQueueGenericSend(cfg, abb, state):
        state = state.copy()

        cp = CallPath(graph=state.callgraph, node=state.call)
        handler = state.cfg.vp.arguments[abb][0].get(call_path=cp, raw=True)

        # TODO this has to be a pointer object. However, the value analysis
        # follows the pointer currently.
        item = state.cfg.vp.arguments[abb][1].get(call_path=cp, raw=True)
        ticks = state.cfg.vp.arguments[abb][2].get(call_path=cp)
        action = state.cfg.vp.arguments[abb][3].get(call_path=cp)

        queue = None
        for v in state.instances.vertices():
            if any([isinstance(state.instances.vp.obj[v], x)
                    for x in [Queue, Mutex]]):
                if handler == state.instances.vp.obj[v].handler.get(raw=True):
                    queue = v
        if queue is None:
            logger.error("Queue handler cannot be found. Ignoring syscall.")
        else:
            e = state.instances.add_edge(state.running, queue)
            state.instances.ep.label[e] = f"xQueueGenericSend"

        state.next_abbs = []
        FreeRTOS.add_normal_cfg(cfg, abb, state)
        return state

    ## HERE BEGINS THE TODO sections, all following syscalls are stubs

    @syscall
    def eTaskGetState(cfg, abb, state):
        pass

    @syscall
    def pcQueueGetName(cfg, abb, state):
        pass

    @syscall
    def pcTaskGetName(cfg, abb, state):
        pass

    @syscall
    def pcTimerGetName(cfg, abb, state):
        pass

    @syscall
    def portDISABLE_INTERRUPTS(cfg, abb, state):
        pass

    @syscall
    def portENABLE_INTERRUPTS(cfg, abb, state):
        pass

    @syscall
    def portSET_INTERRUPT_MASK_FROM_ISR(cfg, abb, state):
        pass

    @syscall
    def portYIELD(cfg, abb, state):
        pass

    @syscall
    def pvTaskGetThreadLocalStoragePointer(cfg, abb, state):
        pass

    @syscall
    def pvTimerGetTimerID(cfg, abb, state):
        pass

    @syscall
    def ulTaskNotifyTake(cfg, abb, state):
        pass

    @syscall
    def uxQueueMessagesWaiting(cfg, abb, state):
        pass

    @syscall
    def uxQueueMessagesWaitingFromISR(cfg, abb, state):
        pass

    @syscall
    def uxQueueSpacesAvailable(cfg, abb, state):
        pass

    @syscall
    def uxTaskGetNumberOfTasks(cfg, abb, state):
        pass

    @syscall
    def uxTaskGetStackHighWaterMark(cfg, abb, state):
        pass

    @syscall
    def uxTaskGetSystemState(cfg, abb, state):
        pass

    @syscall
    def uxTaskPriorityGet(cfg, abb, state):
        pass

    @syscall
    def vCoRoutineSchedule(cfg, abb, state):
        pass

    @syscall
    def vEventGroupDelete(cfg, abb, state):
        pass

    @syscall
    def vQueueAddToRegistry(cfg, abb, state):
        pass

    @syscall
    def vQueueDelete(cfg, abb, state):
        pass

    @syscall
    def vSemaphoreCreateBinary(cfg, abb, state):
        pass

    @syscall
    def vStreamBufferDelete(cfg, abb, state):
        pass

    @syscall
    def vTaskAllocateMPURegions(cfg, abb, state):
        pass

    @syscall
    def vTaskDelayUntil(cfg, abb, state):
        pass

    @syscall
    def vTaskDelete(cfg, abb, state):
        pass

    @syscall
    def vTaskEnterCritical(cfg, abb, state):
        pass

    @syscall
    def vTaskExitCritical(cfg, abb, state):
        pass

    @syscall
    def vTaskGetRunTimeStats(cfg, abb, state):
        pass

    @syscall
    def vTaskList(cfg, abb, state):
        pass

    @syscall
    def vTaskNotifyGiveFromISR(cfg, abb, state):
        pass

    @syscall
    def vTaskPrioritySet(cfg, abb, state):
        pass

    @syscall
    def vTaskResume(cfg, abb, state):
        pass

    @syscall
    def vTaskSetApplicationTaskTag(cfg, abb, state):
        pass

    @syscall
    def vTaskSetThreadLocalStoragePointer(cfg, abb, state):
        pass

    @syscall
    def vTaskSetTimeOutState(cfg, abb, state):
        pass


    @syscall
    def vTaskStepTick(cfg, abb, state):
        pass

    @syscall
    def vTaskSuspend(cfg, abb, state):
        pass

    @syscall
    def vTaskSuspendAll(cfg, abb, state):
        pass

    @syscall
    def vTimerSetTimerID(cfg, abb, state):
        pass

    @syscall
    def xCoRoutineCreate(cfg, abb, state):
        pass

    @syscall
    def xEventGroupClearBits(cfg, abb, state):
        pass

    @syscall
    def xEventGroupClearBitsFromISR(cfg, abb, state):
        pass

    @syscall
    def xEventGroupCreate(cfg, abb, state):
        pass

    @syscall
    def xEventGroupCreateStatic(cfg, abb, state):
        pass

    @syscall
    def xEventGroupGetBitsFromISR(cfg, abb, state):
        pass

    @syscall
    def xEventGroupSetBits(cfg, abb, state):
        pass

    @syscall
    def xEventGroupSetBitsFromISR(cfg, abb, state):
        pass

    @syscall
    def xEventGroupSync(cfg, abb, state):
        pass

    @syscall
    def xEventGroupWaitBits(cfg, abb, state):
        pass

    @syscall
    def xMessageBufferCreateStatic(cfg, abb, state):
        pass

    @syscall
    def xQueueAddToSet(cfg, abb, state):
        pass

    @syscall
    def xQueueCreateCountingSemaphore(cfg, abb, state):
        pass

    @syscall
    def xQueueCreateSet(cfg, abb, state):
        pass

    @syscall
    def xQueueCreateStatic(cfg, abb, state):
        pass

    @syscall
    def xQueueGenericSendFromISR(cfg, abb, state):
        pass

    @syscall
    def xQueueGetMutexHolder(cfg, abb, state):
        pass

    @syscall
    def xQueueGetMutexHolderFromISR(cfg, abb, state):
        pass

    @syscall
    def xQueueGiveFromISR(cfg, abb, state):
        pass

    @syscall
    def xQueueGiveMutexRecursive(cfg, abb, state):
        pass

    @syscall
    def xQueueIsQueueEmptyFromISR(cfg, abb, state):
        pass

    @syscall
    def xQueueIsQueueFullFromISR(cfg, abb, state):
        pass

    @syscall
    def xQueuePeek(cfg, abb, state):
        pass

    @syscall
    def xQueuePeekFromISR(cfg, abb, state):
        pass

    @syscall
    def xQueueReceive(cfg, abb, state):
        pass

    @syscall
    def xQueueReceiveFromISR(cfg, abb, state):
        pass

    @syscall
    def xQueueRemoveFromSet(cfg, abb, state):
        pass

    @syscall
    def xQueueReset(cfg, abb, state):
        pass

    @syscall
    def xQueueSelectFromSet(cfg, abb, state):
        pass

    @syscall
    def xQueueSelectFromSetFromISR(cfg, abb, state):
        pass

    @syscall
    def xQueueSemaphoreTake(cfg, abb, state):
        pass

    @syscall
    def xQueueTakeMutexRecursive(cfg, abb, state):
        pass

    @syscall
    def xSemaphoreCreateBinary(cfg, abb, state):
        pass

    @syscall
    def xSemaphoreCreateBinaryStatic(cfg, abb, state):
        pass

    @syscall
    def xSemaphoreCreateCountingStatic(cfg, abb, state):
        pass

    @syscall
    def xSemaphoreCreateMutexStatic(cfg, abb, state):
        pass

    @syscall
    def xSemaphoreCreateRecursiveMutex(cfg, abb, state):
        pass

    @syscall
    def xSemaphoreCreateRecursiveMutexStatic(cfg, abb, state):
        pass

    @syscall
    def xStreamBufferBytesAvailable(cfg, abb, state):
        pass

    @syscall
    def xStreamBufferCreateStatic(cfg, abb, state):
        pass

    @syscall
    def xStreamBufferGenericCreate(cfg, abb, state):
        pass

    @syscall
    def xStreamBufferIsEmpty(cfg, abb, state):
        pass

    @syscall
    def xStreamBufferIsFull(cfg, abb, state):
        pass

    @syscall
    def xStreamBufferReceive(cfg, abb, state):
        pass

    @syscall
    def xStreamBufferReceiveFromISR(cfg, abb, state):
        pass

    @syscall
    def xStreamBufferReset(cfg, abb, state):
        pass

    @syscall
    def xStreamBufferResetFromISR(cfg, abb, state):
        pass

    @syscall
    def xStreamBufferSend(cfg, abb, state):
        pass

    @syscall
    def xStreamBufferSendFromISR(cfg, abb, state):
        pass

    @syscall
    def xStreamBufferSetTriggerLevel(cfg, abb, state):
        pass

    @syscall
    def xStreamBufferSpacesAvailable(cfg, abb, state):
        pass

    @syscall
    def xTaskAbortDelay(cfg, abb, state):
        pass

    @syscall
    def xTaskCallApplicationTaskHook(cfg, abb, state):
        pass

    @syscall
    def xTaskCheckForTimeOut(cfg, abb, state):
        pass

    @syscall
    def xTaskCreateRestricted(cfg, abb, state):
        pass

    @syscall
    def xTaskCreateStatic(cfg, abb, state):
        pass

    @syscall
    def xTaskGetApplicationTaskTag(cfg, abb, state):
        pass

    @syscall
    def xTaskGetCurrentTaskHandle(cfg, abb, state):
        pass

    @syscall
    def xTaskGetHandle(cfg, abb, state):
        pass

    @syscall
    def xTaskGetIdleTaskHandle(cfg, abb, state):
        pass

    @syscall
    def xTaskGetTickCount(cfg, abb, state):
        pass

    @syscall
    def xTaskGetTickCountFromISR(cfg, abb, state):
        pass

    @syscall
    def xTaskNotifyStateClear(cfg, abb, state):
        pass

    @syscall
    def xTaskResumeAll(cfg, abb, state):
        pass

    @syscall
    def xTaskResumeFromISR(cfg, abb, state):
        pass

    @syscall
    def xTimerCreate(cfg, abb, state):
        pass

    @syscall
    def xTimerCreateStatic(cfg, abb, state):
        pass

    @syscall
    def xTimerGenericCommand(cfg, abb, state):
        pass

    @syscall
    def xTimerGetExpiryTime(cfg, abb, state):
        pass

    @syscall
    def xTimerGetPeriod(cfg, abb, state):
        pass

    @syscall
    def xTimerGetTimerDaemonTaskHandle(cfg, abb, state):
        pass

    @syscall
    def xTimerIsTimerActive(cfg, abb, state):
        pass

    @syscall
    def xTimerPendFunctionCall(cfg, abb, state):
        pass

    @syscall
    def xTimerPendFunctionCallFromISR(cfg, abb, state):
        pass
