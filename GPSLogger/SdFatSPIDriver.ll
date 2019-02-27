; ModuleID = '../../../GPSLogger/Src/SdFatSPIDriver.cpp'
source_filename = "../../../GPSLogger/Src/SdFatSPIDriver.cpp"
target datalayout = "e-m:e-p:32:32-f64:32:64-f80:32-n8:16:32-S128"
target triple = "i386-pc-linux-gnu"

%class.SdFatSPIDriver = type { i32 (...)**, %struct.DMA_HandleTypeDef, %struct.DMA_HandleTypeDef, %struct.DMA_HandleTypeDef, %struct.QueueDefinition* }
%struct.DMA_HandleTypeDef = type { i8*, i32, i32, i32, i8*, void (%struct.__DMA_HandleTypeDef*)*, void (%struct.__DMA_HandleTypeDef*)*, void (%struct.__DMA_HandleTypeDef*)*, void (%struct.__DMA_HandleTypeDef*)*, void (%struct.__DMA_HandleTypeDef*)*, void (%struct.__DMA_HandleTypeDef*)*, i32, i32, i32 }
%struct.__DMA_HandleTypeDef = type opaque
%struct.QueueDefinition = type opaque
%class.SPISettings = type opaque

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
@debugEnabled = global i8 0, align 1
@_ZTV14SdFatSPIDriver = unnamed_addr constant { [12 x i8*] } { [12 x i8*] [i8* null, i8* bitcast ({ i8*, i8* }* @_ZTI14SdFatSPIDriver to i8*), i8* bitcast (void (%class.SdFatSPIDriver*)* @_ZN14SdFatSPIDriver8activateEv to i8*), i8* bitcast (void (%class.SdFatSPIDriver*, i8)* @_ZN14SdFatSPIDriver5beginEh to i8*), i8* bitcast (void (%class.SdFatSPIDriver*)* @_ZN14SdFatSPIDriver10deactivateEv to i8*), i8* bitcast (i8 (%class.SdFatSPIDriver*)* @_ZN14SdFatSPIDriver7receiveEv to i8*), i8* bitcast (i8 (%class.SdFatSPIDriver*, i8*, i32)* @_ZN14SdFatSPIDriver7receiveEPhj to i8*), i8* bitcast (void (%class.SdFatSPIDriver*, i8)* @_ZN14SdFatSPIDriver4sendEh to i8*), i8* bitcast (void (%class.SdFatSPIDriver*, i8*, i32)* @_ZN14SdFatSPIDriver4sendEPKhj to i8*), i8* bitcast (void (%class.SdFatSPIDriver*)* @_ZN14SdFatSPIDriver6selectEv to i8*), i8* bitcast (void (%class.SdFatSPIDriver*, %class.SPISettings*)* @_ZN14SdFatSPIDriver14setSpiSettingsERK11SPISettings to i8*), i8* bitcast (void (%class.SdFatSPIDriver*)* @_ZN14SdFatSPIDriver8unselectEv to i8*)] }, align 4
@_ZTVN10__cxxabiv117__class_type_infoE = external global i8*
@_ZTS14SdFatSPIDriver = constant [17 x i8] c"14SdFatSPIDriver\00"
@_ZTI14SdFatSPIDriver = constant { i8*, i8* } { i8* bitcast (i8** getelementptr inbounds (i8*, i8** @_ZTVN10__cxxabiv117__class_type_infoE, i32 2) to i8*), i8* getelementptr inbounds ([17 x i8], [17 x i8]* @_ZTS14SdFatSPIDriver, i32 0, i32 0) }

; Function Attrs: noinline optnone
define void @_ZN14SdFatSPIDriver5beginEh(%class.SdFatSPIDriver* %this, i8 zeroext %chipSelectPin) unnamed_addr #0 align 2 {
  %ulNewMaskValue.addr.i = alloca i32, align 4
  %ulNewBASEPRI.i = alloca i32, align 4
  %this.addr = alloca %class.SdFatSPIDriver*, align 4
  %chipSelectPin.addr = alloca i8, align 1
  %MOSI = alloca i32, align 4
  %MISO = alloca i32, align 4
  %SCK = alloca i32, align 4
  %CS = alloca i32, align 4
  store %class.SdFatSPIDriver* %this, %class.SdFatSPIDriver** %this.addr, align 4
  store i8 %chipSelectPin, i8* %chipSelectPin.addr, align 1
  %this1 = load %class.SdFatSPIDriver*, %class.SdFatSPIDriver** %this.addr, align 4
  %1 = call i32 asm sideeffect "\09mov $0, $1\09\09\09\09\09\09\09\09\09\09\09\09\0A\09msr basepri, $0\09\09\09\09\09\09\09\09\09\09\09\0A\09isb\09\09\09\09\09\09\09\09\09\09\09\09\09\09\0A\09dsb\09\09\09\09\09\09\09\09\09\09\09\09\09\09\0A", "=r,i,~{dirflag},~{fpsr},~{flags}"(i32 80) #3, !srcloc !3
  store i32 %1, i32* %ulNewBASEPRI.i, align 4
  %call = call %struct.QueueDefinition* @xQueueGenericCreate(i32 1, i32 0, i8 zeroext 3)
  %xSema = getelementptr inbounds %class.SdFatSPIDriver, %class.SdFatSPIDriver* %this1, i32 0, i32 4
  store %struct.QueueDefinition* %call, %struct.QueueDefinition** %xSema, align 4
  store i32 0, i32* %ulNewMaskValue.addr.i, align 4
  %2 = load i32, i32* %ulNewMaskValue.addr.i, align 4
  call void asm sideeffect "\09msr basepri, $0\09", "r,~{dirflag},~{fpsr},~{flags}"(i32 %2) #3, !srcloc !4
  %3 = load i32, i32* @GPIOB, align 4
  %4 = load i32, i32* @LL_GPIO_PIN_1, align 4
  %5 = load i32, i32* @LL_GPIO_MODE_OUTPUT, align 4
  call void @_Z18LL_GPIO_SetPinModejjj(i32 %3, i32 %4, i32 %5)
  %6 = load i32, i32* @GPIOB, align 4
  %7 = load i32, i32* @LL_GPIO_PIN_1, align 4
  %8 = load i32, i32* @LL_GPIO_OUTPUT_PUSHPULL, align 4
  call void @_Z24LL_GPIO_SetPinOutputTypejjj(i32 %6, i32 %7, i32 %8)
  %9 = load i32, i32* @GPIOB, align 4
  %10 = load i32, i32* @LL_GPIO_PIN_1, align 4
  %11 = load i32, i32* @LL_GPIO_SPEED_FREQ_HIGH, align 4
  call void @_Z19LL_GPIO_SetPinSpeedjjj(i32 %9, i32 %10, i32 %11)
  %12 = load i32, i32* @GPIOB, align 4
  %13 = load i32, i32* @LL_GPIO_PIN_0, align 4
  %14 = load i32, i32* @LL_GPIO_MODE_OUTPUT, align 4
  call void @_Z18LL_GPIO_SetPinModejjj(i32 %12, i32 %13, i32 %14)
  %15 = load i32, i32* @GPIOB, align 4
  %16 = load i32, i32* @LL_GPIO_PIN_0, align 4
  %17 = load i32, i32* @LL_GPIO_OUTPUT_PUSHPULL, align 4
  call void @_Z24LL_GPIO_SetPinOutputTypejjj(i32 %15, i32 %16, i32 %17)
  %18 = load i32, i32* @GPIOB, align 4
  %19 = load i32, i32* @LL_GPIO_PIN_0, align 4
  %20 = load i32, i32* @LL_GPIO_SPEED_FREQ_HIGH, align 4
  call void @_Z19LL_GPIO_SetPinSpeedjjj(i32 %18, i32 %19, i32 %20)
  %21 = load i32, i32* @LL_GPIO_PIN_15, align 4
  store i32 %21, i32* %MOSI, align 4
  %22 = load i32, i32* @GPIOB, align 4
  %23 = load i32, i32* %MOSI, align 4
  %24 = load i32, i32* @LL_GPIO_MODE_ALTERNATE, align 4
  call void @_Z18LL_GPIO_SetPinModejjj(i32 %22, i32 %23, i32 %24)
  %25 = load i32, i32* @GPIOB, align 4
  %26 = load i32, i32* %MOSI, align 4
  %27 = load i32, i32* @LL_GPIO_OUTPUT_PUSHPULL, align 4
  call void @_Z24LL_GPIO_SetPinOutputTypejjj(i32 %25, i32 %26, i32 %27)
  %28 = load i32, i32* @GPIOB, align 4
  %29 = load i32, i32* %MOSI, align 4
  %30 = load i32, i32* @LL_GPIO_SPEED_FREQ_HIGH, align 4
  call void @_Z19LL_GPIO_SetPinSpeedjjj(i32 %28, i32 %29, i32 %30)
  %31 = load i32, i32* @LL_GPIO_PIN_14, align 4
  store i32 %31, i32* %MISO, align 4
  %32 = load i32, i32* @GPIOB, align 4
  %33 = load i32, i32* %MISO, align 4
  %34 = load i32, i32* @LL_GPIO_MODE_INPUT, align 4
  call void @_Z18LL_GPIO_SetPinModejjj(i32 %32, i32 %33, i32 %34)
  %35 = load i32, i32* @LL_GPIO_PIN_13, align 4
  store i32 %35, i32* %SCK, align 4
  %36 = load i32, i32* @GPIOB, align 4
  %37 = load i32, i32* %SCK, align 4
  %38 = load i32, i32* @LL_GPIO_MODE_ALTERNATE, align 4
  call void @_Z18LL_GPIO_SetPinModejjj(i32 %36, i32 %37, i32 %38)
  %39 = load i32, i32* @GPIOB, align 4
  %40 = load i32, i32* %SCK, align 4
  %41 = load i32, i32* @LL_GPIO_OUTPUT_PUSHPULL, align 4
  call void @_Z24LL_GPIO_SetPinOutputTypejjj(i32 %39, i32 %40, i32 %41)
  %42 = load i32, i32* @GPIOB, align 4
  %43 = load i32, i32* %SCK, align 4
  %44 = load i32, i32* @LL_GPIO_SPEED_FREQ_HIGH, align 4
  call void @_Z19LL_GPIO_SetPinSpeedjjj(i32 %42, i32 %43, i32 %44)
  %45 = load i32, i32* @LL_GPIO_PIN_12, align 4
  store i32 %45, i32* %CS, align 4
  %46 = load i32, i32* @GPIOB, align 4
  %47 = load i32, i32* %CS, align 4
  %48 = load i32, i32* @LL_GPIO_MODE_OUTPUT, align 4
  call void @_Z18LL_GPIO_SetPinModejjj(i32 %46, i32 %47, i32 %48)
  %49 = load i32, i32* @GPIOB, align 4
  %50 = load i32, i32* %CS, align 4
  %51 = load i32, i32* @LL_GPIO_OUTPUT_PUSHPULL, align 4
  call void @_Z24LL_GPIO_SetPinOutputTypejjj(i32 %49, i32 %50, i32 %51)
  %52 = load i32, i32* @GPIOB, align 4
  %53 = load i32, i32* %CS, align 4
  %54 = load i32, i32* @LL_GPIO_SPEED_FREQ_MEDIUM, align 4
  call void @_Z19LL_GPIO_SetPinSpeedjjj(i32 %52, i32 %53, i32 %54)
  %55 = load i32, i32* @GPIOB, align 4
  %56 = load i32, i32* %CS, align 4
  call void @_Z20LL_GPIO_SetOutputPinjj(i32 %55, i32 %56)
  ret void
}

declare %struct.QueueDefinition* @xQueueGenericCreate(i32, i32, i8 zeroext) #1

declare void @_Z18LL_GPIO_SetPinModejjj(i32, i32, i32) #1

declare void @_Z24LL_GPIO_SetPinOutputTypejjj(i32, i32, i32) #1

declare void @_Z19LL_GPIO_SetPinSpeedjjj(i32, i32, i32) #1

declare void @_Z20LL_GPIO_SetOutputPinjj(i32, i32) #1

; Function Attrs: noinline nounwind optnone
define void @_ZN14SdFatSPIDriver8activateEv(%class.SdFatSPIDriver* %this) unnamed_addr #2 align 2 {
  %this.addr = alloca %class.SdFatSPIDriver*, align 4
  store %class.SdFatSPIDriver* %this, %class.SdFatSPIDriver** %this.addr, align 4
  %this1 = load %class.SdFatSPIDriver*, %class.SdFatSPIDriver** %this.addr, align 4
  ret void
}

; Function Attrs: noinline nounwind optnone
define void @_ZN14SdFatSPIDriver10deactivateEv(%class.SdFatSPIDriver* %this) unnamed_addr #2 align 2 {
  %this.addr = alloca %class.SdFatSPIDriver*, align 4
  store %class.SdFatSPIDriver* %this, %class.SdFatSPIDriver** %this.addr, align 4
  %this1 = load %class.SdFatSPIDriver*, %class.SdFatSPIDriver** %this.addr, align 4
  ret void
}

; Function Attrs: noinline nounwind optnone
define zeroext i8 @_ZN14SdFatSPIDriver7receiveEv(%class.SdFatSPIDriver* %this) unnamed_addr #2 align 2 {
  %this.addr = alloca %class.SdFatSPIDriver*, align 4
  %buf = alloca i8, align 1
  %dummy = alloca i8, align 1
  store %class.SdFatSPIDriver* %this, %class.SdFatSPIDriver** %this.addr, align 4
  %this1 = load %class.SdFatSPIDriver*, %class.SdFatSPIDriver** %this.addr, align 4
  store i8 -1, i8* %dummy, align 1
  %1 = load i8, i8* %buf, align 1
  ret i8 %1
}

; Function Attrs: noinline optnone
define zeroext i8 @_ZN14SdFatSPIDriver7receiveEPhj(%class.SdFatSPIDriver* %this, i8* %buf, i32 %n) unnamed_addr #0 align 2 {
  %retval = alloca i8, align 1
  %this.addr = alloca %class.SdFatSPIDriver*, align 4
  %buf.addr = alloca i8*, align 4
  %n.addr = alloca i32, align 4
  %s = alloca i8, align 1
  store %class.SdFatSPIDriver* %this, %class.SdFatSPIDriver** %this.addr, align 4
  store i8* %buf, i8** %buf.addr, align 4
  store i32 %n, i32* %n.addr, align 4
  %this1 = load %class.SdFatSPIDriver*, %class.SdFatSPIDriver** %this.addr, align 4
  %1 = load i32, i32* %n.addr, align 4
  %cmp = icmp ule i32 %1, 16
  br i1 %cmp, label %2, label %7

; <label>:2:                                      ; preds = %0
  store i8 1, i8* %s, align 1
  %3 = load i8, i8* %s, align 1
  %tobool = icmp ne i8 %3, 0
  br i1 %tobool, label %4, label %6

; <label>:4:                                      ; preds = %2
  %5 = load i8, i8* %s, align 1
  store i8 %5, i8* %retval, align 1
  br label %13

; <label>:6:                                      ; preds = %2
  br label %7

; <label>:7:                                      ; preds = %6, %0
  %8 = load i32, i32* @GPIOB, align 4
  %9 = load i32, i32* @LL_GPIO_PIN_0, align 4
  call void @_Z20LL_GPIO_SetOutputPinjj(i32 %8, i32 %9)
  %xSema = getelementptr inbounds %class.SdFatSPIDriver, %class.SdFatSPIDriver* %this1, i32 0, i32 4
  %10 = load %struct.QueueDefinition*, %struct.QueueDefinition** %xSema, align 4
  %call = call i32 @xQueueSemaphoreTake(%struct.QueueDefinition* %10, i32 100)
  %11 = load i32, i32* @GPIOB, align 4
  %12 = load i32, i32* @LL_GPIO_PIN_0, align 4
  call void @_Z22LL_GPIO_ResetOutputPinjj(i32 %11, i32 %12)
  store i8 0, i8* %retval, align 1
  br label %13

; <label>:13:                                     ; preds = %7, %4
  %14 = load i8, i8* %retval, align 1
  ret i8 %14
}

declare i32 @xQueueSemaphoreTake(%struct.QueueDefinition*, i32) #1

declare void @_Z22LL_GPIO_ResetOutputPinjj(i32, i32) #1

; Function Attrs: noinline nounwind optnone
define void @_ZN14SdFatSPIDriver4sendEh(%class.SdFatSPIDriver* %this, i8 zeroext %data) unnamed_addr #2 align 2 {
  %this.addr = alloca %class.SdFatSPIDriver*, align 4
  %data.addr = alloca i8, align 1
  store %class.SdFatSPIDriver* %this, %class.SdFatSPIDriver** %this.addr, align 4
  store i8 %data, i8* %data.addr, align 1
  %this1 = load %class.SdFatSPIDriver*, %class.SdFatSPIDriver** %this.addr, align 4
  ret void
}

; Function Attrs: noinline optnone
define void @_ZN14SdFatSPIDriver4sendEPKhj(%class.SdFatSPIDriver* %this, i8* %buf, i32 %n) unnamed_addr #0 align 2 {
  %this.addr = alloca %class.SdFatSPIDriver*, align 4
  %buf.addr = alloca i8*, align 4
  %n.addr = alloca i32, align 4
  store %class.SdFatSPIDriver* %this, %class.SdFatSPIDriver** %this.addr, align 4
  store i8* %buf, i8** %buf.addr, align 4
  store i32 %n, i32* %n.addr, align 4
  %this1 = load %class.SdFatSPIDriver*, %class.SdFatSPIDriver** %this.addr, align 4
  %1 = load i32, i32* %n.addr, align 4
  %cmp = icmp ule i32 %1, 16
  br i1 %cmp, label %2, label %3

; <label>:2:                                      ; preds = %0
  br label %5

; <label>:3:                                      ; preds = %0
  %xSema = getelementptr inbounds %class.SdFatSPIDriver, %class.SdFatSPIDriver* %this1, i32 0, i32 4
  %4 = load %struct.QueueDefinition*, %struct.QueueDefinition** %xSema, align 4
  %call = call i32 @xQueueSemaphoreTake(%struct.QueueDefinition* %4, i32 100)
  br label %5

; <label>:5:                                      ; preds = %3, %2
  ret void
}

; Function Attrs: noinline optnone
define void @_ZN14SdFatSPIDriver6selectEv(%class.SdFatSPIDriver* %this) unnamed_addr #0 align 2 {
  %this.addr = alloca %class.SdFatSPIDriver*, align 4
  store %class.SdFatSPIDriver* %this, %class.SdFatSPIDriver** %this.addr, align 4
  %this1 = load %class.SdFatSPIDriver*, %class.SdFatSPIDriver** %this.addr, align 4
  %1 = load i32, i32* @GPIOB, align 4
  %2 = load i32, i32* @LL_GPIO_PIN_12, align 4
  call void @_Z22LL_GPIO_ResetOutputPinjj(i32 %1, i32 %2)
  ret void
}

; Function Attrs: noinline nounwind optnone
define void @_ZN14SdFatSPIDriver14setSpiSettingsERK11SPISettings(%class.SdFatSPIDriver* %this, %class.SPISettings* nonnull %spiSettings) unnamed_addr #2 align 2 {
  %this.addr = alloca %class.SdFatSPIDriver*, align 4
  %spiSettings.addr = alloca %class.SPISettings*, align 4
  store %class.SdFatSPIDriver* %this, %class.SdFatSPIDriver** %this.addr, align 4
  store %class.SPISettings* %spiSettings, %class.SPISettings** %spiSettings.addr, align 4
  %this1 = load %class.SdFatSPIDriver*, %class.SdFatSPIDriver** %this.addr, align 4
  ret void
}

; Function Attrs: noinline optnone
define void @_ZN14SdFatSPIDriver8unselectEv(%class.SdFatSPIDriver* %this) unnamed_addr #0 align 2 {
  %this.addr = alloca %class.SdFatSPIDriver*, align 4
  store %class.SdFatSPIDriver* %this, %class.SdFatSPIDriver** %this.addr, align 4
  %this1 = load %class.SdFatSPIDriver*, %class.SdFatSPIDriver** %this.addr, align 4
  %1 = load i32, i32* @GPIOB, align 4
  %2 = load i32, i32* @LL_GPIO_PIN_12, align 4
  call void @_Z20LL_GPIO_SetOutputPinjj(i32 %1, i32 %2)
  ret void
}

; Function Attrs: noinline optnone
define void @_ZN14SdFatSPIDriver22dmaTransferCompletedCBEv(%class.SdFatSPIDriver* %this) #0 align 2 {
  %this.addr = alloca %class.SdFatSPIDriver*, align 4
  %xHigherPriorityTaskWoken = alloca i32, align 4
  store %class.SdFatSPIDriver* %this, %class.SdFatSPIDriver** %this.addr, align 4
  %this1 = load %class.SdFatSPIDriver*, %class.SdFatSPIDriver** %this.addr, align 4
  %xSema = getelementptr inbounds %class.SdFatSPIDriver, %class.SdFatSPIDriver* %this1, i32 0, i32 4
  %1 = load %struct.QueueDefinition*, %struct.QueueDefinition** %xSema, align 4
  %call = call i32 @xQueueGiveFromISR(%struct.QueueDefinition* %1, i32* %xHigherPriorityTaskWoken)
  %2 = load i32, i32* %xHigherPriorityTaskWoken, align 4
  %cmp = icmp ne i32 %2, 0
  br i1 %cmp, label %3, label %4

; <label>:3:                                      ; preds = %0
  store volatile i32 268435456, i32* inttoptr (i32 -536810236 to i32*), align 4
  call void asm sideeffect "dsb", "~{dirflag},~{fpsr},~{flags}"() #3, !srcloc !5
  call void asm sideeffect "isb", "~{dirflag},~{fpsr},~{flags}"() #3, !srcloc !6
  br label %4

; <label>:4:                                      ; preds = %3, %0
  ret void
}

declare i32 @xQueueGiveFromISR(%struct.QueueDefinition*, i32*) #1

; Function Attrs: noinline nounwind optnone
define void @DMA1_Channel2_IRQHandler() #2 {
  ret void
}

; Function Attrs: noinline nounwind optnone
define void @DMA1_Channel3_IRQHandler() #2 {
  ret void
}

attributes #0 = { noinline optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"NumRegisterParameters", i32 0}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
!3 = !{i32 428243, i32 428276, i32 428312, i32 428339}
!4 = !{i32 429164}
!5 = !{i32 -2146759848}
!6 = !{i32 -2146759808}
