; ModuleID = 'build/appl/AUTOSAR/autosar_singlecore_bcc1_sse1_a.riscv.ll'
source_filename = "../appl/AUTOSAR/singlecore/bcc1/sse1/a.cc"
target datalayout = "e-m:e-p:32:32-i64:64-n32-S128"
target triple = "riscv32-unknown-unknown-elf"

$_ZN7Machine8shutdownEv = comdat any

@AUTOSAR_TASK_H4 = external dso_local constant i32, align 4
@.str = private unnamed_addr constant [5 x i8] c"54+4\00", align 1
@trace_table_idx = external dso_local global i8, align 1
@experiment_number = external dso_local global i32, align 4
@global_all_ok = external dso_local global i8, align 1

; Function Attrs: mustprogress noinline norecurse nounwind
define dso_local noundef i32 @main() #0 !dbg !9 {
entry:
  call void @arch_startup()
  %atomic-temp.i = alloca i8, align 1
  %atomic-temp1.i = alloca i32, align 4
  %atomic-temp2.i = alloca i8, align 1
  br label %BB0, !dbg !14

BB0:                                              ; preds = %entry
  %call = call i32 @AUTOSAR_GetCoreID(), !dbg !14
  br label %BB1, !dbg !14

BB1:                                              ; preds = %BB0
  %cmp = icmp eq i32 %call, 0, !dbg !14
  br i1 %cmp, label %if.then, label %if.end, !dbg !16

if.then:                                          ; preds = %BB1
  store i8 0, i8* %atomic-temp.i, align 1, !dbg !17
  br label %BB2, !dbg !17

BB2:                                              ; preds = %if.then
  call void @__atomic_store(i32 noundef 1, i8* noundef @trace_table_idx, i8* noundef %atomic-temp.i, i32 noundef 5) #6, !dbg !17
  br label %BB3, !dbg !24

BB3:                                              ; preds = %BB2
  store i32 0, i32* %atomic-temp1.i, align 4, !dbg !24
  %0 = bitcast i32* %atomic-temp1.i to i8*, !dbg !24
  br label %BB4, !dbg !24

BB4:                                              ; preds = %BB3
  call void @__atomic_store(i32 noundef 4, i8* noundef bitcast (i32* @experiment_number to i8*), i8* noundef %0, i32 noundef 5) #6, !dbg !24
  br label %BB5, !dbg !25

BB5:                                              ; preds = %BB4
  store i8 1, i8* %atomic-temp2.i, align 1, !dbg !25
  br label %BB6, !dbg !25

BB6:                                              ; preds = %BB5
  call void @__atomic_store(i32 noundef 1, i8* noundef @global_all_ok, i8* noundef %atomic-temp2.i, i32 noundef 5) #6, !dbg !25
  br label %BB7, !dbg !26

BB7:                                              ; preds = %BB6
  br i1 icmp ne (void ()* @test_prepare, void ()* null), label %if.then.i, label %if.end, !dbg !26

if.then.i:                                        ; preds = %BB7
  br label %BB8, !dbg !27

BB8:                                              ; preds = %if.then.i
  call void @test_prepare() #6, !dbg !27
  br label %BB9, !dbg !30

BB9:                                              ; preds = %BB8
  br label %if.end, !dbg !30

if.end:                                           ; preds = %BB7, %BB9, %BB1
  br label %BB10, !dbg !16

BB10:                                             ; preds = %if.end
  call void @AUTOSAR_StartOS(i32 noundef 0), !dbg !16
  br label %BB11, !dbg !16

BB11:                                             ; preds = %BB10
  ret i32 0, !dbg !16
}

declare dso_local i32 @AUTOSAR_GetCoreID() #1

declare dso_local void @AUTOSAR_StartOS(i32 noundef) #1

; Function Attrs: mustprogress noinline nounwind
define dso_local void @AUTOSAR_TASK_FUNC_H1() #2 !dbg !31 {
entry:
  call void @AUTOSAR_kickoff(), !dbg !32
  br label %BB12, !dbg !32

BB12:                                             ; preds = %entry
  call void @test_trace(i8 noundef zeroext 49), !dbg !32
  br label %BB13

BB13:                                             ; preds = %BB12
  call void @llvm.donothing()
  br label %BB14, !dbg !33

BB14:                                             ; preds = %BB13
  %call = call i32 @AUTOSAR_TerminateTask_BB14(), !dbg !33
  br label %BB15, !dbg !34

BB15:                                             ; preds = %BB14
  call void @__OS_HOOK_ErrorHook(i32 14), !dbg !34
  ret void, !dbg !34
}

declare dso_local void @test_trace(i8 noundef zeroext) #1

declare dso_local i32 @AUTOSAR_TerminateTask() #1

; Function Attrs: mustprogress noinline nounwind
define dso_local void @AUTOSAR_TASK_FUNC_H2() #2 !dbg !35 {
entry:
  call void @AUTOSAR_kickoff(), !dbg !36
  br label %BB16, !dbg !36

BB16:                                             ; preds = %entry
  call void @test_trace(i8 noundef zeroext 50), !dbg !36
  br label %BB17

BB17:                                             ; preds = %BB16
  call void @llvm.donothing()
  br label %BB18, !dbg !37

BB18:                                             ; preds = %BB17
  %call = call i32 @AUTOSAR_TerminateTask_BB18(), !dbg !37
  br label %BB19, !dbg !38

BB19:                                             ; preds = %BB18
  call void @__OS_HOOK_ErrorHook(i32 14), !dbg !38
  ret void, !dbg !38
}

; Function Attrs: mustprogress noinline nounwind
define dso_local void @AUTOSAR_TASK_FUNC_H3() #2 !dbg !39 {
entry:
  call void @AUTOSAR_kickoff(), !dbg !40
  br label %BB20, !dbg !40

BB20:                                             ; preds = %entry
  call void @test_trace(i8 noundef zeroext 51), !dbg !40
  br label %BB21

BB21:                                             ; preds = %BB20
  call void @llvm.donothing()
  br label %BB22, !dbg !41

BB22:                                             ; preds = %BB21
  %call = call i32 @AUTOSAR_TerminateTask_BB22(), !dbg !41
  br label %BB23, !dbg !42

BB23:                                             ; preds = %BB22
  call void @__OS_HOOK_ErrorHook(i32 14), !dbg !42
  ret void, !dbg !42
}

; Function Attrs: mustprogress noinline nounwind
define dso_local void @AUTOSAR_TASK_FUNC_H4() #2 !dbg !43 {
entry:
  call void @AUTOSAR_kickoff(), !dbg !44
  br label %BB24, !dbg !44

BB24:                                             ; preds = %entry
  call void @test_trace(i8 noundef zeroext 52), !dbg !44
  br label %BB25

BB25:                                             ; preds = %BB24
  call void @llvm.donothing()
  br label %BB26, !dbg !45

BB26:                                             ; preds = %BB25
  %call = call i32 @AUTOSAR_TerminateTask_BB26(), !dbg !45
  br label %BB27, !dbg !46

BB27:                                             ; preds = %BB26
  call void @__OS_HOOK_ErrorHook(i32 14), !dbg !46
  ret void, !dbg !46
}

; Function Attrs: mustprogress noinline nounwind
define dso_local void @AUTOSAR_TASK_FUNC_H5() #2 !dbg !47 {
entry:
  call void @AUTOSAR_kickoff(), !dbg !48
  br label %BB28, !dbg !48

BB28:                                             ; preds = %entry
  call void @test_trace(i8 noundef zeroext 53), !dbg !48
  br label %BB29, !dbg !49

BB29:                                             ; preds = %BB28
  %0 = load i32, i32* @AUTOSAR_TASK_H4, align 4, !dbg !49
  br label %BB30, !dbg !49

BB30:                                             ; preds = %BB29
  %call = call i32 @AUTOSAR_ActivateTask_BB30(i32 noundef %0), !dbg !49
  br label %BB31

BB31:                                             ; preds = %BB30
  call void @llvm.donothing()
  br label %BB32, !dbg !50

BB32:                                             ; preds = %BB31
  call void @test_trace(i8 noundef zeroext 43), !dbg !50
  br label %BB33

BB33:                                             ; preds = %BB32
  call void @llvm.donothing()
  br label %BB34, !dbg !51

BB34:                                             ; preds = %BB33
  %call1 = call i32 @AUTOSAR_ChainTask_BB34(i32 noundef %0), !dbg !51
  br label %BB35, !dbg !52

BB35:                                             ; preds = %BB34
  call void @__OS_HOOK_ErrorHook(i32 14), !dbg !52
  ret void, !dbg !52
}

declare dso_local i32 @AUTOSAR_ActivateTask(i32 noundef) #1

declare dso_local i32 @AUTOSAR_ChainTask(i32 noundef) #1

; Function Attrs: alwaysinline mustprogress nounwind
define dso_local void @__OS_HOOK_DEFINED_PreIdleHook() #3 !dbg !53 {
entry:
  %0 = getelementptr inbounds [5 x i8], [5 x i8]* @.str, i32 0, i32 0
  br label %BB36, !dbg !54

BB36:                                             ; preds = %entry
  call void @test_trace_assert(i8* noundef %0), !dbg !54
  br label %BB37

BB37:                                             ; preds = %BB36
  call void @llvm.donothing()
  br label %BB38, !dbg !55

BB38:                                             ; preds = %BB37
  call void @test_finish(i32 noundef 0), !dbg !55
  br label %BB39

BB39:                                             ; preds = %BB38
  call void @llvm.donothing()
  br label %BB40, !dbg !56

BB40:                                             ; preds = %BB39
  call void @_ZN7Machine8shutdownEv() #6, !dbg !56
  br label %BB41, !dbg !60

BB41:                                             ; preds = %BB40
  ret void, !dbg !60
}

declare dso_local void @test_trace_assert(i8* noundef) #1

declare dso_local void @test_finish(i32 noundef) #1

; Function Attrs: nounwind willreturn
declare dso_local void @__atomic_store(i32, i8*, i8*, i32) #4

declare extern_weak dso_local void @test_prepare() #1

; Function Attrs: mustprogress noinline nounwind
define linkonce_odr dso_local void @_ZN7Machine8shutdownEv() #2 comdat align 2 !dbg !61 {
entry:
  br label %BB42, !dbg !106

BB42:                                             ; preds = %entry
  call void @_Z13htif_poweroffv(), !dbg !106
  br label %BB43, !dbg !107

BB43:                                             ; preds = %BB42
  ret void, !dbg !107
}

declare dso_local void @_Z13htif_poweroffv() #1

define i32 @__ara_fake_entry() {
entry:
  br label %BB44

BB44:                                             ; preds = %entry
  %old_entry = call i32 @main()
  br label %BB45

BB45:                                             ; preds = %BB44
  ret i32 0
}

; Function Attrs: nofree nosync nounwind readnone willreturn
declare void @llvm.donothing() #5

declare void @AUTOSAR_kickoff()

declare void @arch_startup()

declare void @__OS_HOOK_ErrorHook(i32)

declare i32 @AUTOSAR_TerminateTask_BB14()

declare i32 @AUTOSAR_TerminateTask_BB18()

declare i32 @AUTOSAR_TerminateTask_BB22()

declare i32 @AUTOSAR_TerminateTask_BB26()

declare i32 @AUTOSAR_ActivateTask_BB30(i32)

declare i32 @AUTOSAR_ChainTask_BB34(i32)

attributes #0 = { mustprogress noinline norecurse nounwind "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #1 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #2 = { mustprogress noinline nounwind "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #3 = { alwaysinline mustprogress nounwind "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #4 = { nounwind willreturn }
attributes #5 = { nofree nosync nounwind readnone willreturn }
attributes #6 = { nounwind }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2, !3, !4, !5, !6, !7}
!llvm.ident = !{!8}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_11, file: !1, producer: "Debian clang version 14.0.6", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "../appl/AUTOSAR/singlecore/bcc1/sse1/a.cc", directory: "/srv/scratch/arv.bloecker/ara/build", checksumkind: CSK_MD5, checksum: "5fa77e1f658655241bd3e1411c709200")
!2 = !{i32 7, !"Dwarf Version", i32 5}
!3 = !{i32 2, !"Debug Info Version", i32 3}
!4 = !{i32 1, !"wchar_size", i32 4}
!5 = !{i32 1, !"target-abi", !"ilp32"}
!6 = !{i32 7, !"frame-pointer", i32 2}
!7 = !{i32 1, !"SmallDataLimit", i32 8}
!8 = !{!"Debian clang version 14.0.6"}
!9 = distinct !DISubprogram(name: "main", scope: !1, file: !1, line: 11, type: !10, scopeLine: 11, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !13)
!10 = !DISubroutineType(types: !11)
!11 = !{!12}
!12 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!13 = !{}
!14 = !DILocation(line: 11, column: 1, scope: !15)
!15 = distinct !DILexicalBlock(scope: !9, file: !1, line: 11, column: 1)
!16 = !DILocation(line: 11, column: 1, scope: !9)
!17 = !DILocation(line: 247, column: 18, scope: !18, inlinedAt: !22)
!18 = distinct !DISubprogram(name: "test_init", linkageName: "_ZL9test_initv", scope: !19, file: !19, line: 245, type: !20, scopeLine: 245, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !0, retainedNodes: !13)
!19 = !DIFile(filename: "libs/autosar/test/test.h", directory: "/srv/scratch/arv.bloecker/ara", checksumkind: CSK_MD5, checksum: "ac064b6c13910baa8931888fd9f3bc6b")
!20 = !DISubroutineType(types: !21)
!21 = !{null}
!22 = distinct !DILocation(line: 11, column: 1, scope: !23)
!23 = distinct !DILexicalBlock(scope: !15, file: !1, line: 11, column: 1)
!24 = !DILocation(line: 248, column: 20, scope: !18, inlinedAt: !22)
!25 = !DILocation(line: 249, column: 16, scope: !18, inlinedAt: !22)
!26 = !DILocation(line: 250, column: 6, scope: !18, inlinedAt: !22)
!27 = !DILocation(line: 251, column: 3, scope: !28, inlinedAt: !22)
!28 = distinct !DILexicalBlock(scope: !29, file: !19, line: 250, column: 25)
!29 = distinct !DILexicalBlock(scope: !18, file: !19, line: 250, column: 6)
!30 = !DILocation(line: 252, column: 2, scope: !28, inlinedAt: !22)
!31 = distinct !DISubprogram(name: "AUTOSAR_TASK_FUNC_H1", scope: !1, file: !1, line: 13, type: !20, scopeLine: 13, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !13)
!32 = !DILocation(line: 14, column: 2, scope: !31)
!33 = !DILocation(line: 15, column: 2, scope: !31)
!34 = !DILocation(line: 16, column: 1, scope: !31)
!35 = distinct !DISubprogram(name: "AUTOSAR_TASK_FUNC_H2", scope: !1, file: !1, line: 18, type: !20, scopeLine: 18, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !13)
!36 = !DILocation(line: 19, column: 2, scope: !35)
!37 = !DILocation(line: 20, column: 2, scope: !35)
!38 = !DILocation(line: 21, column: 1, scope: !35)
!39 = distinct !DISubprogram(name: "AUTOSAR_TASK_FUNC_H3", scope: !1, file: !1, line: 23, type: !20, scopeLine: 23, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !13)
!40 = !DILocation(line: 24, column: 2, scope: !39)
!41 = !DILocation(line: 25, column: 2, scope: !39)
!42 = !DILocation(line: 26, column: 1, scope: !39)
!43 = distinct !DISubprogram(name: "AUTOSAR_TASK_FUNC_H4", scope: !1, file: !1, line: 28, type: !20, scopeLine: 28, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !13)
!44 = !DILocation(line: 29, column: 2, scope: !43)
!45 = !DILocation(line: 30, column: 2, scope: !43)
!46 = !DILocation(line: 31, column: 1, scope: !43)
!47 = distinct !DISubprogram(name: "AUTOSAR_TASK_FUNC_H5", scope: !1, file: !1, line: 33, type: !20, scopeLine: 33, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !13)
!48 = !DILocation(line: 34, column: 2, scope: !47)
!49 = !DILocation(line: 35, column: 2, scope: !47)
!50 = !DILocation(line: 36, column: 2, scope: !47)
!51 = !DILocation(line: 37, column: 2, scope: !47)
!52 = !DILocation(line: 38, column: 1, scope: !47)
!53 = distinct !DISubprogram(name: "__OS_HOOK_DEFINED_PreIdleHook", scope: !1, file: !1, line: 40, type: !20, scopeLine: 40, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !13)
!54 = !DILocation(line: 42, column: 2, scope: !53)
!55 = !DILocation(line: 43, column: 2, scope: !53)
!56 = !DILocation(line: 20, column: 49, scope: !57, inlinedAt: !59)
!57 = distinct !DISubprogram(name: "ShutdownMachine", linkageName: "_ZL15ShutdownMachinev", scope: !58, file: !58, line: 20, type: !20, scopeLine: 20, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !0, retainedNodes: !13)
!58 = !DIFile(filename: "libs/autosar/os/helper.h", directory: "/srv/scratch/arv.bloecker/ara", checksumkind: CSK_MD5, checksum: "2e07380def8eafa68b60e856fa891561")
!59 = distinct !DILocation(line: 44, column: 2, scope: !53)
!60 = !DILocation(line: 45, column: 1, scope: !53)
!61 = distinct !DISubprogram(name: "shutdown", linkageName: "_ZN7Machine8shutdownEv", scope: !63, file: !62, line: 99, type: !20, scopeLine: 99, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, declaration: !88, retainedNodes: !13)
!62 = !DIFile(filename: "libs/autosar/arch/riscv/machine.h", directory: "/srv/scratch/arv.bloecker/ara", checksumkind: CSK_MD5, checksum: "a4570db6f0f25a35488af6cb77b5147a")
!63 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "Machine", file: !62, line: 31, size: 8, flags: DIFlagTypePassByValue, elements: !64, identifier: "_ZTS7Machine")
!64 = !{!65, !69, !70, !71, !72, !76, !77, !82, !86, !87, !88, !89, !90, !94, !98, !103, !104, !105}
!65 = !DIDerivedType(tag: DW_TAG_member, name: "soft_irq_cause", scope: !63, file: !62, line: 34, baseType: !66, flags: DIFlagPublic | DIFlagStaticMember)
!66 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint64_t", file: !67, line: 53, baseType: !68)
!67 = !DIFile(filename: "libs/autosar/arch/generic/stdint.h", directory: "/srv/scratch/arv.bloecker/ara", checksumkind: CSK_MD5, checksum: "481e0b8c3eee4af0dcbe2564d54bf201")
!68 = !DIBasicType(name: "unsigned long long", size: 64, encoding: DW_ATE_unsigned)
!69 = !DISubprogram(name: "init", linkageName: "_ZN7Machine4initEv", scope: !63, file: !62, line: 36, type: !20, scopeLine: 36, flags: DIFlagPublic | DIFlagPrototyped | DIFlagStaticMember, spFlags: 0)
!70 = !DISubprogram(name: "nop", linkageName: "_ZN7Machine3nopEv", scope: !63, file: !62, line: 42, type: !20, scopeLine: 42, flags: DIFlagPublic | DIFlagPrototyped | DIFlagStaticMember, spFlags: 0)
!71 = !DISubprogram(name: "debug_trap", linkageName: "_ZN7Machine10debug_trapEv", scope: !63, file: !62, line: 50, type: !20, scopeLine: 50, flags: DIFlagPublic | DIFlagPrototyped | DIFlagStaticMember, spFlags: 0)
!72 = !DISubprogram(name: "disable_interrupts", linkageName: "_ZN7Machine18disable_interruptsEv", scope: !63, file: !62, line: 56, type: !73, scopeLine: 56, flags: DIFlagPublic | DIFlagPrototyped | DIFlagStaticMember, spFlags: 0)
!73 = !DISubroutineType(types: !74)
!74 = !{!75}
!75 = !DIBasicType(name: "bool", size: 8, encoding: DW_ATE_boolean)
!76 = !DISubprogram(name: "enable_interrupts", linkageName: "_ZN7Machine17enable_interruptsEv", scope: !63, file: !62, line: 64, type: !20, scopeLine: 64, flags: DIFlagPublic | DIFlagPrototyped | DIFlagStaticMember, spFlags: 0)
!77 = !DISubprogram(name: "set_sp", linkageName: "_ZN7Machine6set_spEPKv", scope: !63, file: !62, line: 72, type: !78, scopeLine: 72, flags: DIFlagPublic | DIFlagPrototyped | DIFlagStaticMember, spFlags: 0)
!78 = !DISubroutineType(types: !79)
!79 = !{null, !80}
!80 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !81, size: 32)
!81 = !DIDerivedType(tag: DW_TAG_const_type, baseType: null)
!82 = !DISubprogram(name: "get_sp", linkageName: "_ZN7Machine6get_spEv", scope: !63, file: !62, line: 76, type: !83, scopeLine: 76, flags: DIFlagPublic | DIFlagPrototyped | DIFlagStaticMember, spFlags: 0)
!83 = !DISubroutineType(types: !84)
!84 = !{!85}
!85 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 32)
!86 = !DISubprogram(name: "interrupts_enabled", linkageName: "_ZN7Machine18interrupts_enabledEv", scope: !63, file: !62, line: 86, type: !73, scopeLine: 86, flags: DIFlagPublic | DIFlagPrototyped | DIFlagStaticMember, spFlags: 0)
!87 = !DISubprogram(name: "unreachable", linkageName: "_ZN7Machine11unreachableEv", scope: !63, file: !62, line: 94, type: !20, scopeLine: 94, flags: DIFlagPublic | DIFlagPrototyped | DIFlagStaticMember, spFlags: 0)
!88 = !DISubprogram(name: "shutdown", linkageName: "_ZN7Machine8shutdownEv", scope: !63, file: !62, line: 99, type: !20, scopeLine: 99, flags: DIFlagPublic | DIFlagPrototyped | DIFlagStaticMember, spFlags: 0)
!89 = !DISubprogram(name: "halt", linkageName: "_ZN7Machine4haltEv", scope: !63, file: !62, line: 103, type: !20, scopeLine: 103, flags: DIFlagPublic | DIFlagPrototyped | DIFlagStaticMember, spFlags: 0)
!90 = !DISubprogram(name: "exchange_saved_ip", linkageName: "_ZN7Machine17exchange_saved_ipEjPv", scope: !63, file: !62, line: 107, type: !91, scopeLine: 107, flags: DIFlagPublic | DIFlagPrototyped | DIFlagStaticMember, spFlags: 0)
!91 = !DISubroutineType(types: !92)
!92 = !{!85, !93, !85}
!93 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!94 = !DISubprogram(name: "syscall", linkageName: "_ZN7Machine7syscallEj", scope: !63, file: !62, line: 115, type: !95, scopeLine: 115, flags: DIFlagPublic | DIFlagPrototyped | DIFlagStaticMember, spFlags: 0)
!95 = !DISubroutineType(types: !96)
!96 = !{!93, !97}
!97 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !93)
!98 = !DISubprogram(name: "trigger_interrupt", linkageName: "_ZN7Machine17trigger_interruptEh", scope: !63, file: !62, line: 127, type: !99, scopeLine: 127, flags: DIFlagPublic | DIFlagPrototyped | DIFlagStaticMember, spFlags: 0)
!99 = !DISubroutineType(types: !100)
!100 = !{null, !101}
!101 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !67, line: 50, baseType: !102)
!102 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!103 = !DISubprogram(name: "trigger_interrupt_from_user", linkageName: "_ZN7Machine27trigger_interrupt_from_userEh", scope: !63, file: !62, line: 134, type: !99, scopeLine: 134, flags: DIFlagPublic | DIFlagPrototyped | DIFlagStaticMember, spFlags: 0)
!104 = !DISubprogram(name: "sync", linkageName: "_ZN7Machine4syncEv", scope: !63, file: !62, line: 138, type: !20, scopeLine: 138, flags: DIFlagPublic | DIFlagPrototyped | DIFlagStaticMember, spFlags: 0)
!105 = !DISubprogram(name: "sleep", linkageName: "_ZN7Machine5sleepEv", scope: !63, file: !62, line: 142, type: !20, scopeLine: 142, flags: DIFlagPublic | DIFlagPrototyped | DIFlagStaticMember, spFlags: 0)
!106 = !DILocation(line: 100, column: 10, scope: !61)
!107 = !DILocation(line: 101, column: 2, scope: !61)
