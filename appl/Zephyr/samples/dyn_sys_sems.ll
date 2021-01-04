; ModuleID = 'llvm-link'
source_filename = "llvm-link"
target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "thumbv7em-none-unknown-eabi"

%struct.sys_sem = type { %struct.k_sem }
%struct.k_sem = type { %struct._wait_q_t, i32, i32 }
%struct._wait_q_t = type { %struct._dnode }
%struct._dnode = type { %union.anon.0, %union.anon.0 }
%union.anon.0 = type { %struct._dnode* }
%struct.z_thread_stack_element = type { i8 }
%struct.k_thread = type { %struct._thread_base, %struct._callee_saved, i8*, void ()*, i32, %struct._thread_stack_info, %struct.k_mem_pool*, %struct._thread_arch }
%struct._thread_base = type { %struct._wait_q_t, %struct._wait_q_t*, i8, i8, %union.anon.2, i32, i8*, %struct._timeout, %struct._wait_q_t }
%union.anon.2 = type { i16 }
%struct._timeout = type { %struct._dnode, void (%struct._timeout*)*, i64 }
%struct._callee_saved = type { i32, i32, i32, i32, i32, i32, i32, i32, i32 }
%struct._thread_stack_info = type { i32, i32, i32 }
%struct.k_mem_pool = type { %struct.k_heap* }
%struct.k_heap = type { %struct.sys_heap, %struct._wait_q_t, %struct.k_spinlock }
%struct.sys_heap = type { %struct.z_heap*, i8*, i32 }
%struct.z_heap = type opaque
%struct.k_spinlock = type {}
%struct._thread_arch = type { i32, i32 }
%struct.k_timeout_t = type { i64 }

@threadB_sem = dso_local global %struct.sys_sem zeroinitializer, align 4, !dbg !0
@threadA_sem = dso_local global %struct.sys_sem zeroinitializer, align 4, !dbg !63
@threadB_stack_area = dso_local global [1024 x %struct.z_thread_stack_element] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/dyn_sys_sems/src/main.c\22.0", align 8, !dbg !95
@threadA_data = dso_local global %struct.k_thread zeroinitializer, align 8, !dbg !216
@threadA_stack_area = dso_local global [1024 x %struct.z_thread_stack_element] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/dyn_sys_sems/src/main.c\22.1", align 8, !dbg !214
@.str = private unnamed_addr constant [26 x i8] c"%s: Hello World from %s!\0A\00", align 1
@.str.1 = private unnamed_addr constant [14 x i8] c"nucleo_f303re\00", align 1
@__func__.threadB = private unnamed_addr constant [8 x i8] c"threadB\00", align 1
@threadB_data = internal global %struct.k_thread zeroinitializer, align 8, !dbg !105
@.str.2 = private unnamed_addr constant [9 x i8] c"thread_b\00", align 1
@__func__.threadA = private unnamed_addr constant [8 x i8] c"threadA\00", align 1
@.str.3 = private unnamed_addr constant [9 x i8] c"thread_a\00", align 1

; Function Attrs: noinline nounwind optnone
define dso_local void @helloLoop(i8*, %struct.k_sem*, %struct.k_sem*) #0 !dbg !223 {
  %4 = alloca i8*, align 4
  %5 = alloca %struct.k_sem*, align 4
  %6 = alloca %struct.k_sem*, align 4
  %7 = alloca i8*, align 4
  %8 = alloca %struct.k_timeout_t, align 8
  store i8* %0, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !229, metadata !DIExpression()), !dbg !230
  store %struct.k_sem* %1, %struct.k_sem** %5, align 4
  call void @llvm.dbg.declare(metadata %struct.k_sem** %5, metadata !231, metadata !DIExpression()), !dbg !232
  store %struct.k_sem* %2, %struct.k_sem** %6, align 4
  call void @llvm.dbg.declare(metadata %struct.k_sem** %6, metadata !233, metadata !DIExpression()), !dbg !234
  call void @llvm.dbg.declare(metadata i8** %7, metadata !235, metadata !DIExpression()), !dbg !236
  br label %9, !dbg !237

9:                                                ; preds = %31, %3
  %10 = load %struct.k_sem*, %struct.k_sem** %5, align 4, !dbg !238
  %11 = bitcast %struct.k_sem* %10 to %struct.sys_sem*, !dbg !238
  %12 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %8, i32 0, i32 0, !dbg !240
  store i64 -1, i64* %12, align 8, !dbg !240
  %13 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %8, i32 0, i32 0, !dbg !241
  %14 = bitcast i64* %13 to [1 x i64]*, !dbg !241
  %15 = load [1 x i64], [1 x i64]* %14, align 8, !dbg !241
  %16 = call i32 @sys_sem_take(%struct.sys_sem* %11, [1 x i64] %15) #3, !dbg !241
  %17 = call %struct.k_thread* @k_current_get() #3, !dbg !242
  %18 = call i8* @k_thread_name_get(%struct.k_thread* %17) #3, !dbg !243
  store i8* %18, i8** %7, align 4, !dbg !244
  %19 = load i8*, i8** %7, align 4, !dbg !245
  %20 = icmp ne i8* %19, null, !dbg !247
  br i1 %20, label %21, label %29, !dbg !248

21:                                               ; preds = %9
  %22 = load i8*, i8** %7, align 4, !dbg !249
  %23 = getelementptr i8, i8* %22, i32 0, !dbg !249
  %24 = load i8, i8* %23, align 1, !dbg !249
  %25 = zext i8 %24 to i32, !dbg !249
  %26 = icmp ne i32 %25, 0, !dbg !250
  br i1 %26, label %27, label %29, !dbg !251

27:                                               ; preds = %21
  %28 = load i8*, i8** %7, align 4, !dbg !252
  call void (i8*, ...) @printk(i8* getelementptr inbounds ([26 x i8], [26 x i8]* @.str, i32 0, i32 0), i8* %28, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i32 0, i32 0)) #3, !dbg !254
  br label %31, !dbg !255

29:                                               ; preds = %21, %9
  %30 = load i8*, i8** %4, align 4, !dbg !256
  call void (i8*, ...) @printk(i8* getelementptr inbounds ([26 x i8], [26 x i8]* @.str, i32 0, i32 0), i8* %30, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i32 0, i32 0)) #3, !dbg !258
  br label %31

31:                                               ; preds = %29, %27
  %32 = call i32 @k_msleep(i32 500) #3, !dbg !259
  %33 = load %struct.k_sem*, %struct.k_sem** %6, align 4, !dbg !260
  %34 = bitcast %struct.k_sem* %33 to %struct.sys_sem*, !dbg !260
  %35 = call i32 @sys_sem_give(%struct.sys_sem* %34) #3, !dbg !261
  br label %9, !dbg !237, !llvm.loop !262
}

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

declare dso_local i32 @sys_sem_take(%struct.sys_sem*, [1 x i64]) #2

; Function Attrs: noinline nounwind optnone
define internal %struct.k_thread* @k_current_get() #0 !dbg !264 {
  br label %1, !dbg !270

1:                                                ; preds = %0
  call void asm sideeffect "", "~{memory}"() #4, !dbg !271, !srcloc !273
  br label %2, !dbg !271

2:                                                ; preds = %1
  %3 = call %struct.k_thread* bitcast (%struct.k_thread* (...)* @z_impl_k_current_get to %struct.k_thread* ()*)() #3, !dbg !274
  ret %struct.k_thread* %3, !dbg !275
}

declare dso_local i8* @k_thread_name_get(%struct.k_thread*) #2

declare dso_local void @printk(i8*, ...) #2

; Function Attrs: noinline nounwind optnone
define internal i32 @k_msleep(i32) #0 !dbg !276 {
  %2 = alloca i32, align 4
  %3 = alloca %struct.k_timeout_t, align 8
  store i32 %0, i32* %2, align 4
  call void @llvm.dbg.declare(metadata i32* %2, metadata !280, metadata !DIExpression()), !dbg !281
  %4 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !282
  %5 = load i32, i32* %2, align 4, !dbg !282
  %6 = icmp sgt i32 %5, 0, !dbg !282
  br i1 %6, label %7, label %9, !dbg !282

7:                                                ; preds = %1
  %8 = load i32, i32* %2, align 4, !dbg !282
  br label %10, !dbg !282

9:                                                ; preds = %1
  br label %10, !dbg !282

10:                                               ; preds = %9, %7
  %11 = phi i32 [ %8, %7 ], [ 0, %9 ], !dbg !282
  %12 = sext i32 %11 to i64, !dbg !282
  %13 = call i64 @k_ms_to_ticks_ceil64(i64 %12) #3, !dbg !282
  store i64 %13, i64* %4, align 8, !dbg !282
  %14 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !283
  %15 = bitcast i64* %14 to [1 x i64]*, !dbg !283
  %16 = load [1 x i64], [1 x i64]* %15, align 8, !dbg !283
  %17 = call i32 @k_sleep([1 x i64] %16) #3, !dbg !283
  ret i32 %17, !dbg !284
}

declare dso_local i32 @sys_sem_give(%struct.sys_sem*) #2

; Function Attrs: noinline nounwind optnone
define internal i64 @k_ms_to_ticks_ceil64(i64) #0 !dbg !285 {
  %2 = alloca i64, align 8
  %3 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %3, metadata !291, metadata !DIExpression()), !dbg !296
  %4 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !298, metadata !DIExpression()), !dbg !299
  %5 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %5, metadata !300, metadata !DIExpression()), !dbg !301
  %6 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %6, metadata !302, metadata !DIExpression()), !dbg !303
  %7 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %7, metadata !304, metadata !DIExpression()), !dbg !305
  %8 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %8, metadata !306, metadata !DIExpression()), !dbg !307
  %9 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %9, metadata !308, metadata !DIExpression()), !dbg !309
  %10 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %10, metadata !310, metadata !DIExpression()), !dbg !311
  %11 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %11, metadata !312, metadata !DIExpression()), !dbg !313
  %12 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %12, metadata !314, metadata !DIExpression()), !dbg !315
  %13 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %13, metadata !316, metadata !DIExpression()), !dbg !319
  %14 = alloca i64, align 8
  store i64 %0, i64* %14, align 8
  call void @llvm.dbg.declare(metadata i64* %14, metadata !320, metadata !DIExpression()), !dbg !321
  %15 = load i64, i64* %14, align 8, !dbg !322
  store i64 %15, i64* %3, align 8
  store i32 1000, i32* %4, align 4
  store i32 10000, i32* %5, align 4
  store i8 1, i8* %6, align 1
  store i8 0, i8* %7, align 1
  store i8 1, i8* %8, align 1
  store i8 0, i8* %9, align 1
  %16 = load i8, i8* %6, align 1, !dbg !323
  %17 = trunc i8 %16 to i1, !dbg !323
  br i1 %17, label %18, label %27, !dbg !324

18:                                               ; preds = %1
  %19 = load i32, i32* %5, align 4, !dbg !325
  %20 = load i32, i32* %4, align 4, !dbg !326
  %21 = icmp ugt i32 %19, %20, !dbg !327
  br i1 %21, label %22, label %27, !dbg !328

22:                                               ; preds = %18
  %23 = load i32, i32* %5, align 4, !dbg !329
  %24 = load i32, i32* %4, align 4, !dbg !330
  %25 = urem i32 %23, %24, !dbg !331
  %26 = icmp eq i32 %25, 0, !dbg !332
  br label %27

27:                                               ; preds = %22, %18, %1
  %28 = phi i1 [ false, %18 ], [ false, %1 ], [ %26, %22 ], !dbg !333
  %29 = zext i1 %28 to i8, !dbg !311
  store i8 %29, i8* %10, align 1, !dbg !311
  %30 = load i8, i8* %6, align 1, !dbg !334
  %31 = trunc i8 %30 to i1, !dbg !334
  br i1 %31, label %32, label %41, !dbg !335

32:                                               ; preds = %27
  %33 = load i32, i32* %4, align 4, !dbg !336
  %34 = load i32, i32* %5, align 4, !dbg !337
  %35 = icmp ugt i32 %33, %34, !dbg !338
  br i1 %35, label %36, label %41, !dbg !339

36:                                               ; preds = %32
  %37 = load i32, i32* %4, align 4, !dbg !340
  %38 = load i32, i32* %5, align 4, !dbg !341
  %39 = urem i32 %37, %38, !dbg !342
  %40 = icmp eq i32 %39, 0, !dbg !343
  br label %41

41:                                               ; preds = %36, %32, %27
  %42 = phi i1 [ false, %32 ], [ false, %27 ], [ %40, %36 ], !dbg !333
  %43 = zext i1 %42 to i8, !dbg !313
  store i8 %43, i8* %11, align 1, !dbg !313
  %44 = load i32, i32* %4, align 4, !dbg !344
  %45 = load i32, i32* %5, align 4, !dbg !346
  %46 = icmp eq i32 %44, %45, !dbg !347
  br i1 %46, label %47, label %58, !dbg !348

47:                                               ; preds = %41
  %48 = load i8, i8* %7, align 1, !dbg !349
  %49 = trunc i8 %48 to i1, !dbg !349
  br i1 %49, label %50, label %54, !dbg !349

50:                                               ; preds = %47
  %51 = load i64, i64* %3, align 8, !dbg !351
  %52 = trunc i64 %51 to i32, !dbg !352
  %53 = zext i32 %52 to i64, !dbg !353
  br label %56, !dbg !349

54:                                               ; preds = %47
  %55 = load i64, i64* %3, align 8, !dbg !354
  br label %56, !dbg !349

56:                                               ; preds = %54, %50
  %57 = phi i64 [ %53, %50 ], [ %55, %54 ], !dbg !349
  store i64 %57, i64* %2, align 8, !dbg !355
  br label %160, !dbg !355

58:                                               ; preds = %41
  store i64 0, i64* %12, align 8, !dbg !315
  %59 = load i8, i8* %10, align 1, !dbg !356
  %60 = trunc i8 %59 to i1, !dbg !356
  br i1 %60, label %87, label %61, !dbg !357

61:                                               ; preds = %58
  %62 = load i8, i8* %11, align 1, !dbg !358
  %63 = trunc i8 %62 to i1, !dbg !358
  br i1 %63, label %64, label %68, !dbg !358

64:                                               ; preds = %61
  %65 = load i32, i32* %4, align 4, !dbg !359
  %66 = load i32, i32* %5, align 4, !dbg !360
  %67 = udiv i32 %65, %66, !dbg !361
  br label %70, !dbg !358

68:                                               ; preds = %61
  %69 = load i32, i32* %4, align 4, !dbg !362
  br label %70, !dbg !358

70:                                               ; preds = %68, %64
  %71 = phi i32 [ %67, %64 ], [ %69, %68 ], !dbg !358
  store i32 %71, i32* %13, align 4, !dbg !319
  %72 = load i8, i8* %8, align 1, !dbg !363
  %73 = trunc i8 %72 to i1, !dbg !363
  br i1 %73, label %74, label %78, !dbg !365

74:                                               ; preds = %70
  %75 = load i32, i32* %13, align 4, !dbg !366
  %76 = sub i32 %75, 1, !dbg !368
  %77 = zext i32 %76 to i64, !dbg !366
  store i64 %77, i64* %12, align 8, !dbg !369
  br label %86, !dbg !370

78:                                               ; preds = %70
  %79 = load i8, i8* %9, align 1, !dbg !371
  %80 = trunc i8 %79 to i1, !dbg !371
  br i1 %80, label %81, label %85, !dbg !373

81:                                               ; preds = %78
  %82 = load i32, i32* %13, align 4, !dbg !374
  %83 = udiv i32 %82, 2, !dbg !376
  %84 = zext i32 %83 to i64, !dbg !374
  store i64 %84, i64* %12, align 8, !dbg !377
  br label %85, !dbg !378

85:                                               ; preds = %81, %78
  br label %86

86:                                               ; preds = %85, %74
  br label %87, !dbg !379

87:                                               ; preds = %86, %58
  %88 = load i8, i8* %11, align 1, !dbg !380
  %89 = trunc i8 %88 to i1, !dbg !380
  br i1 %89, label %90, label %114, !dbg !382

90:                                               ; preds = %87
  %91 = load i64, i64* %12, align 8, !dbg !383
  %92 = load i64, i64* %3, align 8, !dbg !385
  %93 = add i64 %92, %91, !dbg !385
  store i64 %93, i64* %3, align 8, !dbg !385
  %94 = load i8, i8* %7, align 1, !dbg !386
  %95 = trunc i8 %94 to i1, !dbg !386
  br i1 %95, label %96, label %107, !dbg !388

96:                                               ; preds = %90
  %97 = load i64, i64* %3, align 8, !dbg !389
  %98 = icmp ult i64 %97, 4294967296, !dbg !390
  br i1 %98, label %99, label %107, !dbg !391

99:                                               ; preds = %96
  %100 = load i64, i64* %3, align 8, !dbg !392
  %101 = trunc i64 %100 to i32, !dbg !394
  %102 = load i32, i32* %4, align 4, !dbg !395
  %103 = load i32, i32* %5, align 4, !dbg !396
  %104 = udiv i32 %102, %103, !dbg !397
  %105 = udiv i32 %101, %104, !dbg !398
  %106 = zext i32 %105 to i64, !dbg !399
  store i64 %106, i64* %2, align 8, !dbg !400
  br label %160, !dbg !400

107:                                              ; preds = %96, %90
  %108 = load i64, i64* %3, align 8, !dbg !401
  %109 = load i32, i32* %4, align 4, !dbg !403
  %110 = load i32, i32* %5, align 4, !dbg !404
  %111 = udiv i32 %109, %110, !dbg !405
  %112 = zext i32 %111 to i64, !dbg !406
  %113 = udiv i64 %108, %112, !dbg !407
  store i64 %113, i64* %2, align 8, !dbg !408
  br label %160, !dbg !408

114:                                              ; preds = %87
  %115 = load i8, i8* %10, align 1, !dbg !409
  %116 = trunc i8 %115 to i1, !dbg !409
  br i1 %116, label %117, label %135, !dbg !411

117:                                              ; preds = %114
  %118 = load i8, i8* %7, align 1, !dbg !412
  %119 = trunc i8 %118 to i1, !dbg !412
  br i1 %119, label %120, label %128, !dbg !415

120:                                              ; preds = %117
  %121 = load i64, i64* %3, align 8, !dbg !416
  %122 = trunc i64 %121 to i32, !dbg !418
  %123 = load i32, i32* %5, align 4, !dbg !419
  %124 = load i32, i32* %4, align 4, !dbg !420
  %125 = udiv i32 %123, %124, !dbg !421
  %126 = mul i32 %122, %125, !dbg !422
  %127 = zext i32 %126 to i64, !dbg !423
  store i64 %127, i64* %2, align 8, !dbg !424
  br label %160, !dbg !424

128:                                              ; preds = %117
  %129 = load i64, i64* %3, align 8, !dbg !425
  %130 = load i32, i32* %5, align 4, !dbg !427
  %131 = load i32, i32* %4, align 4, !dbg !428
  %132 = udiv i32 %130, %131, !dbg !429
  %133 = zext i32 %132 to i64, !dbg !430
  %134 = mul i64 %129, %133, !dbg !431
  store i64 %134, i64* %2, align 8, !dbg !432
  br label %160, !dbg !432

135:                                              ; preds = %114
  %136 = load i8, i8* %7, align 1, !dbg !433
  %137 = trunc i8 %136 to i1, !dbg !433
  br i1 %137, label %138, label %150, !dbg !436

138:                                              ; preds = %135
  %139 = load i64, i64* %3, align 8, !dbg !437
  %140 = load i32, i32* %5, align 4, !dbg !439
  %141 = zext i32 %140 to i64, !dbg !439
  %142 = mul i64 %139, %141, !dbg !440
  %143 = load i64, i64* %12, align 8, !dbg !441
  %144 = add i64 %142, %143, !dbg !442
  %145 = load i32, i32* %4, align 4, !dbg !443
  %146 = zext i32 %145 to i64, !dbg !443
  %147 = udiv i64 %144, %146, !dbg !444
  %148 = trunc i64 %147 to i32, !dbg !445
  %149 = zext i32 %148 to i64, !dbg !445
  store i64 %149, i64* %2, align 8, !dbg !446
  br label %160, !dbg !446

150:                                              ; preds = %135
  %151 = load i64, i64* %3, align 8, !dbg !447
  %152 = load i32, i32* %5, align 4, !dbg !449
  %153 = zext i32 %152 to i64, !dbg !449
  %154 = mul i64 %151, %153, !dbg !450
  %155 = load i64, i64* %12, align 8, !dbg !451
  %156 = add i64 %154, %155, !dbg !452
  %157 = load i32, i32* %4, align 4, !dbg !453
  %158 = zext i32 %157 to i64, !dbg !453
  %159 = udiv i64 %156, %158, !dbg !454
  store i64 %159, i64* %2, align 8, !dbg !455
  br label %160, !dbg !455

160:                                              ; preds = %150, %138, %128, %120, %107, %99, %56
  %161 = load i64, i64* %2, align 8, !dbg !456
  ret i64 %161, !dbg !457
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_sleep([1 x i64]) #0 !dbg !458 {
  %2 = alloca %struct.k_timeout_t, align 8
  %3 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0
  %4 = bitcast i64* %3 to [1 x i64]*
  store [1 x i64] %0, [1 x i64]* %4, align 8
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %2, metadata !465, metadata !DIExpression()), !dbg !466
  br label %5, !dbg !467

5:                                                ; preds = %1
  call void asm sideeffect "", "~{memory}"() #4, !dbg !468, !srcloc !470
  br label %6, !dbg !468

6:                                                ; preds = %5
  %7 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !471
  %8 = bitcast i64* %7 to [1 x i64]*, !dbg !471
  %9 = load [1 x i64], [1 x i64]* %8, align 8, !dbg !471
  %10 = call i32 @z_impl_k_sleep([1 x i64] %9) #3, !dbg !471
  ret i32 %10, !dbg !472
}

declare dso_local i32 @z_impl_k_sleep([1 x i64]) #2

declare dso_local %struct.k_thread* @z_impl_k_current_get(...) #2

; Function Attrs: noinline nounwind optnone
define dso_local void @threadB(i8*, i8*, i8*) #0 !dbg !473 {
  %4 = alloca i8*, align 4
  %5 = alloca i8*, align 4
  %6 = alloca i8*, align 4
  store i8* %0, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !476, metadata !DIExpression()), !dbg !477
  store i8* %1, i8** %5, align 4
  call void @llvm.dbg.declare(metadata i8** %5, metadata !478, metadata !DIExpression()), !dbg !479
  store i8* %2, i8** %6, align 4
  call void @llvm.dbg.declare(metadata i8** %6, metadata !480, metadata !DIExpression()), !dbg !481
  %7 = load i8*, i8** %4, align 4, !dbg !482
  %8 = load i8*, i8** %5, align 4, !dbg !483
  %9 = load i8*, i8** %6, align 4, !dbg !484
  call void @helloLoop(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__func__.threadB, i32 0, i32 0), %struct.k_sem* getelementptr inbounds (%struct.sys_sem, %struct.sys_sem* @threadB_sem, i32 0, i32 0), %struct.k_sem* getelementptr inbounds (%struct.sys_sem, %struct.sys_sem* @threadA_sem, i32 0, i32 0)) #3, !dbg !485
  ret void, !dbg !486
}

; Function Attrs: noinline nounwind optnone
define dso_local void @threadA(i8*, i8*, i8*) #0 !dbg !487 {
  %4 = alloca i8*, align 4
  %5 = alloca i8*, align 4
  %6 = alloca i8*, align 4
  %7 = alloca %struct.k_thread*, align 4
  %8 = alloca %struct.k_thread*, align 4
  %9 = alloca %struct.k_timeout_t, align 8
  store i8* %0, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !488, metadata !DIExpression()), !dbg !489
  store i8* %1, i8** %5, align 4
  call void @llvm.dbg.declare(metadata i8** %5, metadata !490, metadata !DIExpression()), !dbg !491
  store i8* %2, i8** %6, align 4
  call void @llvm.dbg.declare(metadata i8** %6, metadata !492, metadata !DIExpression()), !dbg !493
  %10 = load i8*, i8** %4, align 4, !dbg !494
  %11 = load i8*, i8** %5, align 4, !dbg !495
  %12 = load i8*, i8** %6, align 4, !dbg !496
  call void @llvm.dbg.declare(metadata %struct.k_thread** %7, metadata !497, metadata !DIExpression()), !dbg !498
  store %struct.k_thread* @threadB_data, %struct.k_thread** %7, align 4, !dbg !498
  %13 = call i32 @sys_sem_init(%struct.sys_sem* @threadA_sem, i32 1, i32 1) #3, !dbg !499
  %14 = call i32 @sys_sem_init(%struct.sys_sem* @threadB_sem, i32 0, i32 1) #3, !dbg !500
  call void @llvm.dbg.declare(metadata %struct.k_thread** %8, metadata !501, metadata !DIExpression()), !dbg !502
  %15 = load %struct.k_thread*, %struct.k_thread** %7, align 4, !dbg !503
  %16 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %9, i32 0, i32 0, !dbg !504
  store i64 0, i64* %16, align 8, !dbg !504
  %17 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %9, i32 0, i32 0, !dbg !505
  %18 = bitcast i64* %17 to [1 x i64]*, !dbg !505
  %19 = load [1 x i64], [1 x i64]* %18, align 8, !dbg !505
  %20 = call %struct.k_thread* @k_thread_create(%struct.k_thread* %15, %struct.z_thread_stack_element* getelementptr inbounds ([1024 x %struct.z_thread_stack_element], [1024 x %struct.z_thread_stack_element]* @threadB_stack_area, i32 0, i32 0), i32 1024, void (i8*, i8*, i8*)* @threadB, i8* null, i8* null, i8* null, i32 7, i32 0, [1 x i64] %19) #3, !dbg !505
  store %struct.k_thread* %20, %struct.k_thread** %8, align 4, !dbg !502
  %21 = load %struct.k_thread*, %struct.k_thread** %8, align 4, !dbg !506
  %22 = call i32 @k_thread_name_set(%struct.k_thread* %21, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.2, i32 0, i32 0)) #3, !dbg !507
  call void @helloLoop(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__func__.threadA, i32 0, i32 0), %struct.k_sem* getelementptr inbounds (%struct.sys_sem, %struct.sys_sem* @threadA_sem, i32 0, i32 0), %struct.k_sem* getelementptr inbounds (%struct.sys_sem, %struct.sys_sem* @threadB_sem, i32 0, i32 0)) #3, !dbg !508
  ret void, !dbg !509
}

declare dso_local i32 @sys_sem_init(%struct.sys_sem*, i32, i32) #2

; Function Attrs: noinline nounwind optnone
define internal %struct.k_thread* @k_thread_create(%struct.k_thread*, %struct.z_thread_stack_element*, i32, void (i8*, i8*, i8*)*, i8*, i8*, i8*, i32, i32, [1 x i64]) #0 !dbg !510 {
  %11 = alloca %struct.k_timeout_t, align 8
  %12 = alloca %struct.k_thread*, align 4
  %13 = alloca %struct.z_thread_stack_element*, align 4
  %14 = alloca i32, align 4
  %15 = alloca void (i8*, i8*, i8*)*, align 4
  %16 = alloca i8*, align 4
  %17 = alloca i8*, align 4
  %18 = alloca i8*, align 4
  %19 = alloca i32, align 4
  %20 = alloca i32, align 4
  %21 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %11, i32 0, i32 0
  %22 = bitcast i64* %21 to [1 x i64]*
  store [1 x i64] %9, [1 x i64]* %22, align 8
  store %struct.k_thread* %0, %struct.k_thread** %12, align 4
  call void @llvm.dbg.declare(metadata %struct.k_thread** %12, metadata !518, metadata !DIExpression()), !dbg !519
  store %struct.z_thread_stack_element* %1, %struct.z_thread_stack_element** %13, align 4
  call void @llvm.dbg.declare(metadata %struct.z_thread_stack_element** %13, metadata !520, metadata !DIExpression()), !dbg !521
  store i32 %2, i32* %14, align 4
  call void @llvm.dbg.declare(metadata i32* %14, metadata !522, metadata !DIExpression()), !dbg !523
  store void (i8*, i8*, i8*)* %3, void (i8*, i8*, i8*)** %15, align 4
  call void @llvm.dbg.declare(metadata void (i8*, i8*, i8*)** %15, metadata !524, metadata !DIExpression()), !dbg !525
  store i8* %4, i8** %16, align 4
  call void @llvm.dbg.declare(metadata i8** %16, metadata !526, metadata !DIExpression()), !dbg !527
  store i8* %5, i8** %17, align 4
  call void @llvm.dbg.declare(metadata i8** %17, metadata !528, metadata !DIExpression()), !dbg !529
  store i8* %6, i8** %18, align 4
  call void @llvm.dbg.declare(metadata i8** %18, metadata !530, metadata !DIExpression()), !dbg !531
  store i32 %7, i32* %19, align 4
  call void @llvm.dbg.declare(metadata i32* %19, metadata !532, metadata !DIExpression()), !dbg !533
  store i32 %8, i32* %20, align 4
  call void @llvm.dbg.declare(metadata i32* %20, metadata !534, metadata !DIExpression()), !dbg !535
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %11, metadata !536, metadata !DIExpression()), !dbg !537
  br label %23, !dbg !538

23:                                               ; preds = %10
  call void asm sideeffect "", "~{memory}"() #4, !dbg !539, !srcloc !541
  br label %24, !dbg !539

24:                                               ; preds = %23
  %25 = load %struct.k_thread*, %struct.k_thread** %12, align 4, !dbg !542
  %26 = load %struct.z_thread_stack_element*, %struct.z_thread_stack_element** %13, align 4, !dbg !543
  %27 = load i32, i32* %14, align 4, !dbg !544
  %28 = load void (i8*, i8*, i8*)*, void (i8*, i8*, i8*)** %15, align 4, !dbg !545
  %29 = load i8*, i8** %16, align 4, !dbg !546
  %30 = load i8*, i8** %17, align 4, !dbg !547
  %31 = load i8*, i8** %18, align 4, !dbg !548
  %32 = load i32, i32* %19, align 4, !dbg !549
  %33 = load i32, i32* %20, align 4, !dbg !550
  %34 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %11, i32 0, i32 0, !dbg !551
  %35 = bitcast i64* %34 to [1 x i64]*, !dbg !551
  %36 = load [1 x i64], [1 x i64]* %35, align 8, !dbg !551
  %37 = call %struct.k_thread* @z_impl_k_thread_create(%struct.k_thread* %25, %struct.z_thread_stack_element* %26, i32 %27, void (i8*, i8*, i8*)* %28, i8* %29, i8* %30, i8* %31, i32 %32, i32 %33, [1 x i64] %36) #3, !dbg !551
  ret %struct.k_thread* %37, !dbg !552
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_thread_name_set(%struct.k_thread*, i8*) #0 !dbg !553 {
  %3 = alloca %struct.k_thread*, align 4
  %4 = alloca i8*, align 4
  store %struct.k_thread* %0, %struct.k_thread** %3, align 4
  call void @llvm.dbg.declare(metadata %struct.k_thread** %3, metadata !556, metadata !DIExpression()), !dbg !557
  store i8* %1, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !558, metadata !DIExpression()), !dbg !559
  br label %5, !dbg !560

5:                                                ; preds = %2
  call void asm sideeffect "", "~{memory}"() #4, !dbg !561, !srcloc !563
  br label %6, !dbg !561

6:                                                ; preds = %5
  %7 = load %struct.k_thread*, %struct.k_thread** %3, align 4, !dbg !564
  %8 = load i8*, i8** %4, align 4, !dbg !565
  %9 = call i32 @z_impl_k_thread_name_set(%struct.k_thread* %7, i8* %8) #3, !dbg !566
  ret i32 %9, !dbg !567
}

declare dso_local i32 @z_impl_k_thread_name_set(%struct.k_thread*, i8*) #2

declare dso_local %struct.k_thread* @z_impl_k_thread_create(%struct.k_thread*, %struct.z_thread_stack_element*, i32, void (i8*, i8*, i8*)*, i8*, i8*, i8*, i32, i32, [1 x i64]) #2

; Function Attrs: noinline nounwind optnone
define dso_local void @main() #0 !dbg !568 {
  %1 = alloca %struct.k_thread*, align 4
  %2 = alloca %struct.k_timeout_t, align 8
  call void @llvm.dbg.declare(metadata %struct.k_thread** %1, metadata !569, metadata !DIExpression()), !dbg !570
  %3 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !571
  store i64 0, i64* %3, align 8, !dbg !571
  %4 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !572
  %5 = bitcast i64* %4 to [1 x i64]*, !dbg !572
  %6 = load [1 x i64], [1 x i64]* %5, align 8, !dbg !572
  %7 = call %struct.k_thread* @k_thread_create(%struct.k_thread* @threadA_data, %struct.z_thread_stack_element* getelementptr inbounds ([1024 x %struct.z_thread_stack_element], [1024 x %struct.z_thread_stack_element]* @threadA_stack_area, i32 0, i32 0), i32 1024, void (i8*, i8*, i8*)* @threadA, i8* null, i8* null, i8* null, i32 7, i32 0, [1 x i64] %6) #3, !dbg !572
  store %struct.k_thread* %7, %struct.k_thread** %1, align 4, !dbg !570
  %8 = load %struct.k_thread*, %struct.k_thread** %1, align 4, !dbg !573
  %9 = call i32 @k_thread_name_set(%struct.k_thread* %8, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.3, i32 0, i32 0)) #3, !dbg !574
  ret void, !dbg !575
}

attributes #0 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #1 = { nounwind readnone speculatable }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #3 = { nobuiltin }
attributes #4 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.ident = !{!218}
!llvm.module.flags = !{!219, !220, !221, !222}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "threadB_sem", scope: !2, file: !65, line: 40, type: !66, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !52, globals: !62, nameTableKind: None)
!3 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/dyn_sys_sems/src/main.c", directory: "/home/kenny/ara/build/appl/Zephyr/dyn_sys_sems")
!4 = !{!5}
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
!52 = !{!53, !58, !59, !60}
!53 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_ticks_t", file: !54, line: 46, baseType: !55)
!54 = !DIFile(filename: "zephyrproject/zephyr/include/sys_clock.h", directory: "/home/kenny")
!55 = !DIDerivedType(tag: DW_TAG_typedef, name: "int64_t", file: !56, line: 43, baseType: !57)
!56 = !DIFile(filename: "zephyrproject/zephyr/lib/libc/minimal/include/stdint.h", directory: "/home/kenny")
!57 = !DIBasicType(name: "long long int", size: 64, encoding: DW_ATE_signed)
!58 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 32)
!59 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!60 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !56, line: 57, baseType: !61)
!61 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!62 = !{!63, !0, !95, !105, !214, !216}
!63 = !DIGlobalVariableExpression(var: !64, expr: !DIExpression())
!64 = distinct !DIGlobalVariable(name: "threadA_sem", scope: !2, file: !65, line: 40, type: !66, isLocal: false, isDefinition: true)
!65 = !DIFile(filename: "appl/Zephyr/dyn_sys_sems/src/main.c", directory: "/home/kenny/ara")
!66 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "sys_sem", file: !67, line: 33, size: 128, elements: !68)
!67 = !DIFile(filename: "zephyrproject/zephyr/include/sys/sem.h", directory: "/home/kenny")
!68 = !{!69}
!69 = !DIDerivedType(tag: DW_TAG_member, name: "kernel_sem", scope: !66, file: !67, line: 38, baseType: !70, size: 128)
!70 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_sem", file: !6, line: 3704, size: 128, elements: !71)
!71 = !{!72, !93, !94}
!72 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !70, file: !6, line: 3705, baseType: !73, size: 64)
!73 = !DIDerivedType(tag: DW_TAG_typedef, name: "_wait_q_t", file: !74, line: 210, baseType: !75)
!74 = !DIFile(filename: "zephyrproject/zephyr/include/kernel_structs.h", directory: "/home/kenny")
!75 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !74, line: 208, size: 64, elements: !76)
!76 = !{!77}
!77 = !DIDerivedType(tag: DW_TAG_member, name: "waitq", scope: !75, file: !74, line: 209, baseType: !78, size: 64)
!78 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dlist_t", file: !79, line: 42, baseType: !80)
!79 = !DIFile(filename: "zephyrproject/zephyr/include/sys/dlist.h", directory: "/home/kenny")
!80 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_dnode", file: !79, line: 31, size: 64, elements: !81)
!81 = !{!82, !88}
!82 = !DIDerivedType(tag: DW_TAG_member, scope: !80, file: !79, line: 32, baseType: !83, size: 32)
!83 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !80, file: !79, line: 32, size: 32, elements: !84)
!84 = !{!85, !87}
!85 = !DIDerivedType(tag: DW_TAG_member, name: "head", scope: !83, file: !79, line: 33, baseType: !86, size: 32)
!86 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !80, size: 32)
!87 = !DIDerivedType(tag: DW_TAG_member, name: "next", scope: !83, file: !79, line: 34, baseType: !86, size: 32)
!88 = !DIDerivedType(tag: DW_TAG_member, scope: !80, file: !79, line: 36, baseType: !89, size: 32, offset: 32)
!89 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !80, file: !79, line: 36, size: 32, elements: !90)
!90 = !{!91, !92}
!91 = !DIDerivedType(tag: DW_TAG_member, name: "tail", scope: !89, file: !79, line: 37, baseType: !86, size: 32)
!92 = !DIDerivedType(tag: DW_TAG_member, name: "prev", scope: !89, file: !79, line: 38, baseType: !86, size: 32)
!93 = !DIDerivedType(tag: DW_TAG_member, name: "count", scope: !70, file: !6, line: 3706, baseType: !60, size: 32, offset: 64)
!94 = !DIDerivedType(tag: DW_TAG_member, name: "limit", scope: !70, file: !6, line: 3707, baseType: !60, size: 32, offset: 96)
!95 = !DIGlobalVariableExpression(var: !96, expr: !DIExpression())
!96 = distinct !DIGlobalVariable(name: "threadB_stack_area", scope: !2, file: !65, line: 51, type: !97, isLocal: false, isDefinition: true, align: 64)
!97 = !DICompositeType(tag: DW_TAG_array_type, baseType: !98, size: 8192, elements: !103)
!98 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "z_thread_stack_element", file: !99, line: 35, size: 8, elements: !100)
!99 = !DIFile(filename: "zephyrproject/zephyr/include/sys/thread_stack.h", directory: "/home/kenny")
!100 = !{!101}
!101 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !98, file: !99, line: 36, baseType: !102, size: 8)
!102 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_unsigned_char)
!103 = !{!104}
!104 = !DISubrange(count: 1024)
!105 = !DIGlobalVariableExpression(var: !106, expr: !DIExpression())
!106 = distinct !DIGlobalVariable(name: "threadB_data", scope: !2, file: !65, line: 52, type: !107, isLocal: true, isDefinition: true)
!107 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_thread", file: !6, line: 570, size: 1024, elements: !108)
!108 = !{!109, !158, !171, !172, !176, !177, !187, !209}
!109 = !DIDerivedType(tag: DW_TAG_member, name: "base", scope: !107, file: !6, line: 572, baseType: !110, size: 448)
!110 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_base", file: !6, line: 441, size: 448, elements: !111)
!111 = !{!112, !126, !128, !130, !131, !144, !145, !146, !157}
!112 = !DIDerivedType(tag: DW_TAG_member, scope: !110, file: !6, line: 444, baseType: !113, size: 64)
!113 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !110, file: !6, line: 444, size: 64, elements: !114)
!114 = !{!115, !117}
!115 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_dlist", scope: !113, file: !6, line: 445, baseType: !116, size: 64)
!116 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dnode_t", file: !79, line: 43, baseType: !80)
!117 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_rb", scope: !113, file: !6, line: 446, baseType: !118, size: 64)
!118 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "rbnode", file: !119, line: 48, size: 64, elements: !120)
!119 = !DIFile(filename: "zephyrproject/zephyr/include/sys/rb.h", directory: "/home/kenny")
!120 = !{!121}
!121 = !DIDerivedType(tag: DW_TAG_member, name: "children", scope: !118, file: !119, line: 49, baseType: !122, size: 64)
!122 = !DICompositeType(tag: DW_TAG_array_type, baseType: !123, size: 64, elements: !124)
!123 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !118, size: 32)
!124 = !{!125}
!125 = !DISubrange(count: 2)
!126 = !DIDerivedType(tag: DW_TAG_member, name: "pended_on", scope: !110, file: !6, line: 452, baseType: !127, size: 32, offset: 64)
!127 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !73, size: 32)
!128 = !DIDerivedType(tag: DW_TAG_member, name: "user_options", scope: !110, file: !6, line: 455, baseType: !129, size: 8, offset: 96)
!129 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !56, line: 55, baseType: !7)
!130 = !DIDerivedType(tag: DW_TAG_member, name: "thread_state", scope: !110, file: !6, line: 458, baseType: !129, size: 8, offset: 104)
!131 = !DIDerivedType(tag: DW_TAG_member, scope: !110, file: !6, line: 474, baseType: !132, size: 16, offset: 112)
!132 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !110, file: !6, line: 474, size: 16, elements: !133)
!133 = !{!134, !141}
!134 = !DIDerivedType(tag: DW_TAG_member, scope: !132, file: !6, line: 475, baseType: !135, size: 16)
!135 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !132, file: !6, line: 475, size: 16, elements: !136)
!136 = !{!137, !140}
!137 = !DIDerivedType(tag: DW_TAG_member, name: "prio", scope: !135, file: !6, line: 480, baseType: !138, size: 8)
!138 = !DIDerivedType(tag: DW_TAG_typedef, name: "int8_t", file: !56, line: 40, baseType: !139)
!139 = !DIBasicType(name: "signed char", size: 8, encoding: DW_ATE_signed_char)
!140 = !DIDerivedType(tag: DW_TAG_member, name: "sched_locked", scope: !135, file: !6, line: 481, baseType: !129, size: 8, offset: 8)
!141 = !DIDerivedType(tag: DW_TAG_member, name: "preempt", scope: !132, file: !6, line: 484, baseType: !142, size: 16)
!142 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !56, line: 56, baseType: !143)
!143 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!144 = !DIDerivedType(tag: DW_TAG_member, name: "order_key", scope: !110, file: !6, line: 491, baseType: !60, size: 32, offset: 128)
!145 = !DIDerivedType(tag: DW_TAG_member, name: "swap_data", scope: !110, file: !6, line: 511, baseType: !58, size: 32, offset: 160)
!146 = !DIDerivedType(tag: DW_TAG_member, name: "timeout", scope: !110, file: !6, line: 515, baseType: !147, size: 192, offset: 192)
!147 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_timeout", file: !74, line: 221, size: 192, elements: !148)
!148 = !{!149, !150, !156}
!149 = !DIDerivedType(tag: DW_TAG_member, name: "node", scope: !147, file: !74, line: 222, baseType: !116, size: 64)
!150 = !DIDerivedType(tag: DW_TAG_member, name: "fn", scope: !147, file: !74, line: 223, baseType: !151, size: 32, offset: 64)
!151 = !DIDerivedType(tag: DW_TAG_typedef, name: "_timeout_func_t", file: !74, line: 219, baseType: !152)
!152 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !153, size: 32)
!153 = !DISubroutineType(types: !154)
!154 = !{null, !155}
!155 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !147, size: 32)
!156 = !DIDerivedType(tag: DW_TAG_member, name: "dticks", scope: !147, file: !74, line: 226, baseType: !55, size: 64, offset: 128)
!157 = !DIDerivedType(tag: DW_TAG_member, name: "join_waiters", scope: !110, file: !6, line: 518, baseType: !73, size: 64, offset: 384)
!158 = !DIDerivedType(tag: DW_TAG_member, name: "callee_saved", scope: !107, file: !6, line: 575, baseType: !159, size: 288, offset: 448)
!159 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_callee_saved", file: !160, line: 25, size: 288, elements: !161)
!160 = !DIFile(filename: "zephyrproject/zephyr/include/arch/arm/aarch32/thread.h", directory: "/home/kenny")
!161 = !{!162, !163, !164, !165, !166, !167, !168, !169, !170}
!162 = !DIDerivedType(tag: DW_TAG_member, name: "v1", scope: !159, file: !160, line: 26, baseType: !60, size: 32)
!163 = !DIDerivedType(tag: DW_TAG_member, name: "v2", scope: !159, file: !160, line: 27, baseType: !60, size: 32, offset: 32)
!164 = !DIDerivedType(tag: DW_TAG_member, name: "v3", scope: !159, file: !160, line: 28, baseType: !60, size: 32, offset: 64)
!165 = !DIDerivedType(tag: DW_TAG_member, name: "v4", scope: !159, file: !160, line: 29, baseType: !60, size: 32, offset: 96)
!166 = !DIDerivedType(tag: DW_TAG_member, name: "v5", scope: !159, file: !160, line: 30, baseType: !60, size: 32, offset: 128)
!167 = !DIDerivedType(tag: DW_TAG_member, name: "v6", scope: !159, file: !160, line: 31, baseType: !60, size: 32, offset: 160)
!168 = !DIDerivedType(tag: DW_TAG_member, name: "v7", scope: !159, file: !160, line: 32, baseType: !60, size: 32, offset: 192)
!169 = !DIDerivedType(tag: DW_TAG_member, name: "v8", scope: !159, file: !160, line: 33, baseType: !60, size: 32, offset: 224)
!170 = !DIDerivedType(tag: DW_TAG_member, name: "psp", scope: !159, file: !160, line: 34, baseType: !60, size: 32, offset: 256)
!171 = !DIDerivedType(tag: DW_TAG_member, name: "init_data", scope: !107, file: !6, line: 578, baseType: !58, size: 32, offset: 736)
!172 = !DIDerivedType(tag: DW_TAG_member, name: "fn_abort", scope: !107, file: !6, line: 583, baseType: !173, size: 32, offset: 768)
!173 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !174, size: 32)
!174 = !DISubroutineType(types: !175)
!175 = !{null}
!176 = !DIDerivedType(tag: DW_TAG_member, name: "errno_var", scope: !107, file: !6, line: 610, baseType: !59, size: 32, offset: 800)
!177 = !DIDerivedType(tag: DW_TAG_member, name: "stack_info", scope: !107, file: !6, line: 616, baseType: !178, size: 96, offset: 832)
!178 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_stack_info", file: !6, line: 525, size: 96, elements: !179)
!179 = !{!180, !183, !186}
!180 = !DIDerivedType(tag: DW_TAG_member, name: "start", scope: !178, file: !6, line: 529, baseType: !181, size: 32)
!181 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintptr_t", file: !56, line: 71, baseType: !182)
!182 = !DIBasicType(name: "long unsigned int", size: 32, encoding: DW_ATE_unsigned)
!183 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !178, file: !6, line: 538, baseType: !184, size: 32, offset: 32)
!184 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !185, line: 46, baseType: !61)
!185 = !DIFile(filename: "/usr/lib/llvm-9/lib/clang/9.0.1/include/stddef.h", directory: "")
!186 = !DIDerivedType(tag: DW_TAG_member, name: "delta", scope: !178, file: !6, line: 544, baseType: !184, size: 32, offset: 64)
!187 = !DIDerivedType(tag: DW_TAG_member, name: "resource_pool", scope: !107, file: !6, line: 641, baseType: !188, size: 32, offset: 928)
!188 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !189, size: 32)
!189 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mem_pool", file: !190, line: 30, size: 32, elements: !191)
!190 = !DIFile(filename: "zephyrproject/zephyr/include/mempool_heap.h", directory: "/home/kenny")
!191 = !{!192}
!192 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !189, file: !190, line: 31, baseType: !193, size: 32)
!193 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !194, size: 32)
!194 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_heap", file: !74, line: 267, size: 160, elements: !195)
!195 = !{!196, !205, !206}
!196 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !194, file: !74, line: 268, baseType: !197, size: 96)
!197 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "sys_heap", file: !198, line: 51, size: 96, elements: !199)
!198 = !DIFile(filename: "zephyrproject/zephyr/include/sys/sys_heap.h", directory: "/home/kenny")
!199 = !{!200, !203, !204}
!200 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !197, file: !198, line: 52, baseType: !201, size: 32)
!201 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !202, size: 32)
!202 = !DICompositeType(tag: DW_TAG_structure_type, name: "z_heap", file: !198, line: 52, flags: DIFlagFwdDecl)
!203 = !DIDerivedType(tag: DW_TAG_member, name: "init_mem", scope: !197, file: !198, line: 53, baseType: !58, size: 32, offset: 32)
!204 = !DIDerivedType(tag: DW_TAG_member, name: "init_bytes", scope: !197, file: !198, line: 54, baseType: !184, size: 32, offset: 64)
!205 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !194, file: !74, line: 269, baseType: !73, size: 64, offset: 96)
!206 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !194, file: !74, line: 270, baseType: !207, offset: 160)
!207 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_spinlock", file: !74, line: 234, elements: !208)
!208 = !{}
!209 = !DIDerivedType(tag: DW_TAG_member, name: "arch", scope: !107, file: !6, line: 644, baseType: !210, size: 64, offset: 960)
!210 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_arch", file: !160, line: 60, size: 64, elements: !211)
!211 = !{!212, !213}
!212 = !DIDerivedType(tag: DW_TAG_member, name: "basepri", scope: !210, file: !160, line: 63, baseType: !60, size: 32)
!213 = !DIDerivedType(tag: DW_TAG_member, name: "swap_return_value", scope: !210, file: !160, line: 66, baseType: !60, size: 32, offset: 32)
!214 = !DIGlobalVariableExpression(var: !215, expr: !DIExpression())
!215 = distinct !DIGlobalVariable(name: "threadA_stack_area", scope: !2, file: !65, line: 74, type: !97, isLocal: false, isDefinition: true, align: 64)
!216 = !DIGlobalVariableExpression(var: !217, expr: !DIExpression())
!217 = distinct !DIGlobalVariable(name: "threadA_data", scope: !2, file: !65, line: 75, type: !107, isLocal: false, isDefinition: true)
!218 = !{!"clang version 9.0.1-12 "}
!219 = !{i32 2, !"Dwarf Version", i32 4}
!220 = !{i32 2, !"Debug Info Version", i32 3}
!221 = !{i32 1, !"wchar_size", i32 4}
!222 = !{i32 1, !"min_enum_size", i32 1}
!223 = distinct !DISubprogram(name: "helloLoop", scope: !65, file: !65, line: 18, type: !224, scopeLine: 20, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !208)
!224 = !DISubroutineType(types: !225)
!225 = !{null, !226, !228, !228}
!226 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !227, size: 32)
!227 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !102)
!228 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !70, size: 32)
!229 = !DILocalVariable(name: "my_name", arg: 1, scope: !223, file: !65, line: 18, type: !226)
!230 = !DILocation(line: 18, column: 28, scope: !223)
!231 = !DILocalVariable(name: "my_sem", arg: 2, scope: !223, file: !65, line: 19, type: !228)
!232 = !DILocation(line: 19, column: 23, scope: !223)
!233 = !DILocalVariable(name: "other_sem", arg: 3, scope: !223, file: !65, line: 19, type: !228)
!234 = !DILocation(line: 19, column: 45, scope: !223)
!235 = !DILocalVariable(name: "tname", scope: !223, file: !65, line: 21, type: !226)
!236 = !DILocation(line: 21, column: 17, scope: !223)
!237 = !DILocation(line: 23, column: 5, scope: !223)
!238 = !DILocation(line: 24, column: 22, scope: !239)
!239 = distinct !DILexicalBlock(scope: !223, file: !65, line: 23, column: 15)
!240 = !DILocation(line: 24, column: 30, scope: !239)
!241 = !DILocation(line: 24, column: 9, scope: !239)
!242 = !DILocation(line: 26, column: 35, scope: !239)
!243 = !DILocation(line: 26, column: 17, scope: !239)
!244 = !DILocation(line: 26, column: 15, scope: !239)
!245 = !DILocation(line: 27, column: 13, scope: !246)
!246 = distinct !DILexicalBlock(scope: !239, file: !65, line: 27, column: 13)
!247 = !DILocation(line: 27, column: 19, scope: !246)
!248 = !DILocation(line: 27, column: 27, scope: !246)
!249 = !DILocation(line: 27, column: 30, scope: !246)
!250 = !DILocation(line: 27, column: 39, scope: !246)
!251 = !DILocation(line: 27, column: 13, scope: !239)
!252 = !DILocation(line: 29, column: 25, scope: !253)
!253 = distinct !DILexicalBlock(scope: !246, file: !65, line: 27, column: 48)
!254 = !DILocation(line: 28, column: 13, scope: !253)
!255 = !DILocation(line: 30, column: 9, scope: !253)
!256 = !DILocation(line: 32, column: 21, scope: !257)
!257 = distinct !DILexicalBlock(scope: !246, file: !65, line: 30, column: 16)
!258 = !DILocation(line: 31, column: 13, scope: !257)
!259 = !DILocation(line: 35, column: 9, scope: !239)
!260 = !DILocation(line: 36, column: 22, scope: !239)
!261 = !DILocation(line: 36, column: 9, scope: !239)
!262 = distinct !{!262, !237, !263}
!263 = !DILocation(line: 37, column: 5, scope: !223)
!264 = distinct !DISubprogram(name: "k_current_get", scope: !265, file: !265, line: 187, type: !266, scopeLine: 188, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !208)
!265 = !DIFile(filename: "zephyr/include/generated/syscalls/kernel.h", directory: "/home/kenny/ara/build/appl/Zephyr/dyn_sys_sems")
!266 = !DISubroutineType(types: !267)
!267 = !{!268}
!268 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_tid_t", file: !6, line: 648, baseType: !269)
!269 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !107, size: 32)
!270 = !DILocation(line: 194, column: 2, scope: !264)
!271 = !DILocation(line: 194, column: 2, scope: !272)
!272 = distinct !DILexicalBlock(scope: !264, file: !265, line: 194, column: 2)
!273 = !{i32 -2141856736}
!274 = !DILocation(line: 195, column: 9, scope: !264)
!275 = !DILocation(line: 195, column: 2, scope: !264)
!276 = distinct !DISubprogram(name: "k_msleep", scope: !6, file: !6, line: 957, type: !277, scopeLine: 958, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !208)
!277 = !DISubroutineType(types: !278)
!278 = !{!279, !279}
!279 = !DIDerivedType(tag: DW_TAG_typedef, name: "int32_t", file: !56, line: 42, baseType: !59)
!280 = !DILocalVariable(name: "ms", arg: 1, scope: !276, file: !6, line: 957, type: !279)
!281 = !DILocation(line: 957, column: 40, scope: !276)
!282 = !DILocation(line: 959, column: 17, scope: !276)
!283 = !DILocation(line: 959, column: 9, scope: !276)
!284 = !DILocation(line: 959, column: 2, scope: !276)
!285 = distinct !DISubprogram(name: "k_ms_to_ticks_ceil64", scope: !286, file: !286, line: 369, type: !287, scopeLine: 370, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !208)
!286 = !DIFile(filename: "zephyrproject/zephyr/include/sys/time_units.h", directory: "/home/kenny")
!287 = !DISubroutineType(types: !288)
!288 = !{!289, !289}
!289 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint64_t", file: !56, line: 58, baseType: !290)
!290 = !DIBasicType(name: "long long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!291 = !DILocalVariable(name: "t", arg: 1, scope: !292, file: !286, line: 78, type: !289)
!292 = distinct !DISubprogram(name: "z_tmcvt", scope: !286, file: !286, line: 78, type: !293, scopeLine: 82, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !208)
!293 = !DISubroutineType(types: !294)
!294 = !{!289, !289, !60, !60, !295, !295, !295, !295}
!295 = !DIBasicType(name: "_Bool", size: 8, encoding: DW_ATE_boolean)
!296 = !DILocation(line: 78, column: 63, scope: !292, inlinedAt: !297)
!297 = distinct !DILocation(line: 372, column: 9, scope: !285)
!298 = !DILocalVariable(name: "from_hz", arg: 2, scope: !292, file: !286, line: 78, type: !60)
!299 = !DILocation(line: 78, column: 75, scope: !292, inlinedAt: !297)
!300 = !DILocalVariable(name: "to_hz", arg: 3, scope: !292, file: !286, line: 79, type: !60)
!301 = !DILocation(line: 79, column: 18, scope: !292, inlinedAt: !297)
!302 = !DILocalVariable(name: "const_hz", arg: 4, scope: !292, file: !286, line: 79, type: !295)
!303 = !DILocation(line: 79, column: 30, scope: !292, inlinedAt: !297)
!304 = !DILocalVariable(name: "result32", arg: 5, scope: !292, file: !286, line: 80, type: !295)
!305 = !DILocation(line: 80, column: 14, scope: !292, inlinedAt: !297)
!306 = !DILocalVariable(name: "round_up", arg: 6, scope: !292, file: !286, line: 80, type: !295)
!307 = !DILocation(line: 80, column: 29, scope: !292, inlinedAt: !297)
!308 = !DILocalVariable(name: "round_off", arg: 7, scope: !292, file: !286, line: 81, type: !295)
!309 = !DILocation(line: 81, column: 14, scope: !292, inlinedAt: !297)
!310 = !DILocalVariable(name: "mul_ratio", scope: !292, file: !286, line: 84, type: !295)
!311 = !DILocation(line: 84, column: 7, scope: !292, inlinedAt: !297)
!312 = !DILocalVariable(name: "div_ratio", scope: !292, file: !286, line: 86, type: !295)
!313 = !DILocation(line: 86, column: 7, scope: !292, inlinedAt: !297)
!314 = !DILocalVariable(name: "off", scope: !292, file: !286, line: 93, type: !289)
!315 = !DILocation(line: 93, column: 11, scope: !292, inlinedAt: !297)
!316 = !DILocalVariable(name: "rdivisor", scope: !317, file: !286, line: 96, type: !60)
!317 = distinct !DILexicalBlock(scope: !318, file: !286, line: 95, column: 18)
!318 = distinct !DILexicalBlock(scope: !292, file: !286, line: 95, column: 6)
!319 = !DILocation(line: 96, column: 12, scope: !317, inlinedAt: !297)
!320 = !DILocalVariable(name: "t", arg: 1, scope: !285, file: !286, line: 369, type: !289)
!321 = !DILocation(line: 369, column: 69, scope: !285)
!322 = !DILocation(line: 372, column: 17, scope: !285)
!323 = !DILocation(line: 84, column: 19, scope: !292, inlinedAt: !297)
!324 = !DILocation(line: 84, column: 28, scope: !292, inlinedAt: !297)
!325 = !DILocation(line: 85, column: 4, scope: !292, inlinedAt: !297)
!326 = !DILocation(line: 85, column: 12, scope: !292, inlinedAt: !297)
!327 = !DILocation(line: 85, column: 10, scope: !292, inlinedAt: !297)
!328 = !DILocation(line: 85, column: 21, scope: !292, inlinedAt: !297)
!329 = !DILocation(line: 85, column: 26, scope: !292, inlinedAt: !297)
!330 = !DILocation(line: 85, column: 34, scope: !292, inlinedAt: !297)
!331 = !DILocation(line: 85, column: 32, scope: !292, inlinedAt: !297)
!332 = !DILocation(line: 85, column: 43, scope: !292, inlinedAt: !297)
!333 = !DILocation(line: 0, scope: !292, inlinedAt: !297)
!334 = !DILocation(line: 86, column: 19, scope: !292, inlinedAt: !297)
!335 = !DILocation(line: 86, column: 28, scope: !292, inlinedAt: !297)
!336 = !DILocation(line: 87, column: 4, scope: !292, inlinedAt: !297)
!337 = !DILocation(line: 87, column: 14, scope: !292, inlinedAt: !297)
!338 = !DILocation(line: 87, column: 12, scope: !292, inlinedAt: !297)
!339 = !DILocation(line: 87, column: 21, scope: !292, inlinedAt: !297)
!340 = !DILocation(line: 87, column: 26, scope: !292, inlinedAt: !297)
!341 = !DILocation(line: 87, column: 36, scope: !292, inlinedAt: !297)
!342 = !DILocation(line: 87, column: 34, scope: !292, inlinedAt: !297)
!343 = !DILocation(line: 87, column: 43, scope: !292, inlinedAt: !297)
!344 = !DILocation(line: 89, column: 6, scope: !345, inlinedAt: !297)
!345 = distinct !DILexicalBlock(scope: !292, file: !286, line: 89, column: 6)
!346 = !DILocation(line: 89, column: 17, scope: !345, inlinedAt: !297)
!347 = !DILocation(line: 89, column: 14, scope: !345, inlinedAt: !297)
!348 = !DILocation(line: 89, column: 6, scope: !292, inlinedAt: !297)
!349 = !DILocation(line: 90, column: 10, scope: !350, inlinedAt: !297)
!350 = distinct !DILexicalBlock(scope: !345, file: !286, line: 89, column: 24)
!351 = !DILocation(line: 90, column: 32, scope: !350, inlinedAt: !297)
!352 = !DILocation(line: 90, column: 22, scope: !350, inlinedAt: !297)
!353 = !DILocation(line: 90, column: 21, scope: !350, inlinedAt: !297)
!354 = !DILocation(line: 90, column: 37, scope: !350, inlinedAt: !297)
!355 = !DILocation(line: 90, column: 3, scope: !350, inlinedAt: !297)
!356 = !DILocation(line: 95, column: 7, scope: !318, inlinedAt: !297)
!357 = !DILocation(line: 95, column: 6, scope: !292, inlinedAt: !297)
!358 = !DILocation(line: 96, column: 23, scope: !317, inlinedAt: !297)
!359 = !DILocation(line: 96, column: 36, scope: !317, inlinedAt: !297)
!360 = !DILocation(line: 96, column: 46, scope: !317, inlinedAt: !297)
!361 = !DILocation(line: 96, column: 44, scope: !317, inlinedAt: !297)
!362 = !DILocation(line: 96, column: 55, scope: !317, inlinedAt: !297)
!363 = !DILocation(line: 98, column: 7, scope: !364, inlinedAt: !297)
!364 = distinct !DILexicalBlock(scope: !317, file: !286, line: 98, column: 7)
!365 = !DILocation(line: 98, column: 7, scope: !317, inlinedAt: !297)
!366 = !DILocation(line: 99, column: 10, scope: !367, inlinedAt: !297)
!367 = distinct !DILexicalBlock(scope: !364, file: !286, line: 98, column: 17)
!368 = !DILocation(line: 99, column: 19, scope: !367, inlinedAt: !297)
!369 = !DILocation(line: 99, column: 8, scope: !367, inlinedAt: !297)
!370 = !DILocation(line: 100, column: 3, scope: !367, inlinedAt: !297)
!371 = !DILocation(line: 100, column: 14, scope: !372, inlinedAt: !297)
!372 = distinct !DILexicalBlock(scope: !364, file: !286, line: 100, column: 14)
!373 = !DILocation(line: 100, column: 14, scope: !364, inlinedAt: !297)
!374 = !DILocation(line: 101, column: 10, scope: !375, inlinedAt: !297)
!375 = distinct !DILexicalBlock(scope: !372, file: !286, line: 100, column: 25)
!376 = !DILocation(line: 101, column: 19, scope: !375, inlinedAt: !297)
!377 = !DILocation(line: 101, column: 8, scope: !375, inlinedAt: !297)
!378 = !DILocation(line: 102, column: 3, scope: !375, inlinedAt: !297)
!379 = !DILocation(line: 103, column: 2, scope: !317, inlinedAt: !297)
!380 = !DILocation(line: 110, column: 6, scope: !381, inlinedAt: !297)
!381 = distinct !DILexicalBlock(scope: !292, file: !286, line: 110, column: 6)
!382 = !DILocation(line: 110, column: 6, scope: !292, inlinedAt: !297)
!383 = !DILocation(line: 111, column: 8, scope: !384, inlinedAt: !297)
!384 = distinct !DILexicalBlock(scope: !381, file: !286, line: 110, column: 17)
!385 = !DILocation(line: 111, column: 5, scope: !384, inlinedAt: !297)
!386 = !DILocation(line: 112, column: 7, scope: !387, inlinedAt: !297)
!387 = distinct !DILexicalBlock(scope: !384, file: !286, line: 112, column: 7)
!388 = !DILocation(line: 112, column: 16, scope: !387, inlinedAt: !297)
!389 = !DILocation(line: 112, column: 20, scope: !387, inlinedAt: !297)
!390 = !DILocation(line: 112, column: 22, scope: !387, inlinedAt: !297)
!391 = !DILocation(line: 112, column: 7, scope: !384, inlinedAt: !297)
!392 = !DILocation(line: 113, column: 22, scope: !393, inlinedAt: !297)
!393 = distinct !DILexicalBlock(scope: !387, file: !286, line: 112, column: 36)
!394 = !DILocation(line: 113, column: 12, scope: !393, inlinedAt: !297)
!395 = !DILocation(line: 113, column: 28, scope: !393, inlinedAt: !297)
!396 = !DILocation(line: 113, column: 38, scope: !393, inlinedAt: !297)
!397 = !DILocation(line: 113, column: 36, scope: !393, inlinedAt: !297)
!398 = !DILocation(line: 113, column: 25, scope: !393, inlinedAt: !297)
!399 = !DILocation(line: 113, column: 11, scope: !393, inlinedAt: !297)
!400 = !DILocation(line: 113, column: 4, scope: !393, inlinedAt: !297)
!401 = !DILocation(line: 115, column: 11, scope: !402, inlinedAt: !297)
!402 = distinct !DILexicalBlock(scope: !387, file: !286, line: 114, column: 10)
!403 = !DILocation(line: 115, column: 16, scope: !402, inlinedAt: !297)
!404 = !DILocation(line: 115, column: 26, scope: !402, inlinedAt: !297)
!405 = !DILocation(line: 115, column: 24, scope: !402, inlinedAt: !297)
!406 = !DILocation(line: 115, column: 15, scope: !402, inlinedAt: !297)
!407 = !DILocation(line: 115, column: 13, scope: !402, inlinedAt: !297)
!408 = !DILocation(line: 115, column: 4, scope: !402, inlinedAt: !297)
!409 = !DILocation(line: 117, column: 13, scope: !410, inlinedAt: !297)
!410 = distinct !DILexicalBlock(scope: !381, file: !286, line: 117, column: 13)
!411 = !DILocation(line: 117, column: 13, scope: !381, inlinedAt: !297)
!412 = !DILocation(line: 118, column: 7, scope: !413, inlinedAt: !297)
!413 = distinct !DILexicalBlock(scope: !414, file: !286, line: 118, column: 7)
!414 = distinct !DILexicalBlock(scope: !410, file: !286, line: 117, column: 24)
!415 = !DILocation(line: 118, column: 7, scope: !414, inlinedAt: !297)
!416 = !DILocation(line: 119, column: 22, scope: !417, inlinedAt: !297)
!417 = distinct !DILexicalBlock(scope: !413, file: !286, line: 118, column: 17)
!418 = !DILocation(line: 119, column: 12, scope: !417, inlinedAt: !297)
!419 = !DILocation(line: 119, column: 28, scope: !417, inlinedAt: !297)
!420 = !DILocation(line: 119, column: 36, scope: !417, inlinedAt: !297)
!421 = !DILocation(line: 119, column: 34, scope: !417, inlinedAt: !297)
!422 = !DILocation(line: 119, column: 25, scope: !417, inlinedAt: !297)
!423 = !DILocation(line: 119, column: 11, scope: !417, inlinedAt: !297)
!424 = !DILocation(line: 119, column: 4, scope: !417, inlinedAt: !297)
!425 = !DILocation(line: 121, column: 11, scope: !426, inlinedAt: !297)
!426 = distinct !DILexicalBlock(scope: !413, file: !286, line: 120, column: 10)
!427 = !DILocation(line: 121, column: 16, scope: !426, inlinedAt: !297)
!428 = !DILocation(line: 121, column: 24, scope: !426, inlinedAt: !297)
!429 = !DILocation(line: 121, column: 22, scope: !426, inlinedAt: !297)
!430 = !DILocation(line: 121, column: 15, scope: !426, inlinedAt: !297)
!431 = !DILocation(line: 121, column: 13, scope: !426, inlinedAt: !297)
!432 = !DILocation(line: 121, column: 4, scope: !426, inlinedAt: !297)
!433 = !DILocation(line: 124, column: 7, scope: !434, inlinedAt: !297)
!434 = distinct !DILexicalBlock(scope: !435, file: !286, line: 124, column: 7)
!435 = distinct !DILexicalBlock(scope: !410, file: !286, line: 123, column: 9)
!436 = !DILocation(line: 124, column: 7, scope: !435, inlinedAt: !297)
!437 = !DILocation(line: 125, column: 23, scope: !438, inlinedAt: !297)
!438 = distinct !DILexicalBlock(scope: !434, file: !286, line: 124, column: 17)
!439 = !DILocation(line: 125, column: 27, scope: !438, inlinedAt: !297)
!440 = !DILocation(line: 125, column: 25, scope: !438, inlinedAt: !297)
!441 = !DILocation(line: 125, column: 35, scope: !438, inlinedAt: !297)
!442 = !DILocation(line: 125, column: 33, scope: !438, inlinedAt: !297)
!443 = !DILocation(line: 125, column: 42, scope: !438, inlinedAt: !297)
!444 = !DILocation(line: 125, column: 40, scope: !438, inlinedAt: !297)
!445 = !DILocation(line: 125, column: 11, scope: !438, inlinedAt: !297)
!446 = !DILocation(line: 125, column: 4, scope: !438, inlinedAt: !297)
!447 = !DILocation(line: 127, column: 12, scope: !448, inlinedAt: !297)
!448 = distinct !DILexicalBlock(scope: !434, file: !286, line: 126, column: 10)
!449 = !DILocation(line: 127, column: 16, scope: !448, inlinedAt: !297)
!450 = !DILocation(line: 127, column: 14, scope: !448, inlinedAt: !297)
!451 = !DILocation(line: 127, column: 24, scope: !448, inlinedAt: !297)
!452 = !DILocation(line: 127, column: 22, scope: !448, inlinedAt: !297)
!453 = !DILocation(line: 127, column: 31, scope: !448, inlinedAt: !297)
!454 = !DILocation(line: 127, column: 29, scope: !448, inlinedAt: !297)
!455 = !DILocation(line: 127, column: 4, scope: !448, inlinedAt: !297)
!456 = !DILocation(line: 130, column: 1, scope: !292, inlinedAt: !297)
!457 = !DILocation(line: 372, column: 2, scope: !285)
!458 = distinct !DISubprogram(name: "k_sleep", scope: !265, file: !265, line: 117, type: !459, scopeLine: 118, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !208)
!459 = !DISubroutineType(types: !460)
!460 = !{!279, !461}
!461 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_timeout_t", file: !54, line: 69, baseType: !462)
!462 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !54, line: 67, size: 64, elements: !463)
!463 = !{!464}
!464 = !DIDerivedType(tag: DW_TAG_member, name: "ticks", scope: !462, file: !54, line: 68, baseType: !53, size: 64)
!465 = !DILocalVariable(name: "timeout", arg: 1, scope: !458, file: !265, line: 117, type: !461)
!466 = !DILocation(line: 117, column: 61, scope: !458)
!467 = !DILocation(line: 126, column: 2, scope: !458)
!468 = !DILocation(line: 126, column: 2, scope: !469)
!469 = distinct !DILexicalBlock(scope: !458, file: !265, line: 126, column: 2)
!470 = !{i32 -2141857076}
!471 = !DILocation(line: 127, column: 9, scope: !458)
!472 = !DILocation(line: 127, column: 2, scope: !458)
!473 = distinct !DISubprogram(name: "threadB", scope: !65, file: !65, line: 42, type: !474, scopeLine: 43, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !208)
!474 = !DISubroutineType(types: !475)
!475 = !{null, !58, !58, !58}
!476 = !DILocalVariable(name: "dummy1", arg: 1, scope: !473, file: !65, line: 42, type: !58)
!477 = !DILocation(line: 42, column: 20, scope: !473)
!478 = !DILocalVariable(name: "dummy2", arg: 2, scope: !473, file: !65, line: 42, type: !58)
!479 = !DILocation(line: 42, column: 34, scope: !473)
!480 = !DILocalVariable(name: "dummy3", arg: 3, scope: !473, file: !65, line: 42, type: !58)
!481 = !DILocation(line: 42, column: 48, scope: !473)
!482 = !DILocation(line: 44, column: 5, scope: !473)
!483 = !DILocation(line: 45, column: 5, scope: !473)
!484 = !DILocation(line: 46, column: 5, scope: !473)
!485 = !DILocation(line: 48, column: 5, scope: !473)
!486 = !DILocation(line: 49, column: 1, scope: !473)
!487 = distinct !DISubprogram(name: "threadA", scope: !65, file: !65, line: 54, type: !474, scopeLine: 55, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !208)
!488 = !DILocalVariable(name: "dummy1", arg: 1, scope: !487, file: !65, line: 54, type: !58)
!489 = !DILocation(line: 54, column: 20, scope: !487)
!490 = !DILocalVariable(name: "dummy2", arg: 2, scope: !487, file: !65, line: 54, type: !58)
!491 = !DILocation(line: 54, column: 34, scope: !487)
!492 = !DILocalVariable(name: "dummy3", arg: 3, scope: !487, file: !65, line: 54, type: !58)
!493 = !DILocation(line: 54, column: 48, scope: !487)
!494 = !DILocation(line: 56, column: 5, scope: !487)
!495 = !DILocation(line: 57, column: 5, scope: !487)
!496 = !DILocation(line: 58, column: 5, scope: !487)
!497 = !DILocalVariable(name: "bad_stuff", scope: !487, file: !65, line: 59, type: !269)
!498 = !DILocation(line: 59, column: 22, scope: !487)
!499 = !DILocation(line: 61, column: 5, scope: !487)
!500 = !DILocation(line: 62, column: 5, scope: !487)
!501 = !DILocalVariable(name: "tid", scope: !487, file: !65, line: 64, type: !268)
!502 = !DILocation(line: 64, column: 13, scope: !487)
!503 = !DILocation(line: 64, column: 35, scope: !487)
!504 = !DILocation(line: 66, column: 34, scope: !487)
!505 = !DILocation(line: 64, column: 19, scope: !487)
!506 = !DILocation(line: 68, column: 23, scope: !487)
!507 = !DILocation(line: 68, column: 5, scope: !487)
!508 = !DILocation(line: 70, column: 5, scope: !487)
!509 = !DILocation(line: 71, column: 1, scope: !487)
!510 = distinct !DISubprogram(name: "k_thread_create", scope: !265, file: !265, line: 66, type: !511, scopeLine: 67, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !208)
!511 = !DISubroutineType(types: !512)
!512 = !{!268, !269, !513, !184, !516, !58, !58, !58, !59, !60, !461}
!513 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !514, size: 32)
!514 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_stack_t", file: !515, line: 44, baseType: !98)
!515 = !DIFile(filename: "zephyrproject/zephyr/include/sys/arch_interface.h", directory: "/home/kenny")
!516 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_entry_t", file: !515, line: 46, baseType: !517)
!517 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !474, size: 32)
!518 = !DILocalVariable(name: "new_thread", arg: 1, scope: !510, file: !265, line: 66, type: !269)
!519 = !DILocation(line: 66, column: 75, scope: !510)
!520 = !DILocalVariable(name: "stack", arg: 2, scope: !510, file: !265, line: 66, type: !513)
!521 = !DILocation(line: 66, column: 106, scope: !510)
!522 = !DILocalVariable(name: "stack_size", arg: 3, scope: !510, file: !265, line: 66, type: !184)
!523 = !DILocation(line: 66, column: 120, scope: !510)
!524 = !DILocalVariable(name: "entry", arg: 4, scope: !510, file: !265, line: 66, type: !516)
!525 = !DILocation(line: 66, column: 149, scope: !510)
!526 = !DILocalVariable(name: "p1", arg: 5, scope: !510, file: !265, line: 66, type: !58)
!527 = !DILocation(line: 66, column: 163, scope: !510)
!528 = !DILocalVariable(name: "p2", arg: 6, scope: !510, file: !265, line: 66, type: !58)
!529 = !DILocation(line: 66, column: 174, scope: !510)
!530 = !DILocalVariable(name: "p3", arg: 7, scope: !510, file: !265, line: 66, type: !58)
!531 = !DILocation(line: 66, column: 185, scope: !510)
!532 = !DILocalVariable(name: "prio", arg: 8, scope: !510, file: !265, line: 66, type: !59)
!533 = !DILocation(line: 66, column: 193, scope: !510)
!534 = !DILocalVariable(name: "options", arg: 9, scope: !510, file: !265, line: 66, type: !60)
!535 = !DILocation(line: 66, column: 208, scope: !510)
!536 = !DILocalVariable(name: "delay", arg: 10, scope: !510, file: !265, line: 66, type: !461)
!537 = !DILocation(line: 66, column: 229, scope: !510)
!538 = !DILocation(line: 83, column: 2, scope: !510)
!539 = !DILocation(line: 83, column: 2, scope: !540)
!540 = distinct !DILexicalBlock(scope: !510, file: !265, line: 83, column: 2)
!541 = !{i32 -2141857280}
!542 = !DILocation(line: 84, column: 32, scope: !510)
!543 = !DILocation(line: 84, column: 44, scope: !510)
!544 = !DILocation(line: 84, column: 51, scope: !510)
!545 = !DILocation(line: 84, column: 63, scope: !510)
!546 = !DILocation(line: 84, column: 70, scope: !510)
!547 = !DILocation(line: 84, column: 74, scope: !510)
!548 = !DILocation(line: 84, column: 78, scope: !510)
!549 = !DILocation(line: 84, column: 82, scope: !510)
!550 = !DILocation(line: 84, column: 88, scope: !510)
!551 = !DILocation(line: 84, column: 9, scope: !510)
!552 = !DILocation(line: 84, column: 2, scope: !510)
!553 = distinct !DISubprogram(name: "k_thread_name_set", scope: !265, file: !265, line: 363, type: !554, scopeLine: 364, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !208)
!554 = !DISubroutineType(types: !555)
!555 = !{!59, !268, !226}
!556 = !DILocalVariable(name: "thread_id", arg: 1, scope: !553, file: !265, line: 363, type: !268)
!557 = !DILocation(line: 363, column: 63, scope: !553)
!558 = !DILocalVariable(name: "value", arg: 2, scope: !553, file: !265, line: 363, type: !226)
!559 = !DILocation(line: 363, column: 87, scope: !553)
!560 = !DILocation(line: 370, column: 2, scope: !553)
!561 = !DILocation(line: 370, column: 2, scope: !562)
!562 = distinct !DILexicalBlock(scope: !553, file: !265, line: 370, column: 2)
!563 = !{i32 -2141855852}
!564 = !DILocation(line: 371, column: 34, scope: !553)
!565 = !DILocation(line: 371, column: 45, scope: !553)
!566 = !DILocation(line: 371, column: 9, scope: !553)
!567 = !DILocation(line: 371, column: 2, scope: !553)
!568 = distinct !DISubprogram(name: "main", scope: !65, file: !65, line: 77, type: !174, scopeLine: 78, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !208)
!569 = !DILocalVariable(name: "tid", scope: !568, file: !65, line: 79, type: !268)
!570 = !DILocation(line: 79, column: 13, scope: !568)
!571 = !DILocation(line: 81, column: 34, scope: !568)
!572 = !DILocation(line: 79, column: 19, scope: !568)
!573 = !DILocation(line: 83, column: 23, scope: !568)
!574 = !DILocation(line: 83, column: 5, scope: !568)
!575 = !DILocation(line: 84, column: 1, scope: !568)
