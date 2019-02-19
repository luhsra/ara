; ModuleID = 'system.cc'
source_filename = "system.cc"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.QueueDefinition = type opaque
%struct.tskTaskControlBlock = type opaque
%struct.Client = type { %struct.Client*, [8 x i8], [33 x i8], i8 }
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
@xConfiguratorQueue = global %struct.QueueDefinition* null, align 8
@xConfiguratorTask = global %struct.tskTaskControlBlock* null, align 8
@devType = global i32 0, align 4
@STATION_GOT_IP = global i32 324, align 4
@STATION_IF = global i32 234, align 4
@STATION_MODE = global i32 234, align 4
@STATION_CONNECTING = global i32 6546, align 4
@AUTH_WPA_WPA2_PSK = global i32 6463, align 4
@STATIONAP_MODE = global i32 23, align 4
@clientStr = external constant [7 x i8], align 1
@gatewayStr = external constant [7 x i8], align 1
@.str = private unnamed_addr constant [25 x i8] c"First run of the device\0A\00", align 1
@.str.1 = private unnamed_addr constant [12 x i8] c"HTTP Daemon\00", align 1
@xHTTPServerTask = external global %struct.tskTaskControlBlock*, align 8
@.str.2 = private unnamed_addr constant [14 x i8] c"configConnect\00", align 1
@.str.3 = private unnamed_addr constant [22 x i8] c"WiFi: connecting...\0D\0A\00", align 1
@wifiJsonStrings = external global [0 x i8*], align 8
@wifiJsonStringsLen = external constant [0 x i8], align 1
@plcJsonRegisUnsuccessStr = external constant [0 x i8], align 1
@plcJsonRegisUnsuccessStrLen = external constant i8, align 1
@wifiConnectionSuccessJson = external global [0 x i8], align 1
@wifiConnectionSuccessJsonLen = external global i8, align 1
@xMqttQueue = external global %struct.QueueDefinition*, align 8
@.str.4 = private unnamed_addr constant [5 x i8] c"MQTT\00", align 1
@.str.5 = private unnamed_addr constant [9 x i8] c"PowerGet\00", align 1
@plcJsonRegisSuccessStr = external constant [0 x i8], align 1
@plcJsonRegisSuccessStrLen = external constant i8, align 1
@.str.6 = private unnamed_addr constant [23 x i8] c"Starting gateway mode\0A\00", align 1
@.str.7 = private unnamed_addr constant [8 x i8] c"StartUp\00", align 1
@.str.8 = private unnamed_addr constant [16 x i8] c"Not having IP\0A\0D\00", align 1
@.str.9 = private unnamed_addr constant [12 x i8] c"GatewayAddr\00", align 1
@.str.10 = private unnamed_addr constant [22 x i8] c"Starting client mode\0A\00", align 1
@clientListBegin = external global %struct.Client*, align 8

; Function Attrs: noinline optnone uwtable
define void @_Z16initDeviceByModev() #0 {
  %1 = alloca [16 x i8], align 16
  %2 = getelementptr inbounds [16 x i8], [16 x i8]* %1, i32 0, i32 0
  %3 = call i32 @_Z21getDeviceModeFromFilePc(i8* %2)
  %4 = getelementptr inbounds [16 x i8], [16 x i8]* %1, i32 0, i32 0
  %5 = call i32 @strncmp(i8* %4, i8* getelementptr inbounds ([7 x i8], [7 x i8]* @clientStr, i32 0, i32 0), i64 6) #5
  %6 = icmp ne i32 %5, 0
  br i1 %6, label %8, label %7

; <label>:7:                                      ; preds = %0
  call void @_ZL15startClientModev()
  br label %19

; <label>:8:                                      ; preds = %0
  %9 = getelementptr inbounds [16 x i8], [16 x i8]* %1, i32 0, i32 0
  %10 = call i32 @strncmp(i8* %9, i8* getelementptr inbounds ([7 x i8], [7 x i8]* @gatewayStr, i32 0, i32 0), i64 6) #5
  %11 = icmp ne i32 %10, 0
  br i1 %11, label %13, label %12

; <label>:12:                                     ; preds = %8
  call void @_ZL16startGatewayModev()
  br label %18

; <label>:13:                                     ; preds = %8
  %14 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([25 x i8], [25 x i8]* @.str, i32 0, i32 0))
  call void @_ZL16setStationAPModev()
  %15 = call %struct.QueueDefinition* @xQueueGenericCreate(i64 1, i64 180, i8 zeroext 0)
  store %struct.QueueDefinition* %15, %struct.QueueDefinition** @xConfiguratorQueue, align 8
  %16 = call i64 @xTaskCreate(void (i8*)* @_Z10httpd_taskPv, i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.1, i32 0, i32 0), i16 zeroext 256, i8* null, i64 2, %struct.tskTaskControlBlock** @xHTTPServerTask)
  %17 = call i64 @xTaskCreate(void (i8*)* @_Z16configuratorTaskPv, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.2, i32 0, i32 0), i16 zeroext 1536, i8* null, i64 4, %struct.tskTaskControlBlock** @xConfiguratorTask)
  br label %18

; <label>:18:                                     ; preds = %13, %12
  br label %19

; <label>:19:                                     ; preds = %18, %7
  ret void
}

declare i32 @_Z21getDeviceModeFromFilePc(i8*) #1

; Function Attrs: nounwind readonly
declare i32 @strncmp(i8*, i8*, i64) #2

; Function Attrs: noinline optnone uwtable
define internal void @_ZL15startClientModev() #0 {
  store volatile i32 1, i32* @devType, align 4
  call void @_ZL14initCommonOptsv()
  %1 = call i64 @xTaskCreate(void (i8*)* @_ZL27setGatewayPlcPhyAddressTaskPv, i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.9, i32 0, i32 0), i16 zeroext 128, i8* null, i64 2, %struct.tskTaskControlBlock** null)
  %2 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.10, i32 0, i32 0))
  ret void
}

; Function Attrs: noinline optnone uwtable
define internal void @_ZL16startGatewayModev() #0 {
  store volatile i32 2, i32* @devType, align 4
  call void @_ZL14initCommonOptsv()
  call void @_Z26retrieveClientListFromFilev()
  %1 = call %struct.QueueDefinition* @xQueueGenericCreate(i64 6, i64 42, i8 zeroext 0)
  store %struct.QueueDefinition* %1, %struct.QueueDefinition** @xMqttQueue, align 8
  %2 = call i64 @xTaskCreate(void (i8*)* @_Z8mqttTaskPv, i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.4, i32 0, i32 0), i16 zeroext 1536, i8* null, i64 2, %struct.tskTaskControlBlock** null)
  %3 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([23 x i8], [23 x i8]* @.str.6, i32 0, i32 0))
  ret void
}

declare i32 @printf(i8*, ...) #1

; Function Attrs: noinline optnone uwtable
define internal void @_ZL16setStationAPModev() #0 {
  %1 = load i32, i32* @STATIONAP_MODE, align 4
  call void @_Z19sdk_wifi_set_opmodei(i32 %1)
  ret void
}

declare %struct.QueueDefinition* @xQueueGenericCreate(i64, i64, i8 zeroext) #1

declare i64 @xTaskCreate(void (i8*)*, i8*, i16 zeroext, i8*, i64, %struct.tskTaskControlBlock**) #1

declare void @_Z10httpd_taskPv(i8*) #1

; Function Attrs: noinline optnone uwtable
define void @_Z16configuratorTaskPv(i8*) #0 {
  %2 = alloca i8*, align 8
  %3 = alloca %struct.ConfigData, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  store i8* %0, i8** %2, align 8
  br label %6

; <label>:6:                                      ; preds = %68, %1
  %7 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xConfiguratorQueue, align 8
  %8 = bitcast %struct.ConfigData* %3 to i8*
  %9 = call i64 @xQueueReceive(%struct.QueueDefinition* %7, i8* %8, i16 zeroext -1)
  %10 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %3, i32 0, i32 5
  %11 = load i32, i32* %10, align 4
  %12 = icmp eq i32 %11, 0
  br i1 %12, label %13, label %54

; <label>:13:                                     ; preds = %6
  %14 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %3, i32 0, i32 0
  %15 = getelementptr inbounds [33 x i8], [33 x i8]* %14, i32 0, i32 0
  %16 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %3, i32 0, i32 1
  %17 = getelementptr inbounds [65 x i8], [65 x i8]* %16, i32 0, i32 0
  %18 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %3, i32 0, i32 6
  %19 = load i8, i8* %18, align 4
  %20 = zext i8 %19 to i32
  %21 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %3, i32 0, i32 7
  %22 = load i8, i8* %21, align 1
  %23 = zext i8 %22 to i32
  call void @_ZL16connectToStationPcS_ii(i8* %15, i8* %17, i32 %20, i32 %23)
  store i32 10, i32* %4, align 4
  store i32 324, i32* %5, align 4
  br label %24

; <label>:24:                                     ; preds = %33, %13
  %25 = load i32, i32* %5, align 4
  %26 = load i32, i32* @STATION_CONNECTING, align 4
  %27 = icmp eq i32 %25, %26
  br i1 %27, label %28, label %31

; <label>:28:                                     ; preds = %24
  %29 = load i32, i32* %4, align 4
  %30 = icmp ne i32 %29, 0
  br label %31

; <label>:31:                                     ; preds = %28, %24
  %32 = phi i1 [ false, %24 ], [ %30, %28 ]
  br i1 %32, label %33, label %37

; <label>:33:                                     ; preds = %31
  %34 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0))
  call void @vTaskDelay(i16 zeroext 3000)
  store i32 234, i32* %5, align 4
  %35 = load i32, i32* %4, align 4
  %36 = add nsw i32 %35, -1
  store i32 %36, i32* %4, align 4
  br label %24

; <label>:37:                                     ; preds = %31
  %38 = load i32, i32* %5, align 4
  %39 = load i32, i32* @STATION_GOT_IP, align 4
  %40 = icmp eq i32 %38, %39
  br i1 %40, label %41, label %44

; <label>:41:                                     ; preds = %37
  call void @_ZL19switchToGatewayModeP10ConfigData(%struct.ConfigData* %3)
  %42 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xConfiguratorQueue, align 8
  call void @vQueueDelete(%struct.QueueDefinition* %42)
  %43 = load %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** @xHTTPServerTask, align 8
  call void @vTaskDelete(%struct.tskTaskControlBlock* %43)
  call void @vTaskDelete(%struct.tskTaskControlBlock* null)
  br label %44

; <label>:44:                                     ; preds = %41, %37
  %45 = load i32, i32* %5, align 4
  %46 = zext i32 %45 to i64
  %47 = getelementptr inbounds [0 x i8*], [0 x i8*]* @wifiJsonStrings, i64 0, i64 %46
  %48 = load i8*, i8** %47, align 8
  %49 = load i32, i32* %5, align 4
  %50 = zext i32 %49 to i64
  %51 = getelementptr inbounds [0 x i8], [0 x i8]* @wifiJsonStringsLen, i64 0, i64 %50
  %52 = load i8, i8* %51, align 1
  %53 = zext i8 %52 to i32
  call void @_Z14sendWsResponsePKhi(i8* %48, i32 %53)
  br label %68

; <label>:54:                                     ; preds = %6
  %55 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %3, i32 0, i32 5
  %56 = load i32, i32* %55, align 4
  %57 = icmp eq i32 %56, 1
  br i1 %57, label %58, label %67

; <label>:58:                                     ; preds = %54
  %59 = call i32 @_Z14registerClientP10ConfigData(%struct.ConfigData* %3)
  %60 = icmp sge i32 %59, 0
  br i1 %60, label %61, label %64

; <label>:61:                                     ; preds = %58
  call void @_ZL18switchToClientModeP10ConfigData(%struct.ConfigData* %3)
  %62 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xConfiguratorQueue, align 8
  call void @vQueueDelete(%struct.QueueDefinition* %62)
  %63 = load %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** @xHTTPServerTask, align 8
  call void @vTaskDelete(%struct.tskTaskControlBlock* %63)
  call void @vTaskDelete(%struct.tskTaskControlBlock* null)
  br label %64

; <label>:64:                                     ; preds = %61, %58
  %65 = load i8, i8* @plcJsonRegisUnsuccessStrLen, align 1
  %66 = zext i8 %65 to i32
  call void @_Z14sendWsResponsePKhi(i8* getelementptr inbounds ([0 x i8], [0 x i8]* @plcJsonRegisUnsuccessStr, i32 0, i32 0), i32 %66)
  br label %67

; <label>:67:                                     ; preds = %64, %54
  br label %68

; <label>:68:                                     ; preds = %67, %44
  br label %6
                                                  ; No predecessors!
  ret void
}

declare i64 @xQueueReceive(%struct.QueueDefinition*, i8*, i16 zeroext) #1

; Function Attrs: noinline optnone uwtable
define internal void @_ZL16connectToStationPcS_ii(i8*, i8*, i32, i32) #0 {
  %5 = alloca i8*, align 8
  %6 = alloca i8*, align 8
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca %struct.sdk_station_config, align 4
  store i8* %0, i8** %5, align 8
  store i8* %1, i8** %6, align 8
  store i32 %2, i32* %7, align 4
  store i32 %3, i32* %8, align 4
  %10 = load i8*, i8** %5, align 8
  %11 = load i8*, i8** %6, align 8
  %12 = load i32, i32* %7, align 4
  %13 = trunc i32 %12 to i8
  %14 = load i32, i32* %8, align 4
  %15 = trunc i32 %14 to i8
  call void @_Z17fillStationConfigP18sdk_station_configPcS1_hh(%struct.sdk_station_config* %9, i8* %10, i8* %11, i8 zeroext %13, i8 zeroext %15)
  call void @_Z27sdk_wifi_station_set_configP18sdk_station_config(%struct.sdk_station_config* %9)
  ret void
}

declare void @vTaskDelay(i16 zeroext) #1

; Function Attrs: noinline optnone uwtable
define internal void @_ZL19switchToGatewayModeP10ConfigData(%struct.ConfigData*) #0 {
  %2 = alloca %struct.ConfigData*, align 8
  %3 = alloca [8 x i8], align 1
  store %struct.ConfigData* %0, %struct.ConfigData** %2, align 8
  store volatile i32 2, i32* @devType, align 4
  %4 = getelementptr inbounds [8 x i8], [8 x i8]* %3, i32 0, i32 0
  call void @_Z16readPLCregistershPhj(i8 zeroext 106, i8* %4, i32 8)
  %5 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %6 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %5, i32 0, i32 2
  %7 = getelementptr inbounds [17 x i8], [17 x i8]* %6, i32 0, i32 0
  %8 = getelementptr inbounds [8 x i8], [8 x i8]* %3, i32 0, i32 0
  call void @_Z28convertPlcPhyAddressToStringPcPh(i8* %7, i8* %8)
  %9 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %10 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %9, i32 0, i32 2
  %11 = getelementptr inbounds [17 x i8], [17 x i8]* %10, i32 0, i32 0
  call void @_ZL45fillJsonConnectionSuccessStringWithPlcPhyAddrPc(i8* %11)
  %12 = load i8, i8* @wifiConnectionSuccessJsonLen, align 1
  %13 = zext i8 %12 to i32
  call void @_Z27sendWsResponseAndWaitForAckPKhi(i8* getelementptr inbounds ([0 x i8], [0 x i8]* @wifiConnectionSuccessJson, i32 0, i32 0), i32 %13)
  %14 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %15 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %14, i32 0, i32 3
  %16 = getelementptr inbounds [21 x i8], [21 x i8]* %15, i32 0, i32 0
  call void @_Z10setTbTokenPc(i8* %16)
  %17 = load i32, i32* @STATION_MODE, align 4
  call void @_Z19sdk_wifi_set_opmodei(i32 %17)
  call void @_Z8sntpInitv()
  %18 = getelementptr inbounds [8 x i8], [8 x i8]* %3, i32 0, i32 0
  %19 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %20 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %19, i32 0, i32 4
  %21 = getelementptr inbounds [33 x i8], [33 x i8]* %20, i32 0, i32 0
  %22 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %23 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %22, i32 0, i32 8
  %24 = load i8, i8* %23, align 2
  %25 = zext i8 %24 to i32
  %26 = call %struct.Client* @_Z12createClientPhPci(i8* %18, i8* %21, i32 %25)
  call void @_Z9addClientP6Client(%struct.Client* %26)
  %27 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  call void @_Z20saveConfigDataToFileP10ConfigData(%struct.ConfigData* %27)
  %28 = call %struct.QueueDefinition* @xQueueGenericCreate(i64 8, i64 42, i8 zeroext 0)
  store %struct.QueueDefinition* %28, %struct.QueueDefinition** @xMqttQueue, align 8
  %29 = call i64 @xTaskCreate(void (i8*)* @_Z8mqttTaskPv, i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.4, i32 0, i32 0), i16 zeroext 1536, i8* null, i64 2, %struct.tskTaskControlBlock** null)
  %30 = call i64 @xTaskCreate(void (i8*)* @_Z12getPowerTaskPv, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.5, i32 0, i32 0), i16 zeroext 512, i8* null, i64 2, %struct.tskTaskControlBlock** null)
  ret void
}

declare void @vQueueDelete(%struct.QueueDefinition*) #1

declare void @vTaskDelete(%struct.tskTaskControlBlock*) #1

declare void @_Z14sendWsResponsePKhi(i8*, i32) #1

declare i32 @_Z14registerClientP10ConfigData(%struct.ConfigData*) #1

; Function Attrs: noinline optnone uwtable
define internal void @_ZL18switchToClientModeP10ConfigData(%struct.ConfigData*) #0 {
  %2 = alloca %struct.ConfigData*, align 8
  store %struct.ConfigData* %0, %struct.ConfigData** %2, align 8
  store volatile i32 1, i32* @devType, align 4
  %3 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %4 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %3, i32 0, i32 2
  %5 = getelementptr inbounds [17 x i8], [17 x i8]* %4, i32 0, i32 0
  %6 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %7 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %6, i32 0, i32 4
  %8 = getelementptr inbounds [33 x i8], [33 x i8]* %7, i32 0, i32 0
  %9 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %10 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %9, i32 0, i32 8
  %11 = load i8, i8* %10, align 2
  %12 = zext i8 %11 to i32
  %13 = call %struct.Client* @_Z22createClientFromStringPcS_i(i8* %5, i8* %8, i32 %12)
  call void @_Z9addClientP6Client(%struct.Client* %13)
  %14 = load i8, i8* @plcJsonRegisSuccessStrLen, align 1
  %15 = zext i8 %14 to i32
  call void @_Z27sendWsResponseAndWaitForAckPKhi(i8* getelementptr inbounds ([0 x i8], [0 x i8]* @plcJsonRegisSuccessStr, i32 0, i32 0), i32 %15)
  %16 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %17 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %16, i32 0, i32 3
  %18 = getelementptr inbounds [21 x i8], [21 x i8]* %17, i32 0, i32 0
  call void @_Z10setTbTokenPc(i8* %18)
  %19 = load i32, i32* @STATION_MODE, align 4
  call void @_Z19sdk_wifi_set_opmodei(i32 %19)
  %20 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %21 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %20, i32 0, i32 0
  %22 = getelementptr inbounds [33 x i8], [33 x i8]* %21, i32 0, i32 0
  %23 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %24 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %23, i32 0, i32 1
  %25 = getelementptr inbounds [65 x i8], [65 x i8]* %24, i32 0, i32 0
  %26 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %27 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %26, i32 0, i32 6
  %28 = load i8, i8* %27, align 4
  %29 = zext i8 %28 to i32
  %30 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  %31 = getelementptr inbounds %struct.ConfigData, %struct.ConfigData* %30, i32 0, i32 7
  %32 = load i8, i8* %31, align 1
  %33 = zext i8 %32 to i32
  call void @_ZL16connectToStationPcS_ii(i8* %22, i8* %25, i32 %29, i32 %33)
  call void @_Z8sntpInitv()
  %34 = load %struct.ConfigData*, %struct.ConfigData** %2, align 8
  call void @_Z20saveConfigDataToFileP10ConfigData(%struct.ConfigData* %34)
  %35 = call i64 @xTaskCreate(void (i8*)* @_Z12getPowerTaskPv, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.5, i32 0, i32 0), i16 zeroext 512, i8* null, i64 2, %struct.tskTaskControlBlock** null)
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define void @_Z17fillStationConfigP18sdk_station_configPcS1_hh(%struct.sdk_station_config*, i8*, i8*, i8 zeroext, i8 zeroext) #3 {
  %6 = alloca %struct.sdk_station_config*, align 8
  %7 = alloca i8*, align 8
  %8 = alloca i8*, align 8
  %9 = alloca i8, align 1
  %10 = alloca i8, align 1
  store %struct.sdk_station_config* %0, %struct.sdk_station_config** %6, align 8
  store i8* %1, i8** %7, align 8
  store i8* %2, i8** %8, align 8
  store i8 %3, i8* %9, align 1
  store i8 %4, i8* %10, align 1
  ret void
}

declare void @_Z16readPLCregistershPhj(i8 zeroext, i8*, i32) #1

declare void @_Z28convertPlcPhyAddressToStringPcPh(i8*, i8*) #1

; Function Attrs: noinline nounwind optnone uwtable
define internal void @_ZL45fillJsonConnectionSuccessStringWithPlcPhyAddrPc(i8*) #3 {
  %2 = alloca i8*, align 8
  store i8* %0, i8** %2, align 8
  %3 = load i8, i8* @wifiConnectionSuccessJsonLen, align 1
  %4 = zext i8 %3 to i32
  %5 = sext i32 %4 to i64
  %6 = getelementptr inbounds i8, i8* getelementptr inbounds ([0 x i8], [0 x i8]* @wifiConnectionSuccessJson, i32 0, i32 0), i64 %5
  %7 = getelementptr inbounds i8, i8* %6, i64 -18
  %8 = load i8*, i8** %2, align 8
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %7, i8* %8, i64 16, i32 1, i1 false)
  ret void
}

declare void @_Z27sendWsResponseAndWaitForAckPKhi(i8*, i32) #1

declare void @_Z10setTbTokenPc(i8*) #1

declare void @_Z19sdk_wifi_set_opmodei(i32) #1

declare void @_Z8sntpInitv() #1

declare void @_Z9addClientP6Client(%struct.Client*) #1

declare %struct.Client* @_Z12createClientPhPci(i8*, i8*, i32) #1

declare void @_Z20saveConfigDataToFileP10ConfigData(%struct.ConfigData*) #1

declare void @_Z8mqttTaskPv(i8*) #1

declare void @_Z12getPowerTaskPv(i8*) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture writeonly, i8* nocapture readonly, i64, i32, i1) #4

declare %struct.Client* @_Z22createClientFromStringPcS_i(i8*, i8*, i32) #1

; Function Attrs: noinline optnone uwtable
define internal void @_ZL14initCommonOptsv() #0 {
  %1 = alloca [33 x i8], align 16
  %2 = alloca [17 x i8], align 16
  %3 = alloca [21 x i8], align 16
  %4 = call i64 @xTaskCreate(void (i8*)* @_ZL21stationAndSntpStartupPv, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.7, i32 0, i32 0), i16 zeroext 512, i8* null, i64 4, %struct.tskTaskControlBlock** null)
  %5 = getelementptr inbounds [21 x i8], [21 x i8]* %3, i32 0, i32 0
  %6 = getelementptr inbounds [17 x i8], [17 x i8]* %2, i32 0, i32 0
  %7 = getelementptr inbounds [33 x i8], [33 x i8]* %1, i32 0, i32 0
  call void @_Z22getCredentialsFromFilePcS_S_S_S_(i8* null, i8* null, i8* %5, i8* %6, i8* %7)
  %8 = getelementptr inbounds [17 x i8], [17 x i8]* %2, i32 0, i32 0
  %9 = getelementptr inbounds [33 x i8], [33 x i8]* %1, i32 0, i32 0
  %10 = getelementptr inbounds [33 x i8], [33 x i8]* %1, i32 0, i32 0
  %11 = call i64 @strlen(i8* %10) #5
  %12 = trunc i64 %11 to i32
  %13 = call %struct.Client* @_Z22createClientFromStringPcS_i(i8* %8, i8* %9, i32 %12)
  call void @_Z9addClientP6Client(%struct.Client* %13)
  %14 = getelementptr inbounds [21 x i8], [21 x i8]* %3, i32 0, i32 0
  call void @_Z10setTbTokenPc(i8* %14)
  ret void
}

declare void @_Z26retrieveClientListFromFilev() #1

; Function Attrs: noinline optnone uwtable
define internal void @_ZL21stationAndSntpStartupPv(i8*) #0 {
  %2 = alloca i8*, align 8
  store i8* %0, i8** %2, align 8
  call void @_Z8sntpInitv()
  br label %3

; <label>:3:                                      ; preds = %7, %1
  %4 = call i32 @_Z35sdk_wifi_station_get_connect_statusv()
  %5 = load i32, i32* @STATION_GOT_IP, align 4
  %6 = icmp ne i32 %4, %5
  br i1 %6, label %7, label %9

; <label>:7:                                      ; preds = %3
  %8 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.8, i32 0, i32 0))
  call void @vTaskDelay(i16 zeroext 1000)
  br label %3

; <label>:9:                                      ; preds = %3
  call void @vTaskDelete(%struct.tskTaskControlBlock* null)
  ret void
}

declare void @_Z22getCredentialsFromFilePcS_S_S_S_(i8*, i8*, i8*, i8*, i8*) #1

; Function Attrs: nounwind readonly
declare i64 @strlen(i8*) #2

declare i32 @_Z35sdk_wifi_station_get_connect_statusv() #1

; Function Attrs: noinline optnone uwtable
define internal void @_ZL27setGatewayPlcPhyAddressTaskPv(i8*) #0 {
  %2 = alloca i8*, align 8
  store i8* %0, i8** %2, align 8
  call void @vTaskDelay(i16 zeroext 2000)
  %3 = load %struct.Client*, %struct.Client** @clientListBegin, align 8
  %4 = getelementptr inbounds %struct.Client, %struct.Client* %3, i32 0, i32 1
  %5 = getelementptr inbounds [8 x i8], [8 x i8]* %4, i32 0, i32 0
  call void @_Z10setPLCtxDAhPh(i8 zeroext 64, i8* %5)
  call void @vTaskDelay(i16 zeroext 10000)
  call void @vTaskDelete(%struct.tskTaskControlBlock* null)
  ret void
}

declare void @_Z10setPLCtxDAhPh(i8 zeroext, i8*) #1

declare void @_Z27sdk_wifi_station_set_configP18sdk_station_config(%struct.sdk_station_config*) #1

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
