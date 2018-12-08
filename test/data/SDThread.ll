; ModuleID = '../../../GPSLogger/Src/SDThread.cpp'
source_filename = "../../../GPSLogger/Src/SDThread.cpp"
target datalayout = "e-m:e-p:32:32-f64:32:64-f80:32-n8:16:32-S128"
target triple = "i386-pc-linux-gnu"

%class.SdFatSPIDriver = type { i32 (...)**, %struct.DMA_HandleTypeDef, %struct.DMA_HandleTypeDef, %struct.DMA_HandleTypeDef, %struct.QueueDefinition* }
%struct.DMA_HandleTypeDef = type { i8*, i32, i32, i32, i8*, void (%struct.__DMA_HandleTypeDef*)*, void (%struct.__DMA_HandleTypeDef*)*, void (%struct.__DMA_HandleTypeDef*)*, void (%struct.__DMA_HandleTypeDef*)*, void (%struct.__DMA_HandleTypeDef*)*, void (%struct.__DMA_HandleTypeDef*)*, i32, i32, i32 }
%struct.__DMA_HandleTypeDef = type opaque
%struct.QueueDefinition = type opaque
%class.SdFat = type { i8 }
%class.FatFile = type { i8 }
%struct.SDMessage = type { i32, i16, %union.anon }
%union.anon = type { %struct.RawGPSData }
%struct.RawGPSData = type { i8, [81 x i8] }
%class.CharWriter = type { i32 (...)** }

$_ZN14SdFatSPIDriverC2Ev = comdat any

$_ZN5SdFatC2EP14SdFatSPIDriver = comdat any

$_ZN5SdFat5beginEj = comdat any

$_ZN10CharWriter5writeEPKc = comdat any

$_ZN10CharWriter5writeEc = comdat any

$_ZTV10CharWriter = comdat any

$_ZTS10CharWriter = comdat any

$_ZTI10CharWriter = comdat any

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
@_ZTV10CharWriter = linkonce_odr unnamed_addr constant { [4 x i8*] } { [4 x i8*] [i8* null, i8* bitcast ({ i8*, i8* }* @_ZTI10CharWriter to i8*), i8* bitcast (i32 (%class.CharWriter*, i8*)* @_ZN10CharWriter5writeEPKc to i8*), i8* bitcast (i32 (%class.CharWriter*, i8)* @_ZN10CharWriter5writeEc to i8*)] }, comdat, align 4
@Serial = global { i8** } { i8** getelementptr inbounds ({ [4 x i8*] }, { [4 x i8*] }* @_ZTV10CharWriter, i32 0, inrange i32 0, i32 2) }, align 4
@spiDriver = global %class.SdFatSPIDriver zeroinitializer, align 4
@SD = global %class.SdFat zeroinitializer, align 1
@rawDataFile = global %class.FatFile zeroinitializer, align 1
@bulkFile = global %class.FatFile zeroinitializer, align 1
@sdQueue = global %struct.QueueDefinition* null, align 4
@rawGPSDataBuf = global %struct.SDMessage zeroinitializer, align 4
@msgIdx = global i16 0, align 2
@sd_buf = global [512 x i8] zeroinitializer, align 1
@.str = private unnamed_addr constant [25 x i8] c"Receive   GPS Data: %s\0D\0A\00", align 1
@_ZTVN10__cxxabiv117__class_type_infoE = external global i8*
@_ZTS10CharWriter = linkonce_odr constant [13 x i8] c"10CharWriter\00", comdat
@_ZTI10CharWriter = linkonce_odr constant { i8*, i8* } { i8* bitcast (i8** getelementptr inbounds (i8*, i8** @_ZTVN10__cxxabiv117__class_type_infoE, i32 2) to i8*), i8* getelementptr inbounds ([13 x i8], [13 x i8]* @_ZTS10CharWriter, i32 0, i32 0) }, comdat
@_ZTV14SdFatSPIDriver = external unnamed_addr constant { [12 x i8*] }
@.str.2 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* @_GLOBAL__sub_I_SDThread.cpp, i8* null }]

; Function Attrs: noinline
define internal void @__cxx_global_var_init() #0 section ".text.startup" {
  call void @_ZN14SdFatSPIDriverC2Ev(%class.SdFatSPIDriver* @spiDriver) #5
  ret void
}

; Function Attrs: noinline nounwind optnone
define linkonce_odr void @_ZN14SdFatSPIDriverC2Ev(%class.SdFatSPIDriver* %this) unnamed_addr #1 comdat align 2 {
  %this.addr = alloca %class.SdFatSPIDriver*, align 4
  store %class.SdFatSPIDriver* %this, %class.SdFatSPIDriver** %this.addr, align 4
  %this1 = load %class.SdFatSPIDriver*, %class.SdFatSPIDriver** %this.addr, align 4
  %1 = bitcast %class.SdFatSPIDriver* %this1 to i32 (...)***
  store i32 (...)** bitcast (i8** getelementptr inbounds ({ [12 x i8*] }, { [12 x i8*] }* @_ZTV14SdFatSPIDriver, i32 0, inrange i32 0, i32 2) to i32 (...)**), i32 (...)*** %1, align 4
  %spiHandle = getelementptr inbounds %class.SdFatSPIDriver, %class.SdFatSPIDriver* %this1, i32 0, i32 1
  %dmaHandleRx = getelementptr inbounds %class.SdFatSPIDriver, %class.SdFatSPIDriver* %this1, i32 0, i32 2
  %dmaHandleTx = getelementptr inbounds %class.SdFatSPIDriver, %class.SdFatSPIDriver* %this1, i32 0, i32 3
  %xSema = getelementptr inbounds %class.SdFatSPIDriver, %class.SdFatSPIDriver* %this1, i32 0, i32 4
  store %struct.QueueDefinition* null, %struct.QueueDefinition** %xSema, align 4
  ret void
}

; Function Attrs: noinline
define internal void @__cxx_global_var_init.1() #0 section ".text.startup" {
  call void @_ZN5SdFatC2EP14SdFatSPIDriver(%class.SdFat* @SD, %class.SdFatSPIDriver* @spiDriver)
  ret void
}

; Function Attrs: noinline nounwind optnone
define linkonce_odr void @_ZN5SdFatC2EP14SdFatSPIDriver(%class.SdFat* %this, %class.SdFatSPIDriver* %sd) unnamed_addr #1 comdat align 2 {
  %this.addr = alloca %class.SdFat*, align 4
  %sd.addr = alloca %class.SdFatSPIDriver*, align 4
  store %class.SdFat* %this, %class.SdFat** %this.addr, align 4
  store %class.SdFatSPIDriver* %sd, %class.SdFatSPIDriver** %sd.addr, align 4
  %this1 = load %class.SdFat*, %class.SdFat** %this.addr, align 4
  ret void
}

; Function Attrs: noinline nounwind optnone
define i8* @_Z19requestRawGPSBufferv() #1 {
  ret i8* getelementptr inbounds (%struct.SDMessage, %struct.SDMessage* @rawGPSDataBuf, i32 0, i32 2, i32 0, i32 1, i32 0)
}

; Function Attrs: noinline optnone
define void @_Z13ackRawGPSDatah(i8 zeroext %len) #2 {
  %len.addr = alloca i8, align 1
  store i8 %len, i8* %len.addr, align 1
  store i32 0, i32* getelementptr inbounds (%struct.SDMessage, %struct.SDMessage* @rawGPSDataBuf, i32 0, i32 0), align 4
  %1 = load i8, i8* %len.addr, align 1
  store i8 %1, i8* getelementptr inbounds (%struct.SDMessage, %struct.SDMessage* @rawGPSDataBuf, i32 0, i32 2, i32 0, i32 0), align 2
  %2 = load i16, i16* @msgIdx, align 2
  %inc = add i16 %2, 1
  store i16 %inc, i16* @msgIdx, align 2
  store i16 %2, i16* getelementptr inbounds (%struct.SDMessage, %struct.SDMessage* @rawGPSDataBuf, i32 0, i32 1), align 4
  %3 = load %struct.QueueDefinition*, %struct.QueueDefinition** @sdQueue, align 4
  %call = call i32 @xQueueGenericSend(%struct.QueueDefinition* %3, i8* bitcast (%struct.SDMessage* @rawGPSDataBuf to i8*), i32 10, i32 0)
  ret void
}

declare i32 @xQueueGenericSend(%struct.QueueDefinition*, i8*, i32, i32) #3

; Function Attrs: noinline optnone
define zeroext i1 @_Z10initSDCardv() #2 {
  %retval = alloca i1, align 1
  %errno = alloca i32, align 4
  %call = call i32 @_ZN5SdFat5beginEj(%class.SdFat* @SD, i32 100)
  store i32 %call, i32* %errno, align 4
  %1 = load i32, i32* %errno, align 4
  %tobool = icmp ne i32 %1, 0
  br i1 %tobool, label %2, label %3

; <label>:2:                                      ; preds = %0
  store i1 false, i1* %retval, align 1
  br label %4

; <label>:3:                                      ; preds = %0
  store i1 true, i1* %retval, align 1
  br label %4

; <label>:4:                                      ; preds = %3, %2
  %5 = load i1, i1* %retval, align 1
  ret i1 %5
}

; Function Attrs: noinline nounwind optnone
define linkonce_odr i32 @_ZN5SdFat5beginEj(%class.SdFat* %this, i32 %tmp) #1 comdat align 2 {
  %this.addr = alloca %class.SdFat*, align 4
  %tmp.addr = alloca i32, align 4
  store %class.SdFat* %this, %class.SdFat** %this.addr, align 4
  store i32 %tmp, i32* %tmp.addr, align 4
  %this1 = load %class.SdFat*, %class.SdFat** %this.addr, align 4
  %1 = load i32, i32* %tmp.addr, align 4
  ret i32 %1
}

; Function Attrs: noinline optnone
define void @_Z11saveRawDataRK9SDMessage(%struct.SDMessage* dereferenceable(88) %msg) #2 {
  %msg.addr = alloca %struct.SDMessage*, align 4
  store %struct.SDMessage* %msg, %struct.SDMessage** %msg.addr, align 4
  %1 = load i8, i8* getelementptr inbounds (%struct.SDMessage, %struct.SDMessage* @rawGPSDataBuf, i32 0, i32 2, i32 0, i32 0), align 2
  call void @_ZN7FatFile5writeEPch(%class.FatFile* @rawDataFile, i8* getelementptr inbounds (%struct.SDMessage, %struct.SDMessage* @rawGPSDataBuf, i32 0, i32 2, i32 0, i32 1, i32 0), i8 zeroext %1)
  ret void
}

declare void @_ZN7FatFile5writeEPch(%class.FatFile*, i8*, i8 zeroext) #3

; Function Attrs: noinline optnone
define void @_Z16runSDMessageLoopv() #2 {
  %q = alloca i16, align 2
  %i = alloca i32, align 4
  %prev = alloca i32, align 4
  %msg = alloca %struct.SDMessage, align 4
  %cur = alloca i32, align 4
  store i16 0, i16* %q, align 2
  br label %1

; <label>:1:                                      ; preds = %6, %0
  %2 = load i16, i16* %q, align 2
  %conv = zext i16 %2 to i32
  %cmp = icmp slt i32 %conv, 512
  br i1 %cmp, label %3, label %8

; <label>:3:                                      ; preds = %1
  %4 = load i16, i16* %q, align 2
  %conv1 = zext i16 %4 to i32
  %and = and i32 %conv1, 255
  %conv2 = trunc i32 %and to i8
  %5 = load i16, i16* %q, align 2
  %idxprom = zext i16 %5 to i32
  %arrayidx = getelementptr inbounds [512 x i8], [512 x i8]* @sd_buf, i32 0, i32 %idxprom
  store i8 %conv2, i8* %arrayidx, align 1
  br label %6

; <label>:6:                                      ; preds = %3
  %7 = load i16, i16* %q, align 2
  %inc = add i16 %7, 1
  store i16 %inc, i16* %q, align 2
  br label %1

; <label>:8:                                      ; preds = %1
  store i32 0, i32* %i, align 4
  %call = call i32 @_Z11HAL_GetTickv()
  store i32 %call, i32* %prev, align 4
  br label %9

; <label>:9:                                      ; preds = %8, %23
  %10 = load %struct.QueueDefinition*, %struct.QueueDefinition** @sdQueue, align 4
  %11 = bitcast %struct.SDMessage* %msg to i8*
  %call3 = call i32 @xQueueReceive(%struct.QueueDefinition* %10, i8* %11, i32 50)
  %tobool = icmp ne i32 %call3, 0
  br i1 %tobool, label %12, label %18

; <label>:12:                                     ; preds = %9
  %messageType = getelementptr inbounds %struct.SDMessage, %struct.SDMessage* %msg, i32 0, i32 0
  %13 = load i32, i32* %messageType, align 4
  switch i32 %13, label %16 [
    i32 0, label %14
  ]

; <label>:14:                                     ; preds = %12
  %15 = getelementptr inbounds %struct.SDMessage, %struct.SDMessage* %msg, i32 0, i32 2
  %rawData = bitcast %union.anon* %15 to %struct.RawGPSData*
  %rawDataBuf = getelementptr inbounds %struct.RawGPSData, %struct.RawGPSData* %rawData, i32 0, i32 1
  %arraydecay = getelementptr inbounds [81 x i8], [81 x i8]* %rawDataBuf, i32 0, i32 0
  call void (i8*, ...) @serialDebugWrite(i8* getelementptr inbounds ([25 x i8], [25 x i8]* @.str, i32 0, i32 0), i8* %arraydecay)
  br label %17

; <label>:16:                                     ; preds = %12
  br label %17

; <label>:17:                                     ; preds = %16, %14
  br label %18

; <label>:18:                                     ; preds = %17, %9
  %19 = load i32, i32* %i, align 4
  %inc4 = add i32 %19, 1
  store i32 %inc4, i32* %i, align 4
  %call5 = call i32 @_Z11HAL_GetTickv()
  store i32 %call5, i32* %cur, align 4
  %20 = load i32, i32* %cur, align 4
  %21 = load i32, i32* %prev, align 4
  %sub = sub i32 %20, %21
  %cmp6 = icmp uge i32 %sub, 1000
  br i1 %cmp6, label %22, label %23

; <label>:22:                                     ; preds = %18
  store i32 0, i32* %i, align 4
  %call7 = call i32 @_Z11HAL_GetTickv()
  store i32 %call7, i32* %prev, align 4
  br label %23

; <label>:23:                                     ; preds = %22, %18
  br label %9
                                                  ; No predecessors!
  ret void
}

declare i32 @_Z11HAL_GetTickv() #3

declare i32 @xQueueReceive(%struct.QueueDefinition*, i8*, i32) #3

declare void @serialDebugWrite(i8*, ...) #3

; Function Attrs: noinline optnone
define void @_Z12initSDThreadv() #2 {
  %call = call %struct.QueueDefinition* @xQueueGenericCreate(i32 5, i32 88, i8 zeroext 0)
  store %struct.QueueDefinition* %call, %struct.QueueDefinition** @sdQueue, align 4
  ret void
}

declare %struct.QueueDefinition* @xQueueGenericCreate(i32, i32, i8 zeroext) #3

; Function Attrs: noinline optnone
define void @_Z9vSDThreadPv(i8* %pvParameters) #2 {
  %pvParameters.addr = alloca i8*, align 4
  store i8* %pvParameters, i8** %pvParameters.addr, align 4
  call void @_Z12initSDThreadv()
  br label %1

; <label>:1:                                      ; preds = %0, %3
  call void @vTaskDelay(i32 3001)
  %call = call zeroext i1 @_Z10initSDCardv()
  br i1 %call, label %2, label %3

; <label>:2:                                      ; preds = %1
  call void @_Z16runSDMessageLoopv()
  br label %3

; <label>:3:                                      ; preds = %2, %1
  br label %1
                                                  ; No predecessors!
  ret void
}

declare void @vTaskDelay(i32) #3

; Function Attrs: noinline optnone
define linkonce_odr i32 @_ZN10CharWriter5writeEPKc(%class.CharWriter* %this, i8* %s) unnamed_addr #2 comdat align 2 {
  %this.addr = alloca %class.CharWriter*, align 4
  %s.addr = alloca i8*, align 4
  store %class.CharWriter* %this, %class.CharWriter** %this.addr, align 4
  store i8* %s, i8** %s.addr, align 4
  %this1 = load %class.CharWriter*, %class.CharWriter** %this.addr, align 4
  %1 = load i8*, i8** %s.addr, align 4
  call void (i8*, ...) @serialDebugWrite(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.2, i32 0, i32 0), i8* %1)
  %2 = load i8*, i8** %s.addr, align 4
  %call = call i32 @strlen(i8* %2) #6
  ret i32 %call
}

; Function Attrs: noinline optnone
define linkonce_odr i32 @_ZN10CharWriter5writeEc(%class.CharWriter* %this, i8 signext %c) unnamed_addr #2 comdat align 2 {
  %this.addr = alloca %class.CharWriter*, align 4
  %c.addr = alloca i8, align 1
  %x = alloca [2 x i8], align 1
  store %class.CharWriter* %this, %class.CharWriter** %this.addr, align 4
  store i8 %c, i8* %c.addr, align 1
  %this1 = load %class.CharWriter*, %class.CharWriter** %this.addr, align 4
  %1 = load i8, i8* %c.addr, align 1
  %arrayidx = getelementptr inbounds [2 x i8], [2 x i8]* %x, i32 0, i32 0
  store i8 %1, i8* %arrayidx, align 1
  %arrayidx2 = getelementptr inbounds [2 x i8], [2 x i8]* %x, i32 0, i32 1
  store i8 0, i8* %arrayidx2, align 1
  %arraydecay = getelementptr inbounds [2 x i8], [2 x i8]* %x, i32 0, i32 0
  call void (i8*, ...) @serialDebugWrite(i8* %arraydecay)
  ret i32 1
}

; Function Attrs: nounwind readonly
declare i32 @strlen(i8*) #4

; Function Attrs: noinline
define internal void @_GLOBAL__sub_I_SDThread.cpp() #0 section ".text.startup" {
  call void @__cxx_global_var_init()
  call void @__cxx_global_var_init.1()
  ret void
}

attributes #0 = { noinline "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noinline optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { nounwind }
attributes #6 = { nounwind readonly }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"NumRegisterParameters", i32 0}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
