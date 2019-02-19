; ModuleID = 'main.cc'
source_filename = "main.cc"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.QueueDefinition = type opaque
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
@.str = private unnamed_addr constant [14 x i8] c"SDK version:\0A\00", align 1
@xPLCSendSemaphore = external global %struct.QueueDefinition*, align 8
@.str.1 = private unnamed_addr constant [6 x i8] c"Blink\00", align 1
@.str.2 = private unnamed_addr constant [9 x i8] c"PLC Init\00", align 1
@.str.3 = private unnamed_addr constant [8 x i8] c"PLC Rcv\00", align 1
@xPLCTaskRcv = external global %struct.tskTaskControlBlock*, align 8
@.str.4 = private unnamed_addr constant [9 x i8] c"PLC Send\00", align 1
@xPLCTaskSend = external global %struct.tskTaskControlBlock*, align 8

; Function Attrs: noinline optnone uwtable
define void @_Z9blinkTaskPv(i8*) #0 {
  %2 = alloca i8*, align 8
  store i8* %0, i8** %2, align 8
  br label %3

; <label>:3:                                      ; preds = %1, %3
  call void @vTaskDelay(i16 zeroext 1000)
  call void @vTaskDelay(i16 zeroext 1000)
  br label %3
                                                  ; No predecessors!
  ret void
}

declare void @vTaskDelay(i16 zeroext) #1

; Function Attrs: noinline norecurse optnone uwtable
define i32 @main() #2 {
  %1 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %2 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str, i32 0, i32 0), i32 123)
  call void @_Z8i2c_inithh(i8 zeroext 5, i8 zeroext 4)
  %3 = call %struct.QueueDefinition* @xQueueCreateMutex(i8 zeroext 1)
  store %struct.QueueDefinition* %3, %struct.QueueDefinition** @xPLCSendSemaphore, align 8
  %4 = call i32 @_Z14initFileSystemv()
  call void @_Z16initDeviceByModev()
  %5 = call i64 @xTaskCreate(void (i8*)* @_Z9blinkTaskPv, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.1, i32 0, i32 0), i16 zeroext 256, i8* null, i64 2, %struct.tskTaskControlBlock** null)
  %6 = call i64 @xTaskCreate(void (i8*)* @_Z11initPlcTaskPv, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.2, i32 0, i32 0), i16 zeroext 256, i8* null, i64 3, %struct.tskTaskControlBlock** null)
  %7 = call i64 @xTaskCreate(void (i8*)* @_Z10plcTaskRcvPv, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.3, i32 0, i32 0), i16 zeroext 256, i8* null, i64 3, %struct.tskTaskControlBlock** @xPLCTaskRcv)
  %8 = call i64 @xTaskCreate(void (i8*)* @_Z11plcTaskSendPv, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.4, i32 0, i32 0), i16 zeroext 256, i8* null, i64 3, %struct.tskTaskControlBlock** @xPLCTaskSend)
  ret i32 0
}

declare i32 @printf(i8*, ...) #1

declare void @_Z8i2c_inithh(i8 zeroext, i8 zeroext) #1

declare %struct.QueueDefinition* @xQueueCreateMutex(i8 zeroext) #1

declare i32 @_Z14initFileSystemv() #1

declare void @_Z16initDeviceByModev() #1

declare i64 @xTaskCreate(void (i8*)*, i8*, i16 zeroext, i8*, i64, %struct.tskTaskControlBlock**) #1

declare void @_Z11initPlcTaskPv(i8*) #1

declare void @_Z10plcTaskRcvPv(i8*) #1

declare void @_Z11plcTaskSendPv(i8*) #1

attributes #0 = { noinline optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noinline norecurse optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
