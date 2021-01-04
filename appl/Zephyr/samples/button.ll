; ModuleID = 'llvm-link'
source_filename = "llvm-link"
target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "thumbv7em-none-unknown-eabi"

%struct.gpio_callback = type { %struct._snode, void (%struct.device*, %struct.gpio_callback*, i32)*, i32 }
%struct._snode = type { %struct._snode* }
%struct.device = type { i8*, i8*, i8*, i8* }
%struct.gpio_driver_api = type { i32 (%struct.device*, i8, i32)*, i32 (%struct.device*, i32*)*, i32 (%struct.device*, i32, i32)*, i32 (%struct.device*, i32)*, i32 (%struct.device*, i32)*, i32 (%struct.device*, i32)*, i32 (%struct.device*, i8, i32, i32)*, i32 (%struct.device*, %struct.gpio_callback*, i1)*, i32 (%struct.device*)* }
%struct.gpio_driver_config = type { i32 }
%struct.k_timeout_t = type { i64 }

@.str = private unnamed_addr constant [22 x i8] c"Button pressed at %u\0A\00", align 1
@.str.1 = private unnamed_addr constant [6 x i8] c"GPIOC\00", align 1
@.str.2 = private unnamed_addr constant [30 x i8] c"Error: didn't find %s device\0A\00", align 1
@.str.3 = private unnamed_addr constant [41 x i8] c"Error %d: failed to configure %s pin %d\0A\00", align 1
@.str.4 = private unnamed_addr constant [54 x i8] c"Error %d: failed to configure interrupt on %s pin %d\0A\00", align 1
@button_cb_data = internal global %struct.gpio_callback zeroinitializer, align 4, !dbg !0
@.str.5 = private unnamed_addr constant [28 x i8] c"Set up button at %s pin %d\0A\00", align 1
@.str.6 = private unnamed_addr constant [18 x i8] c"Press the button\0A\00", align 1
@.str.7 = private unnamed_addr constant [6 x i8] c"GPIOA\00", align 1
@.str.8 = private unnamed_addr constant [27 x i8] c"Didn't find LED device %s\0A\00", align 1
@.str.9 = private unnamed_addr constant [52 x i8] c"Error %d: failed to configure LED device %s pin %d\0A\00", align 1
@.str.10 = private unnamed_addr constant [25 x i8] c"Set up LED at %s pin %d\0A\00", align 1

; Function Attrs: noinline nounwind optnone
define dso_local void @button_pressed(%struct.device*, %struct.gpio_callback*, i32) #0 !dbg !163 {
  %4 = alloca %struct.device*, align 4
  %5 = alloca %struct.gpio_callback*, align 4
  %6 = alloca i32, align 4
  store %struct.device* %0, %struct.device** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %4, metadata !168, metadata !DIExpression()), !dbg !169
  store %struct.gpio_callback* %1, %struct.gpio_callback** %5, align 4
  call void @llvm.dbg.declare(metadata %struct.gpio_callback** %5, metadata !170, metadata !DIExpression()), !dbg !171
  store i32 %2, i32* %6, align 4
  call void @llvm.dbg.declare(metadata i32* %6, metadata !172, metadata !DIExpression()), !dbg !173
  %7 = call i32 @k_cycle_get_32() #3, !dbg !174
  call void (i8*, ...) @printk(i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str, i32 0, i32 0), i32 %7) #3, !dbg !175
  ret void, !dbg !176
}

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: noinline nounwind optnone
define internal i32 @k_cycle_get_32() #0 !dbg !177 {
  %1 = call i32 @arch_k_cycle_get_32() #3, !dbg !180
  ret i32 %1, !dbg !181
}

declare dso_local void @printk(i8*, ...) #2

; Function Attrs: noinline nounwind optnone
define internal i32 @arch_k_cycle_get_32() #0 !dbg !182 {
  %1 = call i32 @z_timer_cycle_get_32() #3, !dbg !184
  ret i32 %1, !dbg !185
}

declare dso_local i32 @z_timer_cycle_get_32() #2

; Function Attrs: noinline nounwind optnone
define dso_local void @main() #0 !dbg !186 {
  %1 = alloca %struct.device*, align 4
  %2 = alloca %struct.device*, align 4
  %3 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %1, metadata !189, metadata !DIExpression()), !dbg !190
  call void @llvm.dbg.declare(metadata %struct.device** %2, metadata !191, metadata !DIExpression()), !dbg !192
  call void @llvm.dbg.declare(metadata i32* %3, metadata !193, metadata !DIExpression()), !dbg !194
  %4 = call %struct.device* @device_get_binding(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.1, i32 0, i32 0)) #3, !dbg !195
  store %struct.device* %4, %struct.device** %1, align 4, !dbg !196
  %5 = load %struct.device*, %struct.device** %1, align 4, !dbg !197
  %6 = icmp eq %struct.device* %5, null, !dbg !199
  br i1 %6, label %7, label %8, !dbg !200

7:                                                ; preds = %0
  call void (i8*, ...) @printk(i8* getelementptr inbounds ([30 x i8], [30 x i8]* @.str.2, i32 0, i32 0), i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.1, i32 0, i32 0)) #3, !dbg !201
  br label %30, !dbg !203

8:                                                ; preds = %0
  %9 = load %struct.device*, %struct.device** %1, align 4, !dbg !204
  %10 = call i32 @gpio_pin_configure(%struct.device* %9, i8 zeroext 13, i32 257) #3, !dbg !205
  store i32 %10, i32* %3, align 4, !dbg !206
  %11 = load i32, i32* %3, align 4, !dbg !207
  %12 = icmp ne i32 %11, 0, !dbg !209
  br i1 %12, label %13, label %15, !dbg !210

13:                                               ; preds = %8
  %14 = load i32, i32* %3, align 4, !dbg !211
  call void (i8*, ...) @printk(i8* getelementptr inbounds ([41 x i8], [41 x i8]* @.str.3, i32 0, i32 0), i32 %14, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.1, i32 0, i32 0), i32 13) #3, !dbg !213
  br label %30, !dbg !214

15:                                               ; preds = %8
  %16 = load %struct.device*, %struct.device** %1, align 4, !dbg !215
  %17 = call i32 @gpio_pin_interrupt_configure(%struct.device* %16, i8 zeroext 13, i32 376832) #3, !dbg !216
  store i32 %17, i32* %3, align 4, !dbg !217
  %18 = load i32, i32* %3, align 4, !dbg !218
  %19 = icmp ne i32 %18, 0, !dbg !220
  br i1 %19, label %20, label %22, !dbg !221

20:                                               ; preds = %15
  %21 = load i32, i32* %3, align 4, !dbg !222
  call void (i8*, ...) @printk(i8* getelementptr inbounds ([54 x i8], [54 x i8]* @.str.4, i32 0, i32 0), i32 %21, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.1, i32 0, i32 0), i32 13) #3, !dbg !224
  br label %30, !dbg !225

22:                                               ; preds = %15
  call void @gpio_init_callback(%struct.gpio_callback* @button_cb_data, void (%struct.device*, %struct.gpio_callback*, i32)* @button_pressed, i32 8192) #3, !dbg !226
  %23 = load %struct.device*, %struct.device** %1, align 4, !dbg !227
  %24 = call i32 @gpio_add_callback(%struct.device* %23, %struct.gpio_callback* @button_cb_data) #3, !dbg !228
  call void (i8*, ...) @printk(i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.5, i32 0, i32 0), i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.1, i32 0, i32 0), i32 13) #3, !dbg !229
  %25 = call %struct.device* @initialize_led() #3, !dbg !230
  store %struct.device* %25, %struct.device** %2, align 4, !dbg !231
  call void (i8*, ...) @printk(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @.str.6, i32 0, i32 0)) #3, !dbg !232
  br label %26, !dbg !233

26:                                               ; preds = %26, %22
  %27 = load %struct.device*, %struct.device** %1, align 4, !dbg !234
  %28 = load %struct.device*, %struct.device** %2, align 4, !dbg !236
  call void @match_led_to_button(%struct.device* %27, %struct.device* %28) #3, !dbg !237
  %29 = call i32 @k_msleep(i32 1) #3, !dbg !238
  br label %26, !dbg !233, !llvm.loop !239

30:                                               ; preds = %20, %13, %7
  ret void, !dbg !241
}

; Function Attrs: noinline nounwind optnone
define internal %struct.device* @device_get_binding(i8*) #0 !dbg !242 {
  %2 = alloca i8*, align 4
  store i8* %0, i8** %2, align 4
  call void @llvm.dbg.declare(metadata i8** %2, metadata !246, metadata !DIExpression()), !dbg !247
  br label %3, !dbg !248

3:                                                ; preds = %1
  call void asm sideeffect "", "~{memory}"() #4, !dbg !249, !srcloc !251
  br label %4, !dbg !249

4:                                                ; preds = %3
  %5 = load i8*, i8** %2, align 4, !dbg !252
  %6 = call %struct.device* @z_impl_device_get_binding(i8* %5) #3, !dbg !253
  ret %struct.device* %6, !dbg !254
}

; Function Attrs: noinline nounwind optnone
define internal i32 @gpio_pin_configure(%struct.device*, i8 zeroext, i32) #0 !dbg !255 {
  %4 = alloca i32, align 4
  %5 = alloca %struct.device*, align 4
  %6 = alloca i8, align 1
  %7 = alloca i32, align 4
  %8 = alloca %struct.gpio_driver_api*, align 4
  %9 = alloca %struct.gpio_driver_config*, align 4
  %10 = alloca %struct.gpio_driver_config*, align 4
  %11 = alloca i32, align 4
  store %struct.device* %0, %struct.device** %5, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %5, metadata !256, metadata !DIExpression()), !dbg !257
  store i8 %1, i8* %6, align 1
  call void @llvm.dbg.declare(metadata i8* %6, metadata !258, metadata !DIExpression()), !dbg !259
  store i32 %2, i32* %7, align 4
  call void @llvm.dbg.declare(metadata i32* %7, metadata !260, metadata !DIExpression()), !dbg !261
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_api** %8, metadata !262, metadata !DIExpression()), !dbg !263
  %12 = load %struct.device*, %struct.device** %5, align 4, !dbg !264
  %13 = getelementptr inbounds %struct.device, %struct.device* %12, i32 0, i32 2, !dbg !265
  %14 = load i8*, i8** %13, align 4, !dbg !265
  %15 = bitcast i8* %14 to %struct.gpio_driver_api*, !dbg !266
  store %struct.gpio_driver_api* %15, %struct.gpio_driver_api** %8, align 4, !dbg !263
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_config** %9, metadata !267, metadata !DIExpression()), !dbg !269
  %16 = load %struct.device*, %struct.device** %5, align 4, !dbg !270
  %17 = getelementptr inbounds %struct.device, %struct.device* %16, i32 0, i32 1, !dbg !271
  %18 = load i8*, i8** %17, align 4, !dbg !271
  %19 = bitcast i8* %18 to %struct.gpio_driver_config*, !dbg !272
  store %struct.gpio_driver_config* %19, %struct.gpio_driver_config** %9, align 4, !dbg !269
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_config** %10, metadata !273, metadata !DIExpression()), !dbg !274
  %20 = load %struct.device*, %struct.device** %5, align 4, !dbg !275
  %21 = getelementptr inbounds %struct.device, %struct.device* %20, i32 0, i32 3, !dbg !276
  %22 = load i8*, i8** %21, align 4, !dbg !276
  %23 = bitcast i8* %22 to %struct.gpio_driver_config*, !dbg !277
  store %struct.gpio_driver_config* %23, %struct.gpio_driver_config** %10, align 4, !dbg !274
  call void @llvm.dbg.declare(metadata i32* %11, metadata !278, metadata !DIExpression()), !dbg !279
  %24 = load i32, i32* %7, align 4, !dbg !280
  %25 = and i32 %24, 4096, !dbg !282
  %26 = icmp ne i32 %25, 0, !dbg !283
  br i1 %26, label %27, label %38, !dbg !284

27:                                               ; preds = %3
  %28 = load i32, i32* %7, align 4, !dbg !285
  %29 = and i32 %28, 3072, !dbg !286
  %30 = icmp ne i32 %29, 0, !dbg !287
  br i1 %30, label %31, label %38, !dbg !288

31:                                               ; preds = %27
  %32 = load i32, i32* %7, align 4, !dbg !289
  %33 = and i32 %32, 1, !dbg !290
  %34 = icmp ne i32 %33, 0, !dbg !291
  br i1 %34, label %35, label %38, !dbg !292

35:                                               ; preds = %31
  %36 = load i32, i32* %7, align 4, !dbg !293
  %37 = xor i32 %36, 7168, !dbg !293
  store i32 %37, i32* %7, align 4, !dbg !293
  br label %38, !dbg !295

38:                                               ; preds = %35, %31, %27, %3
  %39 = load %struct.gpio_driver_config*, %struct.gpio_driver_config** %9, align 4, !dbg !296
  %40 = load %struct.device*, %struct.device** %5, align 4, !dbg !297
  %41 = load i8, i8* %6, align 1, !dbg !298
  %42 = load i32, i32* %7, align 4, !dbg !299
  %43 = call i32 @gpio_config(%struct.device* %40, i8 zeroext %41, i32 %42) #3, !dbg !300
  store i32 %43, i32* %11, align 4, !dbg !301
  %44 = load i32, i32* %11, align 4, !dbg !302
  %45 = icmp ne i32 %44, 0, !dbg !304
  br i1 %45, label %46, label %48, !dbg !305

46:                                               ; preds = %38
  %47 = load i32, i32* %11, align 4, !dbg !306
  store i32 %47, i32* %4, align 4, !dbg !308
  br label %87, !dbg !308

48:                                               ; preds = %38
  %49 = load i32, i32* %7, align 4, !dbg !309
  %50 = and i32 %49, 1, !dbg !311
  %51 = icmp ne i32 %50, 0, !dbg !312
  br i1 %51, label %52, label %60, !dbg !313

52:                                               ; preds = %48
  %53 = load i8, i8* %6, align 1, !dbg !314
  %54 = zext i8 %53 to i32, !dbg !314
  %55 = shl i32 1, %54, !dbg !314
  %56 = load %struct.gpio_driver_config*, %struct.gpio_driver_config** %10, align 4, !dbg !316
  %57 = getelementptr inbounds %struct.gpio_driver_config, %struct.gpio_driver_config* %56, i32 0, i32 0, !dbg !317
  %58 = load i32, i32* %57, align 4, !dbg !318
  %59 = or i32 %58, %55, !dbg !318
  store i32 %59, i32* %57, align 4, !dbg !318
  br label %69, !dbg !319

60:                                               ; preds = %48
  %61 = load i8, i8* %6, align 1, !dbg !320
  %62 = zext i8 %61 to i32, !dbg !320
  %63 = shl i32 1, %62, !dbg !320
  %64 = xor i32 %63, -1, !dbg !322
  %65 = load %struct.gpio_driver_config*, %struct.gpio_driver_config** %10, align 4, !dbg !323
  %66 = getelementptr inbounds %struct.gpio_driver_config, %struct.gpio_driver_config* %65, i32 0, i32 0, !dbg !324
  %67 = load i32, i32* %66, align 4, !dbg !325
  %68 = and i32 %67, %64, !dbg !325
  store i32 %68, i32* %66, align 4, !dbg !325
  br label %69

69:                                               ; preds = %60, %52
  %70 = load i32, i32* %7, align 4, !dbg !326
  %71 = and i32 %70, 24576, !dbg !328
  %72 = icmp ne i32 %71, 0, !dbg !329
  br i1 %72, label %73, label %85, !dbg !330

73:                                               ; preds = %69
  %74 = load %struct.gpio_driver_api*, %struct.gpio_driver_api** %8, align 4, !dbg !331
  %75 = getelementptr inbounds %struct.gpio_driver_api, %struct.gpio_driver_api* %74, i32 0, i32 6, !dbg !332
  %76 = load i32 (%struct.device*, i8, i32, i32)*, i32 (%struct.device*, i8, i32, i32)** %75, align 4, !dbg !332
  %77 = icmp ne i32 (%struct.device*, i8, i32, i32)* %76, null, !dbg !333
  br i1 %77, label %78, label %85, !dbg !334

78:                                               ; preds = %73
  %79 = load i32, i32* %7, align 4, !dbg !335
  %80 = and i32 %79, -524289, !dbg !335
  store i32 %80, i32* %7, align 4, !dbg !335
  %81 = load %struct.device*, %struct.device** %5, align 4, !dbg !337
  %82 = load i8, i8* %6, align 1, !dbg !338
  %83 = load i32, i32* %7, align 4, !dbg !339
  %84 = call i32 @z_impl_gpio_pin_interrupt_configure(%struct.device* %81, i8 zeroext %82, i32 %83) #3, !dbg !340
  store i32 %84, i32* %11, align 4, !dbg !341
  br label %85, !dbg !342

85:                                               ; preds = %78, %73, %69
  %86 = load i32, i32* %11, align 4, !dbg !343
  store i32 %86, i32* %4, align 4, !dbg !344
  br label %87, !dbg !344

87:                                               ; preds = %85, %46
  %88 = load i32, i32* %4, align 4, !dbg !345
  ret i32 %88, !dbg !345
}

; Function Attrs: noinline nounwind optnone
define internal i32 @gpio_pin_interrupt_configure(%struct.device*, i8 zeroext, i32) #0 !dbg !346 {
  %4 = alloca %struct.device*, align 4
  %5 = alloca i8, align 1
  %6 = alloca i32, align 4
  store %struct.device* %0, %struct.device** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %4, metadata !348, metadata !DIExpression()), !dbg !349
  store i8 %1, i8* %5, align 1
  call void @llvm.dbg.declare(metadata i8* %5, metadata !350, metadata !DIExpression()), !dbg !351
  store i32 %2, i32* %6, align 4
  call void @llvm.dbg.declare(metadata i32* %6, metadata !352, metadata !DIExpression()), !dbg !353
  br label %7, !dbg !354

7:                                                ; preds = %3
  call void asm sideeffect "", "~{memory}"() #4, !dbg !355, !srcloc !357
  br label %8, !dbg !355

8:                                                ; preds = %7
  %9 = load %struct.device*, %struct.device** %4, align 4, !dbg !358
  %10 = load i8, i8* %5, align 1, !dbg !359
  %11 = load i32, i32* %6, align 4, !dbg !360
  %12 = call i32 @z_impl_gpio_pin_interrupt_configure(%struct.device* %9, i8 zeroext %10, i32 %11) #3, !dbg !361
  ret i32 %12, !dbg !362
}

; Function Attrs: noinline nounwind optnone
define internal void @gpio_init_callback(%struct.gpio_callback*, void (%struct.device*, %struct.gpio_callback*, i32)*, i32) #0 !dbg !363 {
  %4 = alloca %struct.gpio_callback*, align 4
  %5 = alloca void (%struct.device*, %struct.gpio_callback*, i32)*, align 4
  %6 = alloca i32, align 4
  store %struct.gpio_callback* %0, %struct.gpio_callback** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.gpio_callback** %4, metadata !366, metadata !DIExpression()), !dbg !367
  store void (%struct.device*, %struct.gpio_callback*, i32)* %1, void (%struct.device*, %struct.gpio_callback*, i32)** %5, align 4
  call void @llvm.dbg.declare(metadata void (%struct.device*, %struct.gpio_callback*, i32)** %5, metadata !368, metadata !DIExpression()), !dbg !369
  store i32 %2, i32* %6, align 4
  call void @llvm.dbg.declare(metadata i32* %6, metadata !370, metadata !DIExpression()), !dbg !371
  %7 = load void (%struct.device*, %struct.gpio_callback*, i32)*, void (%struct.device*, %struct.gpio_callback*, i32)** %5, align 4, !dbg !372
  %8 = load %struct.gpio_callback*, %struct.gpio_callback** %4, align 4, !dbg !373
  %9 = getelementptr inbounds %struct.gpio_callback, %struct.gpio_callback* %8, i32 0, i32 1, !dbg !374
  store void (%struct.device*, %struct.gpio_callback*, i32)* %7, void (%struct.device*, %struct.gpio_callback*, i32)** %9, align 4, !dbg !375
  %10 = load i32, i32* %6, align 4, !dbg !376
  %11 = load %struct.gpio_callback*, %struct.gpio_callback** %4, align 4, !dbg !377
  %12 = getelementptr inbounds %struct.gpio_callback, %struct.gpio_callback* %11, i32 0, i32 2, !dbg !378
  store i32 %10, i32* %12, align 4, !dbg !379
  ret void, !dbg !380
}

; Function Attrs: noinline nounwind optnone
define internal i32 @gpio_add_callback(%struct.device*, %struct.gpio_callback*) #0 !dbg !381 {
  %3 = alloca i32, align 4
  %4 = alloca %struct.device*, align 4
  %5 = alloca %struct.gpio_callback*, align 4
  %6 = alloca %struct.gpio_driver_api*, align 4
  store %struct.device* %0, %struct.device** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %4, metadata !384, metadata !DIExpression()), !dbg !385
  store %struct.gpio_callback* %1, %struct.gpio_callback** %5, align 4
  call void @llvm.dbg.declare(metadata %struct.gpio_callback** %5, metadata !386, metadata !DIExpression()), !dbg !387
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_api** %6, metadata !388, metadata !DIExpression()), !dbg !389
  %7 = load %struct.device*, %struct.device** %4, align 4, !dbg !390
  %8 = getelementptr inbounds %struct.device, %struct.device* %7, i32 0, i32 2, !dbg !391
  %9 = load i8*, i8** %8, align 4, !dbg !391
  %10 = bitcast i8* %9 to %struct.gpio_driver_api*, !dbg !392
  store %struct.gpio_driver_api* %10, %struct.gpio_driver_api** %6, align 4, !dbg !389
  %11 = load %struct.gpio_driver_api*, %struct.gpio_driver_api** %6, align 4, !dbg !393
  %12 = getelementptr inbounds %struct.gpio_driver_api, %struct.gpio_driver_api* %11, i32 0, i32 7, !dbg !395
  %13 = load i32 (%struct.device*, %struct.gpio_callback*, i1)*, i32 (%struct.device*, %struct.gpio_callback*, i1)** %12, align 4, !dbg !395
  %14 = icmp eq i32 (%struct.device*, %struct.gpio_callback*, i1)* %13, null, !dbg !396
  br i1 %14, label %15, label %16, !dbg !397

15:                                               ; preds = %2
  store i32 -35, i32* %3, align 4, !dbg !398
  br label %23, !dbg !398

16:                                               ; preds = %2
  %17 = load %struct.gpio_driver_api*, %struct.gpio_driver_api** %6, align 4, !dbg !400
  %18 = getelementptr inbounds %struct.gpio_driver_api, %struct.gpio_driver_api* %17, i32 0, i32 7, !dbg !401
  %19 = load i32 (%struct.device*, %struct.gpio_callback*, i1)*, i32 (%struct.device*, %struct.gpio_callback*, i1)** %18, align 4, !dbg !401
  %20 = load %struct.device*, %struct.device** %4, align 4, !dbg !402
  %21 = load %struct.gpio_callback*, %struct.gpio_callback** %5, align 4, !dbg !403
  %22 = call i32 %19(%struct.device* %20, %struct.gpio_callback* %21, i1 zeroext true) #3, !dbg !400
  store i32 %22, i32* %3, align 4, !dbg !404
  br label %23, !dbg !404

23:                                               ; preds = %16, %15
  %24 = load i32, i32* %3, align 4, !dbg !405
  ret i32 %24, !dbg !405
}

; Function Attrs: noinline nounwind optnone
define internal %struct.device* @initialize_led() #0 !dbg !406 {
  %1 = alloca %struct.device*, align 4
  %2 = alloca %struct.device*, align 4
  %3 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %2, metadata !409, metadata !DIExpression()), !dbg !410
  call void @llvm.dbg.declare(metadata i32* %3, metadata !411, metadata !DIExpression()), !dbg !412
  %4 = call %struct.device* @device_get_binding(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.7, i32 0, i32 0)) #3, !dbg !413
  store %struct.device* %4, %struct.device** %2, align 4, !dbg !414
  %5 = load %struct.device*, %struct.device** %2, align 4, !dbg !415
  %6 = icmp eq %struct.device* %5, null, !dbg !417
  br i1 %6, label %7, label %8, !dbg !418

7:                                                ; preds = %0
  call void (i8*, ...) @printk(i8* getelementptr inbounds ([27 x i8], [27 x i8]* @.str.8, i32 0, i32 0), i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.7, i32 0, i32 0)) #3, !dbg !419
  store %struct.device* null, %struct.device** %1, align 4, !dbg !421
  br label %17, !dbg !421

8:                                                ; preds = %0
  %9 = load %struct.device*, %struct.device** %2, align 4, !dbg !422
  %10 = call i32 @gpio_pin_configure(%struct.device* %9, i8 zeroext 5, i32 512) #3, !dbg !423
  store i32 %10, i32* %3, align 4, !dbg !424
  %11 = load i32, i32* %3, align 4, !dbg !425
  %12 = icmp ne i32 %11, 0, !dbg !427
  br i1 %12, label %13, label %15, !dbg !428

13:                                               ; preds = %8
  %14 = load i32, i32* %3, align 4, !dbg !429
  call void (i8*, ...) @printk(i8* getelementptr inbounds ([52 x i8], [52 x i8]* @.str.9, i32 0, i32 0), i32 %14, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.7, i32 0, i32 0), i32 5) #3, !dbg !431
  store %struct.device* null, %struct.device** %1, align 4, !dbg !432
  br label %17, !dbg !432

15:                                               ; preds = %8
  call void (i8*, ...) @printk(i8* getelementptr inbounds ([25 x i8], [25 x i8]* @.str.10, i32 0, i32 0), i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.7, i32 0, i32 0), i32 5) #3, !dbg !433
  %16 = load %struct.device*, %struct.device** %2, align 4, !dbg !434
  store %struct.device* %16, %struct.device** %1, align 4, !dbg !435
  br label %17, !dbg !435

17:                                               ; preds = %15, %13, %7
  %18 = load %struct.device*, %struct.device** %1, align 4, !dbg !436
  ret %struct.device* %18, !dbg !436
}

; Function Attrs: noinline nounwind optnone
define internal void @match_led_to_button(%struct.device*, %struct.device*) #0 !dbg !437 {
  %3 = alloca %struct.device*, align 4
  %4 = alloca %struct.device*, align 4
  %5 = alloca i8, align 1
  store %struct.device* %0, %struct.device** %3, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %3, metadata !440, metadata !DIExpression()), !dbg !441
  store %struct.device* %1, %struct.device** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %4, metadata !442, metadata !DIExpression()), !dbg !443
  call void @llvm.dbg.declare(metadata i8* %5, metadata !444, metadata !DIExpression()), !dbg !445
  %6 = load %struct.device*, %struct.device** %3, align 4, !dbg !446
  %7 = call i32 @gpio_pin_get(%struct.device* %6, i8 zeroext 13) #3, !dbg !447
  %8 = icmp ne i32 %7, 0, !dbg !447
  %9 = zext i1 %8 to i8, !dbg !448
  store i8 %9, i8* %5, align 1, !dbg !448
  %10 = load %struct.device*, %struct.device** %4, align 4, !dbg !449
  %11 = load i8, i8* %5, align 1, !dbg !450
  %12 = trunc i8 %11 to i1, !dbg !450
  %13 = zext i1 %12 to i32, !dbg !450
  %14 = call i32 @gpio_pin_set(%struct.device* %10, i8 zeroext 5, i32 %13) #3, !dbg !451
  ret void, !dbg !452
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_msleep(i32) #0 !dbg !453 {
  %2 = alloca i32, align 4
  %3 = alloca %struct.k_timeout_t, align 8
  store i32 %0, i32* %2, align 4
  call void @llvm.dbg.declare(metadata i32* %2, metadata !457, metadata !DIExpression()), !dbg !458
  %4 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !459
  %5 = load i32, i32* %2, align 4, !dbg !459
  %6 = icmp sgt i32 %5, 0, !dbg !459
  br i1 %6, label %7, label %9, !dbg !459

7:                                                ; preds = %1
  %8 = load i32, i32* %2, align 4, !dbg !459
  br label %10, !dbg !459

9:                                                ; preds = %1
  br label %10, !dbg !459

10:                                               ; preds = %9, %7
  %11 = phi i32 [ %8, %7 ], [ 0, %9 ], !dbg !459
  %12 = sext i32 %11 to i64, !dbg !459
  %13 = call i64 @k_ms_to_ticks_ceil64(i64 %12) #3, !dbg !459
  store i64 %13, i64* %4, align 8, !dbg !459
  %14 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !460
  %15 = bitcast i64* %14 to [1 x i64]*, !dbg !460
  %16 = load [1 x i64], [1 x i64]* %15, align 8, !dbg !460
  %17 = call i32 @k_sleep([1 x i64] %16) #3, !dbg !460
  ret i32 %17, !dbg !461
}

; Function Attrs: noinline nounwind optnone
define internal i64 @k_ms_to_ticks_ceil64(i64) #0 !dbg !462 {
  %2 = alloca i64, align 8
  %3 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %3, metadata !468, metadata !DIExpression()), !dbg !472
  %4 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !474, metadata !DIExpression()), !dbg !475
  %5 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %5, metadata !476, metadata !DIExpression()), !dbg !477
  %6 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %6, metadata !478, metadata !DIExpression()), !dbg !479
  %7 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %7, metadata !480, metadata !DIExpression()), !dbg !481
  %8 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %8, metadata !482, metadata !DIExpression()), !dbg !483
  %9 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %9, metadata !484, metadata !DIExpression()), !dbg !485
  %10 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %10, metadata !486, metadata !DIExpression()), !dbg !487
  %11 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %11, metadata !488, metadata !DIExpression()), !dbg !489
  %12 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %12, metadata !490, metadata !DIExpression()), !dbg !491
  %13 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %13, metadata !492, metadata !DIExpression()), !dbg !495
  %14 = alloca i64, align 8
  store i64 %0, i64* %14, align 8
  call void @llvm.dbg.declare(metadata i64* %14, metadata !496, metadata !DIExpression()), !dbg !497
  %15 = load i64, i64* %14, align 8, !dbg !498
  store i64 %15, i64* %3, align 8
  store i32 1000, i32* %4, align 4
  store i32 10000, i32* %5, align 4
  store i8 1, i8* %6, align 1
  store i8 0, i8* %7, align 1
  store i8 1, i8* %8, align 1
  store i8 0, i8* %9, align 1
  %16 = load i8, i8* %6, align 1, !dbg !499
  %17 = trunc i8 %16 to i1, !dbg !499
  br i1 %17, label %18, label %27, !dbg !500

18:                                               ; preds = %1
  %19 = load i32, i32* %5, align 4, !dbg !501
  %20 = load i32, i32* %4, align 4, !dbg !502
  %21 = icmp ugt i32 %19, %20, !dbg !503
  br i1 %21, label %22, label %27, !dbg !504

22:                                               ; preds = %18
  %23 = load i32, i32* %5, align 4, !dbg !505
  %24 = load i32, i32* %4, align 4, !dbg !506
  %25 = urem i32 %23, %24, !dbg !507
  %26 = icmp eq i32 %25, 0, !dbg !508
  br label %27

27:                                               ; preds = %22, %18, %1
  %28 = phi i1 [ false, %18 ], [ false, %1 ], [ %26, %22 ], !dbg !509
  %29 = zext i1 %28 to i8, !dbg !487
  store i8 %29, i8* %10, align 1, !dbg !487
  %30 = load i8, i8* %6, align 1, !dbg !510
  %31 = trunc i8 %30 to i1, !dbg !510
  br i1 %31, label %32, label %41, !dbg !511

32:                                               ; preds = %27
  %33 = load i32, i32* %4, align 4, !dbg !512
  %34 = load i32, i32* %5, align 4, !dbg !513
  %35 = icmp ugt i32 %33, %34, !dbg !514
  br i1 %35, label %36, label %41, !dbg !515

36:                                               ; preds = %32
  %37 = load i32, i32* %4, align 4, !dbg !516
  %38 = load i32, i32* %5, align 4, !dbg !517
  %39 = urem i32 %37, %38, !dbg !518
  %40 = icmp eq i32 %39, 0, !dbg !519
  br label %41

41:                                               ; preds = %36, %32, %27
  %42 = phi i1 [ false, %32 ], [ false, %27 ], [ %40, %36 ], !dbg !509
  %43 = zext i1 %42 to i8, !dbg !489
  store i8 %43, i8* %11, align 1, !dbg !489
  %44 = load i32, i32* %4, align 4, !dbg !520
  %45 = load i32, i32* %5, align 4, !dbg !522
  %46 = icmp eq i32 %44, %45, !dbg !523
  br i1 %46, label %47, label %58, !dbg !524

47:                                               ; preds = %41
  %48 = load i8, i8* %7, align 1, !dbg !525
  %49 = trunc i8 %48 to i1, !dbg !525
  br i1 %49, label %50, label %54, !dbg !525

50:                                               ; preds = %47
  %51 = load i64, i64* %3, align 8, !dbg !527
  %52 = trunc i64 %51 to i32, !dbg !528
  %53 = zext i32 %52 to i64, !dbg !529
  br label %56, !dbg !525

54:                                               ; preds = %47
  %55 = load i64, i64* %3, align 8, !dbg !530
  br label %56, !dbg !525

56:                                               ; preds = %54, %50
  %57 = phi i64 [ %53, %50 ], [ %55, %54 ], !dbg !525
  store i64 %57, i64* %2, align 8, !dbg !531
  br label %160, !dbg !531

58:                                               ; preds = %41
  store i64 0, i64* %12, align 8, !dbg !491
  %59 = load i8, i8* %10, align 1, !dbg !532
  %60 = trunc i8 %59 to i1, !dbg !532
  br i1 %60, label %87, label %61, !dbg !533

61:                                               ; preds = %58
  %62 = load i8, i8* %11, align 1, !dbg !534
  %63 = trunc i8 %62 to i1, !dbg !534
  br i1 %63, label %64, label %68, !dbg !534

64:                                               ; preds = %61
  %65 = load i32, i32* %4, align 4, !dbg !535
  %66 = load i32, i32* %5, align 4, !dbg !536
  %67 = udiv i32 %65, %66, !dbg !537
  br label %70, !dbg !534

68:                                               ; preds = %61
  %69 = load i32, i32* %4, align 4, !dbg !538
  br label %70, !dbg !534

70:                                               ; preds = %68, %64
  %71 = phi i32 [ %67, %64 ], [ %69, %68 ], !dbg !534
  store i32 %71, i32* %13, align 4, !dbg !495
  %72 = load i8, i8* %8, align 1, !dbg !539
  %73 = trunc i8 %72 to i1, !dbg !539
  br i1 %73, label %74, label %78, !dbg !541

74:                                               ; preds = %70
  %75 = load i32, i32* %13, align 4, !dbg !542
  %76 = sub i32 %75, 1, !dbg !544
  %77 = zext i32 %76 to i64, !dbg !542
  store i64 %77, i64* %12, align 8, !dbg !545
  br label %86, !dbg !546

78:                                               ; preds = %70
  %79 = load i8, i8* %9, align 1, !dbg !547
  %80 = trunc i8 %79 to i1, !dbg !547
  br i1 %80, label %81, label %85, !dbg !549

81:                                               ; preds = %78
  %82 = load i32, i32* %13, align 4, !dbg !550
  %83 = udiv i32 %82, 2, !dbg !552
  %84 = zext i32 %83 to i64, !dbg !550
  store i64 %84, i64* %12, align 8, !dbg !553
  br label %85, !dbg !554

85:                                               ; preds = %81, %78
  br label %86

86:                                               ; preds = %85, %74
  br label %87, !dbg !555

87:                                               ; preds = %86, %58
  %88 = load i8, i8* %11, align 1, !dbg !556
  %89 = trunc i8 %88 to i1, !dbg !556
  br i1 %89, label %90, label %114, !dbg !558

90:                                               ; preds = %87
  %91 = load i64, i64* %12, align 8, !dbg !559
  %92 = load i64, i64* %3, align 8, !dbg !561
  %93 = add i64 %92, %91, !dbg !561
  store i64 %93, i64* %3, align 8, !dbg !561
  %94 = load i8, i8* %7, align 1, !dbg !562
  %95 = trunc i8 %94 to i1, !dbg !562
  br i1 %95, label %96, label %107, !dbg !564

96:                                               ; preds = %90
  %97 = load i64, i64* %3, align 8, !dbg !565
  %98 = icmp ult i64 %97, 4294967296, !dbg !566
  br i1 %98, label %99, label %107, !dbg !567

99:                                               ; preds = %96
  %100 = load i64, i64* %3, align 8, !dbg !568
  %101 = trunc i64 %100 to i32, !dbg !570
  %102 = load i32, i32* %4, align 4, !dbg !571
  %103 = load i32, i32* %5, align 4, !dbg !572
  %104 = udiv i32 %102, %103, !dbg !573
  %105 = udiv i32 %101, %104, !dbg !574
  %106 = zext i32 %105 to i64, !dbg !575
  store i64 %106, i64* %2, align 8, !dbg !576
  br label %160, !dbg !576

107:                                              ; preds = %96, %90
  %108 = load i64, i64* %3, align 8, !dbg !577
  %109 = load i32, i32* %4, align 4, !dbg !579
  %110 = load i32, i32* %5, align 4, !dbg !580
  %111 = udiv i32 %109, %110, !dbg !581
  %112 = zext i32 %111 to i64, !dbg !582
  %113 = udiv i64 %108, %112, !dbg !583
  store i64 %113, i64* %2, align 8, !dbg !584
  br label %160, !dbg !584

114:                                              ; preds = %87
  %115 = load i8, i8* %10, align 1, !dbg !585
  %116 = trunc i8 %115 to i1, !dbg !585
  br i1 %116, label %117, label %135, !dbg !587

117:                                              ; preds = %114
  %118 = load i8, i8* %7, align 1, !dbg !588
  %119 = trunc i8 %118 to i1, !dbg !588
  br i1 %119, label %120, label %128, !dbg !591

120:                                              ; preds = %117
  %121 = load i64, i64* %3, align 8, !dbg !592
  %122 = trunc i64 %121 to i32, !dbg !594
  %123 = load i32, i32* %5, align 4, !dbg !595
  %124 = load i32, i32* %4, align 4, !dbg !596
  %125 = udiv i32 %123, %124, !dbg !597
  %126 = mul i32 %122, %125, !dbg !598
  %127 = zext i32 %126 to i64, !dbg !599
  store i64 %127, i64* %2, align 8, !dbg !600
  br label %160, !dbg !600

128:                                              ; preds = %117
  %129 = load i64, i64* %3, align 8, !dbg !601
  %130 = load i32, i32* %5, align 4, !dbg !603
  %131 = load i32, i32* %4, align 4, !dbg !604
  %132 = udiv i32 %130, %131, !dbg !605
  %133 = zext i32 %132 to i64, !dbg !606
  %134 = mul i64 %129, %133, !dbg !607
  store i64 %134, i64* %2, align 8, !dbg !608
  br label %160, !dbg !608

135:                                              ; preds = %114
  %136 = load i8, i8* %7, align 1, !dbg !609
  %137 = trunc i8 %136 to i1, !dbg !609
  br i1 %137, label %138, label %150, !dbg !612

138:                                              ; preds = %135
  %139 = load i64, i64* %3, align 8, !dbg !613
  %140 = load i32, i32* %5, align 4, !dbg !615
  %141 = zext i32 %140 to i64, !dbg !615
  %142 = mul i64 %139, %141, !dbg !616
  %143 = load i64, i64* %12, align 8, !dbg !617
  %144 = add i64 %142, %143, !dbg !618
  %145 = load i32, i32* %4, align 4, !dbg !619
  %146 = zext i32 %145 to i64, !dbg !619
  %147 = udiv i64 %144, %146, !dbg !620
  %148 = trunc i64 %147 to i32, !dbg !621
  %149 = zext i32 %148 to i64, !dbg !621
  store i64 %149, i64* %2, align 8, !dbg !622
  br label %160, !dbg !622

150:                                              ; preds = %135
  %151 = load i64, i64* %3, align 8, !dbg !623
  %152 = load i32, i32* %5, align 4, !dbg !625
  %153 = zext i32 %152 to i64, !dbg !625
  %154 = mul i64 %151, %153, !dbg !626
  %155 = load i64, i64* %12, align 8, !dbg !627
  %156 = add i64 %154, %155, !dbg !628
  %157 = load i32, i32* %4, align 4, !dbg !629
  %158 = zext i32 %157 to i64, !dbg !629
  %159 = udiv i64 %156, %158, !dbg !630
  store i64 %159, i64* %2, align 8, !dbg !631
  br label %160, !dbg !631

160:                                              ; preds = %150, %138, %128, %120, %107, %99, %56
  %161 = load i64, i64* %2, align 8, !dbg !632
  ret i64 %161, !dbg !633
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_sleep([1 x i64]) #0 !dbg !634 {
  %2 = alloca %struct.k_timeout_t, align 8
  %3 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0
  %4 = bitcast i64* %3 to [1 x i64]*
  store [1 x i64] %0, [1 x i64]* %4, align 8
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %2, metadata !642, metadata !DIExpression()), !dbg !643
  br label %5, !dbg !644

5:                                                ; preds = %1
  call void asm sideeffect "", "~{memory}"() #4, !dbg !645, !srcloc !647
  br label %6, !dbg !645

6:                                                ; preds = %5
  %7 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !648
  %8 = bitcast i64* %7 to [1 x i64]*, !dbg !648
  %9 = load [1 x i64], [1 x i64]* %8, align 8, !dbg !648
  %10 = call i32 @z_impl_k_sleep([1 x i64] %9) #3, !dbg !648
  ret i32 %10, !dbg !649
}

declare dso_local i32 @z_impl_k_sleep([1 x i64]) #2

; Function Attrs: noinline nounwind optnone
define internal i32 @gpio_pin_get(%struct.device*, i8 zeroext) #0 !dbg !650 {
  %3 = alloca %struct.device*, align 4
  %4 = alloca i8, align 1
  %5 = alloca %struct.gpio_driver_config*, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  store %struct.device* %0, %struct.device** %3, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %3, metadata !653, metadata !DIExpression()), !dbg !654
  store i8 %1, i8* %4, align 1
  call void @llvm.dbg.declare(metadata i8* %4, metadata !655, metadata !DIExpression()), !dbg !656
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_config** %5, metadata !657, metadata !DIExpression()), !dbg !658
  %8 = load %struct.device*, %struct.device** %3, align 4, !dbg !659
  %9 = getelementptr inbounds %struct.device, %struct.device* %8, i32 0, i32 1, !dbg !660
  %10 = load i8*, i8** %9, align 4, !dbg !660
  %11 = bitcast i8* %10 to %struct.gpio_driver_config*, !dbg !661
  store %struct.gpio_driver_config* %11, %struct.gpio_driver_config** %5, align 4, !dbg !658
  call void @llvm.dbg.declare(metadata i32* %6, metadata !662, metadata !DIExpression()), !dbg !663
  call void @llvm.dbg.declare(metadata i32* %7, metadata !664, metadata !DIExpression()), !dbg !665
  %12 = load %struct.gpio_driver_config*, %struct.gpio_driver_config** %5, align 4, !dbg !666
  %13 = load %struct.device*, %struct.device** %3, align 4, !dbg !667
  %14 = call i32 @gpio_port_get(%struct.device* %13, i32* %6) #3, !dbg !668
  store i32 %14, i32* %7, align 4, !dbg !669
  %15 = load i32, i32* %7, align 4, !dbg !670
  %16 = icmp eq i32 %15, 0, !dbg !672
  br i1 %16, label %17, label %26, !dbg !673

17:                                               ; preds = %2
  %18 = load i32, i32* %6, align 4, !dbg !674
  %19 = load i8, i8* %4, align 1, !dbg !676
  %20 = zext i8 %19 to i32, !dbg !676
  %21 = shl i32 1, %20, !dbg !676
  %22 = and i32 %18, %21, !dbg !677
  %23 = icmp ne i32 %22, 0, !dbg !678
  %24 = zext i1 %23 to i64, !dbg !679
  %25 = select i1 %23, i32 1, i32 0, !dbg !679
  store i32 %25, i32* %7, align 4, !dbg !680
  br label %26, !dbg !681

26:                                               ; preds = %17, %2
  %27 = load i32, i32* %7, align 4, !dbg !682
  ret i32 %27, !dbg !683
}

; Function Attrs: noinline nounwind optnone
define internal i32 @gpio_pin_set(%struct.device*, i8 zeroext, i32) #0 !dbg !684 {
  %4 = alloca %struct.device*, align 4
  %5 = alloca i8, align 1
  %6 = alloca i32, align 4
  %7 = alloca %struct.gpio_driver_config*, align 4
  %8 = alloca %struct.gpio_driver_config*, align 4
  store %struct.device* %0, %struct.device** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %4, metadata !687, metadata !DIExpression()), !dbg !688
  store i8 %1, i8* %5, align 1
  call void @llvm.dbg.declare(metadata i8* %5, metadata !689, metadata !DIExpression()), !dbg !690
  store i32 %2, i32* %6, align 4
  call void @llvm.dbg.declare(metadata i32* %6, metadata !691, metadata !DIExpression()), !dbg !692
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_config** %7, metadata !693, metadata !DIExpression()), !dbg !694
  %9 = load %struct.device*, %struct.device** %4, align 4, !dbg !695
  %10 = getelementptr inbounds %struct.device, %struct.device* %9, i32 0, i32 1, !dbg !696
  %11 = load i8*, i8** %10, align 4, !dbg !696
  %12 = bitcast i8* %11 to %struct.gpio_driver_config*, !dbg !697
  store %struct.gpio_driver_config* %12, %struct.gpio_driver_config** %7, align 4, !dbg !694
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_config** %8, metadata !698, metadata !DIExpression()), !dbg !700
  %13 = load %struct.device*, %struct.device** %4, align 4, !dbg !701
  %14 = getelementptr inbounds %struct.device, %struct.device* %13, i32 0, i32 3, !dbg !702
  %15 = load i8*, i8** %14, align 4, !dbg !702
  %16 = bitcast i8* %15 to %struct.gpio_driver_config*, !dbg !703
  store %struct.gpio_driver_config* %16, %struct.gpio_driver_config** %8, align 4, !dbg !700
  %17 = load %struct.gpio_driver_config*, %struct.gpio_driver_config** %7, align 4, !dbg !704
  %18 = load %struct.gpio_driver_config*, %struct.gpio_driver_config** %8, align 4, !dbg !705
  %19 = getelementptr inbounds %struct.gpio_driver_config, %struct.gpio_driver_config* %18, i32 0, i32 0, !dbg !707
  %20 = load i32, i32* %19, align 4, !dbg !707
  %21 = load i8, i8* %5, align 1, !dbg !708
  %22 = zext i8 %21 to i32, !dbg !708
  %23 = shl i32 1, %22, !dbg !708
  %24 = and i32 %20, %23, !dbg !709
  %25 = icmp ne i32 %24, 0, !dbg !709
  br i1 %25, label %26, label %31, !dbg !710

26:                                               ; preds = %3
  %27 = load i32, i32* %6, align 4, !dbg !711
  %28 = icmp ne i32 %27, 0, !dbg !713
  %29 = zext i1 %28 to i64, !dbg !714
  %30 = select i1 %28, i32 0, i32 1, !dbg !714
  store i32 %30, i32* %6, align 4, !dbg !715
  br label %31, !dbg !716

31:                                               ; preds = %26, %3
  %32 = load %struct.device*, %struct.device** %4, align 4, !dbg !717
  %33 = load i8, i8* %5, align 1, !dbg !718
  %34 = load i32, i32* %6, align 4, !dbg !719
  %35 = call i32 @gpio_pin_set_raw(%struct.device* %32, i8 zeroext %33, i32 %34) #3, !dbg !720
  ret i32 %35, !dbg !721
}

; Function Attrs: noinline nounwind optnone
define internal i32 @gpio_pin_set_raw(%struct.device*, i8 zeroext, i32) #0 !dbg !722 {
  %4 = alloca %struct.device*, align 4
  %5 = alloca i8, align 1
  %6 = alloca i32, align 4
  %7 = alloca %struct.gpio_driver_config*, align 4
  %8 = alloca i32, align 4
  store %struct.device* %0, %struct.device** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %4, metadata !723, metadata !DIExpression()), !dbg !724
  store i8 %1, i8* %5, align 1
  call void @llvm.dbg.declare(metadata i8* %5, metadata !725, metadata !DIExpression()), !dbg !726
  store i32 %2, i32* %6, align 4
  call void @llvm.dbg.declare(metadata i32* %6, metadata !727, metadata !DIExpression()), !dbg !728
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_config** %7, metadata !729, metadata !DIExpression()), !dbg !730
  %9 = load %struct.device*, %struct.device** %4, align 4, !dbg !731
  %10 = getelementptr inbounds %struct.device, %struct.device* %9, i32 0, i32 1, !dbg !732
  %11 = load i8*, i8** %10, align 4, !dbg !732
  %12 = bitcast i8* %11 to %struct.gpio_driver_config*, !dbg !733
  store %struct.gpio_driver_config* %12, %struct.gpio_driver_config** %7, align 4, !dbg !730
  call void @llvm.dbg.declare(metadata i32* %8, metadata !734, metadata !DIExpression()), !dbg !735
  %13 = load %struct.gpio_driver_config*, %struct.gpio_driver_config** %7, align 4, !dbg !736
  %14 = load i32, i32* %6, align 4, !dbg !737
  %15 = icmp ne i32 %14, 0, !dbg !739
  br i1 %15, label %16, label %22, !dbg !740

16:                                               ; preds = %3
  %17 = load %struct.device*, %struct.device** %4, align 4, !dbg !741
  %18 = load i8, i8* %5, align 1, !dbg !743
  %19 = zext i8 %18 to i32, !dbg !743
  %20 = shl i32 1, %19, !dbg !743
  %21 = call i32 @gpio_port_set_bits_raw(%struct.device* %17, i32 %20) #3, !dbg !744
  store i32 %21, i32* %8, align 4, !dbg !745
  br label %28, !dbg !746

22:                                               ; preds = %3
  %23 = load %struct.device*, %struct.device** %4, align 4, !dbg !747
  %24 = load i8, i8* %5, align 1, !dbg !749
  %25 = zext i8 %24 to i32, !dbg !749
  %26 = shl i32 1, %25, !dbg !749
  %27 = call i32 @gpio_port_clear_bits_raw(%struct.device* %23, i32 %26) #3, !dbg !750
  store i32 %27, i32* %8, align 4, !dbg !751
  br label %28

28:                                               ; preds = %22, %16
  %29 = load i32, i32* %8, align 4, !dbg !752
  ret i32 %29, !dbg !753
}

; Function Attrs: noinline nounwind optnone
define internal i32 @gpio_port_set_bits_raw(%struct.device*, i32) #0 !dbg !754 {
  %3 = alloca %struct.device*, align 4
  %4 = alloca i32, align 4
  store %struct.device* %0, %struct.device** %3, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %3, metadata !755, metadata !DIExpression()), !dbg !756
  store i32 %1, i32* %4, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !757, metadata !DIExpression()), !dbg !758
  br label %5, !dbg !759

5:                                                ; preds = %2
  call void asm sideeffect "", "~{memory}"() #4, !dbg !760, !srcloc !762
  br label %6, !dbg !760

6:                                                ; preds = %5
  %7 = load %struct.device*, %struct.device** %3, align 4, !dbg !763
  %8 = load i32, i32* %4, align 4, !dbg !764
  %9 = call i32 @z_impl_gpio_port_set_bits_raw(%struct.device* %7, i32 %8) #3, !dbg !765
  ret i32 %9, !dbg !766
}

; Function Attrs: noinline nounwind optnone
define internal i32 @gpio_port_clear_bits_raw(%struct.device*, i32) #0 !dbg !767 {
  %3 = alloca %struct.device*, align 4
  %4 = alloca i32, align 4
  store %struct.device* %0, %struct.device** %3, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %3, metadata !768, metadata !DIExpression()), !dbg !769
  store i32 %1, i32* %4, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !770, metadata !DIExpression()), !dbg !771
  br label %5, !dbg !772

5:                                                ; preds = %2
  call void asm sideeffect "", "~{memory}"() #4, !dbg !773, !srcloc !775
  br label %6, !dbg !773

6:                                                ; preds = %5
  %7 = load %struct.device*, %struct.device** %3, align 4, !dbg !776
  %8 = load i32, i32* %4, align 4, !dbg !777
  %9 = call i32 @z_impl_gpio_port_clear_bits_raw(%struct.device* %7, i32 %8) #3, !dbg !778
  ret i32 %9, !dbg !779
}

; Function Attrs: noinline nounwind optnone
define internal i32 @z_impl_gpio_port_clear_bits_raw(%struct.device*, i32) #0 !dbg !780 {
  %3 = alloca %struct.device*, align 4
  %4 = alloca i32, align 4
  %5 = alloca %struct.gpio_driver_api*, align 4
  store %struct.device* %0, %struct.device** %3, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %3, metadata !781, metadata !DIExpression()), !dbg !782
  store i32 %1, i32* %4, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !783, metadata !DIExpression()), !dbg !784
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_api** %5, metadata !785, metadata !DIExpression()), !dbg !786
  %6 = load %struct.device*, %struct.device** %3, align 4, !dbg !787
  %7 = getelementptr inbounds %struct.device, %struct.device* %6, i32 0, i32 2, !dbg !788
  %8 = load i8*, i8** %7, align 4, !dbg !788
  %9 = bitcast i8* %8 to %struct.gpio_driver_api*, !dbg !789
  store %struct.gpio_driver_api* %9, %struct.gpio_driver_api** %5, align 4, !dbg !786
  %10 = load %struct.gpio_driver_api*, %struct.gpio_driver_api** %5, align 4, !dbg !790
  %11 = getelementptr inbounds %struct.gpio_driver_api, %struct.gpio_driver_api* %10, i32 0, i32 4, !dbg !791
  %12 = load i32 (%struct.device*, i32)*, i32 (%struct.device*, i32)** %11, align 4, !dbg !791
  %13 = load %struct.device*, %struct.device** %3, align 4, !dbg !792
  %14 = load i32, i32* %4, align 4, !dbg !793
  %15 = call i32 %12(%struct.device* %13, i32 %14) #3, !dbg !790
  ret i32 %15, !dbg !794
}

; Function Attrs: noinline nounwind optnone
define internal i32 @z_impl_gpio_port_set_bits_raw(%struct.device*, i32) #0 !dbg !795 {
  %3 = alloca %struct.device*, align 4
  %4 = alloca i32, align 4
  %5 = alloca %struct.gpio_driver_api*, align 4
  store %struct.device* %0, %struct.device** %3, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %3, metadata !796, metadata !DIExpression()), !dbg !797
  store i32 %1, i32* %4, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !798, metadata !DIExpression()), !dbg !799
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_api** %5, metadata !800, metadata !DIExpression()), !dbg !801
  %6 = load %struct.device*, %struct.device** %3, align 4, !dbg !802
  %7 = getelementptr inbounds %struct.device, %struct.device* %6, i32 0, i32 2, !dbg !803
  %8 = load i8*, i8** %7, align 4, !dbg !803
  %9 = bitcast i8* %8 to %struct.gpio_driver_api*, !dbg !804
  store %struct.gpio_driver_api* %9, %struct.gpio_driver_api** %5, align 4, !dbg !801
  %10 = load %struct.gpio_driver_api*, %struct.gpio_driver_api** %5, align 4, !dbg !805
  %11 = getelementptr inbounds %struct.gpio_driver_api, %struct.gpio_driver_api* %10, i32 0, i32 3, !dbg !806
  %12 = load i32 (%struct.device*, i32)*, i32 (%struct.device*, i32)** %11, align 4, !dbg !806
  %13 = load %struct.device*, %struct.device** %3, align 4, !dbg !807
  %14 = load i32, i32* %4, align 4, !dbg !808
  %15 = call i32 %12(%struct.device* %13, i32 %14) #3, !dbg !805
  ret i32 %15, !dbg !809
}

; Function Attrs: noinline nounwind optnone
define internal i32 @gpio_port_get(%struct.device*, i32*) #0 !dbg !810 {
  %3 = alloca %struct.device*, align 4
  %4 = alloca i32*, align 4
  %5 = alloca %struct.gpio_driver_config*, align 4
  %6 = alloca i32, align 4
  store %struct.device* %0, %struct.device** %3, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %3, metadata !811, metadata !DIExpression()), !dbg !812
  store i32* %1, i32** %4, align 4
  call void @llvm.dbg.declare(metadata i32** %4, metadata !813, metadata !DIExpression()), !dbg !814
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_config** %5, metadata !815, metadata !DIExpression()), !dbg !816
  %7 = load %struct.device*, %struct.device** %3, align 4, !dbg !817
  %8 = getelementptr inbounds %struct.device, %struct.device* %7, i32 0, i32 3, !dbg !818
  %9 = load i8*, i8** %8, align 4, !dbg !818
  %10 = bitcast i8* %9 to %struct.gpio_driver_config*, !dbg !819
  store %struct.gpio_driver_config* %10, %struct.gpio_driver_config** %5, align 4, !dbg !816
  call void @llvm.dbg.declare(metadata i32* %6, metadata !820, metadata !DIExpression()), !dbg !821
  %11 = load %struct.device*, %struct.device** %3, align 4, !dbg !822
  %12 = load i32*, i32** %4, align 4, !dbg !823
  %13 = call i32 @gpio_port_get_raw(%struct.device* %11, i32* %12) #3, !dbg !824
  store i32 %13, i32* %6, align 4, !dbg !825
  %14 = load i32, i32* %6, align 4, !dbg !826
  %15 = icmp eq i32 %14, 0, !dbg !828
  br i1 %15, label %16, label %23, !dbg !829

16:                                               ; preds = %2
  %17 = load %struct.gpio_driver_config*, %struct.gpio_driver_config** %5, align 4, !dbg !830
  %18 = getelementptr inbounds %struct.gpio_driver_config, %struct.gpio_driver_config* %17, i32 0, i32 0, !dbg !832
  %19 = load i32, i32* %18, align 4, !dbg !832
  %20 = load i32*, i32** %4, align 4, !dbg !833
  %21 = load i32, i32* %20, align 4, !dbg !834
  %22 = xor i32 %21, %19, !dbg !834
  store i32 %22, i32* %20, align 4, !dbg !834
  br label %23, !dbg !835

23:                                               ; preds = %16, %2
  %24 = load i32, i32* %6, align 4, !dbg !836
  ret i32 %24, !dbg !837
}

; Function Attrs: noinline nounwind optnone
define internal i32 @gpio_port_get_raw(%struct.device*, i32*) #0 !dbg !838 {
  %3 = alloca %struct.device*, align 4
  %4 = alloca i32*, align 4
  store %struct.device* %0, %struct.device** %3, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %3, metadata !839, metadata !DIExpression()), !dbg !840
  store i32* %1, i32** %4, align 4
  call void @llvm.dbg.declare(metadata i32** %4, metadata !841, metadata !DIExpression()), !dbg !842
  br label %5, !dbg !843

5:                                                ; preds = %2
  call void asm sideeffect "", "~{memory}"() #4, !dbg !844, !srcloc !846
  br label %6, !dbg !844

6:                                                ; preds = %5
  %7 = load %struct.device*, %struct.device** %3, align 4, !dbg !847
  %8 = load i32*, i32** %4, align 4, !dbg !848
  %9 = call i32 @z_impl_gpio_port_get_raw(%struct.device* %7, i32* %8) #3, !dbg !849
  ret i32 %9, !dbg !850
}

; Function Attrs: noinline nounwind optnone
define internal i32 @z_impl_gpio_port_get_raw(%struct.device*, i32*) #0 !dbg !851 {
  %3 = alloca %struct.device*, align 4
  %4 = alloca i32*, align 4
  %5 = alloca %struct.gpio_driver_api*, align 4
  store %struct.device* %0, %struct.device** %3, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %3, metadata !852, metadata !DIExpression()), !dbg !853
  store i32* %1, i32** %4, align 4
  call void @llvm.dbg.declare(metadata i32** %4, metadata !854, metadata !DIExpression()), !dbg !855
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_api** %5, metadata !856, metadata !DIExpression()), !dbg !857
  %6 = load %struct.device*, %struct.device** %3, align 4, !dbg !858
  %7 = getelementptr inbounds %struct.device, %struct.device* %6, i32 0, i32 2, !dbg !859
  %8 = load i8*, i8** %7, align 4, !dbg !859
  %9 = bitcast i8* %8 to %struct.gpio_driver_api*, !dbg !860
  store %struct.gpio_driver_api* %9, %struct.gpio_driver_api** %5, align 4, !dbg !857
  %10 = load %struct.gpio_driver_api*, %struct.gpio_driver_api** %5, align 4, !dbg !861
  %11 = getelementptr inbounds %struct.gpio_driver_api, %struct.gpio_driver_api* %10, i32 0, i32 1, !dbg !862
  %12 = load i32 (%struct.device*, i32*)*, i32 (%struct.device*, i32*)** %11, align 4, !dbg !862
  %13 = load %struct.device*, %struct.device** %3, align 4, !dbg !863
  %14 = load i32*, i32** %4, align 4, !dbg !864
  %15 = call i32 %12(%struct.device* %13, i32* %14) #3, !dbg !861
  ret i32 %15, !dbg !865
}

; Function Attrs: noinline nounwind optnone
define internal i32 @z_impl_gpio_pin_interrupt_configure(%struct.device*, i8 zeroext, i32) #0 !dbg !866 {
  %4 = alloca %struct.device*, align 4
  %5 = alloca i8, align 1
  %6 = alloca i32, align 4
  %7 = alloca %struct.gpio_driver_api*, align 4
  %8 = alloca %struct.gpio_driver_config*, align 4
  %9 = alloca %struct.gpio_driver_config*, align 4
  %10 = alloca i32, align 4
  %11 = alloca i32, align 4
  store %struct.device* %0, %struct.device** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %4, metadata !867, metadata !DIExpression()), !dbg !868
  store i8 %1, i8* %5, align 1
  call void @llvm.dbg.declare(metadata i8* %5, metadata !869, metadata !DIExpression()), !dbg !870
  store i32 %2, i32* %6, align 4
  call void @llvm.dbg.declare(metadata i32* %6, metadata !871, metadata !DIExpression()), !dbg !872
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_api** %7, metadata !873, metadata !DIExpression()), !dbg !874
  %12 = load %struct.device*, %struct.device** %4, align 4, !dbg !875
  %13 = getelementptr inbounds %struct.device, %struct.device* %12, i32 0, i32 2, !dbg !876
  %14 = load i8*, i8** %13, align 4, !dbg !876
  %15 = bitcast i8* %14 to %struct.gpio_driver_api*, !dbg !877
  store %struct.gpio_driver_api* %15, %struct.gpio_driver_api** %7, align 4, !dbg !874
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_config** %8, metadata !878, metadata !DIExpression()), !dbg !879
  %16 = load %struct.device*, %struct.device** %4, align 4, !dbg !880
  %17 = getelementptr inbounds %struct.device, %struct.device* %16, i32 0, i32 1, !dbg !881
  %18 = load i8*, i8** %17, align 4, !dbg !881
  %19 = bitcast i8* %18 to %struct.gpio_driver_config*, !dbg !882
  store %struct.gpio_driver_config* %19, %struct.gpio_driver_config** %8, align 4, !dbg !879
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_config** %9, metadata !883, metadata !DIExpression()), !dbg !884
  %20 = load %struct.device*, %struct.device** %4, align 4, !dbg !885
  %21 = getelementptr inbounds %struct.device, %struct.device* %20, i32 0, i32 3, !dbg !886
  %22 = load i8*, i8** %21, align 4, !dbg !886
  %23 = bitcast i8* %22 to %struct.gpio_driver_config*, !dbg !887
  store %struct.gpio_driver_config* %23, %struct.gpio_driver_config** %9, align 4, !dbg !884
  call void @llvm.dbg.declare(metadata i32* %10, metadata !888, metadata !DIExpression()), !dbg !889
  call void @llvm.dbg.declare(metadata i32* %11, metadata !890, metadata !DIExpression()), !dbg !891
  %24 = load %struct.gpio_driver_config*, %struct.gpio_driver_config** %8, align 4, !dbg !892
  %25 = load i32, i32* %6, align 4, !dbg !893
  %26 = and i32 %25, 32768, !dbg !895
  %27 = icmp ne i32 %26, 0, !dbg !896
  br i1 %27, label %28, label %40, !dbg !897

28:                                               ; preds = %3
  %29 = load %struct.gpio_driver_config*, %struct.gpio_driver_config** %9, align 4, !dbg !898
  %30 = getelementptr inbounds %struct.gpio_driver_config, %struct.gpio_driver_config* %29, i32 0, i32 0, !dbg !899
  %31 = load i32, i32* %30, align 4, !dbg !899
  %32 = load i8, i8* %5, align 1, !dbg !900
  %33 = zext i8 %32 to i32, !dbg !900
  %34 = shl i32 1, %33, !dbg !900
  %35 = and i32 %31, %34, !dbg !901
  %36 = icmp ne i32 %35, 0, !dbg !902
  br i1 %36, label %37, label %40, !dbg !903

37:                                               ; preds = %28
  %38 = load i32, i32* %6, align 4, !dbg !904
  %39 = xor i32 %38, 393216, !dbg !904
  store i32 %39, i32* %6, align 4, !dbg !904
  br label %40, !dbg !906

40:                                               ; preds = %37, %28, %3
  %41 = load i32, i32* %6, align 4, !dbg !907
  %42 = and i32 %41, 393216, !dbg !908
  store i32 %42, i32* %10, align 4, !dbg !909
  %43 = load i32, i32* %6, align 4, !dbg !910
  %44 = and i32 %43, 90112, !dbg !911
  store i32 %44, i32* %11, align 4, !dbg !912
  %45 = load %struct.gpio_driver_api*, %struct.gpio_driver_api** %7, align 4, !dbg !913
  %46 = getelementptr inbounds %struct.gpio_driver_api, %struct.gpio_driver_api* %45, i32 0, i32 6, !dbg !914
  %47 = load i32 (%struct.device*, i8, i32, i32)*, i32 (%struct.device*, i8, i32, i32)** %46, align 4, !dbg !914
  %48 = load %struct.device*, %struct.device** %4, align 4, !dbg !915
  %49 = load i8, i8* %5, align 1, !dbg !916
  %50 = load i32, i32* %11, align 4, !dbg !917
  %51 = load i32, i32* %10, align 4, !dbg !918
  %52 = call i32 %47(%struct.device* %48, i8 zeroext %49, i32 %50, i32 %51) #3, !dbg !913
  ret i32 %52, !dbg !919
}

; Function Attrs: noinline nounwind optnone
define internal i32 @gpio_config(%struct.device*, i8 zeroext, i32) #0 !dbg !920 {
  %4 = alloca %struct.device*, align 4
  %5 = alloca i8, align 1
  %6 = alloca i32, align 4
  store %struct.device* %0, %struct.device** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %4, metadata !921, metadata !DIExpression()), !dbg !922
  store i8 %1, i8* %5, align 1
  call void @llvm.dbg.declare(metadata i8* %5, metadata !923, metadata !DIExpression()), !dbg !924
  store i32 %2, i32* %6, align 4
  call void @llvm.dbg.declare(metadata i32* %6, metadata !925, metadata !DIExpression()), !dbg !926
  br label %7, !dbg !927

7:                                                ; preds = %3
  call void asm sideeffect "", "~{memory}"() #4, !dbg !928, !srcloc !930
  br label %8, !dbg !928

8:                                                ; preds = %7
  %9 = load %struct.device*, %struct.device** %4, align 4, !dbg !931
  %10 = load i8, i8* %5, align 1, !dbg !932
  %11 = load i32, i32* %6, align 4, !dbg !933
  %12 = call i32 @z_impl_gpio_config(%struct.device* %9, i8 zeroext %10, i32 %11) #3, !dbg !934
  ret i32 %12, !dbg !935
}

; Function Attrs: noinline nounwind optnone
define internal i32 @z_impl_gpio_config(%struct.device*, i8 zeroext, i32) #0 !dbg !936 {
  %4 = alloca %struct.device*, align 4
  %5 = alloca i8, align 1
  %6 = alloca i32, align 4
  %7 = alloca %struct.gpio_driver_api*, align 4
  store %struct.device* %0, %struct.device** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.device** %4, metadata !937, metadata !DIExpression()), !dbg !938
  store i8 %1, i8* %5, align 1
  call void @llvm.dbg.declare(metadata i8* %5, metadata !939, metadata !DIExpression()), !dbg !940
  store i32 %2, i32* %6, align 4
  call void @llvm.dbg.declare(metadata i32* %6, metadata !941, metadata !DIExpression()), !dbg !942
  call void @llvm.dbg.declare(metadata %struct.gpio_driver_api** %7, metadata !943, metadata !DIExpression()), !dbg !944
  %8 = load %struct.device*, %struct.device** %4, align 4, !dbg !945
  %9 = getelementptr inbounds %struct.device, %struct.device* %8, i32 0, i32 2, !dbg !946
  %10 = load i8*, i8** %9, align 4, !dbg !946
  %11 = bitcast i8* %10 to %struct.gpio_driver_api*, !dbg !947
  store %struct.gpio_driver_api* %11, %struct.gpio_driver_api** %7, align 4, !dbg !944
  %12 = load %struct.gpio_driver_api*, %struct.gpio_driver_api** %7, align 4, !dbg !948
  %13 = getelementptr inbounds %struct.gpio_driver_api, %struct.gpio_driver_api* %12, i32 0, i32 0, !dbg !949
  %14 = load i32 (%struct.device*, i8, i32)*, i32 (%struct.device*, i8, i32)** %13, align 4, !dbg !949
  %15 = load %struct.device*, %struct.device** %4, align 4, !dbg !950
  %16 = load i8, i8* %5, align 1, !dbg !951
  %17 = load i32, i32* %6, align 4, !dbg !952
  %18 = call i32 %14(%struct.device* %15, i8 zeroext %16, i32 %17) #3, !dbg !948
  ret i32 %18, !dbg !953
}

declare dso_local %struct.device* @z_impl_device_get_binding(i8*) #2

attributes #0 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #1 = { nounwind readnone speculatable }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #3 = { nobuiltin }
attributes #4 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.ident = !{!158}
!llvm.module.flags = !{!159, !160, !161, !162}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "button_cb_data", scope: !2, file: !157, line: 41, type: !121, isLocal: true, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !64, globals: !156, nameTableKind: None)
!3 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/button/src/main.c", directory: "/home/kenny/ara/build/appl/Zephyr/button")
!4 = !{!5, !52, !59}
!5 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "k_objects", file: !6, line: 121, baseType: !7, size: 8, elements: !8)
!6 = !DIFile(filename: "zephyrproject/zephyr/include/kernel.h", directory: "/home/kenny")
!7 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!8 = !{!9, !10, !11, !12, !13, !14, !15, !16, !17, !18, !19, !20, !21, !22, !23, !24, !25, !26, !27, !28, !29, !30, !31, !32, !33, !34, !35, !36, !37, !38, !39, !40, !41, !42, !43, !44, !45, !46, !47, !48, !49, !50, !51}
!9 = !DIEnumerator(name: "K_OBJ_ANY", value: 0, isUnsigned: true)
!10 = !DIEnumerator(name: "K_OBJ_MEM_SLAB", value: 1, isUnsigned: true)
!11 = !DIEnumerator(name: "K_OBJ_MSGQ", value: 2, isUnsigned: true)
!12 = !DIEnumerator(name: "K_OBJ_MUTEX", value: 3, isUnsigned: true)
!13 = !DIEnumerator(name: "K_OBJ_PIPE", value: 4, isUnsigned: true)
!14 = !DIEnumerator(name: "K_OBJ_QUEUE", value: 5, isUnsigned: true)
!15 = !DIEnumerator(name: "K_OBJ_POLL_SIGNAL", value: 6, isUnsigned: true)
!16 = !DIEnumerator(name: "K_OBJ_SEM", value: 7, isUnsigned: true)
!17 = !DIEnumerator(name: "K_OBJ_STACK", value: 8, isUnsigned: true)
!18 = !DIEnumerator(name: "K_OBJ_THREAD", value: 9, isUnsigned: true)
!19 = !DIEnumerator(name: "K_OBJ_TIMER", value: 10, isUnsigned: true)
!20 = !DIEnumerator(name: "K_OBJ_THREAD_STACK_ELEMENT", value: 11, isUnsigned: true)
!21 = !DIEnumerator(name: "K_OBJ_NET_SOCKET", value: 12, isUnsigned: true)
!22 = !DIEnumerator(name: "K_OBJ_NET_IF", value: 13, isUnsigned: true)
!23 = !DIEnumerator(name: "K_OBJ_SYS_MUTEX", value: 14, isUnsigned: true)
!24 = !DIEnumerator(name: "K_OBJ_FUTEX", value: 15, isUnsigned: true)
!25 = !DIEnumerator(name: "K_OBJ_DRIVER_PTP_CLOCK", value: 16, isUnsigned: true)
!26 = !DIEnumerator(name: "K_OBJ_DRIVER_CRYPTO", value: 17, isUnsigned: true)
!27 = !DIEnumerator(name: "K_OBJ_DRIVER_ADC", value: 18, isUnsigned: true)
!28 = !DIEnumerator(name: "K_OBJ_DRIVER_CAN", value: 19, isUnsigned: true)
!29 = !DIEnumerator(name: "K_OBJ_DRIVER_COUNTER", value: 20, isUnsigned: true)
!30 = !DIEnumerator(name: "K_OBJ_DRIVER_DAC", value: 21, isUnsigned: true)
!31 = !DIEnumerator(name: "K_OBJ_DRIVER_DMA", value: 22, isUnsigned: true)
!32 = !DIEnumerator(name: "K_OBJ_DRIVER_EC_HOST_CMD_PERIPH_API", value: 23, isUnsigned: true)
!33 = !DIEnumerator(name: "K_OBJ_DRIVER_EEPROM", value: 24, isUnsigned: true)
!34 = !DIEnumerator(name: "K_OBJ_DRIVER_ENTROPY", value: 25, isUnsigned: true)
!35 = !DIEnumerator(name: "K_OBJ_DRIVER_ESPI", value: 26, isUnsigned: true)
!36 = !DIEnumerator(name: "K_OBJ_DRIVER_FLASH", value: 27, isUnsigned: true)
!37 = !DIEnumerator(name: "K_OBJ_DRIVER_GPIO", value: 28, isUnsigned: true)
!38 = !DIEnumerator(name: "K_OBJ_DRIVER_I2C", value: 29, isUnsigned: true)
!39 = !DIEnumerator(name: "K_OBJ_DRIVER_I2S", value: 30, isUnsigned: true)
!40 = !DIEnumerator(name: "K_OBJ_DRIVER_IPM", value: 31, isUnsigned: true)
!41 = !DIEnumerator(name: "K_OBJ_DRIVER_KSCAN", value: 32, isUnsigned: true)
!42 = !DIEnumerator(name: "K_OBJ_DRIVER_LED", value: 33, isUnsigned: true)
!43 = !DIEnumerator(name: "K_OBJ_DRIVER_PINMUX", value: 34, isUnsigned: true)
!44 = !DIEnumerator(name: "K_OBJ_DRIVER_PS2", value: 35, isUnsigned: true)
!45 = !DIEnumerator(name: "K_OBJ_DRIVER_PWM", value: 36, isUnsigned: true)
!46 = !DIEnumerator(name: "K_OBJ_DRIVER_SENSOR", value: 37, isUnsigned: true)
!47 = !DIEnumerator(name: "K_OBJ_DRIVER_SPI", value: 38, isUnsigned: true)
!48 = !DIEnumerator(name: "K_OBJ_DRIVER_UART", value: 39, isUnsigned: true)
!49 = !DIEnumerator(name: "K_OBJ_DRIVER_WDT", value: 40, isUnsigned: true)
!50 = !DIEnumerator(name: "K_OBJ_DRIVER_UART_MUX", value: 41, isUnsigned: true)
!51 = !DIEnumerator(name: "K_OBJ_LAST", value: 42, isUnsigned: true)
!52 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "gpio_int_mode", file: !53, line: 395, baseType: !54, size: 32, elements: !55)
!53 = !DIFile(filename: "zephyrproject/zephyr/include/drivers/gpio.h", directory: "/home/kenny")
!54 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!55 = !{!56, !57, !58}
!56 = !DIEnumerator(name: "GPIO_INT_MODE_DISABLED", value: 8192, isUnsigned: true)
!57 = !DIEnumerator(name: "GPIO_INT_MODE_LEVEL", value: 16384, isUnsigned: true)
!58 = !DIEnumerator(name: "GPIO_INT_MODE_EDGE", value: 81920, isUnsigned: true)
!59 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "gpio_int_trig", file: !53, line: 401, baseType: !54, size: 32, elements: !60)
!60 = !{!61, !62, !63}
!61 = !DIEnumerator(name: "GPIO_INT_TRIG_LOW", value: 131072, isUnsigned: true)
!62 = !DIEnumerator(name: "GPIO_INT_TRIG_HIGH", value: 262144, isUnsigned: true)
!63 = !DIEnumerator(name: "GPIO_INT_TRIG_BOTH", value: 393216, isUnsigned: true)
!64 = !{!65, !66, !67, !141, !146, !105, !59, !52, !151, !152, !94}
!65 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 32)
!66 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!67 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !68, size: 32)
!68 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !69)
!69 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "gpio_driver_api", file: !53, line: 412, size: 288, elements: !70)
!70 = !{!71, !95, !101, !106, !110, !111, !112, !116, !137}
!71 = !DIDerivedType(tag: DW_TAG_member, name: "pin_configure", scope: !69, file: !53, line: 413, baseType: !72, size: 32)
!72 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !73, size: 32)
!73 = !DISubroutineType(types: !74)
!74 = !{!66, !75, !90, !93}
!75 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !76, size: 32)
!76 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !77)
!77 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "device", file: !78, line: 200, size: 128, elements: !79)
!78 = !DIFile(filename: "zephyrproject/zephyr/include/device.h", directory: "/home/kenny")
!79 = !{!80, !84, !87, !88}
!80 = !DIDerivedType(tag: DW_TAG_member, name: "name", scope: !77, file: !78, line: 202, baseType: !81, size: 32)
!81 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !82, size: 32)
!82 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !83)
!83 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_unsigned_char)
!84 = !DIDerivedType(tag: DW_TAG_member, name: "config", scope: !77, file: !78, line: 204, baseType: !85, size: 32, offset: 32)
!85 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !86, size: 32)
!86 = !DIDerivedType(tag: DW_TAG_const_type, baseType: null)
!87 = !DIDerivedType(tag: DW_TAG_member, name: "api", scope: !77, file: !78, line: 206, baseType: !85, size: 32, offset: 64)
!88 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !77, file: !78, line: 208, baseType: !89, size: 32, offset: 96)
!89 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !65)
!90 = !DIDerivedType(tag: DW_TAG_typedef, name: "gpio_pin_t", file: !53, line: 288, baseType: !91)
!91 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !92, line: 55, baseType: !7)
!92 = !DIFile(filename: "zephyrproject/zephyr/lib/libc/minimal/include/stdint.h", directory: "/home/kenny")
!93 = !DIDerivedType(tag: DW_TAG_typedef, name: "gpio_flags_t", file: !53, line: 305, baseType: !94)
!94 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !92, line: 57, baseType: !54)
!95 = !DIDerivedType(tag: DW_TAG_member, name: "port_get_raw", scope: !69, file: !53, line: 415, baseType: !96, size: 32, offset: 32)
!96 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !97, size: 32)
!97 = !DISubroutineType(types: !98)
!98 = !{!66, !75, !99}
!99 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !100, size: 32)
!100 = !DIDerivedType(tag: DW_TAG_typedef, name: "gpio_port_value_t", file: !53, line: 280, baseType: !94)
!101 = !DIDerivedType(tag: DW_TAG_member, name: "port_set_masked_raw", scope: !69, file: !53, line: 417, baseType: !102, size: 32, offset: 64)
!102 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !103, size: 32)
!103 = !DISubroutineType(types: !104)
!104 = !{!66, !75, !105, !100}
!105 = !DIDerivedType(tag: DW_TAG_typedef, name: "gpio_port_pins_t", file: !53, line: 267, baseType: !94)
!106 = !DIDerivedType(tag: DW_TAG_member, name: "port_set_bits_raw", scope: !69, file: !53, line: 420, baseType: !107, size: 32, offset: 96)
!107 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !108, size: 32)
!108 = !DISubroutineType(types: !109)
!109 = !{!66, !75, !105}
!110 = !DIDerivedType(tag: DW_TAG_member, name: "port_clear_bits_raw", scope: !69, file: !53, line: 422, baseType: !107, size: 32, offset: 128)
!111 = !DIDerivedType(tag: DW_TAG_member, name: "port_toggle_bits", scope: !69, file: !53, line: 424, baseType: !107, size: 32, offset: 160)
!112 = !DIDerivedType(tag: DW_TAG_member, name: "pin_interrupt_configure", scope: !69, file: !53, line: 426, baseType: !113, size: 32, offset: 192)
!113 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !114, size: 32)
!114 = !DISubroutineType(types: !115)
!115 = !{!66, !75, !90, !52, !59}
!116 = !DIDerivedType(tag: DW_TAG_member, name: "manage_callback", scope: !69, file: !53, line: 429, baseType: !117, size: 32, offset: 224)
!117 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !118, size: 32)
!118 = !DISubroutineType(types: !119)
!119 = !{!66, !75, !120, !136}
!120 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !121, size: 32)
!121 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "gpio_callback", file: !53, line: 367, size: 96, elements: !122)
!122 = !{!123, !130, !135}
!123 = !DIDerivedType(tag: DW_TAG_member, name: "node", scope: !121, file: !53, line: 371, baseType: !124, size: 32)
!124 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_snode_t", file: !125, line: 33, baseType: !126)
!125 = !DIFile(filename: "zephyrproject/zephyr/include/sys/slist.h", directory: "/home/kenny")
!126 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_snode", file: !125, line: 29, size: 32, elements: !127)
!127 = !{!128}
!128 = !DIDerivedType(tag: DW_TAG_member, name: "next", scope: !126, file: !125, line: 30, baseType: !129, size: 32)
!129 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !126, size: 32)
!130 = !DIDerivedType(tag: DW_TAG_member, name: "handler", scope: !121, file: !53, line: 374, baseType: !131, size: 32, offset: 32)
!131 = !DIDerivedType(tag: DW_TAG_typedef, name: "gpio_callback_handler_t", file: !53, line: 353, baseType: !132)
!132 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !133, size: 32)
!133 = !DISubroutineType(types: !134)
!134 = !{null, !75, !120, !105}
!135 = !DIDerivedType(tag: DW_TAG_member, name: "pin_mask", scope: !121, file: !53, line: 382, baseType: !105, size: 32, offset: 64)
!136 = !DIBasicType(name: "_Bool", size: 8, encoding: DW_ATE_boolean)
!137 = !DIDerivedType(tag: DW_TAG_member, name: "get_pending_int", scope: !69, file: !53, line: 432, baseType: !138, size: 32, offset: 256)
!138 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !139, size: 32)
!139 = !DISubroutineType(types: !140)
!140 = !{!94, !75}
!141 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !142, size: 32)
!142 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !143)
!143 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "gpio_driver_config", file: !53, line: 317, size: 32, elements: !144)
!144 = !{!145}
!145 = !DIDerivedType(tag: DW_TAG_member, name: "port_pin_mask", scope: !143, file: !53, line: 323, baseType: !105, size: 32)
!146 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !147, size: 32)
!147 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !148)
!148 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "gpio_driver_data", file: !53, line: 330, size: 32, elements: !149)
!149 = !{!150}
!150 = !DIDerivedType(tag: DW_TAG_member, name: "invert", scope: !148, file: !53, line: 336, baseType: !105, size: 32)
!151 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !148, size: 32)
!152 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_ticks_t", file: !153, line: 46, baseType: !154)
!153 = !DIFile(filename: "zephyrproject/zephyr/include/sys_clock.h", directory: "/home/kenny")
!154 = !DIDerivedType(tag: DW_TAG_typedef, name: "int64_t", file: !92, line: 43, baseType: !155)
!155 = !DIBasicType(name: "long long int", size: 64, encoding: DW_ATE_signed)
!156 = !{!0}
!157 = !DIFile(filename: "appl/Zephyr/button/src/main.c", directory: "/home/kenny/ara")
!158 = !{!"clang version 9.0.1-12 "}
!159 = !{i32 2, !"Dwarf Version", i32 4}
!160 = !{i32 2, !"Debug Info Version", i32 3}
!161 = !{i32 1, !"wchar_size", i32 4}
!162 = !{i32 1, !"min_enum_size", i32 1}
!163 = distinct !DISubprogram(name: "button_pressed", scope: !157, file: !157, line: 43, type: !164, scopeLine: 45, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !167)
!164 = !DISubroutineType(types: !165)
!165 = !{null, !166, !120, !94}
!166 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !77, size: 32)
!167 = !{}
!168 = !DILocalVariable(name: "dev", arg: 1, scope: !163, file: !157, line: 43, type: !166)
!169 = !DILocation(line: 43, column: 36, scope: !163)
!170 = !DILocalVariable(name: "cb", arg: 2, scope: !163, file: !157, line: 43, type: !120)
!171 = !DILocation(line: 43, column: 63, scope: !163)
!172 = !DILocalVariable(name: "pins", arg: 3, scope: !163, file: !157, line: 44, type: !94)
!173 = !DILocation(line: 44, column: 16, scope: !163)
!174 = !DILocation(line: 46, column: 44, scope: !163)
!175 = !DILocation(line: 46, column: 2, scope: !163)
!176 = !DILocation(line: 47, column: 1, scope: !163)
!177 = distinct !DISubprogram(name: "k_cycle_get_32", scope: !6, file: !6, line: 2172, type: !178, scopeLine: 2173, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!178 = !DISubroutineType(types: !179)
!179 = !{!94}
!180 = !DILocation(line: 2174, column: 9, scope: !177)
!181 = !DILocation(line: 2174, column: 2, scope: !177)
!182 = distinct !DISubprogram(name: "arch_k_cycle_get_32", scope: !183, file: !183, line: 24, type: !178, scopeLine: 25, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!183 = !DIFile(filename: "zephyrproject/zephyr/include/arch/arm/aarch32/misc.h", directory: "/home/kenny")
!184 = !DILocation(line: 26, column: 9, scope: !182)
!185 = !DILocation(line: 26, column: 2, scope: !182)
!186 = distinct !DISubprogram(name: "main", scope: !157, file: !157, line: 49, type: !187, scopeLine: 50, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !167)
!187 = !DISubroutineType(types: !188)
!188 = !{null}
!189 = !DILocalVariable(name: "button", scope: !186, file: !157, line: 51, type: !166)
!190 = !DILocation(line: 51, column: 17, scope: !186)
!191 = !DILocalVariable(name: "led", scope: !186, file: !157, line: 52, type: !166)
!192 = !DILocation(line: 52, column: 17, scope: !186)
!193 = !DILocalVariable(name: "ret", scope: !186, file: !157, line: 53, type: !66)
!194 = !DILocation(line: 53, column: 6, scope: !186)
!195 = !DILocation(line: 55, column: 11, scope: !186)
!196 = !DILocation(line: 55, column: 9, scope: !186)
!197 = !DILocation(line: 56, column: 6, scope: !198)
!198 = distinct !DILexicalBlock(scope: !186, file: !157, line: 56, column: 6)
!199 = !DILocation(line: 56, column: 13, scope: !198)
!200 = !DILocation(line: 56, column: 6, scope: !186)
!201 = !DILocation(line: 57, column: 3, scope: !202)
!202 = distinct !DILexicalBlock(scope: !198, file: !157, line: 56, column: 22)
!203 = !DILocation(line: 58, column: 3, scope: !202)
!204 = !DILocation(line: 61, column: 27, scope: !186)
!205 = !DILocation(line: 61, column: 8, scope: !186)
!206 = !DILocation(line: 61, column: 6, scope: !186)
!207 = !DILocation(line: 62, column: 6, scope: !208)
!208 = distinct !DILexicalBlock(scope: !186, file: !157, line: 62, column: 6)
!209 = !DILocation(line: 62, column: 10, scope: !208)
!210 = !DILocation(line: 62, column: 6, scope: !186)
!211 = !DILocation(line: 64, column: 10, scope: !212)
!212 = distinct !DILexicalBlock(scope: !208, file: !157, line: 62, column: 16)
!213 = !DILocation(line: 63, column: 3, scope: !212)
!214 = !DILocation(line: 65, column: 3, scope: !212)
!215 = !DILocation(line: 68, column: 37, scope: !186)
!216 = !DILocation(line: 68, column: 8, scope: !186)
!217 = !DILocation(line: 68, column: 6, scope: !186)
!218 = !DILocation(line: 71, column: 6, scope: !219)
!219 = distinct !DILexicalBlock(scope: !186, file: !157, line: 71, column: 6)
!220 = !DILocation(line: 71, column: 10, scope: !219)
!221 = !DILocation(line: 71, column: 6, scope: !186)
!222 = !DILocation(line: 73, column: 4, scope: !223)
!223 = distinct !DILexicalBlock(scope: !219, file: !157, line: 71, column: 16)
!224 = !DILocation(line: 72, column: 3, scope: !223)
!225 = !DILocation(line: 74, column: 3, scope: !223)
!226 = !DILocation(line: 77, column: 2, scope: !186)
!227 = !DILocation(line: 78, column: 20, scope: !186)
!228 = !DILocation(line: 78, column: 2, scope: !186)
!229 = !DILocation(line: 79, column: 2, scope: !186)
!230 = !DILocation(line: 81, column: 8, scope: !186)
!231 = !DILocation(line: 81, column: 6, scope: !186)
!232 = !DILocation(line: 83, column: 2, scope: !186)
!233 = !DILocation(line: 84, column: 2, scope: !186)
!234 = !DILocation(line: 85, column: 23, scope: !235)
!235 = distinct !DILexicalBlock(scope: !186, file: !157, line: 84, column: 12)
!236 = !DILocation(line: 85, column: 31, scope: !235)
!237 = !DILocation(line: 85, column: 3, scope: !235)
!238 = !DILocation(line: 86, column: 3, scope: !235)
!239 = distinct !{!239, !233, !240}
!240 = !DILocation(line: 87, column: 2, scope: !186)
!241 = !DILocation(line: 88, column: 1, scope: !186)
!242 = distinct !DISubprogram(name: "device_get_binding", scope: !243, file: !243, line: 25, type: !244, scopeLine: 26, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!243 = !DIFile(filename: "zephyr/include/generated/syscalls/device.h", directory: "/home/kenny/ara/build/appl/Zephyr/button")
!244 = !DISubroutineType(types: !245)
!245 = !{!75, !81}
!246 = !DILocalVariable(name: "name", arg: 1, scope: !242, file: !243, line: 25, type: !81)
!247 = !DILocation(line: 25, column: 87, scope: !242)
!248 = !DILocation(line: 32, column: 2, scope: !242)
!249 = !DILocation(line: 32, column: 2, scope: !250)
!250 = distinct !DILexicalBlock(scope: !242, file: !243, line: 32, column: 2)
!251 = !{i32 -2141794881}
!252 = !DILocation(line: 33, column: 35, scope: !242)
!253 = !DILocation(line: 33, column: 9, scope: !242)
!254 = !DILocation(line: 33, column: 2, scope: !242)
!255 = distinct !DISubprogram(name: "gpio_pin_configure", scope: !53, file: !53, line: 541, type: !73, scopeLine: 544, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!256 = !DILocalVariable(name: "port", arg: 1, scope: !255, file: !53, line: 541, type: !75)
!257 = !DILocation(line: 541, column: 59, scope: !255)
!258 = !DILocalVariable(name: "pin", arg: 2, scope: !255, file: !53, line: 542, type: !90)
!259 = !DILocation(line: 542, column: 21, scope: !255)
!260 = !DILocalVariable(name: "flags", arg: 3, scope: !255, file: !53, line: 543, type: !93)
!261 = !DILocation(line: 543, column: 23, scope: !255)
!262 = !DILocalVariable(name: "api", scope: !255, file: !53, line: 545, type: !67)
!263 = !DILocation(line: 545, column: 32, scope: !255)
!264 = !DILocation(line: 546, column: 35, scope: !255)
!265 = !DILocation(line: 546, column: 41, scope: !255)
!266 = !DILocation(line: 546, column: 3, scope: !255)
!267 = !DILocalVariable(name: "cfg", scope: !255, file: !53, line: 547, type: !268)
!268 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !141)
!269 = !DILocation(line: 547, column: 41, scope: !255)
!270 = !DILocation(line: 548, column: 38, scope: !255)
!271 = !DILocation(line: 548, column: 44, scope: !255)
!272 = !DILocation(line: 548, column: 3, scope: !255)
!273 = !DILocalVariable(name: "data", scope: !255, file: !53, line: 549, type: !151)
!274 = !DILocation(line: 549, column: 27, scope: !255)
!275 = !DILocation(line: 550, column: 30, scope: !255)
!276 = !DILocation(line: 550, column: 36, scope: !255)
!277 = !DILocation(line: 550, column: 3, scope: !255)
!278 = !DILocalVariable(name: "ret", scope: !255, file: !53, line: 551, type: !66)
!279 = !DILocation(line: 551, column: 6, scope: !255)
!280 = !DILocation(line: 572, column: 8, scope: !281)
!281 = distinct !DILexicalBlock(scope: !255, file: !53, line: 572, column: 6)
!282 = !DILocation(line: 572, column: 14, scope: !281)
!283 = !DILocation(line: 572, column: 42, scope: !281)
!284 = !DILocation(line: 573, column: 6, scope: !281)
!285 = !DILocation(line: 573, column: 11, scope: !281)
!286 = !DILocation(line: 573, column: 17, scope: !281)
!287 = !DILocation(line: 573, column: 67, scope: !281)
!288 = !DILocation(line: 574, column: 6, scope: !281)
!289 = !DILocation(line: 574, column: 11, scope: !281)
!290 = !DILocation(line: 574, column: 17, scope: !281)
!291 = !DILocation(line: 574, column: 36, scope: !281)
!292 = !DILocation(line: 572, column: 6, scope: !255)
!293 = !DILocation(line: 575, column: 9, scope: !294)
!294 = distinct !DILexicalBlock(scope: !281, file: !53, line: 574, column: 43)
!295 = !DILocation(line: 577, column: 2, scope: !294)
!296 = !DILocation(line: 579, column: 8, scope: !255)
!297 = !DILocation(line: 583, column: 20, scope: !255)
!298 = !DILocation(line: 583, column: 26, scope: !255)
!299 = !DILocation(line: 583, column: 31, scope: !255)
!300 = !DILocation(line: 583, column: 8, scope: !255)
!301 = !DILocation(line: 583, column: 6, scope: !255)
!302 = !DILocation(line: 584, column: 6, scope: !303)
!303 = distinct !DILexicalBlock(scope: !255, file: !53, line: 584, column: 6)
!304 = !DILocation(line: 584, column: 10, scope: !303)
!305 = !DILocation(line: 584, column: 6, scope: !255)
!306 = !DILocation(line: 585, column: 10, scope: !307)
!307 = distinct !DILexicalBlock(scope: !303, file: !53, line: 584, column: 16)
!308 = !DILocation(line: 585, column: 3, scope: !307)
!309 = !DILocation(line: 588, column: 7, scope: !310)
!310 = distinct !DILexicalBlock(scope: !255, file: !53, line: 588, column: 6)
!311 = !DILocation(line: 588, column: 13, scope: !310)
!312 = !DILocation(line: 588, column: 32, scope: !310)
!313 = !DILocation(line: 588, column: 6, scope: !255)
!314 = !DILocation(line: 589, column: 37, scope: !315)
!315 = distinct !DILexicalBlock(scope: !310, file: !53, line: 588, column: 38)
!316 = !DILocation(line: 589, column: 3, scope: !315)
!317 = !DILocation(line: 589, column: 9, scope: !315)
!318 = !DILocation(line: 589, column: 16, scope: !315)
!319 = !DILocation(line: 590, column: 2, scope: !315)
!320 = !DILocation(line: 591, column: 38, scope: !321)
!321 = distinct !DILexicalBlock(scope: !310, file: !53, line: 590, column: 9)
!322 = !DILocation(line: 591, column: 19, scope: !321)
!323 = !DILocation(line: 591, column: 3, scope: !321)
!324 = !DILocation(line: 591, column: 9, scope: !321)
!325 = !DILocation(line: 591, column: 16, scope: !321)
!326 = !DILocation(line: 593, column: 8, scope: !327)
!327 = distinct !DILexicalBlock(scope: !255, file: !53, line: 593, column: 6)
!328 = !DILocation(line: 593, column: 14, scope: !327)
!329 = !DILocation(line: 593, column: 54, scope: !327)
!330 = !DILocation(line: 594, column: 6, scope: !327)
!331 = !DILocation(line: 594, column: 10, scope: !327)
!332 = !DILocation(line: 594, column: 15, scope: !327)
!333 = !DILocation(line: 594, column: 39, scope: !327)
!334 = !DILocation(line: 593, column: 6, scope: !255)
!335 = !DILocation(line: 595, column: 9, scope: !336)
!336 = distinct !DILexicalBlock(scope: !327, file: !53, line: 594, column: 49)
!337 = !DILocation(line: 596, column: 45, scope: !336)
!338 = !DILocation(line: 596, column: 51, scope: !336)
!339 = !DILocation(line: 596, column: 56, scope: !336)
!340 = !DILocation(line: 596, column: 9, scope: !336)
!341 = !DILocation(line: 596, column: 7, scope: !336)
!342 = !DILocation(line: 597, column: 2, scope: !336)
!343 = !DILocation(line: 599, column: 9, scope: !255)
!344 = !DILocation(line: 599, column: 2, scope: !255)
!345 = !DILocation(line: 600, column: 1, scope: !255)
!346 = distinct !DISubprogram(name: "gpio_pin_interrupt_configure", scope: !347, file: !347, line: 38, type: !73, scopeLine: 39, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!347 = !DIFile(filename: "zephyr/include/generated/syscalls/gpio.h", directory: "/home/kenny/ara/build/appl/Zephyr/button")
!348 = !DILocalVariable(name: "port", arg: 1, scope: !346, file: !347, line: 38, type: !75)
!349 = !DILocation(line: 38, column: 88, scope: !346)
!350 = !DILocalVariable(name: "pin", arg: 2, scope: !346, file: !347, line: 38, type: !90)
!351 = !DILocation(line: 38, column: 105, scope: !346)
!352 = !DILocalVariable(name: "flags", arg: 3, scope: !346, file: !347, line: 38, type: !93)
!353 = !DILocation(line: 38, column: 123, scope: !346)
!354 = !DILocation(line: 45, column: 2, scope: !346)
!355 = !DILocation(line: 45, column: 2, scope: !356)
!356 = distinct !DILexicalBlock(scope: !346, file: !347, line: 45, column: 2)
!357 = !{i32 -2141747675}
!358 = !DILocation(line: 46, column: 45, scope: !346)
!359 = !DILocation(line: 46, column: 51, scope: !346)
!360 = !DILocation(line: 46, column: 56, scope: !346)
!361 = !DILocation(line: 46, column: 9, scope: !346)
!362 = !DILocation(line: 46, column: 2, scope: !346)
!363 = distinct !DISubprogram(name: "gpio_init_callback", scope: !53, file: !53, line: 1040, type: !364, scopeLine: 1043, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!364 = !DISubroutineType(types: !365)
!365 = !{null, !120, !131, !105}
!366 = !DILocalVariable(name: "callback", arg: 1, scope: !363, file: !53, line: 1040, type: !120)
!367 = !DILocation(line: 1040, column: 61, scope: !363)
!368 = !DILocalVariable(name: "handler", arg: 2, scope: !363, file: !53, line: 1041, type: !131)
!369 = !DILocation(line: 1041, column: 35, scope: !363)
!370 = !DILocalVariable(name: "pin_mask", arg: 3, scope: !363, file: !53, line: 1042, type: !105)
!371 = !DILocation(line: 1042, column: 28, scope: !363)
!372 = !DILocation(line: 1047, column: 22, scope: !363)
!373 = !DILocation(line: 1047, column: 2, scope: !363)
!374 = !DILocation(line: 1047, column: 12, scope: !363)
!375 = !DILocation(line: 1047, column: 20, scope: !363)
!376 = !DILocation(line: 1048, column: 23, scope: !363)
!377 = !DILocation(line: 1048, column: 2, scope: !363)
!378 = !DILocation(line: 1048, column: 12, scope: !363)
!379 = !DILocation(line: 1048, column: 21, scope: !363)
!380 = !DILocation(line: 1049, column: 1, scope: !363)
!381 = distinct !DISubprogram(name: "gpio_add_callback", scope: !53, file: !53, line: 1063, type: !382, scopeLine: 1065, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!382 = !DISubroutineType(types: !383)
!383 = !{!66, !75, !120}
!384 = !DILocalVariable(name: "port", arg: 1, scope: !381, file: !53, line: 1063, type: !75)
!385 = !DILocation(line: 1063, column: 58, scope: !381)
!386 = !DILocalVariable(name: "callback", arg: 2, scope: !381, file: !53, line: 1064, type: !120)
!387 = !DILocation(line: 1064, column: 31, scope: !381)
!388 = !DILocalVariable(name: "api", scope: !381, file: !53, line: 1066, type: !67)
!389 = !DILocation(line: 1066, column: 32, scope: !381)
!390 = !DILocation(line: 1067, column: 35, scope: !381)
!391 = !DILocation(line: 1067, column: 41, scope: !381)
!392 = !DILocation(line: 1067, column: 3, scope: !381)
!393 = !DILocation(line: 1069, column: 6, scope: !394)
!394 = distinct !DILexicalBlock(scope: !381, file: !53, line: 1069, column: 6)
!395 = !DILocation(line: 1069, column: 11, scope: !394)
!396 = !DILocation(line: 1069, column: 27, scope: !394)
!397 = !DILocation(line: 1069, column: 6, scope: !381)
!398 = !DILocation(line: 1070, column: 3, scope: !399)
!399 = distinct !DILexicalBlock(scope: !394, file: !53, line: 1069, column: 36)
!400 = !DILocation(line: 1073, column: 9, scope: !381)
!401 = !DILocation(line: 1073, column: 14, scope: !381)
!402 = !DILocation(line: 1073, column: 30, scope: !381)
!403 = !DILocation(line: 1073, column: 36, scope: !381)
!404 = !DILocation(line: 1073, column: 2, scope: !381)
!405 = !DILocation(line: 1074, column: 1, scope: !381)
!406 = distinct !DISubprogram(name: "initialize_led", scope: !157, file: !157, line: 104, type: !407, scopeLine: 105, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!407 = !DISubroutineType(types: !408)
!408 = !{!166}
!409 = !DILocalVariable(name: "led", scope: !406, file: !157, line: 106, type: !166)
!410 = !DILocation(line: 106, column: 17, scope: !406)
!411 = !DILocalVariable(name: "ret", scope: !406, file: !157, line: 107, type: !66)
!412 = !DILocation(line: 107, column: 6, scope: !406)
!413 = !DILocation(line: 109, column: 8, scope: !406)
!414 = !DILocation(line: 109, column: 6, scope: !406)
!415 = !DILocation(line: 110, column: 6, scope: !416)
!416 = distinct !DILexicalBlock(scope: !406, file: !157, line: 110, column: 6)
!417 = !DILocation(line: 110, column: 10, scope: !416)
!418 = !DILocation(line: 110, column: 6, scope: !406)
!419 = !DILocation(line: 111, column: 3, scope: !420)
!420 = distinct !DILexicalBlock(scope: !416, file: !157, line: 110, column: 19)
!421 = !DILocation(line: 112, column: 3, scope: !420)
!422 = !DILocation(line: 115, column: 27, scope: !406)
!423 = !DILocation(line: 115, column: 8, scope: !406)
!424 = !DILocation(line: 115, column: 6, scope: !406)
!425 = !DILocation(line: 116, column: 6, scope: !426)
!426 = distinct !DILexicalBlock(scope: !406, file: !157, line: 116, column: 6)
!427 = !DILocation(line: 116, column: 10, scope: !426)
!428 = !DILocation(line: 116, column: 6, scope: !406)
!429 = !DILocation(line: 118, column: 10, scope: !430)
!430 = distinct !DILexicalBlock(scope: !426, file: !157, line: 116, column: 16)
!431 = !DILocation(line: 117, column: 3, scope: !430)
!432 = !DILocation(line: 119, column: 3, scope: !430)
!433 = !DILocation(line: 122, column: 2, scope: !406)
!434 = !DILocation(line: 124, column: 9, scope: !406)
!435 = !DILocation(line: 124, column: 2, scope: !406)
!436 = !DILocation(line: 125, column: 1, scope: !406)
!437 = distinct !DISubprogram(name: "match_led_to_button", scope: !157, file: !157, line: 127, type: !438, scopeLine: 128, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!438 = !DISubroutineType(types: !439)
!439 = !{null, !166, !166}
!440 = !DILocalVariable(name: "button", arg: 1, scope: !437, file: !157, line: 127, type: !166)
!441 = !DILocation(line: 127, column: 48, scope: !437)
!442 = !DILocalVariable(name: "led", arg: 2, scope: !437, file: !157, line: 127, type: !166)
!443 = !DILocation(line: 127, column: 71, scope: !437)
!444 = !DILocalVariable(name: "val", scope: !437, file: !157, line: 129, type: !136)
!445 = !DILocation(line: 129, column: 7, scope: !437)
!446 = !DILocation(line: 131, column: 21, scope: !437)
!447 = !DILocation(line: 131, column: 8, scope: !437)
!448 = !DILocation(line: 131, column: 6, scope: !437)
!449 = !DILocation(line: 132, column: 15, scope: !437)
!450 = !DILocation(line: 132, column: 35, scope: !437)
!451 = !DILocation(line: 132, column: 2, scope: !437)
!452 = !DILocation(line: 133, column: 1, scope: !437)
!453 = distinct !DISubprogram(name: "k_msleep", scope: !6, file: !6, line: 957, type: !454, scopeLine: 958, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!454 = !DISubroutineType(types: !455)
!455 = !{!456, !456}
!456 = !DIDerivedType(tag: DW_TAG_typedef, name: "int32_t", file: !92, line: 42, baseType: !66)
!457 = !DILocalVariable(name: "ms", arg: 1, scope: !453, file: !6, line: 957, type: !456)
!458 = !DILocation(line: 957, column: 40, scope: !453)
!459 = !DILocation(line: 959, column: 17, scope: !453)
!460 = !DILocation(line: 959, column: 9, scope: !453)
!461 = !DILocation(line: 959, column: 2, scope: !453)
!462 = distinct !DISubprogram(name: "k_ms_to_ticks_ceil64", scope: !463, file: !463, line: 369, type: !464, scopeLine: 370, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!463 = !DIFile(filename: "zephyrproject/zephyr/include/sys/time_units.h", directory: "/home/kenny")
!464 = !DISubroutineType(types: !465)
!465 = !{!466, !466}
!466 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint64_t", file: !92, line: 58, baseType: !467)
!467 = !DIBasicType(name: "long long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!468 = !DILocalVariable(name: "t", arg: 1, scope: !469, file: !463, line: 78, type: !466)
!469 = distinct !DISubprogram(name: "z_tmcvt", scope: !463, file: !463, line: 78, type: !470, scopeLine: 82, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!470 = !DISubroutineType(types: !471)
!471 = !{!466, !466, !94, !94, !136, !136, !136, !136}
!472 = !DILocation(line: 78, column: 63, scope: !469, inlinedAt: !473)
!473 = distinct !DILocation(line: 372, column: 9, scope: !462)
!474 = !DILocalVariable(name: "from_hz", arg: 2, scope: !469, file: !463, line: 78, type: !94)
!475 = !DILocation(line: 78, column: 75, scope: !469, inlinedAt: !473)
!476 = !DILocalVariable(name: "to_hz", arg: 3, scope: !469, file: !463, line: 79, type: !94)
!477 = !DILocation(line: 79, column: 18, scope: !469, inlinedAt: !473)
!478 = !DILocalVariable(name: "const_hz", arg: 4, scope: !469, file: !463, line: 79, type: !136)
!479 = !DILocation(line: 79, column: 30, scope: !469, inlinedAt: !473)
!480 = !DILocalVariable(name: "result32", arg: 5, scope: !469, file: !463, line: 80, type: !136)
!481 = !DILocation(line: 80, column: 14, scope: !469, inlinedAt: !473)
!482 = !DILocalVariable(name: "round_up", arg: 6, scope: !469, file: !463, line: 80, type: !136)
!483 = !DILocation(line: 80, column: 29, scope: !469, inlinedAt: !473)
!484 = !DILocalVariable(name: "round_off", arg: 7, scope: !469, file: !463, line: 81, type: !136)
!485 = !DILocation(line: 81, column: 14, scope: !469, inlinedAt: !473)
!486 = !DILocalVariable(name: "mul_ratio", scope: !469, file: !463, line: 84, type: !136)
!487 = !DILocation(line: 84, column: 7, scope: !469, inlinedAt: !473)
!488 = !DILocalVariable(name: "div_ratio", scope: !469, file: !463, line: 86, type: !136)
!489 = !DILocation(line: 86, column: 7, scope: !469, inlinedAt: !473)
!490 = !DILocalVariable(name: "off", scope: !469, file: !463, line: 93, type: !466)
!491 = !DILocation(line: 93, column: 11, scope: !469, inlinedAt: !473)
!492 = !DILocalVariable(name: "rdivisor", scope: !493, file: !463, line: 96, type: !94)
!493 = distinct !DILexicalBlock(scope: !494, file: !463, line: 95, column: 18)
!494 = distinct !DILexicalBlock(scope: !469, file: !463, line: 95, column: 6)
!495 = !DILocation(line: 96, column: 12, scope: !493, inlinedAt: !473)
!496 = !DILocalVariable(name: "t", arg: 1, scope: !462, file: !463, line: 369, type: !466)
!497 = !DILocation(line: 369, column: 69, scope: !462)
!498 = !DILocation(line: 372, column: 17, scope: !462)
!499 = !DILocation(line: 84, column: 19, scope: !469, inlinedAt: !473)
!500 = !DILocation(line: 84, column: 28, scope: !469, inlinedAt: !473)
!501 = !DILocation(line: 85, column: 4, scope: !469, inlinedAt: !473)
!502 = !DILocation(line: 85, column: 12, scope: !469, inlinedAt: !473)
!503 = !DILocation(line: 85, column: 10, scope: !469, inlinedAt: !473)
!504 = !DILocation(line: 85, column: 21, scope: !469, inlinedAt: !473)
!505 = !DILocation(line: 85, column: 26, scope: !469, inlinedAt: !473)
!506 = !DILocation(line: 85, column: 34, scope: !469, inlinedAt: !473)
!507 = !DILocation(line: 85, column: 32, scope: !469, inlinedAt: !473)
!508 = !DILocation(line: 85, column: 43, scope: !469, inlinedAt: !473)
!509 = !DILocation(line: 0, scope: !469, inlinedAt: !473)
!510 = !DILocation(line: 86, column: 19, scope: !469, inlinedAt: !473)
!511 = !DILocation(line: 86, column: 28, scope: !469, inlinedAt: !473)
!512 = !DILocation(line: 87, column: 4, scope: !469, inlinedAt: !473)
!513 = !DILocation(line: 87, column: 14, scope: !469, inlinedAt: !473)
!514 = !DILocation(line: 87, column: 12, scope: !469, inlinedAt: !473)
!515 = !DILocation(line: 87, column: 21, scope: !469, inlinedAt: !473)
!516 = !DILocation(line: 87, column: 26, scope: !469, inlinedAt: !473)
!517 = !DILocation(line: 87, column: 36, scope: !469, inlinedAt: !473)
!518 = !DILocation(line: 87, column: 34, scope: !469, inlinedAt: !473)
!519 = !DILocation(line: 87, column: 43, scope: !469, inlinedAt: !473)
!520 = !DILocation(line: 89, column: 6, scope: !521, inlinedAt: !473)
!521 = distinct !DILexicalBlock(scope: !469, file: !463, line: 89, column: 6)
!522 = !DILocation(line: 89, column: 17, scope: !521, inlinedAt: !473)
!523 = !DILocation(line: 89, column: 14, scope: !521, inlinedAt: !473)
!524 = !DILocation(line: 89, column: 6, scope: !469, inlinedAt: !473)
!525 = !DILocation(line: 90, column: 10, scope: !526, inlinedAt: !473)
!526 = distinct !DILexicalBlock(scope: !521, file: !463, line: 89, column: 24)
!527 = !DILocation(line: 90, column: 32, scope: !526, inlinedAt: !473)
!528 = !DILocation(line: 90, column: 22, scope: !526, inlinedAt: !473)
!529 = !DILocation(line: 90, column: 21, scope: !526, inlinedAt: !473)
!530 = !DILocation(line: 90, column: 37, scope: !526, inlinedAt: !473)
!531 = !DILocation(line: 90, column: 3, scope: !526, inlinedAt: !473)
!532 = !DILocation(line: 95, column: 7, scope: !494, inlinedAt: !473)
!533 = !DILocation(line: 95, column: 6, scope: !469, inlinedAt: !473)
!534 = !DILocation(line: 96, column: 23, scope: !493, inlinedAt: !473)
!535 = !DILocation(line: 96, column: 36, scope: !493, inlinedAt: !473)
!536 = !DILocation(line: 96, column: 46, scope: !493, inlinedAt: !473)
!537 = !DILocation(line: 96, column: 44, scope: !493, inlinedAt: !473)
!538 = !DILocation(line: 96, column: 55, scope: !493, inlinedAt: !473)
!539 = !DILocation(line: 98, column: 7, scope: !540, inlinedAt: !473)
!540 = distinct !DILexicalBlock(scope: !493, file: !463, line: 98, column: 7)
!541 = !DILocation(line: 98, column: 7, scope: !493, inlinedAt: !473)
!542 = !DILocation(line: 99, column: 10, scope: !543, inlinedAt: !473)
!543 = distinct !DILexicalBlock(scope: !540, file: !463, line: 98, column: 17)
!544 = !DILocation(line: 99, column: 19, scope: !543, inlinedAt: !473)
!545 = !DILocation(line: 99, column: 8, scope: !543, inlinedAt: !473)
!546 = !DILocation(line: 100, column: 3, scope: !543, inlinedAt: !473)
!547 = !DILocation(line: 100, column: 14, scope: !548, inlinedAt: !473)
!548 = distinct !DILexicalBlock(scope: !540, file: !463, line: 100, column: 14)
!549 = !DILocation(line: 100, column: 14, scope: !540, inlinedAt: !473)
!550 = !DILocation(line: 101, column: 10, scope: !551, inlinedAt: !473)
!551 = distinct !DILexicalBlock(scope: !548, file: !463, line: 100, column: 25)
!552 = !DILocation(line: 101, column: 19, scope: !551, inlinedAt: !473)
!553 = !DILocation(line: 101, column: 8, scope: !551, inlinedAt: !473)
!554 = !DILocation(line: 102, column: 3, scope: !551, inlinedAt: !473)
!555 = !DILocation(line: 103, column: 2, scope: !493, inlinedAt: !473)
!556 = !DILocation(line: 110, column: 6, scope: !557, inlinedAt: !473)
!557 = distinct !DILexicalBlock(scope: !469, file: !463, line: 110, column: 6)
!558 = !DILocation(line: 110, column: 6, scope: !469, inlinedAt: !473)
!559 = !DILocation(line: 111, column: 8, scope: !560, inlinedAt: !473)
!560 = distinct !DILexicalBlock(scope: !557, file: !463, line: 110, column: 17)
!561 = !DILocation(line: 111, column: 5, scope: !560, inlinedAt: !473)
!562 = !DILocation(line: 112, column: 7, scope: !563, inlinedAt: !473)
!563 = distinct !DILexicalBlock(scope: !560, file: !463, line: 112, column: 7)
!564 = !DILocation(line: 112, column: 16, scope: !563, inlinedAt: !473)
!565 = !DILocation(line: 112, column: 20, scope: !563, inlinedAt: !473)
!566 = !DILocation(line: 112, column: 22, scope: !563, inlinedAt: !473)
!567 = !DILocation(line: 112, column: 7, scope: !560, inlinedAt: !473)
!568 = !DILocation(line: 113, column: 22, scope: !569, inlinedAt: !473)
!569 = distinct !DILexicalBlock(scope: !563, file: !463, line: 112, column: 36)
!570 = !DILocation(line: 113, column: 12, scope: !569, inlinedAt: !473)
!571 = !DILocation(line: 113, column: 28, scope: !569, inlinedAt: !473)
!572 = !DILocation(line: 113, column: 38, scope: !569, inlinedAt: !473)
!573 = !DILocation(line: 113, column: 36, scope: !569, inlinedAt: !473)
!574 = !DILocation(line: 113, column: 25, scope: !569, inlinedAt: !473)
!575 = !DILocation(line: 113, column: 11, scope: !569, inlinedAt: !473)
!576 = !DILocation(line: 113, column: 4, scope: !569, inlinedAt: !473)
!577 = !DILocation(line: 115, column: 11, scope: !578, inlinedAt: !473)
!578 = distinct !DILexicalBlock(scope: !563, file: !463, line: 114, column: 10)
!579 = !DILocation(line: 115, column: 16, scope: !578, inlinedAt: !473)
!580 = !DILocation(line: 115, column: 26, scope: !578, inlinedAt: !473)
!581 = !DILocation(line: 115, column: 24, scope: !578, inlinedAt: !473)
!582 = !DILocation(line: 115, column: 15, scope: !578, inlinedAt: !473)
!583 = !DILocation(line: 115, column: 13, scope: !578, inlinedAt: !473)
!584 = !DILocation(line: 115, column: 4, scope: !578, inlinedAt: !473)
!585 = !DILocation(line: 117, column: 13, scope: !586, inlinedAt: !473)
!586 = distinct !DILexicalBlock(scope: !557, file: !463, line: 117, column: 13)
!587 = !DILocation(line: 117, column: 13, scope: !557, inlinedAt: !473)
!588 = !DILocation(line: 118, column: 7, scope: !589, inlinedAt: !473)
!589 = distinct !DILexicalBlock(scope: !590, file: !463, line: 118, column: 7)
!590 = distinct !DILexicalBlock(scope: !586, file: !463, line: 117, column: 24)
!591 = !DILocation(line: 118, column: 7, scope: !590, inlinedAt: !473)
!592 = !DILocation(line: 119, column: 22, scope: !593, inlinedAt: !473)
!593 = distinct !DILexicalBlock(scope: !589, file: !463, line: 118, column: 17)
!594 = !DILocation(line: 119, column: 12, scope: !593, inlinedAt: !473)
!595 = !DILocation(line: 119, column: 28, scope: !593, inlinedAt: !473)
!596 = !DILocation(line: 119, column: 36, scope: !593, inlinedAt: !473)
!597 = !DILocation(line: 119, column: 34, scope: !593, inlinedAt: !473)
!598 = !DILocation(line: 119, column: 25, scope: !593, inlinedAt: !473)
!599 = !DILocation(line: 119, column: 11, scope: !593, inlinedAt: !473)
!600 = !DILocation(line: 119, column: 4, scope: !593, inlinedAt: !473)
!601 = !DILocation(line: 121, column: 11, scope: !602, inlinedAt: !473)
!602 = distinct !DILexicalBlock(scope: !589, file: !463, line: 120, column: 10)
!603 = !DILocation(line: 121, column: 16, scope: !602, inlinedAt: !473)
!604 = !DILocation(line: 121, column: 24, scope: !602, inlinedAt: !473)
!605 = !DILocation(line: 121, column: 22, scope: !602, inlinedAt: !473)
!606 = !DILocation(line: 121, column: 15, scope: !602, inlinedAt: !473)
!607 = !DILocation(line: 121, column: 13, scope: !602, inlinedAt: !473)
!608 = !DILocation(line: 121, column: 4, scope: !602, inlinedAt: !473)
!609 = !DILocation(line: 124, column: 7, scope: !610, inlinedAt: !473)
!610 = distinct !DILexicalBlock(scope: !611, file: !463, line: 124, column: 7)
!611 = distinct !DILexicalBlock(scope: !586, file: !463, line: 123, column: 9)
!612 = !DILocation(line: 124, column: 7, scope: !611, inlinedAt: !473)
!613 = !DILocation(line: 125, column: 23, scope: !614, inlinedAt: !473)
!614 = distinct !DILexicalBlock(scope: !610, file: !463, line: 124, column: 17)
!615 = !DILocation(line: 125, column: 27, scope: !614, inlinedAt: !473)
!616 = !DILocation(line: 125, column: 25, scope: !614, inlinedAt: !473)
!617 = !DILocation(line: 125, column: 35, scope: !614, inlinedAt: !473)
!618 = !DILocation(line: 125, column: 33, scope: !614, inlinedAt: !473)
!619 = !DILocation(line: 125, column: 42, scope: !614, inlinedAt: !473)
!620 = !DILocation(line: 125, column: 40, scope: !614, inlinedAt: !473)
!621 = !DILocation(line: 125, column: 11, scope: !614, inlinedAt: !473)
!622 = !DILocation(line: 125, column: 4, scope: !614, inlinedAt: !473)
!623 = !DILocation(line: 127, column: 12, scope: !624, inlinedAt: !473)
!624 = distinct !DILexicalBlock(scope: !610, file: !463, line: 126, column: 10)
!625 = !DILocation(line: 127, column: 16, scope: !624, inlinedAt: !473)
!626 = !DILocation(line: 127, column: 14, scope: !624, inlinedAt: !473)
!627 = !DILocation(line: 127, column: 24, scope: !624, inlinedAt: !473)
!628 = !DILocation(line: 127, column: 22, scope: !624, inlinedAt: !473)
!629 = !DILocation(line: 127, column: 31, scope: !624, inlinedAt: !473)
!630 = !DILocation(line: 127, column: 29, scope: !624, inlinedAt: !473)
!631 = !DILocation(line: 127, column: 4, scope: !624, inlinedAt: !473)
!632 = !DILocation(line: 130, column: 1, scope: !469, inlinedAt: !473)
!633 = !DILocation(line: 372, column: 2, scope: !462)
!634 = distinct !DISubprogram(name: "k_sleep", scope: !635, file: !635, line: 117, type: !636, scopeLine: 118, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!635 = !DIFile(filename: "zephyr/include/generated/syscalls/kernel.h", directory: "/home/kenny/ara/build/appl/Zephyr/button")
!636 = !DISubroutineType(types: !637)
!637 = !{!456, !638}
!638 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_timeout_t", file: !153, line: 69, baseType: !639)
!639 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !153, line: 67, size: 64, elements: !640)
!640 = !{!641}
!641 = !DIDerivedType(tag: DW_TAG_member, name: "ticks", scope: !639, file: !153, line: 68, baseType: !152, size: 64)
!642 = !DILocalVariable(name: "timeout", arg: 1, scope: !634, file: !635, line: 117, type: !638)
!643 = !DILocation(line: 117, column: 61, scope: !634)
!644 = !DILocation(line: 126, column: 2, scope: !634)
!645 = !DILocation(line: 126, column: 2, scope: !646)
!646 = distinct !DILexicalBlock(scope: !634, file: !635, line: 126, column: 2)
!647 = !{i32 -2141855419}
!648 = !DILocation(line: 127, column: 9, scope: !634)
!649 = !DILocation(line: 127, column: 2, scope: !634)
!650 = distinct !DISubprogram(name: "gpio_pin_get", scope: !53, file: !53, line: 918, type: !651, scopeLine: 919, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!651 = !DISubroutineType(types: !652)
!652 = !{!66, !75, !90}
!653 = !DILocalVariable(name: "port", arg: 1, scope: !650, file: !53, line: 918, type: !75)
!654 = !DILocation(line: 918, column: 53, scope: !650)
!655 = !DILocalVariable(name: "pin", arg: 2, scope: !650, file: !53, line: 918, type: !90)
!656 = !DILocation(line: 918, column: 70, scope: !650)
!657 = !DILocalVariable(name: "cfg", scope: !650, file: !53, line: 920, type: !268)
!658 = !DILocation(line: 920, column: 41, scope: !650)
!659 = !DILocation(line: 921, column: 38, scope: !650)
!660 = !DILocation(line: 921, column: 44, scope: !650)
!661 = !DILocation(line: 921, column: 3, scope: !650)
!662 = !DILocalVariable(name: "value", scope: !650, file: !53, line: 922, type: !100)
!663 = !DILocation(line: 922, column: 20, scope: !650)
!664 = !DILocalVariable(name: "ret", scope: !650, file: !53, line: 923, type: !66)
!665 = !DILocation(line: 923, column: 6, scope: !650)
!666 = !DILocation(line: 925, column: 8, scope: !650)
!667 = !DILocation(line: 929, column: 22, scope: !650)
!668 = !DILocation(line: 929, column: 8, scope: !650)
!669 = !DILocation(line: 929, column: 6, scope: !650)
!670 = !DILocation(line: 930, column: 6, scope: !671)
!671 = distinct !DILexicalBlock(scope: !650, file: !53, line: 930, column: 6)
!672 = !DILocation(line: 930, column: 10, scope: !671)
!673 = !DILocation(line: 930, column: 6, scope: !650)
!674 = !DILocation(line: 931, column: 10, scope: !675)
!675 = distinct !DILexicalBlock(scope: !671, file: !53, line: 930, column: 16)
!676 = !DILocation(line: 931, column: 36, scope: !675)
!677 = !DILocation(line: 931, column: 16, scope: !675)
!678 = !DILocation(line: 931, column: 46, scope: !675)
!679 = !DILocation(line: 931, column: 9, scope: !675)
!680 = !DILocation(line: 931, column: 7, scope: !675)
!681 = !DILocation(line: 932, column: 2, scope: !675)
!682 = !DILocation(line: 934, column: 9, scope: !650)
!683 = !DILocation(line: 934, column: 2, scope: !650)
!684 = distinct !DISubprogram(name: "gpio_pin_set", scope: !53, file: !53, line: 993, type: !685, scopeLine: 995, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!685 = !DISubroutineType(types: !686)
!686 = !{!66, !75, !90, !66}
!687 = !DILocalVariable(name: "port", arg: 1, scope: !684, file: !53, line: 993, type: !75)
!688 = !DILocation(line: 993, column: 53, scope: !684)
!689 = !DILocalVariable(name: "pin", arg: 2, scope: !684, file: !53, line: 993, type: !90)
!690 = !DILocation(line: 993, column: 70, scope: !684)
!691 = !DILocalVariable(name: "value", arg: 3, scope: !684, file: !53, line: 994, type: !66)
!692 = !DILocation(line: 994, column: 15, scope: !684)
!693 = !DILocalVariable(name: "cfg", scope: !684, file: !53, line: 996, type: !268)
!694 = !DILocation(line: 996, column: 41, scope: !684)
!695 = !DILocation(line: 997, column: 38, scope: !684)
!696 = !DILocation(line: 997, column: 44, scope: !684)
!697 = !DILocation(line: 997, column: 3, scope: !684)
!698 = !DILocalVariable(name: "data", scope: !684, file: !53, line: 998, type: !699)
!699 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !146)
!700 = !DILocation(line: 998, column: 39, scope: !684)
!701 = !DILocation(line: 999, column: 37, scope: !684)
!702 = !DILocation(line: 999, column: 43, scope: !684)
!703 = !DILocation(line: 999, column: 4, scope: !684)
!704 = !DILocation(line: 1001, column: 8, scope: !684)
!705 = !DILocation(line: 1005, column: 6, scope: !706)
!706 = distinct !DILexicalBlock(scope: !684, file: !53, line: 1005, column: 6)
!707 = !DILocation(line: 1005, column: 12, scope: !706)
!708 = !DILocation(line: 1005, column: 39, scope: !706)
!709 = !DILocation(line: 1005, column: 19, scope: !706)
!710 = !DILocation(line: 1005, column: 6, scope: !684)
!711 = !DILocation(line: 1006, column: 12, scope: !712)
!712 = distinct !DILexicalBlock(scope: !706, file: !53, line: 1005, column: 49)
!713 = !DILocation(line: 1006, column: 18, scope: !712)
!714 = !DILocation(line: 1006, column: 11, scope: !712)
!715 = !DILocation(line: 1006, column: 9, scope: !712)
!716 = !DILocation(line: 1007, column: 2, scope: !712)
!717 = !DILocation(line: 1009, column: 26, scope: !684)
!718 = !DILocation(line: 1009, column: 32, scope: !684)
!719 = !DILocation(line: 1009, column: 37, scope: !684)
!720 = !DILocation(line: 1009, column: 9, scope: !684)
!721 = !DILocation(line: 1009, column: 2, scope: !684)
!722 = distinct !DISubprogram(name: "gpio_pin_set_raw", scope: !53, file: !53, line: 952, type: !685, scopeLine: 954, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!723 = !DILocalVariable(name: "port", arg: 1, scope: !722, file: !53, line: 952, type: !75)
!724 = !DILocation(line: 952, column: 57, scope: !722)
!725 = !DILocalVariable(name: "pin", arg: 2, scope: !722, file: !53, line: 952, type: !90)
!726 = !DILocation(line: 952, column: 74, scope: !722)
!727 = !DILocalVariable(name: "value", arg: 3, scope: !722, file: !53, line: 953, type: !66)
!728 = !DILocation(line: 953, column: 12, scope: !722)
!729 = !DILocalVariable(name: "cfg", scope: !722, file: !53, line: 955, type: !268)
!730 = !DILocation(line: 955, column: 41, scope: !722)
!731 = !DILocation(line: 956, column: 38, scope: !722)
!732 = !DILocation(line: 956, column: 44, scope: !722)
!733 = !DILocation(line: 956, column: 3, scope: !722)
!734 = !DILocalVariable(name: "ret", scope: !722, file: !53, line: 957, type: !66)
!735 = !DILocation(line: 957, column: 6, scope: !722)
!736 = !DILocation(line: 959, column: 8, scope: !722)
!737 = !DILocation(line: 963, column: 6, scope: !738)
!738 = distinct !DILexicalBlock(scope: !722, file: !53, line: 963, column: 6)
!739 = !DILocation(line: 963, column: 12, scope: !738)
!740 = !DILocation(line: 963, column: 6, scope: !722)
!741 = !DILocation(line: 964, column: 32, scope: !742)
!742 = distinct !DILexicalBlock(scope: !738, file: !53, line: 963, column: 18)
!743 = !DILocation(line: 964, column: 56, scope: !742)
!744 = !DILocation(line: 964, column: 9, scope: !742)
!745 = !DILocation(line: 964, column: 7, scope: !742)
!746 = !DILocation(line: 965, column: 2, scope: !742)
!747 = !DILocation(line: 966, column: 34, scope: !748)
!748 = distinct !DILexicalBlock(scope: !738, file: !53, line: 965, column: 9)
!749 = !DILocation(line: 966, column: 58, scope: !748)
!750 = !DILocation(line: 966, column: 9, scope: !748)
!751 = !DILocation(line: 966, column: 7, scope: !748)
!752 = !DILocation(line: 969, column: 9, scope: !722)
!753 = !DILocation(line: 969, column: 2, scope: !722)
!754 = distinct !DISubprogram(name: "gpio_port_set_bits_raw", scope: !347, file: !347, line: 77, type: !108, scopeLine: 78, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!755 = !DILocalVariable(name: "port", arg: 1, scope: !754, file: !347, line: 77, type: !75)
!756 = !DILocation(line: 77, column: 82, scope: !754)
!757 = !DILocalVariable(name: "pins", arg: 2, scope: !754, file: !347, line: 77, type: !105)
!758 = !DILocation(line: 77, column: 105, scope: !754)
!759 = !DILocation(line: 84, column: 2, scope: !754)
!760 = !DILocation(line: 84, column: 2, scope: !761)
!761 = distinct !DILexicalBlock(scope: !754, file: !347, line: 84, column: 2)
!762 = !{i32 -2141747471}
!763 = !DILocation(line: 85, column: 39, scope: !754)
!764 = !DILocation(line: 85, column: 45, scope: !754)
!765 = !DILocation(line: 85, column: 9, scope: !754)
!766 = !DILocation(line: 85, column: 2, scope: !754)
!767 = distinct !DISubprogram(name: "gpio_port_clear_bits_raw", scope: !347, file: !347, line: 90, type: !108, scopeLine: 91, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!768 = !DILocalVariable(name: "port", arg: 1, scope: !767, file: !347, line: 90, type: !75)
!769 = !DILocation(line: 90, column: 84, scope: !767)
!770 = !DILocalVariable(name: "pins", arg: 2, scope: !767, file: !347, line: 90, type: !105)
!771 = !DILocation(line: 90, column: 107, scope: !767)
!772 = !DILocation(line: 97, column: 2, scope: !767)
!773 = !DILocation(line: 97, column: 2, scope: !774)
!774 = distinct !DILexicalBlock(scope: !767, file: !347, line: 97, column: 2)
!775 = !{i32 -2141747403}
!776 = !DILocation(line: 98, column: 41, scope: !767)
!777 = !DILocation(line: 98, column: 47, scope: !767)
!778 = !DILocation(line: 98, column: 9, scope: !767)
!779 = !DILocation(line: 98, column: 2, scope: !767)
!780 = distinct !DISubprogram(name: "z_impl_gpio_port_clear_bits_raw", scope: !53, file: !53, line: 778, type: !108, scopeLine: 780, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!781 = !DILocalVariable(name: "port", arg: 1, scope: !780, file: !53, line: 778, type: !75)
!782 = !DILocation(line: 778, column: 72, scope: !780)
!783 = !DILocalVariable(name: "pins", arg: 2, scope: !780, file: !53, line: 779, type: !105)
!784 = !DILocation(line: 779, column: 26, scope: !780)
!785 = !DILocalVariable(name: "api", scope: !780, file: !53, line: 781, type: !67)
!786 = !DILocation(line: 781, column: 32, scope: !780)
!787 = !DILocation(line: 782, column: 35, scope: !780)
!788 = !DILocation(line: 782, column: 41, scope: !780)
!789 = !DILocation(line: 782, column: 3, scope: !780)
!790 = !DILocation(line: 784, column: 9, scope: !780)
!791 = !DILocation(line: 784, column: 14, scope: !780)
!792 = !DILocation(line: 784, column: 34, scope: !780)
!793 = !DILocation(line: 784, column: 40, scope: !780)
!794 = !DILocation(line: 784, column: 2, scope: !780)
!795 = distinct !DISubprogram(name: "z_impl_gpio_port_set_bits_raw", scope: !53, file: !53, line: 740, type: !108, scopeLine: 742, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!796 = !DILocalVariable(name: "port", arg: 1, scope: !795, file: !53, line: 740, type: !75)
!797 = !DILocation(line: 740, column: 70, scope: !795)
!798 = !DILocalVariable(name: "pins", arg: 2, scope: !795, file: !53, line: 741, type: !105)
!799 = !DILocation(line: 741, column: 24, scope: !795)
!800 = !DILocalVariable(name: "api", scope: !795, file: !53, line: 743, type: !67)
!801 = !DILocation(line: 743, column: 32, scope: !795)
!802 = !DILocation(line: 744, column: 35, scope: !795)
!803 = !DILocation(line: 744, column: 41, scope: !795)
!804 = !DILocation(line: 744, column: 3, scope: !795)
!805 = !DILocation(line: 746, column: 9, scope: !795)
!806 = !DILocation(line: 746, column: 14, scope: !795)
!807 = !DILocation(line: 746, column: 32, scope: !795)
!808 = !DILocation(line: 746, column: 38, scope: !795)
!809 = !DILocation(line: 746, column: 2, scope: !795)
!810 = distinct !DISubprogram(name: "gpio_port_get", scope: !53, file: !53, line: 649, type: !97, scopeLine: 651, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!811 = !DILocalVariable(name: "port", arg: 1, scope: !810, file: !53, line: 649, type: !75)
!812 = !DILocation(line: 649, column: 54, scope: !810)
!813 = !DILocalVariable(name: "value", arg: 2, scope: !810, file: !53, line: 650, type: !99)
!814 = !DILocation(line: 650, column: 24, scope: !810)
!815 = !DILocalVariable(name: "data", scope: !810, file: !53, line: 652, type: !699)
!816 = !DILocation(line: 652, column: 39, scope: !810)
!817 = !DILocation(line: 653, column: 37, scope: !810)
!818 = !DILocation(line: 653, column: 43, scope: !810)
!819 = !DILocation(line: 653, column: 4, scope: !810)
!820 = !DILocalVariable(name: "ret", scope: !810, file: !53, line: 654, type: !66)
!821 = !DILocation(line: 654, column: 6, scope: !810)
!822 = !DILocation(line: 656, column: 26, scope: !810)
!823 = !DILocation(line: 656, column: 32, scope: !810)
!824 = !DILocation(line: 656, column: 8, scope: !810)
!825 = !DILocation(line: 656, column: 6, scope: !810)
!826 = !DILocation(line: 657, column: 6, scope: !827)
!827 = distinct !DILexicalBlock(scope: !810, file: !53, line: 657, column: 6)
!828 = !DILocation(line: 657, column: 10, scope: !827)
!829 = !DILocation(line: 657, column: 6, scope: !810)
!830 = !DILocation(line: 658, column: 13, scope: !831)
!831 = distinct !DILexicalBlock(scope: !827, file: !53, line: 657, column: 16)
!832 = !DILocation(line: 658, column: 19, scope: !831)
!833 = !DILocation(line: 658, column: 4, scope: !831)
!834 = !DILocation(line: 658, column: 10, scope: !831)
!835 = !DILocation(line: 659, column: 2, scope: !831)
!836 = !DILocation(line: 661, column: 9, scope: !810)
!837 = !DILocation(line: 661, column: 2, scope: !810)
!838 = distinct !DISubprogram(name: "gpio_port_get_raw", scope: !347, file: !347, line: 51, type: !97, scopeLine: 52, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!839 = !DILocalVariable(name: "port", arg: 1, scope: !838, file: !347, line: 51, type: !75)
!840 = !DILocation(line: 51, column: 77, scope: !838)
!841 = !DILocalVariable(name: "value", arg: 2, scope: !838, file: !347, line: 51, type: !99)
!842 = !DILocation(line: 51, column: 103, scope: !838)
!843 = !DILocation(line: 58, column: 2, scope: !838)
!844 = !DILocation(line: 58, column: 2, scope: !845)
!845 = distinct !DILexicalBlock(scope: !838, file: !347, line: 58, column: 2)
!846 = !{i32 -2141747607}
!847 = !DILocation(line: 59, column: 34, scope: !838)
!848 = !DILocation(line: 59, column: 40, scope: !838)
!849 = !DILocation(line: 59, column: 9, scope: !838)
!850 = !DILocation(line: 59, column: 2, scope: !838)
!851 = distinct !DISubprogram(name: "z_impl_gpio_port_get_raw", scope: !53, file: !53, line: 622, type: !97, scopeLine: 624, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!852 = !DILocalVariable(name: "port", arg: 1, scope: !851, file: !53, line: 622, type: !75)
!853 = !DILocation(line: 622, column: 65, scope: !851)
!854 = !DILocalVariable(name: "value", arg: 2, scope: !851, file: !53, line: 623, type: !99)
!855 = !DILocation(line: 623, column: 28, scope: !851)
!856 = !DILocalVariable(name: "api", scope: !851, file: !53, line: 625, type: !67)
!857 = !DILocation(line: 625, column: 32, scope: !851)
!858 = !DILocation(line: 626, column: 35, scope: !851)
!859 = !DILocation(line: 626, column: 41, scope: !851)
!860 = !DILocation(line: 626, column: 3, scope: !851)
!861 = !DILocation(line: 628, column: 9, scope: !851)
!862 = !DILocation(line: 628, column: 14, scope: !851)
!863 = !DILocation(line: 628, column: 27, scope: !851)
!864 = !DILocation(line: 628, column: 33, scope: !851)
!865 = !DILocation(line: 628, column: 2, scope: !851)
!866 = distinct !DISubprogram(name: "z_impl_gpio_pin_interrupt_configure", scope: !53, file: !53, line: 475, type: !73, scopeLine: 478, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!867 = !DILocalVariable(name: "port", arg: 1, scope: !866, file: !53, line: 475, type: !75)
!868 = !DILocation(line: 475, column: 76, scope: !866)
!869 = !DILocalVariable(name: "pin", arg: 2, scope: !866, file: !53, line: 476, type: !90)
!870 = !DILocation(line: 476, column: 24, scope: !866)
!871 = !DILocalVariable(name: "flags", arg: 3, scope: !866, file: !53, line: 477, type: !93)
!872 = !DILocation(line: 477, column: 26, scope: !866)
!873 = !DILocalVariable(name: "api", scope: !866, file: !53, line: 479, type: !67)
!874 = !DILocation(line: 479, column: 32, scope: !866)
!875 = !DILocation(line: 480, column: 35, scope: !866)
!876 = !DILocation(line: 480, column: 41, scope: !866)
!877 = !DILocation(line: 480, column: 3, scope: !866)
!878 = !DILocalVariable(name: "cfg", scope: !866, file: !53, line: 481, type: !268)
!879 = !DILocation(line: 481, column: 41, scope: !866)
!880 = !DILocation(line: 482, column: 38, scope: !866)
!881 = !DILocation(line: 482, column: 44, scope: !866)
!882 = !DILocation(line: 482, column: 3, scope: !866)
!883 = !DILocalVariable(name: "data", scope: !866, file: !53, line: 483, type: !699)
!884 = !DILocation(line: 483, column: 39, scope: !866)
!885 = !DILocation(line: 484, column: 36, scope: !866)
!886 = !DILocation(line: 484, column: 42, scope: !866)
!887 = !DILocation(line: 484, column: 3, scope: !866)
!888 = !DILocalVariable(name: "trig", scope: !866, file: !53, line: 485, type: !59)
!889 = !DILocation(line: 485, column: 21, scope: !866)
!890 = !DILocalVariable(name: "mode", scope: !866, file: !53, line: 486, type: !52)
!891 = !DILocation(line: 486, column: 21, scope: !866)
!892 = !DILocation(line: 509, column: 8, scope: !866)
!893 = !DILocation(line: 513, column: 8, scope: !894)
!894 = distinct !DILexicalBlock(scope: !866, file: !53, line: 513, column: 6)
!895 = !DILocation(line: 513, column: 14, scope: !894)
!896 = !DILocation(line: 513, column: 41, scope: !894)
!897 = !DILocation(line: 513, column: 47, scope: !894)
!898 = !DILocation(line: 514, column: 8, scope: !894)
!899 = !DILocation(line: 514, column: 14, scope: !894)
!900 = !DILocation(line: 514, column: 41, scope: !894)
!901 = !DILocation(line: 514, column: 21, scope: !894)
!902 = !DILocation(line: 514, column: 51, scope: !894)
!903 = !DILocation(line: 513, column: 6, scope: !866)
!904 = !DILocation(line: 516, column: 9, scope: !905)
!905 = distinct !DILexicalBlock(scope: !894, file: !53, line: 514, column: 58)
!906 = !DILocation(line: 517, column: 2, scope: !905)
!907 = !DILocation(line: 519, column: 30, scope: !866)
!908 = !DILocation(line: 519, column: 36, scope: !866)
!909 = !DILocation(line: 519, column: 7, scope: !866)
!910 = !DILocation(line: 520, column: 30, scope: !866)
!911 = !DILocation(line: 520, column: 36, scope: !866)
!912 = !DILocation(line: 520, column: 7, scope: !866)
!913 = !DILocation(line: 522, column: 9, scope: !866)
!914 = !DILocation(line: 522, column: 14, scope: !866)
!915 = !DILocation(line: 522, column: 38, scope: !866)
!916 = !DILocation(line: 522, column: 44, scope: !866)
!917 = !DILocation(line: 522, column: 49, scope: !866)
!918 = !DILocation(line: 522, column: 55, scope: !866)
!919 = !DILocation(line: 522, column: 2, scope: !866)
!920 = distinct !DISubprogram(name: "gpio_config", scope: !347, file: !347, line: 25, type: !73, scopeLine: 26, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!921 = !DILocalVariable(name: "port", arg: 1, scope: !920, file: !347, line: 25, type: !75)
!922 = !DILocation(line: 25, column: 71, scope: !920)
!923 = !DILocalVariable(name: "pin", arg: 2, scope: !920, file: !347, line: 25, type: !90)
!924 = !DILocation(line: 25, column: 88, scope: !920)
!925 = !DILocalVariable(name: "flags", arg: 3, scope: !920, file: !347, line: 25, type: !93)
!926 = !DILocation(line: 25, column: 106, scope: !920)
!927 = !DILocation(line: 32, column: 2, scope: !920)
!928 = !DILocation(line: 32, column: 2, scope: !929)
!929 = distinct !DILexicalBlock(scope: !920, file: !347, line: 32, column: 2)
!930 = !{i32 -2141747743}
!931 = !DILocation(line: 33, column: 28, scope: !920)
!932 = !DILocation(line: 33, column: 34, scope: !920)
!933 = !DILocation(line: 33, column: 39, scope: !920)
!934 = !DILocation(line: 33, column: 9, scope: !920)
!935 = !DILocation(line: 33, column: 2, scope: !920)
!936 = distinct !DISubprogram(name: "z_impl_gpio_config", scope: !53, file: !53, line: 438, type: !73, scopeLine: 440, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !167)
!937 = !DILocalVariable(name: "port", arg: 1, scope: !936, file: !53, line: 438, type: !75)
!938 = !DILocation(line: 438, column: 59, scope: !936)
!939 = !DILocalVariable(name: "pin", arg: 2, scope: !936, file: !53, line: 439, type: !90)
!940 = !DILocation(line: 439, column: 21, scope: !936)
!941 = !DILocalVariable(name: "flags", arg: 3, scope: !936, file: !53, line: 439, type: !93)
!942 = !DILocation(line: 439, column: 39, scope: !936)
!943 = !DILocalVariable(name: "api", scope: !936, file: !53, line: 441, type: !67)
!944 = !DILocation(line: 441, column: 32, scope: !936)
!945 = !DILocation(line: 442, column: 35, scope: !936)
!946 = !DILocation(line: 442, column: 41, scope: !936)
!947 = !DILocation(line: 442, column: 3, scope: !936)
!948 = !DILocation(line: 444, column: 9, scope: !936)
!949 = !DILocation(line: 444, column: 14, scope: !936)
!950 = !DILocation(line: 444, column: 28, scope: !936)
!951 = !DILocation(line: 444, column: 34, scope: !936)
!952 = !DILocation(line: 444, column: 39, scope: !936)
!953 = !DILocation(line: 444, column: 2, scope: !936)
