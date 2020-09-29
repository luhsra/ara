from .os_util import syscall, get_argument
from .os_base import OSBase

import pyllco
import functools

import ara.graph as _graph
from ara.graph import CallPath, SyscallCategory, SigType
from ara.util import get_logger

logger = get_logger("FreeRTOS")

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
        self.__priority = priority
        self.handle_p = handle_p
        self.abb = abb
        self.branch = branch
        self.after_scheduler = after_scheduler
        self.is_regular = is_regular
        self.uid = Task.uid_counter
        Task.uid_counter += 1
        FreeRTOS.malloc_heap(stack_size, FreeRTOS.config.get('STACK_TYPE_SIZE', None), maybe=branch)
        FreeRTOS.malloc_heap(1, FreeRTOS.config.get('TCB_SIZE', None), maybe=branch)

    @property
    def priority(self):
        clamp = FreeRTOS.config.get('configMAX_PRIORITIES', None)
        if clamp is not None:
            clamp = clamp.get()
            if self.__priority >= clamp:
                logger.warning("Task %s priority clamped to %s (was %s)",
                                self.name, clamp -1, self.__priority)
                return clamp-1
        else:
            logger.warning("No value for configMAX_PRIORITIES found")
        return self.__priority

    def __repr__(self):
        return '<' + '|'.join([str((k,v)) for k,v in self.__dict__.items()]) + '>'

# TODO make this a dataclass once we use Python 3.7
class Queue:
    uid_counter = 0
    def __init__(self, cfg, name, handler, length, size, abb, branch,
                 after_scheduler, q_type):
        self.cfg = cfg
        self.name = name
        self.handler = handler
        self.length = length
        self.size = size
        self.abb = abb
        self.branch = branch
        self.after_scheduler = after_scheduler
        self.uid = Queue.uid_counter
        self.q_type = q_type
        Queue.uid_counter += 1
        FreeRTOS.malloc_heap(1, FreeRTOS.config.get('QUEUE_HEAD_SIZE', None), maybe=branch)
        FreeRTOS.malloc_heap(length, size, maybe=branch)

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
        FreeRTOS.malloc_heap(1, FreeRTOS.config.get('QUEUE_HEAD_SIZE', None), maybe=branch)

    def __repr__(self):
        return '<' + '|'.join([str((k,v)) for k,v in self.__dict__.items()]) + '>'


class FreeRTOS(OSBase):
    vertex_properties = [('label', 'string', 'instance name'),
                         ('obj', 'object', 'instance object (e.g. Task)')]
    edge_properties = [('label', 'string', 'syscall name')]

    @staticmethod
    def get_special_steps():
        return ["LoadFreeRTOSConfig"]

    @staticmethod
    def has_dynamic_instances():
        return True

    @staticmethod
    def init(state):
        for prop in FreeRTOS.vertex_properties:
            state.instances.vp[prop[0]] = state.instances.new_vp(prop[1])
        for prop in FreeRTOS.edge_properties:
            state.instances.ep[prop[0]] = state.instances.new_ep(prop[1])
        state.scheduler_on = False

    @staticmethod
    def interpret(cfg, abb, state, categories=SyscallCategory.every):
        syscall = cfg.get_syscall_name(abb)
        logger.debug(f"Get syscall: {syscall}, ABB: {cfg.vp.name[abb]}"
                     f" (in {cfg.vp.name[cfg.get_function(abb)]})")

        syscall_function = getattr(FreeRTOS, syscall)

        if isinstance(categories, SyscallCategory):
            categories = set((categories,))

        if SyscallCategory.every not in categories:
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
            if cfg.ep.type[oedge] == _graph.CFType.lcf:
                state.next_abbs.append(oedge.target())

    @staticmethod
    def malloc_heap(count, size, maybe=False):
        try:
            request = int(count) * int(size)
            used_sure = FreeRTOS.config.get('used_heap_sure', 0)
            used_maybe = FreeRTOS.config.get('used_heap_maybe', 0)
            used_maybe += request
            if not maybe:
                used_sure += request
            FreeRTOS.config['used_heap_sure'] = used_sure
            FreeRTOS.config['used_heap_maybe'] = used_maybe
            total = FreeRTOS.config.get('configTOTAL_HEAP_SIZE', None)
            total = total.get() if total else 0
            percent_sure = used_sure / total
            percent_maybe = used_maybe / total
            logger.debug("FreeRTOS heap usage sure: %05.2f%% (%5d / %5d)",
                         percent_sure*100, used_sure, total)
            logger.debug("FreeRTOS heap usage maybe: %05.2f%% (%5d / %5d)",
                         percent_maybe*100, used_maybe, total)
            if used_sure >= total:
                logger.error("FreeRTOS heap usage exceeds heap size: %s", percent_sure)
            if used_maybe >= total:
                logger.warning("FreeRTOS heap usage exceeds heap size: %s", percent_maybe)
        except Exception as e:
            logger.error("malloc failed: %05.2f%% (%5d / %5d)",
                         percent_sure*100, used_sure, total)
            raise e


    @syscall(categories={SyscallCategory.create},
             signature=(SigType.symbol, SigType.value, SigType.value,
                        SigType.symbol, SigType.value, SigType.symbol))
    def xTaskCreate(cfg, abb, state):
        state = state.copy()

        # instance properties
        cp = state.call_path

        p_get_argument = functools.partial(get_argument, cfg, abb, cp)

        task_function = p_get_argument(0, ty=pyllco.Function).get_name()
        task_name = p_get_argument(1)
        task_stack_size = p_get_argument(2)
        task_parameters = p_get_argument(3, raw_value=True)
        task_priority = p_get_argument(4)
        task_handle_p = p_get_argument(5, raw_value=True)

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

    @syscall(categories={SyscallCategory.create})
    def vTaskStartScheduler(cfg, abb, state):
        state = state.copy()

        v = state.instances.add_vertex()
        state.instances.vp.label[v] = '__idle_task'

        #TODO: get idle task priority from config: ( tskIDLE_PRIORITY | portPRIVILEGE_BIT )
        state.instances.vp.obj[v] = Task(cfg, None,
                                         function='prvIdleTask',
                                         name='idle_task',
                                         stack_size=int(FreeRTOS.config.get('configMINIMAL_STACK_SIZE', None)),
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

    @syscall(categories={SyscallCategory.create},
             signature=(SigType.value, SigType.value, SigType.value))
    def xQueueGenericCreate(cfg, abb, state):
        state = state.copy()

        # instance properties
        cp = state.call_path

        queue_handler = state.cfg.vp.arguments[abb].get_return_value()
        handler_name = queue_handler.get_value(raw=True).get_name()

        p_get_argument = functools.partial(get_argument, cfg, abb, cp)
        queue_len = p_get_argument(0)
        queue_item_size = p_get_argument(1)
        q_type = p_get_argument(2)

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
                                          after_scheduler=state.scheduler_on,
                                          q_type=q_type,
        )
        state.next_abbs = []
        FreeRTOS.add_normal_cfg(cfg, abb, state)
        return state

    @syscall(categories={SyscallCategory.create},
             signature=(SigType.value,))
    def xQueueCreateMutex(cfg, abb, state):
        state = state.copy()
        # instance properties
        cp = state.call_path
        mutex_handler = state.cfg.vp.arguments[abb].get_return_value()
        handler_name = mutex_handler.get_value(raw=True).get_name()

        mutex_type = get_argument(cfg, abb, cp, 0)

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

    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.value,))
    def vTaskDelay(cfg, abb, state):
        state = state.copy()

        cp = state.call_path
        ticks = get_argument(cfg, abb, cp, 0)

        if state.running is None:
            # TODO proper error handling
            logger.error("ERROR: vTaskDelay called without running Task")

        e = state.instances.add_edge(state.running, state.running)
        state.instances.ep.label[e] = f"vTaskDelay({ticks})"

        state.next_abbs = []
        FreeRTOS.add_normal_cfg(cfg, abb, state)
        return state

    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.value, SigType.value,
                        SigType.value))
    def xQueueGenericSend(cfg, abb, state):
        state = state.copy()

        cp = state.call_path
        p_get_argument = functools.partial(get_argument, cfg, abb, cp)

        handler = p_get_argument(0, raw=True)

        # TODO this has to be a pointer object. However, the value analysis
        # follows the pointer currently.
        item = p_get_argument(1, raw=True)
        ticks = p_get_argument(2)
        action = p_get_argument(3)

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

    @syscall(categories={SyscallCategory.comm},
             signature=(SigType.symbol, SigType.value))
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

    @syscall(categories={SyscallCategory.create},
             signature=(SigType.symbol, SigType.value, SigType.value,
                        SigType.symbol, SigType.value, SigType.symbol,
                        SigType.symbol))
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
