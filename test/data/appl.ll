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
define void @_Z12vSenderTask1Pv(i8* %pvParameters) #0 {
entry:
  %pvParameters.addr = alloca i8*, align 4
  %xBlockTime = alloca i16, align 2
  %pcMessage = alloca i8*, align 4
  store i8* %pvParameters, i8** %pvParameters.addr, align 4
  store i16 100, i16* %xBlockTime, align 2
  store i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str, i32 0, i32 0), i8** %pcMessage, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.cond, %entry
  call void @vTaskDelay(i16 zeroext 100)
  %0 = load i8*, i8** @_ZL7xQueue1, align 4
  %1 = bitcast i8** %pcMessage to i8*
  %call = call i32 @xQueueGenericSend(i8* %0, i8* %1, i16 zeroext 0, i32 0)
  br label %for.cond

return:                                           ; No predecessors!
  ret void
}

declare void @vTaskDelay(i16 zeroext) #1

declare i32 @xQueueGenericSend(i8*, i8*, i16 zeroext, i32) #1

; Function Attrs: noinline optnone
define void @_Z12vSenderTask2Pv(i8* %pvParameters) #0 {
entry:
  %pvParameters.addr = alloca i8*, align 4
  %xBlockTime = alloca i16, align 2
  %pcMessage = alloca i8*, align 4
  store i8* %pvParameters, i8** %pvParameters.addr, align 4
  store i16 200, i16* %xBlockTime, align 2
  store i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.1, i32 0, i32 0), i8** %pcMessage, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.cond, %entry
  call void @vTaskDelay(i16 zeroext 200)
  %0 = load i8*, i8** @_ZL7xQueue2, align 4
  %1 = bitcast i8** %pcMessage to i8*
  %call = call i32 @xQueueGenericSend(i8* %0, i8* %1, i16 zeroext 0, i32 0)
  br label %for.cond

return:                                           ; No predecessors!
  ret void
}

; Function Attrs: noinline optnone
define void @_Z27vAMoreRealisticReceiverTaskPv(i8* %pvParameters) #0 {
entry:
  %pvParameters.addr = alloca i8*, align 4
  %xHandle = alloca i8*, align 4
  %pcReceivedString = alloca i8*, align 4
  %ulRecievedValue = alloca i32, align 4
  %xDelay100ms = alloca i16, align 2
  store i8* %pvParameters, i8** %pvParameters.addr, align 4
  store i16 100, i16* %xDelay100ms, align 2
  br label %for.cond

for.cond:                                         ; preds = %if.end14, %entry
  %0 = load i8*, i8** @xQueueSet, align 4
  %call = call i8* @xQueueSelectFromSet(i8* %0, i16 zeroext 100)
  store i8* %call, i8** %xHandle, align 4
  %1 = load i8*, i8** %xHandle, align 4
  %cmp = icmp eq i8* %1, null
  br i1 %cmp, label %if.then, label %if.else

if.then:                                          ; preds = %for.cond
  br label %if.end14

if.else:                                          ; preds = %for.cond
  %2 = load i8*, i8** %xHandle, align 4
  %3 = load i8*, i8** @xCharPointerQueue, align 4
  %cmp1 = icmp eq i8* %2, %3
  br i1 %cmp1, label %if.then2, label %if.else4

if.then2:                                         ; preds = %if.else
  %4 = load i8*, i8** @xCharPointerQueue, align 4
  %5 = bitcast i8** %pcReceivedString to i8*
  %call3 = call i32 @xQueueGenericReceive(i8* %4, i8* %5, i16 zeroext 0, i32 0)
  br label %if.end13

if.else4:                                         ; preds = %if.else
  %6 = load i8*, i8** %xHandle, align 4
  %7 = load i8*, i8** @xUint32tQueue, align 4
  %cmp5 = icmp eq i8* %6, %7
  br i1 %cmp5, label %if.then6, label %if.else8

if.then6:                                         ; preds = %if.else4
  %8 = load i8*, i8** @xUint32tQueue, align 4
  %9 = bitcast i32* %ulRecievedValue to i8*
  %call7 = call i32 @xQueueGenericReceive(i8* %8, i8* %9, i16 zeroext 0, i32 0)
  br label %if.end12

if.else8:                                         ; preds = %if.else4
  %10 = load i8*, i8** %xHandle, align 4
  %11 = load i8*, i8** @xBinarySemaphore, align 4
  %cmp9 = icmp eq i8* %10, %11
  br i1 %cmp9, label %if.then10, label %if.end

if.then10:                                        ; preds = %if.else8
  %12 = load i8*, i8** @xBinarySemaphore, align 4
  %call11 = call i32 @xQueueGenericReceive(i8* %12, i8* null, i16 zeroext 0, i32 0)
  br label %if.end

if.end:                                           ; preds = %if.then10, %if.else8
  br label %if.end12

if.end12:                                         ; preds = %if.end, %if.then6
  br label %if.end13

if.end13:                                         ; preds = %if.end12, %if.then2
  br label %if.end14

if.end14:                                         ; preds = %if.end13, %if.then
  br label %for.cond

return:                                           ; No predecessors!
  ret void
}

declare i8* @xQueueSelectFromSet(i8*, i16 zeroext) #1

declare i32 @xQueueGenericReceive(i8*, i8*, i16 zeroext, i32) #1

; Function Attrs: noinline norecurse optnone
define i32 @main() #2 {
entry:
  %retval = alloca i32, align 4
  store i32 0, i32* %retval, align 4
  %call = call i8* @xQueueGenericCreate(i32 1, i32 4, i8 zeroext 0)
  store i8* %call, i8** @_ZL7xQueue1, align 4
  %call1 = call i8* @xQueueGenericCreate(i32 1, i32 4, i8 zeroext 0)
  store i8* %call1, i8** @_ZL7xQueue2, align 4
  %call2 = call i8* @xQueueCreateSet(i32 2)
  store i8* %call2, i8** @xQueueSet, align 4
  %0 = load i8*, i8** @_ZL7xQueue1, align 4
  %1 = load i8*, i8** @xQueueSet, align 4
  %call3 = call i32 @xQueueAddToSet(i8* %0, i8* %1)
  %2 = load i8*, i8** @_ZL7xQueue2, align 4
  %3 = load i8*, i8** @xQueueSet, align 4
  %call4 = call i32 @xQueueAddToSet(i8* %2, i8* %3)
  %call5 = call i32 @xTaskGenericCreate(void (i8*)* @_Z12vSenderTask1Pv, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.2, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 1, i8** null, i32* null, %struct.xMEMORY_REGION* null)
  %call6 = call i32 @xTaskGenericCreate(void (i8*)* @_Z12vSenderTask2Pv, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.3, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 1, i8** null, i32* null, %struct.xMEMORY_REGION* null)
  %call7 = call i32 @xTaskGenericCreate(void (i8*)* @_Z27vAMoreRealisticReceiverTaskPv, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.4, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 2, i8** null, i32* null, %struct.xMEMORY_REGION* null)
  call void @vTaskStartScheduler()
  br label %for.cond

for.cond:                                         ; preds = %for.cond, %entry
  br label %for.cond

return:                                           ; No predecessors!
  %4 = load i32, i32* %retval, align 4
  ret i32 %4
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
!2 = !{!"clang version 6.0.1 (tags/RELEASE_601/final)"}
