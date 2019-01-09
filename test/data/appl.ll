; ModuleID = '../appl/FreeRTOS/priority_inversion.cc'
source_filename = "../appl/FreeRTOS/priority_inversion.cc"
target datalayout = "e-m:e-p:32:32-f64:32:64-f80:32-n8:16:32-S128"
target triple = "i386-pc-linux-gnu"

%struct.QueueDefinition = type opaque
%struct.AMessage = type { i8, [20 x i8] }
%struct.tskTaskControlBlock = type opaque

@FreeRTOS_configUSE_PREEMPTION = global i32 1, align 4
@FreeRTOS_configUSE_PORT_OPTIMISED_TASK_SELECTION = global i32 -1, align 4
@FreeRTOS_configUSE_TICKLESS_IDLE = global i32 -1, align 4
@FreeRTOS_configCPU_CLOCK_HZ = global i32 -1, align 4
@FreeRTOS_configTICK_RATE_HZ = global i32 1000, align 4
@FreeRTOS_configMAX_PRIORITIES = global i32 10, align 4
@FreeRTOS_configMINIMAL_STACK_SIZE = global i32 256, align 4
@FreeRTOS_configMAX_TASK_NAME_LEN = global i32 16, align 4
@FreeRTOS_configUSE_16_BIT_TICKS = global i32 1, align 4
@FreeRTOS_configIDLE_SHOULD_YIELD = global i32 1, align 4
@FreeRTOS_configUSE_TASK_NOTIFICATIONS = global i32 -1, align 4
@FreeRTOS_configUSE_MUTEXES = global i32 1, align 4
@FreeRTOS_configUSE_RECURSIVE_MUTEXES = global i32 1, align 4
@FreeRTOS_configUSE_COUNTING_SEMAPHORES = global i32 1, align 4
@FreeRTOS_configUSE_ALTERNATIVE_API = global i32 1, align 4
@FreeRTOS_configQUEUE_REGISTRY_SIZE = global i32 0, align 4
@FreeRTOS_configUSE_QUEUE_SETS = global i32 -1, align 4
@FreeRTOS_configUSE_TIME_SLICING = global i32 -1, align 4
@FreeRTOS_configUSE_NEWLIB_REENTRANT = global i32 -1, align 4
@FreeRTOS_configENABLE_BACKWARD_COMPATIBILITY = global i32 -1, align 4
@FreeRTOS_configNUM_THREAD_LOCAL_STORAGE_POINTERS = global i32 -1, align 4
@FreeRTOS_configSUPPORT_STATIC_ALLOCATION = global i32 -1, align 4
@FreeRTOS_configSUPPORT_DYNAMIC_ALLOCATION = global i32 -1, align 4
@FreeRTOS_configTOTAL_HEAP_SIZE = global i32 32768, align 4
@FreeRTOS_configAPPLICATION_ALLOCATED_HEAP = global i32 -1, align 4
@FreeRTOS_configUSE_IDLE_HOOK = global i32 0, align 4
@FreeRTOS_configUSE_TICK_HOOK = global i32 0, align 4
@FreeRTOS_configCHECK_FOR_STACK_OVERFLOW = global i32 0, align 4
@FreeRTOS_configUSE_MALLOC_FAILED_HOOK = global i32 -1, align 4
@FreeRTOS_configUSE_DAEMON_TASK_STARTUP_HOOK = global i32 -1, align 4
@FreeRTOS_configGENERATE_RUN_TIME_STATS = global i32 -1, align 4
@FreeRTOS_configUSE_TRACE_FACILITY = global i32 1, align 4
@FreeRTOS_configUSE_STATS_FORMATTING_FUNCTIONS = global i32 -1, align 4
@FreeRTOS_configUSE_CO_ROUTINES = global i32 0, align 4
@FreeRTOS_configMAX_CO_ROUTINE_PRIORITIES = global i32 2, align 4
@FreeRTOS_configUSE_TIMERS = global i32 -1, align 4
@FreeRTOS_configTIMER_TASK_PRIORITY = global i32 -1, align 4
@FreeRTOS_configTIMER_QUEUE_LENGTH = global i32 -1, align 4
@FreeRTOS_configTIMER_TASK_STACK_DEPTH = global i32 -1, align 4
@FreeRTOS_configKERNEL_INTERRUPT_PRIORITY = global i32 -1, align 4
@FreeRTOS_configMAX_SYSCALL_INTERRUPT_PRIORITY = global i32 -1, align 4
@FreeRTOS_configMAX_API_CALL_INTERRUPT_PRIORITY = global i32 -1, align 4
@FreeRTOS_configINCLUDE_APPLICATION_DEFINED_PRIVILEGED_FUNCTIONS = global i32 -1, align 4
@xCharPointerQueue = global %struct.QueueDefinition* null, align 4
@xUint32tQueue = global %struct.QueueDefinition* null, align 4
@xBinaryMutex1 = global %struct.QueueDefinition* null, align 4
@xBinaryMutex2 = global %struct.QueueDefinition* null, align 4
@xBinaryMutex3 = global %struct.QueueDefinition* null, align 4
@xBinarySemaphore = global %struct.QueueDefinition* null, align 4
@xQueueSet = global %struct.QueueDefinition* null, align 4
@xMessage = global %struct.AMessage zeroinitializer, align 1
@ulVar = global i32 10, align 4
@xSemaphore = global %struct.QueueDefinition* null, align 4
@_ZL7xQueue1 = internal global %struct.QueueDefinition* null, align 4
@_ZL7xQueue2 = internal global %struct.QueueDefinition* null, align 4
@.str = private unnamed_addr constant [28 x i8] c"Message from vSenderTask1\0D\0A\00", align 1
@.str.1 = private unnamed_addr constant [28 x i8] c"Message from vSenderTask2\0D\0A\00", align 1
@.str.2 = private unnamed_addr constant [6 x i8] c"Task1\00", align 1
@.str.3 = private unnamed_addr constant [6 x i8] c"Task2\00", align 1
@.str.4 = private unnamed_addr constant [6 x i8] c"Task3\00", align 1
@.str.5 = private unnamed_addr constant [2 x i8] c"1\00", align 1
@.str.6 = private unnamed_addr constant [2 x i8] c"2\00", align 1
@.str.7 = private unnamed_addr constant [9 x i8] c"Receiver\00", align 1

; Function Attrs: noinline optnone
define void @_Z17intialize_debugerv() #0 {
  %b = alloca i32, align 4
  %a = alloca i32, align 4
  %a2 = alloca i32, align 4
  %a7 = alloca i32, align 4
  store i32 0, i32* %b, align 4
  store i32 0, i32* %a, align 4
  br label %1

; <label>:1:                                      ; preds = %6, %0
  %2 = load i32, i32* %a, align 4
  %cmp = icmp slt i32 %2, 100
  br i1 %cmp, label %3, label %8

; <label>:3:                                      ; preds = %1
  %4 = load i32, i32* %b, align 4
  %5 = load i32, i32* %a, align 4
  %add = add nsw i32 %4, %5
  store i32 %add, i32* %b, align 4
  br label %6

; <label>:6:                                      ; preds = %3
  %7 = load i32, i32* %a, align 4
  %inc = add nsw i32 %7, 1
  store i32 %inc, i32* %a, align 4
  br label %1

; <label>:8:                                      ; preds = %1
  call void @_Z17intialize_debugerv()
  %9 = load i32, i32* %b, align 4
  %cmp1 = icmp eq i32 %9, 0
  br i1 %cmp1, label %10, label %19

; <label>:10:                                     ; preds = %8
  store i32 0, i32* %a2, align 4
  br label %11

; <label>:11:                                     ; preds = %16, %10
  %12 = load i32, i32* %a2, align 4
  %cmp3 = icmp slt i32 %12, 100
  br i1 %cmp3, label %13, label %18

; <label>:13:                                     ; preds = %11
  %14 = load i32, i32* %b, align 4
  %15 = load i32, i32* %a2, align 4
  %add4 = add nsw i32 %14, %15
  store i32 %add4, i32* %b, align 4
  br label %16

; <label>:16:                                     ; preds = %13
  %17 = load i32, i32* %a2, align 4
  %inc5 = add nsw i32 %17, 1
  store i32 %inc5, i32* %a2, align 4
  br label %11

; <label>:18:                                     ; preds = %11
  br label %31

; <label>:19:                                     ; preds = %8
  %20 = load i32, i32* %b, align 4
  %cmp6 = icmp eq i32 %20, 3213
  br i1 %cmp6, label %21, label %30

; <label>:21:                                     ; preds = %19
  store i32 0, i32* %a7, align 4
  br label %22

; <label>:22:                                     ; preds = %27, %21
  %23 = load i32, i32* %a7, align 4
  %cmp8 = icmp slt i32 %23, 100
  br i1 %cmp8, label %24, label %29

; <label>:24:                                     ; preds = %22
  %25 = load i32, i32* %b, align 4
  %26 = load i32, i32* %a7, align 4
  %add9 = add nsw i32 %25, %26
  store i32 %add9, i32* %b, align 4
  br label %27

; <label>:27:                                     ; preds = %24
  %28 = load i32, i32* %a7, align 4
  %inc10 = add nsw i32 %28, 1
  store i32 %inc10, i32* %a7, align 4
  br label %22

; <label>:29:                                     ; preds = %22
  br label %30

; <label>:30:                                     ; preds = %29, %19
  br label %31

; <label>:31:                                     ; preds = %30, %18
  ret void
}

; Function Attrs: noinline optnone
define void @_Z6vATaskPv(i8* %pvParameters) #0 {
  %pvParameters.addr = alloca i8*, align 4
  store i8* %pvParameters, i8** %pvParameters.addr, align 4
  %call = call %struct.QueueDefinition* @xQueueCreateMutex(i8 zeroext 1)
  store %struct.QueueDefinition* %call, %struct.QueueDefinition** @xSemaphore, align 4
  ret void
}

declare %struct.QueueDefinition* @xQueueCreateMutex(i8 zeroext) #1

; Function Attrs: noinline optnone
define void @_Z12vAnotherTaskPv(i8* %pvParameters) #0 {
  %pvParameters.addr = alloca i8*, align 4
  store i8* %pvParameters, i8** %pvParameters.addr, align 4
  %1 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xSemaphore, align 4
  %cmp = icmp ne %struct.QueueDefinition* %1, null
  br i1 %cmp, label %2, label %8

; <label>:2:                                      ; preds = %0
  %3 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xSemaphore, align 4
  %call = call i32 @xQueueSemaphoreTake(%struct.QueueDefinition* %3, i16 zeroext 10)
  %cmp1 = icmp eq i32 %call, 1
  br i1 %cmp1, label %4, label %6

; <label>:4:                                      ; preds = %2
  %5 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xSemaphore, align 4
  %call2 = call i32 @xQueueGenericSend(%struct.QueueDefinition* %5, i8* null, i16 zeroext 0, i32 0)
  br label %7

; <label>:6:                                      ; preds = %2
  br label %7

; <label>:7:                                      ; preds = %6, %4
  br label %8

; <label>:8:                                      ; preds = %7, %0
  ret void
}

declare i32 @xQueueSemaphoreTake(%struct.QueueDefinition*, i16 zeroext) #1

declare i32 @xQueueGenericSend(%struct.QueueDefinition*, i8*, i16 zeroext, i32) #1

; Function Attrs: noinline optnone
define void @_Z10xqueueTaskPv(i8* %pvParameters) #0 {
  %pvParameters.addr = alloca i8*, align 4
  %pxMessage = alloca %struct.AMessage*, align 4
  store i8* %pvParameters, i8** %pvParameters.addr, align 4
  %call = call %struct.QueueDefinition* @xQueueGenericCreate(i32 10, i32 4, i8 zeroext 0)
  store %struct.QueueDefinition* %call, %struct.QueueDefinition** @_ZL7xQueue1, align 4
  %call1 = call %struct.QueueDefinition* @xQueueGenericCreate(i32 10, i32 4, i8 zeroext 0)
  store %struct.QueueDefinition* %call1, %struct.QueueDefinition** @_ZL7xQueue2, align 4
  %1 = load %struct.QueueDefinition*, %struct.QueueDefinition** @_ZL7xQueue1, align 4
  %cmp = icmp ne %struct.QueueDefinition* %1, null
  br i1 %cmp, label %2, label %6

; <label>:2:                                      ; preds = %0
  %3 = load %struct.QueueDefinition*, %struct.QueueDefinition** @_ZL7xQueue1, align 4
  %call2 = call i32 @xQueueGenericSend(%struct.QueueDefinition* %3, i8* bitcast (i32* @ulVar to i8*), i16 zeroext 10, i32 1)
  %cmp3 = icmp ne i32 %call2, 1
  br i1 %cmp3, label %4, label %5

; <label>:4:                                      ; preds = %2
  br label %5

; <label>:5:                                      ; preds = %4, %2
  br label %6

; <label>:6:                                      ; preds = %5, %0
  %7 = load %struct.QueueDefinition*, %struct.QueueDefinition** @_ZL7xQueue2, align 4
  %cmp4 = icmp ne %struct.QueueDefinition* %7, null
  br i1 %cmp4, label %8, label %11

; <label>:8:                                      ; preds = %6
  store %struct.AMessage* @xMessage, %struct.AMessage** %pxMessage, align 4
  %9 = load %struct.QueueDefinition*, %struct.QueueDefinition** @_ZL7xQueue2, align 4
  %10 = bitcast %struct.AMessage** %pxMessage to i8*
  %call5 = call i32 @xQueueGenericSend(%struct.QueueDefinition* %9, i8* %10, i16 zeroext 0, i32 1)
  br label %11

; <label>:11:                                     ; preds = %8, %6
  ret void
}

declare %struct.QueueDefinition* @xQueueGenericCreate(i32, i32, i8 zeroext) #1

; Function Attrs: noinline optnone
define void @_Z12vSenderTask1Pv(i8* %pvParameters) #0 {
  %pvParameters.addr = alloca i8*, align 4
  %xBlockTime = alloca i16, align 2
  %pcMessage = alloca i8*, align 4
  store i8* %pvParameters, i8** %pvParameters.addr, align 4
  %1 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xBinaryMutex1, align 4
  %call = call i32 @xQueueSemaphoreTake(%struct.QueueDefinition* %1, i16 zeroext 1000)
  store i16 100, i16* %xBlockTime, align 2
  store i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str, i32 0, i32 0), i8** %pcMessage, align 4
  br label %2

; <label>:2:                                      ; preds = %2, %0
  call void @vTaskDelay(i16 zeroext 100)
  %3 = load %struct.QueueDefinition*, %struct.QueueDefinition** @_ZL7xQueue1, align 4
  %4 = bitcast i8** %pcMessage to i8*
  %call1 = call i32 @xQueueGenericSend(%struct.QueueDefinition* %3, i8* %4, i16 zeroext 0, i32 0)
  call void @_Z17intialize_debugerv()
  %5 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xBinaryMutex1, align 4
  %call2 = call i32 @xQueueGenericSend(%struct.QueueDefinition* %5, i8* null, i16 zeroext 0, i32 0)
  br label %2
                                                  ; No predecessors!
  ret void
}

declare void @vTaskDelay(i16 zeroext) #1

; Function Attrs: noinline optnone
define void @_Z12vSenderTask2Pv(i8* %pvParameters) #0 {
  %pvParameters.addr = alloca i8*, align 4
  %xBlockTime = alloca i16, align 2
  %pcMessage = alloca i8*, align 4
  store i8* %pvParameters, i8** %pvParameters.addr, align 4
  %1 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xBinaryMutex1, align 4
  %call = call i32 @xQueueSemaphoreTake(%struct.QueueDefinition* %1, i16 zeroext 1000)
  store i16 200, i16* %xBlockTime, align 2
  store i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.1, i32 0, i32 0), i8** %pcMessage, align 4
  call void @_Z17intialize_debugerv()
  br label %2

; <label>:2:                                      ; preds = %2, %0
  call void @vTaskDelay(i16 zeroext 200)
  %3 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xBinaryMutex1, align 4
  %call1 = call i32 @xQueueGenericSend(%struct.QueueDefinition* %3, i8* null, i16 zeroext 0, i32 0)
  %4 = load %struct.QueueDefinition*, %struct.QueueDefinition** @_ZL7xQueue2, align 4
  %5 = bitcast i8** %pcMessage to i8*
  %call2 = call i32 @xQueueGenericSend(%struct.QueueDefinition* %4, i8* %5, i16 zeroext 0, i32 0)
  br label %2
                                                  ; No predecessors!
  ret void
}

; Function Attrs: noinline optnone
define void @_Z27vAMoreRealisticReceiverTaskPv(i8* %pvParameters) #0 {
  %pvParameters.addr = alloca i8*, align 4
  %xHandle = alloca %struct.QueueDefinition*, align 4
  %pcReceivedString = alloca i8*, align 4
  %ulRecievedValue = alloca i32, align 4
  %xDelay100ms = alloca i16, align 2
  store i8* %pvParameters, i8** %pvParameters.addr, align 4
  %call = call %struct.QueueDefinition* @xQueueGenericCreate(i32 100, i32 1, i8 zeroext 0)
  store %struct.QueueDefinition* %call, %struct.QueueDefinition** @_ZL7xQueue1, align 4
  store i16 100, i16* %xDelay100ms, align 2
  br label %1

; <label>:1:                                      ; preds = %25, %0
  %2 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xQueueSet, align 4
  %call1 = call %struct.QueueDefinition* @xQueueSelectFromSet(%struct.QueueDefinition* %2, i16 zeroext 100)
  store %struct.QueueDefinition* %call1, %struct.QueueDefinition** %xHandle, align 4
  %3 = load %struct.QueueDefinition*, %struct.QueueDefinition** %xHandle, align 4
  %cmp = icmp eq %struct.QueueDefinition* %3, null
  br i1 %cmp, label %4, label %5

; <label>:4:                                      ; preds = %1
  br label %25

; <label>:5:                                      ; preds = %1
  %6 = load %struct.QueueDefinition*, %struct.QueueDefinition** %xHandle, align 4
  %7 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xCharPointerQueue, align 4
  %cmp2 = icmp eq %struct.QueueDefinition* %6, %7
  br i1 %cmp2, label %8, label %11

; <label>:8:                                      ; preds = %5
  %9 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xCharPointerQueue, align 4
  %10 = bitcast i8** %pcReceivedString to i8*
  %call3 = call i32 @xQueueReceive(%struct.QueueDefinition* %9, i8* %10, i16 zeroext 0)
  br label %24

; <label>:11:                                     ; preds = %5
  %12 = load %struct.QueueDefinition*, %struct.QueueDefinition** %xHandle, align 4
  %13 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xUint32tQueue, align 4
  %cmp4 = icmp eq %struct.QueueDefinition* %12, %13
  br i1 %cmp4, label %14, label %17

; <label>:14:                                     ; preds = %11
  %15 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xUint32tQueue, align 4
  %16 = bitcast i32* %ulRecievedValue to i8*
  %call5 = call i32 @xQueueReceive(%struct.QueueDefinition* %15, i8* %16, i16 zeroext 0)
  br label %23

; <label>:17:                                     ; preds = %11
  %18 = load %struct.QueueDefinition*, %struct.QueueDefinition** %xHandle, align 4
  %19 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xBinarySemaphore, align 4
  %cmp6 = icmp eq %struct.QueueDefinition* %18, %19
  br i1 %cmp6, label %20, label %22

; <label>:20:                                     ; preds = %17
  %21 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xBinarySemaphore, align 4
  %call7 = call i32 @xQueueSemaphoreTake(%struct.QueueDefinition* %21, i16 zeroext 0)
  br label %22

; <label>:22:                                     ; preds = %20, %17
  br label %23

; <label>:23:                                     ; preds = %22, %14
  br label %24

; <label>:24:                                     ; preds = %23, %8
  br label %25

; <label>:25:                                     ; preds = %24, %4
  br label %1
                                                  ; No predecessors!
  ret void
}

declare %struct.QueueDefinition* @xQueueSelectFromSet(%struct.QueueDefinition*, i16 zeroext) #1

declare i32 @xQueueReceive(%struct.QueueDefinition*, i8*, i16 zeroext) #1

; Function Attrs: noinline norecurse optnone
define i32 @main() #2 {
  %retval = alloca i32, align 4
  %b = alloca i32, align 4
  %a = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %a11 = alloca i32, align 4
  store i32 0, i32* %retval, align 4
  %call = call %struct.QueueDefinition* @xQueueCreateMutex(i8 zeroext 1)
  store %struct.QueueDefinition* %call, %struct.QueueDefinition** @xBinaryMutex1, align 4
  %call1 = call %struct.QueueDefinition* @xQueueCreateMutex(i8 zeroext 1)
  store %struct.QueueDefinition* %call1, %struct.QueueDefinition** @xBinaryMutex2, align 4
  %call2 = call %struct.QueueDefinition* @xQueueCreateMutex(i8 zeroext 1)
  store %struct.QueueDefinition* %call2, %struct.QueueDefinition** @xBinaryMutex3, align 4
  store i32 0, i32* %b, align 4
  store i32 0, i32* %a, align 4
  br label %1

; <label>:1:                                      ; preds = %6, %0
  %2 = load i32, i32* %a, align 4
  %cmp = icmp slt i32 %2, 100
  br i1 %cmp, label %3, label %8

; <label>:3:                                      ; preds = %1
  %4 = load i32, i32* %b, align 4
  %5 = load i32, i32* %a, align 4
  %add = add nsw i32 %4, %5
  store i32 %add, i32* %b, align 4
  br label %6

; <label>:6:                                      ; preds = %3
  %7 = load i32, i32* %a, align 4
  %inc = add nsw i32 %7, 1
  store i32 %inc, i32* %a, align 4
  br label %1

; <label>:8:                                      ; preds = %1
  %call3 = call %struct.QueueDefinition* @xQueueGenericCreate(i32 1, i32 1, i8 zeroext 0)
  store %struct.QueueDefinition* %call3, %struct.QueueDefinition** @xUint32tQueue, align 4
  %call4 = call %struct.QueueDefinition* @xQueueGenericCreate(i32 1, i32 6, i8 zeroext 0)
  store %struct.QueueDefinition* %call4, %struct.QueueDefinition** @xCharPointerQueue, align 4
  %call5 = call %struct.QueueDefinition* @xQueueCreateSet(i32 2)
  store %struct.QueueDefinition* %call5, %struct.QueueDefinition** @xQueueSet, align 4
  store i32 0, i32* %i, align 4
  br label %9

; <label>:9:                                      ; preds = %18, %8
  %10 = load i32, i32* %i, align 4
  %cmp6 = icmp slt i32 %10, 10
  br i1 %cmp6, label %11, label %20

; <label>:11:                                     ; preds = %9
  store i32 0, i32* %j, align 4
  br label %12

; <label>:12:                                     ; preds = %15, %11
  %13 = load i32, i32* %j, align 4
  %cmp7 = icmp slt i32 %13, 10
  br i1 %cmp7, label %14, label %17

; <label>:14:                                     ; preds = %12
  %call8 = call %struct.QueueDefinition* @xQueueGenericCreate(i32 1, i32 4, i8 zeroext 0)
  store %struct.QueueDefinition* %call8, %struct.QueueDefinition** @_ZL7xQueue2, align 4
  br label %15

; <label>:15:                                     ; preds = %14
  %16 = load i32, i32* %j, align 4
  %inc9 = add nsw i32 %16, 1
  store i32 %inc9, i32* %j, align 4
  br label %12

; <label>:17:                                     ; preds = %12
  br label %18

; <label>:18:                                     ; preds = %17
  %19 = load i32, i32* %i, align 4
  %inc10 = add nsw i32 %19, 1
  store i32 %inc10, i32* %i, align 4
  br label %9

; <label>:20:                                     ; preds = %9
  store i32 0, i32* %b, align 4
  store i32 0, i32* %a11, align 4
  br label %21

; <label>:21:                                     ; preds = %26, %20
  %22 = load i32, i32* %a11, align 4
  %cmp12 = icmp slt i32 %22, 100
  br i1 %cmp12, label %23, label %28

; <label>:23:                                     ; preds = %21
  %24 = load i32, i32* %b, align 4
  %25 = load i32, i32* %a11, align 4
  %add13 = add nsw i32 %24, %25
  store i32 %add13, i32* %b, align 4
  br label %26

; <label>:26:                                     ; preds = %23
  %27 = load i32, i32* %a11, align 4
  %inc14 = add nsw i32 %27, 1
  store i32 %inc14, i32* %a11, align 4
  br label %21

; <label>:28:                                     ; preds = %21
  %29 = load %struct.QueueDefinition*, %struct.QueueDefinition** @_ZL7xQueue1, align 4
  %30 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xQueueSet, align 4
  %call15 = call i32 @xQueueAddToSet(%struct.QueueDefinition* %29, %struct.QueueDefinition* %30)
  %31 = load %struct.QueueDefinition*, %struct.QueueDefinition** @_ZL7xQueue2, align 4
  %32 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xQueueSet, align 4
  %call16 = call i32 @xQueueAddToSet(%struct.QueueDefinition* %31, %struct.QueueDefinition* %32)
  %call17 = call i32 @xTaskCreate(void (i8*)* @_Z12vSenderTask1Pv, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.2, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 1, %struct.tskTaskControlBlock** null)
  %call18 = call i32 @xTaskCreate(void (i8*)* @_Z10xqueueTaskPv, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.3, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 2, %struct.tskTaskControlBlock** null)
  %call19 = call i32 @xTaskCreate(void (i8*)* @_Z12vSenderTask2Pv, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.4, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 3, %struct.tskTaskControlBlock** null)
  %call20 = call i32 @xTaskCreate(void (i8*)* @_Z6vATaskPv, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str.5, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 1, %struct.tskTaskControlBlock** null)
  %call21 = call i32 @xTaskCreate(void (i8*)* @_Z12vAnotherTaskPv, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str.6, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 1, %struct.tskTaskControlBlock** null)
  %call22 = call i32 @xTaskCreate(void (i8*)* @_Z27vAMoreRealisticReceiverTaskPv, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.7, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 2, %struct.tskTaskControlBlock** null)
  call void @vTaskStartScheduler()
  br label %33

; <label>:33:                                     ; preds = %33, %28
  br label %33
                                                  ; No predecessors!
  %35 = load i32, i32* %retval, align 4
  ret i32 %35
}

declare %struct.QueueDefinition* @xQueueCreateSet(i32) #1

declare i32 @xQueueAddToSet(%struct.QueueDefinition*, %struct.QueueDefinition*) #1

declare i32 @xTaskCreate(void (i8*)*, i8*, i16 zeroext, i8*, i32, %struct.tskTaskControlBlock**) #1

declare void @vTaskStartScheduler() #1

attributes #0 = { noinline optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noinline norecurse optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"NumRegisterParameters", i32 0}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
