; ModuleID = 'cloud.cc'
source_filename = "cloud.cc"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.QueueDefinition = type opaque
%struct.mqtt_network = type { i32, i32 (%struct.mqtt_network*, i8*, i32, i32)*, i32 (%struct.mqtt_network*, i8*, i32, i32)* }
%struct.MqttData = type { [32 x i8], [8 x i8], i8, i8 }

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
@xMqttQueue = global %struct.QueueDefinition* null, align 8
@.str = private unnamed_addr constant [17 x i8] c"MQTT Error: %d\0A\0D\00", align 1
@.str.1 = private unnamed_addr constant [8 x i8] c"Error\0A\0D\00", align 1
@.str.2 = private unnamed_addr constant [12 x i8] c"Connected\0A\0D\00", align 1
@.str.3 = private unnamed_addr constant [13 x i8] c"Attributes\0A\0D\00", align 1
@_ZL7tbToken = internal global [21 x i8*] zeroinitializer, align 16

; Function Attrs: noinline optnone uwtable
define void @_Z8mqttTaskPv(i8*) #0 {
  %2 = alloca i8*, align 8
  %3 = alloca %struct.mqtt_network, align 8
  %4 = alloca [192 x i8], align 16
  %5 = alloca [128 x i8], align 16
  %6 = alloca [192 x i8], align 16
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  %10 = alloca %struct.MqttData, align 1
  %11 = alloca [33 x i8], align 16
  store i8* %0, i8** %2, align 8
  call void @vTaskDelay(i16 zeroext 200)
  call void @_Z16mqtt_network_newP12mqtt_network(%struct.mqtt_network* %3)
  br label %12

; <label>:12:                                     ; preds = %1, %20, %65
  %13 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str, i32 0, i32 0), i32 123)
  call void @vTaskDelay(i16 zeroext 1000)
  %14 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.1, i32 0, i32 0))
  call void @vTaskDelay(i16 zeroext 500)
  %15 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.2, i32 0, i32 0))
  %16 = bitcast [192 x i8]* %6 to i8*
  call void @llvm.memset.p0i8.i64(i8* %16, i8 0, i64 192, i32 16, i1 false)
  %17 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.3, i32 0, i32 0))
  store i32 0, i32* %7, align 4
  store i32 32, i32* %8, align 4
  store i32 213, i32* %9, align 4
  %18 = load i32, i32* %7, align 4
  %19 = icmp ne i32 %18, 324
  br i1 %19, label %20, label %21

; <label>:20:                                     ; preds = %12
  br label %12

; <label>:21:                                     ; preds = %12
  br label %22

; <label>:22:                                     ; preds = %64, %21
  br label %23

; <label>:23:                                     ; preds = %53, %22
  %24 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xMqttQueue, align 8
  %25 = bitcast %struct.MqttData* %10 to i8*
  %26 = call i64 @xQueueReceive(%struct.QueueDefinition* %24, i8* %25, i16 zeroext 0)
  %27 = icmp eq i64 %26, 1
  br i1 %27, label %28, label %54

; <label>:28:                                     ; preds = %23
  %29 = getelementptr inbounds %struct.MqttData, %struct.MqttData* %10, i32 0, i32 2
  %30 = load i8, i8* %29, align 1
  %31 = zext i8 %30 to i32
  %32 = icmp eq i32 %31, 1
  br i1 %32, label %33, label %41

; <label>:33:                                     ; preds = %28
  %34 = getelementptr inbounds [33 x i8], [33 x i8]* %11, i32 0, i32 0
  %35 = getelementptr inbounds %struct.MqttData, %struct.MqttData* %10, i32 0, i32 1
  %36 = getelementptr inbounds [8 x i8], [8 x i8]* %35, i32 0, i32 0
  call void @_Z25getDeviceNameByPlcPhyAddrPcPh(i8* %34, i8* %36)
  %37 = load i32, i32* %8, align 4
  %38 = icmp sgt i32 %37, 0
  br i1 %38, label %39, label %40

; <label>:39:                                     ; preds = %33
  br label %40

; <label>:40:                                     ; preds = %39, %33
  br label %48

; <label>:41:                                     ; preds = %28
  %42 = getelementptr inbounds %struct.MqttData, %struct.MqttData* %10, i32 0, i32 2
  %43 = load i8, i8* %42, align 1
  %44 = zext i8 %43 to i32
  %45 = icmp eq i32 %44, 2
  br i1 %45, label %46, label %47

; <label>:46:                                     ; preds = %41
  br label %47

; <label>:47:                                     ; preds = %46, %41
  br label %48

; <label>:48:                                     ; preds = %47, %40
  %49 = load i32, i32* %7, align 4
  %50 = load i32, i32* %8, align 4
  %51 = icmp ne i32 %49, %50
  br i1 %51, label %52, label %53

; <label>:52:                                     ; preds = %48
  br label %54

; <label>:53:                                     ; preds = %48
  br label %23

; <label>:54:                                     ; preds = %52, %23
  %55 = load i32, i32* %7, align 4
  %56 = load i32, i32* %8, align 4
  %57 = icmp ne i32 %55, %56
  br i1 %57, label %58, label %59

; <label>:58:                                     ; preds = %54
  br label %65

; <label>:59:                                     ; preds = %54
  %60 = load i32, i32* %7, align 4
  %61 = load i32, i32* %9, align 4
  %62 = icmp eq i32 %60, %61
  br i1 %62, label %63, label %64

; <label>:63:                                     ; preds = %59
  br label %65

; <label>:64:                                     ; preds = %59
  br label %22

; <label>:65:                                     ; preds = %63, %58
  br label %12
                                                  ; No predecessors!
  ret void
}

declare void @vTaskDelay(i16 zeroext) #1

declare void @_Z16mqtt_network_newP12mqtt_network(%struct.mqtt_network*) #1

declare i32 @printf(i8*, ...) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i32, i1) #2

declare i64 @xQueueReceive(%struct.QueueDefinition*, i8*, i16 zeroext) #1

declare void @_Z25getDeviceNameByPlcPhyAddrPcPh(i8*, i8*) #1

; Function Attrs: noinline nounwind optnone uwtable
define void @_Z10setTbTokenPc(i8*) #3 {
  %2 = alloca i8*, align 8
  store i8* %0, i8** %2, align 8
  %3 = load i8*, i8** %2, align 8
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* bitcast ([21 x i8*]* @_ZL7tbToken to i8*), i8* %3, i64 20, i32 1, i1 false)
  ret void
}

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture writeonly, i8* nocapture readonly, i64, i32, i1) #2

; Function Attrs: noinline nounwind optnone uwtable
define i8* @_Z10getTbTokenv() #3 {
  ret i8* bitcast ([21 x i8*]* @_ZL7tbToken to i8*)
}

attributes #0 = { noinline optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { argmemonly nounwind }
attributes #3 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
