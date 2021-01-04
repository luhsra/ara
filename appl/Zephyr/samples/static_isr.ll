; ModuleID = 'llvm-link'
source_filename = "llvm-link"
target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "thumbv7em-none-unknown-eabi"

%struct.k_stack = type { %struct._wait_q_t, %struct.k_spinlock, i32*, i32*, i32*, i8 }
%struct._wait_q_t = type { %struct._dnode }
%struct._dnode = type { %union.anon.0, %union.anon.0 }
%union.anon.0 = type { %struct._dnode* }
%struct.k_spinlock = type {}
%struct.k_mutex = type { %struct._wait_q_t, %struct.k_thread*, i32, i32 }
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
%struct._thread_arch = type { i32, i32 }
%struct.z_thread_stack_element = type { i8 }
%struct._isr_list = type { i32, i32, i8*, i8* }
%struct.k_timeout_t = type { i64 }

@work = dso_local global %struct.k_stack { %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_stack, %struct.k_stack* @work, i32 0, i32 0, i32 0) }, %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_stack, %struct.k_stack* @work, i32 0, i32 0, i32 0) } } }, %struct.k_spinlock zeroinitializer, i32* getelementptr inbounds ([256 x i32], [256 x i32]* @_k_stack_buf_work, i32 0, i32 0), i32* getelementptr inbounds ([256 x i32], [256 x i32]* @_k_stack_buf_work, i32 0, i32 0), i32* bitcast (i8* getelementptr (i8, i8* bitcast ([256 x i32]* @_k_stack_buf_work to i8*), i64 1024) to i32*), i8 0 }, section "._k_stack.static.work", align 4, !dbg !0
@_k_stack_buf_work = dso_local global [256 x i32] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/static_isr/src/main.c\22.1", align 4, !dbg !227
@guard = dso_local global %struct.k_mutex { %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_mutex, %struct.k_mutex* @guard, i32 0, i32 0, i32 0) }, %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_mutex, %struct.k_mutex* @guard, i32 0, i32 0, i32 0) } } }, %struct.k_thread* null, i32 0, i32 15 }, section "._k_mutex.static.guard", align 4, !dbg !65
@worker = dso_local global %struct.k_thread zeroinitializer, align 8, !dbg !225
@worker_stack_area = dso_local global [1024 x %struct.z_thread_stack_element] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/static_isr/src/main.c\22.0", align 8, !dbg !215
@llvm.used = appending global [3 x i8*] [i8* bitcast (%struct.k_stack* @work to i8*), i8* bitcast (%struct.k_mutex* @guard to i8*), i8* bitcast (%struct._isr_list* @main.__isr_produce_work_isr_irq_2 to i8*)], section "llvm.metadata"
@main.__isr_produce_work_isr_irq_2 = internal global %struct._isr_list { i32 0, i32 0, i8* bitcast (void (i8*)* @produce_work_isr to i8*), i8* null }, section ".intList", align 4, !dbg !202

; Function Attrs: noinline nounwind optnone
define dso_local void @produce_work_isr(i8*) #0 !dbg !245 {
  %2 = alloca i8*, align 4
  %3 = alloca %struct.k_timeout_t, align 8
  store i8* %0, i8** %2, align 4
  call void @llvm.dbg.declare(metadata i8** %2, metadata !248, metadata !DIExpression()), !dbg !249
  %4 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !250
  store i64 -1, i64* %4, align 8, !dbg !250
  %5 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !251
  %6 = bitcast i64* %5 to [1 x i64]*, !dbg !251
  %7 = load [1 x i64], [1 x i64]* %6, align 8, !dbg !251
  %8 = call i32 @k_mutex_lock(%struct.k_mutex* @guard, [1 x i64] %7) #3, !dbg !251
  %9 = call i32 @k_stack_push(%struct.k_stack* @work, i32 0) #3, !dbg !252
  %10 = call i32 @k_mutex_unlock(%struct.k_mutex* @guard) #3, !dbg !253
  ret void, !dbg !254
}

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: noinline nounwind optnone
define internal i32 @k_mutex_lock(%struct.k_mutex*, [1 x i64]) #0 !dbg !255 {
  %3 = alloca %struct.k_timeout_t, align 8
  %4 = alloca %struct.k_mutex*, align 4
  %5 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0
  %6 = bitcast i64* %5 to [1 x i64]*
  store [1 x i64] %1, [1 x i64]* %6, align 8
  store %struct.k_mutex* %0, %struct.k_mutex** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.k_mutex** %4, metadata !264, metadata !DIExpression()), !dbg !265
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %3, metadata !266, metadata !DIExpression()), !dbg !267
  br label %7, !dbg !268

7:                                                ; preds = %2
  call void asm sideeffect "", "~{memory}"() #4, !dbg !269, !srcloc !271
  br label %8, !dbg !269

8:                                                ; preds = %7
  %9 = load %struct.k_mutex*, %struct.k_mutex** %4, align 4, !dbg !272
  %10 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !273
  %11 = bitcast i64* %10 to [1 x i64]*, !dbg !273
  %12 = load [1 x i64], [1 x i64]* %11, align 8, !dbg !273
  %13 = call i32 @z_impl_k_mutex_lock(%struct.k_mutex* %9, [1 x i64] %12) #3, !dbg !273
  ret i32 %13, !dbg !274
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_stack_push(%struct.k_stack*, i32) #0 !dbg !275 {
  %3 = alloca %struct.k_stack*, align 4
  %4 = alloca i32, align 4
  store %struct.k_stack* %0, %struct.k_stack** %3, align 4
  call void @llvm.dbg.declare(metadata %struct.k_stack** %3, metadata !279, metadata !DIExpression()), !dbg !280
  store i32 %1, i32* %4, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !281, metadata !DIExpression()), !dbg !282
  br label %5, !dbg !283

5:                                                ; preds = %2
  call void asm sideeffect "", "~{memory}"() #4, !dbg !284, !srcloc !286
  br label %6, !dbg !284

6:                                                ; preds = %5
  %7 = load %struct.k_stack*, %struct.k_stack** %3, align 4, !dbg !287
  %8 = load i32, i32* %4, align 4, !dbg !288
  %9 = call i32 @z_impl_k_stack_push(%struct.k_stack* %7, i32 %8) #3, !dbg !289
  ret i32 %9, !dbg !290
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_mutex_unlock(%struct.k_mutex*) #0 !dbg !291 {
  %2 = alloca %struct.k_mutex*, align 4
  store %struct.k_mutex* %0, %struct.k_mutex** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_mutex** %2, metadata !294, metadata !DIExpression()), !dbg !295
  br label %3, !dbg !296

3:                                                ; preds = %1
  call void asm sideeffect "", "~{memory}"() #4, !dbg !297, !srcloc !299
  br label %4, !dbg !297

4:                                                ; preds = %3
  %5 = load %struct.k_mutex*, %struct.k_mutex** %2, align 4, !dbg !300
  %6 = call i32 @z_impl_k_mutex_unlock(%struct.k_mutex* %5) #3, !dbg !301
  ret i32 %6, !dbg !302
}

declare dso_local i32 @z_impl_k_mutex_unlock(%struct.k_mutex*) #2

declare dso_local i32 @z_impl_k_stack_push(%struct.k_stack*, i32) #2

declare dso_local i32 @z_impl_k_mutex_lock(%struct.k_mutex*, [1 x i64]) #2

; Function Attrs: noinline nounwind optnone
define dso_local void @do_work(i8*, i8*, i8*) #0 !dbg !303 {
  %4 = alloca i8*, align 4
  %5 = alloca i8*, align 4
  %6 = alloca i8*, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca %struct.k_timeout_t, align 8
  %10 = alloca %struct.k_timeout_t, align 8
  store i8* %0, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !306, metadata !DIExpression()), !dbg !307
  store i8* %1, i8** %5, align 4
  call void @llvm.dbg.declare(metadata i8** %5, metadata !308, metadata !DIExpression()), !dbg !309
  store i8* %2, i8** %6, align 4
  call void @llvm.dbg.declare(metadata i8** %6, metadata !310, metadata !DIExpression()), !dbg !311
  call void @llvm.dbg.declare(metadata i32* %7, metadata !312, metadata !DIExpression()), !dbg !313
  store i32 0, i32* %7, align 4, !dbg !313
  br label %11, !dbg !314

11:                                               ; preds = %11, %3
  call void @llvm.dbg.declare(metadata i32* %8, metadata !315, metadata !DIExpression()), !dbg !317
  store i32 0, i32* %8, align 4, !dbg !317
  %12 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %9, i32 0, i32 0, !dbg !318
  store i64 -1, i64* %12, align 8, !dbg !318
  %13 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %9, i32 0, i32 0, !dbg !319
  %14 = bitcast i64* %13 to [1 x i64]*, !dbg !319
  %15 = load [1 x i64], [1 x i64]* %14, align 8, !dbg !319
  %16 = call i32 @k_mutex_lock(%struct.k_mutex* @guard, [1 x i64] %15) #3, !dbg !319
  %17 = load i32, i32* %8, align 4, !dbg !320
  %18 = inttoptr i32 %17 to i32*, !dbg !321
  %19 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %10, i32 0, i32 0, !dbg !322
  store i64 0, i64* %19, align 8, !dbg !322
  %20 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %10, i32 0, i32 0, !dbg !323
  %21 = bitcast i64* %20 to [1 x i64]*, !dbg !323
  %22 = load [1 x i64], [1 x i64]* %21, align 8, !dbg !323
  %23 = call i32 @k_stack_pop(%struct.k_stack* @work, i32* %18, [1 x i64] %22) #3, !dbg !323
  %24 = call i32 @k_mutex_unlock(%struct.k_mutex* @guard) #3, !dbg !324
  %25 = load i32, i32* %8, align 4, !dbg !325
  %26 = load i32, i32* %7, align 4, !dbg !326
  %27 = add i32 %26, %25, !dbg !326
  store i32 %27, i32* %7, align 4, !dbg !326
  br label %11, !dbg !314, !llvm.loop !327
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_stack_pop(%struct.k_stack*, i32*, [1 x i64]) #0 !dbg !329 {
  %4 = alloca %struct.k_timeout_t, align 8
  %5 = alloca %struct.k_stack*, align 4
  %6 = alloca i32*, align 4
  %7 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %4, i32 0, i32 0
  %8 = bitcast i64* %7 to [1 x i64]*
  store [1 x i64] %2, [1 x i64]* %8, align 8
  store %struct.k_stack* %0, %struct.k_stack** %5, align 4
  call void @llvm.dbg.declare(metadata %struct.k_stack** %5, metadata !332, metadata !DIExpression()), !dbg !333
  store i32* %1, i32** %6, align 4
  call void @llvm.dbg.declare(metadata i32** %6, metadata !334, metadata !DIExpression()), !dbg !335
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %4, metadata !336, metadata !DIExpression()), !dbg !337
  br label %9, !dbg !338

9:                                                ; preds = %3
  call void asm sideeffect "", "~{memory}"() #4, !dbg !339, !srcloc !341
  br label %10, !dbg !339

10:                                               ; preds = %9
  %11 = load %struct.k_stack*, %struct.k_stack** %5, align 4, !dbg !342
  %12 = load i32*, i32** %6, align 4, !dbg !343
  %13 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %4, i32 0, i32 0, !dbg !344
  %14 = bitcast i64* %13 to [1 x i64]*, !dbg !344
  %15 = load [1 x i64], [1 x i64]* %14, align 8, !dbg !344
  %16 = call i32 @z_impl_k_stack_pop(%struct.k_stack* %11, i32* %12, [1 x i64] %15) #3, !dbg !344
  ret i32 %16, !dbg !345
}

declare dso_local i32 @z_impl_k_stack_pop(%struct.k_stack*, i32*, [1 x i64]) #2

; Function Attrs: noinline nounwind optnone
define dso_local void @main() #0 !dbg !204 {
  %1 = alloca %struct.k_thread*, align 4
  %2 = alloca %struct.k_timeout_t, align 8
  %3 = alloca %struct.k_timeout_t, align 8
  call void @llvm.dbg.declare(metadata %struct.k_thread** %1, metadata !346, metadata !DIExpression()), !dbg !348
  %4 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !349
  store i64 -1, i64* %4, align 8, !dbg !349
  %5 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !350
  %6 = bitcast i64* %5 to [1 x i64]*, !dbg !350
  %7 = load [1 x i64], [1 x i64]* %6, align 8, !dbg !350
  %8 = call %struct.k_thread* @k_thread_create(%struct.k_thread* @worker, %struct.z_thread_stack_element* getelementptr inbounds ([1024 x %struct.z_thread_stack_element], [1024 x %struct.z_thread_stack_element]* @worker_stack_area, i32 0, i32 0), i32 1024, void (i8*, i8*, i8*)* @do_work, i8* null, i8* null, i8* null, i32 1, i32 0, [1 x i64] %7) #3, !dbg !350
  store %struct.k_thread* %8, %struct.k_thread** %1, align 4, !dbg !348
  br label %9, !dbg !351

9:                                                ; preds = %9, %0
  %10 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !352
  store i64 -1, i64* %10, align 8, !dbg !352
  %11 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !354
  %12 = bitcast i64* %11 to [1 x i64]*, !dbg !354
  %13 = load [1 x i64], [1 x i64]* %12, align 8, !dbg !354
  %14 = call i32 @k_mutex_lock(%struct.k_mutex* @guard, [1 x i64] %13) #3, !dbg !354
  %15 = call i32 @k_stack_push(%struct.k_stack* @work, i32 0) #3, !dbg !355
  %16 = call i32 @k_mutex_unlock(%struct.k_mutex* @guard) #3, !dbg !356
  br label %9, !dbg !351, !llvm.loop !357
}

; Function Attrs: noinline nounwind optnone
define internal %struct.k_thread* @k_thread_create(%struct.k_thread*, %struct.z_thread_stack_element*, i32, void (i8*, i8*, i8*)*, i8*, i8*, i8*, i32, i32, [1 x i64]) #0 !dbg !359 {
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
  call void @llvm.dbg.declare(metadata %struct.k_thread** %12, metadata !367, metadata !DIExpression()), !dbg !368
  store %struct.z_thread_stack_element* %1, %struct.z_thread_stack_element** %13, align 4
  call void @llvm.dbg.declare(metadata %struct.z_thread_stack_element** %13, metadata !369, metadata !DIExpression()), !dbg !370
  store i32 %2, i32* %14, align 4
  call void @llvm.dbg.declare(metadata i32* %14, metadata !371, metadata !DIExpression()), !dbg !372
  store void (i8*, i8*, i8*)* %3, void (i8*, i8*, i8*)** %15, align 4
  call void @llvm.dbg.declare(metadata void (i8*, i8*, i8*)** %15, metadata !373, metadata !DIExpression()), !dbg !374
  store i8* %4, i8** %16, align 4
  call void @llvm.dbg.declare(metadata i8** %16, metadata !375, metadata !DIExpression()), !dbg !376
  store i8* %5, i8** %17, align 4
  call void @llvm.dbg.declare(metadata i8** %17, metadata !377, metadata !DIExpression()), !dbg !378
  store i8* %6, i8** %18, align 4
  call void @llvm.dbg.declare(metadata i8** %18, metadata !379, metadata !DIExpression()), !dbg !380
  store i32 %7, i32* %19, align 4
  call void @llvm.dbg.declare(metadata i32* %19, metadata !381, metadata !DIExpression()), !dbg !382
  store i32 %8, i32* %20, align 4
  call void @llvm.dbg.declare(metadata i32* %20, metadata !383, metadata !DIExpression()), !dbg !384
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %11, metadata !385, metadata !DIExpression()), !dbg !386
  br label %23, !dbg !387

23:                                               ; preds = %10
  call void asm sideeffect "", "~{memory}"() #4, !dbg !388, !srcloc !390
  br label %24, !dbg !388

24:                                               ; preds = %23
  %25 = load %struct.k_thread*, %struct.k_thread** %12, align 4, !dbg !391
  %26 = load %struct.z_thread_stack_element*, %struct.z_thread_stack_element** %13, align 4, !dbg !392
  %27 = load i32, i32* %14, align 4, !dbg !393
  %28 = load void (i8*, i8*, i8*)*, void (i8*, i8*, i8*)** %15, align 4, !dbg !394
  %29 = load i8*, i8** %16, align 4, !dbg !395
  %30 = load i8*, i8** %17, align 4, !dbg !396
  %31 = load i8*, i8** %18, align 4, !dbg !397
  %32 = load i32, i32* %19, align 4, !dbg !398
  %33 = load i32, i32* %20, align 4, !dbg !399
  %34 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %11, i32 0, i32 0, !dbg !400
  %35 = bitcast i64* %34 to [1 x i64]*, !dbg !400
  %36 = load [1 x i64], [1 x i64]* %35, align 8, !dbg !400
  %37 = call %struct.k_thread* @z_impl_k_thread_create(%struct.k_thread* %25, %struct.z_thread_stack_element* %26, i32 %27, void (i8*, i8*, i8*)* %28, i8* %29, i8* %30, i8* %31, i32 %32, i32 %33, [1 x i64] %36) #3, !dbg !400
  ret %struct.k_thread* %37, !dbg !401
}

declare dso_local %struct.k_thread* @z_impl_k_thread_create(%struct.k_thread*, %struct.z_thread_stack_element*, i32, void (i8*, i8*, i8*)*, i8*, i8*, i8*, i32, i32, [1 x i64]) #2

attributes #0 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #1 = { nounwind readnone speculatable }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #3 = { nobuiltin }
attributes #4 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.ident = !{!240}
!llvm.module.flags = !{!241, !242, !243, !244}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "work", scope: !2, file: !67, line: 13, type: !232, isLocal: false, isDefinition: true, align: 32)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !52, globals: !64, nameTableKind: None)
!3 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/static_isr/src/main.c", directory: "/home/kenny/ara/build/appl/Zephyr/static_isr")
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
!52 = !{!53, !58, !59, !62, !63}
!53 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_ticks_t", file: !54, line: 46, baseType: !55)
!54 = !DIFile(filename: "zephyrproject/zephyr/include/sys_clock.h", directory: "/home/kenny")
!55 = !DIDerivedType(tag: DW_TAG_typedef, name: "int64_t", file: !56, line: 43, baseType: !57)
!56 = !DIFile(filename: "zephyrproject/zephyr/lib/libc/minimal/include/stdint.h", directory: "/home/kenny")
!57 = !DIBasicType(name: "long long int", size: 64, encoding: DW_ATE_signed)
!58 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !59, size: 32)
!59 = !DIDerivedType(tag: DW_TAG_typedef, name: "stack_data_t", file: !6, line: 2893, baseType: !60)
!60 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintptr_t", file: !56, line: 71, baseType: !61)
!61 = !DIBasicType(name: "long unsigned int", size: 32, encoding: DW_ATE_unsigned)
!62 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 32)
!63 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!64 = !{!0, !65, !202, !215, !225, !227}
!65 = !DIGlobalVariableExpression(var: !66, expr: !DIExpression())
!66 = distinct !DIGlobalVariable(name: "guard", scope: !2, file: !67, line: 15, type: !68, isLocal: false, isDefinition: true, align: 32)
!67 = !DIFile(filename: "appl/Zephyr/static_isr/src/main.c", directory: "/home/kenny/ara")
!68 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mutex", file: !6, line: 3589, size: 160, elements: !69)
!69 = !{!70, !91, !200, !201}
!70 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !68, file: !6, line: 3591, baseType: !71, size: 64)
!71 = !DIDerivedType(tag: DW_TAG_typedef, name: "_wait_q_t", file: !72, line: 210, baseType: !73)
!72 = !DIFile(filename: "zephyrproject/zephyr/include/kernel_structs.h", directory: "/home/kenny")
!73 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !72, line: 208, size: 64, elements: !74)
!74 = !{!75}
!75 = !DIDerivedType(tag: DW_TAG_member, name: "waitq", scope: !73, file: !72, line: 209, baseType: !76, size: 64)
!76 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dlist_t", file: !77, line: 42, baseType: !78)
!77 = !DIFile(filename: "zephyrproject/zephyr/include/sys/dlist.h", directory: "/home/kenny")
!78 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_dnode", file: !77, line: 31, size: 64, elements: !79)
!79 = !{!80, !86}
!80 = !DIDerivedType(tag: DW_TAG_member, scope: !78, file: !77, line: 32, baseType: !81, size: 32)
!81 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !78, file: !77, line: 32, size: 32, elements: !82)
!82 = !{!83, !85}
!83 = !DIDerivedType(tag: DW_TAG_member, name: "head", scope: !81, file: !77, line: 33, baseType: !84, size: 32)
!84 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !78, size: 32)
!85 = !DIDerivedType(tag: DW_TAG_member, name: "next", scope: !81, file: !77, line: 34, baseType: !84, size: 32)
!86 = !DIDerivedType(tag: DW_TAG_member, scope: !78, file: !77, line: 36, baseType: !87, size: 32, offset: 32)
!87 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !78, file: !77, line: 36, size: 32, elements: !88)
!88 = !{!89, !90}
!89 = !DIDerivedType(tag: DW_TAG_member, name: "tail", scope: !87, file: !77, line: 37, baseType: !84, size: 32)
!90 = !DIDerivedType(tag: DW_TAG_member, name: "prev", scope: !87, file: !77, line: 38, baseType: !84, size: 32)
!91 = !DIDerivedType(tag: DW_TAG_member, name: "owner", scope: !68, file: !6, line: 3593, baseType: !92, size: 32, offset: 64)
!92 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !93, size: 32)
!93 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_thread", file: !6, line: 570, size: 1024, elements: !94)
!94 = !{!95, !146, !159, !160, !164, !165, !173, !195}
!95 = !DIDerivedType(tag: DW_TAG_member, name: "base", scope: !93, file: !6, line: 572, baseType: !96, size: 448)
!96 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_base", file: !6, line: 441, size: 448, elements: !97)
!97 = !{!98, !112, !114, !116, !117, !130, !133, !134, !145}
!98 = !DIDerivedType(tag: DW_TAG_member, scope: !96, file: !6, line: 444, baseType: !99, size: 64)
!99 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !96, file: !6, line: 444, size: 64, elements: !100)
!100 = !{!101, !103}
!101 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_dlist", scope: !99, file: !6, line: 445, baseType: !102, size: 64)
!102 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dnode_t", file: !77, line: 43, baseType: !78)
!103 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_rb", scope: !99, file: !6, line: 446, baseType: !104, size: 64)
!104 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "rbnode", file: !105, line: 48, size: 64, elements: !106)
!105 = !DIFile(filename: "zephyrproject/zephyr/include/sys/rb.h", directory: "/home/kenny")
!106 = !{!107}
!107 = !DIDerivedType(tag: DW_TAG_member, name: "children", scope: !104, file: !105, line: 49, baseType: !108, size: 64)
!108 = !DICompositeType(tag: DW_TAG_array_type, baseType: !109, size: 64, elements: !110)
!109 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !104, size: 32)
!110 = !{!111}
!111 = !DISubrange(count: 2)
!112 = !DIDerivedType(tag: DW_TAG_member, name: "pended_on", scope: !96, file: !6, line: 452, baseType: !113, size: 32, offset: 64)
!113 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !71, size: 32)
!114 = !DIDerivedType(tag: DW_TAG_member, name: "user_options", scope: !96, file: !6, line: 455, baseType: !115, size: 8, offset: 96)
!115 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !56, line: 55, baseType: !7)
!116 = !DIDerivedType(tag: DW_TAG_member, name: "thread_state", scope: !96, file: !6, line: 458, baseType: !115, size: 8, offset: 104)
!117 = !DIDerivedType(tag: DW_TAG_member, scope: !96, file: !6, line: 474, baseType: !118, size: 16, offset: 112)
!118 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !96, file: !6, line: 474, size: 16, elements: !119)
!119 = !{!120, !127}
!120 = !DIDerivedType(tag: DW_TAG_member, scope: !118, file: !6, line: 475, baseType: !121, size: 16)
!121 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !118, file: !6, line: 475, size: 16, elements: !122)
!122 = !{!123, !126}
!123 = !DIDerivedType(tag: DW_TAG_member, name: "prio", scope: !121, file: !6, line: 480, baseType: !124, size: 8)
!124 = !DIDerivedType(tag: DW_TAG_typedef, name: "int8_t", file: !56, line: 40, baseType: !125)
!125 = !DIBasicType(name: "signed char", size: 8, encoding: DW_ATE_signed_char)
!126 = !DIDerivedType(tag: DW_TAG_member, name: "sched_locked", scope: !121, file: !6, line: 481, baseType: !115, size: 8, offset: 8)
!127 = !DIDerivedType(tag: DW_TAG_member, name: "preempt", scope: !118, file: !6, line: 484, baseType: !128, size: 16)
!128 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !56, line: 56, baseType: !129)
!129 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!130 = !DIDerivedType(tag: DW_TAG_member, name: "order_key", scope: !96, file: !6, line: 491, baseType: !131, size: 32, offset: 128)
!131 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !56, line: 57, baseType: !132)
!132 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!133 = !DIDerivedType(tag: DW_TAG_member, name: "swap_data", scope: !96, file: !6, line: 511, baseType: !62, size: 32, offset: 160)
!134 = !DIDerivedType(tag: DW_TAG_member, name: "timeout", scope: !96, file: !6, line: 515, baseType: !135, size: 192, offset: 192)
!135 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_timeout", file: !72, line: 221, size: 192, elements: !136)
!136 = !{!137, !138, !144}
!137 = !DIDerivedType(tag: DW_TAG_member, name: "node", scope: !135, file: !72, line: 222, baseType: !102, size: 64)
!138 = !DIDerivedType(tag: DW_TAG_member, name: "fn", scope: !135, file: !72, line: 223, baseType: !139, size: 32, offset: 64)
!139 = !DIDerivedType(tag: DW_TAG_typedef, name: "_timeout_func_t", file: !72, line: 219, baseType: !140)
!140 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !141, size: 32)
!141 = !DISubroutineType(types: !142)
!142 = !{null, !143}
!143 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !135, size: 32)
!144 = !DIDerivedType(tag: DW_TAG_member, name: "dticks", scope: !135, file: !72, line: 226, baseType: !55, size: 64, offset: 128)
!145 = !DIDerivedType(tag: DW_TAG_member, name: "join_waiters", scope: !96, file: !6, line: 518, baseType: !71, size: 64, offset: 384)
!146 = !DIDerivedType(tag: DW_TAG_member, name: "callee_saved", scope: !93, file: !6, line: 575, baseType: !147, size: 288, offset: 448)
!147 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_callee_saved", file: !148, line: 25, size: 288, elements: !149)
!148 = !DIFile(filename: "zephyrproject/zephyr/include/arch/arm/aarch32/thread.h", directory: "/home/kenny")
!149 = !{!150, !151, !152, !153, !154, !155, !156, !157, !158}
!150 = !DIDerivedType(tag: DW_TAG_member, name: "v1", scope: !147, file: !148, line: 26, baseType: !131, size: 32)
!151 = !DIDerivedType(tag: DW_TAG_member, name: "v2", scope: !147, file: !148, line: 27, baseType: !131, size: 32, offset: 32)
!152 = !DIDerivedType(tag: DW_TAG_member, name: "v3", scope: !147, file: !148, line: 28, baseType: !131, size: 32, offset: 64)
!153 = !DIDerivedType(tag: DW_TAG_member, name: "v4", scope: !147, file: !148, line: 29, baseType: !131, size: 32, offset: 96)
!154 = !DIDerivedType(tag: DW_TAG_member, name: "v5", scope: !147, file: !148, line: 30, baseType: !131, size: 32, offset: 128)
!155 = !DIDerivedType(tag: DW_TAG_member, name: "v6", scope: !147, file: !148, line: 31, baseType: !131, size: 32, offset: 160)
!156 = !DIDerivedType(tag: DW_TAG_member, name: "v7", scope: !147, file: !148, line: 32, baseType: !131, size: 32, offset: 192)
!157 = !DIDerivedType(tag: DW_TAG_member, name: "v8", scope: !147, file: !148, line: 33, baseType: !131, size: 32, offset: 224)
!158 = !DIDerivedType(tag: DW_TAG_member, name: "psp", scope: !147, file: !148, line: 34, baseType: !131, size: 32, offset: 256)
!159 = !DIDerivedType(tag: DW_TAG_member, name: "init_data", scope: !93, file: !6, line: 578, baseType: !62, size: 32, offset: 736)
!160 = !DIDerivedType(tag: DW_TAG_member, name: "fn_abort", scope: !93, file: !6, line: 583, baseType: !161, size: 32, offset: 768)
!161 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !162, size: 32)
!162 = !DISubroutineType(types: !163)
!163 = !{null}
!164 = !DIDerivedType(tag: DW_TAG_member, name: "errno_var", scope: !93, file: !6, line: 610, baseType: !63, size: 32, offset: 800)
!165 = !DIDerivedType(tag: DW_TAG_member, name: "stack_info", scope: !93, file: !6, line: 616, baseType: !166, size: 96, offset: 832)
!166 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_stack_info", file: !6, line: 525, size: 96, elements: !167)
!167 = !{!168, !169, !172}
!168 = !DIDerivedType(tag: DW_TAG_member, name: "start", scope: !166, file: !6, line: 529, baseType: !60, size: 32)
!169 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !166, file: !6, line: 538, baseType: !170, size: 32, offset: 32)
!170 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !171, line: 46, baseType: !132)
!171 = !DIFile(filename: "/usr/lib/llvm-9/lib/clang/9.0.1/include/stddef.h", directory: "")
!172 = !DIDerivedType(tag: DW_TAG_member, name: "delta", scope: !166, file: !6, line: 544, baseType: !170, size: 32, offset: 64)
!173 = !DIDerivedType(tag: DW_TAG_member, name: "resource_pool", scope: !93, file: !6, line: 641, baseType: !174, size: 32, offset: 928)
!174 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !175, size: 32)
!175 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mem_pool", file: !176, line: 30, size: 32, elements: !177)
!176 = !DIFile(filename: "zephyrproject/zephyr/include/mempool_heap.h", directory: "/home/kenny")
!177 = !{!178}
!178 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !175, file: !176, line: 31, baseType: !179, size: 32)
!179 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !180, size: 32)
!180 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_heap", file: !72, line: 267, size: 160, elements: !181)
!181 = !{!182, !191, !192}
!182 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !180, file: !72, line: 268, baseType: !183, size: 96)
!183 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "sys_heap", file: !184, line: 51, size: 96, elements: !185)
!184 = !DIFile(filename: "zephyrproject/zephyr/include/sys/sys_heap.h", directory: "/home/kenny")
!185 = !{!186, !189, !190}
!186 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !183, file: !184, line: 52, baseType: !187, size: 32)
!187 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !188, size: 32)
!188 = !DICompositeType(tag: DW_TAG_structure_type, name: "z_heap", file: !184, line: 52, flags: DIFlagFwdDecl)
!189 = !DIDerivedType(tag: DW_TAG_member, name: "init_mem", scope: !183, file: !184, line: 53, baseType: !62, size: 32, offset: 32)
!190 = !DIDerivedType(tag: DW_TAG_member, name: "init_bytes", scope: !183, file: !184, line: 54, baseType: !170, size: 32, offset: 64)
!191 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !180, file: !72, line: 269, baseType: !71, size: 64, offset: 96)
!192 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !180, file: !72, line: 270, baseType: !193, offset: 160)
!193 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_spinlock", file: !72, line: 234, elements: !194)
!194 = !{}
!195 = !DIDerivedType(tag: DW_TAG_member, name: "arch", scope: !93, file: !6, line: 644, baseType: !196, size: 64, offset: 960)
!196 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_arch", file: !148, line: 60, size: 64, elements: !197)
!197 = !{!198, !199}
!198 = !DIDerivedType(tag: DW_TAG_member, name: "basepri", scope: !196, file: !148, line: 63, baseType: !131, size: 32)
!199 = !DIDerivedType(tag: DW_TAG_member, name: "swap_return_value", scope: !196, file: !148, line: 66, baseType: !131, size: 32, offset: 32)
!200 = !DIDerivedType(tag: DW_TAG_member, name: "lock_count", scope: !68, file: !6, line: 3596, baseType: !131, size: 32, offset: 96)
!201 = !DIDerivedType(tag: DW_TAG_member, name: "owner_orig_prio", scope: !68, file: !6, line: 3599, baseType: !63, size: 32, offset: 128)
!202 = !DIGlobalVariableExpression(var: !203, expr: !DIExpression())
!203 = distinct !DIGlobalVariable(name: "__isr_produce_work_isr_irq_2", scope: !204, file: !67, line: 46, type: !205, isLocal: true, isDefinition: true, align: 32)
!204 = distinct !DISubprogram(name: "main", scope: !67, file: !67, line: 36, type: !162, scopeLine: 36, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !194)
!205 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_isr_list", file: !206, line: 47, size: 128, elements: !207)
!206 = !DIFile(filename: "zephyrproject/zephyr/include/sw_isr_table.h", directory: "/home/kenny")
!207 = !{!208, !210, !211, !212}
!208 = !DIDerivedType(tag: DW_TAG_member, name: "irq", scope: !205, file: !206, line: 49, baseType: !209, size: 32)
!209 = !DIDerivedType(tag: DW_TAG_typedef, name: "int32_t", file: !56, line: 42, baseType: !63)
!210 = !DIDerivedType(tag: DW_TAG_member, name: "flags", scope: !205, file: !206, line: 51, baseType: !209, size: 32, offset: 32)
!211 = !DIDerivedType(tag: DW_TAG_member, name: "func", scope: !205, file: !206, line: 53, baseType: !62, size: 32, offset: 64)
!212 = !DIDerivedType(tag: DW_TAG_member, name: "param", scope: !205, file: !206, line: 55, baseType: !213, size: 32, offset: 96)
!213 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !214, size: 32)
!214 = !DIDerivedType(tag: DW_TAG_const_type, baseType: null)
!215 = !DIGlobalVariableExpression(var: !216, expr: !DIExpression())
!216 = distinct !DIGlobalVariable(name: "worker_stack_area", scope: !2, file: !67, line: 10, type: !217, isLocal: false, isDefinition: true, align: 64)
!217 = !DICompositeType(tag: DW_TAG_array_type, baseType: !218, size: 8192, elements: !223)
!218 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "z_thread_stack_element", file: !219, line: 35, size: 8, elements: !220)
!219 = !DIFile(filename: "zephyrproject/zephyr/include/sys/thread_stack.h", directory: "/home/kenny")
!220 = !{!221}
!221 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !218, file: !219, line: 36, baseType: !222, size: 8)
!222 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_unsigned_char)
!223 = !{!224}
!224 = !DISubrange(count: 1024)
!225 = !DIGlobalVariableExpression(var: !226, expr: !DIExpression())
!226 = distinct !DIGlobalVariable(name: "worker", scope: !2, file: !67, line: 11, type: !93, isLocal: false, isDefinition: true)
!227 = !DIGlobalVariableExpression(var: !228, expr: !DIExpression())
!228 = distinct !DIGlobalVariable(name: "_k_stack_buf_work", scope: !2, file: !67, line: 13, type: !229, isLocal: false, isDefinition: true)
!229 = !DICompositeType(tag: DW_TAG_array_type, baseType: !59, size: 8192, elements: !230)
!230 = !{!231}
!231 = !DISubrange(count: 256)
!232 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_stack", file: !6, line: 2895, size: 192, elements: !233)
!233 = !{!234, !235, !236, !237, !238, !239}
!234 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !232, file: !6, line: 2896, baseType: !71, size: 64)
!235 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !232, file: !6, line: 2897, baseType: !193, offset: 64)
!236 = !DIDerivedType(tag: DW_TAG_member, name: "base", scope: !232, file: !6, line: 2898, baseType: !58, size: 32, offset: 64)
!237 = !DIDerivedType(tag: DW_TAG_member, name: "next", scope: !232, file: !6, line: 2898, baseType: !58, size: 32, offset: 96)
!238 = !DIDerivedType(tag: DW_TAG_member, name: "top", scope: !232, file: !6, line: 2898, baseType: !58, size: 32, offset: 128)
!239 = !DIDerivedType(tag: DW_TAG_member, name: "flags", scope: !232, file: !6, line: 2902, baseType: !115, size: 8, offset: 160)
!240 = !{!"clang version 9.0.1-12 "}
!241 = !{i32 2, !"Dwarf Version", i32 4}
!242 = !{i32 2, !"Debug Info Version", i32 3}
!243 = !{i32 1, !"wchar_size", i32 4}
!244 = !{i32 1, !"min_enum_size", i32 1}
!245 = distinct !DISubprogram(name: "produce_work_isr", scope: !67, file: !67, line: 28, type: !246, scopeLine: 28, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !194)
!246 = !DISubroutineType(types: !247)
!247 = !{null, !213}
!248 = !DILocalVariable(name: "args", arg: 1, scope: !245, file: !67, line: 28, type: !213)
!249 = !DILocation(line: 28, column: 35, scope: !245)
!250 = !DILocation(line: 30, column: 26, scope: !245)
!251 = !DILocation(line: 30, column: 5, scope: !245)
!252 = !DILocation(line: 31, column: 5, scope: !245)
!253 = !DILocation(line: 32, column: 5, scope: !245)
!254 = !DILocation(line: 33, column: 1, scope: !245)
!255 = distinct !DISubprogram(name: "k_mutex_lock", scope: !256, file: !256, line: 705, type: !257, scopeLine: 706, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !194)
!256 = !DIFile(filename: "zephyr/include/generated/syscalls/kernel.h", directory: "/home/kenny/ara/build/appl/Zephyr/static_isr")
!257 = !DISubroutineType(types: !258)
!258 = !{!63, !259, !260}
!259 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !68, size: 32)
!260 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_timeout_t", file: !54, line: 69, baseType: !261)
!261 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !54, line: 67, size: 64, elements: !262)
!262 = !{!263}
!263 = !DIDerivedType(tag: DW_TAG_member, name: "ticks", scope: !261, file: !54, line: 68, baseType: !53, size: 64)
!264 = !DILocalVariable(name: "mutex", arg: 1, scope: !255, file: !256, line: 705, type: !259)
!265 = !DILocation(line: 705, column: 67, scope: !255)
!266 = !DILocalVariable(name: "timeout", arg: 2, scope: !255, file: !256, line: 705, type: !260)
!267 = !DILocation(line: 705, column: 86, scope: !255)
!268 = !DILocation(line: 714, column: 2, scope: !255)
!269 = !DILocation(line: 714, column: 2, scope: !270)
!270 = distinct !DILexicalBlock(scope: !255, file: !256, line: 714, column: 2)
!271 = !{i32 -2141854947}
!272 = !DILocation(line: 715, column: 29, scope: !255)
!273 = !DILocation(line: 715, column: 9, scope: !255)
!274 = !DILocation(line: 715, column: 2, scope: !255)
!275 = distinct !DISubprogram(name: "k_stack_push", scope: !256, file: !256, line: 664, type: !276, scopeLine: 665, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !194)
!276 = !DISubroutineType(types: !277)
!277 = !{!63, !278, !59}
!278 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !232, size: 32)
!279 = !DILocalVariable(name: "stack", arg: 1, scope: !275, file: !256, line: 664, type: !278)
!280 = !DILocation(line: 664, column: 67, scope: !275)
!281 = !DILocalVariable(name: "data", arg: 2, scope: !275, file: !256, line: 664, type: !59)
!282 = !DILocation(line: 664, column: 87, scope: !275)
!283 = !DILocation(line: 671, column: 2, scope: !275)
!284 = !DILocation(line: 671, column: 2, scope: !285)
!285 = distinct !DILexicalBlock(scope: !275, file: !256, line: 671, column: 2)
!286 = !{i32 -2141855151}
!287 = !DILocation(line: 672, column: 29, scope: !275)
!288 = !DILocation(line: 672, column: 36, scope: !275)
!289 = !DILocation(line: 672, column: 9, scope: !275)
!290 = !DILocation(line: 672, column: 2, scope: !275)
!291 = distinct !DISubprogram(name: "k_mutex_unlock", scope: !256, file: !256, line: 720, type: !292, scopeLine: 721, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !194)
!292 = !DISubroutineType(types: !293)
!293 = !{!63, !259}
!294 = !DILocalVariable(name: "mutex", arg: 1, scope: !291, file: !256, line: 720, type: !259)
!295 = !DILocation(line: 720, column: 69, scope: !291)
!296 = !DILocation(line: 727, column: 2, scope: !291)
!297 = !DILocation(line: 727, column: 2, scope: !298)
!298 = distinct !DILexicalBlock(scope: !291, file: !256, line: 727, column: 2)
!299 = !{i32 -2141854879}
!300 = !DILocation(line: 728, column: 31, scope: !291)
!301 = !DILocation(line: 728, column: 9, scope: !291)
!302 = !DILocation(line: 728, column: 2, scope: !291)
!303 = distinct !DISubprogram(name: "do_work", scope: !67, file: !67, line: 17, type: !304, scopeLine: 17, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !194)
!304 = !DISubroutineType(types: !305)
!305 = !{null, !62, !62, !62}
!306 = !DILocalVariable(name: "a", arg: 1, scope: !303, file: !67, line: 17, type: !62)
!307 = !DILocation(line: 17, column: 20, scope: !303)
!308 = !DILocalVariable(name: "b", arg: 2, scope: !303, file: !67, line: 17, type: !62)
!309 = !DILocation(line: 17, column: 29, scope: !303)
!310 = !DILocalVariable(name: "c", arg: 3, scope: !303, file: !67, line: 17, type: !62)
!311 = !DILocation(line: 17, column: 38, scope: !303)
!312 = !DILocalVariable(name: "done", scope: !303, file: !67, line: 18, type: !63)
!313 = !DILocation(line: 18, column: 9, scope: !303)
!314 = !DILocation(line: 19, column: 5, scope: !303)
!315 = !DILocalVariable(name: "w", scope: !316, file: !67, line: 20, type: !63)
!316 = distinct !DILexicalBlock(scope: !303, file: !67, line: 19, column: 17)
!317 = !DILocation(line: 20, column: 13, scope: !316)
!318 = !DILocation(line: 21, column: 30, scope: !316)
!319 = !DILocation(line: 21, column: 9, scope: !316)
!320 = !DILocation(line: 22, column: 43, scope: !316)
!321 = !DILocation(line: 22, column: 28, scope: !316)
!322 = !DILocation(line: 22, column: 46, scope: !316)
!323 = !DILocation(line: 22, column: 9, scope: !316)
!324 = !DILocation(line: 23, column: 9, scope: !316)
!325 = !DILocation(line: 24, column: 17, scope: !316)
!326 = !DILocation(line: 24, column: 14, scope: !316)
!327 = distinct !{!327, !314, !328}
!328 = !DILocation(line: 25, column: 5, scope: !303)
!329 = distinct !DISubprogram(name: "k_stack_pop", scope: !256, file: !256, line: 677, type: !330, scopeLine: 678, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !194)
!330 = !DISubroutineType(types: !331)
!331 = !{!63, !278, !58, !260}
!332 = !DILocalVariable(name: "stack", arg: 1, scope: !329, file: !256, line: 677, type: !278)
!333 = !DILocation(line: 677, column: 66, scope: !329)
!334 = !DILocalVariable(name: "data", arg: 2, scope: !329, file: !256, line: 677, type: !58)
!335 = !DILocation(line: 677, column: 88, scope: !329)
!336 = !DILocalVariable(name: "timeout", arg: 3, scope: !329, file: !256, line: 677, type: !260)
!337 = !DILocation(line: 677, column: 106, scope: !329)
!338 = !DILocation(line: 686, column: 2, scope: !329)
!339 = !DILocation(line: 686, column: 2, scope: !340)
!340 = distinct !DILexicalBlock(scope: !329, file: !256, line: 686, column: 2)
!341 = !{i32 -2141855083}
!342 = !DILocation(line: 687, column: 28, scope: !329)
!343 = !DILocation(line: 687, column: 35, scope: !329)
!344 = !DILocation(line: 687, column: 9, scope: !329)
!345 = !DILocation(line: 687, column: 2, scope: !329)
!346 = !DILocalVariable(name: "workerId", scope: !204, file: !67, line: 37, type: !347)
!347 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_tid_t", file: !6, line: 648, baseType: !92)
!348 = !DILocation(line: 37, column: 13, scope: !204)
!349 = !DILocation(line: 38, column: 60, scope: !204)
!350 = !DILocation(line: 37, column: 24, scope: !204)
!351 = !DILocation(line: 40, column: 5, scope: !204)
!352 = !DILocation(line: 41, column: 30, scope: !353)
!353 = distinct !DILexicalBlock(scope: !204, file: !67, line: 40, column: 17)
!354 = !DILocation(line: 41, column: 9, scope: !353)
!355 = !DILocation(line: 42, column: 9, scope: !353)
!356 = !DILocation(line: 43, column: 9, scope: !353)
!357 = distinct !{!357, !351, !358}
!358 = !DILocation(line: 44, column: 5, scope: !204)
!359 = distinct !DISubprogram(name: "k_thread_create", scope: !256, file: !256, line: 66, type: !360, scopeLine: 67, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !194)
!360 = !DISubroutineType(types: !361)
!361 = !{!347, !92, !362, !170, !365, !62, !62, !62, !63, !131, !260}
!362 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !363, size: 32)
!363 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_stack_t", file: !364, line: 44, baseType: !218)
!364 = !DIFile(filename: "zephyrproject/zephyr/include/sys/arch_interface.h", directory: "/home/kenny")
!365 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_entry_t", file: !364, line: 46, baseType: !366)
!366 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !304, size: 32)
!367 = !DILocalVariable(name: "new_thread", arg: 1, scope: !359, file: !256, line: 66, type: !92)
!368 = !DILocation(line: 66, column: 75, scope: !359)
!369 = !DILocalVariable(name: "stack", arg: 2, scope: !359, file: !256, line: 66, type: !362)
!370 = !DILocation(line: 66, column: 106, scope: !359)
!371 = !DILocalVariable(name: "stack_size", arg: 3, scope: !359, file: !256, line: 66, type: !170)
!372 = !DILocation(line: 66, column: 120, scope: !359)
!373 = !DILocalVariable(name: "entry", arg: 4, scope: !359, file: !256, line: 66, type: !365)
!374 = !DILocation(line: 66, column: 149, scope: !359)
!375 = !DILocalVariable(name: "p1", arg: 5, scope: !359, file: !256, line: 66, type: !62)
!376 = !DILocation(line: 66, column: 163, scope: !359)
!377 = !DILocalVariable(name: "p2", arg: 6, scope: !359, file: !256, line: 66, type: !62)
!378 = !DILocation(line: 66, column: 174, scope: !359)
!379 = !DILocalVariable(name: "p3", arg: 7, scope: !359, file: !256, line: 66, type: !62)
!380 = !DILocation(line: 66, column: 185, scope: !359)
!381 = !DILocalVariable(name: "prio", arg: 8, scope: !359, file: !256, line: 66, type: !63)
!382 = !DILocation(line: 66, column: 193, scope: !359)
!383 = !DILocalVariable(name: "options", arg: 9, scope: !359, file: !256, line: 66, type: !131)
!384 = !DILocation(line: 66, column: 208, scope: !359)
!385 = !DILocalVariable(name: "delay", arg: 10, scope: !359, file: !256, line: 66, type: !260)
!386 = !DILocation(line: 66, column: 229, scope: !359)
!387 = !DILocation(line: 83, column: 2, scope: !359)
!388 = !DILocation(line: 83, column: 2, scope: !389)
!389 = distinct !DILexicalBlock(scope: !359, file: !256, line: 83, column: 2)
!390 = !{i32 -2141858087}
!391 = !DILocation(line: 84, column: 32, scope: !359)
!392 = !DILocation(line: 84, column: 44, scope: !359)
!393 = !DILocation(line: 84, column: 51, scope: !359)
!394 = !DILocation(line: 84, column: 63, scope: !359)
!395 = !DILocation(line: 84, column: 70, scope: !359)
!396 = !DILocation(line: 84, column: 74, scope: !359)
!397 = !DILocation(line: 84, column: 78, scope: !359)
!398 = !DILocation(line: 84, column: 82, scope: !359)
!399 = !DILocation(line: 84, column: 88, scope: !359)
!400 = !DILocation(line: 84, column: 9, scope: !359)
!401 = !DILocation(line: 84, column: 2, scope: !359)
