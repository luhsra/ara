; ModuleID = 'GPS/GPSThread.cpp'
source_filename = "GPS/GPSThread.cpp"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%class.NMEAGPS = type { i8 }
%class.GPS_UART = type { [128 x i8], i8, i8, %struct.tskTaskControlBlock* }
%struct.tskTaskControlBlock = type opaque

$_ZN8GPS_UARTC2Ev = comdat any

$_ZN8GPS_UART14charReceivedCBEh = comdat any

$_ZN8GPS_UART4initEv = comdat any

$_ZN8GPS_UART13waitForStringEv = comdat any

$_ZNK8GPS_UART9availableEv = comdat any

$_ZN8GPS_UART8readCharEv = comdat any

$_ZNVK7NMEAGPS9availableEv = comdat any

@NEOGPS_PACKED = global %class.NMEAGPS zeroinitializer, align 1
@ledStatus = global i32 255, align 4
@LL_GPIO_SPEED_FREQ_LOW = global i32 1, align 4
@LL_GPIO_OUTPUT_PUSHPULL = global i32 1, align 4
@LL_GPIO_MODE_OUTPUT = global i32 1, align 4
@LL_GPIO_PIN_13 = global i32 13, align 4
@LL_GPIO_PIN_12 = global i32 12, align 4
@LL_GPIO_PULL_UP = global i32 13, align 4
@LL_GPIO_MODE_INPUT = global i32 13, align 4
@GPIOC = global i32 0, align 4
@gpsParser = global %class.NMEAGPS zeroinitializer, align 1
@USART1 = global i8 100, align 1
@GPIOA = global i8 1, align 1
@LL_USART_STOPBITS_1 = global i8 1, align 1
@HAL_RCC_GPIOA_CLK_ENABLE = global i8 1, align 1
@LL_GPIO_SPEED_FREQ_HIGH = global i8 1, align 1
@LL_GPIO_MODE_ALTERNATE = global i8 1, align 1
@USART1_IRQn = global i8 1, align 1
@LL_GPIO_PIN_9 = global i8 1, align 1
@LL_GPIO_PIN_10 = global i8 1, align 1
@LL_USART_DATAWIDTH_8B = global i8 1, align 1
@LL_USART_PARITY_NONE = global i8 1, align 1
@LL_USART_HWCONTROL_NONE = global i8 1, align 1
@LL_USART_DIRECTION_TX_RX = global i8 0, align 1
@gpsUart = global %class.GPS_UART zeroinitializer, align 8
@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* @_GLOBAL__sub_I_GPSThread.cpp, i8* null }]

; Function Attrs: noinline uwtable
define internal void @__cxx_global_var_init() #0 section ".text.startup" {
  call void @_ZN7NMEAGPSC1Ev(%class.NMEAGPS* @NEOGPS_PACKED)
  ret void
}

declare void @_ZN7NMEAGPSC1Ev(%class.NMEAGPS*) unnamed_addr #1

; Function Attrs: noinline uwtable
define internal void @__cxx_global_var_init.1() #0 section ".text.startup" {
  call void @_ZN7NMEAGPSC1Ev(%class.NMEAGPS* @gpsParser)
  ret void
}

; Function Attrs: noinline uwtable
define internal void @__cxx_global_var_init.2() #0 section ".text.startup" {
  call void @_ZN8GPS_UARTC2Ev(%class.GPS_UART* @gpsUart) #4
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define linkonce_odr void @_ZN8GPS_UARTC2Ev(%class.GPS_UART*) unnamed_addr #2 comdat align 2 {
  %2 = alloca %class.GPS_UART*, align 8
  store %class.GPS_UART* %0, %class.GPS_UART** %2, align 8
  %3 = load %class.GPS_UART*, %class.GPS_UART** %2, align 8
  %4 = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %3, i32 0, i32 1
  store volatile i8 0, i8* %4, align 8
  %5 = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %3, i32 0, i32 2
  store volatile i8 0, i8* %5, align 1
  %6 = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %3, i32 0, i32 3
  store %struct.tskTaskControlBlock* null, %struct.tskTaskControlBlock** %6, align 8
  ret void
}

; Function Attrs: noinline optnone uwtable
define void @USART1_IRQHandler() #3 {
  %1 = alloca i8, align 1
  %2 = load i8, i8* @USART1, align 1
  %3 = zext i8 %2 to i32
  %4 = call i32 @_Z21LL_USART_ReceiveData8j(i32 %3)
  %5 = trunc i32 %4 to i8
  store i8 %5, i8* %1, align 1
  %6 = load i8, i8* %1, align 1
  call void @_ZN8GPS_UART14charReceivedCBEh(%class.GPS_UART* @gpsUart, i8 zeroext %6)
  ret void
}

declare i32 @_Z21LL_USART_ReceiveData8j(i32) #1

; Function Attrs: noinline optnone uwtable
define linkonce_odr void @_ZN8GPS_UART14charReceivedCBEh(%class.GPS_UART*, i8 zeroext) #3 comdat align 2 {
  %3 = alloca %class.GPS_UART*, align 8
  %4 = alloca i8, align 1
  store %class.GPS_UART* %0, %class.GPS_UART** %3, align 8
  store i8 %1, i8* %4, align 1
  %5 = load %class.GPS_UART*, %class.GPS_UART** %3, align 8
  %6 = load i8, i8* %4, align 1
  %7 = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %5, i32 0, i32 0
  %8 = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %5, i32 0, i32 2
  %9 = load volatile i8, i8* %8, align 1
  %10 = zext i8 %9 to i32
  %11 = srem i32 %10, 128
  %12 = sext i32 %11 to i64
  %13 = getelementptr inbounds [128 x i8], [128 x i8]* %7, i64 0, i64 %12
  store i8 %6, i8* %13, align 1
  %14 = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %5, i32 0, i32 2
  %15 = load volatile i8, i8* %14, align 1
  %16 = add i8 %15, 1
  store volatile i8 %16, i8* %14, align 1
  %17 = load i8, i8* %4, align 1
  %18 = zext i8 %17 to i32
  %19 = icmp eq i32 %18, 10
  br i1 %19, label %20, label %23

; <label>:20:                                     ; preds = %2
  %21 = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %5, i32 0, i32 3
  %22 = load %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** %21, align 8
  call void @vTaskNotifyGiveFromISR(%struct.tskTaskControlBlock* %22, i64* null)
  br label %23

; <label>:23:                                     ; preds = %20, %2
  ret void
}

; Function Attrs: noinline optnone uwtable
define void @_Z8vGPSTaskPv(i8*) #3 {
  %2 = alloca i8*, align 8
  %3 = alloca i8, align 1
  %4 = alloca i8*, align 8
  %5 = alloca i8, align 1
  %6 = alloca i32, align 4
  store i8* %0, i8** %2, align 8
  store i8 0, i8* %3, align 1
  call void @_ZN8GPS_UART4initEv(%class.GPS_UART* @gpsUart)
  br label %7

; <label>:7:                                      ; preds = %57, %10, %1
  %8 = call i8* @_Z19requestRawGPSBufferv()
  store i8* %8, i8** %4, align 8
  store i8 0, i8* %5, align 1
  %9 = call zeroext i1 @_ZN8GPS_UART13waitForStringEv(%class.GPS_UART* @gpsUart)
  br i1 %9, label %11, label %10

; <label>:10:                                     ; preds = %7
  br label %7

; <label>:11:                                     ; preds = %7
  br label %12

; <label>:12:                                     ; preds = %39, %11
  %13 = call zeroext i1 @_ZNK8GPS_UART9availableEv(%class.GPS_UART* @gpsUart)
  br i1 %13, label %14, label %40

; <label>:14:                                     ; preds = %12
  %15 = call signext i8 @_ZN8GPS_UART8readCharEv(%class.GPS_UART* @gpsUart)
  %16 = sext i8 %15 to i32
  store i32 %16, i32* %6, align 4
  %17 = load i32, i32* %6, align 4
  %18 = trunc i32 %17 to i8
  %19 = call i32 @_ZN7NMEAGPS6handleEh(%class.NMEAGPS* @gpsParser, i8 zeroext %18)
  %20 = load i32, i32* %6, align 4
  %21 = trunc i32 %20 to i8
  %22 = load i8*, i8** %4, align 8
  %23 = load i8, i8* %5, align 1
  %24 = add i8 %23, 1
  store i8 %24, i8* %5, align 1
  %25 = zext i8 %23 to i64
  %26 = getelementptr inbounds i8, i8* %22, i64 %25
  store i8 %21, i8* %26, align 1
  %27 = load i32, i32* %6, align 4
  %28 = icmp eq i32 %27, 10
  br i1 %28, label %29, label %30

; <label>:29:                                     ; preds = %14
  br label %40

; <label>:30:                                     ; preds = %14
  %31 = load i8, i8* %5, align 1
  %32 = zext i8 %31 to i32
  %33 = icmp eq i32 %32, 80
  br i1 %33, label %34, label %39

; <label>:34:                                     ; preds = %30
  %35 = load i8*, i8** %4, align 8
  %36 = load i8, i8* %5, align 1
  %37 = zext i8 %36 to i64
  %38 = getelementptr inbounds i8, i8* %35, i64 %37
  store i8 10, i8* %38, align 1
  br label %40

; <label>:39:                                     ; preds = %30
  br label %12

; <label>:40:                                     ; preds = %34, %29, %12
  %41 = load i8*, i8** %4, align 8
  %42 = load i8, i8* %5, align 1
  %43 = zext i8 %42 to i64
  %44 = getelementptr inbounds i8, i8* %41, i64 %43
  store i8 0, i8* %44, align 1
  %45 = load i8, i8* %5, align 1
  %46 = zext i8 %45 to i32
  %47 = load i8, i8* %3, align 1
  %48 = zext i8 %47 to i32
  %49 = icmp sgt i32 %46, %48
  br i1 %49, label %50, label %52

; <label>:50:                                     ; preds = %40
  %51 = load i8, i8* %5, align 1
  store i8 %51, i8* %3, align 1
  br label %52

; <label>:52:                                     ; preds = %50, %40
  %53 = load i8, i8* %5, align 1
  call void @_Z13ackRawGPSDatah(i8 zeroext %53)
  %54 = call zeroext i8 @_ZNVK7NMEAGPS9availableEv(%class.NMEAGPS* @gpsParser)
  %55 = icmp ne i8 %54, 0
  br i1 %55, label %56, label %57

; <label>:56:                                     ; preds = %52
  br label %57

; <label>:57:                                     ; preds = %56, %52
  call void @vTaskDelay(i32 10)
  br label %7
                                                  ; No predecessors!
  ret void
}

; Function Attrs: noinline optnone uwtable
define linkonce_odr void @_ZN8GPS_UART4initEv(%class.GPS_UART*) #3 comdat align 2 {
  %2 = alloca %class.GPS_UART*, align 8
  store %class.GPS_UART* %0, %class.GPS_UART** %2, align 8
  %3 = load %class.GPS_UART*, %class.GPS_UART** %2, align 8
  %4 = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %3, i32 0, i32 1
  store volatile i8 0, i8* %4, align 8
  %5 = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %3, i32 0, i32 2
  store volatile i8 0, i8* %5, align 1
  %6 = call %struct.tskTaskControlBlock* @xTaskGetCurrentTaskHandle()
  %7 = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %3, i32 0, i32 3
  store %struct.tskTaskControlBlock* %6, %struct.tskTaskControlBlock** %7, align 8
  %8 = load i8, i8* @GPIOA, align 1
  %9 = zext i8 %8 to i32
  %10 = load i8, i8* @LL_GPIO_PIN_9, align 1
  %11 = zext i8 %10 to i32
  %12 = load i8, i8* @LL_GPIO_MODE_ALTERNATE, align 1
  %13 = zext i8 %12 to i32
  call void @_Z18LL_GPIO_SetPinModejjj(i32 %9, i32 %11, i32 %13)
  %14 = load i8, i8* @GPIOA, align 1
  %15 = zext i8 %14 to i32
  %16 = load i8, i8* @LL_GPIO_PIN_9, align 1
  %17 = zext i8 %16 to i32
  %18 = load i8, i8* @LL_GPIO_SPEED_FREQ_HIGH, align 1
  %19 = zext i8 %18 to i32
  call void @_Z19LL_GPIO_SetPinSpeedjjj(i32 %15, i32 %17, i32 %19)
  %20 = load i8, i8* @GPIOA, align 1
  %21 = zext i8 %20 to i32
  %22 = load i8, i8* @LL_GPIO_PIN_9, align 1
  %23 = zext i8 %22 to i32
  %24 = load i32, i32* @LL_GPIO_OUTPUT_PUSHPULL, align 4
  call void @_Z24LL_GPIO_SetPinOutputTypejjj(i32 %21, i32 %23, i32 %24)
  %25 = load i8, i8* @GPIOA, align 1
  %26 = zext i8 %25 to i32
  %27 = load i8, i8* @LL_GPIO_PIN_10, align 1
  %28 = zext i8 %27 to i32
  %29 = load i32, i32* @LL_GPIO_MODE_INPUT, align 4
  call void @_Z18LL_GPIO_SetPinModejjj(i32 %26, i32 %28, i32 %29)
  %30 = load i8, i8* @USART1, align 1
  %31 = zext i8 %30 to i32
  call void @_Z16LL_USART_Disablej(i32 %31)
  %32 = load i8, i8* @USART1, align 1
  %33 = zext i8 %32 to i32
  %34 = call i32 @_Z20HAL_RCC_GetPCLK2Freqv()
  call void @_Z20LL_USART_SetBaudRatejjj(i32 %33, i32 %34, i32 9600)
  %35 = load i8, i8* @USART1, align 1
  %36 = zext i8 %35 to i32
  %37 = load i8, i8* @LL_USART_DATAWIDTH_8B, align 1
  %38 = zext i8 %37 to i32
  call void @_Z21LL_USART_SetDataWidthjj(i32 %36, i32 %38)
  %39 = load i8, i8* @USART1, align 1
  %40 = zext i8 %39 to i32
  %41 = load i8, i8* @LL_USART_STOPBITS_1, align 1
  %42 = zext i8 %41 to i32
  call void @_Z26LL_USART_SetStopBitsLengthjj(i32 %40, i32 %42)
  %43 = load i8, i8* @USART1, align 1
  %44 = zext i8 %43 to i32
  %45 = load i8, i8* @LL_USART_PARITY_NONE, align 1
  %46 = zext i8 %45 to i32
  call void @_Z18LL_USART_SetParityjj(i32 %44, i32 %46)
  %47 = load i8, i8* @USART1, align 1
  %48 = zext i8 %47 to i32
  %49 = load i8, i8* @LL_USART_DIRECTION_TX_RX, align 1
  %50 = zext i8 %49 to i32
  call void @_Z29LL_USART_SetTransferDirectionjj(i32 %48, i32 %50)
  %51 = load i8, i8* @USART1, align 1
  %52 = zext i8 %51 to i32
  %53 = load i8, i8* @LL_USART_HWCONTROL_NONE, align 1
  %54 = zext i8 %53 to i32
  call void @_Z22LL_USART_SetHWFlowCtrljj(i32 %52, i32 %54)
  %55 = load i8, i8* @USART1_IRQn, align 1
  %56 = zext i8 %55 to i32
  call void @_Z20HAL_NVIC_SetPriorityjjj(i32 %56, i32 6, i32 0)
  %57 = load i8, i8* @USART1_IRQn, align 1
  %58 = zext i8 %57 to i32
  call void @_Z18HAL_NVIC_EnableIRQj(i32 %58)
  %59 = load i8, i8* @USART1, align 1
  %60 = zext i8 %59 to i32
  call void @_Z22LL_USART_EnableIT_RXNEj(i32 %60)
  %61 = load i8, i8* @USART1, align 1
  %62 = zext i8 %61 to i32
  call void @_Z15LL_USART_Enablej(i32 %62)
  ret void
}

declare i8* @_Z19requestRawGPSBufferv() #1

; Function Attrs: noinline optnone uwtable
define linkonce_odr zeroext i1 @_ZN8GPS_UART13waitForStringEv(%class.GPS_UART*) #3 comdat align 2 {
  %2 = alloca %class.GPS_UART*, align 8
  store %class.GPS_UART* %0, %class.GPS_UART** %2, align 8
  %3 = load %class.GPS_UART*, %class.GPS_UART** %2, align 8
  %4 = call i32 @ulTaskNotifyTake(i64 1, i32 10)
  %5 = icmp ne i32 %4, 0
  ret i1 %5
}

; Function Attrs: noinline nounwind optnone uwtable
define linkonce_odr zeroext i1 @_ZNK8GPS_UART9availableEv(%class.GPS_UART*) #2 comdat align 2 {
  %2 = alloca %class.GPS_UART*, align 8
  store %class.GPS_UART* %0, %class.GPS_UART** %2, align 8
  %3 = load %class.GPS_UART*, %class.GPS_UART** %2, align 8
  %4 = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %3, i32 0, i32 1
  %5 = load volatile i8, i8* %4, align 8
  %6 = zext i8 %5 to i32
  %7 = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %3, i32 0, i32 2
  %8 = load volatile i8, i8* %7, align 1
  %9 = zext i8 %8 to i32
  %10 = icmp ne i32 %6, %9
  ret i1 %10
}

; Function Attrs: noinline nounwind optnone uwtable
define linkonce_odr signext i8 @_ZN8GPS_UART8readCharEv(%class.GPS_UART*) #2 comdat align 2 {
  %2 = alloca i8, align 1
  %3 = alloca %class.GPS_UART*, align 8
  store %class.GPS_UART* %0, %class.GPS_UART** %3, align 8
  %4 = load %class.GPS_UART*, %class.GPS_UART** %3, align 8
  %5 = call zeroext i1 @_ZNK8GPS_UART9availableEv(%class.GPS_UART* %4)
  br i1 %5, label %6, label %16

; <label>:6:                                      ; preds = %1
  %7 = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %4, i32 0, i32 0
  %8 = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %4, i32 0, i32 1
  %9 = load volatile i8, i8* %8, align 8
  %10 = add i8 %9, 1
  store volatile i8 %10, i8* %8, align 8
  %11 = zext i8 %9 to i32
  %12 = srem i32 %11, 128
  %13 = sext i32 %12 to i64
  %14 = getelementptr inbounds [128 x i8], [128 x i8]* %7, i64 0, i64 %13
  %15 = load i8, i8* %14, align 1
  store i8 %15, i8* %2, align 1
  br label %17

; <label>:16:                                     ; preds = %1
  store i8 0, i8* %2, align 1
  br label %17

; <label>:17:                                     ; preds = %16, %6
  %18 = load i8, i8* %2, align 1
  ret i8 %18
}

declare i32 @_ZN7NMEAGPS6handleEh(%class.NMEAGPS*, i8 zeroext) #1

declare void @_Z13ackRawGPSDatah(i8 zeroext) #1

; Function Attrs: noinline nounwind optnone uwtable
define linkonce_odr zeroext i8 @_ZNVK7NMEAGPS9availableEv(%class.NMEAGPS*) #2 comdat align 2 {
  %2 = alloca %class.NMEAGPS*, align 8
  store %class.NMEAGPS* %0, %class.NMEAGPS** %2, align 8
  %3 = load %class.NMEAGPS*, %class.NMEAGPS** %2, align 8
  ret i8 1
}

declare void @vTaskDelay(i32) #1

declare void @vTaskNotifyGiveFromISR(%struct.tskTaskControlBlock*, i64*) #1

declare %struct.tskTaskControlBlock* @xTaskGetCurrentTaskHandle() #1

declare void @_Z18LL_GPIO_SetPinModejjj(i32, i32, i32) #1

declare void @_Z19LL_GPIO_SetPinSpeedjjj(i32, i32, i32) #1

declare void @_Z24LL_GPIO_SetPinOutputTypejjj(i32, i32, i32) #1

declare void @_Z16LL_USART_Disablej(i32) #1

declare void @_Z20LL_USART_SetBaudRatejjj(i32, i32, i32) #1

declare i32 @_Z20HAL_RCC_GetPCLK2Freqv() #1

declare void @_Z21LL_USART_SetDataWidthjj(i32, i32) #1

declare void @_Z26LL_USART_SetStopBitsLengthjj(i32, i32) #1

declare void @_Z18LL_USART_SetParityjj(i32, i32) #1

declare void @_Z29LL_USART_SetTransferDirectionjj(i32, i32) #1

declare void @_Z22LL_USART_SetHWFlowCtrljj(i32, i32) #1

declare void @_Z20HAL_NVIC_SetPriorityjjj(i32, i32, i32) #1

declare void @_Z18HAL_NVIC_EnableIRQj(i32) #1

declare void @_Z22LL_USART_EnableIT_RXNEj(i32) #1

declare void @_Z15LL_USART_Enablej(i32) #1

declare i32 @ulTaskNotifyTake(i64, i32) #1

; Function Attrs: noinline uwtable
define internal void @_GLOBAL__sub_I_GPSThread.cpp() #0 section ".text.startup" {
  call void @__cxx_global_var_init()
  call void @__cxx_global_var_init.1()
  call void @__cxx_global_var_init.2()
  ret void
}

attributes #0 = { noinline uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { noinline optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
