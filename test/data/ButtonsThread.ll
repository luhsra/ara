; ModuleID = '../../../GPSLogger/Src/ButtonsThread.cpp'
source_filename = "../../../GPSLogger/Src/ButtonsThread.cpp"
target datalayout = "e-m:e-p:32:32-f64:32:64-f80:32-n8:16:32-S128"
target triple = "i386-pc-linux-gnu"

%struct.QueueDefinition = type opaque
%struct.ButtonMessage = type { i32, i32 }

$_Z14getButtonStatej = comdat any

@LL_GPIO_SPEED_FREQ_HIGH = global i32 1, align 4
@LL_GPIO_SPEED_FREQ_MEDIUM = global i32 1, align 4
@LL_GPIO_SPEED_FREQ_LOW = global i32 1, align 4
@LL_GPIO_OUTPUT_PUSHPULL = global i32 1, align 4
@LL_GPIO_MODE_OUTPUT = global i32 1, align 4
@LL_GPIO_MODE_ALTERNATE = global i32 1, align 4
@LL_GPIO_PIN_0 = global i32 13, align 4
@LL_GPIO_PIN_1 = global i32 13, align 4
@LL_GPIO_PIN_2 = global i32 12, align 4
@LL_GPIO_PIN_3 = global i32 13, align 4
@LL_GPIO_PIN_4 = global i32 12, align 4
@LL_GPIO_PIN_5 = global i32 13, align 4
@LL_GPIO_PIN_6 = global i32 12, align 4
@LL_GPIO_PIN_7 = global i32 13, align 4
@LL_GPIO_PIN_8 = global i32 12, align 4
@LL_GPIO_PIN_9 = global i32 13, align 4
@LL_GPIO_PIN_10 = global i32 12, align 4
@LL_GPIO_PIN_11 = global i32 12, align 4
@LL_GPIO_PIN_12 = global i32 13, align 4
@LL_GPIO_PIN_13 = global i32 12, align 4
@LL_GPIO_PIN_14 = global i32 12, align 4
@LL_GPIO_PIN_15 = global i32 13, align 4
@LL_GPIO_PIN_16 = global i32 12, align 4
@LL_GPIO_PULL_UP = global i32 13, align 4
@LL_GPIO_MODE_INPUT = global i32 13, align 4
@GPIOC = global i32 0, align 4
@GPIOB = global i32 0, align 4
@SPI2 = global i8* null, align 4
@buttonsQueue = global %struct.QueueDefinition* null, align 4
@_ZL14SEL_BUTTON_PIN = internal global i32 0, align 4
@_ZL13OK_BUTTON_PIN = internal global i32 0, align 4
@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* @_GLOBAL__sub_I_ButtonsThread.cpp, i8* null }]

; Function Attrs: noinline optnone
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
  %call = call %struct.QueueDefinition* @xQueueGenericCreate(i32 3, i32 8, i8 zeroext 0)
  store %struct.QueueDefinition* %call, %struct.QueueDefinition** @buttonsQueue, align 4
  ret void
}

declare void @_Z18LL_GPIO_SetPinModejjj(i32, i32, i32) #1

declare void @_Z18LL_GPIO_SetPinPulljjj(i32, i32, i32) #1

declare %struct.QueueDefinition* @xQueueGenericCreate(i32, i32, i8 zeroext) #1

; Function Attrs: noinline optnone
define i32 @_Z18getPressedButtonIDv() #0 {
  %retval = alloca i32, align 4
  %1 = load i32, i32* @_ZL14SEL_BUTTON_PIN, align 4
  %call = call zeroext i1 @_Z14getButtonStatej(i32 %1)
  br i1 %call, label %2, label %3

; <label>:2:                                      ; preds = %0
  store i32 1, i32* %retval, align 4
  br label %7

; <label>:3:                                      ; preds = %0
  %4 = load i32, i32* @_ZL13OK_BUTTON_PIN, align 4
  %call1 = call zeroext i1 @_Z14getButtonStatej(i32 %4)
  br i1 %call1, label %5, label %6

; <label>:5:                                      ; preds = %3
  store i32 2, i32* %retval, align 4
  br label %7

; <label>:6:                                      ; preds = %3
  store i32 0, i32* %retval, align 4
  br label %7

; <label>:7:                                      ; preds = %6, %5, %2
  %8 = load i32, i32* %retval, align 4
  ret i32 %8
}

; Function Attrs: noinline optnone
define linkonce_odr zeroext i1 @_Z14getButtonStatej(i32 %pin) #0 comdat {
  %retval = alloca i1, align 1
  %pin.addr = alloca i32, align 4
  store i32 %pin, i32* %pin.addr, align 4
  %1 = load i32, i32* @GPIOC, align 4
  %2 = load i32, i32* %pin.addr, align 4
  %call = call zeroext i1 @_Z21LL_GPIO_IsInputPinSetjj(i32 %1, i32 %2)
  br i1 %call, label %8, label %3

; <label>:3:                                      ; preds = %0
  call void @vTaskDelay(i32 1)
  %4 = load i32, i32* @GPIOC, align 4
  %5 = load i32, i32* %pin.addr, align 4
  %call1 = call zeroext i1 @_Z21LL_GPIO_IsInputPinSetjj(i32 %4, i32 %5)
  br i1 %call1, label %7, label %6

; <label>:6:                                      ; preds = %3
  store i1 true, i1* %retval, align 1
  br label %9

; <label>:7:                                      ; preds = %3
  br label %8

; <label>:8:                                      ; preds = %7, %0
  store i1 false, i1* %retval, align 1
  br label %9

; <label>:9:                                      ; preds = %8, %6
  %10 = load i1, i1* %retval, align 1
  ret i1 %10
}

; Function Attrs: noinline optnone
define void @_Z14vButtonsThreadPv(i8* %pvParameters) #0 {
  %pvParameters.addr = alloca i8*, align 4
  %btn = alloca i32, align 4
  %startTime = alloca i32, align 4
  %msg = alloca %struct.ButtonMessage, align 4
  %duration = alloca i32, align 4
  store i8* %pvParameters, i8** %pvParameters.addr, align 4
  br label %1

; <label>:1:                                      ; preds = %19, %0
  %call = call i32 @_Z18getPressedButtonIDv()
  store i32 %call, i32* %btn, align 4
  %2 = load i32, i32* %btn, align 4
  %cmp = icmp ne i32 %2, 0
  br i1 %cmp, label %3, label %19

; <label>:3:                                      ; preds = %1
  %call1 = call i32 @xTaskGetTickCount()
  store i32 %call1, i32* %startTime, align 4
  br label %4

; <label>:4:                                      ; preds = %5, %3
  %call2 = call i32 @_Z18getPressedButtonIDv()
  %cmp3 = icmp ne i32 %call2, 0
  br i1 %cmp3, label %5, label %6

; <label>:5:                                      ; preds = %4
  call void @vTaskDelay(i32 10)
  br label %4

; <label>:6:                                      ; preds = %4
  %7 = load i32, i32* %btn, align 4
  %button = getelementptr inbounds %struct.ButtonMessage, %struct.ButtonMessage* %msg, i32 0, i32 0
  store i32 %7, i32* %button, align 4
  %call4 = call i32 @xTaskGetTickCount()
  %8 = load i32, i32* %startTime, align 4
  %sub = sub i32 %call4, %8
  store i32 %sub, i32* %duration, align 4
  %9 = load i32, i32* %duration, align 4
  %cmp5 = icmp ugt i32 %9, 1000
  br i1 %cmp5, label %10, label %11

; <label>:10:                                     ; preds = %6
  %event = getelementptr inbounds %struct.ButtonMessage, %struct.ButtonMessage* %msg, i32 0, i32 1
  store i32 2, i32* %event, align 4
  br label %16

; <label>:11:                                     ; preds = %6
  %12 = load i32, i32* %duration, align 4
  %cmp6 = icmp ugt i32 %12, 500
  br i1 %cmp6, label %13, label %14

; <label>:13:                                     ; preds = %11
  %event7 = getelementptr inbounds %struct.ButtonMessage, %struct.ButtonMessage* %msg, i32 0, i32 1
  store i32 1, i32* %event7, align 4
  br label %15

; <label>:14:                                     ; preds = %11
  %event8 = getelementptr inbounds %struct.ButtonMessage, %struct.ButtonMessage* %msg, i32 0, i32 1
  store i32 0, i32* %event8, align 4
  br label %15

; <label>:15:                                     ; preds = %14, %13
  br label %16

; <label>:16:                                     ; preds = %15, %10
  %17 = load %struct.QueueDefinition*, %struct.QueueDefinition** @buttonsQueue, align 4
  %18 = bitcast %struct.ButtonMessage* %msg to i8*
  %call9 = call i32 @xQueueGenericSend(%struct.QueueDefinition* %17, i8* %18, i32 0, i32 0)
  br label %19

; <label>:19:                                     ; preds = %16, %1
  call void @vTaskDelay(i32 10)
  br label %1
                                                  ; No predecessors!
  ret void
}

declare i32 @xTaskGetTickCount() #1

declare void @vTaskDelay(i32) #1

declare i32 @xQueueGenericSend(%struct.QueueDefinition*, i8*, i32, i32) #1

; Function Attrs: noinline optnone
define zeroext i1 @_Z20waitForButtonMessageP13ButtonMessagej(%struct.ButtonMessage* %msg, i32 %xTicksToWait) #0 {
  %msg.addr = alloca %struct.ButtonMessage*, align 4
  %xTicksToWait.addr = alloca i32, align 4
  store %struct.ButtonMessage* %msg, %struct.ButtonMessage** %msg.addr, align 4
  store i32 %xTicksToWait, i32* %xTicksToWait.addr, align 4
  %1 = load %struct.QueueDefinition*, %struct.QueueDefinition** @buttonsQueue, align 4
  %2 = load %struct.ButtonMessage*, %struct.ButtonMessage** %msg.addr, align 4
  %3 = bitcast %struct.ButtonMessage* %2 to i8*
  %4 = load i32, i32* %xTicksToWait.addr, align 4
  %call = call i32 @xQueueReceive(%struct.QueueDefinition* %1, i8* %3, i32 %4)
  %tobool = icmp ne i32 %call, 0
  ret i1 %tobool
}

declare i32 @xQueueReceive(%struct.QueueDefinition*, i8*, i32) #1

; Function Attrs: noinline
define internal void @__cxx_global_var_init() #2 section ".text.startup" {
  %1 = load i32, i32* @LL_GPIO_PIN_13, align 4
  store i32 %1, i32* @_ZL14SEL_BUTTON_PIN, align 4
  ret void
}

; Function Attrs: noinline
define internal void @__cxx_global_var_init.1() #2 section ".text.startup" {
  %1 = load i32, i32* @LL_GPIO_PIN_12, align 4
  store i32 %1, i32* @_ZL13OK_BUTTON_PIN, align 4
  ret void
}

declare zeroext i1 @_Z21LL_GPIO_IsInputPinSetjj(i32, i32) #1

; Function Attrs: noinline
define internal void @_GLOBAL__sub_I_ButtonsThread.cpp() #2 section ".text.startup" {
  call void @__cxx_global_var_init()
  call void @__cxx_global_var_init.1()
  ret void
}

attributes #0 = { noinline optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noinline "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"NumRegisterParameters", i32 0}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
