; ModuleID = 'llvm-link'
source_filename = "llvm-link"
target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "thumbv7em-none-unknown-eabi"

%struct.k_heap = type { %struct.sys_heap, %struct._wait_q_t, %struct.k_spinlock }
%struct.sys_heap = type { %struct.z_heap*, i8*, i32 }
%struct.z_heap = type opaque
%struct._wait_q_t = type { %struct._dnode }
%struct._dnode = type { %union.anon.0, %union.anon.0 }
%union.anon.0 = type { %struct._dnode* }
%struct.k_spinlock = type {}
%struct.k_thread = type { %struct._thread_base, %struct._callee_saved, i8*, void ()*, i32, %struct._thread_stack_info, %struct.k_mem_pool*, %struct._thread_arch }
%struct._thread_base = type { %struct._wait_q_t, %struct._wait_q_t*, i8, i8, %union.anon.2, i32, i8*, %struct._timeout, %struct._wait_q_t }
%union.anon.2 = type { i16 }
%struct._timeout = type { %struct._dnode, void (%struct._timeout*)*, i64 }
%struct._callee_saved = type { i32, i32, i32, i32, i32, i32, i32, i32, i32 }
%struct._thread_stack_info = type { i32, i32, i32 }
%struct.k_mem_pool = type { %struct.k_heap* }
%struct._thread_arch = type { i32, i32 }
%struct.z_thread_stack_element = type { i8 }
%struct._static_thread_data = type { %struct.k_thread*, %struct.z_thread_stack_element*, i32, void (i8*, i8*, i8*)*, i8*, i8*, i8*, i32, i32, i32, void ()*, i8* }
%struct.k_timeout_t = type { i64 }

@kheap_shared_heap = dso_local global [2048 x i8] zeroinitializer, align 4, !dbg !0
@shared_heap = dso_local global %struct.k_heap { %struct.sys_heap { %struct.z_heap* null, i8* getelementptr inbounds ([2048 x i8], [2048 x i8]* @kheap_shared_heap, i32 0, i32 0), i32 2048 }, %struct._wait_q_t zeroinitializer, %struct.k_spinlock zeroinitializer }, section "._k_heap.static.shared_heap", align 4, !dbg !56
@_k_thread_obj_thread_a = dso_local global %struct.k_thread zeroinitializer, align 8, !dbg !232
@_k_thread_stack_thread_a = dso_local global [1024 x %struct.z_thread_stack_element] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/static_heap/src/main.c\22.0", align 8, !dbg !227
@_k_thread_data_thread_a = dso_local global %struct._static_thread_data { %struct.k_thread* @_k_thread_obj_thread_a, %struct.z_thread_stack_element* getelementptr inbounds ([1024 x %struct.z_thread_stack_element], [1024 x %struct.z_thread_stack_element]* @_k_thread_stack_thread_a, i32 0, i32 0), i32 1024, void (i8*, i8*, i8*)* @do_stuff, i8* inttoptr (i32 -559038737 to i8*), i8* null, i8* null, i32 7, i32 0, i32 0, void ()* null, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str, i32 0, i32 0) }, section ".__static_thread_data.static._k_thread_data_thread_a", align 4, !dbg !97
@.str = private unnamed_addr constant [9 x i8] c"thread_a\00", align 1
@thread_a = dso_local constant %struct.k_thread* @_k_thread_obj_thread_a, align 4, !dbg !223
@llvm.used = appending global [2 x i8*] [i8* bitcast (%struct.k_heap* @shared_heap to i8*), i8* bitcast (%struct._static_thread_data* @_k_thread_data_thread_a to i8*)], section "llvm.metadata"

; Function Attrs: noinline nounwind optnone
define dso_local void @do_stuff(i8*, i8*, i8*) #0 !dbg !242 {
  %4 = alloca i8*, align 4
  %5 = alloca i8*, align 4
  %6 = alloca i8*, align 4
  %7 = alloca i8*, align 4
  store i8* %0, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !243, metadata !DIExpression()), !dbg !244
  store i8* %1, i8** %5, align 4
  call void @llvm.dbg.declare(metadata i8** %5, metadata !245, metadata !DIExpression()), !dbg !246
  store i8* %2, i8** %6, align 4
  call void @llvm.dbg.declare(metadata i8** %6, metadata !247, metadata !DIExpression()), !dbg !248
  %8 = load i8*, i8** %5, align 4, !dbg !249
  %9 = load i8*, i8** %6, align 4, !dbg !250
  br label %10, !dbg !251

10:                                               ; preds = %10, %3
  call void @llvm.dbg.declare(metadata i8** %7, metadata !252, metadata !DIExpression()), !dbg !254
  %11 = call i8* @k_calloc(i32 123, i32 1) #3, !dbg !255
  store i8* %11, i8** %7, align 4, !dbg !254
  %12 = load i8*, i8** %4, align 4, !dbg !256
  call void @k_heap_free(%struct.k_heap* @shared_heap, i8* %12) #3, !dbg !257
  %13 = load i8*, i8** %7, align 4, !dbg !258
  call void @k_free(i8* %13) #3, !dbg !259
  br label %10, !dbg !251, !llvm.loop !260
}

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

declare dso_local i8* @k_calloc(i32, i32) #2

declare dso_local void @k_heap_free(%struct.k_heap*, i8*) #2

declare dso_local void @k_free(i8*) #2

; Function Attrs: noinline nounwind optnone
define dso_local void @zephyr_dummy_syscall() #0 !dbg !262 {
  ret void, !dbg !263
}

; Function Attrs: noinline nounwind optnone
define dso_local void @sleep_tight(%struct.k_thread*, i8*) #0 !dbg !264 {
  %3 = alloca %struct.k_thread*, align 4
  %4 = alloca i8*, align 4
  store %struct.k_thread* %0, %struct.k_thread** %3, align 4
  call void @llvm.dbg.declare(metadata %struct.k_thread** %3, metadata !267, metadata !DIExpression()), !dbg !268
  store i8* %1, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !269, metadata !DIExpression()), !dbg !270
  ret void, !dbg !271
}

; Function Attrs: noinline nounwind optnone
define dso_local void @main() #0 !dbg !272 {
  %1 = alloca i8*, align 4
  %2 = alloca %struct.k_timeout_t, align 8
  call void @zephyr_dummy_syscall() #3, !dbg !273
  br label %3, !dbg !274

3:                                                ; preds = %3, %0
  call void @llvm.dbg.declare(metadata i8** %1, metadata !275, metadata !DIExpression()), !dbg !277
  %4 = call i8* @k_malloc(i32 123) #3, !dbg !278
  store i8* %4, i8** %1, align 4, !dbg !277
  %5 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !279
  store i64 0, i64* %5, align 8, !dbg !279
  %6 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !280
  %7 = bitcast i64* %6 to [1 x i64]*, !dbg !280
  %8 = load [1 x i64], [1 x i64]* %7, align 8, !dbg !280
  %9 = call i8* @k_heap_alloc(%struct.k_heap* @shared_heap, i32 170, [1 x i64] %8) #3, !dbg !280
  %10 = load i8*, i8** %1, align 4, !dbg !281
  call void @k_free(i8* %10) #3, !dbg !282
  br label %3, !dbg !274, !llvm.loop !283
}

declare dso_local i8* @k_malloc(i32) #2

declare dso_local i8* @k_heap_alloc(%struct.k_heap*, i32, [1 x i64]) #2

attributes #0 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #1 = { nounwind readnone speculatable }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #3 = { nobuiltin }

!llvm.dbg.cu = !{!2}
!llvm.ident = !{!237}
!llvm.module.flags = !{!238, !239, !240, !241}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "kheap_shared_heap", scope: !2, file: !58, line: 10, type: !234, isLocal: false, isDefinition: true, align: 32)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !52, globals: !55, nameTableKind: None)
!3 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/static_heap/src/main.c", directory: "/home/kenny/ara/build/appl/Zephyr/static_heap")
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
!52 = !{!53, !54}
!53 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 32)
!54 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!55 = !{!56, !97, !223, !0, !227, !232}
!56 = !DIGlobalVariableExpression(var: !57, expr: !DIExpression())
!57 = distinct !DIGlobalVariable(name: "shared_heap", scope: !2, file: !58, line: 10, type: !59, isLocal: false, isDefinition: true, align: 32)
!58 = !DIFile(filename: "appl/Zephyr/static_heap/src/main.c", directory: "/home/kenny/ara")
!59 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_heap", file: !60, line: 267, size: 160, elements: !61)
!60 = !DIFile(filename: "zephyrproject/zephyr/include/kernel_structs.h", directory: "/home/kenny")
!61 = !{!62, !74, !94}
!62 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !59, file: !60, line: 268, baseType: !63, size: 96)
!63 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "sys_heap", file: !64, line: 51, size: 96, elements: !65)
!64 = !DIFile(filename: "zephyrproject/zephyr/include/sys/sys_heap.h", directory: "/home/kenny")
!65 = !{!66, !69, !70}
!66 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !63, file: !64, line: 52, baseType: !67, size: 32)
!67 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !68, size: 32)
!68 = !DICompositeType(tag: DW_TAG_structure_type, name: "z_heap", file: !64, line: 52, flags: DIFlagFwdDecl)
!69 = !DIDerivedType(tag: DW_TAG_member, name: "init_mem", scope: !63, file: !64, line: 53, baseType: !53, size: 32, offset: 32)
!70 = !DIDerivedType(tag: DW_TAG_member, name: "init_bytes", scope: !63, file: !64, line: 54, baseType: !71, size: 32, offset: 64)
!71 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !72, line: 46, baseType: !73)
!72 = !DIFile(filename: "/usr/lib/llvm-9/lib/clang/9.0.1/include/stddef.h", directory: "")
!73 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!74 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !59, file: !60, line: 269, baseType: !75, size: 64, offset: 96)
!75 = !DIDerivedType(tag: DW_TAG_typedef, name: "_wait_q_t", file: !60, line: 210, baseType: !76)
!76 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !60, line: 208, size: 64, elements: !77)
!77 = !{!78}
!78 = !DIDerivedType(tag: DW_TAG_member, name: "waitq", scope: !76, file: !60, line: 209, baseType: !79, size: 64)
!79 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dlist_t", file: !80, line: 42, baseType: !81)
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
!94 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !59, file: !60, line: 270, baseType: !95, offset: 160)
!95 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_spinlock", file: !60, line: 234, elements: !96)
!96 = !{}
!97 = !DIGlobalVariableExpression(var: !98, expr: !DIExpression())
!98 = distinct !DIGlobalVariable(name: "_k_thread_data_thread_a", scope: !2, file: !58, line: 23, type: !99, isLocal: false, isDefinition: true, align: 32)
!99 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_static_thread_data", file: !6, line: 1099, size: 384, elements: !100)
!100 = !{!101, !197, !206, !207, !212, !213, !214, !215, !216, !217, !219, !220}
!101 = !DIDerivedType(tag: DW_TAG_member, name: "init_thread", scope: !99, file: !6, line: 1100, baseType: !102, size: 32)
!102 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !103, size: 32)
!103 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_thread", file: !6, line: 570, size: 1024, elements: !104)
!104 = !{!105, !158, !171, !172, !176, !177, !185, !192}
!105 = !DIDerivedType(tag: DW_TAG_member, name: "base", scope: !103, file: !6, line: 572, baseType: !106, size: 448)
!106 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_base", file: !6, line: 441, size: 448, elements: !107)
!107 = !{!108, !122, !124, !127, !128, !141, !143, !144, !157}
!108 = !DIDerivedType(tag: DW_TAG_member, scope: !106, file: !6, line: 444, baseType: !109, size: 64)
!109 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !106, file: !6, line: 444, size: 64, elements: !110)
!110 = !{!111, !113}
!111 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_dlist", scope: !109, file: !6, line: 445, baseType: !112, size: 64)
!112 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dnode_t", file: !80, line: 43, baseType: !81)
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
!123 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !75, size: 32)
!124 = !DIDerivedType(tag: DW_TAG_member, name: "user_options", scope: !106, file: !6, line: 455, baseType: !125, size: 8, offset: 96)
!125 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !126, line: 55, baseType: !7)
!126 = !DIFile(filename: "zephyrproject/zephyr/lib/libc/minimal/include/stdint.h", directory: "/home/kenny")
!127 = !DIDerivedType(tag: DW_TAG_member, name: "thread_state", scope: !106, file: !6, line: 458, baseType: !125, size: 8, offset: 104)
!128 = !DIDerivedType(tag: DW_TAG_member, scope: !106, file: !6, line: 474, baseType: !129, size: 16, offset: 112)
!129 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !106, file: !6, line: 474, size: 16, elements: !130)
!130 = !{!131, !138}
!131 = !DIDerivedType(tag: DW_TAG_member, scope: !129, file: !6, line: 475, baseType: !132, size: 16)
!132 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !129, file: !6, line: 475, size: 16, elements: !133)
!133 = !{!134, !137}
!134 = !DIDerivedType(tag: DW_TAG_member, name: "prio", scope: !132, file: !6, line: 480, baseType: !135, size: 8)
!135 = !DIDerivedType(tag: DW_TAG_typedef, name: "int8_t", file: !126, line: 40, baseType: !136)
!136 = !DIBasicType(name: "signed char", size: 8, encoding: DW_ATE_signed_char)
!137 = !DIDerivedType(tag: DW_TAG_member, name: "sched_locked", scope: !132, file: !6, line: 481, baseType: !125, size: 8, offset: 8)
!138 = !DIDerivedType(tag: DW_TAG_member, name: "preempt", scope: !129, file: !6, line: 484, baseType: !139, size: 16)
!139 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !126, line: 56, baseType: !140)
!140 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!141 = !DIDerivedType(tag: DW_TAG_member, name: "order_key", scope: !106, file: !6, line: 491, baseType: !142, size: 32, offset: 128)
!142 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !126, line: 57, baseType: !73)
!143 = !DIDerivedType(tag: DW_TAG_member, name: "swap_data", scope: !106, file: !6, line: 511, baseType: !53, size: 32, offset: 160)
!144 = !DIDerivedType(tag: DW_TAG_member, name: "timeout", scope: !106, file: !6, line: 515, baseType: !145, size: 192, offset: 192)
!145 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_timeout", file: !60, line: 221, size: 192, elements: !146)
!146 = !{!147, !148, !154}
!147 = !DIDerivedType(tag: DW_TAG_member, name: "node", scope: !145, file: !60, line: 222, baseType: !112, size: 64)
!148 = !DIDerivedType(tag: DW_TAG_member, name: "fn", scope: !145, file: !60, line: 223, baseType: !149, size: 32, offset: 64)
!149 = !DIDerivedType(tag: DW_TAG_typedef, name: "_timeout_func_t", file: !60, line: 219, baseType: !150)
!150 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !151, size: 32)
!151 = !DISubroutineType(types: !152)
!152 = !{null, !153}
!153 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !145, size: 32)
!154 = !DIDerivedType(tag: DW_TAG_member, name: "dticks", scope: !145, file: !60, line: 226, baseType: !155, size: 64, offset: 128)
!155 = !DIDerivedType(tag: DW_TAG_typedef, name: "int64_t", file: !126, line: 43, baseType: !156)
!156 = !DIBasicType(name: "long long int", size: 64, encoding: DW_ATE_signed)
!157 = !DIDerivedType(tag: DW_TAG_member, name: "join_waiters", scope: !106, file: !6, line: 518, baseType: !75, size: 64, offset: 384)
!158 = !DIDerivedType(tag: DW_TAG_member, name: "callee_saved", scope: !103, file: !6, line: 575, baseType: !159, size: 288, offset: 448)
!159 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_callee_saved", file: !160, line: 25, size: 288, elements: !161)
!160 = !DIFile(filename: "zephyrproject/zephyr/include/arch/arm/aarch32/thread.h", directory: "/home/kenny")
!161 = !{!162, !163, !164, !165, !166, !167, !168, !169, !170}
!162 = !DIDerivedType(tag: DW_TAG_member, name: "v1", scope: !159, file: !160, line: 26, baseType: !142, size: 32)
!163 = !DIDerivedType(tag: DW_TAG_member, name: "v2", scope: !159, file: !160, line: 27, baseType: !142, size: 32, offset: 32)
!164 = !DIDerivedType(tag: DW_TAG_member, name: "v3", scope: !159, file: !160, line: 28, baseType: !142, size: 32, offset: 64)
!165 = !DIDerivedType(tag: DW_TAG_member, name: "v4", scope: !159, file: !160, line: 29, baseType: !142, size: 32, offset: 96)
!166 = !DIDerivedType(tag: DW_TAG_member, name: "v5", scope: !159, file: !160, line: 30, baseType: !142, size: 32, offset: 128)
!167 = !DIDerivedType(tag: DW_TAG_member, name: "v6", scope: !159, file: !160, line: 31, baseType: !142, size: 32, offset: 160)
!168 = !DIDerivedType(tag: DW_TAG_member, name: "v7", scope: !159, file: !160, line: 32, baseType: !142, size: 32, offset: 192)
!169 = !DIDerivedType(tag: DW_TAG_member, name: "v8", scope: !159, file: !160, line: 33, baseType: !142, size: 32, offset: 224)
!170 = !DIDerivedType(tag: DW_TAG_member, name: "psp", scope: !159, file: !160, line: 34, baseType: !142, size: 32, offset: 256)
!171 = !DIDerivedType(tag: DW_TAG_member, name: "init_data", scope: !103, file: !6, line: 578, baseType: !53, size: 32, offset: 736)
!172 = !DIDerivedType(tag: DW_TAG_member, name: "fn_abort", scope: !103, file: !6, line: 583, baseType: !173, size: 32, offset: 768)
!173 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !174, size: 32)
!174 = !DISubroutineType(types: !175)
!175 = !{null}
!176 = !DIDerivedType(tag: DW_TAG_member, name: "errno_var", scope: !103, file: !6, line: 610, baseType: !54, size: 32, offset: 800)
!177 = !DIDerivedType(tag: DW_TAG_member, name: "stack_info", scope: !103, file: !6, line: 616, baseType: !178, size: 96, offset: 832)
!178 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_stack_info", file: !6, line: 525, size: 96, elements: !179)
!179 = !{!180, !183, !184}
!180 = !DIDerivedType(tag: DW_TAG_member, name: "start", scope: !178, file: !6, line: 529, baseType: !181, size: 32)
!181 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintptr_t", file: !126, line: 71, baseType: !182)
!182 = !DIBasicType(name: "long unsigned int", size: 32, encoding: DW_ATE_unsigned)
!183 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !178, file: !6, line: 538, baseType: !71, size: 32, offset: 32)
!184 = !DIDerivedType(tag: DW_TAG_member, name: "delta", scope: !178, file: !6, line: 544, baseType: !71, size: 32, offset: 64)
!185 = !DIDerivedType(tag: DW_TAG_member, name: "resource_pool", scope: !103, file: !6, line: 641, baseType: !186, size: 32, offset: 928)
!186 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !187, size: 32)
!187 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mem_pool", file: !188, line: 30, size: 32, elements: !189)
!188 = !DIFile(filename: "zephyrproject/zephyr/include/mempool_heap.h", directory: "/home/kenny")
!189 = !{!190}
!190 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !187, file: !188, line: 31, baseType: !191, size: 32)
!191 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !59, size: 32)
!192 = !DIDerivedType(tag: DW_TAG_member, name: "arch", scope: !103, file: !6, line: 644, baseType: !193, size: 64, offset: 960)
!193 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_arch", file: !160, line: 60, size: 64, elements: !194)
!194 = !{!195, !196}
!195 = !DIDerivedType(tag: DW_TAG_member, name: "basepri", scope: !193, file: !160, line: 63, baseType: !142, size: 32)
!196 = !DIDerivedType(tag: DW_TAG_member, name: "swap_return_value", scope: !193, file: !160, line: 66, baseType: !142, size: 32, offset: 32)
!197 = !DIDerivedType(tag: DW_TAG_member, name: "init_stack", scope: !99, file: !6, line: 1101, baseType: !198, size: 32, offset: 32)
!198 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !199, size: 32)
!199 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_stack_t", file: !200, line: 44, baseType: !201)
!200 = !DIFile(filename: "zephyrproject/zephyr/include/sys/arch_interface.h", directory: "/home/kenny")
!201 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "z_thread_stack_element", file: !202, line: 35, size: 8, elements: !203)
!202 = !DIFile(filename: "zephyrproject/zephyr/include/sys/thread_stack.h", directory: "/home/kenny")
!203 = !{!204}
!204 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !201, file: !202, line: 36, baseType: !205, size: 8)
!205 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_unsigned_char)
!206 = !DIDerivedType(tag: DW_TAG_member, name: "init_stack_size", scope: !99, file: !6, line: 1102, baseType: !73, size: 32, offset: 64)
!207 = !DIDerivedType(tag: DW_TAG_member, name: "init_entry", scope: !99, file: !6, line: 1103, baseType: !208, size: 32, offset: 96)
!208 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_entry_t", file: !200, line: 46, baseType: !209)
!209 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !210, size: 32)
!210 = !DISubroutineType(types: !211)
!211 = !{null, !53, !53, !53}
!212 = !DIDerivedType(tag: DW_TAG_member, name: "init_p1", scope: !99, file: !6, line: 1104, baseType: !53, size: 32, offset: 128)
!213 = !DIDerivedType(tag: DW_TAG_member, name: "init_p2", scope: !99, file: !6, line: 1105, baseType: !53, size: 32, offset: 160)
!214 = !DIDerivedType(tag: DW_TAG_member, name: "init_p3", scope: !99, file: !6, line: 1106, baseType: !53, size: 32, offset: 192)
!215 = !DIDerivedType(tag: DW_TAG_member, name: "init_prio", scope: !99, file: !6, line: 1107, baseType: !54, size: 32, offset: 224)
!216 = !DIDerivedType(tag: DW_TAG_member, name: "init_options", scope: !99, file: !6, line: 1108, baseType: !142, size: 32, offset: 256)
!217 = !DIDerivedType(tag: DW_TAG_member, name: "init_delay", scope: !99, file: !6, line: 1109, baseType: !218, size: 32, offset: 288)
!218 = !DIDerivedType(tag: DW_TAG_typedef, name: "int32_t", file: !126, line: 42, baseType: !54)
!219 = !DIDerivedType(tag: DW_TAG_member, name: "init_abort", scope: !99, file: !6, line: 1110, baseType: !173, size: 32, offset: 320)
!220 = !DIDerivedType(tag: DW_TAG_member, name: "init_name", scope: !99, file: !6, line: 1111, baseType: !221, size: 32, offset: 352)
!221 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !222, size: 32)
!222 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !205)
!223 = !DIGlobalVariableExpression(var: !224, expr: !DIExpression())
!224 = distinct !DIGlobalVariable(name: "thread_a", scope: !2, file: !58, line: 23, type: !225, isLocal: false, isDefinition: true)
!225 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !226)
!226 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_tid_t", file: !6, line: 648, baseType: !102)
!227 = !DIGlobalVariableExpression(var: !228, expr: !DIExpression())
!228 = distinct !DIGlobalVariable(name: "_k_thread_stack_thread_a", scope: !2, file: !58, line: 23, type: !229, isLocal: false, isDefinition: true, align: 64)
!229 = !DICompositeType(tag: DW_TAG_array_type, baseType: !201, size: 8192, elements: !230)
!230 = !{!231}
!231 = !DISubrange(count: 1024)
!232 = !DIGlobalVariableExpression(var: !233, expr: !DIExpression())
!233 = distinct !DIGlobalVariable(name: "_k_thread_obj_thread_a", scope: !2, file: !58, line: 23, type: !103, isLocal: false, isDefinition: true)
!234 = !DICompositeType(tag: DW_TAG_array_type, baseType: !205, size: 16384, elements: !235)
!235 = !{!236}
!236 = !DISubrange(count: 2048)
!237 = !{!"clang version 9.0.1-12 "}
!238 = !{i32 2, !"Dwarf Version", i32 4}
!239 = !{i32 2, !"Debug Info Version", i32 3}
!240 = !{i32 1, !"wchar_size", i32 4}
!241 = !{i32 1, !"min_enum_size", i32 1}
!242 = distinct !DISubprogram(name: "do_stuff", scope: !58, file: !58, line: 12, type: !210, scopeLine: 13, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !96)
!243 = !DILocalVariable(name: "mem_1", arg: 1, scope: !242, file: !58, line: 12, type: !53)
!244 = !DILocation(line: 12, column: 21, scope: !242)
!245 = !DILocalVariable(name: "dummy2", arg: 2, scope: !242, file: !58, line: 12, type: !53)
!246 = !DILocation(line: 12, column: 34, scope: !242)
!247 = !DILocalVariable(name: "dummy3", arg: 3, scope: !242, file: !58, line: 12, type: !53)
!248 = !DILocation(line: 12, column: 48, scope: !242)
!249 = !DILocation(line: 14, column: 2, scope: !242)
!250 = !DILocation(line: 15, column: 2, scope: !242)
!251 = !DILocation(line: 16, column: 9, scope: !242)
!252 = !DILocalVariable(name: "chunk", scope: !253, file: !58, line: 17, type: !53)
!253 = distinct !DILexicalBlock(scope: !242, file: !58, line: 16, column: 20)
!254 = !DILocation(line: 17, column: 19, scope: !253)
!255 = !DILocation(line: 17, column: 27, scope: !253)
!256 = !DILocation(line: 18, column: 39, scope: !253)
!257 = !DILocation(line: 18, column: 13, scope: !253)
!258 = !DILocation(line: 19, column: 20, scope: !253)
!259 = !DILocation(line: 19, column: 13, scope: !253)
!260 = distinct !{!260, !251, !261}
!261 = !DILocation(line: 20, column: 9, scope: !242)
!262 = distinct !DISubprogram(name: "zephyr_dummy_syscall", scope: !58, file: !58, line: 26, type: !174, scopeLine: 26, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !96)
!263 = !DILocation(line: 26, column: 29, scope: !262)
!264 = distinct !DISubprogram(name: "sleep_tight", scope: !58, file: !58, line: 28, type: !265, scopeLine: 28, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !96)
!265 = !DISubroutineType(types: !266)
!266 = !{null, !102, !53}
!267 = !DILocalVariable(name: "t", arg: 1, scope: !264, file: !58, line: 28, type: !102)
!268 = !DILocation(line: 28, column: 35, scope: !264)
!269 = !DILocalVariable(name: "data", arg: 2, scope: !264, file: !58, line: 28, type: !53)
!270 = !DILocation(line: 28, column: 44, scope: !264)
!271 = !DILocation(line: 29, column: 1, scope: !264)
!272 = distinct !DISubprogram(name: "main", scope: !58, file: !58, line: 31, type: !174, scopeLine: 31, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !96)
!273 = !DILocation(line: 32, column: 5, scope: !272)
!274 = !DILocation(line: 34, column: 5, scope: !272)
!275 = !DILocalVariable(name: "chunk", scope: !276, file: !58, line: 35, type: !53)
!276 = distinct !DILexicalBlock(scope: !272, file: !58, line: 34, column: 16)
!277 = !DILocation(line: 35, column: 15, scope: !276)
!278 = !DILocation(line: 35, column: 23, scope: !276)
!279 = !DILocation(line: 36, column: 42, scope: !276)
!280 = !DILocation(line: 36, column: 9, scope: !276)
!281 = !DILocation(line: 37, column: 16, scope: !276)
!282 = !DILocation(line: 37, column: 9, scope: !276)
!283 = distinct !{!283, !274, !284}
!284 = !DILocation(line: 38, column: 5, scope: !272)
