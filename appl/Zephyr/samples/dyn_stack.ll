; ModuleID = 'llvm-link'
source_filename = "llvm-link"
target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "thumbv7em-none-unknown-eabi"

%struct.k_mutex = type { %struct._wait_q_t, %struct.k_thread*, i32, i32 }
%struct._wait_q_t = type { %struct._dnode }
%struct._dnode = type { %union.anon.0, %union.anon.0 }
%union.anon.0 = type { %struct._dnode* }
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
%struct.k_stack = type { %struct._wait_q_t, %struct.k_spinlock, i32*, i32*, i32*, i8 }
%struct.z_thread_stack_element = type { i8 }
%struct.k_timeout_t = type { i64 }

@guard = dso_local global %struct.k_mutex zeroinitializer, align 4, !dbg !0
@work = dso_local global %struct.k_stack zeroinitializer, align 4, !dbg !205
@worker = dso_local global %struct.k_thread zeroinitializer, align 8, !dbg !76
@worker_stack_area = dso_local global [1024 x %struct.z_thread_stack_element] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/dyn_stack/src/main.c\22.0", align 8, !dbg !65

; Function Attrs: noinline nounwind optnone
define dso_local void @do_work(i8*, i8*, i8*) #0 !dbg !227 {
  %4 = alloca i8*, align 4
  %5 = alloca i8*, align 4
  %6 = alloca i8*, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca %struct.k_timeout_t, align 8
  %10 = alloca %struct.k_timeout_t, align 8
  store i8* %0, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !230, metadata !DIExpression()), !dbg !231
  store i8* %1, i8** %5, align 4
  call void @llvm.dbg.declare(metadata i8** %5, metadata !232, metadata !DIExpression()), !dbg !233
  store i8* %2, i8** %6, align 4
  call void @llvm.dbg.declare(metadata i8** %6, metadata !234, metadata !DIExpression()), !dbg !235
  call void @llvm.dbg.declare(metadata i32* %7, metadata !236, metadata !DIExpression()), !dbg !237
  store i32 0, i32* %7, align 4, !dbg !237
  br label %11, !dbg !238

11:                                               ; preds = %11, %3
  call void @llvm.dbg.declare(metadata i32* %8, metadata !239, metadata !DIExpression()), !dbg !241
  store i32 0, i32* %8, align 4, !dbg !241
  %12 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %9, i32 0, i32 0, !dbg !242
  store i64 -1, i64* %12, align 8, !dbg !242
  %13 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %9, i32 0, i32 0, !dbg !243
  %14 = bitcast i64* %13 to [1 x i64]*, !dbg !243
  %15 = load [1 x i64], [1 x i64]* %14, align 8, !dbg !243
  %16 = call i32 @k_mutex_lock(%struct.k_mutex* @guard, [1 x i64] %15) #3, !dbg !243
  %17 = load i32, i32* %8, align 4, !dbg !244
  %18 = inttoptr i32 %17 to i32*, !dbg !245
  %19 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %10, i32 0, i32 0, !dbg !246
  store i64 0, i64* %19, align 8, !dbg !246
  %20 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %10, i32 0, i32 0, !dbg !247
  %21 = bitcast i64* %20 to [1 x i64]*, !dbg !247
  %22 = load [1 x i64], [1 x i64]* %21, align 8, !dbg !247
  %23 = call i32 @k_stack_pop(%struct.k_stack* @work, i32* %18, [1 x i64] %22) #3, !dbg !247
  %24 = call i32 @k_mutex_unlock(%struct.k_mutex* @guard) #3, !dbg !248
  %25 = load i32, i32* %8, align 4, !dbg !249
  %26 = load i32, i32* %7, align 4, !dbg !250
  %27 = add i32 %26, %25, !dbg !250
  store i32 %27, i32* %7, align 4, !dbg !250
  br label %11, !dbg !238, !llvm.loop !251
}

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: noinline nounwind optnone
define internal i32 @k_mutex_lock(%struct.k_mutex*, [1 x i64]) #0 !dbg !253 {
  %3 = alloca %struct.k_timeout_t, align 8
  %4 = alloca %struct.k_mutex*, align 4
  %5 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0
  %6 = bitcast i64* %5 to [1 x i64]*
  store [1 x i64] %1, [1 x i64]* %6, align 8
  store %struct.k_mutex* %0, %struct.k_mutex** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.k_mutex** %4, metadata !262, metadata !DIExpression()), !dbg !263
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %3, metadata !264, metadata !DIExpression()), !dbg !265
  br label %7, !dbg !266

7:                                                ; preds = %2
  call void asm sideeffect "", "~{memory}"() #4, !dbg !267, !srcloc !269
  br label %8, !dbg !267

8:                                                ; preds = %7
  %9 = load %struct.k_mutex*, %struct.k_mutex** %4, align 4, !dbg !270
  %10 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !271
  %11 = bitcast i64* %10 to [1 x i64]*, !dbg !271
  %12 = load [1 x i64], [1 x i64]* %11, align 8, !dbg !271
  %13 = call i32 @z_impl_k_mutex_lock(%struct.k_mutex* %9, [1 x i64] %12) #3, !dbg !271
  ret i32 %13, !dbg !272
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_stack_pop(%struct.k_stack*, i32*, [1 x i64]) #0 !dbg !273 {
  %4 = alloca %struct.k_timeout_t, align 8
  %5 = alloca %struct.k_stack*, align 4
  %6 = alloca i32*, align 4
  %7 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %4, i32 0, i32 0
  %8 = bitcast i64* %7 to [1 x i64]*
  store [1 x i64] %2, [1 x i64]* %8, align 8
  store %struct.k_stack* %0, %struct.k_stack** %5, align 4
  call void @llvm.dbg.declare(metadata %struct.k_stack** %5, metadata !277, metadata !DIExpression()), !dbg !278
  store i32* %1, i32** %6, align 4
  call void @llvm.dbg.declare(metadata i32** %6, metadata !279, metadata !DIExpression()), !dbg !280
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %4, metadata !281, metadata !DIExpression()), !dbg !282
  br label %9, !dbg !283

9:                                                ; preds = %3
  call void asm sideeffect "", "~{memory}"() #4, !dbg !284, !srcloc !286
  br label %10, !dbg !284

10:                                               ; preds = %9
  %11 = load %struct.k_stack*, %struct.k_stack** %5, align 4, !dbg !287
  %12 = load i32*, i32** %6, align 4, !dbg !288
  %13 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %4, i32 0, i32 0, !dbg !289
  %14 = bitcast i64* %13 to [1 x i64]*, !dbg !289
  %15 = load [1 x i64], [1 x i64]* %14, align 8, !dbg !289
  %16 = call i32 @z_impl_k_stack_pop(%struct.k_stack* %11, i32* %12, [1 x i64] %15) #3, !dbg !289
  ret i32 %16, !dbg !290
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

declare dso_local i32 @z_impl_k_stack_pop(%struct.k_stack*, i32*, [1 x i64]) #2

declare dso_local i32 @z_impl_k_mutex_lock(%struct.k_mutex*, [1 x i64]) #2

; Function Attrs: noinline nounwind optnone
define dso_local void @main() #0 !dbg !303 {
  %1 = alloca %struct.k_thread*, align 4
  %2 = alloca %struct.k_timeout_t, align 8
  %3 = alloca %struct.k_timeout_t, align 8
  call void @llvm.dbg.declare(metadata %struct.k_thread** %1, metadata !304, metadata !DIExpression()), !dbg !306
  %4 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !307
  store i64 -1, i64* %4, align 8, !dbg !307
  %5 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !308
  %6 = bitcast i64* %5 to [1 x i64]*, !dbg !308
  %7 = load [1 x i64], [1 x i64]* %6, align 8, !dbg !308
  %8 = call %struct.k_thread* @k_thread_create(%struct.k_thread* @worker, %struct.z_thread_stack_element* getelementptr inbounds ([1024 x %struct.z_thread_stack_element], [1024 x %struct.z_thread_stack_element]* @worker_stack_area, i32 0, i32 0), i32 1024, void (i8*, i8*, i8*)* @do_work, i8* null, i8* null, i8* null, i32 1, i32 0, [1 x i64] %7) #3, !dbg !308
  store %struct.k_thread* %8, %struct.k_thread** %1, align 4, !dbg !306
  %9 = call i32 @k_stack_alloc_init(%struct.k_stack* @work, i32 256) #3, !dbg !309
  %10 = call i32 @k_mutex_init(%struct.k_mutex* @guard) #3, !dbg !310
  br label %11, !dbg !311

11:                                               ; preds = %11, %0
  %12 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !312
  store i64 -1, i64* %12, align 8, !dbg !312
  %13 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !314
  %14 = bitcast i64* %13 to [1 x i64]*, !dbg !314
  %15 = load [1 x i64], [1 x i64]* %14, align 8, !dbg !314
  %16 = call i32 @k_mutex_lock(%struct.k_mutex* @guard, [1 x i64] %15) #3, !dbg !314
  %17 = call i32 @k_stack_push(%struct.k_stack* @work, i32 0) #3, !dbg !315
  %18 = call i32 @k_mutex_unlock(%struct.k_mutex* @guard) #3, !dbg !316
  br label %11, !dbg !311, !llvm.loop !317
}

; Function Attrs: noinline nounwind optnone
define internal %struct.k_thread* @k_thread_create(%struct.k_thread*, %struct.z_thread_stack_element*, i32, void (i8*, i8*, i8*)*, i8*, i8*, i8*, i32, i32, [1 x i64]) #0 !dbg !319 {
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
  call void @llvm.dbg.declare(metadata %struct.k_thread** %12, metadata !327, metadata !DIExpression()), !dbg !328
  store %struct.z_thread_stack_element* %1, %struct.z_thread_stack_element** %13, align 4
  call void @llvm.dbg.declare(metadata %struct.z_thread_stack_element** %13, metadata !329, metadata !DIExpression()), !dbg !330
  store i32 %2, i32* %14, align 4
  call void @llvm.dbg.declare(metadata i32* %14, metadata !331, metadata !DIExpression()), !dbg !332
  store void (i8*, i8*, i8*)* %3, void (i8*, i8*, i8*)** %15, align 4
  call void @llvm.dbg.declare(metadata void (i8*, i8*, i8*)** %15, metadata !333, metadata !DIExpression()), !dbg !334
  store i8* %4, i8** %16, align 4
  call void @llvm.dbg.declare(metadata i8** %16, metadata !335, metadata !DIExpression()), !dbg !336
  store i8* %5, i8** %17, align 4
  call void @llvm.dbg.declare(metadata i8** %17, metadata !337, metadata !DIExpression()), !dbg !338
  store i8* %6, i8** %18, align 4
  call void @llvm.dbg.declare(metadata i8** %18, metadata !339, metadata !DIExpression()), !dbg !340
  store i32 %7, i32* %19, align 4
  call void @llvm.dbg.declare(metadata i32* %19, metadata !341, metadata !DIExpression()), !dbg !342
  store i32 %8, i32* %20, align 4
  call void @llvm.dbg.declare(metadata i32* %20, metadata !343, metadata !DIExpression()), !dbg !344
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %11, metadata !345, metadata !DIExpression()), !dbg !346
  br label %23, !dbg !347

23:                                               ; preds = %10
  call void asm sideeffect "", "~{memory}"() #4, !dbg !348, !srcloc !350
  br label %24, !dbg !348

24:                                               ; preds = %23
  %25 = load %struct.k_thread*, %struct.k_thread** %12, align 4, !dbg !351
  %26 = load %struct.z_thread_stack_element*, %struct.z_thread_stack_element** %13, align 4, !dbg !352
  %27 = load i32, i32* %14, align 4, !dbg !353
  %28 = load void (i8*, i8*, i8*)*, void (i8*, i8*, i8*)** %15, align 4, !dbg !354
  %29 = load i8*, i8** %16, align 4, !dbg !355
  %30 = load i8*, i8** %17, align 4, !dbg !356
  %31 = load i8*, i8** %18, align 4, !dbg !357
  %32 = load i32, i32* %19, align 4, !dbg !358
  %33 = load i32, i32* %20, align 4, !dbg !359
  %34 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %11, i32 0, i32 0, !dbg !360
  %35 = bitcast i64* %34 to [1 x i64]*, !dbg !360
  %36 = load [1 x i64], [1 x i64]* %35, align 8, !dbg !360
  %37 = call %struct.k_thread* @z_impl_k_thread_create(%struct.k_thread* %25, %struct.z_thread_stack_element* %26, i32 %27, void (i8*, i8*, i8*)* %28, i8* %29, i8* %30, i8* %31, i32 %32, i32 %33, [1 x i64] %36) #3, !dbg !360
  ret %struct.k_thread* %37, !dbg !361
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_stack_alloc_init(%struct.k_stack*, i32) #0 !dbg !362 {
  %3 = alloca %struct.k_stack*, align 4
  %4 = alloca i32, align 4
  store %struct.k_stack* %0, %struct.k_stack** %3, align 4
  call void @llvm.dbg.declare(metadata %struct.k_stack** %3, metadata !366, metadata !DIExpression()), !dbg !367
  store i32 %1, i32* %4, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !368, metadata !DIExpression()), !dbg !369
  br label %5, !dbg !370

5:                                                ; preds = %2
  call void asm sideeffect "", "~{memory}"() #4, !dbg !371, !srcloc !373
  br label %6, !dbg !371

6:                                                ; preds = %5
  %7 = load %struct.k_stack*, %struct.k_stack** %3, align 4, !dbg !374
  %8 = load i32, i32* %4, align 4, !dbg !375
  %9 = call i32 @z_impl_k_stack_alloc_init(%struct.k_stack* %7, i32 %8) #3, !dbg !376
  ret i32 %9, !dbg !377
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_mutex_init(%struct.k_mutex*) #0 !dbg !378 {
  %2 = alloca %struct.k_mutex*, align 4
  store %struct.k_mutex* %0, %struct.k_mutex** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_mutex** %2, metadata !379, metadata !DIExpression()), !dbg !380
  br label %3, !dbg !381

3:                                                ; preds = %1
  call void asm sideeffect "", "~{memory}"() #4, !dbg !382, !srcloc !384
  br label %4, !dbg !382

4:                                                ; preds = %3
  %5 = load %struct.k_mutex*, %struct.k_mutex** %2, align 4, !dbg !385
  %6 = call i32 @z_impl_k_mutex_init(%struct.k_mutex* %5) #3, !dbg !386
  ret i32 %6, !dbg !387
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_stack_push(%struct.k_stack*, i32) #0 !dbg !388 {
  %3 = alloca %struct.k_stack*, align 4
  %4 = alloca i32, align 4
  store %struct.k_stack* %0, %struct.k_stack** %3, align 4
  call void @llvm.dbg.declare(metadata %struct.k_stack** %3, metadata !391, metadata !DIExpression()), !dbg !392
  store i32 %1, i32* %4, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !393, metadata !DIExpression()), !dbg !394
  br label %5, !dbg !395

5:                                                ; preds = %2
  call void asm sideeffect "", "~{memory}"() #4, !dbg !396, !srcloc !398
  br label %6, !dbg !396

6:                                                ; preds = %5
  %7 = load %struct.k_stack*, %struct.k_stack** %3, align 4, !dbg !399
  %8 = load i32, i32* %4, align 4, !dbg !400
  %9 = call i32 @z_impl_k_stack_push(%struct.k_stack* %7, i32 %8) #3, !dbg !401
  ret i32 %9, !dbg !402
}

declare dso_local i32 @z_impl_k_stack_push(%struct.k_stack*, i32) #2

declare dso_local i32 @z_impl_k_mutex_init(%struct.k_mutex*) #2

declare dso_local i32 @z_impl_k_stack_alloc_init(%struct.k_stack*, i32) #2

declare dso_local %struct.k_thread* @z_impl_k_thread_create(%struct.k_thread*, %struct.z_thread_stack_element*, i32, void (i8*, i8*, i8*)*, i8*, i8*, i8*, i32, i32, [1 x i64]) #2

attributes #0 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #1 = { nounwind readnone speculatable }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #3 = { nobuiltin }
attributes #4 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.ident = !{!222}
!llvm.module.flags = !{!223, !224, !225, !226}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "guard", scope: !2, file: !67, line: 13, type: !215, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !52, globals: !64, nameTableKind: None)
!3 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/dyn_stack/src/main.c", directory: "/home/kenny/ara/build/appl/Zephyr/dyn_stack")
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
!52 = !{!53, !58, !62, !59, !63}
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
!64 = !{!65, !76, !205, !0}
!65 = !DIGlobalVariableExpression(var: !66, expr: !DIExpression())
!66 = distinct !DIGlobalVariable(name: "worker_stack_area", scope: !2, file: !67, line: 8, type: !68, isLocal: false, isDefinition: true, align: 64)
!67 = !DIFile(filename: "appl/Zephyr/dyn_stack/src/main.c", directory: "/home/kenny/ara")
!68 = !DICompositeType(tag: DW_TAG_array_type, baseType: !69, size: 8192, elements: !74)
!69 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "z_thread_stack_element", file: !70, line: 35, size: 8, elements: !71)
!70 = !DIFile(filename: "zephyrproject/zephyr/include/sys/thread_stack.h", directory: "/home/kenny")
!71 = !{!72}
!72 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !69, file: !70, line: 36, baseType: !73, size: 8)
!73 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_unsigned_char)
!74 = !{!75}
!75 = !DISubrange(count: 1024)
!76 = !DIGlobalVariableExpression(var: !77, expr: !DIExpression())
!77 = distinct !DIGlobalVariable(name: "worker", scope: !2, file: !67, line: 9, type: !78, isLocal: false, isDefinition: true)
!78 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_thread", file: !6, line: 570, size: 1024, elements: !79)
!79 = !{!80, !151, !164, !165, !169, !170, !178, !200}
!80 = !DIDerivedType(tag: DW_TAG_member, name: "base", scope: !78, file: !6, line: 572, baseType: !81, size: 448)
!81 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_base", file: !6, line: 441, size: 448, elements: !82)
!82 = !{!83, !111, !119, !121, !122, !135, !138, !139, !150}
!83 = !DIDerivedType(tag: DW_TAG_member, scope: !81, file: !6, line: 444, baseType: !84, size: 64)
!84 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !81, file: !6, line: 444, size: 64, elements: !85)
!85 = !{!86, !102}
!86 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_dlist", scope: !84, file: !6, line: 445, baseType: !87, size: 64)
!87 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dnode_t", file: !88, line: 43, baseType: !89)
!88 = !DIFile(filename: "zephyrproject/zephyr/include/sys/dlist.h", directory: "/home/kenny")
!89 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_dnode", file: !88, line: 31, size: 64, elements: !90)
!90 = !{!91, !97}
!91 = !DIDerivedType(tag: DW_TAG_member, scope: !89, file: !88, line: 32, baseType: !92, size: 32)
!92 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !89, file: !88, line: 32, size: 32, elements: !93)
!93 = !{!94, !96}
!94 = !DIDerivedType(tag: DW_TAG_member, name: "head", scope: !92, file: !88, line: 33, baseType: !95, size: 32)
!95 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !89, size: 32)
!96 = !DIDerivedType(tag: DW_TAG_member, name: "next", scope: !92, file: !88, line: 34, baseType: !95, size: 32)
!97 = !DIDerivedType(tag: DW_TAG_member, scope: !89, file: !88, line: 36, baseType: !98, size: 32, offset: 32)
!98 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !89, file: !88, line: 36, size: 32, elements: !99)
!99 = !{!100, !101}
!100 = !DIDerivedType(tag: DW_TAG_member, name: "tail", scope: !98, file: !88, line: 37, baseType: !95, size: 32)
!101 = !DIDerivedType(tag: DW_TAG_member, name: "prev", scope: !98, file: !88, line: 38, baseType: !95, size: 32)
!102 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_rb", scope: !84, file: !6, line: 446, baseType: !103, size: 64)
!103 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "rbnode", file: !104, line: 48, size: 64, elements: !105)
!104 = !DIFile(filename: "zephyrproject/zephyr/include/sys/rb.h", directory: "/home/kenny")
!105 = !{!106}
!106 = !DIDerivedType(tag: DW_TAG_member, name: "children", scope: !103, file: !104, line: 49, baseType: !107, size: 64)
!107 = !DICompositeType(tag: DW_TAG_array_type, baseType: !108, size: 64, elements: !109)
!108 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !103, size: 32)
!109 = !{!110}
!110 = !DISubrange(count: 2)
!111 = !DIDerivedType(tag: DW_TAG_member, name: "pended_on", scope: !81, file: !6, line: 452, baseType: !112, size: 32, offset: 64)
!112 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !113, size: 32)
!113 = !DIDerivedType(tag: DW_TAG_typedef, name: "_wait_q_t", file: !114, line: 210, baseType: !115)
!114 = !DIFile(filename: "zephyrproject/zephyr/include/kernel_structs.h", directory: "/home/kenny")
!115 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !114, line: 208, size: 64, elements: !116)
!116 = !{!117}
!117 = !DIDerivedType(tag: DW_TAG_member, name: "waitq", scope: !115, file: !114, line: 209, baseType: !118, size: 64)
!118 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dlist_t", file: !88, line: 42, baseType: !89)
!119 = !DIDerivedType(tag: DW_TAG_member, name: "user_options", scope: !81, file: !6, line: 455, baseType: !120, size: 8, offset: 96)
!120 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !56, line: 55, baseType: !7)
!121 = !DIDerivedType(tag: DW_TAG_member, name: "thread_state", scope: !81, file: !6, line: 458, baseType: !120, size: 8, offset: 104)
!122 = !DIDerivedType(tag: DW_TAG_member, scope: !81, file: !6, line: 474, baseType: !123, size: 16, offset: 112)
!123 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !81, file: !6, line: 474, size: 16, elements: !124)
!124 = !{!125, !132}
!125 = !DIDerivedType(tag: DW_TAG_member, scope: !123, file: !6, line: 475, baseType: !126, size: 16)
!126 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !123, file: !6, line: 475, size: 16, elements: !127)
!127 = !{!128, !131}
!128 = !DIDerivedType(tag: DW_TAG_member, name: "prio", scope: !126, file: !6, line: 480, baseType: !129, size: 8)
!129 = !DIDerivedType(tag: DW_TAG_typedef, name: "int8_t", file: !56, line: 40, baseType: !130)
!130 = !DIBasicType(name: "signed char", size: 8, encoding: DW_ATE_signed_char)
!131 = !DIDerivedType(tag: DW_TAG_member, name: "sched_locked", scope: !126, file: !6, line: 481, baseType: !120, size: 8, offset: 8)
!132 = !DIDerivedType(tag: DW_TAG_member, name: "preempt", scope: !123, file: !6, line: 484, baseType: !133, size: 16)
!133 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !56, line: 56, baseType: !134)
!134 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!135 = !DIDerivedType(tag: DW_TAG_member, name: "order_key", scope: !81, file: !6, line: 491, baseType: !136, size: 32, offset: 128)
!136 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !56, line: 57, baseType: !137)
!137 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!138 = !DIDerivedType(tag: DW_TAG_member, name: "swap_data", scope: !81, file: !6, line: 511, baseType: !62, size: 32, offset: 160)
!139 = !DIDerivedType(tag: DW_TAG_member, name: "timeout", scope: !81, file: !6, line: 515, baseType: !140, size: 192, offset: 192)
!140 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_timeout", file: !114, line: 221, size: 192, elements: !141)
!141 = !{!142, !143, !149}
!142 = !DIDerivedType(tag: DW_TAG_member, name: "node", scope: !140, file: !114, line: 222, baseType: !87, size: 64)
!143 = !DIDerivedType(tag: DW_TAG_member, name: "fn", scope: !140, file: !114, line: 223, baseType: !144, size: 32, offset: 64)
!144 = !DIDerivedType(tag: DW_TAG_typedef, name: "_timeout_func_t", file: !114, line: 219, baseType: !145)
!145 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !146, size: 32)
!146 = !DISubroutineType(types: !147)
!147 = !{null, !148}
!148 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !140, size: 32)
!149 = !DIDerivedType(tag: DW_TAG_member, name: "dticks", scope: !140, file: !114, line: 226, baseType: !55, size: 64, offset: 128)
!150 = !DIDerivedType(tag: DW_TAG_member, name: "join_waiters", scope: !81, file: !6, line: 518, baseType: !113, size: 64, offset: 384)
!151 = !DIDerivedType(tag: DW_TAG_member, name: "callee_saved", scope: !78, file: !6, line: 575, baseType: !152, size: 288, offset: 448)
!152 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_callee_saved", file: !153, line: 25, size: 288, elements: !154)
!153 = !DIFile(filename: "zephyrproject/zephyr/include/arch/arm/aarch32/thread.h", directory: "/home/kenny")
!154 = !{!155, !156, !157, !158, !159, !160, !161, !162, !163}
!155 = !DIDerivedType(tag: DW_TAG_member, name: "v1", scope: !152, file: !153, line: 26, baseType: !136, size: 32)
!156 = !DIDerivedType(tag: DW_TAG_member, name: "v2", scope: !152, file: !153, line: 27, baseType: !136, size: 32, offset: 32)
!157 = !DIDerivedType(tag: DW_TAG_member, name: "v3", scope: !152, file: !153, line: 28, baseType: !136, size: 32, offset: 64)
!158 = !DIDerivedType(tag: DW_TAG_member, name: "v4", scope: !152, file: !153, line: 29, baseType: !136, size: 32, offset: 96)
!159 = !DIDerivedType(tag: DW_TAG_member, name: "v5", scope: !152, file: !153, line: 30, baseType: !136, size: 32, offset: 128)
!160 = !DIDerivedType(tag: DW_TAG_member, name: "v6", scope: !152, file: !153, line: 31, baseType: !136, size: 32, offset: 160)
!161 = !DIDerivedType(tag: DW_TAG_member, name: "v7", scope: !152, file: !153, line: 32, baseType: !136, size: 32, offset: 192)
!162 = !DIDerivedType(tag: DW_TAG_member, name: "v8", scope: !152, file: !153, line: 33, baseType: !136, size: 32, offset: 224)
!163 = !DIDerivedType(tag: DW_TAG_member, name: "psp", scope: !152, file: !153, line: 34, baseType: !136, size: 32, offset: 256)
!164 = !DIDerivedType(tag: DW_TAG_member, name: "init_data", scope: !78, file: !6, line: 578, baseType: !62, size: 32, offset: 736)
!165 = !DIDerivedType(tag: DW_TAG_member, name: "fn_abort", scope: !78, file: !6, line: 583, baseType: !166, size: 32, offset: 768)
!166 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !167, size: 32)
!167 = !DISubroutineType(types: !168)
!168 = !{null}
!169 = !DIDerivedType(tag: DW_TAG_member, name: "errno_var", scope: !78, file: !6, line: 610, baseType: !63, size: 32, offset: 800)
!170 = !DIDerivedType(tag: DW_TAG_member, name: "stack_info", scope: !78, file: !6, line: 616, baseType: !171, size: 96, offset: 832)
!171 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_stack_info", file: !6, line: 525, size: 96, elements: !172)
!172 = !{!173, !174, !177}
!173 = !DIDerivedType(tag: DW_TAG_member, name: "start", scope: !171, file: !6, line: 529, baseType: !60, size: 32)
!174 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !171, file: !6, line: 538, baseType: !175, size: 32, offset: 32)
!175 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !176, line: 46, baseType: !137)
!176 = !DIFile(filename: "/usr/lib/llvm-9/lib/clang/9.0.1/include/stddef.h", directory: "")
!177 = !DIDerivedType(tag: DW_TAG_member, name: "delta", scope: !171, file: !6, line: 544, baseType: !175, size: 32, offset: 64)
!178 = !DIDerivedType(tag: DW_TAG_member, name: "resource_pool", scope: !78, file: !6, line: 641, baseType: !179, size: 32, offset: 928)
!179 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !180, size: 32)
!180 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mem_pool", file: !181, line: 30, size: 32, elements: !182)
!181 = !DIFile(filename: "zephyrproject/zephyr/include/mempool_heap.h", directory: "/home/kenny")
!182 = !{!183}
!183 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !180, file: !181, line: 31, baseType: !184, size: 32)
!184 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !185, size: 32)
!185 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_heap", file: !114, line: 267, size: 160, elements: !186)
!186 = !{!187, !196, !197}
!187 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !185, file: !114, line: 268, baseType: !188, size: 96)
!188 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "sys_heap", file: !189, line: 51, size: 96, elements: !190)
!189 = !DIFile(filename: "zephyrproject/zephyr/include/sys/sys_heap.h", directory: "/home/kenny")
!190 = !{!191, !194, !195}
!191 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !188, file: !189, line: 52, baseType: !192, size: 32)
!192 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !193, size: 32)
!193 = !DICompositeType(tag: DW_TAG_structure_type, name: "z_heap", file: !189, line: 52, flags: DIFlagFwdDecl)
!194 = !DIDerivedType(tag: DW_TAG_member, name: "init_mem", scope: !188, file: !189, line: 53, baseType: !62, size: 32, offset: 32)
!195 = !DIDerivedType(tag: DW_TAG_member, name: "init_bytes", scope: !188, file: !189, line: 54, baseType: !175, size: 32, offset: 64)
!196 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !185, file: !114, line: 269, baseType: !113, size: 64, offset: 96)
!197 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !185, file: !114, line: 270, baseType: !198, offset: 160)
!198 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_spinlock", file: !114, line: 234, elements: !199)
!199 = !{}
!200 = !DIDerivedType(tag: DW_TAG_member, name: "arch", scope: !78, file: !6, line: 644, baseType: !201, size: 64, offset: 960)
!201 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_arch", file: !153, line: 60, size: 64, elements: !202)
!202 = !{!203, !204}
!203 = !DIDerivedType(tag: DW_TAG_member, name: "basepri", scope: !201, file: !153, line: 63, baseType: !136, size: 32)
!204 = !DIDerivedType(tag: DW_TAG_member, name: "swap_return_value", scope: !201, file: !153, line: 66, baseType: !136, size: 32, offset: 32)
!205 = !DIGlobalVariableExpression(var: !206, expr: !DIExpression())
!206 = distinct !DIGlobalVariable(name: "work", scope: !2, file: !67, line: 11, type: !207, isLocal: false, isDefinition: true)
!207 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_stack", file: !6, line: 2895, size: 192, elements: !208)
!208 = !{!209, !210, !211, !212, !213, !214}
!209 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !207, file: !6, line: 2896, baseType: !113, size: 64)
!210 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !207, file: !6, line: 2897, baseType: !198, offset: 64)
!211 = !DIDerivedType(tag: DW_TAG_member, name: "base", scope: !207, file: !6, line: 2898, baseType: !58, size: 32, offset: 64)
!212 = !DIDerivedType(tag: DW_TAG_member, name: "next", scope: !207, file: !6, line: 2898, baseType: !58, size: 32, offset: 96)
!213 = !DIDerivedType(tag: DW_TAG_member, name: "top", scope: !207, file: !6, line: 2898, baseType: !58, size: 32, offset: 128)
!214 = !DIDerivedType(tag: DW_TAG_member, name: "flags", scope: !207, file: !6, line: 2902, baseType: !120, size: 8, offset: 160)
!215 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mutex", file: !6, line: 3589, size: 160, elements: !216)
!216 = !{!217, !218, !220, !221}
!217 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !215, file: !6, line: 3591, baseType: !113, size: 64)
!218 = !DIDerivedType(tag: DW_TAG_member, name: "owner", scope: !215, file: !6, line: 3593, baseType: !219, size: 32, offset: 64)
!219 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !78, size: 32)
!220 = !DIDerivedType(tag: DW_TAG_member, name: "lock_count", scope: !215, file: !6, line: 3596, baseType: !136, size: 32, offset: 96)
!221 = !DIDerivedType(tag: DW_TAG_member, name: "owner_orig_prio", scope: !215, file: !6, line: 3599, baseType: !63, size: 32, offset: 128)
!222 = !{!"clang version 9.0.1-12 "}
!223 = !{i32 2, !"Dwarf Version", i32 4}
!224 = !{i32 2, !"Debug Info Version", i32 3}
!225 = !{i32 1, !"wchar_size", i32 4}
!226 = !{i32 1, !"min_enum_size", i32 1}
!227 = distinct !DISubprogram(name: "do_work", scope: !67, file: !67, line: 15, type: !228, scopeLine: 15, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !199)
!228 = !DISubroutineType(types: !229)
!229 = !{null, !62, !62, !62}
!230 = !DILocalVariable(name: "a", arg: 1, scope: !227, file: !67, line: 15, type: !62)
!231 = !DILocation(line: 15, column: 20, scope: !227)
!232 = !DILocalVariable(name: "b", arg: 2, scope: !227, file: !67, line: 15, type: !62)
!233 = !DILocation(line: 15, column: 29, scope: !227)
!234 = !DILocalVariable(name: "c", arg: 3, scope: !227, file: !67, line: 15, type: !62)
!235 = !DILocation(line: 15, column: 38, scope: !227)
!236 = !DILocalVariable(name: "done", scope: !227, file: !67, line: 16, type: !63)
!237 = !DILocation(line: 16, column: 9, scope: !227)
!238 = !DILocation(line: 17, column: 5, scope: !227)
!239 = !DILocalVariable(name: "w", scope: !240, file: !67, line: 18, type: !63)
!240 = distinct !DILexicalBlock(scope: !227, file: !67, line: 17, column: 17)
!241 = !DILocation(line: 18, column: 13, scope: !240)
!242 = !DILocation(line: 19, column: 30, scope: !240)
!243 = !DILocation(line: 19, column: 9, scope: !240)
!244 = !DILocation(line: 20, column: 43, scope: !240)
!245 = !DILocation(line: 20, column: 28, scope: !240)
!246 = !DILocation(line: 20, column: 46, scope: !240)
!247 = !DILocation(line: 20, column: 9, scope: !240)
!248 = !DILocation(line: 21, column: 9, scope: !240)
!249 = !DILocation(line: 22, column: 17, scope: !240)
!250 = !DILocation(line: 22, column: 14, scope: !240)
!251 = distinct !{!251, !238, !252}
!252 = !DILocation(line: 23, column: 5, scope: !227)
!253 = distinct !DISubprogram(name: "k_mutex_lock", scope: !254, file: !254, line: 705, type: !255, scopeLine: 706, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !199)
!254 = !DIFile(filename: "zephyr/include/generated/syscalls/kernel.h", directory: "/home/kenny/ara/build/appl/Zephyr/dyn_stack")
!255 = !DISubroutineType(types: !256)
!256 = !{!63, !257, !258}
!257 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !215, size: 32)
!258 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_timeout_t", file: !54, line: 69, baseType: !259)
!259 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !54, line: 67, size: 64, elements: !260)
!260 = !{!261}
!261 = !DIDerivedType(tag: DW_TAG_member, name: "ticks", scope: !259, file: !54, line: 68, baseType: !53, size: 64)
!262 = !DILocalVariable(name: "mutex", arg: 1, scope: !253, file: !254, line: 705, type: !257)
!263 = !DILocation(line: 705, column: 67, scope: !253)
!264 = !DILocalVariable(name: "timeout", arg: 2, scope: !253, file: !254, line: 705, type: !258)
!265 = !DILocation(line: 705, column: 86, scope: !253)
!266 = !DILocation(line: 714, column: 2, scope: !253)
!267 = !DILocation(line: 714, column: 2, scope: !268)
!268 = distinct !DILexicalBlock(scope: !253, file: !254, line: 714, column: 2)
!269 = !{i32 -2141855262}
!270 = !DILocation(line: 715, column: 29, scope: !253)
!271 = !DILocation(line: 715, column: 9, scope: !253)
!272 = !DILocation(line: 715, column: 2, scope: !253)
!273 = distinct !DISubprogram(name: "k_stack_pop", scope: !254, file: !254, line: 677, type: !274, scopeLine: 678, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !199)
!274 = !DISubroutineType(types: !275)
!275 = !{!63, !276, !58, !258}
!276 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !207, size: 32)
!277 = !DILocalVariable(name: "stack", arg: 1, scope: !273, file: !254, line: 677, type: !276)
!278 = !DILocation(line: 677, column: 66, scope: !273)
!279 = !DILocalVariable(name: "data", arg: 2, scope: !273, file: !254, line: 677, type: !58)
!280 = !DILocation(line: 677, column: 88, scope: !273)
!281 = !DILocalVariable(name: "timeout", arg: 3, scope: !273, file: !254, line: 677, type: !258)
!282 = !DILocation(line: 677, column: 106, scope: !273)
!283 = !DILocation(line: 686, column: 2, scope: !273)
!284 = !DILocation(line: 686, column: 2, scope: !285)
!285 = distinct !DILexicalBlock(scope: !273, file: !254, line: 686, column: 2)
!286 = !{i32 -2141855398}
!287 = !DILocation(line: 687, column: 28, scope: !273)
!288 = !DILocation(line: 687, column: 35, scope: !273)
!289 = !DILocation(line: 687, column: 9, scope: !273)
!290 = !DILocation(line: 687, column: 2, scope: !273)
!291 = distinct !DISubprogram(name: "k_mutex_unlock", scope: !254, file: !254, line: 720, type: !292, scopeLine: 721, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !199)
!292 = !DISubroutineType(types: !293)
!293 = !{!63, !257}
!294 = !DILocalVariable(name: "mutex", arg: 1, scope: !291, file: !254, line: 720, type: !257)
!295 = !DILocation(line: 720, column: 69, scope: !291)
!296 = !DILocation(line: 727, column: 2, scope: !291)
!297 = !DILocation(line: 727, column: 2, scope: !298)
!298 = distinct !DILexicalBlock(scope: !291, file: !254, line: 727, column: 2)
!299 = !{i32 -2141855194}
!300 = !DILocation(line: 728, column: 31, scope: !291)
!301 = !DILocation(line: 728, column: 9, scope: !291)
!302 = !DILocation(line: 728, column: 2, scope: !291)
!303 = distinct !DISubprogram(name: "main", scope: !67, file: !67, line: 26, type: !167, scopeLine: 26, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !199)
!304 = !DILocalVariable(name: "workerId", scope: !303, file: !67, line: 27, type: !305)
!305 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_tid_t", file: !6, line: 648, baseType: !219)
!306 = !DILocation(line: 27, column: 13, scope: !303)
!307 = !DILocation(line: 28, column: 60, scope: !303)
!308 = !DILocation(line: 27, column: 24, scope: !303)
!309 = !DILocation(line: 30, column: 5, scope: !303)
!310 = !DILocation(line: 31, column: 5, scope: !303)
!311 = !DILocation(line: 33, column: 5, scope: !303)
!312 = !DILocation(line: 34, column: 30, scope: !313)
!313 = distinct !DILexicalBlock(scope: !303, file: !67, line: 33, column: 17)
!314 = !DILocation(line: 34, column: 9, scope: !313)
!315 = !DILocation(line: 35, column: 9, scope: !313)
!316 = !DILocation(line: 36, column: 9, scope: !313)
!317 = distinct !{!317, !311, !318}
!318 = !DILocation(line: 37, column: 5, scope: !303)
!319 = distinct !DISubprogram(name: "k_thread_create", scope: !254, file: !254, line: 66, type: !320, scopeLine: 67, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !199)
!320 = !DISubroutineType(types: !321)
!321 = !{!305, !219, !322, !175, !325, !62, !62, !62, !63, !136, !258}
!322 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !323, size: 32)
!323 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_stack_t", file: !324, line: 44, baseType: !69)
!324 = !DIFile(filename: "zephyrproject/zephyr/include/sys/arch_interface.h", directory: "/home/kenny")
!325 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_entry_t", file: !324, line: 46, baseType: !326)
!326 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !228, size: 32)
!327 = !DILocalVariable(name: "new_thread", arg: 1, scope: !319, file: !254, line: 66, type: !219)
!328 = !DILocation(line: 66, column: 75, scope: !319)
!329 = !DILocalVariable(name: "stack", arg: 2, scope: !319, file: !254, line: 66, type: !322)
!330 = !DILocation(line: 66, column: 106, scope: !319)
!331 = !DILocalVariable(name: "stack_size", arg: 3, scope: !319, file: !254, line: 66, type: !175)
!332 = !DILocation(line: 66, column: 120, scope: !319)
!333 = !DILocalVariable(name: "entry", arg: 4, scope: !319, file: !254, line: 66, type: !325)
!334 = !DILocation(line: 66, column: 149, scope: !319)
!335 = !DILocalVariable(name: "p1", arg: 5, scope: !319, file: !254, line: 66, type: !62)
!336 = !DILocation(line: 66, column: 163, scope: !319)
!337 = !DILocalVariable(name: "p2", arg: 6, scope: !319, file: !254, line: 66, type: !62)
!338 = !DILocation(line: 66, column: 174, scope: !319)
!339 = !DILocalVariable(name: "p3", arg: 7, scope: !319, file: !254, line: 66, type: !62)
!340 = !DILocation(line: 66, column: 185, scope: !319)
!341 = !DILocalVariable(name: "prio", arg: 8, scope: !319, file: !254, line: 66, type: !63)
!342 = !DILocation(line: 66, column: 193, scope: !319)
!343 = !DILocalVariable(name: "options", arg: 9, scope: !319, file: !254, line: 66, type: !136)
!344 = !DILocation(line: 66, column: 208, scope: !319)
!345 = !DILocalVariable(name: "delay", arg: 10, scope: !319, file: !254, line: 66, type: !258)
!346 = !DILocation(line: 66, column: 229, scope: !319)
!347 = !DILocation(line: 83, column: 2, scope: !319)
!348 = !DILocation(line: 83, column: 2, scope: !349)
!349 = distinct !DILexicalBlock(scope: !319, file: !254, line: 83, column: 2)
!350 = !{i32 -2141858402}
!351 = !DILocation(line: 84, column: 32, scope: !319)
!352 = !DILocation(line: 84, column: 44, scope: !319)
!353 = !DILocation(line: 84, column: 51, scope: !319)
!354 = !DILocation(line: 84, column: 63, scope: !319)
!355 = !DILocation(line: 84, column: 70, scope: !319)
!356 = !DILocation(line: 84, column: 74, scope: !319)
!357 = !DILocation(line: 84, column: 78, scope: !319)
!358 = !DILocation(line: 84, column: 82, scope: !319)
!359 = !DILocation(line: 84, column: 88, scope: !319)
!360 = !DILocation(line: 84, column: 9, scope: !319)
!361 = !DILocation(line: 84, column: 2, scope: !319)
!362 = distinct !DISubprogram(name: "k_stack_alloc_init", scope: !254, file: !254, line: 651, type: !363, scopeLine: 652, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !199)
!363 = !DISubroutineType(types: !364)
!364 = !{!365, !276, !136}
!365 = !DIDerivedType(tag: DW_TAG_typedef, name: "int32_t", file: !56, line: 42, baseType: !63)
!366 = !DILocalVariable(name: "stack", arg: 1, scope: !362, file: !254, line: 651, type: !276)
!367 = !DILocation(line: 651, column: 77, scope: !362)
!368 = !DILocalVariable(name: "num_entries", arg: 2, scope: !362, file: !254, line: 651, type: !136)
!369 = !DILocation(line: 651, column: 93, scope: !362)
!370 = !DILocation(line: 658, column: 2, scope: !362)
!371 = !DILocation(line: 658, column: 2, scope: !372)
!372 = distinct !DILexicalBlock(scope: !362, file: !254, line: 658, column: 2)
!373 = !{i32 -2141855534}
!374 = !DILocation(line: 659, column: 35, scope: !362)
!375 = !DILocation(line: 659, column: 42, scope: !362)
!376 = !DILocation(line: 659, column: 9, scope: !362)
!377 = !DILocation(line: 659, column: 2, scope: !362)
!378 = distinct !DISubprogram(name: "k_mutex_init", scope: !254, file: !254, line: 692, type: !292, scopeLine: 693, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !199)
!379 = !DILocalVariable(name: "mutex", arg: 1, scope: !378, file: !254, line: 692, type: !257)
!380 = !DILocation(line: 692, column: 67, scope: !378)
!381 = !DILocation(line: 699, column: 2, scope: !378)
!382 = !DILocation(line: 699, column: 2, scope: !383)
!383 = distinct !DILexicalBlock(scope: !378, file: !254, line: 699, column: 2)
!384 = !{i32 -2141855330}
!385 = !DILocation(line: 700, column: 29, scope: !378)
!386 = !DILocation(line: 700, column: 9, scope: !378)
!387 = !DILocation(line: 700, column: 2, scope: !378)
!388 = distinct !DISubprogram(name: "k_stack_push", scope: !254, file: !254, line: 664, type: !389, scopeLine: 665, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !199)
!389 = !DISubroutineType(types: !390)
!390 = !{!63, !276, !59}
!391 = !DILocalVariable(name: "stack", arg: 1, scope: !388, file: !254, line: 664, type: !276)
!392 = !DILocation(line: 664, column: 67, scope: !388)
!393 = !DILocalVariable(name: "data", arg: 2, scope: !388, file: !254, line: 664, type: !59)
!394 = !DILocation(line: 664, column: 87, scope: !388)
!395 = !DILocation(line: 671, column: 2, scope: !388)
!396 = !DILocation(line: 671, column: 2, scope: !397)
!397 = distinct !DILexicalBlock(scope: !388, file: !254, line: 671, column: 2)
!398 = !{i32 -2141855466}
!399 = !DILocation(line: 672, column: 29, scope: !388)
!400 = !DILocation(line: 672, column: 36, scope: !388)
!401 = !DILocation(line: 672, column: 9, scope: !388)
!402 = !DILocation(line: 672, column: 2, scope: !388)
