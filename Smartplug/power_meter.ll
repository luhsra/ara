; ModuleID = 'power_meter.cc'
source_filename = "power_meter.cc"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.Client = type { %struct.Client*, [8 x i8], [33 x i8], i8 }
%struct.QueueDefinition = type opaque
%struct.MqttData = type { [32 x i8], [8 x i8], i8, i8 }
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
@clientListBegin = external global %struct.Client*, align 8
@_ZZ12getPowerTaskPvE15commandGetPower = internal constant [7 x i8] c"\12\07A\00\0AD;", align 1
@.str = private unnamed_addr constant [22 x i8] c"Error sending packet\0A\00", align 1
@.str.1 = private unnamed_addr constant [24 x i8] c"Sending power samples\0A\0D\00", align 1
@devType = external global i32, align 4
@xMqttQueue = external global %struct.QueueDefinition*, align 8

; Function Attrs: noinline optnone uwtable
define void @_Z12getPowerTaskPv(i8*) #0 {
  %2 = alloca i8*, align 8
  %3 = alloca %struct.MqttData, align 1
  %4 = alloca i32, align 4
  %5 = alloca i16, align 2
  %6 = alloca [8 x i8], align 1
  %7 = alloca i32, align 4
  %8 = alloca i64, align 8
  %9 = alloca i32, align 4
  %10 = alloca i32, align 4
  store i8* %0, i8** %2, align 8
  %11 = getelementptr inbounds %struct.MqttData, %struct.MqttData* %3, i32 0, i32 1
  %12 = getelementptr inbounds [8 x i8], [8 x i8]* %11, i32 0, i32 0
  %13 = load %struct.Client*, %struct.Client** @clientListBegin, align 8
  %14 = getelementptr inbounds %struct.Client, %struct.Client* %13, i32 0, i32 1
  %15 = getelementptr inbounds [8 x i8], [8 x i8]* %14, i32 0, i32 0
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %12, i8* %15, i64 8, i32 1, i1 false)
  %16 = getelementptr inbounds %struct.MqttData, %struct.MqttData* %3, i32 0, i32 2
  store i8 1, i8* %16, align 1
  store i32 0, i32* %4, align 4
  call void @_Z13softuart_openiiii(i32 0, i32 4800, i32 12, i32 14)
  call void @vTaskDelay(i16 zeroext 10000)
  %17 = call zeroext i16 @xTaskGetTickCount()
  store i16 %17, i16* %5, align 2
  br label %18

; <label>:18:                                     ; preds = %1, %116
  call void @vTaskDelayUntil(i16* %5, i16 zeroext 1250)
  call void @_Z14softuart_nputsiPKci(i32 0, i8* getelementptr inbounds ([7 x i8], [7 x i8]* @_ZZ12getPowerTaskPvE15commandGetPower, i32 0, i32 0), i32 7)
  %19 = getelementptr inbounds [8 x i8], [8 x i8]* %6, i32 0, i32 0
  %20 = call i32 @_ZL12getSSIPacketPhPt(i8* %19, i16* %5)
  store i32 %20, i32* %7, align 4
  %21 = load i32, i32* %7, align 4
  %22 = icmp slt i32 %21, 0
  br i1 %22, label %23, label %25

; <label>:23:                                     ; preds = %18
  %24 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str, i32 0, i32 0))
  call void @_Z14softuart_closei(i32 0)
  call void @vTaskDelayUntil(i16* %5, i16 zeroext 400)
  call void @_Z13softuart_openiiii(i32 0, i32 4800, i32 12, i32 14)
  br label %116

; <label>:25:                                     ; preds = %18
  %26 = load i32, i32* %7, align 4
  %27 = icmp eq i32 %26, 7
  br i1 %27, label %28, label %115

; <label>:28:                                     ; preds = %25
  %29 = call i64 @time(i64* null) #4
  store i64 %29, i64* %8, align 8
  %30 = getelementptr inbounds %struct.MqttData, %struct.MqttData* %3, i32 0, i32 0
  %31 = load i32, i32* %4, align 4
  %32 = sext i32 %31 to i64
  %33 = getelementptr inbounds [32 x i8], [32 x i8]* %30, i64 0, i64 %32
  %34 = bitcast i64* %8 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %33, i8* %34, i64 8, i32 1, i1 false)
  %35 = load i32, i32* %4, align 4
  %36 = sext i32 %35 to i64
  %37 = add i64 %36, 8
  %38 = trunc i64 %37 to i32
  store i32 %38, i32* %4, align 4
  %39 = call zeroext i16 @xTaskGetTickCount()
  %40 = zext i16 %39 to i32
  %41 = mul nsw i32 %40, 1000
  %42 = sdiv i32 %41, 1000
  %43 = srem i32 %42, 1000
  store i32 %43, i32* %9, align 4
  %44 = load i32, i32* %9, align 4
  %45 = ashr i32 %44, 8
  %46 = and i32 %45, 255
  %47 = trunc i32 %46 to i8
  %48 = getelementptr inbounds %struct.MqttData, %struct.MqttData* %3, i32 0, i32 0
  %49 = load i32, i32* %4, align 4
  %50 = add nsw i32 %49, 1
  store i32 %50, i32* %4, align 4
  %51 = sext i32 %49 to i64
  %52 = getelementptr inbounds [32 x i8], [32 x i8]* %48, i64 0, i64 %51
  store i8 %47, i8* %52, align 1
  %53 = load i32, i32* %9, align 4
  %54 = and i32 %53, 255
  %55 = trunc i32 %54 to i8
  %56 = getelementptr inbounds %struct.MqttData, %struct.MqttData* %3, i32 0, i32 0
  %57 = load i32, i32* %4, align 4
  %58 = add nsw i32 %57, 1
  store i32 %58, i32* %4, align 4
  %59 = sext i32 %57 to i64
  %60 = getelementptr inbounds [32 x i8], [32 x i8]* %56, i64 0, i64 %59
  store i8 %55, i8* %60, align 1
  %61 = getelementptr inbounds [8 x i8], [8 x i8]* %6, i64 0, i64 0
  %62 = load i8, i8* %61, align 1
  %63 = zext i8 %62 to i32
  %64 = and i32 %63, 255
  %65 = shl i32 %64, 24
  %66 = getelementptr inbounds [8 x i8], [8 x i8]* %6, i64 0, i64 1
  %67 = load i8, i8* %66, align 1
  %68 = zext i8 %67 to i32
  %69 = and i32 %68, 255
  %70 = shl i32 %69, 16
  %71 = or i32 %65, %70
  %72 = getelementptr inbounds [8 x i8], [8 x i8]* %6, i64 0, i64 2
  %73 = load i8, i8* %72, align 1
  %74 = zext i8 %73 to i32
  %75 = and i32 %74, 255
  %76 = shl i32 %75, 8
  %77 = or i32 %71, %76
  %78 = getelementptr inbounds [8 x i8], [8 x i8]* %6, i64 0, i64 3
  %79 = load i8, i8* %78, align 1
  %80 = zext i8 %79 to i32
  %81 = and i32 %80, 255
  %82 = or i32 %77, %81
  store i32 %82, i32* %10, align 4
  %83 = getelementptr inbounds %struct.MqttData, %struct.MqttData* %3, i32 0, i32 0
  %84 = load i32, i32* %4, align 4
  %85 = sext i32 %84 to i64
  %86 = getelementptr inbounds [32 x i8], [32 x i8]* %83, i64 0, i64 %85
  %87 = bitcast i8* %86 to i32*
  %88 = bitcast i32* %87 to i8*
  %89 = bitcast i32* %10 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %88, i8* %89, i64 4, i32 1, i1 false)
  %90 = load i32, i32* %4, align 4
  %91 = sext i32 %90 to i64
  %92 = add i64 %91, 4
  %93 = trunc i64 %92 to i32
  store i32 %93, i32* %4, align 4
  %94 = load i32, i32* %4, align 4
  %95 = icmp sge i32 %94, 30
  br i1 %95, label %96, label %114

; <label>:96:                                     ; preds = %28
  %97 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.1, i32 0, i32 0))
  %98 = load i32, i32* %4, align 4
  %99 = trunc i32 %98 to i8
  %100 = getelementptr inbounds %struct.MqttData, %struct.MqttData* %3, i32 0, i32 3
  store i8 %99, i8* %100, align 1
  %101 = load volatile i32, i32* @devType, align 4
  %102 = icmp eq i32 %101, 1
  br i1 %102, label %103, label %109

; <label>:103:                                    ; preds = %96
  %104 = getelementptr inbounds %struct.MqttData, %struct.MqttData* %3, i32 0, i32 0
  %105 = getelementptr inbounds [32 x i8], [32 x i8]* %104, i32 0, i32 0
  %106 = load i32, i32* %4, align 4
  %107 = trunc i32 %106 to i8
  %108 = call i32 @_Z11sendPlcDataPhS_P19tskTaskControlBlockhh(i8* %105, i8* null, %struct.tskTaskControlBlock* null, i8 zeroext 54, i8 zeroext %107)
  br label %113

; <label>:109:                                    ; preds = %96
  %110 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xMqttQueue, align 8
  %111 = bitcast %struct.MqttData* %3 to i8*
  %112 = call i64 @xQueueGenericSend(%struct.QueueDefinition* %110, i8* %111, i16 zeroext 0, i64 0)
  br label %113

; <label>:113:                                    ; preds = %109, %103
  store i32 0, i32* %4, align 4
  br label %114

; <label>:114:                                    ; preds = %113, %28
  br label %115

; <label>:115:                                    ; preds = %114, %25
  br label %116

; <label>:116:                                    ; preds = %115, %23
  br label %18
                                                  ; No predecessors!
  ret void
}

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture writeonly, i8* nocapture readonly, i64, i32, i1) #1

declare void @_Z13softuart_openiiii(i32, i32, i32, i32) #2

declare void @vTaskDelay(i16 zeroext) #2

declare zeroext i16 @xTaskGetTickCount() #2

declare void @vTaskDelayUntil(i16*, i16 zeroext) #2

declare void @_Z14softuart_nputsiPKci(i32, i8*, i32) #2

; Function Attrs: noinline optnone uwtable
define internal i32 @_ZL12getSSIPacketPhPt(i8*, i16*) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i8*, align 8
  %5 = alloca i16*, align 8
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  store i8* %0, i8** %4, align 8
  store i16* %1, i16** %5, align 8
  %8 = load i16*, i16** %5, align 8
  call void @vTaskDelayUntil(i16* %8, i16 zeroext 70)
  %9 = call zeroext i1 @_Z18softuart_availablei(i32 0)
  br i1 %9, label %12, label %10

; <label>:10:                                     ; preds = %2
  %11 = load i16*, i16** %5, align 8
  call void @vTaskDelayUntil(i16* %11, i16 zeroext 5)
  br label %12

; <label>:12:                                     ; preds = %10, %2
  %13 = call i32 @_Z13softuart_readi(i32 0)
  %14 = and i32 %13, 255
  store i32 %14, i32* %6, align 4
  %15 = load i32, i32* %6, align 4
  %16 = icmp ne i32 %15, 6
  br i1 %16, label %17, label %18

; <label>:17:                                     ; preds = %12
  store i32 -1, i32* %3, align 4
  br label %47

; <label>:18:                                     ; preds = %12
  %19 = call zeroext i1 @_Z18softuart_availablei(i32 0)
  br i1 %19, label %22, label %20

; <label>:20:                                     ; preds = %18
  %21 = load i16*, i16** %5, align 8
  call void @vTaskDelayUntil(i16* %21, i16 zeroext 5)
  br label %22

; <label>:22:                                     ; preds = %20, %18
  %23 = call i32 @_Z13softuart_readi(i32 0)
  %24 = and i32 %23, 255
  store i32 %24, i32* %7, align 4
  %25 = load i32, i32* %7, align 4
  %26 = sub nsw i32 %25, 3
  store i32 %26, i32* %6, align 4
  br label %27

; <label>:27:                                     ; preds = %35, %22
  %28 = load i32, i32* %6, align 4
  %29 = add nsw i32 %28, -1
  store i32 %29, i32* %6, align 4
  %30 = icmp ne i32 %28, 0
  br i1 %30, label %31, label %40

; <label>:31:                                     ; preds = %27
  %32 = call zeroext i1 @_Z18softuart_availablei(i32 0)
  br i1 %32, label %35, label %33

; <label>:33:                                     ; preds = %31
  %34 = load i16*, i16** %5, align 8
  call void @vTaskDelayUntil(i16* %34, i16 zeroext 5)
  br label %35

; <label>:35:                                     ; preds = %33, %31
  %36 = call i32 @_Z13softuart_readi(i32 0)
  %37 = trunc i32 %36 to i8
  %38 = load i8*, i8** %4, align 8
  %39 = getelementptr inbounds i8, i8* %38, i32 1
  store i8* %39, i8** %4, align 8
  store i8 %37, i8* %38, align 1
  br label %27

; <label>:40:                                     ; preds = %27
  %41 = call zeroext i1 @_Z18softuart_availablei(i32 0)
  br i1 %41, label %44, label %42

; <label>:42:                                     ; preds = %40
  %43 = load i16*, i16** %5, align 8
  call void @vTaskDelayUntil(i16* %43, i16 zeroext 5)
  br label %44

; <label>:44:                                     ; preds = %42, %40
  %45 = call i32 @_Z13softuart_readi(i32 0)
  %46 = load i32, i32* %7, align 4
  store i32 %46, i32* %3, align 4
  br label %47

; <label>:47:                                     ; preds = %44, %17
  %48 = load i32, i32* %3, align 4
  ret i32 %48
}

declare i32 @printf(i8*, ...) #2

declare void @_Z14softuart_closei(i32) #2

; Function Attrs: nounwind
declare i64 @time(i64*) #3

declare i32 @_Z11sendPlcDataPhS_P19tskTaskControlBlockhh(i8*, i8*, %struct.tskTaskControlBlock*, i8 zeroext, i8 zeroext) #2

declare i64 @xQueueGenericSend(%struct.QueueDefinition*, i8*, i16 zeroext, i64) #2

declare zeroext i1 @_Z18softuart_availablei(i32) #2

declare i32 @_Z13softuart_readi(i32) #2

attributes #0 = { noinline optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
