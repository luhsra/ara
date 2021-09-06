from .os_util import syscall, assign_id, Arg, find_return_value, UnknownArgument
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
            try:
                return current_step._graph.instances.vp[name][self.vidx]
            except KeyError as ke:
                raise AttributeError

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
    never_deleted = True
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
            except (TypeError, ValueError):
                self.heap_need = None
        else:
            self.heap_need = 0


    @property
    def priority(self):
        if self.__priority is None or isinstance(self.__priority, UnknownArgument):
            return None
        clamp = FreeRTOS.config.get('configMAX_PRIORITIES', None)
        if clamp is not None:
            clamp = clamp.get()
            try:
                prio = int(self.__priority)
            except ValueError:
                logger.warning("Task %s priority is not statically assigned (was %s)",
                                self.name, self.__priority)
                return self.__priority
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
        handler_name = self.handle_p.value.get_name() if self.handle_p else "-"
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
    never_deleted = True
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
    never_deleted = True
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
    never_deleted = True
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


def find_instance_node(instances, obj):
    for ins in instances.vertices():
        if instances.vp.obj[ins] is obj:
            return ins
    raise RuntimeError("Instance could not be found.")


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
        cp = state.call_path

        v = state.instances.add_vertex()
        func_name = args.task_function.get_name()
        state.instances.vp.label[v] = f"Task: {args.task_name} ({func_name})"

        #check if task_parameters is call path independent
        if args.task_parameters.value and args.task_parameters.callpath is None:
            task_parameters = args.task_parameters.value
        else:
            task_parameters = args.task_parameters

        entry = graph.cfg.get_entry_abb(graph.cfg.get_function_by_name(func_name))
        assert entry is not None
        # TODO: when do we know that this is an unique instance?
        FreeRTOS.handle_soc(state, v, graph.cfg, abb)
        state.instances.vp.obj[v] = Task(graph.cfg, entry,
                                         vidx=v,
                                         function=func_name,
                                         name=args.task_name,
                                         stack_size=args.task_stack_size,
                                         parameters=task_parameters,
                                         priority=args.task_priority,
                                         handle_p=args.task_handle_p,
                                         call_path=cp,
                                         abb=graph.cfg.vertex(abb),
        )
        if args.task_handle_p:
            va.assign_system_object(args.task_handle_p.value,
                                    state.instances.vp.obj[v],
                                    args.task_handle_p.offset,
                                    args.task_handle_p.callpath)
        else:
            logger.warn(f"Task for ABB {graph.cfg.vp.name[abb]} not assigned,"
                        f" since the task handle cannot be retrieved.")

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
                                         abb=graph.cfg.vertex(abb),
                                         is_regular=False)
        graph.os.idle_task = state.instances.vp.obj[v]

        assign_id(state.instances, v)

        # this syscall is an exit node
        state.scheduler_on = True
        return state

    @syscall(categories={SyscallCategory.create},
             signature=(Arg("queue_len"),
                        Arg("queue_item_size"),
                        Arg("q_type")))
    def xQueueGenericCreate(graph, abb, state, args, va):
        state = state.copy()

        # instance properties
        cp = state.call_path
        cfg = graph.cfg

        queue_handler = find_return_value(abb, cp, va)
        assert isinstance(queue_handler.value, pyllco.Value)
        handler_name = queue_handler.value.get_name()

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

        va.assign_system_object(queue_handler.value,
                                state.instances.vp.obj[v],
                                queue_handler.offset,
                                queue_handler.callpath)

        return state

    @syscall(categories={SyscallCategory.create},
             signature=(Arg("mutex_type"),))
    def xQueueCreateMutex(graph, abb, state, args, va):
        state = state.copy()
        # instance properties
        cp = state.call_path
        cfg = graph.cfg

        ret_val = find_return_value(abb, cp, va)
        handler_name = ret_val.value.get_name()

        v = state.instances.add_vertex()
        state.instances.vp.label[v] = f"Mutex: {handler_name}"
        FreeRTOS.handle_soc(state, v, cfg, abb)

        state.instances.vp.obj[v] = Mutex(cfg,
                                          name=handler_name,
                                          handler=ret_val,
                                          m_type=args.mutex_type,
                                          abb=abb,
                                          call_path=cp,
                                          vidx=v)

        logger.info(f"Create new Mutex {handler_name}")

        assign_id(state.instances, v)

        va.assign_system_object(ret_val.value,
                                state.instances.vp.obj[v],
                                ret_val.offset,
                                ret_val.callpath)


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
             signature=(Arg('handler', ty=Mutex, hint=SigType.instance),
                        Arg('item', raw_value=True),
                        Arg('ticks'),
                        Arg('action')))
    def xQueueGenericSend(graph, abb, state, args, va):
        state = state.copy()

        queue = args.handler
        if not queue:
            logger.error(f"xQueueGenericSend (file: {cfg.vp.file[abb]}, "
                         f"line: {cfg.vp.line[abb]}): Queue handler cannot be "
                         "found. Ignoring syscall.")
        else:
            queue_node = find_instance_node(state.instances, queue.value)
            e = state.instances.add_edge(state.running, queue_node)
            state.instances.ep.label[e] = f"xQueueGenericSend"

        return state

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg('handler', ty=Mutex, hint=SigType.instance),
                        Arg('type')))
    def xQueueSemaphoreTake(graph, abb, state, args, va):
        state = state.copy()

        queue = args.handler
        if not queue:
            logger.error(f"xQueueSemaphoreTake (file: {cfg.vp.file[abb]}, "
                         f"line: {cfg.vp.line[abb]}): Queue handler cannot be "
                         "found. Ignoring syscall.")
        else:
            queue_node = find_instance_node(state.instances, queue.value)
            e = state.instances.add_edge(state.running, queue_node)
            state.instances.ep.label[e] = "xQueueSemaphoreTake"

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

        task_handler = find_return_value(abb, cp, va)

        v = state.instances.add_vertex()
        func_name = args.task_function.get_name()
        state.instances.vp.label[v] = f"Task: {args.task_name} ({func_name})"

        #check if task_parameters is call path independent
        if args.task_parameters.value and args.task_parameters.callpath is None:
            task_parameters = args.task_parameters.value
        else:
            task_parameters = args.task_parameters

        entry = cfg.get_entry_abb(
            cfg.get_function_by_name(func_name)
        )
        assert entry is not None
        # TODO: when do we know that this is an unique instance?
        FreeRTOS.handle_soc(state, v, cfg, abb)
        state.instances.vp.obj[v] = Task(cfg, entry,
                                         vidx=v,
                                         function=func_name,
                                         name=args.task_name,
                                         stack_size=args.task_stack_size,
                                         parameters=task_parameters,
                                         priority=args.task_priority,
                                         handle_p=task_handler,
                                         call_path=cp,
                                         abb=cfg.vertex(abb),
                                         static_stack=args.task_stack,
        )

        assign_id(state.instances, v)
        if args.task_handle_p:
            va.assign_system_object(args.task_handle_p.value,
                                    state.instances.vp.obj[v],
                                    args.task_handle_p.offset,
                                    args.task_handle_p.callpath)
        else:
            logger.warn(f"Task for ABB {graph.cfg.vp.name[abb]} not assigned,"
                        f" since the task handle cannot be retrieved.")

        logger.info(f"Create new Task {args.task_name} (function: {func_name}) (parameters: {args.task_parameters})")
        return state

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg('handler'), Arg('type')))
    def xQueueTakeMutexRecursive(graph, abb, state, args, va):
        pass

    @syscall(categories={SyscallCategory.create}, signature=(Arg("size"),))
    def xStreamBufferGenericCreate(graph, abb, state, args, va):
        state = state.copy()
        cfg = graph.cfg
        cp = state.call_path

        handler = find_return_value(abb, cp, va)
        handler_name = handler.value.get_name()

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

        va.assign_system_object(handler.value,
                                state.instances.vp.obj[v],
                                handler.offset,
                                handler.callpath)

        return state

    # HERE BEGINS THE TODO sections, all following syscalls are stubs

    @syscall
    def eTaskGetState(graph, abb, state, args, va):
        pass

    @syscall
    def pcQueueGetName(graph, abb, state, args, va):
        pass

    @syscall
    def pcTaskGetName(graph, abb, state, args, va):
        pass

    @syscall
    def pcTimerGetName(graph, abb, state, args, va):
        pass

    @syscall
    def portDISABLE_INTERRUPTS(graph, abb, state, args, va):
        pass

    @syscall
    def portENABLE_INTERRUPTS(graph, abb, state, args, va):
        pass

    @syscall
    def portSET_INTERRUPT_MASK_FROM_ISR(graph, abb, state, args, va):
        pass

    @syscall
    def portYIELD(graph, abb, state, args, va):
        pass

    @syscall
    def pvTaskGetThreadLocalStoragePointer(graph, abb, state, args, va):
        pass

    @syscall
    def pvTimerGetTimerID(graph, abb, state, args, va):
        pass

    @syscall
    def ulTaskNotifyTake(graph, abb, state, args, va):
        pass

    @syscall
    def uxQueueMessagesWaiting(graph, abb, state, args, va):
        pass

    @syscall
    def uxQueueMessagesWaitingFromISR(graph, abb, state, args, va):
        pass

    @syscall
    def uxQueueSpacesAvailable(graph, abb, state, args, va):
        pass

    @syscall
    def uxTaskGetNumberOfTasks(graph, abb, state, args, va):
        pass

    @syscall
    def uxTaskGetStackHighWaterMark(graph, abb, state, args, va):
        pass

    @syscall
    def uxTaskGetSystemState(graph, abb, state, args, va):
        pass

    @syscall
    def uxTaskPriorityGet(graph, abb, state, args, va):
        pass

    @syscall
    def vCoRoutineSchedule(graph, abb, state, args, va):
        pass

    @syscall
    def vEventGroupDelete(graph, abb, state, args, va):
        logger.warn("Got an vEventGroupDelete. Deleting a potientially static EventGroup.")

    @syscall
    def vQueueAddToRegistry(graph, abb, state, args, va):
        pass

    @syscall
    def vQueueDelete(graph, abb, state, args, va):
        Queue.never_deleted = False
        Mutex.never_deleted = False
        logger.warn("Got an vQueueDelete. Deleting a potientially static Queue.")

    @syscall
    def vSemaphoreCreateBinary(graph, abb, state, args, va):
        pass

    @syscall
    def vStreamBufferDelete(graph, abb, state, args, va):
        StreamBuffer.never_deleted = False
        logger.warn("Got an vStreamBufferDelete. Deleting a potientially static StreamBuffer.")

    @syscall
    def vTaskAllocateMPURegions(graph, abb, state, args, va):
        pass

    @syscall
    def vTaskDelayUntil(graph, abb, state, args, va):
        pass

    @syscall
    def vTaskDelete(graph, abb, state, args, va):
        Task.never_deleted = False
        logger.warn("Got an vTaskDelete. Deleting a potientially static Task.")

    @syscall
    def vTaskEnterCritical(graph, abb, state, args, va):
        pass

    @syscall
    def vTaskExitCritical(graph, abb, state, args, va):
        pass

    @syscall
    def vTaskGetRunTimeStats(graph, abb, state, args, va):
        pass

    @syscall
    def vTaskList(graph, abb, state, args, va):
        pass

    @syscall
    def vTaskNotifyGiveFromISR(graph, abb, state, args, va):
        pass

    @syscall
    def vTaskPrioritySet(graph, abb, state, args, va):
        pass

    @syscall
    def vTaskResume(graph, abb, state, args, va):
        pass

    @syscall
    def vTaskSetApplicationTaskTag(graph, abb, state, args, va):
        pass

    @syscall
    def vTaskSetThreadLocalStoragePointer(graph, abb, state, args, va):
        pass

    @syscall
    def vTaskSetTimeOutState(graph, abb, state, args, va):
        pass

    @syscall
    def vTaskStepTick(graph, abb, state, args, va):
        pass

    @syscall
    def vTaskSuspend(graph, abb, state, args, va):
        pass

    @syscall
    def vTaskSuspendAll(graph, abb, state, args, va):
        pass

    @syscall
    def vTimerSetTimerID(graph, abb, state, args, va):
        pass

    @syscall
    def xCoRoutineCreate(graph, abb, state, args, va):
        pass

    @syscall
    def xEventGroupClearBits(graph, abb, state, args, va):
        pass

    @syscall
    def xEventGroupClearBitsFromISR(graph, abb, state, args, va):
        pass

    @syscall
    def xEventGroupCreate(graph, abb, state, args, va):
        pass

    @syscall
    def xEventGroupCreateStatic(graph, abb, state, args, va):
        pass

    @syscall
    def xEventGroupGetBitsFromISR(graph, abb, state, args, va):
        pass

    @syscall
    def xEventGroupSetBits(graph, abb, state, args, va):
        pass

    @syscall
    def xEventGroupSetBitsFromISR(graph, abb, state, args, va):
        pass

    @syscall
    def xEventGroupSync(graph, abb, state, args, va):
        pass

    @syscall
    def xEventGroupWaitBits(graph, abb, state, args, va):
        pass

    @syscall
    def xMessageBufferCreateStatic(graph, abb, state, args, va):
        pass

    @syscall
    def xQueueAddToSet(graph, abb, state, args, va):
        pass

    @syscall
    def xQueueCreateCountingSemaphore(graph, abb, state, args, va):
        pass

    @syscall
    def xQueueCreateSet(graph, abb, state, args, va):
        pass

    @syscall
    def xQueueCreateStatic(graph, abb, state, args, va):
        pass

    @syscall
    def xQueueGenericSendFromISR(graph, abb, state, args, va):
        pass

    @syscall
    def xQueueGetMutexHolder(graph, abb, state, args, va):
        pass

    @syscall
    def xQueueGetMutexHolderFromISR(graph, abb, state, args, va):
        pass

    @syscall
    def xQueueGiveFromISR(graph, abb, state, args, va):
        pass

    @syscall
    def xQueueGiveMutexRecursive(graph, abb, state, args, va):
        pass

    @syscall
    def xQueueIsQueueEmptyFromISR(graph, abb, state, args, va):
        pass

    @syscall
    def xQueueIsQueueFullFromISR(graph, abb, state, args, va):
        pass

    @syscall
    def xQueuePeek(graph, abb, state, args, va):
        pass

    @syscall
    def xQueuePeekFromISR(graph, abb, state, args, va):
        pass

    @syscall
    def xQueueReceive(graph, abb, state, args, va):
        pass

    @syscall
    def xQueueReceiveFromISR(graph, abb, state, args, va):
        pass

    @syscall
    def xQueueRemoveFromSet(graph, abb, state, args, va):
        pass

    @syscall
    def xQueueReset(graph, abb, state, args, va):
        pass

    @syscall
    def xQueueSelectFromSet(graph, abb, state, args, va):
        pass

    @syscall
    def xQueueSelectFromSetFromISR(graph, abb, state, args, va):
        pass

    @syscall
    def xSemaphoreCreateBinary(graph, abb, state, args, va):
        pass

    @syscall
    def xSemaphoreCreateBinaryStatic(graph, abb, state, args, va):
        pass

    @syscall
    def xSemaphoreCreateCountingStatic(graph, abb, state, args, va):
        pass

    @syscall
    def xSemaphoreCreateMutexStatic(graph, abb, state, args, va):
        pass

    @syscall
    def xSemaphoreCreateRecursiveMutex(graph, abb, state, args, va):
        pass

    @syscall
    def xSemaphoreCreateRecursiveMutexStatic(graph, abb, state, args, va):
        pass

    @syscall
    def xStreamBufferBytesAvailable(graph, abb, state, args, va):
        pass

    @syscall
    def xStreamBufferCreateStatic(graph, abb, state, args, va):
        pass

    @syscall
    def xStreamBufferIsEmpty(graph, abb, state, args, va):
        pass

    @syscall
    def xStreamBufferIsFull(graph, abb, state, args, va):
        pass

    @syscall
    def xStreamBufferReceive(graph, abb, state, args, va):
        pass

    @syscall
    def xStreamBufferReceiveFromISR(graph, abb, state, args, va):
        pass

    @syscall
    def xStreamBufferReset(graph, abb, state, args, va):
        pass

    @syscall
    def xStreamBufferResetFromISR(graph, abb, state, args, va):
        pass

    @syscall
    def xStreamBufferSend(graph, abb, state, args, va):
        pass

    @syscall
    def xStreamBufferSendFromISR(graph, abb, state, args, va):
        pass

    @syscall
    def xStreamBufferSetTriggerLevel(graph, abb, state, args, va):
        pass

    @syscall
    def xStreamBufferSpacesAvailable(graph, abb, state, args, va):
        pass

    @syscall
    def xTaskAbortDelay(graph, abb, state, args, va):
        pass

    @syscall
    def xTaskCallApplicationTaskHook(graph, abb, state, args, va):
        pass

    @syscall
    def xTaskCheckForTimeOut(graph, abb, state, args, va):
        pass

    @syscall
    def xTaskCreateRestricted(graph, abb, state, args, va):
        pass

    @syscall
    def xTaskGetApplicationTaskTag(graph, abb, state, args, va):
        pass

    @syscall
    def xTaskGetCurrentTaskHandle(graph, abb, state, args, va):
        pass

    @syscall
    def xTaskGetHandle(graph, abb, state, args, va):
        pass

    @syscall
    def xTaskGetIdleTaskHandle(graph, abb, state, args, va):
        pass

    @syscall
    def xTaskGetTickCount(graph, abb, state, args, va):
        pass

    @syscall
    def xTaskGetTickCountFromISR(graph, abb, state, args, va):
        pass

    @syscall
    def xTaskNotifyStateClear(graph, abb, state, args, va):
        pass

    @syscall
    def xTaskResumeAll(graph, abb, state, args, va):
        pass

    @syscall
    def xTaskResumeFromISR(graph, abb, state, args, va):
        pass

    @syscall
    def xTimerCreate(graph, abb, state, args, va):
        pass

    @syscall
    def xTimerCreateStatic(graph, abb, state, args, va):
        pass

    @syscall
    def xTimerGenericCommand(graph, abb, state, args, va):
        pass

    @syscall
    def xTimerGetExpiryTime(graph, abb, state, args, va):
        pass

    @syscall
    def xTimerGetPeriod(graph, abb, state, args, va):
        pass

    @syscall
    def xTimerGetTimerDaemonTaskHandle(graph, abb, state, args, va):
        pass

    @syscall
    def xTimerIsTimerActive(graph, abb, state, args, va):
        pass

    @syscall
    def xTimerPendFunctionCall(graph, abb, state, args, va):
        pass

    @syscall
    def xTimerPendFunctionCallFromISR(graph, abb, state, args, va):
        pass
