; ModuleID = '../appl/FreeRTOS/timer.cc'
source_filename = "../appl/FreeRTOS/timer.cc"
target datalayout = "e-m:e-p:32:32-f64:32:64-f80:32-n8:16:32-S128"
target triple = "i386-pc-linux-gnu"

%struct.tmrTimerControl = type opaque

@xTimer = global %struct.tmrTimerControl* null, align 4
@.str = private unnamed_addr constant [6 x i8] c"Timer\00", align 1

; Function Attrs: noinline optnone
define void @_Z14vTimerCallbackP15tmrTimerControl(%struct.tmrTimerControl* %xTimer) #0 {
  %xTimer.addr = alloca %struct.tmrTimerControl*, align 4
  %ulMaxExpiryCountBeforeStopping = alloca i32, align 4
  %ulCount = alloca i32, align 4
  store %struct.tmrTimerControl* %xTimer, %struct.tmrTimerControl** %xTimer.addr, align 4
  store i32 10, i32* %ulMaxExpiryCountBeforeStopping, align 4
  %1 = load %struct.tmrTimerControl*, %struct.tmrTimerControl** %xTimer.addr, align 4
  %call = call i8* @pvTimerGetTimerID(%struct.tmrTimerControl* %1)
  %2 = ptrtoint i8* %call to i32
  store i32 %2, i32* %ulCount, align 4
  %3 = load i32, i32* %ulCount, align 4
  %inc = add i32 %3, 1
  store i32 %inc, i32* %ulCount, align 4
  %4 = load i32, i32* %ulCount, align 4
  %cmp = icmp uge i32 %4, 10
  br i1 %cmp, label %5, label %7

; <label>:5:                                      ; preds = %0
  %6 = load %struct.tmrTimerControl*, %struct.tmrTimerControl** %xTimer.addr, align 4
  %call1 = call i32 @xTimerGenericCommand(%struct.tmrTimerControl* %6, i32 3, i16 zeroext 0, i32* null, i16 zeroext 0)
  br label %11

; <label>:7:                                      ; preds = %0
  %8 = load %struct.tmrTimerControl*, %struct.tmrTimerControl** %xTimer.addr, align 4
  %9 = load i32, i32* %ulCount, align 4
  %10 = inttoptr i32 %9 to i8*
  call void @vTimerSetTimerID(%struct.tmrTimerControl* %8, i8* %10)
  br label %11

; <label>:11:                                     ; preds = %7, %5
  ret void
}

declare i8* @pvTimerGetTimerID(%struct.tmrTimerControl*) #1

declare i32 @xTimerGenericCommand(%struct.tmrTimerControl*, i32, i16 zeroext, i32*, i16 zeroext) #1

declare void @vTimerSetTimerID(%struct.tmrTimerControl*, i8*) #1

; Function Attrs: noinline norecurse optnone
define i32 @main() #2 {
  %retval = alloca i32, align 4
  %x = alloca i32, align 4
  store i32 0, i32* %retval, align 4
  store i32 10, i32* %x, align 4
  %call = call %struct.tmrTimerControl* @xTimerCreate(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str, i32 0, i32 0), i16 zeroext 100, i32 1, i8* null, void (%struct.tmrTimerControl*)* @_Z14vTimerCallbackP15tmrTimerControl)
  store %struct.tmrTimerControl* %call, %struct.tmrTimerControl** @xTimer, align 4
  %1 = load %struct.tmrTimerControl*, %struct.tmrTimerControl** @xTimer, align 4
  %cmp = icmp eq %struct.tmrTimerControl* %1, null
  br i1 %cmp, label %2, label %3

; <label>:2:                                      ; preds = %0
  br label %7

; <label>:3:                                      ; preds = %0
  %4 = load %struct.tmrTimerControl*, %struct.tmrTimerControl** @xTimer, align 4
  %call1 = call zeroext i16 @xTaskGetTickCount()
  %call2 = call i32 @xTimerGenericCommand(%struct.tmrTimerControl* %4, i32 1, i16 zeroext %call1, i32* null, i16 zeroext 0)
  %cmp3 = icmp ne i32 %call2, 1
  br i1 %cmp3, label %5, label %6

; <label>:5:                                      ; preds = %3
  br label %6

; <label>:6:                                      ; preds = %5, %3
  br label %7

; <label>:7:                                      ; preds = %6, %2
  call void @vTaskStartScheduler()
  br label %8

; <label>:8:                                      ; preds = %8, %7
  br label %8
                                                  ; No predecessors!
  %10 = load i32, i32* %retval, align 4
  ret i32 %10
}

declare %struct.tmrTimerControl* @xTimerCreate(i8*, i16 zeroext, i32, i8*, void (%struct.tmrTimerControl*)*) #1

declare zeroext i16 @xTaskGetTickCount() #1

declare void @vTaskStartScheduler() #1

attributes #0 = { noinline optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noinline norecurse optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"NumRegisterParameters", i32 0}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
