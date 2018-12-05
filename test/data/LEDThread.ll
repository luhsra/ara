; ModuleID = 'LEDThread.cpp'
source_filename = "LEDThread.cpp"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%class.LEDDriver = type <{ i32, i8, [3 x i8] }>

$_ZN9LEDDriverC2Ev = comdat any

$_ZN9LEDDriver4initEv = comdat any

$_ZN9LEDDriver6turnOnEv = comdat any

$_ZN9LEDDriver7turnOffEv = comdat any

@LL_GPIO_SPEED_FREQ_LOW = global i32 1, align 4
@LL_GPIO_OUTPUT_PUSHPULL = global i32 1, align 4
@LL_GPIO_MODE_OUTPUT = global i32 1, align 4
@LL_GPIO_PIN_13 = global i32 13, align 4
@LL_GPIO_PIN_12 = global i32 12, align 4
@LL_GPIO_PULL_UP = global i32 13, align 4
@LL_GPIO_MODE_INPUT = global i32 13, align 4
@GPIOC = global i32 0, align 4
@GPIOA = global i32 1, align 4
@ledStatus = global i32 255, align 4
@led = global %class.LEDDriver zeroinitializer, align 4
@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* @_GLOBAL__sub_I_LEDThread.cpp, i8* null }]

; Function Attrs: noinline uwtable
define internal void @__cxx_global_var_init() #0 section ".text.startup" {
  call void @_ZN9LEDDriverC2Ev(%class.LEDDriver* @led)
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define linkonce_odr void @_ZN9LEDDriverC2Ev(%class.LEDDriver*) unnamed_addr #1 comdat align 2 {
  %2 = alloca %class.LEDDriver*, align 8
  store %class.LEDDriver* %0, %class.LEDDriver** %2, align 8
  %3 = load %class.LEDDriver*, %class.LEDDriver** %2, align 8
  %4 = getelementptr inbounds %class.LEDDriver, %class.LEDDriver* %3, i32 0, i32 0
  store i32 32, i32* %4, align 4
  %5 = getelementptr inbounds %class.LEDDriver, %class.LEDDriver* %3, i32 0, i32 1
  store i8 0, i8* %5, align 4
  ret void
}

; Function Attrs: noinline optnone uwtable
define void @_Z5blinkh(i8 zeroext) #2 {
  %2 = alloca i8, align 1
  %3 = alloca i32, align 4
  store i8 %0, i8* %2, align 1
  call void @_ZN9LEDDriver4initEv(%class.LEDDriver* @led)
  store i32 0, i32* %3, align 4
  br label %4

; <label>:4:                                      ; preds = %19, %1
  %5 = load i32, i32* %3, align 4
  %6 = icmp slt i32 %5, 3
  br i1 %6, label %7, label %22

; <label>:7:                                      ; preds = %4
  call void @_ZN9LEDDriver6turnOnEv(%class.LEDDriver* @led)
  %8 = load i8, i8* %2, align 1
  %9 = zext i8 %8 to i32
  %10 = and i32 %9, 4
  %11 = icmp ne i32 %10, 0
  br i1 %11, label %12, label %13

; <label>:12:                                     ; preds = %7
  call void @_Z9HAL_Delayj(i32 300)
  br label %14

; <label>:13:                                     ; preds = %7
  call void @_Z9HAL_Delayj(i32 100)
  br label %14

; <label>:14:                                     ; preds = %13, %12
  call void @_ZN9LEDDriver7turnOffEv(%class.LEDDriver* @led)
  %15 = load i8, i8* %2, align 1
  %16 = zext i8 %15 to i32
  %17 = shl i32 %16, 1
  %18 = trunc i32 %17 to i8
  store i8 %18, i8* %2, align 1
  call void @_Z9HAL_Delayj(i32 200)
  br label %19

; <label>:19:                                     ; preds = %14
  %20 = load i32, i32* %3, align 4
  %21 = add nsw i32 %20, 1
  store i32 %21, i32* %3, align 4
  br label %4

; <label>:22:                                     ; preds = %4
  ret void
}

; Function Attrs: noinline optnone uwtable
define linkonce_odr void @_ZN9LEDDriver4initEv(%class.LEDDriver*) #2 comdat align 2 {
  %2 = alloca %class.LEDDriver*, align 8
  store %class.LEDDriver* %0, %class.LEDDriver** %2, align 8
  %3 = load %class.LEDDriver*, %class.LEDDriver** %2, align 8
  %4 = getelementptr inbounds %class.LEDDriver, %class.LEDDriver* %3, i32 0, i32 1
  %5 = load i8, i8* %4, align 4
  %6 = trunc i8 %5 to i1
  br i1 %6, label %7, label %8

; <label>:7:                                      ; preds = %1
  br label %22

; <label>:8:                                      ; preds = %1
  %9 = load i32, i32* @GPIOA, align 4
  %10 = getelementptr inbounds %class.LEDDriver, %class.LEDDriver* %3, i32 0, i32 0
  %11 = load i32, i32* %10, align 4
  %12 = load i32, i32* @LL_GPIO_MODE_OUTPUT, align 4
  call void @_Z18LL_GPIO_SetPinModejjj(i32 %9, i32 %11, i32 %12)
  %13 = load i32, i32* @GPIOA, align 4
  %14 = getelementptr inbounds %class.LEDDriver, %class.LEDDriver* %3, i32 0, i32 0
  %15 = load i32, i32* %14, align 4
  %16 = load i32, i32* @LL_GPIO_OUTPUT_PUSHPULL, align 4
  call void @_Z24LL_GPIO_SetPinOutputTypejjj(i32 %13, i32 %15, i32 %16)
  %17 = load i32, i32* @GPIOA, align 4
  %18 = getelementptr inbounds %class.LEDDriver, %class.LEDDriver* %3, i32 0, i32 0
  %19 = load i32, i32* %18, align 4
  %20 = load i32, i32* @LL_GPIO_SPEED_FREQ_LOW, align 4
  call void @_Z19LL_GPIO_SetPinSpeedjjj(i32 %17, i32 %19, i32 %20)
  %21 = getelementptr inbounds %class.LEDDriver, %class.LEDDriver* %3, i32 0, i32 1
  store i8 1, i8* %21, align 4
  br label %22

; <label>:22:                                     ; preds = %8, %7
  ret void
}

; Function Attrs: noinline optnone uwtable
define linkonce_odr void @_ZN9LEDDriver6turnOnEv(%class.LEDDriver*) #2 comdat align 2 {
  %2 = alloca %class.LEDDriver*, align 8
  store %class.LEDDriver* %0, %class.LEDDriver** %2, align 8
  %3 = load %class.LEDDriver*, %class.LEDDriver** %2, align 8
  %4 = load i32, i32* @GPIOA, align 4
  %5 = getelementptr inbounds %class.LEDDriver, %class.LEDDriver* %3, i32 0, i32 0
  %6 = load i32, i32* %5, align 4
  call void @_Z22LL_GPIO_ResetOutputPinjj(i32 %4, i32 %6)
  ret void
}

declare void @_Z9HAL_Delayj(i32) #3

; Function Attrs: noinline optnone uwtable
define linkonce_odr void @_ZN9LEDDriver7turnOffEv(%class.LEDDriver*) #2 comdat align 2 {
  %2 = alloca %class.LEDDriver*, align 8
  store %class.LEDDriver* %0, %class.LEDDriver** %2, align 8
  %3 = load %class.LEDDriver*, %class.LEDDriver** %2, align 8
  %4 = load i32, i32* @GPIOA, align 4
  %5 = getelementptr inbounds %class.LEDDriver, %class.LEDDriver* %3, i32 0, i32 0
  %6 = load i32, i32* %5, align 4
  call void @_Z20LL_GPIO_SetOutputPinjj(i32 %4, i32 %6)
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define void @_Z12setLedStatush(i8 zeroext) #1 {
  %2 = alloca i8, align 1
  store i8 %0, i8* %2, align 1
  %3 = load i8, i8* %2, align 1
  %4 = zext i8 %3 to i32
  store volatile i32 %4, i32* @ledStatus, align 4
  ret void
}

; Function Attrs: noinline optnone uwtable
define void @_Z4halth(i8 zeroext) #2 {
  %2 = alloca i8, align 1
  store i8 %0, i8* %2, align 1
  call void @_ZN9LEDDriver4initEv(%class.LEDDriver* @led)
  br label %3

; <label>:3:                                      ; preds = %1, %3
  %4 = load i8, i8* %2, align 1
  call void @_Z5blinkh(i8 zeroext %4)
  call void @_Z9HAL_Delayj(i32 700)
  br label %3
                                                  ; No predecessors!
  ret void
}

; Function Attrs: noinline optnone uwtable
define void @_Z10vLEDThreadPv(i8*) #2 {
  %2 = alloca i8*, align 8
  store i8* %0, i8** %2, align 8
  call void @_ZN9LEDDriver4initEv(%class.LEDDriver* @led)
  br label %3

; <label>:3:                                      ; preds = %10, %1
  call void @vTaskDelay(i32 2000)
  %4 = load volatile i32, i32* @ledStatus, align 4
  %5 = icmp eq i32 %4, 255
  br i1 %5, label %6, label %7

; <label>:6:                                      ; preds = %3
  call void @_ZN9LEDDriver6turnOnEv(%class.LEDDriver* @led)
  call void @vTaskDelay(i32 100)
  call void @_ZN9LEDDriver7turnOffEv(%class.LEDDriver* @led)
  br label %10

; <label>:7:                                      ; preds = %3
  %8 = load volatile i32, i32* @ledStatus, align 4
  %9 = trunc i32 %8 to i8
  call void @_Z5blinkh(i8 zeroext %9)
  br label %10

; <label>:10:                                     ; preds = %7, %6
  br label %3
                                                  ; No predecessors!
  ret void
}

declare void @vTaskDelay(i32) #3

declare void @_Z18LL_GPIO_SetPinModejjj(i32, i32, i32) #3

declare void @_Z24LL_GPIO_SetPinOutputTypejjj(i32, i32, i32) #3

declare void @_Z19LL_GPIO_SetPinSpeedjjj(i32, i32, i32) #3

declare void @_Z22LL_GPIO_ResetOutputPinjj(i32, i32) #3

declare void @_Z20LL_GPIO_SetOutputPinjj(i32, i32) #3

; Function Attrs: noinline uwtable
define internal void @_GLOBAL__sub_I_LEDThread.cpp() #0 section ".text.startup" {
  call void @__cxx_global_var_init()
  ret void
}

attributes #0 = { noinline uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noinline optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
