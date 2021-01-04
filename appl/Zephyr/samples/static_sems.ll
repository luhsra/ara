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
%struct._static_thread_data = type { %struct.k_thread*, %struct.z_thread_stack_element*, i32, void (i8*, i8*, i8*)*, i8*, i8*, i8*, i32, i32, i32, void ()*, i8* }
%struct.k_timeout_t = type { i64 }

@threadA_sem = dso_local global %struct.k_sem { %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_sem, %struct.k_sem* @threadA_sem, i32 0, i32 0, i32 0) }, %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_sem, %struct.k_sem* @threadA_sem, i32 0, i32 0, i32 0) } } }, i32 1, i32 1 }, section "._k_sem.static.threadA_sem", align 4, !dbg !0
@threadB_sem = dso_local global %struct.k_sem { %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_sem, %struct.k_sem* @threadB_sem, i32 0, i32 0, i32 0) }, %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_sem, %struct.k_sem* @threadB_sem, i32 0, i32 0, i32 0) } } }, i32 0, i32 1 }, section "._k_sem.static.threadB_sem", align 4, !dbg !63
@threadB_stack_area = dso_local global [1024 x %struct.z_thread_stack_element] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/static_sems/src/main.c\22.4", align 8, !dbg !234
@_k_thread_obj_thread_a = dso_local global %struct.k_thread zeroinitializer, align 8, !dbg !243
@_k_thread_stack_thread_a = dso_local global [1024 x %struct.z_thread_stack_element] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/static_sems/src/main.c\22.5", align 8, !dbg !241
@_k_thread_data_thread_a = dso_local global %struct._static_thread_data { %struct.k_thread* @_k_thread_obj_thread_a, %struct.z_thread_stack_element* getelementptr inbounds ([1024 x %struct.z_thread_stack_element], [1024 x %struct.z_thread_stack_element]* @_k_thread_stack_thread_a, i32 0, i32 0), i32 1024, void (i8*, i8*, i8*)* @threadA, i8* null, i8* null, i8* null, i32 7, i32 0, i32 0, void ()* null, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.3, i32 0, i32 0) }, section ".__static_thread_data.static._k_thread_data_thread_a", align 4, !dbg !91
@.str.3 = private unnamed_addr constant [9 x i8] c"thread_a\00", align 1
@threadB_data = internal global %struct.k_thread zeroinitializer, align 8, !dbg !239
@.str.2 = private unnamed_addr constant [9 x i8] c"thread_b\00", align 1
@__func__.threadA = private unnamed_addr constant [8 x i8] c"threadA\00", align 1
@.str = private unnamed_addr constant [26 x i8] c"%s: Hello World from %s!\0A\00", align 1
@.str.1 = private unnamed_addr constant [14 x i8] c"nucleo_f303re\00", align 1
@__func__.threadB = private unnamed_addr constant [8 x i8] c"threadB\00", align 1
@thread_a = dso_local constant %struct.k_thread* @_k_thread_obj_thread_a, align 4, !dbg !230
@llvm.used = appending global [3 x i8*] [i8* bitcast (%struct.k_sem* @threadA_sem to i8*), i8* bitcast (%struct.k_sem* @threadB_sem to i8*), i8* bitcast (%struct._static_thread_data* @_k_thread_data_thread_a to i8*)], section "llvm.metadata"

; Function Attrs: noinline nounwind optnone
define dso_local void @threadA(i8*, i8*, i8*) #0 !dbg !250 {
  %4 = alloca i8*, align 4
  %5 = alloca i8*, align 4
  %6 = alloca i8*, align 4
  %7 = alloca %struct.k_thread*, align 4
  %8 = alloca %struct.k_timeout_t, align 8
  store i8* %0, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !251, metadata !DIExpression()), !dbg !252
  store i8* %1, i8** %5, align 4
  call void @llvm.dbg.declare(metadata i8** %5, metadata !253, metadata !DIExpression()), !dbg !254
  store i8* %2, i8** %6, align 4
  call void @llvm.dbg.declare(metadata i8** %6, metadata !255, metadata !DIExpression()), !dbg !256
  %9 = load i8*, i8** %4, align 4, !dbg !257
  %10 = load i8*, i8** %5, align 4, !dbg !258
  %11 = load i8*, i8** %6, align 4, !dbg !259
  call void @llvm.dbg.declare(metadata %struct.k_thread** %7, metadata !260, metadata !DIExpression()), !dbg !261
  %12 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %8, i32 0, i32 0, !dbg !262
  store i64 0, i64* %12, align 8, !dbg !262
  %13 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %8, i32 0, i32 0, !dbg !263
  %14 = bitcast i64* %13 to [1 x i64]*, !dbg !263
  %15 = load [1 x i64], [1 x i64]* %14, align 8, !dbg !263
  %16 = call %struct.k_thread* @k_thread_create(%struct.k_thread* @threadB_data, %struct.z_thread_stack_element* getelementptr inbounds ([1024 x %struct.z_thread_stack_element], [1024 x %struct.z_thread_stack_element]* @threadB_stack_area, i32 0, i32 0), i32 1024, void (i8*, i8*, i8*)* @threadB, i8* null, i8* null, i8* null, i32 7, i32 0, [1 x i64] %15) #3, !dbg !263
  store %struct.k_thread* %16, %struct.k_thread** %7, align 4, !dbg !261
  %17 = load %struct.k_thread*, %struct.k_thread** %7, align 4, !dbg !264
  %18 = call i32 @k_thread_name_set(%struct.k_thread* %17, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.2, i32 0, i32 0)) #3, !dbg !265
  call void @helloLoop(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__func__.threadA, i32 0, i32 0), %struct.k_sem* @threadA_sem, %struct.k_sem* @threadB_sem) #3, !dbg !266
  ret void, !dbg !267
}

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: noinline nounwind optnone
define dso_local void @threadB(i8*, i8*, i8*) #0 !dbg !268 {
  %4 = alloca i8*, align 4
  %5 = alloca i8*, align 4
  %6 = alloca i8*, align 4
  store i8* %0, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !269, metadata !DIExpression()), !dbg !270
  store i8* %1, i8** %5, align 4
  call void @llvm.dbg.declare(metadata i8** %5, metadata !271, metadata !DIExpression()), !dbg !272
  store i8* %2, i8** %6, align 4
  call void @llvm.dbg.declare(metadata i8** %6, metadata !273, metadata !DIExpression()), !dbg !274
  %7 = load i8*, i8** %4, align 4, !dbg !275
  %8 = load i8*, i8** %5, align 4, !dbg !276
  %9 = load i8*, i8** %6, align 4, !dbg !277
  call void @helloLoop(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__func__.threadB, i32 0, i32 0), %struct.k_sem* @threadB_sem, %struct.k_sem* @threadA_sem) #3, !dbg !278
  ret void, !dbg !279
}

; Function Attrs: noinline nounwind optnone
define internal %struct.k_thread* @k_thread_create(%struct.k_thread*, %struct.z_thread_stack_element*, i32, void (i8*, i8*, i8*)*, i8*, i8*, i8*, i32, i32, [1 x i64]) #0 !dbg !280 {
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
  call void @llvm.dbg.declare(metadata %struct.k_thread** %12, metadata !288, metadata !DIExpression()), !dbg !289
  store %struct.z_thread_stack_element* %1, %struct.z_thread_stack_element** %13, align 4
  call void @llvm.dbg.declare(metadata %struct.z_thread_stack_element** %13, metadata !290, metadata !DIExpression()), !dbg !291
  store i32 %2, i32* %14, align 4
  call void @llvm.dbg.declare(metadata i32* %14, metadata !292, metadata !DIExpression()), !dbg !293
  store void (i8*, i8*, i8*)* %3, void (i8*, i8*, i8*)** %15, align 4
  call void @llvm.dbg.declare(metadata void (i8*, i8*, i8*)** %15, metadata !294, metadata !DIExpression()), !dbg !295
  store i8* %4, i8** %16, align 4
  call void @llvm.dbg.declare(metadata i8** %16, metadata !296, metadata !DIExpression()), !dbg !297
  store i8* %5, i8** %17, align 4
  call void @llvm.dbg.declare(metadata i8** %17, metadata !298, metadata !DIExpression()), !dbg !299
  store i8* %6, i8** %18, align 4
  call void @llvm.dbg.declare(metadata i8** %18, metadata !300, metadata !DIExpression()), !dbg !301
  store i32 %7, i32* %19, align 4
  call void @llvm.dbg.declare(metadata i32* %19, metadata !302, metadata !DIExpression()), !dbg !303
  store i32 %8, i32* %20, align 4
  call void @llvm.dbg.declare(metadata i32* %20, metadata !304, metadata !DIExpression()), !dbg !305
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %11, metadata !306, metadata !DIExpression()), !dbg !307
  br label %23, !dbg !308

23:                                               ; preds = %10
  call void asm sideeffect "", "~{memory}"() #4, !dbg !309, !srcloc !311
  br label %24, !dbg !309

24:                                               ; preds = %23
  %25 = load %struct.k_thread*, %struct.k_thread** %12, align 4, !dbg !312
  %26 = load %struct.z_thread_stack_element*, %struct.z_thread_stack_element** %13, align 4, !dbg !313
  %27 = load i32, i32* %14, align 4, !dbg !314
  %28 = load void (i8*, i8*, i8*)*, void (i8*, i8*, i8*)** %15, align 4, !dbg !315
  %29 = load i8*, i8** %16, align 4, !dbg !316
  %30 = load i8*, i8** %17, align 4, !dbg !317
  %31 = load i8*, i8** %18, align 4, !dbg !318
  %32 = load i32, i32* %19, align 4, !dbg !319
  %33 = load i32, i32* %20, align 4, !dbg !320
  %34 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %11, i32 0, i32 0, !dbg !321
  %35 = bitcast i64* %34 to [1 x i64]*, !dbg !321
  %36 = load [1 x i64], [1 x i64]* %35, align 8, !dbg !321
  %37 = call %struct.k_thread* @z_impl_k_thread_create(%struct.k_thread* %25, %struct.z_thread_stack_element* %26, i32 %27, void (i8*, i8*, i8*)* %28, i8* %29, i8* %30, i8* %31, i32 %32, i32 %33, [1 x i64] %36) #3, !dbg !321
  ret %struct.k_thread* %37, !dbg !322
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_thread_name_set(%struct.k_thread*, i8*) #0 !dbg !323 {
  %3 = alloca %struct.k_thread*, align 4
  %4 = alloca i8*, align 4
  store %struct.k_thread* %0, %struct.k_thread** %3, align 4
  call void @llvm.dbg.declare(metadata %struct.k_thread** %3, metadata !326, metadata !DIExpression()), !dbg !327
  store i8* %1, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !328, metadata !DIExpression()), !dbg !329
  br label %5, !dbg !330

5:                                                ; preds = %2
  call void asm sideeffect "", "~{memory}"() #4, !dbg !331, !srcloc !333
  br label %6, !dbg !331

6:                                                ; preds = %5
  %7 = load %struct.k_thread*, %struct.k_thread** %3, align 4, !dbg !334
  %8 = load i8*, i8** %4, align 4, !dbg !335
  %9 = call i32 @z_impl_k_thread_name_set(%struct.k_thread* %7, i8* %8) #3, !dbg !336
  ret i32 %9, !dbg !337
}

; Function Attrs: noinline nounwind optnone
define dso_local void @helloLoop(i8*, %struct.k_sem*, %struct.k_sem*) #0 !dbg !338 {
  %4 = alloca i8*, align 4
  %5 = alloca %struct.k_sem*, align 4
  %6 = alloca %struct.k_sem*, align 4
  %7 = alloca i8*, align 4
  %8 = alloca %struct.k_timeout_t, align 8
  store i8* %0, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !342, metadata !DIExpression()), !dbg !343
  store %struct.k_sem* %1, %struct.k_sem** %5, align 4
  call void @llvm.dbg.declare(metadata %struct.k_sem** %5, metadata !344, metadata !DIExpression()), !dbg !345
  store %struct.k_sem* %2, %struct.k_sem** %6, align 4
  call void @llvm.dbg.declare(metadata %struct.k_sem** %6, metadata !346, metadata !DIExpression()), !dbg !347
  call void @llvm.dbg.declare(metadata i8** %7, metadata !348, metadata !DIExpression()), !dbg !349
  br label %9, !dbg !350

9:                                                ; preds = %30, %3
  %10 = load %struct.k_sem*, %struct.k_sem** %5, align 4, !dbg !351
  %11 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %8, i32 0, i32 0, !dbg !353
  store i64 -1, i64* %11, align 8, !dbg !353
  %12 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %8, i32 0, i32 0, !dbg !354
  %13 = bitcast i64* %12 to [1 x i64]*, !dbg !354
  %14 = load [1 x i64], [1 x i64]* %13, align 8, !dbg !354
  %15 = call i32 @k_sem_take(%struct.k_sem* %10, [1 x i64] %14) #3, !dbg !354
  %16 = call %struct.k_thread* @k_current_get() #3, !dbg !355
  %17 = call i8* @k_thread_name_get(%struct.k_thread* %16) #3, !dbg !356
  store i8* %17, i8** %7, align 4, !dbg !357
  %18 = load i8*, i8** %7, align 4, !dbg !358
  %19 = icmp ne i8* %18, null, !dbg !360
  br i1 %19, label %20, label %28, !dbg !361

20:                                               ; preds = %9
  %21 = load i8*, i8** %7, align 4, !dbg !362
  %22 = getelementptr i8, i8* %21, i32 0, !dbg !362
  %23 = load i8, i8* %22, align 1, !dbg !362
  %24 = zext i8 %23 to i32, !dbg !362
  %25 = icmp ne i32 %24, 0, !dbg !363
  br i1 %25, label %26, label %28, !dbg !364

26:                                               ; preds = %20
  %27 = load i8*, i8** %7, align 4, !dbg !365
  call void (i8*, ...) @printk(i8* getelementptr inbounds ([26 x i8], [26 x i8]* @.str, i32 0, i32 0), i8* %27, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i32 0, i32 0)) #3, !dbg !367
  br label %30, !dbg !368

28:                                               ; preds = %20, %9
  %29 = load i8*, i8** %4, align 4, !dbg !369
  call void (i8*, ...) @printk(i8* getelementptr inbounds ([26 x i8], [26 x i8]* @.str, i32 0, i32 0), i8* %29, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i32 0, i32 0)) #3, !dbg !371
  br label %30

30:                                               ; preds = %28, %26
  %31 = call i32 @k_msleep(i32 500) #3, !dbg !372
  %32 = load %struct.k_sem*, %struct.k_sem** %6, align 4, !dbg !373
  call void @k_sem_give(%struct.k_sem* %32) #3, !dbg !374
  br label %9, !dbg !350, !llvm.loop !375
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_sem_take(%struct.k_sem*, [1 x i64]) #0 !dbg !377 {
  %3 = alloca %struct.k_timeout_t, align 8
  %4 = alloca %struct.k_sem*, align 4
  %5 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0
  %6 = bitcast i64* %5 to [1 x i64]*
  store [1 x i64] %1, [1 x i64]* %6, align 8
  store %struct.k_sem* %0, %struct.k_sem** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.k_sem** %4, metadata !380, metadata !DIExpression()), !dbg !381
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %3, metadata !382, metadata !DIExpression()), !dbg !383
  br label %7, !dbg !384

7:                                                ; preds = %2
  call void asm sideeffect "", "~{memory}"() #4, !dbg !385, !srcloc !387
  br label %8, !dbg !385

8:                                                ; preds = %7
  %9 = load %struct.k_sem*, %struct.k_sem** %4, align 4, !dbg !388
  %10 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !389
  %11 = bitcast i64* %10 to [1 x i64]*, !dbg !389
  %12 = load [1 x i64], [1 x i64]* %11, align 8, !dbg !389
  %13 = call i32 @z_impl_k_sem_take(%struct.k_sem* %9, [1 x i64] %12) #3, !dbg !389
  ret i32 %13, !dbg !390
}

; Function Attrs: noinline nounwind optnone
define internal %struct.k_thread* @k_current_get() #0 !dbg !391 {
  br label %1, !dbg !394

1:                                                ; preds = %0
  call void asm sideeffect "", "~{memory}"() #4, !dbg !395, !srcloc !397
  br label %2, !dbg !395

2:                                                ; preds = %1
  %3 = call %struct.k_thread* bitcast (%struct.k_thread* (...)* @z_impl_k_current_get to %struct.k_thread* ()*)() #3, !dbg !398
  ret %struct.k_thread* %3, !dbg !399
}

declare dso_local i8* @k_thread_name_get(%struct.k_thread*) #2

declare dso_local void @printk(i8*, ...) #2

; Function Attrs: noinline nounwind optnone
define internal i32 @k_msleep(i32) #0 !dbg !400 {
  %2 = alloca i32, align 4
  %3 = alloca %struct.k_timeout_t, align 8
  store i32 %0, i32* %2, align 4
  call void @llvm.dbg.declare(metadata i32* %2, metadata !403, metadata !DIExpression()), !dbg !404
  %4 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !405
  %5 = load i32, i32* %2, align 4, !dbg !405
  %6 = icmp sgt i32 %5, 0, !dbg !405
  br i1 %6, label %7, label %9, !dbg !405

7:                                                ; preds = %1
  %8 = load i32, i32* %2, align 4, !dbg !405
  br label %10, !dbg !405

9:                                                ; preds = %1
  br label %10, !dbg !405

10:                                               ; preds = %9, %7
  %11 = phi i32 [ %8, %7 ], [ 0, %9 ], !dbg !405
  %12 = sext i32 %11 to i64, !dbg !405
  %13 = call i64 @k_ms_to_ticks_ceil64(i64 %12) #3, !dbg !405
  store i64 %13, i64* %4, align 8, !dbg !405
  %14 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !406
  %15 = bitcast i64* %14 to [1 x i64]*, !dbg !406
  %16 = load [1 x i64], [1 x i64]* %15, align 8, !dbg !406
  %17 = call i32 @k_sleep([1 x i64] %16) #3, !dbg !406
  ret i32 %17, !dbg !407
}

; Function Attrs: noinline nounwind optnone
define internal void @k_sem_give(%struct.k_sem*) #0 !dbg !408 {
  %2 = alloca %struct.k_sem*, align 4
  store %struct.k_sem* %0, %struct.k_sem** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_sem** %2, metadata !411, metadata !DIExpression()), !dbg !412
  br label %3, !dbg !413

3:                                                ; preds = %1
  call void asm sideeffect "", "~{memory}"() #4, !dbg !414, !srcloc !416
  br label %4, !dbg !414

4:                                                ; preds = %3
  %5 = load %struct.k_sem*, %struct.k_sem** %2, align 4, !dbg !417
  call void @z_impl_k_sem_give(%struct.k_sem* %5) #3, !dbg !418
  ret void, !dbg !419
}

declare dso_local void @z_impl_k_sem_give(%struct.k_sem*) #2

; Function Attrs: noinline nounwind optnone
define internal i64 @k_ms_to_ticks_ceil64(i64) #0 !dbg !420 {
  %2 = alloca i64, align 8
  %3 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %3, metadata !426, metadata !DIExpression()), !dbg !431
  %4 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !433, metadata !DIExpression()), !dbg !434
  %5 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %5, metadata !435, metadata !DIExpression()), !dbg !436
  %6 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %6, metadata !437, metadata !DIExpression()), !dbg !438
  %7 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %7, metadata !439, metadata !DIExpression()), !dbg !440
  %8 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %8, metadata !441, metadata !DIExpression()), !dbg !442
  %9 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %9, metadata !443, metadata !DIExpression()), !dbg !444
  %10 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %10, metadata !445, metadata !DIExpression()), !dbg !446
  %11 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %11, metadata !447, metadata !DIExpression()), !dbg !448
  %12 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %12, metadata !449, metadata !DIExpression()), !dbg !450
  %13 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %13, metadata !451, metadata !DIExpression()), !dbg !454
  %14 = alloca i64, align 8
  store i64 %0, i64* %14, align 8
  call void @llvm.dbg.declare(metadata i64* %14, metadata !455, metadata !DIExpression()), !dbg !456
  %15 = load i64, i64* %14, align 8, !dbg !457
  store i64 %15, i64* %3, align 8
  store i32 1000, i32* %4, align 4
  store i32 10000, i32* %5, align 4
  store i8 1, i8* %6, align 1
  store i8 0, i8* %7, align 1
  store i8 1, i8* %8, align 1
  store i8 0, i8* %9, align 1
  %16 = load i8, i8* %6, align 1, !dbg !458
  %17 = trunc i8 %16 to i1, !dbg !458
  br i1 %17, label %18, label %27, !dbg !459

18:                                               ; preds = %1
  %19 = load i32, i32* %5, align 4, !dbg !460
  %20 = load i32, i32* %4, align 4, !dbg !461
  %21 = icmp ugt i32 %19, %20, !dbg !462
  br i1 %21, label %22, label %27, !dbg !463

22:                                               ; preds = %18
  %23 = load i32, i32* %5, align 4, !dbg !464
  %24 = load i32, i32* %4, align 4, !dbg !465
  %25 = urem i32 %23, %24, !dbg !466
  %26 = icmp eq i32 %25, 0, !dbg !467
  br label %27

27:                                               ; preds = %22, %18, %1
  %28 = phi i1 [ false, %18 ], [ false, %1 ], [ %26, %22 ], !dbg !468
  %29 = zext i1 %28 to i8, !dbg !446
  store i8 %29, i8* %10, align 1, !dbg !446
  %30 = load i8, i8* %6, align 1, !dbg !469
  %31 = trunc i8 %30 to i1, !dbg !469
  br i1 %31, label %32, label %41, !dbg !470

32:                                               ; preds = %27
  %33 = load i32, i32* %4, align 4, !dbg !471
  %34 = load i32, i32* %5, align 4, !dbg !472
  %35 = icmp ugt i32 %33, %34, !dbg !473
  br i1 %35, label %36, label %41, !dbg !474

36:                                               ; preds = %32
  %37 = load i32, i32* %4, align 4, !dbg !475
  %38 = load i32, i32* %5, align 4, !dbg !476
  %39 = urem i32 %37, %38, !dbg !477
  %40 = icmp eq i32 %39, 0, !dbg !478
  br label %41

41:                                               ; preds = %36, %32, %27
  %42 = phi i1 [ false, %32 ], [ false, %27 ], [ %40, %36 ], !dbg !468
  %43 = zext i1 %42 to i8, !dbg !448
  store i8 %43, i8* %11, align 1, !dbg !448
  %44 = load i32, i32* %4, align 4, !dbg !479
  %45 = load i32, i32* %5, align 4, !dbg !481
  %46 = icmp eq i32 %44, %45, !dbg !482
  br i1 %46, label %47, label %58, !dbg !483

47:                                               ; preds = %41
  %48 = load i8, i8* %7, align 1, !dbg !484
  %49 = trunc i8 %48 to i1, !dbg !484
  br i1 %49, label %50, label %54, !dbg !484

50:                                               ; preds = %47
  %51 = load i64, i64* %3, align 8, !dbg !486
  %52 = trunc i64 %51 to i32, !dbg !487
  %53 = zext i32 %52 to i64, !dbg !488
  br label %56, !dbg !484

54:                                               ; preds = %47
  %55 = load i64, i64* %3, align 8, !dbg !489
  br label %56, !dbg !484

56:                                               ; preds = %54, %50
  %57 = phi i64 [ %53, %50 ], [ %55, %54 ], !dbg !484
  store i64 %57, i64* %2, align 8, !dbg !490
  br label %160, !dbg !490

58:                                               ; preds = %41
  store i64 0, i64* %12, align 8, !dbg !450
  %59 = load i8, i8* %10, align 1, !dbg !491
  %60 = trunc i8 %59 to i1, !dbg !491
  br i1 %60, label %87, label %61, !dbg !492

61:                                               ; preds = %58
  %62 = load i8, i8* %11, align 1, !dbg !493
  %63 = trunc i8 %62 to i1, !dbg !493
  br i1 %63, label %64, label %68, !dbg !493

64:                                               ; preds = %61
  %65 = load i32, i32* %4, align 4, !dbg !494
  %66 = load i32, i32* %5, align 4, !dbg !495
  %67 = udiv i32 %65, %66, !dbg !496
  br label %70, !dbg !493

68:                                               ; preds = %61
  %69 = load i32, i32* %4, align 4, !dbg !497
  br label %70, !dbg !493

70:                                               ; preds = %68, %64
  %71 = phi i32 [ %67, %64 ], [ %69, %68 ], !dbg !493
  store i32 %71, i32* %13, align 4, !dbg !454
  %72 = load i8, i8* %8, align 1, !dbg !498
  %73 = trunc i8 %72 to i1, !dbg !498
  br i1 %73, label %74, label %78, !dbg !500

74:                                               ; preds = %70
  %75 = load i32, i32* %13, align 4, !dbg !501
  %76 = sub i32 %75, 1, !dbg !503
  %77 = zext i32 %76 to i64, !dbg !501
  store i64 %77, i64* %12, align 8, !dbg !504
  br label %86, !dbg !505

78:                                               ; preds = %70
  %79 = load i8, i8* %9, align 1, !dbg !506
  %80 = trunc i8 %79 to i1, !dbg !506
  br i1 %80, label %81, label %85, !dbg !508

81:                                               ; preds = %78
  %82 = load i32, i32* %13, align 4, !dbg !509
  %83 = udiv i32 %82, 2, !dbg !511
  %84 = zext i32 %83 to i64, !dbg !509
  store i64 %84, i64* %12, align 8, !dbg !512
  br label %85, !dbg !513

85:                                               ; preds = %81, %78
  br label %86

86:                                               ; preds = %85, %74
  br label %87, !dbg !514

87:                                               ; preds = %86, %58
  %88 = load i8, i8* %11, align 1, !dbg !515
  %89 = trunc i8 %88 to i1, !dbg !515
  br i1 %89, label %90, label %114, !dbg !517

90:                                               ; preds = %87
  %91 = load i64, i64* %12, align 8, !dbg !518
  %92 = load i64, i64* %3, align 8, !dbg !520
  %93 = add i64 %92, %91, !dbg !520
  store i64 %93, i64* %3, align 8, !dbg !520
  %94 = load i8, i8* %7, align 1, !dbg !521
  %95 = trunc i8 %94 to i1, !dbg !521
  br i1 %95, label %96, label %107, !dbg !523

96:                                               ; preds = %90
  %97 = load i64, i64* %3, align 8, !dbg !524
  %98 = icmp ult i64 %97, 4294967296, !dbg !525
  br i1 %98, label %99, label %107, !dbg !526

99:                                               ; preds = %96
  %100 = load i64, i64* %3, align 8, !dbg !527
  %101 = trunc i64 %100 to i32, !dbg !529
  %102 = load i32, i32* %4, align 4, !dbg !530
  %103 = load i32, i32* %5, align 4, !dbg !531
  %104 = udiv i32 %102, %103, !dbg !532
  %105 = udiv i32 %101, %104, !dbg !533
  %106 = zext i32 %105 to i64, !dbg !534
  store i64 %106, i64* %2, align 8, !dbg !535
  br label %160, !dbg !535

107:                                              ; preds = %96, %90
  %108 = load i64, i64* %3, align 8, !dbg !536
  %109 = load i32, i32* %4, align 4, !dbg !538
  %110 = load i32, i32* %5, align 4, !dbg !539
  %111 = udiv i32 %109, %110, !dbg !540
  %112 = zext i32 %111 to i64, !dbg !541
  %113 = udiv i64 %108, %112, !dbg !542
  store i64 %113, i64* %2, align 8, !dbg !543
  br label %160, !dbg !543

114:                                              ; preds = %87
  %115 = load i8, i8* %10, align 1, !dbg !544
  %116 = trunc i8 %115 to i1, !dbg !544
  br i1 %116, label %117, label %135, !dbg !546

117:                                              ; preds = %114
  %118 = load i8, i8* %7, align 1, !dbg !547
  %119 = trunc i8 %118 to i1, !dbg !547
  br i1 %119, label %120, label %128, !dbg !550

120:                                              ; preds = %117
  %121 = load i64, i64* %3, align 8, !dbg !551
  %122 = trunc i64 %121 to i32, !dbg !553
  %123 = load i32, i32* %5, align 4, !dbg !554
  %124 = load i32, i32* %4, align 4, !dbg !555
  %125 = udiv i32 %123, %124, !dbg !556
  %126 = mul i32 %122, %125, !dbg !557
  %127 = zext i32 %126 to i64, !dbg !558
  store i64 %127, i64* %2, align 8, !dbg !559
  br label %160, !dbg !559

128:                                              ; preds = %117
  %129 = load i64, i64* %3, align 8, !dbg !560
  %130 = load i32, i32* %5, align 4, !dbg !562
  %131 = load i32, i32* %4, align 4, !dbg !563
  %132 = udiv i32 %130, %131, !dbg !564
  %133 = zext i32 %132 to i64, !dbg !565
  %134 = mul i64 %129, %133, !dbg !566
  store i64 %134, i64* %2, align 8, !dbg !567
  br label %160, !dbg !567

135:                                              ; preds = %114
  %136 = load i8, i8* %7, align 1, !dbg !568
  %137 = trunc i8 %136 to i1, !dbg !568
  br i1 %137, label %138, label %150, !dbg !571

138:                                              ; preds = %135
  %139 = load i64, i64* %3, align 8, !dbg !572
  %140 = load i32, i32* %5, align 4, !dbg !574
  %141 = zext i32 %140 to i64, !dbg !574
  %142 = mul i64 %139, %141, !dbg !575
  %143 = load i64, i64* %12, align 8, !dbg !576
  %144 = add i64 %142, %143, !dbg !577
  %145 = load i32, i32* %4, align 4, !dbg !578
  %146 = zext i32 %145 to i64, !dbg !578
  %147 = udiv i64 %144, %146, !dbg !579
  %148 = trunc i64 %147 to i32, !dbg !580
  %149 = zext i32 %148 to i64, !dbg !580
  store i64 %149, i64* %2, align 8, !dbg !581
  br label %160, !dbg !581

150:                                              ; preds = %135
  %151 = load i64, i64* %3, align 8, !dbg !582
  %152 = load i32, i32* %5, align 4, !dbg !584
  %153 = zext i32 %152 to i64, !dbg !584
  %154 = mul i64 %151, %153, !dbg !585
  %155 = load i64, i64* %12, align 8, !dbg !586
  %156 = add i64 %154, %155, !dbg !587
  %157 = load i32, i32* %4, align 4, !dbg !588
  %158 = zext i32 %157 to i64, !dbg !588
  %159 = udiv i64 %156, %158, !dbg !589
  store i64 %159, i64* %2, align 8, !dbg !590
  br label %160, !dbg !590

160:                                              ; preds = %150, %138, %128, %120, %107, %99, %56
  %161 = load i64, i64* %2, align 8, !dbg !591
  ret i64 %161, !dbg !592
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_sleep([1 x i64]) #0 !dbg !593 {
  %2 = alloca %struct.k_timeout_t, align 8
  %3 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0
  %4 = bitcast i64* %3 to [1 x i64]*
  store [1 x i64] %0, [1 x i64]* %4, align 8
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %2, metadata !596, metadata !DIExpression()), !dbg !597
  br label %5, !dbg !598

5:                                                ; preds = %1
  call void asm sideeffect "", "~{memory}"() #4, !dbg !599, !srcloc !601
  br label %6, !dbg !599

6:                                                ; preds = %5
  %7 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !602
  %8 = bitcast i64* %7 to [1 x i64]*, !dbg !602
  %9 = load [1 x i64], [1 x i64]* %8, align 8, !dbg !602
  %10 = call i32 @z_impl_k_sleep([1 x i64] %9) #3, !dbg !602
  ret i32 %10, !dbg !603
}

declare dso_local i32 @z_impl_k_sleep([1 x i64]) #2

declare dso_local %struct.k_thread* @z_impl_k_current_get(...) #2

declare dso_local i32 @z_impl_k_sem_take(%struct.k_sem*, [1 x i64]) #2

declare dso_local i32 @z_impl_k_thread_name_set(%struct.k_thread*, i8*) #2

declare dso_local %struct.k_thread* @z_impl_k_thread_create(%struct.k_thread*, %struct.z_thread_stack_element*, i32, void (i8*, i8*, i8*)*, i8*, i8*, i8*, i32, i32, [1 x i64]) #2

; Function Attrs: noinline nounwind optnone
define dso_local void @main() #0 !dbg !604 {
  %1 = alloca %struct.k_timeout_t, align 8
  %2 = alloca %struct.k_timeout_t, align 8
  %3 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %1, i32 0, i32 0, !dbg !605
  store i64 -1, i64* %3, align 8, !dbg !605
  %4 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %1, i32 0, i32 0, !dbg !606
  %5 = bitcast i64* %4 to [1 x i64]*, !dbg !606
  %6 = load [1 x i64], [1 x i64]* %5, align 8, !dbg !606
  %7 = call i32 @k_thread_join(%struct.k_thread* @_k_thread_obj_thread_a, [1 x i64] %6) #3, !dbg !606
  %8 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !607
  store i64 -1, i64* %8, align 8, !dbg !607
  %9 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !608
  %10 = bitcast i64* %9 to [1 x i64]*, !dbg !608
  %11 = load [1 x i64], [1 x i64]* %10, align 8, !dbg !608
  %12 = call i32 @k_thread_join(%struct.k_thread* @threadB_data, [1 x i64] %11) #3, !dbg !608
  ret void, !dbg !609
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_thread_join(%struct.k_thread*, [1 x i64]) #0 !dbg !610 {
  %3 = alloca %struct.k_timeout_t, align 8
  %4 = alloca %struct.k_thread*, align 4
  %5 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0
  %6 = bitcast i64* %5 to [1 x i64]*
  store [1 x i64] %1, [1 x i64]* %6, align 8
  store %struct.k_thread* %0, %struct.k_thread** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.k_thread** %4, metadata !613, metadata !DIExpression()), !dbg !614
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %3, metadata !615, metadata !DIExpression()), !dbg !616
  br label %7, !dbg !617

7:                                                ; preds = %2
  call void asm sideeffect "", "~{memory}"() #4, !dbg !618, !srcloc !620
  br label %8, !dbg !618

8:                                                ; preds = %7
  %9 = load %struct.k_thread*, %struct.k_thread** %4, align 4, !dbg !621
  %10 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !622
  %11 = bitcast i64* %10 to [1 x i64]*, !dbg !622
  %12 = load [1 x i64], [1 x i64]* %11, align 8, !dbg !622
  %13 = call i32 @z_impl_k_thread_join(%struct.k_thread* %9, [1 x i64] %12) #3, !dbg !622
  ret i32 %13, !dbg !623
}

declare dso_local i32 @z_impl_k_thread_join(%struct.k_thread*, [1 x i64]) #2

attributes #0 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #1 = { nounwind readnone speculatable }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #3 = { nobuiltin }
attributes #4 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.ident = !{!245}
!llvm.module.flags = !{!246, !247, !248, !249}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "threadA_sem", scope: !2, file: !65, line: 38, type: !66, isLocal: false, isDefinition: true, align: 32)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !52, globals: !62, nameTableKind: None)
!3 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/static_sems/src/main.c", directory: "/home/kenny/ara/build/appl/Zephyr/static_sems")
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
!62 = !{!0, !63, !91, !230, !234, !239, !241, !243}
!63 = !DIGlobalVariableExpression(var: !64, expr: !DIExpression())
!64 = distinct !DIGlobalVariable(name: "threadB_sem", scope: !2, file: !65, line: 39, type: !66, isLocal: false, isDefinition: true, align: 32)
!65 = !DIFile(filename: "appl/Zephyr/static_sems/src/main.c", directory: "/home/kenny/ara")
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
!92 = distinct !DIGlobalVariable(name: "_k_thread_data_thread_a", scope: !2, file: !65, line: 69, type: !93, isLocal: false, isDefinition: true, align: 32)
!93 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_static_thread_data", file: !6, line: 1099, size: 384, elements: !94)
!94 = !{!95, !204, !213, !214, !219, !220, !221, !222, !223, !224, !226, !227}
!95 = !DIDerivedType(tag: DW_TAG_member, name: "init_thread", scope: !93, file: !6, line: 1100, baseType: !96, size: 32)
!96 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !97, size: 32)
!97 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_thread", file: !6, line: 570, size: 1024, elements: !98)
!98 = !{!99, !148, !161, !162, !166, !167, !177, !199}
!99 = !DIDerivedType(tag: DW_TAG_member, name: "base", scope: !97, file: !6, line: 572, baseType: !100, size: 448)
!100 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_base", file: !6, line: 441, size: 448, elements: !101)
!101 = !{!102, !116, !118, !120, !121, !134, !135, !136, !147}
!102 = !DIDerivedType(tag: DW_TAG_member, scope: !100, file: !6, line: 444, baseType: !103, size: 64)
!103 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !100, file: !6, line: 444, size: 64, elements: !104)
!104 = !{!105, !107}
!105 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_dlist", scope: !103, file: !6, line: 445, baseType: !106, size: 64)
!106 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dnode_t", file: !75, line: 43, baseType: !76)
!107 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_rb", scope: !103, file: !6, line: 446, baseType: !108, size: 64)
!108 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "rbnode", file: !109, line: 48, size: 64, elements: !110)
!109 = !DIFile(filename: "zephyrproject/zephyr/include/sys/rb.h", directory: "/home/kenny")
!110 = !{!111}
!111 = !DIDerivedType(tag: DW_TAG_member, name: "children", scope: !108, file: !109, line: 49, baseType: !112, size: 64)
!112 = !DICompositeType(tag: DW_TAG_array_type, baseType: !113, size: 64, elements: !114)
!113 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !108, size: 32)
!114 = !{!115}
!115 = !DISubrange(count: 2)
!116 = !DIDerivedType(tag: DW_TAG_member, name: "pended_on", scope: !100, file: !6, line: 452, baseType: !117, size: 32, offset: 64)
!117 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !69, size: 32)
!118 = !DIDerivedType(tag: DW_TAG_member, name: "user_options", scope: !100, file: !6, line: 455, baseType: !119, size: 8, offset: 96)
!119 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !56, line: 55, baseType: !7)
!120 = !DIDerivedType(tag: DW_TAG_member, name: "thread_state", scope: !100, file: !6, line: 458, baseType: !119, size: 8, offset: 104)
!121 = !DIDerivedType(tag: DW_TAG_member, scope: !100, file: !6, line: 474, baseType: !122, size: 16, offset: 112)
!122 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !100, file: !6, line: 474, size: 16, elements: !123)
!123 = !{!124, !131}
!124 = !DIDerivedType(tag: DW_TAG_member, scope: !122, file: !6, line: 475, baseType: !125, size: 16)
!125 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !122, file: !6, line: 475, size: 16, elements: !126)
!126 = !{!127, !130}
!127 = !DIDerivedType(tag: DW_TAG_member, name: "prio", scope: !125, file: !6, line: 480, baseType: !128, size: 8)
!128 = !DIDerivedType(tag: DW_TAG_typedef, name: "int8_t", file: !56, line: 40, baseType: !129)
!129 = !DIBasicType(name: "signed char", size: 8, encoding: DW_ATE_signed_char)
!130 = !DIDerivedType(tag: DW_TAG_member, name: "sched_locked", scope: !125, file: !6, line: 481, baseType: !119, size: 8, offset: 8)
!131 = !DIDerivedType(tag: DW_TAG_member, name: "preempt", scope: !122, file: !6, line: 484, baseType: !132, size: 16)
!132 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !56, line: 56, baseType: !133)
!133 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!134 = !DIDerivedType(tag: DW_TAG_member, name: "order_key", scope: !100, file: !6, line: 491, baseType: !60, size: 32, offset: 128)
!135 = !DIDerivedType(tag: DW_TAG_member, name: "swap_data", scope: !100, file: !6, line: 511, baseType: !58, size: 32, offset: 160)
!136 = !DIDerivedType(tag: DW_TAG_member, name: "timeout", scope: !100, file: !6, line: 515, baseType: !137, size: 192, offset: 192)
!137 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_timeout", file: !70, line: 221, size: 192, elements: !138)
!138 = !{!139, !140, !146}
!139 = !DIDerivedType(tag: DW_TAG_member, name: "node", scope: !137, file: !70, line: 222, baseType: !106, size: 64)
!140 = !DIDerivedType(tag: DW_TAG_member, name: "fn", scope: !137, file: !70, line: 223, baseType: !141, size: 32, offset: 64)
!141 = !DIDerivedType(tag: DW_TAG_typedef, name: "_timeout_func_t", file: !70, line: 219, baseType: !142)
!142 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !143, size: 32)
!143 = !DISubroutineType(types: !144)
!144 = !{null, !145}
!145 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !137, size: 32)
!146 = !DIDerivedType(tag: DW_TAG_member, name: "dticks", scope: !137, file: !70, line: 226, baseType: !55, size: 64, offset: 128)
!147 = !DIDerivedType(tag: DW_TAG_member, name: "join_waiters", scope: !100, file: !6, line: 518, baseType: !69, size: 64, offset: 384)
!148 = !DIDerivedType(tag: DW_TAG_member, name: "callee_saved", scope: !97, file: !6, line: 575, baseType: !149, size: 288, offset: 448)
!149 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_callee_saved", file: !150, line: 25, size: 288, elements: !151)
!150 = !DIFile(filename: "zephyrproject/zephyr/include/arch/arm/aarch32/thread.h", directory: "/home/kenny")
!151 = !{!152, !153, !154, !155, !156, !157, !158, !159, !160}
!152 = !DIDerivedType(tag: DW_TAG_member, name: "v1", scope: !149, file: !150, line: 26, baseType: !60, size: 32)
!153 = !DIDerivedType(tag: DW_TAG_member, name: "v2", scope: !149, file: !150, line: 27, baseType: !60, size: 32, offset: 32)
!154 = !DIDerivedType(tag: DW_TAG_member, name: "v3", scope: !149, file: !150, line: 28, baseType: !60, size: 32, offset: 64)
!155 = !DIDerivedType(tag: DW_TAG_member, name: "v4", scope: !149, file: !150, line: 29, baseType: !60, size: 32, offset: 96)
!156 = !DIDerivedType(tag: DW_TAG_member, name: "v5", scope: !149, file: !150, line: 30, baseType: !60, size: 32, offset: 128)
!157 = !DIDerivedType(tag: DW_TAG_member, name: "v6", scope: !149, file: !150, line: 31, baseType: !60, size: 32, offset: 160)
!158 = !DIDerivedType(tag: DW_TAG_member, name: "v7", scope: !149, file: !150, line: 32, baseType: !60, size: 32, offset: 192)
!159 = !DIDerivedType(tag: DW_TAG_member, name: "v8", scope: !149, file: !150, line: 33, baseType: !60, size: 32, offset: 224)
!160 = !DIDerivedType(tag: DW_TAG_member, name: "psp", scope: !149, file: !150, line: 34, baseType: !60, size: 32, offset: 256)
!161 = !DIDerivedType(tag: DW_TAG_member, name: "init_data", scope: !97, file: !6, line: 578, baseType: !58, size: 32, offset: 736)
!162 = !DIDerivedType(tag: DW_TAG_member, name: "fn_abort", scope: !97, file: !6, line: 583, baseType: !163, size: 32, offset: 768)
!163 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !164, size: 32)
!164 = !DISubroutineType(types: !165)
!165 = !{null}
!166 = !DIDerivedType(tag: DW_TAG_member, name: "errno_var", scope: !97, file: !6, line: 610, baseType: !59, size: 32, offset: 800)
!167 = !DIDerivedType(tag: DW_TAG_member, name: "stack_info", scope: !97, file: !6, line: 616, baseType: !168, size: 96, offset: 832)
!168 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_stack_info", file: !6, line: 525, size: 96, elements: !169)
!169 = !{!170, !173, !176}
!170 = !DIDerivedType(tag: DW_TAG_member, name: "start", scope: !168, file: !6, line: 529, baseType: !171, size: 32)
!171 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintptr_t", file: !56, line: 71, baseType: !172)
!172 = !DIBasicType(name: "long unsigned int", size: 32, encoding: DW_ATE_unsigned)
!173 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !168, file: !6, line: 538, baseType: !174, size: 32, offset: 32)
!174 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !175, line: 46, baseType: !61)
!175 = !DIFile(filename: "/usr/lib/llvm-9/lib/clang/9.0.1/include/stddef.h", directory: "")
!176 = !DIDerivedType(tag: DW_TAG_member, name: "delta", scope: !168, file: !6, line: 544, baseType: !174, size: 32, offset: 64)
!177 = !DIDerivedType(tag: DW_TAG_member, name: "resource_pool", scope: !97, file: !6, line: 641, baseType: !178, size: 32, offset: 928)
!178 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !179, size: 32)
!179 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mem_pool", file: !180, line: 30, size: 32, elements: !181)
!180 = !DIFile(filename: "zephyrproject/zephyr/include/mempool_heap.h", directory: "/home/kenny")
!181 = !{!182}
!182 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !179, file: !180, line: 31, baseType: !183, size: 32)
!183 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !184, size: 32)
!184 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_heap", file: !70, line: 267, size: 160, elements: !185)
!185 = !{!186, !195, !196}
!186 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !184, file: !70, line: 268, baseType: !187, size: 96)
!187 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "sys_heap", file: !188, line: 51, size: 96, elements: !189)
!188 = !DIFile(filename: "zephyrproject/zephyr/include/sys/sys_heap.h", directory: "/home/kenny")
!189 = !{!190, !193, !194}
!190 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !187, file: !188, line: 52, baseType: !191, size: 32)
!191 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !192, size: 32)
!192 = !DICompositeType(tag: DW_TAG_structure_type, name: "z_heap", file: !188, line: 52, flags: DIFlagFwdDecl)
!193 = !DIDerivedType(tag: DW_TAG_member, name: "init_mem", scope: !187, file: !188, line: 53, baseType: !58, size: 32, offset: 32)
!194 = !DIDerivedType(tag: DW_TAG_member, name: "init_bytes", scope: !187, file: !188, line: 54, baseType: !174, size: 32, offset: 64)
!195 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !184, file: !70, line: 269, baseType: !69, size: 64, offset: 96)
!196 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !184, file: !70, line: 270, baseType: !197, offset: 160)
!197 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_spinlock", file: !70, line: 234, elements: !198)
!198 = !{}
!199 = !DIDerivedType(tag: DW_TAG_member, name: "arch", scope: !97, file: !6, line: 644, baseType: !200, size: 64, offset: 960)
!200 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_arch", file: !150, line: 60, size: 64, elements: !201)
!201 = !{!202, !203}
!202 = !DIDerivedType(tag: DW_TAG_member, name: "basepri", scope: !200, file: !150, line: 63, baseType: !60, size: 32)
!203 = !DIDerivedType(tag: DW_TAG_member, name: "swap_return_value", scope: !200, file: !150, line: 66, baseType: !60, size: 32, offset: 32)
!204 = !DIDerivedType(tag: DW_TAG_member, name: "init_stack", scope: !93, file: !6, line: 1101, baseType: !205, size: 32, offset: 32)
!205 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !206, size: 32)
!206 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_stack_t", file: !207, line: 44, baseType: !208)
!207 = !DIFile(filename: "zephyrproject/zephyr/include/sys/arch_interface.h", directory: "/home/kenny")
!208 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "z_thread_stack_element", file: !209, line: 35, size: 8, elements: !210)
!209 = !DIFile(filename: "zephyrproject/zephyr/include/sys/thread_stack.h", directory: "/home/kenny")
!210 = !{!211}
!211 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !208, file: !209, line: 36, baseType: !212, size: 8)
!212 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_unsigned_char)
!213 = !DIDerivedType(tag: DW_TAG_member, name: "init_stack_size", scope: !93, file: !6, line: 1102, baseType: !61, size: 32, offset: 64)
!214 = !DIDerivedType(tag: DW_TAG_member, name: "init_entry", scope: !93, file: !6, line: 1103, baseType: !215, size: 32, offset: 96)
!215 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_entry_t", file: !207, line: 46, baseType: !216)
!216 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !217, size: 32)
!217 = !DISubroutineType(types: !218)
!218 = !{null, !58, !58, !58}
!219 = !DIDerivedType(tag: DW_TAG_member, name: "init_p1", scope: !93, file: !6, line: 1104, baseType: !58, size: 32, offset: 128)
!220 = !DIDerivedType(tag: DW_TAG_member, name: "init_p2", scope: !93, file: !6, line: 1105, baseType: !58, size: 32, offset: 160)
!221 = !DIDerivedType(tag: DW_TAG_member, name: "init_p3", scope: !93, file: !6, line: 1106, baseType: !58, size: 32, offset: 192)
!222 = !DIDerivedType(tag: DW_TAG_member, name: "init_prio", scope: !93, file: !6, line: 1107, baseType: !59, size: 32, offset: 224)
!223 = !DIDerivedType(tag: DW_TAG_member, name: "init_options", scope: !93, file: !6, line: 1108, baseType: !60, size: 32, offset: 256)
!224 = !DIDerivedType(tag: DW_TAG_member, name: "init_delay", scope: !93, file: !6, line: 1109, baseType: !225, size: 32, offset: 288)
!225 = !DIDerivedType(tag: DW_TAG_typedef, name: "int32_t", file: !56, line: 42, baseType: !59)
!226 = !DIDerivedType(tag: DW_TAG_member, name: "init_abort", scope: !93, file: !6, line: 1110, baseType: !163, size: 32, offset: 320)
!227 = !DIDerivedType(tag: DW_TAG_member, name: "init_name", scope: !93, file: !6, line: 1111, baseType: !228, size: 32, offset: 352)
!228 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !229, size: 32)
!229 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !212)
!230 = !DIGlobalVariableExpression(var: !231, expr: !DIExpression())
!231 = distinct !DIGlobalVariable(name: "thread_a", scope: !2, file: !65, line: 69, type: !232, isLocal: false, isDefinition: true)
!232 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !233)
!233 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_tid_t", file: !6, line: 648, baseType: !96)
!234 = !DIGlobalVariableExpression(var: !235, expr: !DIExpression())
!235 = distinct !DIGlobalVariable(name: "threadB_stack_area", scope: !2, file: !65, line: 51, type: !236, isLocal: false, isDefinition: true, align: 64)
!236 = !DICompositeType(tag: DW_TAG_array_type, baseType: !208, size: 8192, elements: !237)
!237 = !{!238}
!238 = !DISubrange(count: 1024)
!239 = !DIGlobalVariableExpression(var: !240, expr: !DIExpression())
!240 = distinct !DIGlobalVariable(name: "threadB_data", scope: !2, file: !65, line: 52, type: !97, isLocal: true, isDefinition: true)
!241 = !DIGlobalVariableExpression(var: !242, expr: !DIExpression())
!242 = distinct !DIGlobalVariable(name: "_k_thread_stack_thread_a", scope: !2, file: !65, line: 69, type: !236, isLocal: false, isDefinition: true, align: 64)
!243 = !DIGlobalVariableExpression(var: !244, expr: !DIExpression())
!244 = distinct !DIGlobalVariable(name: "_k_thread_obj_thread_a", scope: !2, file: !65, line: 69, type: !97, isLocal: false, isDefinition: true)
!245 = !{!"clang version 9.0.1-12 "}
!246 = !{i32 2, !"Dwarf Version", i32 4}
!247 = !{i32 2, !"Debug Info Version", i32 3}
!248 = !{i32 1, !"wchar_size", i32 4}
!249 = !{i32 1, !"min_enum_size", i32 1}
!250 = distinct !DISubprogram(name: "threadA", scope: !65, file: !65, line: 54, type: !217, scopeLine: 55, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !198)
!251 = !DILocalVariable(name: "dummy1", arg: 1, scope: !250, file: !65, line: 54, type: !58)
!252 = !DILocation(line: 54, column: 20, scope: !250)
!253 = !DILocalVariable(name: "dummy2", arg: 2, scope: !250, file: !65, line: 54, type: !58)
!254 = !DILocation(line: 54, column: 34, scope: !250)
!255 = !DILocalVariable(name: "dummy3", arg: 3, scope: !250, file: !65, line: 54, type: !58)
!256 = !DILocation(line: 54, column: 48, scope: !250)
!257 = !DILocation(line: 56, column: 2, scope: !250)
!258 = !DILocation(line: 57, column: 2, scope: !250)
!259 = !DILocation(line: 58, column: 2, scope: !250)
!260 = !DILocalVariable(name: "tid", scope: !250, file: !65, line: 60, type: !233)
!261 = !DILocation(line: 60, column: 10, scope: !250)
!262 = !DILocation(line: 62, column: 17, scope: !250)
!263 = !DILocation(line: 60, column: 16, scope: !250)
!264 = !DILocation(line: 64, column: 20, scope: !250)
!265 = !DILocation(line: 64, column: 2, scope: !250)
!266 = !DILocation(line: 66, column: 2, scope: !250)
!267 = !DILocation(line: 67, column: 1, scope: !250)
!268 = distinct !DISubprogram(name: "threadB", scope: !65, file: !65, line: 42, type: !217, scopeLine: 43, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !198)
!269 = !DILocalVariable(name: "dummy1", arg: 1, scope: !268, file: !65, line: 42, type: !58)
!270 = !DILocation(line: 42, column: 20, scope: !268)
!271 = !DILocalVariable(name: "dummy2", arg: 2, scope: !268, file: !65, line: 42, type: !58)
!272 = !DILocation(line: 42, column: 34, scope: !268)
!273 = !DILocalVariable(name: "dummy3", arg: 3, scope: !268, file: !65, line: 42, type: !58)
!274 = !DILocation(line: 42, column: 48, scope: !268)
!275 = !DILocation(line: 44, column: 2, scope: !268)
!276 = !DILocation(line: 45, column: 2, scope: !268)
!277 = !DILocation(line: 46, column: 2, scope: !268)
!278 = !DILocation(line: 48, column: 2, scope: !268)
!279 = !DILocation(line: 49, column: 1, scope: !268)
!280 = distinct !DISubprogram(name: "k_thread_create", scope: !281, file: !281, line: 66, type: !282, scopeLine: 67, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !198)
!281 = !DIFile(filename: "zephyr/include/generated/syscalls/kernel.h", directory: "/home/kenny/ara/build/appl/Zephyr/static_sems")
!282 = !DISubroutineType(types: !283)
!283 = !{!233, !96, !205, !174, !215, !58, !58, !58, !59, !60, !284}
!284 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_timeout_t", file: !54, line: 69, baseType: !285)
!285 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !54, line: 67, size: 64, elements: !286)
!286 = !{!287}
!287 = !DIDerivedType(tag: DW_TAG_member, name: "ticks", scope: !285, file: !54, line: 68, baseType: !53, size: 64)
!288 = !DILocalVariable(name: "new_thread", arg: 1, scope: !280, file: !281, line: 66, type: !96)
!289 = !DILocation(line: 66, column: 75, scope: !280)
!290 = !DILocalVariable(name: "stack", arg: 2, scope: !280, file: !281, line: 66, type: !205)
!291 = !DILocation(line: 66, column: 106, scope: !280)
!292 = !DILocalVariable(name: "stack_size", arg: 3, scope: !280, file: !281, line: 66, type: !174)
!293 = !DILocation(line: 66, column: 120, scope: !280)
!294 = !DILocalVariable(name: "entry", arg: 4, scope: !280, file: !281, line: 66, type: !215)
!295 = !DILocation(line: 66, column: 149, scope: !280)
!296 = !DILocalVariable(name: "p1", arg: 5, scope: !280, file: !281, line: 66, type: !58)
!297 = !DILocation(line: 66, column: 163, scope: !280)
!298 = !DILocalVariable(name: "p2", arg: 6, scope: !280, file: !281, line: 66, type: !58)
!299 = !DILocation(line: 66, column: 174, scope: !280)
!300 = !DILocalVariable(name: "p3", arg: 7, scope: !280, file: !281, line: 66, type: !58)
!301 = !DILocation(line: 66, column: 185, scope: !280)
!302 = !DILocalVariable(name: "prio", arg: 8, scope: !280, file: !281, line: 66, type: !59)
!303 = !DILocation(line: 66, column: 193, scope: !280)
!304 = !DILocalVariable(name: "options", arg: 9, scope: !280, file: !281, line: 66, type: !60)
!305 = !DILocation(line: 66, column: 208, scope: !280)
!306 = !DILocalVariable(name: "delay", arg: 10, scope: !280, file: !281, line: 66, type: !284)
!307 = !DILocation(line: 66, column: 229, scope: !280)
!308 = !DILocation(line: 83, column: 2, scope: !280)
!309 = !DILocation(line: 83, column: 2, scope: !310)
!310 = distinct !DILexicalBlock(scope: !280, file: !281, line: 83, column: 2)
!311 = !{i32 -2141857713}
!312 = !DILocation(line: 84, column: 32, scope: !280)
!313 = !DILocation(line: 84, column: 44, scope: !280)
!314 = !DILocation(line: 84, column: 51, scope: !280)
!315 = !DILocation(line: 84, column: 63, scope: !280)
!316 = !DILocation(line: 84, column: 70, scope: !280)
!317 = !DILocation(line: 84, column: 74, scope: !280)
!318 = !DILocation(line: 84, column: 78, scope: !280)
!319 = !DILocation(line: 84, column: 82, scope: !280)
!320 = !DILocation(line: 84, column: 88, scope: !280)
!321 = !DILocation(line: 84, column: 9, scope: !280)
!322 = !DILocation(line: 84, column: 2, scope: !280)
!323 = distinct !DISubprogram(name: "k_thread_name_set", scope: !281, file: !281, line: 363, type: !324, scopeLine: 364, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !198)
!324 = !DISubroutineType(types: !325)
!325 = !{!59, !233, !228}
!326 = !DILocalVariable(name: "thread_id", arg: 1, scope: !323, file: !281, line: 363, type: !233)
!327 = !DILocation(line: 363, column: 63, scope: !323)
!328 = !DILocalVariable(name: "value", arg: 2, scope: !323, file: !281, line: 363, type: !228)
!329 = !DILocation(line: 363, column: 87, scope: !323)
!330 = !DILocation(line: 370, column: 2, scope: !323)
!331 = !DILocation(line: 370, column: 2, scope: !332)
!332 = distinct !DILexicalBlock(scope: !323, file: !281, line: 370, column: 2)
!333 = !{i32 -2141856285}
!334 = !DILocation(line: 371, column: 34, scope: !323)
!335 = !DILocation(line: 371, column: 45, scope: !323)
!336 = !DILocation(line: 371, column: 9, scope: !323)
!337 = !DILocation(line: 371, column: 2, scope: !323)
!338 = distinct !DISubprogram(name: "helloLoop", scope: !65, file: !65, line: 16, type: !339, scopeLine: 18, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !198)
!339 = !DISubroutineType(types: !340)
!340 = !{null, !228, !341, !341}
!341 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !66, size: 32)
!342 = !DILocalVariable(name: "my_name", arg: 1, scope: !338, file: !65, line: 16, type: !228)
!343 = !DILocation(line: 16, column: 28, scope: !338)
!344 = !DILocalVariable(name: "my_sem", arg: 2, scope: !338, file: !65, line: 17, type: !341)
!345 = !DILocation(line: 17, column: 23, scope: !338)
!346 = !DILocalVariable(name: "other_sem", arg: 3, scope: !338, file: !65, line: 17, type: !341)
!347 = !DILocation(line: 17, column: 45, scope: !338)
!348 = !DILocalVariable(name: "tname", scope: !338, file: !65, line: 19, type: !228)
!349 = !DILocation(line: 19, column: 14, scope: !338)
!350 = !DILocation(line: 21, column: 2, scope: !338)
!351 = !DILocation(line: 22, column: 14, scope: !352)
!352 = distinct !DILexicalBlock(scope: !338, file: !65, line: 21, column: 12)
!353 = !DILocation(line: 22, column: 22, scope: !352)
!354 = !DILocation(line: 22, column: 3, scope: !352)
!355 = !DILocation(line: 24, column: 29, scope: !352)
!356 = !DILocation(line: 24, column: 11, scope: !352)
!357 = !DILocation(line: 24, column: 9, scope: !352)
!358 = !DILocation(line: 25, column: 7, scope: !359)
!359 = distinct !DILexicalBlock(scope: !352, file: !65, line: 25, column: 7)
!360 = !DILocation(line: 25, column: 13, scope: !359)
!361 = !DILocation(line: 25, column: 21, scope: !359)
!362 = !DILocation(line: 25, column: 24, scope: !359)
!363 = !DILocation(line: 25, column: 33, scope: !359)
!364 = !DILocation(line: 25, column: 7, scope: !352)
!365 = !DILocation(line: 27, column: 5, scope: !366)
!366 = distinct !DILexicalBlock(scope: !359, file: !65, line: 25, column: 42)
!367 = !DILocation(line: 26, column: 4, scope: !366)
!368 = !DILocation(line: 28, column: 3, scope: !366)
!369 = !DILocation(line: 30, column: 5, scope: !370)
!370 = distinct !DILexicalBlock(scope: !359, file: !65, line: 28, column: 10)
!371 = !DILocation(line: 29, column: 4, scope: !370)
!372 = !DILocation(line: 33, column: 3, scope: !352)
!373 = !DILocation(line: 34, column: 14, scope: !352)
!374 = !DILocation(line: 34, column: 3, scope: !352)
!375 = distinct !{!375, !350, !376}
!376 = !DILocation(line: 35, column: 2, scope: !338)
!377 = distinct !DISubprogram(name: "k_sem_take", scope: !281, file: !281, line: 746, type: !378, scopeLine: 747, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !198)
!378 = !DISubroutineType(types: !379)
!379 = !{!59, !341, !284}
!380 = !DILocalVariable(name: "sem", arg: 1, scope: !377, file: !281, line: 746, type: !341)
!381 = !DILocation(line: 746, column: 63, scope: !377)
!382 = !DILocalVariable(name: "timeout", arg: 2, scope: !377, file: !281, line: 746, type: !284)
!383 = !DILocation(line: 746, column: 80, scope: !377)
!384 = !DILocation(line: 755, column: 2, scope: !377)
!385 = !DILocation(line: 755, column: 2, scope: !386)
!386 = distinct !DILexicalBlock(scope: !377, file: !281, line: 755, column: 2)
!387 = !{i32 -2141854369}
!388 = !DILocation(line: 756, column: 27, scope: !377)
!389 = !DILocation(line: 756, column: 9, scope: !377)
!390 = !DILocation(line: 756, column: 2, scope: !377)
!391 = distinct !DISubprogram(name: "k_current_get", scope: !281, file: !281, line: 187, type: !392, scopeLine: 188, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !198)
!392 = !DISubroutineType(types: !393)
!393 = !{!233}
!394 = !DILocation(line: 194, column: 2, scope: !391)
!395 = !DILocation(line: 194, column: 2, scope: !396)
!396 = distinct !DILexicalBlock(scope: !391, file: !281, line: 194, column: 2)
!397 = !{i32 -2141857169}
!398 = !DILocation(line: 195, column: 9, scope: !391)
!399 = !DILocation(line: 195, column: 2, scope: !391)
!400 = distinct !DISubprogram(name: "k_msleep", scope: !6, file: !6, line: 957, type: !401, scopeLine: 958, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !198)
!401 = !DISubroutineType(types: !402)
!402 = !{!225, !225}
!403 = !DILocalVariable(name: "ms", arg: 1, scope: !400, file: !6, line: 957, type: !225)
!404 = !DILocation(line: 957, column: 40, scope: !400)
!405 = !DILocation(line: 959, column: 17, scope: !400)
!406 = !DILocation(line: 959, column: 9, scope: !400)
!407 = !DILocation(line: 959, column: 2, scope: !400)
!408 = distinct !DISubprogram(name: "k_sem_give", scope: !281, file: !281, line: 761, type: !409, scopeLine: 762, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !198)
!409 = !DISubroutineType(types: !410)
!410 = !{null, !341}
!411 = !DILocalVariable(name: "sem", arg: 1, scope: !408, file: !281, line: 761, type: !341)
!412 = !DILocation(line: 761, column: 64, scope: !408)
!413 = !DILocation(line: 769, column: 2, scope: !408)
!414 = !DILocation(line: 769, column: 2, scope: !415)
!415 = distinct !DILexicalBlock(scope: !408, file: !281, line: 769, column: 2)
!416 = !{i32 -2141854301}
!417 = !DILocation(line: 770, column: 20, scope: !408)
!418 = !DILocation(line: 770, column: 2, scope: !408)
!419 = !DILocation(line: 771, column: 1, scope: !408)
!420 = distinct !DISubprogram(name: "k_ms_to_ticks_ceil64", scope: !421, file: !421, line: 369, type: !422, scopeLine: 370, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !198)
!421 = !DIFile(filename: "zephyrproject/zephyr/include/sys/time_units.h", directory: "/home/kenny")
!422 = !DISubroutineType(types: !423)
!423 = !{!424, !424}
!424 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint64_t", file: !56, line: 58, baseType: !425)
!425 = !DIBasicType(name: "long long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!426 = !DILocalVariable(name: "t", arg: 1, scope: !427, file: !421, line: 78, type: !424)
!427 = distinct !DISubprogram(name: "z_tmcvt", scope: !421, file: !421, line: 78, type: !428, scopeLine: 82, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !198)
!428 = !DISubroutineType(types: !429)
!429 = !{!424, !424, !60, !60, !430, !430, !430, !430}
!430 = !DIBasicType(name: "_Bool", size: 8, encoding: DW_ATE_boolean)
!431 = !DILocation(line: 78, column: 63, scope: !427, inlinedAt: !432)
!432 = distinct !DILocation(line: 372, column: 9, scope: !420)
!433 = !DILocalVariable(name: "from_hz", arg: 2, scope: !427, file: !421, line: 78, type: !60)
!434 = !DILocation(line: 78, column: 75, scope: !427, inlinedAt: !432)
!435 = !DILocalVariable(name: "to_hz", arg: 3, scope: !427, file: !421, line: 79, type: !60)
!436 = !DILocation(line: 79, column: 18, scope: !427, inlinedAt: !432)
!437 = !DILocalVariable(name: "const_hz", arg: 4, scope: !427, file: !421, line: 79, type: !430)
!438 = !DILocation(line: 79, column: 30, scope: !427, inlinedAt: !432)
!439 = !DILocalVariable(name: "result32", arg: 5, scope: !427, file: !421, line: 80, type: !430)
!440 = !DILocation(line: 80, column: 14, scope: !427, inlinedAt: !432)
!441 = !DILocalVariable(name: "round_up", arg: 6, scope: !427, file: !421, line: 80, type: !430)
!442 = !DILocation(line: 80, column: 29, scope: !427, inlinedAt: !432)
!443 = !DILocalVariable(name: "round_off", arg: 7, scope: !427, file: !421, line: 81, type: !430)
!444 = !DILocation(line: 81, column: 14, scope: !427, inlinedAt: !432)
!445 = !DILocalVariable(name: "mul_ratio", scope: !427, file: !421, line: 84, type: !430)
!446 = !DILocation(line: 84, column: 7, scope: !427, inlinedAt: !432)
!447 = !DILocalVariable(name: "div_ratio", scope: !427, file: !421, line: 86, type: !430)
!448 = !DILocation(line: 86, column: 7, scope: !427, inlinedAt: !432)
!449 = !DILocalVariable(name: "off", scope: !427, file: !421, line: 93, type: !424)
!450 = !DILocation(line: 93, column: 11, scope: !427, inlinedAt: !432)
!451 = !DILocalVariable(name: "rdivisor", scope: !452, file: !421, line: 96, type: !60)
!452 = distinct !DILexicalBlock(scope: !453, file: !421, line: 95, column: 18)
!453 = distinct !DILexicalBlock(scope: !427, file: !421, line: 95, column: 6)
!454 = !DILocation(line: 96, column: 12, scope: !452, inlinedAt: !432)
!455 = !DILocalVariable(name: "t", arg: 1, scope: !420, file: !421, line: 369, type: !424)
!456 = !DILocation(line: 369, column: 69, scope: !420)
!457 = !DILocation(line: 372, column: 17, scope: !420)
!458 = !DILocation(line: 84, column: 19, scope: !427, inlinedAt: !432)
!459 = !DILocation(line: 84, column: 28, scope: !427, inlinedAt: !432)
!460 = !DILocation(line: 85, column: 4, scope: !427, inlinedAt: !432)
!461 = !DILocation(line: 85, column: 12, scope: !427, inlinedAt: !432)
!462 = !DILocation(line: 85, column: 10, scope: !427, inlinedAt: !432)
!463 = !DILocation(line: 85, column: 21, scope: !427, inlinedAt: !432)
!464 = !DILocation(line: 85, column: 26, scope: !427, inlinedAt: !432)
!465 = !DILocation(line: 85, column: 34, scope: !427, inlinedAt: !432)
!466 = !DILocation(line: 85, column: 32, scope: !427, inlinedAt: !432)
!467 = !DILocation(line: 85, column: 43, scope: !427, inlinedAt: !432)
!468 = !DILocation(line: 0, scope: !427, inlinedAt: !432)
!469 = !DILocation(line: 86, column: 19, scope: !427, inlinedAt: !432)
!470 = !DILocation(line: 86, column: 28, scope: !427, inlinedAt: !432)
!471 = !DILocation(line: 87, column: 4, scope: !427, inlinedAt: !432)
!472 = !DILocation(line: 87, column: 14, scope: !427, inlinedAt: !432)
!473 = !DILocation(line: 87, column: 12, scope: !427, inlinedAt: !432)
!474 = !DILocation(line: 87, column: 21, scope: !427, inlinedAt: !432)
!475 = !DILocation(line: 87, column: 26, scope: !427, inlinedAt: !432)
!476 = !DILocation(line: 87, column: 36, scope: !427, inlinedAt: !432)
!477 = !DILocation(line: 87, column: 34, scope: !427, inlinedAt: !432)
!478 = !DILocation(line: 87, column: 43, scope: !427, inlinedAt: !432)
!479 = !DILocation(line: 89, column: 6, scope: !480, inlinedAt: !432)
!480 = distinct !DILexicalBlock(scope: !427, file: !421, line: 89, column: 6)
!481 = !DILocation(line: 89, column: 17, scope: !480, inlinedAt: !432)
!482 = !DILocation(line: 89, column: 14, scope: !480, inlinedAt: !432)
!483 = !DILocation(line: 89, column: 6, scope: !427, inlinedAt: !432)
!484 = !DILocation(line: 90, column: 10, scope: !485, inlinedAt: !432)
!485 = distinct !DILexicalBlock(scope: !480, file: !421, line: 89, column: 24)
!486 = !DILocation(line: 90, column: 32, scope: !485, inlinedAt: !432)
!487 = !DILocation(line: 90, column: 22, scope: !485, inlinedAt: !432)
!488 = !DILocation(line: 90, column: 21, scope: !485, inlinedAt: !432)
!489 = !DILocation(line: 90, column: 37, scope: !485, inlinedAt: !432)
!490 = !DILocation(line: 90, column: 3, scope: !485, inlinedAt: !432)
!491 = !DILocation(line: 95, column: 7, scope: !453, inlinedAt: !432)
!492 = !DILocation(line: 95, column: 6, scope: !427, inlinedAt: !432)
!493 = !DILocation(line: 96, column: 23, scope: !452, inlinedAt: !432)
!494 = !DILocation(line: 96, column: 36, scope: !452, inlinedAt: !432)
!495 = !DILocation(line: 96, column: 46, scope: !452, inlinedAt: !432)
!496 = !DILocation(line: 96, column: 44, scope: !452, inlinedAt: !432)
!497 = !DILocation(line: 96, column: 55, scope: !452, inlinedAt: !432)
!498 = !DILocation(line: 98, column: 7, scope: !499, inlinedAt: !432)
!499 = distinct !DILexicalBlock(scope: !452, file: !421, line: 98, column: 7)
!500 = !DILocation(line: 98, column: 7, scope: !452, inlinedAt: !432)
!501 = !DILocation(line: 99, column: 10, scope: !502, inlinedAt: !432)
!502 = distinct !DILexicalBlock(scope: !499, file: !421, line: 98, column: 17)
!503 = !DILocation(line: 99, column: 19, scope: !502, inlinedAt: !432)
!504 = !DILocation(line: 99, column: 8, scope: !502, inlinedAt: !432)
!505 = !DILocation(line: 100, column: 3, scope: !502, inlinedAt: !432)
!506 = !DILocation(line: 100, column: 14, scope: !507, inlinedAt: !432)
!507 = distinct !DILexicalBlock(scope: !499, file: !421, line: 100, column: 14)
!508 = !DILocation(line: 100, column: 14, scope: !499, inlinedAt: !432)
!509 = !DILocation(line: 101, column: 10, scope: !510, inlinedAt: !432)
!510 = distinct !DILexicalBlock(scope: !507, file: !421, line: 100, column: 25)
!511 = !DILocation(line: 101, column: 19, scope: !510, inlinedAt: !432)
!512 = !DILocation(line: 101, column: 8, scope: !510, inlinedAt: !432)
!513 = !DILocation(line: 102, column: 3, scope: !510, inlinedAt: !432)
!514 = !DILocation(line: 103, column: 2, scope: !452, inlinedAt: !432)
!515 = !DILocation(line: 110, column: 6, scope: !516, inlinedAt: !432)
!516 = distinct !DILexicalBlock(scope: !427, file: !421, line: 110, column: 6)
!517 = !DILocation(line: 110, column: 6, scope: !427, inlinedAt: !432)
!518 = !DILocation(line: 111, column: 8, scope: !519, inlinedAt: !432)
!519 = distinct !DILexicalBlock(scope: !516, file: !421, line: 110, column: 17)
!520 = !DILocation(line: 111, column: 5, scope: !519, inlinedAt: !432)
!521 = !DILocation(line: 112, column: 7, scope: !522, inlinedAt: !432)
!522 = distinct !DILexicalBlock(scope: !519, file: !421, line: 112, column: 7)
!523 = !DILocation(line: 112, column: 16, scope: !522, inlinedAt: !432)
!524 = !DILocation(line: 112, column: 20, scope: !522, inlinedAt: !432)
!525 = !DILocation(line: 112, column: 22, scope: !522, inlinedAt: !432)
!526 = !DILocation(line: 112, column: 7, scope: !519, inlinedAt: !432)
!527 = !DILocation(line: 113, column: 22, scope: !528, inlinedAt: !432)
!528 = distinct !DILexicalBlock(scope: !522, file: !421, line: 112, column: 36)
!529 = !DILocation(line: 113, column: 12, scope: !528, inlinedAt: !432)
!530 = !DILocation(line: 113, column: 28, scope: !528, inlinedAt: !432)
!531 = !DILocation(line: 113, column: 38, scope: !528, inlinedAt: !432)
!532 = !DILocation(line: 113, column: 36, scope: !528, inlinedAt: !432)
!533 = !DILocation(line: 113, column: 25, scope: !528, inlinedAt: !432)
!534 = !DILocation(line: 113, column: 11, scope: !528, inlinedAt: !432)
!535 = !DILocation(line: 113, column: 4, scope: !528, inlinedAt: !432)
!536 = !DILocation(line: 115, column: 11, scope: !537, inlinedAt: !432)
!537 = distinct !DILexicalBlock(scope: !522, file: !421, line: 114, column: 10)
!538 = !DILocation(line: 115, column: 16, scope: !537, inlinedAt: !432)
!539 = !DILocation(line: 115, column: 26, scope: !537, inlinedAt: !432)
!540 = !DILocation(line: 115, column: 24, scope: !537, inlinedAt: !432)
!541 = !DILocation(line: 115, column: 15, scope: !537, inlinedAt: !432)
!542 = !DILocation(line: 115, column: 13, scope: !537, inlinedAt: !432)
!543 = !DILocation(line: 115, column: 4, scope: !537, inlinedAt: !432)
!544 = !DILocation(line: 117, column: 13, scope: !545, inlinedAt: !432)
!545 = distinct !DILexicalBlock(scope: !516, file: !421, line: 117, column: 13)
!546 = !DILocation(line: 117, column: 13, scope: !516, inlinedAt: !432)
!547 = !DILocation(line: 118, column: 7, scope: !548, inlinedAt: !432)
!548 = distinct !DILexicalBlock(scope: !549, file: !421, line: 118, column: 7)
!549 = distinct !DILexicalBlock(scope: !545, file: !421, line: 117, column: 24)
!550 = !DILocation(line: 118, column: 7, scope: !549, inlinedAt: !432)
!551 = !DILocation(line: 119, column: 22, scope: !552, inlinedAt: !432)
!552 = distinct !DILexicalBlock(scope: !548, file: !421, line: 118, column: 17)
!553 = !DILocation(line: 119, column: 12, scope: !552, inlinedAt: !432)
!554 = !DILocation(line: 119, column: 28, scope: !552, inlinedAt: !432)
!555 = !DILocation(line: 119, column: 36, scope: !552, inlinedAt: !432)
!556 = !DILocation(line: 119, column: 34, scope: !552, inlinedAt: !432)
!557 = !DILocation(line: 119, column: 25, scope: !552, inlinedAt: !432)
!558 = !DILocation(line: 119, column: 11, scope: !552, inlinedAt: !432)
!559 = !DILocation(line: 119, column: 4, scope: !552, inlinedAt: !432)
!560 = !DILocation(line: 121, column: 11, scope: !561, inlinedAt: !432)
!561 = distinct !DILexicalBlock(scope: !548, file: !421, line: 120, column: 10)
!562 = !DILocation(line: 121, column: 16, scope: !561, inlinedAt: !432)
!563 = !DILocation(line: 121, column: 24, scope: !561, inlinedAt: !432)
!564 = !DILocation(line: 121, column: 22, scope: !561, inlinedAt: !432)
!565 = !DILocation(line: 121, column: 15, scope: !561, inlinedAt: !432)
!566 = !DILocation(line: 121, column: 13, scope: !561, inlinedAt: !432)
!567 = !DILocation(line: 121, column: 4, scope: !561, inlinedAt: !432)
!568 = !DILocation(line: 124, column: 7, scope: !569, inlinedAt: !432)
!569 = distinct !DILexicalBlock(scope: !570, file: !421, line: 124, column: 7)
!570 = distinct !DILexicalBlock(scope: !545, file: !421, line: 123, column: 9)
!571 = !DILocation(line: 124, column: 7, scope: !570, inlinedAt: !432)
!572 = !DILocation(line: 125, column: 23, scope: !573, inlinedAt: !432)
!573 = distinct !DILexicalBlock(scope: !569, file: !421, line: 124, column: 17)
!574 = !DILocation(line: 125, column: 27, scope: !573, inlinedAt: !432)
!575 = !DILocation(line: 125, column: 25, scope: !573, inlinedAt: !432)
!576 = !DILocation(line: 125, column: 35, scope: !573, inlinedAt: !432)
!577 = !DILocation(line: 125, column: 33, scope: !573, inlinedAt: !432)
!578 = !DILocation(line: 125, column: 42, scope: !573, inlinedAt: !432)
!579 = !DILocation(line: 125, column: 40, scope: !573, inlinedAt: !432)
!580 = !DILocation(line: 125, column: 11, scope: !573, inlinedAt: !432)
!581 = !DILocation(line: 125, column: 4, scope: !573, inlinedAt: !432)
!582 = !DILocation(line: 127, column: 12, scope: !583, inlinedAt: !432)
!583 = distinct !DILexicalBlock(scope: !569, file: !421, line: 126, column: 10)
!584 = !DILocation(line: 127, column: 16, scope: !583, inlinedAt: !432)
!585 = !DILocation(line: 127, column: 14, scope: !583, inlinedAt: !432)
!586 = !DILocation(line: 127, column: 24, scope: !583, inlinedAt: !432)
!587 = !DILocation(line: 127, column: 22, scope: !583, inlinedAt: !432)
!588 = !DILocation(line: 127, column: 31, scope: !583, inlinedAt: !432)
!589 = !DILocation(line: 127, column: 29, scope: !583, inlinedAt: !432)
!590 = !DILocation(line: 127, column: 4, scope: !583, inlinedAt: !432)
!591 = !DILocation(line: 130, column: 1, scope: !427, inlinedAt: !432)
!592 = !DILocation(line: 372, column: 2, scope: !420)
!593 = distinct !DISubprogram(name: "k_sleep", scope: !281, file: !281, line: 117, type: !594, scopeLine: 118, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !198)
!594 = !DISubroutineType(types: !595)
!595 = !{!225, !284}
!596 = !DILocalVariable(name: "timeout", arg: 1, scope: !593, file: !281, line: 117, type: !284)
!597 = !DILocation(line: 117, column: 61, scope: !593)
!598 = !DILocation(line: 126, column: 2, scope: !593)
!599 = !DILocation(line: 126, column: 2, scope: !600)
!600 = distinct !DILexicalBlock(scope: !593, file: !281, line: 126, column: 2)
!601 = !{i32 -2141857509}
!602 = !DILocation(line: 127, column: 9, scope: !593)
!603 = !DILocation(line: 127, column: 2, scope: !593)
!604 = distinct !DISubprogram(name: "main", scope: !65, file: !65, line: 72, type: !164, scopeLine: 72, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !198)
!605 = !DILocation(line: 73, column: 29, scope: !604)
!606 = !DILocation(line: 73, column: 5, scope: !604)
!607 = !DILocation(line: 74, column: 34, scope: !604)
!608 = !DILocation(line: 74, column: 5, scope: !604)
!609 = !DILocation(line: 75, column: 1, scope: !604)
!610 = distinct !DISubprogram(name: "k_thread_join", scope: !281, file: !281, line: 102, type: !611, scopeLine: 103, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !198)
!611 = !DISubroutineType(types: !612)
!612 = !{!59, !96, !284}
!613 = !DILocalVariable(name: "thread", arg: 1, scope: !610, file: !281, line: 102, type: !96)
!614 = !DILocation(line: 102, column: 69, scope: !610)
!615 = !DILocalVariable(name: "timeout", arg: 2, scope: !610, file: !281, line: 102, type: !284)
!616 = !DILocation(line: 102, column: 89, scope: !610)
!617 = !DILocation(line: 111, column: 2, scope: !610)
!618 = !DILocation(line: 111, column: 2, scope: !619)
!619 = distinct !DILexicalBlock(scope: !610, file: !281, line: 111, column: 2)
!620 = !{i32 -2141857577}
!621 = !DILocation(line: 112, column: 30, scope: !610)
!622 = !DILocation(line: 112, column: 9, scope: !610)
!623 = !DILocation(line: 112, column: 2, scope: !610)
