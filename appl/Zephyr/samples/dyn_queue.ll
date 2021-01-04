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
%struct.k_lifo = type { %struct.k_queue }
%struct.k_queue = type { %struct._sflist, %struct.k_spinlock, %struct._wait_q_t }
%struct._sflist = type { %struct._sfnode*, %struct._sfnode* }
%struct._sfnode = type { i32 }
%struct.z_thread_stack_element = type { i8 }
%struct.k_timeout_t = type { i64 }
%struct.work_item = type { i8*, i32 }

@guard = dso_local global %struct.k_mutex zeroinitializer, align 4, !dbg !0
@work = dso_local global %struct.k_lifo zeroinitializer, align 4, !dbg !203
@worker = dso_local global %struct.k_thread zeroinitializer, align 8, !dbg !72
@worker_stack_area = dso_local global [1024 x %struct.z_thread_stack_element] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/dyn_queue/src/main.c\22.0", align 8, !dbg !61

; Function Attrs: noinline nounwind optnone
define dso_local void @do_work(i8*, i8*, i8*) #0 !dbg !237 {
  %4 = alloca i8*, align 4
  %5 = alloca i8*, align 4
  %6 = alloca i8*, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca %struct.k_timeout_t, align 8
  %10 = alloca %struct.work_item*, align 4
  %11 = alloca %struct.k_timeout_t, align 8
  store i8* %0, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !240, metadata !DIExpression()), !dbg !241
  store i8* %1, i8** %5, align 4
  call void @llvm.dbg.declare(metadata i8** %5, metadata !242, metadata !DIExpression()), !dbg !243
  store i8* %2, i8** %6, align 4
  call void @llvm.dbg.declare(metadata i8** %6, metadata !244, metadata !DIExpression()), !dbg !245
  call void @llvm.dbg.declare(metadata i32* %7, metadata !246, metadata !DIExpression()), !dbg !247
  store i32 0, i32* %7, align 4, !dbg !247
  br label %12, !dbg !248

12:                                               ; preds = %12, %3
  call void @llvm.dbg.declare(metadata i32* %8, metadata !249, metadata !DIExpression()), !dbg !251
  store i32 0, i32* %8, align 4, !dbg !251
  %13 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %9, i32 0, i32 0, !dbg !252
  store i64 -1, i64* %13, align 8, !dbg !252
  %14 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %9, i32 0, i32 0, !dbg !253
  %15 = bitcast i64* %14 to [1 x i64]*, !dbg !253
  %16 = load [1 x i64], [1 x i64]* %15, align 8, !dbg !253
  %17 = call i32 @k_mutex_lock(%struct.k_mutex* @guard, [1 x i64] %16) #4, !dbg !253
  call void @llvm.dbg.declare(metadata %struct.work_item** %10, metadata !254, metadata !DIExpression()), !dbg !260
  %18 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %11, i32 0, i32 0, !dbg !261
  store i64 0, i64* %18, align 8, !dbg !261
  %19 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %11, i32 0, i32 0, !dbg !261
  %20 = bitcast i64* %19 to [1 x i64]*, !dbg !261
  %21 = load [1 x i64], [1 x i64]* %20, align 8, !dbg !261
  %22 = call i8* @k_queue_get(%struct.k_queue* getelementptr inbounds (%struct.k_lifo, %struct.k_lifo* @work, i32 0, i32 0), [1 x i64] %21) #4, !dbg !261
  %23 = bitcast i8* %22 to %struct.work_item*, !dbg !261
  store %struct.work_item* %23, %struct.work_item** %10, align 4, !dbg !260
  %24 = call i32 @k_mutex_unlock(%struct.k_mutex* @guard) #4, !dbg !262
  %25 = load %struct.work_item*, %struct.work_item** %10, align 4, !dbg !263
  %26 = getelementptr inbounds %struct.work_item, %struct.work_item* %25, i32 0, i32 1, !dbg !264
  %27 = load i32, i32* %26, align 4, !dbg !264
  %28 = load i32, i32* %7, align 4, !dbg !265
  %29 = add i32 %28, %27, !dbg !265
  store i32 %29, i32* %7, align 4, !dbg !265
  br label %12, !dbg !248, !llvm.loop !266
}

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: noinline nounwind optnone
define internal i32 @k_mutex_lock(%struct.k_mutex*, [1 x i64]) #0 !dbg !268 {
  %3 = alloca %struct.k_timeout_t, align 8
  %4 = alloca %struct.k_mutex*, align 4
  %5 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0
  %6 = bitcast i64* %5 to [1 x i64]*
  store [1 x i64] %1, [1 x i64]* %6, align 8
  store %struct.k_mutex* %0, %struct.k_mutex** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.k_mutex** %4, metadata !277, metadata !DIExpression()), !dbg !278
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %3, metadata !279, metadata !DIExpression()), !dbg !280
  br label %7, !dbg !281

7:                                                ; preds = %2
  call void asm sideeffect "", "~{memory}"() #5, !dbg !282, !srcloc !284
  br label %8, !dbg !282

8:                                                ; preds = %7
  %9 = load %struct.k_mutex*, %struct.k_mutex** %4, align 4, !dbg !285
  %10 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !286
  %11 = bitcast i64* %10 to [1 x i64]*, !dbg !286
  %12 = load [1 x i64], [1 x i64]* %11, align 8, !dbg !286
  %13 = call i32 @z_impl_k_mutex_lock(%struct.k_mutex* %9, [1 x i64] %12) #4, !dbg !286
  ret i32 %13, !dbg !287
}

; Function Attrs: noinline nounwind optnone
define internal i8* @k_queue_get(%struct.k_queue*, [1 x i64]) #0 !dbg !288 {
  %3 = alloca %struct.k_timeout_t, align 8
  %4 = alloca %struct.k_queue*, align 4
  %5 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0
  %6 = bitcast i64* %5 to [1 x i64]*
  store [1 x i64] %1, [1 x i64]* %6, align 8
  store %struct.k_queue* %0, %struct.k_queue** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.k_queue** %4, metadata !292, metadata !DIExpression()), !dbg !293
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %3, metadata !294, metadata !DIExpression()), !dbg !295
  br label %7, !dbg !296

7:                                                ; preds = %2
  call void asm sideeffect "", "~{memory}"() #5, !dbg !297, !srcloc !299
  br label %8, !dbg !297

8:                                                ; preds = %7
  %9 = load %struct.k_queue*, %struct.k_queue** %4, align 4, !dbg !300
  %10 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !301
  %11 = bitcast i64* %10 to [1 x i64]*, !dbg !301
  %12 = load [1 x i64], [1 x i64]* %11, align 8, !dbg !301
  %13 = call i8* @z_impl_k_queue_get(%struct.k_queue* %9, [1 x i64] %12) #4, !dbg !301
  ret i8* %13, !dbg !302
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_mutex_unlock(%struct.k_mutex*) #0 !dbg !303 {
  %2 = alloca %struct.k_mutex*, align 4
  store %struct.k_mutex* %0, %struct.k_mutex** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_mutex** %2, metadata !306, metadata !DIExpression()), !dbg !307
  br label %3, !dbg !308

3:                                                ; preds = %1
  call void asm sideeffect "", "~{memory}"() #5, !dbg !309, !srcloc !311
  br label %4, !dbg !309

4:                                                ; preds = %3
  %5 = load %struct.k_mutex*, %struct.k_mutex** %2, align 4, !dbg !312
  %6 = call i32 @z_impl_k_mutex_unlock(%struct.k_mutex* %5) #4, !dbg !313
  ret i32 %6, !dbg !314
}

declare dso_local i32 @z_impl_k_mutex_unlock(%struct.k_mutex*) #2

declare dso_local i8* @z_impl_k_queue_get(%struct.k_queue*, [1 x i64]) #2

declare dso_local i32 @z_impl_k_mutex_lock(%struct.k_mutex*, [1 x i64]) #2

; Function Attrs: noinline nounwind optnone
define dso_local void @main() #0 !dbg !315 {
  %1 = alloca %struct.k_thread*, align 4
  %2 = alloca %struct.k_timeout_t, align 8
  %3 = alloca %struct.work_item, align 4
  %4 = alloca %struct.k_timeout_t, align 8
  call void @llvm.dbg.declare(metadata %struct.k_thread** %1, metadata !316, metadata !DIExpression()), !dbg !318
  %5 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !319
  store i64 -1, i64* %5, align 8, !dbg !319
  %6 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !320
  %7 = bitcast i64* %6 to [1 x i64]*, !dbg !320
  %8 = load [1 x i64], [1 x i64]* %7, align 8, !dbg !320
  %9 = call %struct.k_thread* @k_thread_create(%struct.k_thread* @worker, %struct.z_thread_stack_element* getelementptr inbounds ([1024 x %struct.z_thread_stack_element], [1024 x %struct.z_thread_stack_element]* @worker_stack_area, i32 0, i32 0), i32 1024, void (i8*, i8*, i8*)* @do_work, i8* null, i8* null, i8* null, i32 1, i32 0, [1 x i64] %8) #4, !dbg !320
  store %struct.k_thread* %9, %struct.k_thread** %1, align 4, !dbg !318
  call void @k_queue_init(%struct.k_queue* getelementptr inbounds (%struct.k_lifo, %struct.k_lifo* @work, i32 0, i32 0)) #4, !dbg !321
  %10 = call i32 @k_mutex_init(%struct.k_mutex* @guard) #4, !dbg !322
  br label %11, !dbg !323

11:                                               ; preds = %11, %0
  call void @llvm.dbg.declare(metadata %struct.work_item* %3, metadata !324, metadata !DIExpression()), !dbg !326
  %12 = bitcast %struct.work_item* %3 to i8*, !dbg !326
  call void @llvm.memset.p0i8.i32(i8* align 4 %12, i8 0, i32 8, i1 false), !dbg !326
  %13 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %4, i32 0, i32 0, !dbg !327
  store i64 -1, i64* %13, align 8, !dbg !327
  %14 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %4, i32 0, i32 0, !dbg !328
  %15 = bitcast i64* %14 to [1 x i64]*, !dbg !328
  %16 = load [1 x i64], [1 x i64]* %15, align 8, !dbg !328
  %17 = call i32 @k_mutex_lock(%struct.k_mutex* @guard, [1 x i64] %16) #4, !dbg !328
  %18 = bitcast %struct.work_item* %3 to i8*, !dbg !329
  call void @k_queue_prepend(%struct.k_queue* getelementptr inbounds (%struct.k_lifo, %struct.k_lifo* @work, i32 0, i32 0), i8* %18) #4, !dbg !329
  %19 = call i32 @k_mutex_unlock(%struct.k_mutex* @guard) #4, !dbg !330
  br label %11, !dbg !323, !llvm.loop !331
}

; Function Attrs: noinline nounwind optnone
define internal %struct.k_thread* @k_thread_create(%struct.k_thread*, %struct.z_thread_stack_element*, i32, void (i8*, i8*, i8*)*, i8*, i8*, i8*, i32, i32, [1 x i64]) #0 !dbg !333 {
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
  call void @llvm.dbg.declare(metadata %struct.k_thread** %12, metadata !341, metadata !DIExpression()), !dbg !342
  store %struct.z_thread_stack_element* %1, %struct.z_thread_stack_element** %13, align 4
  call void @llvm.dbg.declare(metadata %struct.z_thread_stack_element** %13, metadata !343, metadata !DIExpression()), !dbg !344
  store i32 %2, i32* %14, align 4
  call void @llvm.dbg.declare(metadata i32* %14, metadata !345, metadata !DIExpression()), !dbg !346
  store void (i8*, i8*, i8*)* %3, void (i8*, i8*, i8*)** %15, align 4
  call void @llvm.dbg.declare(metadata void (i8*, i8*, i8*)** %15, metadata !347, metadata !DIExpression()), !dbg !348
  store i8* %4, i8** %16, align 4
  call void @llvm.dbg.declare(metadata i8** %16, metadata !349, metadata !DIExpression()), !dbg !350
  store i8* %5, i8** %17, align 4
  call void @llvm.dbg.declare(metadata i8** %17, metadata !351, metadata !DIExpression()), !dbg !352
  store i8* %6, i8** %18, align 4
  call void @llvm.dbg.declare(metadata i8** %18, metadata !353, metadata !DIExpression()), !dbg !354
  store i32 %7, i32* %19, align 4
  call void @llvm.dbg.declare(metadata i32* %19, metadata !355, metadata !DIExpression()), !dbg !356
  store i32 %8, i32* %20, align 4
  call void @llvm.dbg.declare(metadata i32* %20, metadata !357, metadata !DIExpression()), !dbg !358
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %11, metadata !359, metadata !DIExpression()), !dbg !360
  br label %23, !dbg !361

23:                                               ; preds = %10
  call void asm sideeffect "", "~{memory}"() #5, !dbg !362, !srcloc !364
  br label %24, !dbg !362

24:                                               ; preds = %23
  %25 = load %struct.k_thread*, %struct.k_thread** %12, align 4, !dbg !365
  %26 = load %struct.z_thread_stack_element*, %struct.z_thread_stack_element** %13, align 4, !dbg !366
  %27 = load i32, i32* %14, align 4, !dbg !367
  %28 = load void (i8*, i8*, i8*)*, void (i8*, i8*, i8*)** %15, align 4, !dbg !368
  %29 = load i8*, i8** %16, align 4, !dbg !369
  %30 = load i8*, i8** %17, align 4, !dbg !370
  %31 = load i8*, i8** %18, align 4, !dbg !371
  %32 = load i32, i32* %19, align 4, !dbg !372
  %33 = load i32, i32* %20, align 4, !dbg !373
  %34 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %11, i32 0, i32 0, !dbg !374
  %35 = bitcast i64* %34 to [1 x i64]*, !dbg !374
  %36 = load [1 x i64], [1 x i64]* %35, align 8, !dbg !374
  %37 = call %struct.k_thread* @z_impl_k_thread_create(%struct.k_thread* %25, %struct.z_thread_stack_element* %26, i32 %27, void (i8*, i8*, i8*)* %28, i8* %29, i8* %30, i8* %31, i32 %32, i32 %33, [1 x i64] %36) #4, !dbg !374
  ret %struct.k_thread* %37, !dbg !375
}

; Function Attrs: noinline nounwind optnone
define internal void @k_queue_init(%struct.k_queue*) #0 !dbg !376 {
  %2 = alloca %struct.k_queue*, align 4
  store %struct.k_queue* %0, %struct.k_queue** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_queue** %2, metadata !379, metadata !DIExpression()), !dbg !380
  br label %3, !dbg !381

3:                                                ; preds = %1
  call void asm sideeffect "", "~{memory}"() #5, !dbg !382, !srcloc !384
  br label %4, !dbg !382

4:                                                ; preds = %3
  %5 = load %struct.k_queue*, %struct.k_queue** %2, align 4, !dbg !385
  call void @z_impl_k_queue_init(%struct.k_queue* %5) #4, !dbg !386
  ret void, !dbg !387
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_mutex_init(%struct.k_mutex*) #0 !dbg !388 {
  %2 = alloca %struct.k_mutex*, align 4
  store %struct.k_mutex* %0, %struct.k_mutex** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_mutex** %2, metadata !389, metadata !DIExpression()), !dbg !390
  br label %3, !dbg !391

3:                                                ; preds = %1
  call void asm sideeffect "", "~{memory}"() #5, !dbg !392, !srcloc !394
  br label %4, !dbg !392

4:                                                ; preds = %3
  %5 = load %struct.k_mutex*, %struct.k_mutex** %2, align 4, !dbg !395
  %6 = call i32 @z_impl_k_mutex_init(%struct.k_mutex* %5) #4, !dbg !396
  ret i32 %6, !dbg !397
}

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i32(i8* nocapture writeonly, i8, i32, i1 immarg) #3

declare dso_local void @k_queue_prepend(%struct.k_queue*, i8*) #2

declare dso_local i32 @z_impl_k_mutex_init(%struct.k_mutex*) #2

declare dso_local void @z_impl_k_queue_init(%struct.k_queue*) #2

declare dso_local %struct.k_thread* @z_impl_k_thread_create(%struct.k_thread*, %struct.z_thread_stack_element*, i32, void (i8*, i8*, i8*)*, i8*, i8*, i8*, i32, i32, [1 x i64]) #2

attributes #0 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #1 = { nounwind readnone speculatable }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #3 = { argmemonly nounwind }
attributes #4 = { nobuiltin }
attributes #5 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.ident = !{!232}
!llvm.module.flags = !{!233, !234, !235, !236}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "guard", scope: !2, file: !63, line: 17, type: !225, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !52, globals: !60, nameTableKind: None)
!3 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/dyn_queue/src/main.c", directory: "/home/kenny/ara/build/appl/Zephyr/dyn_queue")
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
!52 = !{!53, !58, !59}
!53 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_ticks_t", file: !54, line: 46, baseType: !55)
!54 = !DIFile(filename: "zephyrproject/zephyr/include/sys_clock.h", directory: "/home/kenny")
!55 = !DIDerivedType(tag: DW_TAG_typedef, name: "int64_t", file: !56, line: 43, baseType: !57)
!56 = !DIFile(filename: "zephyrproject/zephyr/lib/libc/minimal/include/stdint.h", directory: "/home/kenny")
!57 = !DIBasicType(name: "long long int", size: 64, encoding: DW_ATE_signed)
!58 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 32)
!59 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!60 = !{!61, !72, !203, !0}
!61 = !DIGlobalVariableExpression(var: !62, expr: !DIExpression())
!62 = distinct !DIGlobalVariable(name: "worker_stack_area", scope: !2, file: !63, line: 12, type: !64, isLocal: false, isDefinition: true, align: 64)
!63 = !DIFile(filename: "appl/Zephyr/dyn_queue/src/main.c", directory: "/home/kenny/ara")
!64 = !DICompositeType(tag: DW_TAG_array_type, baseType: !65, size: 8192, elements: !70)
!65 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "z_thread_stack_element", file: !66, line: 35, size: 8, elements: !67)
!66 = !DIFile(filename: "zephyrproject/zephyr/include/sys/thread_stack.h", directory: "/home/kenny")
!67 = !{!68}
!68 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !65, file: !66, line: 36, baseType: !69, size: 8)
!69 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_unsigned_char)
!70 = !{!71}
!71 = !DISubrange(count: 1024)
!72 = !DIGlobalVariableExpression(var: !73, expr: !DIExpression())
!73 = distinct !DIGlobalVariable(name: "worker", scope: !2, file: !63, line: 13, type: !74, isLocal: false, isDefinition: true)
!74 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_thread", file: !6, line: 570, size: 1024, elements: !75)
!75 = !{!76, !147, !160, !161, !165, !166, !176, !198}
!76 = !DIDerivedType(tag: DW_TAG_member, name: "base", scope: !74, file: !6, line: 572, baseType: !77, size: 448)
!77 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_base", file: !6, line: 441, size: 448, elements: !78)
!78 = !{!79, !107, !115, !117, !118, !131, !134, !135, !146}
!79 = !DIDerivedType(tag: DW_TAG_member, scope: !77, file: !6, line: 444, baseType: !80, size: 64)
!80 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !77, file: !6, line: 444, size: 64, elements: !81)
!81 = !{!82, !98}
!82 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_dlist", scope: !80, file: !6, line: 445, baseType: !83, size: 64)
!83 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dnode_t", file: !84, line: 43, baseType: !85)
!84 = !DIFile(filename: "zephyrproject/zephyr/include/sys/dlist.h", directory: "/home/kenny")
!85 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_dnode", file: !84, line: 31, size: 64, elements: !86)
!86 = !{!87, !93}
!87 = !DIDerivedType(tag: DW_TAG_member, scope: !85, file: !84, line: 32, baseType: !88, size: 32)
!88 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !85, file: !84, line: 32, size: 32, elements: !89)
!89 = !{!90, !92}
!90 = !DIDerivedType(tag: DW_TAG_member, name: "head", scope: !88, file: !84, line: 33, baseType: !91, size: 32)
!91 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !85, size: 32)
!92 = !DIDerivedType(tag: DW_TAG_member, name: "next", scope: !88, file: !84, line: 34, baseType: !91, size: 32)
!93 = !DIDerivedType(tag: DW_TAG_member, scope: !85, file: !84, line: 36, baseType: !94, size: 32, offset: 32)
!94 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !85, file: !84, line: 36, size: 32, elements: !95)
!95 = !{!96, !97}
!96 = !DIDerivedType(tag: DW_TAG_member, name: "tail", scope: !94, file: !84, line: 37, baseType: !91, size: 32)
!97 = !DIDerivedType(tag: DW_TAG_member, name: "prev", scope: !94, file: !84, line: 38, baseType: !91, size: 32)
!98 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_rb", scope: !80, file: !6, line: 446, baseType: !99, size: 64)
!99 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "rbnode", file: !100, line: 48, size: 64, elements: !101)
!100 = !DIFile(filename: "zephyrproject/zephyr/include/sys/rb.h", directory: "/home/kenny")
!101 = !{!102}
!102 = !DIDerivedType(tag: DW_TAG_member, name: "children", scope: !99, file: !100, line: 49, baseType: !103, size: 64)
!103 = !DICompositeType(tag: DW_TAG_array_type, baseType: !104, size: 64, elements: !105)
!104 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !99, size: 32)
!105 = !{!106}
!106 = !DISubrange(count: 2)
!107 = !DIDerivedType(tag: DW_TAG_member, name: "pended_on", scope: !77, file: !6, line: 452, baseType: !108, size: 32, offset: 64)
!108 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !109, size: 32)
!109 = !DIDerivedType(tag: DW_TAG_typedef, name: "_wait_q_t", file: !110, line: 210, baseType: !111)
!110 = !DIFile(filename: "zephyrproject/zephyr/include/kernel_structs.h", directory: "/home/kenny")
!111 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !110, line: 208, size: 64, elements: !112)
!112 = !{!113}
!113 = !DIDerivedType(tag: DW_TAG_member, name: "waitq", scope: !111, file: !110, line: 209, baseType: !114, size: 64)
!114 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dlist_t", file: !84, line: 42, baseType: !85)
!115 = !DIDerivedType(tag: DW_TAG_member, name: "user_options", scope: !77, file: !6, line: 455, baseType: !116, size: 8, offset: 96)
!116 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !56, line: 55, baseType: !7)
!117 = !DIDerivedType(tag: DW_TAG_member, name: "thread_state", scope: !77, file: !6, line: 458, baseType: !116, size: 8, offset: 104)
!118 = !DIDerivedType(tag: DW_TAG_member, scope: !77, file: !6, line: 474, baseType: !119, size: 16, offset: 112)
!119 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !77, file: !6, line: 474, size: 16, elements: !120)
!120 = !{!121, !128}
!121 = !DIDerivedType(tag: DW_TAG_member, scope: !119, file: !6, line: 475, baseType: !122, size: 16)
!122 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !119, file: !6, line: 475, size: 16, elements: !123)
!123 = !{!124, !127}
!124 = !DIDerivedType(tag: DW_TAG_member, name: "prio", scope: !122, file: !6, line: 480, baseType: !125, size: 8)
!125 = !DIDerivedType(tag: DW_TAG_typedef, name: "int8_t", file: !56, line: 40, baseType: !126)
!126 = !DIBasicType(name: "signed char", size: 8, encoding: DW_ATE_signed_char)
!127 = !DIDerivedType(tag: DW_TAG_member, name: "sched_locked", scope: !122, file: !6, line: 481, baseType: !116, size: 8, offset: 8)
!128 = !DIDerivedType(tag: DW_TAG_member, name: "preempt", scope: !119, file: !6, line: 484, baseType: !129, size: 16)
!129 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !56, line: 56, baseType: !130)
!130 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!131 = !DIDerivedType(tag: DW_TAG_member, name: "order_key", scope: !77, file: !6, line: 491, baseType: !132, size: 32, offset: 128)
!132 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !56, line: 57, baseType: !133)
!133 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!134 = !DIDerivedType(tag: DW_TAG_member, name: "swap_data", scope: !77, file: !6, line: 511, baseType: !58, size: 32, offset: 160)
!135 = !DIDerivedType(tag: DW_TAG_member, name: "timeout", scope: !77, file: !6, line: 515, baseType: !136, size: 192, offset: 192)
!136 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_timeout", file: !110, line: 221, size: 192, elements: !137)
!137 = !{!138, !139, !145}
!138 = !DIDerivedType(tag: DW_TAG_member, name: "node", scope: !136, file: !110, line: 222, baseType: !83, size: 64)
!139 = !DIDerivedType(tag: DW_TAG_member, name: "fn", scope: !136, file: !110, line: 223, baseType: !140, size: 32, offset: 64)
!140 = !DIDerivedType(tag: DW_TAG_typedef, name: "_timeout_func_t", file: !110, line: 219, baseType: !141)
!141 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !142, size: 32)
!142 = !DISubroutineType(types: !143)
!143 = !{null, !144}
!144 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !136, size: 32)
!145 = !DIDerivedType(tag: DW_TAG_member, name: "dticks", scope: !136, file: !110, line: 226, baseType: !55, size: 64, offset: 128)
!146 = !DIDerivedType(tag: DW_TAG_member, name: "join_waiters", scope: !77, file: !6, line: 518, baseType: !109, size: 64, offset: 384)
!147 = !DIDerivedType(tag: DW_TAG_member, name: "callee_saved", scope: !74, file: !6, line: 575, baseType: !148, size: 288, offset: 448)
!148 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_callee_saved", file: !149, line: 25, size: 288, elements: !150)
!149 = !DIFile(filename: "zephyrproject/zephyr/include/arch/arm/aarch32/thread.h", directory: "/home/kenny")
!150 = !{!151, !152, !153, !154, !155, !156, !157, !158, !159}
!151 = !DIDerivedType(tag: DW_TAG_member, name: "v1", scope: !148, file: !149, line: 26, baseType: !132, size: 32)
!152 = !DIDerivedType(tag: DW_TAG_member, name: "v2", scope: !148, file: !149, line: 27, baseType: !132, size: 32, offset: 32)
!153 = !DIDerivedType(tag: DW_TAG_member, name: "v3", scope: !148, file: !149, line: 28, baseType: !132, size: 32, offset: 64)
!154 = !DIDerivedType(tag: DW_TAG_member, name: "v4", scope: !148, file: !149, line: 29, baseType: !132, size: 32, offset: 96)
!155 = !DIDerivedType(tag: DW_TAG_member, name: "v5", scope: !148, file: !149, line: 30, baseType: !132, size: 32, offset: 128)
!156 = !DIDerivedType(tag: DW_TAG_member, name: "v6", scope: !148, file: !149, line: 31, baseType: !132, size: 32, offset: 160)
!157 = !DIDerivedType(tag: DW_TAG_member, name: "v7", scope: !148, file: !149, line: 32, baseType: !132, size: 32, offset: 192)
!158 = !DIDerivedType(tag: DW_TAG_member, name: "v8", scope: !148, file: !149, line: 33, baseType: !132, size: 32, offset: 224)
!159 = !DIDerivedType(tag: DW_TAG_member, name: "psp", scope: !148, file: !149, line: 34, baseType: !132, size: 32, offset: 256)
!160 = !DIDerivedType(tag: DW_TAG_member, name: "init_data", scope: !74, file: !6, line: 578, baseType: !58, size: 32, offset: 736)
!161 = !DIDerivedType(tag: DW_TAG_member, name: "fn_abort", scope: !74, file: !6, line: 583, baseType: !162, size: 32, offset: 768)
!162 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !163, size: 32)
!163 = !DISubroutineType(types: !164)
!164 = !{null}
!165 = !DIDerivedType(tag: DW_TAG_member, name: "errno_var", scope: !74, file: !6, line: 610, baseType: !59, size: 32, offset: 800)
!166 = !DIDerivedType(tag: DW_TAG_member, name: "stack_info", scope: !74, file: !6, line: 616, baseType: !167, size: 96, offset: 832)
!167 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_stack_info", file: !6, line: 525, size: 96, elements: !168)
!168 = !{!169, !172, !175}
!169 = !DIDerivedType(tag: DW_TAG_member, name: "start", scope: !167, file: !6, line: 529, baseType: !170, size: 32)
!170 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintptr_t", file: !56, line: 71, baseType: !171)
!171 = !DIBasicType(name: "long unsigned int", size: 32, encoding: DW_ATE_unsigned)
!172 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !167, file: !6, line: 538, baseType: !173, size: 32, offset: 32)
!173 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !174, line: 46, baseType: !133)
!174 = !DIFile(filename: "/usr/lib/llvm-9/lib/clang/9.0.1/include/stddef.h", directory: "")
!175 = !DIDerivedType(tag: DW_TAG_member, name: "delta", scope: !167, file: !6, line: 544, baseType: !173, size: 32, offset: 64)
!176 = !DIDerivedType(tag: DW_TAG_member, name: "resource_pool", scope: !74, file: !6, line: 641, baseType: !177, size: 32, offset: 928)
!177 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !178, size: 32)
!178 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mem_pool", file: !179, line: 30, size: 32, elements: !180)
!179 = !DIFile(filename: "zephyrproject/zephyr/include/mempool_heap.h", directory: "/home/kenny")
!180 = !{!181}
!181 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !178, file: !179, line: 31, baseType: !182, size: 32)
!182 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !183, size: 32)
!183 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_heap", file: !110, line: 267, size: 160, elements: !184)
!184 = !{!185, !194, !195}
!185 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !183, file: !110, line: 268, baseType: !186, size: 96)
!186 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "sys_heap", file: !187, line: 51, size: 96, elements: !188)
!187 = !DIFile(filename: "zephyrproject/zephyr/include/sys/sys_heap.h", directory: "/home/kenny")
!188 = !{!189, !192, !193}
!189 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !186, file: !187, line: 52, baseType: !190, size: 32)
!190 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !191, size: 32)
!191 = !DICompositeType(tag: DW_TAG_structure_type, name: "z_heap", file: !187, line: 52, flags: DIFlagFwdDecl)
!192 = !DIDerivedType(tag: DW_TAG_member, name: "init_mem", scope: !186, file: !187, line: 53, baseType: !58, size: 32, offset: 32)
!193 = !DIDerivedType(tag: DW_TAG_member, name: "init_bytes", scope: !186, file: !187, line: 54, baseType: !173, size: 32, offset: 64)
!194 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !183, file: !110, line: 269, baseType: !109, size: 64, offset: 96)
!195 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !183, file: !110, line: 270, baseType: !196, offset: 160)
!196 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_spinlock", file: !110, line: 234, elements: !197)
!197 = !{}
!198 = !DIDerivedType(tag: DW_TAG_member, name: "arch", scope: !74, file: !6, line: 644, baseType: !199, size: 64, offset: 960)
!199 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_arch", file: !149, line: 60, size: 64, elements: !200)
!200 = !{!201, !202}
!201 = !DIDerivedType(tag: DW_TAG_member, name: "basepri", scope: !199, file: !149, line: 63, baseType: !132, size: 32)
!202 = !DIDerivedType(tag: DW_TAG_member, name: "swap_return_value", scope: !199, file: !149, line: 66, baseType: !132, size: 32, offset: 32)
!203 = !DIGlobalVariableExpression(var: !204, expr: !DIExpression())
!204 = distinct !DIGlobalVariable(name: "work", scope: !2, file: !63, line: 15, type: !205, isLocal: false, isDefinition: true)
!205 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_lifo", file: !6, line: 2782, size: 128, elements: !206)
!206 = !{!207}
!207 = !DIDerivedType(tag: DW_TAG_member, name: "_queue", scope: !205, file: !6, line: 2783, baseType: !208, size: 128)
!208 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_queue", file: !6, line: 2185, size: 128, elements: !209)
!209 = !{!210, !223, !224}
!210 = !DIDerivedType(tag: DW_TAG_member, name: "data_q", scope: !208, file: !6, line: 2186, baseType: !211, size: 64)
!211 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_sflist_t", file: !212, line: 45, baseType: !213)
!212 = !DIFile(filename: "zephyrproject/zephyr/include/sys/sflist.h", directory: "/home/kenny")
!213 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_sflist", file: !212, line: 40, size: 64, elements: !214)
!214 = !{!215, !222}
!215 = !DIDerivedType(tag: DW_TAG_member, name: "head", scope: !213, file: !212, line: 41, baseType: !216, size: 32)
!216 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !217, size: 32)
!217 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_sfnode_t", file: !212, line: 38, baseType: !218)
!218 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_sfnode", file: !212, line: 34, size: 32, elements: !219)
!219 = !{!220}
!220 = !DIDerivedType(tag: DW_TAG_member, name: "next_and_flags", scope: !218, file: !212, line: 35, baseType: !221, size: 32)
!221 = !DIDerivedType(tag: DW_TAG_typedef, name: "unative_t", file: !212, line: 31, baseType: !132)
!222 = !DIDerivedType(tag: DW_TAG_member, name: "tail", scope: !213, file: !212, line: 42, baseType: !216, size: 32, offset: 32)
!223 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !208, file: !6, line: 2187, baseType: !196, offset: 64)
!224 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !208, file: !6, line: 2188, baseType: !109, size: 64, offset: 64)
!225 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mutex", file: !6, line: 3589, size: 160, elements: !226)
!226 = !{!227, !228, !230, !231}
!227 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !225, file: !6, line: 3591, baseType: !109, size: 64)
!228 = !DIDerivedType(tag: DW_TAG_member, name: "owner", scope: !225, file: !6, line: 3593, baseType: !229, size: 32, offset: 64)
!229 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !74, size: 32)
!230 = !DIDerivedType(tag: DW_TAG_member, name: "lock_count", scope: !225, file: !6, line: 3596, baseType: !132, size: 32, offset: 96)
!231 = !DIDerivedType(tag: DW_TAG_member, name: "owner_orig_prio", scope: !225, file: !6, line: 3599, baseType: !59, size: 32, offset: 128)
!232 = !{!"clang version 9.0.1-12 "}
!233 = !{i32 2, !"Dwarf Version", i32 4}
!234 = !{i32 2, !"Debug Info Version", i32 3}
!235 = !{i32 1, !"wchar_size", i32 4}
!236 = !{i32 1, !"min_enum_size", i32 1}
!237 = distinct !DISubprogram(name: "do_work", scope: !63, file: !63, line: 19, type: !238, scopeLine: 19, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !197)
!238 = !DISubroutineType(types: !239)
!239 = !{null, !58, !58, !58}
!240 = !DILocalVariable(name: "a", arg: 1, scope: !237, file: !63, line: 19, type: !58)
!241 = !DILocation(line: 19, column: 20, scope: !237)
!242 = !DILocalVariable(name: "b", arg: 2, scope: !237, file: !63, line: 19, type: !58)
!243 = !DILocation(line: 19, column: 29, scope: !237)
!244 = !DILocalVariable(name: "c", arg: 3, scope: !237, file: !63, line: 19, type: !58)
!245 = !DILocation(line: 19, column: 38, scope: !237)
!246 = !DILocalVariable(name: "done", scope: !237, file: !63, line: 20, type: !59)
!247 = !DILocation(line: 20, column: 9, scope: !237)
!248 = !DILocation(line: 21, column: 5, scope: !237)
!249 = !DILocalVariable(name: "w", scope: !250, file: !63, line: 22, type: !59)
!250 = distinct !DILexicalBlock(scope: !237, file: !63, line: 21, column: 17)
!251 = !DILocation(line: 22, column: 13, scope: !250)
!252 = !DILocation(line: 23, column: 30, scope: !250)
!253 = !DILocation(line: 23, column: 9, scope: !250)
!254 = !DILocalVariable(name: "item", scope: !250, file: !63, line: 24, type: !255)
!255 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !256, size: 32)
!256 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "work_item", file: !63, line: 7, size: 64, elements: !257)
!257 = !{!258, !259}
!258 = !DIDerivedType(tag: DW_TAG_member, name: "reserved", scope: !256, file: !63, line: 8, baseType: !58, size: 32)
!259 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !256, file: !63, line: 9, baseType: !59, size: 32, offset: 32)
!260 = !DILocation(line: 24, column: 27, scope: !250)
!261 = !DILocation(line: 24, column: 34, scope: !250)
!262 = !DILocation(line: 25, column: 9, scope: !250)
!263 = !DILocation(line: 26, column: 17, scope: !250)
!264 = !DILocation(line: 26, column: 23, scope: !250)
!265 = !DILocation(line: 26, column: 14, scope: !250)
!266 = distinct !{!266, !248, !267}
!267 = !DILocation(line: 27, column: 5, scope: !237)
!268 = distinct !DISubprogram(name: "k_mutex_lock", scope: !269, file: !269, line: 705, type: !270, scopeLine: 706, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !197)
!269 = !DIFile(filename: "zephyr/include/generated/syscalls/kernel.h", directory: "/home/kenny/ara/build/appl/Zephyr/dyn_queue")
!270 = !DISubroutineType(types: !271)
!271 = !{!59, !272, !273}
!272 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !225, size: 32)
!273 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_timeout_t", file: !54, line: 69, baseType: !274)
!274 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !54, line: 67, size: 64, elements: !275)
!275 = !{!276}
!276 = !DIDerivedType(tag: DW_TAG_member, name: "ticks", scope: !274, file: !54, line: 68, baseType: !53, size: 64)
!277 = !DILocalVariable(name: "mutex", arg: 1, scope: !268, file: !269, line: 705, type: !272)
!278 = !DILocation(line: 705, column: 67, scope: !268)
!279 = !DILocalVariable(name: "timeout", arg: 2, scope: !268, file: !269, line: 705, type: !273)
!280 = !DILocation(line: 705, column: 86, scope: !268)
!281 = !DILocation(line: 714, column: 2, scope: !268)
!282 = !DILocation(line: 714, column: 2, scope: !283)
!283 = distinct !DILexicalBlock(scope: !268, file: !269, line: 714, column: 2)
!284 = !{i32 -2141855170}
!285 = !DILocation(line: 715, column: 29, scope: !268)
!286 = !DILocation(line: 715, column: 9, scope: !268)
!287 = !DILocation(line: 715, column: 2, scope: !268)
!288 = distinct !DISubprogram(name: "k_queue_get", scope: !269, file: !269, line: 569, type: !289, scopeLine: 570, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !197)
!289 = !DISubroutineType(types: !290)
!290 = !{!58, !291, !273}
!291 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !208, size: 32)
!292 = !DILocalVariable(name: "queue", arg: 1, scope: !288, file: !269, line: 569, type: !291)
!293 = !DILocation(line: 569, column: 69, scope: !288)
!294 = !DILocalVariable(name: "timeout", arg: 2, scope: !288, file: !269, line: 569, type: !273)
!295 = !DILocation(line: 569, column: 88, scope: !288)
!296 = !DILocation(line: 578, column: 2, scope: !288)
!297 = !DILocation(line: 578, column: 2, scope: !298)
!298 = distinct !DILexicalBlock(scope: !288, file: !269, line: 578, column: 2)
!299 = !{i32 -2141855862}
!300 = !DILocation(line: 579, column: 28, scope: !288)
!301 = !DILocation(line: 579, column: 9, scope: !288)
!302 = !DILocation(line: 579, column: 2, scope: !288)
!303 = distinct !DISubprogram(name: "k_mutex_unlock", scope: !269, file: !269, line: 720, type: !304, scopeLine: 721, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !197)
!304 = !DISubroutineType(types: !305)
!305 = !{!59, !272}
!306 = !DILocalVariable(name: "mutex", arg: 1, scope: !303, file: !269, line: 720, type: !272)
!307 = !DILocation(line: 720, column: 69, scope: !303)
!308 = !DILocation(line: 727, column: 2, scope: !303)
!309 = !DILocation(line: 727, column: 2, scope: !310)
!310 = distinct !DILexicalBlock(scope: !303, file: !269, line: 727, column: 2)
!311 = !{i32 -2141855102}
!312 = !DILocation(line: 728, column: 31, scope: !303)
!313 = !DILocation(line: 728, column: 9, scope: !303)
!314 = !DILocation(line: 728, column: 2, scope: !303)
!315 = distinct !DISubprogram(name: "main", scope: !63, file: !63, line: 30, type: !163, scopeLine: 30, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !197)
!316 = !DILocalVariable(name: "workerId", scope: !315, file: !63, line: 31, type: !317)
!317 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_tid_t", file: !6, line: 648, baseType: !229)
!318 = !DILocation(line: 31, column: 13, scope: !315)
!319 = !DILocation(line: 32, column: 60, scope: !315)
!320 = !DILocation(line: 31, column: 24, scope: !315)
!321 = !DILocation(line: 34, column: 5, scope: !315)
!322 = !DILocation(line: 35, column: 5, scope: !315)
!323 = !DILocation(line: 37, column: 5, scope: !315)
!324 = !DILocalVariable(name: "item", scope: !325, file: !63, line: 38, type: !256)
!325 = distinct !DILexicalBlock(scope: !315, file: !63, line: 37, column: 17)
!326 = !DILocation(line: 38, column: 26, scope: !325)
!327 = !DILocation(line: 39, column: 30, scope: !325)
!328 = !DILocation(line: 39, column: 9, scope: !325)
!329 = !DILocation(line: 40, column: 9, scope: !325)
!330 = !DILocation(line: 41, column: 9, scope: !325)
!331 = distinct !{!331, !323, !332}
!332 = !DILocation(line: 42, column: 5, scope: !315)
!333 = distinct !DISubprogram(name: "k_thread_create", scope: !269, file: !269, line: 66, type: !334, scopeLine: 67, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !197)
!334 = !DISubroutineType(types: !335)
!335 = !{!317, !229, !336, !173, !339, !58, !58, !58, !59, !132, !273}
!336 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !337, size: 32)
!337 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_stack_t", file: !338, line: 44, baseType: !65)
!338 = !DIFile(filename: "zephyrproject/zephyr/include/sys/arch_interface.h", directory: "/home/kenny")
!339 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_entry_t", file: !338, line: 46, baseType: !340)
!340 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !238, size: 32)
!341 = !DILocalVariable(name: "new_thread", arg: 1, scope: !333, file: !269, line: 66, type: !229)
!342 = !DILocation(line: 66, column: 75, scope: !333)
!343 = !DILocalVariable(name: "stack", arg: 2, scope: !333, file: !269, line: 66, type: !336)
!344 = !DILocation(line: 66, column: 106, scope: !333)
!345 = !DILocalVariable(name: "stack_size", arg: 3, scope: !333, file: !269, line: 66, type: !173)
!346 = !DILocation(line: 66, column: 120, scope: !333)
!347 = !DILocalVariable(name: "entry", arg: 4, scope: !333, file: !269, line: 66, type: !339)
!348 = !DILocation(line: 66, column: 149, scope: !333)
!349 = !DILocalVariable(name: "p1", arg: 5, scope: !333, file: !269, line: 66, type: !58)
!350 = !DILocation(line: 66, column: 163, scope: !333)
!351 = !DILocalVariable(name: "p2", arg: 6, scope: !333, file: !269, line: 66, type: !58)
!352 = !DILocation(line: 66, column: 174, scope: !333)
!353 = !DILocalVariable(name: "p3", arg: 7, scope: !333, file: !269, line: 66, type: !58)
!354 = !DILocation(line: 66, column: 185, scope: !333)
!355 = !DILocalVariable(name: "prio", arg: 8, scope: !333, file: !269, line: 66, type: !59)
!356 = !DILocation(line: 66, column: 193, scope: !333)
!357 = !DILocalVariable(name: "options", arg: 9, scope: !333, file: !269, line: 66, type: !132)
!358 = !DILocation(line: 66, column: 208, scope: !333)
!359 = !DILocalVariable(name: "delay", arg: 10, scope: !333, file: !269, line: 66, type: !273)
!360 = !DILocation(line: 66, column: 229, scope: !333)
!361 = !DILocation(line: 83, column: 2, scope: !333)
!362 = !DILocation(line: 83, column: 2, scope: !363)
!363 = distinct !DILexicalBlock(scope: !333, file: !269, line: 83, column: 2)
!364 = !{i32 -2141858310}
!365 = !DILocation(line: 84, column: 32, scope: !333)
!366 = !DILocation(line: 84, column: 44, scope: !333)
!367 = !DILocation(line: 84, column: 51, scope: !333)
!368 = !DILocation(line: 84, column: 63, scope: !333)
!369 = !DILocation(line: 84, column: 70, scope: !333)
!370 = !DILocation(line: 84, column: 74, scope: !333)
!371 = !DILocation(line: 84, column: 78, scope: !333)
!372 = !DILocation(line: 84, column: 82, scope: !333)
!373 = !DILocation(line: 84, column: 88, scope: !333)
!374 = !DILocation(line: 84, column: 9, scope: !333)
!375 = !DILocation(line: 84, column: 2, scope: !333)
!376 = distinct !DISubprogram(name: "k_queue_init", scope: !269, file: !269, line: 515, type: !377, scopeLine: 516, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !197)
!377 = !DISubroutineType(types: !378)
!378 = !{null, !291}
!379 = !DILocalVariable(name: "queue", arg: 1, scope: !376, file: !269, line: 515, type: !291)
!380 = !DILocation(line: 515, column: 68, scope: !376)
!381 = !DILocation(line: 523, column: 2, scope: !376)
!382 = !DILocation(line: 523, column: 2, scope: !383)
!383 = distinct !DILexicalBlock(scope: !376, file: !269, line: 523, column: 2)
!384 = !{i32 -2141856134}
!385 = !DILocation(line: 524, column: 22, scope: !376)
!386 = !DILocation(line: 524, column: 2, scope: !376)
!387 = !DILocation(line: 525, column: 1, scope: !376)
!388 = distinct !DISubprogram(name: "k_mutex_init", scope: !269, file: !269, line: 692, type: !304, scopeLine: 693, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !197)
!389 = !DILocalVariable(name: "mutex", arg: 1, scope: !388, file: !269, line: 692, type: !272)
!390 = !DILocation(line: 692, column: 67, scope: !388)
!391 = !DILocation(line: 699, column: 2, scope: !388)
!392 = !DILocation(line: 699, column: 2, scope: !393)
!393 = distinct !DILexicalBlock(scope: !388, file: !269, line: 699, column: 2)
!394 = !{i32 -2141855238}
!395 = !DILocation(line: 700, column: 29, scope: !388)
!396 = !DILocation(line: 700, column: 9, scope: !388)
!397 = !DILocation(line: 700, column: 2, scope: !388)
