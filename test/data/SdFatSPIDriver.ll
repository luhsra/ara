; ModuleID = 'SdFatSPIDriver.cpp'
source_filename = "SdFatSPIDriver.cpp"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

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
@SPI2 = global i8* null, align 8
@debugEnabled = global i8 0, align 1
@_ZTV14SdFatSPIDriver = unnamed_addr constant { [12 x i8*] } { [12 x i8*] [i8* null, i8* bitcast ({ i8*, i8* }* @_ZTI14SdFatSPIDriver to i8*), i8* bitcast (void (%class.SdFatSPIDriver*)* @_ZN14SdFatSPIDriver8activateEv to i8*), i8* bitcast (void (%class.SdFatSPIDriver*, i8)* @_ZN14SdFatSPIDriver5beginEh to i8*), i8* bitcast (void (%class.SdFatSPIDriver*)* @_ZN14SdFatSPIDriver10deactivateEv to i8*), i8* bitcast (i8 (%class.SdFatSPIDriver*)* @_ZN14SdFatSPIDriver7receiveEv to i8*), i8* bitcast (i8 (%class.SdFatSPIDriver*, i8*, i64)* @_ZN14SdFatSPIDriver7receiveEPhm to i8*), i8* bitcast (void (%class.SdFatSPIDriver*, i8)* @_ZN14SdFatSPIDriver4sendEh to i8*), i8* bitcast (void (%class.SdFatSPIDriver*, i8*, i64)* @_ZN14SdFatSPIDriver4sendEPKhm to i8*), i8* bitcast (void (%class.SdFatSPIDriver*)* @_ZN14SdFatSPIDriver6selectEv to i8*), i8* bitcast (void (%class.SdFatSPIDriver*, %class.SPISettings*)* @_ZN14SdFatSPIDriver14setSpiSettingsERK11SPISettings to i8*), i8* bitcast (void (%class.SdFatSPIDriver*)* @_ZN14SdFatSPIDriver8unselectEv to i8*)] }, align 8
@_ZTVN10__cxxabiv117__class_type_infoE = external global i8*
@_ZTS14SdFatSPIDriver = constant [17 x i8] c"14SdFatSPIDriver\00"
@_ZTI14SdFatSPIDriver = constant { i8*, i8* } { i8* bitcast (i8** getelementptr inbounds (i8*, i8** @_ZTVN10__cxxabiv117__class_type_infoE, i64 2) to i8*), i8* getelementptr inbounds ([17 x i8], [17 x i8]* @_ZTS14SdFatSPIDriver, i32 0, i32 0) }

; Function Attrs: noinline optnone uwtable
define void @_ZN14SdFatSPIDriver5beginEh(%class.SdFatSPIDriver*, i8 zeroext) unnamed_addr #0 align 2 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca %class.SdFatSPIDriver*, align 8
  %6 = alloca i8, align 1
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  %10 = alloca i32, align 4
  store %class.SdFatSPIDriver* %0, %class.SdFatSPIDriver** %5, align 8
  store i8 %1, i8* %6, align 1
  %11 = load %class.SdFatSPIDriver*, %class.SdFatSPIDriver** %5, align 8
  %12 = call i32 asm sideeffect "\09mov $0, $1\09\09\09\09\09\09\09\09\09\09\09\09\0A\09msr basepri, $0\09\09\09\09\09\09\09\09\09\09\09\0A\09isb\09\09\09\09\09\09\09\09\09\09\09\09\09\09\0A\09dsb\09\09\09\09\09\09\09\09\09\09\09\09\09\09\0A", "=r,i,~{dirflag},~{fpsr},~{flags}"(i32 80) #3, !srcloc !2
  store i32 %12, i32* %4, align 4
  %13 = call %struct.QueueDefinition* @xQueueGenericCreate(i64 1, i64 0, i8 zeroext 3)
  %14 = getelementptr inbounds %class.SdFatSPIDriver, %class.SdFatSPIDriver* %11, i32 0, i32 4
  store %struct.QueueDefinition* %13, %struct.QueueDefinition** %14, align 8
  store i32 0, i32* %3, align 4
  %15 = load i32, i32* %3, align 4
  call void asm sideeffect "\09msr basepri, $0\09", "r,~{dirflag},~{fpsr},~{flags}"(i32 %15) #3, !srcloc !3
  %16 = load i32, i32* @GPIOB, align 4
  %17 = load i32, i32* @LL_GPIO_PIN_1, align 4
  %18 = load i32, i32* @LL_GPIO_MODE_OUTPUT, align 4
  call void @_Z18LL_GPIO_SetPinModejjj(i32 %16, i32 %17, i32 %18)
  %19 = load i32, i32* @GPIOB, align 4
  %20 = load i32, i32* @LL_GPIO_PIN_1, align 4
  %21 = load i32, i32* @LL_GPIO_OUTPUT_PUSHPULL, align 4
  call void @_Z24LL_GPIO_SetPinOutputTypejjj(i32 %19, i32 %20, i32 %21)
  %22 = load i32, i32* @GPIOB, align 4
  %23 = load i32, i32* @LL_GPIO_PIN_1, align 4
  %24 = load i32, i32* @LL_GPIO_SPEED_FREQ_HIGH, align 4
  call void @_Z19LL_GPIO_SetPinSpeedjjj(i32 %22, i32 %23, i32 %24)
  %25 = load i32, i32* @GPIOB, align 4
  %26 = load i32, i32* @LL_GPIO_PIN_0, align 4
  %27 = load i32, i32* @LL_GPIO_MODE_OUTPUT, align 4
  call void @_Z18LL_GPIO_SetPinModejjj(i32 %25, i32 %26, i32 %27)
  %28 = load i32, i32* @GPIOB, align 4
  %29 = load i32, i32* @LL_GPIO_PIN_0, align 4
  %30 = load i32, i32* @LL_GPIO_OUTPUT_PUSHPULL, align 4
  call void @_Z24LL_GPIO_SetPinOutputTypejjj(i32 %28, i32 %29, i32 %30)
  %31 = load i32, i32* @GPIOB, align 4
  %32 = load i32, i32* @LL_GPIO_PIN_0, align 4
  %33 = load i32, i32* @LL_GPIO_SPEED_FREQ_HIGH, align 4
  call void @_Z19LL_GPIO_SetPinSpeedjjj(i32 %31, i32 %32, i32 %33)
  %34 = load i32, i32* @LL_GPIO_PIN_15, align 4
  store i32 %34, i32* %7, align 4
  %35 = load i32, i32* @GPIOB, align 4
  %36 = load i32, i32* %7, align 4
  %37 = load i32, i32* @LL_GPIO_MODE_ALTERNATE, align 4
  call void @_Z18LL_GPIO_SetPinModejjj(i32 %35, i32 %36, i32 %37)
  %38 = load i32, i32* @GPIOB, align 4
  %39 = load i32, i32* %7, align 4
  %40 = load i32, i32* @LL_GPIO_OUTPUT_PUSHPULL, align 4
  call void @_Z24LL_GPIO_SetPinOutputTypejjj(i32 %38, i32 %39, i32 %40)
  %41 = load i32, i32* @GPIOB, align 4
  %42 = load i32, i32* %7, align 4
  %43 = load i32, i32* @LL_GPIO_SPEED_FREQ_HIGH, align 4
  call void @_Z19LL_GPIO_SetPinSpeedjjj(i32 %41, i32 %42, i32 %43)
  %44 = load i32, i32* @LL_GPIO_PIN_14, align 4
  store i32 %44, i32* %8, align 4
  %45 = load i32, i32* @GPIOB, align 4
  %46 = load i32, i32* %8, align 4
  %47 = load i32, i32* @LL_GPIO_MODE_INPUT, align 4
  call void @_Z18LL_GPIO_SetPinModejjj(i32 %45, i32 %46, i32 %47)
  %48 = load i32, i32* @LL_GPIO_PIN_13, align 4
  store i32 %48, i32* %9, align 4
  %49 = load i32, i32* @GPIOB, align 4
  %50 = load i32, i32* %9, align 4
  %51 = load i32, i32* @LL_GPIO_MODE_ALTERNATE, align 4
  call void @_Z18LL_GPIO_SetPinModejjj(i32 %49, i32 %50, i32 %51)
  %52 = load i32, i32* @GPIOB, align 4
  %53 = load i32, i32* %9, align 4
  %54 = load i32, i32* @LL_GPIO_OUTPUT_PUSHPULL, align 4
  call void @_Z24LL_GPIO_SetPinOutputTypejjj(i32 %52, i32 %53, i32 %54)
  %55 = load i32, i32* @GPIOB, align 4
  %56 = load i32, i32* %9, align 4
  %57 = load i32, i32* @LL_GPIO_SPEED_FREQ_HIGH, align 4
  call void @_Z19LL_GPIO_SetPinSpeedjjj(i32 %55, i32 %56, i32 %57)
  %58 = load i32, i32* @LL_GPIO_PIN_12, align 4
  store i32 %58, i32* %10, align 4
  %59 = load i32, i32* @GPIOB, align 4
  %60 = load i32, i32* %10, align 4
  %61 = load i32, i32* @LL_GPIO_MODE_OUTPUT, align 4
  call void @_Z18LL_GPIO_SetPinModejjj(i32 %59, i32 %60, i32 %61)
  %62 = load i32, i32* @GPIOB, align 4
  %63 = load i32, i32* %10, align 4
  %64 = load i32, i32* @LL_GPIO_OUTPUT_PUSHPULL, align 4
  call void @_Z24LL_GPIO_SetPinOutputTypejjj(i32 %62, i32 %63, i32 %64)
  %65 = load i32, i32* @GPIOB, align 4
  %66 = load i32, i32* %10, align 4
  %67 = load i32, i32* @LL_GPIO_SPEED_FREQ_MEDIUM, align 4
  call void @_Z19LL_GPIO_SetPinSpeedjjj(i32 %65, i32 %66, i32 %67)
  %68 = load i32, i32* @GPIOB, align 4
  %69 = load i32, i32* %10, align 4
  call void @_Z20LL_GPIO_SetOutputPinjj(i32 %68, i32 %69)
  ret void
}

declare %struct.QueueDefinition* @xQueueGenericCreate(i64, i64, i8 zeroext) #1

declare void @_Z18LL_GPIO_SetPinModejjj(i32, i32, i32) #1

declare void @_Z24LL_GPIO_SetPinOutputTypejjj(i32, i32, i32) #1

declare void @_Z19LL_GPIO_SetPinSpeedjjj(i32, i32, i32) #1

declare void @_Z20LL_GPIO_SetOutputPinjj(i32, i32) #1

; Function Attrs: noinline nounwind optnone uwtable
define void @_ZN14SdFatSPIDriver8activateEv(%class.SdFatSPIDriver*) unnamed_addr #2 align 2 {
  %2 = alloca %class.SdFatSPIDriver*, align 8
  store %class.SdFatSPIDriver* %0, %class.SdFatSPIDriver** %2, align 8
  %3 = load %class.SdFatSPIDriver*, %class.SdFatSPIDriver** %2, align 8
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define void @_ZN14SdFatSPIDriver10deactivateEv(%class.SdFatSPIDriver*) unnamed_addr #2 align 2 {
  %2 = alloca %class.SdFatSPIDriver*, align 8
  store %class.SdFatSPIDriver* %0, %class.SdFatSPIDriver** %2, align 8
  %3 = load %class.SdFatSPIDriver*, %class.SdFatSPIDriver** %2, align 8
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define zeroext i8 @_ZN14SdFatSPIDriver7receiveEv(%class.SdFatSPIDriver*) unnamed_addr #2 align 2 {
  %2 = alloca %class.SdFatSPIDriver*, align 8
  %3 = alloca i8, align 1
  %4 = alloca i8, align 1
  store %class.SdFatSPIDriver* %0, %class.SdFatSPIDriver** %2, align 8
  %5 = load %class.SdFatSPIDriver*, %class.SdFatSPIDriver** %2, align 8
  store i8 -1, i8* %4, align 1
  %6 = load i8, i8* %3, align 1
  ret i8 %6
}

; Function Attrs: noinline optnone uwtable
define zeroext i8 @_ZN14SdFatSPIDriver7receiveEPhm(%class.SdFatSPIDriver*, i8*, i64) unnamed_addr #0 align 2 {
  %4 = alloca i8, align 1
  %5 = alloca %class.SdFatSPIDriver*, align 8
  %6 = alloca i8*, align 8
  %7 = alloca i64, align 8
  %8 = alloca i8, align 1
  store %class.SdFatSPIDriver* %0, %class.SdFatSPIDriver** %5, align 8
  store i8* %1, i8** %6, align 8
  store i64 %2, i64* %7, align 8
  %9 = load %class.SdFatSPIDriver*, %class.SdFatSPIDriver** %5, align 8
  %10 = load i64, i64* %7, align 8
  %11 = icmp ule i64 %10, 16
  br i1 %11, label %12, label %18

; <label>:12:                                     ; preds = %3
  store i8 1, i8* %8, align 1
  %13 = load i8, i8* %8, align 1
  %14 = icmp ne i8 %13, 0
  br i1 %14, label %15, label %17

; <label>:15:                                     ; preds = %12
  %16 = load i8, i8* %8, align 1
  store i8 %16, i8* %4, align 1
  br label %26

; <label>:17:                                     ; preds = %12
  br label %18

; <label>:18:                                     ; preds = %17, %3
  %19 = load i32, i32* @GPIOB, align 4
  %20 = load i32, i32* @LL_GPIO_PIN_0, align 4
  call void @_Z20LL_GPIO_SetOutputPinjj(i32 %19, i32 %20)
  %21 = getelementptr inbounds %class.SdFatSPIDriver, %class.SdFatSPIDriver* %9, i32 0, i32 4
  %22 = load %struct.QueueDefinition*, %struct.QueueDefinition** %21, align 8
  %23 = call i64 @xQueueSemaphoreTake(%struct.QueueDefinition* %22, i32 100)
  %24 = load i32, i32* @GPIOB, align 4
  %25 = load i32, i32* @LL_GPIO_PIN_0, align 4
  call void @_Z22LL_GPIO_ResetOutputPinjj(i32 %24, i32 %25)
  store i8 0, i8* %4, align 1
  br label %26

; <label>:26:                                     ; preds = %18, %15
  %27 = load i8, i8* %4, align 1
  ret i8 %27
}

declare i64 @xQueueSemaphoreTake(%struct.QueueDefinition*, i32) #1

declare void @_Z22LL_GPIO_ResetOutputPinjj(i32, i32) #1

; Function Attrs: noinline nounwind optnone uwtable
define void @_ZN14SdFatSPIDriver4sendEh(%class.SdFatSPIDriver*, i8 zeroext) unnamed_addr #2 align 2 {
  %3 = alloca %class.SdFatSPIDriver*, align 8
  %4 = alloca i8, align 1
  store %class.SdFatSPIDriver* %0, %class.SdFatSPIDriver** %3, align 8
  store i8 %1, i8* %4, align 1
  %5 = load %class.SdFatSPIDriver*, %class.SdFatSPIDriver** %3, align 8
  ret void
}

; Function Attrs: noinline optnone uwtable
define void @_ZN14SdFatSPIDriver4sendEPKhm(%class.SdFatSPIDriver*, i8*, i64) unnamed_addr #0 align 2 {
  %4 = alloca %class.SdFatSPIDriver*, align 8
  %5 = alloca i8*, align 8
  %6 = alloca i64, align 8
  store %class.SdFatSPIDriver* %0, %class.SdFatSPIDriver** %4, align 8
  store i8* %1, i8** %5, align 8
  store i64 %2, i64* %6, align 8
  %7 = load %class.SdFatSPIDriver*, %class.SdFatSPIDriver** %4, align 8
  %8 = load i64, i64* %6, align 8
  %9 = icmp ule i64 %8, 16
  br i1 %9, label %10, label %11

; <label>:10:                                     ; preds = %3
  br label %15

; <label>:11:                                     ; preds = %3
  %12 = getelementptr inbounds %class.SdFatSPIDriver, %class.SdFatSPIDriver* %7, i32 0, i32 4
  %13 = load %struct.QueueDefinition*, %struct.QueueDefinition** %12, align 8
  %14 = call i64 @xQueueSemaphoreTake(%struct.QueueDefinition* %13, i32 100)
  br label %15

; <label>:15:                                     ; preds = %11, %10
  ret void
}

; Function Attrs: noinline optnone uwtable
define void @_ZN14SdFatSPIDriver6selectEv(%class.SdFatSPIDriver*) unnamed_addr #0 align 2 {
  %2 = alloca %class.SdFatSPIDriver*, align 8
  store %class.SdFatSPIDriver* %0, %class.SdFatSPIDriver** %2, align 8
  %3 = load %class.SdFatSPIDriver*, %class.SdFatSPIDriver** %2, align 8
  %4 = load i32, i32* @GPIOB, align 4
  %5 = load i32, i32* @LL_GPIO_PIN_12, align 4
  call void @_Z22LL_GPIO_ResetOutputPinjj(i32 %4, i32 %5)
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define void @_ZN14SdFatSPIDriver14setSpiSettingsERK11SPISettings(%class.SdFatSPIDriver*, %class.SPISettings* nonnull) unnamed_addr #2 align 2 {
  %3 = alloca %class.SdFatSPIDriver*, align 8
  %4 = alloca %class.SPISettings*, align 8
  store %class.SdFatSPIDriver* %0, %class.SdFatSPIDriver** %3, align 8
  store %class.SPISettings* %1, %class.SPISettings** %4, align 8
  %5 = load %class.SdFatSPIDriver*, %class.SdFatSPIDriver** %3, align 8
  ret void
}

; Function Attrs: noinline optnone uwtable
define void @_ZN14SdFatSPIDriver8unselectEv(%class.SdFatSPIDriver*) unnamed_addr #0 align 2 {
  %2 = alloca %class.SdFatSPIDriver*, align 8
  store %class.SdFatSPIDriver* %0, %class.SdFatSPIDriver** %2, align 8
  %3 = load %class.SdFatSPIDriver*, %class.SdFatSPIDriver** %2, align 8
  %4 = load i32, i32* @GPIOB, align 4
  %5 = load i32, i32* @LL_GPIO_PIN_12, align 4
  call void @_Z20LL_GPIO_SetOutputPinjj(i32 %4, i32 %5)
  ret void
}

; Function Attrs: noinline optnone uwtable
define void @_ZN14SdFatSPIDriver22dmaTransferCompletedCBEv(%class.SdFatSPIDriver*) #0 align 2 {
  %2 = alloca %class.SdFatSPIDriver*, align 8
  %3 = alloca i64, align 8
  store %class.SdFatSPIDriver* %0, %class.SdFatSPIDriver** %2, align 8
  %4 = load %class.SdFatSPIDriver*, %class.SdFatSPIDriver** %2, align 8
  %5 = getelementptr inbounds %class.SdFatSPIDriver, %class.SdFatSPIDriver* %4, i32 0, i32 4
  %6 = load %struct.QueueDefinition*, %struct.QueueDefinition** %5, align 8
  %7 = call i64 @xQueueGiveFromISR(%struct.QueueDefinition* %6, i64* %3)
  %8 = load i64, i64* %3, align 8
  %9 = icmp ne i64 %8, 0
  br i1 %9, label %10, label %11

; <label>:10:                                     ; preds = %1
  store volatile i32 268435456, i32* inttoptr (i64 3758157060 to i32*), align 4
  call void asm sideeffect "dsb", "~{dirflag},~{fpsr},~{flags}"() #3, !srcloc !4
  call void asm sideeffect "isb", "~{dirflag},~{fpsr},~{flags}"() #3, !srcloc !5
  br label %11

; <label>:11:                                     ; preds = %10, %1
  ret void
}

declare i64 @xQueueGiveFromISR(%struct.QueueDefinition*, i64*) #1

; Function Attrs: noinline nounwind optnone uwtable
define void @DMA1_Channel2_IRQHandler() #2 {
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define void @DMA1_Channel3_IRQHandler() #2 {
  ret void
}

attributes #0 = { noinline optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
!2 = !{i32 427965, i32 427998, i32 428034, i32 428061}
!3 = !{i32 428886}
!4 = !{i32 -2146760126}
!5 = !{i32 -2146760086}
