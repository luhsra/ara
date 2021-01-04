; ModuleID = 'llvm-link'
source_filename = "llvm-link"
target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "thumbv7em-none-unknown-eabi"

%struct.k_pipe = type { i8*, i32, i32, i32, i32, %struct.k_spinlock, %struct.anon.3, i8 }
%struct.k_spinlock = type {}
%struct.anon.3 = type { %struct._wait_q_t, %struct._wait_q_t }
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
%struct._thread_arch = type { i32, i32 }
%struct.z_thread_stack_element = type { i8 }
%struct._static_thread_data = type { %struct.k_thread*, %struct.z_thread_stack_element*, i32, void (i8*, i8*, i8*)*, i8*, i8*, i8*, i32, i32, i32, void ()*, i8* }
%struct.k_timeout_t = type { i64 }

@work = dso_local global %struct.k_pipe zeroinitializer, align 4, !dbg !0
@_k_thread_obj_thread_a = dso_local global %struct.k_thread zeroinitializer, align 8, !dbg !232
@_k_thread_stack_thread_a = dso_local global [1024 x %struct.z_thread_stack_element] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/dyn_pipe/src/main.c\22.0", align 8, !dbg !227
@_k_thread_data_thread_a = dso_local global %struct._static_thread_data { %struct.k_thread* @_k_thread_obj_thread_a, %struct.z_thread_stack_element* getelementptr inbounds ([1024 x %struct.z_thread_stack_element], [1024 x %struct.z_thread_stack_element]* @_k_thread_stack_thread_a, i32 0, i32 0), i32 1024, void (i8*, i8*, i8*)* @do_stuff, i8* null, i8* null, i8* null, i32 7, i32 0, i32 0, void ()* null, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str, i32 0, i32 0) }, section ".__static_thread_data.static._k_thread_data_thread_a", align 4, !dbg !61
@.str = private unnamed_addr constant [9 x i8] c"thread_a\00", align 1
@thread_a = dso_local constant %struct.k_thread* @_k_thread_obj_thread_a, align 4, !dbg !223
@llvm.used = appending global [1 x i8*] [i8* bitcast (%struct._static_thread_data* @_k_thread_data_thread_a to i8*)], section "llvm.metadata"

; Function Attrs: noinline nounwind optnone
define dso_local void @do_stuff(i8*, i8*, i8*) #0 !dbg !254 {
  %4 = alloca i8*, align 4
  %5 = alloca i8*, align 4
  %6 = alloca i8*, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  %10 = alloca %struct.k_timeout_t, align 8
  store i8* %0, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !255, metadata !DIExpression()), !dbg !256
  store i8* %1, i8** %5, align 4
  call void @llvm.dbg.declare(metadata i8** %5, metadata !257, metadata !DIExpression()), !dbg !258
  store i8* %2, i8** %6, align 4
  call void @llvm.dbg.declare(metadata i8** %6, metadata !259, metadata !DIExpression()), !dbg !260
  %11 = load i8*, i8** %4, align 4, !dbg !261
  %12 = load i8*, i8** %5, align 4, !dbg !262
  %13 = load i8*, i8** %6, align 4, !dbg !263
  call void @llvm.dbg.declare(metadata i32* %7, metadata !264, metadata !DIExpression()), !dbg !265
  store i32 0, i32* %7, align 4, !dbg !265
  br label %14, !dbg !266

14:                                               ; preds = %14, %3
  call void @llvm.dbg.declare(metadata i32* %8, metadata !267, metadata !DIExpression()), !dbg !269
  call void @llvm.dbg.declare(metadata i32* %9, metadata !270, metadata !DIExpression()), !dbg !271
  %15 = bitcast i32* %8 to i8*, !dbg !272
  %16 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %10, i32 0, i32 0, !dbg !273
  store i64 -1, i64* %16, align 8, !dbg !273
  %17 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %10, i32 0, i32 0, !dbg !274
  %18 = bitcast i64* %17 to [1 x i64]*, !dbg !274
  %19 = load [1 x i64], [1 x i64]* %18, align 8, !dbg !274
  %20 = call i32 @k_pipe_get(%struct.k_pipe* @work, i8* %15, i32 4, i32* %9, i32 4, [1 x i64] %19) #3, !dbg !274
  %21 = load i32, i32* %8, align 4, !dbg !275
  %22 = load i32, i32* %7, align 4, !dbg !276
  %23 = add i32 %22, %21, !dbg !276
  store i32 %23, i32* %7, align 4, !dbg !276
  br label %14, !dbg !266, !llvm.loop !277
}

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: noinline nounwind optnone
define internal i32 @k_pipe_get(%struct.k_pipe*, i8*, i32, i32*, i32, [1 x i64]) #0 !dbg !279 {
  %7 = alloca %struct.k_timeout_t, align 8
  %8 = alloca %struct.k_pipe*, align 4
  %9 = alloca i8*, align 4
  %10 = alloca i32, align 4
  %11 = alloca i32*, align 4
  %12 = alloca i32, align 4
  %13 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %7, i32 0, i32 0
  %14 = bitcast i64* %13 to [1 x i64]*
  store [1 x i64] %5, [1 x i64]* %14, align 8
  store %struct.k_pipe* %0, %struct.k_pipe** %8, align 4
  call void @llvm.dbg.declare(metadata %struct.k_pipe** %8, metadata !289, metadata !DIExpression()), !dbg !290
  store i8* %1, i8** %9, align 4
  call void @llvm.dbg.declare(metadata i8** %9, metadata !291, metadata !DIExpression()), !dbg !292
  store i32 %2, i32* %10, align 4
  call void @llvm.dbg.declare(metadata i32* %10, metadata !293, metadata !DIExpression()), !dbg !294
  store i32* %3, i32** %11, align 4
  call void @llvm.dbg.declare(metadata i32** %11, metadata !295, metadata !DIExpression()), !dbg !296
  store i32 %4, i32* %12, align 4
  call void @llvm.dbg.declare(metadata i32* %12, metadata !297, metadata !DIExpression()), !dbg !298
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %7, metadata !299, metadata !DIExpression()), !dbg !300
  br label %15, !dbg !301

15:                                               ; preds = %6
  call void asm sideeffect "", "~{memory}"() #4, !dbg !302, !srcloc !304
  br label %16, !dbg !302

16:                                               ; preds = %15
  %17 = load %struct.k_pipe*, %struct.k_pipe** %8, align 4, !dbg !305
  %18 = load i8*, i8** %9, align 4, !dbg !306
  %19 = load i32, i32* %10, align 4, !dbg !307
  %20 = load i32*, i32** %11, align 4, !dbg !308
  %21 = load i32, i32* %12, align 4, !dbg !309
  %22 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %7, i32 0, i32 0, !dbg !310
  %23 = bitcast i64* %22 to [1 x i64]*, !dbg !310
  %24 = load [1 x i64], [1 x i64]* %23, align 8, !dbg !310
  %25 = call i32 @z_impl_k_pipe_get(%struct.k_pipe* %17, i8* %18, i32 %19, i32* %20, i32 %21, [1 x i64] %24) #3, !dbg !310
  ret i32 %25, !dbg !311
}

declare dso_local i32 @z_impl_k_pipe_get(%struct.k_pipe*, i8*, i32, i32*, i32, [1 x i64]) #2

; Function Attrs: noinline nounwind optnone
define dso_local void @main() #0 !dbg !312 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca %struct.k_timeout_t, align 8
  %4 = call i32 @k_pipe_alloc_init(%struct.k_pipe* @work, i32 256) #3, !dbg !313
  call void @llvm.dbg.declare(metadata i32* %1, metadata !314, metadata !DIExpression()), !dbg !315
  store i32 0, i32* %1, align 4, !dbg !315
  br label %5, !dbg !316

5:                                                ; preds = %5, %0
  call void @llvm.dbg.declare(metadata i32* %2, metadata !317, metadata !DIExpression()), !dbg !319
  %6 = bitcast i32* %1 to i8*, !dbg !320
  %7 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !321
  store i64 -1, i64* %7, align 8, !dbg !321
  %8 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !322
  %9 = bitcast i64* %8 to [1 x i64]*, !dbg !322
  %10 = load [1 x i64], [1 x i64]* %9, align 8, !dbg !322
  %11 = call i32 @k_pipe_put(%struct.k_pipe* @work, i8* %6, i32 4, i32* %2, i32 4, [1 x i64] %10) #3, !dbg !322
  br label %5, !dbg !316, !llvm.loop !323
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_pipe_alloc_init(%struct.k_pipe*, i32) #0 !dbg !325 {
  %3 = alloca %struct.k_pipe*, align 4
  %4 = alloca i32, align 4
  store %struct.k_pipe* %0, %struct.k_pipe** %3, align 4
  call void @llvm.dbg.declare(metadata %struct.k_pipe** %3, metadata !328, metadata !DIExpression()), !dbg !329
  store i32 %1, i32* %4, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !330, metadata !DIExpression()), !dbg !331
  br label %5, !dbg !332

5:                                                ; preds = %2
  call void asm sideeffect "", "~{memory}"() #4, !dbg !333, !srcloc !335
  br label %6, !dbg !333

6:                                                ; preds = %5
  %7 = load %struct.k_pipe*, %struct.k_pipe** %3, align 4, !dbg !336
  %8 = load i32, i32* %4, align 4, !dbg !337
  %9 = call i32 @z_impl_k_pipe_alloc_init(%struct.k_pipe* %7, i32 %8) #3, !dbg !338
  ret i32 %9, !dbg !339
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_pipe_put(%struct.k_pipe*, i8*, i32, i32*, i32, [1 x i64]) #0 !dbg !340 {
  %7 = alloca %struct.k_timeout_t, align 8
  %8 = alloca %struct.k_pipe*, align 4
  %9 = alloca i8*, align 4
  %10 = alloca i32, align 4
  %11 = alloca i32*, align 4
  %12 = alloca i32, align 4
  %13 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %7, i32 0, i32 0
  %14 = bitcast i64* %13 to [1 x i64]*
  store [1 x i64] %5, [1 x i64]* %14, align 8
  store %struct.k_pipe* %0, %struct.k_pipe** %8, align 4
  call void @llvm.dbg.declare(metadata %struct.k_pipe** %8, metadata !341, metadata !DIExpression()), !dbg !342
  store i8* %1, i8** %9, align 4
  call void @llvm.dbg.declare(metadata i8** %9, metadata !343, metadata !DIExpression()), !dbg !344
  store i32 %2, i32* %10, align 4
  call void @llvm.dbg.declare(metadata i32* %10, metadata !345, metadata !DIExpression()), !dbg !346
  store i32* %3, i32** %11, align 4
  call void @llvm.dbg.declare(metadata i32** %11, metadata !347, metadata !DIExpression()), !dbg !348
  store i32 %4, i32* %12, align 4
  call void @llvm.dbg.declare(metadata i32* %12, metadata !349, metadata !DIExpression()), !dbg !350
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %7, metadata !351, metadata !DIExpression()), !dbg !352
  br label %15, !dbg !353

15:                                               ; preds = %6
  call void asm sideeffect "", "~{memory}"() #4, !dbg !354, !srcloc !356
  br label %16, !dbg !354

16:                                               ; preds = %15
  %17 = load %struct.k_pipe*, %struct.k_pipe** %8, align 4, !dbg !357
  %18 = load i8*, i8** %9, align 4, !dbg !358
  %19 = load i32, i32* %10, align 4, !dbg !359
  %20 = load i32*, i32** %11, align 4, !dbg !360
  %21 = load i32, i32* %12, align 4, !dbg !361
  %22 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %7, i32 0, i32 0, !dbg !362
  %23 = bitcast i64* %22 to [1 x i64]*, !dbg !362
  %24 = load [1 x i64], [1 x i64]* %23, align 8, !dbg !362
  %25 = call i32 @z_impl_k_pipe_put(%struct.k_pipe* %17, i8* %18, i32 %19, i32* %20, i32 %21, [1 x i64] %24) #3, !dbg !362
  ret i32 %25, !dbg !363
}

declare dso_local i32 @z_impl_k_pipe_put(%struct.k_pipe*, i8*, i32, i32*, i32, [1 x i64]) #2

declare dso_local i32 @z_impl_k_pipe_alloc_init(%struct.k_pipe*, i32) #2

attributes #0 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #1 = { nounwind readnone speculatable }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #3 = { nobuiltin }
attributes #4 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.ident = !{!249}
!llvm.module.flags = !{!250, !251, !252, !253}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "work", scope: !2, file: !63, line: 10, type: !234, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !52, globals: !60, nameTableKind: None)
!3 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/dyn_pipe/src/main.c", directory: "/home/kenny/ara/build/appl/Zephyr/dyn_pipe")
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
!60 = !{!61, !223, !0, !227, !232}
!61 = !DIGlobalVariableExpression(var: !62, expr: !DIExpression())
!62 = distinct !DIGlobalVariable(name: "_k_thread_data_thread_a", scope: !2, file: !63, line: 26, type: !64, isLocal: false, isDefinition: true, align: 32)
!63 = !DIFile(filename: "appl/Zephyr/dyn_pipe/src/main.c", directory: "/home/kenny/ara")
!64 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_static_thread_data", file: !6, line: 1099, size: 384, elements: !65)
!65 = !{!66, !197, !206, !207, !212, !213, !214, !215, !216, !217, !219, !220}
!66 = !DIDerivedType(tag: DW_TAG_member, name: "init_thread", scope: !64, file: !6, line: 1100, baseType: !67, size: 32)
!67 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !68, size: 32)
!68 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_thread", file: !6, line: 570, size: 1024, elements: !69)
!69 = !{!70, !141, !154, !155, !159, !160, !170, !192}
!70 = !DIDerivedType(tag: DW_TAG_member, name: "base", scope: !68, file: !6, line: 572, baseType: !71, size: 448)
!71 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_base", file: !6, line: 441, size: 448, elements: !72)
!72 = !{!73, !101, !109, !111, !112, !125, !128, !129, !140}
!73 = !DIDerivedType(tag: DW_TAG_member, scope: !71, file: !6, line: 444, baseType: !74, size: 64)
!74 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !71, file: !6, line: 444, size: 64, elements: !75)
!75 = !{!76, !92}
!76 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_dlist", scope: !74, file: !6, line: 445, baseType: !77, size: 64)
!77 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dnode_t", file: !78, line: 43, baseType: !79)
!78 = !DIFile(filename: "zephyrproject/zephyr/include/sys/dlist.h", directory: "/home/kenny")
!79 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_dnode", file: !78, line: 31, size: 64, elements: !80)
!80 = !{!81, !87}
!81 = !DIDerivedType(tag: DW_TAG_member, scope: !79, file: !78, line: 32, baseType: !82, size: 32)
!82 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !79, file: !78, line: 32, size: 32, elements: !83)
!83 = !{!84, !86}
!84 = !DIDerivedType(tag: DW_TAG_member, name: "head", scope: !82, file: !78, line: 33, baseType: !85, size: 32)
!85 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !79, size: 32)
!86 = !DIDerivedType(tag: DW_TAG_member, name: "next", scope: !82, file: !78, line: 34, baseType: !85, size: 32)
!87 = !DIDerivedType(tag: DW_TAG_member, scope: !79, file: !78, line: 36, baseType: !88, size: 32, offset: 32)
!88 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !79, file: !78, line: 36, size: 32, elements: !89)
!89 = !{!90, !91}
!90 = !DIDerivedType(tag: DW_TAG_member, name: "tail", scope: !88, file: !78, line: 37, baseType: !85, size: 32)
!91 = !DIDerivedType(tag: DW_TAG_member, name: "prev", scope: !88, file: !78, line: 38, baseType: !85, size: 32)
!92 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_rb", scope: !74, file: !6, line: 446, baseType: !93, size: 64)
!93 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "rbnode", file: !94, line: 48, size: 64, elements: !95)
!94 = !DIFile(filename: "zephyrproject/zephyr/include/sys/rb.h", directory: "/home/kenny")
!95 = !{!96}
!96 = !DIDerivedType(tag: DW_TAG_member, name: "children", scope: !93, file: !94, line: 49, baseType: !97, size: 64)
!97 = !DICompositeType(tag: DW_TAG_array_type, baseType: !98, size: 64, elements: !99)
!98 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !93, size: 32)
!99 = !{!100}
!100 = !DISubrange(count: 2)
!101 = !DIDerivedType(tag: DW_TAG_member, name: "pended_on", scope: !71, file: !6, line: 452, baseType: !102, size: 32, offset: 64)
!102 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !103, size: 32)
!103 = !DIDerivedType(tag: DW_TAG_typedef, name: "_wait_q_t", file: !104, line: 210, baseType: !105)
!104 = !DIFile(filename: "zephyrproject/zephyr/include/kernel_structs.h", directory: "/home/kenny")
!105 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !104, line: 208, size: 64, elements: !106)
!106 = !{!107}
!107 = !DIDerivedType(tag: DW_TAG_member, name: "waitq", scope: !105, file: !104, line: 209, baseType: !108, size: 64)
!108 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dlist_t", file: !78, line: 42, baseType: !79)
!109 = !DIDerivedType(tag: DW_TAG_member, name: "user_options", scope: !71, file: !6, line: 455, baseType: !110, size: 8, offset: 96)
!110 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !56, line: 55, baseType: !7)
!111 = !DIDerivedType(tag: DW_TAG_member, name: "thread_state", scope: !71, file: !6, line: 458, baseType: !110, size: 8, offset: 104)
!112 = !DIDerivedType(tag: DW_TAG_member, scope: !71, file: !6, line: 474, baseType: !113, size: 16, offset: 112)
!113 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !71, file: !6, line: 474, size: 16, elements: !114)
!114 = !{!115, !122}
!115 = !DIDerivedType(tag: DW_TAG_member, scope: !113, file: !6, line: 475, baseType: !116, size: 16)
!116 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !113, file: !6, line: 475, size: 16, elements: !117)
!117 = !{!118, !121}
!118 = !DIDerivedType(tag: DW_TAG_member, name: "prio", scope: !116, file: !6, line: 480, baseType: !119, size: 8)
!119 = !DIDerivedType(tag: DW_TAG_typedef, name: "int8_t", file: !56, line: 40, baseType: !120)
!120 = !DIBasicType(name: "signed char", size: 8, encoding: DW_ATE_signed_char)
!121 = !DIDerivedType(tag: DW_TAG_member, name: "sched_locked", scope: !116, file: !6, line: 481, baseType: !110, size: 8, offset: 8)
!122 = !DIDerivedType(tag: DW_TAG_member, name: "preempt", scope: !113, file: !6, line: 484, baseType: !123, size: 16)
!123 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !56, line: 56, baseType: !124)
!124 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!125 = !DIDerivedType(tag: DW_TAG_member, name: "order_key", scope: !71, file: !6, line: 491, baseType: !126, size: 32, offset: 128)
!126 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !56, line: 57, baseType: !127)
!127 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!128 = !DIDerivedType(tag: DW_TAG_member, name: "swap_data", scope: !71, file: !6, line: 511, baseType: !58, size: 32, offset: 160)
!129 = !DIDerivedType(tag: DW_TAG_member, name: "timeout", scope: !71, file: !6, line: 515, baseType: !130, size: 192, offset: 192)
!130 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_timeout", file: !104, line: 221, size: 192, elements: !131)
!131 = !{!132, !133, !139}
!132 = !DIDerivedType(tag: DW_TAG_member, name: "node", scope: !130, file: !104, line: 222, baseType: !77, size: 64)
!133 = !DIDerivedType(tag: DW_TAG_member, name: "fn", scope: !130, file: !104, line: 223, baseType: !134, size: 32, offset: 64)
!134 = !DIDerivedType(tag: DW_TAG_typedef, name: "_timeout_func_t", file: !104, line: 219, baseType: !135)
!135 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !136, size: 32)
!136 = !DISubroutineType(types: !137)
!137 = !{null, !138}
!138 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !130, size: 32)
!139 = !DIDerivedType(tag: DW_TAG_member, name: "dticks", scope: !130, file: !104, line: 226, baseType: !55, size: 64, offset: 128)
!140 = !DIDerivedType(tag: DW_TAG_member, name: "join_waiters", scope: !71, file: !6, line: 518, baseType: !103, size: 64, offset: 384)
!141 = !DIDerivedType(tag: DW_TAG_member, name: "callee_saved", scope: !68, file: !6, line: 575, baseType: !142, size: 288, offset: 448)
!142 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_callee_saved", file: !143, line: 25, size: 288, elements: !144)
!143 = !DIFile(filename: "zephyrproject/zephyr/include/arch/arm/aarch32/thread.h", directory: "/home/kenny")
!144 = !{!145, !146, !147, !148, !149, !150, !151, !152, !153}
!145 = !DIDerivedType(tag: DW_TAG_member, name: "v1", scope: !142, file: !143, line: 26, baseType: !126, size: 32)
!146 = !DIDerivedType(tag: DW_TAG_member, name: "v2", scope: !142, file: !143, line: 27, baseType: !126, size: 32, offset: 32)
!147 = !DIDerivedType(tag: DW_TAG_member, name: "v3", scope: !142, file: !143, line: 28, baseType: !126, size: 32, offset: 64)
!148 = !DIDerivedType(tag: DW_TAG_member, name: "v4", scope: !142, file: !143, line: 29, baseType: !126, size: 32, offset: 96)
!149 = !DIDerivedType(tag: DW_TAG_member, name: "v5", scope: !142, file: !143, line: 30, baseType: !126, size: 32, offset: 128)
!150 = !DIDerivedType(tag: DW_TAG_member, name: "v6", scope: !142, file: !143, line: 31, baseType: !126, size: 32, offset: 160)
!151 = !DIDerivedType(tag: DW_TAG_member, name: "v7", scope: !142, file: !143, line: 32, baseType: !126, size: 32, offset: 192)
!152 = !DIDerivedType(tag: DW_TAG_member, name: "v8", scope: !142, file: !143, line: 33, baseType: !126, size: 32, offset: 224)
!153 = !DIDerivedType(tag: DW_TAG_member, name: "psp", scope: !142, file: !143, line: 34, baseType: !126, size: 32, offset: 256)
!154 = !DIDerivedType(tag: DW_TAG_member, name: "init_data", scope: !68, file: !6, line: 578, baseType: !58, size: 32, offset: 736)
!155 = !DIDerivedType(tag: DW_TAG_member, name: "fn_abort", scope: !68, file: !6, line: 583, baseType: !156, size: 32, offset: 768)
!156 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !157, size: 32)
!157 = !DISubroutineType(types: !158)
!158 = !{null}
!159 = !DIDerivedType(tag: DW_TAG_member, name: "errno_var", scope: !68, file: !6, line: 610, baseType: !59, size: 32, offset: 800)
!160 = !DIDerivedType(tag: DW_TAG_member, name: "stack_info", scope: !68, file: !6, line: 616, baseType: !161, size: 96, offset: 832)
!161 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_stack_info", file: !6, line: 525, size: 96, elements: !162)
!162 = !{!163, !166, !169}
!163 = !DIDerivedType(tag: DW_TAG_member, name: "start", scope: !161, file: !6, line: 529, baseType: !164, size: 32)
!164 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintptr_t", file: !56, line: 71, baseType: !165)
!165 = !DIBasicType(name: "long unsigned int", size: 32, encoding: DW_ATE_unsigned)
!166 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !161, file: !6, line: 538, baseType: !167, size: 32, offset: 32)
!167 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !168, line: 46, baseType: !127)
!168 = !DIFile(filename: "/usr/lib/llvm-9/lib/clang/9.0.1/include/stddef.h", directory: "")
!169 = !DIDerivedType(tag: DW_TAG_member, name: "delta", scope: !161, file: !6, line: 544, baseType: !167, size: 32, offset: 64)
!170 = !DIDerivedType(tag: DW_TAG_member, name: "resource_pool", scope: !68, file: !6, line: 641, baseType: !171, size: 32, offset: 928)
!171 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !172, size: 32)
!172 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mem_pool", file: !173, line: 30, size: 32, elements: !174)
!173 = !DIFile(filename: "zephyrproject/zephyr/include/mempool_heap.h", directory: "/home/kenny")
!174 = !{!175}
!175 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !172, file: !173, line: 31, baseType: !176, size: 32)
!176 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !177, size: 32)
!177 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_heap", file: !104, line: 267, size: 160, elements: !178)
!178 = !{!179, !188, !189}
!179 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !177, file: !104, line: 268, baseType: !180, size: 96)
!180 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "sys_heap", file: !181, line: 51, size: 96, elements: !182)
!181 = !DIFile(filename: "zephyrproject/zephyr/include/sys/sys_heap.h", directory: "/home/kenny")
!182 = !{!183, !186, !187}
!183 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !180, file: !181, line: 52, baseType: !184, size: 32)
!184 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !185, size: 32)
!185 = !DICompositeType(tag: DW_TAG_structure_type, name: "z_heap", file: !181, line: 52, flags: DIFlagFwdDecl)
!186 = !DIDerivedType(tag: DW_TAG_member, name: "init_mem", scope: !180, file: !181, line: 53, baseType: !58, size: 32, offset: 32)
!187 = !DIDerivedType(tag: DW_TAG_member, name: "init_bytes", scope: !180, file: !181, line: 54, baseType: !167, size: 32, offset: 64)
!188 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !177, file: !104, line: 269, baseType: !103, size: 64, offset: 96)
!189 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !177, file: !104, line: 270, baseType: !190, offset: 160)
!190 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_spinlock", file: !104, line: 234, elements: !191)
!191 = !{}
!192 = !DIDerivedType(tag: DW_TAG_member, name: "arch", scope: !68, file: !6, line: 644, baseType: !193, size: 64, offset: 960)
!193 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_arch", file: !143, line: 60, size: 64, elements: !194)
!194 = !{!195, !196}
!195 = !DIDerivedType(tag: DW_TAG_member, name: "basepri", scope: !193, file: !143, line: 63, baseType: !126, size: 32)
!196 = !DIDerivedType(tag: DW_TAG_member, name: "swap_return_value", scope: !193, file: !143, line: 66, baseType: !126, size: 32, offset: 32)
!197 = !DIDerivedType(tag: DW_TAG_member, name: "init_stack", scope: !64, file: !6, line: 1101, baseType: !198, size: 32, offset: 32)
!198 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !199, size: 32)
!199 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_stack_t", file: !200, line: 44, baseType: !201)
!200 = !DIFile(filename: "zephyrproject/zephyr/include/sys/arch_interface.h", directory: "/home/kenny")
!201 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "z_thread_stack_element", file: !202, line: 35, size: 8, elements: !203)
!202 = !DIFile(filename: "zephyrproject/zephyr/include/sys/thread_stack.h", directory: "/home/kenny")
!203 = !{!204}
!204 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !201, file: !202, line: 36, baseType: !205, size: 8)
!205 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_unsigned_char)
!206 = !DIDerivedType(tag: DW_TAG_member, name: "init_stack_size", scope: !64, file: !6, line: 1102, baseType: !127, size: 32, offset: 64)
!207 = !DIDerivedType(tag: DW_TAG_member, name: "init_entry", scope: !64, file: !6, line: 1103, baseType: !208, size: 32, offset: 96)
!208 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_entry_t", file: !200, line: 46, baseType: !209)
!209 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !210, size: 32)
!210 = !DISubroutineType(types: !211)
!211 = !{null, !58, !58, !58}
!212 = !DIDerivedType(tag: DW_TAG_member, name: "init_p1", scope: !64, file: !6, line: 1104, baseType: !58, size: 32, offset: 128)
!213 = !DIDerivedType(tag: DW_TAG_member, name: "init_p2", scope: !64, file: !6, line: 1105, baseType: !58, size: 32, offset: 160)
!214 = !DIDerivedType(tag: DW_TAG_member, name: "init_p3", scope: !64, file: !6, line: 1106, baseType: !58, size: 32, offset: 192)
!215 = !DIDerivedType(tag: DW_TAG_member, name: "init_prio", scope: !64, file: !6, line: 1107, baseType: !59, size: 32, offset: 224)
!216 = !DIDerivedType(tag: DW_TAG_member, name: "init_options", scope: !64, file: !6, line: 1108, baseType: !126, size: 32, offset: 256)
!217 = !DIDerivedType(tag: DW_TAG_member, name: "init_delay", scope: !64, file: !6, line: 1109, baseType: !218, size: 32, offset: 288)
!218 = !DIDerivedType(tag: DW_TAG_typedef, name: "int32_t", file: !56, line: 42, baseType: !59)
!219 = !DIDerivedType(tag: DW_TAG_member, name: "init_abort", scope: !64, file: !6, line: 1110, baseType: !156, size: 32, offset: 320)
!220 = !DIDerivedType(tag: DW_TAG_member, name: "init_name", scope: !64, file: !6, line: 1111, baseType: !221, size: 32, offset: 352)
!221 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !222, size: 32)
!222 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !205)
!223 = !DIGlobalVariableExpression(var: !224, expr: !DIExpression())
!224 = distinct !DIGlobalVariable(name: "thread_a", scope: !2, file: !63, line: 26, type: !225, isLocal: false, isDefinition: true)
!225 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !226)
!226 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_tid_t", file: !6, line: 648, baseType: !67)
!227 = !DIGlobalVariableExpression(var: !228, expr: !DIExpression())
!228 = distinct !DIGlobalVariable(name: "_k_thread_stack_thread_a", scope: !2, file: !63, line: 26, type: !229, isLocal: false, isDefinition: true, align: 64)
!229 = !DICompositeType(tag: DW_TAG_array_type, baseType: !201, size: 8192, elements: !230)
!230 = !{!231}
!231 = !DISubrange(count: 1024)
!232 = !DIGlobalVariableExpression(var: !233, expr: !DIExpression())
!233 = distinct !DIGlobalVariable(name: "_k_thread_obj_thread_a", scope: !2, file: !63, line: 26, type: !68, isLocal: false, isDefinition: true)
!234 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_pipe", file: !6, line: 4324, size: 320, elements: !235)
!235 = !{!236, !238, !239, !240, !241, !242, !243, !248}
!236 = !DIDerivedType(tag: DW_TAG_member, name: "buffer", scope: !234, file: !6, line: 4325, baseType: !237, size: 32)
!237 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !7, size: 32)
!238 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !234, file: !6, line: 4326, baseType: !167, size: 32, offset: 32)
!239 = !DIDerivedType(tag: DW_TAG_member, name: "bytes_used", scope: !234, file: !6, line: 4327, baseType: !167, size: 32, offset: 64)
!240 = !DIDerivedType(tag: DW_TAG_member, name: "read_index", scope: !234, file: !6, line: 4328, baseType: !167, size: 32, offset: 96)
!241 = !DIDerivedType(tag: DW_TAG_member, name: "write_index", scope: !234, file: !6, line: 4329, baseType: !167, size: 32, offset: 128)
!242 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !234, file: !6, line: 4330, baseType: !190, offset: 160)
!243 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !234, file: !6, line: 4335, baseType: !244, size: 128, offset: 160)
!244 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !234, file: !6, line: 4332, size: 128, elements: !245)
!245 = !{!246, !247}
!246 = !DIDerivedType(tag: DW_TAG_member, name: "readers", scope: !244, file: !6, line: 4333, baseType: !103, size: 64)
!247 = !DIDerivedType(tag: DW_TAG_member, name: "writers", scope: !244, file: !6, line: 4334, baseType: !103, size: 64, offset: 64)
!248 = !DIDerivedType(tag: DW_TAG_member, name: "flags", scope: !234, file: !6, line: 4339, baseType: !110, size: 8, offset: 288)
!249 = !{!"clang version 9.0.1-12 "}
!250 = !{i32 2, !"Dwarf Version", i32 4}
!251 = !{i32 2, !"Debug Info Version", i32 3}
!252 = !{i32 1, !"wchar_size", i32 4}
!253 = !{i32 1, !"min_enum_size", i32 1}
!254 = distinct !DISubprogram(name: "do_stuff", scope: !63, file: !63, line: 12, type: !210, scopeLine: 13, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !191)
!255 = !DILocalVariable(name: "dummy1", arg: 1, scope: !254, file: !63, line: 12, type: !58)
!256 = !DILocation(line: 12, column: 21, scope: !254)
!257 = !DILocalVariable(name: "dummy2", arg: 2, scope: !254, file: !63, line: 12, type: !58)
!258 = !DILocation(line: 12, column: 35, scope: !254)
!259 = !DILocalVariable(name: "dummy3", arg: 3, scope: !254, file: !63, line: 12, type: !58)
!260 = !DILocation(line: 12, column: 49, scope: !254)
!261 = !DILocation(line: 14, column: 2, scope: !254)
!262 = !DILocation(line: 15, column: 2, scope: !254)
!263 = !DILocation(line: 16, column: 2, scope: !254)
!264 = !DILocalVariable(name: "items", scope: !254, file: !63, line: 17, type: !59)
!265 = !DILocation(line: 17, column: 13, scope: !254)
!266 = !DILocation(line: 18, column: 9, scope: !254)
!267 = !DILocalVariable(name: "item", scope: !268, file: !63, line: 19, type: !59)
!268 = distinct !DILexicalBlock(scope: !254, file: !63, line: 18, column: 20)
!269 = !DILocation(line: 19, column: 17, scope: !268)
!270 = !DILocalVariable(name: "bytes_read", scope: !268, file: !63, line: 20, type: !167)
!271 = !DILocation(line: 20, column: 20, scope: !268)
!272 = !DILocation(line: 21, column: 31, scope: !268)
!273 = !DILocation(line: 21, column: 77, scope: !268)
!274 = !DILocation(line: 21, column: 13, scope: !268)
!275 = !DILocation(line: 22, column: 22, scope: !268)
!276 = !DILocation(line: 22, column: 19, scope: !268)
!277 = distinct !{!277, !266, !278}
!278 = !DILocation(line: 23, column: 9, scope: !254)
!279 = distinct !DISubprogram(name: "k_pipe_get", scope: !280, file: !280, line: 944, type: !281, scopeLine: 945, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !191)
!280 = !DIFile(filename: "zephyr/include/generated/syscalls/kernel.h", directory: "/home/kenny/ara/build/appl/Zephyr/dyn_pipe")
!281 = !DISubroutineType(types: !282)
!282 = !{!59, !283, !58, !167, !284, !167, !285}
!283 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !234, size: 32)
!284 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !167, size: 32)
!285 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_timeout_t", file: !54, line: 69, baseType: !286)
!286 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !54, line: 67, size: 64, elements: !287)
!287 = !{!288}
!288 = !DIDerivedType(tag: DW_TAG_member, name: "ticks", scope: !286, file: !54, line: 68, baseType: !53, size: 64)
!289 = !DILocalVariable(name: "pipe", arg: 1, scope: !279, file: !280, line: 944, type: !283)
!290 = !DILocation(line: 944, column: 64, scope: !279)
!291 = !DILocalVariable(name: "data", arg: 2, scope: !279, file: !280, line: 944, type: !58)
!292 = !DILocation(line: 944, column: 77, scope: !279)
!293 = !DILocalVariable(name: "bytes_to_read", arg: 3, scope: !279, file: !280, line: 944, type: !167)
!294 = !DILocation(line: 944, column: 90, scope: !279)
!295 = !DILocalVariable(name: "bytes_read", arg: 4, scope: !279, file: !280, line: 944, type: !284)
!296 = !DILocation(line: 944, column: 114, scope: !279)
!297 = !DILocalVariable(name: "min_xfer", arg: 5, scope: !279, file: !280, line: 944, type: !167)
!298 = !DILocation(line: 944, column: 133, scope: !279)
!299 = !DILocalVariable(name: "timeout", arg: 6, scope: !279, file: !280, line: 944, type: !285)
!300 = !DILocation(line: 944, column: 155, scope: !279)
!301 = !DILocation(line: 957, column: 2, scope: !279)
!302 = !DILocation(line: 957, column: 2, scope: !303)
!303 = distinct !DILexicalBlock(scope: !279, file: !280, line: 957, column: 2)
!304 = !{i32 -2141854200}
!305 = !DILocation(line: 958, column: 27, scope: !279)
!306 = !DILocation(line: 958, column: 33, scope: !279)
!307 = !DILocation(line: 958, column: 39, scope: !279)
!308 = !DILocation(line: 958, column: 54, scope: !279)
!309 = !DILocation(line: 958, column: 66, scope: !279)
!310 = !DILocation(line: 958, column: 9, scope: !279)
!311 = !DILocation(line: 958, column: 2, scope: !279)
!312 = distinct !DISubprogram(name: "main", scope: !63, file: !63, line: 29, type: !157, scopeLine: 29, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !191)
!313 = !DILocation(line: 30, column: 5, scope: !312)
!314 = !DILocalVariable(name: "item", scope: !312, file: !63, line: 31, type: !59)
!315 = !DILocation(line: 31, column: 9, scope: !312)
!316 = !DILocation(line: 32, column: 5, scope: !312)
!317 = !DILocalVariable(name: "bytes_written", scope: !318, file: !63, line: 33, type: !167)
!318 = distinct !DILexicalBlock(scope: !312, file: !63, line: 32, column: 16)
!319 = !DILocation(line: 33, column: 16, scope: !318)
!320 = !DILocation(line: 34, column: 27, scope: !318)
!321 = !DILocation(line: 34, column: 76, scope: !318)
!322 = !DILocation(line: 34, column: 9, scope: !318)
!323 = distinct !{!323, !316, !324}
!324 = !DILocation(line: 35, column: 5, scope: !312)
!325 = distinct !DISubprogram(name: "k_pipe_alloc_init", scope: !280, file: !280, line: 912, type: !326, scopeLine: 913, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !191)
!326 = !DISubroutineType(types: !327)
!327 = !{!59, !283, !167}
!328 = !DILocalVariable(name: "pipe", arg: 1, scope: !325, file: !280, line: 912, type: !283)
!329 = !DILocation(line: 912, column: 71, scope: !325)
!330 = !DILocalVariable(name: "size", arg: 2, scope: !325, file: !280, line: 912, type: !167)
!331 = !DILocation(line: 912, column: 84, scope: !325)
!332 = !DILocation(line: 919, column: 2, scope: !325)
!333 = !DILocation(line: 919, column: 2, scope: !334)
!334 = distinct !DILexicalBlock(scope: !325, file: !280, line: 919, column: 2)
!335 = !{i32 -2141854336}
!336 = !DILocation(line: 920, column: 34, scope: !325)
!337 = !DILocation(line: 920, column: 40, scope: !325)
!338 = !DILocation(line: 920, column: 9, scope: !325)
!339 = !DILocation(line: 920, column: 2, scope: !325)
!340 = distinct !DISubprogram(name: "k_pipe_put", scope: !280, file: !280, line: 925, type: !281, scopeLine: 926, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !191)
!341 = !DILocalVariable(name: "pipe", arg: 1, scope: !340, file: !280, line: 925, type: !283)
!342 = !DILocation(line: 925, column: 64, scope: !340)
!343 = !DILocalVariable(name: "data", arg: 2, scope: !340, file: !280, line: 925, type: !58)
!344 = !DILocation(line: 925, column: 77, scope: !340)
!345 = !DILocalVariable(name: "bytes_to_write", arg: 3, scope: !340, file: !280, line: 925, type: !167)
!346 = !DILocation(line: 925, column: 90, scope: !340)
!347 = !DILocalVariable(name: "bytes_written", arg: 4, scope: !340, file: !280, line: 925, type: !284)
!348 = !DILocation(line: 925, column: 115, scope: !340)
!349 = !DILocalVariable(name: "min_xfer", arg: 5, scope: !340, file: !280, line: 925, type: !167)
!350 = !DILocation(line: 925, column: 137, scope: !340)
!351 = !DILocalVariable(name: "timeout", arg: 6, scope: !340, file: !280, line: 925, type: !285)
!352 = !DILocation(line: 925, column: 159, scope: !340)
!353 = !DILocation(line: 938, column: 2, scope: !340)
!354 = !DILocation(line: 938, column: 2, scope: !355)
!355 = distinct !DILexicalBlock(scope: !340, file: !280, line: 938, column: 2)
!356 = !{i32 -2141854268}
!357 = !DILocation(line: 939, column: 27, scope: !340)
!358 = !DILocation(line: 939, column: 33, scope: !340)
!359 = !DILocation(line: 939, column: 39, scope: !340)
!360 = !DILocation(line: 939, column: 55, scope: !340)
!361 = !DILocation(line: 939, column: 70, scope: !340)
!362 = !DILocation(line: 939, column: 9, scope: !340)
!363 = !DILocation(line: 939, column: 2, scope: !340)
