; ModuleID = '../appl/FreeRTOS/loop_detection.cc'
source_filename = "../appl/FreeRTOS/loop_detection.cc"
target datalayout = "e-m:e-p:32:32-f64:32:64-f80:32-n8:16:32-S128"
target triple = "i386-pc-linux-gnu"

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
@xCharPointerQueue = global %struct.QueueDefinition* null, align 4
@xUint32tQueue = global %struct.QueueDefinition* null, align 4
@xBinaryMutex1 = global %struct.QueueDefinition* null, align 4
@xBinaryMutex2 = global %struct.QueueDefinition* null, align 4
@xBinaryMutex3 = global %struct.QueueDefinition* null, align 4
@xBinarySemaphore = global %struct.QueueDefinition* null, align 4
@_ZL7xQueue1 = internal global %struct.QueueDefinition* null, align 4
@_ZL7xQueue2 = internal global %struct.QueueDefinition* null, align 4
@.str = private unnamed_addr constant [6 x i8] c"Task1\00", align 1
@.str.1 = private unnamed_addr constant [6 x i8] c"Task2\00", align 1

; Function Attrs: noinline optnone
define void @_Z15test_function_1v() #0 {
  call void @_Z15test_function_2v()
  ret void
}

; Function Attrs: noinline optnone
define void @_Z15test_function_2v() #0 {
  call void @_Z15test_function_3v()
  ret void
}

; Function Attrs: noinline optnone
define void @_Z15test_function_3v() #0 {
  call void @_Z12vSenderTask2Pv(i8* null)
  ret void
}

; Function Attrs: noinline optnone
define void @_Z12vSenderTask2Pv(i8* %pvParameters) #0 {
  %pvParameters.addr = alloca i8*, align 4
  store i8* %pvParameters, i8** %pvParameters.addr, align 4
  %call = call %struct.QueueDefinition* @xQueueGenericCreate(i32 100, i32 1, i8 zeroext 0)
  store %struct.QueueDefinition* %call, %struct.QueueDefinition** @_ZL7xQueue2, align 4
  ret void
}

; Function Attrs: noinline optnone
define void @_Z12vSenderTask1Pv(i8* %pvParameters) #0 {
  %pvParameters.addr = alloca i8*, align 4
  store i8* %pvParameters, i8** %pvParameters.addr, align 4
  br label %1

; <label>:1:                                      ; preds = %1, %0
  %call = call %struct.QueueDefinition* @xQueueGenericCreate(i32 100, i32 1, i8 zeroext 0)
  store %struct.QueueDefinition* %call, %struct.QueueDefinition** @_ZL7xQueue1, align 4
  call void @_Z15test_function_1v()
  br label %1
                                                  ; No predecessors!
  ret void
}

declare %struct.QueueDefinition* @xQueueGenericCreate(i32, i32, i8 zeroext) #1

; Function Attrs: noinline norecurse optnone
define i32 @main() #2 {
  %retval = alloca i32, align 4
  store i32 0, i32* %retval, align 4
  %call = call i32 @xTaskCreate(void (i8*)* @_Z12vSenderTask1Pv, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 1, %struct.tskTaskControlBlock** null)
  %call1 = call i32 @xTaskCreate(void (i8*)* @_Z12vSenderTask2Pv, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.1, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 1, %struct.tskTaskControlBlock** null)
  call void @vTaskStartScheduler()
  br label %1

; <label>:1:                                      ; preds = %1, %0
  br label %1
                                                  ; No predecessors!
  %3 = load i32, i32* %retval, align 4
  ret i32 %3
}

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
