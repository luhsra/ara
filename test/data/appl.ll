; ModuleID = '../appl/FreeRTOS/g.cc'
source_filename = "../appl/FreeRTOS/g.cc"
target datalayout = "e-m:e-p:32:32-f64:32:64-f80:32-n8:16:32-S128"
target triple = "i386-pc-linux-gnu"

%struct.QueueDefinition = type opaque
%struct.AMessage = type { i8, [20 x i8] }
%struct.tskTaskControlBlock = type opaque

@xCharPointerQueue = global %struct.QueueDefinition* null, align 4
@xUint32tQueue = global %struct.QueueDefinition* null, align 4
@xBinarySemaphore = global %struct.QueueDefinition* null, align 4
@xQueueSet = global %struct.QueueDefinition* null, align 4
@xMessage = global %struct.AMessage zeroinitializer, align 1
@ulVar = global i32 10, align 4
@_ZL7xQueue1 = internal global %struct.QueueDefinition* null, align 4
@_ZL7xQueue2 = internal global %struct.QueueDefinition* null, align 4
@.str = private unnamed_addr constant [28 x i8] c"Message from vSenderTask1\0D\0A\00", align 1
@.str.1 = private unnamed_addr constant [28 x i8] c"Message from vSenderTask2\0D\0A\00", align 1
@.str.2 = private unnamed_addr constant [8 x i8] c"Sender1\00", align 1
@.str.3 = private unnamed_addr constant [10 x i8] c"QueueTask\00", align 1
@.str.4 = private unnamed_addr constant [8 x i8] c"Sender2\00", align 1
@.str.5 = private unnamed_addr constant [9 x i8] c"Receiver\00", align 1

; Function Attrs: noinline optnone
define void @_Z10xqueueTaskPv(i8*) #0 {
  %2 = alloca i8*, align 4
  %3 = alloca %struct.AMessage*, align 4
  store i8* %0, i8** %2, align 4
  %4 = call %struct.QueueDefinition* @xQueueGenericCreate(i32 10, i32 4, i8 zeroext 0)
  store %struct.QueueDefinition* %4, %struct.QueueDefinition** @_ZL7xQueue1, align 4
  %5 = call %struct.QueueDefinition* @xQueueGenericCreate(i32 10, i32 4, i8 zeroext 0)
  store %struct.QueueDefinition* %5, %struct.QueueDefinition** @_ZL7xQueue2, align 4
  %6 = load %struct.QueueDefinition*, %struct.QueueDefinition** @_ZL7xQueue1, align 4
  %7 = icmp ne %struct.QueueDefinition* %6, null
  br i1 %7, label %8, label %14

; <label>:8:                                      ; preds = %1
  %9 = load %struct.QueueDefinition*, %struct.QueueDefinition** @_ZL7xQueue1, align 4
  %10 = call i32 @xQueueGenericSend(%struct.QueueDefinition* %9, i8* bitcast (i32* @ulVar to i8*), i16 zeroext 10, i32 1)
  %11 = icmp ne i32 %10, 1
  br i1 %11, label %12, label %13

; <label>:12:                                     ; preds = %8
  br label %13

; <label>:13:                                     ; preds = %12, %8
  br label %14

; <label>:14:                                     ; preds = %13, %1
  %15 = load %struct.QueueDefinition*, %struct.QueueDefinition** @_ZL7xQueue2, align 4
  %16 = icmp ne %struct.QueueDefinition* %15, null
  br i1 %16, label %17, label %21

; <label>:17:                                     ; preds = %14
  store %struct.AMessage* @xMessage, %struct.AMessage** %3, align 4
  %18 = load %struct.QueueDefinition*, %struct.QueueDefinition** @_ZL7xQueue2, align 4
  %19 = bitcast %struct.AMessage** %3 to i8*
  %20 = call i32 @xQueueGenericSend(%struct.QueueDefinition* %18, i8* %19, i16 zeroext 0, i32 1)
  br label %21

; <label>:21:                                     ; preds = %17, %14
  ret void
}

declare %struct.QueueDefinition* @xQueueGenericCreate(i32, i32, i8 zeroext) #1

declare i32 @xQueueGenericSend(%struct.QueueDefinition*, i8*, i16 zeroext, i32) #1

; Function Attrs: noinline optnone
define void @_Z12vSenderTask1Pv(i8*) #0 {
  %2 = alloca i8*, align 4
  %3 = alloca i16, align 2
  %4 = alloca i8*, align 4
  store i8* %0, i8** %2, align 4
  store i16 100, i16* %3, align 2
  store i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str, i32 0, i32 0), i8** %4, align 4
  br label %5

; <label>:5:                                      ; preds = %5, %1
  call void @vTaskDelay(i16 zeroext 100)
  %6 = load %struct.QueueDefinition*, %struct.QueueDefinition** @_ZL7xQueue1, align 4
  %7 = bitcast i8** %4 to i8*
  %8 = call i32 @xQueueGenericSend(%struct.QueueDefinition* %6, i8* %7, i16 zeroext 0, i32 0)
  br label %5
                                                  ; No predecessors!
  ret void
}

declare void @vTaskDelay(i16 zeroext) #1

; Function Attrs: noinline optnone
define void @_Z12vSenderTask2Pv(i8*) #0 {
  %2 = alloca i8*, align 4
  %3 = alloca i16, align 2
  %4 = alloca i8*, align 4
  store i8* %0, i8** %2, align 4
  store i16 200, i16* %3, align 2
  store i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.1, i32 0, i32 0), i8** %4, align 4
  br label %5

; <label>:5:                                      ; preds = %5, %1
  call void @vTaskDelay(i16 zeroext 200)
  %6 = load %struct.QueueDefinition*, %struct.QueueDefinition** @_ZL7xQueue2, align 4
  %7 = bitcast i8** %4 to i8*
  %8 = call i32 @xQueueGenericSend(%struct.QueueDefinition* %6, i8* %7, i16 zeroext 0, i32 0)
  br label %5
                                                  ; No predecessors!
  ret void
}

; Function Attrs: noinline optnone
define void @_Z27vAMoreRealisticReceiverTaskPv(i8*) #0 {
  %2 = alloca i8*, align 4
  %3 = alloca %struct.QueueDefinition*, align 4
  %4 = alloca i8*, align 4
  %5 = alloca i32, align 4
  %6 = alloca i16, align 2
  store i8* %0, i8** %2, align 4
  %7 = call %struct.QueueDefinition* @xQueueGenericCreate(i32 100, i32 1, i8 zeroext 0)
  store %struct.QueueDefinition* %7, %struct.QueueDefinition** @_ZL7xQueue1, align 4
  %8 = call %struct.QueueDefinition* @xQueueGenericCreate(i32 1, i32 0, i8 zeroext 3)
  store %struct.QueueDefinition* %8, %struct.QueueDefinition** @xBinarySemaphore, align 4
  store i16 100, i16* %6, align 2
  br label %9

; <label>:9:                                      ; preds = %39, %1
  %10 = load %struct.QueueDefinition*, %struct.QueueDefinition** %3, align 4
  %11 = icmp eq %struct.QueueDefinition* %10, null
  br i1 %11, label %12, label %13

; <label>:12:                                     ; preds = %9
  br label %39

; <label>:13:                                     ; preds = %9
  %14 = load %struct.QueueDefinition*, %struct.QueueDefinition** %3, align 4
  %15 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xCharPointerQueue, align 4
  %16 = icmp eq %struct.QueueDefinition* %14, %15
  br i1 %16, label %17, label %21

; <label>:17:                                     ; preds = %13
  %18 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xCharPointerQueue, align 4
  %19 = bitcast i8** %4 to i8*
  %20 = call i32 @xQueueReceive(%struct.QueueDefinition* %18, i8* %19, i16 zeroext 0)
  br label %38

; <label>:21:                                     ; preds = %13
  %22 = load %struct.QueueDefinition*, %struct.QueueDefinition** %3, align 4
  %23 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xUint32tQueue, align 4
  %24 = icmp eq %struct.QueueDefinition* %22, %23
  br i1 %24, label %25, label %29

; <label>:25:                                     ; preds = %21
  %26 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xUint32tQueue, align 4
  %27 = bitcast i32* %5 to i8*
  %28 = call i32 @xQueueReceive(%struct.QueueDefinition* %26, i8* %27, i16 zeroext 0)
  br label %37

; <label>:29:                                     ; preds = %21
  %30 = load %struct.QueueDefinition*, %struct.QueueDefinition** %3, align 4
  %31 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xBinarySemaphore, align 4
  %32 = icmp eq %struct.QueueDefinition* %30, %31
  br i1 %32, label %33, label %36

; <label>:33:                                     ; preds = %29
  %34 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xBinarySemaphore, align 4
  %35 = call i32 @xQueueSemaphoreTake(%struct.QueueDefinition* %34, i16 zeroext 0)
  br label %36

; <label>:36:                                     ; preds = %33, %29
  br label %37

; <label>:37:                                     ; preds = %36, %25
  br label %38

; <label>:38:                                     ; preds = %37, %17
  br label %39

; <label>:39:                                     ; preds = %38, %12
  br label %9
                                                  ; No predecessors!
  ret void
}

declare i32 @xQueueReceive(%struct.QueueDefinition*, i8*, i16 zeroext) #1

declare i32 @xQueueSemaphoreTake(%struct.QueueDefinition*, i16 zeroext) #1

; Function Attrs: noinline norecurse optnone
define i32 @main() #2 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  store i32 0, i32* %2, align 4
  store i32 0, i32* %3, align 4
  br label %6

; <label>:6:                                      ; preds = %13, %0
  %7 = load i32, i32* %3, align 4
  %8 = icmp slt i32 %7, 100
  br i1 %8, label %9, label %16

; <label>:9:                                      ; preds = %6
  %10 = load i32, i32* %2, align 4
  %11 = load i32, i32* %3, align 4
  %12 = add nsw i32 %10, %11
  store i32 %12, i32* %2, align 4
  br label %13

; <label>:13:                                     ; preds = %9
  %14 = load i32, i32* %3, align 4
  %15 = add nsw i32 %14, 1
  store i32 %15, i32* %3, align 4
  br label %6

; <label>:16:                                     ; preds = %6
  %17 = call %struct.QueueDefinition* @xQueueGenericCreate(i32 1, i32 1, i8 zeroext 0)
  store %struct.QueueDefinition* %17, %struct.QueueDefinition** @xUint32tQueue, align 4
  %18 = call %struct.QueueDefinition* @xQueueGenericCreate(i32 1, i32 6, i8 zeroext 0)
  store %struct.QueueDefinition* %18, %struct.QueueDefinition** @xCharPointerQueue, align 4
  %19 = call %struct.QueueDefinition* @xQueueCreateSet(i32 2)
  store %struct.QueueDefinition* %19, %struct.QueueDefinition** @xQueueSet, align 4
  store i32 0, i32* %4, align 4
  br label %20

; <label>:20:                                     ; preds = %33, %16
  %21 = load i32, i32* %4, align 4
  %22 = icmp slt i32 %21, 10
  br i1 %22, label %23, label %36

; <label>:23:                                     ; preds = %20
  store i32 0, i32* %5, align 4
  br label %24

; <label>:24:                                     ; preds = %29, %23
  %25 = load i32, i32* %5, align 4
  %26 = icmp slt i32 %25, 10
  br i1 %26, label %27, label %32

; <label>:27:                                     ; preds = %24
  %28 = call %struct.QueueDefinition* @xQueueGenericCreate(i32 1, i32 4, i8 zeroext 0)
  store %struct.QueueDefinition* %28, %struct.QueueDefinition** @_ZL7xQueue2, align 4
  br label %29

; <label>:29:                                     ; preds = %27
  %30 = load i32, i32* %5, align 4
  %31 = add nsw i32 %30, 1
  store i32 %31, i32* %5, align 4
  br label %24

; <label>:32:                                     ; preds = %24
  br label %33

; <label>:33:                                     ; preds = %32
  %34 = load i32, i32* %4, align 4
  %35 = add nsw i32 %34, 1
  store i32 %35, i32* %4, align 4
  br label %20

; <label>:36:                                     ; preds = %20
  %37 = load %struct.QueueDefinition*, %struct.QueueDefinition** @_ZL7xQueue1, align 4
  %38 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xQueueSet, align 4
  %39 = call i32 @xQueueAddToSet(%struct.QueueDefinition* %37, %struct.QueueDefinition* %38)
  %40 = load %struct.QueueDefinition*, %struct.QueueDefinition** @_ZL7xQueue2, align 4
  %41 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xQueueSet, align 4
  %42 = call i32 @xQueueAddToSet(%struct.QueueDefinition* %40, %struct.QueueDefinition* %41)
  %43 = call i32 @xTaskCreate(void (i8*)* @_Z12vSenderTask1Pv, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.2, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 1, %struct.tskTaskControlBlock** null)
  %44 = call i32 @xTaskCreate(void (i8*)* @_Z10xqueueTaskPv, i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.3, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 1, %struct.tskTaskControlBlock** null)
  %45 = call i32 @xTaskCreate(void (i8*)* @_Z12vSenderTask2Pv, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.4, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 1, %struct.tskTaskControlBlock** null)
  %46 = call i32 @xTaskCreate(void (i8*)* @_Z27vAMoreRealisticReceiverTaskPv, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.5, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 2, %struct.tskTaskControlBlock** null)
  call void @vTaskStartScheduler()
  br label %47

; <label>:47:                                     ; preds = %47, %36
  br label %47
                                                  ; No predecessors!
  %49 = load i32, i32* %1, align 4
  ret i32 %49
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
