; ModuleID = 'llvm-link'
source_filename = "llvm-link"
target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "thumbv7em-none-unknown-eabi"

%struct.k_thread = type { %struct._thread_base, %struct._callee_saved, i8*, void ()*, i32, %struct._thread_stack_info, %struct.k_mem_pool*, %struct._thread_arch }
%struct._thread_base = type { %union.anon, %union.anon*, i8, i8, %union.anon.2, i32, i8*, %struct._timeout, %union.anon }
%union.anon.2 = type { i16 }
%struct._timeout = type { %struct._dnode, void (%struct._timeout*)*, i64 }
%struct._dnode = type { %union.anon.0, %union.anon.0 }
%union.anon.0 = type { %struct._dnode* }
%union.anon = type { %struct._dnode }
%struct._callee_saved = type { i32, i32, i32, i32, i32, i32, i32, i32, i32 }
%struct._thread_stack_info = type { i32, i32, i32 }
%struct.k_mem_pool = type { %struct.k_heap* }
%struct.k_heap = type { %struct.sys_heap, %union.anon, %struct.k_spinlock }
%struct.sys_heap = type { %struct.z_heap*, i8*, i32 }
%struct.z_heap = type opaque
%struct.k_spinlock = type {}
%struct._thread_arch = type { i32, i32 }
%struct.z_thread_stack_element = type { i8 }
%struct._static_thread_data = type { %struct.k_thread*, %struct.z_thread_stack_element*, i32, void (i8*, i8*, i8*)*, i8*, i8*, i8*, i32, i32, i32, void ()*, i8* }
%struct.k_timeout_t = type { i64 }

@_k_thread_obj_thread_a = dso_local global %struct.k_thread zeroinitializer, align 8, !dbg !0
@_k_thread_stack_thread_a = dso_local global [1024 x %struct.z_thread_stack_element] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/static_threads/src/main.c\22.0", align 8, !dbg !231
@_k_thread_data_thread_a = dso_local global %struct._static_thread_data { %struct.k_thread* @_k_thread_obj_thread_a, %struct.z_thread_stack_element* getelementptr inbounds ([1024 x %struct.z_thread_stack_element], [1024 x %struct.z_thread_stack_element]* @_k_thread_stack_thread_a, i32 0, i32 0), i32 1024, void (i8*, i8*, i8*)* @do_stuff, i8* null, i8* null, i8* null, i32 7, i32 0, i32 0, void ()* null, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str, i32 0, i32 0) }, section ".__static_thread_data.static._k_thread_data_thread_a", align 4, !dbg !63
@.str = private unnamed_addr constant [9 x i8] c"thread_a\00", align 1
@thread_a = dso_local constant %struct.k_thread* @_k_thread_obj_thread_a, align 4, !dbg !223
@_k_thread_obj_thread_b = dso_local global %struct.k_thread zeroinitializer, align 8, !dbg !238
@_k_thread_stack_thread_b = dso_local global [1024 x %struct.z_thread_stack_element] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/static_threads/src/main.c\22.1", align 8, !dbg !236
@_k_thread_data_thread_b = dso_local global %struct._static_thread_data { %struct.k_thread* @_k_thread_obj_thread_b, %struct.z_thread_stack_element* getelementptr inbounds ([1024 x %struct.z_thread_stack_element], [1024 x %struct.z_thread_stack_element]* @_k_thread_stack_thread_b, i32 0, i32 0), i32 1024, void (i8*, i8*, i8*)* @do_stuff, i8* null, i8* null, i8* null, i32 11, i32 0, i32 0, void ()* null, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.1, i32 0, i32 0) }, section ".__static_thread_data.static._k_thread_data_thread_b", align 4, !dbg !227
@.str.1 = private unnamed_addr constant [9 x i8] c"thread_b\00", align 1
@thread_b = dso_local constant %struct.k_thread* @_k_thread_obj_thread_b, align 4, !dbg !229
@llvm.used = appending global [2 x i8*] [i8* bitcast (%struct._static_thread_data* @_k_thread_data_thread_a to i8*), i8* bitcast (%struct._static_thread_data* @_k_thread_data_thread_b to i8*)], section "llvm.metadata"

; Function Attrs: noinline nounwind optnone
define dso_local void @do_stuff(i8*, i8*, i8*) #0 !dbg !245 {
  %4 = alloca i8*, align 4
  %5 = alloca i8*, align 4
  %6 = alloca i8*, align 4
  %7 = alloca i32, align 4
  store i8* %0, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !246, metadata !DIExpression()), !dbg !247
  store i8* %1, i8** %5, align 4
  call void @llvm.dbg.declare(metadata i8** %5, metadata !248, metadata !DIExpression()), !dbg !249
  store i8* %2, i8** %6, align 4
  call void @llvm.dbg.declare(metadata i8** %6, metadata !250, metadata !DIExpression()), !dbg !251
  %8 = load i8*, i8** %4, align 4, !dbg !252
  %9 = load i8*, i8** %5, align 4, !dbg !253
  %10 = load i8*, i8** %6, align 4, !dbg !254
  call void @zephyr_dummy_syscall() #3, !dbg !255
  br label %11, !dbg !256

11:                                               ; preds = %11, %3
  call void @llvm.dbg.declare(metadata i32* %7, metadata !257, metadata !DIExpression()), !dbg !260
  store volatile i32 0, i32* %7, align 4, !dbg !260
  %12 = call i32 @k_msleep(i32 500) #3, !dbg !261
  call void @k_yield() #3, !dbg !262
  br label %11, !dbg !256, !llvm.loop !263
}

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: noinline nounwind optnone
define dso_local void @zephyr_dummy_syscall() #0 !dbg !265 {
  ret void, !dbg !266
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_msleep(i32) #0 !dbg !267 {
  %2 = alloca i32, align 4
  %3 = alloca %struct.k_timeout_t, align 8
  store i32 %0, i32* %2, align 4
  call void @llvm.dbg.declare(metadata i32* %2, metadata !270, metadata !DIExpression()), !dbg !271
  %4 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !272
  %5 = load i32, i32* %2, align 4, !dbg !272
  %6 = icmp sgt i32 %5, 0, !dbg !272
  br i1 %6, label %7, label %9, !dbg !272

7:                                                ; preds = %1
  %8 = load i32, i32* %2, align 4, !dbg !272
  br label %10, !dbg !272

9:                                                ; preds = %1
  br label %10, !dbg !272

10:                                               ; preds = %9, %7
  %11 = phi i32 [ %8, %7 ], [ 0, %9 ], !dbg !272
  %12 = sext i32 %11 to i64, !dbg !272
  %13 = call i64 @k_ms_to_ticks_ceil64(i64 %12) #3, !dbg !272
  store i64 %13, i64* %4, align 8, !dbg !272
  %14 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !273
  %15 = bitcast i64* %14 to [1 x i64]*, !dbg !273
  %16 = load [1 x i64], [1 x i64]* %15, align 8, !dbg !273
  %17 = call i32 @k_sleep([1 x i64] %16) #3, !dbg !273
  ret i32 %17, !dbg !274
}

; Function Attrs: noinline nounwind optnone
define internal void @k_yield() #0 !dbg !275 {
  br label %1, !dbg !277

1:                                                ; preds = %0
  call void asm sideeffect "", "~{memory}"() #4, !dbg !278, !srcloc !280
  br label %2, !dbg !278

2:                                                ; preds = %1
  call void bitcast (void (...)* @z_impl_k_yield to void ()*)() #3, !dbg !281
  ret void, !dbg !282
}

declare dso_local void @z_impl_k_yield(...) #2

; Function Attrs: noinline nounwind optnone
define internal i64 @k_ms_to_ticks_ceil64(i64) #0 !dbg !283 {
  %2 = alloca i64, align 8
  %3 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %3, metadata !289, metadata !DIExpression()), !dbg !294
  %4 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !296, metadata !DIExpression()), !dbg !297
  %5 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %5, metadata !298, metadata !DIExpression()), !dbg !299
  %6 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %6, metadata !300, metadata !DIExpression()), !dbg !301
  %7 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %7, metadata !302, metadata !DIExpression()), !dbg !303
  %8 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %8, metadata !304, metadata !DIExpression()), !dbg !305
  %9 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %9, metadata !306, metadata !DIExpression()), !dbg !307
  %10 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %10, metadata !308, metadata !DIExpression()), !dbg !309
  %11 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %11, metadata !310, metadata !DIExpression()), !dbg !311
  %12 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %12, metadata !312, metadata !DIExpression()), !dbg !313
  %13 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %13, metadata !314, metadata !DIExpression()), !dbg !317
  %14 = alloca i64, align 8
  store i64 %0, i64* %14, align 8
  call void @llvm.dbg.declare(metadata i64* %14, metadata !318, metadata !DIExpression()), !dbg !319
  %15 = load i64, i64* %14, align 8, !dbg !320
  store i64 %15, i64* %3, align 8
  store i32 1000, i32* %4, align 4
  store i32 10000, i32* %5, align 4
  store i8 1, i8* %6, align 1
  store i8 0, i8* %7, align 1
  store i8 1, i8* %8, align 1
  store i8 0, i8* %9, align 1
  %16 = load i8, i8* %6, align 1, !dbg !321
  %17 = trunc i8 %16 to i1, !dbg !321
  br i1 %17, label %18, label %27, !dbg !322

18:                                               ; preds = %1
  %19 = load i32, i32* %5, align 4, !dbg !323
  %20 = load i32, i32* %4, align 4, !dbg !324
  %21 = icmp ugt i32 %19, %20, !dbg !325
  br i1 %21, label %22, label %27, !dbg !326

22:                                               ; preds = %18
  %23 = load i32, i32* %5, align 4, !dbg !327
  %24 = load i32, i32* %4, align 4, !dbg !328
  %25 = urem i32 %23, %24, !dbg !329
  %26 = icmp eq i32 %25, 0, !dbg !330
  br label %27

27:                                               ; preds = %22, %18, %1
  %28 = phi i1 [ false, %18 ], [ false, %1 ], [ %26, %22 ], !dbg !331
  %29 = zext i1 %28 to i8, !dbg !309
  store i8 %29, i8* %10, align 1, !dbg !309
  %30 = load i8, i8* %6, align 1, !dbg !332
  %31 = trunc i8 %30 to i1, !dbg !332
  br i1 %31, label %32, label %41, !dbg !333

32:                                               ; preds = %27
  %33 = load i32, i32* %4, align 4, !dbg !334
  %34 = load i32, i32* %5, align 4, !dbg !335
  %35 = icmp ugt i32 %33, %34, !dbg !336
  br i1 %35, label %36, label %41, !dbg !337

36:                                               ; preds = %32
  %37 = load i32, i32* %4, align 4, !dbg !338
  %38 = load i32, i32* %5, align 4, !dbg !339
  %39 = urem i32 %37, %38, !dbg !340
  %40 = icmp eq i32 %39, 0, !dbg !341
  br label %41

41:                                               ; preds = %36, %32, %27
  %42 = phi i1 [ false, %32 ], [ false, %27 ], [ %40, %36 ], !dbg !331
  %43 = zext i1 %42 to i8, !dbg !311
  store i8 %43, i8* %11, align 1, !dbg !311
  %44 = load i32, i32* %4, align 4, !dbg !342
  %45 = load i32, i32* %5, align 4, !dbg !344
  %46 = icmp eq i32 %44, %45, !dbg !345
  br i1 %46, label %47, label %58, !dbg !346

47:                                               ; preds = %41
  %48 = load i8, i8* %7, align 1, !dbg !347
  %49 = trunc i8 %48 to i1, !dbg !347
  br i1 %49, label %50, label %54, !dbg !347

50:                                               ; preds = %47
  %51 = load i64, i64* %3, align 8, !dbg !349
  %52 = trunc i64 %51 to i32, !dbg !350
  %53 = zext i32 %52 to i64, !dbg !351
  br label %56, !dbg !347

54:                                               ; preds = %47
  %55 = load i64, i64* %3, align 8, !dbg !352
  br label %56, !dbg !347

56:                                               ; preds = %54, %50
  %57 = phi i64 [ %53, %50 ], [ %55, %54 ], !dbg !347
  store i64 %57, i64* %2, align 8, !dbg !353
  br label %160, !dbg !353

58:                                               ; preds = %41
  store i64 0, i64* %12, align 8, !dbg !313
  %59 = load i8, i8* %10, align 1, !dbg !354
  %60 = trunc i8 %59 to i1, !dbg !354
  br i1 %60, label %87, label %61, !dbg !355

61:                                               ; preds = %58
  %62 = load i8, i8* %11, align 1, !dbg !356
  %63 = trunc i8 %62 to i1, !dbg !356
  br i1 %63, label %64, label %68, !dbg !356

64:                                               ; preds = %61
  %65 = load i32, i32* %4, align 4, !dbg !357
  %66 = load i32, i32* %5, align 4, !dbg !358
  %67 = udiv i32 %65, %66, !dbg !359
  br label %70, !dbg !356

68:                                               ; preds = %61
  %69 = load i32, i32* %4, align 4, !dbg !360
  br label %70, !dbg !356

70:                                               ; preds = %68, %64
  %71 = phi i32 [ %67, %64 ], [ %69, %68 ], !dbg !356
  store i32 %71, i32* %13, align 4, !dbg !317
  %72 = load i8, i8* %8, align 1, !dbg !361
  %73 = trunc i8 %72 to i1, !dbg !361
  br i1 %73, label %74, label %78, !dbg !363

74:                                               ; preds = %70
  %75 = load i32, i32* %13, align 4, !dbg !364
  %76 = sub i32 %75, 1, !dbg !366
  %77 = zext i32 %76 to i64, !dbg !364
  store i64 %77, i64* %12, align 8, !dbg !367
  br label %86, !dbg !368

78:                                               ; preds = %70
  %79 = load i8, i8* %9, align 1, !dbg !369
  %80 = trunc i8 %79 to i1, !dbg !369
  br i1 %80, label %81, label %85, !dbg !371

81:                                               ; preds = %78
  %82 = load i32, i32* %13, align 4, !dbg !372
  %83 = udiv i32 %82, 2, !dbg !374
  %84 = zext i32 %83 to i64, !dbg !372
  store i64 %84, i64* %12, align 8, !dbg !375
  br label %85, !dbg !376

85:                                               ; preds = %81, %78
  br label %86

86:                                               ; preds = %85, %74
  br label %87, !dbg !377

87:                                               ; preds = %86, %58
  %88 = load i8, i8* %11, align 1, !dbg !378
  %89 = trunc i8 %88 to i1, !dbg !378
  br i1 %89, label %90, label %114, !dbg !380

90:                                               ; preds = %87
  %91 = load i64, i64* %12, align 8, !dbg !381
  %92 = load i64, i64* %3, align 8, !dbg !383
  %93 = add i64 %92, %91, !dbg !383
  store i64 %93, i64* %3, align 8, !dbg !383
  %94 = load i8, i8* %7, align 1, !dbg !384
  %95 = trunc i8 %94 to i1, !dbg !384
  br i1 %95, label %96, label %107, !dbg !386

96:                                               ; preds = %90
  %97 = load i64, i64* %3, align 8, !dbg !387
  %98 = icmp ult i64 %97, 4294967296, !dbg !388
  br i1 %98, label %99, label %107, !dbg !389

99:                                               ; preds = %96
  %100 = load i64, i64* %3, align 8, !dbg !390
  %101 = trunc i64 %100 to i32, !dbg !392
  %102 = load i32, i32* %4, align 4, !dbg !393
  %103 = load i32, i32* %5, align 4, !dbg !394
  %104 = udiv i32 %102, %103, !dbg !395
  %105 = udiv i32 %101, %104, !dbg !396
  %106 = zext i32 %105 to i64, !dbg !397
  store i64 %106, i64* %2, align 8, !dbg !398
  br label %160, !dbg !398

107:                                              ; preds = %96, %90
  %108 = load i64, i64* %3, align 8, !dbg !399
  %109 = load i32, i32* %4, align 4, !dbg !401
  %110 = load i32, i32* %5, align 4, !dbg !402
  %111 = udiv i32 %109, %110, !dbg !403
  %112 = zext i32 %111 to i64, !dbg !404
  %113 = udiv i64 %108, %112, !dbg !405
  store i64 %113, i64* %2, align 8, !dbg !406
  br label %160, !dbg !406

114:                                              ; preds = %87
  %115 = load i8, i8* %10, align 1, !dbg !407
  %116 = trunc i8 %115 to i1, !dbg !407
  br i1 %116, label %117, label %135, !dbg !409

117:                                              ; preds = %114
  %118 = load i8, i8* %7, align 1, !dbg !410
  %119 = trunc i8 %118 to i1, !dbg !410
  br i1 %119, label %120, label %128, !dbg !413

120:                                              ; preds = %117
  %121 = load i64, i64* %3, align 8, !dbg !414
  %122 = trunc i64 %121 to i32, !dbg !416
  %123 = load i32, i32* %5, align 4, !dbg !417
  %124 = load i32, i32* %4, align 4, !dbg !418
  %125 = udiv i32 %123, %124, !dbg !419
  %126 = mul i32 %122, %125, !dbg !420
  %127 = zext i32 %126 to i64, !dbg !421
  store i64 %127, i64* %2, align 8, !dbg !422
  br label %160, !dbg !422

128:                                              ; preds = %117
  %129 = load i64, i64* %3, align 8, !dbg !423
  %130 = load i32, i32* %5, align 4, !dbg !425
  %131 = load i32, i32* %4, align 4, !dbg !426
  %132 = udiv i32 %130, %131, !dbg !427
  %133 = zext i32 %132 to i64, !dbg !428
  %134 = mul i64 %129, %133, !dbg !429
  store i64 %134, i64* %2, align 8, !dbg !430
  br label %160, !dbg !430

135:                                              ; preds = %114
  %136 = load i8, i8* %7, align 1, !dbg !431
  %137 = trunc i8 %136 to i1, !dbg !431
  br i1 %137, label %138, label %150, !dbg !434

138:                                              ; preds = %135
  %139 = load i64, i64* %3, align 8, !dbg !435
  %140 = load i32, i32* %5, align 4, !dbg !437
  %141 = zext i32 %140 to i64, !dbg !437
  %142 = mul i64 %139, %141, !dbg !438
  %143 = load i64, i64* %12, align 8, !dbg !439
  %144 = add i64 %142, %143, !dbg !440
  %145 = load i32, i32* %4, align 4, !dbg !441
  %146 = zext i32 %145 to i64, !dbg !441
  %147 = udiv i64 %144, %146, !dbg !442
  %148 = trunc i64 %147 to i32, !dbg !443
  %149 = zext i32 %148 to i64, !dbg !443
  store i64 %149, i64* %2, align 8, !dbg !444
  br label %160, !dbg !444

150:                                              ; preds = %135
  %151 = load i64, i64* %3, align 8, !dbg !445
  %152 = load i32, i32* %5, align 4, !dbg !447
  %153 = zext i32 %152 to i64, !dbg !447
  %154 = mul i64 %151, %153, !dbg !448
  %155 = load i64, i64* %12, align 8, !dbg !449
  %156 = add i64 %154, %155, !dbg !450
  %157 = load i32, i32* %4, align 4, !dbg !451
  %158 = zext i32 %157 to i64, !dbg !451
  %159 = udiv i64 %156, %158, !dbg !452
  store i64 %159, i64* %2, align 8, !dbg !453
  br label %160, !dbg !453

160:                                              ; preds = %150, %138, %128, %120, %107, %99, %56
  %161 = load i64, i64* %2, align 8, !dbg !454
  ret i64 %161, !dbg !455
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_sleep([1 x i64]) #0 !dbg !456 {
  %2 = alloca %struct.k_timeout_t, align 8
  %3 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0
  %4 = bitcast i64* %3 to [1 x i64]*
  store [1 x i64] %0, [1 x i64]* %4, align 8
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %2, metadata !463, metadata !DIExpression()), !dbg !464
  br label %5, !dbg !465

5:                                                ; preds = %1
  call void asm sideeffect "", "~{memory}"() #4, !dbg !466, !srcloc !468
  br label %6, !dbg !466

6:                                                ; preds = %5
  %7 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !469
  %8 = bitcast i64* %7 to [1 x i64]*, !dbg !469
  %9 = load [1 x i64], [1 x i64]* %8, align 8, !dbg !469
  %10 = call i32 @z_impl_k_sleep([1 x i64] %9) #3, !dbg !469
  ret i32 %10, !dbg !470
}

declare dso_local i32 @z_impl_k_sleep([1 x i64]) #2

; Function Attrs: noinline nounwind optnone
define dso_local void @main() #0 !dbg !471 {
  call void @zephyr_dummy_syscall() #3, !dbg !472
  ret void, !dbg !473
}

attributes #0 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #1 = { nounwind readnone speculatable }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #3 = { nobuiltin }
attributes #4 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.ident = !{!240}
!llvm.module.flags = !{!241, !242, !243, !244}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "_k_thread_obj_thread_a", scope: !2, file: !65, line: 25, type: !70, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !52, globals: !62, nameTableKind: None)
!3 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/static_threads/src/main.c", directory: "/home/kenny/ara/build/appl/Zephyr/static_threads")
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
!52 = !{!53, !54, !55, !60}
!53 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 32)
!54 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!55 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_ticks_t", file: !56, line: 46, baseType: !57)
!56 = !DIFile(filename: "zephyrproject/zephyr/include/sys_clock.h", directory: "/home/kenny")
!57 = !DIDerivedType(tag: DW_TAG_typedef, name: "int64_t", file: !58, line: 43, baseType: !59)
!58 = !DIFile(filename: "zephyrproject/zephyr/lib/libc/minimal/include/stdint.h", directory: "/home/kenny")
!59 = !DIBasicType(name: "long long int", size: 64, encoding: DW_ATE_signed)
!60 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !58, line: 57, baseType: !61)
!61 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!62 = !{!63, !223, !227, !229, !231, !0, !236, !238}
!63 = !DIGlobalVariableExpression(var: !64, expr: !DIExpression())
!64 = distinct !DIGlobalVariable(name: "_k_thread_data_thread_a", scope: !2, file: !65, line: 25, type: !66, isLocal: false, isDefinition: true, align: 32)
!65 = !DIFile(filename: "appl/Zephyr/static_threads/src/main.c", directory: "/home/kenny/ara")
!66 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_static_thread_data", file: !6, line: 1099, size: 384, elements: !67)
!67 = !{!68, !197, !206, !207, !212, !213, !214, !215, !216, !217, !219, !220}
!68 = !DIDerivedType(tag: DW_TAG_member, name: "init_thread", scope: !66, file: !6, line: 1100, baseType: !69, size: 32)
!69 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !70, size: 32)
!70 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_thread", file: !6, line: 570, size: 1024, elements: !71)
!71 = !{!72, !141, !154, !155, !159, !160, !170, !192}
!72 = !DIDerivedType(tag: DW_TAG_member, name: "base", scope: !70, file: !6, line: 572, baseType: !73, size: 448)
!73 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_base", file: !6, line: 441, size: 448, elements: !74)
!74 = !{!75, !103, !111, !113, !114, !127, !128, !129, !140}
!75 = !DIDerivedType(tag: DW_TAG_member, scope: !73, file: !6, line: 444, baseType: !76, size: 64)
!76 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !73, file: !6, line: 444, size: 64, elements: !77)
!77 = !{!78, !94}
!78 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_dlist", scope: !76, file: !6, line: 445, baseType: !79, size: 64)
!79 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dnode_t", file: !80, line: 43, baseType: !81)
!80 = !DIFile(filename: "zephyrproject/zephyr/include/sys/dlist.h", directory: "/home/kenny")
!81 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_dnode", file: !80, line: 31, size: 64, elements: !82)
!82 = !{!83, !89}
!83 = !DIDerivedType(tag: DW_TAG_member, scope: !81, file: !80, line: 32, baseType: !84, size: 32)
!84 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !81, file: !80, line: 32, size: 32, elements: !85)
!85 = !{!86, !88}
!86 = !DIDerivedType(tag: DW_TAG_member, name: "head", scope: !84, file: !80, line: 33, baseType: !87, size: 32)
!87 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !81, size: 32)
!88 = !DIDerivedType(tag: DW_TAG_member, name: "next", scope: !84, file: !80, line: 34, baseType: !87, size: 32)
!89 = !DIDerivedType(tag: DW_TAG_member, scope: !81, file: !80, line: 36, baseType: !90, size: 32, offset: 32)
!90 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !81, file: !80, line: 36, size: 32, elements: !91)
!91 = !{!92, !93}
!92 = !DIDerivedType(tag: DW_TAG_member, name: "tail", scope: !90, file: !80, line: 37, baseType: !87, size: 32)
!93 = !DIDerivedType(tag: DW_TAG_member, name: "prev", scope: !90, file: !80, line: 38, baseType: !87, size: 32)
!94 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_rb", scope: !76, file: !6, line: 446, baseType: !95, size: 64)
!95 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "rbnode", file: !96, line: 48, size: 64, elements: !97)
!96 = !DIFile(filename: "zephyrproject/zephyr/include/sys/rb.h", directory: "/home/kenny")
!97 = !{!98}
!98 = !DIDerivedType(tag: DW_TAG_member, name: "children", scope: !95, file: !96, line: 49, baseType: !99, size: 64)
!99 = !DICompositeType(tag: DW_TAG_array_type, baseType: !100, size: 64, elements: !101)
!100 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !95, size: 32)
!101 = !{!102}
!102 = !DISubrange(count: 2)
!103 = !DIDerivedType(tag: DW_TAG_member, name: "pended_on", scope: !73, file: !6, line: 452, baseType: !104, size: 32, offset: 64)
!104 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !105, size: 32)
!105 = !DIDerivedType(tag: DW_TAG_typedef, name: "_wait_q_t", file: !106, line: 210, baseType: !107)
!106 = !DIFile(filename: "zephyrproject/zephyr/include/kernel_structs.h", directory: "/home/kenny")
!107 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !106, line: 208, size: 64, elements: !108)
!108 = !{!109}
!109 = !DIDerivedType(tag: DW_TAG_member, name: "waitq", scope: !107, file: !106, line: 209, baseType: !110, size: 64)
!110 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dlist_t", file: !80, line: 42, baseType: !81)
!111 = !DIDerivedType(tag: DW_TAG_member, name: "user_options", scope: !73, file: !6, line: 455, baseType: !112, size: 8, offset: 96)
!112 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !58, line: 55, baseType: !7)
!113 = !DIDerivedType(tag: DW_TAG_member, name: "thread_state", scope: !73, file: !6, line: 458, baseType: !112, size: 8, offset: 104)
!114 = !DIDerivedType(tag: DW_TAG_member, scope: !73, file: !6, line: 474, baseType: !115, size: 16, offset: 112)
!115 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !73, file: !6, line: 474, size: 16, elements: !116)
!116 = !{!117, !124}
!117 = !DIDerivedType(tag: DW_TAG_member, scope: !115, file: !6, line: 475, baseType: !118, size: 16)
!118 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !115, file: !6, line: 475, size: 16, elements: !119)
!119 = !{!120, !123}
!120 = !DIDerivedType(tag: DW_TAG_member, name: "prio", scope: !118, file: !6, line: 480, baseType: !121, size: 8)
!121 = !DIDerivedType(tag: DW_TAG_typedef, name: "int8_t", file: !58, line: 40, baseType: !122)
!122 = !DIBasicType(name: "signed char", size: 8, encoding: DW_ATE_signed_char)
!123 = !DIDerivedType(tag: DW_TAG_member, name: "sched_locked", scope: !118, file: !6, line: 481, baseType: !112, size: 8, offset: 8)
!124 = !DIDerivedType(tag: DW_TAG_member, name: "preempt", scope: !115, file: !6, line: 484, baseType: !125, size: 16)
!125 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !58, line: 56, baseType: !126)
!126 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!127 = !DIDerivedType(tag: DW_TAG_member, name: "order_key", scope: !73, file: !6, line: 491, baseType: !60, size: 32, offset: 128)
!128 = !DIDerivedType(tag: DW_TAG_member, name: "swap_data", scope: !73, file: !6, line: 511, baseType: !53, size: 32, offset: 160)
!129 = !DIDerivedType(tag: DW_TAG_member, name: "timeout", scope: !73, file: !6, line: 515, baseType: !130, size: 192, offset: 192)
!130 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_timeout", file: !106, line: 221, size: 192, elements: !131)
!131 = !{!132, !133, !139}
!132 = !DIDerivedType(tag: DW_TAG_member, name: "node", scope: !130, file: !106, line: 222, baseType: !79, size: 64)
!133 = !DIDerivedType(tag: DW_TAG_member, name: "fn", scope: !130, file: !106, line: 223, baseType: !134, size: 32, offset: 64)
!134 = !DIDerivedType(tag: DW_TAG_typedef, name: "_timeout_func_t", file: !106, line: 219, baseType: !135)
!135 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !136, size: 32)
!136 = !DISubroutineType(types: !137)
!137 = !{null, !138}
!138 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !130, size: 32)
!139 = !DIDerivedType(tag: DW_TAG_member, name: "dticks", scope: !130, file: !106, line: 226, baseType: !57, size: 64, offset: 128)
!140 = !DIDerivedType(tag: DW_TAG_member, name: "join_waiters", scope: !73, file: !6, line: 518, baseType: !105, size: 64, offset: 384)
!141 = !DIDerivedType(tag: DW_TAG_member, name: "callee_saved", scope: !70, file: !6, line: 575, baseType: !142, size: 288, offset: 448)
!142 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_callee_saved", file: !143, line: 25, size: 288, elements: !144)
!143 = !DIFile(filename: "zephyrproject/zephyr/include/arch/arm/aarch32/thread.h", directory: "/home/kenny")
!144 = !{!145, !146, !147, !148, !149, !150, !151, !152, !153}
!145 = !DIDerivedType(tag: DW_TAG_member, name: "v1", scope: !142, file: !143, line: 26, baseType: !60, size: 32)
!146 = !DIDerivedType(tag: DW_TAG_member, name: "v2", scope: !142, file: !143, line: 27, baseType: !60, size: 32, offset: 32)
!147 = !DIDerivedType(tag: DW_TAG_member, name: "v3", scope: !142, file: !143, line: 28, baseType: !60, size: 32, offset: 64)
!148 = !DIDerivedType(tag: DW_TAG_member, name: "v4", scope: !142, file: !143, line: 29, baseType: !60, size: 32, offset: 96)
!149 = !DIDerivedType(tag: DW_TAG_member, name: "v5", scope: !142, file: !143, line: 30, baseType: !60, size: 32, offset: 128)
!150 = !DIDerivedType(tag: DW_TAG_member, name: "v6", scope: !142, file: !143, line: 31, baseType: !60, size: 32, offset: 160)
!151 = !DIDerivedType(tag: DW_TAG_member, name: "v7", scope: !142, file: !143, line: 32, baseType: !60, size: 32, offset: 192)
!152 = !DIDerivedType(tag: DW_TAG_member, name: "v8", scope: !142, file: !143, line: 33, baseType: !60, size: 32, offset: 224)
!153 = !DIDerivedType(tag: DW_TAG_member, name: "psp", scope: !142, file: !143, line: 34, baseType: !60, size: 32, offset: 256)
!154 = !DIDerivedType(tag: DW_TAG_member, name: "init_data", scope: !70, file: !6, line: 578, baseType: !53, size: 32, offset: 736)
!155 = !DIDerivedType(tag: DW_TAG_member, name: "fn_abort", scope: !70, file: !6, line: 583, baseType: !156, size: 32, offset: 768)
!156 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !157, size: 32)
!157 = !DISubroutineType(types: !158)
!158 = !{null}
!159 = !DIDerivedType(tag: DW_TAG_member, name: "errno_var", scope: !70, file: !6, line: 610, baseType: !54, size: 32, offset: 800)
!160 = !DIDerivedType(tag: DW_TAG_member, name: "stack_info", scope: !70, file: !6, line: 616, baseType: !161, size: 96, offset: 832)
!161 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_stack_info", file: !6, line: 525, size: 96, elements: !162)
!162 = !{!163, !166, !169}
!163 = !DIDerivedType(tag: DW_TAG_member, name: "start", scope: !161, file: !6, line: 529, baseType: !164, size: 32)
!164 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintptr_t", file: !58, line: 71, baseType: !165)
!165 = !DIBasicType(name: "long unsigned int", size: 32, encoding: DW_ATE_unsigned)
!166 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !161, file: !6, line: 538, baseType: !167, size: 32, offset: 32)
!167 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !168, line: 46, baseType: !61)
!168 = !DIFile(filename: "/usr/lib/llvm-9/lib/clang/9.0.1/include/stddef.h", directory: "")
!169 = !DIDerivedType(tag: DW_TAG_member, name: "delta", scope: !161, file: !6, line: 544, baseType: !167, size: 32, offset: 64)
!170 = !DIDerivedType(tag: DW_TAG_member, name: "resource_pool", scope: !70, file: !6, line: 641, baseType: !171, size: 32, offset: 928)
!171 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !172, size: 32)
!172 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mem_pool", file: !173, line: 30, size: 32, elements: !174)
!173 = !DIFile(filename: "zephyrproject/zephyr/include/mempool_heap.h", directory: "/home/kenny")
!174 = !{!175}
!175 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !172, file: !173, line: 31, baseType: !176, size: 32)
!176 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !177, size: 32)
!177 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_heap", file: !106, line: 267, size: 160, elements: !178)
!178 = !{!179, !188, !189}
!179 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !177, file: !106, line: 268, baseType: !180, size: 96)
!180 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "sys_heap", file: !181, line: 51, size: 96, elements: !182)
!181 = !DIFile(filename: "zephyrproject/zephyr/include/sys/sys_heap.h", directory: "/home/kenny")
!182 = !{!183, !186, !187}
!183 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !180, file: !181, line: 52, baseType: !184, size: 32)
!184 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !185, size: 32)
!185 = !DICompositeType(tag: DW_TAG_structure_type, name: "z_heap", file: !181, line: 52, flags: DIFlagFwdDecl)
!186 = !DIDerivedType(tag: DW_TAG_member, name: "init_mem", scope: !180, file: !181, line: 53, baseType: !53, size: 32, offset: 32)
!187 = !DIDerivedType(tag: DW_TAG_member, name: "init_bytes", scope: !180, file: !181, line: 54, baseType: !167, size: 32, offset: 64)
!188 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !177, file: !106, line: 269, baseType: !105, size: 64, offset: 96)
!189 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !177, file: !106, line: 270, baseType: !190, offset: 160)
!190 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_spinlock", file: !106, line: 234, elements: !191)
!191 = !{}
!192 = !DIDerivedType(tag: DW_TAG_member, name: "arch", scope: !70, file: !6, line: 644, baseType: !193, size: 64, offset: 960)
!193 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_arch", file: !143, line: 60, size: 64, elements: !194)
!194 = !{!195, !196}
!195 = !DIDerivedType(tag: DW_TAG_member, name: "basepri", scope: !193, file: !143, line: 63, baseType: !60, size: 32)
!196 = !DIDerivedType(tag: DW_TAG_member, name: "swap_return_value", scope: !193, file: !143, line: 66, baseType: !60, size: 32, offset: 32)
!197 = !DIDerivedType(tag: DW_TAG_member, name: "init_stack", scope: !66, file: !6, line: 1101, baseType: !198, size: 32, offset: 32)
!198 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !199, size: 32)
!199 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_stack_t", file: !200, line: 44, baseType: !201)
!200 = !DIFile(filename: "zephyrproject/zephyr/include/sys/arch_interface.h", directory: "/home/kenny")
!201 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "z_thread_stack_element", file: !202, line: 35, size: 8, elements: !203)
!202 = !DIFile(filename: "zephyrproject/zephyr/include/sys/thread_stack.h", directory: "/home/kenny")
!203 = !{!204}
!204 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !201, file: !202, line: 36, baseType: !205, size: 8)
!205 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_unsigned_char)
!206 = !DIDerivedType(tag: DW_TAG_member, name: "init_stack_size", scope: !66, file: !6, line: 1102, baseType: !61, size: 32, offset: 64)
!207 = !DIDerivedType(tag: DW_TAG_member, name: "init_entry", scope: !66, file: !6, line: 1103, baseType: !208, size: 32, offset: 96)
!208 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_entry_t", file: !200, line: 46, baseType: !209)
!209 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !210, size: 32)
!210 = !DISubroutineType(types: !211)
!211 = !{null, !53, !53, !53}
!212 = !DIDerivedType(tag: DW_TAG_member, name: "init_p1", scope: !66, file: !6, line: 1104, baseType: !53, size: 32, offset: 128)
!213 = !DIDerivedType(tag: DW_TAG_member, name: "init_p2", scope: !66, file: !6, line: 1105, baseType: !53, size: 32, offset: 160)
!214 = !DIDerivedType(tag: DW_TAG_member, name: "init_p3", scope: !66, file: !6, line: 1106, baseType: !53, size: 32, offset: 192)
!215 = !DIDerivedType(tag: DW_TAG_member, name: "init_prio", scope: !66, file: !6, line: 1107, baseType: !54, size: 32, offset: 224)
!216 = !DIDerivedType(tag: DW_TAG_member, name: "init_options", scope: !66, file: !6, line: 1108, baseType: !60, size: 32, offset: 256)
!217 = !DIDerivedType(tag: DW_TAG_member, name: "init_delay", scope: !66, file: !6, line: 1109, baseType: !218, size: 32, offset: 288)
!218 = !DIDerivedType(tag: DW_TAG_typedef, name: "int32_t", file: !58, line: 42, baseType: !54)
!219 = !DIDerivedType(tag: DW_TAG_member, name: "init_abort", scope: !66, file: !6, line: 1110, baseType: !156, size: 32, offset: 320)
!220 = !DIDerivedType(tag: DW_TAG_member, name: "init_name", scope: !66, file: !6, line: 1111, baseType: !221, size: 32, offset: 352)
!221 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !222, size: 32)
!222 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !205)
!223 = !DIGlobalVariableExpression(var: !224, expr: !DIExpression())
!224 = distinct !DIGlobalVariable(name: "thread_a", scope: !2, file: !65, line: 25, type: !225, isLocal: false, isDefinition: true)
!225 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !226)
!226 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_tid_t", file: !6, line: 648, baseType: !69)
!227 = !DIGlobalVariableExpression(var: !228, expr: !DIExpression())
!228 = distinct !DIGlobalVariable(name: "_k_thread_data_thread_b", scope: !2, file: !65, line: 29, type: !66, isLocal: false, isDefinition: true, align: 32)
!229 = !DIGlobalVariableExpression(var: !230, expr: !DIExpression())
!230 = distinct !DIGlobalVariable(name: "thread_b", scope: !2, file: !65, line: 29, type: !225, isLocal: false, isDefinition: true)
!231 = !DIGlobalVariableExpression(var: !232, expr: !DIExpression())
!232 = distinct !DIGlobalVariable(name: "_k_thread_stack_thread_a", scope: !2, file: !65, line: 25, type: !233, isLocal: false, isDefinition: true, align: 64)
!233 = !DICompositeType(tag: DW_TAG_array_type, baseType: !201, size: 8192, elements: !234)
!234 = !{!235}
!235 = !DISubrange(count: 1024)
!236 = !DIGlobalVariableExpression(var: !237, expr: !DIExpression())
!237 = distinct !DIGlobalVariable(name: "_k_thread_stack_thread_b", scope: !2, file: !65, line: 29, type: !233, isLocal: false, isDefinition: true, align: 64)
!238 = !DIGlobalVariableExpression(var: !239, expr: !DIExpression())
!239 = distinct !DIGlobalVariable(name: "_k_thread_obj_thread_b", scope: !2, file: !65, line: 29, type: !70, isLocal: false, isDefinition: true)
!240 = !{!"clang version 9.0.1-12 "}
!241 = !{i32 2, !"Dwarf Version", i32 4}
!242 = !{i32 2, !"Debug Info Version", i32 3}
!243 = !{i32 1, !"wchar_size", i32 4}
!244 = !{i32 1, !"min_enum_size", i32 1}
!245 = distinct !DISubprogram(name: "do_stuff", scope: !65, file: !65, line: 12, type: !210, scopeLine: 13, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !191)
!246 = !DILocalVariable(name: "dummy1", arg: 1, scope: !245, file: !65, line: 12, type: !53)
!247 = !DILocation(line: 12, column: 21, scope: !245)
!248 = !DILocalVariable(name: "dummy2", arg: 2, scope: !245, file: !65, line: 12, type: !53)
!249 = !DILocation(line: 12, column: 35, scope: !245)
!250 = !DILocalVariable(name: "dummy3", arg: 3, scope: !245, file: !65, line: 12, type: !53)
!251 = !DILocation(line: 12, column: 49, scope: !245)
!252 = !DILocation(line: 14, column: 2, scope: !245)
!253 = !DILocation(line: 15, column: 2, scope: !245)
!254 = !DILocation(line: 16, column: 2, scope: !245)
!255 = !DILocation(line: 17, column: 9, scope: !245)
!256 = !DILocation(line: 18, column: 9, scope: !245)
!257 = !DILocalVariable(name: "stuff", scope: !258, file: !65, line: 19, type: !259)
!258 = distinct !DILexicalBlock(scope: !245, file: !65, line: 18, column: 20)
!259 = !DIDerivedType(tag: DW_TAG_volatile_type, baseType: !54)
!260 = !DILocation(line: 19, column: 26, scope: !258)
!261 = !DILocation(line: 20, column: 13, scope: !258)
!262 = !DILocation(line: 21, column: 13, scope: !258)
!263 = distinct !{!263, !256, !264}
!264 = !DILocation(line: 22, column: 9, scope: !245)
!265 = distinct !DISubprogram(name: "zephyr_dummy_syscall", scope: !65, file: !65, line: 10, type: !157, scopeLine: 10, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !191)
!266 = !DILocation(line: 10, column: 29, scope: !265)
!267 = distinct !DISubprogram(name: "k_msleep", scope: !6, file: !6, line: 957, type: !268, scopeLine: 958, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !191)
!268 = !DISubroutineType(types: !269)
!269 = !{!218, !218}
!270 = !DILocalVariable(name: "ms", arg: 1, scope: !267, file: !6, line: 957, type: !218)
!271 = !DILocation(line: 957, column: 40, scope: !267)
!272 = !DILocation(line: 959, column: 17, scope: !267)
!273 = !DILocation(line: 959, column: 9, scope: !267)
!274 = !DILocation(line: 959, column: 2, scope: !267)
!275 = distinct !DISubprogram(name: "k_yield", scope: !276, file: !276, line: 159, type: !157, scopeLine: 160, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !191)
!276 = !DIFile(filename: "zephyr/include/generated/syscalls/kernel.h", directory: "/home/kenny/ara/build/appl/Zephyr/static_threads")
!277 = !DILocation(line: 167, column: 2, scope: !275)
!278 = !DILocation(line: 167, column: 2, scope: !279)
!279 = distinct !DILexicalBlock(scope: !275, file: !276, line: 167, column: 2)
!280 = !{i32 -2141858225}
!281 = !DILocation(line: 168, column: 2, scope: !275)
!282 = !DILocation(line: 169, column: 1, scope: !275)
!283 = distinct !DISubprogram(name: "k_ms_to_ticks_ceil64", scope: !284, file: !284, line: 369, type: !285, scopeLine: 370, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !191)
!284 = !DIFile(filename: "zephyrproject/zephyr/include/sys/time_units.h", directory: "/home/kenny")
!285 = !DISubroutineType(types: !286)
!286 = !{!287, !287}
!287 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint64_t", file: !58, line: 58, baseType: !288)
!288 = !DIBasicType(name: "long long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!289 = !DILocalVariable(name: "t", arg: 1, scope: !290, file: !284, line: 78, type: !287)
!290 = distinct !DISubprogram(name: "z_tmcvt", scope: !284, file: !284, line: 78, type: !291, scopeLine: 82, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !191)
!291 = !DISubroutineType(types: !292)
!292 = !{!287, !287, !60, !60, !293, !293, !293, !293}
!293 = !DIBasicType(name: "_Bool", size: 8, encoding: DW_ATE_boolean)
!294 = !DILocation(line: 78, column: 63, scope: !290, inlinedAt: !295)
!295 = distinct !DILocation(line: 372, column: 9, scope: !283)
!296 = !DILocalVariable(name: "from_hz", arg: 2, scope: !290, file: !284, line: 78, type: !60)
!297 = !DILocation(line: 78, column: 75, scope: !290, inlinedAt: !295)
!298 = !DILocalVariable(name: "to_hz", arg: 3, scope: !290, file: !284, line: 79, type: !60)
!299 = !DILocation(line: 79, column: 18, scope: !290, inlinedAt: !295)
!300 = !DILocalVariable(name: "const_hz", arg: 4, scope: !290, file: !284, line: 79, type: !293)
!301 = !DILocation(line: 79, column: 30, scope: !290, inlinedAt: !295)
!302 = !DILocalVariable(name: "result32", arg: 5, scope: !290, file: !284, line: 80, type: !293)
!303 = !DILocation(line: 80, column: 14, scope: !290, inlinedAt: !295)
!304 = !DILocalVariable(name: "round_up", arg: 6, scope: !290, file: !284, line: 80, type: !293)
!305 = !DILocation(line: 80, column: 29, scope: !290, inlinedAt: !295)
!306 = !DILocalVariable(name: "round_off", arg: 7, scope: !290, file: !284, line: 81, type: !293)
!307 = !DILocation(line: 81, column: 14, scope: !290, inlinedAt: !295)
!308 = !DILocalVariable(name: "mul_ratio", scope: !290, file: !284, line: 84, type: !293)
!309 = !DILocation(line: 84, column: 7, scope: !290, inlinedAt: !295)
!310 = !DILocalVariable(name: "div_ratio", scope: !290, file: !284, line: 86, type: !293)
!311 = !DILocation(line: 86, column: 7, scope: !290, inlinedAt: !295)
!312 = !DILocalVariable(name: "off", scope: !290, file: !284, line: 93, type: !287)
!313 = !DILocation(line: 93, column: 11, scope: !290, inlinedAt: !295)
!314 = !DILocalVariable(name: "rdivisor", scope: !315, file: !284, line: 96, type: !60)
!315 = distinct !DILexicalBlock(scope: !316, file: !284, line: 95, column: 18)
!316 = distinct !DILexicalBlock(scope: !290, file: !284, line: 95, column: 6)
!317 = !DILocation(line: 96, column: 12, scope: !315, inlinedAt: !295)
!318 = !DILocalVariable(name: "t", arg: 1, scope: !283, file: !284, line: 369, type: !287)
!319 = !DILocation(line: 369, column: 69, scope: !283)
!320 = !DILocation(line: 372, column: 17, scope: !283)
!321 = !DILocation(line: 84, column: 19, scope: !290, inlinedAt: !295)
!322 = !DILocation(line: 84, column: 28, scope: !290, inlinedAt: !295)
!323 = !DILocation(line: 85, column: 4, scope: !290, inlinedAt: !295)
!324 = !DILocation(line: 85, column: 12, scope: !290, inlinedAt: !295)
!325 = !DILocation(line: 85, column: 10, scope: !290, inlinedAt: !295)
!326 = !DILocation(line: 85, column: 21, scope: !290, inlinedAt: !295)
!327 = !DILocation(line: 85, column: 26, scope: !290, inlinedAt: !295)
!328 = !DILocation(line: 85, column: 34, scope: !290, inlinedAt: !295)
!329 = !DILocation(line: 85, column: 32, scope: !290, inlinedAt: !295)
!330 = !DILocation(line: 85, column: 43, scope: !290, inlinedAt: !295)
!331 = !DILocation(line: 0, scope: !290, inlinedAt: !295)
!332 = !DILocation(line: 86, column: 19, scope: !290, inlinedAt: !295)
!333 = !DILocation(line: 86, column: 28, scope: !290, inlinedAt: !295)
!334 = !DILocation(line: 87, column: 4, scope: !290, inlinedAt: !295)
!335 = !DILocation(line: 87, column: 14, scope: !290, inlinedAt: !295)
!336 = !DILocation(line: 87, column: 12, scope: !290, inlinedAt: !295)
!337 = !DILocation(line: 87, column: 21, scope: !290, inlinedAt: !295)
!338 = !DILocation(line: 87, column: 26, scope: !290, inlinedAt: !295)
!339 = !DILocation(line: 87, column: 36, scope: !290, inlinedAt: !295)
!340 = !DILocation(line: 87, column: 34, scope: !290, inlinedAt: !295)
!341 = !DILocation(line: 87, column: 43, scope: !290, inlinedAt: !295)
!342 = !DILocation(line: 89, column: 6, scope: !343, inlinedAt: !295)
!343 = distinct !DILexicalBlock(scope: !290, file: !284, line: 89, column: 6)
!344 = !DILocation(line: 89, column: 17, scope: !343, inlinedAt: !295)
!345 = !DILocation(line: 89, column: 14, scope: !343, inlinedAt: !295)
!346 = !DILocation(line: 89, column: 6, scope: !290, inlinedAt: !295)
!347 = !DILocation(line: 90, column: 10, scope: !348, inlinedAt: !295)
!348 = distinct !DILexicalBlock(scope: !343, file: !284, line: 89, column: 24)
!349 = !DILocation(line: 90, column: 32, scope: !348, inlinedAt: !295)
!350 = !DILocation(line: 90, column: 22, scope: !348, inlinedAt: !295)
!351 = !DILocation(line: 90, column: 21, scope: !348, inlinedAt: !295)
!352 = !DILocation(line: 90, column: 37, scope: !348, inlinedAt: !295)
!353 = !DILocation(line: 90, column: 3, scope: !348, inlinedAt: !295)
!354 = !DILocation(line: 95, column: 7, scope: !316, inlinedAt: !295)
!355 = !DILocation(line: 95, column: 6, scope: !290, inlinedAt: !295)
!356 = !DILocation(line: 96, column: 23, scope: !315, inlinedAt: !295)
!357 = !DILocation(line: 96, column: 36, scope: !315, inlinedAt: !295)
!358 = !DILocation(line: 96, column: 46, scope: !315, inlinedAt: !295)
!359 = !DILocation(line: 96, column: 44, scope: !315, inlinedAt: !295)
!360 = !DILocation(line: 96, column: 55, scope: !315, inlinedAt: !295)
!361 = !DILocation(line: 98, column: 7, scope: !362, inlinedAt: !295)
!362 = distinct !DILexicalBlock(scope: !315, file: !284, line: 98, column: 7)
!363 = !DILocation(line: 98, column: 7, scope: !315, inlinedAt: !295)
!364 = !DILocation(line: 99, column: 10, scope: !365, inlinedAt: !295)
!365 = distinct !DILexicalBlock(scope: !362, file: !284, line: 98, column: 17)
!366 = !DILocation(line: 99, column: 19, scope: !365, inlinedAt: !295)
!367 = !DILocation(line: 99, column: 8, scope: !365, inlinedAt: !295)
!368 = !DILocation(line: 100, column: 3, scope: !365, inlinedAt: !295)
!369 = !DILocation(line: 100, column: 14, scope: !370, inlinedAt: !295)
!370 = distinct !DILexicalBlock(scope: !362, file: !284, line: 100, column: 14)
!371 = !DILocation(line: 100, column: 14, scope: !362, inlinedAt: !295)
!372 = !DILocation(line: 101, column: 10, scope: !373, inlinedAt: !295)
!373 = distinct !DILexicalBlock(scope: !370, file: !284, line: 100, column: 25)
!374 = !DILocation(line: 101, column: 19, scope: !373, inlinedAt: !295)
!375 = !DILocation(line: 101, column: 8, scope: !373, inlinedAt: !295)
!376 = !DILocation(line: 102, column: 3, scope: !373, inlinedAt: !295)
!377 = !DILocation(line: 103, column: 2, scope: !315, inlinedAt: !295)
!378 = !DILocation(line: 110, column: 6, scope: !379, inlinedAt: !295)
!379 = distinct !DILexicalBlock(scope: !290, file: !284, line: 110, column: 6)
!380 = !DILocation(line: 110, column: 6, scope: !290, inlinedAt: !295)
!381 = !DILocation(line: 111, column: 8, scope: !382, inlinedAt: !295)
!382 = distinct !DILexicalBlock(scope: !379, file: !284, line: 110, column: 17)
!383 = !DILocation(line: 111, column: 5, scope: !382, inlinedAt: !295)
!384 = !DILocation(line: 112, column: 7, scope: !385, inlinedAt: !295)
!385 = distinct !DILexicalBlock(scope: !382, file: !284, line: 112, column: 7)
!386 = !DILocation(line: 112, column: 16, scope: !385, inlinedAt: !295)
!387 = !DILocation(line: 112, column: 20, scope: !385, inlinedAt: !295)
!388 = !DILocation(line: 112, column: 22, scope: !385, inlinedAt: !295)
!389 = !DILocation(line: 112, column: 7, scope: !382, inlinedAt: !295)
!390 = !DILocation(line: 113, column: 22, scope: !391, inlinedAt: !295)
!391 = distinct !DILexicalBlock(scope: !385, file: !284, line: 112, column: 36)
!392 = !DILocation(line: 113, column: 12, scope: !391, inlinedAt: !295)
!393 = !DILocation(line: 113, column: 28, scope: !391, inlinedAt: !295)
!394 = !DILocation(line: 113, column: 38, scope: !391, inlinedAt: !295)
!395 = !DILocation(line: 113, column: 36, scope: !391, inlinedAt: !295)
!396 = !DILocation(line: 113, column: 25, scope: !391, inlinedAt: !295)
!397 = !DILocation(line: 113, column: 11, scope: !391, inlinedAt: !295)
!398 = !DILocation(line: 113, column: 4, scope: !391, inlinedAt: !295)
!399 = !DILocation(line: 115, column: 11, scope: !400, inlinedAt: !295)
!400 = distinct !DILexicalBlock(scope: !385, file: !284, line: 114, column: 10)
!401 = !DILocation(line: 115, column: 16, scope: !400, inlinedAt: !295)
!402 = !DILocation(line: 115, column: 26, scope: !400, inlinedAt: !295)
!403 = !DILocation(line: 115, column: 24, scope: !400, inlinedAt: !295)
!404 = !DILocation(line: 115, column: 15, scope: !400, inlinedAt: !295)
!405 = !DILocation(line: 115, column: 13, scope: !400, inlinedAt: !295)
!406 = !DILocation(line: 115, column: 4, scope: !400, inlinedAt: !295)
!407 = !DILocation(line: 117, column: 13, scope: !408, inlinedAt: !295)
!408 = distinct !DILexicalBlock(scope: !379, file: !284, line: 117, column: 13)
!409 = !DILocation(line: 117, column: 13, scope: !379, inlinedAt: !295)
!410 = !DILocation(line: 118, column: 7, scope: !411, inlinedAt: !295)
!411 = distinct !DILexicalBlock(scope: !412, file: !284, line: 118, column: 7)
!412 = distinct !DILexicalBlock(scope: !408, file: !284, line: 117, column: 24)
!413 = !DILocation(line: 118, column: 7, scope: !412, inlinedAt: !295)
!414 = !DILocation(line: 119, column: 22, scope: !415, inlinedAt: !295)
!415 = distinct !DILexicalBlock(scope: !411, file: !284, line: 118, column: 17)
!416 = !DILocation(line: 119, column: 12, scope: !415, inlinedAt: !295)
!417 = !DILocation(line: 119, column: 28, scope: !415, inlinedAt: !295)
!418 = !DILocation(line: 119, column: 36, scope: !415, inlinedAt: !295)
!419 = !DILocation(line: 119, column: 34, scope: !415, inlinedAt: !295)
!420 = !DILocation(line: 119, column: 25, scope: !415, inlinedAt: !295)
!421 = !DILocation(line: 119, column: 11, scope: !415, inlinedAt: !295)
!422 = !DILocation(line: 119, column: 4, scope: !415, inlinedAt: !295)
!423 = !DILocation(line: 121, column: 11, scope: !424, inlinedAt: !295)
!424 = distinct !DILexicalBlock(scope: !411, file: !284, line: 120, column: 10)
!425 = !DILocation(line: 121, column: 16, scope: !424, inlinedAt: !295)
!426 = !DILocation(line: 121, column: 24, scope: !424, inlinedAt: !295)
!427 = !DILocation(line: 121, column: 22, scope: !424, inlinedAt: !295)
!428 = !DILocation(line: 121, column: 15, scope: !424, inlinedAt: !295)
!429 = !DILocation(line: 121, column: 13, scope: !424, inlinedAt: !295)
!430 = !DILocation(line: 121, column: 4, scope: !424, inlinedAt: !295)
!431 = !DILocation(line: 124, column: 7, scope: !432, inlinedAt: !295)
!432 = distinct !DILexicalBlock(scope: !433, file: !284, line: 124, column: 7)
!433 = distinct !DILexicalBlock(scope: !408, file: !284, line: 123, column: 9)
!434 = !DILocation(line: 124, column: 7, scope: !433, inlinedAt: !295)
!435 = !DILocation(line: 125, column: 23, scope: !436, inlinedAt: !295)
!436 = distinct !DILexicalBlock(scope: !432, file: !284, line: 124, column: 17)
!437 = !DILocation(line: 125, column: 27, scope: !436, inlinedAt: !295)
!438 = !DILocation(line: 125, column: 25, scope: !436, inlinedAt: !295)
!439 = !DILocation(line: 125, column: 35, scope: !436, inlinedAt: !295)
!440 = !DILocation(line: 125, column: 33, scope: !436, inlinedAt: !295)
!441 = !DILocation(line: 125, column: 42, scope: !436, inlinedAt: !295)
!442 = !DILocation(line: 125, column: 40, scope: !436, inlinedAt: !295)
!443 = !DILocation(line: 125, column: 11, scope: !436, inlinedAt: !295)
!444 = !DILocation(line: 125, column: 4, scope: !436, inlinedAt: !295)
!445 = !DILocation(line: 127, column: 12, scope: !446, inlinedAt: !295)
!446 = distinct !DILexicalBlock(scope: !432, file: !284, line: 126, column: 10)
!447 = !DILocation(line: 127, column: 16, scope: !446, inlinedAt: !295)
!448 = !DILocation(line: 127, column: 14, scope: !446, inlinedAt: !295)
!449 = !DILocation(line: 127, column: 24, scope: !446, inlinedAt: !295)
!450 = !DILocation(line: 127, column: 22, scope: !446, inlinedAt: !295)
!451 = !DILocation(line: 127, column: 31, scope: !446, inlinedAt: !295)
!452 = !DILocation(line: 127, column: 29, scope: !446, inlinedAt: !295)
!453 = !DILocation(line: 127, column: 4, scope: !446, inlinedAt: !295)
!454 = !DILocation(line: 130, column: 1, scope: !290, inlinedAt: !295)
!455 = !DILocation(line: 372, column: 2, scope: !283)
!456 = distinct !DISubprogram(name: "k_sleep", scope: !276, file: !276, line: 117, type: !457, scopeLine: 118, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !191)
!457 = !DISubroutineType(types: !458)
!458 = !{!218, !459}
!459 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_timeout_t", file: !56, line: 69, baseType: !460)
!460 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !56, line: 67, size: 64, elements: !461)
!461 = !{!462}
!462 = !DIDerivedType(tag: DW_TAG_member, name: "ticks", scope: !460, file: !56, line: 68, baseType: !55, size: 64)
!463 = !DILocalVariable(name: "timeout", arg: 1, scope: !456, file: !276, line: 117, type: !459)
!464 = !DILocation(line: 117, column: 61, scope: !456)
!465 = !DILocation(line: 126, column: 2, scope: !456)
!466 = !DILocation(line: 126, column: 2, scope: !467)
!467 = distinct !DILexicalBlock(scope: !456, file: !276, line: 126, column: 2)
!468 = !{i32 -2141858429}
!469 = !DILocation(line: 127, column: 9, scope: !456)
!470 = !DILocation(line: 127, column: 2, scope: !456)
!471 = distinct !DISubprogram(name: "main", scope: !65, file: !65, line: 32, type: !157, scopeLine: 32, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !191)
!472 = !DILocation(line: 33, column: 5, scope: !471)
!473 = !DILocation(line: 34, column: 1, scope: !471)
