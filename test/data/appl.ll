; ModuleID = '../appl/FreeRTOS/wrong_scheduler_access.cc'
source_filename = "../appl/FreeRTOS/wrong_scheduler_access.cc"
target datalayout = "e-m:e-p:32:32-f64:32:64-f80:32-n8:16:32-S128"
target triple = "i386-pc-linux-gnu"

%struct.tskTaskControlBlock = type opaque

@.str = private unnamed_addr constant [6 x i8] c"Task1\00", align 1
@.str.1 = private unnamed_addr constant [6 x i8] c"Task2\00", align 1

; Function Attrs: noinline optnone
define void @_Z12tmp_functioni(i32 %b) #0 {
  %b.addr = alloca i32, align 4
  store i32 %b, i32* %b.addr, align 4
  %1 = load i32, i32* %b.addr, align 4
  %cmp = icmp eq i32 %1, 23
  br i1 %cmp, label %2, label %3

; <label>:2:                                      ; preds = %0
  call void @vTaskExitCritical()
  br label %4

; <label>:3:                                      ; preds = %0
  call void @vTaskExitCritical()
  br label %4

; <label>:4:                                      ; preds = %3, %2
  ret void
}

declare void @vTaskExitCritical() #1

; Function Attrs: noinline optnone
define void @_Z5Task1Pv(i8* %pvParameters) #0 {
  %pvParameters.addr = alloca i8*, align 4
  %a = alloca i32, align 4
  %b = alloca i32, align 4
  store i8* %pvParameters, i8** %pvParameters.addr, align 4
  call void @vTaskEnterCritical()
  call void @_Z12tmp_functioni(i32 34)
  store i32 0, i32* %a, align 4
  %1 = load i32, i32* %a, align 4
  %add = add nsw i32 %1, 1243
  store i32 %add, i32* %b, align 4
  ret void
}

declare void @vTaskEnterCritical() #1

; Function Attrs: noinline optnone
define void @_Z5Task2Pv(i8* %pvParameters) #0 {
  %pvParameters.addr = alloca i8*, align 4
  store i8* %pvParameters, i8** %pvParameters.addr, align 4
  call void @_Z12tmp_functioni(i32 43)
  ret void
}

; Function Attrs: noinline optnone
define void @_Z9test_funci(i32 %b) #0 {
  %b.addr = alloca i32, align 4
  store i32 %b, i32* %b.addr, align 4
  %1 = load i32, i32* %b.addr, align 4
  %cmp = icmp eq i32 %1, 100
  br i1 %cmp, label %2, label %3

; <label>:2:                                      ; preds = %0
  call void @vTaskStartScheduler()
  br label %3

; <label>:3:                                      ; preds = %2, %0
  call void @vTaskStartScheduler()
  ret void
}

declare void @vTaskStartScheduler() #1

; Function Attrs: noinline nounwind optnone
define void @_Z10test_func1v() #2 {
  ret void
}

; Function Attrs: noinline norecurse optnone
define i32 @main() #3 {
  %retval = alloca i32, align 4
  %a = alloca i32, align 4
  store i32 0, i32* %retval, align 4
  store i32 4, i32* %a, align 4
  %1 = load i32, i32* %a, align 4
  %cmp = icmp eq i32 23423, %1
  br i1 %cmp, label %2, label %3

; <label>:2:                                      ; preds = %0
  call void @_Z9test_funci(i32 324)
  call void @_Z10test_func1v()
  br label %3

; <label>:3:                                      ; preds = %2, %0
  %call = call i32 @xTaskCreate(void (i8*)* @_Z5Task1Pv, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 1, %struct.tskTaskControlBlock** null)
  call void @vTaskStartScheduler()
  %call1 = call i32 @xTaskCreate(void (i8*)* @_Z5Task2Pv, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.1, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 2, %struct.tskTaskControlBlock** null)
  br label %4

; <label>:4:                                      ; preds = %4, %3
  br label %4
                                                  ; No predecessors!
  %6 = load i32, i32* %retval, align 4
  ret i32 %6
}

declare i32 @xTaskCreate(void (i8*)*, i8*, i16 zeroext, i8*, i32, %struct.tskTaskControlBlock**) #1

attributes #0 = { noinline optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { noinline norecurse optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"NumRegisterParameters", i32 0}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
