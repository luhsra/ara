; ModuleID = 'ButtonsThread.cpp'
source_filename = "ButtonsThread.cpp"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.QueueDefinition = type opaque
%struct.ButtonMessage = type { i32, i32 }

$_Z14getButtonStatej = comdat any

@ledStatus = global i32 255, align 4
@LL_GPIO_SPEED_FREQ_LOW = global i32 1, align 4
@LL_GPIO_OUTPUT_PUSHPULL = global i32 1, align 4
@LL_GPIO_MODE_OUTPUT = global i32 1, align 4
@LL_GPIO_PIN_13 = global i32 13, align 4
@LL_GPIO_PIN_12 = global i32 12, align 4
@LL_GPIO_PULL_UP = global i32 13, align 4
@LL_GPIO_MODE_INPUT = global i32 13, align 4
@GPIOC = global i32 0, align 4
@buttonsQueue = global %struct.QueueDefinition* null, align 8
@_ZL14SEL_BUTTON_PIN = internal global i32 0, align 4
@_ZL13OK_BUTTON_PIN = internal global i32 0, align 4
@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* @_GLOBAL__sub_I_ButtonsThread.cpp, i8* null }]

; Function Attrs: noinline optnone uwtable
define void @_Z11initButtonsv() #0 {
  %1 = load i32, i32* @GPIOC, align 4
  %2 = load i32, i32* @_ZL14SEL_BUTTON_PIN, align 4
  %3 = load i32, i32* @LL_GPIO_MODE_INPUT, align 4
  call void @_Z18LL_GPIO_SetPinModejjj(i32 %1, i32 %2, i32 %3)
  %4 = load i32, i32* @GPIOC, align 4
  %5 = load i32, i32* @_ZL14SEL_BUTTON_PIN, align 4
  %6 = load i32, i32* @LL_GPIO_PULL_UP, align 4
  call void @_Z18LL_GPIO_SetPinPulljjj(i32 %4, i32 %5, i32 %6)
  %7 = load i32, i32* @GPIOC, align 4
  %8 = load i32, i32* @_ZL13OK_BUTTON_PIN, align 4
  %9 = load i32, i32* @LL_GPIO_MODE_INPUT, align 4
  call void @_Z18LL_GPIO_SetPinModejjj(i32 %7, i32 %8, i32 %9)
  %10 = load i32, i32* @GPIOC, align 4
  %11 = load i32, i32* @_ZL13OK_BUTTON_PIN, align 4
  %12 = load i32, i32* @LL_GPIO_PULL_UP, align 4
  call void @_Z18LL_GPIO_SetPinPulljjj(i32 %10, i32 %11, i32 %12)
  %13 = call %struct.QueueDefinition* @xQueueGenericCreate(i64 3, i64 8, i8 zeroext 0)
  store %struct.QueueDefinition* %13, %struct.QueueDefinition** @buttonsQueue, align 8
  ret void
}

declare void @_Z18LL_GPIO_SetPinModejjj(i32, i32, i32) #1

declare void @_Z18LL_GPIO_SetPinPulljjj(i32, i32, i32) #1

declare %struct.QueueDefinition* @xQueueGenericCreate(i64, i64, i8 zeroext) #1

; Function Attrs: noinline optnone uwtable
define i32 @_Z18getPressedButtonIDv() #0 {
  %1 = alloca i32, align 4
  %2 = load i32, i32* @_ZL14SEL_BUTTON_PIN, align 4
  %3 = call zeroext i1 @_Z14getButtonStatej(i32 %2)
  br i1 %3, label %4, label %5

; <label>:4:                                      ; preds = %0
  store i32 1, i32* %1, align 4
  br label %10

; <label>:5:                                      ; preds = %0
  %6 = load i32, i32* @_ZL13OK_BUTTON_PIN, align 4
  %7 = call zeroext i1 @_Z14getButtonStatej(i32 %6)
  br i1 %7, label %8, label %9

; <label>:8:                                      ; preds = %5
  store i32 2, i32* %1, align 4
  br label %10

; <label>:9:                                      ; preds = %5
  store i32 0, i32* %1, align 4
  br label %10

; <label>:10:                                     ; preds = %9, %8, %4
  %11 = load i32, i32* %1, align 4
  ret i32 %11
}

; Function Attrs: noinline optnone uwtable
define linkonce_odr zeroext i1 @_Z14getButtonStatej(i32) #0 comdat {
  %2 = alloca i1, align 1
  %3 = alloca i32, align 4
  store i32 %0, i32* %3, align 4
  %4 = load i32, i32* @GPIOC, align 4
  %5 = load i32, i32* %3, align 4
  %6 = call zeroext i1 @_Z21LL_GPIO_IsInputPinSetjj(i32 %4, i32 %5)
  br i1 %6, label %13, label %7

; <label>:7:                                      ; preds = %1
  call void @vTaskDelay(i32 1)
  %8 = load i32, i32* @GPIOC, align 4
  %9 = load i32, i32* %3, align 4
  %10 = call zeroext i1 @_Z21LL_GPIO_IsInputPinSetjj(i32 %8, i32 %9)
  br i1 %10, label %12, label %11

; <label>:11:                                     ; preds = %7
  store i1 true, i1* %2, align 1
  br label %14

; <label>:12:                                     ; preds = %7
  br label %13

; <label>:13:                                     ; preds = %12, %1
  store i1 false, i1* %2, align 1
  br label %14

; <label>:14:                                     ; preds = %13, %11
  %15 = load i1, i1* %2, align 1
  ret i1 %15
}

; Function Attrs: noinline optnone uwtable
define void @_Z14vButtonsThreadPv(i8*) #0 {
  %2 = alloca i8*, align 8
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca %struct.ButtonMessage, align 4
  %6 = alloca i32, align 4
  store i8* %0, i8** %2, align 8
  br label %7

; <label>:7:                                      ; preds = %39, %1
  %8 = call i32 @_Z18getPressedButtonIDv()
  store i32 %8, i32* %3, align 4
  %9 = load i32, i32* %3, align 4
  %10 = icmp ne i32 %9, 0
  br i1 %10, label %11, label %39

; <label>:11:                                     ; preds = %7
  %12 = call i32 @xTaskGetTickCount()
  store i32 %12, i32* %4, align 4
  br label %13

; <label>:13:                                     ; preds = %16, %11
  %14 = call i32 @_Z18getPressedButtonIDv()
  %15 = icmp ne i32 %14, 0
  br i1 %15, label %16, label %17

; <label>:16:                                     ; preds = %13
  call void @vTaskDelay(i32 10)
  br label %13

; <label>:17:                                     ; preds = %13
  %18 = load i32, i32* %3, align 4
  %19 = getelementptr inbounds %struct.ButtonMessage, %struct.ButtonMessage* %5, i32 0, i32 0
  store i32 %18, i32* %19, align 4
  %20 = call i32 @xTaskGetTickCount()
  %21 = load i32, i32* %4, align 4
  %22 = sub i32 %20, %21
  store i32 %22, i32* %6, align 4
  %23 = load i32, i32* %6, align 4
  %24 = icmp ugt i32 %23, 1000
  br i1 %24, label %25, label %27

; <label>:25:                                     ; preds = %17
  %26 = getelementptr inbounds %struct.ButtonMessage, %struct.ButtonMessage* %5, i32 0, i32 1
  store i32 2, i32* %26, align 4
  br label %35

; <label>:27:                                     ; preds = %17
  %28 = load i32, i32* %6, align 4
  %29 = icmp ugt i32 %28, 500
  br i1 %29, label %30, label %32

; <label>:30:                                     ; preds = %27
  %31 = getelementptr inbounds %struct.ButtonMessage, %struct.ButtonMessage* %5, i32 0, i32 1
  store i32 1, i32* %31, align 4
  br label %34

; <label>:32:                                     ; preds = %27
  %33 = getelementptr inbounds %struct.ButtonMessage, %struct.ButtonMessage* %5, i32 0, i32 1
  store i32 0, i32* %33, align 4
  br label %34

; <label>:34:                                     ; preds = %32, %30
  br label %35

; <label>:35:                                     ; preds = %34, %25
  %36 = load %struct.QueueDefinition*, %struct.QueueDefinition** @buttonsQueue, align 8
  %37 = bitcast %struct.ButtonMessage* %5 to i8*
  %38 = call i64 @xQueueGenericSend(%struct.QueueDefinition* %36, i8* %37, i32 0, i64 0)
  br label %39

; <label>:39:                                     ; preds = %35, %7
  call void @vTaskDelay(i32 10)
  br label %7
                                                  ; No predecessors!
  ret void
}

declare i32 @xTaskGetTickCount() #1

declare void @vTaskDelay(i32) #1

declare i64 @xQueueGenericSend(%struct.QueueDefinition*, i8*, i32, i64) #1

; Function Attrs: noinline optnone uwtable
define zeroext i1 @_Z20waitForButtonMessageP13ButtonMessagej(%struct.ButtonMessage*, i32) #0 {
  %3 = alloca %struct.ButtonMessage*, align 8
  %4 = alloca i32, align 4
  store %struct.ButtonMessage* %0, %struct.ButtonMessage** %3, align 8
  store i32 %1, i32* %4, align 4
  %5 = load %struct.QueueDefinition*, %struct.QueueDefinition** @buttonsQueue, align 8
  %6 = load %struct.ButtonMessage*, %struct.ButtonMessage** %3, align 8
  %7 = bitcast %struct.ButtonMessage* %6 to i8*
  %8 = load i32, i32* %4, align 4
  %9 = call i64 @xQueueReceive(%struct.QueueDefinition* %5, i8* %7, i32 %8)
  %10 = icmp ne i64 %9, 0
  ret i1 %10
}

declare i64 @xQueueReceive(%struct.QueueDefinition*, i8*, i32) #1

; Function Attrs: noinline uwtable
define internal void @__cxx_global_var_init() #2 section ".text.startup" {
  %1 = load i32, i32* @LL_GPIO_PIN_13, align 4
  store i32 %1, i32* @_ZL14SEL_BUTTON_PIN, align 4
  ret void
}

; Function Attrs: noinline uwtable
define internal void @__cxx_global_var_init.1() #2 section ".text.startup" {
  %1 = load i32, i32* @LL_GPIO_PIN_12, align 4
  store i32 %1, i32* @_ZL13OK_BUTTON_PIN, align 4
  ret void
}

declare zeroext i1 @_Z21LL_GPIO_IsInputPinSetjj(i32, i32) #1

; Function Attrs: noinline uwtable
define internal void @_GLOBAL__sub_I_ButtonsThread.cpp() #2 section ".text.startup" {
  call void @__cxx_global_var_init()
  call void @__cxx_global_var_init.1()
  ret void
}

attributes #0 = { noinline optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noinline uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
