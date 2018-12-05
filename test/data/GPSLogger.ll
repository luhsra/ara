; ModuleID = 'GPSLogger.cpp'
source_filename = "GPSLogger.cpp"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.tskTaskControlBlock = type opaque

@m_start = global i32 0, align 4
@m_startInits = global i32 0, align 4
@m_startSched = global i32 0, align 4
@.str = private unnamed_addr constant [10 x i8] c"SD Thread\00", align 1
@.str.1 = private unnamed_addr constant [11 x i8] c"LED Thread\00", align 1
@.str.2 = private unnamed_addr constant [13 x i8] c"Display Task\00", align 1
@.str.3 = private unnamed_addr constant [15 x i8] c"Buttons Thread\00", align 1
@.str.4 = private unnamed_addr constant [9 x i8] c"GPS Task\00", align 1

; Function Attrs: noinline norecurse optnone uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  store i32 0, i32* %2, align 4
  %3 = load volatile i32, i32* inttoptr (i64 3758100484 to i32*), align 4
  store i32 %3, i32* @m_start, align 4
  call void @_Z9InitBoardv()
  call void @_Z15initDebugSerialv()
  store i32 0, i32* %1, align 4
  %4 = load i32, i32* %1, align 4
  call void asm sideeffect "\09msr basepri, $0\09", "r,~{dirflag},~{fpsr},~{flags}"(i32 %4) #2, !srcloc !2
  call void @_Z11initButtonsv()
  %5 = load volatile i32, i32* inttoptr (i64 3758100484 to i32*), align 4
  store i32 %5, i32* @m_startInits, align 4
  %6 = call i64 @xTaskCreate(void (i8*)* @_Z9vSDThreadPv, i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str, i32 0, i32 0), i16 zeroext 512, i8* null, i64 4, %struct.tskTaskControlBlock** null)
  %7 = call i64 @xTaskCreate(void (i8*)* @_Z10vLEDThreadPv, i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.1, i32 0, i32 0), i16 zeroext 170, i8* null, i64 2, %struct.tskTaskControlBlock** null)
  %8 = call i64 @xTaskCreate(void (i8*)* @_Z12vDisplayTaskPv, i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.2, i32 0, i32 0), i16 zeroext 768, i8* null, i64 2, %struct.tskTaskControlBlock** null)
  %9 = call i64 @xTaskCreate(void (i8*)* @_Z14vButtonsThreadPv, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.3, i32 0, i32 0), i16 zeroext 170, i8* null, i64 2, %struct.tskTaskControlBlock** null)
  %10 = call i64 @xTaskCreate(void (i8*)* @_Z8vGPSTaskPv, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.4, i32 0, i32 0), i16 zeroext 256, i8* null, i64 3, %struct.tskTaskControlBlock** null)
  %11 = load volatile i32, i32* inttoptr (i64 3758100484 to i32*), align 4
  store i32 %11, i32* @m_startSched, align 4
  call void @vTaskStartScheduler()
  ret i32 0
}

declare void @_Z9InitBoardv() #1

declare void @_Z15initDebugSerialv() #1

declare void @_Z11initButtonsv() #1

declare i64 @xTaskCreate(void (i8*)*, i8*, i16 zeroext, i8*, i64, %struct.tskTaskControlBlock**) #1

declare void @_Z9vSDThreadPv(i8*) #1

declare void @_Z10vLEDThreadPv(i8*) #1

declare void @_Z12vDisplayTaskPv(i8*) #1

declare void @_Z14vButtonsThreadPv(i8*) #1

declare void @_Z8vGPSTaskPv(i8*) #1

declare void @vTaskStartScheduler() #1

attributes #0 = { noinline norecurse optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
!2 = !{i32 194915}
