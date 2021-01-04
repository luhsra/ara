; ModuleID = 'llvm-link'
source_filename = "llvm-link"
target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "thumbv7em-none-unknown-eabi"

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

@threadB_sem = dso_local global %struct.k_sem zeroinitializer, align 4, !dbg !0
@threadA_sem = dso_local global %struct.k_sem zeroinitializer, align 4, !dbg !63
@threadB_stack_area = dso_local global [1024 x %struct.z_thread_stack_element] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/dyn_sems/src/main.c\22.0", align 8, !dbg !91
@threadA_data = dso_local global %struct.k_thread zeroinitializer, align 8, !dbg !212
@threadA_stack_area = dso_local global [1024 x %struct.z_thread_stack_element] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/dyn_sems/src/main.c\22.1", align 8, !dbg !210
@.str = private unnamed_addr constant [26 x i8] c"%s: Hello World from %s!\0A\00", align 1
@.str.1 = private unnamed_addr constant [14 x i8] c"nucleo_f303re\00", align 1
@__func__.threadB = private unnamed_addr constant [8 x i8] c"threadB\00", align 1
@threadB_data = internal global %struct.k_thread zeroinitializer, align 8, !dbg !101
@.str.2 = private unnamed_addr constant [9 x i8] c"thread_b\00", align 1
@__func__.threadA = private unnamed_addr constant [8 x i8] c"threadA\00", align 1
@.str.3 = private unnamed_addr constant [9 x i8] c"thread_a\00", align 1

; Function Attrs: noinline nounwind optnone
define dso_local void @helloLoop(i8*, %struct.k_sem*, %struct.k_sem*) #0 !dbg !219 {
  %4 = alloca i8*, align 4
  %5 = alloca %struct.k_sem*, align 4
  %6 = alloca %struct.k_sem*, align 4
  %7 = alloca i8*, align 4
  %8 = alloca %struct.k_timeout_t, align 8
  store i8* %0, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !225, metadata !DIExpression()), !dbg !226
  store %struct.k_sem* %1, %struct.k_sem** %5, align 4
  call void @llvm.dbg.declare(metadata %struct.k_sem** %5, metadata !227, metadata !DIExpression()), !dbg !228
  store %struct.k_sem* %2, %struct.k_sem** %6, align 4
  call void @llvm.dbg.declare(metadata %struct.k_sem** %6, metadata !229, metadata !DIExpression()), !dbg !230
  call void @llvm.dbg.declare(metadata i8** %7, metadata !231, metadata !DIExpression()), !dbg !232
  br label %9, !dbg !233

9:                                                ; preds = %30, %3
  %10 = load %struct.k_sem*, %struct.k_sem** %5, align 4, !dbg !234
  %11 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %8, i32 0, i32 0, !dbg !236
  store i64 -1, i64* %11, align 8, !dbg !236
  %12 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %8, i32 0, i32 0, !dbg !237
  %13 = bitcast i64* %12 to [1 x i64]*, !dbg !237
  %14 = load [1 x i64], [1 x i64]* %13, align 8, !dbg !237
  %15 = call i32 @k_sem_take(%struct.k_sem* %10, [1 x i64] %14) #3, !dbg !237
  %16 = call %struct.k_thread* @k_current_get() #3, !dbg !238
  %17 = call i8* @k_thread_name_get(%struct.k_thread* %16) #3, !dbg !239
  store i8* %17, i8** %7, align 4, !dbg !240
  %18 = load i8*, i8** %7, align 4, !dbg !241
  %19 = icmp ne i8* %18, null, !dbg !243
  br i1 %19, label %20, label %28, !dbg !244

20:                                               ; preds = %9
  %21 = load i8*, i8** %7, align 4, !dbg !245
  %22 = getelementptr i8, i8* %21, i32 0, !dbg !245
  %23 = load i8, i8* %22, align 1, !dbg !245
  %24 = zext i8 %23 to i32, !dbg !245
  %25 = icmp ne i32 %24, 0, !dbg !246
  br i1 %25, label %26, label %28, !dbg !247

26:                                               ; preds = %20
  %27 = load i8*, i8** %7, align 4, !dbg !248
  call void (i8*, ...) @printk(i8* getelementptr inbounds ([26 x i8], [26 x i8]* @.str, i32 0, i32 0), i8* %27, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i32 0, i32 0)) #3, !dbg !250
  br label %30, !dbg !251

28:                                               ; preds = %20, %9
  %29 = load i8*, i8** %4, align 4, !dbg !252
  call void (i8*, ...) @printk(i8* getelementptr inbounds ([26 x i8], [26 x i8]* @.str, i32 0, i32 0), i8* %29, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i32 0, i32 0)) #3, !dbg !254
  br label %30

30:                                               ; preds = %28, %26
  %31 = call i32 @k_msleep(i32 500) #3, !dbg !255
  %32 = load %struct.k_sem*, %struct.k_sem** %6, align 4, !dbg !256
  call void @k_sem_give(%struct.k_sem* %32) #3, !dbg !257
  br label %9, !dbg !233, !llvm.loop !258
}

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: noinline nounwind optnone
define internal i32 @k_sem_take(%struct.k_sem*, [1 x i64]) #0 !dbg !260 {
  %3 = alloca %struct.k_timeout_t, align 8
  %4 = alloca %struct.k_sem*, align 4
  %5 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0
  %6 = bitcast i64* %5 to [1 x i64]*
  store [1 x i64] %1, [1 x i64]* %6, align 8
  store %struct.k_sem* %0, %struct.k_sem** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.k_sem** %4, metadata !268, metadata !DIExpression()), !dbg !269
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %3, metadata !270, metadata !DIExpression()), !dbg !271
  br label %7, !dbg !272

7:                                                ; preds = %2
  call void asm sideeffect "", "~{memory}"() #4, !dbg !273, !srcloc !275
  br label %8, !dbg !273

8:                                                ; preds = %7
  %9 = load %struct.k_sem*, %struct.k_sem** %4, align 4, !dbg !276
  %10 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !277
  %11 = bitcast i64* %10 to [1 x i64]*, !dbg !277
  %12 = load [1 x i64], [1 x i64]* %11, align 8, !dbg !277
  %13 = call i32 @z_impl_k_sem_take(%struct.k_sem* %9, [1 x i64] %12) #3, !dbg !277
  ret i32 %13, !dbg !278
}

; Function Attrs: noinline nounwind optnone
define internal %struct.k_thread* @k_current_get() #0 !dbg !279 {
  br label %1, !dbg !284

1:                                                ; preds = %0
  call void asm sideeffect "", "~{memory}"() #4, !dbg !285, !srcloc !287
  br label %2, !dbg !285

2:                                                ; preds = %1
  %3 = call %struct.k_thread* bitcast (%struct.k_thread* (...)* @z_impl_k_current_get to %struct.k_thread* ()*)() #3, !dbg !288
  ret %struct.k_thread* %3, !dbg !289
}

declare dso_local i8* @k_thread_name_get(%struct.k_thread*) #2

declare dso_local void @printk(i8*, ...) #2

; Function Attrs: noinline nounwind optnone
define internal i32 @k_msleep(i32) #0 !dbg !290 {
  %2 = alloca i32, align 4
  %3 = alloca %struct.k_timeout_t, align 8
  store i32 %0, i32* %2, align 4
  call void @llvm.dbg.declare(metadata i32* %2, metadata !294, metadata !DIExpression()), !dbg !295
  %4 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !296
  %5 = load i32, i32* %2, align 4, !dbg !296
  %6 = icmp sgt i32 %5, 0, !dbg !296
  br i1 %6, label %7, label %9, !dbg !296

7:                                                ; preds = %1
  %8 = load i32, i32* %2, align 4, !dbg !296
  br label %10, !dbg !296

9:                                                ; preds = %1
  br label %10, !dbg !296

10:                                               ; preds = %9, %7
  %11 = phi i32 [ %8, %7 ], [ 0, %9 ], !dbg !296
  %12 = sext i32 %11 to i64, !dbg !296
  %13 = call i64 @k_ms_to_ticks_ceil64(i64 %12) #3, !dbg !296
  store i64 %13, i64* %4, align 8, !dbg !296
  %14 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !297
  %15 = bitcast i64* %14 to [1 x i64]*, !dbg !297
  %16 = load [1 x i64], [1 x i64]* %15, align 8, !dbg !297
  %17 = call i32 @k_sleep([1 x i64] %16) #3, !dbg !297
  ret i32 %17, !dbg !298
}

; Function Attrs: noinline nounwind optnone
define internal void @k_sem_give(%struct.k_sem*) #0 !dbg !299 {
  %2 = alloca %struct.k_sem*, align 4
  store %struct.k_sem* %0, %struct.k_sem** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_sem** %2, metadata !302, metadata !DIExpression()), !dbg !303
  br label %3, !dbg !304

3:                                                ; preds = %1
  call void asm sideeffect "", "~{memory}"() #4, !dbg !305, !srcloc !307
  br label %4, !dbg !305

4:                                                ; preds = %3
  %5 = load %struct.k_sem*, %struct.k_sem** %2, align 4, !dbg !308
  call void @z_impl_k_sem_give(%struct.k_sem* %5) #3, !dbg !309
  ret void, !dbg !310
}

declare dso_local void @z_impl_k_sem_give(%struct.k_sem*) #2

; Function Attrs: noinline nounwind optnone
define internal i64 @k_ms_to_ticks_ceil64(i64) #0 !dbg !311 {
  %2 = alloca i64, align 8
  %3 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %3, metadata !317, metadata !DIExpression()), !dbg !322
  %4 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !324, metadata !DIExpression()), !dbg !325
  %5 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %5, metadata !326, metadata !DIExpression()), !dbg !327
  %6 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %6, metadata !328, metadata !DIExpression()), !dbg !329
  %7 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %7, metadata !330, metadata !DIExpression()), !dbg !331
  %8 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %8, metadata !332, metadata !DIExpression()), !dbg !333
  %9 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %9, metadata !334, metadata !DIExpression()), !dbg !335
  %10 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %10, metadata !336, metadata !DIExpression()), !dbg !337
  %11 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %11, metadata !338, metadata !DIExpression()), !dbg !339
  %12 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %12, metadata !340, metadata !DIExpression()), !dbg !341
  %13 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %13, metadata !342, metadata !DIExpression()), !dbg !345
  %14 = alloca i64, align 8
  store i64 %0, i64* %14, align 8
  call void @llvm.dbg.declare(metadata i64* %14, metadata !346, metadata !DIExpression()), !dbg !347
  %15 = load i64, i64* %14, align 8, !dbg !348
  store i64 %15, i64* %3, align 8
  store i32 1000, i32* %4, align 4
  store i32 10000, i32* %5, align 4
  store i8 1, i8* %6, align 1
  store i8 0, i8* %7, align 1
  store i8 1, i8* %8, align 1
  store i8 0, i8* %9, align 1
  %16 = load i8, i8* %6, align 1, !dbg !349
  %17 = trunc i8 %16 to i1, !dbg !349
  br i1 %17, label %18, label %27, !dbg !350

18:                                               ; preds = %1
  %19 = load i32, i32* %5, align 4, !dbg !351
  %20 = load i32, i32* %4, align 4, !dbg !352
  %21 = icmp ugt i32 %19, %20, !dbg !353
  br i1 %21, label %22, label %27, !dbg !354

22:                                               ; preds = %18
  %23 = load i32, i32* %5, align 4, !dbg !355
  %24 = load i32, i32* %4, align 4, !dbg !356
  %25 = urem i32 %23, %24, !dbg !357
  %26 = icmp eq i32 %25, 0, !dbg !358
  br label %27

27:                                               ; preds = %22, %18, %1
  %28 = phi i1 [ false, %18 ], [ false, %1 ], [ %26, %22 ], !dbg !359
  %29 = zext i1 %28 to i8, !dbg !337
  store i8 %29, i8* %10, align 1, !dbg !337
  %30 = load i8, i8* %6, align 1, !dbg !360
  %31 = trunc i8 %30 to i1, !dbg !360
  br i1 %31, label %32, label %41, !dbg !361

32:                                               ; preds = %27
  %33 = load i32, i32* %4, align 4, !dbg !362
  %34 = load i32, i32* %5, align 4, !dbg !363
  %35 = icmp ugt i32 %33, %34, !dbg !364
  br i1 %35, label %36, label %41, !dbg !365

36:                                               ; preds = %32
  %37 = load i32, i32* %4, align 4, !dbg !366
  %38 = load i32, i32* %5, align 4, !dbg !367
  %39 = urem i32 %37, %38, !dbg !368
  %40 = icmp eq i32 %39, 0, !dbg !369
  br label %41

41:                                               ; preds = %36, %32, %27
  %42 = phi i1 [ false, %32 ], [ false, %27 ], [ %40, %36 ], !dbg !359
  %43 = zext i1 %42 to i8, !dbg !339
  store i8 %43, i8* %11, align 1, !dbg !339
  %44 = load i32, i32* %4, align 4, !dbg !370
  %45 = load i32, i32* %5, align 4, !dbg !372
  %46 = icmp eq i32 %44, %45, !dbg !373
  br i1 %46, label %47, label %58, !dbg !374

47:                                               ; preds = %41
  %48 = load i8, i8* %7, align 1, !dbg !375
  %49 = trunc i8 %48 to i1, !dbg !375
  br i1 %49, label %50, label %54, !dbg !375

50:                                               ; preds = %47
  %51 = load i64, i64* %3, align 8, !dbg !377
  %52 = trunc i64 %51 to i32, !dbg !378
  %53 = zext i32 %52 to i64, !dbg !379
  br label %56, !dbg !375

54:                                               ; preds = %47
  %55 = load i64, i64* %3, align 8, !dbg !380
  br label %56, !dbg !375

56:                                               ; preds = %54, %50
  %57 = phi i64 [ %53, %50 ], [ %55, %54 ], !dbg !375
  store i64 %57, i64* %2, align 8, !dbg !381
  br label %160, !dbg !381

58:                                               ; preds = %41
  store i64 0, i64* %12, align 8, !dbg !341
  %59 = load i8, i8* %10, align 1, !dbg !382
  %60 = trunc i8 %59 to i1, !dbg !382
  br i1 %60, label %87, label %61, !dbg !383

61:                                               ; preds = %58
  %62 = load i8, i8* %11, align 1, !dbg !384
  %63 = trunc i8 %62 to i1, !dbg !384
  br i1 %63, label %64, label %68, !dbg !384

64:                                               ; preds = %61
  %65 = load i32, i32* %4, align 4, !dbg !385
  %66 = load i32, i32* %5, align 4, !dbg !386
  %67 = udiv i32 %65, %66, !dbg !387
  br label %70, !dbg !384

68:                                               ; preds = %61
  %69 = load i32, i32* %4, align 4, !dbg !388
  br label %70, !dbg !384

70:                                               ; preds = %68, %64
  %71 = phi i32 [ %67, %64 ], [ %69, %68 ], !dbg !384
  store i32 %71, i32* %13, align 4, !dbg !345
  %72 = load i8, i8* %8, align 1, !dbg !389
  %73 = trunc i8 %72 to i1, !dbg !389
  br i1 %73, label %74, label %78, !dbg !391

74:                                               ; preds = %70
  %75 = load i32, i32* %13, align 4, !dbg !392
  %76 = sub i32 %75, 1, !dbg !394
  %77 = zext i32 %76 to i64, !dbg !392
  store i64 %77, i64* %12, align 8, !dbg !395
  br label %86, !dbg !396

78:                                               ; preds = %70
  %79 = load i8, i8* %9, align 1, !dbg !397
  %80 = trunc i8 %79 to i1, !dbg !397
  br i1 %80, label %81, label %85, !dbg !399

81:                                               ; preds = %78
  %82 = load i32, i32* %13, align 4, !dbg !400
  %83 = udiv i32 %82, 2, !dbg !402
  %84 = zext i32 %83 to i64, !dbg !400
  store i64 %84, i64* %12, align 8, !dbg !403
  br label %85, !dbg !404

85:                                               ; preds = %81, %78
  br label %86

86:                                               ; preds = %85, %74
  br label %87, !dbg !405

87:                                               ; preds = %86, %58
  %88 = load i8, i8* %11, align 1, !dbg !406
  %89 = trunc i8 %88 to i1, !dbg !406
  br i1 %89, label %90, label %114, !dbg !408

90:                                               ; preds = %87
  %91 = load i64, i64* %12, align 8, !dbg !409
  %92 = load i64, i64* %3, align 8, !dbg !411
  %93 = add i64 %92, %91, !dbg !411
  store i64 %93, i64* %3, align 8, !dbg !411
  %94 = load i8, i8* %7, align 1, !dbg !412
  %95 = trunc i8 %94 to i1, !dbg !412
  br i1 %95, label %96, label %107, !dbg !414

96:                                               ; preds = %90
  %97 = load i64, i64* %3, align 8, !dbg !415
  %98 = icmp ult i64 %97, 4294967296, !dbg !416
  br i1 %98, label %99, label %107, !dbg !417

99:                                               ; preds = %96
  %100 = load i64, i64* %3, align 8, !dbg !418
  %101 = trunc i64 %100 to i32, !dbg !420
  %102 = load i32, i32* %4, align 4, !dbg !421
  %103 = load i32, i32* %5, align 4, !dbg !422
  %104 = udiv i32 %102, %103, !dbg !423
  %105 = udiv i32 %101, %104, !dbg !424
  %106 = zext i32 %105 to i64, !dbg !425
  store i64 %106, i64* %2, align 8, !dbg !426
  br label %160, !dbg !426

107:                                              ; preds = %96, %90
  %108 = load i64, i64* %3, align 8, !dbg !427
  %109 = load i32, i32* %4, align 4, !dbg !429
  %110 = load i32, i32* %5, align 4, !dbg !430
  %111 = udiv i32 %109, %110, !dbg !431
  %112 = zext i32 %111 to i64, !dbg !432
  %113 = udiv i64 %108, %112, !dbg !433
  store i64 %113, i64* %2, align 8, !dbg !434
  br label %160, !dbg !434

114:                                              ; preds = %87
  %115 = load i8, i8* %10, align 1, !dbg !435
  %116 = trunc i8 %115 to i1, !dbg !435
  br i1 %116, label %117, label %135, !dbg !437

117:                                              ; preds = %114
  %118 = load i8, i8* %7, align 1, !dbg !438
  %119 = trunc i8 %118 to i1, !dbg !438
  br i1 %119, label %120, label %128, !dbg !441

120:                                              ; preds = %117
  %121 = load i64, i64* %3, align 8, !dbg !442
  %122 = trunc i64 %121 to i32, !dbg !444
  %123 = load i32, i32* %5, align 4, !dbg !445
  %124 = load i32, i32* %4, align 4, !dbg !446
  %125 = udiv i32 %123, %124, !dbg !447
  %126 = mul i32 %122, %125, !dbg !448
  %127 = zext i32 %126 to i64, !dbg !449
  store i64 %127, i64* %2, align 8, !dbg !450
  br label %160, !dbg !450

128:                                              ; preds = %117
  %129 = load i64, i64* %3, align 8, !dbg !451
  %130 = load i32, i32* %5, align 4, !dbg !453
  %131 = load i32, i32* %4, align 4, !dbg !454
  %132 = udiv i32 %130, %131, !dbg !455
  %133 = zext i32 %132 to i64, !dbg !456
  %134 = mul i64 %129, %133, !dbg !457
  store i64 %134, i64* %2, align 8, !dbg !458
  br label %160, !dbg !458

135:                                              ; preds = %114
  %136 = load i8, i8* %7, align 1, !dbg !459
  %137 = trunc i8 %136 to i1, !dbg !459
  br i1 %137, label %138, label %150, !dbg !462

138:                                              ; preds = %135
  %139 = load i64, i64* %3, align 8, !dbg !463
  %140 = load i32, i32* %5, align 4, !dbg !465
  %141 = zext i32 %140 to i64, !dbg !465
  %142 = mul i64 %139, %141, !dbg !466
  %143 = load i64, i64* %12, align 8, !dbg !467
  %144 = add i64 %142, %143, !dbg !468
  %145 = load i32, i32* %4, align 4, !dbg !469
  %146 = zext i32 %145 to i64, !dbg !469
  %147 = udiv i64 %144, %146, !dbg !470
  %148 = trunc i64 %147 to i32, !dbg !471
  %149 = zext i32 %148 to i64, !dbg !471
  store i64 %149, i64* %2, align 8, !dbg !472
  br label %160, !dbg !472

150:                                              ; preds = %135
  %151 = load i64, i64* %3, align 8, !dbg !473
  %152 = load i32, i32* %5, align 4, !dbg !475
  %153 = zext i32 %152 to i64, !dbg !475
  %154 = mul i64 %151, %153, !dbg !476
  %155 = load i64, i64* %12, align 8, !dbg !477
  %156 = add i64 %154, %155, !dbg !478
  %157 = load i32, i32* %4, align 4, !dbg !479
  %158 = zext i32 %157 to i64, !dbg !479
  %159 = udiv i64 %156, %158, !dbg !480
  store i64 %159, i64* %2, align 8, !dbg !481
  br label %160, !dbg !481

160:                                              ; preds = %150, %138, %128, %120, %107, %99, %56
  %161 = load i64, i64* %2, align 8, !dbg !482
  ret i64 %161, !dbg !483
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_sleep([1 x i64]) #0 !dbg !484 {
  %2 = alloca %struct.k_timeout_t, align 8
  %3 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0
  %4 = bitcast i64* %3 to [1 x i64]*
  store [1 x i64] %0, [1 x i64]* %4, align 8
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %2, metadata !487, metadata !DIExpression()), !dbg !488
  br label %5, !dbg !489

5:                                                ; preds = %1
  call void asm sideeffect "", "~{memory}"() #4, !dbg !490, !srcloc !492
  br label %6, !dbg !490

6:                                                ; preds = %5
  %7 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !493
  %8 = bitcast i64* %7 to [1 x i64]*, !dbg !493
  %9 = load [1 x i64], [1 x i64]* %8, align 8, !dbg !493
  %10 = call i32 @z_impl_k_sleep([1 x i64] %9) #3, !dbg !493
  ret i32 %10, !dbg !494
}

declare dso_local i32 @z_impl_k_sleep([1 x i64]) #2

declare dso_local %struct.k_thread* @z_impl_k_current_get(...) #2

declare dso_local i32 @z_impl_k_sem_take(%struct.k_sem*, [1 x i64]) #2

; Function Attrs: noinline nounwind optnone
define dso_local void @threadB(i8*, i8*, i8*) #0 !dbg !495 {
  %4 = alloca i8*, align 4
  %5 = alloca i8*, align 4
  %6 = alloca i8*, align 4
  store i8* %0, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !498, metadata !DIExpression()), !dbg !499
  store i8* %1, i8** %5, align 4
  call void @llvm.dbg.declare(metadata i8** %5, metadata !500, metadata !DIExpression()), !dbg !501
  store i8* %2, i8** %6, align 4
  call void @llvm.dbg.declare(metadata i8** %6, metadata !502, metadata !DIExpression()), !dbg !503
  %7 = load i8*, i8** %4, align 4, !dbg !504
  %8 = load i8*, i8** %5, align 4, !dbg !505
  %9 = load i8*, i8** %6, align 4, !dbg !506
  call void @helloLoop(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__func__.threadB, i32 0, i32 0), %struct.k_sem* @threadB_sem, %struct.k_sem* @threadA_sem) #3, !dbg !507
  ret void, !dbg !508
}

; Function Attrs: noinline nounwind optnone
define dso_local void @threadA(i8*, i8*, i8*) #0 !dbg !509 {
  %4 = alloca i8*, align 4
  %5 = alloca i8*, align 4
  %6 = alloca i8*, align 4
  %7 = alloca %struct.k_thread*, align 4
  %8 = alloca %struct.k_thread*, align 4
  %9 = alloca %struct.k_timeout_t, align 8
  store i8* %0, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !510, metadata !DIExpression()), !dbg !511
  store i8* %1, i8** %5, align 4
  call void @llvm.dbg.declare(metadata i8** %5, metadata !512, metadata !DIExpression()), !dbg !513
  store i8* %2, i8** %6, align 4
  call void @llvm.dbg.declare(metadata i8** %6, metadata !514, metadata !DIExpression()), !dbg !515
  %10 = load i8*, i8** %4, align 4, !dbg !516
  %11 = load i8*, i8** %5, align 4, !dbg !517
  %12 = load i8*, i8** %6, align 4, !dbg !518
  call void @llvm.dbg.declare(metadata %struct.k_thread** %7, metadata !519, metadata !DIExpression()), !dbg !520
  store %struct.k_thread* @threadB_data, %struct.k_thread** %7, align 4, !dbg !520
  %13 = call i32 @k_sem_init(%struct.k_sem* @threadA_sem, i32 1, i32 1) #3, !dbg !521
  %14 = call i32 @k_sem_init(%struct.k_sem* @threadB_sem, i32 0, i32 1) #3, !dbg !522
  call void @llvm.dbg.declare(metadata %struct.k_thread** %8, metadata !523, metadata !DIExpression()), !dbg !524
  %15 = load %struct.k_thread*, %struct.k_thread** %7, align 4, !dbg !525
  %16 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %9, i32 0, i32 0, !dbg !526
  store i64 0, i64* %16, align 8, !dbg !526
  %17 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %9, i32 0, i32 0, !dbg !527
  %18 = bitcast i64* %17 to [1 x i64]*, !dbg !527
  %19 = load [1 x i64], [1 x i64]* %18, align 8, !dbg !527
  %20 = call %struct.k_thread* @k_thread_create(%struct.k_thread* %15, %struct.z_thread_stack_element* getelementptr inbounds ([1024 x %struct.z_thread_stack_element], [1024 x %struct.z_thread_stack_element]* @threadB_stack_area, i32 0, i32 0), i32 1024, void (i8*, i8*, i8*)* @threadB, i8* null, i8* null, i8* null, i32 7, i32 0, [1 x i64] %19) #3, !dbg !527
  store %struct.k_thread* %20, %struct.k_thread** %8, align 4, !dbg !524
  %21 = load %struct.k_thread*, %struct.k_thread** %8, align 4, !dbg !528
  %22 = call i32 @k_thread_name_set(%struct.k_thread* %21, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.2, i32 0, i32 0)) #3, !dbg !529
  call void @helloLoop(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__func__.threadA, i32 0, i32 0), %struct.k_sem* @threadA_sem, %struct.k_sem* @threadB_sem) #3, !dbg !530
  ret void, !dbg !531
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_sem_init(%struct.k_sem*, i32, i32) #0 !dbg !532 {
  %4 = alloca %struct.k_sem*, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  store %struct.k_sem* %0, %struct.k_sem** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.k_sem** %4, metadata !535, metadata !DIExpression()), !dbg !536
  store i32 %1, i32* %5, align 4
  call void @llvm.dbg.declare(metadata i32* %5, metadata !537, metadata !DIExpression()), !dbg !538
  store i32 %2, i32* %6, align 4
  call void @llvm.dbg.declare(metadata i32* %6, metadata !539, metadata !DIExpression()), !dbg !540
  br label %7, !dbg !541

7:                                                ; preds = %3
  call void asm sideeffect "", "~{memory}"() #4, !dbg !542, !srcloc !544
  br label %8, !dbg !542

8:                                                ; preds = %7
  %9 = load %struct.k_sem*, %struct.k_sem** %4, align 4, !dbg !545
  %10 = load i32, i32* %5, align 4, !dbg !546
  %11 = load i32, i32* %6, align 4, !dbg !547
  %12 = call i32 @z_impl_k_sem_init(%struct.k_sem* %9, i32 %10, i32 %11) #3, !dbg !548
  ret i32 %12, !dbg !549
}

; Function Attrs: noinline nounwind optnone
define internal %struct.k_thread* @k_thread_create(%struct.k_thread*, %struct.z_thread_stack_element*, i32, void (i8*, i8*, i8*)*, i8*, i8*, i8*, i32, i32, [1 x i64]) #0 !dbg !550 {
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
  call void @llvm.dbg.declare(metadata %struct.k_thread** %12, metadata !558, metadata !DIExpression()), !dbg !559
  store %struct.z_thread_stack_element* %1, %struct.z_thread_stack_element** %13, align 4
  call void @llvm.dbg.declare(metadata %struct.z_thread_stack_element** %13, metadata !560, metadata !DIExpression()), !dbg !561
  store i32 %2, i32* %14, align 4
  call void @llvm.dbg.declare(metadata i32* %14, metadata !562, metadata !DIExpression()), !dbg !563
  store void (i8*, i8*, i8*)* %3, void (i8*, i8*, i8*)** %15, align 4
  call void @llvm.dbg.declare(metadata void (i8*, i8*, i8*)** %15, metadata !564, metadata !DIExpression()), !dbg !565
  store i8* %4, i8** %16, align 4
  call void @llvm.dbg.declare(metadata i8** %16, metadata !566, metadata !DIExpression()), !dbg !567
  store i8* %5, i8** %17, align 4
  call void @llvm.dbg.declare(metadata i8** %17, metadata !568, metadata !DIExpression()), !dbg !569
  store i8* %6, i8** %18, align 4
  call void @llvm.dbg.declare(metadata i8** %18, metadata !570, metadata !DIExpression()), !dbg !571
  store i32 %7, i32* %19, align 4
  call void @llvm.dbg.declare(metadata i32* %19, metadata !572, metadata !DIExpression()), !dbg !573
  store i32 %8, i32* %20, align 4
  call void @llvm.dbg.declare(metadata i32* %20, metadata !574, metadata !DIExpression()), !dbg !575
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %11, metadata !576, metadata !DIExpression()), !dbg !577
  br label %23, !dbg !578

23:                                               ; preds = %10
  call void asm sideeffect "", "~{memory}"() #4, !dbg !579, !srcloc !581
  br label %24, !dbg !579

24:                                               ; preds = %23
  %25 = load %struct.k_thread*, %struct.k_thread** %12, align 4, !dbg !582
  %26 = load %struct.z_thread_stack_element*, %struct.z_thread_stack_element** %13, align 4, !dbg !583
  %27 = load i32, i32* %14, align 4, !dbg !584
  %28 = load void (i8*, i8*, i8*)*, void (i8*, i8*, i8*)** %15, align 4, !dbg !585
  %29 = load i8*, i8** %16, align 4, !dbg !586
  %30 = load i8*, i8** %17, align 4, !dbg !587
  %31 = load i8*, i8** %18, align 4, !dbg !588
  %32 = load i32, i32* %19, align 4, !dbg !589
  %33 = load i32, i32* %20, align 4, !dbg !590
  %34 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %11, i32 0, i32 0, !dbg !591
  %35 = bitcast i64* %34 to [1 x i64]*, !dbg !591
  %36 = load [1 x i64], [1 x i64]* %35, align 8, !dbg !591
  %37 = call %struct.k_thread* @z_impl_k_thread_create(%struct.k_thread* %25, %struct.z_thread_stack_element* %26, i32 %27, void (i8*, i8*, i8*)* %28, i8* %29, i8* %30, i8* %31, i32 %32, i32 %33, [1 x i64] %36) #3, !dbg !591
  ret %struct.k_thread* %37, !dbg !592
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_thread_name_set(%struct.k_thread*, i8*) #0 !dbg !593 {
  %3 = alloca %struct.k_thread*, align 4
  %4 = alloca i8*, align 4
  store %struct.k_thread* %0, %struct.k_thread** %3, align 4
  call void @llvm.dbg.declare(metadata %struct.k_thread** %3, metadata !596, metadata !DIExpression()), !dbg !597
  store i8* %1, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !598, metadata !DIExpression()), !dbg !599
  br label %5, !dbg !600

5:                                                ; preds = %2
  call void asm sideeffect "", "~{memory}"() #4, !dbg !601, !srcloc !603
  br label %6, !dbg !601

6:                                                ; preds = %5
  %7 = load %struct.k_thread*, %struct.k_thread** %3, align 4, !dbg !604
  %8 = load i8*, i8** %4, align 4, !dbg !605
  %9 = call i32 @z_impl_k_thread_name_set(%struct.k_thread* %7, i8* %8) #3, !dbg !606
  ret i32 %9, !dbg !607
}

declare dso_local i32 @z_impl_k_thread_name_set(%struct.k_thread*, i8*) #2

declare dso_local %struct.k_thread* @z_impl_k_thread_create(%struct.k_thread*, %struct.z_thread_stack_element*, i32, void (i8*, i8*, i8*)*, i8*, i8*, i8*, i32, i32, [1 x i64]) #2

declare dso_local i32 @z_impl_k_sem_init(%struct.k_sem*, i32, i32) #2

; Function Attrs: noinline nounwind optnone
define dso_local void @main() #0 !dbg !608 {
  %1 = alloca %struct.k_thread*, align 4
  %2 = alloca %struct.k_timeout_t, align 8
  call void @llvm.dbg.declare(metadata %struct.k_thread** %1, metadata !609, metadata !DIExpression()), !dbg !610
  %3 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !611
  store i64 0, i64* %3, align 8, !dbg !611
  %4 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !612
  %5 = bitcast i64* %4 to [1 x i64]*, !dbg !612
  %6 = load [1 x i64], [1 x i64]* %5, align 8, !dbg !612
  %7 = call %struct.k_thread* @k_thread_create(%struct.k_thread* @threadA_data, %struct.z_thread_stack_element* getelementptr inbounds ([1024 x %struct.z_thread_stack_element], [1024 x %struct.z_thread_stack_element]* @threadA_stack_area, i32 0, i32 0), i32 1024, void (i8*, i8*, i8*)* @threadA, i8* null, i8* null, i8* null, i32 7, i32 0, [1 x i64] %6) #3, !dbg !612
  store %struct.k_thread* %7, %struct.k_thread** %1, align 4, !dbg !610
  %8 = load %struct.k_thread*, %struct.k_thread** %1, align 4, !dbg !613
  %9 = call i32 @k_thread_name_set(%struct.k_thread* %8, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.3, i32 0, i32 0)) #3, !dbg !614
  ret void, !dbg !615
}

attributes #0 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #1 = { nounwind readnone speculatable }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #3 = { nobuiltin }
attributes #4 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.ident = !{!214}
!llvm.module.flags = !{!215, !216, !217, !218}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "threadB_sem", scope: !2, file: !65, line: 39, type: !66, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !52, globals: !62, nameTableKind: None)
!3 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/dyn_sems/src/main.c", directory: "/home/kenny/ara/build/appl/Zephyr/dyn_sems")
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
!62 = !{!63, !0, !91, !101, !210, !212}
!63 = !DIGlobalVariableExpression(var: !64, expr: !DIExpression())
!64 = distinct !DIGlobalVariable(name: "threadA_sem", scope: !2, file: !65, line: 39, type: !66, isLocal: false, isDefinition: true)
!65 = !DIFile(filename: "appl/Zephyr/dyn_sems/src/main.c", directory: "/home/kenny/ara")
!66 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_sem", file: !6, line: 3704, size: 128, elements: !67)
!67 = !{!68, !89, !90}
!68 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !66, file: !6, line: 3705, baseType: !69, size: 64)
!69 = !DIDerivedType(tag: DW_TAG_typedef, name: "_wait_q_t", file: !70, line: 210, baseType: !71)
!70 = !DIFile(filename: "zephyrproject/zephyr/include/kernel_structs.h", directory: "/home/kenny")
!71 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !70, line: 208, size: 64, elements: !72)
!72 = !{!73}
!73 = !DIDerivedType(tag: DW_TAG_member, name: "waitq", scope: !71, file: !70, line: 209, baseType: !74, size: 64)
!74 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dlist_t", file: !75, line: 42, baseType: !76)
!75 = !DIFile(filename: "zephyrproject/zephyr/include/sys/dlist.h", directory: "/home/kenny")
!76 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_dnode", file: !75, line: 31, size: 64, elements: !77)
!77 = !{!78, !84}
!78 = !DIDerivedType(tag: DW_TAG_member, scope: !76, file: !75, line: 32, baseType: !79, size: 32)
!79 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !76, file: !75, line: 32, size: 32, elements: !80)
!80 = !{!81, !83}
!81 = !DIDerivedType(tag: DW_TAG_member, name: "head", scope: !79, file: !75, line: 33, baseType: !82, size: 32)
!82 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !76, size: 32)
!83 = !DIDerivedType(tag: DW_TAG_member, name: "next", scope: !79, file: !75, line: 34, baseType: !82, size: 32)
!84 = !DIDerivedType(tag: DW_TAG_member, scope: !76, file: !75, line: 36, baseType: !85, size: 32, offset: 32)
!85 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !76, file: !75, line: 36, size: 32, elements: !86)
!86 = !{!87, !88}
!87 = !DIDerivedType(tag: DW_TAG_member, name: "tail", scope: !85, file: !75, line: 37, baseType: !82, size: 32)
!88 = !DIDerivedType(tag: DW_TAG_member, name: "prev", scope: !85, file: !75, line: 38, baseType: !82, size: 32)
!89 = !DIDerivedType(tag: DW_TAG_member, name: "count", scope: !66, file: !6, line: 3706, baseType: !60, size: 32, offset: 64)
!90 = !DIDerivedType(tag: DW_TAG_member, name: "limit", scope: !66, file: !6, line: 3707, baseType: !60, size: 32, offset: 96)
!91 = !DIGlobalVariableExpression(var: !92, expr: !DIExpression())
!92 = distinct !DIGlobalVariable(name: "threadB_stack_area", scope: !2, file: !65, line: 50, type: !93, isLocal: false, isDefinition: true, align: 64)
!93 = !DICompositeType(tag: DW_TAG_array_type, baseType: !94, size: 8192, elements: !99)
!94 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "z_thread_stack_element", file: !95, line: 35, size: 8, elements: !96)
!95 = !DIFile(filename: "zephyrproject/zephyr/include/sys/thread_stack.h", directory: "/home/kenny")
!96 = !{!97}
!97 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !94, file: !95, line: 36, baseType: !98, size: 8)
!98 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_unsigned_char)
!99 = !{!100}
!100 = !DISubrange(count: 1024)
!101 = !DIGlobalVariableExpression(var: !102, expr: !DIExpression())
!102 = distinct !DIGlobalVariable(name: "threadB_data", scope: !2, file: !65, line: 51, type: !103, isLocal: true, isDefinition: true)
!103 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_thread", file: !6, line: 570, size: 1024, elements: !104)
!104 = !{!105, !154, !167, !168, !172, !173, !183, !205}
!105 = !DIDerivedType(tag: DW_TAG_member, name: "base", scope: !103, file: !6, line: 572, baseType: !106, size: 448)
!106 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_base", file: !6, line: 441, size: 448, elements: !107)
!107 = !{!108, !122, !124, !126, !127, !140, !141, !142, !153}
!108 = !DIDerivedType(tag: DW_TAG_member, scope: !106, file: !6, line: 444, baseType: !109, size: 64)
!109 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !106, file: !6, line: 444, size: 64, elements: !110)
!110 = !{!111, !113}
!111 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_dlist", scope: !109, file: !6, line: 445, baseType: !112, size: 64)
!112 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dnode_t", file: !75, line: 43, baseType: !76)
!113 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_rb", scope: !109, file: !6, line: 446, baseType: !114, size: 64)
!114 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "rbnode", file: !115, line: 48, size: 64, elements: !116)
!115 = !DIFile(filename: "zephyrproject/zephyr/include/sys/rb.h", directory: "/home/kenny")
!116 = !{!117}
!117 = !DIDerivedType(tag: DW_TAG_member, name: "children", scope: !114, file: !115, line: 49, baseType: !118, size: 64)
!118 = !DICompositeType(tag: DW_TAG_array_type, baseType: !119, size: 64, elements: !120)
!119 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !114, size: 32)
!120 = !{!121}
!121 = !DISubrange(count: 2)
!122 = !DIDerivedType(tag: DW_TAG_member, name: "pended_on", scope: !106, file: !6, line: 452, baseType: !123, size: 32, offset: 64)
!123 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !69, size: 32)
!124 = !DIDerivedType(tag: DW_TAG_member, name: "user_options", scope: !106, file: !6, line: 455, baseType: !125, size: 8, offset: 96)
!125 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !56, line: 55, baseType: !7)
!126 = !DIDerivedType(tag: DW_TAG_member, name: "thread_state", scope: !106, file: !6, line: 458, baseType: !125, size: 8, offset: 104)
!127 = !DIDerivedType(tag: DW_TAG_member, scope: !106, file: !6, line: 474, baseType: !128, size: 16, offset: 112)
!128 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !106, file: !6, line: 474, size: 16, elements: !129)
!129 = !{!130, !137}
!130 = !DIDerivedType(tag: DW_TAG_member, scope: !128, file: !6, line: 475, baseType: !131, size: 16)
!131 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !128, file: !6, line: 475, size: 16, elements: !132)
!132 = !{!133, !136}
!133 = !DIDerivedType(tag: DW_TAG_member, name: "prio", scope: !131, file: !6, line: 480, baseType: !134, size: 8)
!134 = !DIDerivedType(tag: DW_TAG_typedef, name: "int8_t", file: !56, line: 40, baseType: !135)
!135 = !DIBasicType(name: "signed char", size: 8, encoding: DW_ATE_signed_char)
!136 = !DIDerivedType(tag: DW_TAG_member, name: "sched_locked", scope: !131, file: !6, line: 481, baseType: !125, size: 8, offset: 8)
!137 = !DIDerivedType(tag: DW_TAG_member, name: "preempt", scope: !128, file: !6, line: 484, baseType: !138, size: 16)
!138 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !56, line: 56, baseType: !139)
!139 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!140 = !DIDerivedType(tag: DW_TAG_member, name: "order_key", scope: !106, file: !6, line: 491, baseType: !60, size: 32, offset: 128)
!141 = !DIDerivedType(tag: DW_TAG_member, name: "swap_data", scope: !106, file: !6, line: 511, baseType: !58, size: 32, offset: 160)
!142 = !DIDerivedType(tag: DW_TAG_member, name: "timeout", scope: !106, file: !6, line: 515, baseType: !143, size: 192, offset: 192)
!143 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_timeout", file: !70, line: 221, size: 192, elements: !144)
!144 = !{!145, !146, !152}
!145 = !DIDerivedType(tag: DW_TAG_member, name: "node", scope: !143, file: !70, line: 222, baseType: !112, size: 64)
!146 = !DIDerivedType(tag: DW_TAG_member, name: "fn", scope: !143, file: !70, line: 223, baseType: !147, size: 32, offset: 64)
!147 = !DIDerivedType(tag: DW_TAG_typedef, name: "_timeout_func_t", file: !70, line: 219, baseType: !148)
!148 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !149, size: 32)
!149 = !DISubroutineType(types: !150)
!150 = !{null, !151}
!151 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !143, size: 32)
!152 = !DIDerivedType(tag: DW_TAG_member, name: "dticks", scope: !143, file: !70, line: 226, baseType: !55, size: 64, offset: 128)
!153 = !DIDerivedType(tag: DW_TAG_member, name: "join_waiters", scope: !106, file: !6, line: 518, baseType: !69, size: 64, offset: 384)
!154 = !DIDerivedType(tag: DW_TAG_member, name: "callee_saved", scope: !103, file: !6, line: 575, baseType: !155, size: 288, offset: 448)
!155 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_callee_saved", file: !156, line: 25, size: 288, elements: !157)
!156 = !DIFile(filename: "zephyrproject/zephyr/include/arch/arm/aarch32/thread.h", directory: "/home/kenny")
!157 = !{!158, !159, !160, !161, !162, !163, !164, !165, !166}
!158 = !DIDerivedType(tag: DW_TAG_member, name: "v1", scope: !155, file: !156, line: 26, baseType: !60, size: 32)
!159 = !DIDerivedType(tag: DW_TAG_member, name: "v2", scope: !155, file: !156, line: 27, baseType: !60, size: 32, offset: 32)
!160 = !DIDerivedType(tag: DW_TAG_member, name: "v3", scope: !155, file: !156, line: 28, baseType: !60, size: 32, offset: 64)
!161 = !DIDerivedType(tag: DW_TAG_member, name: "v4", scope: !155, file: !156, line: 29, baseType: !60, size: 32, offset: 96)
!162 = !DIDerivedType(tag: DW_TAG_member, name: "v5", scope: !155, file: !156, line: 30, baseType: !60, size: 32, offset: 128)
!163 = !DIDerivedType(tag: DW_TAG_member, name: "v6", scope: !155, file: !156, line: 31, baseType: !60, size: 32, offset: 160)
!164 = !DIDerivedType(tag: DW_TAG_member, name: "v7", scope: !155, file: !156, line: 32, baseType: !60, size: 32, offset: 192)
!165 = !DIDerivedType(tag: DW_TAG_member, name: "v8", scope: !155, file: !156, line: 33, baseType: !60, size: 32, offset: 224)
!166 = !DIDerivedType(tag: DW_TAG_member, name: "psp", scope: !155, file: !156, line: 34, baseType: !60, size: 32, offset: 256)
!167 = !DIDerivedType(tag: DW_TAG_member, name: "init_data", scope: !103, file: !6, line: 578, baseType: !58, size: 32, offset: 736)
!168 = !DIDerivedType(tag: DW_TAG_member, name: "fn_abort", scope: !103, file: !6, line: 583, baseType: !169, size: 32, offset: 768)
!169 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !170, size: 32)
!170 = !DISubroutineType(types: !171)
!171 = !{null}
!172 = !DIDerivedType(tag: DW_TAG_member, name: "errno_var", scope: !103, file: !6, line: 610, baseType: !59, size: 32, offset: 800)
!173 = !DIDerivedType(tag: DW_TAG_member, name: "stack_info", scope: !103, file: !6, line: 616, baseType: !174, size: 96, offset: 832)
!174 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_stack_info", file: !6, line: 525, size: 96, elements: !175)
!175 = !{!176, !179, !182}
!176 = !DIDerivedType(tag: DW_TAG_member, name: "start", scope: !174, file: !6, line: 529, baseType: !177, size: 32)
!177 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintptr_t", file: !56, line: 71, baseType: !178)
!178 = !DIBasicType(name: "long unsigned int", size: 32, encoding: DW_ATE_unsigned)
!179 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !174, file: !6, line: 538, baseType: !180, size: 32, offset: 32)
!180 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !181, line: 46, baseType: !61)
!181 = !DIFile(filename: "/usr/lib/llvm-9/lib/clang/9.0.1/include/stddef.h", directory: "")
!182 = !DIDerivedType(tag: DW_TAG_member, name: "delta", scope: !174, file: !6, line: 544, baseType: !180, size: 32, offset: 64)
!183 = !DIDerivedType(tag: DW_TAG_member, name: "resource_pool", scope: !103, file: !6, line: 641, baseType: !184, size: 32, offset: 928)
!184 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !185, size: 32)
!185 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mem_pool", file: !186, line: 30, size: 32, elements: !187)
!186 = !DIFile(filename: "zephyrproject/zephyr/include/mempool_heap.h", directory: "/home/kenny")
!187 = !{!188}
!188 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !185, file: !186, line: 31, baseType: !189, size: 32)
!189 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !190, size: 32)
!190 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_heap", file: !70, line: 267, size: 160, elements: !191)
!191 = !{!192, !201, !202}
!192 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !190, file: !70, line: 268, baseType: !193, size: 96)
!193 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "sys_heap", file: !194, line: 51, size: 96, elements: !195)
!194 = !DIFile(filename: "zephyrproject/zephyr/include/sys/sys_heap.h", directory: "/home/kenny")
!195 = !{!196, !199, !200}
!196 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !193, file: !194, line: 52, baseType: !197, size: 32)
!197 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !198, size: 32)
!198 = !DICompositeType(tag: DW_TAG_structure_type, name: "z_heap", file: !194, line: 52, flags: DIFlagFwdDecl)
!199 = !DIDerivedType(tag: DW_TAG_member, name: "init_mem", scope: !193, file: !194, line: 53, baseType: !58, size: 32, offset: 32)
!200 = !DIDerivedType(tag: DW_TAG_member, name: "init_bytes", scope: !193, file: !194, line: 54, baseType: !180, size: 32, offset: 64)
!201 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !190, file: !70, line: 269, baseType: !69, size: 64, offset: 96)
!202 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !190, file: !70, line: 270, baseType: !203, offset: 160)
!203 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_spinlock", file: !70, line: 234, elements: !204)
!204 = !{}
!205 = !DIDerivedType(tag: DW_TAG_member, name: "arch", scope: !103, file: !6, line: 644, baseType: !206, size: 64, offset: 960)
!206 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_arch", file: !156, line: 60, size: 64, elements: !207)
!207 = !{!208, !209}
!208 = !DIDerivedType(tag: DW_TAG_member, name: "basepri", scope: !206, file: !156, line: 63, baseType: !60, size: 32)
!209 = !DIDerivedType(tag: DW_TAG_member, name: "swap_return_value", scope: !206, file: !156, line: 66, baseType: !60, size: 32, offset: 32)
!210 = !DIGlobalVariableExpression(var: !211, expr: !DIExpression())
!211 = distinct !DIGlobalVariable(name: "threadA_stack_area", scope: !2, file: !65, line: 73, type: !93, isLocal: false, isDefinition: true, align: 64)
!212 = !DIGlobalVariableExpression(var: !213, expr: !DIExpression())
!213 = distinct !DIGlobalVariable(name: "threadA_data", scope: !2, file: !65, line: 74, type: !103, isLocal: false, isDefinition: true)
!214 = !{!"clang version 9.0.1-12 "}
!215 = !{i32 2, !"Dwarf Version", i32 4}
!216 = !{i32 2, !"Debug Info Version", i32 3}
!217 = !{i32 1, !"wchar_size", i32 4}
!218 = !{i32 1, !"min_enum_size", i32 1}
!219 = distinct !DISubprogram(name: "helloLoop", scope: !65, file: !65, line: 17, type: !220, scopeLine: 19, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !204)
!220 = !DISubroutineType(types: !221)
!221 = !{null, !222, !224, !224}
!222 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !223, size: 32)
!223 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !98)
!224 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !66, size: 32)
!225 = !DILocalVariable(name: "my_name", arg: 1, scope: !219, file: !65, line: 17, type: !222)
!226 = !DILocation(line: 17, column: 28, scope: !219)
!227 = !DILocalVariable(name: "my_sem", arg: 2, scope: !219, file: !65, line: 18, type: !224)
!228 = !DILocation(line: 18, column: 23, scope: !219)
!229 = !DILocalVariable(name: "other_sem", arg: 3, scope: !219, file: !65, line: 18, type: !224)
!230 = !DILocation(line: 18, column: 45, scope: !219)
!231 = !DILocalVariable(name: "tname", scope: !219, file: !65, line: 20, type: !222)
!232 = !DILocation(line: 20, column: 17, scope: !219)
!233 = !DILocation(line: 22, column: 5, scope: !219)
!234 = !DILocation(line: 23, column: 20, scope: !235)
!235 = distinct !DILexicalBlock(scope: !219, file: !65, line: 22, column: 15)
!236 = !DILocation(line: 23, column: 28, scope: !235)
!237 = !DILocation(line: 23, column: 9, scope: !235)
!238 = !DILocation(line: 25, column: 35, scope: !235)
!239 = !DILocation(line: 25, column: 17, scope: !235)
!240 = !DILocation(line: 25, column: 15, scope: !235)
!241 = !DILocation(line: 26, column: 13, scope: !242)
!242 = distinct !DILexicalBlock(scope: !235, file: !65, line: 26, column: 13)
!243 = !DILocation(line: 26, column: 19, scope: !242)
!244 = !DILocation(line: 26, column: 27, scope: !242)
!245 = !DILocation(line: 26, column: 30, scope: !242)
!246 = !DILocation(line: 26, column: 39, scope: !242)
!247 = !DILocation(line: 26, column: 13, scope: !235)
!248 = !DILocation(line: 28, column: 25, scope: !249)
!249 = distinct !DILexicalBlock(scope: !242, file: !65, line: 26, column: 48)
!250 = !DILocation(line: 27, column: 13, scope: !249)
!251 = !DILocation(line: 29, column: 9, scope: !249)
!252 = !DILocation(line: 31, column: 21, scope: !253)
!253 = distinct !DILexicalBlock(scope: !242, file: !65, line: 29, column: 16)
!254 = !DILocation(line: 30, column: 13, scope: !253)
!255 = !DILocation(line: 34, column: 9, scope: !235)
!256 = !DILocation(line: 35, column: 20, scope: !235)
!257 = !DILocation(line: 35, column: 9, scope: !235)
!258 = distinct !{!258, !233, !259}
!259 = !DILocation(line: 36, column: 5, scope: !219)
!260 = distinct !DISubprogram(name: "k_sem_take", scope: !261, file: !261, line: 746, type: !262, scopeLine: 747, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !204)
!261 = !DIFile(filename: "zephyr/include/generated/syscalls/kernel.h", directory: "/home/kenny/ara/build/appl/Zephyr/dyn_sems")
!262 = !DISubroutineType(types: !263)
!263 = !{!59, !224, !264}
!264 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_timeout_t", file: !54, line: 69, baseType: !265)
!265 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !54, line: 67, size: 64, elements: !266)
!266 = !{!267}
!267 = !DIDerivedType(tag: DW_TAG_member, name: "ticks", scope: !265, file: !54, line: 68, baseType: !53, size: 64)
!268 = !DILocalVariable(name: "sem", arg: 1, scope: !260, file: !261, line: 746, type: !224)
!269 = !DILocation(line: 746, column: 63, scope: !260)
!270 = !DILocalVariable(name: "timeout", arg: 2, scope: !260, file: !261, line: 746, type: !264)
!271 = !DILocation(line: 746, column: 80, scope: !260)
!272 = !DILocation(line: 755, column: 2, scope: !260)
!273 = !DILocation(line: 755, column: 2, scope: !274)
!274 = distinct !DILexicalBlock(scope: !260, file: !261, line: 755, column: 2)
!275 = !{i32 -2141853971}
!276 = !DILocation(line: 756, column: 27, scope: !260)
!277 = !DILocation(line: 756, column: 9, scope: !260)
!278 = !DILocation(line: 756, column: 2, scope: !260)
!279 = distinct !DISubprogram(name: "k_current_get", scope: !261, file: !261, line: 187, type: !280, scopeLine: 188, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !204)
!280 = !DISubroutineType(types: !281)
!281 = !{!282}
!282 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_tid_t", file: !6, line: 648, baseType: !283)
!283 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !103, size: 32)
!284 = !DILocation(line: 194, column: 2, scope: !279)
!285 = !DILocation(line: 194, column: 2, scope: !286)
!286 = distinct !DILexicalBlock(scope: !279, file: !261, line: 194, column: 2)
!287 = !{i32 -2141856771}
!288 = !DILocation(line: 195, column: 9, scope: !279)
!289 = !DILocation(line: 195, column: 2, scope: !279)
!290 = distinct !DISubprogram(name: "k_msleep", scope: !6, file: !6, line: 957, type: !291, scopeLine: 958, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !204)
!291 = !DISubroutineType(types: !292)
!292 = !{!293, !293}
!293 = !DIDerivedType(tag: DW_TAG_typedef, name: "int32_t", file: !56, line: 42, baseType: !59)
!294 = !DILocalVariable(name: "ms", arg: 1, scope: !290, file: !6, line: 957, type: !293)
!295 = !DILocation(line: 957, column: 40, scope: !290)
!296 = !DILocation(line: 959, column: 17, scope: !290)
!297 = !DILocation(line: 959, column: 9, scope: !290)
!298 = !DILocation(line: 959, column: 2, scope: !290)
!299 = distinct !DISubprogram(name: "k_sem_give", scope: !261, file: !261, line: 761, type: !300, scopeLine: 762, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !204)
!300 = !DISubroutineType(types: !301)
!301 = !{null, !224}
!302 = !DILocalVariable(name: "sem", arg: 1, scope: !299, file: !261, line: 761, type: !224)
!303 = !DILocation(line: 761, column: 64, scope: !299)
!304 = !DILocation(line: 769, column: 2, scope: !299)
!305 = !DILocation(line: 769, column: 2, scope: !306)
!306 = distinct !DILexicalBlock(scope: !299, file: !261, line: 769, column: 2)
!307 = !{i32 -2141853903}
!308 = !DILocation(line: 770, column: 20, scope: !299)
!309 = !DILocation(line: 770, column: 2, scope: !299)
!310 = !DILocation(line: 771, column: 1, scope: !299)
!311 = distinct !DISubprogram(name: "k_ms_to_ticks_ceil64", scope: !312, file: !312, line: 369, type: !313, scopeLine: 370, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !204)
!312 = !DIFile(filename: "zephyrproject/zephyr/include/sys/time_units.h", directory: "/home/kenny")
!313 = !DISubroutineType(types: !314)
!314 = !{!315, !315}
!315 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint64_t", file: !56, line: 58, baseType: !316)
!316 = !DIBasicType(name: "long long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!317 = !DILocalVariable(name: "t", arg: 1, scope: !318, file: !312, line: 78, type: !315)
!318 = distinct !DISubprogram(name: "z_tmcvt", scope: !312, file: !312, line: 78, type: !319, scopeLine: 82, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !204)
!319 = !DISubroutineType(types: !320)
!320 = !{!315, !315, !60, !60, !321, !321, !321, !321}
!321 = !DIBasicType(name: "_Bool", size: 8, encoding: DW_ATE_boolean)
!322 = !DILocation(line: 78, column: 63, scope: !318, inlinedAt: !323)
!323 = distinct !DILocation(line: 372, column: 9, scope: !311)
!324 = !DILocalVariable(name: "from_hz", arg: 2, scope: !318, file: !312, line: 78, type: !60)
!325 = !DILocation(line: 78, column: 75, scope: !318, inlinedAt: !323)
!326 = !DILocalVariable(name: "to_hz", arg: 3, scope: !318, file: !312, line: 79, type: !60)
!327 = !DILocation(line: 79, column: 18, scope: !318, inlinedAt: !323)
!328 = !DILocalVariable(name: "const_hz", arg: 4, scope: !318, file: !312, line: 79, type: !321)
!329 = !DILocation(line: 79, column: 30, scope: !318, inlinedAt: !323)
!330 = !DILocalVariable(name: "result32", arg: 5, scope: !318, file: !312, line: 80, type: !321)
!331 = !DILocation(line: 80, column: 14, scope: !318, inlinedAt: !323)
!332 = !DILocalVariable(name: "round_up", arg: 6, scope: !318, file: !312, line: 80, type: !321)
!333 = !DILocation(line: 80, column: 29, scope: !318, inlinedAt: !323)
!334 = !DILocalVariable(name: "round_off", arg: 7, scope: !318, file: !312, line: 81, type: !321)
!335 = !DILocation(line: 81, column: 14, scope: !318, inlinedAt: !323)
!336 = !DILocalVariable(name: "mul_ratio", scope: !318, file: !312, line: 84, type: !321)
!337 = !DILocation(line: 84, column: 7, scope: !318, inlinedAt: !323)
!338 = !DILocalVariable(name: "div_ratio", scope: !318, file: !312, line: 86, type: !321)
!339 = !DILocation(line: 86, column: 7, scope: !318, inlinedAt: !323)
!340 = !DILocalVariable(name: "off", scope: !318, file: !312, line: 93, type: !315)
!341 = !DILocation(line: 93, column: 11, scope: !318, inlinedAt: !323)
!342 = !DILocalVariable(name: "rdivisor", scope: !343, file: !312, line: 96, type: !60)
!343 = distinct !DILexicalBlock(scope: !344, file: !312, line: 95, column: 18)
!344 = distinct !DILexicalBlock(scope: !318, file: !312, line: 95, column: 6)
!345 = !DILocation(line: 96, column: 12, scope: !343, inlinedAt: !323)
!346 = !DILocalVariable(name: "t", arg: 1, scope: !311, file: !312, line: 369, type: !315)
!347 = !DILocation(line: 369, column: 69, scope: !311)
!348 = !DILocation(line: 372, column: 17, scope: !311)
!349 = !DILocation(line: 84, column: 19, scope: !318, inlinedAt: !323)
!350 = !DILocation(line: 84, column: 28, scope: !318, inlinedAt: !323)
!351 = !DILocation(line: 85, column: 4, scope: !318, inlinedAt: !323)
!352 = !DILocation(line: 85, column: 12, scope: !318, inlinedAt: !323)
!353 = !DILocation(line: 85, column: 10, scope: !318, inlinedAt: !323)
!354 = !DILocation(line: 85, column: 21, scope: !318, inlinedAt: !323)
!355 = !DILocation(line: 85, column: 26, scope: !318, inlinedAt: !323)
!356 = !DILocation(line: 85, column: 34, scope: !318, inlinedAt: !323)
!357 = !DILocation(line: 85, column: 32, scope: !318, inlinedAt: !323)
!358 = !DILocation(line: 85, column: 43, scope: !318, inlinedAt: !323)
!359 = !DILocation(line: 0, scope: !318, inlinedAt: !323)
!360 = !DILocation(line: 86, column: 19, scope: !318, inlinedAt: !323)
!361 = !DILocation(line: 86, column: 28, scope: !318, inlinedAt: !323)
!362 = !DILocation(line: 87, column: 4, scope: !318, inlinedAt: !323)
!363 = !DILocation(line: 87, column: 14, scope: !318, inlinedAt: !323)
!364 = !DILocation(line: 87, column: 12, scope: !318, inlinedAt: !323)
!365 = !DILocation(line: 87, column: 21, scope: !318, inlinedAt: !323)
!366 = !DILocation(line: 87, column: 26, scope: !318, inlinedAt: !323)
!367 = !DILocation(line: 87, column: 36, scope: !318, inlinedAt: !323)
!368 = !DILocation(line: 87, column: 34, scope: !318, inlinedAt: !323)
!369 = !DILocation(line: 87, column: 43, scope: !318, inlinedAt: !323)
!370 = !DILocation(line: 89, column: 6, scope: !371, inlinedAt: !323)
!371 = distinct !DILexicalBlock(scope: !318, file: !312, line: 89, column: 6)
!372 = !DILocation(line: 89, column: 17, scope: !371, inlinedAt: !323)
!373 = !DILocation(line: 89, column: 14, scope: !371, inlinedAt: !323)
!374 = !DILocation(line: 89, column: 6, scope: !318, inlinedAt: !323)
!375 = !DILocation(line: 90, column: 10, scope: !376, inlinedAt: !323)
!376 = distinct !DILexicalBlock(scope: !371, file: !312, line: 89, column: 24)
!377 = !DILocation(line: 90, column: 32, scope: !376, inlinedAt: !323)
!378 = !DILocation(line: 90, column: 22, scope: !376, inlinedAt: !323)
!379 = !DILocation(line: 90, column: 21, scope: !376, inlinedAt: !323)
!380 = !DILocation(line: 90, column: 37, scope: !376, inlinedAt: !323)
!381 = !DILocation(line: 90, column: 3, scope: !376, inlinedAt: !323)
!382 = !DILocation(line: 95, column: 7, scope: !344, inlinedAt: !323)
!383 = !DILocation(line: 95, column: 6, scope: !318, inlinedAt: !323)
!384 = !DILocation(line: 96, column: 23, scope: !343, inlinedAt: !323)
!385 = !DILocation(line: 96, column: 36, scope: !343, inlinedAt: !323)
!386 = !DILocation(line: 96, column: 46, scope: !343, inlinedAt: !323)
!387 = !DILocation(line: 96, column: 44, scope: !343, inlinedAt: !323)
!388 = !DILocation(line: 96, column: 55, scope: !343, inlinedAt: !323)
!389 = !DILocation(line: 98, column: 7, scope: !390, inlinedAt: !323)
!390 = distinct !DILexicalBlock(scope: !343, file: !312, line: 98, column: 7)
!391 = !DILocation(line: 98, column: 7, scope: !343, inlinedAt: !323)
!392 = !DILocation(line: 99, column: 10, scope: !393, inlinedAt: !323)
!393 = distinct !DILexicalBlock(scope: !390, file: !312, line: 98, column: 17)
!394 = !DILocation(line: 99, column: 19, scope: !393, inlinedAt: !323)
!395 = !DILocation(line: 99, column: 8, scope: !393, inlinedAt: !323)
!396 = !DILocation(line: 100, column: 3, scope: !393, inlinedAt: !323)
!397 = !DILocation(line: 100, column: 14, scope: !398, inlinedAt: !323)
!398 = distinct !DILexicalBlock(scope: !390, file: !312, line: 100, column: 14)
!399 = !DILocation(line: 100, column: 14, scope: !390, inlinedAt: !323)
!400 = !DILocation(line: 101, column: 10, scope: !401, inlinedAt: !323)
!401 = distinct !DILexicalBlock(scope: !398, file: !312, line: 100, column: 25)
!402 = !DILocation(line: 101, column: 19, scope: !401, inlinedAt: !323)
!403 = !DILocation(line: 101, column: 8, scope: !401, inlinedAt: !323)
!404 = !DILocation(line: 102, column: 3, scope: !401, inlinedAt: !323)
!405 = !DILocation(line: 103, column: 2, scope: !343, inlinedAt: !323)
!406 = !DILocation(line: 110, column: 6, scope: !407, inlinedAt: !323)
!407 = distinct !DILexicalBlock(scope: !318, file: !312, line: 110, column: 6)
!408 = !DILocation(line: 110, column: 6, scope: !318, inlinedAt: !323)
!409 = !DILocation(line: 111, column: 8, scope: !410, inlinedAt: !323)
!410 = distinct !DILexicalBlock(scope: !407, file: !312, line: 110, column: 17)
!411 = !DILocation(line: 111, column: 5, scope: !410, inlinedAt: !323)
!412 = !DILocation(line: 112, column: 7, scope: !413, inlinedAt: !323)
!413 = distinct !DILexicalBlock(scope: !410, file: !312, line: 112, column: 7)
!414 = !DILocation(line: 112, column: 16, scope: !413, inlinedAt: !323)
!415 = !DILocation(line: 112, column: 20, scope: !413, inlinedAt: !323)
!416 = !DILocation(line: 112, column: 22, scope: !413, inlinedAt: !323)
!417 = !DILocation(line: 112, column: 7, scope: !410, inlinedAt: !323)
!418 = !DILocation(line: 113, column: 22, scope: !419, inlinedAt: !323)
!419 = distinct !DILexicalBlock(scope: !413, file: !312, line: 112, column: 36)
!420 = !DILocation(line: 113, column: 12, scope: !419, inlinedAt: !323)
!421 = !DILocation(line: 113, column: 28, scope: !419, inlinedAt: !323)
!422 = !DILocation(line: 113, column: 38, scope: !419, inlinedAt: !323)
!423 = !DILocation(line: 113, column: 36, scope: !419, inlinedAt: !323)
!424 = !DILocation(line: 113, column: 25, scope: !419, inlinedAt: !323)
!425 = !DILocation(line: 113, column: 11, scope: !419, inlinedAt: !323)
!426 = !DILocation(line: 113, column: 4, scope: !419, inlinedAt: !323)
!427 = !DILocation(line: 115, column: 11, scope: !428, inlinedAt: !323)
!428 = distinct !DILexicalBlock(scope: !413, file: !312, line: 114, column: 10)
!429 = !DILocation(line: 115, column: 16, scope: !428, inlinedAt: !323)
!430 = !DILocation(line: 115, column: 26, scope: !428, inlinedAt: !323)
!431 = !DILocation(line: 115, column: 24, scope: !428, inlinedAt: !323)
!432 = !DILocation(line: 115, column: 15, scope: !428, inlinedAt: !323)
!433 = !DILocation(line: 115, column: 13, scope: !428, inlinedAt: !323)
!434 = !DILocation(line: 115, column: 4, scope: !428, inlinedAt: !323)
!435 = !DILocation(line: 117, column: 13, scope: !436, inlinedAt: !323)
!436 = distinct !DILexicalBlock(scope: !407, file: !312, line: 117, column: 13)
!437 = !DILocation(line: 117, column: 13, scope: !407, inlinedAt: !323)
!438 = !DILocation(line: 118, column: 7, scope: !439, inlinedAt: !323)
!439 = distinct !DILexicalBlock(scope: !440, file: !312, line: 118, column: 7)
!440 = distinct !DILexicalBlock(scope: !436, file: !312, line: 117, column: 24)
!441 = !DILocation(line: 118, column: 7, scope: !440, inlinedAt: !323)
!442 = !DILocation(line: 119, column: 22, scope: !443, inlinedAt: !323)
!443 = distinct !DILexicalBlock(scope: !439, file: !312, line: 118, column: 17)
!444 = !DILocation(line: 119, column: 12, scope: !443, inlinedAt: !323)
!445 = !DILocation(line: 119, column: 28, scope: !443, inlinedAt: !323)
!446 = !DILocation(line: 119, column: 36, scope: !443, inlinedAt: !323)
!447 = !DILocation(line: 119, column: 34, scope: !443, inlinedAt: !323)
!448 = !DILocation(line: 119, column: 25, scope: !443, inlinedAt: !323)
!449 = !DILocation(line: 119, column: 11, scope: !443, inlinedAt: !323)
!450 = !DILocation(line: 119, column: 4, scope: !443, inlinedAt: !323)
!451 = !DILocation(line: 121, column: 11, scope: !452, inlinedAt: !323)
!452 = distinct !DILexicalBlock(scope: !439, file: !312, line: 120, column: 10)
!453 = !DILocation(line: 121, column: 16, scope: !452, inlinedAt: !323)
!454 = !DILocation(line: 121, column: 24, scope: !452, inlinedAt: !323)
!455 = !DILocation(line: 121, column: 22, scope: !452, inlinedAt: !323)
!456 = !DILocation(line: 121, column: 15, scope: !452, inlinedAt: !323)
!457 = !DILocation(line: 121, column: 13, scope: !452, inlinedAt: !323)
!458 = !DILocation(line: 121, column: 4, scope: !452, inlinedAt: !323)
!459 = !DILocation(line: 124, column: 7, scope: !460, inlinedAt: !323)
!460 = distinct !DILexicalBlock(scope: !461, file: !312, line: 124, column: 7)
!461 = distinct !DILexicalBlock(scope: !436, file: !312, line: 123, column: 9)
!462 = !DILocation(line: 124, column: 7, scope: !461, inlinedAt: !323)
!463 = !DILocation(line: 125, column: 23, scope: !464, inlinedAt: !323)
!464 = distinct !DILexicalBlock(scope: !460, file: !312, line: 124, column: 17)
!465 = !DILocation(line: 125, column: 27, scope: !464, inlinedAt: !323)
!466 = !DILocation(line: 125, column: 25, scope: !464, inlinedAt: !323)
!467 = !DILocation(line: 125, column: 35, scope: !464, inlinedAt: !323)
!468 = !DILocation(line: 125, column: 33, scope: !464, inlinedAt: !323)
!469 = !DILocation(line: 125, column: 42, scope: !464, inlinedAt: !323)
!470 = !DILocation(line: 125, column: 40, scope: !464, inlinedAt: !323)
!471 = !DILocation(line: 125, column: 11, scope: !464, inlinedAt: !323)
!472 = !DILocation(line: 125, column: 4, scope: !464, inlinedAt: !323)
!473 = !DILocation(line: 127, column: 12, scope: !474, inlinedAt: !323)
!474 = distinct !DILexicalBlock(scope: !460, file: !312, line: 126, column: 10)
!475 = !DILocation(line: 127, column: 16, scope: !474, inlinedAt: !323)
!476 = !DILocation(line: 127, column: 14, scope: !474, inlinedAt: !323)
!477 = !DILocation(line: 127, column: 24, scope: !474, inlinedAt: !323)
!478 = !DILocation(line: 127, column: 22, scope: !474, inlinedAt: !323)
!479 = !DILocation(line: 127, column: 31, scope: !474, inlinedAt: !323)
!480 = !DILocation(line: 127, column: 29, scope: !474, inlinedAt: !323)
!481 = !DILocation(line: 127, column: 4, scope: !474, inlinedAt: !323)
!482 = !DILocation(line: 130, column: 1, scope: !318, inlinedAt: !323)
!483 = !DILocation(line: 372, column: 2, scope: !311)
!484 = distinct !DISubprogram(name: "k_sleep", scope: !261, file: !261, line: 117, type: !485, scopeLine: 118, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !204)
!485 = !DISubroutineType(types: !486)
!486 = !{!293, !264}
!487 = !DILocalVariable(name: "timeout", arg: 1, scope: !484, file: !261, line: 117, type: !264)
!488 = !DILocation(line: 117, column: 61, scope: !484)
!489 = !DILocation(line: 126, column: 2, scope: !484)
!490 = !DILocation(line: 126, column: 2, scope: !491)
!491 = distinct !DILexicalBlock(scope: !484, file: !261, line: 126, column: 2)
!492 = !{i32 -2141857111}
!493 = !DILocation(line: 127, column: 9, scope: !484)
!494 = !DILocation(line: 127, column: 2, scope: !484)
!495 = distinct !DISubprogram(name: "threadB", scope: !65, file: !65, line: 41, type: !496, scopeLine: 42, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !204)
!496 = !DISubroutineType(types: !497)
!497 = !{null, !58, !58, !58}
!498 = !DILocalVariable(name: "dummy1", arg: 1, scope: !495, file: !65, line: 41, type: !58)
!499 = !DILocation(line: 41, column: 20, scope: !495)
!500 = !DILocalVariable(name: "dummy2", arg: 2, scope: !495, file: !65, line: 41, type: !58)
!501 = !DILocation(line: 41, column: 34, scope: !495)
!502 = !DILocalVariable(name: "dummy3", arg: 3, scope: !495, file: !65, line: 41, type: !58)
!503 = !DILocation(line: 41, column: 48, scope: !495)
!504 = !DILocation(line: 43, column: 5, scope: !495)
!505 = !DILocation(line: 44, column: 5, scope: !495)
!506 = !DILocation(line: 45, column: 5, scope: !495)
!507 = !DILocation(line: 47, column: 5, scope: !495)
!508 = !DILocation(line: 48, column: 1, scope: !495)
!509 = distinct !DISubprogram(name: "threadA", scope: !65, file: !65, line: 53, type: !496, scopeLine: 54, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !204)
!510 = !DILocalVariable(name: "dummy1", arg: 1, scope: !509, file: !65, line: 53, type: !58)
!511 = !DILocation(line: 53, column: 20, scope: !509)
!512 = !DILocalVariable(name: "dummy2", arg: 2, scope: !509, file: !65, line: 53, type: !58)
!513 = !DILocation(line: 53, column: 34, scope: !509)
!514 = !DILocalVariable(name: "dummy3", arg: 3, scope: !509, file: !65, line: 53, type: !58)
!515 = !DILocation(line: 53, column: 48, scope: !509)
!516 = !DILocation(line: 55, column: 5, scope: !509)
!517 = !DILocation(line: 56, column: 5, scope: !509)
!518 = !DILocation(line: 57, column: 5, scope: !509)
!519 = !DILocalVariable(name: "bad_stuff", scope: !509, file: !65, line: 58, type: !283)
!520 = !DILocation(line: 58, column: 22, scope: !509)
!521 = !DILocation(line: 60, column: 5, scope: !509)
!522 = !DILocation(line: 61, column: 5, scope: !509)
!523 = !DILocalVariable(name: "tid", scope: !509, file: !65, line: 63, type: !282)
!524 = !DILocation(line: 63, column: 13, scope: !509)
!525 = !DILocation(line: 63, column: 35, scope: !509)
!526 = !DILocation(line: 65, column: 34, scope: !509)
!527 = !DILocation(line: 63, column: 19, scope: !509)
!528 = !DILocation(line: 67, column: 23, scope: !509)
!529 = !DILocation(line: 67, column: 5, scope: !509)
!530 = !DILocation(line: 69, column: 5, scope: !509)
!531 = !DILocation(line: 70, column: 1, scope: !509)
!532 = distinct !DISubprogram(name: "k_sem_init", scope: !261, file: !261, line: 733, type: !533, scopeLine: 734, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !204)
!533 = !DISubroutineType(types: !534)
!534 = !{!59, !224, !61, !61}
!535 = !DILocalVariable(name: "sem", arg: 1, scope: !532, file: !261, line: 733, type: !224)
!536 = !DILocation(line: 733, column: 63, scope: !532)
!537 = !DILocalVariable(name: "initial_count", arg: 2, scope: !532, file: !261, line: 733, type: !61)
!538 = !DILocation(line: 733, column: 81, scope: !532)
!539 = !DILocalVariable(name: "limit", arg: 3, scope: !532, file: !261, line: 733, type: !61)
!540 = !DILocation(line: 733, column: 109, scope: !532)
!541 = !DILocation(line: 740, column: 2, scope: !532)
!542 = !DILocation(line: 740, column: 2, scope: !543)
!543 = distinct !DILexicalBlock(scope: !532, file: !261, line: 740, column: 2)
!544 = !{i32 -2141854039}
!545 = !DILocation(line: 741, column: 27, scope: !532)
!546 = !DILocation(line: 741, column: 32, scope: !532)
!547 = !DILocation(line: 741, column: 47, scope: !532)
!548 = !DILocation(line: 741, column: 9, scope: !532)
!549 = !DILocation(line: 741, column: 2, scope: !532)
!550 = distinct !DISubprogram(name: "k_thread_create", scope: !261, file: !261, line: 66, type: !551, scopeLine: 67, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !204)
!551 = !DISubroutineType(types: !552)
!552 = !{!282, !283, !553, !180, !556, !58, !58, !58, !59, !60, !264}
!553 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !554, size: 32)
!554 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_stack_t", file: !555, line: 44, baseType: !94)
!555 = !DIFile(filename: "zephyrproject/zephyr/include/sys/arch_interface.h", directory: "/home/kenny")
!556 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_entry_t", file: !555, line: 46, baseType: !557)
!557 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !496, size: 32)
!558 = !DILocalVariable(name: "new_thread", arg: 1, scope: !550, file: !261, line: 66, type: !283)
!559 = !DILocation(line: 66, column: 75, scope: !550)
!560 = !DILocalVariable(name: "stack", arg: 2, scope: !550, file: !261, line: 66, type: !553)
!561 = !DILocation(line: 66, column: 106, scope: !550)
!562 = !DILocalVariable(name: "stack_size", arg: 3, scope: !550, file: !261, line: 66, type: !180)
!563 = !DILocation(line: 66, column: 120, scope: !550)
!564 = !DILocalVariable(name: "entry", arg: 4, scope: !550, file: !261, line: 66, type: !556)
!565 = !DILocation(line: 66, column: 149, scope: !550)
!566 = !DILocalVariable(name: "p1", arg: 5, scope: !550, file: !261, line: 66, type: !58)
!567 = !DILocation(line: 66, column: 163, scope: !550)
!568 = !DILocalVariable(name: "p2", arg: 6, scope: !550, file: !261, line: 66, type: !58)
!569 = !DILocation(line: 66, column: 174, scope: !550)
!570 = !DILocalVariable(name: "p3", arg: 7, scope: !550, file: !261, line: 66, type: !58)
!571 = !DILocation(line: 66, column: 185, scope: !550)
!572 = !DILocalVariable(name: "prio", arg: 8, scope: !550, file: !261, line: 66, type: !59)
!573 = !DILocation(line: 66, column: 193, scope: !550)
!574 = !DILocalVariable(name: "options", arg: 9, scope: !550, file: !261, line: 66, type: !60)
!575 = !DILocation(line: 66, column: 208, scope: !550)
!576 = !DILocalVariable(name: "delay", arg: 10, scope: !550, file: !261, line: 66, type: !264)
!577 = !DILocation(line: 66, column: 229, scope: !550)
!578 = !DILocation(line: 83, column: 2, scope: !550)
!579 = !DILocation(line: 83, column: 2, scope: !580)
!580 = distinct !DILexicalBlock(scope: !550, file: !261, line: 83, column: 2)
!581 = !{i32 -2141857315}
!582 = !DILocation(line: 84, column: 32, scope: !550)
!583 = !DILocation(line: 84, column: 44, scope: !550)
!584 = !DILocation(line: 84, column: 51, scope: !550)
!585 = !DILocation(line: 84, column: 63, scope: !550)
!586 = !DILocation(line: 84, column: 70, scope: !550)
!587 = !DILocation(line: 84, column: 74, scope: !550)
!588 = !DILocation(line: 84, column: 78, scope: !550)
!589 = !DILocation(line: 84, column: 82, scope: !550)
!590 = !DILocation(line: 84, column: 88, scope: !550)
!591 = !DILocation(line: 84, column: 9, scope: !550)
!592 = !DILocation(line: 84, column: 2, scope: !550)
!593 = distinct !DISubprogram(name: "k_thread_name_set", scope: !261, file: !261, line: 363, type: !594, scopeLine: 364, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !204)
!594 = !DISubroutineType(types: !595)
!595 = !{!59, !282, !222}
!596 = !DILocalVariable(name: "thread_id", arg: 1, scope: !593, file: !261, line: 363, type: !282)
!597 = !DILocation(line: 363, column: 63, scope: !593)
!598 = !DILocalVariable(name: "value", arg: 2, scope: !593, file: !261, line: 363, type: !222)
!599 = !DILocation(line: 363, column: 87, scope: !593)
!600 = !DILocation(line: 370, column: 2, scope: !593)
!601 = !DILocation(line: 370, column: 2, scope: !602)
!602 = distinct !DILexicalBlock(scope: !593, file: !261, line: 370, column: 2)
!603 = !{i32 -2141855887}
!604 = !DILocation(line: 371, column: 34, scope: !593)
!605 = !DILocation(line: 371, column: 45, scope: !593)
!606 = !DILocation(line: 371, column: 9, scope: !593)
!607 = !DILocation(line: 371, column: 2, scope: !593)
!608 = distinct !DISubprogram(name: "main", scope: !65, file: !65, line: 76, type: !170, scopeLine: 77, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !204)
!609 = !DILocalVariable(name: "tid", scope: !608, file: !65, line: 78, type: !282)
!610 = !DILocation(line: 78, column: 13, scope: !608)
!611 = !DILocation(line: 80, column: 34, scope: !608)
!612 = !DILocation(line: 78, column: 19, scope: !608)
!613 = !DILocation(line: 82, column: 23, scope: !608)
!614 = !DILocation(line: 82, column: 5, scope: !608)
!615 = !DILocation(line: 83, column: 1, scope: !608)
