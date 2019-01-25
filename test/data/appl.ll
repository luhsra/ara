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

declare i32 @xQueueGenericSend(%struct.QueueDefinition*, i8*, i16 zeroext, i32) #1

; Function Attrs: noinline optnone
define void @_Z12vSenderTask1Pv(i8* %pvParameters) #0 {
  %pvParameters.addr = alloca i8*, align 4
  %xBlockTime = alloca i16, align 2
  %pcMessage = alloca i8*, align 4
  store i8* %pvParameters, i8** %pvParameters.addr, align 4
  store i16 100, i16* %xBlockTime, align 2
  store i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str, i32 0, i32 0), i8** %pcMessage, align 4
  br label %1

; <label>:1:                                      ; preds = %1, %0
  call void @vTaskDelay(i16 zeroext 100)
  %2 = load %struct.QueueDefinition*, %struct.QueueDefinition** @_ZL7xQueue1, align 4
  %3 = bitcast i8** %pcMessage to i8*
  %call = call i32 @xQueueGenericSend(%struct.QueueDefinition* %2, i8* %3, i16 zeroext 0, i32 0)
  br label %1
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
  store i16 200, i16* %xBlockTime, align 2
  store i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.1, i32 0, i32 0), i8** %pcMessage, align 4
  br label %1

; <label>:1:                                      ; preds = %1, %0
  call void @vTaskDelay(i16 zeroext 200)
  %2 = load %struct.QueueDefinition*, %struct.QueueDefinition** @_ZL7xQueue2, align 4
  %3 = bitcast i8** %pcMessage to i8*
  %call = call i32 @xQueueGenericSend(%struct.QueueDefinition* %2, i8* %3, i16 zeroext 0, i32 0)
  br label %1
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
  %call1 = call %struct.QueueDefinition* @xQueueGenericCreate(i32 1, i32 0, i8 zeroext 3)
  store %struct.QueueDefinition* %call1, %struct.QueueDefinition** @xBinarySemaphore, align 4
  store i16 100, i16* %xDelay100ms, align 2
  br label %1

; <label>:1:                                      ; preds = %24, %0
  %2 = load %struct.QueueDefinition*, %struct.QueueDefinition** %xHandle, align 4
  %cmp = icmp eq %struct.QueueDefinition* %2, null
  br i1 %cmp, label %3, label %4

; <label>:3:                                      ; preds = %1
  br label %24

; <label>:4:                                      ; preds = %1
  %5 = load %struct.QueueDefinition*, %struct.QueueDefinition** %xHandle, align 4
  %6 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xCharPointerQueue, align 4
  %cmp2 = icmp eq %struct.QueueDefinition* %5, %6
  br i1 %cmp2, label %7, label %10

; <label>:7:                                      ; preds = %4
  %8 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xCharPointerQueue, align 4
  %9 = bitcast i8** %pcReceivedString to i8*
  %call3 = call i32 @xQueueReceive(%struct.QueueDefinition* %8, i8* %9, i16 zeroext 0)
  br label %23

; <label>:10:                                     ; preds = %4
  %11 = load %struct.QueueDefinition*, %struct.QueueDefinition** %xHandle, align 4
  %12 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xUint32tQueue, align 4
  %cmp4 = icmp eq %struct.QueueDefinition* %11, %12
  br i1 %cmp4, label %13, label %16

; <label>:13:                                     ; preds = %10
  %14 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xUint32tQueue, align 4
  %15 = bitcast i32* %ulRecievedValue to i8*
  %call5 = call i32 @xQueueReceive(%struct.QueueDefinition* %14, i8* %15, i16 zeroext 0)
  br label %22

; <label>:16:                                     ; preds = %10
  %17 = load %struct.QueueDefinition*, %struct.QueueDefinition** %xHandle, align 4
  %18 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xBinarySemaphore, align 4
  %cmp6 = icmp eq %struct.QueueDefinition* %17, %18
  br i1 %cmp6, label %19, label %21

; <label>:19:                                     ; preds = %16
  %20 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xBinarySemaphore, align 4
  %call7 = call i32 @xQueueSemaphoreTake(%struct.QueueDefinition* %20, i16 zeroext 0)
  br label %21

; <label>:21:                                     ; preds = %19, %16
  br label %22

; <label>:22:                                     ; preds = %21, %13
  br label %23

; <label>:23:                                     ; preds = %22, %7
  br label %24

; <label>:24:                                     ; preds = %23, %3
  br label %1
                                                  ; No predecessors!
  ret void
}

declare i32 @xQueueReceive(%struct.QueueDefinition*, i8*, i16 zeroext) #1

declare i32 @xQueueSemaphoreTake(%struct.QueueDefinition*, i16 zeroext) #1

; Function Attrs: noinline norecurse optnone
define i32 @main() #2 {
  %retval = alloca i32, align 4
  %b = alloca i32, align 4
  %a = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store i32 0, i32* %retval, align 4
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
  %call = call %struct.QueueDefinition* @xQueueGenericCreate(i32 1, i32 1, i8 zeroext 0)
  store %struct.QueueDefinition* %call, %struct.QueueDefinition** @xUint32tQueue, align 4
  %call1 = call %struct.QueueDefinition* @xQueueGenericCreate(i32 1, i32 6, i8 zeroext 0)
  store %struct.QueueDefinition* %call1, %struct.QueueDefinition** @xCharPointerQueue, align 4
  %call2 = call %struct.QueueDefinition* @xQueueCreateSet(i32 2)
  store %struct.QueueDefinition* %call2, %struct.QueueDefinition** @xQueueSet, align 4
  store i32 0, i32* %i, align 4
  br label %9

; <label>:9:                                      ; preds = %18, %8
  %10 = load i32, i32* %i, align 4
  %cmp3 = icmp slt i32 %10, 10
  br i1 %cmp3, label %11, label %20

; <label>:11:                                     ; preds = %9
  store i32 0, i32* %j, align 4
  br label %12

; <label>:12:                                     ; preds = %15, %11
  %13 = load i32, i32* %j, align 4
  %cmp4 = icmp slt i32 %13, 10
  br i1 %cmp4, label %14, label %17

; <label>:14:                                     ; preds = %12
  %call5 = call %struct.QueueDefinition* @xQueueGenericCreate(i32 1, i32 4, i8 zeroext 0)
  store %struct.QueueDefinition* %call5, %struct.QueueDefinition** @_ZL7xQueue2, align 4
  br label %15

; <label>:15:                                     ; preds = %14
  %16 = load i32, i32* %j, align 4
  %inc6 = add nsw i32 %16, 1
  store i32 %inc6, i32* %j, align 4
  br label %12

; <label>:17:                                     ; preds = %12
  br label %18

; <label>:18:                                     ; preds = %17
  %19 = load i32, i32* %i, align 4
  %inc7 = add nsw i32 %19, 1
  store i32 %inc7, i32* %i, align 4
  br label %9

; <label>:20:                                     ; preds = %9
  %21 = load %struct.QueueDefinition*, %struct.QueueDefinition** @_ZL7xQueue1, align 4
  %22 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xQueueSet, align 4
  %call8 = call i32 @xQueueAddToSet(%struct.QueueDefinition* %21, %struct.QueueDefinition* %22)
  %23 = load %struct.QueueDefinition*, %struct.QueueDefinition** @_ZL7xQueue2, align 4
  %24 = load %struct.QueueDefinition*, %struct.QueueDefinition** @xQueueSet, align 4
  %call9 = call i32 @xQueueAddToSet(%struct.QueueDefinition* %23, %struct.QueueDefinition* %24)
  %call10 = call i32 @xTaskCreate(void (i8*)* @_Z12vSenderTask1Pv, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.2, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 1, %struct.tskTaskControlBlock** null)
  %call11 = call i32 @xTaskCreate(void (i8*)* @_Z10xqueueTaskPv, i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.3, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 1, %struct.tskTaskControlBlock** null)
  %call12 = call i32 @xTaskCreate(void (i8*)* @_Z12vSenderTask2Pv, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.4, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 1, %struct.tskTaskControlBlock** null)
  %call13 = call i32 @xTaskCreate(void (i8*)* @_Z27vAMoreRealisticReceiverTaskPv, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.5, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 2, %struct.tskTaskControlBlock** null)
  call void @vTaskStartScheduler()
  br label %25

; <label>:25:                                     ; preds = %25, %20
  br label %25
                                                  ; No predecessors!
  %27 = load i32, i32* %retval, align 4
  ret i32 %27
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
