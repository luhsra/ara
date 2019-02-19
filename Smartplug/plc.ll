; ModuleID = 'plc.cc'
source_filename = "plc.cc"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.tskTaskControlBlock = type opaque
%struct.QueueDefinition = type opaque
%struct.PlcTxRecord = type { [32 x i8], [8 x i8], %struct.tskTaskControlBlock*, i8, i8 }
%struct.Client = type { %struct.Client*, [8 x i8], [33 x i8], i8 }
%struct.MqttData = type { [32 x i8], [8 x i8], i8, i8 }
%struct.ConfigData = type { [33 x i8], [65 x i8], [17 x i8], [21 x i8], [33 x i8], i32, i8, i8, i8 }
%struct.sdk_station_config = type { i32, i32 }

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
@xPLCTaskRcv = global %struct.tskTaskControlBlock* null, align 8
@xPLCTaskSend = global %struct.tskTaskControlBlock* null, align 8
@xTaskNewClientRegis = global %struct.tskTaskControlBlock* null, align 8
@xPLCSendSemaphore = global %struct.QueueDefinition* null, align 8
@plcTxBuf = global [8 x %struct.PlcTxRecord] zeroinitializer, align 16
@plcTxBufHead = global i32 0, align 4
@plcTxBufTail = global i32 0, align 4
@newWifiSsid = global i8* null, align 8
@newWifiPassword = global i8* null, align 8
@.str = private unnamed_addr constant [27 x i8] c"Read PLC register failed\0A\0D\00", align 1
@.str.1 = private unnamed_addr constant [28 x i8] c"Read PLC registers failed\0A\0D\00", align 1
@.str.2 = private unnamed_addr constant [28 x i8] c"Write PLC register failed\0A\0D\00", align 1
@.str.3 = private unnamed_addr constant [29 x i8] c"Write PLC registers failed\0A\0D\00", align 1
@.str.4 = private unnamed_addr constant [48 x i8] c"Internal CY8CPLC10 buffer is shorter than len\0A\0D\00", align 1
@.str.5 = private unnamed_addr constant [29 x i8] c"Got some data from PLC: %d\0A\0D\00", align 1
@_ZZ10plcTaskRcvPvE7nackCnt = internal global i32 2, align 4
@_ZZ10plcTaskRcvPvE9noRespCnt = internal global i32 5, align 4
@.str.6 = private unnamed_addr constant [18 x i8] c"PLC: Data sent.\0A\0D\00", align 1
@.str.7 = private unnamed_addr constant [43 x i8] c"Wrong PLC Interrupt register content: %d\0A\0D\00", align 1
@.str.8 = private unnamed_addr constant [54 x i8] c"Sending PLC data \22%.*s\22 of len %d with command 0x%X\0A\0D\00", align 1
@_ZL29xClientSideRegistrationHandle = internal global %struct.tskTaskControlBlock* null, align 8
@.str.9 = private unnamed_addr constant [25 x i8] c"Registration successful\0A\00", align 1
@xMqttQueue = external global %struct.QueueDefinition*, align 8
@.str.10 = private unnamed_addr constant [30 x i8] c"Registation unsuccessful: %d\0A\00", align 1
@clientListBegin = external global %struct.Client*, align 8
@.str.11 = private unnamed_addr constant [30 x i8] c"PLC: New RX data available.\0A\0D\00", align 1
@devType = external global i32, align 4
@.str.12 = private unnamed_addr constant [6 x i8] c"Regis\00", align 1

; Function Attrs: noinline optnone uwtable
define void @_Z11initPlcTaskPv(i8*) #0 {
  %2 = alloca i8*, align 8
  store i8* %0, i8** %2, align 8
  call void @vTaskDelay(i16 zeroext 3000)
  call void @_Z13initPLCdeviceh(i8 zeroext 0)
  call void @vTaskDelay(i16 zeroext 10000)
  call void @vTaskDelete(%struct.tskTaskControlBlock* null)
  ret void
}

declare void @vTaskDelay(i16 zeroext) #1

; Function Attrs: noinline optnone uwtable
define void @_Z13initPLCdeviceh(i8 zeroext) #0 {
  %2 = alloca i8, align 1
  store i8 %0, i8* %2, align 1
  call void @_Z16writePLCregisterhh(i8 zeroext 5, i8 zeroext -56)
  call void @_Z16writePLCregisterhh(i8 zeroext 48, i8 zeroext 3)
  call void @_Z16writePLCregisterhh(i8 zeroext 49, i8 zeroext 11)
  call void @_Z16writePLCregisterhh(i8 zeroext 0, i8 zeroext 123)
  call void @_Z16writePLCregisterhh(i8 zeroext 7, i8 zeroext 21)
  call void @_Z16writePLCregisterhh(i8 zeroext 50, i8 zeroext 13)
  call void @_Z16writePLCregisterhh(i8 zeroext 51, i8 zeroext 6)
  %3 = load i8, i8* %2, align 1
  call void @_Z12setPLCnodeLAh(i8 zeroext %3)
  call void @_Z12setPLCnodeGAh(i8 zeroext 10)
  call void @_Z16setPLCtxAddrTypehh(i8 zeroext -128, i8 zeroext 64)
  ret void
}

declare void @vTaskDelete(%struct.tskTaskControlBlock*) #1

; Function Attrs: noinline optnone uwtable
define zeroext i8 @_Z15readPLCregisterh(i8 zeroext) #0 {
  %2 = alloca i8, align 1
  %3 = alloca i8, align 1
  %4 = alloca i32, align 4
  store i8 %0, i8* %2, align 1
  store i32 5, i32* %4, align 4
  br label %5

; <label>:5:                                      ; preds = %12, %1
  %6 = load i32, i32* %4, align 4
  %7 = icmp ne i32 %6, 0
  br i1 %7, label %8, label %15

; <label>:8:                                      ; preds = %5
  %9 = load i8, i8* %2, align 1
  %10 = call zeroext i1 @_Z14i2c_slave_readhhPhj(i8 zeroext 1, i8 zeroext %9, i8* %3, i32 1)
  br i1 %10, label %11, label %12

; <label>:11:                                     ; preds = %8
  br label %15

; <label>:12:                                     ; preds = %8
  %13 = load i32, i32* %4, align 4
  %14 = add i32 %13, -1
  store i32 %14, i32* %4, align 4
  br label %5

; <label>:15:                                     ; preds = %11, %5
  %16 = load i32, i32* %4, align 4
  %17 = icmp ne i32 %16, 0
  br i1 %17, label %20, label %18

; <label>:18:                                     ; preds = %15
  %19 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([27 x i8], [27 x i8]* @.str, i32 0, i32 0))
  br label %20

; <label>:20:                                     ; preds = %18, %15
  %21 = load i8, i8* %3, align 1
  ret i8 %21
}

declare zeroext i1 @_Z14i2c_slave_readhhPhj(i8 zeroext, i8 zeroext, i8*, i32) #1

declare i32 @printf(i8*, ...) #1

; Function Attrs: noinline optnone uwtable
define void @_Z16readPLCregistershPhj(i8 zeroext, i8*, i32) #0 {
  %4 = alloca i8, align 1
  %5 = alloca i8*, align 8
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  store i8 %0, i8* %4, align 1
  store i8* %1, i8** %5, align 8
  store i32 %2, i32* %6, align 4
  store i32 5, i32* %7, align 4
  br label %8

; <label>:8:                                      ; preds = %17, %3
  %9 = load i32, i32* %7, align 4
  %10 = icmp ne i32 %9, 0
  br i1 %10, label %11, label %20

; <label>:11:                                     ; preds = %8
  %12 = load i8, i8* %4, align 1
  %13 = load i8*, i8** %5, align 8
  %14 = load i32, i32* %6, align 4
  %15 = call zeroext i1 @_Z14i2c_slave_readhhPhj(i8 zeroext 1, i8 zeroext %12, i8* %13, i32 %14)
  br i1 %15, label %16, label %17

; <label>:16:                                     ; preds = %11
  br label %20

; <label>:17:                                     ; preds = %11
  %18 = load i32, i32* %7, align 4
  %19 = add i32 %18, -1
  store i32 %19, i32* %7, align 4
  br label %8

; <label>:20:                                     ; preds = %16, %8
  %21 = load i32, i32* %7, align 4
  %22 = icmp ne i32 %21, 0
  br i1 %22, label %25, label %23

; <label>:23:                                     ; preds = %20
  %24 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.1, i32 0, i32 0))
  br label %25

; <label>:25:                                     ; preds = %23, %20
  ret void
}

; Function Attrs: noinline optnone uwtable
define void @_Z16writePLCregisterhh(i8 zeroext, i8 zeroext) #0 {
  %3 = alloca i8, align 1
  %4 = alloca i8, align 1
  %5 = alloca [2 x i8], align 1
  %6 = alloca i32, align 4
  store i8 %0, i8* %3, align 1
  store i8 %1, i8* %4, align 1
  %7 = load i8, i8* %3, align 1
  %8 = getelementptr inbounds [2 x i8], [2 x i8]* %5, i64 0, i64 0
  store i8 %7, i8* %8, align 1
  %9 = load i8, i8* %4, align 1
  %10 = getelementptr inbounds [2 x i8], [2 x i8]* %5, i64 0, i64 1
  store i8 %9, i8* %10, align 1
  store i32 5, i32* %6, align 4
  br label %11

; <label>:11:                                     ; preds = %18, %2
  %12 = load i32, i32* %6, align 4
  %13 = icmp ne i32 %12, 0
  br i1 %13, label %14, label %21

; <label>:14:                                     ; preds = %11
  %15 = getelementptr inbounds [2 x i8], [2 x i8]* %5, i32 0, i32 0
  %16 = call zeroext i1 @_Z15i2c_slave_writehPhh(i8 zeroext 1, i8* %15, i8 zeroext 2)
  br i1 %16, label %17, label %18

; <label>:17:                                     ; preds = %14
  br label %21

; <label>:18:                                     ; preds = %14
  %19 = load i32, i32* %6, align 4
  %20 = add i32 %19, -1
  store i32 %20, i32* %6, align 4
  br label %11

; <label>:21:                                     ; preds = %17, %11
  %22 = load i32, i32* %6, align 4
  %23 = icmp ne i32 %22, 0
  br i1 %23, label %26, label %24

; <label>:24:                                     ; preds = %21
  %25 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.2, i32 0, i32 0))
  br label %26

; <label>:26:                                     ; preds = %24, %21
  ret void
}

declare zeroext i1 @_Z15i2c_slave_writehPhh(i8 zeroext, i8*, i8 zeroext) #1

; Function Attrs: noinline optnone uwtable
define void @_Z17writePLCregistersPhh(i8*, i8 zeroext) #0 {
  %3 = alloca i8*, align 8
  %4 = alloca i8, align 1
  %5 = alloca i32, align 4
  store i8* %0, i8** %3, align 8
  store i8 %1, i8* %4, align 1
  store i32 5, i32* %5, align 4
  br label %6

; <label>:6:                                      ; preds = %14, %2
  %7 = load i32, i32* %5, align 4
  %8 = icmp ne i32 %7, 0
  br i1 %8, label %9, label %17

; <label>:9:                                      ; preds = %6
  %10 = load i8*, i8** %3, align 8
  %11 = load i8, i8* %4, align 1
  %12 = call zeroext i1 @_Z15i2c_slave_writehPhh(i8 zeroext 1, i8* %10, i8 zeroext %11)
  br i1 %12, label %13, label %14

; <label>:13:                                     ; preds = %9
  br label %17

; <label>:14:                                     ; preds = %9
  %15 = load i32, i32* %5, align 4
  %16 = add i32 %15, -1
  store i32 %16, i32* %5, align 4
  br label %6

; <label>:17:                                     ; preds = %13, %6
  %18 = load i32, i32* %5, align 4
  %19 = icmp ne i32 %18, 0
  br i1 %19, label %22, label %20

; <label>:20:                                     ; preds = %17
  %21 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([29 x i8], [29 x i8]* @.str.3, i32 0, i32 0))
  br label %22

; <label>:22:                                     ; preds = %20, %17
  ret void
}

; Function Attrs: noinline optnone uwtable
define void @_Z16setPLCtxAddrTypehh(i8 zeroext, i8 zeroext) #0 {
  %3 = alloca i8, align 1
  %4 = alloca i8, align 1
  %5 = alloca i8, align 1
  store i8 %0, i8* %3, align 1
  store i8 %1, i8* %4, align 1
  %6 = call zeroext i8 @_Z15readPLCregisterh(i8 zeroext 7)
  %7 = zext i8 %6 to i32
  %8 = and i32 %7, -225
  %9 = trunc i32 %8 to i8
  store i8 %9, i8* %5, align 1
  %10 = load i8, i8* %5, align 1
  %11 = zext i8 %10 to i32
  %12 = load i8, i8* %3, align 1
  %13 = zext i8 %12 to i32
  %14 = or i32 %11, %13
  %15 = load i8, i8* %4, align 1
  %16 = zext i8 %15 to i32
  %17 = or i32 %14, %16
  %18 = trunc i32 %17 to i8
  call void @_Z16writePLCregisterhh(i8 zeroext 7, i8 zeroext %18)
  ret void
}

; Function Attrs: noinline optnone uwtable
define void @_Z10setPLCtxDAhPh(i8 zeroext, i8*) #0 {
  %3 = alloca i8, align 1
  %4 = alloca i8*, align 8
  %5 = alloca [9 x i8], align 1
  store i8 %0, i8* %3, align 1
  store i8* %1, i8** %4, align 8
  %6 = load i8, i8* %3, align 1
  %7 = zext i8 %6 to i32
  switch i32 %7, label %17 [
    i32 0, label %8
    i32 32, label %8
    i32 64, label %11
  ]

; <label>:8:                                      ; preds = %2, %2
  %9 = load i8*, i8** %4, align 8
  %10 = load i8, i8* %9, align 1
  call void @_Z16writePLCregisterhh(i8 zeroext 8, i8 zeroext %10)
  br label %17

; <label>:11:                                     ; preds = %2
  %12 = getelementptr inbounds [9 x i8], [9 x i8]* %5, i64 0, i64 0
  store i8 8, i8* %12, align 1
  %13 = getelementptr inbounds [9 x i8], [9 x i8]* %5, i32 0, i32 0
  %14 = getelementptr inbounds i8, i8* %13, i64 1
  %15 = load i8*, i8** %4, align 8
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %14, i8* %15, i64 8, i32 1, i1 false)
  %16 = getelementptr inbounds [9 x i8], [9 x i8]* %5, i32 0, i32 0
  call void @_Z17writePLCregistersPhh(i8* %16, i8 zeroext 9)
  br label %17

; <label>:17:                                     ; preds = %2, %11, %8
  ret void
}

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture writeonly, i8* nocapture readonly, i64, i32, i1) #2

; Function Attrs: noinline optnone uwtable
define void @_Z12setPLCnodeLAh(i8 zeroext) #0 {
  %2 = alloca i8, align 1
  store i8 %0, i8* %2, align 1
  %3 = load i8, i8* %2, align 1
  call void @_Z16writePLCregisterhh(i8 zeroext 1, i8 zeroext %3)
  ret void
}

; Function Attrs: noinline optnone uwtable
define void @_Z12setPLCnodeGAh(i8 zeroext) #0 {
  %2 = alloca i8, align 1
  store i8 %0, i8* %2, align 1
  %3 = load i8, i8* %2, align 1
  call void @_Z16writePLCregisterhh(i8 zeroext 3, i8 zeroext %3)
  ret void
}

; Function Attrs: noinline optnone uwtable
define void @_Z16getPLCrxAddrTypePhS_(i8*, i8*) #0 {
  %3 = alloca i8*, align 8
  %4 = alloca i8*, align 8
  %5 = alloca i8, align 1
  store i8* %0, i8** %3, align 8
  store i8* %1, i8** %4, align 8
  %6 = call zeroext i8 @_Z15readPLCregisterh(i8 zeroext 64)
  store i8 %6, i8* %5, align 1
  %7 = load i8, i8* %5, align 1
  %8 = zext i8 %7 to i32
  %9 = and i32 %8, 64
  %10 = trunc i32 %9 to i8
  %11 = load i8*, i8** %4, align 8
  store i8 %10, i8* %11, align 1
  %12 = load i8, i8* %5, align 1
  %13 = zext i8 %12 to i32
  %14 = and i32 %13, 32
  %15 = trunc i32 %14 to i8
  %16 = load i8*, i8** %3, align 8
  store i8 %15, i8* %16, align 1
  ret void
}

; Function Attrs: noinline optnone uwtable
define void @_Z10getPLCrxSAPh(i8*) #0 {
  %2 = alloca i8*, align 8
  store i8* %0, i8** %2, align 8
  %3 = load i8*, i8** %2, align 8
  call void @_Z16readPLCregistershPhj(i8 zeroext 65, i8* %3, i32 8)
  ret void
}

; Function Attrs: noinline optnone uwtable
define void @_Z15readPLCrxPacketPhS_S_(i8*, i8*, i8*) #0 {
  %4 = alloca i8*, align 8
  %5 = alloca i8*, align 8
  %6 = alloca i8*, align 8
  %7 = alloca i8, align 1
  %8 = alloca i8, align 1
  store i8* %0, i8** %4, align 8
  store i8* %1, i8** %5, align 8
  store i8* %2, i8** %6, align 8
  %9 = call zeroext i8 @_Z15readPLCregisterh(i8 zeroext 64)
  %10 = zext i8 %9 to i32
  %11 = and i32 %10, 31
  %12 = trunc i32 %11 to i8
  store i8 %12, i8* %8, align 1
  %13 = load i8*, i8** %4, align 8
  %14 = icmp ne i8* %13, null
  br i1 %14, label %15, label %18

; <label>:15:                                     ; preds = %3
  %16 = call zeroext i8 @_Z15readPLCregisterh(i8 zeroext 73)
  %17 = load i8*, i8** %4, align 8
  store i8 %16, i8* %17, align 1
  br label %18

; <label>:18:                                     ; preds = %15, %3
  %19 = load i8*, i8** %5, align 8
  %20 = load i8, i8* %8, align 1
  %21 = zext i8 %20 to i32
  call void @_Z16readPLCregistershPhj(i8 zeroext 74, i8* %19, i32 %21)
  %22 = call zeroext i8 @_Z15readPLCregisterh(i8 zeroext 64)
  store i8 %22, i8* %7, align 1
  %23 = load i8, i8* %7, align 1
  %24 = zext i8 %23 to i32
  %25 = and i32 %24, -129
  %26 = trunc i32 %25 to i8
  call void @_Z16writePLCregisterhh(i8 zeroext 64, i8 zeroext %26)
  %27 = load i8*, i8** %6, align 8
  %28 = icmp ne i8* %27, null
  br i1 %28, label %29, label %32

; <label>:29:                                     ; preds = %18
  %30 = load i8, i8* %8, align 1
  %31 = load i8*, i8** %6, align 8
  store i8 %30, i8* %31, align 1
  br label %32

; <label>:32:                                     ; preds = %29, %18
  ret void
}

; Function Attrs: noinline optnone uwtable
define zeroext i8 @_Z18readPLCintRegisterv() #0 {
  %1 = alloca i8, align 1
  %2 = alloca i8, align 1
  %3 = call zeroext i8 @_Z15readPLCregisterh(i8 zeroext 105)
  %4 = zext i8 %3 to i32
  %5 = and i32 %4, -129
  %6 = trunc i32 %5 to i8
  store i8 %6, i8* %1, align 1
  %7 = call zeroext i8 @_Z15readPLCregisterh(i8 zeroext 0)
  %8 = zext i8 %7 to i32
  %9 = and i32 %8, -129
  %10 = trunc i32 %9 to i8
  store i8 %10, i8* %2, align 1
  %11 = load i8, i8* %2, align 1
  call void @_Z16writePLCregisterhh(i8 zeroext 0, i8 zeroext %11)
  %12 = load i8, i8* %1, align 1
  ret i8 %12
}

; Function Attrs: noinline optnone uwtable
define void @_Z13fillPLCTxDataPhh(i8*, i8 zeroext) #0 {
  %3 = alloca i8*, align 8
  %4 = alloca i8, align 1
  %5 = alloca [33 x i8], align 16
  store i8* %0, i8** %3, align 8
  store i8 %1, i8* %4, align 1
  %6 = load i8, i8* %4, align 1
  %7 = zext i8 %6 to i32
  %8 = icmp sgt i32 %7, 32
  br i1 %8, label %9, label %11

; <label>:9:                                      ; preds = %2
  %10 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([48 x i8], [48 x i8]* @.str.4, i32 0, i32 0))
  br label %28

; <label>:11:                                     ; preds = %2
  %12 = load i8, i8* %4, align 1
  %13 = zext i8 %12 to i32
  %14 = icmp eq i32 %13, 0
  br i1 %14, label %15, label %16

; <label>:15:                                     ; preds = %11
  br label %28

; <label>:16:                                     ; preds = %11
  %17 = getelementptr inbounds [33 x i8], [33 x i8]* %5, i64 0, i64 0
  store i8 17, i8* %17, align 16
  %18 = getelementptr inbounds [33 x i8], [33 x i8]* %5, i32 0, i32 0
  %19 = getelementptr inbounds i8, i8* %18, i64 1
  %20 = load i8*, i8** %3, align 8
  %21 = load i8, i8* %4, align 1
  %22 = zext i8 %21 to i64
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %19, i8* %20, i64 %22, i32 1, i1 false)
  %23 = getelementptr inbounds [33 x i8], [33 x i8]* %5, i32 0, i32 0
  %24 = load i8, i8* %4, align 1
  %25 = zext i8 %24 to i32
  %26 = add nsw i32 %25, 1
  %27 = trunc i32 %26 to i8
  call void @_Z17writePLCregistersPhh(i8* %23, i8 zeroext %27)
  br label %28

; <label>:28:                                     ; preds = %16, %15, %9
  ret void
}

; Function Attrs: noinline optnone uwtable
define void @_Z17hostIntPinHandlerh(i8 zeroext) #0 {
  %2 = alloca i8, align 1
  %3 = alloca i64, align 8
  store i8 %0, i8* %2, align 1
  store i64 0, i64* %3, align 8
  %4 = load %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** @xPLCTaskRcv, align 8
  %5 = icmp ne %struct.tskTaskControlBlock* %4, null
  br i1 %5, label %6, label %8

; <label>:6:                                      ; preds = %1
  %7 = load %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** @xPLCTaskRcv, align 8
  call void @vTaskNotifyGiveFromISR(%struct.tskTaskControlBlock* %7, i64* %3)
  br label %8

; <label>:8:                                      ; preds = %6, %1
  ret void
}

declare void @vTaskNotifyGiveFromISR(%struct.tskTaskControlBlock*, i64*) #1

; Function Attrs: noinline optnone uwtable
define void @_Z10plcTaskRcvPv(i8*) #0 {
  %2 = alloca i8*, align 8
  %3 = alloca i32, align 4
  %4 = alloca %struct.PlcTxRecord*, align 8
  %5 = alloca %struct.PlcTxRecord*, align 8
  %6 = alloca %struct.PlcTxRecord*, align 8
  store i8* %0, i8** %2, align 8
  br label %7

; <label>:7:                                      ; preds = %88, %1
  %8 = call i32 @ulTaskNotifyTake(i64 1, i16 zeroext -1)
  %9 = call zeroext i8 @_Z18readPLCintRegisterv()
  %10 = zext i8 %9 to i32
  store i32 %10, i32* %3, align 4
  %11 = load i32, i32* %3, align 4
  %12 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([29 x i8], [29 x i8]* @.str.5, i32 0, i32 0), i32 %11)
  %13 = load i32, i32* %3, align 4
  switch i32 %13, label %85 [
    i32 2, label %14
    i32 16, label %15
    i32 8, label %40
    i32 1, label %65
  ]

; <label>:14:                                     ; preds = %7
  call void @_ZL41handleReceivedDataBasingOnCommandReceivedv()
  br label %88

; <label>:15:                                     ; preds = %7
  %16 = load i32, i32* @_ZZ10plcTaskRcvPvE7nackCnt, align 4
  %17 = add nsw i32 %16, -1
  store i32 %17, i32* @_ZZ10plcTaskRcvPvE7nackCnt, align 4
  %18 = load i32, i32* @_ZZ10plcTaskRcvPvE7nackCnt, align 4
  %19 = icmp ne i32 %18, 0
  br i1 %19, label %37, label %20

; <label>:20:                                     ; preds = %15
  %21 = load i32, i32* @plcTxBufTail, align 4
  %22 = sext i32 %21 to i64
  %23 = getelementptr inbounds [8 x %struct.PlcTxRecord], [8 x %struct.PlcTxRecord]* @plcTxBuf, i64 0, i64 %22
  store %struct.PlcTxRecord* %23, %struct.PlcTxRecord** %4, align 8
  %24 = load %struct.PlcTxRecord*, %struct.PlcTxRecord** %4, align 8
  %25 = getelementptr inbounds %struct.PlcTxRecord, %struct.PlcTxRecord* %24, i32 0, i32 2
  %26 = load %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** %25, align 8
  %27 = icmp ne %struct.tskTaskControlBlock* %26, null
  br i1 %27, label %28, label %33

; <label>:28:                                     ; preds = %20
  %29 = load %struct.PlcTxRecord*, %struct.PlcTxRecord** %4, align 8
  %30 = getelementptr inbounds %struct.PlcTxRecord, %struct.PlcTxRecord* %29, i32 0, i32 2
  %31 = load %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** %30, align 8
  %32 = call i64 @xTaskGenericNotify(%struct.tskTaskControlBlock* %31, i32 -2, i32 4, i32* null)
  br label %33

; <label>:33:                                     ; preds = %28, %20
  store i32 2, i32* @_ZZ10plcTaskRcvPvE7nackCnt, align 4
  %34 = load i32, i32* @plcTxBufTail, align 4
  %35 = add nsw i32 %34, 1
  %36 = and i32 %35, 7
  store i32 %36, i32* @plcTxBufTail, align 4
  br label %37

; <label>:37:                                     ; preds = %33, %15
  %38 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xPLCSendSemaphore, align 8
  %39 = call i64 @xQueueGenericSend(%struct.QueueDefinition* %38, i8* null, i16 zeroext 0, i64 0)
  br label %88

; <label>:40:                                     ; preds = %7
  %41 = load i32, i32* @_ZZ10plcTaskRcvPvE9noRespCnt, align 4
  %42 = add nsw i32 %41, -1
  store i32 %42, i32* @_ZZ10plcTaskRcvPvE9noRespCnt, align 4
  %43 = load i32, i32* @_ZZ10plcTaskRcvPvE9noRespCnt, align 4
  %44 = icmp ne i32 %43, 0
  br i1 %44, label %62, label %45

; <label>:45:                                     ; preds = %40
  %46 = load i32, i32* @plcTxBufTail, align 4
  %47 = sext i32 %46 to i64
  %48 = getelementptr inbounds [8 x %struct.PlcTxRecord], [8 x %struct.PlcTxRecord]* @plcTxBuf, i64 0, i64 %47
  store %struct.PlcTxRecord* %48, %struct.PlcTxRecord** %5, align 8
  %49 = load %struct.PlcTxRecord*, %struct.PlcTxRecord** %5, align 8
  %50 = getelementptr inbounds %struct.PlcTxRecord, %struct.PlcTxRecord* %49, i32 0, i32 2
  %51 = load %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** %50, align 8
  %52 = icmp ne %struct.tskTaskControlBlock* %51, null
  br i1 %52, label %53, label %58

; <label>:53:                                     ; preds = %45
  %54 = load %struct.PlcTxRecord*, %struct.PlcTxRecord** %5, align 8
  %55 = getelementptr inbounds %struct.PlcTxRecord, %struct.PlcTxRecord* %54, i32 0, i32 2
  %56 = load %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** %55, align 8
  %57 = call i64 @xTaskGenericNotify(%struct.tskTaskControlBlock* %56, i32 -3, i32 4, i32* null)
  br label %58

; <label>:58:                                     ; preds = %53, %45
  store i32 5, i32* @_ZZ10plcTaskRcvPvE9noRespCnt, align 4
  %59 = load i32, i32* @plcTxBufTail, align 4
  %60 = add nsw i32 %59, 1
  %61 = and i32 %60, 7
  store i32 %61, i32* @plcTxBufTail, align 4
  br label %62

; <label>:62:                                     ; preds = %58, %40
  %63 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xPLCSendSemaphore, align 8
  %64 = call i64 @xQueueGenericSend(%struct.QueueDefinition* %63, i8* null, i16 zeroext 0, i64 0)
  br label %88

; <label>:65:                                     ; preds = %7
  %66 = load i32, i32* @plcTxBufTail, align 4
  %67 = sext i32 %66 to i64
  %68 = getelementptr inbounds [8 x %struct.PlcTxRecord], [8 x %struct.PlcTxRecord]* @plcTxBuf, i64 0, i64 %67
  store %struct.PlcTxRecord* %68, %struct.PlcTxRecord** %6, align 8
  %69 = load %struct.PlcTxRecord*, %struct.PlcTxRecord** %6, align 8
  %70 = getelementptr inbounds %struct.PlcTxRecord, %struct.PlcTxRecord* %69, i32 0, i32 2
  %71 = load %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** %70, align 8
  %72 = icmp ne %struct.tskTaskControlBlock* %71, null
  br i1 %72, label %73, label %78

; <label>:73:                                     ; preds = %65
  %74 = load %struct.PlcTxRecord*, %struct.PlcTxRecord** %6, align 8
  %75 = getelementptr inbounds %struct.PlcTxRecord, %struct.PlcTxRecord* %74, i32 0, i32 2
  %76 = load %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** %75, align 8
  %77 = call i64 @xTaskGenericNotify(%struct.tskTaskControlBlock* %76, i32 0, i32 4, i32* null)
  br label %78

; <label>:78:                                     ; preds = %73, %65
  %79 = load i32, i32* @plcTxBufTail, align 4
  %80 = add nsw i32 %79, 1
  %81 = and i32 %80, 7
  store i32 %81, i32* @plcTxBufTail, align 4
  %82 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @.str.6, i32 0, i32 0))
  %83 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xPLCSendSemaphore, align 8
  %84 = call i64 @xQueueGenericSend(%struct.QueueDefinition* %83, i8* null, i16 zeroext 0, i64 0)
  br label %88

; <label>:85:                                     ; preds = %7
  %86 = load i32, i32* %3, align 4
  %87 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([43 x i8], [43 x i8]* @.str.7, i32 0, i32 0), i32 %86)
  br label %88

; <label>:88:                                     ; preds = %85, %78, %62, %37, %14
  br label %7
                                                  ; No predecessors!
  ret void
}

declare i32 @ulTaskNotifyTake(i64, i16 zeroext) #1

; Function Attrs: noinline optnone uwtable
define internal void @_ZL41handleReceivedDataBasingOnCommandReceivedv() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca %struct.MqttData, align 1
  %4 = alloca i8, align 1
  %5 = call zeroext i8 @_Z15readPLCregisterh(i8 zeroext 73)
  %6 = zext i8 %5 to i32
  store i32 %6, i32* %1, align 4
  %7 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([30 x i8], [30 x i8]* @.str.11, i32 0, i32 0))
  store i32 -6, i32* %2, align 4
  %8 = load i32, i32* %1, align 4
  switch i32 %8, label %36 [
    i32 48, label %9
    i32 50, label %15
    i32 49, label %22
    i32 52, label %23
    i32 51, label %24
    i32 53, label %25
    i32 54, label %26
    i32 55, label %35
  ]

; <label>:9:                                      ; preds = %0
  %10 = load volatile i32, i32* @devType, align 4
  %11 = icmp eq i32 %10, 2
  br i1 %11, label %12, label %14

; <label>:12:                                     ; preds = %9
  %13 = call i64 @xTaskCreate(void (i8*)* @_Z21registerNewClientTaskPv, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.12, i32 0, i32 0), i16 zeroext 256, i8* null, i64 4, %struct.tskTaskControlBlock** @xTaskNewClientRegis)
  br label %14

; <label>:14:                                     ; preds = %12, %9
  br label %36

; <label>:15:                                     ; preds = %0
  %16 = load %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** @xTaskNewClientRegis, align 8
  %17 = icmp ne %struct.tskTaskControlBlock* %16, null
  br i1 %17, label %18, label %21

; <label>:18:                                     ; preds = %15
  %19 = load %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** @xTaskNewClientRegis, align 8
  %20 = call i64 @xTaskGenericNotify(%struct.tskTaskControlBlock* %19, i32 1, i32 4, i32* null)
  br label %21

; <label>:21:                                     ; preds = %18, %15
  br label %36

; <label>:22:                                     ; preds = %0
  store i32 -4, i32* %2, align 4
  br label %36

; <label>:23:                                     ; preds = %0
  store i32 2, i32* %2, align 4
  br label %36

; <label>:24:                                     ; preds = %0
  store i32 1, i32* %2, align 4
  br label %36

; <label>:25:                                     ; preds = %0
  store i32 3, i32* %2, align 4
  br label %36

; <label>:26:                                     ; preds = %0
  %27 = getelementptr inbounds %struct.MqttData, %struct.MqttData* %3, i32 0, i32 1
  %28 = getelementptr inbounds [8 x i8], [8 x i8]* %27, i32 0, i32 0
  call void @_Z10getPLCrxSAPh(i8* %28)
  %29 = getelementptr inbounds %struct.MqttData, %struct.MqttData* %3, i32 0, i32 0
  %30 = getelementptr inbounds [32 x i8], [32 x i8]* %29, i32 0, i32 0
  %31 = getelementptr inbounds %struct.MqttData, %struct.MqttData* %3, i32 0, i32 3
  call void @_Z15readPLCrxPacketPhS_S_(i8* null, i8* %30, i8* %31)
  %32 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xMqttQueue, align 8
  %33 = bitcast %struct.MqttData* %3 to i8*
  %34 = call i64 @xQueueGenericSend(%struct.QueueDefinition* %32, i8* %33, i16 zeroext 0, i64 0)
  br label %36

; <label>:35:                                     ; preds = %0
  call void @_Z15readPLCrxPacketPhS_S_(i8* null, i8* %4, i8* null)
  br label %36

; <label>:36:                                     ; preds = %0, %35, %26, %25, %24, %23, %22, %21, %14
  %37 = load i32, i32* %2, align 4
  %38 = icmp ne i32 %37, -6
  br i1 %38, label %39, label %46

; <label>:39:                                     ; preds = %36
  %40 = load volatile %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** @_ZL29xClientSideRegistrationHandle, align 8
  %41 = icmp ne %struct.tskTaskControlBlock* %40, null
  br i1 %41, label %42, label %46

; <label>:42:                                     ; preds = %39
  %43 = load volatile %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** @_ZL29xClientSideRegistrationHandle, align 8
  %44 = load i32, i32* %2, align 4
  %45 = call i64 @xTaskGenericNotify(%struct.tskTaskControlBlock* %43, i32 %44, i32 4, i32* null)
  br label %46

; <label>:46:                                     ; preds = %42, %39, %36
  ret void
}

declare i64 @xTaskGenericNotify(%struct.tskTaskControlBlock*, i32, i32, i32*) #1

declare i64 @xQueueGenericSend(%struct.QueueDefinition*, i8*, i16 zeroext, i64) #1

; Function Attrs: noinline optnone uwtable
define void @_Z11plcTaskSendPv(i8*) #0 {
  %2 = alloca i8*, align 8
  %3 = alloca %struct.PlcTxRecord*, align 8
  store i8* %0, i8** %2, align 8
  %4 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xPLCSendSemaphore, align 8
  %5 = call i64 @xQueueGenericSend(%struct.QueueDefinition* %4, i8* null, i16 zeroext 0, i64 0)
  br label %6

; <label>:6:                                      ; preds = %67, %1
  %7 = call i32 @ulTaskNotifyTake(i64 1, i16 zeroext 10)
  %8 = load i32, i32* @plcTxBufHead, align 4
  %9 = load i32, i32* @plcTxBufTail, align 4
  %10 = icmp ne i32 %8, %9
  br i1 %10, label %11, label %67

; <label>:11:                                     ; preds = %6
  %12 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xPLCSendSemaphore, align 8
  %13 = call i64 @xQueueSemaphoreTake(%struct.QueueDefinition* %12, i16 zeroext 0)
  %14 = icmp ne i64 %13, 0
  br i1 %14, label %15, label %66

; <label>:15:                                     ; preds = %11
  %16 = load i32, i32* @plcTxBufTail, align 4
  %17 = sext i32 %16 to i64
  %18 = getelementptr inbounds [8 x %struct.PlcTxRecord], [8 x %struct.PlcTxRecord]* @plcTxBuf, i64 0, i64 %17
  store %struct.PlcTxRecord* %18, %struct.PlcTxRecord** %3, align 8
  %19 = load %struct.PlcTxRecord*, %struct.PlcTxRecord** %3, align 8
  %20 = getelementptr inbounds %struct.PlcTxRecord, %struct.PlcTxRecord* %19, i32 0, i32 4
  %21 = load i8, i8* %20, align 1
  %22 = zext i8 %21 to i32
  %23 = load %struct.PlcTxRecord*, %struct.PlcTxRecord** %3, align 8
  %24 = getelementptr inbounds %struct.PlcTxRecord, %struct.PlcTxRecord* %23, i32 0, i32 0
  %25 = getelementptr inbounds [32 x i8], [32 x i8]* %24, i32 0, i32 0
  %26 = load %struct.PlcTxRecord*, %struct.PlcTxRecord** %3, align 8
  %27 = getelementptr inbounds %struct.PlcTxRecord, %struct.PlcTxRecord* %26, i32 0, i32 4
  %28 = load i8, i8* %27, align 1
  %29 = zext i8 %28 to i32
  %30 = load %struct.PlcTxRecord*, %struct.PlcTxRecord** %3, align 8
  %31 = getelementptr inbounds %struct.PlcTxRecord, %struct.PlcTxRecord* %30, i32 0, i32 3
  %32 = load i8, i8* %31, align 8
  %33 = zext i8 %32 to i32
  %34 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([54 x i8], [54 x i8]* @.str.8, i32 0, i32 0), i32 %22, i8* %25, i32 %29, i32 %33)
  %35 = load %struct.PlcTxRecord*, %struct.PlcTxRecord** %3, align 8
  %36 = getelementptr inbounds %struct.PlcTxRecord, %struct.PlcTxRecord* %35, i32 0, i32 4
  %37 = load i8, i8* %36, align 1
  %38 = icmp ne i8 %37, 0
  br i1 %38, label %39, label %46

; <label>:39:                                     ; preds = %15
  %40 = load %struct.PlcTxRecord*, %struct.PlcTxRecord** %3, align 8
  %41 = getelementptr inbounds %struct.PlcTxRecord, %struct.PlcTxRecord* %40, i32 0, i32 0
  %42 = getelementptr inbounds [32 x i8], [32 x i8]* %41, i32 0, i32 0
  %43 = load %struct.PlcTxRecord*, %struct.PlcTxRecord** %3, align 8
  %44 = getelementptr inbounds %struct.PlcTxRecord, %struct.PlcTxRecord* %43, i32 0, i32 4
  %45 = load i8, i8* %44, align 1
  call void @_Z13fillPLCTxDataPhh(i8* %42, i8 zeroext %45)
  br label %46

; <label>:46:                                     ; preds = %39, %15
  %47 = load %struct.PlcTxRecord*, %struct.PlcTxRecord** %3, align 8
  %48 = getelementptr inbounds %struct.PlcTxRecord, %struct.PlcTxRecord* %47, i32 0, i32 1
  %49 = getelementptr inbounds [8 x i8], [8 x i8]* %48, i64 0, i64 0
  %50 = load i8, i8* %49, align 8
  %51 = icmp ne i8 %50, 0
  br i1 %51, label %52, label %56

; <label>:52:                                     ; preds = %46
  %53 = load %struct.PlcTxRecord*, %struct.PlcTxRecord** %3, align 8
  %54 = getelementptr inbounds %struct.PlcTxRecord, %struct.PlcTxRecord* %53, i32 0, i32 1
  %55 = getelementptr inbounds [8 x i8], [8 x i8]* %54, i32 0, i32 0
  call void @_Z10setPLCtxDAhPh(i8 zeroext 64, i8* %55)
  br label %56

; <label>:56:                                     ; preds = %52, %46
  %57 = load %struct.PlcTxRecord*, %struct.PlcTxRecord** %3, align 8
  %58 = getelementptr inbounds %struct.PlcTxRecord, %struct.PlcTxRecord* %57, i32 0, i32 3
  %59 = load i8, i8* %58, align 8
  call void @_Z16writePLCregisterhh(i8 zeroext 16, i8 zeroext %59)
  %60 = load %struct.PlcTxRecord*, %struct.PlcTxRecord** %3, align 8
  %61 = getelementptr inbounds %struct.PlcTxRecord, %struct.PlcTxRecord* %60, i32 0, i32 4
  %62 = load i8, i8* %61, align 1
  %63 = zext i8 %62 to i32
  %64 = or i32 %63, 128
  %65 = trunc i32 %64 to i8
  call void @_Z16writePLCregisterhh(i8 zeroext 6, i8 zeroext %65)
  br label %66

; <label>:66:                                     ; preds = %56, %11
  br label %67

; <label>:67:                                     ; preds = %66, %6
  br label %6
                                                  ; No predecessors!
  ret void
}

declare i64 @xQueueSemaphoreTake(%struct.QueueDefinition*, i16 zeroext) #1

; Function Attrs: noinline optnone uwtable
define i32 @_Z14registerClientP10ConfigData(%struct.ConfigData*) #0 {
  %2 = alloca %struct.ConfigData*, align 8
  %3 = alloca [8 x i8], align 1
  %4 = alloca %struct.tskTaskControlBlock*, align 8
  %5 = alloca i32, align 4
  %6 = alloca i8, align 1
  store %struct.ConfigData* %0, %struct.ConfigData** %2, align 8
  %7 = getelementptr inbounds [8 x i8], [8 x i8]* %3, i32 0, i32 0
  %8 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %9 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %8, i32 0, i32 2
  %10 = getelementptr inbounds [17 x i8], [17 x i8]* %9, i32 0, i32 0
  call void @_Z25convertPlcPhyAddressToRawPhPc(i8* %7, i8* %10)
  %11 = call %struct.tskTaskControlBlock* @xTaskGetCurrentTaskHandle()
  store %struct.tskTaskControlBlock* %11, %struct.tskTaskControlBlock** %4, align 8
  %12 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %13 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %12, i32 0, i32 4
  %14 = getelementptr inbounds [33 x i8], [33 x i8]* %13, i32 0, i32 0
  %15 = getelementptr inbounds [8 x i8], [8 x i8]* %3, i32 0, i32 0
  %16 = load %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** %4, align 8
  %17 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %18 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %17, i32 0, i32 8
  %19 = load i8, i8* %18, align 2
  %20 = call i32 @_Z11sendPlcDataPhS_P19tskTaskControlBlockhh(i8* %14, i8* %15, %struct.tskTaskControlBlock* %16, i8 zeroext 48, i8 zeroext %19)
  store i32 %20, i32* %5, align 4
  %21 = load i32, i32* %5, align 4
  %22 = icmp sge i32 %21, 0
  br i1 %22, label %23, label %88

; <label>:23:                                     ; preds = %1
  %24 = load %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** %4, align 8
  store volatile %struct.tskTaskControlBlock* %24, %struct.tskTaskControlBlock** @_ZL29xClientSideRegistrationHandle, align 8
  %25 = call i64 @xTaskNotifyWait(i32 0, i32 -1, i32* %5, i16 zeroext 3000)
  %26 = icmp ne i64 %25, 1
  br i1 %26, label %27, label %28

; <label>:27:                                     ; preds = %23
  store i32 -1, i32* %5, align 4
  br label %28

; <label>:28:                                     ; preds = %27, %23
  %29 = load i32, i32* %5, align 4
  %30 = icmp eq i32 %29, 1
  br i1 %30, label %31, label %86

; <label>:31:                                     ; preds = %28
  %32 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %33 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %32, i32 0, i32 0
  %34 = getelementptr inbounds [33 x i8], [33 x i8]* %33, i32 0, i32 0
  %35 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %36 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %35, i32 0, i32 6
  call void @_Z15readPLCrxPacketPhS_S_(i8* null, i8* %34, i8* %36)
  %37 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %38 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %37, i32 0, i32 0
  %39 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %40 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %39, i32 0, i32 6
  %41 = load i8, i8* %40, align 4
  %42 = zext i8 %41 to i64
  %43 = getelementptr inbounds [33 x i8], [33 x i8]* %38, i64 0, i64 %42
  store i8 0, i8* %43, align 1
  %44 = call i64 @xTaskNotifyWait(i32 0, i32 -1, i32* %5, i16 zeroext 3000)
  %45 = icmp ne i64 %44, 1
  br i1 %45, label %46, label %47

; <label>:46:                                     ; preds = %31
  store i32 -1, i32* %5, align 4
  br label %47

; <label>:47:                                     ; preds = %46, %31
  %48 = load i32, i32* %5, align 4
  %49 = icmp eq i32 %48, 2
  br i1 %49, label %50, label %84

; <label>:50:                                     ; preds = %47
  %51 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %52 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %51, i32 0, i32 1
  %53 = getelementptr inbounds [65 x i8], [65 x i8]* %52, i32 0, i32 0
  %54 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %55 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %54, i32 0, i32 7
  call void @_Z15readPLCrxPacketPhS_S_(i8* null, i8* %53, i8* %55)
  %56 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %57 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %56, i32 0, i32 1
  %58 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %59 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %58, i32 0, i32 7
  %60 = load i8, i8* %59, align 1
  %61 = zext i8 %60 to i64
  %62 = getelementptr inbounds [65 x i8], [65 x i8]* %57, i64 0, i64 %61
  store i8 0, i8* %62, align 1
  %63 = call i64 @xTaskNotifyWait(i32 0, i32 -1, i32* %5, i16 zeroext 3000)
  %64 = icmp ne i64 %63, 1
  br i1 %64, label %65, label %66

; <label>:65:                                     ; preds = %50
  store i32 -1, i32* %5, align 4
  br label %66

; <label>:66:                                     ; preds = %65, %50
  %67 = load i32, i32* %5, align 4
  %68 = icmp eq i32 %67, 3
  br i1 %68, label %69, label %82

; <label>:69:                                     ; preds = %66
  %70 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %71 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %70, i32 0, i32 3
  %72 = getelementptr inbounds [21 x i8], [21 x i8]* %71, i32 0, i32 0
  call void @_Z15readPLCrxPacketPhS_S_(i8* null, i8* %72, i8* %6)
  %73 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %74 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %73, i32 0, i32 3
  %75 = getelementptr inbounds [21 x i8], [21 x i8]* %74, i64 0, i64 20
  store i8 0, i8* %75, align 1
  %76 = load i8, i8* %6, align 1
  %77 = zext i8 %76 to i32
  %78 = icmp eq i32 %77, 20
  br i1 %78, label %79, label %81

; <label>:79:                                     ; preds = %69
  %80 = call i32 @_Z11sendPlcDataPhS_P19tskTaskControlBlockhh(i8* null, i8* null, %struct.tskTaskControlBlock* null, i8 zeroext 50, i8 zeroext 0)
  store i32 %80, i32* %5, align 4
  br label %81

; <label>:81:                                     ; preds = %79, %69
  br label %83

; <label>:82:                                     ; preds = %66
  store i32 -5, i32* %5, align 4
  br label %83

; <label>:83:                                     ; preds = %82, %81
  br label %85

; <label>:84:                                     ; preds = %47
  store i32 -5, i32* %5, align 4
  br label %85

; <label>:85:                                     ; preds = %84, %83
  br label %87

; <label>:86:                                     ; preds = %28
  store i32 -5, i32* %5, align 4
  br label %87

; <label>:87:                                     ; preds = %86, %85
  br label %88

; <label>:88:                                     ; preds = %87, %1
  store volatile %struct.tskTaskControlBlock* null, %struct.tskTaskControlBlock** @_ZL29xClientSideRegistrationHandle, align 8
  %89 = load i32, i32* %5, align 4
  ret i32 %89
}

declare void @_Z25convertPlcPhyAddressToRawPhPc(i8*, i8*) #1

declare %struct.tskTaskControlBlock* @xTaskGetCurrentTaskHandle() #1

; Function Attrs: noinline optnone uwtable
define i32 @_Z11sendPlcDataPhS_P19tskTaskControlBlockhh(i8*, i8*, %struct.tskTaskControlBlock*, i8 zeroext, i8 zeroext) #0 {
  %6 = alloca i8*, align 8
  %7 = alloca i8*, align 8
  %8 = alloca %struct.tskTaskControlBlock*, align 8
  %9 = alloca i8, align 1
  %10 = alloca i8, align 1
  %11 = alloca %struct.PlcTxRecord*, align 8
  %12 = alloca i32, align 4
  store i8* %0, i8** %6, align 8
  store i8* %1, i8** %7, align 8
  store %struct.tskTaskControlBlock* %2, %struct.tskTaskControlBlock** %8, align 8
  store i8 %3, i8* %9, align 1
  store i8 %4, i8* %10, align 1
  %13 = load i32, i32* @plcTxBufHead, align 4
  %14 = sext i32 %13 to i64
  %15 = getelementptr inbounds [8 x %struct.PlcTxRecord], [8 x %struct.PlcTxRecord]* @plcTxBuf, i64 0, i64 %14
  store %struct.PlcTxRecord* %15, %struct.PlcTxRecord** %11, align 8
  %16 = load i8, i8* %10, align 1
  %17 = load %struct.PlcTxRecord*, %struct.PlcTxRecord** %11, align 8
  %18 = getelementptr inbounds %struct.PlcTxRecord, %struct.PlcTxRecord* %17, i32 0, i32 4
  store i8 %16, i8* %18, align 1
  %19 = load i8, i8* %9, align 1
  %20 = load %struct.PlcTxRecord*, %struct.PlcTxRecord** %11, align 8
  %21 = getelementptr inbounds %struct.PlcTxRecord, %struct.PlcTxRecord* %20, i32 0, i32 3
  store i8 %19, i8* %21, align 8
  %22 = load %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** %8, align 8
  %23 = load %struct.PlcTxRecord*, %struct.PlcTxRecord** %11, align 8
  %24 = getelementptr inbounds %struct.PlcTxRecord, %struct.PlcTxRecord* %23, i32 0, i32 2
  store %struct.tskTaskControlBlock* %22, %struct.tskTaskControlBlock** %24, align 8
  %25 = load i8*, i8** %7, align 8
  %26 = icmp ne i8* %25, null
  br i1 %26, label %27, label %32

; <label>:27:                                     ; preds = %5
  %28 = load %struct.PlcTxRecord*, %struct.PlcTxRecord** %11, align 8
  %29 = getelementptr inbounds %struct.PlcTxRecord, %struct.PlcTxRecord* %28, i32 0, i32 1
  %30 = getelementptr inbounds [8 x i8], [8 x i8]* %29, i32 0, i32 0
  %31 = load i8*, i8** %7, align 8
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %30, i8* %31, i64 8, i32 1, i1 false)
  br label %36

; <label>:32:                                     ; preds = %5
  %33 = load %struct.PlcTxRecord*, %struct.PlcTxRecord** %11, align 8
  %34 = getelementptr inbounds %struct.PlcTxRecord, %struct.PlcTxRecord* %33, i32 0, i32 1
  %35 = getelementptr inbounds [8 x i8], [8 x i8]* %34, i64 0, i64 0
  store i8 0, i8* %35, align 8
  br label %36

; <label>:36:                                     ; preds = %32, %27
  %37 = load i8, i8* %10, align 1
  %38 = icmp ne i8 %37, 0
  br i1 %38, label %39, label %46

; <label>:39:                                     ; preds = %36
  %40 = load %struct.PlcTxRecord*, %struct.PlcTxRecord** %11, align 8
  %41 = getelementptr inbounds %struct.PlcTxRecord, %struct.PlcTxRecord* %40, i32 0, i32 0
  %42 = getelementptr inbounds [32 x i8], [32 x i8]* %41, i32 0, i32 0
  %43 = load i8*, i8** %6, align 8
  %44 = load i8, i8* %10, align 1
  %45 = zext i8 %44 to i64
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %42, i8* %43, i64 %45, i32 1, i1 false)
  br label %46

; <label>:46:                                     ; preds = %39, %36
  %47 = load i32, i32* @plcTxBufHead, align 4
  %48 = add nsw i32 %47, 1
  %49 = and i32 %48, 7
  store i32 %49, i32* @plcTxBufHead, align 4
  %50 = load %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** @xPLCTaskSend, align 8
  %51 = call i64 @xTaskGenericNotify(%struct.tskTaskControlBlock* %50, i32 0, i32 2, i32* null)
  store i32 0, i32* %12, align 4
  %52 = load %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** %8, align 8
  %53 = icmp ne %struct.tskTaskControlBlock* %52, null
  br i1 %53, label %54, label %61

; <label>:54:                                     ; preds = %46
  %55 = call i64 @xTaskNotifyWait(i32 0, i32 -1, i32* %12, i16 zeroext 3000)
  %56 = icmp ne i64 %55, 1
  br i1 %56, label %57, label %60

; <label>:57:                                     ; preds = %54
  %58 = load %struct.PlcTxRecord*, %struct.PlcTxRecord** %11, align 8
  %59 = getelementptr inbounds %struct.PlcTxRecord, %struct.PlcTxRecord* %58, i32 0, i32 2
  store %struct.tskTaskControlBlock* null, %struct.tskTaskControlBlock** %59, align 8
  store i32 -1, i32* %12, align 4
  br label %60

; <label>:60:                                     ; preds = %57, %54
  br label %61

; <label>:61:                                     ; preds = %60, %46
  %62 = load i32, i32* %12, align 4
  ret i32 %62
}

declare i64 @xTaskNotifyWait(i32, i32, i32*, i16 zeroext) #1

; Function Attrs: noinline optnone uwtable
define void @_Z21registerNewClientTaskPv(i8*) #0 {
  %2 = alloca i8*, align 8
  %3 = alloca i8, align 1
  %4 = alloca i8, align 1
  %5 = alloca %struct.Client*, align 8
  %6 = alloca i32, align 4
  %7 = alloca %struct.sdk_station_config, align 4
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  %10 = alloca %struct.MqttData, align 1
  store i8* %0, i8** %2, align 8
  %11 = call i8* @pvPortMalloc(i64 56)
  %12 = bitcast i8* %11 to %struct.Client*
  store %struct.Client* %12, %struct.Client** %5, align 8
  %13 = load %struct.Client*, %struct.Client** %5, align 8
  %14 = getelementptr inbounds %struct.Client, %struct.Client* %13, i32 0, i32 2
  %15 = getelementptr inbounds [33 x i8], [33 x i8]* %14, i32 0, i32 0
  call void @_Z15readPLCrxPacketPhS_S_(i8* %4, i8* %15, i8* %3)
  %16 = load %struct.Client*, %struct.Client** %5, align 8
  %17 = getelementptr inbounds %struct.Client, %struct.Client* %16, i32 0, i32 2
  %18 = load i8, i8* %3, align 1
  %19 = zext i8 %18 to i64
  %20 = getelementptr inbounds [33 x i8], [33 x i8]* %17, i64 0, i64 %19
  store i8 0, i8* %20, align 1
  %21 = load %struct.Client*, %struct.Client** %5, align 8
  %22 = getelementptr inbounds %struct.Client, %struct.Client* %21, i32 0, i32 1
  %23 = getelementptr inbounds [8 x i8], [8 x i8]* %22, i32 0, i32 0
  call void @_Z10getPLCrxSAPh(i8* %23)
  store i32 0, i32* %6, align 4
  store i32 345, i32* %8, align 4
  store i32 3454, i32* %9, align 4
  %24 = load %struct.Client*, %struct.Client** %5, align 8
  %25 = getelementptr inbounds %struct.Client, %struct.Client* %24, i32 0, i32 1
  %26 = getelementptr inbounds [8 x i8], [8 x i8]* %25, i32 0, i32 0
  %27 = load %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** @xTaskNewClientRegis, align 8
  %28 = load i32, i32* %8, align 4
  %29 = trunc i32 %28 to i8
  %30 = call i32 @_Z11sendPlcDataPhS_P19tskTaskControlBlockhh(i8* null, i8* %26, %struct.tskTaskControlBlock* %27, i8 zeroext 51, i8 zeroext %29)
  store i32 %30, i32* %6, align 4
  %31 = load i32, i32* %6, align 4
  %32 = icmp sge i32 %31, 0
  br i1 %32, label %33, label %61

; <label>:33:                                     ; preds = %1
  %34 = load %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** @xTaskNewClientRegis, align 8
  %35 = load i32, i32* %9, align 4
  %36 = trunc i32 %35 to i8
  %37 = call i32 @_Z11sendPlcDataPhS_P19tskTaskControlBlockhh(i8* null, i8* null, %struct.tskTaskControlBlock* %34, i8 zeroext 52, i8 zeroext %36)
  store i32 %37, i32* %6, align 4
  %38 = load i32, i32* %6, align 4
  %39 = icmp sge i32 %38, 0
  br i1 %39, label %40, label %60

; <label>:40:                                     ; preds = %33
  %41 = call i8* @_Z10getTbTokenv()
  %42 = load %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** @xTaskNewClientRegis, align 8
  %43 = call i32 @_Z11sendPlcDataPhS_P19tskTaskControlBlockhh(i8* %41, i8* null, %struct.tskTaskControlBlock* %42, i8 zeroext 53, i8 zeroext 20)
  store i32 %43, i32* %6, align 4
  %44 = load i32, i32* %6, align 4
  %45 = icmp sge i32 %44, 0
  br i1 %45, label %46, label %59

; <label>:46:                                     ; preds = %40
  %47 = call i64 @xTaskNotifyWait(i32 0, i32 -1, i32* %6, i16 zeroext 4000)
  %48 = icmp ne i64 %47, 1
  br i1 %48, label %49, label %50

; <label>:49:                                     ; preds = %46
  store i32 -1, i32* %6, align 4
  br label %58

; <label>:50:                                     ; preds = %46
  %51 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([25 x i8], [25 x i8]* @.str.9, i32 0, i32 0))
  %52 = load %struct.Client*, %struct.Client** %5, align 8
  call void @_Z9addClientP6Client(%struct.Client* %52)
  %53 = load %struct.Client*, %struct.Client** %5, align 8
  call void @_Z20saveClientDataToFileP6Client(%struct.Client* %53)
  %54 = getelementptr inbounds %struct.MqttData, %struct.MqttData* %10, i32 0, i32 2
  store i8 2, i8* %54, align 1
  %55 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xMqttQueue, align 8
  %56 = bitcast %struct.MqttData* %10 to i8*
  %57 = call i64 @xQueueGenericSend(%struct.QueueDefinition* %55, i8* %56, i16 zeroext 0, i64 0)
  br label %58

; <label>:58:                                     ; preds = %50, %49
  br label %59

; <label>:59:                                     ; preds = %58, %40
  br label %60

; <label>:60:                                     ; preds = %59, %33
  br label %61

; <label>:61:                                     ; preds = %60, %1
  %62 = load i32, i32* %6, align 4
  %63 = icmp slt i32 %62, 0
  br i1 %63, label %64, label %70

; <label>:64:                                     ; preds = %61
  %65 = load %struct.Client*, %struct.Client** %5, align 8
  %66 = bitcast %struct.Client* %65 to i8*
  call void @vPortFree(i8* %66)
  %67 = call i32 @_Z11sendPlcDataPhS_P19tskTaskControlBlockhh(i8* null, i8* null, %struct.tskTaskControlBlock* null, i8 zeroext 49, i8 zeroext 0)
  %68 = load i32, i32* %6, align 4
  %69 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([30 x i8], [30 x i8]* @.str.10, i32 0, i32 0), i32 %68)
  br label %70

; <label>:70:                                     ; preds = %64, %61
  call void @vTaskDelete(%struct.tskTaskControlBlock* null)
  ret void
}

declare i8* @pvPortMalloc(i64) #1

declare i8* @_Z10getTbTokenv() #1

declare void @_Z9addClientP6Client(%struct.Client*) #1

declare void @_Z20saveClientDataToFileP6Client(%struct.Client*) #1

declare void @vPortFree(i8*) #1

; Function Attrs: noinline optnone uwtable
define void @_Z16changeRelayStateii(i32, i32) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca %struct.Client*, align 8
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  store i32 %0, i32* %3, align 4
  store i32 %1, i32* %4, align 4
  %8 = load i32, i32* %3, align 4
  %9 = icmp ne i32 %8, 1
  br i1 %9, label %10, label %46

; <label>:10:                                     ; preds = %2
  %11 = load %struct.Client*, %struct.Client** @clientListBegin, align 8
  store %struct.Client* %11, %struct.Client** %5, align 8
  store i32 1, i32* %6, align 4
  br label %12

; <label>:12:                                     ; preds = %21, %10
  %13 = load %struct.Client*, %struct.Client** %5, align 8
  %14 = icmp ne %struct.Client* %13, null
  br i1 %14, label %15, label %19

; <label>:15:                                     ; preds = %12
  %16 = load i32, i32* %6, align 4
  %17 = load i32, i32* %3, align 4
  %18 = icmp ne i32 %16, %17
  br label %19

; <label>:19:                                     ; preds = %15, %12
  %20 = phi i1 [ false, %12 ], [ %18, %15 ]
  br i1 %20, label %21, label %27

; <label>:21:                                     ; preds = %19
  %22 = load %struct.Client*, %struct.Client** %5, align 8
  %23 = getelementptr inbounds %struct.Client, %struct.Client* %22, i32 0, i32 0
  %24 = load %struct.Client*, %struct.Client** %23, align 8
  store %struct.Client* %24, %struct.Client** %5, align 8
  %25 = load i32, i32* %6, align 4
  %26 = add nsw i32 %25, 1
  store i32 %26, i32* %6, align 4
  br label %12

; <label>:27:                                     ; preds = %19
  %28 = load %struct.Client*, %struct.Client** %5, align 8
  %29 = icmp ne %struct.Client* %28, null
  br i1 %29, label %31, label %30

; <label>:30:                                     ; preds = %27
  br label %51

; <label>:31:                                     ; preds = %27
  %32 = bitcast i32* %4 to i8*
  %33 = load %struct.Client*, %struct.Client** %5, align 8
  %34 = getelementptr inbounds %struct.Client, %struct.Client* %33, i32 0, i32 1
  %35 = getelementptr inbounds [8 x i8], [8 x i8]* %34, i32 0, i32 0
  %36 = call %struct.tskTaskControlBlock* @xTaskGetCurrentTaskHandle()
  %37 = call i32 @_Z11sendPlcDataPhS_P19tskTaskControlBlockhh(i8* %32, i8* %35, %struct.tskTaskControlBlock* %36, i8 zeroext 55, i8 zeroext 1)
  store i32 %37, i32* %7, align 4
  %38 = load i32, i32* %7, align 4
  %39 = icmp eq i32 %38, 0
  br i1 %39, label %40, label %45

; <label>:40:                                     ; preds = %31
  %41 = load i32, i32* %4, align 4
  %42 = trunc i32 %41 to i8
  %43 = load %struct.Client*, %struct.Client** %5, align 8
  %44 = getelementptr inbounds %struct.Client, %struct.Client* %43, i32 0, i32 3
  store i8 %42, i8* %44, align 1
  br label %45

; <label>:45:                                     ; preds = %40, %31
  br label %51

; <label>:46:                                     ; preds = %2
  %47 = load i32, i32* %4, align 4
  %48 = trunc i32 %47 to i8
  %49 = load %struct.Client*, %struct.Client** @clientListBegin, align 8
  %50 = getelementptr inbounds %struct.Client, %struct.Client* %49, i32 0, i32 3
  store volatile i8 %48, i8* %50, align 1
  br label %51

; <label>:51:                                     ; preds = %30, %46, %45
  ret void
}

declare i64 @xTaskCreate(void (i8*)*, i8*, i16 zeroext, i8*, i64, %struct.tskTaskControlBlock**) #1

attributes #0 = { noinline optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { argmemonly nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
