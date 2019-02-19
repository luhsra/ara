; ModuleID = 'http_server.cc'
source_filename = "http_server.cc"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.tskTaskControlBlock = type opaque
%struct.tcp_pcb = type { i32 }
%struct.QueueDefinition = type opaque
%struct.ConfigData = type { [33 x i8], [65 x i8], [17 x i8], [21 x i8], [33 x i8], i32, i8, i8, i8 }

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
@.str = private unnamed_addr constant [6 x i8] c"casdf\00", align 1
@xHTTPServerTask = global %struct.tskTaskControlBlock* null, align 8
@websocketClbkUse = global i32 0, align 4
@wsPCB = global %struct.tcp_pcb* null, align 8
@wifiConnectionSuccessJson = global [114 x i8] c"{\22data\22:\22stopWs\22,\22msg\22:\22Connection successful. Closing access point. Save the PLC Phy Address: ----------------\22}\00", align 16
@wifiConnectionSuccessJsonLen = global i8 113, align 1
@_ZL24wifiConnectionFailedJson = internal constant [52 x i8] c"{\22data\22:\22enableButtons\22,\22msg\22:\22Could not connect.\22}\00", align 16
@_ZL21wifiWrongPasswordJson = internal constant [53 x i8] c"{\22data\22:\22enableButtons\22,\22msg\22:\22Wrong wifi password\22}\00", align 16
@_ZL17wifiNoAPFoundJson = internal constant [46 x i8] c"{\22data\22:\22enableButtons\22,\22msg\22:\22No AP found.\22}\00", align 16
@wifiJsonStrings = global [5 x i8*] [i8* getelementptr inbounds ([52 x i8], [52 x i8]* @_ZL24wifiConnectionFailedJson, i32 0, i32 0), i8* getelementptr inbounds ([52 x i8], [52 x i8]* @_ZL24wifiConnectionFailedJson, i32 0, i32 0), i8* getelementptr inbounds ([53 x i8], [53 x i8]* @_ZL21wifiWrongPasswordJson, i32 0, i32 0), i8* getelementptr inbounds ([46 x i8], [46 x i8]* @_ZL17wifiNoAPFoundJson, i32 0, i32 0), i8* getelementptr inbounds ([52 x i8], [52 x i8]* @_ZL24wifiConnectionFailedJson, i32 0, i32 0)], align 16
@wifiJsonStringsLen = constant [5 x i8] c"334-3", align 1
@plcJsonRegisSuccessStr = constant [79 x i8] c"{\22data\22:\22stopWs\22,\22msg\22:\22Succesfully registered client. Closing access point.\22}\00", align 16
@plcJsonRegisUnsuccessStr = constant [91 x i8] c"{\22data\22:\22enableButtons\22,\22msg\22:\22Client registration error. Please, check PLC Phy address.\22}\00", align 16
@plcJsonRegisSuccessStrLen = constant i8 78, align 1
@plcJsonRegisUnsuccessStrLen = constant i8 90, align 1
@.str.1 = private unnamed_addr constant [21 x i8] c"JSON Parsing failed\0A\00", align 1
@.str.2 = private unnamed_addr constant [6 x i8] c"%.*s\0A\00", align 1
@.str.3 = private unnamed_addr constant [5 x i8] c"ssid\00", align 1
@.str.4 = private unnamed_addr constant [8 x i8] c"phyaddr\00", align 1
@.str.5 = private unnamed_addr constant [12 x i8] c"/index.html\00", align 1
@.str.6 = private unnamed_addr constant [28 x i8] c"[websocket_callback]:\0A%.*s\0A\00", align 1
@.str.7 = private unnamed_addr constant [4 x i8] c"ACK\00", align 1
@_ZL19xWSGetAckTaskHandle = internal global %struct.tskTaskControlBlock* null, align 8
@.str.8 = private unnamed_addr constant [12 x i8] c"WS URI: %s\0A\00", align 1
@.str.9 = private unnamed_addr constant [12 x i8] c"/set-config\00", align 1
@.str.10 = private unnamed_addr constant [12 x i8] c"Set config\0A\00", align 1
@.str.11 = private unnamed_addr constant [16 x i8] c"Uri not found\0A\0D\00", align 1
@xConfiguratorQueue = external global %struct.QueueDefinition*, align 8
@.str.12 = private unnamed_addr constant [7 x i8] c"%s %s\0A\00", align 1

; Function Attrs: noinline optnone uwtable
define void @_Z28websocket_register_callbacksPFvP7tcp_pcbPKcEPFvS0_PhihE(void (%struct.tcp_pcb*, i8*)*, void (%struct.tcp_pcb*, i8*, i32, i8)*) #0 {
  %3 = alloca void (%struct.tcp_pcb*, i8*)*, align 8
  %4 = alloca void (%struct.tcp_pcb*, i8*, i32, i8)*, align 8
  %5 = alloca %struct.tcp_pcb, align 4
  %6 = alloca i8, align 1
  store void (%struct.tcp_pcb*, i8*)* %0, void (%struct.tcp_pcb*, i8*)** %3, align 8
  store void (%struct.tcp_pcb*, i8*, i32, i8)* %1, void (%struct.tcp_pcb*, i8*, i32, i8)** %4, align 8
  store i8 32, i8* %6, align 1
  %7 = load void (%struct.tcp_pcb*, i8*)*, void (%struct.tcp_pcb*, i8*)** %3, align 8
  call void %7(%struct.tcp_pcb* %5, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str, i32 0, i32 0))
  %8 = load void (%struct.tcp_pcb*, i8*, i32, i8)*, void (%struct.tcp_pcb*, i8*, i32, i8)** %4, align 8
  call void %8(%struct.tcp_pcb* %5, i8* %6, i32 324, i8 zeroext 68)
  ret void
}

; Function Attrs: noinline optnone uwtable
define void @_Z9setConfigPciP7tcp_pcb(i8*, i32, %struct.tcp_pcb*) #0 {
  %4 = alloca i8*, align 8
  %5 = alloca i32, align 4
  %6 = alloca %struct.tcp_pcb*, align 8
  %7 = alloca [10 x i8], align 1
  %8 = alloca i32, align 4
  %9 = alloca i8*, align 8
  %10 = alloca i32, align 4
  store i8* %0, i8** %4, align 8
  store i32 %1, i32* %5, align 4
  store %struct.tcp_pcb* %2, %struct.tcp_pcb** %6, align 8
  store i32 34, i32* %8, align 4
  %11 = load i32, i32* %8, align 4
  %12 = icmp slt i32 %11, 0
  br i1 %12, label %13, label %15

; <label>:13:                                     ; preds = %3
  %14 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([21 x i8], [21 x i8]* @.str.1, i32 0, i32 0))
  br label %50

; <label>:15:                                     ; preds = %3
  %16 = load i8*, i8** %4, align 8
  %17 = getelementptr inbounds [10 x i8], [10 x i8]* %7, i64 0, i64 1
  %18 = load i8, i8* %17, align 1
  %19 = sext i8 %18 to i32
  %20 = sext i32 %19 to i64
  %21 = getelementptr inbounds i8, i8* %16, i64 %20
  store i8* %21, i8** %9, align 8
  %22 = getelementptr inbounds [10 x i8], [10 x i8]* %7, i64 0, i64 1
  %23 = load i8, i8* %22, align 1
  %24 = sext i8 %23 to i32
  %25 = getelementptr inbounds [10 x i8], [10 x i8]* %7, i64 0, i64 1
  %26 = load i8, i8* %25, align 1
  %27 = sext i8 %26 to i32
  %28 = sub nsw i32 %24, %27
  store i32 %28, i32* %10, align 4
  %29 = load i32, i32* %10, align 4
  %30 = load i8*, i8** %9, align 8
  %31 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.2, i32 0, i32 0), i32 %29, i8* %30)
  %32 = load i8*, i8** %9, align 8
  %33 = load i32, i32* %10, align 4
  %34 = sext i32 %33 to i64
  %35 = call i32 @strncmp(i8* %32, i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.3, i32 0, i32 0), i64 %34) #5
  %36 = icmp ne i32 %35, 0
  br i1 %36, label %40, label %37

; <label>:37:                                     ; preds = %15
  %38 = load i8*, i8** %4, align 8
  %39 = getelementptr inbounds [10 x i8], [10 x i8]* %7, i32 0, i32 0
  call void @_ZL39sendGatewayConfigDataToConfiguratorTaskPcS_(i8* %38, i8* %39)
  br label %50

; <label>:40:                                     ; preds = %15
  %41 = load i8*, i8** %9, align 8
  %42 = load i32, i32* %10, align 4
  %43 = sext i32 %42 to i64
  %44 = call i32 @strncmp(i8* %41, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.4, i32 0, i32 0), i64 %43) #5
  %45 = icmp ne i32 %44, 0
  br i1 %45, label %49, label %46

; <label>:46:                                     ; preds = %40
  %47 = load i8*, i8** %4, align 8
  %48 = getelementptr inbounds [10 x i8], [10 x i8]* %7, i32 0, i32 0
  call void @_ZL38sendClientConfigDataToConfiguratorTaskPcS_(i8* %47, i8* %48)
  br label %49

; <label>:49:                                     ; preds = %46, %40
  br label %50

; <label>:50:                                     ; preds = %13, %49, %37
  ret void
}

declare i32 @printf(i8*, ...) #1

; Function Attrs: nounwind readonly
declare i32 @strncmp(i8*, i8*, i64) #2

; Function Attrs: noinline optnone uwtable
define internal void @_ZL39sendGatewayConfigDataToConfiguratorTaskPcS_(i8*, i8*) #0 {
  %3 = alloca i8*, align 8
  %4 = alloca i8*, align 8
  %5 = alloca %struct.ConfigData, align 4
  %6 = alloca i8*, align 8
  %7 = alloca i32, align 4
  %8 = alloca i8*, align 8
  %9 = alloca i32, align 4
  %10 = alloca i8*, align 8
  %11 = alloca i8*, align 8
  %12 = alloca i32, align 4
  store i8* %0, i8** %3, align 8
  store i8* %1, i8** %4, align 8
  %13 = load i8*, i8** %3, align 8
  %14 = load i8*, i8** %4, align 8
  %15 = getelementptr inbounds i8, i8* %14, i64 2
  %16 = load i8, i8* %15, align 1
  %17 = sext i8 %16 to i32
  %18 = sext i32 %17 to i64
  %19 = getelementptr inbounds i8, i8* %13, i64 %18
  store i8* %19, i8** %6, align 8
  %20 = load i8*, i8** %4, align 8
  %21 = getelementptr inbounds i8, i8* %20, i64 2
  %22 = load i8, i8* %21, align 1
  %23 = sext i8 %22 to i32
  %24 = load i8*, i8** %4, align 8
  %25 = getelementptr inbounds i8, i8* %24, i64 2
  %26 = load i8, i8* %25, align 1
  %27 = sext i8 %26 to i32
  %28 = sub nsw i32 %23, %27
  store i32 %28, i32* %7, align 4
  %29 = load i8*, i8** %3, align 8
  %30 = load i8*, i8** %4, align 8
  %31 = getelementptr inbounds i8, i8* %30, i64 4
  %32 = load i8, i8* %31, align 1
  %33 = sext i8 %32 to i32
  %34 = sext i32 %33 to i64
  %35 = getelementptr inbounds i8, i8* %29, i64 %34
  store i8* %35, i8** %8, align 8
  %36 = load i8*, i8** %4, align 8
  %37 = getelementptr inbounds i8, i8* %36, i64 4
  %38 = load i8, i8* %37, align 1
  %39 = sext i8 %38 to i32
  %40 = load i8*, i8** %4, align 8
  %41 = getelementptr inbounds i8, i8* %40, i64 4
  %42 = load i8, i8* %41, align 1
  %43 = sext i8 %42 to i32
  %44 = sub nsw i32 %39, %43
  store i32 %44, i32* %9, align 4
  %45 = load i8*, i8** %3, align 8
  %46 = load i8*, i8** %4, align 8
  %47 = getelementptr inbounds i8, i8* %46, i64 6
  %48 = load i8, i8* %47, align 1
  %49 = sext i8 %48 to i32
  %50 = sext i32 %49 to i64
  %51 = getelementptr inbounds i8, i8* %45, i64 %50
  store i8* %51, i8** %10, align 8
  %52 = load i8*, i8** %3, align 8
  %53 = load i8*, i8** %4, align 8
  %54 = getelementptr inbounds i8, i8* %53, i64 8
  %55 = load i8, i8* %54, align 1
  %56 = sext i8 %55 to i32
  %57 = sext i32 %56 to i64
  %58 = getelementptr inbounds i8, i8* %52, i64 %57
  store i8* %58, i8** %11, align 8
  %59 = load i8*, i8** %4, align 8
  %60 = getelementptr inbounds i8, i8* %59, i64 8
  %61 = load i8, i8* %60, align 1
  %62 = sext i8 %61 to i32
  %63 = load i8*, i8** %4, align 8
  %64 = getelementptr inbounds i8, i8* %63, i64 8
  %65 = load i8, i8* %64, align 1
  %66 = sext i8 %65 to i32
  %67 = sub nsw i32 %62, %66
  store i32 %67, i32* %12, align 4
  %68 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %5, i32 0, i32 0
  %69 = getelementptr inbounds [33 x i8], [33 x i8]* %68, i32 0, i32 0
  %70 = load i8*, i8** %6, align 8
  %71 = load i32, i32* %7, align 4
  %72 = sext i32 %71 to i64
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %69, i8* %70, i64 %72, i32 1, i1 false)
  %73 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %5, i32 0, i32 1
  %74 = getelementptr inbounds [65 x i8], [65 x i8]* %73, i32 0, i32 0
  %75 = load i8*, i8** %8, align 8
  %76 = load i32, i32* %9, align 4
  %77 = sext i32 %76 to i64
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %74, i8* %75, i64 %77, i32 1, i1 false)
  %78 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %5, i32 0, i32 3
  %79 = getelementptr inbounds [21 x i8], [21 x i8]* %78, i32 0, i32 0
  %80 = load i8*, i8** %10, align 8
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %79, i8* %80, i64 20, i32 1, i1 false)
  %81 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %5, i32 0, i32 4
  %82 = getelementptr inbounds [33 x i8], [33 x i8]* %81, i32 0, i32 0
  %83 = load i8*, i8** %11, align 8
  %84 = load i32, i32* %12, align 4
  %85 = sext i32 %84 to i64
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %82, i8* %83, i64 %85, i32 1, i1 false)
  %86 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %5, i32 0, i32 4
  %87 = load i32, i32* %12, align 4
  %88 = sext i32 %87 to i64
  %89 = getelementptr inbounds [33 x i8], [33 x i8]* %86, i64 0, i64 %88
  store i8 0, i8* %89, align 1
  %90 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %5, i32 0, i32 3
  %91 = getelementptr inbounds [21 x i8], [21 x i8]* %90, i64 0, i64 20
  store i8 0, i8* %91, align 1
  %92 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %5, i32 0, i32 1
  %93 = load i32, i32* %9, align 4
  %94 = sext i32 %93 to i64
  %95 = getelementptr inbounds [65 x i8], [65 x i8]* %92, i64 0, i64 %94
  store i8 0, i8* %95, align 1
  %96 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %5, i32 0, i32 0
  %97 = load i32, i32* %7, align 4
  %98 = sext i32 %97 to i64
  %99 = getelementptr inbounds [33 x i8], [33 x i8]* %96, i64 0, i64 %98
  store i8 0, i8* %99, align 1
  %100 = load i32, i32* %7, align 4
  %101 = trunc i32 %100 to i8
  %102 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %5, i32 0, i32 6
  store i8 %101, i8* %102, align 4
  %103 = load i32, i32* %9, align 4
  %104 = trunc i32 %103 to i8
  %105 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %5, i32 0, i32 7
  store i8 %104, i8* %105, align 1
  %106 = load i32, i32* %12, align 4
  %107 = trunc i32 %106 to i8
  %108 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %5, i32 0, i32 8
  store i8 %107, i8* %108, align 2
  %109 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %5, i32 0, i32 5
  store i32 0, i32* %109, align 4
  %110 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xConfiguratorQueue, align 8
  %111 = bitcast %struct.ConfigData* %5 to i8*
  %112 = call i64 @xQueueGenericSend(%struct.QueueDefinition* %110, i8* %111, i16 zeroext 0, i64 0)
  ret void
}

; Function Attrs: noinline optnone uwtable
define internal void @_ZL38sendClientConfigDataToConfiguratorTaskPcS_(i8*, i8*) #0 {
  %3 = alloca i8*, align 8
  %4 = alloca i8*, align 8
  %5 = alloca %struct.ConfigData, align 4
  %6 = alloca i8*, align 8
  %7 = alloca i8*, align 8
  %8 = alloca i32, align 4
  store i8* %0, i8** %3, align 8
  store i8* %1, i8** %4, align 8
  %9 = load i8*, i8** %3, align 8
  %10 = load i8*, i8** %4, align 8
  %11 = getelementptr inbounds i8, i8* %10, i64 2
  %12 = load i8, i8* %11, align 1
  %13 = sext i8 %12 to i32
  %14 = sext i32 %13 to i64
  %15 = getelementptr inbounds i8, i8* %9, i64 %14
  store i8* %15, i8** %6, align 8
  %16 = load i8*, i8** %3, align 8
  %17 = load i8*, i8** %4, align 8
  %18 = getelementptr inbounds i8, i8* %17, i64 4
  %19 = load i8, i8* %18, align 1
  %20 = sext i8 %19 to i32
  %21 = sext i32 %20 to i64
  %22 = getelementptr inbounds i8, i8* %16, i64 %21
  store i8* %22, i8** %7, align 8
  %23 = load i8*, i8** %4, align 8
  %24 = getelementptr inbounds i8, i8* %23, i64 4
  %25 = load i8, i8* %24, align 1
  %26 = sext i8 %25 to i32
  %27 = load i8*, i8** %4, align 8
  %28 = getelementptr inbounds i8, i8* %27, i64 4
  %29 = load i8, i8* %28, align 1
  %30 = sext i8 %29 to i32
  %31 = sub nsw i32 %26, %30
  store i32 %31, i32* %8, align 4
  %32 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %5, i32 0, i32 2
  %33 = getelementptr inbounds [17 x i8], [17 x i8]* %32, i32 0, i32 0
  %34 = load i8*, i8** %6, align 8
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %33, i8* %34, i64 16, i32 1, i1 false)
  %35 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %5, i32 0, i32 4
  %36 = getelementptr inbounds [33 x i8], [33 x i8]* %35, i32 0, i32 0
  %37 = load i8*, i8** %7, align 8
  %38 = load i32, i32* %8, align 4
  %39 = sext i32 %38 to i64
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %36, i8* %37, i64 %39, i32 1, i1 false)
  %40 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %5, i32 0, i32 4
  %41 = load i32, i32* %8, align 4
  %42 = sext i32 %41 to i64
  %43 = getelementptr inbounds [33 x i8], [33 x i8]* %40, i64 0, i64 %42
  store i8 0, i8* %43, align 1
  %44 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %5, i32 0, i32 2
  %45 = getelementptr inbounds [17 x i8], [17 x i8]* %44, i64 0, i64 16
  store i8 0, i8* %45, align 2
  %46 = load i32, i32* %8, align 4
  %47 = trunc i32 %46 to i8
  %48 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %5, i32 0, i32 8
  store i8 %47, i8* %48, align 2
  %49 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %5, i32 0, i32 2
  %50 = getelementptr inbounds [17 x i8], [17 x i8]* %49, i32 0, i32 0
  %51 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %5, i32 0, i32 4
  %52 = getelementptr inbounds [33 x i8], [33 x i8]* %51, i32 0, i32 0
  %53 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.12, i32 0, i32 0), i8* %50, i8* %52)
  %54 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %5, i32 0, i32 5
  store i32 1, i32* %54, align 4
  %55 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xConfiguratorQueue, align 8
  %56 = bitcast %struct.ConfigData* %5 to i8*
  %57 = call i64 @xQueueGenericSend(%struct.QueueDefinition* %55, i8* %56, i16 zeroext 0, i64 0)
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define i8* @_Z17index_cgi_handleriiPPcS0_(i32, i32, i8**, i8**) #3 {
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i8**, align 8
  %8 = alloca i8**, align 8
  store i32 %0, i32* %5, align 4
  store i32 %1, i32* %6, align 4
  store i8** %2, i8*** %7, align 8
  store i8** %3, i8*** %8, align 8
  ret i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.5, i32 0, i32 0)
}

; Function Attrs: noinline optnone uwtable
define void @_Z12websocket_cbP7tcp_pcbPhih(%struct.tcp_pcb*, i8*, i32, i8 zeroext) #0 {
  %5 = alloca %struct.tcp_pcb*, align 8
  %6 = alloca i8*, align 8
  %7 = alloca i32, align 4
  %8 = alloca i8, align 1
  store %struct.tcp_pcb* %0, %struct.tcp_pcb** %5, align 8
  store i8* %1, i8** %6, align 8
  store i32 %2, i32* %7, align 4
  store i8 %3, i8* %8, align 1
  %9 = load i32, i32* %7, align 4
  %10 = load i8*, i8** %6, align 8
  %11 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.6, i32 0, i32 0), i32 %9, i8* %10)
  %12 = load i8*, i8** %6, align 8
  %13 = call i32 @strncmp(i8* %12, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.7, i32 0, i32 0), i64 3) #5
  %14 = icmp ne i32 %13, 0
  br i1 %14, label %22, label %15

; <label>:15:                                     ; preds = %4
  %16 = load %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** @_ZL19xWSGetAckTaskHandle, align 8
  %17 = icmp ne %struct.tskTaskControlBlock* %16, null
  br i1 %17, label %18, label %21

; <label>:18:                                     ; preds = %15
  %19 = load %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** @_ZL19xWSGetAckTaskHandle, align 8
  %20 = call i64 @xTaskGenericNotify(%struct.tskTaskControlBlock* %19, i32 0, i32 2, i32* null)
  br label %21

; <label>:21:                                     ; preds = %18, %15
  br label %29

; <label>:22:                                     ; preds = %4
  %23 = load volatile i32, i32* @websocketClbkUse, align 4
  %24 = icmp eq i32 %23, 1
  br i1 %24, label %25, label %29

; <label>:25:                                     ; preds = %22
  %26 = load i8*, i8** %6, align 8
  %27 = load i32, i32* %7, align 4
  %28 = load %struct.tcp_pcb*, %struct.tcp_pcb** %5, align 8
  call void @_Z9setConfigPciP7tcp_pcb(i8* %26, i32 %27, %struct.tcp_pcb* %28)
  br label %29

; <label>:29:                                     ; preds = %21, %25, %22
  ret void
}

declare i64 @xTaskGenericNotify(%struct.tskTaskControlBlock*, i32, i32, i32*) #1

; Function Attrs: noinline optnone uwtable
define void @_Z17websocket_open_cbP7tcp_pcbPKc(%struct.tcp_pcb*, i8*) #0 {
  %3 = alloca %struct.tcp_pcb*, align 8
  %4 = alloca i8*, align 8
  store %struct.tcp_pcb* %0, %struct.tcp_pcb** %3, align 8
  store i8* %1, i8** %4, align 8
  %5 = load i8*, i8** %4, align 8
  %6 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.8, i32 0, i32 0), i8* %5)
  %7 = load i8*, i8** %4, align 8
  %8 = call i32 @strcmp(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.9, i32 0, i32 0), i8* %7) #5
  %9 = icmp ne i32 %8, 0
  br i1 %9, label %13, label %10

; <label>:10:                                     ; preds = %2
  store volatile i32 1, i32* @websocketClbkUse, align 4
  %11 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.10, i32 0, i32 0))
  %12 = load %struct.tcp_pcb*, %struct.tcp_pcb** %3, align 8
  store %struct.tcp_pcb* %12, %struct.tcp_pcb** @wsPCB, align 8
  br label %15

; <label>:13:                                     ; preds = %2
  store volatile i32 0, i32* @websocketClbkUse, align 4
  %14 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.11, i32 0, i32 0))
  br label %15

; <label>:15:                                     ; preds = %13, %10
  ret void
}

; Function Attrs: nounwind readonly
declare i32 @strcmp(i8*, i8*) #2

; Function Attrs: noinline optnone uwtable
define void @_Z10httpd_taskPv(i8*) #0 {
  %2 = alloca i8*, align 8
  %3 = alloca %struct.tcp_pcb, align 4
  %4 = alloca i8, align 1
  store i8* %0, i8** %2, align 8
  call void @_Z28websocket_register_callbacksPFvP7tcp_pcbPKcEPFvS0_PhihE(void (%struct.tcp_pcb*, i8*)* @_Z17websocket_open_cbP7tcp_pcbPKc, void (%struct.tcp_pcb*, i8*, i32, i8)* @_Z12websocket_cbP7tcp_pcbPhih)
  store i8 32, i8* %4, align 1
  call void @_Z17websocket_open_cbP7tcp_pcbPKc(%struct.tcp_pcb* %3, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str, i32 0, i32 0))
  call void @_Z12websocket_cbP7tcp_pcbPhih(%struct.tcp_pcb* %3, i8* %4, i32 324, i8 zeroext 68)
  br label %5

; <label>:5:                                      ; preds = %5, %1
  br label %5
                                                  ; No predecessors!
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define void @_Z14sendWsResponsePKhi(i8*, i32) #3 {
  %3 = alloca i8*, align 8
  %4 = alloca i32, align 4
  store i8* %0, i8** %3, align 8
  store i32 %1, i32* %4, align 4
  ret void
}

; Function Attrs: noinline optnone uwtable
define void @_Z27sendWsResponseAndWaitForAckPKhi(i8*, i32) #0 {
  %3 = alloca i8*, align 8
  %4 = alloca i32, align 4
  store i8* %0, i8** %3, align 8
  store i32 %1, i32* %4, align 4
  %5 = call %struct.tskTaskControlBlock* @xTaskGetCurrentTaskHandle()
  store %struct.tskTaskControlBlock* %5, %struct.tskTaskControlBlock** @_ZL19xWSGetAckTaskHandle, align 8
  %6 = call i32 @ulTaskNotifyTake(i64 1, i16 zeroext 10000)
  store %struct.tskTaskControlBlock* null, %struct.tskTaskControlBlock** @_ZL19xWSGetAckTaskHandle, align 8
  ret void
}

declare %struct.tskTaskControlBlock* @xTaskGetCurrentTaskHandle() #1

declare i32 @ulTaskNotifyTake(i64, i16 zeroext) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture writeonly, i8* nocapture readonly, i64, i32, i1) #4

declare i64 @xQueueGenericSend(%struct.QueueDefinition*, i8*, i16 zeroext, i64) #1

attributes #0 = { noinline optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { argmemonly nounwind }
attributes #5 = { nounwind readonly }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
