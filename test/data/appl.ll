; ModuleID = '../appl/FreeRTOS/i.cc'
source_filename = "../appl/FreeRTOS/i.cc"
target datalayout = "e-m:e-p:32:32-f64:32:64-f80:32-n8:16:32-S128"
target triple = "i386-pc-linux-gnu"

%struct.QueueDefinition = type opaque
%struct.tskTaskControlBlock = type opaque

@xBinarySemaphore = global %struct.QueueDefinition* null, align 4
@"xBinary\E1\B8\BEutex" = global %struct.QueueDefinition* null, align 4
@xCountingSemaphore = global %struct.QueueDefinition* null, align 4
@xMutex = global %struct.QueueDefinition* null, align 4
@xRecursiveMutex = global %struct.QueueDefinition* null, align 4
@.str = private unnamed_addr constant [5 x i8] c"TEST\00", align 1
@.str.1 = private unnamed_addr constant [8 x i8] c"Handler\00", align 1
@.str.2 = private unnamed_addr constant [9 x i8] c"Periodic\00", align 1
@.str.3 = private unnamed_addr constant [16 x i8] c"AFTER SCHEDULER\00", align 1

; Function Attrs: noinline optnone
define void @_Z13vTaskFunctionPv(i8*) #0 {
  %2 = alloca i8*, align 4
  %3 = alloca i16, align 2
  store i8* %0, i8** %2, align 4
  store i16 20, i16* %3, align 2
  %4 = call %struct.QueueDefinition* @xQueueCreateMutex(i8 zeroext 4)
  store %struct.QueueDefinition* %4, %struct.QueueDefinition** @xRecursiveMutex, align 4
  br label %5

; <label>:5:                                      ; preds = %16, %1
  %6 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xRecursiveMutex, align 4
  %7 = call i32 @xQueueTakeMutexRecursive(%struct.QueueDefinition* %6, i16 zeroext 20)
  %8 = icmp eq i32 %7, 1
  br i1 %8, label %9, label %16

; <label>:9:                                      ; preds = %5
  %10 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xRecursiveMutex, align 4
  %11 = call i32 @xQueueTakeMutexRecursive(%struct.QueueDefinition* %10, i16 zeroext 20)
  %12 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xRecursiveMutex, align 4
  %13 = call i32 @xQueueGiveMutexRecursive(%struct.QueueDefinition* %12)
  %14 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xRecursiveMutex, align 4
  %15 = call i32 @xQueueGiveMutexRecursive(%struct.QueueDefinition* %14)
  br label %16

; <label>:16:                                     ; preds = %9, %5
  br label %5
                                                  ; No predecessors!
  ret void
}

declare %struct.QueueDefinition* @xQueueCreateMutex(i8 zeroext) #1

declare i32 @xQueueTakeMutexRecursive(%struct.QueueDefinition*, i16 zeroext) #1

declare i32 @xQueueGiveMutexRecursive(%struct.QueueDefinition*) #1

; Function Attrs: noinline norecurse optnone
define i32 @main() #2 {
  %1 = alloca i32, align 4
  %2 = alloca i16, align 2
  store i32 0, i32* %1, align 4
  %3 = call %struct.QueueDefinition* @xQueueCreateMutex(i8 zeroext 1)
  store %struct.QueueDefinition* %3, %struct.QueueDefinition** @"xBinary\E1\B8\BEutex", align 4
  %4 = call %struct.QueueDefinition* @xQueueCreateMutex(i8 zeroext 1)
  store %struct.QueueDefinition* %4, %struct.QueueDefinition** @xMutex, align 4
  %5 = call %struct.QueueDefinition* @xQueueGenericCreate(i32 1, i32 0, i8 zeroext 3)
  store %struct.QueueDefinition* %5, %struct.QueueDefinition** @xBinarySemaphore, align 4
  call void @_ZL17prvNewPrintStringPKc(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str, i32 0, i32 0))
  %6 = call %struct.QueueDefinition* @xQueueCreateCountingSemaphore(i32 10, i32 0)
  store %struct.QueueDefinition* %6, %struct.QueueDefinition** @xCountingSemaphore, align 4
  %7 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xBinarySemaphore, align 4
  %8 = icmp ne %struct.QueueDefinition* %7, null
  br i1 %8, label %9, label %12

; <label>:9:                                      ; preds = %0
  store i16 100, i16* %2, align 2
  %10 = call i32 @xTaskCreate(void (i8*)* @_Z13vTaskFunctionPv, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.1, i32 0, i32 0), i16 zeroext 100, i8* null, i32 3, %struct.tskTaskControlBlock** null)
  %11 = call i32 @xTaskCreate(void (i8*)* @_ZL12prvPrintTaskPv, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.2, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 1, %struct.tskTaskControlBlock** null)
  call void @vTaskStartScheduler()
  br label %12

; <label>:12:                                     ; preds = %9, %0
  %13 = call i32 @xTaskCreate(void (i8*)* @_ZL12prvPrintTaskPv, i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.3, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 1, %struct.tskTaskControlBlock** null)
  br label %14

; <label>:14:                                     ; preds = %14, %12
  br label %14
                                                  ; No predecessors!
  %16 = load i32, i32* %1, align 4
  ret i32 %16
}

declare %struct.QueueDefinition* @xQueueGenericCreate(i32, i32, i8 zeroext) #1

; Function Attrs: noinline optnone
define internal void @_ZL17prvNewPrintStringPKc(i8*) #0 {
  %2 = alloca i8*, align 4
  store i8* %0, i8** %2, align 4
  %3 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xMutex, align 4
  %4 = call i32 @xQueueSemaphoreTake(%struct.QueueDefinition* %3, i16 zeroext -1)
  %5 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xMutex, align 4
  %6 = call i32 @xQueueGenericSend(%struct.QueueDefinition* %5, i8* null, i16 zeroext 0, i32 0)
  ret void
}

declare %struct.QueueDefinition* @xQueueCreateCountingSemaphore(i32, i32) #1

declare i32 @xTaskCreate(void (i8*)*, i8*, i16 zeroext, i8*, i32, %struct.tskTaskControlBlock**) #1

; Function Attrs: noinline optnone
define internal void @_ZL12prvPrintTaskPv(i8*) #0 {
  %2 = alloca i8*, align 4
  %3 = alloca i8*, align 4
  %4 = alloca i16, align 2
  %5 = alloca i16, align 2
  store i8* %0, i8** %2, align 4
  store i16 32, i16* %4, align 2
  store i16 120, i16* %5, align 2
  %6 = load i16, i16* %5, align 2
  call void @vTaskDelay(i16 zeroext %6)
  store i16 1230, i16* %5, align 2
  %7 = load i8*, i8** %2, align 4
  store i8* %7, i8** %3, align 4
  br label %8

; <label>:8:                                      ; preds = %8, %1
  %9 = load i8*, i8** %3, align 4
  call void @_ZL17prvNewPrintStringPKc(i8* %9)
  call void @vTaskDelay(i16 zeroext 32)
  br label %8
                                                  ; No predecessors!
  ret void
}

declare void @vTaskStartScheduler() #1

declare i32 @xQueueSemaphoreTake(%struct.QueueDefinition*, i16 zeroext) #1

declare i32 @xQueueGenericSend(%struct.QueueDefinition*, i8*, i16 zeroext, i32) #1

declare void @vTaskDelay(i16 zeroext) #1

attributes #0 = { noinline optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noinline norecurse optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"NumRegisterParameters", i32 0}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
