; ModuleID = '../src/main.c'
source_filename = "../src/main.c"
target datalayout = "e-m:e-p:32:32-f64:32:64-f80:32-n8:16:32-S128"
target triple = "i386-pc-linux-gnu"

%struct.k_sem = type { %struct._wait_q_t, i32, i32 }
%struct._wait_q_t = type { %struct._dnode }
%struct._dnode = type { %union.anon.0, %union.anon.1 }
%union.anon.0 = type { %struct._dnode* }
%union.anon.1 = type { %struct._dnode* }
%struct.k_thread = type { %struct._thread_base, %struct._callee_saved, i8*, void ()*, i32, %struct.k_mem_pool*, %struct._thread_arch }
%struct._thread_base = type { %union.anon, %struct._wait_q_t*, i8, i8, %union.anon.2, i32, i8*, %struct._timeout, %struct._wait_q_t }
%union.anon = type { %struct._dnode }
%union.anon.2 = type { i16 }
%struct._timeout = type { %struct._dnode, void (%struct._timeout*)*, i64 }
%struct._callee_saved = type { i32, i32, i8* }
%struct.k_mem_pool = type { %struct.k_heap* }
%struct.k_heap = type { %struct.sys_heap, %struct._wait_q_t, %struct.k_spinlock }
%struct.sys_heap = type { %struct.z_heap*, i8*, i32 }
%struct.z_heap = type opaque
%struct.k_spinlock = type {}
%struct._thread_arch = type { i32 }
%struct.z_thread_stack_element = type { i8 }
%struct._static_thread_data = type { %struct.k_thread*, %struct.z_thread_stack_element*, i32, void (i8*, i8*, i8*)*, i8*, i8*, i8*, i32, i32, i32, void ()*, i8* }
%struct.k_timer = type { %struct._timeout, %struct._wait_q_t, void (%struct.k_timer*)*, void (%struct.k_timer*)*, %struct.k_timeout_t, i32, i8* }
%struct.k_timeout_t = type { i64 }
%struct.k_queue = type { %struct._sflist, %struct.k_spinlock, %struct._wait_q_t }
%struct._sflist = type { %struct._sfnode*, %struct._sfnode* }
%struct._sfnode = type { i32 }
%struct.k_msgq = type { %struct._wait_q_t, %struct.k_spinlock, i32, i32, i8*, i8*, i8*, i8*, i32, i8 }
%struct.k_poll_signal = type { %struct._dnode, i32, i32 }

@.str = private unnamed_addr constant [26 x i8] c"%s: Hello World from %s!\0A\00", align 1
@.str.1 = private unnamed_addr constant [13 x i8] c"native_posix\00", align 1
@threadA_sem = dso_local global %struct.k_sem { %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_sem, %struct.k_sem* @threadA_sem, i32 0, i32 0, i32 0) }, %union.anon.1 { %struct._dnode* getelementptr inbounds (%struct.k_sem, %struct.k_sem* @threadA_sem, i32 0, i32 0, i32 0) } } }, i32 1, i32 1 }, section "._k_sem.static.threadA_sem", align 4, !dbg !0
@threadB_sem = dso_local global %struct.k_sem { %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_sem, %struct.k_sem* @threadB_sem, i32 0, i32 0, i32 0) }, %union.anon.1 { %struct._dnode* getelementptr inbounds (%struct.k_sem, %struct.k_sem* @threadB_sem, i32 0, i32 0, i32 0) } } }, i32 0, i32 1 }, section "._k_sem.static.threadB_sem", align 4, !dbg !61
@__func__.threadB = private unnamed_addr constant [8 x i8] c"threadB\00", align 1
@threadB_data = internal global %struct.k_thread zeroinitializer, align 4, !dbg !224
@threadB_stack_area = dso_local global [1024 x %struct.z_thread_stack_element] zeroinitializer, section ".noinit.\22../src/main.c\22.0", align 4, !dbg !219
@.str.2 = private unnamed_addr constant [9 x i8] c"thread_b\00", align 1
@__func__.threadA = private unnamed_addr constant [8 x i8] c"threadA\00", align 1
@_k_thread_obj_thread_a = dso_local global %struct.k_thread zeroinitializer, align 4, !dbg !228
@_k_thread_stack_thread_a = dso_local global [1024 x %struct.z_thread_stack_element] zeroinitializer, section ".noinit.\22../src/main.c\22.1", align 4, !dbg !226
@.str.3 = private unnamed_addr constant [9 x i8] c"thread_a\00", align 1
@_k_thread_data_thread_a = dso_local global %struct._static_thread_data { %struct.k_thread* @_k_thread_obj_thread_a, %struct.z_thread_stack_element* getelementptr inbounds ([1024 x %struct.z_thread_stack_element], [1024 x %struct.z_thread_stack_element]* @_k_thread_stack_thread_a, i32 0, i32 0), i32 1024, void (i8*, i8*, i8*)* @threadA, i8* null, i8* null, i8* null, i32 7, i32 0, i32 0, void ()* null, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.3, i32 0, i32 0) }, section ".__static_thread_data.static._k_thread_data_thread_a", align 4, !dbg !88
@thread_a = dso_local constant %struct.k_thread* @_k_thread_obj_thread_a, align 4, !dbg !215
@llvm.used = appending global [3 x i8*] [i8* bitcast (%struct.k_sem* @threadA_sem to i8*), i8* bitcast (%struct.k_sem* @threadB_sem to i8*), i8* bitcast (%struct._static_thread_data* @_k_thread_data_thread_a to i8*)], section "llvm.metadata"

; Function Attrs: noinline nounwind optnone
define internal void @k_object_access_revoke(i8*, %struct.k_thread*) #0 !dbg !235 {
  %3 = alloca i8*, align 4
  %4 = alloca %struct.k_thread*, align 4
  store i8* %0, i8** %3, align 4
  call void @llvm.dbg.declare(metadata i8** %3, metadata !238, metadata !DIExpression()), !dbg !239
  store %struct.k_thread* %1, %struct.k_thread** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.k_thread** %4, metadata !240, metadata !DIExpression()), !dbg !241
  %5 = load i8*, i8** %3, align 4, !dbg !242
  %6 = load %struct.k_thread*, %struct.k_thread** %4, align 4, !dbg !243
  ret void, !dbg !244
}

; Function Attrs: noinline nounwind optnone
define internal void @k_object_access_all_grant(i8*) #0 !dbg !245 {
  %2 = alloca i8*, align 4
  store i8* %0, i8** %2, align 4
  call void @llvm.dbg.declare(metadata i8** %2, metadata !248, metadata !DIExpression()), !dbg !249
  %3 = load i8*, i8** %2, align 4, !dbg !250
  ret void, !dbg !251
}

; Function Attrs: noinline nounwind optnone
define internal void @z_impl_k_object_access_grant(i8*, %struct.k_thread*) #0 !dbg !252 {
  %3 = alloca i8*, align 4
  %4 = alloca %struct.k_thread*, align 4
  store i8* %0, i8** %3, align 4
  call void @llvm.dbg.declare(metadata i8** %3, metadata !253, metadata !DIExpression()), !dbg !254
  store %struct.k_thread* %1, %struct.k_thread** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.k_thread** %4, metadata !255, metadata !DIExpression()), !dbg !256
  %5 = load i8*, i8** %3, align 4, !dbg !257
  %6 = load %struct.k_thread*, %struct.k_thread** %4, align 4, !dbg !258
  ret void, !dbg !259
}

; Function Attrs: noinline nounwind optnone
define internal void @z_impl_k_object_release(i8*) #0 !dbg !260 {
  %2 = alloca i8*, align 4
  store i8* %0, i8** %2, align 4
  call void @llvm.dbg.declare(metadata i8** %2, metadata !261, metadata !DIExpression()), !dbg !262
  %3 = load i8*, i8** %2, align 4, !dbg !263
  ret void, !dbg !264
}

; Function Attrs: noinline nounwind optnone
define internal i8* @z_impl_k_object_alloc(i32) #0 !dbg !265 {
  %2 = alloca i32, align 4
  store i32 %0, i32* %2, align 4
  call void @llvm.dbg.declare(metadata i32* %2, metadata !268, metadata !DIExpression()), !dbg !269
  %3 = load i32, i32* %2, align 4, !dbg !270
  ret i8* null, !dbg !271
}

; Function Attrs: noinline nounwind optnone
define internal i64 @z_impl_k_thread_timeout_expires_ticks(%struct.k_thread*) #0 !dbg !272 {
  %2 = alloca %struct.k_thread*, align 4
  store %struct.k_thread* %0, %struct.k_thread** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_thread** %2, metadata !275, metadata !DIExpression()), !dbg !276
  %3 = load %struct.k_thread*, %struct.k_thread** %2, align 4, !dbg !277
  %4 = getelementptr inbounds %struct.k_thread, %struct.k_thread* %3, i32 0, i32 0, !dbg !278
  %5 = getelementptr inbounds %struct._thread_base, %struct._thread_base* %4, i32 0, i32 7, !dbg !279
  %6 = call i64 @z_timeout_expires(%struct._timeout* %5) #3, !dbg !280
  ret i64 %6, !dbg !281
}

; Function Attrs: noinline nounwind optnone
define internal i64 @z_impl_k_thread_timeout_remaining_ticks(%struct.k_thread*) #0 !dbg !282 {
  %2 = alloca %struct.k_thread*, align 4
  store %struct.k_thread* %0, %struct.k_thread** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_thread** %2, metadata !283, metadata !DIExpression()), !dbg !284
  %3 = load %struct.k_thread*, %struct.k_thread** %2, align 4, !dbg !285
  %4 = getelementptr inbounds %struct.k_thread, %struct.k_thread* %3, i32 0, i32 0, !dbg !286
  %5 = getelementptr inbounds %struct._thread_base, %struct._thread_base* %4, i32 0, i32 7, !dbg !287
  %6 = call i64 @z_timeout_remaining(%struct._timeout* %5) #3, !dbg !288
  ret i64 %6, !dbg !289
}

; Function Attrs: noinline nounwind optnone
define internal i64 @z_impl_k_timer_expires_ticks(%struct.k_timer*) #0 !dbg !290 {
  %2 = alloca %struct.k_timer*, align 4
  store %struct.k_timer* %0, %struct.k_timer** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_timer** %2, metadata !310, metadata !DIExpression()), !dbg !311
  %3 = load %struct.k_timer*, %struct.k_timer** %2, align 4, !dbg !312
  %4 = getelementptr inbounds %struct.k_timer, %struct.k_timer* %3, i32 0, i32 0, !dbg !313
  %5 = call i64 @z_timeout_expires(%struct._timeout* %4) #3, !dbg !314
  ret i64 %5, !dbg !315
}

; Function Attrs: noinline nounwind optnone
define internal i64 @z_impl_k_timer_remaining_ticks(%struct.k_timer*) #0 !dbg !316 {
  %2 = alloca %struct.k_timer*, align 4
  store %struct.k_timer* %0, %struct.k_timer** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_timer** %2, metadata !317, metadata !DIExpression()), !dbg !318
  %3 = load %struct.k_timer*, %struct.k_timer** %2, align 4, !dbg !319
  %4 = getelementptr inbounds %struct.k_timer, %struct.k_timer* %3, i32 0, i32 0, !dbg !320
  %5 = call i64 @z_timeout_remaining(%struct._timeout* %4) #3, !dbg !321
  ret i64 %5, !dbg !322
}

; Function Attrs: noinline nounwind optnone
define internal void @z_impl_k_timer_user_data_set(%struct.k_timer*, i8*) #0 !dbg !323 {
  %3 = alloca %struct.k_timer*, align 4
  %4 = alloca i8*, align 4
  store %struct.k_timer* %0, %struct.k_timer** %3, align 4
  call void @llvm.dbg.declare(metadata %struct.k_timer** %3, metadata !326, metadata !DIExpression()), !dbg !327
  store i8* %1, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !328, metadata !DIExpression()), !dbg !329
  %5 = load i8*, i8** %4, align 4, !dbg !330
  %6 = load %struct.k_timer*, %struct.k_timer** %3, align 4, !dbg !331
  %7 = getelementptr inbounds %struct.k_timer, %struct.k_timer* %6, i32 0, i32 6, !dbg !332
  store i8* %5, i8** %7, align 4, !dbg !333
  ret void, !dbg !334
}

; Function Attrs: noinline nounwind optnone
define internal i8* @z_impl_k_timer_user_data_get(%struct.k_timer*) #0 !dbg !335 {
  %2 = alloca %struct.k_timer*, align 4
  store %struct.k_timer* %0, %struct.k_timer** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_timer** %2, metadata !338, metadata !DIExpression()), !dbg !339
  %3 = load %struct.k_timer*, %struct.k_timer** %2, align 4, !dbg !340
  %4 = getelementptr inbounds %struct.k_timer, %struct.k_timer* %3, i32 0, i32 6, !dbg !341
  %5 = load i8*, i8** %4, align 4, !dbg !341
  ret i8* %5, !dbg !342
}

; Function Attrs: noinline nounwind optnone
define internal i32 @z_impl_k_queue_is_empty(%struct.k_queue*) #0 !dbg !343 {
  %2 = alloca %struct.k_queue*, align 4
  store %struct.k_queue* %0, %struct.k_queue** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_queue** %2, metadata !364, metadata !DIExpression()), !dbg !365
  %3 = load %struct.k_queue*, %struct.k_queue** %2, align 4, !dbg !366
  %4 = getelementptr inbounds %struct.k_queue, %struct.k_queue* %3, i32 0, i32 0, !dbg !367
  %5 = call zeroext i1 @sys_sflist_is_empty(%struct._sflist* %4) #3, !dbg !368
  %6 = zext i1 %5 to i32, !dbg !369
  ret i32 %6, !dbg !370
}

; Function Attrs: noinline nounwind optnone
define internal i8* @z_impl_k_queue_peek_head(%struct.k_queue*) #0 !dbg !371 {
  %2 = alloca %struct.k_queue*, align 4
  store %struct.k_queue* %0, %struct.k_queue** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_queue** %2, metadata !374, metadata !DIExpression()), !dbg !375
  %3 = load %struct.k_queue*, %struct.k_queue** %2, align 4, !dbg !376
  %4 = getelementptr inbounds %struct.k_queue, %struct.k_queue* %3, i32 0, i32 0, !dbg !377
  %5 = call %struct._sfnode* @sys_sflist_peek_head(%struct._sflist* %4) #3, !dbg !378
  %6 = call i8* @z_queue_node_peek(%struct._sfnode* %5, i1 zeroext false) #3, !dbg !379
  ret i8* %6, !dbg !380
}

; Function Attrs: noinline nounwind optnone
define internal i8* @z_impl_k_queue_peek_tail(%struct.k_queue*) #0 !dbg !381 {
  %2 = alloca %struct.k_queue*, align 4
  store %struct.k_queue* %0, %struct.k_queue** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_queue** %2, metadata !382, metadata !DIExpression()), !dbg !383
  %3 = load %struct.k_queue*, %struct.k_queue** %2, align 4, !dbg !384
  %4 = getelementptr inbounds %struct.k_queue, %struct.k_queue* %3, i32 0, i32 0, !dbg !385
  %5 = call %struct._sfnode* @sys_sflist_peek_tail(%struct._sflist* %4) #3, !dbg !386
  %6 = call i8* @z_queue_node_peek(%struct._sfnode* %5, i1 zeroext false) #3, !dbg !387
  ret i8* %6, !dbg !388
}

; Function Attrs: noinline nounwind optnone
define internal void @z_impl_k_sem_reset(%struct.k_sem*) #0 !dbg !389 {
  %2 = alloca %struct.k_sem*, align 4
  store %struct.k_sem* %0, %struct.k_sem** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_sem** %2, metadata !393, metadata !DIExpression()), !dbg !394
  %3 = load %struct.k_sem*, %struct.k_sem** %2, align 4, !dbg !395
  %4 = getelementptr inbounds %struct.k_sem, %struct.k_sem* %3, i32 0, i32 1, !dbg !396
  store i32 0, i32* %4, align 4, !dbg !397
  ret void, !dbg !398
}

; Function Attrs: noinline nounwind optnone
define internal i32 @z_impl_k_sem_count_get(%struct.k_sem*) #0 !dbg !399 {
  %2 = alloca %struct.k_sem*, align 4
  store %struct.k_sem* %0, %struct.k_sem** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_sem** %2, metadata !402, metadata !DIExpression()), !dbg !403
  %3 = load %struct.k_sem*, %struct.k_sem** %2, align 4, !dbg !404
  %4 = getelementptr inbounds %struct.k_sem, %struct.k_sem* %3, i32 0, i32 1, !dbg !405
  %5 = load i32, i32* %4, align 4, !dbg !405
  ret i32 %5, !dbg !406
}

; Function Attrs: noinline nounwind optnone
define internal i32 @z_impl_k_msgq_num_free_get(%struct.k_msgq*) #0 !dbg !407 {
  %2 = alloca %struct.k_msgq*, align 4
  store %struct.k_msgq* %0, %struct.k_msgq** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_msgq** %2, metadata !424, metadata !DIExpression()), !dbg !425
  %3 = load %struct.k_msgq*, %struct.k_msgq** %2, align 4, !dbg !426
  %4 = getelementptr inbounds %struct.k_msgq, %struct.k_msgq* %3, i32 0, i32 3, !dbg !427
  %5 = load i32, i32* %4, align 4, !dbg !427
  %6 = load %struct.k_msgq*, %struct.k_msgq** %2, align 4, !dbg !428
  %7 = getelementptr inbounds %struct.k_msgq, %struct.k_msgq* %6, i32 0, i32 8, !dbg !429
  %8 = load i32, i32* %7, align 4, !dbg !429
  %9 = sub i32 %5, %8, !dbg !430
  ret i32 %9, !dbg !431
}

; Function Attrs: noinline nounwind optnone
define internal i32 @z_impl_k_msgq_num_used_get(%struct.k_msgq*) #0 !dbg !432 {
  %2 = alloca %struct.k_msgq*, align 4
  store %struct.k_msgq* %0, %struct.k_msgq** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_msgq** %2, metadata !433, metadata !DIExpression()), !dbg !434
  %3 = load %struct.k_msgq*, %struct.k_msgq** %2, align 4, !dbg !435
  %4 = getelementptr inbounds %struct.k_msgq, %struct.k_msgq* %3, i32 0, i32 8, !dbg !436
  %5 = load i32, i32* %4, align 4, !dbg !436
  ret i32 %5, !dbg !437
}

; Function Attrs: noinline nounwind optnone
define internal void @z_impl_k_poll_signal_reset(%struct.k_poll_signal*) #0 !dbg !438 {
  %2 = alloca %struct.k_poll_signal*, align 4
  store %struct.k_poll_signal* %0, %struct.k_poll_signal** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_poll_signal** %2, metadata !447, metadata !DIExpression()), !dbg !448
  %3 = load %struct.k_poll_signal*, %struct.k_poll_signal** %2, align 4, !dbg !449
  %4 = getelementptr inbounds %struct.k_poll_signal, %struct.k_poll_signal* %3, i32 0, i32 1, !dbg !450
  store i32 0, i32* %4, align 4, !dbg !451
  ret void, !dbg !452
}

; Function Attrs: noinline nounwind optnone
define dso_local void @helloLoop(i8*, %struct.k_sem*, %struct.k_sem*) #0 !dbg !453 {
  %4 = alloca i8*, align 4
  %5 = alloca %struct.k_sem*, align 4
  %6 = alloca %struct.k_sem*, align 4
  %7 = alloca i8*, align 4
  %8 = alloca %struct.k_timeout_t, align 4
  store i8* %0, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !456, metadata !DIExpression()), !dbg !457
  store %struct.k_sem* %1, %struct.k_sem** %5, align 4
  call void @llvm.dbg.declare(metadata %struct.k_sem** %5, metadata !458, metadata !DIExpression()), !dbg !459
  store %struct.k_sem* %2, %struct.k_sem** %6, align 4
  call void @llvm.dbg.declare(metadata %struct.k_sem** %6, metadata !460, metadata !DIExpression()), !dbg !461
  call void @llvm.dbg.declare(metadata i8** %7, metadata !462, metadata !DIExpression()), !dbg !463
  br label %9, !dbg !464

9:                                                ; preds = %3, %23
  %10 = load %struct.k_sem*, %struct.k_sem** %5, align 4, !dbg !465
  %11 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %8, i32 0, i32 0, !dbg !467
  store i64 -1, i64* %11, align 4, !dbg !467
  %12 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %8, i32 0, i32 0, !dbg !468
  %13 = load i64, i64* %12, align 4, !dbg !468
  %14 = call i32 @k_sem_take(%struct.k_sem* %10, i64 %13) #3, !dbg !468
  %15 = call %struct.k_thread* @k_current_get() #3, !dbg !469
  %16 = call i8* @k_thread_name_get(%struct.k_thread* %15) #3, !dbg !470
  store i8* %16, i8** %7, align 4, !dbg !471
  %17 = load i8*, i8** %7, align 4, !dbg !472
  %18 = icmp eq i8* %17, null, !dbg !474
  br i1 %18, label %19, label %21, !dbg !475

19:                                               ; preds = %9
  %20 = load i8*, i8** %4, align 4, !dbg !476
  call void (i8*, ...) @printk(i8* getelementptr inbounds ([26 x i8], [26 x i8]* @.str, i32 0, i32 0), i8* %20, i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.1, i32 0, i32 0)) #3, !dbg !478
  br label %23, !dbg !479

21:                                               ; preds = %9
  %22 = load i8*, i8** %7, align 4, !dbg !480
  call void (i8*, ...) @printk(i8* getelementptr inbounds ([26 x i8], [26 x i8]* @.str, i32 0, i32 0), i8* %22, i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.1, i32 0, i32 0)) #3, !dbg !482
  br label %23

23:                                               ; preds = %21, %19
  %24 = call i32 @k_msleep(i32 500) #3, !dbg !483
  %25 = load %struct.k_sem*, %struct.k_sem** %6, align 4, !dbg !484
  call void @k_sem_give(%struct.k_sem* %25) #3, !dbg !485
  br label %9, !dbg !464, !llvm.loop !486
}

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: noinline nounwind optnone
define internal i32 @k_sem_take(%struct.k_sem*, i64) #0 !dbg !488 {
  %3 = alloca %struct.k_timeout_t, align 4
  %4 = alloca %struct.k_sem*, align 4
  %5 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0
  store i64 %1, i64* %5, align 4
  store %struct.k_sem* %0, %struct.k_sem** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.k_sem** %4, metadata !492, metadata !DIExpression()), !dbg !493
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %3, metadata !494, metadata !DIExpression()), !dbg !495
  br label %6, !dbg !496

6:                                                ; preds = %2
  call void asm sideeffect "", "~{memory},~{dirflag},~{fpsr},~{flags}"() #4, !dbg !497, !srcloc !499
  br label %7, !dbg !497

7:                                                ; preds = %6
  %8 = load %struct.k_sem*, %struct.k_sem** %4, align 4, !dbg !500
  %9 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !501
  %10 = load i64, i64* %9, align 4, !dbg !501
  %11 = call i32 @z_impl_k_sem_take(%struct.k_sem* %8, i64 %10) #3, !dbg !501
  ret i32 %11, !dbg !502
}

declare dso_local i8* @k_thread_name_get(%struct.k_thread*) #2

; Function Attrs: noinline nounwind optnone
define internal %struct.k_thread* @k_current_get() #0 !dbg !503 {
  br label %1, !dbg !506

1:                                                ; preds = %0
  call void asm sideeffect "", "~{memory},~{dirflag},~{fpsr},~{flags}"() #4, !dbg !507, !srcloc !509
  br label %2, !dbg !507

2:                                                ; preds = %1
  %3 = call %struct.k_thread* bitcast (%struct.k_thread* (...)* @z_impl_k_current_get to %struct.k_thread* ()*)() #3, !dbg !510
  ret %struct.k_thread* %3, !dbg !511
}

declare dso_local void @printk(i8*, ...) #2

; Function Attrs: noinline nounwind optnone
define internal i32 @k_msleep(i32) #0 !dbg !512 {
  %2 = alloca i32, align 4
  %3 = alloca %struct.k_timeout_t, align 4
  store i32 %0, i32* %2, align 4
  call void @llvm.dbg.declare(metadata i32* %2, metadata !515, metadata !DIExpression()), !dbg !516
  %4 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !517
  %5 = load i32, i32* %2, align 4, !dbg !517
  %6 = icmp sgt i32 %5, 0, !dbg !517
  br i1 %6, label %7, label %9, !dbg !517

7:                                                ; preds = %1
  %8 = load i32, i32* %2, align 4, !dbg !517
  br label %10, !dbg !517

9:                                                ; preds = %1
  br label %10, !dbg !517

10:                                               ; preds = %9, %7
  %11 = phi i32 [ %8, %7 ], [ 0, %9 ], !dbg !517
  %12 = sext i32 %11 to i64, !dbg !517
  %13 = call i64 @k_ms_to_ticks_ceil64(i64 %12) #3, !dbg !517
  store i64 %13, i64* %4, align 4, !dbg !517
  %14 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !518
  %15 = load i64, i64* %14, align 4, !dbg !518
  %16 = call i32 @k_sleep(i64 %15) #3, !dbg !518
  ret i32 %16, !dbg !519
}

; Function Attrs: noinline nounwind optnone
define internal void @k_sem_give(%struct.k_sem*) #0 !dbg !520 {
  %2 = alloca %struct.k_sem*, align 4
  store %struct.k_sem* %0, %struct.k_sem** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_sem** %2, metadata !521, metadata !DIExpression()), !dbg !522
  br label %3, !dbg !523

3:                                                ; preds = %1
  call void asm sideeffect "", "~{memory},~{dirflag},~{fpsr},~{flags}"() #4, !dbg !524, !srcloc !526
  br label %4, !dbg !524

4:                                                ; preds = %3
  %5 = load %struct.k_sem*, %struct.k_sem** %2, align 4, !dbg !527
  call void @z_impl_k_sem_give(%struct.k_sem* %5) #3, !dbg !528
  ret void, !dbg !529
}

; Function Attrs: noinline nounwind optnone
define dso_local void @threadB(i8*, i8*, i8*) #0 !dbg !530 {
  %4 = alloca i8*, align 4
  %5 = alloca i8*, align 4
  %6 = alloca i8*, align 4
  store i8* %0, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !531, metadata !DIExpression()), !dbg !532
  store i8* %1, i8** %5, align 4
  call void @llvm.dbg.declare(metadata i8** %5, metadata !533, metadata !DIExpression()), !dbg !534
  store i8* %2, i8** %6, align 4
  call void @llvm.dbg.declare(metadata i8** %6, metadata !535, metadata !DIExpression()), !dbg !536
  %7 = load i8*, i8** %4, align 4, !dbg !537
  %8 = load i8*, i8** %5, align 4, !dbg !538
  %9 = load i8*, i8** %6, align 4, !dbg !539
  call void @helloLoop(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__func__.threadB, i32 0, i32 0), %struct.k_sem* @threadB_sem, %struct.k_sem* @threadA_sem) #3, !dbg !540
  ret void, !dbg !541
}

; Function Attrs: noinline nounwind optnone
define dso_local void @threadA(i8*, i8*, i8*) #0 !dbg !542 {
  %4 = alloca i8*, align 4
  %5 = alloca i8*, align 4
  %6 = alloca i8*, align 4
  %7 = alloca %struct.k_thread*, align 4
  %8 = alloca %struct.k_timeout_t, align 4
  store i8* %0, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !543, metadata !DIExpression()), !dbg !544
  store i8* %1, i8** %5, align 4
  call void @llvm.dbg.declare(metadata i8** %5, metadata !545, metadata !DIExpression()), !dbg !546
  store i8* %2, i8** %6, align 4
  call void @llvm.dbg.declare(metadata i8** %6, metadata !547, metadata !DIExpression()), !dbg !548
  %9 = load i8*, i8** %4, align 4, !dbg !549
  %10 = load i8*, i8** %5, align 4, !dbg !550
  %11 = load i8*, i8** %6, align 4, !dbg !551
  call void @llvm.dbg.declare(metadata %struct.k_thread** %7, metadata !552, metadata !DIExpression()), !dbg !553
  %12 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %8, i32 0, i32 0, !dbg !554
  store i64 0, i64* %12, align 4, !dbg !554
  %13 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %8, i32 0, i32 0, !dbg !555
  %14 = load i64, i64* %13, align 4, !dbg !555
  %15 = call %struct.k_thread* @k_thread_create(%struct.k_thread* @threadB_data, %struct.z_thread_stack_element* getelementptr inbounds ([1024 x %struct.z_thread_stack_element], [1024 x %struct.z_thread_stack_element]* @threadB_stack_area, i32 0, i32 0), i32 1024, void (i8*, i8*, i8*)* @threadB, i8* null, i8* null, i8* null, i32 7, i32 0, i64 %14) #3, !dbg !555
  store %struct.k_thread* %15, %struct.k_thread** %7, align 4, !dbg !553
  %16 = load %struct.k_thread*, %struct.k_thread** %7, align 4, !dbg !556
  %17 = call i32 @k_thread_name_set(%struct.k_thread* %16, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.2, i32 0, i32 0)) #3, !dbg !557
  call void @helloLoop(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @__func__.threadA, i32 0, i32 0), %struct.k_sem* @threadA_sem, %struct.k_sem* @threadB_sem) #3, !dbg !558
  ret void, !dbg !559
}

; Function Attrs: noinline nounwind optnone
define internal %struct.k_thread* @k_thread_create(%struct.k_thread*, %struct.z_thread_stack_element*, i32, void (i8*, i8*, i8*)*, i8*, i8*, i8*, i32, i32, i64) #0 !dbg !560 {
  %11 = alloca %struct.k_timeout_t, align 4
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
  store i64 %9, i64* %21, align 4
  store %struct.k_thread* %0, %struct.k_thread** %12, align 4
  call void @llvm.dbg.declare(metadata %struct.k_thread** %12, metadata !563, metadata !DIExpression()), !dbg !564
  store %struct.z_thread_stack_element* %1, %struct.z_thread_stack_element** %13, align 4
  call void @llvm.dbg.declare(metadata %struct.z_thread_stack_element** %13, metadata !565, metadata !DIExpression()), !dbg !566
  store i32 %2, i32* %14, align 4
  call void @llvm.dbg.declare(metadata i32* %14, metadata !567, metadata !DIExpression()), !dbg !568
  store void (i8*, i8*, i8*)* %3, void (i8*, i8*, i8*)** %15, align 4
  call void @llvm.dbg.declare(metadata void (i8*, i8*, i8*)** %15, metadata !569, metadata !DIExpression()), !dbg !570
  store i8* %4, i8** %16, align 4
  call void @llvm.dbg.declare(metadata i8** %16, metadata !571, metadata !DIExpression()), !dbg !572
  store i8* %5, i8** %17, align 4
  call void @llvm.dbg.declare(metadata i8** %17, metadata !573, metadata !DIExpression()), !dbg !574
  store i8* %6, i8** %18, align 4
  call void @llvm.dbg.declare(metadata i8** %18, metadata !575, metadata !DIExpression()), !dbg !576
  store i32 %7, i32* %19, align 4
  call void @llvm.dbg.declare(metadata i32* %19, metadata !577, metadata !DIExpression()), !dbg !578
  store i32 %8, i32* %20, align 4
  call void @llvm.dbg.declare(metadata i32* %20, metadata !579, metadata !DIExpression()), !dbg !580
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %11, metadata !581, metadata !DIExpression()), !dbg !582
  br label %22, !dbg !583

22:                                               ; preds = %10
  call void asm sideeffect "", "~{memory},~{dirflag},~{fpsr},~{flags}"() #4, !dbg !584, !srcloc !586
  br label %23, !dbg !584

23:                                               ; preds = %22
  %24 = load %struct.k_thread*, %struct.k_thread** %12, align 4, !dbg !587
  %25 = load %struct.z_thread_stack_element*, %struct.z_thread_stack_element** %13, align 4, !dbg !588
  %26 = load i32, i32* %14, align 4, !dbg !589
  %27 = load void (i8*, i8*, i8*)*, void (i8*, i8*, i8*)** %15, align 4, !dbg !590
  %28 = load i8*, i8** %16, align 4, !dbg !591
  %29 = load i8*, i8** %17, align 4, !dbg !592
  %30 = load i8*, i8** %18, align 4, !dbg !593
  %31 = load i32, i32* %19, align 4, !dbg !594
  %32 = load i32, i32* %20, align 4, !dbg !595
  %33 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %11, i32 0, i32 0, !dbg !596
  %34 = load i64, i64* %33, align 4, !dbg !596
  %35 = call %struct.k_thread* @z_impl_k_thread_create(%struct.k_thread* %24, %struct.z_thread_stack_element* %25, i32 %26, void (i8*, i8*, i8*)* %27, i8* %28, i8* %29, i8* %30, i32 %31, i32 %32, i64 %34) #3, !dbg !596
  ret %struct.k_thread* %35, !dbg !597
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_thread_name_set(%struct.k_thread*, i8*) #0 !dbg !598 {
  %3 = alloca %struct.k_thread*, align 4
  %4 = alloca i8*, align 4
  store %struct.k_thread* %0, %struct.k_thread** %3, align 4
  call void @llvm.dbg.declare(metadata %struct.k_thread** %3, metadata !601, metadata !DIExpression()), !dbg !602
  store i8* %1, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !603, metadata !DIExpression()), !dbg !604
  br label %5, !dbg !605

5:                                                ; preds = %2
  call void asm sideeffect "", "~{memory},~{dirflag},~{fpsr},~{flags}"() #4, !dbg !606, !srcloc !608
  br label %6, !dbg !606

6:                                                ; preds = %5
  %7 = load %struct.k_thread*, %struct.k_thread** %3, align 4, !dbg !609
  %8 = load i8*, i8** %4, align 4, !dbg !610
  %9 = call i32 @z_impl_k_thread_name_set(%struct.k_thread* %7, i8* %8) #3, !dbg !611
  ret i32 %9, !dbg !612
}

; Function Attrs: noinline nounwind optnone
define dso_local void @zephyr_app_main() #0 !dbg !613 {
  ret void, !dbg !614
}

declare dso_local i64 @z_timeout_expires(%struct._timeout*) #2

declare dso_local i64 @z_timeout_remaining(%struct._timeout*) #2

; Function Attrs: noinline nounwind optnone
define internal zeroext i1 @sys_sflist_is_empty(%struct._sflist*) #0 !dbg !615 {
  %2 = alloca %struct._sflist*, align 4
  store %struct._sflist* %0, %struct._sflist** %2, align 4
  call void @llvm.dbg.declare(metadata %struct._sflist** %2, metadata !620, metadata !DIExpression()), !dbg !621
  %3 = load %struct._sflist*, %struct._sflist** %2, align 4, !dbg !621
  %4 = call %struct._sfnode* @sys_sflist_peek_head(%struct._sflist* %3) #3, !dbg !621
  %5 = icmp eq %struct._sfnode* %4, null, !dbg !621
  ret i1 %5, !dbg !621
}

; Function Attrs: noinline nounwind optnone
define internal %struct._sfnode* @sys_sflist_peek_head(%struct._sflist*) #0 !dbg !622 {
  %2 = alloca %struct._sflist*, align 4
  store %struct._sflist* %0, %struct._sflist** %2, align 4
  call void @llvm.dbg.declare(metadata %struct._sflist** %2, metadata !625, metadata !DIExpression()), !dbg !626
  %3 = load %struct._sflist*, %struct._sflist** %2, align 4, !dbg !627
  %4 = getelementptr inbounds %struct._sflist, %struct._sflist* %3, i32 0, i32 0, !dbg !628
  %5 = load %struct._sfnode*, %struct._sfnode** %4, align 4, !dbg !628
  ret %struct._sfnode* %5, !dbg !629
}

declare dso_local i8* @z_queue_node_peek(%struct._sfnode*, i1 zeroext) #2

; Function Attrs: noinline nounwind optnone
define internal %struct._sfnode* @sys_sflist_peek_tail(%struct._sflist*) #0 !dbg !630 {
  %2 = alloca %struct._sflist*, align 4
  store %struct._sflist* %0, %struct._sflist** %2, align 4
  call void @llvm.dbg.declare(metadata %struct._sflist** %2, metadata !631, metadata !DIExpression()), !dbg !632
  %3 = load %struct._sflist*, %struct._sflist** %2, align 4, !dbg !633
  %4 = getelementptr inbounds %struct._sflist, %struct._sflist* %3, i32 0, i32 1, !dbg !634
  %5 = load %struct._sfnode*, %struct._sfnode** %4, align 4, !dbg !634
  ret %struct._sfnode* %5, !dbg !635
}

declare dso_local i32 @z_impl_k_sem_take(%struct.k_sem*, i64) #2

declare dso_local %struct.k_thread* @z_impl_k_current_get(...) #2

; Function Attrs: noinline nounwind optnone
define internal i32 @k_sleep(i64) #0 !dbg !636 {
  %2 = alloca %struct.k_timeout_t, align 4
  %3 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0
  store i64 %0, i64* %3, align 4
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %2, metadata !639, metadata !DIExpression()), !dbg !640
  br label %4, !dbg !641

4:                                                ; preds = %1
  call void asm sideeffect "", "~{memory},~{dirflag},~{fpsr},~{flags}"() #4, !dbg !642, !srcloc !644
  br label %5, !dbg !642

5:                                                ; preds = %4
  %6 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !645
  %7 = load i64, i64* %6, align 4, !dbg !645
  %8 = call i32 @z_impl_k_sleep(i64 %7) #3, !dbg !645
  ret i32 %8, !dbg !646
}

; Function Attrs: noinline nounwind optnone
define internal i64 @k_ms_to_ticks_ceil64(i64) #0 !dbg !647 {
  %2 = alloca i64, align 4
  %3 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %3, metadata !651, metadata !DIExpression()), !dbg !655
  %4 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !657, metadata !DIExpression()), !dbg !658
  %5 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %5, metadata !659, metadata !DIExpression()), !dbg !660
  %6 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %6, metadata !661, metadata !DIExpression()), !dbg !662
  %7 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %7, metadata !663, metadata !DIExpression()), !dbg !664
  %8 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %8, metadata !665, metadata !DIExpression()), !dbg !666
  %9 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %9, metadata !667, metadata !DIExpression()), !dbg !668
  %10 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %10, metadata !669, metadata !DIExpression()), !dbg !670
  %11 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %11, metadata !671, metadata !DIExpression()), !dbg !672
  %12 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %12, metadata !673, metadata !DIExpression()), !dbg !674
  %13 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %13, metadata !675, metadata !DIExpression()), !dbg !678
  %14 = alloca i64, align 8
  store i64 %0, i64* %14, align 8
  call void @llvm.dbg.declare(metadata i64* %14, metadata !679, metadata !DIExpression()), !dbg !680
  %15 = load i64, i64* %14, align 8, !dbg !681
  store i64 %15, i64* %3, align 8
  store i32 1000, i32* %4, align 4
  store i32 100, i32* %5, align 4
  store i8 1, i8* %6, align 1
  store i8 0, i8* %7, align 1
  store i8 1, i8* %8, align 1
  store i8 0, i8* %9, align 1
  %16 = load i8, i8* %6, align 1, !dbg !682
  %17 = trunc i8 %16 to i1, !dbg !682
  br i1 %17, label %18, label %27, !dbg !683

18:                                               ; preds = %1
  %19 = load i32, i32* %5, align 4, !dbg !684
  %20 = load i32, i32* %4, align 4, !dbg !685
  %21 = icmp ugt i32 %19, %20, !dbg !686
  br i1 %21, label %22, label %27, !dbg !687

22:                                               ; preds = %18
  %23 = load i32, i32* %5, align 4, !dbg !688
  %24 = load i32, i32* %4, align 4, !dbg !689
  %25 = urem i32 %23, %24, !dbg !690
  %26 = icmp eq i32 %25, 0, !dbg !691
  br label %27

27:                                               ; preds = %22, %18, %1
  %28 = phi i1 [ false, %18 ], [ false, %1 ], [ %26, %22 ], !dbg !692
  %29 = zext i1 %28 to i8, !dbg !670
  store i8 %29, i8* %10, align 1, !dbg !670
  %30 = load i8, i8* %6, align 1, !dbg !693
  %31 = trunc i8 %30 to i1, !dbg !693
  br i1 %31, label %32, label %41, !dbg !694

32:                                               ; preds = %27
  %33 = load i32, i32* %4, align 4, !dbg !695
  %34 = load i32, i32* %5, align 4, !dbg !696
  %35 = icmp ugt i32 %33, %34, !dbg !697
  br i1 %35, label %36, label %41, !dbg !698

36:                                               ; preds = %32
  %37 = load i32, i32* %4, align 4, !dbg !699
  %38 = load i32, i32* %5, align 4, !dbg !700
  %39 = urem i32 %37, %38, !dbg !701
  %40 = icmp eq i32 %39, 0, !dbg !702
  br label %41

41:                                               ; preds = %36, %32, %27
  %42 = phi i1 [ false, %32 ], [ false, %27 ], [ %40, %36 ], !dbg !692
  %43 = zext i1 %42 to i8, !dbg !672
  store i8 %43, i8* %11, align 1, !dbg !672
  %44 = load i32, i32* %4, align 4, !dbg !703
  %45 = load i32, i32* %5, align 4, !dbg !705
  %46 = icmp eq i32 %44, %45, !dbg !706
  br i1 %46, label %47, label %58, !dbg !707

47:                                               ; preds = %41
  %48 = load i8, i8* %7, align 1, !dbg !708
  %49 = trunc i8 %48 to i1, !dbg !708
  br i1 %49, label %50, label %54, !dbg !708

50:                                               ; preds = %47
  %51 = load i64, i64* %3, align 8, !dbg !710
  %52 = trunc i64 %51 to i32, !dbg !711
  %53 = zext i32 %52 to i64, !dbg !712
  br label %56, !dbg !708

54:                                               ; preds = %47
  %55 = load i64, i64* %3, align 8, !dbg !713
  br label %56, !dbg !708

56:                                               ; preds = %54, %50
  %57 = phi i64 [ %53, %50 ], [ %55, %54 ], !dbg !708
  store i64 %57, i64* %2, align 4, !dbg !714
  br label %160, !dbg !714

58:                                               ; preds = %41
  store i64 0, i64* %12, align 8, !dbg !674
  %59 = load i8, i8* %10, align 1, !dbg !715
  %60 = trunc i8 %59 to i1, !dbg !715
  br i1 %60, label %87, label %61, !dbg !716

61:                                               ; preds = %58
  %62 = load i8, i8* %11, align 1, !dbg !717
  %63 = trunc i8 %62 to i1, !dbg !717
  br i1 %63, label %64, label %68, !dbg !717

64:                                               ; preds = %61
  %65 = load i32, i32* %4, align 4, !dbg !718
  %66 = load i32, i32* %5, align 4, !dbg !719
  %67 = udiv i32 %65, %66, !dbg !720
  br label %70, !dbg !717

68:                                               ; preds = %61
  %69 = load i32, i32* %4, align 4, !dbg !721
  br label %70, !dbg !717

70:                                               ; preds = %68, %64
  %71 = phi i32 [ %67, %64 ], [ %69, %68 ], !dbg !717
  store i32 %71, i32* %13, align 4, !dbg !678
  %72 = load i8, i8* %8, align 1, !dbg !722
  %73 = trunc i8 %72 to i1, !dbg !722
  br i1 %73, label %74, label %78, !dbg !724

74:                                               ; preds = %70
  %75 = load i32, i32* %13, align 4, !dbg !725
  %76 = sub i32 %75, 1, !dbg !727
  %77 = zext i32 %76 to i64, !dbg !725
  store i64 %77, i64* %12, align 8, !dbg !728
  br label %86, !dbg !729

78:                                               ; preds = %70
  %79 = load i8, i8* %9, align 1, !dbg !730
  %80 = trunc i8 %79 to i1, !dbg !730
  br i1 %80, label %81, label %85, !dbg !732

81:                                               ; preds = %78
  %82 = load i32, i32* %13, align 4, !dbg !733
  %83 = udiv i32 %82, 2, !dbg !735
  %84 = zext i32 %83 to i64, !dbg !733
  store i64 %84, i64* %12, align 8, !dbg !736
  br label %85, !dbg !737

85:                                               ; preds = %81, %78
  br label %86

86:                                               ; preds = %85, %74
  br label %87, !dbg !738

87:                                               ; preds = %86, %58
  %88 = load i8, i8* %11, align 1, !dbg !739
  %89 = trunc i8 %88 to i1, !dbg !739
  br i1 %89, label %90, label %114, !dbg !741

90:                                               ; preds = %87
  %91 = load i64, i64* %12, align 8, !dbg !742
  %92 = load i64, i64* %3, align 8, !dbg !744
  %93 = add i64 %92, %91, !dbg !744
  store i64 %93, i64* %3, align 8, !dbg !744
  %94 = load i8, i8* %7, align 1, !dbg !745
  %95 = trunc i8 %94 to i1, !dbg !745
  br i1 %95, label %96, label %107, !dbg !747

96:                                               ; preds = %90
  %97 = load i64, i64* %3, align 8, !dbg !748
  %98 = icmp ult i64 %97, 4294967296, !dbg !749
  br i1 %98, label %99, label %107, !dbg !750

99:                                               ; preds = %96
  %100 = load i64, i64* %3, align 8, !dbg !751
  %101 = trunc i64 %100 to i32, !dbg !753
  %102 = load i32, i32* %4, align 4, !dbg !754
  %103 = load i32, i32* %5, align 4, !dbg !755
  %104 = udiv i32 %102, %103, !dbg !756
  %105 = udiv i32 %101, %104, !dbg !757
  %106 = zext i32 %105 to i64, !dbg !758
  store i64 %106, i64* %2, align 4, !dbg !759
  br label %160, !dbg !759

107:                                              ; preds = %96, %90
  %108 = load i64, i64* %3, align 8, !dbg !760
  %109 = load i32, i32* %4, align 4, !dbg !762
  %110 = load i32, i32* %5, align 4, !dbg !763
  %111 = udiv i32 %109, %110, !dbg !764
  %112 = zext i32 %111 to i64, !dbg !765
  %113 = udiv i64 %108, %112, !dbg !766
  store i64 %113, i64* %2, align 4, !dbg !767
  br label %160, !dbg !767

114:                                              ; preds = %87
  %115 = load i8, i8* %10, align 1, !dbg !768
  %116 = trunc i8 %115 to i1, !dbg !768
  br i1 %116, label %117, label %135, !dbg !770

117:                                              ; preds = %114
  %118 = load i8, i8* %7, align 1, !dbg !771
  %119 = trunc i8 %118 to i1, !dbg !771
  br i1 %119, label %120, label %128, !dbg !774

120:                                              ; preds = %117
  %121 = load i64, i64* %3, align 8, !dbg !775
  %122 = trunc i64 %121 to i32, !dbg !777
  %123 = load i32, i32* %5, align 4, !dbg !778
  %124 = load i32, i32* %4, align 4, !dbg !779
  %125 = udiv i32 %123, %124, !dbg !780
  %126 = mul i32 %122, %125, !dbg !781
  %127 = zext i32 %126 to i64, !dbg !782
  store i64 %127, i64* %2, align 4, !dbg !783
  br label %160, !dbg !783

128:                                              ; preds = %117
  %129 = load i64, i64* %3, align 8, !dbg !784
  %130 = load i32, i32* %5, align 4, !dbg !786
  %131 = load i32, i32* %4, align 4, !dbg !787
  %132 = udiv i32 %130, %131, !dbg !788
  %133 = zext i32 %132 to i64, !dbg !789
  %134 = mul i64 %129, %133, !dbg !790
  store i64 %134, i64* %2, align 4, !dbg !791
  br label %160, !dbg !791

135:                                              ; preds = %114
  %136 = load i8, i8* %7, align 1, !dbg !792
  %137 = trunc i8 %136 to i1, !dbg !792
  br i1 %137, label %138, label %150, !dbg !795

138:                                              ; preds = %135
  %139 = load i64, i64* %3, align 8, !dbg !796
  %140 = load i32, i32* %5, align 4, !dbg !798
  %141 = zext i32 %140 to i64, !dbg !798
  %142 = mul i64 %139, %141, !dbg !799
  %143 = load i64, i64* %12, align 8, !dbg !800
  %144 = add i64 %142, %143, !dbg !801
  %145 = load i32, i32* %4, align 4, !dbg !802
  %146 = zext i32 %145 to i64, !dbg !802
  %147 = udiv i64 %144, %146, !dbg !803
  %148 = trunc i64 %147 to i32, !dbg !804
  %149 = zext i32 %148 to i64, !dbg !804
  store i64 %149, i64* %2, align 4, !dbg !805
  br label %160, !dbg !805

150:                                              ; preds = %135
  %151 = load i64, i64* %3, align 8, !dbg !806
  %152 = load i32, i32* %5, align 4, !dbg !808
  %153 = zext i32 %152 to i64, !dbg !808
  %154 = mul i64 %151, %153, !dbg !809
  %155 = load i64, i64* %12, align 8, !dbg !810
  %156 = add i64 %154, %155, !dbg !811
  %157 = load i32, i32* %4, align 4, !dbg !812
  %158 = zext i32 %157 to i64, !dbg !812
  %159 = udiv i64 %156, %158, !dbg !813
  store i64 %159, i64* %2, align 4, !dbg !814
  br label %160, !dbg !814

160:                                              ; preds = %56, %99, %107, %120, %128, %138, %150
  %161 = load i64, i64* %2, align 4, !dbg !815
  ret i64 %161, !dbg !816
}

declare dso_local i32 @z_impl_k_sleep(i64) #2

declare dso_local void @z_impl_k_sem_give(%struct.k_sem*) #2

declare dso_local %struct.k_thread* @z_impl_k_thread_create(%struct.k_thread*, %struct.z_thread_stack_element*, i32, void (i8*, i8*, i8*)*, i8*, i8*, i8*, i32, i32, i64) #2

declare dso_local i32 @z_impl_k_thread_name_set(%struct.k_thread*, i8*) #2

attributes #0 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="i686" "target-features"="+cx8,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="i686" "target-features"="+cx8,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nobuiltin }
attributes #4 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!230, !231, !232, !233}
!llvm.ident = !{!234}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "threadA_sem", scope: !2, file: !3, line: 63, type: !63, isLocal: false, isDefinition: true, align: 32)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !51, globals: !60, nameTableKind: None)
!3 = !DIFile(filename: "../src/main.c", directory: "/home/kenny/ara/appl/Zephyr/synchronization/build")
!4 = !{!5}
!5 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "k_objects", file: !6, line: 121, baseType: !7, size: 32, elements: !8)
!6 = !DIFile(filename: "zephyrproject/zephyr/include/kernel.h", directory: "/home/kenny")
!7 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!8 = !{!9, !10, !11, !12, !13, !14, !15, !16, !17, !18, !19, !20, !21, !22, !23, !24, !25, !26, !27, !28, !29, !30, !31, !32, !33, !34, !35, !36, !37, !38, !39, !40, !41, !42, !43, !44, !45, !46, !47, !48, !49, !50}
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
!32 = !DIEnumerator(name: "K_OBJ_DRIVER_EEPROM", value: 23, isUnsigned: true)
!33 = !DIEnumerator(name: "K_OBJ_DRIVER_ENTROPY", value: 24, isUnsigned: true)
!34 = !DIEnumerator(name: "K_OBJ_DRIVER_ESPI", value: 25, isUnsigned: true)
!35 = !DIEnumerator(name: "K_OBJ_DRIVER_FLASH", value: 26, isUnsigned: true)
!36 = !DIEnumerator(name: "K_OBJ_DRIVER_GPIO", value: 27, isUnsigned: true)
!37 = !DIEnumerator(name: "K_OBJ_DRIVER_I2C", value: 28, isUnsigned: true)
!38 = !DIEnumerator(name: "K_OBJ_DRIVER_I2S", value: 29, isUnsigned: true)
!39 = !DIEnumerator(name: "K_OBJ_DRIVER_IPM", value: 30, isUnsigned: true)
!40 = !DIEnumerator(name: "K_OBJ_DRIVER_KSCAN", value: 31, isUnsigned: true)
!41 = !DIEnumerator(name: "K_OBJ_DRIVER_LED", value: 32, isUnsigned: true)
!42 = !DIEnumerator(name: "K_OBJ_DRIVER_PINMUX", value: 33, isUnsigned: true)
!43 = !DIEnumerator(name: "K_OBJ_DRIVER_PS2", value: 34, isUnsigned: true)
!44 = !DIEnumerator(name: "K_OBJ_DRIVER_PWM", value: 35, isUnsigned: true)
!45 = !DIEnumerator(name: "K_OBJ_DRIVER_SENSOR", value: 36, isUnsigned: true)
!46 = !DIEnumerator(name: "K_OBJ_DRIVER_SPI", value: 37, isUnsigned: true)
!47 = !DIEnumerator(name: "K_OBJ_DRIVER_UART", value: 38, isUnsigned: true)
!48 = !DIEnumerator(name: "K_OBJ_DRIVER_WDT", value: 39, isUnsigned: true)
!49 = !DIEnumerator(name: "K_OBJ_DRIVER_UART_MUX", value: 40, isUnsigned: true)
!50 = !DIEnumerator(name: "K_OBJ_LAST", value: 41, isUnsigned: true)
!51 = !{!52, !57, !58, !59}
!52 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_ticks_t", file: !53, line: 46, baseType: !54)
!53 = !DIFile(filename: "zephyrproject/zephyr/include/sys_clock.h", directory: "/home/kenny")
!54 = !DIDerivedType(tag: DW_TAG_typedef, name: "int64_t", file: !55, line: 96, baseType: !56)
!55 = !DIFile(filename: "/usr/lib/llvm-9/lib/clang/9.0.1/include/stdint.h", directory: "")
!56 = !DIBasicType(name: "long long int", size: 64, encoding: DW_ATE_signed)
!57 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 32)
!58 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!59 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !55, line: 172, baseType: !7)
!60 = !{!0, !61, !88, !215, !219, !224, !226, !228}
!61 = !DIGlobalVariableExpression(var: !62, expr: !DIExpression())
!62 = distinct !DIGlobalVariable(name: "threadB_sem", scope: !2, file: !3, line: 64, type: !63, isLocal: false, isDefinition: true, align: 32)
!63 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_sem", file: !6, line: 3721, size: 128, elements: !64)
!64 = !{!65, !86, !87}
!65 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !63, file: !6, line: 3722, baseType: !66, size: 64)
!66 = !DIDerivedType(tag: DW_TAG_typedef, name: "_wait_q_t", file: !67, line: 210, baseType: !68)
!67 = !DIFile(filename: "zephyrproject/zephyr/include/kernel_structs.h", directory: "/home/kenny")
!68 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !67, line: 208, size: 64, elements: !69)
!69 = !{!70}
!70 = !DIDerivedType(tag: DW_TAG_member, name: "waitq", scope: !68, file: !67, line: 209, baseType: !71, size: 64)
!71 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dlist_t", file: !72, line: 42, baseType: !73)
!72 = !DIFile(filename: "zephyrproject/zephyr/include/sys/dlist.h", directory: "/home/kenny")
!73 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_dnode", file: !72, line: 31, size: 64, elements: !74)
!74 = !{!75, !81}
!75 = !DIDerivedType(tag: DW_TAG_member, scope: !73, file: !72, line: 32, baseType: !76, size: 32)
!76 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !73, file: !72, line: 32, size: 32, elements: !77)
!77 = !{!78, !80}
!78 = !DIDerivedType(tag: DW_TAG_member, name: "head", scope: !76, file: !72, line: 33, baseType: !79, size: 32)
!79 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !73, size: 32)
!80 = !DIDerivedType(tag: DW_TAG_member, name: "next", scope: !76, file: !72, line: 34, baseType: !79, size: 32)
!81 = !DIDerivedType(tag: DW_TAG_member, scope: !73, file: !72, line: 36, baseType: !82, size: 32, offset: 32)
!82 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !73, file: !72, line: 36, size: 32, elements: !83)
!83 = !{!84, !85}
!84 = !DIDerivedType(tag: DW_TAG_member, name: "tail", scope: !82, file: !72, line: 37, baseType: !79, size: 32)
!85 = !DIDerivedType(tag: DW_TAG_member, name: "prev", scope: !82, file: !72, line: 38, baseType: !79, size: 32)
!86 = !DIDerivedType(tag: DW_TAG_member, name: "count", scope: !63, file: !6, line: 3723, baseType: !59, size: 32, offset: 64)
!87 = !DIDerivedType(tag: DW_TAG_member, name: "limit", scope: !63, file: !6, line: 3724, baseType: !59, size: 32, offset: 96)
!88 = !DIGlobalVariableExpression(var: !89, expr: !DIExpression())
!89 = distinct !DIGlobalVariable(name: "_k_thread_data_thread_a", scope: !2, file: !3, line: 103, type: !90, isLocal: false, isDefinition: true, align: 32)
!90 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_static_thread_data", file: !6, line: 1097, size: 384, elements: !91)
!91 = !{!92, !189, !198, !199, !204, !205, !206, !207, !208, !209, !211, !212}
!92 = !DIDerivedType(tag: DW_TAG_member, name: "init_thread", scope: !90, file: !6, line: 1098, baseType: !93, size: 32)
!93 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !94, size: 32)
!94 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_thread", file: !6, line: 569, size: 672, elements: !95)
!95 = !{!96, !148, !155, !156, !160, !161, !185}
!96 = !DIDerivedType(tag: DW_TAG_member, name: "base", scope: !94, file: !6, line: 571, baseType: !97, size: 416)
!97 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_base", file: !6, line: 440, size: 416, elements: !98)
!98 = !{!99, !113, !115, !118, !119, !132, !133, !134, !147}
!99 = !DIDerivedType(tag: DW_TAG_member, scope: !97, file: !6, line: 443, baseType: !100, size: 64)
!100 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !97, file: !6, line: 443, size: 64, elements: !101)
!101 = !{!102, !104}
!102 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_dlist", scope: !100, file: !6, line: 444, baseType: !103, size: 64)
!103 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dnode_t", file: !72, line: 43, baseType: !73)
!104 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_rb", scope: !100, file: !6, line: 445, baseType: !105, size: 64)
!105 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "rbnode", file: !106, line: 48, size: 64, elements: !107)
!106 = !DIFile(filename: "zephyrproject/zephyr/include/sys/rb.h", directory: "/home/kenny")
!107 = !{!108}
!108 = !DIDerivedType(tag: DW_TAG_member, name: "children", scope: !105, file: !106, line: 49, baseType: !109, size: 64)
!109 = !DICompositeType(tag: DW_TAG_array_type, baseType: !110, size: 64, elements: !111)
!110 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !105, size: 32)
!111 = !{!112}
!112 = !DISubrange(count: 2)
!113 = !DIDerivedType(tag: DW_TAG_member, name: "pended_on", scope: !97, file: !6, line: 451, baseType: !114, size: 32, offset: 64)
!114 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !66, size: 32)
!115 = !DIDerivedType(tag: DW_TAG_member, name: "user_options", scope: !97, file: !6, line: 454, baseType: !116, size: 8, offset: 96)
!116 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !55, line: 226, baseType: !117)
!117 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!118 = !DIDerivedType(tag: DW_TAG_member, name: "thread_state", scope: !97, file: !6, line: 457, baseType: !116, size: 8, offset: 104)
!119 = !DIDerivedType(tag: DW_TAG_member, scope: !97, file: !6, line: 473, baseType: !120, size: 16, offset: 112)
!120 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !97, file: !6, line: 473, size: 16, elements: !121)
!121 = !{!122, !129}
!122 = !DIDerivedType(tag: DW_TAG_member, scope: !120, file: !6, line: 474, baseType: !123, size: 16)
!123 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !120, file: !6, line: 474, size: 16, elements: !124)
!124 = !{!125, !128}
!125 = !DIDerivedType(tag: DW_TAG_member, name: "prio", scope: !123, file: !6, line: 479, baseType: !126, size: 8)
!126 = !DIDerivedType(tag: DW_TAG_typedef, name: "int8_t", file: !55, line: 224, baseType: !127)
!127 = !DIBasicType(name: "signed char", size: 8, encoding: DW_ATE_signed_char)
!128 = !DIDerivedType(tag: DW_TAG_member, name: "sched_locked", scope: !123, file: !6, line: 480, baseType: !116, size: 8, offset: 8)
!129 = !DIDerivedType(tag: DW_TAG_member, name: "preempt", scope: !120, file: !6, line: 483, baseType: !130, size: 16)
!130 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !55, line: 207, baseType: !131)
!131 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!132 = !DIDerivedType(tag: DW_TAG_member, name: "order_key", scope: !97, file: !6, line: 490, baseType: !59, size: 32, offset: 128)
!133 = !DIDerivedType(tag: DW_TAG_member, name: "swap_data", scope: !97, file: !6, line: 510, baseType: !57, size: 32, offset: 160)
!134 = !DIDerivedType(tag: DW_TAG_member, name: "timeout", scope: !97, file: !6, line: 514, baseType: !135, size: 160, offset: 192)
!135 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_timeout", file: !67, line: 221, size: 160, elements: !136)
!136 = !{!137, !138, !144}
!137 = !DIDerivedType(tag: DW_TAG_member, name: "node", scope: !135, file: !67, line: 222, baseType: !103, size: 64)
!138 = !DIDerivedType(tag: DW_TAG_member, name: "fn", scope: !135, file: !67, line: 223, baseType: !139, size: 32, offset: 64)
!139 = !DIDerivedType(tag: DW_TAG_typedef, name: "_timeout_func_t", file: !67, line: 219, baseType: !140)
!140 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !141, size: 32)
!141 = !DISubroutineType(types: !142)
!142 = !{null, !143}
!143 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !135, size: 32)
!144 = !DIDerivedType(tag: DW_TAG_member, name: "dticks", scope: !135, file: !67, line: 226, baseType: !145, size: 64, offset: 96)
!145 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint64_t", file: !55, line: 98, baseType: !146)
!146 = !DIBasicType(name: "long long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!147 = !DIDerivedType(tag: DW_TAG_member, name: "join_waiters", scope: !97, file: !6, line: 517, baseType: !66, size: 64, offset: 352)
!148 = !DIDerivedType(tag: DW_TAG_member, name: "callee_saved", scope: !94, file: !6, line: 574, baseType: !149, size: 96, offset: 416)
!149 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_callee_saved", file: !150, line: 30, size: 96, elements: !151)
!150 = !DIFile(filename: "zephyrproject/zephyr/include/arch/posix/thread.h", directory: "/home/kenny")
!151 = !{!152, !153, !154}
!152 = !DIDerivedType(tag: DW_TAG_member, name: "key", scope: !149, file: !150, line: 32, baseType: !59, size: 32)
!153 = !DIDerivedType(tag: DW_TAG_member, name: "retval", scope: !149, file: !150, line: 35, baseType: !59, size: 32, offset: 32)
!154 = !DIDerivedType(tag: DW_TAG_member, name: "thread_status", scope: !149, file: !150, line: 38, baseType: !57, size: 32, offset: 64)
!155 = !DIDerivedType(tag: DW_TAG_member, name: "init_data", scope: !94, file: !6, line: 577, baseType: !57, size: 32, offset: 512)
!156 = !DIDerivedType(tag: DW_TAG_member, name: "fn_abort", scope: !94, file: !6, line: 582, baseType: !157, size: 32, offset: 544)
!157 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !158, size: 32)
!158 = !DISubroutineType(types: !159)
!159 = !{null}
!160 = !DIDerivedType(tag: DW_TAG_member, name: "errno_var", scope: !94, file: !6, line: 609, baseType: !58, size: 32, offset: 576)
!161 = !DIDerivedType(tag: DW_TAG_member, name: "resource_pool", scope: !94, file: !6, line: 640, baseType: !162, size: 32, offset: 608)
!162 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !163, size: 32)
!163 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mem_pool", file: !164, line: 30, size: 32, elements: !165)
!164 = !DIFile(filename: "zephyrproject/zephyr/include/mempool_heap.h", directory: "/home/kenny")
!165 = !{!166}
!166 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !163, file: !164, line: 31, baseType: !167, size: 32)
!167 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !168, size: 32)
!168 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_heap", file: !67, line: 267, size: 160, elements: !169)
!169 = !{!170, !181, !182}
!170 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !168, file: !67, line: 268, baseType: !171, size: 96)
!171 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "sys_heap", file: !172, line: 51, size: 96, elements: !173)
!172 = !DIFile(filename: "zephyrproject/zephyr/include/sys/sys_heap.h", directory: "/home/kenny")
!173 = !{!174, !177, !178}
!174 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !171, file: !172, line: 52, baseType: !175, size: 32)
!175 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !176, size: 32)
!176 = !DICompositeType(tag: DW_TAG_structure_type, name: "z_heap", file: !172, line: 52, flags: DIFlagFwdDecl)
!177 = !DIDerivedType(tag: DW_TAG_member, name: "init_mem", scope: !171, file: !172, line: 53, baseType: !57, size: 32, offset: 32)
!178 = !DIDerivedType(tag: DW_TAG_member, name: "init_bytes", scope: !171, file: !172, line: 54, baseType: !179, size: 32, offset: 64)
!179 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !180, line: 46, baseType: !7)
!180 = !DIFile(filename: "/usr/lib/llvm-9/lib/clang/9.0.1/include/stddef.h", directory: "")
!181 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !168, file: !67, line: 269, baseType: !66, size: 64, offset: 96)
!182 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !168, file: !67, line: 270, baseType: !183, offset: 160)
!183 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_spinlock", file: !67, line: 234, elements: !184)
!184 = !{}
!185 = !DIDerivedType(tag: DW_TAG_member, name: "arch", scope: !94, file: !6, line: 643, baseType: !186, size: 32, offset: 640)
!186 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_arch", file: !150, line: 42, size: 32, elements: !187)
!187 = !{!188}
!188 = !DIDerivedType(tag: DW_TAG_member, name: "dummy", scope: !186, file: !150, line: 44, baseType: !58, size: 32)
!189 = !DIDerivedType(tag: DW_TAG_member, name: "init_stack", scope: !90, file: !6, line: 1099, baseType: !190, size: 32, offset: 32)
!190 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !191, size: 32)
!191 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_stack_t", file: !192, line: 44, baseType: !193)
!192 = !DIFile(filename: "zephyrproject/zephyr/include/sys/arch_interface.h", directory: "/home/kenny")
!193 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "z_thread_stack_element", file: !194, line: 35, size: 8, elements: !195)
!194 = !DIFile(filename: "zephyrproject/zephyr/include/sys/thread_stack.h", directory: "/home/kenny")
!195 = !{!196}
!196 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !193, file: !194, line: 36, baseType: !197, size: 8)
!197 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!198 = !DIDerivedType(tag: DW_TAG_member, name: "init_stack_size", scope: !90, file: !6, line: 1100, baseType: !7, size: 32, offset: 64)
!199 = !DIDerivedType(tag: DW_TAG_member, name: "init_entry", scope: !90, file: !6, line: 1101, baseType: !200, size: 32, offset: 96)
!200 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_entry_t", file: !192, line: 46, baseType: !201)
!201 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !202, size: 32)
!202 = !DISubroutineType(types: !203)
!203 = !{null, !57, !57, !57}
!204 = !DIDerivedType(tag: DW_TAG_member, name: "init_p1", scope: !90, file: !6, line: 1102, baseType: !57, size: 32, offset: 128)
!205 = !DIDerivedType(tag: DW_TAG_member, name: "init_p2", scope: !90, file: !6, line: 1103, baseType: !57, size: 32, offset: 160)
!206 = !DIDerivedType(tag: DW_TAG_member, name: "init_p3", scope: !90, file: !6, line: 1104, baseType: !57, size: 32, offset: 192)
!207 = !DIDerivedType(tag: DW_TAG_member, name: "init_prio", scope: !90, file: !6, line: 1105, baseType: !58, size: 32, offset: 224)
!208 = !DIDerivedType(tag: DW_TAG_member, name: "init_options", scope: !90, file: !6, line: 1106, baseType: !59, size: 32, offset: 256)
!209 = !DIDerivedType(tag: DW_TAG_member, name: "init_delay", scope: !90, file: !6, line: 1107, baseType: !210, size: 32, offset: 288)
!210 = !DIDerivedType(tag: DW_TAG_typedef, name: "int32_t", file: !55, line: 167, baseType: !58)
!211 = !DIDerivedType(tag: DW_TAG_member, name: "init_abort", scope: !90, file: !6, line: 1108, baseType: !157, size: 32, offset: 320)
!212 = !DIDerivedType(tag: DW_TAG_member, name: "init_name", scope: !90, file: !6, line: 1109, baseType: !213, size: 32, offset: 352)
!213 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !214, size: 32)
!214 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !197)
!215 = !DIGlobalVariableExpression(var: !216, expr: !DIExpression())
!216 = distinct !DIGlobalVariable(name: "thread_a", scope: !2, file: !3, line: 103, type: !217, isLocal: false, isDefinition: true)
!217 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !218)
!218 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_tid_t", file: !6, line: 647, baseType: !93)
!219 = !DIGlobalVariableExpression(var: !220, expr: !DIExpression())
!220 = distinct !DIGlobalVariable(name: "threadB_stack_area", scope: !2, file: !3, line: 79, type: !221, isLocal: false, isDefinition: true, align: 32)
!221 = !DICompositeType(tag: DW_TAG_array_type, baseType: !193, size: 8192, elements: !222)
!222 = !{!223}
!223 = !DISubrange(count: 1024)
!224 = !DIGlobalVariableExpression(var: !225, expr: !DIExpression())
!225 = distinct !DIGlobalVariable(name: "threadB_data", scope: !2, file: !3, line: 80, type: !94, isLocal: true, isDefinition: true)
!226 = !DIGlobalVariableExpression(var: !227, expr: !DIExpression())
!227 = distinct !DIGlobalVariable(name: "_k_thread_stack_thread_a", scope: !2, file: !3, line: 103, type: !221, isLocal: false, isDefinition: true, align: 32)
!228 = !DIGlobalVariableExpression(var: !229, expr: !DIExpression())
!229 = distinct !DIGlobalVariable(name: "_k_thread_obj_thread_a", scope: !2, file: !3, line: 103, type: !94, isLocal: false, isDefinition: true)
!230 = !{i32 1, !"NumRegisterParameters", i32 0}
!231 = !{i32 2, !"Dwarf Version", i32 4}
!232 = !{i32 2, !"Debug Info Version", i32 3}
!233 = !{i32 1, !"wchar_size", i32 4}
!234 = !{!"clang version 9.0.1-12 "}
!235 = distinct !DISubprogram(name: "k_object_access_revoke", scope: !6, file: !6, line: 256, type: !236, scopeLine: 258, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!236 = !DISubroutineType(types: !237)
!237 = !{null, !57, !93}
!238 = !DILocalVariable(name: "object", arg: 1, scope: !235, file: !6, line: 256, type: !57)
!239 = !DILocation(line: 256, column: 49, scope: !235)
!240 = !DILocalVariable(name: "thread", arg: 2, scope: !235, file: !6, line: 257, type: !93)
!241 = !DILocation(line: 257, column: 25, scope: !235)
!242 = !DILocation(line: 259, column: 2, scope: !235)
!243 = !DILocation(line: 260, column: 2, scope: !235)
!244 = !DILocation(line: 261, column: 1, scope: !235)
!245 = distinct !DISubprogram(name: "k_object_access_all_grant", scope: !6, file: !6, line: 271, type: !246, scopeLine: 272, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!246 = !DISubroutineType(types: !247)
!247 = !{null, !57}
!248 = !DILocalVariable(name: "object", arg: 1, scope: !245, file: !6, line: 271, type: !57)
!249 = !DILocation(line: 271, column: 52, scope: !245)
!250 = !DILocation(line: 273, column: 2, scope: !245)
!251 = !DILocation(line: 274, column: 1, scope: !245)
!252 = distinct !DISubprogram(name: "z_impl_k_object_access_grant", scope: !6, file: !6, line: 246, type: !236, scopeLine: 248, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!253 = !DILocalVariable(name: "object", arg: 1, scope: !252, file: !6, line: 246, type: !57)
!254 = !DILocation(line: 246, column: 55, scope: !252)
!255 = !DILocalVariable(name: "thread", arg: 2, scope: !252, file: !6, line: 247, type: !93)
!256 = !DILocation(line: 247, column: 30, scope: !252)
!257 = !DILocation(line: 249, column: 2, scope: !252)
!258 = !DILocation(line: 250, column: 2, scope: !252)
!259 = !DILocation(line: 251, column: 1, scope: !252)
!260 = distinct !DISubprogram(name: "z_impl_k_object_release", scope: !6, file: !6, line: 266, type: !246, scopeLine: 267, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!261 = !DILocalVariable(name: "object", arg: 1, scope: !260, file: !6, line: 266, type: !57)
!262 = !DILocation(line: 266, column: 50, scope: !260)
!263 = !DILocation(line: 268, column: 2, scope: !260)
!264 = !DILocation(line: 269, column: 1, scope: !260)
!265 = distinct !DISubprogram(name: "z_impl_k_object_alloc", scope: !6, file: !6, line: 382, type: !266, scopeLine: 383, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!266 = !DISubroutineType(types: !267)
!267 = !{!57, !5}
!268 = !DILocalVariable(name: "otype", arg: 1, scope: !265, file: !6, line: 382, type: !5)
!269 = !DILocation(line: 382, column: 58, scope: !265)
!270 = !DILocation(line: 384, column: 2, scope: !265)
!271 = !DILocation(line: 386, column: 2, scope: !265)
!272 = distinct !DISubprogram(name: "z_impl_k_thread_timeout_expires_ticks", scope: !6, file: !6, line: 1067, type: !273, scopeLine: 1069, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!273 = !DISubroutineType(types: !274)
!274 = !{!52, !93}
!275 = !DILocalVariable(name: "t", arg: 1, scope: !272, file: !6, line: 1068, type: !93)
!276 = !DILocation(line: 1068, column: 24, scope: !272)
!277 = !DILocation(line: 1070, column: 28, scope: !272)
!278 = !DILocation(line: 1070, column: 31, scope: !272)
!279 = !DILocation(line: 1070, column: 36, scope: !272)
!280 = !DILocation(line: 1070, column: 9, scope: !272)
!281 = !DILocation(line: 1070, column: 2, scope: !272)
!282 = distinct !DISubprogram(name: "z_impl_k_thread_timeout_remaining_ticks", scope: !6, file: !6, line: 1082, type: !273, scopeLine: 1084, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!283 = !DILocalVariable(name: "t", arg: 1, scope: !282, file: !6, line: 1083, type: !93)
!284 = !DILocation(line: 1083, column: 24, scope: !282)
!285 = !DILocation(line: 1085, column: 30, scope: !282)
!286 = !DILocation(line: 1085, column: 33, scope: !282)
!287 = !DILocation(line: 1085, column: 38, scope: !282)
!288 = !DILocation(line: 1085, column: 9, scope: !282)
!289 = !DILocation(line: 1085, column: 2, scope: !282)
!290 = distinct !DISubprogram(name: "z_impl_k_timer_expires_ticks", scope: !6, file: !6, line: 1966, type: !291, scopeLine: 1967, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!291 = !DISubroutineType(types: !292)
!292 = !{!52, !293}
!293 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !294, size: 32)
!294 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_timer", file: !6, line: 1766, size: 416, elements: !295)
!295 = !{!296, !297, !298, !302, !303, !308, !309}
!296 = !DIDerivedType(tag: DW_TAG_member, name: "timeout", scope: !294, file: !6, line: 1772, baseType: !135, size: 160)
!297 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !294, file: !6, line: 1775, baseType: !66, size: 64, offset: 160)
!298 = !DIDerivedType(tag: DW_TAG_member, name: "expiry_fn", scope: !294, file: !6, line: 1778, baseType: !299, size: 32, offset: 224)
!299 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !300, size: 32)
!300 = !DISubroutineType(types: !301)
!301 = !{null, !293}
!302 = !DIDerivedType(tag: DW_TAG_member, name: "stop_fn", scope: !294, file: !6, line: 1781, baseType: !299, size: 32, offset: 256)
!303 = !DIDerivedType(tag: DW_TAG_member, name: "period", scope: !294, file: !6, line: 1784, baseType: !304, size: 64, offset: 288)
!304 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_timeout_t", file: !53, line: 69, baseType: !305)
!305 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !53, line: 67, size: 64, elements: !306)
!306 = !{!307}
!307 = !DIDerivedType(tag: DW_TAG_member, name: "ticks", scope: !305, file: !53, line: 68, baseType: !52, size: 64)
!308 = !DIDerivedType(tag: DW_TAG_member, name: "status", scope: !294, file: !6, line: 1787, baseType: !59, size: 32, offset: 352)
!309 = !DIDerivedType(tag: DW_TAG_member, name: "user_data", scope: !294, file: !6, line: 1790, baseType: !57, size: 32, offset: 384)
!310 = !DILocalVariable(name: "timer", arg: 1, scope: !290, file: !6, line: 1966, type: !293)
!311 = !DILocation(line: 1966, column: 70, scope: !290)
!312 = !DILocation(line: 1968, column: 28, scope: !290)
!313 = !DILocation(line: 1968, column: 35, scope: !290)
!314 = !DILocation(line: 1968, column: 9, scope: !290)
!315 = !DILocation(line: 1968, column: 2, scope: !290)
!316 = distinct !DISubprogram(name: "z_impl_k_timer_remaining_ticks", scope: !6, file: !6, line: 1980, type: !291, scopeLine: 1981, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!317 = !DILocalVariable(name: "timer", arg: 1, scope: !316, file: !6, line: 1980, type: !293)
!318 = !DILocation(line: 1980, column: 72, scope: !316)
!319 = !DILocation(line: 1982, column: 30, scope: !316)
!320 = !DILocation(line: 1982, column: 37, scope: !316)
!321 = !DILocation(line: 1982, column: 9, scope: !316)
!322 = !DILocation(line: 1982, column: 2, scope: !316)
!323 = distinct !DISubprogram(name: "z_impl_k_timer_user_data_set", scope: !6, file: !6, line: 2021, type: !324, scopeLine: 2023, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!324 = !DISubroutineType(types: !325)
!325 = !{null, !293, !57}
!326 = !DILocalVariable(name: "timer", arg: 1, scope: !323, file: !6, line: 2021, type: !293)
!327 = !DILocation(line: 2021, column: 65, scope: !323)
!328 = !DILocalVariable(name: "user_data", arg: 2, scope: !323, file: !6, line: 2022, type: !57)
!329 = !DILocation(line: 2022, column: 19, scope: !323)
!330 = !DILocation(line: 2024, column: 21, scope: !323)
!331 = !DILocation(line: 2024, column: 2, scope: !323)
!332 = !DILocation(line: 2024, column: 9, scope: !323)
!333 = !DILocation(line: 2024, column: 19, scope: !323)
!334 = !DILocation(line: 2025, column: 1, scope: !323)
!335 = distinct !DISubprogram(name: "z_impl_k_timer_user_data_get", scope: !6, file: !6, line: 2036, type: !336, scopeLine: 2037, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!336 = !DISubroutineType(types: !337)
!337 = !{!57, !293}
!338 = !DILocalVariable(name: "timer", arg: 1, scope: !335, file: !6, line: 2036, type: !293)
!339 = !DILocation(line: 2036, column: 66, scope: !335)
!340 = !DILocation(line: 2038, column: 9, scope: !335)
!341 = !DILocation(line: 2038, column: 16, scope: !335)
!342 = !DILocation(line: 2038, column: 2, scope: !335)
!343 = distinct !DISubprogram(name: "z_impl_k_queue_is_empty", scope: !6, file: !6, line: 2465, type: !344, scopeLine: 2466, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!344 = !DISubroutineType(types: !345)
!345 = !{!58, !346}
!346 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !347, size: 32)
!347 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_queue", file: !6, line: 2202, size: 128, elements: !348)
!348 = !{!349, !362, !363}
!349 = !DIDerivedType(tag: DW_TAG_member, name: "data_q", scope: !347, file: !6, line: 2203, baseType: !350, size: 64)
!350 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_sflist_t", file: !351, line: 45, baseType: !352)
!351 = !DIFile(filename: "zephyrproject/zephyr/include/sys/sflist.h", directory: "/home/kenny")
!352 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_sflist", file: !351, line: 40, size: 64, elements: !353)
!353 = !{!354, !361}
!354 = !DIDerivedType(tag: DW_TAG_member, name: "head", scope: !352, file: !351, line: 41, baseType: !355, size: 32)
!355 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !356, size: 32)
!356 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_sfnode_t", file: !351, line: 38, baseType: !357)
!357 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_sfnode", file: !351, line: 34, size: 32, elements: !358)
!358 = !{!359}
!359 = !DIDerivedType(tag: DW_TAG_member, name: "next_and_flags", scope: !357, file: !351, line: 35, baseType: !360, size: 32)
!360 = !DIDerivedType(tag: DW_TAG_typedef, name: "unative_t", file: !351, line: 31, baseType: !59)
!361 = !DIDerivedType(tag: DW_TAG_member, name: "tail", scope: !352, file: !351, line: 42, baseType: !355, size: 32, offset: 32)
!362 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !347, file: !6, line: 2204, baseType: !183, offset: 64)
!363 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !347, file: !6, line: 2205, baseType: !66, size: 64, offset: 64)
!364 = !DILocalVariable(name: "queue", arg: 1, scope: !343, file: !6, line: 2465, type: !346)
!365 = !DILocation(line: 2465, column: 59, scope: !343)
!366 = !DILocation(line: 2467, column: 35, scope: !343)
!367 = !DILocation(line: 2467, column: 42, scope: !343)
!368 = !DILocation(line: 2467, column: 14, scope: !343)
!369 = !DILocation(line: 2467, column: 9, scope: !343)
!370 = !DILocation(line: 2467, column: 2, scope: !343)
!371 = distinct !DISubprogram(name: "z_impl_k_queue_peek_head", scope: !6, file: !6, line: 2481, type: !372, scopeLine: 2482, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!372 = !DISubroutineType(types: !373)
!373 = !{!57, !346}
!374 = !DILocalVariable(name: "queue", arg: 1, scope: !371, file: !6, line: 2481, type: !346)
!375 = !DILocation(line: 2481, column: 62, scope: !371)
!376 = !DILocation(line: 2483, column: 49, scope: !371)
!377 = !DILocation(line: 2483, column: 56, scope: !371)
!378 = !DILocation(line: 2483, column: 27, scope: !371)
!379 = !DILocation(line: 2483, column: 9, scope: !371)
!380 = !DILocation(line: 2483, column: 2, scope: !371)
!381 = distinct !DISubprogram(name: "z_impl_k_queue_peek_tail", scope: !6, file: !6, line: 2497, type: !372, scopeLine: 2498, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!382 = !DILocalVariable(name: "queue", arg: 1, scope: !381, file: !6, line: 2497, type: !346)
!383 = !DILocation(line: 2497, column: 62, scope: !381)
!384 = !DILocation(line: 2499, column: 49, scope: !381)
!385 = !DILocation(line: 2499, column: 56, scope: !381)
!386 = !DILocation(line: 2499, column: 27, scope: !381)
!387 = !DILocation(line: 2499, column: 9, scope: !381)
!388 = !DILocation(line: 2499, column: 2, scope: !381)
!389 = distinct !DISubprogram(name: "z_impl_k_sem_reset", scope: !6, file: !6, line: 3813, type: !390, scopeLine: 3814, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!390 = !DISubroutineType(types: !391)
!391 = !{null, !392}
!392 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !63, size: 32)
!393 = !DILocalVariable(name: "sem", arg: 1, scope: !389, file: !6, line: 3813, type: !392)
!394 = !DILocation(line: 3813, column: 53, scope: !389)
!395 = !DILocation(line: 3815, column: 2, scope: !389)
!396 = !DILocation(line: 3815, column: 7, scope: !389)
!397 = !DILocation(line: 3815, column: 13, scope: !389)
!398 = !DILocation(line: 3816, column: 1, scope: !389)
!399 = distinct !DISubprogram(name: "z_impl_k_sem_count_get", scope: !6, file: !6, line: 3832, type: !400, scopeLine: 3833, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!400 = !DISubroutineType(types: !401)
!401 = !{!7, !392}
!402 = !DILocalVariable(name: "sem", arg: 1, scope: !399, file: !6, line: 3832, type: !392)
!403 = !DILocation(line: 3832, column: 65, scope: !399)
!404 = !DILocation(line: 3834, column: 9, scope: !399)
!405 = !DILocation(line: 3834, column: 14, scope: !399)
!406 = !DILocation(line: 3834, column: 2, scope: !399)
!407 = distinct !DISubprogram(name: "z_impl_k_msgq_num_free_get", scope: !6, file: !6, line: 4105, type: !408, scopeLine: 4106, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!408 = !DISubroutineType(types: !409)
!409 = !{!59, !410}
!410 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !411, size: 32)
!411 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_msgq", file: !6, line: 3865, size: 320, elements: !412)
!412 = !{!413, !414, !415, !416, !417, !419, !420, !421, !422, !423}
!413 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !411, file: !6, line: 3867, baseType: !66, size: 64)
!414 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !411, file: !6, line: 3869, baseType: !183, offset: 64)
!415 = !DIDerivedType(tag: DW_TAG_member, name: "msg_size", scope: !411, file: !6, line: 3871, baseType: !179, size: 32, offset: 64)
!416 = !DIDerivedType(tag: DW_TAG_member, name: "max_msgs", scope: !411, file: !6, line: 3873, baseType: !59, size: 32, offset: 96)
!417 = !DIDerivedType(tag: DW_TAG_member, name: "buffer_start", scope: !411, file: !6, line: 3875, baseType: !418, size: 32, offset: 128)
!418 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !197, size: 32)
!419 = !DIDerivedType(tag: DW_TAG_member, name: "buffer_end", scope: !411, file: !6, line: 3877, baseType: !418, size: 32, offset: 160)
!420 = !DIDerivedType(tag: DW_TAG_member, name: "read_ptr", scope: !411, file: !6, line: 3879, baseType: !418, size: 32, offset: 192)
!421 = !DIDerivedType(tag: DW_TAG_member, name: "write_ptr", scope: !411, file: !6, line: 3881, baseType: !418, size: 32, offset: 224)
!422 = !DIDerivedType(tag: DW_TAG_member, name: "used_msgs", scope: !411, file: !6, line: 3883, baseType: !59, size: 32, offset: 256)
!423 = !DIDerivedType(tag: DW_TAG_member, name: "flags", scope: !411, file: !6, line: 3889, baseType: !116, size: 8, offset: 288)
!424 = !DILocalVariable(name: "msgq", arg: 1, scope: !407, file: !6, line: 4105, type: !410)
!425 = !DILocation(line: 4105, column: 66, scope: !407)
!426 = !DILocation(line: 4107, column: 9, scope: !407)
!427 = !DILocation(line: 4107, column: 15, scope: !407)
!428 = !DILocation(line: 4107, column: 26, scope: !407)
!429 = !DILocation(line: 4107, column: 32, scope: !407)
!430 = !DILocation(line: 4107, column: 24, scope: !407)
!431 = !DILocation(line: 4107, column: 2, scope: !407)
!432 = distinct !DISubprogram(name: "z_impl_k_msgq_num_used_get", scope: !6, file: !6, line: 4121, type: !408, scopeLine: 4122, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!433 = !DILocalVariable(name: "msgq", arg: 1, scope: !432, file: !6, line: 4121, type: !410)
!434 = !DILocation(line: 4121, column: 66, scope: !432)
!435 = !DILocation(line: 4123, column: 9, scope: !432)
!436 = !DILocation(line: 4123, column: 15, scope: !432)
!437 = !DILocation(line: 4123, column: 2, scope: !432)
!438 = distinct !DISubprogram(name: "z_impl_k_poll_signal_reset", scope: !6, file: !6, line: 5146, type: !439, scopeLine: 5147, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!439 = !DISubroutineType(types: !440)
!440 = !{null, !441}
!441 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !442, size: 32)
!442 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_poll_signal", file: !6, line: 4984, size: 128, elements: !443)
!443 = !{!444, !445, !446}
!444 = !DIDerivedType(tag: DW_TAG_member, name: "poll_events", scope: !442, file: !6, line: 4986, baseType: !71, size: 64)
!445 = !DIDerivedType(tag: DW_TAG_member, name: "signaled", scope: !442, file: !6, line: 4992, baseType: !7, size: 32, offset: 64)
!446 = !DIDerivedType(tag: DW_TAG_member, name: "result", scope: !442, file: !6, line: 4995, baseType: !58, size: 32, offset: 96)
!447 = !DILocalVariable(name: "signal", arg: 1, scope: !438, file: !6, line: 5146, type: !441)
!448 = !DILocation(line: 5146, column: 69, scope: !438)
!449 = !DILocation(line: 5148, column: 2, scope: !438)
!450 = !DILocation(line: 5148, column: 10, scope: !438)
!451 = !DILocation(line: 5148, column: 19, scope: !438)
!452 = !DILocation(line: 5149, column: 1, scope: !438)
!453 = distinct !DISubprogram(name: "helloLoop", scope: !3, file: !3, line: 36, type: !454, scopeLine: 38, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !184)
!454 = !DISubroutineType(types: !455)
!455 = !{null, !213, !392, !392}
!456 = !DILocalVariable(name: "my_name", arg: 1, scope: !453, file: !3, line: 36, type: !213)
!457 = !DILocation(line: 36, column: 28, scope: !453)
!458 = !DILocalVariable(name: "my_sem", arg: 2, scope: !453, file: !3, line: 37, type: !392)
!459 = !DILocation(line: 37, column: 23, scope: !453)
!460 = !DILocalVariable(name: "other_sem", arg: 3, scope: !453, file: !3, line: 37, type: !392)
!461 = !DILocation(line: 37, column: 45, scope: !453)
!462 = !DILocalVariable(name: "tname", scope: !453, file: !3, line: 39, type: !213)
!463 = !DILocation(line: 39, column: 14, scope: !453)
!464 = !DILocation(line: 41, column: 2, scope: !453)
!465 = !DILocation(line: 43, column: 14, scope: !466)
!466 = distinct !DILexicalBlock(scope: !453, file: !3, line: 41, column: 12)
!467 = !DILocation(line: 43, column: 22, scope: !466)
!468 = !DILocation(line: 43, column: 3, scope: !466)
!469 = !DILocation(line: 46, column: 29, scope: !466)
!470 = !DILocation(line: 46, column: 11, scope: !466)
!471 = !DILocation(line: 46, column: 9, scope: !466)
!472 = !DILocation(line: 47, column: 7, scope: !473)
!473 = distinct !DILexicalBlock(scope: !466, file: !3, line: 47, column: 7)
!474 = !DILocation(line: 47, column: 13, scope: !473)
!475 = !DILocation(line: 47, column: 7, scope: !466)
!476 = !DILocation(line: 49, column: 5, scope: !477)
!477 = distinct !DILexicalBlock(scope: !473, file: !3, line: 47, column: 22)
!478 = !DILocation(line: 48, column: 4, scope: !477)
!479 = !DILocation(line: 50, column: 3, scope: !477)
!480 = !DILocation(line: 52, column: 5, scope: !481)
!481 = distinct !DILexicalBlock(scope: !473, file: !3, line: 50, column: 10)
!482 = !DILocation(line: 51, column: 4, scope: !481)
!483 = !DILocation(line: 56, column: 3, scope: !466)
!484 = !DILocation(line: 57, column: 14, scope: !466)
!485 = !DILocation(line: 57, column: 3, scope: !466)
!486 = distinct !{!486, !464, !487}
!487 = !DILocation(line: 58, column: 2, scope: !453)
!488 = distinct !DISubprogram(name: "k_sem_take", scope: !489, file: !489, line: 746, type: !490, scopeLine: 747, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!489 = !DIFile(filename: "zephyr/include/generated/syscalls/kernel.h", directory: "/home/kenny/ara/appl/Zephyr/synchronization/build")
!490 = !DISubroutineType(types: !491)
!491 = !{!58, !392, !304}
!492 = !DILocalVariable(name: "sem", arg: 1, scope: !488, file: !489, line: 746, type: !392)
!493 = !DILocation(line: 746, column: 45, scope: !488)
!494 = !DILocalVariable(name: "timeout", arg: 2, scope: !488, file: !489, line: 746, type: !304)
!495 = !DILocation(line: 746, column: 62, scope: !488)
!496 = !DILocation(line: 755, column: 2, scope: !488)
!497 = !DILocation(line: 755, column: 2, scope: !498)
!498 = distinct !DILexicalBlock(scope: !488, file: !489, line: 755, column: 2)
!499 = !{i32 -2146410751}
!500 = !DILocation(line: 756, column: 27, scope: !488)
!501 = !DILocation(line: 756, column: 9, scope: !488)
!502 = !DILocation(line: 756, column: 2, scope: !488)
!503 = distinct !DISubprogram(name: "k_current_get", scope: !489, file: !489, line: 187, type: !504, scopeLine: 188, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!504 = !DISubroutineType(types: !505)
!505 = !{!218}
!506 = !DILocation(line: 194, column: 2, scope: !503)
!507 = !DILocation(line: 194, column: 2, scope: !508)
!508 = distinct !DILexicalBlock(scope: !503, file: !489, line: 194, column: 2)
!509 = !{i32 -2146413551}
!510 = !DILocation(line: 195, column: 9, scope: !503)
!511 = !DILocation(line: 195, column: 2, scope: !503)
!512 = distinct !DISubprogram(name: "k_msleep", scope: !6, file: !6, line: 956, type: !513, scopeLine: 957, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!513 = !DISubroutineType(types: !514)
!514 = !{!210, !210}
!515 = !DILocalVariable(name: "ms", arg: 1, scope: !512, file: !6, line: 956, type: !210)
!516 = !DILocation(line: 956, column: 40, scope: !512)
!517 = !DILocation(line: 958, column: 17, scope: !512)
!518 = !DILocation(line: 958, column: 9, scope: !512)
!519 = !DILocation(line: 958, column: 2, scope: !512)
!520 = distinct !DISubprogram(name: "k_sem_give", scope: !489, file: !489, line: 761, type: !390, scopeLine: 762, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!521 = !DILocalVariable(name: "sem", arg: 1, scope: !520, file: !489, line: 761, type: !392)
!522 = !DILocation(line: 761, column: 46, scope: !520)
!523 = !DILocation(line: 769, column: 2, scope: !520)
!524 = !DILocation(line: 769, column: 2, scope: !525)
!525 = distinct !DILexicalBlock(scope: !520, file: !489, line: 769, column: 2)
!526 = !{i32 -2146410683}
!527 = !DILocation(line: 770, column: 20, scope: !520)
!528 = !DILocation(line: 770, column: 2, scope: !520)
!529 = !DILocation(line: 771, column: 1, scope: !520)
!530 = distinct !DISubprogram(name: "threadB", scope: !3, file: !3, line: 69, type: !202, scopeLine: 70, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !184)
!531 = !DILocalVariable(name: "dummy1", arg: 1, scope: !530, file: !3, line: 69, type: !57)
!532 = !DILocation(line: 69, column: 20, scope: !530)
!533 = !DILocalVariable(name: "dummy2", arg: 2, scope: !530, file: !3, line: 69, type: !57)
!534 = !DILocation(line: 69, column: 34, scope: !530)
!535 = !DILocalVariable(name: "dummy3", arg: 3, scope: !530, file: !3, line: 69, type: !57)
!536 = !DILocation(line: 69, column: 48, scope: !530)
!537 = !DILocation(line: 71, column: 2, scope: !530)
!538 = !DILocation(line: 72, column: 2, scope: !530)
!539 = !DILocation(line: 73, column: 2, scope: !530)
!540 = !DILocation(line: 76, column: 2, scope: !530)
!541 = !DILocation(line: 77, column: 1, scope: !530)
!542 = distinct !DISubprogram(name: "threadA", scope: !3, file: !3, line: 84, type: !202, scopeLine: 85, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !184)
!543 = !DILocalVariable(name: "dummy1", arg: 1, scope: !542, file: !3, line: 84, type: !57)
!544 = !DILocation(line: 84, column: 20, scope: !542)
!545 = !DILocalVariable(name: "dummy2", arg: 2, scope: !542, file: !3, line: 84, type: !57)
!546 = !DILocation(line: 84, column: 34, scope: !542)
!547 = !DILocalVariable(name: "dummy3", arg: 3, scope: !542, file: !3, line: 84, type: !57)
!548 = !DILocation(line: 84, column: 48, scope: !542)
!549 = !DILocation(line: 86, column: 2, scope: !542)
!550 = !DILocation(line: 87, column: 2, scope: !542)
!551 = !DILocation(line: 88, column: 2, scope: !542)
!552 = !DILocalVariable(name: "tid", scope: !542, file: !3, line: 93, type: !218)
!553 = !DILocation(line: 93, column: 10, scope: !542)
!554 = !DILocation(line: 95, column: 17, scope: !542)
!555 = !DILocation(line: 93, column: 16, scope: !542)
!556 = !DILocation(line: 97, column: 20, scope: !542)
!557 = !DILocation(line: 97, column: 2, scope: !542)
!558 = !DILocation(line: 100, column: 2, scope: !542)
!559 = !DILocation(line: 101, column: 1, scope: !542)
!560 = distinct !DISubprogram(name: "k_thread_create", scope: !489, file: !489, line: 66, type: !561, scopeLine: 67, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!561 = !DISubroutineType(types: !562)
!562 = !{!218, !93, !190, !179, !200, !57, !57, !57, !58, !59, !304}
!563 = !DILocalVariable(name: "new_thread", arg: 1, scope: !560, file: !489, line: 66, type: !93)
!564 = !DILocation(line: 66, column: 57, scope: !560)
!565 = !DILocalVariable(name: "stack", arg: 2, scope: !560, file: !489, line: 66, type: !190)
!566 = !DILocation(line: 66, column: 88, scope: !560)
!567 = !DILocalVariable(name: "stack_size", arg: 3, scope: !560, file: !489, line: 66, type: !179)
!568 = !DILocation(line: 66, column: 102, scope: !560)
!569 = !DILocalVariable(name: "entry", arg: 4, scope: !560, file: !489, line: 66, type: !200)
!570 = !DILocation(line: 66, column: 131, scope: !560)
!571 = !DILocalVariable(name: "p1", arg: 5, scope: !560, file: !489, line: 66, type: !57)
!572 = !DILocation(line: 66, column: 145, scope: !560)
!573 = !DILocalVariable(name: "p2", arg: 6, scope: !560, file: !489, line: 66, type: !57)
!574 = !DILocation(line: 66, column: 156, scope: !560)
!575 = !DILocalVariable(name: "p3", arg: 7, scope: !560, file: !489, line: 66, type: !57)
!576 = !DILocation(line: 66, column: 167, scope: !560)
!577 = !DILocalVariable(name: "prio", arg: 8, scope: !560, file: !489, line: 66, type: !58)
!578 = !DILocation(line: 66, column: 175, scope: !560)
!579 = !DILocalVariable(name: "options", arg: 9, scope: !560, file: !489, line: 66, type: !59)
!580 = !DILocation(line: 66, column: 190, scope: !560)
!581 = !DILocalVariable(name: "delay", arg: 10, scope: !560, file: !489, line: 66, type: !304)
!582 = !DILocation(line: 66, column: 211, scope: !560)
!583 = !DILocation(line: 83, column: 2, scope: !560)
!584 = !DILocation(line: 83, column: 2, scope: !585)
!585 = distinct !DILexicalBlock(scope: !560, file: !489, line: 83, column: 2)
!586 = !{i32 -2146414095}
!587 = !DILocation(line: 84, column: 32, scope: !560)
!588 = !DILocation(line: 84, column: 44, scope: !560)
!589 = !DILocation(line: 84, column: 51, scope: !560)
!590 = !DILocation(line: 84, column: 63, scope: !560)
!591 = !DILocation(line: 84, column: 70, scope: !560)
!592 = !DILocation(line: 84, column: 74, scope: !560)
!593 = !DILocation(line: 84, column: 78, scope: !560)
!594 = !DILocation(line: 84, column: 82, scope: !560)
!595 = !DILocation(line: 84, column: 88, scope: !560)
!596 = !DILocation(line: 84, column: 9, scope: !560)
!597 = !DILocation(line: 84, column: 2, scope: !560)
!598 = distinct !DISubprogram(name: "k_thread_name_set", scope: !489, file: !489, line: 363, type: !599, scopeLine: 364, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!599 = !DISubroutineType(types: !600)
!600 = !{!58, !218, !213}
!601 = !DILocalVariable(name: "thread_id", arg: 1, scope: !598, file: !489, line: 363, type: !218)
!602 = !DILocation(line: 363, column: 45, scope: !598)
!603 = !DILocalVariable(name: "value", arg: 2, scope: !598, file: !489, line: 363, type: !213)
!604 = !DILocation(line: 363, column: 69, scope: !598)
!605 = !DILocation(line: 370, column: 2, scope: !598)
!606 = !DILocation(line: 370, column: 2, scope: !607)
!607 = distinct !DILexicalBlock(scope: !598, file: !489, line: 370, column: 2)
!608 = !{i32 -2146412667}
!609 = !DILocation(line: 371, column: 34, scope: !598)
!610 = !DILocation(line: 371, column: 45, scope: !598)
!611 = !DILocation(line: 371, column: 9, scope: !598)
!612 = !DILocation(line: 371, column: 2, scope: !598)
!613 = distinct !DISubprogram(name: "zephyr_app_main", scope: !3, file: !3, line: 106, type: !158, scopeLine: 106, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !184)
!614 = !DILocation(line: 108, column: 1, scope: !613)
!615 = distinct !DISubprogram(name: "sys_sflist_is_empty", scope: !351, file: !351, line: 317, type: !616, scopeLine: 317, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!616 = !DISubroutineType(types: !617)
!617 = !{!618, !619}
!618 = !DIBasicType(name: "_Bool", size: 8, encoding: DW_ATE_boolean)
!619 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !350, size: 32)
!620 = !DILocalVariable(name: "list", arg: 1, scope: !615, file: !351, line: 317, type: !619)
!621 = !DILocation(line: 317, column: 1, scope: !615)
!622 = distinct !DISubprogram(name: "sys_sflist_peek_head", scope: !351, file: !351, line: 237, type: !623, scopeLine: 238, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!623 = !DISubroutineType(types: !624)
!624 = !{!355, !619}
!625 = !DILocalVariable(name: "list", arg: 1, scope: !622, file: !351, line: 237, type: !619)
!626 = !DILocation(line: 237, column: 64, scope: !622)
!627 = !DILocation(line: 239, column: 9, scope: !622)
!628 = !DILocation(line: 239, column: 15, scope: !622)
!629 = !DILocation(line: 239, column: 2, scope: !622)
!630 = distinct !DISubprogram(name: "sys_sflist_peek_tail", scope: !351, file: !351, line: 249, type: !623, scopeLine: 250, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!631 = !DILocalVariable(name: "list", arg: 1, scope: !630, file: !351, line: 249, type: !619)
!632 = !DILocation(line: 249, column: 64, scope: !630)
!633 = !DILocation(line: 251, column: 9, scope: !630)
!634 = !DILocation(line: 251, column: 15, scope: !630)
!635 = !DILocation(line: 251, column: 2, scope: !630)
!636 = distinct !DISubprogram(name: "k_sleep", scope: !489, file: !489, line: 117, type: !637, scopeLine: 118, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!637 = !DISubroutineType(types: !638)
!638 = !{!210, !304}
!639 = !DILocalVariable(name: "timeout", arg: 1, scope: !636, file: !489, line: 117, type: !304)
!640 = !DILocation(line: 117, column: 43, scope: !636)
!641 = !DILocation(line: 126, column: 2, scope: !636)
!642 = !DILocation(line: 126, column: 2, scope: !643)
!643 = distinct !DILexicalBlock(scope: !636, file: !489, line: 126, column: 2)
!644 = !{i32 -2146413891}
!645 = !DILocation(line: 127, column: 9, scope: !636)
!646 = !DILocation(line: 127, column: 2, scope: !636)
!647 = distinct !DISubprogram(name: "k_ms_to_ticks_ceil64", scope: !648, file: !648, line: 368, type: !649, scopeLine: 369, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!648 = !DIFile(filename: "zephyrproject/zephyr/include/sys/time_units.h", directory: "/home/kenny")
!649 = !DISubroutineType(types: !650)
!650 = !{!145, !145}
!651 = !DILocalVariable(name: "t", arg: 1, scope: !652, file: !648, line: 78, type: !145)
!652 = distinct !DISubprogram(name: "z_tmcvt", scope: !648, file: !648, line: 78, type: !653, scopeLine: 82, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !184)
!653 = !DISubroutineType(types: !654)
!654 = !{!145, !145, !59, !59, !618, !618, !618, !618}
!655 = !DILocation(line: 78, column: 63, scope: !652, inlinedAt: !656)
!656 = distinct !DILocation(line: 371, column: 9, scope: !647)
!657 = !DILocalVariable(name: "from_hz", arg: 2, scope: !652, file: !648, line: 78, type: !59)
!658 = !DILocation(line: 78, column: 75, scope: !652, inlinedAt: !656)
!659 = !DILocalVariable(name: "to_hz", arg: 3, scope: !652, file: !648, line: 79, type: !59)
!660 = !DILocation(line: 79, column: 18, scope: !652, inlinedAt: !656)
!661 = !DILocalVariable(name: "const_hz", arg: 4, scope: !652, file: !648, line: 79, type: !618)
!662 = !DILocation(line: 79, column: 30, scope: !652, inlinedAt: !656)
!663 = !DILocalVariable(name: "result32", arg: 5, scope: !652, file: !648, line: 80, type: !618)
!664 = !DILocation(line: 80, column: 14, scope: !652, inlinedAt: !656)
!665 = !DILocalVariable(name: "round_up", arg: 6, scope: !652, file: !648, line: 80, type: !618)
!666 = !DILocation(line: 80, column: 29, scope: !652, inlinedAt: !656)
!667 = !DILocalVariable(name: "round_off", arg: 7, scope: !652, file: !648, line: 81, type: !618)
!668 = !DILocation(line: 81, column: 14, scope: !652, inlinedAt: !656)
!669 = !DILocalVariable(name: "mul_ratio", scope: !652, file: !648, line: 83, type: !618)
!670 = !DILocation(line: 83, column: 7, scope: !652, inlinedAt: !656)
!671 = !DILocalVariable(name: "div_ratio", scope: !652, file: !648, line: 85, type: !618)
!672 = !DILocation(line: 85, column: 7, scope: !652, inlinedAt: !656)
!673 = !DILocalVariable(name: "off", scope: !652, file: !648, line: 92, type: !145)
!674 = !DILocation(line: 92, column: 11, scope: !652, inlinedAt: !656)
!675 = !DILocalVariable(name: "rdivisor", scope: !676, file: !648, line: 95, type: !59)
!676 = distinct !DILexicalBlock(scope: !677, file: !648, line: 94, column: 18)
!677 = distinct !DILexicalBlock(scope: !652, file: !648, line: 94, column: 6)
!678 = !DILocation(line: 95, column: 12, scope: !676, inlinedAt: !656)
!679 = !DILocalVariable(name: "t", arg: 1, scope: !647, file: !648, line: 368, type: !145)
!680 = !DILocation(line: 368, column: 69, scope: !647)
!681 = !DILocation(line: 371, column: 17, scope: !647)
!682 = !DILocation(line: 83, column: 19, scope: !652, inlinedAt: !656)
!683 = !DILocation(line: 83, column: 28, scope: !652, inlinedAt: !656)
!684 = !DILocation(line: 84, column: 4, scope: !652, inlinedAt: !656)
!685 = !DILocation(line: 84, column: 12, scope: !652, inlinedAt: !656)
!686 = !DILocation(line: 84, column: 10, scope: !652, inlinedAt: !656)
!687 = !DILocation(line: 84, column: 21, scope: !652, inlinedAt: !656)
!688 = !DILocation(line: 84, column: 26, scope: !652, inlinedAt: !656)
!689 = !DILocation(line: 84, column: 34, scope: !652, inlinedAt: !656)
!690 = !DILocation(line: 84, column: 32, scope: !652, inlinedAt: !656)
!691 = !DILocation(line: 84, column: 43, scope: !652, inlinedAt: !656)
!692 = !DILocation(line: 0, scope: !652, inlinedAt: !656)
!693 = !DILocation(line: 85, column: 19, scope: !652, inlinedAt: !656)
!694 = !DILocation(line: 85, column: 28, scope: !652, inlinedAt: !656)
!695 = !DILocation(line: 86, column: 4, scope: !652, inlinedAt: !656)
!696 = !DILocation(line: 86, column: 14, scope: !652, inlinedAt: !656)
!697 = !DILocation(line: 86, column: 12, scope: !652, inlinedAt: !656)
!698 = !DILocation(line: 86, column: 21, scope: !652, inlinedAt: !656)
!699 = !DILocation(line: 86, column: 26, scope: !652, inlinedAt: !656)
!700 = !DILocation(line: 86, column: 36, scope: !652, inlinedAt: !656)
!701 = !DILocation(line: 86, column: 34, scope: !652, inlinedAt: !656)
!702 = !DILocation(line: 86, column: 43, scope: !652, inlinedAt: !656)
!703 = !DILocation(line: 88, column: 6, scope: !704, inlinedAt: !656)
!704 = distinct !DILexicalBlock(scope: !652, file: !648, line: 88, column: 6)
!705 = !DILocation(line: 88, column: 17, scope: !704, inlinedAt: !656)
!706 = !DILocation(line: 88, column: 14, scope: !704, inlinedAt: !656)
!707 = !DILocation(line: 88, column: 6, scope: !652, inlinedAt: !656)
!708 = !DILocation(line: 89, column: 10, scope: !709, inlinedAt: !656)
!709 = distinct !DILexicalBlock(scope: !704, file: !648, line: 88, column: 24)
!710 = !DILocation(line: 89, column: 32, scope: !709, inlinedAt: !656)
!711 = !DILocation(line: 89, column: 22, scope: !709, inlinedAt: !656)
!712 = !DILocation(line: 89, column: 21, scope: !709, inlinedAt: !656)
!713 = !DILocation(line: 89, column: 37, scope: !709, inlinedAt: !656)
!714 = !DILocation(line: 89, column: 3, scope: !709, inlinedAt: !656)
!715 = !DILocation(line: 94, column: 7, scope: !677, inlinedAt: !656)
!716 = !DILocation(line: 94, column: 6, scope: !652, inlinedAt: !656)
!717 = !DILocation(line: 95, column: 23, scope: !676, inlinedAt: !656)
!718 = !DILocation(line: 95, column: 36, scope: !676, inlinedAt: !656)
!719 = !DILocation(line: 95, column: 46, scope: !676, inlinedAt: !656)
!720 = !DILocation(line: 95, column: 44, scope: !676, inlinedAt: !656)
!721 = !DILocation(line: 95, column: 55, scope: !676, inlinedAt: !656)
!722 = !DILocation(line: 97, column: 7, scope: !723, inlinedAt: !656)
!723 = distinct !DILexicalBlock(scope: !676, file: !648, line: 97, column: 7)
!724 = !DILocation(line: 97, column: 7, scope: !676, inlinedAt: !656)
!725 = !DILocation(line: 98, column: 10, scope: !726, inlinedAt: !656)
!726 = distinct !DILexicalBlock(scope: !723, file: !648, line: 97, column: 17)
!727 = !DILocation(line: 98, column: 19, scope: !726, inlinedAt: !656)
!728 = !DILocation(line: 98, column: 8, scope: !726, inlinedAt: !656)
!729 = !DILocation(line: 99, column: 3, scope: !726, inlinedAt: !656)
!730 = !DILocation(line: 99, column: 14, scope: !731, inlinedAt: !656)
!731 = distinct !DILexicalBlock(scope: !723, file: !648, line: 99, column: 14)
!732 = !DILocation(line: 99, column: 14, scope: !723, inlinedAt: !656)
!733 = !DILocation(line: 100, column: 10, scope: !734, inlinedAt: !656)
!734 = distinct !DILexicalBlock(scope: !731, file: !648, line: 99, column: 25)
!735 = !DILocation(line: 100, column: 19, scope: !734, inlinedAt: !656)
!736 = !DILocation(line: 100, column: 8, scope: !734, inlinedAt: !656)
!737 = !DILocation(line: 101, column: 3, scope: !734, inlinedAt: !656)
!738 = !DILocation(line: 102, column: 2, scope: !676, inlinedAt: !656)
!739 = !DILocation(line: 109, column: 6, scope: !740, inlinedAt: !656)
!740 = distinct !DILexicalBlock(scope: !652, file: !648, line: 109, column: 6)
!741 = !DILocation(line: 109, column: 6, scope: !652, inlinedAt: !656)
!742 = !DILocation(line: 110, column: 8, scope: !743, inlinedAt: !656)
!743 = distinct !DILexicalBlock(scope: !740, file: !648, line: 109, column: 17)
!744 = !DILocation(line: 110, column: 5, scope: !743, inlinedAt: !656)
!745 = !DILocation(line: 111, column: 7, scope: !746, inlinedAt: !656)
!746 = distinct !DILexicalBlock(scope: !743, file: !648, line: 111, column: 7)
!747 = !DILocation(line: 111, column: 16, scope: !746, inlinedAt: !656)
!748 = !DILocation(line: 111, column: 20, scope: !746, inlinedAt: !656)
!749 = !DILocation(line: 111, column: 22, scope: !746, inlinedAt: !656)
!750 = !DILocation(line: 111, column: 7, scope: !743, inlinedAt: !656)
!751 = !DILocation(line: 112, column: 22, scope: !752, inlinedAt: !656)
!752 = distinct !DILexicalBlock(scope: !746, file: !648, line: 111, column: 36)
!753 = !DILocation(line: 112, column: 12, scope: !752, inlinedAt: !656)
!754 = !DILocation(line: 112, column: 28, scope: !752, inlinedAt: !656)
!755 = !DILocation(line: 112, column: 38, scope: !752, inlinedAt: !656)
!756 = !DILocation(line: 112, column: 36, scope: !752, inlinedAt: !656)
!757 = !DILocation(line: 112, column: 25, scope: !752, inlinedAt: !656)
!758 = !DILocation(line: 112, column: 11, scope: !752, inlinedAt: !656)
!759 = !DILocation(line: 112, column: 4, scope: !752, inlinedAt: !656)
!760 = !DILocation(line: 114, column: 11, scope: !761, inlinedAt: !656)
!761 = distinct !DILexicalBlock(scope: !746, file: !648, line: 113, column: 10)
!762 = !DILocation(line: 114, column: 16, scope: !761, inlinedAt: !656)
!763 = !DILocation(line: 114, column: 26, scope: !761, inlinedAt: !656)
!764 = !DILocation(line: 114, column: 24, scope: !761, inlinedAt: !656)
!765 = !DILocation(line: 114, column: 15, scope: !761, inlinedAt: !656)
!766 = !DILocation(line: 114, column: 13, scope: !761, inlinedAt: !656)
!767 = !DILocation(line: 114, column: 4, scope: !761, inlinedAt: !656)
!768 = !DILocation(line: 116, column: 13, scope: !769, inlinedAt: !656)
!769 = distinct !DILexicalBlock(scope: !740, file: !648, line: 116, column: 13)
!770 = !DILocation(line: 116, column: 13, scope: !740, inlinedAt: !656)
!771 = !DILocation(line: 117, column: 7, scope: !772, inlinedAt: !656)
!772 = distinct !DILexicalBlock(scope: !773, file: !648, line: 117, column: 7)
!773 = distinct !DILexicalBlock(scope: !769, file: !648, line: 116, column: 24)
!774 = !DILocation(line: 117, column: 7, scope: !773, inlinedAt: !656)
!775 = !DILocation(line: 118, column: 22, scope: !776, inlinedAt: !656)
!776 = distinct !DILexicalBlock(scope: !772, file: !648, line: 117, column: 17)
!777 = !DILocation(line: 118, column: 12, scope: !776, inlinedAt: !656)
!778 = !DILocation(line: 118, column: 28, scope: !776, inlinedAt: !656)
!779 = !DILocation(line: 118, column: 36, scope: !776, inlinedAt: !656)
!780 = !DILocation(line: 118, column: 34, scope: !776, inlinedAt: !656)
!781 = !DILocation(line: 118, column: 25, scope: !776, inlinedAt: !656)
!782 = !DILocation(line: 118, column: 11, scope: !776, inlinedAt: !656)
!783 = !DILocation(line: 118, column: 4, scope: !776, inlinedAt: !656)
!784 = !DILocation(line: 120, column: 11, scope: !785, inlinedAt: !656)
!785 = distinct !DILexicalBlock(scope: !772, file: !648, line: 119, column: 10)
!786 = !DILocation(line: 120, column: 16, scope: !785, inlinedAt: !656)
!787 = !DILocation(line: 120, column: 24, scope: !785, inlinedAt: !656)
!788 = !DILocation(line: 120, column: 22, scope: !785, inlinedAt: !656)
!789 = !DILocation(line: 120, column: 15, scope: !785, inlinedAt: !656)
!790 = !DILocation(line: 120, column: 13, scope: !785, inlinedAt: !656)
!791 = !DILocation(line: 120, column: 4, scope: !785, inlinedAt: !656)
!792 = !DILocation(line: 123, column: 7, scope: !793, inlinedAt: !656)
!793 = distinct !DILexicalBlock(scope: !794, file: !648, line: 123, column: 7)
!794 = distinct !DILexicalBlock(scope: !769, file: !648, line: 122, column: 9)
!795 = !DILocation(line: 123, column: 7, scope: !794, inlinedAt: !656)
!796 = !DILocation(line: 124, column: 23, scope: !797, inlinedAt: !656)
!797 = distinct !DILexicalBlock(scope: !793, file: !648, line: 123, column: 17)
!798 = !DILocation(line: 124, column: 27, scope: !797, inlinedAt: !656)
!799 = !DILocation(line: 124, column: 25, scope: !797, inlinedAt: !656)
!800 = !DILocation(line: 124, column: 35, scope: !797, inlinedAt: !656)
!801 = !DILocation(line: 124, column: 33, scope: !797, inlinedAt: !656)
!802 = !DILocation(line: 124, column: 42, scope: !797, inlinedAt: !656)
!803 = !DILocation(line: 124, column: 40, scope: !797, inlinedAt: !656)
!804 = !DILocation(line: 124, column: 11, scope: !797, inlinedAt: !656)
!805 = !DILocation(line: 124, column: 4, scope: !797, inlinedAt: !656)
!806 = !DILocation(line: 126, column: 12, scope: !807, inlinedAt: !656)
!807 = distinct !DILexicalBlock(scope: !793, file: !648, line: 125, column: 10)
!808 = !DILocation(line: 126, column: 16, scope: !807, inlinedAt: !656)
!809 = !DILocation(line: 126, column: 14, scope: !807, inlinedAt: !656)
!810 = !DILocation(line: 126, column: 24, scope: !807, inlinedAt: !656)
!811 = !DILocation(line: 126, column: 22, scope: !807, inlinedAt: !656)
!812 = !DILocation(line: 126, column: 31, scope: !807, inlinedAt: !656)
!813 = !DILocation(line: 126, column: 29, scope: !807, inlinedAt: !656)
!814 = !DILocation(line: 126, column: 4, scope: !807, inlinedAt: !656)
!815 = !DILocation(line: 129, column: 1, scope: !652, inlinedAt: !656)
!816 = !DILocation(line: 371, column: 2, scope: !647)
