; ModuleID = '../../../GPSLogger/Src/LEDThread.cpp'
source_filename = "../../../GPSLogger/Src/LEDThread.cpp"
target datalayout = "e-m:e-p:32:32-f64:32:64-f80:32-n8:16:32-S128"
target triple = "i386-pc-linux-gnu"

%class.LEDDriver = type <{ i32, i8, [3 x i8] }>

$_ZN9LEDDriverC2Ev = comdat any

$_ZN9LEDDriver4initEv = comdat any

$_ZN9LEDDriver6turnOnEv = comdat any

$_ZN9LEDDriver7turnOffEv = comdat any

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
@GPIOA = global i32 1, align 4
@ledStatus = global i32 255, align 4
@led = global %class.LEDDriver zeroinitializer, align 4
@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* @_GLOBAL__sub_I_LEDThread.cpp, i8* null }]

; Function Attrs: noinline
define internal void @__cxx_global_var_init() #0 section ".text.startup" {
  call void @_ZN9LEDDriverC2Ev(%class.LEDDriver* @led)
  ret void
}

; Function Attrs: noinline nounwind optnone
define linkonce_odr void @_ZN9LEDDriverC2Ev(%class.LEDDriver* %this) unnamed_addr #1 comdat align 2 {
  %this.addr = alloca %class.LEDDriver*, align 4
  store %class.LEDDriver* %this, %class.LEDDriver** %this.addr, align 4
  %this1 = load %class.LEDDriver*, %class.LEDDriver** %this.addr, align 4
  %pin = getelementptr inbounds %class.LEDDriver, %class.LEDDriver* %this1, i32 0, i32 0
  store i32 32, i32* %pin, align 4
  %inited = getelementptr inbounds %class.LEDDriver, %class.LEDDriver* %this1, i32 0, i32 1
  store i8 0, i8* %inited, align 4
  ret void
}

; Function Attrs: noinline optnone
define void @_Z5blinkh(i8 zeroext %status) #2 {
  %status.addr = alloca i8, align 1
  %i = alloca i32, align 4
  store i8 %status, i8* %status.addr, align 1
  call void @_ZN9LEDDriver4initEv(%class.LEDDriver* @led)
  store i32 0, i32* %i, align 4
  br label %1

; <label>:1:                                      ; preds = %9, %0
  %2 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %2, 3
  br i1 %cmp, label %3, label %11

; <label>:3:                                      ; preds = %1
  call void @_ZN9LEDDriver6turnOnEv(%class.LEDDriver* @led)
  %4 = load i8, i8* %status.addr, align 1
  %conv = zext i8 %4 to i32
  %and = and i32 %conv, 4
  %tobool = icmp ne i32 %and, 0
  br i1 %tobool, label %5, label %6

; <label>:5:                                      ; preds = %3
  call void @_Z9HAL_Delayj(i32 300)
  br label %7

; <label>:6:                                      ; preds = %3
  call void @_Z9HAL_Delayj(i32 100)
  br label %7

; <label>:7:                                      ; preds = %6, %5
  call void @_ZN9LEDDriver7turnOffEv(%class.LEDDriver* @led)
  %8 = load i8, i8* %status.addr, align 1
  %conv1 = zext i8 %8 to i32
  %shl = shl i32 %conv1, 1
  %conv2 = trunc i32 %shl to i8
  store i8 %conv2, i8* %status.addr, align 1
  call void @_Z9HAL_Delayj(i32 200)
  br label %9

; <label>:9:                                      ; preds = %7
  %10 = load i32, i32* %i, align 4
  %inc = add nsw i32 %10, 1
  store i32 %inc, i32* %i, align 4
  br label %1

; <label>:11:                                     ; preds = %1
  ret void
}

; Function Attrs: noinline optnone
define linkonce_odr void @_ZN9LEDDriver4initEv(%class.LEDDriver* %this) #2 comdat align 2 {
  %this.addr = alloca %class.LEDDriver*, align 4
  store %class.LEDDriver* %this, %class.LEDDriver** %this.addr, align 4
  %this1 = load %class.LEDDriver*, %class.LEDDriver** %this.addr, align 4
  %inited = getelementptr inbounds %class.LEDDriver, %class.LEDDriver* %this1, i32 0, i32 1
  %1 = load i8, i8* %inited, align 4
  %tobool = trunc i8 %1 to i1
  br i1 %tobool, label %2, label %3

; <label>:2:                                      ; preds = %0
  br label %13

; <label>:3:                                      ; preds = %0
  %4 = load i32, i32* @GPIOA, align 4
  %pin = getelementptr inbounds %class.LEDDriver, %class.LEDDriver* %this1, i32 0, i32 0
  %5 = load i32, i32* %pin, align 4
  %6 = load i32, i32* @LL_GPIO_MODE_OUTPUT, align 4
  call void @_Z18LL_GPIO_SetPinModejjj(i32 %4, i32 %5, i32 %6)
  %7 = load i32, i32* @GPIOA, align 4
  %pin2 = getelementptr inbounds %class.LEDDriver, %class.LEDDriver* %this1, i32 0, i32 0
  %8 = load i32, i32* %pin2, align 4
  %9 = load i32, i32* @LL_GPIO_OUTPUT_PUSHPULL, align 4
  call void @_Z24LL_GPIO_SetPinOutputTypejjj(i32 %7, i32 %8, i32 %9)
  %10 = load i32, i32* @GPIOA, align 4
  %pin3 = getelementptr inbounds %class.LEDDriver, %class.LEDDriver* %this1, i32 0, i32 0
  %11 = load i32, i32* %pin3, align 4
  %12 = load i32, i32* @LL_GPIO_SPEED_FREQ_LOW, align 4
  call void @_Z19LL_GPIO_SetPinSpeedjjj(i32 %10, i32 %11, i32 %12)
  %inited4 = getelementptr inbounds %class.LEDDriver, %class.LEDDriver* %this1, i32 0, i32 1
  store i8 1, i8* %inited4, align 4
  br label %13

; <label>:13:                                     ; preds = %3, %2
  ret void
}

; Function Attrs: noinline optnone
define linkonce_odr void @_ZN9LEDDriver6turnOnEv(%class.LEDDriver* %this) #2 comdat align 2 {
  %this.addr = alloca %class.LEDDriver*, align 4
  store %class.LEDDriver* %this, %class.LEDDriver** %this.addr, align 4
  %this1 = load %class.LEDDriver*, %class.LEDDriver** %this.addr, align 4
  %1 = load i32, i32* @GPIOA, align 4
  %pin = getelementptr inbounds %class.LEDDriver, %class.LEDDriver* %this1, i32 0, i32 0
  %2 = load i32, i32* %pin, align 4
  call void @_Z22LL_GPIO_ResetOutputPinjj(i32 %1, i32 %2)
  ret void
}

declare void @_Z9HAL_Delayj(i32) #3

; Function Attrs: noinline optnone
define linkonce_odr void @_ZN9LEDDriver7turnOffEv(%class.LEDDriver* %this) #2 comdat align 2 {
  %this.addr = alloca %class.LEDDriver*, align 4
  store %class.LEDDriver* %this, %class.LEDDriver** %this.addr, align 4
  %this1 = load %class.LEDDriver*, %class.LEDDriver** %this.addr, align 4
  %1 = load i32, i32* @GPIOA, align 4
  %pin = getelementptr inbounds %class.LEDDriver, %class.LEDDriver* %this1, i32 0, i32 0
  %2 = load i32, i32* %pin, align 4
  call void @_Z20LL_GPIO_SetOutputPinjj(i32 %1, i32 %2)
  ret void
}

; Function Attrs: noinline nounwind optnone
define void @_Z12setLedStatush(i8 zeroext %status) #1 {
  %status.addr = alloca i8, align 1
  store i8 %status, i8* %status.addr, align 1
  %1 = load i8, i8* %status.addr, align 1
  %conv = zext i8 %1 to i32
  store volatile i32 %conv, i32* @ledStatus, align 4
  ret void
}

; Function Attrs: noinline optnone
define void @_Z4halth(i8 zeroext %status) #2 {
  %status.addr = alloca i8, align 1
  store i8 %status, i8* %status.addr, align 1
  call void @_ZN9LEDDriver4initEv(%class.LEDDriver* @led)
  br label %1

; <label>:1:                                      ; preds = %0, %1
  %2 = load i8, i8* %status.addr, align 1
  call void @_Z5blinkh(i8 zeroext %2)
  call void @_Z9HAL_Delayj(i32 700)
  br label %1
                                                  ; No predecessors!
  ret void
}

; Function Attrs: noinline optnone
define void @_Z10vLEDThreadPv(i8* %pvParameters) #2 {
  %pvParameters.addr = alloca i8*, align 4
  store i8* %pvParameters, i8** %pvParameters.addr, align 4
  call void @_ZN9LEDDriver4initEv(%class.LEDDriver* @led)
  br label %1

; <label>:1:                                      ; preds = %6, %0
  call void @vTaskDelay(i32 2000)
  %2 = load volatile i32, i32* @ledStatus, align 4
  %cmp = icmp eq i32 %2, 255
  br i1 %cmp, label %3, label %4

; <label>:3:                                      ; preds = %1
  call void @_ZN9LEDDriver6turnOnEv(%class.LEDDriver* @led)
  call void @vTaskDelay(i32 100)
  call void @_ZN9LEDDriver7turnOffEv(%class.LEDDriver* @led)
  br label %6

; <label>:4:                                      ; preds = %1
  %5 = load volatile i32, i32* @ledStatus, align 4
  %conv = trunc i32 %5 to i8
  call void @_Z5blinkh(i8 zeroext %conv)
  br label %6

; <label>:6:                                      ; preds = %4, %3
  br label %1
                                                  ; No predecessors!
  ret void
}

declare void @vTaskDelay(i32) #3

declare void @_Z18LL_GPIO_SetPinModejjj(i32, i32, i32) #3

declare void @_Z24LL_GPIO_SetPinOutputTypejjj(i32, i32, i32) #3

declare void @_Z19LL_GPIO_SetPinSpeedjjj(i32, i32, i32) #3

declare void @_Z22LL_GPIO_ResetOutputPinjj(i32, i32) #3

declare void @_Z20LL_GPIO_SetOutputPinjj(i32, i32) #3

; Function Attrs: noinline
define internal void @_GLOBAL__sub_I_LEDThread.cpp() #0 section ".text.startup" {
  call void @__cxx_global_var_init()
  ret void
}

attributes #0 = { noinline "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noinline optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"NumRegisterParameters", i32 0}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
