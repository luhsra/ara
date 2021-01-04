; ModuleID = 'llvm-link'
source_filename = "llvm-link"
target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "thumbv7em-none-unknown-eabi"

; Function Attrs: norecurse nounwind optsize readnone
define dso_local void @main() local_unnamed_addr #0 !dbg !58 {
  ret void, !dbg !63
}

attributes #0 = { norecurse nounwind optsize readnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }

!llvm.dbg.cu = !{!0}
!llvm.ident = !{!53}
!llvm.module.flags = !{!54, !55, !56, !57}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 9.0.1-12 ", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !50, nameTableKind: None)
!1 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/minimal/src/main.c", directory: "/home/kenny/ara/build/appl/Zephyr/minimal")
!2 = !{!3}
!3 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "k_objects", file: !4, line: 121, baseType: !5, size: 8, elements: !6)
!4 = !DIFile(filename: "zephyrproject/zephyr/include/kernel.h", directory: "/home/kenny")
!5 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!6 = !{!7, !8, !9, !10, !11, !12, !13, !14, !15, !16, !17, !18, !19, !20, !21, !22, !23, !24, !25, !26, !27, !28, !29, !30, !31, !32, !33, !34, !35, !36, !37, !38, !39, !40, !41, !42, !43, !44, !45, !46, !47, !48, !49}
!7 = !DIEnumerator(name: "K_OBJ_ANY", value: 0, isUnsigned: true)
!8 = !DIEnumerator(name: "K_OBJ_MEM_SLAB", value: 1, isUnsigned: true)
!9 = !DIEnumerator(name: "K_OBJ_MSGQ", value: 2, isUnsigned: true)
!10 = !DIEnumerator(name: "K_OBJ_MUTEX", value: 3, isUnsigned: true)
!11 = !DIEnumerator(name: "K_OBJ_PIPE", value: 4, isUnsigned: true)
!12 = !DIEnumerator(name: "K_OBJ_QUEUE", value: 5, isUnsigned: true)
!13 = !DIEnumerator(name: "K_OBJ_POLL_SIGNAL", value: 6, isUnsigned: true)
!14 = !DIEnumerator(name: "K_OBJ_SEM", value: 7, isUnsigned: true)
!15 = !DIEnumerator(name: "K_OBJ_STACK", value: 8, isUnsigned: true)
!16 = !DIEnumerator(name: "K_OBJ_THREAD", value: 9, isUnsigned: true)
!17 = !DIEnumerator(name: "K_OBJ_TIMER", value: 10, isUnsigned: true)
!18 = !DIEnumerator(name: "K_OBJ_THREAD_STACK_ELEMENT", value: 11, isUnsigned: true)
!19 = !DIEnumerator(name: "K_OBJ_NET_SOCKET", value: 12, isUnsigned: true)
!20 = !DIEnumerator(name: "K_OBJ_NET_IF", value: 13, isUnsigned: true)
!21 = !DIEnumerator(name: "K_OBJ_SYS_MUTEX", value: 14, isUnsigned: true)
!22 = !DIEnumerator(name: "K_OBJ_FUTEX", value: 15, isUnsigned: true)
!23 = !DIEnumerator(name: "K_OBJ_DRIVER_PTP_CLOCK", value: 16, isUnsigned: true)
!24 = !DIEnumerator(name: "K_OBJ_DRIVER_CRYPTO", value: 17, isUnsigned: true)
!25 = !DIEnumerator(name: "K_OBJ_DRIVER_ADC", value: 18, isUnsigned: true)
!26 = !DIEnumerator(name: "K_OBJ_DRIVER_CAN", value: 19, isUnsigned: true)
!27 = !DIEnumerator(name: "K_OBJ_DRIVER_COUNTER", value: 20, isUnsigned: true)
!28 = !DIEnumerator(name: "K_OBJ_DRIVER_DAC", value: 21, isUnsigned: true)
!29 = !DIEnumerator(name: "K_OBJ_DRIVER_DMA", value: 22, isUnsigned: true)
!30 = !DIEnumerator(name: "K_OBJ_DRIVER_EC_HOST_CMD_PERIPH_API", value: 23, isUnsigned: true)
!31 = !DIEnumerator(name: "K_OBJ_DRIVER_EEPROM", value: 24, isUnsigned: true)
!32 = !DIEnumerator(name: "K_OBJ_DRIVER_ENTROPY", value: 25, isUnsigned: true)
!33 = !DIEnumerator(name: "K_OBJ_DRIVER_ESPI", value: 26, isUnsigned: true)
!34 = !DIEnumerator(name: "K_OBJ_DRIVER_FLASH", value: 27, isUnsigned: true)
!35 = !DIEnumerator(name: "K_OBJ_DRIVER_GPIO", value: 28, isUnsigned: true)
!36 = !DIEnumerator(name: "K_OBJ_DRIVER_I2C", value: 29, isUnsigned: true)
!37 = !DIEnumerator(name: "K_OBJ_DRIVER_I2S", value: 30, isUnsigned: true)
!38 = !DIEnumerator(name: "K_OBJ_DRIVER_IPM", value: 31, isUnsigned: true)
!39 = !DIEnumerator(name: "K_OBJ_DRIVER_KSCAN", value: 32, isUnsigned: true)
!40 = !DIEnumerator(name: "K_OBJ_DRIVER_LED", value: 33, isUnsigned: true)
!41 = !DIEnumerator(name: "K_OBJ_DRIVER_PINMUX", value: 34, isUnsigned: true)
!42 = !DIEnumerator(name: "K_OBJ_DRIVER_PS2", value: 35, isUnsigned: true)
!43 = !DIEnumerator(name: "K_OBJ_DRIVER_PWM", value: 36, isUnsigned: true)
!44 = !DIEnumerator(name: "K_OBJ_DRIVER_SENSOR", value: 37, isUnsigned: true)
!45 = !DIEnumerator(name: "K_OBJ_DRIVER_SPI", value: 38, isUnsigned: true)
!46 = !DIEnumerator(name: "K_OBJ_DRIVER_UART", value: 39, isUnsigned: true)
!47 = !DIEnumerator(name: "K_OBJ_DRIVER_WDT", value: 40, isUnsigned: true)
!48 = !DIEnumerator(name: "K_OBJ_DRIVER_UART_MUX", value: 41, isUnsigned: true)
!49 = !DIEnumerator(name: "K_OBJ_LAST", value: 42, isUnsigned: true)
!50 = !{!51, !52}
!51 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 32)
!52 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!53 = !{!"clang version 9.0.1-12 "}
!54 = !{i32 2, !"Dwarf Version", i32 4}
!55 = !{i32 2, !"Debug Info Version", i32 3}
!56 = !{i32 1, !"wchar_size", i32 4}
!57 = !{i32 1, !"min_enum_size", i32 1}
!58 = distinct !DISubprogram(name: "main", scope: !59, file: !59, line: 9, type: !60, scopeLine: 10, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !62)
!59 = !DIFile(filename: "appl/Zephyr/minimal/src/main.c", directory: "/home/kenny/ara")
!60 = !DISubroutineType(types: !61)
!61 = !{null}
!62 = !{}
!63 = !DILocation(line: 11, column: 1, scope: !58)
