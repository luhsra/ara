; ModuleID = '../../../GPSLogger/Src/GPSLogger.cpp'
source_filename = "../../../GPSLogger/Src/GPSLogger.cpp"
target datalayout = "e-m:e-p:32:32-f64:32:64-f80:32-n8:16:32-S128"
target triple = "i386-pc-linux-gnu"

%struct.tskTaskControlBlock = type opaque

@m_start = global i32 0, align 4
@m_startInits = global i32 0, align 4
@m_startSched = global i32 0, align 4
@.str = private unnamed_addr constant [10 x i8] c"SD Thread\00", align 1
@.str.1 = private unnamed_addr constant [11 x i8] c"LED Thread\00", align 1
@.str.2 = private unnamed_addr constant [13 x i8] c"Display Task\00", align 1
@.str.3 = private unnamed_addr constant [15 x i8] c"Buttons Thread\00", align 1
@.str.4 = private unnamed_addr constant [9 x i8] c"GPS Task\00", align 1

; Function Attrs: noinline norecurse optnone
define i32 @main() #0 {
  %ulNewMaskValue.addr.i = alloca i32, align 4
  %retval = alloca i32, align 4
  store i32 0, i32* %retval, align 4
  %1 = load volatile i32, i32* inttoptr (i32 -536866812 to i32*), align 4
  store i32 %1, i32* @m_start, align 4
  call void @_Z9InitBoardv()
  call void @_Z15initDebugSerialv()
  store i32 0, i32* %ulNewMaskValue.addr.i, align 4
  %2 = load i32, i32* %ulNewMaskValue.addr.i, align 4
  call void asm sideeffect "\09msr basepri, $0\09", "r,~{dirflag},~{fpsr},~{flags}"(i32 %2) #2, !srcloc !3
  call void @_Z11initButtonsv()
  %3 = load volatile i32, i32* inttoptr (i32 -536866812 to i32*), align 4
  store i32 %3, i32* @m_startInits, align 4
  %call = call i32 @xTaskCreate(void (i8*)* @_Z9vSDThreadPv, i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str, i32 0, i32 0), i16 zeroext 512, i8* null, i32 4, %struct.tskTaskControlBlock** null)
  %call1 = call i32 @xTaskCreate(void (i8*)* @_Z10vLEDThreadPv, i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.1, i32 0, i32 0), i16 zeroext 170, i8* null, i32 2, %struct.tskTaskControlBlock** null)
  %call2 = call i32 @xTaskCreate(void (i8*)* @_Z12vDisplayTaskPv, i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.2, i32 0, i32 0), i16 zeroext 768, i8* null, i32 2, %struct.tskTaskControlBlock** null)
  %call3 = call i32 @xTaskCreate(void (i8*)* @_Z14vButtonsThreadPv, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.3, i32 0, i32 0), i16 zeroext 170, i8* null, i32 2, %struct.tskTaskControlBlock** null)
  %call4 = call i32 @xTaskCreate(void (i8*)* @_Z8vGPSTaskPv, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.4, i32 0, i32 0), i16 zeroext 256, i8* null, i32 3, %struct.tskTaskControlBlock** null)
  %4 = load volatile i32, i32* inttoptr (i32 -536866812 to i32*), align 4
  store i32 %4, i32* @m_startSched, align 4
  call void @vTaskStartScheduler()
  ret i32 0
}

declare void @_Z9InitBoardv() #1

declare void @_Z15initDebugSerialv() #1

declare void @_Z11initButtonsv() #1

declare i32 @xTaskCreate(void (i8*)*, i8*, i16 zeroext, i8*, i32, %struct.tskTaskControlBlock**) #1

declare void @_Z9vSDThreadPv(i8*) #1

declare void @_Z10vLEDThreadPv(i8*) #1

declare void @_Z12vDisplayTaskPv(i8*) #1

declare void @_Z14vButtonsThreadPv(i8*) #1

declare void @_Z8vGPSTaskPv(i8*) #1

declare void @vTaskStartScheduler() #1

attributes #0 = { noinline norecurse optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"NumRegisterParameters", i32 0}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
!3 = !{i32 195155}
