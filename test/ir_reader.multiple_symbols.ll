; ModuleID = '../appl/FreeRTOS/GPSLogger/Src/SDThread.cpp'
source_filename = "../appl/FreeRTOS/GPSLogger/Src/SDThread.cpp"
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

@LL_GPIO_SPEED_FREQ_HIGH = dso_local global i32 1, align 4, !dbg !0
@LL_GPIO_SPEED_FREQ_MEDIUM = dso_local global i32 1, align 4, !dbg !19
@LL_GPIO_SPEED_FREQ_LOW = dso_local global i32 1, align 4, !dbg !23
@LL_GPIO_OUTPUT_PUSHPULL = dso_local global i32 1, align 4, !dbg !25
@LL_GPIO_MODE_OUTPUT = dso_local global i32 1, align 4, !dbg !27
@LL_GPIO_MODE_ALTERNATE = dso_local global i32 1, align 4, !dbg !29
@LL_GPIO_PIN_0 = dso_local global i32 13, align 4, !dbg !31
@LL_GPIO_PIN_1 = dso_local global i32 13, align 4, !dbg !33
@LL_GPIO_PIN_2 = dso_local global i32 12, align 4, !dbg !35
@LL_GPIO_PIN_3 = dso_local global i32 13, align 4, !dbg !37
@LL_GPIO_PIN_4 = dso_local global i32 12, align 4, !dbg !39
@LL_GPIO_PIN_5 = dso_local global i32 13, align 4, !dbg !41
@LL_GPIO_PIN_6 = dso_local global i32 12, align 4, !dbg !43
@LL_GPIO_PIN_7 = dso_local global i32 13, align 4, !dbg !45
@LL_GPIO_PIN_8 = dso_local global i32 12, align 4, !dbg !47
@LL_GPIO_PIN_9 = dso_local global i32 13, align 4, !dbg !49
@LL_GPIO_PIN_10 = dso_local global i32 12, align 4, !dbg !51
@LL_GPIO_PIN_11 = dso_local global i32 12, align 4, !dbg !53
@LL_GPIO_PIN_12 = dso_local global i32 13, align 4, !dbg !55
@LL_GPIO_PIN_13 = dso_local global i32 12, align 4, !dbg !57
@LL_GPIO_PIN_14 = dso_local global i32 12, align 4, !dbg !59
@LL_GPIO_PIN_15 = dso_local global i32 13, align 4, !dbg !61
@LL_GPIO_PIN_16 = dso_local global i32 12, align 4, !dbg !63
@LL_GPIO_PULL_UP = dso_local global i32 13, align 4, !dbg !65
@LL_GPIO_MODE_INPUT = dso_local global i32 13, align 4, !dbg !67
@GPIOC = dso_local global i32 0, align 4, !dbg !69
@GPIOB = dso_local global i32 0, align 4, !dbg !71
@SPI2 = dso_local global i8* null, align 4, !dbg !73
@_ZTV10CharWriter = linkonce_odr dso_local unnamed_addr constant { [4 x i8*] } { [4 x i8*] [i8* null, i8* bitcast ({ i8*, i8* }* @_ZTI10CharWriter to i8*), i8* bitcast (i32 (%class.CharWriter*, i8*)* @_ZN10CharWriter5writeEPKc to i8*), i8* bitcast (i32 (%class.CharWriter*, i8)* @_ZN10CharWriter5writeEc to i8*)] }, comdat, align 4
@Serial = dso_local global { i8** } { i8** getelementptr inbounds ({ [4 x i8*] }, { [4 x i8*] }* @_ZTV10CharWriter, i32 0, inrange i32 0, i32 2) }, align 4, !dbg !76
@spiDriver = dso_local global %class.SdFatSPIDriver zeroinitializer, align 4, !dbg !98
@SD = dso_local global %class.SdFat zeroinitializer, align 1, !dbg !102
@rawDataFile = dso_local global %class.FatFile zeroinitializer, align 1, !dbg !114
@bulkFile = dso_local global %class.FatFile zeroinitializer, align 1, !dbg !123
@sdQueue = dso_local global %struct.QueueDefinition* null, align 4, !dbg !125
@rawGPSDataBuf = dso_local global %struct.SDMessage zeroinitializer, align 4, !dbg !131
@msgIdx = dso_local global i16 0, align 2, !dbg !150
@sd_buf = dso_local global [512 x i8] zeroinitializer, align 1, !dbg !152
@.str = private unnamed_addr constant [25 x i8] c"Receive   GPS Data: %s\0D\0A\00", align 1
@_ZTVN10__cxxabiv117__class_type_infoE = external dso_local global i8*
@_ZTS10CharWriter = linkonce_odr dso_local constant [13 x i8] c"10CharWriter\00", comdat
@_ZTI10CharWriter = linkonce_odr dso_local constant { i8*, i8* } { i8* bitcast (i8** getelementptr inbounds (i8*, i8** @_ZTVN10__cxxabiv117__class_type_infoE, i32 2) to i8*), i8* getelementptr inbounds ([13 x i8], [13 x i8]* @_ZTS10CharWriter, i32 0, i32 0) }, comdat
@_ZTV14SdFatSPIDriver = external dso_local unnamed_addr constant { [12 x i8*] }
@.str.2 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* @_GLOBAL__sub_I_SDThread.cpp, i8* null }]

; Function Attrs: noinline
define internal void @__cxx_global_var_init() #0 section ".text.startup" !dbg !395 {
entry:
  call void @_ZN14SdFatSPIDriverC2Ev(%class.SdFatSPIDriver* @spiDriver) #6, !dbg !397
  ret void, !dbg !397
}

; Function Attrs: noinline nounwind optnone
define linkonce_odr dso_local void @_ZN14SdFatSPIDriverC2Ev(%class.SdFatSPIDriver* %this) unnamed_addr #1 comdat align 2 !dbg !398 {
entry:
  %this.addr = alloca %class.SdFatSPIDriver*, align 4
  store %class.SdFatSPIDriver* %this, %class.SdFatSPIDriver** %this.addr, align 4
  call void @llvm.dbg.declare(metadata %class.SdFatSPIDriver** %this.addr, metadata !403, metadata !DIExpression()), !dbg !404
  %this1 = load %class.SdFatSPIDriver*, %class.SdFatSPIDriver** %this.addr, align 4
  %0 = bitcast %class.SdFatSPIDriver* %this1 to i32 (...)***, !dbg !405
  store i32 (...)** bitcast (i8** getelementptr inbounds ({ [12 x i8*] }, { [12 x i8*] }* @_ZTV14SdFatSPIDriver, i32 0, inrange i32 0, i32 2) to i32 (...)**), i32 (...)*** %0, align 4, !dbg !405
  %spiHandle = getelementptr inbounds %class.SdFatSPIDriver, %class.SdFatSPIDriver* %this1, i32 0, i32 1, !dbg !405
  %dmaHandleRx = getelementptr inbounds %class.SdFatSPIDriver, %class.SdFatSPIDriver* %this1, i32 0, i32 2, !dbg !405
  %dmaHandleTx = getelementptr inbounds %class.SdFatSPIDriver, %class.SdFatSPIDriver* %this1, i32 0, i32 3, !dbg !405
  %xSema = getelementptr inbounds %class.SdFatSPIDriver, %class.SdFatSPIDriver* %this1, i32 0, i32 4, !dbg !406
  store %struct.QueueDefinition* null, %struct.QueueDefinition** %xSema, align 4, !dbg !406
  ret void, !dbg !405
}

; Function Attrs: noinline
define internal void @__cxx_global_var_init.1() #0 section ".text.startup" !dbg !407 {
entry:
  call void @_ZN5SdFatC2EP14SdFatSPIDriver(%class.SdFat* @SD, %class.SdFatSPIDriver* @spiDriver), !dbg !408
  ret void, !dbg !409
}

; Function Attrs: noinline nounwind optnone
define linkonce_odr dso_local void @_ZN5SdFatC2EP14SdFatSPIDriver(%class.SdFat* %this, %class.SdFatSPIDriver* %sd) unnamed_addr #1 comdat align 2 !dbg !410 {
entry:
  %this.addr = alloca %class.SdFat*, align 4
  %sd.addr = alloca %class.SdFatSPIDriver*, align 4
  store %class.SdFat* %this, %class.SdFat** %this.addr, align 4
  call void @llvm.dbg.declare(metadata %class.SdFat** %this.addr, metadata !411, metadata !DIExpression()), !dbg !413
  store %class.SdFatSPIDriver* %sd, %class.SdFatSPIDriver** %sd.addr, align 4
  call void @llvm.dbg.declare(metadata %class.SdFatSPIDriver** %sd.addr, metadata !414, metadata !DIExpression()), !dbg !415
  %this1 = load %class.SdFat*, %class.SdFat** %this.addr, align 4
  ret void, !dbg !416
}

; Function Attrs: noinline nounwind optnone
define dso_local i8* @_Z19requestRawGPSBufferv() #1 !dbg !417 {
entry:
  ret i8* getelementptr inbounds (%struct.SDMessage, %struct.SDMessage* @rawGPSDataBuf, i32 0, i32 2, i32 0, i32 1, i32 0), !dbg !420
}

; Function Attrs: noinline optnone
define dso_local void @_Z13ackRawGPSDatah(i8 zeroext %len) #2 !dbg !421 {
entry:
  %len.addr = alloca i8, align 1
  store i8 %len, i8* %len.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %len.addr, metadata !424, metadata !DIExpression()), !dbg !425
  store i32 0, i32* getelementptr inbounds (%struct.SDMessage, %struct.SDMessage* @rawGPSDataBuf, i32 0, i32 0), align 4, !dbg !426
  %0 = load i8, i8* %len.addr, align 1, !dbg !427
  store i8 %0, i8* getelementptr inbounds (%struct.SDMessage, %struct.SDMessage* @rawGPSDataBuf, i32 0, i32 2, i32 0, i32 0), align 2, !dbg !428
  %1 = load i16, i16* @msgIdx, align 2, !dbg !429
  %inc = add i16 %1, 1, !dbg !429
  store i16 %inc, i16* @msgIdx, align 2, !dbg !429
  store i16 %1, i16* getelementptr inbounds (%struct.SDMessage, %struct.SDMessage* @rawGPSDataBuf, i32 0, i32 1), align 4, !dbg !430
  %2 = load %struct.QueueDefinition*, %struct.QueueDefinition** @sdQueue, align 4, !dbg !431
  %call = call i32 @xQueueGenericSend(%struct.QueueDefinition* %2, i8* bitcast (%struct.SDMessage* @rawGPSDataBuf to i8*), i32 10, i32 0), !dbg !431
  ret void, !dbg !432
}

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.declare(metadata, metadata, metadata) #3

declare dso_local i32 @xQueueGenericSend(%struct.QueueDefinition*, i8*, i32, i32) #4

; Function Attrs: noinline optnone
define dso_local zeroext i1 @_Z10initSDCardv() #2 !dbg !433 {
entry:
  %retval = alloca i1, align 1
  %errno = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %errno, metadata !437, metadata !DIExpression()), !dbg !438
  %call = call i32 @_ZN5SdFat5beginEj(%class.SdFat* @SD, i32 100), !dbg !439
  store i32 %call, i32* %errno, align 4, !dbg !438
  %0 = load i32, i32* %errno, align 4, !dbg !440
  %tobool = icmp ne i32 %0, 0, !dbg !440
  br i1 %tobool, label %if.then, label %if.end, !dbg !442

if.then:                                          ; preds = %entry
  store i1 false, i1* %retval, align 1, !dbg !443
  br label %return, !dbg !443

if.end:                                           ; preds = %entry
  store i1 true, i1* %retval, align 1, !dbg !445
  br label %return, !dbg !445

return:                                           ; preds = %if.end, %if.then
  %1 = load i1, i1* %retval, align 1, !dbg !446
  ret i1 %1, !dbg !446
}

; Function Attrs: noinline nounwind optnone
define linkonce_odr dso_local i32 @_ZN5SdFat5beginEj(%class.SdFat* %this, i32 %tmp) #1 comdat align 2 !dbg !447 {
entry:
  %this.addr = alloca %class.SdFat*, align 4
  %tmp.addr = alloca i32, align 4
  store %class.SdFat* %this, %class.SdFat** %this.addr, align 4
  call void @llvm.dbg.declare(metadata %class.SdFat** %this.addr, metadata !448, metadata !DIExpression()), !dbg !449
  store i32 %tmp, i32* %tmp.addr, align 4
  call void @llvm.dbg.declare(metadata i32* %tmp.addr, metadata !450, metadata !DIExpression()), !dbg !451
  %this1 = load %class.SdFat*, %class.SdFat** %this.addr, align 4
  %0 = load i32, i32* %tmp.addr, align 4, !dbg !452
  ret i32 %0, !dbg !453
}

; Function Attrs: noinline optnone
define dso_local void @_Z11saveRawDataRK9SDMessage(%struct.SDMessage* dereferenceable(88) %msg) #2 !dbg !454 {
entry:
  %msg.addr = alloca %struct.SDMessage*, align 4
  store %struct.SDMessage* %msg, %struct.SDMessage** %msg.addr, align 4
  call void @llvm.dbg.declare(metadata %struct.SDMessage** %msg.addr, metadata !459, metadata !DIExpression()), !dbg !460
  %0 = load i8, i8* getelementptr inbounds (%struct.SDMessage, %struct.SDMessage* @rawGPSDataBuf, i32 0, i32 2, i32 0, i32 0), align 2, !dbg !461
  call void @_ZN7FatFile5writeEPch(%class.FatFile* @rawDataFile, i8* getelementptr inbounds (%struct.SDMessage, %struct.SDMessage* @rawGPSDataBuf, i32 0, i32 2, i32 0, i32 1, i32 0), i8 zeroext %0), !dbg !462
  ret void, !dbg !463
}

declare dso_local void @_ZN7FatFile5writeEPch(%class.FatFile*, i8*, i8 zeroext) #4

; Function Attrs: noinline optnone
define dso_local void @_Z16runSDMessageLoopv() #2 !dbg !464 {
entry:
  %q = alloca i16, align 2
  %i = alloca i32, align 4
  %prev = alloca i32, align 4
  %msg = alloca %struct.SDMessage, align 4
  %cur = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i16* %q, metadata !465, metadata !DIExpression()), !dbg !467
  store i16 0, i16* %q, align 2, !dbg !467
  br label %for.cond, !dbg !468

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i16, i16* %q, align 2, !dbg !469
  %conv = zext i16 %0 to i32, !dbg !469
  %cmp = icmp slt i32 %conv, 512, !dbg !471
  br i1 %cmp, label %for.body, label %for.end, !dbg !472

for.body:                                         ; preds = %for.cond
  %1 = load i16, i16* %q, align 2, !dbg !473
  %conv1 = zext i16 %1 to i32, !dbg !473
  %and = and i32 %conv1, 255, !dbg !474
  %conv2 = trunc i32 %and to i8, !dbg !473
  %2 = load i16, i16* %q, align 2, !dbg !475
  %idxprom = zext i16 %2 to i32, !dbg !476
  %arrayidx = getelementptr inbounds [512 x i8], [512 x i8]* @sd_buf, i32 0, i32 %idxprom, !dbg !476
  store i8 %conv2, i8* %arrayidx, align 1, !dbg !477
  br label %for.inc, !dbg !476

for.inc:                                          ; preds = %for.body
  %3 = load i16, i16* %q, align 2, !dbg !478
  %inc = add i16 %3, 1, !dbg !478
  store i16 %inc, i16* %q, align 2, !dbg !478
  br label %for.cond, !dbg !479, !llvm.loop !480

for.end:                                          ; preds = %for.cond
  call void @llvm.dbg.declare(metadata i32* %i, metadata !482, metadata !DIExpression()), !dbg !483
  store i32 0, i32* %i, align 4, !dbg !483
  call void @llvm.dbg.declare(metadata i32* %prev, metadata !484, metadata !DIExpression()), !dbg !485
  %call = call i32 @_Z11HAL_GetTickv(), !dbg !486
  store i32 %call, i32* %prev, align 4, !dbg !485
  br label %while.body, !dbg !487

while.body:                                       ; preds = %for.end, %if.end9
  call void @llvm.dbg.declare(metadata %struct.SDMessage* %msg, metadata !488, metadata !DIExpression()), !dbg !490
  %4 = load %struct.QueueDefinition*, %struct.QueueDefinition** @sdQueue, align 4, !dbg !491
  %5 = bitcast %struct.SDMessage* %msg to i8*, !dbg !493
  %call3 = call i32 @xQueueReceive(%struct.QueueDefinition* %4, i8* %5, i32 50), !dbg !494
  %tobool = icmp ne i32 %call3, 0, !dbg !494
  br i1 %tobool, label %if.then, label %if.end, !dbg !495

if.then:                                          ; preds = %while.body
  %messageType = getelementptr inbounds %struct.SDMessage, %struct.SDMessage* %msg, i32 0, i32 0, !dbg !496
  %6 = load i32, i32* %messageType, align 4, !dbg !496
  switch i32 %6, label %sw.default [
    i32 0, label %sw.bb
  ], !dbg !498

sw.bb:                                            ; preds = %if.then
  %7 = getelementptr inbounds %struct.SDMessage, %struct.SDMessage* %msg, i32 0, i32 2, !dbg !499
  %rawData = bitcast %union.anon* %7 to %struct.RawGPSData*, !dbg !499
  %rawDataBuf = getelementptr inbounds %struct.RawGPSData, %struct.RawGPSData* %rawData, i32 0, i32 1, !dbg !501
  %arraydecay = getelementptr inbounds [81 x i8], [81 x i8]* %rawDataBuf, i32 0, i32 0, !dbg !502
  call void (i8*, ...) @serialDebugWrite(i8* getelementptr inbounds ([25 x i8], [25 x i8]* @.str, i32 0, i32 0), i8* %arraydecay), !dbg !503
  br label %sw.epilog, !dbg !504

sw.default:                                       ; preds = %if.then
  br label %sw.epilog, !dbg !505

sw.epilog:                                        ; preds = %sw.default, %sw.bb
  br label %if.end, !dbg !506

if.end:                                           ; preds = %sw.epilog, %while.body
  %8 = load i32, i32* %i, align 4, !dbg !507
  %inc4 = add i32 %8, 1, !dbg !507
  store i32 %inc4, i32* %i, align 4, !dbg !507
  call void @llvm.dbg.declare(metadata i32* %cur, metadata !508, metadata !DIExpression()), !dbg !509
  %call5 = call i32 @_Z11HAL_GetTickv(), !dbg !510
  store i32 %call5, i32* %cur, align 4, !dbg !509
  %9 = load i32, i32* %cur, align 4, !dbg !511
  %10 = load i32, i32* %prev, align 4, !dbg !513
  %sub = sub i32 %9, %10, !dbg !514
  %cmp6 = icmp uge i32 %sub, 1000, !dbg !515
  br i1 %cmp6, label %if.then7, label %if.end9, !dbg !516

if.then7:                                         ; preds = %if.end
  store i32 0, i32* %i, align 4, !dbg !517
  %call8 = call i32 @_Z11HAL_GetTickv(), !dbg !519
  store i32 %call8, i32* %prev, align 4, !dbg !520
  br label %if.end9, !dbg !521

if.end9:                                          ; preds = %if.then7, %if.end
  br label %while.body, !dbg !487, !llvm.loop !522

return:                                           ; No predecessors!
  ret void, !dbg !524
}

declare dso_local i32 @_Z11HAL_GetTickv() #4

declare dso_local i32 @xQueueReceive(%struct.QueueDefinition*, i8*, i32) #4

declare dso_local void @serialDebugWrite(i8*, ...) #4

; Function Attrs: noinline optnone
define dso_local void @_Z12initSDThreadv() #2 !dbg !525 {
entry:
  %call = call %struct.QueueDefinition* @xQueueGenericCreate(i32 5, i32 88, i8 zeroext 0), !dbg !526
  store %struct.QueueDefinition* %call, %struct.QueueDefinition** @sdQueue, align 4, !dbg !527
  ret void, !dbg !528
}

declare dso_local %struct.QueueDefinition* @xQueueGenericCreate(i32, i32, i8 zeroext) #4

; Function Attrs: noinline optnone
define dso_local void @_Z9vSDThreadPv(i8* %pvParameters) #2 !dbg !529 {
entry:
  %pvParameters.addr = alloca i8*, align 4
  store i8* %pvParameters, i8** %pvParameters.addr, align 4
  call void @llvm.dbg.declare(metadata i8** %pvParameters.addr, metadata !530, metadata !DIExpression()), !dbg !531
  call void @_Z12initSDThreadv(), !dbg !532
  br label %while.body, !dbg !533

while.body:                                       ; preds = %entry, %if.end
  call void @vTaskDelay(i32 3001), !dbg !534
  %call = call zeroext i1 @_Z10initSDCardv(), !dbg !536
  br i1 %call, label %if.then, label %if.end, !dbg !538

if.then:                                          ; preds = %while.body
  call void @_Z16runSDMessageLoopv(), !dbg !539
  br label %if.end, !dbg !539

if.end:                                           ; preds = %if.then, %while.body
  br label %while.body, !dbg !533, !llvm.loop !540

return:                                           ; No predecessors!
  ret void, !dbg !542
}

declare dso_local void @vTaskDelay(i32) #4

; Function Attrs: noinline optnone
define linkonce_odr dso_local i32 @_ZN10CharWriter5writeEPKc(%class.CharWriter* %this, i8* %s) unnamed_addr #2 comdat align 2 !dbg !543 {
entry:
  %this.addr = alloca %class.CharWriter*, align 4
  %s.addr = alloca i8*, align 4
  store %class.CharWriter* %this, %class.CharWriter** %this.addr, align 4
  call void @llvm.dbg.declare(metadata %class.CharWriter** %this.addr, metadata !544, metadata !DIExpression()), !dbg !546
  store i8* %s, i8** %s.addr, align 4
  call void @llvm.dbg.declare(metadata i8** %s.addr, metadata !547, metadata !DIExpression()), !dbg !548
  %this1 = load %class.CharWriter*, %class.CharWriter** %this.addr, align 4
  %0 = load i8*, i8** %s.addr, align 4, !dbg !549
  call void (i8*, ...) @serialDebugWrite(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.2, i32 0, i32 0), i8* %0), !dbg !550
  %1 = load i8*, i8** %s.addr, align 4, !dbg !551
  %call = call i32 @strlen(i8* %1) #7, !dbg !552
  ret i32 %call, !dbg !553
}

; Function Attrs: noinline optnone
define linkonce_odr dso_local i32 @_ZN10CharWriter5writeEc(%class.CharWriter* %this, i8 signext %c) unnamed_addr #2 comdat align 2 !dbg !554 {
entry:
  %this.addr = alloca %class.CharWriter*, align 4
  %c.addr = alloca i8, align 1
  %x = alloca [2 x i8], align 1
  store %class.CharWriter* %this, %class.CharWriter** %this.addr, align 4
  call void @llvm.dbg.declare(metadata %class.CharWriter** %this.addr, metadata !555, metadata !DIExpression()), !dbg !556
  store i8 %c, i8* %c.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %c.addr, metadata !557, metadata !DIExpression()), !dbg !558
  %this1 = load %class.CharWriter*, %class.CharWriter** %this.addr, align 4
  call void @llvm.dbg.declare(metadata [2 x i8]* %x, metadata !559, metadata !DIExpression()), !dbg !563
  %0 = load i8, i8* %c.addr, align 1, !dbg !564
  %arrayidx = getelementptr inbounds [2 x i8], [2 x i8]* %x, i32 0, i32 0, !dbg !565
  store i8 %0, i8* %arrayidx, align 1, !dbg !566
  %arrayidx2 = getelementptr inbounds [2 x i8], [2 x i8]* %x, i32 0, i32 1, !dbg !567
  store i8 0, i8* %arrayidx2, align 1, !dbg !568
  %arraydecay = getelementptr inbounds [2 x i8], [2 x i8]* %x, i32 0, i32 0, !dbg !569
  call void (i8*, ...) @serialDebugWrite(i8* %arraydecay), !dbg !570
  ret i32 1, !dbg !571
}

; Function Attrs: nounwind readonly
declare dso_local i32 @strlen(i8*) #5

; Function Attrs: noinline
define internal void @_GLOBAL__sub_I_SDThread.cpp() #0 section ".text.startup" !dbg !572 {
entry:
  call void @__cxx_global_var_init(), !dbg !574
  call void @__cxx_global_var_init.1(), !dbg !574
  ret void
}

attributes #0 = { noinline "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noinline optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind readnone speculatable }
attributes #4 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { nounwind }
attributes #7 = { nounwind readonly }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!390, !391, !392, !393}
!llvm.ident = !{!394}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "LL_GPIO_SPEED_FREQ_HIGH", scope: !2, file: !21, line: 33, type: !22, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, file: !3, producer: "clang version 7.0.1 (tags/RELEASE_701/final)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !11, globals: !18, imports: !157)
!3 = !DIFile(filename: "../appl/FreeRTOS/GPSLogger/Src/SDThread.cpp", directory: "/home/gerion/sourcecode/ara/build")
!4 = !{!5}
!5 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "SDMessageType", file: !3, line: 67, baseType: !6, size: 32, elements: !7, identifier: "_ZTS13SDMessageType")
!6 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!7 = !{!8, !9, !10}
!8 = !DIEnumerator(name: "RAW_GPS_DATA", value: 0, isUnsigned: true)
!9 = !DIEnumerator(name: "CURRENT_POSITION_DATA", value: 1, isUnsigned: true)
!10 = !DIEnumerator(name: "USER_WAY_POINT_DATA", value: 2, isUnsigned: true)
!11 = !{!12, !15}
!12 = !DIDerivedType(tag: DW_TAG_typedef, name: "BaseType_t", file: !13, line: 98, baseType: !14)
!13 = !DIFile(filename: "/home/gerion/sourcecode/ara/appl/FreeRTOS/GPSLogger/Libs/FreeRTOS/portmacro.h", directory: "/home/gerion/sourcecode/ara/build")
!14 = !DIBasicType(name: "long int", size: 32, encoding: DW_ATE_signed)
!15 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !16, line: 20, baseType: !17)
!16 = !DIFile(filename: "/home/gerion/sourcecode/ara/appl/FreeRTOS/GPSLogger/Libs/FreeRTOS/stdint.h", directory: "/home/gerion/sourcecode/ara/build")
!17 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!18 = !{!0, !19, !23, !25, !27, !29, !31, !33, !35, !37, !39, !41, !43, !45, !47, !49, !51, !53, !55, !57, !59, !61, !63, !65, !67, !69, !71, !73, !76, !98, !102, !114, !123, !125, !131, !150, !152}
!19 = !DIGlobalVariableExpression(var: !20, expr: !DIExpression())
!20 = distinct !DIGlobalVariable(name: "LL_GPIO_SPEED_FREQ_MEDIUM", scope: !2, file: !21, line: 34, type: !22, isLocal: false, isDefinition: true)
!21 = !DIFile(filename: "../appl/FreeRTOS/GPSLogger/Src/common.h", directory: "/home/gerion/sourcecode/ara/build")
!22 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !16, line: 24, baseType: !6)
!23 = !DIGlobalVariableExpression(var: !24, expr: !DIExpression())
!24 = distinct !DIGlobalVariable(name: "LL_GPIO_SPEED_FREQ_LOW", scope: !2, file: !21, line: 35, type: !22, isLocal: false, isDefinition: true)
!25 = !DIGlobalVariableExpression(var: !26, expr: !DIExpression())
!26 = distinct !DIGlobalVariable(name: "LL_GPIO_OUTPUT_PUSHPULL", scope: !2, file: !21, line: 36, type: !22, isLocal: false, isDefinition: true)
!27 = !DIGlobalVariableExpression(var: !28, expr: !DIExpression())
!28 = distinct !DIGlobalVariable(name: "LL_GPIO_MODE_OUTPUT", scope: !2, file: !21, line: 37, type: !22, isLocal: false, isDefinition: true)
!29 = !DIGlobalVariableExpression(var: !30, expr: !DIExpression())
!30 = distinct !DIGlobalVariable(name: "LL_GPIO_MODE_ALTERNATE", scope: !2, file: !21, line: 38, type: !22, isLocal: false, isDefinition: true)
!31 = !DIGlobalVariableExpression(var: !32, expr: !DIExpression())
!32 = distinct !DIGlobalVariable(name: "LL_GPIO_PIN_0", scope: !2, file: !21, line: 39, type: !22, isLocal: false, isDefinition: true)
!33 = !DIGlobalVariableExpression(var: !34, expr: !DIExpression())
!34 = distinct !DIGlobalVariable(name: "LL_GPIO_PIN_1", scope: !2, file: !21, line: 40, type: !22, isLocal: false, isDefinition: true)
!35 = !DIGlobalVariableExpression(var: !36, expr: !DIExpression())
!36 = distinct !DIGlobalVariable(name: "LL_GPIO_PIN_2", scope: !2, file: !21, line: 41, type: !22, isLocal: false, isDefinition: true)
!37 = !DIGlobalVariableExpression(var: !38, expr: !DIExpression())
!38 = distinct !DIGlobalVariable(name: "LL_GPIO_PIN_3", scope: !2, file: !21, line: 42, type: !22, isLocal: false, isDefinition: true)
!39 = !DIGlobalVariableExpression(var: !40, expr: !DIExpression())
!40 = distinct !DIGlobalVariable(name: "LL_GPIO_PIN_4", scope: !2, file: !21, line: 43, type: !22, isLocal: false, isDefinition: true)
!41 = !DIGlobalVariableExpression(var: !42, expr: !DIExpression())
!42 = distinct !DIGlobalVariable(name: "LL_GPIO_PIN_5", scope: !2, file: !21, line: 44, type: !22, isLocal: false, isDefinition: true)
!43 = !DIGlobalVariableExpression(var: !44, expr: !DIExpression())
!44 = distinct !DIGlobalVariable(name: "LL_GPIO_PIN_6", scope: !2, file: !21, line: 45, type: !22, isLocal: false, isDefinition: true)
!45 = !DIGlobalVariableExpression(var: !46, expr: !DIExpression())
!46 = distinct !DIGlobalVariable(name: "LL_GPIO_PIN_7", scope: !2, file: !21, line: 46, type: !22, isLocal: false, isDefinition: true)
!47 = !DIGlobalVariableExpression(var: !48, expr: !DIExpression())
!48 = distinct !DIGlobalVariable(name: "LL_GPIO_PIN_8", scope: !2, file: !21, line: 47, type: !22, isLocal: false, isDefinition: true)
!49 = !DIGlobalVariableExpression(var: !50, expr: !DIExpression())
!50 = distinct !DIGlobalVariable(name: "LL_GPIO_PIN_9", scope: !2, file: !21, line: 48, type: !22, isLocal: false, isDefinition: true)
!51 = !DIGlobalVariableExpression(var: !52, expr: !DIExpression())
!52 = distinct !DIGlobalVariable(name: "LL_GPIO_PIN_10", scope: !2, file: !21, line: 49, type: !22, isLocal: false, isDefinition: true)
!53 = !DIGlobalVariableExpression(var: !54, expr: !DIExpression())
!54 = distinct !DIGlobalVariable(name: "LL_GPIO_PIN_11", scope: !2, file: !21, line: 50, type: !22, isLocal: false, isDefinition: true)
!55 = !DIGlobalVariableExpression(var: !56, expr: !DIExpression())
!56 = distinct !DIGlobalVariable(name: "LL_GPIO_PIN_12", scope: !2, file: !21, line: 51, type: !22, isLocal: false, isDefinition: true)
!57 = !DIGlobalVariableExpression(var: !58, expr: !DIExpression())
!58 = distinct !DIGlobalVariable(name: "LL_GPIO_PIN_13", scope: !2, file: !21, line: 52, type: !22, isLocal: false, isDefinition: true)
!59 = !DIGlobalVariableExpression(var: !60, expr: !DIExpression())
!60 = distinct !DIGlobalVariable(name: "LL_GPIO_PIN_14", scope: !2, file: !21, line: 53, type: !22, isLocal: false, isDefinition: true)
!61 = !DIGlobalVariableExpression(var: !62, expr: !DIExpression())
!62 = distinct !DIGlobalVariable(name: "LL_GPIO_PIN_15", scope: !2, file: !21, line: 54, type: !22, isLocal: false, isDefinition: true)
!63 = !DIGlobalVariableExpression(var: !64, expr: !DIExpression())
!64 = distinct !DIGlobalVariable(name: "LL_GPIO_PIN_16", scope: !2, file: !21, line: 55, type: !22, isLocal: false, isDefinition: true)
!65 = !DIGlobalVariableExpression(var: !66, expr: !DIExpression())
!66 = distinct !DIGlobalVariable(name: "LL_GPIO_PULL_UP", scope: !2, file: !21, line: 56, type: !22, isLocal: false, isDefinition: true)
!67 = !DIGlobalVariableExpression(var: !68, expr: !DIExpression())
!68 = distinct !DIGlobalVariable(name: "LL_GPIO_MODE_INPUT", scope: !2, file: !21, line: 57, type: !22, isLocal: false, isDefinition: true)
!69 = !DIGlobalVariableExpression(var: !70, expr: !DIExpression())
!70 = distinct !DIGlobalVariable(name: "GPIOC", scope: !2, file: !21, line: 58, type: !22, isLocal: false, isDefinition: true)
!71 = !DIGlobalVariableExpression(var: !72, expr: !DIExpression())
!72 = distinct !DIGlobalVariable(name: "GPIOB", scope: !2, file: !21, line: 59, type: !22, isLocal: false, isDefinition: true)
!73 = !DIGlobalVariableExpression(var: !74, expr: !DIExpression())
!74 = distinct !DIGlobalVariable(name: "SPI2", scope: !2, file: !21, line: 60, type: !75, isLocal: false, isDefinition: true)
!75 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 32)
!76 = !DIGlobalVariableExpression(var: !77, expr: !DIExpression())
!77 = distinct !DIGlobalVariable(name: "Serial", scope: !2, file: !3, line: 26, type: !78, isLocal: false, isDefinition: true)
!78 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "CharWriter", file: !3, line: 12, size: 32, flags: DIFlagTypePassByReference, elements: !79, vtableHolder: !78, identifier: "_ZTS10CharWriter")
!79 = !{!80, !86, !95}
!80 = !DIDerivedType(tag: DW_TAG_member, name: "_vptr$CharWriter", scope: !3, file: !3, baseType: !81, size: 32, flags: DIFlagArtificial)
!81 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !82, size: 32)
!82 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "__vtbl_ptr_type", baseType: !83, size: 32)
!83 = !DISubroutineType(types: !84)
!84 = !{!85}
!85 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!86 = !DISubprogram(name: "write", linkageName: "_ZN10CharWriter5writeEPKc", scope: !78, file: !3, line: 14, type: !87, isLocal: false, isDefinition: false, scopeLine: 14, containingType: !78, virtuality: DW_VIRTUALITY_virtual, virtualIndex: 0, flags: DIFlagPrototyped, isOptimized: false)
!87 = !DISubroutineType(types: !88)
!88 = !{!89, !91, !92}
!89 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !90, line: 62, baseType: !6)
!90 = !DIFile(filename: "/usr/lib64/llvm/7/bin/../../../../lib/clang/7.0.1/include/stddef.h", directory: "/home/gerion/sourcecode/ara/build")
!91 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !78, size: 32, flags: DIFlagArtificial | DIFlagObjectPointer)
!92 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !93, size: 32)
!93 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !94)
!94 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!95 = !DISubprogram(name: "write", linkageName: "_ZN10CharWriter5writeEc", scope: !78, file: !3, line: 18, type: !96, isLocal: false, isDefinition: false, scopeLine: 18, containingType: !78, virtuality: DW_VIRTUALITY_virtual, virtualIndex: 1, flags: DIFlagPrototyped, isOptimized: false)
!96 = !DISubroutineType(types: !97)
!97 = !{!89, !91, !94}
!98 = !DIGlobalVariableExpression(var: !99, expr: !DIExpression())
!99 = distinct !DIGlobalVariable(name: "spiDriver", scope: !2, file: !3, line: 52, type: !100, isLocal: false, isDefinition: true)
!100 = !DICompositeType(tag: DW_TAG_class_type, name: "SdFatSPIDriver", file: !101, line: 18, flags: DIFlagFwdDecl, identifier: "_ZTS14SdFatSPIDriver")
!101 = !DIFile(filename: "../appl/FreeRTOS/GPSLogger/Src/SdFatSPIDriver.h", directory: "/home/gerion/sourcecode/ara/build")
!102 = !DIGlobalVariableExpression(var: !103, expr: !DIExpression())
!103 = distinct !DIGlobalVariable(name: "SD", scope: !2, file: !3, line: 57, type: !104, isLocal: false, isDefinition: true)
!104 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "SdFat", file: !3, line: 38, size: 8, flags: DIFlagTypePassByValue, elements: !105, identifier: "_ZTS5SdFat")
!105 = !{!106, !111}
!106 = !DISubprogram(name: "SdFat", scope: !104, file: !3, line: 42, type: !107, isLocal: false, isDefinition: false, scopeLine: 42, flags: DIFlagPublic | DIFlagPrototyped, isOptimized: false)
!107 = !DISubroutineType(types: !108)
!108 = !{null, !109, !110}
!109 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !104, size: 32, flags: DIFlagArtificial | DIFlagObjectPointer)
!110 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !100, size: 32)
!111 = !DISubprogram(name: "begin", linkageName: "_ZN5SdFat5beginEj", scope: !104, file: !3, line: 44, type: !112, isLocal: false, isDefinition: false, scopeLine: 44, flags: DIFlagPublic | DIFlagPrototyped, isOptimized: false)
!112 = !DISubroutineType(types: !113)
!113 = !{!22, !109, !22}
!114 = !DIGlobalVariableExpression(var: !115, expr: !DIExpression())
!115 = distinct !DIGlobalVariable(name: "rawDataFile", scope: !2, file: !3, line: 64, type: !116, isLocal: false, isDefinition: true)
!116 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "FatFile", file: !21, line: 93, size: 8, flags: DIFlagTypePassByValue | DIFlagTrivial, elements: !117, identifier: "_ZTS7FatFile")
!117 = !{!118}
!118 = !DISubprogram(name: "write", linkageName: "_ZN7FatFile5writeEPch", scope: !116, file: !21, line: 97, type: !119, isLocal: false, isDefinition: false, scopeLine: 97, flags: DIFlagPublic | DIFlagPrototyped, isOptimized: false)
!119 = !DISubroutineType(types: !120)
!120 = !{null, !121, !122, !15}
!121 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !116, size: 32, flags: DIFlagArtificial | DIFlagObjectPointer)
!122 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !94, size: 32)
!123 = !DIGlobalVariableExpression(var: !124, expr: !DIExpression())
!124 = distinct !DIGlobalVariable(name: "bulkFile", scope: !2, file: !3, line: 65, type: !116, isLocal: false, isDefinition: true)
!125 = !DIGlobalVariableExpression(var: !126, expr: !DIExpression())
!126 = distinct !DIGlobalVariable(name: "sdQueue", scope: !2, file: !3, line: 91, type: !127, isLocal: false, isDefinition: true)
!127 = !DIDerivedType(tag: DW_TAG_typedef, name: "QueueHandle_t", file: !128, line: 48, baseType: !129)
!128 = !DIFile(filename: "/home/gerion/sourcecode/ara/appl/FreeRTOS/GPSLogger/Libs/FreeRTOS/queue.h", directory: "/home/gerion/sourcecode/ara/build")
!129 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !130, size: 32)
!130 = !DICompositeType(tag: DW_TAG_structure_type, name: "QueueDefinition", file: !128, line: 47, flags: DIFlagFwdDecl, identifier: "_ZTS15QueueDefinition")
!131 = !DIGlobalVariableExpression(var: !132, expr: !DIExpression())
!132 = distinct !DIGlobalVariable(name: "rawGPSDataBuf", scope: !2, file: !3, line: 97, type: !133, isLocal: false, isDefinition: true)
!133 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "SDMessage", file: !3, line: 80, size: 704, flags: DIFlagTypePassByValue | DIFlagTrivial, elements: !134, identifier: "_ZTS9SDMessage")
!134 = !{!135, !136, !139}
!135 = !DIDerivedType(tag: DW_TAG_member, name: "messageType", scope: !133, file: !3, line: 82, baseType: !5, size: 32)
!136 = !DIDerivedType(tag: DW_TAG_member, name: "msgIdx", scope: !133, file: !3, line: 83, baseType: !137, size: 16, offset: 32)
!137 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !16, line: 22, baseType: !138)
!138 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!139 = !DIDerivedType(tag: DW_TAG_member, scope: !133, file: !3, line: 85, baseType: !140, size: 656, offset: 48)
!140 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !133, file: !3, line: 85, size: 656, flags: DIFlagTypePassByValue | DIFlagTrivial, elements: !141, identifier: "_ZTSN9SDMessageUt_E")
!141 = !{!142}
!142 = !DIDerivedType(tag: DW_TAG_member, name: "rawData", scope: !140, file: !3, line: 87, baseType: !143, size: 656)
!143 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "RawGPSData", file: !3, line: 74, size: 656, flags: DIFlagTypePassByValue | DIFlagTrivial, elements: !144, identifier: "_ZTS10RawGPSData")
!144 = !{!145, !146}
!145 = !DIDerivedType(tag: DW_TAG_member, name: "len", scope: !143, file: !3, line: 76, baseType: !15, size: 8)
!146 = !DIDerivedType(tag: DW_TAG_member, name: "rawDataBuf", scope: !143, file: !3, line: 77, baseType: !147, size: 648, offset: 8)
!147 = !DICompositeType(tag: DW_TAG_array_type, baseType: !94, size: 648, elements: !148)
!148 = !{!149}
!149 = !DISubrange(count: 81)
!150 = !DIGlobalVariableExpression(var: !151, expr: !DIExpression())
!151 = distinct !DIGlobalVariable(name: "msgIdx", scope: !2, file: !3, line: 98, type: !137, isLocal: false, isDefinition: true)
!152 = !DIGlobalVariableExpression(var: !153, expr: !DIExpression())
!153 = distinct !DIGlobalVariable(name: "sd_buf", scope: !2, file: !3, line: 153, type: !154, isLocal: false, isDefinition: true)
!154 = !DICompositeType(tag: DW_TAG_array_type, baseType: !15, size: 4096, elements: !155)
!155 = !{!156}
!156 = !DISubrange(count: 512)
!157 = !{!158, !165, !169, !175, !179, !184, !186, !191, !195, !199, !209, !213, !217, !221, !225, !229, !233, !237, !241, !245, !253, !257, !261, !263, !265, !269, !273, !279, !283, !288, !290, !298, !302, !310, !312, !316, !320, !324, !328, !333, !338, !343, !344, !345, !346, !348, !349, !350, !351, !352, !353, !354, !356, !357, !358, !359, !360, !361, !362, !366, !367, !368, !369, !370, !371, !372, !373, !374, !375, !376, !377, !378, !379, !380, !381, !382, !383, !384, !385, !386, !387, !388, !389}
!158 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !160, file: !164, line: 52)
!159 = !DINamespace(name: "std", scope: null)
!160 = !DISubprogram(name: "abs", scope: !161, file: !161, line: 837, type: !162, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!161 = !DIFile(filename: "/usr/include/stdlib.h", directory: "/home/gerion/sourcecode/ara/build")
!162 = !DISubroutineType(types: !163)
!163 = !{!85, !85}
!164 = !DIFile(filename: "/usr/lib/gcc/x86_64-pc-linux-gnu/8.3.0/include/g++-v8/bits/std_abs.h", directory: "/home/gerion/sourcecode/ara/build")
!165 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !166, file: !168, line: 127)
!166 = !DIDerivedType(tag: DW_TAG_typedef, name: "div_t", file: !161, line: 62, baseType: !167)
!167 = !DICompositeType(tag: DW_TAG_structure_type, file: !161, line: 58, flags: DIFlagFwdDecl, identifier: "_ZTS5div_t")
!168 = !DIFile(filename: "/usr/lib/gcc/x86_64-pc-linux-gnu/8.3.0/include/g++-v8/cstdlib", directory: "/home/gerion/sourcecode/ara/build")
!169 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !170, file: !168, line: 128)
!170 = !DIDerivedType(tag: DW_TAG_typedef, name: "ldiv_t", file: !161, line: 70, baseType: !171)
!171 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !161, line: 66, size: 64, flags: DIFlagTypePassByValue | DIFlagTrivial, elements: !172, identifier: "_ZTS6ldiv_t")
!172 = !{!173, !174}
!173 = !DIDerivedType(tag: DW_TAG_member, name: "quot", scope: !171, file: !161, line: 68, baseType: !14, size: 32)
!174 = !DIDerivedType(tag: DW_TAG_member, name: "rem", scope: !171, file: !161, line: 69, baseType: !14, size: 32, offset: 32)
!175 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !176, file: !168, line: 130)
!176 = !DISubprogram(name: "abort", scope: !161, file: !161, line: 588, type: !177, isLocal: false, isDefinition: false, flags: DIFlagPrototyped | DIFlagNoReturn, isOptimized: false)
!177 = !DISubroutineType(types: !178)
!178 = !{null}
!179 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !180, file: !168, line: 134)
!180 = !DISubprogram(name: "atexit", scope: !161, file: !161, line: 592, type: !181, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!181 = !DISubroutineType(types: !182)
!182 = !{!85, !183}
!183 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !177, size: 32)
!184 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !185, file: !168, line: 137)
!185 = !DISubprogram(name: "at_quick_exit", scope: !161, file: !161, line: 597, type: !181, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!186 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !187, file: !168, line: 140)
!187 = !DISubprogram(name: "atof", scope: !161, file: !161, line: 101, type: !188, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!188 = !DISubroutineType(types: !189)
!189 = !{!190, !92}
!190 = !DIBasicType(name: "double", size: 64, encoding: DW_ATE_float)
!191 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !192, file: !168, line: 141)
!192 = !DISubprogram(name: "atoi", scope: !161, file: !161, line: 104, type: !193, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!193 = !DISubroutineType(types: !194)
!194 = !{!85, !92}
!195 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !196, file: !168, line: 142)
!196 = !DISubprogram(name: "atol", scope: !161, file: !161, line: 107, type: !197, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!197 = !DISubroutineType(types: !198)
!198 = !{!14, !92}
!199 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !200, file: !168, line: 143)
!200 = !DISubprogram(name: "bsearch", scope: !161, file: !161, line: 817, type: !201, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!201 = !DISubroutineType(types: !202)
!202 = !{!75, !203, !203, !89, !89, !205}
!203 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !204, size: 32)
!204 = !DIDerivedType(tag: DW_TAG_const_type, baseType: null)
!205 = !DIDerivedType(tag: DW_TAG_typedef, name: "__compar_fn_t", file: !161, line: 805, baseType: !206)
!206 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !207, size: 32)
!207 = !DISubroutineType(types: !208)
!208 = !{!85, !203, !203}
!209 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !210, file: !168, line: 144)
!210 = !DISubprogram(name: "calloc", scope: !161, file: !161, line: 541, type: !211, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!211 = !DISubroutineType(types: !212)
!212 = !{!75, !89, !89}
!213 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !214, file: !168, line: 145)
!214 = !DISubprogram(name: "div", scope: !161, file: !161, line: 849, type: !215, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!215 = !DISubroutineType(types: !216)
!216 = !{!166, !85, !85}
!217 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !218, file: !168, line: 146)
!218 = !DISubprogram(name: "exit", scope: !161, file: !161, line: 614, type: !219, isLocal: false, isDefinition: false, flags: DIFlagPrototyped | DIFlagNoReturn, isOptimized: false)
!219 = !DISubroutineType(types: !220)
!220 = !{null, !85}
!221 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !222, file: !168, line: 147)
!222 = !DISubprogram(name: "free", scope: !161, file: !161, line: 563, type: !223, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!223 = !DISubroutineType(types: !224)
!224 = !{null, !75}
!225 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !226, file: !168, line: 148)
!226 = !DISubprogram(name: "getenv", scope: !161, file: !161, line: 631, type: !227, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!227 = !DISubroutineType(types: !228)
!228 = !{!122, !92}
!229 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !230, file: !168, line: 149)
!230 = !DISubprogram(name: "labs", scope: !161, file: !161, line: 838, type: !231, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!231 = !DISubroutineType(types: !232)
!232 = !{!14, !14}
!233 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !234, file: !168, line: 150)
!234 = !DISubprogram(name: "ldiv", scope: !161, file: !161, line: 851, type: !235, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!235 = !DISubroutineType(types: !236)
!236 = !{!170, !14, !14}
!237 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !238, file: !168, line: 151)
!238 = !DISubprogram(name: "malloc", scope: !161, file: !161, line: 539, type: !239, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!239 = !DISubroutineType(types: !240)
!240 = !{!75, !89}
!241 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !242, file: !168, line: 153)
!242 = !DISubprogram(name: "mblen", scope: !161, file: !161, line: 919, type: !243, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!243 = !DISubroutineType(types: !244)
!244 = !{!85, !92, !89}
!245 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !246, file: !168, line: 154)
!246 = !DISubprogram(name: "mbstowcs", scope: !161, file: !161, line: 930, type: !247, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!247 = !DISubroutineType(types: !248)
!248 = !{!89, !249, !252, !89}
!249 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !250)
!250 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !251, size: 32)
!251 = !DIBasicType(name: "wchar_t", size: 32, encoding: DW_ATE_signed)
!252 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !92)
!253 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !254, file: !168, line: 155)
!254 = !DISubprogram(name: "mbtowc", scope: !161, file: !161, line: 922, type: !255, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!255 = !DISubroutineType(types: !256)
!256 = !{!85, !249, !252, !89}
!257 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !258, file: !168, line: 157)
!258 = !DISubprogram(name: "qsort", scope: !161, file: !161, line: 827, type: !259, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!259 = !DISubroutineType(types: !260)
!260 = !{null, !75, !89, !89, !205}
!261 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !262, file: !168, line: 160)
!262 = !DISubprogram(name: "quick_exit", scope: !161, file: !161, line: 620, type: !219, isLocal: false, isDefinition: false, flags: DIFlagPrototyped | DIFlagNoReturn, isOptimized: false)
!263 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !264, file: !168, line: 163)
!264 = !DISubprogram(name: "rand", scope: !161, file: !161, line: 453, type: !83, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!265 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !266, file: !168, line: 164)
!266 = !DISubprogram(name: "realloc", scope: !161, file: !161, line: 549, type: !267, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!267 = !DISubroutineType(types: !268)
!268 = !{!75, !75, !89}
!269 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !270, file: !168, line: 165)
!270 = !DISubprogram(name: "srand", scope: !161, file: !161, line: 455, type: !271, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!271 = !DISubroutineType(types: !272)
!272 = !{null, !6}
!273 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !274, file: !168, line: 166)
!274 = !DISubprogram(name: "strtod", scope: !161, file: !161, line: 117, type: !275, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!275 = !DISubroutineType(types: !276)
!276 = !{!190, !252, !277}
!277 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !278)
!278 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !122, size: 32)
!279 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !280, file: !168, line: 167)
!280 = !DISubprogram(name: "strtol", scope: !161, file: !161, line: 176, type: !281, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!281 = !DISubroutineType(types: !282)
!282 = !{!14, !252, !277, !85}
!283 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !284, file: !168, line: 168)
!284 = !DISubprogram(name: "strtoul", scope: !161, file: !161, line: 180, type: !285, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!285 = !DISubroutineType(types: !286)
!286 = !{!287, !252, !277, !85}
!287 = !DIBasicType(name: "long unsigned int", size: 32, encoding: DW_ATE_unsigned)
!288 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !289, file: !168, line: 169)
!289 = !DISubprogram(name: "system", scope: !161, file: !161, line: 781, type: !193, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!290 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !291, file: !168, line: 171)
!291 = !DISubprogram(name: "wcstombs", scope: !161, file: !161, line: 933, type: !292, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!292 = !DISubroutineType(types: !293)
!293 = !{!89, !294, !295, !89}
!294 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !122)
!295 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !296)
!296 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !297, size: 32)
!297 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !251)
!298 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !299, file: !168, line: 172)
!299 = !DISubprogram(name: "wctomb", scope: !161, file: !161, line: 926, type: !300, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!300 = !DISubroutineType(types: !301)
!301 = !{!85, !122, !251}
!302 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !303, entity: !304, file: !168, line: 200)
!303 = !DINamespace(name: "__gnu_cxx", scope: null)
!304 = !DIDerivedType(tag: DW_TAG_typedef, name: "lldiv_t", file: !161, line: 80, baseType: !305)
!305 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !161, line: 76, size: 128, flags: DIFlagTypePassByValue | DIFlagTrivial, elements: !306, identifier: "_ZTS7lldiv_t")
!306 = !{!307, !309}
!307 = !DIDerivedType(tag: DW_TAG_member, name: "quot", scope: !305, file: !161, line: 78, baseType: !308, size: 64)
!308 = !DIBasicType(name: "long long int", size: 64, encoding: DW_ATE_signed)
!309 = !DIDerivedType(tag: DW_TAG_member, name: "rem", scope: !305, file: !161, line: 79, baseType: !308, size: 64, offset: 64)
!310 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !303, entity: !311, file: !168, line: 206)
!311 = !DISubprogram(name: "_Exit", scope: !161, file: !161, line: 626, type: !219, isLocal: false, isDefinition: false, flags: DIFlagPrototyped | DIFlagNoReturn, isOptimized: false)
!312 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !303, entity: !313, file: !168, line: 210)
!313 = !DISubprogram(name: "llabs", scope: !161, file: !161, line: 841, type: !314, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!314 = !DISubroutineType(types: !315)
!315 = !{!308, !308}
!316 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !303, entity: !317, file: !168, line: 216)
!317 = !DISubprogram(name: "lldiv", scope: !161, file: !161, line: 855, type: !318, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!318 = !DISubroutineType(types: !319)
!319 = !{!304, !308, !308}
!320 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !303, entity: !321, file: !168, line: 227)
!321 = !DISubprogram(name: "atoll", scope: !161, file: !161, line: 112, type: !322, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!322 = !DISubroutineType(types: !323)
!323 = !{!308, !92}
!324 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !303, entity: !325, file: !168, line: 228)
!325 = !DISubprogram(name: "strtoll", scope: !161, file: !161, line: 200, type: !326, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!326 = !DISubroutineType(types: !327)
!327 = !{!308, !252, !277, !85}
!328 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !303, entity: !329, file: !168, line: 229)
!329 = !DISubprogram(name: "strtoull", scope: !161, file: !161, line: 205, type: !330, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!330 = !DISubroutineType(types: !331)
!331 = !{!332, !252, !277, !85}
!332 = !DIBasicType(name: "long long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!333 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !303, entity: !334, file: !168, line: 231)
!334 = !DISubprogram(name: "strtof", scope: !161, file: !161, line: 123, type: !335, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!335 = !DISubroutineType(types: !336)
!336 = !{!337, !252, !277}
!337 = !DIBasicType(name: "float", size: 32, encoding: DW_ATE_float)
!338 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !303, entity: !339, file: !168, line: 232)
!339 = !DISubprogram(name: "strtold", scope: !161, file: !161, line: 126, type: !340, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!340 = !DISubroutineType(types: !341)
!341 = !{!342, !252, !277}
!342 = !DIBasicType(name: "long double", size: 96, encoding: DW_ATE_float)
!343 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !304, file: !168, line: 240)
!344 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !311, file: !168, line: 242)
!345 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !313, file: !168, line: 244)
!346 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !347, file: !168, line: 245)
!347 = !DISubprogram(name: "div", linkageName: "_ZN9__gnu_cxx3divExx", scope: !303, file: !168, line: 213, type: !318, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!348 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !317, file: !168, line: 246)
!349 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !321, file: !168, line: 248)
!350 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !334, file: !168, line: 249)
!351 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !325, file: !168, line: 250)
!352 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !329, file: !168, line: 251)
!353 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !159, entity: !339, file: !168, line: 252)
!354 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !176, file: !355, line: 38)
!355 = !DIFile(filename: "/usr/lib/gcc/x86_64-pc-linux-gnu/8.3.0/include/g++-v8/stdlib.h", directory: "/home/gerion/sourcecode/ara/build")
!356 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !180, file: !355, line: 39)
!357 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !218, file: !355, line: 40)
!358 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !185, file: !355, line: 43)
!359 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !262, file: !355, line: 46)
!360 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !166, file: !355, line: 51)
!361 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !170, file: !355, line: 52)
!362 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !363, file: !355, line: 54)
!363 = !DISubprogram(name: "abs", linkageName: "_ZSt3abse", scope: !159, file: !164, line: 78, type: !364, isLocal: false, isDefinition: false, flags: DIFlagPrototyped, isOptimized: false)
!364 = !DISubroutineType(types: !365)
!365 = !{!342, !342}
!366 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !187, file: !355, line: 55)
!367 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !192, file: !355, line: 56)
!368 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !196, file: !355, line: 57)
!369 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !200, file: !355, line: 58)
!370 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !210, file: !355, line: 59)
!371 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !347, file: !355, line: 60)
!372 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !222, file: !355, line: 61)
!373 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !226, file: !355, line: 62)
!374 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !230, file: !355, line: 63)
!375 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !234, file: !355, line: 64)
!376 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !238, file: !355, line: 65)
!377 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !242, file: !355, line: 67)
!378 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !246, file: !355, line: 68)
!379 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !254, file: !355, line: 69)
!380 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !258, file: !355, line: 71)
!381 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !264, file: !355, line: 72)
!382 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !266, file: !355, line: 73)
!383 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !270, file: !355, line: 74)
!384 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !274, file: !355, line: 75)
!385 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !280, file: !355, line: 76)
!386 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !284, file: !355, line: 77)
!387 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !289, file: !355, line: 78)
!388 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !291, file: !355, line: 80)
!389 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !2, entity: !299, file: !355, line: 81)
!390 = !{i32 1, !"NumRegisterParameters", i32 0}
!391 = !{i32 2, !"Dwarf Version", i32 4}
!392 = !{i32 2, !"Debug Info Version", i32 3}
!393 = !{i32 1, !"wchar_size", i32 4}
!394 = !{!"clang version 7.0.1 (tags/RELEASE_701/final)"}
!395 = distinct !DISubprogram(name: "__cxx_global_var_init", scope: !3, file: !3, line: 52, type: !177, isLocal: true, isDefinition: true, scopeLine: 52, flags: DIFlagPrototyped, isOptimized: false, unit: !2, retainedNodes: !396)
!396 = !{}
!397 = !DILocation(line: 52, column: 16, scope: !395)
!398 = distinct !DISubprogram(name: "SdFatSPIDriver", linkageName: "_ZN14SdFatSPIDriverC2Ev", scope: !100, file: !101, line: 18, type: !399, isLocal: false, isDefinition: true, scopeLine: 18, flags: DIFlagArtificial | DIFlagPrototyped, isOptimized: false, unit: !2, declaration: !402, retainedNodes: !396)
!399 = !DISubroutineType(types: !400)
!400 = !{null, !401}
!401 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !100, size: 32, flags: DIFlagArtificial | DIFlagObjectPointer)
!402 = !DISubprogram(name: "SdFatSPIDriver", scope: !100, type: !399, isLocal: false, isDefinition: false, flags: DIFlagPublic | DIFlagArtificial | DIFlagPrototyped, isOptimized: false)
!403 = !DILocalVariable(name: "this", arg: 1, scope: !398, type: !110, flags: DIFlagArtificial | DIFlagObjectPointer)
!404 = !DILocation(line: 0, scope: !398)
!405 = !DILocation(line: 18, column: 7, scope: !398)
!406 = !DILocation(line: 26, column: 20, scope: !398)
!407 = distinct !DISubprogram(name: "__cxx_global_var_init.1", scope: !3, file: !3, line: 57, type: !177, isLocal: true, isDefinition: true, scopeLine: 57, flags: DIFlagPrototyped, isOptimized: false, unit: !2, retainedNodes: !396)
!408 = !DILocation(line: 57, column: 7, scope: !407)
!409 = !DILocation(line: 57, column: 11, scope: !407)
!410 = distinct !DISubprogram(name: "SdFat", linkageName: "_ZN5SdFatC2EP14SdFatSPIDriver", scope: !104, file: !3, line: 42, type: !107, isLocal: false, isDefinition: true, scopeLine: 42, flags: DIFlagPrototyped, isOptimized: false, unit: !2, declaration: !106, retainedNodes: !396)
!411 = !DILocalVariable(name: "this", arg: 1, scope: !410, type: !412, flags: DIFlagArtificial | DIFlagObjectPointer)
!412 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !104, size: 32)
!413 = !DILocation(line: 0, scope: !410)
!414 = !DILocalVariable(name: "sd", arg: 2, scope: !410, file: !3, line: 42, type: !110)
!415 = !DILocation(line: 42, column: 31, scope: !410)
!416 = !DILocation(line: 42, column: 35, scope: !410)
!417 = distinct !DISubprogram(name: "requestRawGPSBuffer", linkageName: "_Z19requestRawGPSBufferv", scope: !3, file: !3, line: 100, type: !418, isLocal: false, isDefinition: true, scopeLine: 101, flags: DIFlagPrototyped, isOptimized: false, unit: !2, retainedNodes: !396)
!418 = !DISubroutineType(types: !419)
!419 = !{!122}
!420 = !DILocation(line: 102, column: 2, scope: !417)
!421 = distinct !DISubprogram(name: "ackRawGPSData", linkageName: "_Z13ackRawGPSDatah", scope: !3, file: !3, line: 105, type: !422, isLocal: false, isDefinition: true, scopeLine: 106, flags: DIFlagPrototyped, isOptimized: false, unit: !2, retainedNodes: !396)
!422 = !DISubroutineType(types: !423)
!423 = !{null, !15}
!424 = !DILocalVariable(name: "len", arg: 1, scope: !421, file: !3, line: 105, type: !15)
!425 = !DILocation(line: 105, column: 28, scope: !421)
!426 = !DILocation(line: 107, column: 28, scope: !421)
!427 = !DILocation(line: 108, column: 30, scope: !421)
!428 = !DILocation(line: 108, column: 28, scope: !421)
!429 = !DILocation(line: 109, column: 31, scope: !421)
!430 = !DILocation(line: 109, column: 23, scope: !421)
!431 = !DILocation(line: 113, column: 2, scope: !421)
!432 = !DILocation(line: 114, column: 1, scope: !421)
!433 = distinct !DISubprogram(name: "initSDCard", linkageName: "_Z10initSDCardv", scope: !3, file: !3, line: 117, type: !434, isLocal: false, isDefinition: true, scopeLine: 118, flags: DIFlagPrototyped, isOptimized: false, unit: !2, retainedNodes: !396)
!434 = !DISubroutineType(types: !435)
!435 = !{!436}
!436 = !DIBasicType(name: "bool", size: 8, encoding: DW_ATE_boolean)
!437 = !DILocalVariable(name: "errno", scope: !433, file: !3, line: 124, type: !22)
!438 = !DILocation(line: 124, column: 11, scope: !433)
!439 = !DILocation(line: 124, column: 22, scope: !433)
!440 = !DILocation(line: 125, column: 6, scope: !441)
!441 = distinct !DILexicalBlock(scope: !433, file: !3, line: 125, column: 6)
!442 = !DILocation(line: 125, column: 6, scope: !433)
!443 = !DILocation(line: 129, column: 3, scope: !444)
!444 = distinct !DILexicalBlock(scope: !441, file: !3, line: 126, column: 2)
!445 = !DILocation(line: 140, column: 2, scope: !433)
!446 = !DILocation(line: 141, column: 1, scope: !433)
!447 = distinct !DISubprogram(name: "begin", linkageName: "_ZN5SdFat5beginEj", scope: !104, file: !3, line: 44, type: !112, isLocal: false, isDefinition: true, scopeLine: 44, flags: DIFlagPrototyped, isOptimized: false, unit: !2, declaration: !111, retainedNodes: !396)
!448 = !DILocalVariable(name: "this", arg: 1, scope: !447, type: !412, flags: DIFlagArtificial | DIFlagObjectPointer)
!449 = !DILocation(line: 0, scope: !447)
!450 = !DILocalVariable(name: "tmp", arg: 2, scope: !447, file: !3, line: 44, type: !22)
!451 = !DILocation(line: 44, column: 33, scope: !447)
!452 = !DILocation(line: 45, column: 20, scope: !447)
!453 = !DILocation(line: 45, column: 13, scope: !447)
!454 = distinct !DISubprogram(name: "saveRawData", linkageName: "_Z11saveRawDataRK9SDMessage", scope: !3, file: !3, line: 143, type: !455, isLocal: false, isDefinition: true, scopeLine: 144, flags: DIFlagPrototyped, isOptimized: false, unit: !2, retainedNodes: !396)
!455 = !DISubroutineType(types: !456)
!456 = !{null, !457}
!457 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !458, size: 32)
!458 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !133)
!459 = !DILocalVariable(name: "msg", arg: 1, scope: !454, file: !3, line: 143, type: !457)
!460 = !DILocation(line: 143, column: 36, scope: !454)
!461 = !DILocation(line: 150, column: 76, scope: !454)
!462 = !DILocation(line: 150, column: 14, scope: !454)
!463 = !DILocation(line: 151, column: 1, scope: !454)
!464 = distinct !DISubprogram(name: "runSDMessageLoop", linkageName: "_Z16runSDMessageLoopv", scope: !3, file: !3, line: 155, type: !177, isLocal: false, isDefinition: true, scopeLine: 156, flags: DIFlagPrototyped, isOptimized: false, unit: !2, retainedNodes: !396)
!465 = !DILocalVariable(name: "q", scope: !466, file: !3, line: 158, type: !137)
!466 = distinct !DILexicalBlock(scope: !464, file: !3, line: 158, column: 2)
!467 = !DILocation(line: 158, column: 15, scope: !466)
!468 = !DILocation(line: 158, column: 6, scope: !466)
!469 = !DILocation(line: 158, column: 22, scope: !470)
!470 = distinct !DILexicalBlock(scope: !466, file: !3, line: 158, column: 2)
!471 = !DILocation(line: 158, column: 23, scope: !470)
!472 = !DILocation(line: 158, column: 2, scope: !466)
!473 = !DILocation(line: 159, column: 15, scope: !470)
!474 = !DILocation(line: 159, column: 17, scope: !470)
!475 = !DILocation(line: 159, column: 10, scope: !470)
!476 = !DILocation(line: 159, column: 3, scope: !470)
!477 = !DILocation(line: 159, column: 13, scope: !470)
!478 = !DILocation(line: 158, column: 30, scope: !470)
!479 = !DILocation(line: 158, column: 2, scope: !470)
!480 = distinct !{!480, !472, !481}
!481 = !DILocation(line: 159, column: 19, scope: !466)
!482 = !DILocalVariable(name: "i", scope: !464, file: !3, line: 161, type: !22)
!483 = !DILocation(line: 161, column: 11, scope: !464)
!484 = !DILocalVariable(name: "prev", scope: !464, file: !3, line: 162, type: !22)
!485 = !DILocation(line: 162, column: 11, scope: !464)
!486 = !DILocation(line: 162, column: 18, scope: !464)
!487 = !DILocation(line: 163, column: 2, scope: !464)
!488 = !DILocalVariable(name: "msg", scope: !489, file: !3, line: 166, type: !133)
!489 = distinct !DILexicalBlock(scope: !464, file: !3, line: 164, column: 2)
!490 = !DILocation(line: 166, column: 13, scope: !489)
!491 = !DILocation(line: 167, column: 20, scope: !492)
!492 = distinct !DILexicalBlock(scope: !489, file: !3, line: 167, column: 6)
!493 = !DILocation(line: 167, column: 29, scope: !492)
!494 = !DILocation(line: 167, column: 6, scope: !492)
!495 = !DILocation(line: 167, column: 6, scope: !489)
!496 = !DILocation(line: 169, column: 15, scope: !497)
!497 = distinct !DILexicalBlock(scope: !492, file: !3, line: 168, column: 3)
!498 = !DILocation(line: 169, column: 4, scope: !497)
!499 = !DILocation(line: 173, column: 53, scope: !500)
!500 = distinct !DILexicalBlock(scope: !497, file: !3, line: 170, column: 4)
!501 = !DILocation(line: 173, column: 61, scope: !500)
!502 = !DILocation(line: 173, column: 49, scope: !500)
!503 = !DILocation(line: 173, column: 6, scope: !500)
!504 = !DILocation(line: 174, column: 5, scope: !500)
!505 = !DILocation(line: 176, column: 5, scope: !500)
!506 = !DILocation(line: 178, column: 3, scope: !497)
!507 = !DILocation(line: 192, column: 4, scope: !489)
!508 = !DILocalVariable(name: "cur", scope: !489, file: !3, line: 194, type: !22)
!509 = !DILocation(line: 194, column: 12, scope: !489)
!510 = !DILocation(line: 194, column: 18, scope: !489)
!511 = !DILocation(line: 195, column: 6, scope: !512)
!512 = distinct !DILexicalBlock(scope: !489, file: !3, line: 195, column: 6)
!513 = !DILocation(line: 195, column: 10, scope: !512)
!514 = !DILocation(line: 195, column: 9, scope: !512)
!515 = !DILocation(line: 195, column: 15, scope: !512)
!516 = !DILocation(line: 195, column: 6, scope: !489)
!517 = !DILocation(line: 198, column: 6, scope: !518)
!518 = distinct !DILexicalBlock(scope: !512, file: !3, line: 196, column: 3)
!519 = !DILocation(line: 201, column: 11, scope: !518)
!520 = !DILocation(line: 201, column: 9, scope: !518)
!521 = !DILocation(line: 202, column: 3, scope: !518)
!522 = distinct !{!522, !487, !523}
!523 = !DILocation(line: 203, column: 2, scope: !464)
!524 = !DILocation(line: 204, column: 1, scope: !464)
!525 = distinct !DISubprogram(name: "initSDThread", linkageName: "_Z12initSDThreadv", scope: !3, file: !3, line: 206, type: !177, isLocal: false, isDefinition: true, scopeLine: 207, flags: DIFlagPrototyped, isOptimized: false, unit: !2, retainedNodes: !396)
!526 = !DILocation(line: 209, column: 12, scope: !525)
!527 = !DILocation(line: 209, column: 10, scope: !525)
!528 = !DILocation(line: 210, column: 1, scope: !525)
!529 = distinct !DISubprogram(name: "vSDThread", linkageName: "_Z9vSDThreadPv", scope: !3, file: !3, line: 212, type: !223, isLocal: false, isDefinition: true, scopeLine: 213, flags: DIFlagPrototyped, isOptimized: false, unit: !2, retainedNodes: !396)
!530 = !DILocalVariable(name: "pvParameters", arg: 1, scope: !529, file: !3, line: 212, type: !75)
!531 = !DILocation(line: 212, column: 22, scope: !529)
!532 = !DILocation(line: 215, column: 2, scope: !529)
!533 = !DILocation(line: 218, column: 2, scope: !529)
!534 = !DILocation(line: 220, column: 3, scope: !535)
!535 = distinct !DILexicalBlock(scope: !529, file: !3, line: 219, column: 2)
!536 = !DILocation(line: 222, column: 6, scope: !537)
!537 = distinct !DILexicalBlock(scope: !535, file: !3, line: 222, column: 6)
!538 = !DILocation(line: 222, column: 6, scope: !535)
!539 = !DILocation(line: 223, column: 4, scope: !537)
!540 = distinct !{!540, !533, !541}
!541 = !DILocation(line: 226, column: 2, scope: !529)
!542 = !DILocation(line: 227, column: 1, scope: !529)
!543 = distinct !DISubprogram(name: "write", linkageName: "_ZN10CharWriter5writeEPKc", scope: !78, file: !3, line: 14, type: !87, isLocal: false, isDefinition: true, scopeLine: 14, flags: DIFlagPrototyped, isOptimized: false, unit: !2, declaration: !86, retainedNodes: !396)
!544 = !DILocalVariable(name: "this", arg: 1, scope: !543, type: !545, flags: DIFlagArtificial | DIFlagObjectPointer)
!545 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !78, size: 32)
!546 = !DILocation(line: 0, scope: !543)
!547 = !DILocalVariable(name: "s", arg: 2, scope: !543, file: !3, line: 14, type: !92)
!548 = !DILocation(line: 14, column: 37, scope: !543)
!549 = !DILocation(line: 15, column: 27, scope: !543)
!550 = !DILocation(line: 15, column: 5, scope: !543)
!551 = !DILocation(line: 16, column: 19, scope: !543)
!552 = !DILocation(line: 16, column: 12, scope: !543)
!553 = !DILocation(line: 16, column: 5, scope: !543)
!554 = distinct !DISubprogram(name: "write", linkageName: "_ZN10CharWriter5writeEc", scope: !78, file: !3, line: 18, type: !96, isLocal: false, isDefinition: true, scopeLine: 19, flags: DIFlagPrototyped, isOptimized: false, unit: !2, declaration: !95, retainedNodes: !396)
!555 = !DILocalVariable(name: "this", arg: 1, scope: !554, type: !545, flags: DIFlagArtificial | DIFlagObjectPointer)
!556 = !DILocation(line: 0, scope: !554)
!557 = !DILocalVariable(name: "c", arg: 2, scope: !554, file: !3, line: 18, type: !94)
!558 = !DILocation(line: 18, column: 28, scope: !554)
!559 = !DILocalVariable(name: "x", scope: !554, file: !3, line: 20, type: !560)
!560 = !DICompositeType(tag: DW_TAG_array_type, baseType: !94, size: 16, elements: !561)
!561 = !{!562}
!562 = !DISubrange(count: 2)
!563 = !DILocation(line: 20, column: 9, scope: !554)
!564 = !DILocation(line: 21, column: 11, scope: !554)
!565 = !DILocation(line: 21, column: 4, scope: !554)
!566 = !DILocation(line: 21, column: 9, scope: !554)
!567 = !DILocation(line: 22, column: 4, scope: !554)
!568 = !DILocation(line: 22, column: 9, scope: !554)
!569 = !DILocation(line: 23, column: 21, scope: !554)
!570 = !DILocation(line: 23, column: 4, scope: !554)
!571 = !DILocation(line: 24, column: 4, scope: !554)
!572 = distinct !DISubprogram(linkageName: "_GLOBAL__sub_I_SDThread.cpp", scope: !3, file: !3, type: !573, isLocal: true, isDefinition: true, flags: DIFlagArtificial, isOptimized: false, unit: !2, retainedNodes: !396)
!573 = !DISubroutineType(types: !396)
!574 = !DILocation(line: 0, scope: !572)
