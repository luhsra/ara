; ModuleID = '../../../GPSLogger/Src/GPS/GPSThread.cpp'
source_filename = "../../../GPSLogger/Src/GPS/GPSThread.cpp"
target datalayout = "e-m:e-p:32:32-f64:32:64-f80:32-n8:16:32-S128"
target triple = "i386-pc-linux-gnu"

%class.NMEAGPS = type { i8 }
%class.GPS_UART = type { [128 x i8], i8, i8, %struct.tskTaskControlBlock* }
%struct.tskTaskControlBlock = type opaque
%class.gps_fix = type { i8 }
%class.GPSDataModel = type { %class.gps_fix, %class.gps_fix, %class.GPSSatellitesData, [3 x %class.GPSOdometer*], [3 x i8], %struct.QueueDefinition* }
%class.GPSSatellitesData = type { [20 x %"struct.GPSSatellitesData::SatteliteData"], i8 }
%"struct.GPSSatellitesData::SatteliteData" = type { i8, i8 }
%class.GPSOdometer = type opaque
%struct.QueueDefinition = type opaque

$_ZN8GPS_UARTC2Ev = comdat any

$_ZN8GPS_UART14charReceivedCBEh = comdat any

$_ZN8GPS_UART4initEv = comdat any

$_ZN8GPS_UART13waitForStringEv = comdat any

$_ZNK8GPS_UART9availableEv = comdat any

$_ZN8GPS_UART8readCharEv = comdat any

$_ZNVK7NMEAGPS9availableEv = comdat any

@NEOGPS_PACKED = global %class.NMEAGPS zeroinitializer, align 1
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
@gpsParser = global %class.NMEAGPS zeroinitializer, align 1
@USART1 = global i8 100, align 1
@GPIOA = global i8 1, align 1
@LL_USART_STOPBITS_1 = global i8 1, align 1
@HAL_RCC_GPIOA_CLK_ENABLE = global i8 1, align 1
@USART1_IRQn = global i8 1, align 1
@LL_USART_DATAWIDTH_8B = global i8 1, align 1
@LL_USART_PARITY_NONE = global i8 1, align 1
@LL_USART_HWCONTROL_NONE = global i8 1, align 1
@LL_USART_DIRECTION_TX_RX = global i8 0, align 1
@gpsUart = global %class.GPS_UART zeroinitializer, align 4
@_ZZ8vGPSTaskPvE3tmp = internal constant %class.gps_fix undef, align 1
@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* @_GLOBAL__sub_I_GPSThread.cpp, i8* null }]

; Function Attrs: noinline
define internal void @__cxx_global_var_init() #0 section ".text.startup" {
  call void @_ZN7NMEAGPSC1Ev(%class.NMEAGPS* @NEOGPS_PACKED)
  ret void
}

declare void @_ZN7NMEAGPSC1Ev(%class.NMEAGPS*) unnamed_addr #1

; Function Attrs: noinline
define internal void @__cxx_global_var_init.1() #0 section ".text.startup" {
  call void @_ZN7NMEAGPSC1Ev(%class.NMEAGPS* @gpsParser)
  ret void
}

; Function Attrs: noinline
define internal void @__cxx_global_var_init.2() #0 section ".text.startup" {
  call void @_ZN8GPS_UARTC2Ev(%class.GPS_UART* @gpsUart) #4
  ret void
}

; Function Attrs: noinline nounwind optnone
define linkonce_odr void @_ZN8GPS_UARTC2Ev(%class.GPS_UART* %this) unnamed_addr #2 comdat align 2 {
  %this.addr = alloca %class.GPS_UART*, align 4
  store %class.GPS_UART* %this, %class.GPS_UART** %this.addr, align 4
  %this1 = load %class.GPS_UART*, %class.GPS_UART** %this.addr, align 4
  %lastReadIndex = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %this1, i32 0, i32 1
  store volatile i8 0, i8* %lastReadIndex, align 4
  %lastReceivedIndex = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %this1, i32 0, i32 2
  store volatile i8 0, i8* %lastReceivedIndex, align 1
  %xGPSThread = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %this1, i32 0, i32 3
  store %struct.tskTaskControlBlock* null, %struct.tskTaskControlBlock** %xGPSThread, align 4
  ret void
}

; Function Attrs: noinline optnone
define void @USART1_IRQHandler() #3 {
  %byte = alloca i8, align 1
  %1 = load i8, i8* @USART1, align 1
  %conv = zext i8 %1 to i32
  %call = call i32 @_Z21LL_USART_ReceiveData8j(i32 %conv)
  %conv1 = trunc i32 %call to i8
  store i8 %conv1, i8* %byte, align 1
  %2 = load i8, i8* %byte, align 1
  call void @_ZN8GPS_UART14charReceivedCBEh(%class.GPS_UART* @gpsUart, i8 zeroext %2)
  ret void
}

declare i32 @_Z21LL_USART_ReceiveData8j(i32) #1

; Function Attrs: noinline optnone
define linkonce_odr void @_ZN8GPS_UART14charReceivedCBEh(%class.GPS_UART* %this, i8 zeroext %c) #3 comdat align 2 {
  %this.addr = alloca %class.GPS_UART*, align 4
  %c.addr = alloca i8, align 1
  store %class.GPS_UART* %this, %class.GPS_UART** %this.addr, align 4
  store i8 %c, i8* %c.addr, align 1
  %this1 = load %class.GPS_UART*, %class.GPS_UART** %this.addr, align 4
  %1 = load i8, i8* %c.addr, align 1
  %rxBuffer = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %this1, i32 0, i32 0
  %lastReceivedIndex = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %this1, i32 0, i32 2
  %2 = load volatile i8, i8* %lastReceivedIndex, align 1
  %conv = zext i8 %2 to i32
  %rem = srem i32 %conv, 128
  %arrayidx = getelementptr inbounds [128 x i8], [128 x i8]* %rxBuffer, i32 0, i32 %rem
  store i8 %1, i8* %arrayidx, align 1
  %lastReceivedIndex2 = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %this1, i32 0, i32 2
  %3 = load volatile i8, i8* %lastReceivedIndex2, align 1
  %inc = add i8 %3, 1
  store volatile i8 %inc, i8* %lastReceivedIndex2, align 1
  %4 = load i8, i8* %c.addr, align 1
  %conv3 = zext i8 %4 to i32
  %cmp = icmp eq i32 %conv3, 10
  br i1 %cmp, label %5, label %7

; <label>:5:                                      ; preds = %0
  %xGPSThread = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %this1, i32 0, i32 3
  %6 = load %struct.tskTaskControlBlock*, %struct.tskTaskControlBlock** %xGPSThread, align 4
  call void @vTaskNotifyGiveFromISR(%struct.tskTaskControlBlock* %6, i32* null)
  br label %7

; <label>:7:                                      ; preds = %5, %0
  ret void
}

; Function Attrs: noinline optnone
define void @_Z8vGPSTaskPv(i8* %pvParameters) #3 {
  %pvParameters.addr = alloca i8*, align 4
  %maxLen = alloca i8, align 1
  %buf = alloca i8*, align 4
  %len = alloca i8, align 1
  %c = alloca i32, align 4
  %a = alloca i32, align 4
  %pointer_tmp = alloca i8*, align 4
  store i8* %pvParameters, i8** %pvParameters.addr, align 4
  store i8 0, i8* %maxLen, align 1
  call void @_ZN8GPS_UART4initEv(%class.GPS_UART* @gpsUart)
  br label %1

; <label>:1:                                      ; preds = %30, %2, %0
  %call = call i8* @_Z19requestRawGPSBufferv()
  store i8* %call, i8** %buf, align 4
  store i8 0, i8* %len, align 1
  %call1 = call zeroext i1 @_ZN8GPS_UART13waitForStringEv(%class.GPS_UART* @gpsUart)
  br i1 %call1, label %3, label %2

; <label>:2:                                      ; preds = %1
  br label %1

; <label>:3:                                      ; preds = %1
  br label %4

; <label>:4:                                      ; preds = %17, %3
  %call2 = call zeroext i1 @_ZNK8GPS_UART9availableEv(%class.GPS_UART* @gpsUart)
  br i1 %call2, label %5, label %18

; <label>:5:                                      ; preds = %4
  %call3 = call signext i8 @_ZN8GPS_UART8readCharEv(%class.GPS_UART* @gpsUart)
  %conv = sext i8 %call3 to i32
  store i32 %conv, i32* %c, align 4
  %6 = load i32, i32* %c, align 4
  %conv4 = trunc i32 %6 to i8
  %call5 = call i32 @_ZN7NMEAGPS6handleEh(%class.NMEAGPS* @gpsParser, i8 zeroext %conv4)
  %7 = load i32, i32* %c, align 4
  %conv6 = trunc i32 %7 to i8
  %8 = load i8*, i8** %buf, align 4
  %9 = load i8, i8* %len, align 1
  %inc = add i8 %9, 1
  store i8 %inc, i8* %len, align 1
  %idxprom = zext i8 %9 to i32
  %arrayidx = getelementptr inbounds i8, i8* %8, i32 %idxprom
  store i8 %conv6, i8* %arrayidx, align 1
  %10 = load i32, i32* %c, align 4
  %cmp = icmp eq i32 %10, 10
  br i1 %cmp, label %11, label %12

; <label>:11:                                     ; preds = %5
  br label %18

; <label>:12:                                     ; preds = %5
  %13 = load i8, i8* %len, align 1
  %conv7 = zext i8 %13 to i32
  %cmp8 = icmp eq i32 %conv7, 80
  br i1 %cmp8, label %14, label %17

; <label>:14:                                     ; preds = %12
  %15 = load i8*, i8** %buf, align 4
  %16 = load i8, i8* %len, align 1
  %idxprom9 = zext i8 %16 to i32
  %arrayidx10 = getelementptr inbounds i8, i8* %15, i32 %idxprom9
  store i8 10, i8* %arrayidx10, align 1
  br label %18

; <label>:17:                                     ; preds = %12
  br label %4

; <label>:18:                                     ; preds = %14, %11, %4
  %19 = load i8*, i8** %buf, align 4
  %20 = load i8, i8* %len, align 1
  %idxprom11 = zext i8 %20 to i32
  %arrayidx12 = getelementptr inbounds i8, i8* %19, i32 %idxprom11
  store i8 0, i8* %arrayidx12, align 1
  %21 = load i8, i8* %len, align 1
  %conv13 = zext i8 %21 to i32
  %22 = load i8, i8* %maxLen, align 1
  %conv14 = zext i8 %22 to i32
  %cmp15 = icmp sgt i32 %conv13, %conv14
  br i1 %cmp15, label %23, label %25

; <label>:23:                                     ; preds = %18
  %24 = load i8, i8* %len, align 1
  store i8 %24, i8* %maxLen, align 1
  br label %25

; <label>:25:                                     ; preds = %23, %18
  %26 = load i8, i8* %len, align 1
  call void @_Z13ackRawGPSDatah(i8 zeroext %26)
  %call16 = call zeroext i8 @_ZNVK7NMEAGPS9availableEv(%class.NMEAGPS* @gpsParser)
  %tobool = icmp ne i8 %call16, 0
  br i1 %tobool, label %27, label %30

; <label>:27:                                     ; preds = %25
  store i32 231, i32* %a, align 4
  %28 = bitcast i32* %a to i8*
  store i8* %28, i8** %pointer_tmp, align 4
  %call17 = call dereferenceable(64) %class.GPSDataModel* @_ZN12GPSDataModel8instanceEv()
  call void @_ZN12GPSDataModel16processNewGPSFixERK7gps_fix(%class.GPSDataModel* %call17, %class.gps_fix* dereferenceable(1) @_ZZ8vGPSTaskPvE3tmp)
  %call18 = call dereferenceable(64) %class.GPSDataModel* @_ZN12GPSDataModel8instanceEv()
  %29 = load i8*, i8** %pointer_tmp, align 4
  call void @_ZN12GPSDataModel24processNewSatellitesDataEPvh(%class.GPSDataModel* %call18, i8* %29, i8 zeroext 65)
  br label %30

; <label>:30:                                     ; preds = %27, %25
  call void @vTaskDelay(i32 10)
  br label %1
                                                  ; No predecessors!
  ret void
}

; Function Attrs: noinline optnone
define linkonce_odr void @_ZN8GPS_UART4initEv(%class.GPS_UART* %this) #3 comdat align 2 {
  %this.addr = alloca %class.GPS_UART*, align 4
  store %class.GPS_UART* %this, %class.GPS_UART** %this.addr, align 4
  %this1 = load %class.GPS_UART*, %class.GPS_UART** %this.addr, align 4
  %lastReadIndex = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %this1, i32 0, i32 1
  store volatile i8 0, i8* %lastReadIndex, align 4
  %lastReceivedIndex = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %this1, i32 0, i32 2
  store volatile i8 0, i8* %lastReceivedIndex, align 1
  %call = call %struct.tskTaskControlBlock* @xTaskGetCurrentTaskHandle()
  %xGPSThread = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %this1, i32 0, i32 3
  store %struct.tskTaskControlBlock* %call, %struct.tskTaskControlBlock** %xGPSThread, align 4
  %1 = load i8, i8* @GPIOA, align 1
  %conv = zext i8 %1 to i32
  %2 = load i32, i32* @LL_GPIO_PIN_9, align 4
  %3 = load i32, i32* @LL_GPIO_MODE_ALTERNATE, align 4
  call void @_Z18LL_GPIO_SetPinModejjj(i32 %conv, i32 %2, i32 %3)
  %4 = load i8, i8* @GPIOA, align 1
  %conv2 = zext i8 %4 to i32
  %5 = load i32, i32* @LL_GPIO_PIN_9, align 4
  %6 = load i32, i32* @LL_GPIO_SPEED_FREQ_HIGH, align 4
  call void @_Z19LL_GPIO_SetPinSpeedjjj(i32 %conv2, i32 %5, i32 %6)
  %7 = load i8, i8* @GPIOA, align 1
  %conv3 = zext i8 %7 to i32
  %8 = load i32, i32* @LL_GPIO_PIN_9, align 4
  %9 = load i32, i32* @LL_GPIO_OUTPUT_PUSHPULL, align 4
  call void @_Z24LL_GPIO_SetPinOutputTypejjj(i32 %conv3, i32 %8, i32 %9)
  %10 = load i8, i8* @GPIOA, align 1
  %conv4 = zext i8 %10 to i32
  %11 = load i32, i32* @LL_GPIO_PIN_10, align 4
  %12 = load i32, i32* @LL_GPIO_MODE_INPUT, align 4
  call void @_Z18LL_GPIO_SetPinModejjj(i32 %conv4, i32 %11, i32 %12)
  %13 = load i8, i8* @USART1, align 1
  %conv5 = zext i8 %13 to i32
  call void @_Z16LL_USART_Disablej(i32 %conv5)
  %14 = load i8, i8* @USART1, align 1
  %conv6 = zext i8 %14 to i32
  %call7 = call i32 @_Z20HAL_RCC_GetPCLK2Freqv()
  call void @_Z20LL_USART_SetBaudRatejjj(i32 %conv6, i32 %call7, i32 9600)
  %15 = load i8, i8* @USART1, align 1
  %conv8 = zext i8 %15 to i32
  %16 = load i8, i8* @LL_USART_DATAWIDTH_8B, align 1
  %conv9 = zext i8 %16 to i32
  call void @_Z21LL_USART_SetDataWidthjj(i32 %conv8, i32 %conv9)
  %17 = load i8, i8* @USART1, align 1
  %conv10 = zext i8 %17 to i32
  %18 = load i8, i8* @LL_USART_STOPBITS_1, align 1
  %conv11 = zext i8 %18 to i32
  call void @_Z26LL_USART_SetStopBitsLengthjj(i32 %conv10, i32 %conv11)
  %19 = load i8, i8* @USART1, align 1
  %conv12 = zext i8 %19 to i32
  %20 = load i8, i8* @LL_USART_PARITY_NONE, align 1
  %conv13 = zext i8 %20 to i32
  call void @_Z18LL_USART_SetParityjj(i32 %conv12, i32 %conv13)
  %21 = load i8, i8* @USART1, align 1
  %conv14 = zext i8 %21 to i32
  %22 = load i8, i8* @LL_USART_DIRECTION_TX_RX, align 1
  %conv15 = zext i8 %22 to i32
  call void @_Z29LL_USART_SetTransferDirectionjj(i32 %conv14, i32 %conv15)
  %23 = load i8, i8* @USART1, align 1
  %conv16 = zext i8 %23 to i32
  %24 = load i8, i8* @LL_USART_HWCONTROL_NONE, align 1
  %conv17 = zext i8 %24 to i32
  call void @_Z22LL_USART_SetHWFlowCtrljj(i32 %conv16, i32 %conv17)
  %25 = load i8, i8* @USART1_IRQn, align 1
  %conv18 = zext i8 %25 to i32
  call void @_Z20HAL_NVIC_SetPriorityjjj(i32 %conv18, i32 6, i32 0)
  %26 = load i8, i8* @USART1_IRQn, align 1
  %conv19 = zext i8 %26 to i32
  call void @_Z18HAL_NVIC_EnableIRQj(i32 %conv19)
  %27 = load i8, i8* @USART1, align 1
  %conv20 = zext i8 %27 to i32
  call void @_Z22LL_USART_EnableIT_RXNEj(i32 %conv20)
  %28 = load i8, i8* @USART1, align 1
  %conv21 = zext i8 %28 to i32
  call void @_Z15LL_USART_Enablej(i32 %conv21)
  ret void
}

declare i8* @_Z19requestRawGPSBufferv() #1

; Function Attrs: noinline optnone
define linkonce_odr zeroext i1 @_ZN8GPS_UART13waitForStringEv(%class.GPS_UART* %this) #3 comdat align 2 {
  %this.addr = alloca %class.GPS_UART*, align 4
  store %class.GPS_UART* %this, %class.GPS_UART** %this.addr, align 4
  %this1 = load %class.GPS_UART*, %class.GPS_UART** %this.addr, align 4
  %call = call i32 @ulTaskNotifyTake(i32 1, i32 10)
  %tobool = icmp ne i32 %call, 0
  ret i1 %tobool
}

; Function Attrs: noinline nounwind optnone
define linkonce_odr zeroext i1 @_ZNK8GPS_UART9availableEv(%class.GPS_UART* %this) #2 comdat align 2 {
  %this.addr = alloca %class.GPS_UART*, align 4
  store %class.GPS_UART* %this, %class.GPS_UART** %this.addr, align 4
  %this1 = load %class.GPS_UART*, %class.GPS_UART** %this.addr, align 4
  %lastReadIndex = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %this1, i32 0, i32 1
  %1 = load volatile i8, i8* %lastReadIndex, align 4
  %conv = zext i8 %1 to i32
  %lastReceivedIndex = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %this1, i32 0, i32 2
  %2 = load volatile i8, i8* %lastReceivedIndex, align 1
  %conv2 = zext i8 %2 to i32
  %cmp = icmp ne i32 %conv, %conv2
  ret i1 %cmp
}

; Function Attrs: noinline nounwind optnone
define linkonce_odr signext i8 @_ZN8GPS_UART8readCharEv(%class.GPS_UART* %this) #2 comdat align 2 {
  %retval = alloca i8, align 1
  %this.addr = alloca %class.GPS_UART*, align 4
  store %class.GPS_UART* %this, %class.GPS_UART** %this.addr, align 4
  %this1 = load %class.GPS_UART*, %class.GPS_UART** %this.addr, align 4
  %call = call zeroext i1 @_ZNK8GPS_UART9availableEv(%class.GPS_UART* %this1)
  br i1 %call, label %1, label %4

; <label>:1:                                      ; preds = %0
  %rxBuffer = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %this1, i32 0, i32 0
  %lastReadIndex = getelementptr inbounds %class.GPS_UART, %class.GPS_UART* %this1, i32 0, i32 1
  %2 = load volatile i8, i8* %lastReadIndex, align 4
  %inc = add i8 %2, 1
  store volatile i8 %inc, i8* %lastReadIndex, align 4
  %conv = zext i8 %2 to i32
  %rem = srem i32 %conv, 128
  %arrayidx = getelementptr inbounds [128 x i8], [128 x i8]* %rxBuffer, i32 0, i32 %rem
  %3 = load i8, i8* %arrayidx, align 1
  store i8 %3, i8* %retval, align 1
  br label %5

; <label>:4:                                      ; preds = %0
  store i8 0, i8* %retval, align 1
  br label %5

; <label>:5:                                      ; preds = %4, %1
  %6 = load i8, i8* %retval, align 1
  ret i8 %6
}

declare i32 @_ZN7NMEAGPS6handleEh(%class.NMEAGPS*, i8 zeroext) #1

declare void @_Z13ackRawGPSDatah(i8 zeroext) #1

; Function Attrs: noinline nounwind optnone
define linkonce_odr zeroext i8 @_ZNVK7NMEAGPS9availableEv(%class.NMEAGPS* %this) #2 comdat align 2 {
  %this.addr = alloca %class.NMEAGPS*, align 4
  store %class.NMEAGPS* %this, %class.NMEAGPS** %this.addr, align 4
  %this1 = load %class.NMEAGPS*, %class.NMEAGPS** %this.addr, align 4
  ret i8 1
}

declare dereferenceable(64) %class.GPSDataModel* @_ZN12GPSDataModel8instanceEv() #1

declare void @_ZN12GPSDataModel16processNewGPSFixERK7gps_fix(%class.GPSDataModel*, %class.gps_fix* dereferenceable(1)) #1

declare void @_ZN12GPSDataModel24processNewSatellitesDataEPvh(%class.GPSDataModel*, i8*, i8 zeroext) #1

declare void @vTaskDelay(i32) #1

declare void @vTaskNotifyGiveFromISR(%struct.tskTaskControlBlock*, i32*) #1

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

declare i32 @ulTaskNotifyTake(i32, i32) #1

; Function Attrs: noinline
define internal void @_GLOBAL__sub_I_GPSThread.cpp() #0 section ".text.startup" {
  call void @__cxx_global_var_init()
  call void @__cxx_global_var_init.1()
  call void @__cxx_global_var_init.2()
  ret void
}

attributes #0 = { noinline "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { noinline optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"NumRegisterParameters", i32 0}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
