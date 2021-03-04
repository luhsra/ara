from .os_util import syscall, assign_id, Arg
from .os_base import OSBase

import pyllco
import functools
import html

import ara.graph as _graph
from ara.graph import CallPath, SyscallCategory, SigType
from ara.util import get_logger
from ara.steps.util import current_step

logger = get_logger("FreeRTOS")

# TODO make this a dataclass once we use Python 3.7
class FreeRTOSInstance(object):
    def __init__(self, cfg, abb, call_path, vidx, name):
        self.cfg = cfg
        self.abb = abb
        self.call_path = call_path
        self.vidx = vidx
        self.name = name
        self.heap_need = 0

    def __getattr__(self, name):
        try:
            return self.__dict__[name]
        except KeyError as ke:
            return current_step._graph.instances.vp[name][self.vidx]
    def __setattr__(self, name, value):
        if name in current_step._graph.instances.vp:
            current_step._graph.instances.vp[name][self.vidx] = value
        else:
            self.__dict__[name] = value

    def __repr__(self):
        attrs = ', '.join([f"{k}={repr(v)}" for k,v in self.__dict__.items()])
        return f"{type(self).__name__}({attrs})"

    def heap_decline(self):
        if self.specialization_level in ['static', 'initialized']:
            return self.heap_need
        return 0

    def heap_usage_maybe(self):
        if not self.unique:
            return self.heap_need or 0
        return 0

    def heap_usage_sure(self):
        if self.unique:
            return self.heap_need
        return 0


    @property
    def uid(self):
        return int(self.vidx)



class Task(FreeRTOSInstance):
    uid_counter = 0
    def __init__(self, cfg, entry_abb, name, function, stack_size, parameters,
                 vidx,
                 priority, handle_p, call_path, abb, is_regular=True,
                 static_stack=None):
        super().__init__(cfg, abb, call_path, vidx, name)
        self.entry_abb = entry_abb
        self.function = function
        self.stack_size = stack_size
        self.parameters = parameters
        self.__priority = priority
        self.handle_p = handle_p
        self.is_regular = is_regular
        self.uid = Task.uid_counter
        self.static_stack = static_stack
        Task.uid_counter += 1
        if static_stack is None:
            try:
                self.heap_need += int(stack_size) * int(FreeRTOS.config.get('STACK_TYPE_SIZE', None))
                self.heap_need += int(FreeRTOS.config.get('TCB_SIZE', None))
            except TypeError:
                self.heap_need = None
        else:
            self.heap_need = 0


    @property
    def priority(self):
        if self.__priority is None:
            return None
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

    def as_dot(self):
        wanted_attrs = ["name", "function", "stack_size", "parameters",
                        "priority", "handle_p", "is_regular"]
        attrs = [(x, str(getattr(self, x))) for x in wanted_attrs]
        sublabel = '<br/>'.join([f"<i>{k}</i>: {html.escape(v)}"
                                 for k, v in attrs])

        return {
            "shape": "box",
            "fillcolor": "#6fbf87",
            "style": "filled",
            "sublabel": sublabel
        }

    def get_maximal_id(self):
        print(self.handle_p)
        handler_name = self.handle_p.get_name() if self.handle_p else "-"
        return '.'.join(map(str, ["Task",
                                  self.name,
                                  self.function,
                                  self.priority,
                                  self.stack_size,
                                  self.is_regular,
                                  self.cfg.vp.name[self.abb],
                                  handler_name,
                                  self.parameters,
                                  self.call_path.print(call_site=True)]))


# TODO make this a dataclass once we use Python 3.7
class Queue(FreeRTOSInstance):
    uid_counter = 0
    def __init__(self, cfg, name, handler, length, size, abb, q_type,
                 call_path, vidx):
        super().__init__(cfg, abb, call_path, vidx, name)
        self.handler = handler
        self.length = length
        self.size = size
        self.uid = Queue.uid_counter
        self.q_type = q_type
        self.call_path = call_path
        Queue.uid_counter += 1
        try:
            self.heap_need +=  int(FreeRTOS.config.get('QUEUE_HEAD_SIZE', None))
            self.heap_need += int(length) * int(size)
        except TypeError:
            self.heap_need = None

    def __repr__(self):
        return '<' + '|'.join([str((k,v)) for k,v in self.__dict__.items()]) + '>'

    def as_dot(self):
        wanted_attrs = ["name", "handler", "length", "size"]
        attrs = [(x, str(getattr(self, x))) for x in wanted_attrs]
        sublabel = '<br/>'.join([f"<i>{k}</i>: {html.escape(v)}"
                                 for k, v in attrs])

        return {
            "shape": "box",
            "fillcolor": "#fdbb9b",
            "style": "filled",
            "sublabel": sublabel
        }

    def get_maximal_id(self):
        return '.'.join(map(str, ["Queue",
                                  self.name,
                                  self.length,
                                  self.size,
                                  self.handler,
                                  self.call_path.print(call_site=True)]))


# TODO make this a dataclass once we use Python 3.7
class Mutex(FreeRTOSInstance):
    uid_counter = 0
    def __init__(self, cfg, name, handler, m_type, abb, call_path, vidx):
        super().__init__(cfg, abb, call_path, vidx, name)
        self.handler = handler
        self.m_type = m_type
        self.uid = Queue.uid_counter
        self.size = 0
        self.length = 1
        self.call_path = call_path
        Mutex.uid_counter += 1
        try:
            self.heap_need += int(FreeRTOS.config.get('QUEUE_HEAD_SIZE', None))
        except TypeError:
            self.heap_need = None

    def __repr__(self):
        return '<' + '|'.join([str((k,v)) for k,v in self.__dict__.items()]) + '>'

    def as_dot(self):
        wanted_attrs = ["name", "handler", "m_type"]
        attrs = [(x, str(getattr(self, x))) for x in wanted_attrs]
        sublabel = '<br/>'.join([f"<i>{k}</i>: {html.escape(v)}"
                                 for k, v in attrs])

        return {
            "shape": "box",
            "fillcolor": "#fdbb9b",
            "style": "filled",
            "sublabel": sublabel
        }

    def get_maximal_id(self):
        return '.'.join(map(str, ["Mutex",
                                  self.name,
                                  self.m_type,
                                  self.handler,
                                  self.call_path.print(call_site=True)]))

class StreamBuffer(FreeRTOSInstance):
    def __init__(self, cfg, abb, call_path, vidx, handler, name, size):
        super().__init__(cfg, abb, call_path, vidx, name)
        self.size = size
        self.handler = handler
    def as_dot(self):
        wanted_attrs = ["name", "handler", "size"]
        attrs = [(x, str(getattr(self, x))) for x in wanted_attrs]
        sublabel = '<br/>'.join([f"<i>{k}</i>: {html.escape(v)}"
                                 for k, v in attrs])

        return {
            "shape": "box",
            "fillcolor": "#fd0b9b",
            "style": "filled",
            "sublabel": sublabel
        }
    def get_maximal_id(self):
        return '.'.join(map(str, ["StreamBuffer",
                                  self.name,
                                  self.size,
                                  self.handler,
                                  self.call_path.print(call_site=True)]))


class FreeRTOS(OSBase):
    @staticmethod
    def get_special_steps():
        from ara.steps import get_native_component
        ValueAnalyzer = get_native_component("ValueAnalyzer")
        return ValueAnalyzer.get_dependencies() + ["LoadFreeRTOSConfig"]

    @staticmethod
    def has_dynamic_instances():
        return True

    @staticmethod
    def init(state):
        state.scheduler_on = False

    @staticmethod
    def interpret(graph, abb, state, categories=SyscallCategory.every):
        cfg = graph.cfg
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
        return getattr(FreeRTOS, syscall)(graph, abb, state)

    @staticmethod
    def add_normal_cfg(cfg, abb, state):
        for oedge in cfg.vertex(abb).out_edges():
            if cfg.ep.type[oedge] == _graph.CFType.lcf:
                state.next_abbs.append(oedge.target())

    @staticmethod
    def total_heap_size():
        return int(FreeRTOS.config.get('configTOTAL_HEAP_SIZE', None))

    def handle_soc(state, v, cfg, abb,
                   branch=None, loop=None, recursive=None, scheduler_on=None,
                   usually_taken=None):
        instances = state.instances

        def b(c1, c2):
            if c2 is None:
                return c1
            else:
                return c2

        in_branch = b(state.branch, branch)
        in_loop = b(state.loop, loop)
        is_recursive = b(state.recursive, recursive)
        after_sched = b(state.scheduler_on, scheduler_on)
        is_usually_taken = b(state.usually_taken, usually_taken)

        instances.vp.branch[v] = in_branch
        instances.vp.loop[v] = in_loop
        instances.vp.recursive[v] = is_recursive
        instances.vp.after_scheduler[v] = after_sched
        instances.vp.usually_taken[v] = is_usually_taken
        instances.vp.unique[v] = not (is_recursive or in_branch or in_loop)
        instances.vp.soc[v] = abb
        instances.vp.llvm_soc[v] = cfg.vp.llvm_link[cfg.get_single_bb(abb)]
        instances.vp.file[v] = cfg.vp.file[abb]
        instances.vp.line[v] = cfg.vp.line[abb]


    @syscall(categories={SyscallCategory.create},
             signature=(Arg("task_function", hint=SigType.symbol, ty=pyllco.Function),
                        Arg("task_name"),
                        Arg("task_stack_size"),
                        Arg("task_parameters", hint=SigType.symbol),
                        Arg("task_priority"),
                        Arg("task_handle_p", hint=SigType.instance)))
    def xTaskCreate(graph, abb, state, args, va):
        state = state.copy()

        v = state.instances.add_vertex()
        func_name = args.task_function.get_name()
        state.instances.vp.label[v] = f"Task: {args.task_name} ({func_name})"

        new_cfg = graph.cfg.get_entry_abb(graph.cfg.get_function_by_name(func_name))
        assert new_cfg is not None
        # TODO: when do we know that this is an unique instance?
        FreeRTOS.handle_soc(state, v, graph.cfg, abb)
        state.instances.vp.obj[v] = Task(graph.cfg, new_cfg,
                                         vidx=v,
                                         function=func_name,
                                         name=args.task_name,
                                         stack_size=args.task_stack_size,
                                         parameters=args.task_parameters,
                                         priority=args.task_priority,
                                         handle_p=args.task_handle_p,
                                         call_path=state.call_path,
                                         abb=abb,
        )

        args.task_handle_p = state.instances.vp.obj[v]

        assign_id(state.instances, v)

        logger.info(f"Create new Task {args.task_name} (function: {func_name})")
        return state

    @syscall(categories={SyscallCategory.create}, custom_control_flow=True)
    def vTaskStartScheduler(graph, abb, state, args, va):
        v = state.instances.add_vertex()
        state.instances.vp.label[v] = '__idle_task'

        #TODO: get idle task priority from config: ( tskIDLE_PRIORITY | portPRIVILEGE_BIT )
        FreeRTOS.handle_soc(state, v, graph.cfg, abb, scheduler_on=False)
        state.instances.vp.obj[v] = Task(graph.cfg, None,
                                         function='prvIdleTask',
                                         name='idle_task',
                                         vidx=v,
                                         stack_size=int(FreeRTOS.config.get('configMINIMAL_STACK_SIZE', None)),
                                         parameters=0,
                                         priority=0,
                                         handle_p=0,
                                         call_path=state.call_path,
                                         abb=abb,
                                         is_regular=False)

        assign_id(state.instances, v)

        # this syscall is an exit node
        state.scheduler_on = True
        return state

    @syscall(categories={SyscallCategory.create},
             signature=(Arg("queue_len"),
                        Arg("queue_item_size"),
                        Arg("q_type")))
    def XQueueGenericCreate(graph, abb, state, args, va):
        state = state.copy()

        # instance properties
        cp = state.call_path

        queue_handler = va.get_return_value(abb, callpath=cp)
        handler_name = queue_handler.get_name()

        v = state.instances.add_vertex()
        state.instances.vp.label[v] = f"Queue: {handler_name}"
        FreeRTOS.handle_soc(state, v, cfg, abb)

        # TODO: when do we know that this is an unique instance?
        state.instances.vp.obj[v] = Queue(cfg,
                                          vidx=v,
                                          name=handler_name,
                                          handler=queue_handler,
                                          length=args.queue_len,
                                          size=args.queue_item_size,
                                          abb=abb,
                                          q_type=args.q_type,
                                          call_path=cp,
        )

        assign_id(state.instances, v)

        return state

    @syscall(categories={SyscallCategory.create},
             signature=(Arg("mutex_type"),))
    def xQueueCreateMutex(graph, abb, state, args, va):
        state = state.copy()
        # instance properties
        cp = state.call_path
        cfg = graph.cfg

        ret_val = va.get_return_value(abb, cp)
        handler_name = ret_val.get_name()

        v = state.instances.add_vertex()
        state.instances.vp.label[v] = f"Mutex: {handler_name}"
        FreeRTOS.handle_soc(state, v, cfg, abb)

        state.instances.vp.obj[v] = Mutex(cfg,
                                          name=handler_name,
                                          handler=ret_val,
                                          m_type=args.mutex_type,
                                          abb=abb,
                                          call_path=cp,
                                          vidx=v,
        )

        assign_id(state.instances, v)

        va.assign_system_object(abb, state.instances.vp.obj[v], callpath=cp)

        return state

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("ticks"),))
    def vTaskDelay(graph, abb, state, args, va):
        state = state.copy()

        cp = state.call_path

        if state.running is None:
            # TODO proper error handling
            logger.error("ERROR: vTaskDelay called without running Task")

        e = state.instances.add_edge(state.running, state.running)
        state.instances.ep.label[e] = f"vTaskDelay({args.ticks})"

        return state

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg('handler'),
                        Arg('item', raw_value=True),
                        Arg('ticks'),
                        Arg('action')))
    def xQueueGenericSend(graph, abb, state, args, va):
        state = state.copy()

        cp = state.call_path

        queue = args.handler
        if queue is None:
            logger.error(f"xQueueGenericSend (file: {cfg.vp.file[abb]}, "
                         f"line: {cfg.vp.line[abb]}): Queue handler cannot be "
                         "found. Ignoring syscall.")
        else:
            e = state.instances.add_edge(state.running, queue)
            state.instances.ep.label[e] = f"xQueueGenericSend"

        return state

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg('handler'),
                        Arg('type')))
    def xQueueSemaphoreTake(cfg, abb, state):
        state = state.copy()

        cp = state.call_path

        queue = args.handler
        if queue is None:
            logger.error(f"xQueueSemaphoreTake (file: {cfg.vp.file[abb]}, "
                         f"line: {cfg.vp.line[abb]}): Queue handler cannot be "
                         "found. Ignoring syscall.")
        else:
            e = state.instances.add_edge(state.running, queue)
            state.instances.ep.label[e] = f"xQueueSemaphoreTake"

        return state


    @syscall(categories={SyscallCategory.create},
             signature=(Arg("task_function", hint=SigType.symbol, ty=pyllco.Function),
                        Arg("task_name"),
                        Arg("task_stack_size"),
                        Arg("task_parameters", hint=SigType.symbol),
                        Arg("task_priority"),
                        Arg("task_stack", hint=SigType.symbol),
                        Arg("task_handle_p", hint=SigType.instance)))
    def xTaskCreateStatic(graph, abb, state, args, va):
        state = state.copy()
        cfg = graph.cfg

        # instance properties
        cp = state.call_path

        task_handler = va.get_return_value(abb, callpath=cp)

        v = state.instances.add_vertex()
        func_name = args.task_function.get_name()
        state.instances.vp.label[v] = f"Task: {args.task_name} ({func_name})"

        new_cfg = cfg.get_entry_abb(
            cfg.get_function_by_name(func_name)
        )
        assert new_cfg is not None
        # TODO: when do we know that this is an unique instance?
        FreeRTOS.handle_soc(state, v, cfg, abb)
        state.instances.vp.obj[v] = Task(cfg, new_cfg,
                                         vidx=v,
                                         function=func_name,
                                         name=args.task_name,
                                         stack_size=args.task_stack_size,
                                         parameters=args.task_parameters,
                                         priority=args.task_priority,
                                         handle_p=task_handler,
                                         call_path=cp,
                                         abb=abb,
                                         static_stack=args.task_stack,
        )

        assign_id(state.instances, v)
        va.assign_system_object(abb, state.instances.vp.obj[v], callpath=cp)

        logger.info(f"Create new Task {args.task_name} (function: {func_name})")
        return state
        pass


    @syscall(categories={SyscallCategory.comm},
             signature=(Arg('handler'), Arg('type')))
    def xQueueTakeMutexRecursive(graph, abb, state, args, va):
        pass


    @syscall(categories={SyscallCategory.create}, signature=(Arg("size"),))
    def xStreamBufferGenericCreate(graph, abb, state, args, va):
        state = state.copy()
        cfg = graph.cfg
        cp = state.call_path

        handler = va.get_return_value(abb, callpath=cp)
        handler_name = handler.get_name()

        v = state.instances.add_vertex()
        state.instances.vp.label[v] = f"StreamBuffer: {handler_name}"
        FreeRTOS.handle_soc(state, v, cfg, abb)

        state.instances.vp.obj[v] = StreamBuffer(cfg,
                                                 abb=abb,
                                                 call_path=cp,
                                                 vidx=v,
                                                 handler=handler,
                                                 name=handler_name,
                                                 size=args.size,
        )
        assign_id(state.instances, v)

        va.assign_system_object(abb, state.instances.vp.obj[v], callpath=cp)

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
        logger.warn("Got an vEventGroupDelete. Deleting a potientially static EventGroup.")

    @syscall
    def vQueueAddToRegistry(cfg, abb, state):
        pass

    @syscall
    def vQueueDelete(cfg, abb, state):
        logger.warn("Got an vQueueDelete. Deleting a potientially static Queue.")

    @syscall
    def vSemaphoreCreateBinary(cfg, abb, state):
        pass

    @syscall
    def vStreamBufferDelete(cfg, abb, state):
        logger.warn("Got an vStreamBufferDelete. Deleting a potientially static StreamBuffer.")

    @syscall
    def vTaskAllocateMPURegions(cfg, abb, state):
        pass

    @syscall
    def vTaskDelayUntil(cfg, abb, state):
        pass

    @syscall
    def vTaskDelete(cfg, abb, state):
        logger.warn("Got an vTaskDelete. Deleting a potientially static Task.")

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
