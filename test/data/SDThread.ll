; ModuleID = 'SDThread.cpp'
source_filename = "SDThread.cpp"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

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

@LL_GPIO_SPEED_FREQ_LOW = global i32 1, align 4
@LL_GPIO_OUTPUT_PUSHPULL = global i32 1, align 4
@LL_GPIO_MODE_OUTPUT = global i32 1, align 4
@LL_GPIO_PIN_13 = global i32 13, align 4
@LL_GPIO_PIN_12 = global i32 12, align 4
@LL_GPIO_PULL_UP = global i32 13, align 4
@LL_GPIO_MODE_INPUT = global i32 13, align 4
@GPIOC = global i32 0, align 4
@_ZTV10CharWriter = linkonce_odr unnamed_addr constant { [4 x i8*] } { [4 x i8*] [i8* null, i8* bitcast ({ i8*, i8* }* @_ZTI10CharWriter to i8*), i8* bitcast (i64 (%class.CharWriter*, i8*)* @_ZN10CharWriter5writeEPKc to i8*), i8* bitcast (i64 (%class.CharWriter*, i8)* @_ZN10CharWriter5writeEc to i8*)] }, comdat, align 8
@Serial = global { i8** } { i8** getelementptr inbounds ({ [4 x i8*] }, { [4 x i8*] }* @_ZTV10CharWriter, i32 0, inrange i32 0, i32 2) }, align 8
@spiDriver = global %class.SdFatSPIDriver zeroinitializer, align 8
@SD = global %class.SdFat zeroinitializer, align 1
@rawDataFile = global %class.FatFile zeroinitializer, align 1
@bulkFile = global %class.FatFile zeroinitializer, align 1
@sdQueue = global %struct.QueueDefinition* null, align 8
@rawGPSDataBuf = global %struct.SDMessage zeroinitializer, align 4
@msgIdx = global i16 0, align 2
@sd_buf = global [512 x i8] zeroinitializer, align 16
@.str = private unnamed_addr constant [25 x i8] c"Receive   GPS Data: %s\0D\0A\00", align 1
@_ZTVN10__cxxabiv117__class_type_infoE = external global i8*
@_ZTS10CharWriter = linkonce_odr constant [13 x i8] c"10CharWriter\00", comdat
@_ZTI10CharWriter = linkonce_odr constant { i8*, i8* } { i8* bitcast (i8** getelementptr inbounds (i8*, i8** @_ZTVN10__cxxabiv117__class_type_infoE, i64 2) to i8*), i8* getelementptr inbounds ([13 x i8], [13 x i8]* @_ZTS10CharWriter, i32 0, i32 0) }, comdat
@_ZTV14SdFatSPIDriver = external unnamed_addr constant { [12 x i8*] }
@.str.2 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* @_GLOBAL__sub_I_SDThread.cpp, i8* null }]

; Function Attrs: noinline uwtable
define internal void @__cxx_global_var_init() #0 section ".text.startup" {
  call void @_ZN14SdFatSPIDriverC2Ev(%class.SdFatSPIDriver* @spiDriver) #5
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define linkonce_odr void @_ZN14SdFatSPIDriverC2Ev(%class.SdFatSPIDriver*) unnamed_addr #1 comdat align 2 {
  %2 = alloca %class.SdFatSPIDriver*, align 8
  store %class.SdFatSPIDriver* %0, %class.SdFatSPIDriver** %2, align 8
  %3 = load %class.SdFatSPIDriver*, %class.SdFatSPIDriver** %2, align 8
  %4 = bitcast %class.SdFatSPIDriver* %3 to i32 (...)***
  store i32 (...)** bitcast (i8** getelementptr inbounds ({ [12 x i8*] }, { [12 x i8*] }* @_ZTV14SdFatSPIDriver, i32 0, inrange i32 0, i32 2) to i32 (...)**), i32 (...)*** %4, align 8
  %5 = getelementptr inbounds %class.SdFatSPIDriver, %class.SdFatSPIDriver* %3, i32 0, i32 1
  %6 = getelementptr inbounds %class.SdFatSPIDriver, %class.SdFatSPIDriver* %3, i32 0, i32 2
  %7 = getelementptr inbounds %class.SdFatSPIDriver, %class.SdFatSPIDriver* %3, i32 0, i32 3
  %8 = getelementptr inbounds %class.SdFatSPIDriver, %class.SdFatSPIDriver* %3, i32 0, i32 4
  store %struct.QueueDefinition* null, %struct.QueueDefinition** %8, align 8
  ret void
}

; Function Attrs: noinline uwtable
define internal void @__cxx_global_var_init.1() #0 section ".text.startup" {
  call void @_ZN5SdFatC2EP14SdFatSPIDriver(%class.SdFat* @SD, %class.SdFatSPIDriver* @spiDriver)
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define linkonce_odr void @_ZN5SdFatC2EP14SdFatSPIDriver(%class.SdFat*, %class.SdFatSPIDriver*) unnamed_addr #1 comdat align 2 {
  %3 = alloca %class.SdFat*, align 8
  %4 = alloca %class.SdFatSPIDriver*, align 8
  store %class.SdFat* %0, %class.SdFat** %3, align 8
  store %class.SdFatSPIDriver* %1, %class.SdFatSPIDriver** %4, align 8
  %5 = load %class.SdFat*, %class.SdFat** %3, align 8
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define i8* @_Z19requestRawGPSBufferv() #1 {
  ret i8* getelementptr inbounds (%struct.SDMessage, %struct.SDMessage* @rawGPSDataBuf, i32 0, i32 2, i32 0, i32 1, i32 0)
}

; Function Attrs: noinline optnone uwtable
define void @_Z13ackRawGPSDatah(i8 zeroext) #2 {
  %2 = alloca i8, align 1
  store i8 %0, i8* %2, align 1
  store i32 0, i32* getelementptr inbounds (%struct.SDMessage, %struct.SDMessage* @rawGPSDataBuf, i32 0, i32 0), align 4
  %3 = load i8, i8* %2, align 1
  store i8 %3, i8* getelementptr inbounds (%struct.SDMessage, %struct.SDMessage* @rawGPSDataBuf, i32 0, i32 2, i32 0, i32 0), align 2
  %4 = load i16, i16* @msgIdx, align 2
  %5 = add i16 %4, 1
  store i16 %5, i16* @msgIdx, align 2
  store i16 %4, i16* getelementptr inbounds (%struct.SDMessage, %struct.SDMessage* @rawGPSDataBuf, i32 0, i32 1), align 4
  %6 = load %struct.QueueDefinition*, %struct.QueueDefinition** @sdQueue, align 8
  %7 = call i64 @xQueueGenericSend(%struct.QueueDefinition* %6, i8* bitcast (%struct.SDMessage* @rawGPSDataBuf to i8*), i32 10, i64 0)
  ret void
}

declare i64 @xQueueGenericSend(%struct.QueueDefinition*, i8*, i32, i64) #3

; Function Attrs: noinline optnone uwtable
define zeroext i1 @_Z10initSDCardv() #2 {
  %1 = alloca i1, align 1
  %2 = alloca i32, align 4
  %3 = call i32 @_ZN5SdFat5beginEj(%class.SdFat* @SD, i32 100)
  store i32 %3, i32* %2, align 4
  %4 = load i32, i32* %2, align 4
  %5 = icmp ne i32 %4, 0
  br i1 %5, label %6, label %7

; <label>:6:                                      ; preds = %0
  store i1 false, i1* %1, align 1
  br label %8

; <label>:7:                                      ; preds = %0
  store i1 true, i1* %1, align 1
  br label %8

; <label>:8:                                      ; preds = %7, %6
  %9 = load i1, i1* %1, align 1
  ret i1 %9
}

; Function Attrs: noinline nounwind optnone uwtable
define linkonce_odr i32 @_ZN5SdFat5beginEj(%class.SdFat*, i32) #1 comdat align 2 {
  %3 = alloca %class.SdFat*, align 8
  %4 = alloca i32, align 4
  store %class.SdFat* %0, %class.SdFat** %3, align 8
  store i32 %1, i32* %4, align 4
  %5 = load %class.SdFat*, %class.SdFat** %3, align 8
  %6 = load i32, i32* %4, align 4
  ret i32 %6
}

; Function Attrs: noinline optnone uwtable
define void @_Z11saveRawDataRK9SDMessage(%struct.SDMessage* dereferenceable(88)) #2 {
  %2 = alloca %struct.SDMessage*, align 8
  store %struct.SDMessage* %0, %struct.SDMessage** %2, align 8
  %3 = load i8, i8* getelementptr inbounds (%struct.SDMessage, %struct.SDMessage* @rawGPSDataBuf, i32 0, i32 2, i32 0, i32 0), align 2
  call void @_ZN7FatFile5writeEPch(%class.FatFile* @rawDataFile, i8* getelementptr inbounds (%struct.SDMessage, %struct.SDMessage* @rawGPSDataBuf, i32 0, i32 2, i32 0, i32 1, i32 0), i8 zeroext %3)
  ret void
}

declare void @_ZN7FatFile5writeEPch(%class.FatFile*, i8*, i8 zeroext) #3

; Function Attrs: noinline optnone uwtable
define void @_Z16runSDMessageLoopv() #2 {
  %1 = alloca i16, align 2
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca %struct.SDMessage, align 4
  %5 = alloca i32, align 4
  store i16 0, i16* %1, align 2
  br label %6

; <label>:6:                                      ; preds = %18, %0
  %7 = load i16, i16* %1, align 2
  %8 = zext i16 %7 to i32
  %9 = icmp slt i32 %8, 512
  br i1 %9, label %10, label %21

; <label>:10:                                     ; preds = %6
  %11 = load i16, i16* %1, align 2
  %12 = zext i16 %11 to i32
  %13 = and i32 %12, 255
  %14 = trunc i32 %13 to i8
  %15 = load i16, i16* %1, align 2
  %16 = zext i16 %15 to i64
  %17 = getelementptr inbounds [512 x i8], [512 x i8]* @sd_buf, i64 0, i64 %16
  store i8 %14, i8* %17, align 1
  br label %18

; <label>:18:                                     ; preds = %10
  %19 = load i16, i16* %1, align 2
  %20 = add i16 %19, 1
  store i16 %20, i16* %1, align 2
  br label %6

; <label>:21:                                     ; preds = %6
  store i32 0, i32* %2, align 4
  %22 = call i32 @_Z11HAL_GetTickv()
  store i32 %22, i32* %3, align 4
  br label %23

; <label>:23:                                     ; preds = %21, %48
  %24 = load %struct.QueueDefinition*, %struct.QueueDefinition** @sdQueue, align 8
  %25 = bitcast %struct.SDMessage* %4 to i8*
  %26 = call i64 @xQueueReceive(%struct.QueueDefinition* %24, i8* %25, i32 50)
  %27 = icmp ne i64 %26, 0
  br i1 %27, label %28, label %38

; <label>:28:                                     ; preds = %23
  %29 = getelementptr inbounds %struct.SDMessage, %struct.SDMessage* %4, i32 0, i32 0
  %30 = load i32, i32* %29, align 4
  switch i32 %30, label %36 [
    i32 0, label %31
  ]

; <label>:31:                                     ; preds = %28
  %32 = getelementptr inbounds %struct.SDMessage, %struct.SDMessage* %4, i32 0, i32 2
  %33 = bitcast %union.anon* %32 to %struct.RawGPSData*
  %34 = getelementptr inbounds %struct.RawGPSData, %struct.RawGPSData* %33, i32 0, i32 1
  %35 = getelementptr inbounds [81 x i8], [81 x i8]* %34, i32 0, i32 0
  call void (i8*, ...) @serialDebugWrite(i8* getelementptr inbounds ([25 x i8], [25 x i8]* @.str, i32 0, i32 0), i8* %35)
  br label %37

; <label>:36:                                     ; preds = %28
  br label %37

; <label>:37:                                     ; preds = %36, %31
  br label %38

; <label>:38:                                     ; preds = %37, %23
  %39 = load i32, i32* %2, align 4
  %40 = add i32 %39, 1
  store i32 %40, i32* %2, align 4
  %41 = call i32 @_Z11HAL_GetTickv()
  store i32 %41, i32* %5, align 4
  %42 = load i32, i32* %5, align 4
  %43 = load i32, i32* %3, align 4
  %44 = sub i32 %42, %43
  %45 = icmp uge i32 %44, 1000
  br i1 %45, label %46, label %48

; <label>:46:                                     ; preds = %38
  store i32 0, i32* %2, align 4
  %47 = call i32 @_Z11HAL_GetTickv()
  store i32 %47, i32* %3, align 4
  br label %48

; <label>:48:                                     ; preds = %46, %38
  br label %23
                                                  ; No predecessors!
  ret void
}

declare i32 @_Z11HAL_GetTickv() #3

declare i64 @xQueueReceive(%struct.QueueDefinition*, i8*, i32) #3

declare void @serialDebugWrite(i8*, ...) #3

; Function Attrs: noinline optnone uwtable
define void @_Z12initSDThreadv() #2 {
  %1 = call %struct.QueueDefinition* @xQueueGenericCreate(i64 5, i64 88, i8 zeroext 0)
  store %struct.QueueDefinition* %1, %struct.QueueDefinition** @sdQueue, align 8
  ret void
}

declare %struct.QueueDefinition* @xQueueGenericCreate(i64, i64, i8 zeroext) #3

; Function Attrs: noinline optnone uwtable
define void @_Z9vSDThreadPv(i8*) #2 {
  %2 = alloca i8*, align 8
  store i8* %0, i8** %2, align 8
  call void @_Z12initSDThreadv()
  br label %3

; <label>:3:                                      ; preds = %1, %6
  call void @vTaskDelay(i32 3001)
  %4 = call zeroext i1 @_Z10initSDCardv()
  br i1 %4, label %5, label %6

; <label>:5:                                      ; preds = %3
  call void @_Z16runSDMessageLoopv()
  br label %6

; <label>:6:                                      ; preds = %5, %3
  br label %3
                                                  ; No predecessors!
  ret void
}

declare void @vTaskDelay(i32) #3

; Function Attrs: noinline optnone uwtable
define linkonce_odr i64 @_ZN10CharWriter5writeEPKc(%class.CharWriter*, i8*) unnamed_addr #2 comdat align 2 {
  %3 = alloca %class.CharWriter*, align 8
  %4 = alloca i8*, align 8
  store %class.CharWriter* %0, %class.CharWriter** %3, align 8
  store i8* %1, i8** %4, align 8
  %5 = load %class.CharWriter*, %class.CharWriter** %3, align 8
  %6 = load i8*, i8** %4, align 8
  call void (i8*, ...) @serialDebugWrite(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.2, i32 0, i32 0), i8* %6)
  %7 = load i8*, i8** %4, align 8
  %8 = call i64 @strlen(i8* %7) #6
  ret i64 %8
}

; Function Attrs: noinline optnone uwtable
define linkonce_odr i64 @_ZN10CharWriter5writeEc(%class.CharWriter*, i8 signext) unnamed_addr #2 comdat align 2 {
  %3 = alloca %class.CharWriter*, align 8
  %4 = alloca i8, align 1
  %5 = alloca [2 x i8], align 1
  store %class.CharWriter* %0, %class.CharWriter** %3, align 8
  store i8 %1, i8* %4, align 1
  %6 = load %class.CharWriter*, %class.CharWriter** %3, align 8
  %7 = load i8, i8* %4, align 1
  %8 = getelementptr inbounds [2 x i8], [2 x i8]* %5, i64 0, i64 0
  store i8 %7, i8* %8, align 1
  %9 = getelementptr inbounds [2 x i8], [2 x i8]* %5, i64 0, i64 1
  store i8 0, i8* %9, align 1
  %10 = getelementptr inbounds [2 x i8], [2 x i8]* %5, i32 0, i32 0
  call void (i8*, ...) @serialDebugWrite(i8* %10)
  ret i64 1
}

; Function Attrs: nounwind readonly
declare i64 @strlen(i8*) #4

; Function Attrs: noinline uwtable
define internal void @_GLOBAL__sub_I_SDThread.cpp() #0 section ".text.startup" {
  call void @__cxx_global_var_init()
  call void @__cxx_global_var_init.1()
  ret void
}

attributes #0 = { noinline uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noinline optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { nounwind }
attributes #6 = { nounwind readonly }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
