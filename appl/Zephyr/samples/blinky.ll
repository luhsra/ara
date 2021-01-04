; ModuleID = 'llvm-link'
source_filename = "llvm-link"
target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "thumbv7em-none-unknown-eabi"

%struct.device = type { i8*, i8*, i8*, i8* }
%struct.gpio_driver_api = type { i32 (%struct.device*, i8, i32)*, i32 (%struct.device*, i32*)*, i32 (%struct.device*, i32, i32)*, i32 (%struct.device*, i32)*, i32 (%struct.device*, i32)*, i32 (%struct.device*, i32)*, i32 (%struct.device*, i8, i32, i32)*, i32 (%struct.device*, %struct.gpio_callback*, i1)*, i32 (%struct.device*)* }
%struct.gpio_callback = type { %struct._snode, void (%struct.device*, %struct.gpio_callback*, i32)*, i32 }
%struct._snode = type { %struct._snode* }
%struct.gpio_driver_config = type { i32 }
%struct.k_timeout_t = type { i64 }

@.str = private unnamed_addr constant [6 x i8] c"GPIOA\00", align 1

; Function Attrs: noinline nounwind optnone
define dso_local void @main() #0 !dbg !159 {
  %1 = alloca %struct.device*, align 4
  %2 = alloca i8, align 1
  %3 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %1, metadata !164, metadata !DIExpression()), !dbg !166
  call void @llvm.dbg.declare(metadata i8* %2, metadata !167, metadata !DIExpression()), !dbg !168
  store i8 1, i8* %2, align 1, !dbg !168
  call void @llvm.dbg.declare(metadata i32* %3, metadata !169, metadata !DIExpression()), !dbg !170
  %4 = call %struct.device* @device_get_binding(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str, i32 0, i32 0)) #3, !dbg !171
  store %struct.device* %4, %struct.device** %1, align 4, !dbg !172
  %5 = load %struct.device*, %struct.device** %1, align 4, !dbg !173
  %6 = icmp eq %struct.device* %5, null, !dbg !175
  br i1 %6, label %7, label %8, !dbg !176

7:                                                ; preds = %0
  br label %26, !dbg !177

8:                                                ; preds = %0
  %9 = load %struct.device*, %struct.device** %1, align 4, !dbg !179
  %10 = call i32 @gpio_pin_configure(%struct.device* %9, i8 zeroext 5, i32 6656) #3, !dbg !180
  store i32 %10, i32* %3, align 4, !dbg !181
  %11 = load i32, i32* %3, align 4, !dbg !182
  %12 = icmp slt i32 %11, 0, !dbg !184
  br i1 %12, label %13, label %14, !dbg !185

13:                                               ; preds = %8
  br label %26, !dbg !186

14:                                               ; preds = %8
  br label %15, !dbg !188

15:                                               ; preds = %15, %14
  %16 = load %struct.device*, %struct.device** %1, align 4, !dbg !189
  %17 = load i8, i8* %2, align 1, !dbg !191
  %18 = trunc i8 %17 to i1, !dbg !191
  %19 = zext i1 %18 to i32, !dbg !192
  %20 = call i32 @gpio_pin_set(%struct.device* %16, i8 zeroext 5, i32 %19) #3, !dbg !193
  %21 = load i8, i8* %2, align 1, !dbg !194
  %22 = trunc i8 %21 to i1, !dbg !194
  %23 = xor i1 %22, true, !dbg !195
  %24 = zext i1 %23 to i8, !dbg !196
  store i8 %24, i8* %2, align 1, !dbg !196
  %25 = call i32 @k_msleep(i32 1000) #3, !dbg !197
  br label %15, !dbg !188, !llvm.loop !198

26:                                               ; preds = %13, %7
  ret void, !dbg !200
}

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: noinline nounwind optnone
define internal %struct.device* @device_get_binding(i8*) #0 !dbg !201 {
  %2 = alloca i8*, align 4
  store i8* %0, i8** %2, align 4
  call void @llvm.dbg.declare(metadata i8** %2, metadata !205, metadata !DIExpression()), !dbg !206
  br label %3, !dbg !207

3:                                                ; preds = %1
  call void asm sideeffect "", "~{memory}"() #4, !dbg !208, !srcloc !210
  br label %4, !dbg !208

4:                                                ; preds = %3
  %5 = load i8*, i8** %2, align 4, !dbg !211
  %6 = call %struct.device* @z_impl_device_get_binding(i8* %5) #3, !dbg !212
  ret %struct.device* %6, !dbg !213
}

; Function Attrs: noinline nounwind optnone
define internal i32 @gpio_pin_configure(%struct.device*, i8 zeroext, i32) #0 !dbg !214 {
  %4 = alloca i32, align 4
  %5 = alloca %struct.device*, align 4
  %6 = alloca i8, align 1
  %7 = alloca i32, align 4
  %8 = alloca %struct.gpio_driver_api*, align 4
  %9 = alloca %struct.gpio_driver_config*, align 4
  %10 = alloca %struct.gpio_driver_config*, align 4
  %11 = alloca i32, align 4
  store %struct.device* %0, %struct.device** %5, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %5, metadata !215, metadata !DIExpression()), !dbg !216
  store i8 %1, i8* %6, align 1
  call void @llvm.dbg.declare(metadata i8* %6, metadata !217, metadata !DIExpression()), !dbg !218
  store i32 %2, i32* %7, align 4
  call void @llvm.dbg.declare(metadata i32* %7, metadata !219, metadata !DIExpression()), !dbg !220
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_api** %8, metadata !221, metadata !DIExpression()), !dbg !222
  %12 = load %struct.device*, %struct.device** %5, align 4, !dbg !223
  %13 = getelementptr inbounds %struct.device, %struct.device* %12, i32 0, i32 2, !dbg !224
  %14 = load i8*, i8** %13, align 4, !dbg !224
  %15 = bitcast i8* %14 to %struct.gpio_driver_api*, !dbg !225
  store %struct.gpio_driver_api* %15, %struct.gpio_driver_api** %8, align 4, !dbg !222
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_config** %9, metadata !226, metadata !DIExpression()), !dbg !228
  %16 = load %struct.device*, %struct.device** %5, align 4, !dbg !229
  %17 = getelementptr inbounds %struct.device, %struct.device* %16, i32 0, i32 1, !dbg !230
  %18 = load i8*, i8** %17, align 4, !dbg !230
  %19 = bitcast i8* %18 to %struct.gpio_driver_config*, !dbg !231
  store %struct.gpio_driver_config* %19, %struct.gpio_driver_config** %9, align 4, !dbg !228
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_config** %10, metadata !232, metadata !DIExpression()), !dbg !233
  %20 = load %struct.device*, %struct.device** %5, align 4, !dbg !234
  %21 = getelementptr inbounds %struct.device, %struct.device* %20, i32 0, i32 3, !dbg !235
  %22 = load i8*, i8** %21, align 4, !dbg !235
  %23 = bitcast i8* %22 to %struct.gpio_driver_config*, !dbg !236
  store %struct.gpio_driver_config* %23, %struct.gpio_driver_config** %10, align 4, !dbg !233
  call void @llvm.dbg.declare(metadata i32* %11, metadata !237, metadata !DIExpression()), !dbg !238
  %24 = load i32, i32* %7, align 4, !dbg !239
  %25 = and i32 %24, 4096, !dbg !241
  %26 = icmp ne i32 %25, 0, !dbg !242
  br i1 %26, label %27, label %38, !dbg !243

27:                                               ; preds = %3
  %28 = load i32, i32* %7, align 4, !dbg !244
  %29 = and i32 %28, 3072, !dbg !245
  %30 = icmp ne i32 %29, 0, !dbg !246
  br i1 %30, label %31, label %38, !dbg !247

31:                                               ; preds = %27
  %32 = load i32, i32* %7, align 4, !dbg !248
  %33 = and i32 %32, 1, !dbg !249
  %34 = icmp ne i32 %33, 0, !dbg !250
  br i1 %34, label %35, label %38, !dbg !251

35:                                               ; preds = %31
  %36 = load i32, i32* %7, align 4, !dbg !252
  %37 = xor i32 %36, 7168, !dbg !252
  store i32 %37, i32* %7, align 4, !dbg !252
  br label %38, !dbg !254

38:                                               ; preds = %35, %31, %27, %3
  %39 = load %struct.gpio_driver_config*, %struct.gpio_driver_config** %9, align 4, !dbg !255
  %40 = load %struct.device*, %struct.device** %5, align 4, !dbg !256
  %41 = load i8, i8* %6, align 1, !dbg !257
  %42 = load i32, i32* %7, align 4, !dbg !258
  %43 = call i32 @gpio_config(%struct.device* %40, i8 zeroext %41, i32 %42) #3, !dbg !259
  store i32 %43, i32* %11, align 4, !dbg !260
  %44 = load i32, i32* %11, align 4, !dbg !261
  %45 = icmp ne i32 %44, 0, !dbg !263
  br i1 %45, label %46, label %48, !dbg !264

46:                                               ; preds = %38
  %47 = load i32, i32* %11, align 4, !dbg !265
  store i32 %47, i32* %4, align 4, !dbg !267
  br label %87, !dbg !267

48:                                               ; preds = %38
  %49 = load i32, i32* %7, align 4, !dbg !268
  %50 = and i32 %49, 1, !dbg !270
  %51 = icmp ne i32 %50, 0, !dbg !271
  br i1 %51, label %52, label %60, !dbg !272

52:                                               ; preds = %48
  %53 = load i8, i8* %6, align 1, !dbg !273
  %54 = zext i8 %53 to i32, !dbg !273
  %55 = shl i32 1, %54, !dbg !273
  %56 = load %struct.gpio_driver_config*, %struct.gpio_driver_config** %10, align 4, !dbg !275
  %57 = getelementptr inbounds %struct.gpio_driver_config, %struct.gpio_driver_config* %56, i32 0, i32 0, !dbg !276
  %58 = load i32, i32* %57, align 4, !dbg !277
  %59 = or i32 %58, %55, !dbg !277
  store i32 %59, i32* %57, align 4, !dbg !277
  br label %69, !dbg !278

60:                                               ; preds = %48
  %61 = load i8, i8* %6, align 1, !dbg !279
  %62 = zext i8 %61 to i32, !dbg !279
  %63 = shl i32 1, %62, !dbg !279
  %64 = xor i32 %63, -1, !dbg !281
  %65 = load %struct.gpio_driver_config*, %struct.gpio_driver_config** %10, align 4, !dbg !282
  %66 = getelementptr inbounds %struct.gpio_driver_config, %struct.gpio_driver_config* %65, i32 0, i32 0, !dbg !283
  %67 = load i32, i32* %66, align 4, !dbg !284
  %68 = and i32 %67, %64, !dbg !284
  store i32 %68, i32* %66, align 4, !dbg !284
  br label %69

69:                                               ; preds = %60, %52
  %70 = load i32, i32* %7, align 4, !dbg !285
  %71 = and i32 %70, 24576, !dbg !287
  %72 = icmp ne i32 %71, 0, !dbg !288
  br i1 %72, label %73, label %85, !dbg !289

73:                                               ; preds = %69
  %74 = load %struct.gpio_driver_api*, %struct.gpio_driver_api** %8, align 4, !dbg !290
  %75 = getelementptr inbounds %struct.gpio_driver_api, %struct.gpio_driver_api* %74, i32 0, i32 6, !dbg !291
  %76 = load i32 (%struct.device*, i8, i32, i32)*, i32 (%struct.device*, i8, i32, i32)** %75, align 4, !dbg !291
  %77 = icmp ne i32 (%struct.device*, i8, i32, i32)* %76, null, !dbg !292
  br i1 %77, label %78, label %85, !dbg !293

78:                                               ; preds = %73
  %79 = load i32, i32* %7, align 4, !dbg !294
  %80 = and i32 %79, -524289, !dbg !294
  store i32 %80, i32* %7, align 4, !dbg !294
  %81 = load %struct.device*, %struct.device** %5, align 4, !dbg !296
  %82 = load i8, i8* %6, align 1, !dbg !297
  %83 = load i32, i32* %7, align 4, !dbg !298
  %84 = call i32 @z_impl_gpio_pin_interrupt_configure(%struct.device* %81, i8 zeroext %82, i32 %83) #3, !dbg !299
  store i32 %84, i32* %11, align 4, !dbg !300
  br label %85, !dbg !301

85:                                               ; preds = %78, %73, %69
  %86 = load i32, i32* %11, align 4, !dbg !302
  store i32 %86, i32* %4, align 4, !dbg !303
  br label %87, !dbg !303

87:                                               ; preds = %85, %46
  %88 = load i32, i32* %4, align 4, !dbg !304
  ret i32 %88, !dbg !304
}

; Function Attrs: noinline nounwind optnone
define internal i32 @gpio_pin_set(%struct.device*, i8 zeroext, i32) #0 !dbg !305 {
  %4 = alloca %struct.device*, align 4
  %5 = alloca i8, align 1
  %6 = alloca i32, align 4
  %7 = alloca %struct.gpio_driver_config*, align 4
  %8 = alloca %struct.gpio_driver_config*, align 4
  store %struct.device* %0, %struct.device** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %4, metadata !308, metadata !DIExpression()), !dbg !309
  store i8 %1, i8* %5, align 1
  call void @llvm.dbg.declare(metadata i8* %5, metadata !310, metadata !DIExpression()), !dbg !311
  store i32 %2, i32* %6, align 4
  call void @llvm.dbg.declare(metadata i32* %6, metadata !312, metadata !DIExpression()), !dbg !313
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_config** %7, metadata !314, metadata !DIExpression()), !dbg !315
  %9 = load %struct.device*, %struct.device** %4, align 4, !dbg !316
  %10 = getelementptr inbounds %struct.device, %struct.device* %9, i32 0, i32 1, !dbg !317
  %11 = load i8*, i8** %10, align 4, !dbg !317
  %12 = bitcast i8* %11 to %struct.gpio_driver_config*, !dbg !318
  store %struct.gpio_driver_config* %12, %struct.gpio_driver_config** %7, align 4, !dbg !315
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_config** %8, metadata !319, metadata !DIExpression()), !dbg !321
  %13 = load %struct.device*, %struct.device** %4, align 4, !dbg !322
  %14 = getelementptr inbounds %struct.device, %struct.device* %13, i32 0, i32 3, !dbg !323
  %15 = load i8*, i8** %14, align 4, !dbg !323
  %16 = bitcast i8* %15 to %struct.gpio_driver_config*, !dbg !324
  store %struct.gpio_driver_config* %16, %struct.gpio_driver_config** %8, align 4, !dbg !321
  %17 = load %struct.gpio_driver_config*, %struct.gpio_driver_config** %7, align 4, !dbg !325
  %18 = load %struct.gpio_driver_config*, %struct.gpio_driver_config** %8, align 4, !dbg !326
  %19 = getelementptr inbounds %struct.gpio_driver_config, %struct.gpio_driver_config* %18, i32 0, i32 0, !dbg !328
  %20 = load i32, i32* %19, align 4, !dbg !328
  %21 = load i8, i8* %5, align 1, !dbg !329
  %22 = zext i8 %21 to i32, !dbg !329
  %23 = shl i32 1, %22, !dbg !329
  %24 = and i32 %20, %23, !dbg !330
  %25 = icmp ne i32 %24, 0, !dbg !330
  br i1 %25, label %26, label %31, !dbg !331

26:                                               ; preds = %3
  %27 = load i32, i32* %6, align 4, !dbg !332
  %28 = icmp ne i32 %27, 0, !dbg !334
  %29 = zext i1 %28 to i64, !dbg !335
  %30 = select i1 %28, i32 0, i32 1, !dbg !335
  store i32 %30, i32* %6, align 4, !dbg !336
  br label %31, !dbg !337

31:                                               ; preds = %26, %3
  %32 = load %struct.device*, %struct.device** %4, align 4, !dbg !338
  %33 = load i8, i8* %5, align 1, !dbg !339
  %34 = load i32, i32* %6, align 4, !dbg !340
  %35 = call i32 @gpio_pin_set_raw(%struct.device* %32, i8 zeroext %33, i32 %34) #3, !dbg !341
  ret i32 %35, !dbg !342
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_msleep(i32) #0 !dbg !343 {
  %2 = alloca i32, align 4
  %3 = alloca %struct.k_timeout_t, align 8
  store i32 %0, i32* %2, align 4
  call void @llvm.dbg.declare(metadata i32* %2, metadata !347, metadata !DIExpression()), !dbg !348
  %4 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !349
  %5 = load i32, i32* %2, align 4, !dbg !349
  %6 = icmp sgt i32 %5, 0, !dbg !349
  br i1 %6, label %7, label %9, !dbg !349

7:                                                ; preds = %1
  %8 = load i32, i32* %2, align 4, !dbg !349
  br label %10, !dbg !349

9:                                                ; preds = %1
  br label %10, !dbg !349

10:                                               ; preds = %9, %7
  %11 = phi i32 [ %8, %7 ], [ 0, %9 ], !dbg !349
  %12 = sext i32 %11 to i64, !dbg !349
  %13 = call i64 @k_ms_to_ticks_ceil64(i64 %12) #3, !dbg !349
  store i64 %13, i64* %4, align 8, !dbg !349
  %14 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !350
  %15 = bitcast i64* %14 to [1 x i64]*, !dbg !350
  %16 = load [1 x i64], [1 x i64]* %15, align 8, !dbg !350
  %17 = call i32 @k_sleep([1 x i64] %16) #3, !dbg !350
  ret i32 %17, !dbg !351
}

; Function Attrs: noinline nounwind optnone
define internal i64 @k_ms_to_ticks_ceil64(i64) #0 !dbg !352 {
  %2 = alloca i64, align 8
  %3 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %3, metadata !358, metadata !DIExpression()), !dbg !362
  %4 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !364, metadata !DIExpression()), !dbg !365
  %5 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %5, metadata !366, metadata !DIExpression()), !dbg !367
  %6 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %6, metadata !368, metadata !DIExpression()), !dbg !369
  %7 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %7, metadata !370, metadata !DIExpression()), !dbg !371
  %8 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %8, metadata !372, metadata !DIExpression()), !dbg !373
  %9 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %9, metadata !374, metadata !DIExpression()), !dbg !375
  %10 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %10, metadata !376, metadata !DIExpression()), !dbg !377
  %11 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %11, metadata !378, metadata !DIExpression()), !dbg !379
  %12 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %12, metadata !380, metadata !DIExpression()), !dbg !381
  %13 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %13, metadata !382, metadata !DIExpression()), !dbg !385
  %14 = alloca i64, align 8
  store i64 %0, i64* %14, align 8
  call void @llvm.dbg.declare(metadata i64* %14, metadata !386, metadata !DIExpression()), !dbg !387
  %15 = load i64, i64* %14, align 8, !dbg !388
  store i64 %15, i64* %3, align 8
  store i32 1000, i32* %4, align 4
  store i32 10000, i32* %5, align 4
  store i8 1, i8* %6, align 1
  store i8 0, i8* %7, align 1
  store i8 1, i8* %8, align 1
  store i8 0, i8* %9, align 1
  %16 = load i8, i8* %6, align 1, !dbg !389
  %17 = trunc i8 %16 to i1, !dbg !389
  br i1 %17, label %18, label %27, !dbg !390

18:                                               ; preds = %1
  %19 = load i32, i32* %5, align 4, !dbg !391
  %20 = load i32, i32* %4, align 4, !dbg !392
  %21 = icmp ugt i32 %19, %20, !dbg !393
  br i1 %21, label %22, label %27, !dbg !394

22:                                               ; preds = %18
  %23 = load i32, i32* %5, align 4, !dbg !395
  %24 = load i32, i32* %4, align 4, !dbg !396
  %25 = urem i32 %23, %24, !dbg !397
  %26 = icmp eq i32 %25, 0, !dbg !398
  br label %27

27:                                               ; preds = %22, %18, %1
  %28 = phi i1 [ false, %18 ], [ false, %1 ], [ %26, %22 ], !dbg !399
  %29 = zext i1 %28 to i8, !dbg !377
  store i8 %29, i8* %10, align 1, !dbg !377
  %30 = load i8, i8* %6, align 1, !dbg !400
  %31 = trunc i8 %30 to i1, !dbg !400
  br i1 %31, label %32, label %41, !dbg !401

32:                                               ; preds = %27
  %33 = load i32, i32* %4, align 4, !dbg !402
  %34 = load i32, i32* %5, align 4, !dbg !403
  %35 = icmp ugt i32 %33, %34, !dbg !404
  br i1 %35, label %36, label %41, !dbg !405

36:                                               ; preds = %32
  %37 = load i32, i32* %4, align 4, !dbg !406
  %38 = load i32, i32* %5, align 4, !dbg !407
  %39 = urem i32 %37, %38, !dbg !408
  %40 = icmp eq i32 %39, 0, !dbg !409
  br label %41

41:                                               ; preds = %36, %32, %27
  %42 = phi i1 [ false, %32 ], [ false, %27 ], [ %40, %36 ], !dbg !399
  %43 = zext i1 %42 to i8, !dbg !379
  store i8 %43, i8* %11, align 1, !dbg !379
  %44 = load i32, i32* %4, align 4, !dbg !410
  %45 = load i32, i32* %5, align 4, !dbg !412
  %46 = icmp eq i32 %44, %45, !dbg !413
  br i1 %46, label %47, label %58, !dbg !414

47:                                               ; preds = %41
  %48 = load i8, i8* %7, align 1, !dbg !415
  %49 = trunc i8 %48 to i1, !dbg !415
  br i1 %49, label %50, label %54, !dbg !415

50:                                               ; preds = %47
  %51 = load i64, i64* %3, align 8, !dbg !417
  %52 = trunc i64 %51 to i32, !dbg !418
  %53 = zext i32 %52 to i64, !dbg !419
  br label %56, !dbg !415

54:                                               ; preds = %47
  %55 = load i64, i64* %3, align 8, !dbg !420
  br label %56, !dbg !415

56:                                               ; preds = %54, %50
  %57 = phi i64 [ %53, %50 ], [ %55, %54 ], !dbg !415
  store i64 %57, i64* %2, align 8, !dbg !421
  br label %160, !dbg !421

58:                                               ; preds = %41
  store i64 0, i64* %12, align 8, !dbg !381
  %59 = load i8, i8* %10, align 1, !dbg !422
  %60 = trunc i8 %59 to i1, !dbg !422
  br i1 %60, label %87, label %61, !dbg !423

61:                                               ; preds = %58
  %62 = load i8, i8* %11, align 1, !dbg !424
  %63 = trunc i8 %62 to i1, !dbg !424
  br i1 %63, label %64, label %68, !dbg !424

64:                                               ; preds = %61
  %65 = load i32, i32* %4, align 4, !dbg !425
  %66 = load i32, i32* %5, align 4, !dbg !426
  %67 = udiv i32 %65, %66, !dbg !427
  br label %70, !dbg !424

68:                                               ; preds = %61
  %69 = load i32, i32* %4, align 4, !dbg !428
  br label %70, !dbg !424

70:                                               ; preds = %68, %64
  %71 = phi i32 [ %67, %64 ], [ %69, %68 ], !dbg !424
  store i32 %71, i32* %13, align 4, !dbg !385
  %72 = load i8, i8* %8, align 1, !dbg !429
  %73 = trunc i8 %72 to i1, !dbg !429
  br i1 %73, label %74, label %78, !dbg !431

74:                                               ; preds = %70
  %75 = load i32, i32* %13, align 4, !dbg !432
  %76 = sub i32 %75, 1, !dbg !434
  %77 = zext i32 %76 to i64, !dbg !432
  store i64 %77, i64* %12, align 8, !dbg !435
  br label %86, !dbg !436

78:                                               ; preds = %70
  %79 = load i8, i8* %9, align 1, !dbg !437
  %80 = trunc i8 %79 to i1, !dbg !437
  br i1 %80, label %81, label %85, !dbg !439

81:                                               ; preds = %78
  %82 = load i32, i32* %13, align 4, !dbg !440
  %83 = udiv i32 %82, 2, !dbg !442
  %84 = zext i32 %83 to i64, !dbg !440
  store i64 %84, i64* %12, align 8, !dbg !443
  br label %85, !dbg !444

85:                                               ; preds = %81, %78
  br label %86

86:                                               ; preds = %85, %74
  br label %87, !dbg !445

87:                                               ; preds = %86, %58
  %88 = load i8, i8* %11, align 1, !dbg !446
  %89 = trunc i8 %88 to i1, !dbg !446
  br i1 %89, label %90, label %114, !dbg !448

90:                                               ; preds = %87
  %91 = load i64, i64* %12, align 8, !dbg !449
  %92 = load i64, i64* %3, align 8, !dbg !451
  %93 = add i64 %92, %91, !dbg !451
  store i64 %93, i64* %3, align 8, !dbg !451
  %94 = load i8, i8* %7, align 1, !dbg !452
  %95 = trunc i8 %94 to i1, !dbg !452
  br i1 %95, label %96, label %107, !dbg !454

96:                                               ; preds = %90
  %97 = load i64, i64* %3, align 8, !dbg !455
  %98 = icmp ult i64 %97, 4294967296, !dbg !456
  br i1 %98, label %99, label %107, !dbg !457

99:                                               ; preds = %96
  %100 = load i64, i64* %3, align 8, !dbg !458
  %101 = trunc i64 %100 to i32, !dbg !460
  %102 = load i32, i32* %4, align 4, !dbg !461
  %103 = load i32, i32* %5, align 4, !dbg !462
  %104 = udiv i32 %102, %103, !dbg !463
  %105 = udiv i32 %101, %104, !dbg !464
  %106 = zext i32 %105 to i64, !dbg !465
  store i64 %106, i64* %2, align 8, !dbg !466
  br label %160, !dbg !466

107:                                              ; preds = %96, %90
  %108 = load i64, i64* %3, align 8, !dbg !467
  %109 = load i32, i32* %4, align 4, !dbg !469
  %110 = load i32, i32* %5, align 4, !dbg !470
  %111 = udiv i32 %109, %110, !dbg !471
  %112 = zext i32 %111 to i64, !dbg !472
  %113 = udiv i64 %108, %112, !dbg !473
  store i64 %113, i64* %2, align 8, !dbg !474
  br label %160, !dbg !474

114:                                              ; preds = %87
  %115 = load i8, i8* %10, align 1, !dbg !475
  %116 = trunc i8 %115 to i1, !dbg !475
  br i1 %116, label %117, label %135, !dbg !477

117:                                              ; preds = %114
  %118 = load i8, i8* %7, align 1, !dbg !478
  %119 = trunc i8 %118 to i1, !dbg !478
  br i1 %119, label %120, label %128, !dbg !481

120:                                              ; preds = %117
  %121 = load i64, i64* %3, align 8, !dbg !482
  %122 = trunc i64 %121 to i32, !dbg !484
  %123 = load i32, i32* %5, align 4, !dbg !485
  %124 = load i32, i32* %4, align 4, !dbg !486
  %125 = udiv i32 %123, %124, !dbg !487
  %126 = mul i32 %122, %125, !dbg !488
  %127 = zext i32 %126 to i64, !dbg !489
  store i64 %127, i64* %2, align 8, !dbg !490
  br label %160, !dbg !490

128:                                              ; preds = %117
  %129 = load i64, i64* %3, align 8, !dbg !491
  %130 = load i32, i32* %5, align 4, !dbg !493
  %131 = load i32, i32* %4, align 4, !dbg !494
  %132 = udiv i32 %130, %131, !dbg !495
  %133 = zext i32 %132 to i64, !dbg !496
  %134 = mul i64 %129, %133, !dbg !497
  store i64 %134, i64* %2, align 8, !dbg !498
  br label %160, !dbg !498

135:                                              ; preds = %114
  %136 = load i8, i8* %7, align 1, !dbg !499
  %137 = trunc i8 %136 to i1, !dbg !499
  br i1 %137, label %138, label %150, !dbg !502

138:                                              ; preds = %135
  %139 = load i64, i64* %3, align 8, !dbg !503
  %140 = load i32, i32* %5, align 4, !dbg !505
  %141 = zext i32 %140 to i64, !dbg !505
  %142 = mul i64 %139, %141, !dbg !506
  %143 = load i64, i64* %12, align 8, !dbg !507
  %144 = add i64 %142, %143, !dbg !508
  %145 = load i32, i32* %4, align 4, !dbg !509
  %146 = zext i32 %145 to i64, !dbg !509
  %147 = udiv i64 %144, %146, !dbg !510
  %148 = trunc i64 %147 to i32, !dbg !511
  %149 = zext i32 %148 to i64, !dbg !511
  store i64 %149, i64* %2, align 8, !dbg !512
  br label %160, !dbg !512

150:                                              ; preds = %135
  %151 = load i64, i64* %3, align 8, !dbg !513
  %152 = load i32, i32* %5, align 4, !dbg !515
  %153 = zext i32 %152 to i64, !dbg !515
  %154 = mul i64 %151, %153, !dbg !516
  %155 = load i64, i64* %12, align 8, !dbg !517
  %156 = add i64 %154, %155, !dbg !518
  %157 = load i32, i32* %4, align 4, !dbg !519
  %158 = zext i32 %157 to i64, !dbg !519
  %159 = udiv i64 %156, %158, !dbg !520
  store i64 %159, i64* %2, align 8, !dbg !521
  br label %160, !dbg !521

160:                                              ; preds = %150, %138, %128, %120, %107, %99, %56
  %161 = load i64, i64* %2, align 8, !dbg !522
  ret i64 %161, !dbg !523
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_sleep([1 x i64]) #0 !dbg !524 {
  %2 = alloca %struct.k_timeout_t, align 8
  %3 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0
  %4 = bitcast i64* %3 to [1 x i64]*
  store [1 x i64] %0, [1 x i64]* %4, align 8
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %2, metadata !532, metadata !DIExpression()), !dbg !533
  br label %5, !dbg !534

5:                                                ; preds = %1
  call void asm sideeffect "", "~{memory}"() #4, !dbg !535, !srcloc !537
  br label %6, !dbg !535

6:                                                ; preds = %5
  %7 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !538
  %8 = bitcast i64* %7 to [1 x i64]*, !dbg !538
  %9 = load [1 x i64], [1 x i64]* %8, align 8, !dbg !538
  %10 = call i32 @z_impl_k_sleep([1 x i64] %9) #3, !dbg !538
  ret i32 %10, !dbg !539
}

declare dso_local i32 @z_impl_k_sleep([1 x i64]) #2

; Function Attrs: noinline nounwind optnone
define internal i32 @gpio_pin_set_raw(%struct.device*, i8 zeroext, i32) #0 !dbg !540 {
  %4 = alloca %struct.device*, align 4
  %5 = alloca i8, align 1
  %6 = alloca i32, align 4
  %7 = alloca %struct.gpio_driver_config*, align 4
  %8 = alloca i32, align 4
  store %struct.device* %0, %struct.device** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %4, metadata !541, metadata !DIExpression()), !dbg !542
  store i8 %1, i8* %5, align 1
  call void @llvm.dbg.declare(metadata i8* %5, metadata !543, metadata !DIExpression()), !dbg !544
  store i32 %2, i32* %6, align 4
  call void @llvm.dbg.declare(metadata i32* %6, metadata !545, metadata !DIExpression()), !dbg !546
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_config** %7, metadata !547, metadata !DIExpression()), !dbg !548
  %9 = load %struct.device*, %struct.device** %4, align 4, !dbg !549
  %10 = getelementptr inbounds %struct.device, %struct.device* %9, i32 0, i32 1, !dbg !550
  %11 = load i8*, i8** %10, align 4, !dbg !550
  %12 = bitcast i8* %11 to %struct.gpio_driver_config*, !dbg !551
  store %struct.gpio_driver_config* %12, %struct.gpio_driver_config** %7, align 4, !dbg !548
  call void @llvm.dbg.declare(metadata i32* %8, metadata !552, metadata !DIExpression()), !dbg !553
  %13 = load %struct.gpio_driver_config*, %struct.gpio_driver_config** %7, align 4, !dbg !554
  %14 = load i32, i32* %6, align 4, !dbg !555
  %15 = icmp ne i32 %14, 0, !dbg !557
  br i1 %15, label %16, label %22, !dbg !558

16:                                               ; preds = %3
  %17 = load %struct.device*, %struct.device** %4, align 4, !dbg !559
  %18 = load i8, i8* %5, align 1, !dbg !561
  %19 = zext i8 %18 to i32, !dbg !561
  %20 = shl i32 1, %19, !dbg !561
  %21 = call i32 @gpio_port_set_bits_raw(%struct.device* %17, i32 %20) #3, !dbg !562
  store i32 %21, i32* %8, align 4, !dbg !563
  br label %28, !dbg !564

22:                                               ; preds = %3
  %23 = load %struct.device*, %struct.device** %4, align 4, !dbg !565
  %24 = load i8, i8* %5, align 1, !dbg !567
  %25 = zext i8 %24 to i32, !dbg !567
  %26 = shl i32 1, %25, !dbg !567
  %27 = call i32 @gpio_port_clear_bits_raw(%struct.device* %23, i32 %26) #3, !dbg !568
  store i32 %27, i32* %8, align 4, !dbg !569
  br label %28

28:                                               ; preds = %22, %16
  %29 = load i32, i32* %8, align 4, !dbg !570
  ret i32 %29, !dbg !571
}

; Function Attrs: noinline nounwind optnone
define internal i32 @gpio_port_set_bits_raw(%struct.device*, i32) #0 !dbg !572 {
  %3 = alloca %struct.device*, align 4
  %4 = alloca i32, align 4
  store %struct.device* %0, %struct.device** %3, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %3, metadata !574, metadata !DIExpression()), !dbg !575
  store i32 %1, i32* %4, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !576, metadata !DIExpression()), !dbg !577
  br label %5, !dbg !578

5:                                                ; preds = %2
  call void asm sideeffect "", "~{memory}"() #4, !dbg !579, !srcloc !581
  br label %6, !dbg !579

6:                                                ; preds = %5
  %7 = load %struct.device*, %struct.device** %3, align 4, !dbg !582
  %8 = load i32, i32* %4, align 4, !dbg !583
  %9 = call i32 @z_impl_gpio_port_set_bits_raw(%struct.device* %7, i32 %8) #3, !dbg !584
  ret i32 %9, !dbg !585
}

; Function Attrs: noinline nounwind optnone
define internal i32 @gpio_port_clear_bits_raw(%struct.device*, i32) #0 !dbg !586 {
  %3 = alloca %struct.device*, align 4
  %4 = alloca i32, align 4
  store %struct.device* %0, %struct.device** %3, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %3, metadata !587, metadata !DIExpression()), !dbg !588
  store i32 %1, i32* %4, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !589, metadata !DIExpression()), !dbg !590
  br label %5, !dbg !591

5:                                                ; preds = %2
  call void asm sideeffect "", "~{memory}"() #4, !dbg !592, !srcloc !594
  br label %6, !dbg !592

6:                                                ; preds = %5
  %7 = load %struct.device*, %struct.device** %3, align 4, !dbg !595
  %8 = load i32, i32* %4, align 4, !dbg !596
  %9 = call i32 @z_impl_gpio_port_clear_bits_raw(%struct.device* %7, i32 %8) #3, !dbg !597
  ret i32 %9, !dbg !598
}

; Function Attrs: noinline nounwind optnone
define internal i32 @z_impl_gpio_port_clear_bits_raw(%struct.device*, i32) #0 !dbg !599 {
  %3 = alloca %struct.device*, align 4
  %4 = alloca i32, align 4
  %5 = alloca %struct.gpio_driver_api*, align 4
  store %struct.device* %0, %struct.device** %3, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %3, metadata !600, metadata !DIExpression()), !dbg !601
  store i32 %1, i32* %4, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !602, metadata !DIExpression()), !dbg !603
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_api** %5, metadata !604, metadata !DIExpression()), !dbg !605
  %6 = load %struct.device*, %struct.device** %3, align 4, !dbg !606
  %7 = getelementptr inbounds %struct.device, %struct.device* %6, i32 0, i32 2, !dbg !607
  %8 = load i8*, i8** %7, align 4, !dbg !607
  %9 = bitcast i8* %8 to %struct.gpio_driver_api*, !dbg !608
  store %struct.gpio_driver_api* %9, %struct.gpio_driver_api** %5, align 4, !dbg !605
  %10 = load %struct.gpio_driver_api*, %struct.gpio_driver_api** %5, align 4, !dbg !609
  %11 = getelementptr inbounds %struct.gpio_driver_api, %struct.gpio_driver_api* %10, i32 0, i32 4, !dbg !610
  %12 = load i32 (%struct.device*, i32)*, i32 (%struct.device*, i32)** %11, align 4, !dbg !610
  %13 = load %struct.device*, %struct.device** %3, align 4, !dbg !611
  %14 = load i32, i32* %4, align 4, !dbg !612
  %15 = call i32 %12(%struct.device* %13, i32 %14) #3, !dbg !609
  ret i32 %15, !dbg !613
}

; Function Attrs: noinline nounwind optnone
define internal i32 @z_impl_gpio_port_set_bits_raw(%struct.device*, i32) #0 !dbg !614 {
  %3 = alloca %struct.device*, align 4
  %4 = alloca i32, align 4
  %5 = alloca %struct.gpio_driver_api*, align 4
  store %struct.device* %0, %struct.device** %3, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %3, metadata !615, metadata !DIExpression()), !dbg !616
  store i32 %1, i32* %4, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !617, metadata !DIExpression()), !dbg !618
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_api** %5, metadata !619, metadata !DIExpression()), !dbg !620
  %6 = load %struct.device*, %struct.device** %3, align 4, !dbg !621
  %7 = getelementptr inbounds %struct.device, %struct.device* %6, i32 0, i32 2, !dbg !622
  %8 = load i8*, i8** %7, align 4, !dbg !622
  %9 = bitcast i8* %8 to %struct.gpio_driver_api*, !dbg !623
  store %struct.gpio_driver_api* %9, %struct.gpio_driver_api** %5, align 4, !dbg !620
  %10 = load %struct.gpio_driver_api*, %struct.gpio_driver_api** %5, align 4, !dbg !624
  %11 = getelementptr inbounds %struct.gpio_driver_api, %struct.gpio_driver_api* %10, i32 0, i32 3, !dbg !625
  %12 = load i32 (%struct.device*, i32)*, i32 (%struct.device*, i32)** %11, align 4, !dbg !625
  %13 = load %struct.device*, %struct.device** %3, align 4, !dbg !626
  %14 = load i32, i32* %4, align 4, !dbg !627
  %15 = call i32 %12(%struct.device* %13, i32 %14) #3, !dbg !624
  ret i32 %15, !dbg !628
}

; Function Attrs: noinline nounwind optnone
define internal i32 @gpio_config(%struct.device*, i8 zeroext, i32) #0 !dbg !629 {
  %4 = alloca %struct.device*, align 4
  %5 = alloca i8, align 1
  %6 = alloca i32, align 4
  store %struct.device* %0, %struct.device** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %4, metadata !630, metadata !DIExpression()), !dbg !631
  store i8 %1, i8* %5, align 1
  call void @llvm.dbg.declare(metadata i8* %5, metadata !632, metadata !DIExpression()), !dbg !633
  store i32 %2, i32* %6, align 4
  call void @llvm.dbg.declare(metadata i32* %6, metadata !634, metadata !DIExpression()), !dbg !635
  br label %7, !dbg !636

7:                                                ; preds = %3
  call void asm sideeffect "", "~{memory}"() #4, !dbg !637, !srcloc !639
  br label %8, !dbg !637

8:                                                ; preds = %7
  %9 = load %struct.device*, %struct.device** %4, align 4, !dbg !640
  %10 = load i8, i8* %5, align 1, !dbg !641
  %11 = load i32, i32* %6, align 4, !dbg !642
  %12 = call i32 @z_impl_gpio_config(%struct.device* %9, i8 zeroext %10, i32 %11) #3, !dbg !643
  ret i32 %12, !dbg !644
}

; Function Attrs: noinline nounwind optnone
define internal i32 @z_impl_gpio_pin_interrupt_configure(%struct.device*, i8 zeroext, i32) #0 !dbg !645 {
  %4 = alloca %struct.device*, align 4
  %5 = alloca i8, align 1
  %6 = alloca i32, align 4
  %7 = alloca %struct.gpio_driver_api*, align 4
  %8 = alloca %struct.gpio_driver_config*, align 4
  %9 = alloca %struct.gpio_driver_config*, align 4
  %10 = alloca i32, align 4
  %11 = alloca i32, align 4
  store %struct.device* %0, %struct.device** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %4, metadata !646, metadata !DIExpression()), !dbg !647
  store i8 %1, i8* %5, align 1
  call void @llvm.dbg.declare(metadata i8* %5, metadata !648, metadata !DIExpression()), !dbg !649
  store i32 %2, i32* %6, align 4
  call void @llvm.dbg.declare(metadata i32* %6, metadata !650, metadata !DIExpression()), !dbg !651
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_api** %7, metadata !652, metadata !DIExpression()), !dbg !653
  %12 = load %struct.device*, %struct.device** %4, align 4, !dbg !654
  %13 = getelementptr inbounds %struct.device, %struct.device* %12, i32 0, i32 2, !dbg !655
  %14 = load i8*, i8** %13, align 4, !dbg !655
  %15 = bitcast i8* %14 to %struct.gpio_driver_api*, !dbg !656
  store %struct.gpio_driver_api* %15, %struct.gpio_driver_api** %7, align 4, !dbg !653
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_config** %8, metadata !657, metadata !DIExpression()), !dbg !658
  %16 = load %struct.device*, %struct.device** %4, align 4, !dbg !659
  %17 = getelementptr inbounds %struct.device, %struct.device* %16, i32 0, i32 1, !dbg !660
  %18 = load i8*, i8** %17, align 4, !dbg !660
  %19 = bitcast i8* %18 to %struct.gpio_driver_config*, !dbg !661
  store %struct.gpio_driver_config* %19, %struct.gpio_driver_config** %8, align 4, !dbg !658
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_config** %9, metadata !662, metadata !DIExpression()), !dbg !663
  %20 = load %struct.device*, %struct.device** %4, align 4, !dbg !664
  %21 = getelementptr inbounds %struct.device, %struct.device* %20, i32 0, i32 3, !dbg !665
  %22 = load i8*, i8** %21, align 4, !dbg !665
  %23 = bitcast i8* %22 to %struct.gpio_driver_config*, !dbg !666
  store %struct.gpio_driver_config* %23, %struct.gpio_driver_config** %9, align 4, !dbg !663
  call void @llvm.dbg.declare(metadata i32* %10, metadata !667, metadata !DIExpression()), !dbg !668
  call void @llvm.dbg.declare(metadata i32* %11, metadata !669, metadata !DIExpression()), !dbg !670
  %24 = load %struct.gpio_driver_config*, %struct.gpio_driver_config** %8, align 4, !dbg !671
  %25 = load i32, i32* %6, align 4, !dbg !672
  %26 = and i32 %25, 32768, !dbg !674
  %27 = icmp ne i32 %26, 0, !dbg !675
  br i1 %27, label %28, label %40, !dbg !676

28:                                               ; preds = %3
  %29 = load %struct.gpio_driver_config*, %struct.gpio_driver_config** %9, align 4, !dbg !677
  %30 = getelementptr inbounds %struct.gpio_driver_config, %struct.gpio_driver_config* %29, i32 0, i32 0, !dbg !678
  %31 = load i32, i32* %30, align 4, !dbg !678
  %32 = load i8, i8* %5, align 1, !dbg !679
  %33 = zext i8 %32 to i32, !dbg !679
  %34 = shl i32 1, %33, !dbg !679
  %35 = and i32 %31, %34, !dbg !680
  %36 = icmp ne i32 %35, 0, !dbg !681
  br i1 %36, label %37, label %40, !dbg !682

37:                                               ; preds = %28
  %38 = load i32, i32* %6, align 4, !dbg !683
  %39 = xor i32 %38, 393216, !dbg !683
  store i32 %39, i32* %6, align 4, !dbg !683
  br label %40, !dbg !685

40:                                               ; preds = %37, %28, %3
  %41 = load i32, i32* %6, align 4, !dbg !686
  %42 = and i32 %41, 393216, !dbg !687
  store i32 %42, i32* %10, align 4, !dbg !688
  %43 = load i32, i32* %6, align 4, !dbg !689
  %44 = and i32 %43, 90112, !dbg !690
  store i32 %44, i32* %11, align 4, !dbg !691
  %45 = load %struct.gpio_driver_api*, %struct.gpio_driver_api** %7, align 4, !dbg !692
  %46 = getelementptr inbounds %struct.gpio_driver_api, %struct.gpio_driver_api* %45, i32 0, i32 6, !dbg !693
  %47 = load i32 (%struct.device*, i8, i32, i32)*, i32 (%struct.device*, i8, i32, i32)** %46, align 4, !dbg !693
  %48 = load %struct.device*, %struct.device** %4, align 4, !dbg !694
  %49 = load i8, i8* %5, align 1, !dbg !695
  %50 = load i32, i32* %11, align 4, !dbg !696
  %51 = load i32, i32* %10, align 4, !dbg !697
  %52 = call i32 %47(%struct.device* %48, i8 zeroext %49, i32 %50, i32 %51) #3, !dbg !692
  ret i32 %52, !dbg !698
}

; Function Attrs: noinline nounwind optnone
define internal i32 @z_impl_gpio_config(%struct.device*, i8 zeroext, i32) #0 !dbg !699 {
  %4 = alloca %struct.device*, align 4
  %5 = alloca i8, align 1
  %6 = alloca i32, align 4
  %7 = alloca %struct.gpio_driver_api*, align 4
  store %struct.device* %0, %struct.device** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %4, metadata !700, metadata !DIExpression()), !dbg !701
  store i8 %1, i8* %5, align 1
  call void @llvm.dbg.declare(metadata i8* %5, metadata !702, metadata !DIExpression()), !dbg !703
  store i32 %2, i32* %6, align 4
  call void @llvm.dbg.declare(metadata i32* %6, metadata !704, metadata !DIExpression()), !dbg !705
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_api** %7, metadata !706, metadata !DIExpression()), !dbg !707
  %8 = load %struct.device*, %struct.device** %4, align 4, !dbg !708
  %9 = getelementptr inbounds %struct.device, %struct.device* %8, i32 0, i32 2, !dbg !709
  %10 = load i8*, i8** %9, align 4, !dbg !709
  %11 = bitcast i8* %10 to %struct.gpio_driver_api*, !dbg !710
  store %struct.gpio_driver_api* %11, %struct.gpio_driver_api** %7, align 4, !dbg !707
  %12 = load %struct.gpio_driver_api*, %struct.gpio_driver_api** %7, align 4, !dbg !711
  %13 = getelementptr inbounds %struct.gpio_driver_api, %struct.gpio_driver_api* %12, i32 0, i32 0, !dbg !712
  %14 = load i32 (%struct.device*, i8, i32)*, i32 (%struct.device*, i8, i32)** %13, align 4, !dbg !712
  %15 = load %struct.device*, %struct.device** %4, align 4, !dbg !713
  %16 = load i8, i8* %5, align 1, !dbg !714
  %17 = load i32, i32* %6, align 4, !dbg !715
  %18 = call i32 %14(%struct.device* %15, i8 zeroext %16, i32 %17) #3, !dbg !711
  ret i32 %18, !dbg !716
}

declare dso_local %struct.device* @z_impl_device_get_binding(i8*) #2

attributes #0 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #1 = { nounwind readnone speculatable }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #3 = { nobuiltin }
attributes #4 = { nounwind }

!llvm.dbg.cu = !{!0}
!llvm.ident = !{!154}
!llvm.module.flags = !{!155, !156, !157, !158}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !62, nameTableKind: None)
!1 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/blinky/src/main.c", directory: "/home/kenny/ara/build/appl/Zephyr/blinky")
!2 = !{!3, !50, !57}
!3 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "k_objects", file: !4, line: 121, baseType: !5, size: 8, elements: !6)
!4 = !DIFile(filename: "zephyrproject/zephyr/include/kernel.h", directory: "/home/kenny")
!5 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!6 = !{!7, !8, !9, !10, !11, !12, !13, !14, !15, !16, !17, !18, !19, !20, !21, !22, !23, !24, !25, !26, !27, !28, !29, !30, !31, !32, !33, !34, !35, !36, !37, !38, !39, !40, !41, !42, !43, !44, !45, !46, !47, !48, !49}
!7 = !DIEnumerator(name: "K_OBJ_ANY", value: 0, isUnsigned: true)
!8 = !DIEnumerator(name: "K_OBJ_MEM_SLAB", value: 1, isUnsigned: true)
!9 = !DIEnumerator(name: "K_OBJ_MSGQ", value: 2, isUnsigned: true)
!10 = !DIEnumerator(name: "K_OBJ_MUTEX", value: 3, isUnsigned: true)
!11 = !DIEnumerator(name: "K_OBJ_PIPE", value: 4, isUnsigned: true)
!12 = !DIEnumerator(name: "K_OBJ_QUEUE", value: 5, isUnsigned: true)
!13 = !DIEnumerator(name: "K_OBJ_POLL_SIGNAL", value: 6, isUnsigned: true)
!14 = !DIEnumerator(name: "K_OBJ_SEM", value: 7, isUnsigned: true)
!15 = !DIEnumerator(name: "K_OBJ_STACK", value: 8, isUnsigned: true)
!16 = !DIEnumerator(name: "K_OBJ_THREAD", value: 9, isUnsigned: true)
!17 = !DIEnumerator(name: "K_OBJ_TIMER", value: 10, isUnsigned: true)
!18 = !DIEnumerator(name: "K_OBJ_THREAD_STACK_ELEMENT", value: 11, isUnsigned: true)
!19 = !DIEnumerator(name: "K_OBJ_NET_SOCKET", value: 12, isUnsigned: true)
!20 = !DIEnumerator(name: "K_OBJ_NET_IF", value: 13, isUnsigned: true)
!21 = !DIEnumerator(name: "K_OBJ_SYS_MUTEX", value: 14, isUnsigned: true)
!22 = !DIEnumerator(name: "K_OBJ_FUTEX", value: 15, isUnsigned: true)
!23 = !DIEnumerator(name: "K_OBJ_DRIVER_PTP_CLOCK", value: 16, isUnsigned: true)
!24 = !DIEnumerator(name: "K_OBJ_DRIVER_CRYPTO", value: 17, isUnsigned: true)
!25 = !DIEnumerator(name: "K_OBJ_DRIVER_ADC", value: 18, isUnsigned: true)
!26 = !DIEnumerator(name: "K_OBJ_DRIVER_CAN", value: 19, isUnsigned: true)
!27 = !DIEnumerator(name: "K_OBJ_DRIVER_COUNTER", value: 20, isUnsigned: true)
!28 = !DIEnumerator(name: "K_OBJ_DRIVER_DAC", value: 21, isUnsigned: true)
!29 = !DIEnumerator(name: "K_OBJ_DRIVER_DMA", value: 22, isUnsigned: true)
!30 = !DIEnumerator(name: "K_OBJ_DRIVER_EC_HOST_CMD_PERIPH_API", value: 23, isUnsigned: true)
!31 = !DIEnumerator(name: "K_OBJ_DRIVER_EEPROM", value: 24, isUnsigned: true)
!32 = !DIEnumerator(name: "K_OBJ_DRIVER_ENTROPY", value: 25, isUnsigned: true)
!33 = !DIEnumerator(name: "K_OBJ_DRIVER_ESPI", value: 26, isUnsigned: true)
!34 = !DIEnumerator(name: "K_OBJ_DRIVER_FLASH", value: 27, isUnsigned: true)
!35 = !DIEnumerator(name: "K_OBJ_DRIVER_GPIO", value: 28, isUnsigned: true)
!36 = !DIEnumerator(name: "K_OBJ_DRIVER_I2C", value: 29, isUnsigned: true)
!37 = !DIEnumerator(name: "K_OBJ_DRIVER_I2S", value: 30, isUnsigned: true)
!38 = !DIEnumerator(name: "K_OBJ_DRIVER_IPM", value: 31, isUnsigned: true)
!39 = !DIEnumerator(name: "K_OBJ_DRIVER_KSCAN", value: 32, isUnsigned: true)
!40 = !DIEnumerator(name: "K_OBJ_DRIVER_LED", value: 33, isUnsigned: true)
!41 = !DIEnumerator(name: "K_OBJ_DRIVER_PINMUX", value: 34, isUnsigned: true)
!42 = !DIEnumerator(name: "K_OBJ_DRIVER_PS2", value: 35, isUnsigned: true)
!43 = !DIEnumerator(name: "K_OBJ_DRIVER_PWM", value: 36, isUnsigned: true)
!44 = !DIEnumerator(name: "K_OBJ_DRIVER_SENSOR", value: 37, isUnsigned: true)
!45 = !DIEnumerator(name: "K_OBJ_DRIVER_SPI", value: 38, isUnsigned: true)
!46 = !DIEnumerator(name: "K_OBJ_DRIVER_UART", value: 39, isUnsigned: true)
!47 = !DIEnumerator(name: "K_OBJ_DRIVER_WDT", value: 40, isUnsigned: true)
!48 = !DIEnumerator(name: "K_OBJ_DRIVER_UART_MUX", value: 41, isUnsigned: true)
!49 = !DIEnumerator(name: "K_OBJ_LAST", value: 42, isUnsigned: true)
!50 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "gpio_int_mode", file: !51, line: 395, baseType: !52, size: 32, elements: !53)
!51 = !DIFile(filename: "zephyrproject/zephyr/include/drivers/gpio.h", directory: "/home/kenny")
!52 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!53 = !{!54, !55, !56}
!54 = !DIEnumerator(name: "GPIO_INT_MODE_DISABLED", value: 8192, isUnsigned: true)
!55 = !DIEnumerator(name: "GPIO_INT_MODE_LEVEL", value: 16384, isUnsigned: true)
!56 = !DIEnumerator(name: "GPIO_INT_MODE_EDGE", value: 81920, isUnsigned: true)
!57 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "gpio_int_trig", file: !51, line: 401, baseType: !52, size: 32, elements: !58)
!58 = !{!59, !60, !61}
!59 = !DIEnumerator(name: "GPIO_INT_TRIG_LOW", value: 131072, isUnsigned: true)
!60 = !DIEnumerator(name: "GPIO_INT_TRIG_HIGH", value: 262144, isUnsigned: true)
!61 = !DIEnumerator(name: "GPIO_INT_TRIG_BOTH", value: 393216, isUnsigned: true)
!62 = !{!63, !64, !65, !139, !144, !103, !57, !50, !149, !150, !92}
!63 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 32)
!64 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!65 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !66, size: 32)
!66 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !67)
!67 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "gpio_driver_api", file: !51, line: 412, size: 288, elements: !68)
!68 = !{!69, !93, !99, !104, !108, !109, !110, !114, !135}
!69 = !DIDerivedType(tag: DW_TAG_member, name: "pin_configure", scope: !67, file: !51, line: 413, baseType: !70, size: 32)
!70 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !71, size: 32)
!71 = !DISubroutineType(types: !72)
!72 = !{!64, !73, !88, !91}
!73 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !74, size: 32)
!74 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !75)
!75 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "device", file: !76, line: 200, size: 128, elements: !77)
!76 = !DIFile(filename: "zephyrproject/zephyr/include/device.h", directory: "/home/kenny")
!77 = !{!78, !82, !85, !86}
!78 = !DIDerivedType(tag: DW_TAG_member, name: "name", scope: !75, file: !76, line: 202, baseType: !79, size: 32)
!79 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !80, size: 32)
!80 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !81)
!81 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_unsigned_char)
!82 = !DIDerivedType(tag: DW_TAG_member, name: "config", scope: !75, file: !76, line: 204, baseType: !83, size: 32, offset: 32)
!83 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !84, size: 32)
!84 = !DIDerivedType(tag: DW_TAG_const_type, baseType: null)
!85 = !DIDerivedType(tag: DW_TAG_member, name: "api", scope: !75, file: !76, line: 206, baseType: !83, size: 32, offset: 64)
!86 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !75, file: !76, line: 208, baseType: !87, size: 32, offset: 96)
!87 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !63)
!88 = !DIDerivedType(tag: DW_TAG_typedef, name: "gpio_pin_t", file: !51, line: 288, baseType: !89)
!89 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !90, line: 55, baseType: !5)
!90 = !DIFile(filename: "zephyrproject/zephyr/lib/libc/minimal/include/stdint.h", directory: "/home/kenny")
!91 = !DIDerivedType(tag: DW_TAG_typedef, name: "gpio_flags_t", file: !51, line: 305, baseType: !92)
!92 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !90, line: 57, baseType: !52)
!93 = !DIDerivedType(tag: DW_TAG_member, name: "port_get_raw", scope: !67, file: !51, line: 415, baseType: !94, size: 32, offset: 32)
!94 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !95, size: 32)
!95 = !DISubroutineType(types: !96)
!96 = !{!64, !73, !97}
!97 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !98, size: 32)
!98 = !DIDerivedType(tag: DW_TAG_typedef, name: "gpio_port_value_t", file: !51, line: 280, baseType: !92)
!99 = !DIDerivedType(tag: DW_TAG_member, name: "port_set_masked_raw", scope: !67, file: !51, line: 417, baseType: !100, size: 32, offset: 64)
!100 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !101, size: 32)
!101 = !DISubroutineType(types: !102)
!102 = !{!64, !73, !103, !98}
!103 = !DIDerivedType(tag: DW_TAG_typedef, name: "gpio_port_pins_t", file: !51, line: 267, baseType: !92)
!104 = !DIDerivedType(tag: DW_TAG_member, name: "port_set_bits_raw", scope: !67, file: !51, line: 420, baseType: !105, size: 32, offset: 96)
!105 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !106, size: 32)
!106 = !DISubroutineType(types: !107)
!107 = !{!64, !73, !103}
!108 = !DIDerivedType(tag: DW_TAG_member, name: "port_clear_bits_raw", scope: !67, file: !51, line: 422, baseType: !105, size: 32, offset: 128)
!109 = !DIDerivedType(tag: DW_TAG_member, name: "port_toggle_bits", scope: !67, file: !51, line: 424, baseType: !105, size: 32, offset: 160)
!110 = !DIDerivedType(tag: DW_TAG_member, name: "pin_interrupt_configure", scope: !67, file: !51, line: 426, baseType: !111, size: 32, offset: 192)
!111 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !112, size: 32)
!112 = !DISubroutineType(types: !113)
!113 = !{!64, !73, !88, !50, !57}
!114 = !DIDerivedType(tag: DW_TAG_member, name: "manage_callback", scope: !67, file: !51, line: 429, baseType: !115, size: 32, offset: 224)
!115 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !116, size: 32)
!116 = !DISubroutineType(types: !117)
!117 = !{!64, !73, !118, !134}
!118 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !119, size: 32)
!119 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "gpio_callback", file: !51, line: 367, size: 96, elements: !120)
!120 = !{!121, !128, !133}
!121 = !DIDerivedType(tag: DW_TAG_member, name: "node", scope: !119, file: !51, line: 371, baseType: !122, size: 32)
!122 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_snode_t", file: !123, line: 33, baseType: !124)
!123 = !DIFile(filename: "zephyrproject/zephyr/include/sys/slist.h", directory: "/home/kenny")
!124 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_snode", file: !123, line: 29, size: 32, elements: !125)
!125 = !{!126}
!126 = !DIDerivedType(tag: DW_TAG_member, name: "next", scope: !124, file: !123, line: 30, baseType: !127, size: 32)
!127 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !124, size: 32)
!128 = !DIDerivedType(tag: DW_TAG_member, name: "handler", scope: !119, file: !51, line: 374, baseType: !129, size: 32, offset: 32)
!129 = !DIDerivedType(tag: DW_TAG_typedef, name: "gpio_callback_handler_t", file: !51, line: 353, baseType: !130)
!130 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !131, size: 32)
!131 = !DISubroutineType(types: !132)
!132 = !{null, !73, !118, !103}
!133 = !DIDerivedType(tag: DW_TAG_member, name: "pin_mask", scope: !119, file: !51, line: 382, baseType: !103, size: 32, offset: 64)
!134 = !DIBasicType(name: "_Bool", size: 8, encoding: DW_ATE_boolean)
!135 = !DIDerivedType(tag: DW_TAG_member, name: "get_pending_int", scope: !67, file: !51, line: 432, baseType: !136, size: 32, offset: 256)
!136 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !137, size: 32)
!137 = !DISubroutineType(types: !138)
!138 = !{!92, !73}
!139 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !140, size: 32)
!140 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !141)
!141 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "gpio_driver_config", file: !51, line: 317, size: 32, elements: !142)
!142 = !{!143}
!143 = !DIDerivedType(tag: DW_TAG_member, name: "port_pin_mask", scope: !141, file: !51, line: 323, baseType: !103, size: 32)
!144 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !145, size: 32)
!145 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !146)
!146 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "gpio_driver_data", file: !51, line: 330, size: 32, elements: !147)
!147 = !{!148}
!148 = !DIDerivedType(tag: DW_TAG_member, name: "invert", scope: !146, file: !51, line: 336, baseType: !103, size: 32)
!149 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !146, size: 32)
!150 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_ticks_t", file: !151, line: 46, baseType: !152)
!151 = !DIFile(filename: "zephyrproject/zephyr/include/sys_clock.h", directory: "/home/kenny")
!152 = !DIDerivedType(tag: DW_TAG_typedef, name: "int64_t", file: !90, line: 43, baseType: !153)
!153 = !DIBasicType(name: "long long int", size: 64, encoding: DW_ATE_signed)
!154 = !{!"clang version 9.0.1-12 "}
!155 = !{i32 2, !"Dwarf Version", i32 4}
!156 = !{i32 2, !"Debug Info Version", i32 3}
!157 = !{i32 1, !"wchar_size", i32 4}
!158 = !{i32 1, !"min_enum_size", i32 1}
!159 = distinct !DISubprogram(name: "main", scope: !160, file: !160, line: 35, type: !161, scopeLine: 36, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !163)
!160 = !DIFile(filename: "appl/Zephyr/blinky/src/main.c", directory: "/home/kenny/ara")
!161 = !DISubroutineType(types: !162)
!162 = !{null}
!163 = !{}
!164 = !DILocalVariable(name: "dev", scope: !159, file: !160, line: 37, type: !165)
!165 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !75, size: 32)
!166 = !DILocation(line: 37, column: 17, scope: !159)
!167 = !DILocalVariable(name: "led_is_on", scope: !159, file: !160, line: 38, type: !134)
!168 = !DILocation(line: 38, column: 7, scope: !159)
!169 = !DILocalVariable(name: "ret", scope: !159, file: !160, line: 39, type: !64)
!170 = !DILocation(line: 39, column: 6, scope: !159)
!171 = !DILocation(line: 41, column: 8, scope: !159)
!172 = !DILocation(line: 41, column: 6, scope: !159)
!173 = !DILocation(line: 42, column: 6, scope: !174)
!174 = distinct !DILexicalBlock(scope: !159, file: !160, line: 42, column: 6)
!175 = !DILocation(line: 42, column: 10, scope: !174)
!176 = !DILocation(line: 42, column: 6, scope: !159)
!177 = !DILocation(line: 43, column: 3, scope: !178)
!178 = distinct !DILexicalBlock(scope: !174, file: !160, line: 42, column: 19)
!179 = !DILocation(line: 46, column: 27, scope: !159)
!180 = !DILocation(line: 46, column: 8, scope: !159)
!181 = !DILocation(line: 46, column: 6, scope: !159)
!182 = !DILocation(line: 47, column: 6, scope: !183)
!183 = distinct !DILexicalBlock(scope: !159, file: !160, line: 47, column: 6)
!184 = !DILocation(line: 47, column: 10, scope: !183)
!185 = !DILocation(line: 47, column: 6, scope: !159)
!186 = !DILocation(line: 48, column: 3, scope: !187)
!187 = distinct !DILexicalBlock(scope: !183, file: !160, line: 47, column: 15)
!188 = !DILocation(line: 51, column: 2, scope: !159)
!189 = !DILocation(line: 52, column: 16, scope: !190)
!190 = distinct !DILexicalBlock(scope: !159, file: !160, line: 51, column: 12)
!191 = !DILocation(line: 52, column: 31, scope: !190)
!192 = !DILocation(line: 52, column: 26, scope: !190)
!193 = !DILocation(line: 52, column: 3, scope: !190)
!194 = !DILocation(line: 53, column: 16, scope: !190)
!195 = !DILocation(line: 53, column: 15, scope: !190)
!196 = !DILocation(line: 53, column: 13, scope: !190)
!197 = !DILocation(line: 54, column: 3, scope: !190)
!198 = distinct !{!198, !188, !199}
!199 = !DILocation(line: 55, column: 2, scope: !159)
!200 = !DILocation(line: 56, column: 1, scope: !159)
!201 = distinct !DISubprogram(name: "device_get_binding", scope: !202, file: !202, line: 25, type: !203, scopeLine: 26, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !0, retainedNodes: !163)
!202 = !DIFile(filename: "zephyr/include/generated/syscalls/device.h", directory: "/home/kenny/ara/build/appl/Zephyr/blinky")
!203 = !DISubroutineType(types: !204)
!204 = !{!73, !79}
!205 = !DILocalVariable(name: "name", arg: 1, scope: !201, file: !202, line: 25, type: !79)
!206 = !DILocation(line: 25, column: 87, scope: !201)
!207 = !DILocation(line: 32, column: 2, scope: !201)
!208 = !DILocation(line: 32, column: 2, scope: !209)
!209 = distinct !DILexicalBlock(scope: !201, file: !202, line: 32, column: 2)
!210 = !{i32 -2141797391}
!211 = !DILocation(line: 33, column: 35, scope: !201)
!212 = !DILocation(line: 33, column: 9, scope: !201)
!213 = !DILocation(line: 33, column: 2, scope: !201)
!214 = distinct !DISubprogram(name: "gpio_pin_configure", scope: !51, file: !51, line: 541, type: !71, scopeLine: 544, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !0, retainedNodes: !163)
!215 = !DILocalVariable(name: "port", arg: 1, scope: !214, file: !51, line: 541, type: !73)
!216 = !DILocation(line: 541, column: 59, scope: !214)
!217 = !DILocalVariable(name: "pin", arg: 2, scope: !214, file: !51, line: 542, type: !88)
!218 = !DILocation(line: 542, column: 21, scope: !214)
!219 = !DILocalVariable(name: "flags", arg: 3, scope: !214, file: !51, line: 543, type: !91)
!220 = !DILocation(line: 543, column: 23, scope: !214)
!221 = !DILocalVariable(name: "api", scope: !214, file: !51, line: 545, type: !65)
!222 = !DILocation(line: 545, column: 32, scope: !214)
!223 = !DILocation(line: 546, column: 35, scope: !214)
!224 = !DILocation(line: 546, column: 41, scope: !214)
!225 = !DILocation(line: 546, column: 3, scope: !214)
!226 = !DILocalVariable(name: "cfg", scope: !214, file: !51, line: 547, type: !227)
!227 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !139)
!228 = !DILocation(line: 547, column: 41, scope: !214)
!229 = !DILocation(line: 548, column: 38, scope: !214)
!230 = !DILocation(line: 548, column: 44, scope: !214)
!231 = !DILocation(line: 548, column: 3, scope: !214)
!232 = !DILocalVariable(name: "data", scope: !214, file: !51, line: 549, type: !149)
!233 = !DILocation(line: 549, column: 27, scope: !214)
!234 = !DILocation(line: 550, column: 30, scope: !214)
!235 = !DILocation(line: 550, column: 36, scope: !214)
!236 = !DILocation(line: 550, column: 3, scope: !214)
!237 = !DILocalVariable(name: "ret", scope: !214, file: !51, line: 551, type: !64)
!238 = !DILocation(line: 551, column: 6, scope: !214)
!239 = !DILocation(line: 572, column: 8, scope: !240)
!240 = distinct !DILexicalBlock(scope: !214, file: !51, line: 572, column: 6)
!241 = !DILocation(line: 572, column: 14, scope: !240)
!242 = !DILocation(line: 572, column: 42, scope: !240)
!243 = !DILocation(line: 573, column: 6, scope: !240)
!244 = !DILocation(line: 573, column: 11, scope: !240)
!245 = !DILocation(line: 573, column: 17, scope: !240)
!246 = !DILocation(line: 573, column: 67, scope: !240)
!247 = !DILocation(line: 574, column: 6, scope: !240)
!248 = !DILocation(line: 574, column: 11, scope: !240)
!249 = !DILocation(line: 574, column: 17, scope: !240)
!250 = !DILocation(line: 574, column: 36, scope: !240)
!251 = !DILocation(line: 572, column: 6, scope: !214)
!252 = !DILocation(line: 575, column: 9, scope: !253)
!253 = distinct !DILexicalBlock(scope: !240, file: !51, line: 574, column: 43)
!254 = !DILocation(line: 577, column: 2, scope: !253)
!255 = !DILocation(line: 579, column: 8, scope: !214)
!256 = !DILocation(line: 583, column: 20, scope: !214)
!257 = !DILocation(line: 583, column: 26, scope: !214)
!258 = !DILocation(line: 583, column: 31, scope: !214)
!259 = !DILocation(line: 583, column: 8, scope: !214)
!260 = !DILocation(line: 583, column: 6, scope: !214)
!261 = !DILocation(line: 584, column: 6, scope: !262)
!262 = distinct !DILexicalBlock(scope: !214, file: !51, line: 584, column: 6)
!263 = !DILocation(line: 584, column: 10, scope: !262)
!264 = !DILocation(line: 584, column: 6, scope: !214)
!265 = !DILocation(line: 585, column: 10, scope: !266)
!266 = distinct !DILexicalBlock(scope: !262, file: !51, line: 584, column: 16)
!267 = !DILocation(line: 585, column: 3, scope: !266)
!268 = !DILocation(line: 588, column: 7, scope: !269)
!269 = distinct !DILexicalBlock(scope: !214, file: !51, line: 588, column: 6)
!270 = !DILocation(line: 588, column: 13, scope: !269)
!271 = !DILocation(line: 588, column: 32, scope: !269)
!272 = !DILocation(line: 588, column: 6, scope: !214)
!273 = !DILocation(line: 589, column: 37, scope: !274)
!274 = distinct !DILexicalBlock(scope: !269, file: !51, line: 588, column: 38)
!275 = !DILocation(line: 589, column: 3, scope: !274)
!276 = !DILocation(line: 589, column: 9, scope: !274)
!277 = !DILocation(line: 589, column: 16, scope: !274)
!278 = !DILocation(line: 590, column: 2, scope: !274)
!279 = !DILocation(line: 591, column: 38, scope: !280)
!280 = distinct !DILexicalBlock(scope: !269, file: !51, line: 590, column: 9)
!281 = !DILocation(line: 591, column: 19, scope: !280)
!282 = !DILocation(line: 591, column: 3, scope: !280)
!283 = !DILocation(line: 591, column: 9, scope: !280)
!284 = !DILocation(line: 591, column: 16, scope: !280)
!285 = !DILocation(line: 593, column: 8, scope: !286)
!286 = distinct !DILexicalBlock(scope: !214, file: !51, line: 593, column: 6)
!287 = !DILocation(line: 593, column: 14, scope: !286)
!288 = !DILocation(line: 593, column: 54, scope: !286)
!289 = !DILocation(line: 594, column: 6, scope: !286)
!290 = !DILocation(line: 594, column: 10, scope: !286)
!291 = !DILocation(line: 594, column: 15, scope: !286)
!292 = !DILocation(line: 594, column: 39, scope: !286)
!293 = !DILocation(line: 593, column: 6, scope: !214)
!294 = !DILocation(line: 595, column: 9, scope: !295)
!295 = distinct !DILexicalBlock(scope: !286, file: !51, line: 594, column: 49)
!296 = !DILocation(line: 596, column: 45, scope: !295)
!297 = !DILocation(line: 596, column: 51, scope: !295)
!298 = !DILocation(line: 596, column: 56, scope: !295)
!299 = !DILocation(line: 596, column: 9, scope: !295)
!300 = !DILocation(line: 596, column: 7, scope: !295)
!301 = !DILocation(line: 597, column: 2, scope: !295)
!302 = !DILocation(line: 599, column: 9, scope: !214)
!303 = !DILocation(line: 599, column: 2, scope: !214)
!304 = !DILocation(line: 600, column: 1, scope: !214)
!305 = distinct !DISubprogram(name: "gpio_pin_set", scope: !51, file: !51, line: 993, type: !306, scopeLine: 995, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !0, retainedNodes: !163)
!306 = !DISubroutineType(types: !307)
!307 = !{!64, !73, !88, !64}
!308 = !DILocalVariable(name: "port", arg: 1, scope: !305, file: !51, line: 993, type: !73)
!309 = !DILocation(line: 993, column: 53, scope: !305)
!310 = !DILocalVariable(name: "pin", arg: 2, scope: !305, file: !51, line: 993, type: !88)
!311 = !DILocation(line: 993, column: 70, scope: !305)
!312 = !DILocalVariable(name: "value", arg: 3, scope: !305, file: !51, line: 994, type: !64)
!313 = !DILocation(line: 994, column: 15, scope: !305)
!314 = !DILocalVariable(name: "cfg", scope: !305, file: !51, line: 996, type: !227)
!315 = !DILocation(line: 996, column: 41, scope: !305)
!316 = !DILocation(line: 997, column: 38, scope: !305)
!317 = !DILocation(line: 997, column: 44, scope: !305)
!318 = !DILocation(line: 997, column: 3, scope: !305)
!319 = !DILocalVariable(name: "data", scope: !305, file: !51, line: 998, type: !320)
!320 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !144)
!321 = !DILocation(line: 998, column: 39, scope: !305)
!322 = !DILocation(line: 999, column: 37, scope: !305)
!323 = !DILocation(line: 999, column: 43, scope: !305)
!324 = !DILocation(line: 999, column: 4, scope: !305)
!325 = !DILocation(line: 1001, column: 8, scope: !305)
!326 = !DILocation(line: 1005, column: 6, scope: !327)
!327 = distinct !DILexicalBlock(scope: !305, file: !51, line: 1005, column: 6)
!328 = !DILocation(line: 1005, column: 12, scope: !327)
!329 = !DILocation(line: 1005, column: 39, scope: !327)
!330 = !DILocation(line: 1005, column: 19, scope: !327)
!331 = !DILocation(line: 1005, column: 6, scope: !305)
!332 = !DILocation(line: 1006, column: 12, scope: !333)
!333 = distinct !DILexicalBlock(scope: !327, file: !51, line: 1005, column: 49)
!334 = !DILocation(line: 1006, column: 18, scope: !333)
!335 = !DILocation(line: 1006, column: 11, scope: !333)
!336 = !DILocation(line: 1006, column: 9, scope: !333)
!337 = !DILocation(line: 1007, column: 2, scope: !333)
!338 = !DILocation(line: 1009, column: 26, scope: !305)
!339 = !DILocation(line: 1009, column: 32, scope: !305)
!340 = !DILocation(line: 1009, column: 37, scope: !305)
!341 = !DILocation(line: 1009, column: 9, scope: !305)
!342 = !DILocation(line: 1009, column: 2, scope: !305)
!343 = distinct !DISubprogram(name: "k_msleep", scope: !4, file: !4, line: 957, type: !344, scopeLine: 958, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !0, retainedNodes: !163)
!344 = !DISubroutineType(types: !345)
!345 = !{!346, !346}
!346 = !DIDerivedType(tag: DW_TAG_typedef, name: "int32_t", file: !90, line: 42, baseType: !64)
!347 = !DILocalVariable(name: "ms", arg: 1, scope: !343, file: !4, line: 957, type: !346)
!348 = !DILocation(line: 957, column: 40, scope: !343)
!349 = !DILocation(line: 959, column: 17, scope: !343)
!350 = !DILocation(line: 959, column: 9, scope: !343)
!351 = !DILocation(line: 959, column: 2, scope: !343)
!352 = distinct !DISubprogram(name: "k_ms_to_ticks_ceil64", scope: !353, file: !353, line: 369, type: !354, scopeLine: 370, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !0, retainedNodes: !163)
!353 = !DIFile(filename: "zephyrproject/zephyr/include/sys/time_units.h", directory: "/home/kenny")
!354 = !DISubroutineType(types: !355)
!355 = !{!356, !356}
!356 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint64_t", file: !90, line: 58, baseType: !357)
!357 = !DIBasicType(name: "long long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!358 = !DILocalVariable(name: "t", arg: 1, scope: !359, file: !353, line: 78, type: !356)
!359 = distinct !DISubprogram(name: "z_tmcvt", scope: !353, file: !353, line: 78, type: !360, scopeLine: 82, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !0, retainedNodes: !163)
!360 = !DISubroutineType(types: !361)
!361 = !{!356, !356, !92, !92, !134, !134, !134, !134}
!362 = !DILocation(line: 78, column: 63, scope: !359, inlinedAt: !363)
!363 = distinct !DILocation(line: 372, column: 9, scope: !352)
!364 = !DILocalVariable(name: "from_hz", arg: 2, scope: !359, file: !353, line: 78, type: !92)
!365 = !DILocation(line: 78, column: 75, scope: !359, inlinedAt: !363)
!366 = !DILocalVariable(name: "to_hz", arg: 3, scope: !359, file: !353, line: 79, type: !92)
!367 = !DILocation(line: 79, column: 18, scope: !359, inlinedAt: !363)
!368 = !DILocalVariable(name: "const_hz", arg: 4, scope: !359, file: !353, line: 79, type: !134)
!369 = !DILocation(line: 79, column: 30, scope: !359, inlinedAt: !363)
!370 = !DILocalVariable(name: "result32", arg: 5, scope: !359, file: !353, line: 80, type: !134)
!371 = !DILocation(line: 80, column: 14, scope: !359, inlinedAt: !363)
!372 = !DILocalVariable(name: "round_up", arg: 6, scope: !359, file: !353, line: 80, type: !134)
!373 = !DILocation(line: 80, column: 29, scope: !359, inlinedAt: !363)
!374 = !DILocalVariable(name: "round_off", arg: 7, scope: !359, file: !353, line: 81, type: !134)
!375 = !DILocation(line: 81, column: 14, scope: !359, inlinedAt: !363)
!376 = !DILocalVariable(name: "mul_ratio", scope: !359, file: !353, line: 84, type: !134)
!377 = !DILocation(line: 84, column: 7, scope: !359, inlinedAt: !363)
!378 = !DILocalVariable(name: "div_ratio", scope: !359, file: !353, line: 86, type: !134)
!379 = !DILocation(line: 86, column: 7, scope: !359, inlinedAt: !363)
!380 = !DILocalVariable(name: "off", scope: !359, file: !353, line: 93, type: !356)
!381 = !DILocation(line: 93, column: 11, scope: !359, inlinedAt: !363)
!382 = !DILocalVariable(name: "rdivisor", scope: !383, file: !353, line: 96, type: !92)
!383 = distinct !DILexicalBlock(scope: !384, file: !353, line: 95, column: 18)
!384 = distinct !DILexicalBlock(scope: !359, file: !353, line: 95, column: 6)
!385 = !DILocation(line: 96, column: 12, scope: !383, inlinedAt: !363)
!386 = !DILocalVariable(name: "t", arg: 1, scope: !352, file: !353, line: 369, type: !356)
!387 = !DILocation(line: 369, column: 69, scope: !352)
!388 = !DILocation(line: 372, column: 17, scope: !352)
!389 = !DILocation(line: 84, column: 19, scope: !359, inlinedAt: !363)
!390 = !DILocation(line: 84, column: 28, scope: !359, inlinedAt: !363)
!391 = !DILocation(line: 85, column: 4, scope: !359, inlinedAt: !363)
!392 = !DILocation(line: 85, column: 12, scope: !359, inlinedAt: !363)
!393 = !DILocation(line: 85, column: 10, scope: !359, inlinedAt: !363)
!394 = !DILocation(line: 85, column: 21, scope: !359, inlinedAt: !363)
!395 = !DILocation(line: 85, column: 26, scope: !359, inlinedAt: !363)
!396 = !DILocation(line: 85, column: 34, scope: !359, inlinedAt: !363)
!397 = !DILocation(line: 85, column: 32, scope: !359, inlinedAt: !363)
!398 = !DILocation(line: 85, column: 43, scope: !359, inlinedAt: !363)
!399 = !DILocation(line: 0, scope: !359, inlinedAt: !363)
!400 = !DILocation(line: 86, column: 19, scope: !359, inlinedAt: !363)
!401 = !DILocation(line: 86, column: 28, scope: !359, inlinedAt: !363)
!402 = !DILocation(line: 87, column: 4, scope: !359, inlinedAt: !363)
!403 = !DILocation(line: 87, column: 14, scope: !359, inlinedAt: !363)
!404 = !DILocation(line: 87, column: 12, scope: !359, inlinedAt: !363)
!405 = !DILocation(line: 87, column: 21, scope: !359, inlinedAt: !363)
!406 = !DILocation(line: 87, column: 26, scope: !359, inlinedAt: !363)
!407 = !DILocation(line: 87, column: 36, scope: !359, inlinedAt: !363)
!408 = !DILocation(line: 87, column: 34, scope: !359, inlinedAt: !363)
!409 = !DILocation(line: 87, column: 43, scope: !359, inlinedAt: !363)
!410 = !DILocation(line: 89, column: 6, scope: !411, inlinedAt: !363)
!411 = distinct !DILexicalBlock(scope: !359, file: !353, line: 89, column: 6)
!412 = !DILocation(line: 89, column: 17, scope: !411, inlinedAt: !363)
!413 = !DILocation(line: 89, column: 14, scope: !411, inlinedAt: !363)
!414 = !DILocation(line: 89, column: 6, scope: !359, inlinedAt: !363)
!415 = !DILocation(line: 90, column: 10, scope: !416, inlinedAt: !363)
!416 = distinct !DILexicalBlock(scope: !411, file: !353, line: 89, column: 24)
!417 = !DILocation(line: 90, column: 32, scope: !416, inlinedAt: !363)
!418 = !DILocation(line: 90, column: 22, scope: !416, inlinedAt: !363)
!419 = !DILocation(line: 90, column: 21, scope: !416, inlinedAt: !363)
!420 = !DILocation(line: 90, column: 37, scope: !416, inlinedAt: !363)
!421 = !DILocation(line: 90, column: 3, scope: !416, inlinedAt: !363)
!422 = !DILocation(line: 95, column: 7, scope: !384, inlinedAt: !363)
!423 = !DILocation(line: 95, column: 6, scope: !359, inlinedAt: !363)
!424 = !DILocation(line: 96, column: 23, scope: !383, inlinedAt: !363)
!425 = !DILocation(line: 96, column: 36, scope: !383, inlinedAt: !363)
!426 = !DILocation(line: 96, column: 46, scope: !383, inlinedAt: !363)
!427 = !DILocation(line: 96, column: 44, scope: !383, inlinedAt: !363)
!428 = !DILocation(line: 96, column: 55, scope: !383, inlinedAt: !363)
!429 = !DILocation(line: 98, column: 7, scope: !430, inlinedAt: !363)
!430 = distinct !DILexicalBlock(scope: !383, file: !353, line: 98, column: 7)
!431 = !DILocation(line: 98, column: 7, scope: !383, inlinedAt: !363)
!432 = !DILocation(line: 99, column: 10, scope: !433, inlinedAt: !363)
!433 = distinct !DILexicalBlock(scope: !430, file: !353, line: 98, column: 17)
!434 = !DILocation(line: 99, column: 19, scope: !433, inlinedAt: !363)
!435 = !DILocation(line: 99, column: 8, scope: !433, inlinedAt: !363)
!436 = !DILocation(line: 100, column: 3, scope: !433, inlinedAt: !363)
!437 = !DILocation(line: 100, column: 14, scope: !438, inlinedAt: !363)
!438 = distinct !DILexicalBlock(scope: !430, file: !353, line: 100, column: 14)
!439 = !DILocation(line: 100, column: 14, scope: !430, inlinedAt: !363)
!440 = !DILocation(line: 101, column: 10, scope: !441, inlinedAt: !363)
!441 = distinct !DILexicalBlock(scope: !438, file: !353, line: 100, column: 25)
!442 = !DILocation(line: 101, column: 19, scope: !441, inlinedAt: !363)
!443 = !DILocation(line: 101, column: 8, scope: !441, inlinedAt: !363)
!444 = !DILocation(line: 102, column: 3, scope: !441, inlinedAt: !363)
!445 = !DILocation(line: 103, column: 2, scope: !383, inlinedAt: !363)
!446 = !DILocation(line: 110, column: 6, scope: !447, inlinedAt: !363)
!447 = distinct !DILexicalBlock(scope: !359, file: !353, line: 110, column: 6)
!448 = !DILocation(line: 110, column: 6, scope: !359, inlinedAt: !363)
!449 = !DILocation(line: 111, column: 8, scope: !450, inlinedAt: !363)
!450 = distinct !DILexicalBlock(scope: !447, file: !353, line: 110, column: 17)
!451 = !DILocation(line: 111, column: 5, scope: !450, inlinedAt: !363)
!452 = !DILocation(line: 112, column: 7, scope: !453, inlinedAt: !363)
!453 = distinct !DILexicalBlock(scope: !450, file: !353, line: 112, column: 7)
!454 = !DILocation(line: 112, column: 16, scope: !453, inlinedAt: !363)
!455 = !DILocation(line: 112, column: 20, scope: !453, inlinedAt: !363)
!456 = !DILocation(line: 112, column: 22, scope: !453, inlinedAt: !363)
!457 = !DILocation(line: 112, column: 7, scope: !450, inlinedAt: !363)
!458 = !DILocation(line: 113, column: 22, scope: !459, inlinedAt: !363)
!459 = distinct !DILexicalBlock(scope: !453, file: !353, line: 112, column: 36)
!460 = !DILocation(line: 113, column: 12, scope: !459, inlinedAt: !363)
!461 = !DILocation(line: 113, column: 28, scope: !459, inlinedAt: !363)
!462 = !DILocation(line: 113, column: 38, scope: !459, inlinedAt: !363)
!463 = !DILocation(line: 113, column: 36, scope: !459, inlinedAt: !363)
!464 = !DILocation(line: 113, column: 25, scope: !459, inlinedAt: !363)
!465 = !DILocation(line: 113, column: 11, scope: !459, inlinedAt: !363)
!466 = !DILocation(line: 113, column: 4, scope: !459, inlinedAt: !363)
!467 = !DILocation(line: 115, column: 11, scope: !468, inlinedAt: !363)
!468 = distinct !DILexicalBlock(scope: !453, file: !353, line: 114, column: 10)
!469 = !DILocation(line: 115, column: 16, scope: !468, inlinedAt: !363)
!470 = !DILocation(line: 115, column: 26, scope: !468, inlinedAt: !363)
!471 = !DILocation(line: 115, column: 24, scope: !468, inlinedAt: !363)
!472 = !DILocation(line: 115, column: 15, scope: !468, inlinedAt: !363)
!473 = !DILocation(line: 115, column: 13, scope: !468, inlinedAt: !363)
!474 = !DILocation(line: 115, column: 4, scope: !468, inlinedAt: !363)
!475 = !DILocation(line: 117, column: 13, scope: !476, inlinedAt: !363)
!476 = distinct !DILexicalBlock(scope: !447, file: !353, line: 117, column: 13)
!477 = !DILocation(line: 117, column: 13, scope: !447, inlinedAt: !363)
!478 = !DILocation(line: 118, column: 7, scope: !479, inlinedAt: !363)
!479 = distinct !DILexicalBlock(scope: !480, file: !353, line: 118, column: 7)
!480 = distinct !DILexicalBlock(scope: !476, file: !353, line: 117, column: 24)
!481 = !DILocation(line: 118, column: 7, scope: !480, inlinedAt: !363)
!482 = !DILocation(line: 119, column: 22, scope: !483, inlinedAt: !363)
!483 = distinct !DILexicalBlock(scope: !479, file: !353, line: 118, column: 17)
!484 = !DILocation(line: 119, column: 12, scope: !483, inlinedAt: !363)
!485 = !DILocation(line: 119, column: 28, scope: !483, inlinedAt: !363)
!486 = !DILocation(line: 119, column: 36, scope: !483, inlinedAt: !363)
!487 = !DILocation(line: 119, column: 34, scope: !483, inlinedAt: !363)
!488 = !DILocation(line: 119, column: 25, scope: !483, inlinedAt: !363)
!489 = !DILocation(line: 119, column: 11, scope: !483, inlinedAt: !363)
!490 = !DILocation(line: 119, column: 4, scope: !483, inlinedAt: !363)
!491 = !DILocation(line: 121, column: 11, scope: !492, inlinedAt: !363)
!492 = distinct !DILexicalBlock(scope: !479, file: !353, line: 120, column: 10)
!493 = !DILocation(line: 121, column: 16, scope: !492, inlinedAt: !363)
!494 = !DILocation(line: 121, column: 24, scope: !492, inlinedAt: !363)
!495 = !DILocation(line: 121, column: 22, scope: !492, inlinedAt: !363)
!496 = !DILocation(line: 121, column: 15, scope: !492, inlinedAt: !363)
!497 = !DILocation(line: 121, column: 13, scope: !492, inlinedAt: !363)
!498 = !DILocation(line: 121, column: 4, scope: !492, inlinedAt: !363)
!499 = !DILocation(line: 124, column: 7, scope: !500, inlinedAt: !363)
!500 = distinct !DILexicalBlock(scope: !501, file: !353, line: 124, column: 7)
!501 = distinct !DILexicalBlock(scope: !476, file: !353, line: 123, column: 9)
!502 = !DILocation(line: 124, column: 7, scope: !501, inlinedAt: !363)
!503 = !DILocation(line: 125, column: 23, scope: !504, inlinedAt: !363)
!504 = distinct !DILexicalBlock(scope: !500, file: !353, line: 124, column: 17)
!505 = !DILocation(line: 125, column: 27, scope: !504, inlinedAt: !363)
!506 = !DILocation(line: 125, column: 25, scope: !504, inlinedAt: !363)
!507 = !DILocation(line: 125, column: 35, scope: !504, inlinedAt: !363)
!508 = !DILocation(line: 125, column: 33, scope: !504, inlinedAt: !363)
!509 = !DILocation(line: 125, column: 42, scope: !504, inlinedAt: !363)
!510 = !DILocation(line: 125, column: 40, scope: !504, inlinedAt: !363)
!511 = !DILocation(line: 125, column: 11, scope: !504, inlinedAt: !363)
!512 = !DILocation(line: 125, column: 4, scope: !504, inlinedAt: !363)
!513 = !DILocation(line: 127, column: 12, scope: !514, inlinedAt: !363)
!514 = distinct !DILexicalBlock(scope: !500, file: !353, line: 126, column: 10)
!515 = !DILocation(line: 127, column: 16, scope: !514, inlinedAt: !363)
!516 = !DILocation(line: 127, column: 14, scope: !514, inlinedAt: !363)
!517 = !DILocation(line: 127, column: 24, scope: !514, inlinedAt: !363)
!518 = !DILocation(line: 127, column: 22, scope: !514, inlinedAt: !363)
!519 = !DILocation(line: 127, column: 31, scope: !514, inlinedAt: !363)
!520 = !DILocation(line: 127, column: 29, scope: !514, inlinedAt: !363)
!521 = !DILocation(line: 127, column: 4, scope: !514, inlinedAt: !363)
!522 = !DILocation(line: 130, column: 1, scope: !359, inlinedAt: !363)
!523 = !DILocation(line: 372, column: 2, scope: !352)
!524 = distinct !DISubprogram(name: "k_sleep", scope: !525, file: !525, line: 117, type: !526, scopeLine: 118, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !0, retainedNodes: !163)
!525 = !DIFile(filename: "zephyr/include/generated/syscalls/kernel.h", directory: "/home/kenny/ara/build/appl/Zephyr/blinky")
!526 = !DISubroutineType(types: !527)
!527 = !{!346, !528}
!528 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_timeout_t", file: !151, line: 69, baseType: !529)
!529 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !151, line: 67, size: 64, elements: !530)
!530 = !{!531}
!531 = !DIDerivedType(tag: DW_TAG_member, name: "ticks", scope: !529, file: !151, line: 68, baseType: !150, size: 64)
!532 = !DILocalVariable(name: "timeout", arg: 1, scope: !524, file: !525, line: 117, type: !528)
!533 = !DILocation(line: 117, column: 61, scope: !524)
!534 = !DILocation(line: 126, column: 2, scope: !524)
!535 = !DILocation(line: 126, column: 2, scope: !536)
!536 = distinct !DILexicalBlock(scope: !524, file: !525, line: 126, column: 2)
!537 = !{i32 -2141857929}
!538 = !DILocation(line: 127, column: 9, scope: !524)
!539 = !DILocation(line: 127, column: 2, scope: !524)
!540 = distinct !DISubprogram(name: "gpio_pin_set_raw", scope: !51, file: !51, line: 952, type: !306, scopeLine: 954, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !0, retainedNodes: !163)
!541 = !DILocalVariable(name: "port", arg: 1, scope: !540, file: !51, line: 952, type: !73)
!542 = !DILocation(line: 952, column: 57, scope: !540)
!543 = !DILocalVariable(name: "pin", arg: 2, scope: !540, file: !51, line: 952, type: !88)
!544 = !DILocation(line: 952, column: 74, scope: !540)
!545 = !DILocalVariable(name: "value", arg: 3, scope: !540, file: !51, line: 953, type: !64)
!546 = !DILocation(line: 953, column: 12, scope: !540)
!547 = !DILocalVariable(name: "cfg", scope: !540, file: !51, line: 955, type: !227)
!548 = !DILocation(line: 955, column: 41, scope: !540)
!549 = !DILocation(line: 956, column: 38, scope: !540)
!550 = !DILocation(line: 956, column: 44, scope: !540)
!551 = !DILocation(line: 956, column: 3, scope: !540)
!552 = !DILocalVariable(name: "ret", scope: !540, file: !51, line: 957, type: !64)
!553 = !DILocation(line: 957, column: 6, scope: !540)
!554 = !DILocation(line: 959, column: 8, scope: !540)
!555 = !DILocation(line: 963, column: 6, scope: !556)
!556 = distinct !DILexicalBlock(scope: !540, file: !51, line: 963, column: 6)
!557 = !DILocation(line: 963, column: 12, scope: !556)
!558 = !DILocation(line: 963, column: 6, scope: !540)
!559 = !DILocation(line: 964, column: 32, scope: !560)
!560 = distinct !DILexicalBlock(scope: !556, file: !51, line: 963, column: 18)
!561 = !DILocation(line: 964, column: 56, scope: !560)
!562 = !DILocation(line: 964, column: 9, scope: !560)
!563 = !DILocation(line: 964, column: 7, scope: !560)
!564 = !DILocation(line: 965, column: 2, scope: !560)
!565 = !DILocation(line: 966, column: 34, scope: !566)
!566 = distinct !DILexicalBlock(scope: !556, file: !51, line: 965, column: 9)
!567 = !DILocation(line: 966, column: 58, scope: !566)
!568 = !DILocation(line: 966, column: 9, scope: !566)
!569 = !DILocation(line: 966, column: 7, scope: !566)
!570 = !DILocation(line: 969, column: 9, scope: !540)
!571 = !DILocation(line: 969, column: 2, scope: !540)
!572 = distinct !DISubprogram(name: "gpio_port_set_bits_raw", scope: !573, file: !573, line: 77, type: !106, scopeLine: 78, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !0, retainedNodes: !163)
!573 = !DIFile(filename: "zephyr/include/generated/syscalls/gpio.h", directory: "/home/kenny/ara/build/appl/Zephyr/blinky")
!574 = !DILocalVariable(name: "port", arg: 1, scope: !572, file: !573, line: 77, type: !73)
!575 = !DILocation(line: 77, column: 82, scope: !572)
!576 = !DILocalVariable(name: "pins", arg: 2, scope: !572, file: !573, line: 77, type: !103)
!577 = !DILocation(line: 77, column: 105, scope: !572)
!578 = !DILocation(line: 84, column: 2, scope: !572)
!579 = !DILocation(line: 84, column: 2, scope: !580)
!580 = distinct !DILexicalBlock(scope: !572, file: !573, line: 84, column: 2)
!581 = !{i32 -2141749981}
!582 = !DILocation(line: 85, column: 39, scope: !572)
!583 = !DILocation(line: 85, column: 45, scope: !572)
!584 = !DILocation(line: 85, column: 9, scope: !572)
!585 = !DILocation(line: 85, column: 2, scope: !572)
!586 = distinct !DISubprogram(name: "gpio_port_clear_bits_raw", scope: !573, file: !573, line: 90, type: !106, scopeLine: 91, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !0, retainedNodes: !163)
!587 = !DILocalVariable(name: "port", arg: 1, scope: !586, file: !573, line: 90, type: !73)
!588 = !DILocation(line: 90, column: 84, scope: !586)
!589 = !DILocalVariable(name: "pins", arg: 2, scope: !586, file: !573, line: 90, type: !103)
!590 = !DILocation(line: 90, column: 107, scope: !586)
!591 = !DILocation(line: 97, column: 2, scope: !586)
!592 = !DILocation(line: 97, column: 2, scope: !593)
!593 = distinct !DILexicalBlock(scope: !586, file: !573, line: 97, column: 2)
!594 = !{i32 -2141749913}
!595 = !DILocation(line: 98, column: 41, scope: !586)
!596 = !DILocation(line: 98, column: 47, scope: !586)
!597 = !DILocation(line: 98, column: 9, scope: !586)
!598 = !DILocation(line: 98, column: 2, scope: !586)
!599 = distinct !DISubprogram(name: "z_impl_gpio_port_clear_bits_raw", scope: !51, file: !51, line: 778, type: !106, scopeLine: 780, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !0, retainedNodes: !163)
!600 = !DILocalVariable(name: "port", arg: 1, scope: !599, file: !51, line: 778, type: !73)
!601 = !DILocation(line: 778, column: 72, scope: !599)
!602 = !DILocalVariable(name: "pins", arg: 2, scope: !599, file: !51, line: 779, type: !103)
!603 = !DILocation(line: 779, column: 26, scope: !599)
!604 = !DILocalVariable(name: "api", scope: !599, file: !51, line: 781, type: !65)
!605 = !DILocation(line: 781, column: 32, scope: !599)
!606 = !DILocation(line: 782, column: 35, scope: !599)
!607 = !DILocation(line: 782, column: 41, scope: !599)
!608 = !DILocation(line: 782, column: 3, scope: !599)
!609 = !DILocation(line: 784, column: 9, scope: !599)
!610 = !DILocation(line: 784, column: 14, scope: !599)
!611 = !DILocation(line: 784, column: 34, scope: !599)
!612 = !DILocation(line: 784, column: 40, scope: !599)
!613 = !DILocation(line: 784, column: 2, scope: !599)
!614 = distinct !DISubprogram(name: "z_impl_gpio_port_set_bits_raw", scope: !51, file: !51, line: 740, type: !106, scopeLine: 742, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !0, retainedNodes: !163)
!615 = !DILocalVariable(name: "port", arg: 1, scope: !614, file: !51, line: 740, type: !73)
!616 = !DILocation(line: 740, column: 70, scope: !614)
!617 = !DILocalVariable(name: "pins", arg: 2, scope: !614, file: !51, line: 741, type: !103)
!618 = !DILocation(line: 741, column: 24, scope: !614)
!619 = !DILocalVariable(name: "api", scope: !614, file: !51, line: 743, type: !65)
!620 = !DILocation(line: 743, column: 32, scope: !614)
!621 = !DILocation(line: 744, column: 35, scope: !614)
!622 = !DILocation(line: 744, column: 41, scope: !614)
!623 = !DILocation(line: 744, column: 3, scope: !614)
!624 = !DILocation(line: 746, column: 9, scope: !614)
!625 = !DILocation(line: 746, column: 14, scope: !614)
!626 = !DILocation(line: 746, column: 32, scope: !614)
!627 = !DILocation(line: 746, column: 38, scope: !614)
!628 = !DILocation(line: 746, column: 2, scope: !614)
!629 = distinct !DISubprogram(name: "gpio_config", scope: !573, file: !573, line: 25, type: !71, scopeLine: 26, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !0, retainedNodes: !163)
!630 = !DILocalVariable(name: "port", arg: 1, scope: !629, file: !573, line: 25, type: !73)
!631 = !DILocation(line: 25, column: 71, scope: !629)
!632 = !DILocalVariable(name: "pin", arg: 2, scope: !629, file: !573, line: 25, type: !88)
!633 = !DILocation(line: 25, column: 88, scope: !629)
!634 = !DILocalVariable(name: "flags", arg: 3, scope: !629, file: !573, line: 25, type: !91)
!635 = !DILocation(line: 25, column: 106, scope: !629)
!636 = !DILocation(line: 32, column: 2, scope: !629)
!637 = !DILocation(line: 32, column: 2, scope: !638)
!638 = distinct !DILexicalBlock(scope: !629, file: !573, line: 32, column: 2)
!639 = !{i32 -2141750253}
!640 = !DILocation(line: 33, column: 28, scope: !629)
!641 = !DILocation(line: 33, column: 34, scope: !629)
!642 = !DILocation(line: 33, column: 39, scope: !629)
!643 = !DILocation(line: 33, column: 9, scope: !629)
!644 = !DILocation(line: 33, column: 2, scope: !629)
!645 = distinct !DISubprogram(name: "z_impl_gpio_pin_interrupt_configure", scope: !51, file: !51, line: 475, type: !71, scopeLine: 478, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !0, retainedNodes: !163)
!646 = !DILocalVariable(name: "port", arg: 1, scope: !645, file: !51, line: 475, type: !73)
!647 = !DILocation(line: 475, column: 76, scope: !645)
!648 = !DILocalVariable(name: "pin", arg: 2, scope: !645, file: !51, line: 476, type: !88)
!649 = !DILocation(line: 476, column: 24, scope: !645)
!650 = !DILocalVariable(name: "flags", arg: 3, scope: !645, file: !51, line: 477, type: !91)
!651 = !DILocation(line: 477, column: 26, scope: !645)
!652 = !DILocalVariable(name: "api", scope: !645, file: !51, line: 479, type: !65)
!653 = !DILocation(line: 479, column: 32, scope: !645)
!654 = !DILocation(line: 480, column: 35, scope: !645)
!655 = !DILocation(line: 480, column: 41, scope: !645)
!656 = !DILocation(line: 480, column: 3, scope: !645)
!657 = !DILocalVariable(name: "cfg", scope: !645, file: !51, line: 481, type: !227)
!658 = !DILocation(line: 481, column: 41, scope: !645)
!659 = !DILocation(line: 482, column: 38, scope: !645)
!660 = !DILocation(line: 482, column: 44, scope: !645)
!661 = !DILocation(line: 482, column: 3, scope: !645)
!662 = !DILocalVariable(name: "data", scope: !645, file: !51, line: 483, type: !320)
!663 = !DILocation(line: 483, column: 39, scope: !645)
!664 = !DILocation(line: 484, column: 36, scope: !645)
!665 = !DILocation(line: 484, column: 42, scope: !645)
!666 = !DILocation(line: 484, column: 3, scope: !645)
!667 = !DILocalVariable(name: "trig", scope: !645, file: !51, line: 485, type: !57)
!668 = !DILocation(line: 485, column: 21, scope: !645)
!669 = !DILocalVariable(name: "mode", scope: !645, file: !51, line: 486, type: !50)
!670 = !DILocation(line: 486, column: 21, scope: !645)
!671 = !DILocation(line: 509, column: 8, scope: !645)
!672 = !DILocation(line: 513, column: 8, scope: !673)
!673 = distinct !DILexicalBlock(scope: !645, file: !51, line: 513, column: 6)
!674 = !DILocation(line: 513, column: 14, scope: !673)
!675 = !DILocation(line: 513, column: 41, scope: !673)
!676 = !DILocation(line: 513, column: 47, scope: !673)
!677 = !DILocation(line: 514, column: 8, scope: !673)
!678 = !DILocation(line: 514, column: 14, scope: !673)
!679 = !DILocation(line: 514, column: 41, scope: !673)
!680 = !DILocation(line: 514, column: 21, scope: !673)
!681 = !DILocation(line: 514, column: 51, scope: !673)
!682 = !DILocation(line: 513, column: 6, scope: !645)
!683 = !DILocation(line: 516, column: 9, scope: !684)
!684 = distinct !DILexicalBlock(scope: !673, file: !51, line: 514, column: 58)
!685 = !DILocation(line: 517, column: 2, scope: !684)
!686 = !DILocation(line: 519, column: 30, scope: !645)
!687 = !DILocation(line: 519, column: 36, scope: !645)
!688 = !DILocation(line: 519, column: 7, scope: !645)
!689 = !DILocation(line: 520, column: 30, scope: !645)
!690 = !DILocation(line: 520, column: 36, scope: !645)
!691 = !DILocation(line: 520, column: 7, scope: !645)
!692 = !DILocation(line: 522, column: 9, scope: !645)
!693 = !DILocation(line: 522, column: 14, scope: !645)
!694 = !DILocation(line: 522, column: 38, scope: !645)
!695 = !DILocation(line: 522, column: 44, scope: !645)
!696 = !DILocation(line: 522, column: 49, scope: !645)
!697 = !DILocation(line: 522, column: 55, scope: !645)
!698 = !DILocation(line: 522, column: 2, scope: !645)
!699 = distinct !DISubprogram(name: "z_impl_gpio_config", scope: !51, file: !51, line: 438, type: !71, scopeLine: 440, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !0, retainedNodes: !163)
!700 = !DILocalVariable(name: "port", arg: 1, scope: !699, file: !51, line: 438, type: !73)
!701 = !DILocation(line: 438, column: 59, scope: !699)
!702 = !DILocalVariable(name: "pin", arg: 2, scope: !699, file: !51, line: 439, type: !88)
!703 = !DILocation(line: 439, column: 21, scope: !699)
!704 = !DILocalVariable(name: "flags", arg: 3, scope: !699, file: !51, line: 439, type: !91)
!705 = !DILocation(line: 439, column: 39, scope: !699)
!706 = !DILocalVariable(name: "api", scope: !699, file: !51, line: 441, type: !65)
!707 = !DILocation(line: 441, column: 32, scope: !699)
!708 = !DILocation(line: 442, column: 35, scope: !699)
!709 = !DILocation(line: 442, column: 41, scope: !699)
!710 = !DILocation(line: 442, column: 3, scope: !699)
!711 = !DILocation(line: 444, column: 9, scope: !699)
!712 = !DILocation(line: 444, column: 14, scope: !699)
!713 = !DILocation(line: 444, column: 28, scope: !699)
!714 = !DILocation(line: 444, column: 34, scope: !699)
!715 = !DILocation(line: 444, column: 39, scope: !699)
!716 = !DILocation(line: 444, column: 2, scope: !699)
