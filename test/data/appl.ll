; ModuleID = '../appl/FreeRTOS/g.cc'
source_filename = "../appl/FreeRTOS/g.cc"
target datalayout = "e-m:e-p:32:32-f64:32:64-f80:32-n8:16:32-S128"
target triple = "i386-pc-linux-gnu"

%struct.xMEMORY_REGION = type { i8*, i32, i32 }

@xCharPointerQueue = global i8* null, align 4
@xUint32tQueue = global i8* null, align 4
@xBinarySemaphore = global i8* null, align 4
@xQueueSet = global i8* null, align 4
@.str = private unnamed_addr constant [28 x i8] c"Message from vSenderTask1\0D\0A\00", align 1
@_ZL7xQueue1 = internal global i8* null, align 4
@.str.1 = private unnamed_addr constant [28 x i8] c"Message from vSenderTask2\0D\0A\00", align 1
@_ZL7xQueue2 = internal global i8* null, align 4
@.str.2 = private unnamed_addr constant [8 x i8] c"Sender1\00", align 1
@.str.3 = private unnamed_addr constant [8 x i8] c"Sender2\00", align 1
@.str.4 = private unnamed_addr constant [9 x i8] c"Receiver\00", align 1

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
  %6 = load i8*, i8** @_ZL7xQueue1, align 4
  %7 = bitcast i8** %4 to i8*
  %8 = call i32 @xQueueGenericSend(i8* %6, i8* %7, i16 zeroext 0, i32 0)
  br label %5
                                                  ; No predecessors!
  ret void
}

declare void @vTaskDelay(i16 zeroext) #1

declare i32 @xQueueGenericSend(i8*, i8*, i16 zeroext, i32) #1

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
  %6 = load i8*, i8** @_ZL7xQueue2, align 4
  %7 = bitcast i8** %4 to i8*
  %8 = call i32 @xQueueGenericSend(i8* %6, i8* %7, i16 zeroext 0, i32 0)
  br label %5
                                                  ; No predecessors!
  ret void
}

; Function Attrs: noinline optnone
define void @_Z27vAMoreRealisticReceiverTaskPv(i8*) #0 {
  %2 = alloca i8*, align 4
  %3 = alloca i8*, align 4
  %4 = alloca i8*, align 4
  %5 = alloca i32, align 4
  %6 = alloca i16, align 2
  store i8* %0, i8** %2, align 4
  store i16 100, i16* %6, align 2
  br label %7

; <label>:7:                                      ; preds = %39, %1
  %8 = load i8*, i8** @xQueueSet, align 4
  %9 = call i8* @xQueueSelectFromSet(i8* %8, i16 zeroext 100)
  store i8* %9, i8** %3, align 4
  %10 = load i8*, i8** %3, align 4
  %11 = icmp eq i8* %10, null
  br i1 %11, label %12, label %13

; <label>:12:                                     ; preds = %7
  br label %39

; <label>:13:                                     ; preds = %7
  %14 = load i8*, i8** %3, align 4
  %15 = load i8*, i8** @xCharPointerQueue, align 4
  %16 = icmp eq i8* %14, %15
  br i1 %16, label %17, label %21

; <label>:17:                                     ; preds = %13
  %18 = load i8*, i8** @xCharPointerQueue, align 4
  %19 = bitcast i8** %4 to i8*
  %20 = call i32 @xQueueGenericReceive(i8* %18, i8* %19, i16 zeroext 0, i32 0)
  br label %38

; <label>:21:                                     ; preds = %13
  %22 = load i8*, i8** %3, align 4
  %23 = load i8*, i8** @xUint32tQueue, align 4
  %24 = icmp eq i8* %22, %23
  br i1 %24, label %25, label %29

; <label>:25:                                     ; preds = %21
  %26 = load i8*, i8** @xUint32tQueue, align 4
  %27 = bitcast i32* %5 to i8*
  %28 = call i32 @xQueueGenericReceive(i8* %26, i8* %27, i16 zeroext 0, i32 0)
  br label %37

; <label>:29:                                     ; preds = %21
  %30 = load i8*, i8** %3, align 4
  %31 = load i8*, i8** @xBinarySemaphore, align 4
  %32 = icmp eq i8* %30, %31
  br i1 %32, label %33, label %36

; <label>:33:                                     ; preds = %29
  %34 = load i8*, i8** @xBinarySemaphore, align 4
  %35 = call i32 @xQueueGenericReceive(i8* %34, i8* null, i16 zeroext 0, i32 0)
  br label %36

; <label>:36:                                     ; preds = %33, %29
  br label %37

; <label>:37:                                     ; preds = %36, %25
  br label %38

; <label>:38:                                     ; preds = %37, %17
  br label %39

; <label>:39:                                     ; preds = %38, %12
  br label %7
                                                  ; No predecessors!
  ret void
}

declare i8* @xQueueSelectFromSet(i8*, i16 zeroext) #1

declare i32 @xQueueGenericReceive(i8*, i8*, i16 zeroext, i32) #1

; Function Attrs: noinline norecurse optnone
define i32 @main() #2 {
  %1 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %2 = call i8* @xQueueGenericCreate(i32 1, i32 4, i8 zeroext 0)
  store i8* %2, i8** @_ZL7xQueue1, align 4
  %3 = call i8* @xQueueGenericCreate(i32 1, i32 4, i8 zeroext 0)
  store i8* %3, i8** @_ZL7xQueue2, align 4
  %4 = call i8* @xQueueCreateSet(i32 2)
  store i8* %4, i8** @xQueueSet, align 4
  %5 = load i8*, i8** @_ZL7xQueue1, align 4
  %6 = load i8*, i8** @xQueueSet, align 4
  %7 = call i32 @xQueueAddToSet(i8* %5, i8* %6)
  %8 = load i8*, i8** @_ZL7xQueue2, align 4
  %9 = load i8*, i8** @xQueueSet, align 4
  %10 = call i32 @xQueueAddToSet(i8* %8, i8* %9)
  %11 = call i32 @xTaskGenericCreate(void (i8*)* @_Z12vSenderTask1Pv, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.2, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 1, i8** null, i32* null, %struct.xMEMORY_REGION* null)
  %12 = call i32 @xTaskGenericCreate(void (i8*)* @_Z12vSenderTask2Pv, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.3, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 1, i8** null, i32* null, %struct.xMEMORY_REGION* null)
  %13 = call i32 @xTaskGenericCreate(void (i8*)* @_Z27vAMoreRealisticReceiverTaskPv, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.4, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 2, i8** null, i32* null, %struct.xMEMORY_REGION* null)
  call void @vTaskStartScheduler()
  br label %14

; <label>:14:                                     ; preds = %14, %0
  br label %14
                                                  ; No predecessors!
  %16 = load i32, i32* %1, align 4
  ret i32 %16
}

declare i8* @xQueueGenericCreate(i32, i32, i8 zeroext) #1

declare i8* @xQueueCreateSet(i32) #1

declare i32 @xQueueAddToSet(i8*, i8*) #1

declare i32 @xTaskGenericCreate(void (i8*)*, i8*, i16 zeroext, i8*, i32, i8**, i32*, %struct.xMEMORY_REGION*) #1

declare void @vTaskStartScheduler() #1

attributes #0 = { noinline optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noinline norecurse optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"NumRegisterParameters", i32 0}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
