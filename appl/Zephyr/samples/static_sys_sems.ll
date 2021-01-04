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
%struct._static_thread_data = type { %struct.k_thread*, %struct.z_thread_stack_element*, i32, void (i8*, i8*, i8*)*, i8*, i8*, i8*, i32, i32, i32, void ()*, i8* }
%struct.k_timeout_t = type { i64 }

@threadA_sem = dso_local global %struct.sys_sem { %struct.k_sem { %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.sys_sem, %struct.sys_sem* @threadA_sem, i32 0, i32 0, i32 0, i32 0) }, %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.sys_sem, %struct.sys_sem* @threadA_sem, i32 0, i32 0, i32 0, i32 0) } } }, i32 1, i32 1 } }, section "._k_sem.static.threadA_sem", align 4, !dbg !0
@threadB_sem = dso_local global %struct.sys_sem { %struct.k_sem { %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.sys_sem, %struct.sys_sem* @threadB_sem, i32 0, i32 0, i32 0, i32 0) }, %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.sys_sem, %struct.sys_sem* @threadB_sem, i32 0, i32 0, i32 0, i32 0) } } }, i32 0, i32 1 } }, section "._k_sem.static.threadB_sem", align 4, !dbg !63
@threadB_stack_area = dso_local global [1024 x %struct.z_thread_stack_element] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/static_sys_sems/src/main.c\22.4", align 8, !dbg !238
@_k_thread_obj_thread_a = dso_local global %struct.k_thread zeroinitializer, align 8, !dbg !247
@_k_thread_stack_thread_a = dso_local global [1024 x %struct.z_thread_stack_element] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/static_sys_sems/src/main.c\22.5", align 8, !dbg !245
@_k_thread_data_thread_a = dso_local global %struct._static_thread_data { %struct.k_thread* @_k_thread_obj_thread_a, %struct.z_thread_stack_element* getelementptr inbounds ([1024 x %struct.z_thread_stack_element], [1024 x %struct.z_thread_stack_element]* @_k_thread_stack_thread_a, i32 0, i32 0), i32 1024, void (i8*, i8*, i8*)* @threadA, i8* null, i8* null, i8* null, i32 7, i32 0, i32 0, void ()* null, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.3, i32 0, i32 0) }, section ".__static_thread_data.static._k_thread_data_thread_a", align 4, !dbg !95
@.str.3 = private unnamed_addr constant [9 x i8] c"thread_a\00", align 1
@threadB_data = internal global %struct.k_thread zeroinitializer, align 8, !dbg !243
@.str.2 = private unnamed_addr constant [9 x i8] c"thread_b\00", align 1
@__func__.threadA = private unnamed_addr constant [8 x i8] c"threadA\00", align 1
@.str = private unnamed_addr constant [26 x i8] c"%s: Hello World from %s!\0A\00", align 1
@.str.1 = private unnamed_addr constant [14 x i8] c"nucleo_f303re\00", align 1
@__func__.threadB = private unnamed_addr constant [8 x i8] c"threadB\00", align 1
@thread_a = dso_local constant %struct.k_thread* @_k_thread_obj_thread_a, align 4, !dbg !234
@llvm.used = appending global [3 x i8*] [i8* bitcast (%struct.sys_sem* @threadA_sem to i8*), i8* bitcast (%struct.sys_sem* @threadB_sem to i8*), i8* bitcast (%struct._static_thread_data* @_k_thread_data_thread_a to i8*)], section "llvm.metadata"

; Function Attrs: noinline nounwind optnone
define dso_local void @threadA(i8*, i8*, i8*) #0 !dbg !254 {
  %4 = alloca i8*, align 4
  %5 = alloca i8*, align 4
  %6 = alloca i8*, align 4
  %7 = alloca %struct.k_thread*, align 4
  %8 = alloca %struct.k_timeout_t, align 8
  store i8* %0, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !255, metadata !DIExpression()), !dbg !256
  store i8* %1, i8** %5, align 4
  call void @llvm.dbg.declare(metadata i8** %5, metadata !257, metadata !DIExpression()), !dbg !258
  store i8* %2, i8** %6, align 4
  call void @llvm.dbg.declare(metadata i8** %6, metadata !259, metadata !DIExpression()), !dbg !260
  %9 = load i8*, i8** %4, align 4, !dbg !261
  %10 = load i8*, i8** %5, align 4, !dbg !262
  %11 = load i8*, i8** %6, align 4, !dbg !263
  call void @llvm.dbg.declare(metadata %struct.k_thread** %7, metadata !264, metadata !DIExpression()), !dbg !265
  %12 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %8, i32 0, i32 0, !dbg !266
  store i64 0, i64* %12, align 8, !dbg !266
  %13 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %8, i32 0, i32 0, !dbg !267
  %14 = bitcast i64* %13 to [1 x i64]*, !dbg !267
  %15 = load [1 x i64], [1 x i64]* %14, align 8, !dbg !267
  %16 = call %struct.k_thread* @k_thread_create(%struct.k_thread* @threadB_data, %struct.z_thread_stack_element* getelementptr inbounds ([1024 x %struct.z_thread_stack_element], [1024 x %struct.z_thread_stack_element]* @threadB_stack_area, i32 0, i32 0), i32 1024, void (i8*, i8*, i8*)* @threadB, i8* null, i8* null, i8* null, i32 7, i32 0, [1 x i64] %15) #3, !dbg !267
  store %struct.k_thread* %16, %struct.k_thread** %7, align 4, !dbg !265
  %17 = load %struct.k_thread*, %struct.k_thread** %7, align 4, !dbg !268
  %18 = call i32 @k_thread_name_set(%struct.k_thread* %17, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.2, i32 0, i32 0)) #3, !dbg !269
  call void @helloLoop(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__func__.threadA, i32 0, i32 0), %struct.sys_sem* @threadA_sem, %struct.sys_sem* @threadB_sem) #3, !dbg !270
  ret void, !dbg !271
}

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: noinline nounwind optnone
define dso_local void @threadB(i8*, i8*, i8*) #0 !dbg !272 {
  %4 = alloca i8*, align 4
  %5 = alloca i8*, align 4
  %6 = alloca i8*, align 4
  store i8* %0, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !273, metadata !DIExpression()), !dbg !274
  store i8* %1, i8** %5, align 4
  call void @llvm.dbg.declare(metadata i8** %5, metadata !275, metadata !DIExpression()), !dbg !276
  store i8* %2, i8** %6, align 4
  call void @llvm.dbg.declare(metadata i8** %6, metadata !277, metadata !DIExpression()), !dbg !278
  %7 = load i8*, i8** %4, align 4, !dbg !279
  %8 = load i8*, i8** %5, align 4, !dbg !280
  %9 = load i8*, i8** %6, align 4, !dbg !281
  call void @helloLoop(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__func__.threadB, i32 0, i32 0), %struct.sys_sem* @threadB_sem, %struct.sys_sem* @threadA_sem) #3, !dbg !282
  ret void, !dbg !283
}

; Function Attrs: noinline nounwind optnone
define internal %struct.k_thread* @k_thread_create(%struct.k_thread*, %struct.z_thread_stack_element*, i32, void (i8*, i8*, i8*)*, i8*, i8*, i8*, i32, i32, [1 x i64]) #0 !dbg !284 {
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
  call void @llvm.dbg.declare(metadata %struct.k_thread** %12, metadata !292, metadata !DIExpression()), !dbg !293
  store %struct.z_thread_stack_element* %1, %struct.z_thread_stack_element** %13, align 4
  call void @llvm.dbg.declare(metadata %struct.z_thread_stack_element** %13, metadata !294, metadata !DIExpression()), !dbg !295
  store i32 %2, i32* %14, align 4
  call void @llvm.dbg.declare(metadata i32* %14, metadata !296, metadata !DIExpression()), !dbg !297
  store void (i8*, i8*, i8*)* %3, void (i8*, i8*, i8*)** %15, align 4
  call void @llvm.dbg.declare(metadata void (i8*, i8*, i8*)** %15, metadata !298, metadata !DIExpression()), !dbg !299
  store i8* %4, i8** %16, align 4
  call void @llvm.dbg.declare(metadata i8** %16, metadata !300, metadata !DIExpression()), !dbg !301
  store i8* %5, i8** %17, align 4
  call void @llvm.dbg.declare(metadata i8** %17, metadata !302, metadata !DIExpression()), !dbg !303
  store i8* %6, i8** %18, align 4
  call void @llvm.dbg.declare(metadata i8** %18, metadata !304, metadata !DIExpression()), !dbg !305
  store i32 %7, i32* %19, align 4
  call void @llvm.dbg.declare(metadata i32* %19, metadata !306, metadata !DIExpression()), !dbg !307
  store i32 %8, i32* %20, align 4
  call void @llvm.dbg.declare(metadata i32* %20, metadata !308, metadata !DIExpression()), !dbg !309
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %11, metadata !310, metadata !DIExpression()), !dbg !311
  br label %23, !dbg !312

23:                                               ; preds = %10
  call void asm sideeffect "", "~{memory}"() #4, !dbg !313, !srcloc !315
  br label %24, !dbg !313

24:                                               ; preds = %23
  %25 = load %struct.k_thread*, %struct.k_thread** %12, align 4, !dbg !316
  %26 = load %struct.z_thread_stack_element*, %struct.z_thread_stack_element** %13, align 4, !dbg !317
  %27 = load i32, i32* %14, align 4, !dbg !318
  %28 = load void (i8*, i8*, i8*)*, void (i8*, i8*, i8*)** %15, align 4, !dbg !319
  %29 = load i8*, i8** %16, align 4, !dbg !320
  %30 = load i8*, i8** %17, align 4, !dbg !321
  %31 = load i8*, i8** %18, align 4, !dbg !322
  %32 = load i32, i32* %19, align 4, !dbg !323
  %33 = load i32, i32* %20, align 4, !dbg !324
  %34 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %11, i32 0, i32 0, !dbg !325
  %35 = bitcast i64* %34 to [1 x i64]*, !dbg !325
  %36 = load [1 x i64], [1 x i64]* %35, align 8, !dbg !325
  %37 = call %struct.k_thread* @z_impl_k_thread_create(%struct.k_thread* %25, %struct.z_thread_stack_element* %26, i32 %27, void (i8*, i8*, i8*)* %28, i8* %29, i8* %30, i8* %31, i32 %32, i32 %33, [1 x i64] %36) #3, !dbg !325
  ret %struct.k_thread* %37, !dbg !326
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_thread_name_set(%struct.k_thread*, i8*) #0 !dbg !327 {
  %3 = alloca %struct.k_thread*, align 4
  %4 = alloca i8*, align 4
  store %struct.k_thread* %0, %struct.k_thread** %3, align 4
  call void @llvm.dbg.declare(metadata %struct.k_thread** %3, metadata !330, metadata !DIExpression()), !dbg !331
  store i8* %1, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !332, metadata !DIExpression()), !dbg !333
  br label %5, !dbg !334

5:                                                ; preds = %2
  call void asm sideeffect "", "~{memory}"() #4, !dbg !335, !srcloc !337
  br label %6, !dbg !335

6:                                                ; preds = %5
  %7 = load %struct.k_thread*, %struct.k_thread** %3, align 4, !dbg !338
  %8 = load i8*, i8** %4, align 4, !dbg !339
  %9 = call i32 @z_impl_k_thread_name_set(%struct.k_thread* %7, i8* %8) #3, !dbg !340
  ret i32 %9, !dbg !341
}

; Function Attrs: noinline nounwind optnone
define dso_local void @helloLoop(i8*, %struct.sys_sem*, %struct.sys_sem*) #0 !dbg !342 {
  %4 = alloca i8*, align 4
  %5 = alloca %struct.sys_sem*, align 4
  %6 = alloca %struct.sys_sem*, align 4
  %7 = alloca i8*, align 4
  %8 = alloca %struct.k_timeout_t, align 8
  store i8* %0, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !346, metadata !DIExpression()), !dbg !347
  store %struct.sys_sem* %1, %struct.sys_sem** %5, align 4
  call void @llvm.dbg.declare(metadata %struct.sys_sem** %5, metadata !348, metadata !DIExpression()), !dbg !349
  store %struct.sys_sem* %2, %struct.sys_sem** %6, align 4
  call void @llvm.dbg.declare(metadata %struct.sys_sem** %6, metadata !350, metadata !DIExpression()), !dbg !351
  call void @llvm.dbg.declare(metadata i8** %7, metadata !352, metadata !DIExpression()), !dbg !353
  br label %9, !dbg !354

9:                                                ; preds = %30, %3
  %10 = load %struct.sys_sem*, %struct.sys_sem** %5, align 4, !dbg !355
  %11 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %8, i32 0, i32 0, !dbg !357
  store i64 -1, i64* %11, align 8, !dbg !357
  %12 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %8, i32 0, i32 0, !dbg !358
  %13 = bitcast i64* %12 to [1 x i64]*, !dbg !358
  %14 = load [1 x i64], [1 x i64]* %13, align 8, !dbg !358
  %15 = call i32 @sys_sem_take(%struct.sys_sem* %10, [1 x i64] %14) #3, !dbg !358
  %16 = call %struct.k_thread* @k_current_get() #3, !dbg !359
  %17 = call i8* @k_thread_name_get(%struct.k_thread* %16) #3, !dbg !360
  store i8* %17, i8** %7, align 4, !dbg !361
  %18 = load i8*, i8** %7, align 4, !dbg !362
  %19 = icmp ne i8* %18, null, !dbg !364
  br i1 %19, label %20, label %28, !dbg !365

20:                                               ; preds = %9
  %21 = load i8*, i8** %7, align 4, !dbg !366
  %22 = getelementptr i8, i8* %21, i32 0, !dbg !366
  %23 = load i8, i8* %22, align 1, !dbg !366
  %24 = zext i8 %23 to i32, !dbg !366
  %25 = icmp ne i32 %24, 0, !dbg !367
  br i1 %25, label %26, label %28, !dbg !368

26:                                               ; preds = %20
  %27 = load i8*, i8** %7, align 4, !dbg !369
  call void (i8*, ...) @printk(i8* getelementptr inbounds ([26 x i8], [26 x i8]* @.str, i32 0, i32 0), i8* %27, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i32 0, i32 0)) #3, !dbg !371
  br label %30, !dbg !372

28:                                               ; preds = %20, %9
  %29 = load i8*, i8** %4, align 4, !dbg !373
  call void (i8*, ...) @printk(i8* getelementptr inbounds ([26 x i8], [26 x i8]* @.str, i32 0, i32 0), i8* %29, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i32 0, i32 0)) #3, !dbg !375
  br label %30

30:                                               ; preds = %28, %26
  %31 = call i32 @k_msleep(i32 500) #3, !dbg !376
  %32 = load %struct.sys_sem*, %struct.sys_sem** %6, align 4, !dbg !377
  %33 = call i32 @sys_sem_give(%struct.sys_sem* %32) #3, !dbg !378
  br label %9, !dbg !354, !llvm.loop !379
}

declare dso_local i32 @sys_sem_take(%struct.sys_sem*, [1 x i64]) #2

; Function Attrs: noinline nounwind optnone
define internal %struct.k_thread* @k_current_get() #0 !dbg !381 {
  br label %1, !dbg !384

1:                                                ; preds = %0
  call void asm sideeffect "", "~{memory}"() #4, !dbg !385, !srcloc !387
  br label %2, !dbg !385

2:                                                ; preds = %1
  %3 = call %struct.k_thread* bitcast (%struct.k_thread* (...)* @z_impl_k_current_get to %struct.k_thread* ()*)() #3, !dbg !388
  ret %struct.k_thread* %3, !dbg !389
}

declare dso_local i8* @k_thread_name_get(%struct.k_thread*) #2

declare dso_local void @printk(i8*, ...) #2

; Function Attrs: noinline nounwind optnone
define internal i32 @k_msleep(i32) #0 !dbg !390 {
  %2 = alloca i32, align 4
  %3 = alloca %struct.k_timeout_t, align 8
  store i32 %0, i32* %2, align 4
  call void @llvm.dbg.declare(metadata i32* %2, metadata !393, metadata !DIExpression()), !dbg !394
  %4 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !395
  %5 = load i32, i32* %2, align 4, !dbg !395
  %6 = icmp sgt i32 %5, 0, !dbg !395
  br i1 %6, label %7, label %9, !dbg !395

7:                                                ; preds = %1
  %8 = load i32, i32* %2, align 4, !dbg !395
  br label %10, !dbg !395

9:                                                ; preds = %1
  br label %10, !dbg !395

10:                                               ; preds = %9, %7
  %11 = phi i32 [ %8, %7 ], [ 0, %9 ], !dbg !395
  %12 = sext i32 %11 to i64, !dbg !395
  %13 = call i64 @k_ms_to_ticks_ceil64(i64 %12) #3, !dbg !395
  store i64 %13, i64* %4, align 8, !dbg !395
  %14 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !396
  %15 = bitcast i64* %14 to [1 x i64]*, !dbg !396
  %16 = load [1 x i64], [1 x i64]* %15, align 8, !dbg !396
  %17 = call i32 @k_sleep([1 x i64] %16) #3, !dbg !396
  ret i32 %17, !dbg !397
}

declare dso_local i32 @sys_sem_give(%struct.sys_sem*) #2

; Function Attrs: noinline nounwind optnone
define internal i64 @k_ms_to_ticks_ceil64(i64) #0 !dbg !398 {
  %2 = alloca i64, align 8
  %3 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %3, metadata !404, metadata !DIExpression()), !dbg !409
  %4 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !411, metadata !DIExpression()), !dbg !412
  %5 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %5, metadata !413, metadata !DIExpression()), !dbg !414
  %6 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %6, metadata !415, metadata !DIExpression()), !dbg !416
  %7 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %7, metadata !417, metadata !DIExpression()), !dbg !418
  %8 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %8, metadata !419, metadata !DIExpression()), !dbg !420
  %9 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %9, metadata !421, metadata !DIExpression()), !dbg !422
  %10 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %10, metadata !423, metadata !DIExpression()), !dbg !424
  %11 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %11, metadata !425, metadata !DIExpression()), !dbg !426
  %12 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %12, metadata !427, metadata !DIExpression()), !dbg !428
  %13 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %13, metadata !429, metadata !DIExpression()), !dbg !432
  %14 = alloca i64, align 8
  store i64 %0, i64* %14, align 8
  call void @llvm.dbg.declare(metadata i64* %14, metadata !433, metadata !DIExpression()), !dbg !434
  %15 = load i64, i64* %14, align 8, !dbg !435
  store i64 %15, i64* %3, align 8
  store i32 1000, i32* %4, align 4
  store i32 10000, i32* %5, align 4
  store i8 1, i8* %6, align 1
  store i8 0, i8* %7, align 1
  store i8 1, i8* %8, align 1
  store i8 0, i8* %9, align 1
  %16 = load i8, i8* %6, align 1, !dbg !436
  %17 = trunc i8 %16 to i1, !dbg !436
  br i1 %17, label %18, label %27, !dbg !437

18:                                               ; preds = %1
  %19 = load i32, i32* %5, align 4, !dbg !438
  %20 = load i32, i32* %4, align 4, !dbg !439
  %21 = icmp ugt i32 %19, %20, !dbg !440
  br i1 %21, label %22, label %27, !dbg !441

22:                                               ; preds = %18
  %23 = load i32, i32* %5, align 4, !dbg !442
  %24 = load i32, i32* %4, align 4, !dbg !443
  %25 = urem i32 %23, %24, !dbg !444
  %26 = icmp eq i32 %25, 0, !dbg !445
  br label %27

27:                                               ; preds = %22, %18, %1
  %28 = phi i1 [ false, %18 ], [ false, %1 ], [ %26, %22 ], !dbg !446
  %29 = zext i1 %28 to i8, !dbg !424
  store i8 %29, i8* %10, align 1, !dbg !424
  %30 = load i8, i8* %6, align 1, !dbg !447
  %31 = trunc i8 %30 to i1, !dbg !447
  br i1 %31, label %32, label %41, !dbg !448

32:                                               ; preds = %27
  %33 = load i32, i32* %4, align 4, !dbg !449
  %34 = load i32, i32* %5, align 4, !dbg !450
  %35 = icmp ugt i32 %33, %34, !dbg !451
  br i1 %35, label %36, label %41, !dbg !452

36:                                               ; preds = %32
  %37 = load i32, i32* %4, align 4, !dbg !453
  %38 = load i32, i32* %5, align 4, !dbg !454
  %39 = urem i32 %37, %38, !dbg !455
  %40 = icmp eq i32 %39, 0, !dbg !456
  br label %41

41:                                               ; preds = %36, %32, %27
  %42 = phi i1 [ false, %32 ], [ false, %27 ], [ %40, %36 ], !dbg !446
  %43 = zext i1 %42 to i8, !dbg !426
  store i8 %43, i8* %11, align 1, !dbg !426
  %44 = load i32, i32* %4, align 4, !dbg !457
  %45 = load i32, i32* %5, align 4, !dbg !459
  %46 = icmp eq i32 %44, %45, !dbg !460
  br i1 %46, label %47, label %58, !dbg !461

47:                                               ; preds = %41
  %48 = load i8, i8* %7, align 1, !dbg !462
  %49 = trunc i8 %48 to i1, !dbg !462
  br i1 %49, label %50, label %54, !dbg !462

50:                                               ; preds = %47
  %51 = load i64, i64* %3, align 8, !dbg !464
  %52 = trunc i64 %51 to i32, !dbg !465
  %53 = zext i32 %52 to i64, !dbg !466
  br label %56, !dbg !462

54:                                               ; preds = %47
  %55 = load i64, i64* %3, align 8, !dbg !467
  br label %56, !dbg !462

56:                                               ; preds = %54, %50
  %57 = phi i64 [ %53, %50 ], [ %55, %54 ], !dbg !462
  store i64 %57, i64* %2, align 8, !dbg !468
  br label %160, !dbg !468

58:                                               ; preds = %41
  store i64 0, i64* %12, align 8, !dbg !428
  %59 = load i8, i8* %10, align 1, !dbg !469
  %60 = trunc i8 %59 to i1, !dbg !469
  br i1 %60, label %87, label %61, !dbg !470

61:                                               ; preds = %58
  %62 = load i8, i8* %11, align 1, !dbg !471
  %63 = trunc i8 %62 to i1, !dbg !471
  br i1 %63, label %64, label %68, !dbg !471

64:                                               ; preds = %61
  %65 = load i32, i32* %4, align 4, !dbg !472
  %66 = load i32, i32* %5, align 4, !dbg !473
  %67 = udiv i32 %65, %66, !dbg !474
  br label %70, !dbg !471

68:                                               ; preds = %61
  %69 = load i32, i32* %4, align 4, !dbg !475
  br label %70, !dbg !471

70:                                               ; preds = %68, %64
  %71 = phi i32 [ %67, %64 ], [ %69, %68 ], !dbg !471
  store i32 %71, i32* %13, align 4, !dbg !432
  %72 = load i8, i8* %8, align 1, !dbg !476
  %73 = trunc i8 %72 to i1, !dbg !476
  br i1 %73, label %74, label %78, !dbg !478

74:                                               ; preds = %70
  %75 = load i32, i32* %13, align 4, !dbg !479
  %76 = sub i32 %75, 1, !dbg !481
  %77 = zext i32 %76 to i64, !dbg !479
  store i64 %77, i64* %12, align 8, !dbg !482
  br label %86, !dbg !483

78:                                               ; preds = %70
  %79 = load i8, i8* %9, align 1, !dbg !484
  %80 = trunc i8 %79 to i1, !dbg !484
  br i1 %80, label %81, label %85, !dbg !486

81:                                               ; preds = %78
  %82 = load i32, i32* %13, align 4, !dbg !487
  %83 = udiv i32 %82, 2, !dbg !489
  %84 = zext i32 %83 to i64, !dbg !487
  store i64 %84, i64* %12, align 8, !dbg !490
  br label %85, !dbg !491

85:                                               ; preds = %81, %78
  br label %86

86:                                               ; preds = %85, %74
  br label %87, !dbg !492

87:                                               ; preds = %86, %58
  %88 = load i8, i8* %11, align 1, !dbg !493
  %89 = trunc i8 %88 to i1, !dbg !493
  br i1 %89, label %90, label %114, !dbg !495

90:                                               ; preds = %87
  %91 = load i64, i64* %12, align 8, !dbg !496
  %92 = load i64, i64* %3, align 8, !dbg !498
  %93 = add i64 %92, %91, !dbg !498
  store i64 %93, i64* %3, align 8, !dbg !498
  %94 = load i8, i8* %7, align 1, !dbg !499
  %95 = trunc i8 %94 to i1, !dbg !499
  br i1 %95, label %96, label %107, !dbg !501

96:                                               ; preds = %90
  %97 = load i64, i64* %3, align 8, !dbg !502
  %98 = icmp ult i64 %97, 4294967296, !dbg !503
  br i1 %98, label %99, label %107, !dbg !504

99:                                               ; preds = %96
  %100 = load i64, i64* %3, align 8, !dbg !505
  %101 = trunc i64 %100 to i32, !dbg !507
  %102 = load i32, i32* %4, align 4, !dbg !508
  %103 = load i32, i32* %5, align 4, !dbg !509
  %104 = udiv i32 %102, %103, !dbg !510
  %105 = udiv i32 %101, %104, !dbg !511
  %106 = zext i32 %105 to i64, !dbg !512
  store i64 %106, i64* %2, align 8, !dbg !513
  br label %160, !dbg !513

107:                                              ; preds = %96, %90
  %108 = load i64, i64* %3, align 8, !dbg !514
  %109 = load i32, i32* %4, align 4, !dbg !516
  %110 = load i32, i32* %5, align 4, !dbg !517
  %111 = udiv i32 %109, %110, !dbg !518
  %112 = zext i32 %111 to i64, !dbg !519
  %113 = udiv i64 %108, %112, !dbg !520
  store i64 %113, i64* %2, align 8, !dbg !521
  br label %160, !dbg !521

114:                                              ; preds = %87
  %115 = load i8, i8* %10, align 1, !dbg !522
  %116 = trunc i8 %115 to i1, !dbg !522
  br i1 %116, label %117, label %135, !dbg !524

117:                                              ; preds = %114
  %118 = load i8, i8* %7, align 1, !dbg !525
  %119 = trunc i8 %118 to i1, !dbg !525
  br i1 %119, label %120, label %128, !dbg !528

120:                                              ; preds = %117
  %121 = load i64, i64* %3, align 8, !dbg !529
  %122 = trunc i64 %121 to i32, !dbg !531
  %123 = load i32, i32* %5, align 4, !dbg !532
  %124 = load i32, i32* %4, align 4, !dbg !533
  %125 = udiv i32 %123, %124, !dbg !534
  %126 = mul i32 %122, %125, !dbg !535
  %127 = zext i32 %126 to i64, !dbg !536
  store i64 %127, i64* %2, align 8, !dbg !537
  br label %160, !dbg !537

128:                                              ; preds = %117
  %129 = load i64, i64* %3, align 8, !dbg !538
  %130 = load i32, i32* %5, align 4, !dbg !540
  %131 = load i32, i32* %4, align 4, !dbg !541
  %132 = udiv i32 %130, %131, !dbg !542
  %133 = zext i32 %132 to i64, !dbg !543
  %134 = mul i64 %129, %133, !dbg !544
  store i64 %134, i64* %2, align 8, !dbg !545
  br label %160, !dbg !545

135:                                              ; preds = %114
  %136 = load i8, i8* %7, align 1, !dbg !546
  %137 = trunc i8 %136 to i1, !dbg !546
  br i1 %137, label %138, label %150, !dbg !549

138:                                              ; preds = %135
  %139 = load i64, i64* %3, align 8, !dbg !550
  %140 = load i32, i32* %5, align 4, !dbg !552
  %141 = zext i32 %140 to i64, !dbg !552
  %142 = mul i64 %139, %141, !dbg !553
  %143 = load i64, i64* %12, align 8, !dbg !554
  %144 = add i64 %142, %143, !dbg !555
  %145 = load i32, i32* %4, align 4, !dbg !556
  %146 = zext i32 %145 to i64, !dbg !556
  %147 = udiv i64 %144, %146, !dbg !557
  %148 = trunc i64 %147 to i32, !dbg !558
  %149 = zext i32 %148 to i64, !dbg !558
  store i64 %149, i64* %2, align 8, !dbg !559
  br label %160, !dbg !559

150:                                              ; preds = %135
  %151 = load i64, i64* %3, align 8, !dbg !560
  %152 = load i32, i32* %5, align 4, !dbg !562
  %153 = zext i32 %152 to i64, !dbg !562
  %154 = mul i64 %151, %153, !dbg !563
  %155 = load i64, i64* %12, align 8, !dbg !564
  %156 = add i64 %154, %155, !dbg !565
  %157 = load i32, i32* %4, align 4, !dbg !566
  %158 = zext i32 %157 to i64, !dbg !566
  %159 = udiv i64 %156, %158, !dbg !567
  store i64 %159, i64* %2, align 8, !dbg !568
  br label %160, !dbg !568

160:                                              ; preds = %150, %138, %128, %120, %107, %99, %56
  %161 = load i64, i64* %2, align 8, !dbg !569
  ret i64 %161, !dbg !570
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_sleep([1 x i64]) #0 !dbg !571 {
  %2 = alloca %struct.k_timeout_t, align 8
  %3 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0
  %4 = bitcast i64* %3 to [1 x i64]*
  store [1 x i64] %0, [1 x i64]* %4, align 8
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %2, metadata !574, metadata !DIExpression()), !dbg !575
  br label %5, !dbg !576

5:                                                ; preds = %1
  call void asm sideeffect "", "~{memory}"() #4, !dbg !577, !srcloc !579
  br label %6, !dbg !577

6:                                                ; preds = %5
  %7 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !580
  %8 = bitcast i64* %7 to [1 x i64]*, !dbg !580
  %9 = load [1 x i64], [1 x i64]* %8, align 8, !dbg !580
  %10 = call i32 @z_impl_k_sleep([1 x i64] %9) #3, !dbg !580
  ret i32 %10, !dbg !581
}

declare dso_local i32 @z_impl_k_sleep([1 x i64]) #2

declare dso_local %struct.k_thread* @z_impl_k_current_get(...) #2

declare dso_local i32 @z_impl_k_thread_name_set(%struct.k_thread*, i8*) #2

declare dso_local %struct.k_thread* @z_impl_k_thread_create(%struct.k_thread*, %struct.z_thread_stack_element*, i32, void (i8*, i8*, i8*)*, i8*, i8*, i8*, i32, i32, [1 x i64]) #2

; Function Attrs: noinline nounwind optnone
define dso_local void @main() #0 !dbg !582 {
  %1 = alloca %struct.k_timeout_t, align 8
  %2 = alloca %struct.k_timeout_t, align 8
  %3 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %1, i32 0, i32 0, !dbg !583
  store i64 -1, i64* %3, align 8, !dbg !583
  %4 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %1, i32 0, i32 0, !dbg !584
  %5 = bitcast i64* %4 to [1 x i64]*, !dbg !584
  %6 = load [1 x i64], [1 x i64]* %5, align 8, !dbg !584
  %7 = call i32 @k_thread_join(%struct.k_thread* @_k_thread_obj_thread_a, [1 x i64] %6) #3, !dbg !584
  %8 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !585
  store i64 -1, i64* %8, align 8, !dbg !585
  %9 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !586
  %10 = bitcast i64* %9 to [1 x i64]*, !dbg !586
  %11 = load [1 x i64], [1 x i64]* %10, align 8, !dbg !586
  %12 = call i32 @k_thread_join(%struct.k_thread* @threadB_data, [1 x i64] %11) #3, !dbg !586
  ret void, !dbg !587
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_thread_join(%struct.k_thread*, [1 x i64]) #0 !dbg !588 {
  %3 = alloca %struct.k_timeout_t, align 8
  %4 = alloca %struct.k_thread*, align 4
  %5 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0
  %6 = bitcast i64* %5 to [1 x i64]*
  store [1 x i64] %1, [1 x i64]* %6, align 8
  store %struct.k_thread* %0, %struct.k_thread** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.k_thread** %4, metadata !591, metadata !DIExpression()), !dbg !592
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %3, metadata !593, metadata !DIExpression()), !dbg !594
  br label %7, !dbg !595

7:                                                ; preds = %2
  call void asm sideeffect "", "~{memory}"() #4, !dbg !596, !srcloc !598
  br label %8, !dbg !596

8:                                                ; preds = %7
  %9 = load %struct.k_thread*, %struct.k_thread** %4, align 4, !dbg !599
  %10 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !600
  %11 = bitcast i64* %10 to [1 x i64]*, !dbg !600
  %12 = load [1 x i64], [1 x i64]* %11, align 8, !dbg !600
  %13 = call i32 @z_impl_k_thread_join(%struct.k_thread* %9, [1 x i64] %12) #3, !dbg !600
  ret i32 %13, !dbg !601
}

declare dso_local i32 @z_impl_k_thread_join(%struct.k_thread*, [1 x i64]) #2

attributes #0 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #1 = { nounwind readnone speculatable }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #3 = { nobuiltin }
attributes #4 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.ident = !{!249}
!llvm.module.flags = !{!250, !251, !252, !253}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "threadA_sem", scope: !2, file: !65, line: 39, type: !66, isLocal: false, isDefinition: true, align: 32)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !52, globals: !62, nameTableKind: None)
!3 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/static_sys_sems/src/main.c", directory: "/home/kenny/ara/build/appl/Zephyr/static_sys_sems")
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
!62 = !{!0, !63, !95, !234, !238, !243, !245, !247}
!63 = !DIGlobalVariableExpression(var: !64, expr: !DIExpression())
!64 = distinct !DIGlobalVariable(name: "threadB_sem", scope: !2, file: !65, line: 40, type: !66, isLocal: false, isDefinition: true, align: 32)
!65 = !DIFile(filename: "appl/Zephyr/static_sys_sems/src/main.c", directory: "/home/kenny/ara")
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
!96 = distinct !DIGlobalVariable(name: "_k_thread_data_thread_a", scope: !2, file: !65, line: 70, type: !97, isLocal: false, isDefinition: true, align: 32)
!97 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_static_thread_data", file: !6, line: 1099, size: 384, elements: !98)
!98 = !{!99, !208, !217, !218, !223, !224, !225, !226, !227, !228, !230, !231}
!99 = !DIDerivedType(tag: DW_TAG_member, name: "init_thread", scope: !97, file: !6, line: 1100, baseType: !100, size: 32)
!100 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !101, size: 32)
!101 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_thread", file: !6, line: 570, size: 1024, elements: !102)
!102 = !{!103, !152, !165, !166, !170, !171, !181, !203}
!103 = !DIDerivedType(tag: DW_TAG_member, name: "base", scope: !101, file: !6, line: 572, baseType: !104, size: 448)
!104 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_base", file: !6, line: 441, size: 448, elements: !105)
!105 = !{!106, !120, !122, !124, !125, !138, !139, !140, !151}
!106 = !DIDerivedType(tag: DW_TAG_member, scope: !104, file: !6, line: 444, baseType: !107, size: 64)
!107 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !104, file: !6, line: 444, size: 64, elements: !108)
!108 = !{!109, !111}
!109 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_dlist", scope: !107, file: !6, line: 445, baseType: !110, size: 64)
!110 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dnode_t", file: !79, line: 43, baseType: !80)
!111 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_rb", scope: !107, file: !6, line: 446, baseType: !112, size: 64)
!112 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "rbnode", file: !113, line: 48, size: 64, elements: !114)
!113 = !DIFile(filename: "zephyrproject/zephyr/include/sys/rb.h", directory: "/home/kenny")
!114 = !{!115}
!115 = !DIDerivedType(tag: DW_TAG_member, name: "children", scope: !112, file: !113, line: 49, baseType: !116, size: 64)
!116 = !DICompositeType(tag: DW_TAG_array_type, baseType: !117, size: 64, elements: !118)
!117 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !112, size: 32)
!118 = !{!119}
!119 = !DISubrange(count: 2)
!120 = !DIDerivedType(tag: DW_TAG_member, name: "pended_on", scope: !104, file: !6, line: 452, baseType: !121, size: 32, offset: 64)
!121 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !73, size: 32)
!122 = !DIDerivedType(tag: DW_TAG_member, name: "user_options", scope: !104, file: !6, line: 455, baseType: !123, size: 8, offset: 96)
!123 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !56, line: 55, baseType: !7)
!124 = !DIDerivedType(tag: DW_TAG_member, name: "thread_state", scope: !104, file: !6, line: 458, baseType: !123, size: 8, offset: 104)
!125 = !DIDerivedType(tag: DW_TAG_member, scope: !104, file: !6, line: 474, baseType: !126, size: 16, offset: 112)
!126 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !104, file: !6, line: 474, size: 16, elements: !127)
!127 = !{!128, !135}
!128 = !DIDerivedType(tag: DW_TAG_member, scope: !126, file: !6, line: 475, baseType: !129, size: 16)
!129 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !126, file: !6, line: 475, size: 16, elements: !130)
!130 = !{!131, !134}
!131 = !DIDerivedType(tag: DW_TAG_member, name: "prio", scope: !129, file: !6, line: 480, baseType: !132, size: 8)
!132 = !DIDerivedType(tag: DW_TAG_typedef, name: "int8_t", file: !56, line: 40, baseType: !133)
!133 = !DIBasicType(name: "signed char", size: 8, encoding: DW_ATE_signed_char)
!134 = !DIDerivedType(tag: DW_TAG_member, name: "sched_locked", scope: !129, file: !6, line: 481, baseType: !123, size: 8, offset: 8)
!135 = !DIDerivedType(tag: DW_TAG_member, name: "preempt", scope: !126, file: !6, line: 484, baseType: !136, size: 16)
!136 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !56, line: 56, baseType: !137)
!137 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!138 = !DIDerivedType(tag: DW_TAG_member, name: "order_key", scope: !104, file: !6, line: 491, baseType: !60, size: 32, offset: 128)
!139 = !DIDerivedType(tag: DW_TAG_member, name: "swap_data", scope: !104, file: !6, line: 511, baseType: !58, size: 32, offset: 160)
!140 = !DIDerivedType(tag: DW_TAG_member, name: "timeout", scope: !104, file: !6, line: 515, baseType: !141, size: 192, offset: 192)
!141 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_timeout", file: !74, line: 221, size: 192, elements: !142)
!142 = !{!143, !144, !150}
!143 = !DIDerivedType(tag: DW_TAG_member, name: "node", scope: !141, file: !74, line: 222, baseType: !110, size: 64)
!144 = !DIDerivedType(tag: DW_TAG_member, name: "fn", scope: !141, file: !74, line: 223, baseType: !145, size: 32, offset: 64)
!145 = !DIDerivedType(tag: DW_TAG_typedef, name: "_timeout_func_t", file: !74, line: 219, baseType: !146)
!146 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !147, size: 32)
!147 = !DISubroutineType(types: !148)
!148 = !{null, !149}
!149 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !141, size: 32)
!150 = !DIDerivedType(tag: DW_TAG_member, name: "dticks", scope: !141, file: !74, line: 226, baseType: !55, size: 64, offset: 128)
!151 = !DIDerivedType(tag: DW_TAG_member, name: "join_waiters", scope: !104, file: !6, line: 518, baseType: !73, size: 64, offset: 384)
!152 = !DIDerivedType(tag: DW_TAG_member, name: "callee_saved", scope: !101, file: !6, line: 575, baseType: !153, size: 288, offset: 448)
!153 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_callee_saved", file: !154, line: 25, size: 288, elements: !155)
!154 = !DIFile(filename: "zephyrproject/zephyr/include/arch/arm/aarch32/thread.h", directory: "/home/kenny")
!155 = !{!156, !157, !158, !159, !160, !161, !162, !163, !164}
!156 = !DIDerivedType(tag: DW_TAG_member, name: "v1", scope: !153, file: !154, line: 26, baseType: !60, size: 32)
!157 = !DIDerivedType(tag: DW_TAG_member, name: "v2", scope: !153, file: !154, line: 27, baseType: !60, size: 32, offset: 32)
!158 = !DIDerivedType(tag: DW_TAG_member, name: "v3", scope: !153, file: !154, line: 28, baseType: !60, size: 32, offset: 64)
!159 = !DIDerivedType(tag: DW_TAG_member, name: "v4", scope: !153, file: !154, line: 29, baseType: !60, size: 32, offset: 96)
!160 = !DIDerivedType(tag: DW_TAG_member, name: "v5", scope: !153, file: !154, line: 30, baseType: !60, size: 32, offset: 128)
!161 = !DIDerivedType(tag: DW_TAG_member, name: "v6", scope: !153, file: !154, line: 31, baseType: !60, size: 32, offset: 160)
!162 = !DIDerivedType(tag: DW_TAG_member, name: "v7", scope: !153, file: !154, line: 32, baseType: !60, size: 32, offset: 192)
!163 = !DIDerivedType(tag: DW_TAG_member, name: "v8", scope: !153, file: !154, line: 33, baseType: !60, size: 32, offset: 224)
!164 = !DIDerivedType(tag: DW_TAG_member, name: "psp", scope: !153, file: !154, line: 34, baseType: !60, size: 32, offset: 256)
!165 = !DIDerivedType(tag: DW_TAG_member, name: "init_data", scope: !101, file: !6, line: 578, baseType: !58, size: 32, offset: 736)
!166 = !DIDerivedType(tag: DW_TAG_member, name: "fn_abort", scope: !101, file: !6, line: 583, baseType: !167, size: 32, offset: 768)
!167 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !168, size: 32)
!168 = !DISubroutineType(types: !169)
!169 = !{null}
!170 = !DIDerivedType(tag: DW_TAG_member, name: "errno_var", scope: !101, file: !6, line: 610, baseType: !59, size: 32, offset: 800)
!171 = !DIDerivedType(tag: DW_TAG_member, name: "stack_info", scope: !101, file: !6, line: 616, baseType: !172, size: 96, offset: 832)
!172 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_stack_info", file: !6, line: 525, size: 96, elements: !173)
!173 = !{!174, !177, !180}
!174 = !DIDerivedType(tag: DW_TAG_member, name: "start", scope: !172, file: !6, line: 529, baseType: !175, size: 32)
!175 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintptr_t", file: !56, line: 71, baseType: !176)
!176 = !DIBasicType(name: "long unsigned int", size: 32, encoding: DW_ATE_unsigned)
!177 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !172, file: !6, line: 538, baseType: !178, size: 32, offset: 32)
!178 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !179, line: 46, baseType: !61)
!179 = !DIFile(filename: "/usr/lib/llvm-9/lib/clang/9.0.1/include/stddef.h", directory: "")
!180 = !DIDerivedType(tag: DW_TAG_member, name: "delta", scope: !172, file: !6, line: 544, baseType: !178, size: 32, offset: 64)
!181 = !DIDerivedType(tag: DW_TAG_member, name: "resource_pool", scope: !101, file: !6, line: 641, baseType: !182, size: 32, offset: 928)
!182 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !183, size: 32)
!183 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mem_pool", file: !184, line: 30, size: 32, elements: !185)
!184 = !DIFile(filename: "zephyrproject/zephyr/include/mempool_heap.h", directory: "/home/kenny")
!185 = !{!186}
!186 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !183, file: !184, line: 31, baseType: !187, size: 32)
!187 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !188, size: 32)
!188 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_heap", file: !74, line: 267, size: 160, elements: !189)
!189 = !{!190, !199, !200}
!190 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !188, file: !74, line: 268, baseType: !191, size: 96)
!191 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "sys_heap", file: !192, line: 51, size: 96, elements: !193)
!192 = !DIFile(filename: "zephyrproject/zephyr/include/sys/sys_heap.h", directory: "/home/kenny")
!193 = !{!194, !197, !198}
!194 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !191, file: !192, line: 52, baseType: !195, size: 32)
!195 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !196, size: 32)
!196 = !DICompositeType(tag: DW_TAG_structure_type, name: "z_heap", file: !192, line: 52, flags: DIFlagFwdDecl)
!197 = !DIDerivedType(tag: DW_TAG_member, name: "init_mem", scope: !191, file: !192, line: 53, baseType: !58, size: 32, offset: 32)
!198 = !DIDerivedType(tag: DW_TAG_member, name: "init_bytes", scope: !191, file: !192, line: 54, baseType: !178, size: 32, offset: 64)
!199 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !188, file: !74, line: 269, baseType: !73, size: 64, offset: 96)
!200 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !188, file: !74, line: 270, baseType: !201, offset: 160)
!201 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_spinlock", file: !74, line: 234, elements: !202)
!202 = !{}
!203 = !DIDerivedType(tag: DW_TAG_member, name: "arch", scope: !101, file: !6, line: 644, baseType: !204, size: 64, offset: 960)
!204 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_arch", file: !154, line: 60, size: 64, elements: !205)
!205 = !{!206, !207}
!206 = !DIDerivedType(tag: DW_TAG_member, name: "basepri", scope: !204, file: !154, line: 63, baseType: !60, size: 32)
!207 = !DIDerivedType(tag: DW_TAG_member, name: "swap_return_value", scope: !204, file: !154, line: 66, baseType: !60, size: 32, offset: 32)
!208 = !DIDerivedType(tag: DW_TAG_member, name: "init_stack", scope: !97, file: !6, line: 1101, baseType: !209, size: 32, offset: 32)
!209 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !210, size: 32)
!210 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_stack_t", file: !211, line: 44, baseType: !212)
!211 = !DIFile(filename: "zephyrproject/zephyr/include/sys/arch_interface.h", directory: "/home/kenny")
!212 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "z_thread_stack_element", file: !213, line: 35, size: 8, elements: !214)
!213 = !DIFile(filename: "zephyrproject/zephyr/include/sys/thread_stack.h", directory: "/home/kenny")
!214 = !{!215}
!215 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !212, file: !213, line: 36, baseType: !216, size: 8)
!216 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_unsigned_char)
!217 = !DIDerivedType(tag: DW_TAG_member, name: "init_stack_size", scope: !97, file: !6, line: 1102, baseType: !61, size: 32, offset: 64)
!218 = !DIDerivedType(tag: DW_TAG_member, name: "init_entry", scope: !97, file: !6, line: 1103, baseType: !219, size: 32, offset: 96)
!219 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_entry_t", file: !211, line: 46, baseType: !220)
!220 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !221, size: 32)
!221 = !DISubroutineType(types: !222)
!222 = !{null, !58, !58, !58}
!223 = !DIDerivedType(tag: DW_TAG_member, name: "init_p1", scope: !97, file: !6, line: 1104, baseType: !58, size: 32, offset: 128)
!224 = !DIDerivedType(tag: DW_TAG_member, name: "init_p2", scope: !97, file: !6, line: 1105, baseType: !58, size: 32, offset: 160)
!225 = !DIDerivedType(tag: DW_TAG_member, name: "init_p3", scope: !97, file: !6, line: 1106, baseType: !58, size: 32, offset: 192)
!226 = !DIDerivedType(tag: DW_TAG_member, name: "init_prio", scope: !97, file: !6, line: 1107, baseType: !59, size: 32, offset: 224)
!227 = !DIDerivedType(tag: DW_TAG_member, name: "init_options", scope: !97, file: !6, line: 1108, baseType: !60, size: 32, offset: 256)
!228 = !DIDerivedType(tag: DW_TAG_member, name: "init_delay", scope: !97, file: !6, line: 1109, baseType: !229, size: 32, offset: 288)
!229 = !DIDerivedType(tag: DW_TAG_typedef, name: "int32_t", file: !56, line: 42, baseType: !59)
!230 = !DIDerivedType(tag: DW_TAG_member, name: "init_abort", scope: !97, file: !6, line: 1110, baseType: !167, size: 32, offset: 320)
!231 = !DIDerivedType(tag: DW_TAG_member, name: "init_name", scope: !97, file: !6, line: 1111, baseType: !232, size: 32, offset: 352)
!232 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !233, size: 32)
!233 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !216)
!234 = !DIGlobalVariableExpression(var: !235, expr: !DIExpression())
!235 = distinct !DIGlobalVariable(name: "thread_a", scope: !2, file: !65, line: 70, type: !236, isLocal: false, isDefinition: true)
!236 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !237)
!237 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_tid_t", file: !6, line: 648, baseType: !100)
!238 = !DIGlobalVariableExpression(var: !239, expr: !DIExpression())
!239 = distinct !DIGlobalVariable(name: "threadB_stack_area", scope: !2, file: !65, line: 52, type: !240, isLocal: false, isDefinition: true, align: 64)
!240 = !DICompositeType(tag: DW_TAG_array_type, baseType: !212, size: 8192, elements: !241)
!241 = !{!242}
!242 = !DISubrange(count: 1024)
!243 = !DIGlobalVariableExpression(var: !244, expr: !DIExpression())
!244 = distinct !DIGlobalVariable(name: "threadB_data", scope: !2, file: !65, line: 53, type: !101, isLocal: true, isDefinition: true)
!245 = !DIGlobalVariableExpression(var: !246, expr: !DIExpression())
!246 = distinct !DIGlobalVariable(name: "_k_thread_stack_thread_a", scope: !2, file: !65, line: 70, type: !240, isLocal: false, isDefinition: true, align: 64)
!247 = !DIGlobalVariableExpression(var: !248, expr: !DIExpression())
!248 = distinct !DIGlobalVariable(name: "_k_thread_obj_thread_a", scope: !2, file: !65, line: 70, type: !101, isLocal: false, isDefinition: true)
!249 = !{!"clang version 9.0.1-12 "}
!250 = !{i32 2, !"Dwarf Version", i32 4}
!251 = !{i32 2, !"Debug Info Version", i32 3}
!252 = !{i32 1, !"wchar_size", i32 4}
!253 = !{i32 1, !"min_enum_size", i32 1}
!254 = distinct !DISubprogram(name: "threadA", scope: !65, file: !65, line: 55, type: !221, scopeLine: 56, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !202)
!255 = !DILocalVariable(name: "dummy1", arg: 1, scope: !254, file: !65, line: 55, type: !58)
!256 = !DILocation(line: 55, column: 20, scope: !254)
!257 = !DILocalVariable(name: "dummy2", arg: 2, scope: !254, file: !65, line: 55, type: !58)
!258 = !DILocation(line: 55, column: 34, scope: !254)
!259 = !DILocalVariable(name: "dummy3", arg: 3, scope: !254, file: !65, line: 55, type: !58)
!260 = !DILocation(line: 55, column: 48, scope: !254)
!261 = !DILocation(line: 57, column: 2, scope: !254)
!262 = !DILocation(line: 58, column: 2, scope: !254)
!263 = !DILocation(line: 59, column: 2, scope: !254)
!264 = !DILocalVariable(name: "tid", scope: !254, file: !65, line: 61, type: !237)
!265 = !DILocation(line: 61, column: 10, scope: !254)
!266 = !DILocation(line: 63, column: 17, scope: !254)
!267 = !DILocation(line: 61, column: 16, scope: !254)
!268 = !DILocation(line: 65, column: 20, scope: !254)
!269 = !DILocation(line: 65, column: 2, scope: !254)
!270 = !DILocation(line: 67, column: 2, scope: !254)
!271 = !DILocation(line: 68, column: 1, scope: !254)
!272 = distinct !DISubprogram(name: "threadB", scope: !65, file: !65, line: 43, type: !221, scopeLine: 44, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !202)
!273 = !DILocalVariable(name: "dummy1", arg: 1, scope: !272, file: !65, line: 43, type: !58)
!274 = !DILocation(line: 43, column: 20, scope: !272)
!275 = !DILocalVariable(name: "dummy2", arg: 2, scope: !272, file: !65, line: 43, type: !58)
!276 = !DILocation(line: 43, column: 34, scope: !272)
!277 = !DILocalVariable(name: "dummy3", arg: 3, scope: !272, file: !65, line: 43, type: !58)
!278 = !DILocation(line: 43, column: 48, scope: !272)
!279 = !DILocation(line: 45, column: 2, scope: !272)
!280 = !DILocation(line: 46, column: 2, scope: !272)
!281 = !DILocation(line: 47, column: 2, scope: !272)
!282 = !DILocation(line: 49, column: 2, scope: !272)
!283 = !DILocation(line: 50, column: 1, scope: !272)
!284 = distinct !DISubprogram(name: "k_thread_create", scope: !285, file: !285, line: 66, type: !286, scopeLine: 67, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !202)
!285 = !DIFile(filename: "zephyr/include/generated/syscalls/kernel.h", directory: "/home/kenny/ara/build/appl/Zephyr/static_sys_sems")
!286 = !DISubroutineType(types: !287)
!287 = !{!237, !100, !209, !178, !219, !58, !58, !58, !59, !60, !288}
!288 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_timeout_t", file: !54, line: 69, baseType: !289)
!289 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !54, line: 67, size: 64, elements: !290)
!290 = !{!291}
!291 = !DIDerivedType(tag: DW_TAG_member, name: "ticks", scope: !289, file: !54, line: 68, baseType: !53, size: 64)
!292 = !DILocalVariable(name: "new_thread", arg: 1, scope: !284, file: !285, line: 66, type: !100)
!293 = !DILocation(line: 66, column: 75, scope: !284)
!294 = !DILocalVariable(name: "stack", arg: 2, scope: !284, file: !285, line: 66, type: !209)
!295 = !DILocation(line: 66, column: 106, scope: !284)
!296 = !DILocalVariable(name: "stack_size", arg: 3, scope: !284, file: !285, line: 66, type: !178)
!297 = !DILocation(line: 66, column: 120, scope: !284)
!298 = !DILocalVariable(name: "entry", arg: 4, scope: !284, file: !285, line: 66, type: !219)
!299 = !DILocation(line: 66, column: 149, scope: !284)
!300 = !DILocalVariable(name: "p1", arg: 5, scope: !284, file: !285, line: 66, type: !58)
!301 = !DILocation(line: 66, column: 163, scope: !284)
!302 = !DILocalVariable(name: "p2", arg: 6, scope: !284, file: !285, line: 66, type: !58)
!303 = !DILocation(line: 66, column: 174, scope: !284)
!304 = !DILocalVariable(name: "p3", arg: 7, scope: !284, file: !285, line: 66, type: !58)
!305 = !DILocation(line: 66, column: 185, scope: !284)
!306 = !DILocalVariable(name: "prio", arg: 8, scope: !284, file: !285, line: 66, type: !59)
!307 = !DILocation(line: 66, column: 193, scope: !284)
!308 = !DILocalVariable(name: "options", arg: 9, scope: !284, file: !285, line: 66, type: !60)
!309 = !DILocation(line: 66, column: 208, scope: !284)
!310 = !DILocalVariable(name: "delay", arg: 10, scope: !284, file: !285, line: 66, type: !288)
!311 = !DILocation(line: 66, column: 229, scope: !284)
!312 = !DILocation(line: 83, column: 2, scope: !284)
!313 = !DILocation(line: 83, column: 2, scope: !314)
!314 = distinct !DILexicalBlock(scope: !284, file: !285, line: 83, column: 2)
!315 = !{i32 -2141857676}
!316 = !DILocation(line: 84, column: 32, scope: !284)
!317 = !DILocation(line: 84, column: 44, scope: !284)
!318 = !DILocation(line: 84, column: 51, scope: !284)
!319 = !DILocation(line: 84, column: 63, scope: !284)
!320 = !DILocation(line: 84, column: 70, scope: !284)
!321 = !DILocation(line: 84, column: 74, scope: !284)
!322 = !DILocation(line: 84, column: 78, scope: !284)
!323 = !DILocation(line: 84, column: 82, scope: !284)
!324 = !DILocation(line: 84, column: 88, scope: !284)
!325 = !DILocation(line: 84, column: 9, scope: !284)
!326 = !DILocation(line: 84, column: 2, scope: !284)
!327 = distinct !DISubprogram(name: "k_thread_name_set", scope: !285, file: !285, line: 363, type: !328, scopeLine: 364, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !202)
!328 = !DISubroutineType(types: !329)
!329 = !{!59, !237, !232}
!330 = !DILocalVariable(name: "thread_id", arg: 1, scope: !327, file: !285, line: 363, type: !237)
!331 = !DILocation(line: 363, column: 63, scope: !327)
!332 = !DILocalVariable(name: "value", arg: 2, scope: !327, file: !285, line: 363, type: !232)
!333 = !DILocation(line: 363, column: 87, scope: !327)
!334 = !DILocation(line: 370, column: 2, scope: !327)
!335 = !DILocation(line: 370, column: 2, scope: !336)
!336 = distinct !DILexicalBlock(scope: !327, file: !285, line: 370, column: 2)
!337 = !{i32 -2141856248}
!338 = !DILocation(line: 371, column: 34, scope: !327)
!339 = !DILocation(line: 371, column: 45, scope: !327)
!340 = !DILocation(line: 371, column: 9, scope: !327)
!341 = !DILocation(line: 371, column: 2, scope: !327)
!342 = distinct !DISubprogram(name: "helloLoop", scope: !65, file: !65, line: 17, type: !343, scopeLine: 19, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !202)
!343 = !DISubroutineType(types: !344)
!344 = !{null, !232, !345, !345}
!345 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !66, size: 32)
!346 = !DILocalVariable(name: "my_name", arg: 1, scope: !342, file: !65, line: 17, type: !232)
!347 = !DILocation(line: 17, column: 28, scope: !342)
!348 = !DILocalVariable(name: "my_sem", arg: 2, scope: !342, file: !65, line: 18, type: !345)
!349 = !DILocation(line: 18, column: 25, scope: !342)
!350 = !DILocalVariable(name: "other_sem", arg: 3, scope: !342, file: !65, line: 18, type: !345)
!351 = !DILocation(line: 18, column: 49, scope: !342)
!352 = !DILocalVariable(name: "tname", scope: !342, file: !65, line: 20, type: !232)
!353 = !DILocation(line: 20, column: 14, scope: !342)
!354 = !DILocation(line: 22, column: 2, scope: !342)
!355 = !DILocation(line: 23, column: 16, scope: !356)
!356 = distinct !DILexicalBlock(scope: !342, file: !65, line: 22, column: 12)
!357 = !DILocation(line: 23, column: 24, scope: !356)
!358 = !DILocation(line: 23, column: 3, scope: !356)
!359 = !DILocation(line: 25, column: 29, scope: !356)
!360 = !DILocation(line: 25, column: 11, scope: !356)
!361 = !DILocation(line: 25, column: 9, scope: !356)
!362 = !DILocation(line: 26, column: 7, scope: !363)
!363 = distinct !DILexicalBlock(scope: !356, file: !65, line: 26, column: 7)
!364 = !DILocation(line: 26, column: 13, scope: !363)
!365 = !DILocation(line: 26, column: 21, scope: !363)
!366 = !DILocation(line: 26, column: 24, scope: !363)
!367 = !DILocation(line: 26, column: 33, scope: !363)
!368 = !DILocation(line: 26, column: 7, scope: !356)
!369 = !DILocation(line: 28, column: 5, scope: !370)
!370 = distinct !DILexicalBlock(scope: !363, file: !65, line: 26, column: 42)
!371 = !DILocation(line: 27, column: 4, scope: !370)
!372 = !DILocation(line: 29, column: 3, scope: !370)
!373 = !DILocation(line: 31, column: 5, scope: !374)
!374 = distinct !DILexicalBlock(scope: !363, file: !65, line: 29, column: 10)
!375 = !DILocation(line: 30, column: 4, scope: !374)
!376 = !DILocation(line: 34, column: 3, scope: !356)
!377 = !DILocation(line: 35, column: 16, scope: !356)
!378 = !DILocation(line: 35, column: 3, scope: !356)
!379 = distinct !{!379, !354, !380}
!380 = !DILocation(line: 36, column: 2, scope: !342)
!381 = distinct !DISubprogram(name: "k_current_get", scope: !285, file: !285, line: 187, type: !382, scopeLine: 188, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !202)
!382 = !DISubroutineType(types: !383)
!383 = !{!237}
!384 = !DILocation(line: 194, column: 2, scope: !381)
!385 = !DILocation(line: 194, column: 2, scope: !386)
!386 = distinct !DILexicalBlock(scope: !381, file: !285, line: 194, column: 2)
!387 = !{i32 -2141857132}
!388 = !DILocation(line: 195, column: 9, scope: !381)
!389 = !DILocation(line: 195, column: 2, scope: !381)
!390 = distinct !DISubprogram(name: "k_msleep", scope: !6, file: !6, line: 957, type: !391, scopeLine: 958, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !202)
!391 = !DISubroutineType(types: !392)
!392 = !{!229, !229}
!393 = !DILocalVariable(name: "ms", arg: 1, scope: !390, file: !6, line: 957, type: !229)
!394 = !DILocation(line: 957, column: 40, scope: !390)
!395 = !DILocation(line: 959, column: 17, scope: !390)
!396 = !DILocation(line: 959, column: 9, scope: !390)
!397 = !DILocation(line: 959, column: 2, scope: !390)
!398 = distinct !DISubprogram(name: "k_ms_to_ticks_ceil64", scope: !399, file: !399, line: 369, type: !400, scopeLine: 370, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !202)
!399 = !DIFile(filename: "zephyrproject/zephyr/include/sys/time_units.h", directory: "/home/kenny")
!400 = !DISubroutineType(types: !401)
!401 = !{!402, !402}
!402 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint64_t", file: !56, line: 58, baseType: !403)
!403 = !DIBasicType(name: "long long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!404 = !DILocalVariable(name: "t", arg: 1, scope: !405, file: !399, line: 78, type: !402)
!405 = distinct !DISubprogram(name: "z_tmcvt", scope: !399, file: !399, line: 78, type: !406, scopeLine: 82, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !202)
!406 = !DISubroutineType(types: !407)
!407 = !{!402, !402, !60, !60, !408, !408, !408, !408}
!408 = !DIBasicType(name: "_Bool", size: 8, encoding: DW_ATE_boolean)
!409 = !DILocation(line: 78, column: 63, scope: !405, inlinedAt: !410)
!410 = distinct !DILocation(line: 372, column: 9, scope: !398)
!411 = !DILocalVariable(name: "from_hz", arg: 2, scope: !405, file: !399, line: 78, type: !60)
!412 = !DILocation(line: 78, column: 75, scope: !405, inlinedAt: !410)
!413 = !DILocalVariable(name: "to_hz", arg: 3, scope: !405, file: !399, line: 79, type: !60)
!414 = !DILocation(line: 79, column: 18, scope: !405, inlinedAt: !410)
!415 = !DILocalVariable(name: "const_hz", arg: 4, scope: !405, file: !399, line: 79, type: !408)
!416 = !DILocation(line: 79, column: 30, scope: !405, inlinedAt: !410)
!417 = !DILocalVariable(name: "result32", arg: 5, scope: !405, file: !399, line: 80, type: !408)
!418 = !DILocation(line: 80, column: 14, scope: !405, inlinedAt: !410)
!419 = !DILocalVariable(name: "round_up", arg: 6, scope: !405, file: !399, line: 80, type: !408)
!420 = !DILocation(line: 80, column: 29, scope: !405, inlinedAt: !410)
!421 = !DILocalVariable(name: "round_off", arg: 7, scope: !405, file: !399, line: 81, type: !408)
!422 = !DILocation(line: 81, column: 14, scope: !405, inlinedAt: !410)
!423 = !DILocalVariable(name: "mul_ratio", scope: !405, file: !399, line: 84, type: !408)
!424 = !DILocation(line: 84, column: 7, scope: !405, inlinedAt: !410)
!425 = !DILocalVariable(name: "div_ratio", scope: !405, file: !399, line: 86, type: !408)
!426 = !DILocation(line: 86, column: 7, scope: !405, inlinedAt: !410)
!427 = !DILocalVariable(name: "off", scope: !405, file: !399, line: 93, type: !402)
!428 = !DILocation(line: 93, column: 11, scope: !405, inlinedAt: !410)
!429 = !DILocalVariable(name: "rdivisor", scope: !430, file: !399, line: 96, type: !60)
!430 = distinct !DILexicalBlock(scope: !431, file: !399, line: 95, column: 18)
!431 = distinct !DILexicalBlock(scope: !405, file: !399, line: 95, column: 6)
!432 = !DILocation(line: 96, column: 12, scope: !430, inlinedAt: !410)
!433 = !DILocalVariable(name: "t", arg: 1, scope: !398, file: !399, line: 369, type: !402)
!434 = !DILocation(line: 369, column: 69, scope: !398)
!435 = !DILocation(line: 372, column: 17, scope: !398)
!436 = !DILocation(line: 84, column: 19, scope: !405, inlinedAt: !410)
!437 = !DILocation(line: 84, column: 28, scope: !405, inlinedAt: !410)
!438 = !DILocation(line: 85, column: 4, scope: !405, inlinedAt: !410)
!439 = !DILocation(line: 85, column: 12, scope: !405, inlinedAt: !410)
!440 = !DILocation(line: 85, column: 10, scope: !405, inlinedAt: !410)
!441 = !DILocation(line: 85, column: 21, scope: !405, inlinedAt: !410)
!442 = !DILocation(line: 85, column: 26, scope: !405, inlinedAt: !410)
!443 = !DILocation(line: 85, column: 34, scope: !405, inlinedAt: !410)
!444 = !DILocation(line: 85, column: 32, scope: !405, inlinedAt: !410)
!445 = !DILocation(line: 85, column: 43, scope: !405, inlinedAt: !410)
!446 = !DILocation(line: 0, scope: !405, inlinedAt: !410)
!447 = !DILocation(line: 86, column: 19, scope: !405, inlinedAt: !410)
!448 = !DILocation(line: 86, column: 28, scope: !405, inlinedAt: !410)
!449 = !DILocation(line: 87, column: 4, scope: !405, inlinedAt: !410)
!450 = !DILocation(line: 87, column: 14, scope: !405, inlinedAt: !410)
!451 = !DILocation(line: 87, column: 12, scope: !405, inlinedAt: !410)
!452 = !DILocation(line: 87, column: 21, scope: !405, inlinedAt: !410)
!453 = !DILocation(line: 87, column: 26, scope: !405, inlinedAt: !410)
!454 = !DILocation(line: 87, column: 36, scope: !405, inlinedAt: !410)
!455 = !DILocation(line: 87, column: 34, scope: !405, inlinedAt: !410)
!456 = !DILocation(line: 87, column: 43, scope: !405, inlinedAt: !410)
!457 = !DILocation(line: 89, column: 6, scope: !458, inlinedAt: !410)
!458 = distinct !DILexicalBlock(scope: !405, file: !399, line: 89, column: 6)
!459 = !DILocation(line: 89, column: 17, scope: !458, inlinedAt: !410)
!460 = !DILocation(line: 89, column: 14, scope: !458, inlinedAt: !410)
!461 = !DILocation(line: 89, column: 6, scope: !405, inlinedAt: !410)
!462 = !DILocation(line: 90, column: 10, scope: !463, inlinedAt: !410)
!463 = distinct !DILexicalBlock(scope: !458, file: !399, line: 89, column: 24)
!464 = !DILocation(line: 90, column: 32, scope: !463, inlinedAt: !410)
!465 = !DILocation(line: 90, column: 22, scope: !463, inlinedAt: !410)
!466 = !DILocation(line: 90, column: 21, scope: !463, inlinedAt: !410)
!467 = !DILocation(line: 90, column: 37, scope: !463, inlinedAt: !410)
!468 = !DILocation(line: 90, column: 3, scope: !463, inlinedAt: !410)
!469 = !DILocation(line: 95, column: 7, scope: !431, inlinedAt: !410)
!470 = !DILocation(line: 95, column: 6, scope: !405, inlinedAt: !410)
!471 = !DILocation(line: 96, column: 23, scope: !430, inlinedAt: !410)
!472 = !DILocation(line: 96, column: 36, scope: !430, inlinedAt: !410)
!473 = !DILocation(line: 96, column: 46, scope: !430, inlinedAt: !410)
!474 = !DILocation(line: 96, column: 44, scope: !430, inlinedAt: !410)
!475 = !DILocation(line: 96, column: 55, scope: !430, inlinedAt: !410)
!476 = !DILocation(line: 98, column: 7, scope: !477, inlinedAt: !410)
!477 = distinct !DILexicalBlock(scope: !430, file: !399, line: 98, column: 7)
!478 = !DILocation(line: 98, column: 7, scope: !430, inlinedAt: !410)
!479 = !DILocation(line: 99, column: 10, scope: !480, inlinedAt: !410)
!480 = distinct !DILexicalBlock(scope: !477, file: !399, line: 98, column: 17)
!481 = !DILocation(line: 99, column: 19, scope: !480, inlinedAt: !410)
!482 = !DILocation(line: 99, column: 8, scope: !480, inlinedAt: !410)
!483 = !DILocation(line: 100, column: 3, scope: !480, inlinedAt: !410)
!484 = !DILocation(line: 100, column: 14, scope: !485, inlinedAt: !410)
!485 = distinct !DILexicalBlock(scope: !477, file: !399, line: 100, column: 14)
!486 = !DILocation(line: 100, column: 14, scope: !477, inlinedAt: !410)
!487 = !DILocation(line: 101, column: 10, scope: !488, inlinedAt: !410)
!488 = distinct !DILexicalBlock(scope: !485, file: !399, line: 100, column: 25)
!489 = !DILocation(line: 101, column: 19, scope: !488, inlinedAt: !410)
!490 = !DILocation(line: 101, column: 8, scope: !488, inlinedAt: !410)
!491 = !DILocation(line: 102, column: 3, scope: !488, inlinedAt: !410)
!492 = !DILocation(line: 103, column: 2, scope: !430, inlinedAt: !410)
!493 = !DILocation(line: 110, column: 6, scope: !494, inlinedAt: !410)
!494 = distinct !DILexicalBlock(scope: !405, file: !399, line: 110, column: 6)
!495 = !DILocation(line: 110, column: 6, scope: !405, inlinedAt: !410)
!496 = !DILocation(line: 111, column: 8, scope: !497, inlinedAt: !410)
!497 = distinct !DILexicalBlock(scope: !494, file: !399, line: 110, column: 17)
!498 = !DILocation(line: 111, column: 5, scope: !497, inlinedAt: !410)
!499 = !DILocation(line: 112, column: 7, scope: !500, inlinedAt: !410)
!500 = distinct !DILexicalBlock(scope: !497, file: !399, line: 112, column: 7)
!501 = !DILocation(line: 112, column: 16, scope: !500, inlinedAt: !410)
!502 = !DILocation(line: 112, column: 20, scope: !500, inlinedAt: !410)
!503 = !DILocation(line: 112, column: 22, scope: !500, inlinedAt: !410)
!504 = !DILocation(line: 112, column: 7, scope: !497, inlinedAt: !410)
!505 = !DILocation(line: 113, column: 22, scope: !506, inlinedAt: !410)
!506 = distinct !DILexicalBlock(scope: !500, file: !399, line: 112, column: 36)
!507 = !DILocation(line: 113, column: 12, scope: !506, inlinedAt: !410)
!508 = !DILocation(line: 113, column: 28, scope: !506, inlinedAt: !410)
!509 = !DILocation(line: 113, column: 38, scope: !506, inlinedAt: !410)
!510 = !DILocation(line: 113, column: 36, scope: !506, inlinedAt: !410)
!511 = !DILocation(line: 113, column: 25, scope: !506, inlinedAt: !410)
!512 = !DILocation(line: 113, column: 11, scope: !506, inlinedAt: !410)
!513 = !DILocation(line: 113, column: 4, scope: !506, inlinedAt: !410)
!514 = !DILocation(line: 115, column: 11, scope: !515, inlinedAt: !410)
!515 = distinct !DILexicalBlock(scope: !500, file: !399, line: 114, column: 10)
!516 = !DILocation(line: 115, column: 16, scope: !515, inlinedAt: !410)
!517 = !DILocation(line: 115, column: 26, scope: !515, inlinedAt: !410)
!518 = !DILocation(line: 115, column: 24, scope: !515, inlinedAt: !410)
!519 = !DILocation(line: 115, column: 15, scope: !515, inlinedAt: !410)
!520 = !DILocation(line: 115, column: 13, scope: !515, inlinedAt: !410)
!521 = !DILocation(line: 115, column: 4, scope: !515, inlinedAt: !410)
!522 = !DILocation(line: 117, column: 13, scope: !523, inlinedAt: !410)
!523 = distinct !DILexicalBlock(scope: !494, file: !399, line: 117, column: 13)
!524 = !DILocation(line: 117, column: 13, scope: !494, inlinedAt: !410)
!525 = !DILocation(line: 118, column: 7, scope: !526, inlinedAt: !410)
!526 = distinct !DILexicalBlock(scope: !527, file: !399, line: 118, column: 7)
!527 = distinct !DILexicalBlock(scope: !523, file: !399, line: 117, column: 24)
!528 = !DILocation(line: 118, column: 7, scope: !527, inlinedAt: !410)
!529 = !DILocation(line: 119, column: 22, scope: !530, inlinedAt: !410)
!530 = distinct !DILexicalBlock(scope: !526, file: !399, line: 118, column: 17)
!531 = !DILocation(line: 119, column: 12, scope: !530, inlinedAt: !410)
!532 = !DILocation(line: 119, column: 28, scope: !530, inlinedAt: !410)
!533 = !DILocation(line: 119, column: 36, scope: !530, inlinedAt: !410)
!534 = !DILocation(line: 119, column: 34, scope: !530, inlinedAt: !410)
!535 = !DILocation(line: 119, column: 25, scope: !530, inlinedAt: !410)
!536 = !DILocation(line: 119, column: 11, scope: !530, inlinedAt: !410)
!537 = !DILocation(line: 119, column: 4, scope: !530, inlinedAt: !410)
!538 = !DILocation(line: 121, column: 11, scope: !539, inlinedAt: !410)
!539 = distinct !DILexicalBlock(scope: !526, file: !399, line: 120, column: 10)
!540 = !DILocation(line: 121, column: 16, scope: !539, inlinedAt: !410)
!541 = !DILocation(line: 121, column: 24, scope: !539, inlinedAt: !410)
!542 = !DILocation(line: 121, column: 22, scope: !539, inlinedAt: !410)
!543 = !DILocation(line: 121, column: 15, scope: !539, inlinedAt: !410)
!544 = !DILocation(line: 121, column: 13, scope: !539, inlinedAt: !410)
!545 = !DILocation(line: 121, column: 4, scope: !539, inlinedAt: !410)
!546 = !DILocation(line: 124, column: 7, scope: !547, inlinedAt: !410)
!547 = distinct !DILexicalBlock(scope: !548, file: !399, line: 124, column: 7)
!548 = distinct !DILexicalBlock(scope: !523, file: !399, line: 123, column: 9)
!549 = !DILocation(line: 124, column: 7, scope: !548, inlinedAt: !410)
!550 = !DILocation(line: 125, column: 23, scope: !551, inlinedAt: !410)
!551 = distinct !DILexicalBlock(scope: !547, file: !399, line: 124, column: 17)
!552 = !DILocation(line: 125, column: 27, scope: !551, inlinedAt: !410)
!553 = !DILocation(line: 125, column: 25, scope: !551, inlinedAt: !410)
!554 = !DILocation(line: 125, column: 35, scope: !551, inlinedAt: !410)
!555 = !DILocation(line: 125, column: 33, scope: !551, inlinedAt: !410)
!556 = !DILocation(line: 125, column: 42, scope: !551, inlinedAt: !410)
!557 = !DILocation(line: 125, column: 40, scope: !551, inlinedAt: !410)
!558 = !DILocation(line: 125, column: 11, scope: !551, inlinedAt: !410)
!559 = !DILocation(line: 125, column: 4, scope: !551, inlinedAt: !410)
!560 = !DILocation(line: 127, column: 12, scope: !561, inlinedAt: !410)
!561 = distinct !DILexicalBlock(scope: !547, file: !399, line: 126, column: 10)
!562 = !DILocation(line: 127, column: 16, scope: !561, inlinedAt: !410)
!563 = !DILocation(line: 127, column: 14, scope: !561, inlinedAt: !410)
!564 = !DILocation(line: 127, column: 24, scope: !561, inlinedAt: !410)
!565 = !DILocation(line: 127, column: 22, scope: !561, inlinedAt: !410)
!566 = !DILocation(line: 127, column: 31, scope: !561, inlinedAt: !410)
!567 = !DILocation(line: 127, column: 29, scope: !561, inlinedAt: !410)
!568 = !DILocation(line: 127, column: 4, scope: !561, inlinedAt: !410)
!569 = !DILocation(line: 130, column: 1, scope: !405, inlinedAt: !410)
!570 = !DILocation(line: 372, column: 2, scope: !398)
!571 = distinct !DISubprogram(name: "k_sleep", scope: !285, file: !285, line: 117, type: !572, scopeLine: 118, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !202)
!572 = !DISubroutineType(types: !573)
!573 = !{!229, !288}
!574 = !DILocalVariable(name: "timeout", arg: 1, scope: !571, file: !285, line: 117, type: !288)
!575 = !DILocation(line: 117, column: 61, scope: !571)
!576 = !DILocation(line: 126, column: 2, scope: !571)
!577 = !DILocation(line: 126, column: 2, scope: !578)
!578 = distinct !DILexicalBlock(scope: !571, file: !285, line: 126, column: 2)
!579 = !{i32 -2141857472}
!580 = !DILocation(line: 127, column: 9, scope: !571)
!581 = !DILocation(line: 127, column: 2, scope: !571)
!582 = distinct !DISubprogram(name: "main", scope: !65, file: !65, line: 73, type: !168, scopeLine: 73, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !202)
!583 = !DILocation(line: 74, column: 29, scope: !582)
!584 = !DILocation(line: 74, column: 5, scope: !582)
!585 = !DILocation(line: 75, column: 34, scope: !582)
!586 = !DILocation(line: 75, column: 5, scope: !582)
!587 = !DILocation(line: 76, column: 1, scope: !582)
!588 = distinct !DISubprogram(name: "k_thread_join", scope: !285, file: !285, line: 102, type: !589, scopeLine: 103, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !202)
!589 = !DISubroutineType(types: !590)
!590 = !{!59, !100, !288}
!591 = !DILocalVariable(name: "thread", arg: 1, scope: !588, file: !285, line: 102, type: !100)
!592 = !DILocation(line: 102, column: 69, scope: !588)
!593 = !DILocalVariable(name: "timeout", arg: 2, scope: !588, file: !285, line: 102, type: !288)
!594 = !DILocation(line: 102, column: 89, scope: !588)
!595 = !DILocation(line: 111, column: 2, scope: !588)
!596 = !DILocation(line: 111, column: 2, scope: !597)
!597 = distinct !DILexicalBlock(scope: !588, file: !285, line: 111, column: 2)
!598 = !{i32 -2141857540}
!599 = !DILocation(line: 112, column: 30, scope: !588)
!600 = !DILocation(line: 112, column: 9, scope: !588)
!601 = !DILocation(line: 112, column: 2, scope: !588)
