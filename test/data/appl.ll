; ModuleID = '../appl/FreeRTOS/l.cc'
source_filename = "../appl/FreeRTOS/l.cc"
target datalayout = "e-m:e-p:32:32-f64:32:64-f80:32-n8:16:32-S128"
target triple = "i386-pc-linux-gnu"

%struct.EventGroupDef_t = type opaque
%struct.StreamBufferDef_t = type opaque
%struct.tskTaskControlBlock = type opaque

@xEventGroup = global %struct.EventGroupDef_t* null, align 4
@.str = private unnamed_addr constant [11 x i8] c"Bit Setter\00", align 1
@.str.1 = private unnamed_addr constant [11 x i8] c"Bit Reader\00", align 1
@llvm.used = appending global [1 x i8*] [i8* bitcast (void (i8*)* @_Z3tmpPv to i8*)], section "llvm.metadata"

; Function Attrs: noinline nounwind optnone
define x86_intrcc void @_Z3tmpPv(i8*) #0 {
  %2 = alloca i8*, align 4
  %3 = alloca i32, align 4
  store i8* %0, i8** %2, align 4
  store i32 0, i32* %3, align 4
  ret void
}

; Function Attrs: noinline optnone
define void @_Z29vASwitchCompatibleISR_Handlerv() #1 {
  %1 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %2 = load i32, i32* %1, align 4
  %3 = icmp ne i32 %2, 0
  br i1 %3, label %4, label %5

; <label>:4:                                      ; preds = %0
  call void @_Z18portYIELD_FROM_ISRv()
  br label %5

; <label>:5:                                      ; preds = %4, %0
  ret void
}

declare void @_Z18portYIELD_FROM_ISRv() #2

; Function Attrs: naked noinline nounwind optnone
define void @_Z29vASwitchCompatibleISR_Wrapperv() #3 {
  unreachable
}

; Function Attrs: noinline optnone
define void @_Z20vEventBitReadingTaskPv(i8*) #1 {
  %2 = alloca i8*, align 4
  %3 = alloca i16, align 2
  %4 = alloca i16, align 2
  store i8* %0, i8** %2, align 4
  store i16 7, i16* %4, align 2
  br label %5

; <label>:5:                                      ; preds = %25, %1
  %6 = load %struct.EventGroupDef_t*, %struct.EventGroupDef_t** @xEventGroup, align 4
  %7 = call zeroext i16 @xEventGroupWaitBits(%struct.EventGroupDef_t* %6, i16 zeroext 7, i32 1, i32 0, i16 zeroext -1)
  store i16 %7, i16* %3, align 2
  %8 = load i16, i16* %3, align 2
  %9 = zext i16 %8 to i32
  %10 = and i32 %9, 2
  %11 = icmp ne i32 %10, 0
  br i1 %11, label %12, label %13

; <label>:12:                                     ; preds = %5
  br label %13

; <label>:13:                                     ; preds = %12, %5
  %14 = load i16, i16* %3, align 2
  %15 = zext i16 %14 to i32
  %16 = and i32 %15, 4
  %17 = icmp ne i32 %16, 0
  br i1 %17, label %18, label %19

; <label>:18:                                     ; preds = %13
  br label %19

; <label>:19:                                     ; preds = %18, %13
  %20 = load i16, i16* %3, align 2
  %21 = zext i16 %20 to i32
  %22 = and i32 %21, 5
  %23 = icmp ne i32 %22, 0
  br i1 %23, label %24, label %25

; <label>:24:                                     ; preds = %19
  br label %25

; <label>:25:                                     ; preds = %24, %19
  br label %5
                                                  ; No predecessors!
  ret void
}

declare zeroext i16 @xEventGroupWaitBits(%struct.EventGroupDef_t*, i16 zeroext, i32, i32, i16 zeroext) #2

; Function Attrs: noinline optnone
define void @_Z10vAFunctionv() #1 {
  %1 = alloca %struct.StreamBufferDef_t*, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  store i32 100, i32* %2, align 4
  store i32 10, i32* %3, align 4
  %4 = call %struct.StreamBufferDef_t* @xStreamBufferGenericCreate(i32 100, i32 10, i32 0)
  store %struct.StreamBufferDef_t* %4, %struct.StreamBufferDef_t** %1, align 4
  %5 = load %struct.StreamBufferDef_t*, %struct.StreamBufferDef_t** %1, align 4
  %6 = icmp eq %struct.StreamBufferDef_t* %5, null
  br i1 %6, label %7, label %8

; <label>:7:                                      ; preds = %0
  br label %9

; <label>:8:                                      ; preds = %0
  br label %9

; <label>:9:                                      ; preds = %8, %7
  ret void
}

declare %struct.StreamBufferDef_t* @xStreamBufferGenericCreate(i32, i32, i32) #2

; Function Attrs: noinline optnone
define void @_Z10vBFunctionv() #1 {
  %1 = alloca i8*, align 4
  %2 = alloca i32, align 4
  store i32 100, i32* %2, align 4
  %3 = call %struct.StreamBufferDef_t* @xStreamBufferGenericCreate(i32 100, i32 0, i32 1)
  %4 = bitcast %struct.StreamBufferDef_t* %3 to i8*
  store i8* %4, i8** %1, align 4
  %5 = load i8*, i8** %1, align 4
  %6 = icmp eq i8* %5, null
  br i1 %6, label %7, label %8

; <label>:7:                                      ; preds = %0
  br label %9

; <label>:8:                                      ; preds = %0
  br label %9

; <label>:9:                                      ; preds = %8, %7
  ret void
}

; Function Attrs: noinline optnone
define i32 @_Z11fake_createv() #1 {
  %1 = alloca i32, align 4
  %2 = call i32 @xTaskCreate(void (i8*)* @_ZL20vEventBitSettingTaskPv, i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 1, %struct.tskTaskControlBlock** null)
  call void @llvm.trap()
  unreachable
                                                  ; No predecessors!
  %4 = load i32, i32* %1, align 4
  ret i32 %4
}

declare i32 @xTaskCreate(void (i8*)*, i8*, i16 zeroext, i8*, i32, %struct.tskTaskControlBlock**) #2

; Function Attrs: noinline optnone
define internal void @_ZL20vEventBitSettingTaskPv(i8*) #1 {
  %2 = alloca i8*, align 4
  %3 = alloca i16, align 2
  %4 = alloca i16, align 2
  store i8* %0, i8** %2, align 4
  store i16 200, i16* %3, align 2
  store i16 0, i16* %4, align 2
  br label %5

; <label>:5:                                      ; preds = %5, %1
  call void @vTaskDelay(i16 zeroext 200)
  %6 = load %struct.EventGroupDef_t*, %struct.EventGroupDef_t** @xEventGroup, align 4
  %7 = call zeroext i16 @xEventGroupSetBits(%struct.EventGroupDef_t* %6, i16 zeroext 2)
  call void @vTaskDelay(i16 zeroext 200)
  %8 = load %struct.EventGroupDef_t*, %struct.EventGroupDef_t** @xEventGroup, align 4
  %9 = call zeroext i16 @xEventGroupSetBits(%struct.EventGroupDef_t* %8, i16 zeroext 4)
  br label %5
                                                  ; No predecessors!
  ret void
}

; Function Attrs: noreturn nounwind
declare void @llvm.trap() #4

; Function Attrs: noinline norecurse optnone
define i32 @main() #5 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %5 = call %struct.EventGroupDef_t* @xEventGroupCreate()
  store %struct.EventGroupDef_t* %5, %struct.EventGroupDef_t** @xEventGroup, align 4
  store i32 0, i32* %2, align 4
  br label %6

; <label>:6:                                      ; preds = %19, %0
  %7 = load i32, i32* %2, align 4
  %8 = icmp slt i32 %7, 10
  br i1 %8, label %9, label %22

; <label>:9:                                      ; preds = %6
  store i32 0, i32* %3, align 4
  br label %10

; <label>:10:                                     ; preds = %15, %9
  %11 = load i32, i32* %3, align 4
  %12 = icmp slt i32 %11, 10
  br i1 %12, label %13, label %18

; <label>:13:                                     ; preds = %10
  %14 = call i32 @xTaskCreate(void (i8*)* @_ZL20vEventBitSettingTaskPv, i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 1, %struct.tskTaskControlBlock** null)
  br label %15

; <label>:15:                                     ; preds = %13
  %16 = load i32, i32* %3, align 4
  %17 = add nsw i32 %16, 1
  store i32 %17, i32* %3, align 4
  br label %10

; <label>:18:                                     ; preds = %10
  br label %19

; <label>:19:                                     ; preds = %18
  %20 = load i32, i32* %2, align 4
  %21 = add nsw i32 %20, 1
  store i32 %21, i32* %2, align 4
  br label %6

; <label>:22:                                     ; preds = %6
  store i32 0, i32* %4, align 4
  br label %23

; <label>:23:                                     ; preds = %28, %22
  %24 = load i32, i32* %4, align 4
  %25 = icmp slt i32 %24, 10
  br i1 %25, label %26, label %31

; <label>:26:                                     ; preds = %23
  %27 = call i32 @_Z11fake_createv()
  br label %28

; <label>:28:                                     ; preds = %26
  %29 = load i32, i32* %4, align 4
  %30 = add nsw i32 %29, 1
  store i32 %30, i32* %4, align 4
  br label %23

; <label>:31:                                     ; preds = %23
  %32 = call i32 @xTaskCreate(void (i8*)* @_Z20vEventBitReadingTaskPv, i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.1, i32 0, i32 0), i16 zeroext 1000, i8* null, i32 2, %struct.tskTaskControlBlock** null)
  call void @vTaskStartScheduler()
  br label %33

; <label>:33:                                     ; preds = %33, %31
  br label %33
                                                  ; No predecessors!
  %35 = load i32, i32* %1, align 4
  ret i32 %35
}

declare %struct.EventGroupDef_t* @xEventGroupCreate() #2

declare void @vTaskStartScheduler() #2

declare void @vTaskDelay(i16 zeroext) #2

declare zeroext i16 @xEventGroupSetBits(%struct.EventGroupDef_t*, i16 zeroext) #2

attributes #0 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="true" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { noinline optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { naked noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { noreturn nounwind }
attributes #5 = { noinline norecurse optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"NumRegisterParameters", i32 0}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
