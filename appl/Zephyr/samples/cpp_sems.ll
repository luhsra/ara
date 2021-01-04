; ModuleID = 'llvm-link'
source_filename = "llvm-link"
target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "thumbv7em-none-unknown-eabi"

%struct.k_thread = type { %struct._thread_base, %struct._callee_saved, i8*, void ()*, i32, %struct._thread_stack_info, %struct.k_mem_pool*, %struct._thread_arch }
%struct._thread_base = type { %union.anon, %union.anon*, i8, i8, %union.anon.2, i32, i8*, %struct._timeout, %union.anon }
%union.anon.2 = type { i16 }
%struct._timeout = type { %struct._dnode, void (%struct._timeout*)*, i64 }
%struct._dnode = type { %union.anon.0, %union.anon.0 }
%union.anon.0 = type { %struct._dnode* }
%union.anon = type { %struct._dnode }
%struct._callee_saved = type { i32, i32, i32, i32, i32, i32, i32, i32, i32 }
%struct._thread_stack_info = type { i32, i32, i32 }
%struct.k_mem_pool = type { %struct.k_heap* }
%struct.k_heap = type { %struct.sys_heap, %union.anon, %struct.k_spinlock }
%struct.sys_heap = type { %struct.z_heap*, i8*, i32 }
%struct.z_heap = type opaque
%struct.k_spinlock = type { i8 }
%struct._thread_arch = type { i32, i32 }
%class.cpp_semaphore = type { %class.semaphore, %struct.k_sem }
%class.semaphore = type { i32 (...)** }
%struct.k_sem = type { %union.anon, i32, i32 }
%struct.k_timeout_t = type { i64 }
%struct.k_timer = type { %struct._timeout, %union.anon, void (%struct.k_timer*)*, void (%struct.k_timer*)*, %struct.k_timeout_t, i32, i8* }

$_ZN13cpp_semaphoreD2Ev = comdat any

$_ZN13cpp_semaphoreD0Ev = comdat any

$_ZN9semaphoreC2Ev = comdat any

$_ZTV9semaphore = comdat any

@coop_thread = dso_local global %struct.k_thread zeroinitializer, align 8, !dbg !0
@coop_stack = dso_local global [2000 x %struct.k_spinlock] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/cpp_sems/src/main.cpp\22.0", align 8, !dbg !20
@_ZTV13cpp_semaphore = dso_local unnamed_addr constant { [7 x i8*] } { [7 x i8*] [i8* null, i8* null, i8* bitcast (i32 (%class.cpp_semaphore*)* @_ZN13cpp_semaphore4waitEv to i8*), i8* bitcast (i32 (%class.cpp_semaphore*, i32)* @_ZN13cpp_semaphore4waitEi to i8*), i8* bitcast (void (%class.cpp_semaphore*)* @_ZN13cpp_semaphore4giveEv to i8*), i8* bitcast (%class.cpp_semaphore* (%class.cpp_semaphore*)* @_ZN13cpp_semaphoreD2Ev to i8*), i8* bitcast (void (%class.cpp_semaphore*)* @_ZN13cpp_semaphoreD0Ev to i8*)] }, align 4
@sem_main = dso_local global %class.cpp_semaphore zeroinitializer, align 4, !dbg !31
@sem_coop = dso_local global %class.cpp_semaphore zeroinitializer, align 4, !dbg !93
@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* @_GLOBAL__sub_I_main.cpp, i8* null }]
@__dso_handle = external hidden global i8
@.str = private unnamed_addr constant [21 x i8] c"Create semaphore %p\0A\00", align 1
@_ZTV9semaphore = linkonce_odr dso_local unnamed_addr constant { [5 x i8*] } { [5 x i8*] [i8* null, i8* null, i8* bitcast (void ()* @__cxa_pure_virtual to i8*), i8* bitcast (void ()* @__cxa_pure_virtual to i8*), i8* bitcast (void ()* @__cxa_pure_virtual to i8*)] }, comdat, align 4
@.str.2 = private unnamed_addr constant [18 x i8] c"%s: Hello World!\0A\00", align 1
@__FUNCTION__._Z17coop_thread_entryv = private unnamed_addr constant [18 x i8] c"coop_thread_entry\00", align 1
@__FUNCTION__._Z4mainv = private unnamed_addr constant [5 x i8] c"main\00", align 1

@_ZN13cpp_semaphoreC1Ev = dso_local unnamed_addr alias %class.cpp_semaphore* (%class.cpp_semaphore*), %class.cpp_semaphore* (%class.cpp_semaphore*)* @_ZN13cpp_semaphoreC2Ev

; Function Attrs: noinline nounwind optnone
define dso_local i32 @_ZN13cpp_semaphore4waitEv(%class.cpp_semaphore*) unnamed_addr #0 align 2 !dbg !190 {
  %2 = alloca %class.cpp_semaphore*, align 4
  %3 = alloca %struct.k_timeout_t, align 8
  store %class.cpp_semaphore* %0, %class.cpp_semaphore** %2, align 4
  call void @llvm.dbg.declare(metadata %class.cpp_semaphore** %2, metadata !191, metadata !DIExpression()), !dbg !193
  %4 = load %class.cpp_semaphore*, %class.cpp_semaphore** %2, align 4
  %5 = getelementptr inbounds %class.cpp_semaphore, %class.cpp_semaphore* %4, i32 0, i32 1, !dbg !194
  %6 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !195
  store i64 -1, i64* %6, align 8, !dbg !195
  %7 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !196
  %8 = bitcast i64* %7 to [1 x i64]*, !dbg !196
  %9 = load [1 x i64], [1 x i64]* %8, align 8, !dbg !196
  %10 = call i32 @_ZL10k_sem_takeP5k_sem11k_timeout_t(%struct.k_sem* %5, [1 x i64] %9) #7, !dbg !196
  ret i32 1, !dbg !197
}

; Function Attrs: noinline nounwind optnone
define dso_local i32 @_ZN13cpp_semaphore4waitEi(%class.cpp_semaphore*, i32) unnamed_addr #0 align 2 !dbg !198 {
  %3 = alloca %class.cpp_semaphore*, align 4
  %4 = alloca i32, align 4
  %5 = alloca %struct.k_timeout_t, align 8
  store %class.cpp_semaphore* %0, %class.cpp_semaphore** %3, align 4
  call void @llvm.dbg.declare(metadata %class.cpp_semaphore** %3, metadata !199, metadata !DIExpression()), !dbg !200
  store i32 %1, i32* %4, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !201, metadata !DIExpression()), !dbg !202
  %6 = load %class.cpp_semaphore*, %class.cpp_semaphore** %3, align 4
  %7 = getelementptr inbounds %class.cpp_semaphore, %class.cpp_semaphore* %6, i32 0, i32 1, !dbg !203
  %8 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %5, i32 0, i32 0, !dbg !204
  %9 = load i32, i32* %4, align 4, !dbg !204
  %10 = icmp sgt i32 %9, 0, !dbg !204
  br i1 %10, label %11, label %13, !dbg !204

11:                                               ; preds = %2
  %12 = load i32, i32* %4, align 4, !dbg !204
  br label %14, !dbg !204

13:                                               ; preds = %2
  br label %14, !dbg !204

14:                                               ; preds = %13, %11
  %15 = phi i32 [ %12, %11 ], [ 0, %13 ], !dbg !204
  %16 = sext i32 %15 to i64, !dbg !204
  %17 = call i64 @_ZL20k_ms_to_ticks_ceil64y(i64 %16) #7, !dbg !204
  store i64 %17, i64* %8, align 8, !dbg !204
  %18 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %5, i32 0, i32 0, !dbg !205
  %19 = bitcast i64* %18 to [1 x i64]*, !dbg !205
  %20 = load [1 x i64], [1 x i64]* %19, align 8, !dbg !205
  %21 = call i32 @_ZL10k_sem_takeP5k_sem11k_timeout_t(%struct.k_sem* %7, [1 x i64] %20) #7, !dbg !205
  ret i32 %21, !dbg !206
}

; Function Attrs: noinline nounwind optnone
define dso_local void @_ZN13cpp_semaphore4giveEv(%class.cpp_semaphore*) unnamed_addr #0 align 2 !dbg !207 {
  %2 = alloca %class.cpp_semaphore*, align 4
  store %class.cpp_semaphore* %0, %class.cpp_semaphore** %2, align 4
  call void @llvm.dbg.declare(metadata %class.cpp_semaphore** %2, metadata !208, metadata !DIExpression()), !dbg !209
  %3 = load %class.cpp_semaphore*, %class.cpp_semaphore** %2, align 4
  %4 = getelementptr inbounds %class.cpp_semaphore, %class.cpp_semaphore* %3, i32 0, i32 1, !dbg !210
  call void @_ZL10k_sem_giveP5k_sem(%struct.k_sem* %4) #7, !dbg !211
  ret void, !dbg !212
}

; Function Attrs: noinline nounwind optnone
define linkonce_odr dso_local %class.cpp_semaphore* @_ZN13cpp_semaphoreD2Ev(%class.cpp_semaphore* returned) unnamed_addr #0 comdat align 2 !dbg !213 {
  %2 = alloca %class.cpp_semaphore*, align 4
  store %class.cpp_semaphore* %0, %class.cpp_semaphore** %2, align 4
  call void @llvm.dbg.declare(metadata %class.cpp_semaphore** %2, metadata !214, metadata !DIExpression()), !dbg !215
  %3 = load %class.cpp_semaphore*, %class.cpp_semaphore** %2, align 4
  ret %class.cpp_semaphore* %3, !dbg !216
}

; Function Attrs: noinline nounwind optnone
define linkonce_odr dso_local void @_ZN13cpp_semaphoreD0Ev(%class.cpp_semaphore*) unnamed_addr #0 comdat align 2 !dbg !217 {
  %2 = alloca %class.cpp_semaphore*, align 4
  store %class.cpp_semaphore* %0, %class.cpp_semaphore** %2, align 4
  call void @llvm.dbg.declare(metadata %class.cpp_semaphore** %2, metadata !218, metadata !DIExpression()), !dbg !219
  %3 = load %class.cpp_semaphore*, %class.cpp_semaphore** %2, align 4
  %4 = call %class.cpp_semaphore* @_ZN13cpp_semaphoreD2Ev(%class.cpp_semaphore* %3) #8, !dbg !220
  %5 = bitcast %class.cpp_semaphore* %3 to i8*, !dbg !220
  call void @_ZdlPv(i8* %5) #9, !dbg !220
  ret void, !dbg !221
}

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: nobuiltin nounwind
declare dso_local void @_ZdlPv(i8*) #2

; Function Attrs: noinline nounwind optnone
define internal void @_ZL10k_sem_giveP5k_sem(%struct.k_sem*) #0 !dbg !222 {
  %2 = alloca %struct.k_sem*, align 4
  store %struct.k_sem* %0, %struct.k_sem** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_sem** %2, metadata !227, metadata !DIExpression()), !dbg !228
  br label %3, !dbg !229

3:                                                ; preds = %1
  call void asm sideeffect "", "~{memory}"() #6, !dbg !230, !srcloc !232
  br label %4, !dbg !230

4:                                                ; preds = %3
  %5 = load %struct.k_sem*, %struct.k_sem** %2, align 4, !dbg !233
  call void @z_impl_k_sem_give(%struct.k_sem* %5) #7, !dbg !234
  ret void, !dbg !235
}

declare dso_local void @z_impl_k_sem_give(%struct.k_sem*) #3

; Function Attrs: noinline nounwind optnone
define internal i64 @_ZL20k_ms_to_ticks_ceil64y(i64) #0 !dbg !236 {
  %2 = alloca i64, align 8
  %3 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %3, metadata !242, metadata !DIExpression()), !dbg !247
  %4 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !249, metadata !DIExpression()), !dbg !250
  %5 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %5, metadata !251, metadata !DIExpression()), !dbg !252
  %6 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %6, metadata !253, metadata !DIExpression()), !dbg !254
  %7 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %7, metadata !255, metadata !DIExpression()), !dbg !256
  %8 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %8, metadata !257, metadata !DIExpression()), !dbg !258
  %9 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %9, metadata !259, metadata !DIExpression()), !dbg !260
  %10 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %10, metadata !261, metadata !DIExpression()), !dbg !262
  %11 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %11, metadata !263, metadata !DIExpression()), !dbg !264
  %12 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %12, metadata !265, metadata !DIExpression()), !dbg !266
  %13 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %13, metadata !267, metadata !DIExpression()), !dbg !270
  %14 = alloca i64, align 8
  store i64 %0, i64* %14, align 8
  call void @llvm.dbg.declare(metadata i64* %14, metadata !271, metadata !DIExpression()), !dbg !272
  %15 = load i64, i64* %14, align 8, !dbg !273
  store i64 %15, i64* %3, align 8
  store i32 1000, i32* %4, align 4
  store i32 10000, i32* %5, align 4
  store i8 1, i8* %6, align 1
  store i8 0, i8* %7, align 1
  store i8 1, i8* %8, align 1
  store i8 0, i8* %9, align 1
  %16 = load i8, i8* %6, align 1, !dbg !274
  %17 = trunc i8 %16 to i1, !dbg !274
  br i1 %17, label %18, label %27, !dbg !275

18:                                               ; preds = %1
  %19 = load i32, i32* %5, align 4, !dbg !276
  %20 = load i32, i32* %4, align 4, !dbg !277
  %21 = icmp ugt i32 %19, %20, !dbg !278
  br i1 %21, label %22, label %27, !dbg !279

22:                                               ; preds = %18
  %23 = load i32, i32* %5, align 4, !dbg !280
  %24 = load i32, i32* %4, align 4, !dbg !281
  %25 = urem i32 %23, %24, !dbg !282
  %26 = icmp eq i32 %25, 0, !dbg !283
  br label %27

27:                                               ; preds = %22, %18, %1
  %28 = phi i1 [ false, %18 ], [ false, %1 ], [ %26, %22 ], !dbg !284
  %29 = zext i1 %28 to i8, !dbg !262
  store i8 %29, i8* %10, align 1, !dbg !262
  %30 = load i8, i8* %6, align 1, !dbg !285
  %31 = trunc i8 %30 to i1, !dbg !285
  br i1 %31, label %32, label %41, !dbg !286

32:                                               ; preds = %27
  %33 = load i32, i32* %4, align 4, !dbg !287
  %34 = load i32, i32* %5, align 4, !dbg !288
  %35 = icmp ugt i32 %33, %34, !dbg !289
  br i1 %35, label %36, label %41, !dbg !290

36:                                               ; preds = %32
  %37 = load i32, i32* %4, align 4, !dbg !291
  %38 = load i32, i32* %5, align 4, !dbg !292
  %39 = urem i32 %37, %38, !dbg !293
  %40 = icmp eq i32 %39, 0, !dbg !294
  br label %41

41:                                               ; preds = %36, %32, %27
  %42 = phi i1 [ false, %32 ], [ false, %27 ], [ %40, %36 ], !dbg !284
  %43 = zext i1 %42 to i8, !dbg !264
  store i8 %43, i8* %11, align 1, !dbg !264
  %44 = load i32, i32* %4, align 4, !dbg !295
  %45 = load i32, i32* %5, align 4, !dbg !297
  %46 = icmp eq i32 %44, %45, !dbg !298
  br i1 %46, label %47, label %58, !dbg !299

47:                                               ; preds = %41
  %48 = load i8, i8* %7, align 1, !dbg !300
  %49 = trunc i8 %48 to i1, !dbg !300
  br i1 %49, label %50, label %54, !dbg !300

50:                                               ; preds = %47
  %51 = load i64, i64* %3, align 8, !dbg !302
  %52 = trunc i64 %51 to i32, !dbg !302
  %53 = zext i32 %52 to i64, !dbg !303
  br label %56, !dbg !300

54:                                               ; preds = %47
  %55 = load i64, i64* %3, align 8, !dbg !304
  br label %56, !dbg !300

56:                                               ; preds = %54, %50
  %57 = phi i64 [ %53, %50 ], [ %55, %54 ], !dbg !300
  store i64 %57, i64* %2, align 8, !dbg !305
  br label %160, !dbg !305

58:                                               ; preds = %41
  store i64 0, i64* %12, align 8, !dbg !266
  %59 = load i8, i8* %10, align 1, !dbg !306
  %60 = trunc i8 %59 to i1, !dbg !306
  br i1 %60, label %87, label %61, !dbg !307

61:                                               ; preds = %58
  %62 = load i8, i8* %11, align 1, !dbg !308
  %63 = trunc i8 %62 to i1, !dbg !308
  br i1 %63, label %64, label %68, !dbg !308

64:                                               ; preds = %61
  %65 = load i32, i32* %4, align 4, !dbg !309
  %66 = load i32, i32* %5, align 4, !dbg !310
  %67 = udiv i32 %65, %66, !dbg !311
  br label %70, !dbg !308

68:                                               ; preds = %61
  %69 = load i32, i32* %4, align 4, !dbg !312
  br label %70, !dbg !308

70:                                               ; preds = %68, %64
  %71 = phi i32 [ %67, %64 ], [ %69, %68 ], !dbg !308
  store i32 %71, i32* %13, align 4, !dbg !270
  %72 = load i8, i8* %8, align 1, !dbg !313
  %73 = trunc i8 %72 to i1, !dbg !313
  br i1 %73, label %74, label %78, !dbg !315

74:                                               ; preds = %70
  %75 = load i32, i32* %13, align 4, !dbg !316
  %76 = sub i32 %75, 1, !dbg !318
  %77 = zext i32 %76 to i64, !dbg !316
  store i64 %77, i64* %12, align 8, !dbg !319
  br label %86, !dbg !320

78:                                               ; preds = %70
  %79 = load i8, i8* %9, align 1, !dbg !321
  %80 = trunc i8 %79 to i1, !dbg !321
  br i1 %80, label %81, label %85, !dbg !323

81:                                               ; preds = %78
  %82 = load i32, i32* %13, align 4, !dbg !324
  %83 = udiv i32 %82, 2, !dbg !326
  %84 = zext i32 %83 to i64, !dbg !324
  store i64 %84, i64* %12, align 8, !dbg !327
  br label %85, !dbg !328

85:                                               ; preds = %81, %78
  br label %86

86:                                               ; preds = %85, %74
  br label %87, !dbg !329

87:                                               ; preds = %86, %58
  %88 = load i8, i8* %11, align 1, !dbg !330
  %89 = trunc i8 %88 to i1, !dbg !330
  br i1 %89, label %90, label %114, !dbg !332

90:                                               ; preds = %87
  %91 = load i64, i64* %12, align 8, !dbg !333
  %92 = load i64, i64* %3, align 8, !dbg !335
  %93 = add i64 %92, %91, !dbg !335
  store i64 %93, i64* %3, align 8, !dbg !335
  %94 = load i8, i8* %7, align 1, !dbg !336
  %95 = trunc i8 %94 to i1, !dbg !336
  br i1 %95, label %96, label %107, !dbg !338

96:                                               ; preds = %90
  %97 = load i64, i64* %3, align 8, !dbg !339
  %98 = icmp ult i64 %97, 4294967296, !dbg !340
  br i1 %98, label %99, label %107, !dbg !341

99:                                               ; preds = %96
  %100 = load i64, i64* %3, align 8, !dbg !342
  %101 = trunc i64 %100 to i32, !dbg !342
  %102 = load i32, i32* %4, align 4, !dbg !344
  %103 = load i32, i32* %5, align 4, !dbg !345
  %104 = udiv i32 %102, %103, !dbg !346
  %105 = udiv i32 %101, %104, !dbg !347
  %106 = zext i32 %105 to i64, !dbg !348
  store i64 %106, i64* %2, align 8, !dbg !349
  br label %160, !dbg !349

107:                                              ; preds = %96, %90
  %108 = load i64, i64* %3, align 8, !dbg !350
  %109 = load i32, i32* %4, align 4, !dbg !352
  %110 = load i32, i32* %5, align 4, !dbg !353
  %111 = udiv i32 %109, %110, !dbg !354
  %112 = zext i32 %111 to i64, !dbg !355
  %113 = udiv i64 %108, %112, !dbg !356
  store i64 %113, i64* %2, align 8, !dbg !357
  br label %160, !dbg !357

114:                                              ; preds = %87
  %115 = load i8, i8* %10, align 1, !dbg !358
  %116 = trunc i8 %115 to i1, !dbg !358
  br i1 %116, label %117, label %135, !dbg !360

117:                                              ; preds = %114
  %118 = load i8, i8* %7, align 1, !dbg !361
  %119 = trunc i8 %118 to i1, !dbg !361
  br i1 %119, label %120, label %128, !dbg !364

120:                                              ; preds = %117
  %121 = load i64, i64* %3, align 8, !dbg !365
  %122 = trunc i64 %121 to i32, !dbg !365
  %123 = load i32, i32* %5, align 4, !dbg !367
  %124 = load i32, i32* %4, align 4, !dbg !368
  %125 = udiv i32 %123, %124, !dbg !369
  %126 = mul i32 %122, %125, !dbg !370
  %127 = zext i32 %126 to i64, !dbg !371
  store i64 %127, i64* %2, align 8, !dbg !372
  br label %160, !dbg !372

128:                                              ; preds = %117
  %129 = load i64, i64* %3, align 8, !dbg !373
  %130 = load i32, i32* %5, align 4, !dbg !375
  %131 = load i32, i32* %4, align 4, !dbg !376
  %132 = udiv i32 %130, %131, !dbg !377
  %133 = zext i32 %132 to i64, !dbg !378
  %134 = mul i64 %129, %133, !dbg !379
  store i64 %134, i64* %2, align 8, !dbg !380
  br label %160, !dbg !380

135:                                              ; preds = %114
  %136 = load i8, i8* %7, align 1, !dbg !381
  %137 = trunc i8 %136 to i1, !dbg !381
  br i1 %137, label %138, label %150, !dbg !384

138:                                              ; preds = %135
  %139 = load i64, i64* %3, align 8, !dbg !385
  %140 = load i32, i32* %5, align 4, !dbg !387
  %141 = zext i32 %140 to i64, !dbg !387
  %142 = mul i64 %139, %141, !dbg !388
  %143 = load i64, i64* %12, align 8, !dbg !389
  %144 = add i64 %142, %143, !dbg !390
  %145 = load i32, i32* %4, align 4, !dbg !391
  %146 = zext i32 %145 to i64, !dbg !391
  %147 = udiv i64 %144, %146, !dbg !392
  %148 = trunc i64 %147 to i32, !dbg !393
  %149 = zext i32 %148 to i64, !dbg !394
  store i64 %149, i64* %2, align 8, !dbg !395
  br label %160, !dbg !395

150:                                              ; preds = %135
  %151 = load i64, i64* %3, align 8, !dbg !396
  %152 = load i32, i32* %5, align 4, !dbg !398
  %153 = zext i32 %152 to i64, !dbg !398
  %154 = mul i64 %151, %153, !dbg !399
  %155 = load i64, i64* %12, align 8, !dbg !400
  %156 = add i64 %154, %155, !dbg !401
  %157 = load i32, i32* %4, align 4, !dbg !402
  %158 = zext i32 %157 to i64, !dbg !402
  %159 = udiv i64 %156, %158, !dbg !403
  store i64 %159, i64* %2, align 8, !dbg !404
  br label %160, !dbg !404

160:                                              ; preds = %150, %138, %128, %120, %107, %99, %56
  %161 = load i64, i64* %2, align 8, !dbg !405
  ret i64 %161, !dbg !406
}

; Function Attrs: noinline nounwind optnone
define internal i32 @_ZL10k_sem_takeP5k_sem11k_timeout_t(%struct.k_sem*, [1 x i64]) #0 !dbg !407 {
  %3 = alloca %struct.k_timeout_t, align 8
  %4 = alloca %struct.k_sem*, align 4
  %5 = alloca %struct.k_timeout_t, align 8
  %6 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0
  %7 = bitcast i64* %6 to [1 x i64]*
  store [1 x i64] %1, [1 x i64]* %7, align 8
  store %struct.k_sem* %0, %struct.k_sem** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.k_sem** %4, metadata !414, metadata !DIExpression()), !dbg !415
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %3, metadata !416, metadata !DIExpression()), !dbg !417
  br label %8, !dbg !418

8:                                                ; preds = %2
  call void asm sideeffect "", "~{memory}"() #6, !dbg !419, !srcloc !421
  br label %9, !dbg !419

9:                                                ; preds = %8
  %10 = load %struct.k_sem*, %struct.k_sem** %4, align 4, !dbg !422
  %11 = bitcast %struct.k_timeout_t* %5 to i8*, !dbg !423
  %12 = bitcast %struct.k_timeout_t* %3 to i8*, !dbg !423
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* align 8 %11, i8* align 8 %12, i32 8, i1 false), !dbg !423
  %13 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %5, i32 0, i32 0, !dbg !424
  %14 = bitcast i64* %13 to [1 x i64]*, !dbg !424
  %15 = load [1 x i64], [1 x i64]* %14, align 8, !dbg !424
  %16 = call i32 @z_impl_k_sem_take(%struct.k_sem* %10, [1 x i64] %15) #7, !dbg !424
  ret i32 %16, !dbg !425
}

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i32(i8* nocapture writeonly, i8* nocapture readonly, i32, i1 immarg) #4

declare dso_local i32 @z_impl_k_sem_take(%struct.k_sem*, [1 x i64]) #3

; Function Attrs: noinline nounwind
define internal void @_GLOBAL__sub_I_main.cpp() #5 !dbg !426 {
  call void @__cxx_global_var_init(), !dbg !428
  call void @__cxx_global_var_init.1(), !dbg !428
  ret void
}

; Function Attrs: noinline nounwind
define internal void @__cxx_global_var_init() #5 !dbg !429 {
  %1 = call %class.cpp_semaphore* @_ZN13cpp_semaphoreC1Ev(%class.cpp_semaphore* @sem_main) #7, !dbg !430
  %2 = call i32 @__cxa_atexit(void (i8*)* bitcast (%class.cpp_semaphore* (%class.cpp_semaphore*)* @_ZN13cpp_semaphoreD2Ev to void (i8*)*), i8* bitcast (%class.cpp_semaphore* @sem_main to i8*), i8* @__dso_handle) #6, !dbg !430
  ret void, !dbg !430
}

; Function Attrs: noinline nounwind
define internal void @__cxx_global_var_init.1() #5 !dbg !431 {
  %1 = call %class.cpp_semaphore* @_ZN13cpp_semaphoreC1Ev(%class.cpp_semaphore* @sem_coop) #7, !dbg !432
  %2 = call i32 @__cxa_atexit(void (i8*)* bitcast (%class.cpp_semaphore* (%class.cpp_semaphore*)* @_ZN13cpp_semaphoreD2Ev to void (i8*)*), i8* bitcast (%class.cpp_semaphore* @sem_coop to i8*), i8* @__dso_handle) #6, !dbg !432
  ret void, !dbg !432
}

; Function Attrs: nounwind
declare dso_local i32 @__cxa_atexit(void (i8*)*, i8*, i8*) #6

; Function Attrs: noinline nounwind optnone
define dso_local %class.cpp_semaphore* @_ZN13cpp_semaphoreC2Ev(%class.cpp_semaphore* returned) unnamed_addr #0 align 2 !dbg !433 {
  %2 = alloca %class.cpp_semaphore*, align 4
  store %class.cpp_semaphore* %0, %class.cpp_semaphore** %2, align 4
  call void @llvm.dbg.declare(metadata %class.cpp_semaphore** %2, metadata !434, metadata !DIExpression()), !dbg !435
  %3 = load %class.cpp_semaphore*, %class.cpp_semaphore** %2, align 4
  %4 = bitcast %class.cpp_semaphore* %3 to %class.semaphore*, !dbg !436
  %5 = call %class.semaphore* @_ZN9semaphoreC2Ev(%class.semaphore* %4) #8, !dbg !437
  %6 = bitcast %class.cpp_semaphore* %3 to i32 (...)***, !dbg !436
  store i32 (...)** bitcast (i8** getelementptr inbounds ({ [7 x i8*] }, { [7 x i8*] }* @_ZTV13cpp_semaphore, i32 0, inrange i32 0, i32 2) to i32 (...)**), i32 (...)*** %6, align 4, !dbg !436
  %7 = getelementptr inbounds %class.cpp_semaphore, %class.cpp_semaphore* %3, i32 0, i32 1, !dbg !437
  call void (i8*, ...) @printk(i8* getelementptr inbounds ([21 x i8], [21 x i8]* @.str, i32 0, i32 0), %class.cpp_semaphore* %3) #7, !dbg !438
  %8 = getelementptr inbounds %class.cpp_semaphore, %class.cpp_semaphore* %3, i32 0, i32 1, !dbg !440
  %9 = call i32 @_ZL10k_sem_initP5k_semjj(%struct.k_sem* %8, i32 0, i32 -1) #7, !dbg !441
  ret %class.cpp_semaphore* %3, !dbg !442
}

; Function Attrs: noinline nounwind optnone
define linkonce_odr dso_local %class.semaphore* @_ZN9semaphoreC2Ev(%class.semaphore* returned) unnamed_addr #0 comdat align 2 !dbg !443 {
  %2 = alloca %class.semaphore*, align 4
  store %class.semaphore* %0, %class.semaphore** %2, align 4
  call void @llvm.dbg.declare(metadata %class.semaphore** %2, metadata !445, metadata !DIExpression()), !dbg !447
  %3 = load %class.semaphore*, %class.semaphore** %2, align 4
  %4 = bitcast %class.semaphore* %3 to i32 (...)***, !dbg !448
  store i32 (...)** bitcast (i8** getelementptr inbounds ({ [5 x i8*] }, { [5 x i8*] }* @_ZTV9semaphore, i32 0, inrange i32 0, i32 2) to i32 (...)**), i32 (...)*** %4, align 4, !dbg !448
  ret %class.semaphore* %3, !dbg !448
}

declare dso_local void @printk(i8*, ...) #3

; Function Attrs: noinline nounwind optnone
define internal i32 @_ZL10k_sem_initP5k_semjj(%struct.k_sem*, i32, i32) #0 !dbg !449 {
  %4 = alloca %struct.k_sem*, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  store %struct.k_sem* %0, %struct.k_sem** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.k_sem** %4, metadata !452, metadata !DIExpression()), !dbg !453
  store i32 %1, i32* %5, align 4
  call void @llvm.dbg.declare(metadata i32* %5, metadata !454, metadata !DIExpression()), !dbg !455
  store i32 %2, i32* %6, align 4
  call void @llvm.dbg.declare(metadata i32* %6, metadata !456, metadata !DIExpression()), !dbg !457
  br label %7, !dbg !458

7:                                                ; preds = %3
  call void asm sideeffect "", "~{memory}"() #6, !dbg !459, !srcloc !461
  br label %8, !dbg !459

8:                                                ; preds = %7
  %9 = load %struct.k_sem*, %struct.k_sem** %4, align 4, !dbg !462
  %10 = load i32, i32* %5, align 4, !dbg !463
  %11 = load i32, i32* %6, align 4, !dbg !464
  %12 = call i32 @z_impl_k_sem_init(%struct.k_sem* %9, i32 %10, i32 %11) #7, !dbg !465
  ret i32 %12, !dbg !466
}

declare dso_local i32 @z_impl_k_sem_init(%struct.k_sem*, i32, i32) #3

declare dso_local void @__cxa_pure_virtual() unnamed_addr

; Function Attrs: noinline nounwind optnone
define dso_local void @_Z17coop_thread_entryv() #0 !dbg !467 {
  %1 = alloca %struct.k_timer, align 8
  %2 = alloca %struct.k_timeout_t, align 8
  %3 = alloca %struct.k_timeout_t, align 8
  call void @llvm.dbg.declare(metadata %struct.k_timer* %1, metadata !468, metadata !DIExpression()), !dbg !482
  call void @k_timer_init(%struct.k_timer* %1, void (%struct.k_timer*)* null, void (%struct.k_timer*)* null) #7, !dbg !483
  br label %4, !dbg !484

4:                                                ; preds = %4, %0
  %5 = call i32 @_ZN13cpp_semaphore4waitEv(%class.cpp_semaphore* @sem_coop) #7, !dbg !485
  call void (i8*, ...) @printk(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @.str.2, i32 0, i32 0), i8* getelementptr inbounds ([18 x i8], [18 x i8]* @__FUNCTION__._Z17coop_thread_entryv, i32 0, i32 0)) #7, !dbg !487
  %6 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !488
  %7 = call i64 @_ZL20k_ms_to_ticks_ceil64y(i64 500) #7, !dbg !488
  store i64 %7, i64* %6, align 8, !dbg !488
  %8 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !489
  store i64 0, i64* %8, align 8, !dbg !489
  %9 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !490
  %10 = bitcast i64* %9 to [1 x i64]*, !dbg !490
  %11 = load [1 x i64], [1 x i64]* %10, align 8, !dbg !490
  %12 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !490
  %13 = bitcast i64* %12 to [1 x i64]*, !dbg !490
  %14 = load [1 x i64], [1 x i64]* %13, align 8, !dbg !490
  call void @_ZL13k_timer_startP7k_timer11k_timeout_tS1_(%struct.k_timer* %1, [1 x i64] %11, [1 x i64] %14) #7, !dbg !490
  %15 = call i32 @_ZL19k_timer_status_syncP7k_timer(%struct.k_timer* %1) #7, !dbg !491
  call void @_ZN13cpp_semaphore4giveEv(%class.cpp_semaphore* @sem_main) #7, !dbg !492
  br label %4, !dbg !484, !llvm.loop !493
}

declare dso_local void @k_timer_init(%struct.k_timer*, void (%struct.k_timer*)*, void (%struct.k_timer*)*) #3

; Function Attrs: noinline nounwind optnone
define internal void @_ZL13k_timer_startP7k_timer11k_timeout_tS1_(%struct.k_timer*, [1 x i64], [1 x i64]) #0 !dbg !495 {
  %4 = alloca %struct.k_timeout_t, align 8
  %5 = alloca %struct.k_timeout_t, align 8
  %6 = alloca %struct.k_timer*, align 4
  %7 = alloca %struct.k_timeout_t, align 8
  %8 = alloca %struct.k_timeout_t, align 8
  %9 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %4, i32 0, i32 0
  %10 = bitcast i64* %9 to [1 x i64]*
  store [1 x i64] %1, [1 x i64]* %10, align 8
  %11 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %5, i32 0, i32 0
  %12 = bitcast i64* %11 to [1 x i64]*
  store [1 x i64] %2, [1 x i64]* %12, align 8
  store %struct.k_timer* %0, %struct.k_timer** %6, align 4
  call void @llvm.dbg.declare(metadata %struct.k_timer** %6, metadata !498, metadata !DIExpression()), !dbg !499
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %4, metadata !500, metadata !DIExpression()), !dbg !501
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %5, metadata !502, metadata !DIExpression()), !dbg !503
  br label %13, !dbg !504

13:                                               ; preds = %3
  call void asm sideeffect "", "~{memory}"() #6, !dbg !505, !srcloc !507
  br label %14, !dbg !505

14:                                               ; preds = %13
  %15 = load %struct.k_timer*, %struct.k_timer** %6, align 4, !dbg !508
  %16 = bitcast %struct.k_timeout_t* %7 to i8*, !dbg !509
  %17 = bitcast %struct.k_timeout_t* %4 to i8*, !dbg !509
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* align 8 %16, i8* align 8 %17, i32 8, i1 false), !dbg !509
  %18 = bitcast %struct.k_timeout_t* %8 to i8*, !dbg !510
  %19 = bitcast %struct.k_timeout_t* %5 to i8*, !dbg !510
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* align 8 %18, i8* align 8 %19, i32 8, i1 false), !dbg !510
  %20 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %7, i32 0, i32 0, !dbg !511
  %21 = bitcast i64* %20 to [1 x i64]*, !dbg !511
  %22 = load [1 x i64], [1 x i64]* %21, align 8, !dbg !511
  %23 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %8, i32 0, i32 0, !dbg !511
  %24 = bitcast i64* %23 to [1 x i64]*, !dbg !511
  %25 = load [1 x i64], [1 x i64]* %24, align 8, !dbg !511
  call void @z_impl_k_timer_start(%struct.k_timer* %15, [1 x i64] %22, [1 x i64] %25) #7, !dbg !511
  ret void, !dbg !512
}

; Function Attrs: noinline nounwind optnone
define internal i32 @_ZL19k_timer_status_syncP7k_timer(%struct.k_timer*) #0 !dbg !513 {
  %2 = alloca %struct.k_timer*, align 4
  store %struct.k_timer* %0, %struct.k_timer** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_timer** %2, metadata !516, metadata !DIExpression()), !dbg !517
  br label %3, !dbg !518

3:                                                ; preds = %1
  call void asm sideeffect "", "~{memory}"() #6, !dbg !519, !srcloc !521
  br label %4, !dbg !519

4:                                                ; preds = %3
  %5 = load %struct.k_timer*, %struct.k_timer** %2, align 4, !dbg !522
  %6 = call i32 @z_impl_k_timer_status_sync(%struct.k_timer* %5) #7, !dbg !523
  ret i32 %6, !dbg !524
}

declare dso_local i32 @z_impl_k_timer_status_sync(%struct.k_timer*) #3

declare dso_local void @z_impl_k_timer_start(%struct.k_timer*, [1 x i64], [1 x i64]) #3

; Function Attrs: noinline nounwind optnone
define dso_local void @_Z4mainv() #0 !dbg !525 {
  %1 = alloca %struct.k_timer, align 8
  %2 = alloca %struct.k_timeout_t, align 8
  %3 = alloca %struct.k_timeout_t, align 8
  %4 = alloca %struct.k_timeout_t, align 8
  call void @llvm.dbg.declare(metadata %struct.k_timer* %1, metadata !526, metadata !DIExpression()), !dbg !527
  %5 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !528
  store i64 0, i64* %5, align 8, !dbg !528
  %6 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !529
  %7 = bitcast i64* %6 to [1 x i64]*, !dbg !529
  %8 = load [1 x i64], [1 x i64]* %7, align 8, !dbg !529
  %9 = call %struct.k_thread* @_ZL15k_thread_createP8k_threadP22z_thread_stack_elementjPFvPvS3_S3_ES3_S3_S3_ij11k_timeout_t(%struct.k_thread* @coop_thread, %struct.k_spinlock* getelementptr inbounds ([2000 x %struct.k_spinlock], [2000 x %struct.k_spinlock]* @coop_stack, i32 0, i32 0), i32 2000, void (i8*, i8*, i8*)* bitcast (void ()* @_Z17coop_thread_entryv to void (i8*, i8*, i8*)*), i8* null, i8* null, i8* null, i32 -9, i32 0, [1 x i64] %8) #7, !dbg !529
  call void @k_timer_init(%struct.k_timer* %1, void (%struct.k_timer*)* null, void (%struct.k_timer*)* null) #7, !dbg !530
  br label %10, !dbg !531

10:                                               ; preds = %10, %0
  call void (i8*, ...) @printk(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @.str.2, i32 0, i32 0), i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__FUNCTION__._Z4mainv, i32 0, i32 0)) #7, !dbg !532
  %11 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !534
  %12 = call i64 @_ZL20k_ms_to_ticks_ceil64y(i64 500) #7, !dbg !534
  store i64 %12, i64* %11, align 8, !dbg !534
  %13 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %4, i32 0, i32 0, !dbg !535
  store i64 0, i64* %13, align 8, !dbg !535
  %14 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !536
  %15 = bitcast i64* %14 to [1 x i64]*, !dbg !536
  %16 = load [1 x i64], [1 x i64]* %15, align 8, !dbg !536
  %17 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %4, i32 0, i32 0, !dbg !536
  %18 = bitcast i64* %17 to [1 x i64]*, !dbg !536
  %19 = load [1 x i64], [1 x i64]* %18, align 8, !dbg !536
  call void @_ZL13k_timer_startP7k_timer11k_timeout_tS1_(%struct.k_timer* %1, [1 x i64] %16, [1 x i64] %19) #7, !dbg !536
  %20 = call i32 @_ZL19k_timer_status_syncP7k_timer(%struct.k_timer* %1) #7, !dbg !537
  call void @_ZN13cpp_semaphore4giveEv(%class.cpp_semaphore* @sem_coop) #7, !dbg !538
  %21 = call i32 @_ZN13cpp_semaphore4waitEv(%class.cpp_semaphore* @sem_main) #7, !dbg !539
  br label %10, !dbg !531, !llvm.loop !540
}

; Function Attrs: noinline nounwind optnone
define internal %struct.k_thread* @_ZL15k_thread_createP8k_threadP22z_thread_stack_elementjPFvPvS3_S3_ES3_S3_S3_ij11k_timeout_t(%struct.k_thread*, %struct.k_spinlock*, i32, void (i8*, i8*, i8*)*, i8*, i8*, i8*, i32, i32, [1 x i64]) #0 !dbg !542 {
  %11 = alloca %struct.k_timeout_t, align 8
  %12 = alloca %struct.k_thread*, align 4
  %13 = alloca %struct.k_spinlock*, align 4
  %14 = alloca i32, align 4
  %15 = alloca void (i8*, i8*, i8*)*, align 4
  %16 = alloca i8*, align 4
  %17 = alloca i8*, align 4
  %18 = alloca i8*, align 4
  %19 = alloca i32, align 4
  %20 = alloca i32, align 4
  %21 = alloca %struct.k_timeout_t, align 8
  %22 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %11, i32 0, i32 0
  %23 = bitcast i64* %22 to [1 x i64]*
  store [1 x i64] %9, [1 x i64]* %23, align 8
  store %struct.k_thread* %0, %struct.k_thread** %12, align 4
  call void @llvm.dbg.declare(metadata %struct.k_thread** %12, metadata !549, metadata !DIExpression()), !dbg !550
  store %struct.k_spinlock* %1, %struct.k_spinlock** %13, align 4
  call void @llvm.dbg.declare(metadata %struct.k_spinlock** %13, metadata !551, metadata !DIExpression()), !dbg !552
  store i32 %2, i32* %14, align 4
  call void @llvm.dbg.declare(metadata i32* %14, metadata !553, metadata !DIExpression()), !dbg !554
  store void (i8*, i8*, i8*)* %3, void (i8*, i8*, i8*)** %15, align 4
  call void @llvm.dbg.declare(metadata void (i8*, i8*, i8*)** %15, metadata !555, metadata !DIExpression()), !dbg !556
  store i8* %4, i8** %16, align 4
  call void @llvm.dbg.declare(metadata i8** %16, metadata !557, metadata !DIExpression()), !dbg !558
  store i8* %5, i8** %17, align 4
  call void @llvm.dbg.declare(metadata i8** %17, metadata !559, metadata !DIExpression()), !dbg !560
  store i8* %6, i8** %18, align 4
  call void @llvm.dbg.declare(metadata i8** %18, metadata !561, metadata !DIExpression()), !dbg !562
  store i32 %7, i32* %19, align 4
  call void @llvm.dbg.declare(metadata i32* %19, metadata !563, metadata !DIExpression()), !dbg !564
  store i32 %8, i32* %20, align 4
  call void @llvm.dbg.declare(metadata i32* %20, metadata !565, metadata !DIExpression()), !dbg !566
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %11, metadata !567, metadata !DIExpression()), !dbg !568
  br label %24, !dbg !569

24:                                               ; preds = %10
  call void asm sideeffect "", "~{memory}"() #6, !dbg !570, !srcloc !572
  br label %25, !dbg !570

25:                                               ; preds = %24
  %26 = load %struct.k_thread*, %struct.k_thread** %12, align 4, !dbg !573
  %27 = load %struct.k_spinlock*, %struct.k_spinlock** %13, align 4, !dbg !574
  %28 = load i32, i32* %14, align 4, !dbg !575
  %29 = load void (i8*, i8*, i8*)*, void (i8*, i8*, i8*)** %15, align 4, !dbg !576
  %30 = load i8*, i8** %16, align 4, !dbg !577
  %31 = load i8*, i8** %17, align 4, !dbg !578
  %32 = load i8*, i8** %18, align 4, !dbg !579
  %33 = load i32, i32* %19, align 4, !dbg !580
  %34 = load i32, i32* %20, align 4, !dbg !581
  %35 = bitcast %struct.k_timeout_t* %21 to i8*, !dbg !582
  %36 = bitcast %struct.k_timeout_t* %11 to i8*, !dbg !582
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* align 8 %35, i8* align 8 %36, i32 8, i1 false), !dbg !582
  %37 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %21, i32 0, i32 0, !dbg !583
  %38 = bitcast i64* %37 to [1 x i64]*, !dbg !583
  %39 = load [1 x i64], [1 x i64]* %38, align 8, !dbg !583
  %40 = call %struct.k_thread* @z_impl_k_thread_create(%struct.k_thread* %26, %struct.k_spinlock* %27, i32 %28, void (i8*, i8*, i8*)* %29, i8* %30, i8* %31, i8* %32, i32 %33, i32 %34, [1 x i64] %39) #7, !dbg !583
  ret %struct.k_thread* %40, !dbg !584
}

declare dso_local %struct.k_thread* @z_impl_k_thread_create(%struct.k_thread*, %struct.k_spinlock*, i32, void (i8*, i8*, i8*)*, i8*, i8*, i8*, i32, i32, [1 x i64]) #3

attributes #0 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #1 = { nounwind readnone speculatable }
attributes #2 = { nobuiltin nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #4 = { argmemonly nounwind }
attributes #5 = { noinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #6 = { nounwind }
attributes #7 = { nobuiltin }
attributes #8 = { nobuiltin nounwind }
attributes #9 = { builtin nobuiltin nounwind }

!llvm.dbg.cu = !{!2}
!llvm.ident = !{!185}
!llvm.module.flags = !{!186, !187, !188, !189}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "coop_thread", scope: !2, file: !22, line: 40, type: !95, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, file: !3, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !5, globals: !19, nameTableKind: None)
!3 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/cpp_sems/src/main.cpp", directory: "/home/kenny/ara/build/appl/Zephyr/cpp_sems")
!4 = !{}
!5 = !{!6, !11, !17}
!6 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_ticks_t", file: !7, line: 46, baseType: !8)
!7 = !DIFile(filename: "zephyrproject/zephyr/include/sys_clock.h", directory: "/home/kenny")
!8 = !DIDerivedType(tag: DW_TAG_typedef, name: "int64_t", file: !9, line: 43, baseType: !10)
!9 = !DIFile(filename: "zephyrproject/zephyr/lib/libc/minimal/include/stdint.h", directory: "/home/kenny")
!10 = !DIBasicType(name: "long long int", size: 64, encoding: DW_ATE_signed)
!11 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_entry_t", file: !12, line: 46, baseType: !13)
!12 = !DIFile(filename: "zephyrproject/zephyr/include/sys/arch_interface.h", directory: "/home/kenny")
!13 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !14, size: 32)
!14 = !DISubroutineType(types: !15)
!15 = !{null, !16, !16, !16}
!16 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 32)
!17 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !9, line: 57, baseType: !18)
!18 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!19 = !{!0, !20, !31, !93}
!20 = !DIGlobalVariableExpression(var: !21, expr: !DIExpression())
!21 = distinct !DIGlobalVariable(name: "coop_stack", scope: !2, file: !22, line: 41, type: !23, isLocal: false, isDefinition: true, align: 64)
!22 = !DIFile(filename: "appl/Zephyr/cpp_sems/src/main.cpp", directory: "/home/kenny/ara")
!23 = !DICompositeType(tag: DW_TAG_array_type, baseType: !24, size: 16000, elements: !29)
!24 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "z_thread_stack_element", file: !25, line: 35, size: 8, flags: DIFlagTypePassByValue, elements: !26, identifier: "_ZTS22z_thread_stack_element")
!25 = !DIFile(filename: "zephyrproject/zephyr/include/sys/thread_stack.h", directory: "/home/kenny")
!26 = !{!27}
!27 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !24, file: !25, line: 36, baseType: !28, size: 8)
!28 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_unsigned_char)
!29 = !{!30}
!30 = !DISubrange(count: 2000)
!31 = !DIGlobalVariableExpression(var: !32, expr: !DIExpression())
!32 = distinct !DIGlobalVariable(name: "sem_main", scope: !2, file: !22, line: 113, type: !33, isLocal: false, isDefinition: true)
!33 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "cpp_semaphore", file: !22, line: 50, size: 160, flags: DIFlagTypePassByReference | DIFlagNonTrivial, elements: !34, vtableHolder: !36)
!34 = !{!35, !54, !81, !85, !86, !89, !92}
!35 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !33, baseType: !36, flags: DIFlagPublic, extraData: i32 0)
!36 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "semaphore", file: !22, line: 29, size: 32, flags: DIFlagTypePassByReference | DIFlagNonTrivial, elements: !37, vtableHolder: !36, identifier: "_ZTS9semaphore")
!37 = !{!38, !44, !48, !51}
!38 = !DIDerivedType(tag: DW_TAG_member, name: "_vptr$semaphore", scope: !22, file: !22, baseType: !39, size: 32, flags: DIFlagArtificial)
!39 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !40, size: 32)
!40 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "__vtbl_ptr_type", baseType: !41, size: 32)
!41 = !DISubroutineType(types: !42)
!42 = !{!43}
!43 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!44 = !DISubprogram(name: "wait", linkageName: "_ZN9semaphore4waitEv", scope: !36, file: !22, line: 31, type: !45, scopeLine: 31, containingType: !36, virtualIndex: 0, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagPureVirtual)
!45 = !DISubroutineType(types: !46)
!46 = !{!43, !47}
!47 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !36, size: 32, flags: DIFlagArtificial | DIFlagObjectPointer)
!48 = !DISubprogram(name: "wait", linkageName: "_ZN9semaphore4waitEi", scope: !36, file: !22, line: 32, type: !49, scopeLine: 32, containingType: !36, virtualIndex: 1, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagPureVirtual)
!49 = !DISubroutineType(types: !50)
!50 = !{!43, !47, !43}
!51 = !DISubprogram(name: "give", linkageName: "_ZN9semaphore4giveEv", scope: !36, file: !22, line: 33, type: !52, scopeLine: 33, containingType: !36, virtualIndex: 2, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagPureVirtual)
!52 = !DISubroutineType(types: !53)
!53 = !{null, !47}
!54 = !DIDerivedType(tag: DW_TAG_member, name: "_sema_internal", scope: !33, file: !22, line: 52, baseType: !55, size: 128, offset: 32, flags: DIFlagProtected)
!55 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_sem", file: !56, line: 3704, size: 128, flags: DIFlagTypePassByValue, elements: !57, identifier: "_ZTS5k_sem")
!56 = !DIFile(filename: "zephyrproject/zephyr/include/kernel.h", directory: "/home/kenny")
!57 = !{!58, !79, !80}
!58 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !55, file: !56, line: 3705, baseType: !59, size: 64)
!59 = !DIDerivedType(tag: DW_TAG_typedef, name: "_wait_q_t", file: !60, line: 210, baseType: !61)
!60 = !DIFile(filename: "zephyrproject/zephyr/include/kernel_structs.h", directory: "/home/kenny")
!61 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !60, line: 208, size: 64, flags: DIFlagTypePassByValue, elements: !62, identifier: "_ZTS9_wait_q_t")
!62 = !{!63}
!63 = !DIDerivedType(tag: DW_TAG_member, name: "waitq", scope: !61, file: !60, line: 209, baseType: !64, size: 64)
!64 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dlist_t", file: !65, line: 42, baseType: !66)
!65 = !DIFile(filename: "zephyrproject/zephyr/include/sys/dlist.h", directory: "/home/kenny")
!66 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_dnode", file: !65, line: 31, size: 64, flags: DIFlagTypePassByValue, elements: !67, identifier: "_ZTS6_dnode")
!67 = !{!68, !74}
!68 = !DIDerivedType(tag: DW_TAG_member, scope: !66, file: !65, line: 32, baseType: !69, size: 32)
!69 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !66, file: !65, line: 32, size: 32, flags: DIFlagTypePassByValue, elements: !70, identifier: "_ZTSN6_dnodeUt_E")
!70 = !{!71, !73}
!71 = !DIDerivedType(tag: DW_TAG_member, name: "head", scope: !69, file: !65, line: 33, baseType: !72, size: 32)
!72 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !66, size: 32)
!73 = !DIDerivedType(tag: DW_TAG_member, name: "next", scope: !69, file: !65, line: 34, baseType: !72, size: 32)
!74 = !DIDerivedType(tag: DW_TAG_member, scope: !66, file: !65, line: 36, baseType: !75, size: 32, offset: 32)
!75 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !66, file: !65, line: 36, size: 32, flags: DIFlagTypePassByValue, elements: !76, identifier: "_ZTSN6_dnodeUt0_E")
!76 = !{!77, !78}
!77 = !DIDerivedType(tag: DW_TAG_member, name: "tail", scope: !75, file: !65, line: 37, baseType: !72, size: 32)
!78 = !DIDerivedType(tag: DW_TAG_member, name: "prev", scope: !75, file: !65, line: 38, baseType: !72, size: 32)
!79 = !DIDerivedType(tag: DW_TAG_member, name: "count", scope: !55, file: !56, line: 3706, baseType: !17, size: 32, offset: 64)
!80 = !DIDerivedType(tag: DW_TAG_member, name: "limit", scope: !55, file: !56, line: 3707, baseType: !17, size: 32, offset: 96)
!81 = !DISubprogram(name: "cpp_semaphore", scope: !33, file: !22, line: 54, type: !82, scopeLine: 54, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!82 = !DISubroutineType(types: !83)
!83 = !{null, !84}
!84 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !33, size: 32, flags: DIFlagArtificial | DIFlagObjectPointer)
!85 = !DISubprogram(name: "~cpp_semaphore", scope: !33, file: !22, line: 55, type: !82, scopeLine: 55, containingType: !33, virtualIndex: 0, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagVirtual)
!86 = !DISubprogram(name: "wait", linkageName: "_ZN13cpp_semaphore4waitEv", scope: !33, file: !22, line: 56, type: !87, scopeLine: 56, containingType: !33, virtualIndex: 0, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagVirtual)
!87 = !DISubroutineType(types: !88)
!88 = !{!43, !84}
!89 = !DISubprogram(name: "wait", linkageName: "_ZN13cpp_semaphore4waitEi", scope: !33, file: !22, line: 57, type: !90, scopeLine: 57, containingType: !33, virtualIndex: 1, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagVirtual)
!90 = !DISubroutineType(types: !91)
!91 = !{!43, !84, !43}
!92 = !DISubprogram(name: "give", linkageName: "_ZN13cpp_semaphore4giveEv", scope: !33, file: !22, line: 58, type: !82, scopeLine: 58, containingType: !33, virtualIndex: 2, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagVirtual)
!93 = !DIGlobalVariableExpression(var: !94, expr: !DIExpression())
!94 = distinct !DIGlobalVariable(name: "sem_coop", scope: !2, file: !22, line: 114, type: !33, isLocal: false, isDefinition: true)
!95 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_thread", file: !56, line: 570, size: 1024, flags: DIFlagTypePassByValue, elements: !96, identifier: "_ZTS8k_thread")
!96 = !{!97, !147, !160, !161, !165, !166, !176, !180}
!97 = !DIDerivedType(tag: DW_TAG_member, name: "base", scope: !95, file: !56, line: 572, baseType: !98, size: 448)
!98 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_base", file: !56, line: 441, size: 448, flags: DIFlagTypePassByValue, elements: !99, identifier: "_ZTS12_thread_base")
!99 = !{!100, !114, !116, !119, !120, !133, !134, !135, !146}
!100 = !DIDerivedType(tag: DW_TAG_member, scope: !98, file: !56, line: 444, baseType: !101, size: 64)
!101 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !98, file: !56, line: 444, size: 64, flags: DIFlagTypePassByValue, elements: !102, identifier: "_ZTSN12_thread_baseUt_E")
!102 = !{!103, !105}
!103 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_dlist", scope: !101, file: !56, line: 445, baseType: !104, size: 64)
!104 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dnode_t", file: !65, line: 43, baseType: !66)
!105 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_rb", scope: !101, file: !56, line: 446, baseType: !106, size: 64)
!106 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "rbnode", file: !107, line: 48, size: 64, flags: DIFlagTypePassByValue, elements: !108, identifier: "_ZTS6rbnode")
!107 = !DIFile(filename: "zephyrproject/zephyr/include/sys/rb.h", directory: "/home/kenny")
!108 = !{!109}
!109 = !DIDerivedType(tag: DW_TAG_member, name: "children", scope: !106, file: !107, line: 49, baseType: !110, size: 64)
!110 = !DICompositeType(tag: DW_TAG_array_type, baseType: !111, size: 64, elements: !112)
!111 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !106, size: 32)
!112 = !{!113}
!113 = !DISubrange(count: 2)
!114 = !DIDerivedType(tag: DW_TAG_member, name: "pended_on", scope: !98, file: !56, line: 452, baseType: !115, size: 32, offset: 64)
!115 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !59, size: 32)
!116 = !DIDerivedType(tag: DW_TAG_member, name: "user_options", scope: !98, file: !56, line: 455, baseType: !117, size: 8, offset: 96)
!117 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !9, line: 55, baseType: !118)
!118 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!119 = !DIDerivedType(tag: DW_TAG_member, name: "thread_state", scope: !98, file: !56, line: 458, baseType: !117, size: 8, offset: 104)
!120 = !DIDerivedType(tag: DW_TAG_member, scope: !98, file: !56, line: 474, baseType: !121, size: 16, offset: 112)
!121 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !98, file: !56, line: 474, size: 16, flags: DIFlagTypePassByValue, elements: !122, identifier: "_ZTSN12_thread_baseUt0_E")
!122 = !{!123, !130}
!123 = !DIDerivedType(tag: DW_TAG_member, scope: !121, file: !56, line: 475, baseType: !124, size: 16)
!124 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !121, file: !56, line: 475, size: 16, flags: DIFlagTypePassByValue, elements: !125, identifier: "_ZTSN12_thread_baseUt0_Ut_E")
!125 = !{!126, !129}
!126 = !DIDerivedType(tag: DW_TAG_member, name: "prio", scope: !124, file: !56, line: 480, baseType: !127, size: 8)
!127 = !DIDerivedType(tag: DW_TAG_typedef, name: "int8_t", file: !9, line: 40, baseType: !128)
!128 = !DIBasicType(name: "signed char", size: 8, encoding: DW_ATE_signed_char)
!129 = !DIDerivedType(tag: DW_TAG_member, name: "sched_locked", scope: !124, file: !56, line: 481, baseType: !117, size: 8, offset: 8)
!130 = !DIDerivedType(tag: DW_TAG_member, name: "preempt", scope: !121, file: !56, line: 484, baseType: !131, size: 16)
!131 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !9, line: 56, baseType: !132)
!132 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!133 = !DIDerivedType(tag: DW_TAG_member, name: "order_key", scope: !98, file: !56, line: 491, baseType: !17, size: 32, offset: 128)
!134 = !DIDerivedType(tag: DW_TAG_member, name: "swap_data", scope: !98, file: !56, line: 511, baseType: !16, size: 32, offset: 160)
!135 = !DIDerivedType(tag: DW_TAG_member, name: "timeout", scope: !98, file: !56, line: 515, baseType: !136, size: 192, offset: 192)
!136 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_timeout", file: !60, line: 221, size: 192, flags: DIFlagTypePassByValue, elements: !137, identifier: "_ZTS8_timeout")
!137 = !{!138, !139, !145}
!138 = !DIDerivedType(tag: DW_TAG_member, name: "node", scope: !136, file: !60, line: 222, baseType: !104, size: 64)
!139 = !DIDerivedType(tag: DW_TAG_member, name: "fn", scope: !136, file: !60, line: 223, baseType: !140, size: 32, offset: 64)
!140 = !DIDerivedType(tag: DW_TAG_typedef, name: "_timeout_func_t", file: !60, line: 219, baseType: !141)
!141 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !142, size: 32)
!142 = !DISubroutineType(types: !143)
!143 = !{null, !144}
!144 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !136, size: 32)
!145 = !DIDerivedType(tag: DW_TAG_member, name: "dticks", scope: !136, file: !60, line: 226, baseType: !8, size: 64, offset: 128)
!146 = !DIDerivedType(tag: DW_TAG_member, name: "join_waiters", scope: !98, file: !56, line: 518, baseType: !59, size: 64, offset: 384)
!147 = !DIDerivedType(tag: DW_TAG_member, name: "callee_saved", scope: !95, file: !56, line: 575, baseType: !148, size: 288, offset: 448)
!148 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_callee_saved", file: !149, line: 25, size: 288, flags: DIFlagTypePassByValue, elements: !150, identifier: "_ZTS13_callee_saved")
!149 = !DIFile(filename: "zephyrproject/zephyr/include/arch/arm/aarch32/thread.h", directory: "/home/kenny")
!150 = !{!151, !152, !153, !154, !155, !156, !157, !158, !159}
!151 = !DIDerivedType(tag: DW_TAG_member, name: "v1", scope: !148, file: !149, line: 26, baseType: !17, size: 32)
!152 = !DIDerivedType(tag: DW_TAG_member, name: "v2", scope: !148, file: !149, line: 27, baseType: !17, size: 32, offset: 32)
!153 = !DIDerivedType(tag: DW_TAG_member, name: "v3", scope: !148, file: !149, line: 28, baseType: !17, size: 32, offset: 64)
!154 = !DIDerivedType(tag: DW_TAG_member, name: "v4", scope: !148, file: !149, line: 29, baseType: !17, size: 32, offset: 96)
!155 = !DIDerivedType(tag: DW_TAG_member, name: "v5", scope: !148, file: !149, line: 30, baseType: !17, size: 32, offset: 128)
!156 = !DIDerivedType(tag: DW_TAG_member, name: "v6", scope: !148, file: !149, line: 31, baseType: !17, size: 32, offset: 160)
!157 = !DIDerivedType(tag: DW_TAG_member, name: "v7", scope: !148, file: !149, line: 32, baseType: !17, size: 32, offset: 192)
!158 = !DIDerivedType(tag: DW_TAG_member, name: "v8", scope: !148, file: !149, line: 33, baseType: !17, size: 32, offset: 224)
!159 = !DIDerivedType(tag: DW_TAG_member, name: "psp", scope: !148, file: !149, line: 34, baseType: !17, size: 32, offset: 256)
!160 = !DIDerivedType(tag: DW_TAG_member, name: "init_data", scope: !95, file: !56, line: 578, baseType: !16, size: 32, offset: 736)
!161 = !DIDerivedType(tag: DW_TAG_member, name: "fn_abort", scope: !95, file: !56, line: 583, baseType: !162, size: 32, offset: 768)
!162 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !163, size: 32)
!163 = !DISubroutineType(types: !164)
!164 = !{null}
!165 = !DIDerivedType(tag: DW_TAG_member, name: "errno_var", scope: !95, file: !56, line: 610, baseType: !43, size: 32, offset: 800)
!166 = !DIDerivedType(tag: DW_TAG_member, name: "stack_info", scope: !95, file: !56, line: 616, baseType: !167, size: 96, offset: 832)
!167 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_stack_info", file: !56, line: 525, size: 96, flags: DIFlagTypePassByValue, elements: !168, identifier: "_ZTS18_thread_stack_info")
!168 = !{!169, !172, !175}
!169 = !DIDerivedType(tag: DW_TAG_member, name: "start", scope: !167, file: !56, line: 529, baseType: !170, size: 32)
!170 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintptr_t", file: !9, line: 71, baseType: !171)
!171 = !DIBasicType(name: "long unsigned int", size: 32, encoding: DW_ATE_unsigned)
!172 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !167, file: !56, line: 538, baseType: !173, size: 32, offset: 32)
!173 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !174, line: 46, baseType: !18)
!174 = !DIFile(filename: "/usr/lib/llvm-9/lib/clang/9.0.1/include/stddef.h", directory: "")
!175 = !DIDerivedType(tag: DW_TAG_member, name: "delta", scope: !167, file: !56, line: 544, baseType: !173, size: 32, offset: 64)
!176 = !DIDerivedType(tag: DW_TAG_member, name: "resource_pool", scope: !95, file: !56, line: 641, baseType: !177, size: 32, offset: 928)
!177 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !178, size: 32)
!178 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mem_pool", file: !179, line: 30, flags: DIFlagFwdDecl, identifier: "_ZTS10k_mem_pool")
!179 = !DIFile(filename: "zephyrproject/zephyr/include/mempool_heap.h", directory: "/home/kenny")
!180 = !DIDerivedType(tag: DW_TAG_member, name: "arch", scope: !95, file: !56, line: 644, baseType: !181, size: 64, offset: 960)
!181 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_arch", file: !149, line: 60, size: 64, flags: DIFlagTypePassByValue, elements: !182, identifier: "_ZTS12_thread_arch")
!182 = !{!183, !184}
!183 = !DIDerivedType(tag: DW_TAG_member, name: "basepri", scope: !181, file: !149, line: 63, baseType: !17, size: 32)
!184 = !DIDerivedType(tag: DW_TAG_member, name: "swap_return_value", scope: !181, file: !149, line: 66, baseType: !17, size: 32, offset: 32)
!185 = !{!"clang version 9.0.1-12 "}
!186 = !{i32 2, !"Dwarf Version", i32 4}
!187 = !{i32 2, !"Debug Info Version", i32 3}
!188 = !{i32 1, !"wchar_size", i32 4}
!189 = !{i32 1, !"min_enum_size", i32 1}
!190 = distinct !DISubprogram(name: "wait", linkageName: "_ZN13cpp_semaphore4waitEv", scope: !33, file: !22, line: 78, type: !87, scopeLine: 79, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, declaration: !86, retainedNodes: !4)
!191 = !DILocalVariable(name: "this", arg: 1, scope: !190, type: !192, flags: DIFlagArtificial | DIFlagObjectPointer)
!192 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !33, size: 32)
!193 = !DILocation(line: 0, scope: !190)
!194 = !DILocation(line: 80, column: 14, scope: !190)
!195 = !DILocation(line: 80, column: 30, scope: !190)
!196 = !DILocation(line: 80, column: 2, scope: !190)
!197 = !DILocation(line: 81, column: 2, scope: !190)
!198 = distinct !DISubprogram(name: "wait", linkageName: "_ZN13cpp_semaphore4waitEi", scope: !33, file: !22, line: 95, type: !90, scopeLine: 96, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, declaration: !89, retainedNodes: !4)
!199 = !DILocalVariable(name: "this", arg: 1, scope: !198, type: !192, flags: DIFlagArtificial | DIFlagObjectPointer)
!200 = !DILocation(line: 0, scope: !198)
!201 = !DILocalVariable(name: "timeout", arg: 2, scope: !198, file: !22, line: 95, type: !43)
!202 = !DILocation(line: 95, column: 29, scope: !198)
!203 = !DILocation(line: 97, column: 21, scope: !198)
!204 = !DILocation(line: 97, column: 37, scope: !198)
!205 = !DILocation(line: 97, column: 9, scope: !198)
!206 = !DILocation(line: 97, column: 2, scope: !198)
!207 = distinct !DISubprogram(name: "give", linkageName: "_ZN13cpp_semaphore4giveEv", scope: !33, file: !22, line: 108, type: !82, scopeLine: 109, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, declaration: !92, retainedNodes: !4)
!208 = !DILocalVariable(name: "this", arg: 1, scope: !207, type: !192, flags: DIFlagArtificial | DIFlagObjectPointer)
!209 = !DILocation(line: 0, scope: !207)
!210 = !DILocation(line: 110, column: 14, scope: !207)
!211 = !DILocation(line: 110, column: 2, scope: !207)
!212 = !DILocation(line: 111, column: 1, scope: !207)
!213 = distinct !DISubprogram(name: "~cpp_semaphore", linkageName: "_ZN13cpp_semaphoreD2Ev", scope: !33, file: !22, line: 55, type: !82, scopeLine: 55, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, declaration: !85, retainedNodes: !4)
!214 = !DILocalVariable(name: "this", arg: 1, scope: !213, type: !192, flags: DIFlagArtificial | DIFlagObjectPointer)
!215 = !DILocation(line: 0, scope: !213)
!216 = !DILocation(line: 55, column: 28, scope: !213)
!217 = distinct !DISubprogram(name: "~cpp_semaphore", linkageName: "_ZN13cpp_semaphoreD0Ev", scope: !33, file: !22, line: 55, type: !82, scopeLine: 55, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, declaration: !85, retainedNodes: !4)
!218 = !DILocalVariable(name: "this", arg: 1, scope: !217, type: !192, flags: DIFlagArtificial | DIFlagObjectPointer)
!219 = !DILocation(line: 0, scope: !217)
!220 = !DILocation(line: 55, column: 27, scope: !217)
!221 = !DILocation(line: 55, column: 28, scope: !217)
!222 = distinct !DISubprogram(name: "k_sem_give", linkageName: "_ZL10k_sem_giveP5k_sem", scope: !223, file: !223, line: 761, type: !224, scopeLine: 762, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !4)
!223 = !DIFile(filename: "zephyr/include/generated/syscalls/kernel.h", directory: "/home/kenny/ara/build/appl/Zephyr/cpp_sems")
!224 = !DISubroutineType(types: !225)
!225 = !{null, !226}
!226 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !55, size: 32)
!227 = !DILocalVariable(name: "sem", arg: 1, scope: !222, file: !223, line: 761, type: !226)
!228 = !DILocation(line: 761, column: 64, scope: !222)
!229 = !DILocation(line: 769, column: 2, scope: !222)
!230 = !DILocation(line: 769, column: 2, scope: !231)
!231 = distinct !DILexicalBlock(scope: !222, file: !223, line: 769, column: 2)
!232 = !{i32 -2141845008}
!233 = !DILocation(line: 770, column: 20, scope: !222)
!234 = !DILocation(line: 770, column: 2, scope: !222)
!235 = !DILocation(line: 771, column: 1, scope: !222)
!236 = distinct !DISubprogram(name: "k_ms_to_ticks_ceil64", linkageName: "_ZL20k_ms_to_ticks_ceil64y", scope: !237, file: !237, line: 369, type: !238, scopeLine: 370, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !4)
!237 = !DIFile(filename: "zephyrproject/zephyr/include/sys/time_units.h", directory: "/home/kenny")
!238 = !DISubroutineType(types: !239)
!239 = !{!240, !240}
!240 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint64_t", file: !9, line: 58, baseType: !241)
!241 = !DIBasicType(name: "long long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!242 = !DILocalVariable(name: "t", arg: 1, scope: !243, file: !237, line: 78, type: !240)
!243 = distinct !DISubprogram(name: "z_tmcvt", linkageName: "_ZL7z_tmcvtyjjbbbb", scope: !237, file: !237, line: 78, type: !244, scopeLine: 82, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !4)
!244 = !DISubroutineType(types: !245)
!245 = !{!240, !240, !17, !17, !246, !246, !246, !246}
!246 = !DIBasicType(name: "bool", size: 8, encoding: DW_ATE_boolean)
!247 = !DILocation(line: 78, column: 63, scope: !243, inlinedAt: !248)
!248 = distinct !DILocation(line: 372, column: 9, scope: !236)
!249 = !DILocalVariable(name: "from_hz", arg: 2, scope: !243, file: !237, line: 78, type: !17)
!250 = !DILocation(line: 78, column: 75, scope: !243, inlinedAt: !248)
!251 = !DILocalVariable(name: "to_hz", arg: 3, scope: !243, file: !237, line: 79, type: !17)
!252 = !DILocation(line: 79, column: 18, scope: !243, inlinedAt: !248)
!253 = !DILocalVariable(name: "const_hz", arg: 4, scope: !243, file: !237, line: 79, type: !246)
!254 = !DILocation(line: 79, column: 30, scope: !243, inlinedAt: !248)
!255 = !DILocalVariable(name: "result32", arg: 5, scope: !243, file: !237, line: 80, type: !246)
!256 = !DILocation(line: 80, column: 14, scope: !243, inlinedAt: !248)
!257 = !DILocalVariable(name: "round_up", arg: 6, scope: !243, file: !237, line: 80, type: !246)
!258 = !DILocation(line: 80, column: 29, scope: !243, inlinedAt: !248)
!259 = !DILocalVariable(name: "round_off", arg: 7, scope: !243, file: !237, line: 81, type: !246)
!260 = !DILocation(line: 81, column: 14, scope: !243, inlinedAt: !248)
!261 = !DILocalVariable(name: "mul_ratio", scope: !243, file: !237, line: 84, type: !246)
!262 = !DILocation(line: 84, column: 7, scope: !243, inlinedAt: !248)
!263 = !DILocalVariable(name: "div_ratio", scope: !243, file: !237, line: 86, type: !246)
!264 = !DILocation(line: 86, column: 7, scope: !243, inlinedAt: !248)
!265 = !DILocalVariable(name: "off", scope: !243, file: !237, line: 93, type: !240)
!266 = !DILocation(line: 93, column: 11, scope: !243, inlinedAt: !248)
!267 = !DILocalVariable(name: "rdivisor", scope: !268, file: !237, line: 96, type: !17)
!268 = distinct !DILexicalBlock(scope: !269, file: !237, line: 95, column: 18)
!269 = distinct !DILexicalBlock(scope: !243, file: !237, line: 95, column: 6)
!270 = !DILocation(line: 96, column: 12, scope: !268, inlinedAt: !248)
!271 = !DILocalVariable(name: "t", arg: 1, scope: !236, file: !237, line: 369, type: !240)
!272 = !DILocation(line: 369, column: 69, scope: !236)
!273 = !DILocation(line: 372, column: 17, scope: !236)
!274 = !DILocation(line: 84, column: 19, scope: !243, inlinedAt: !248)
!275 = !DILocation(line: 84, column: 28, scope: !243, inlinedAt: !248)
!276 = !DILocation(line: 85, column: 4, scope: !243, inlinedAt: !248)
!277 = !DILocation(line: 85, column: 12, scope: !243, inlinedAt: !248)
!278 = !DILocation(line: 85, column: 10, scope: !243, inlinedAt: !248)
!279 = !DILocation(line: 85, column: 21, scope: !243, inlinedAt: !248)
!280 = !DILocation(line: 85, column: 26, scope: !243, inlinedAt: !248)
!281 = !DILocation(line: 85, column: 34, scope: !243, inlinedAt: !248)
!282 = !DILocation(line: 85, column: 32, scope: !243, inlinedAt: !248)
!283 = !DILocation(line: 85, column: 43, scope: !243, inlinedAt: !248)
!284 = !DILocation(line: 0, scope: !243, inlinedAt: !248)
!285 = !DILocation(line: 86, column: 19, scope: !243, inlinedAt: !248)
!286 = !DILocation(line: 86, column: 28, scope: !243, inlinedAt: !248)
!287 = !DILocation(line: 87, column: 4, scope: !243, inlinedAt: !248)
!288 = !DILocation(line: 87, column: 14, scope: !243, inlinedAt: !248)
!289 = !DILocation(line: 87, column: 12, scope: !243, inlinedAt: !248)
!290 = !DILocation(line: 87, column: 21, scope: !243, inlinedAt: !248)
!291 = !DILocation(line: 87, column: 26, scope: !243, inlinedAt: !248)
!292 = !DILocation(line: 87, column: 36, scope: !243, inlinedAt: !248)
!293 = !DILocation(line: 87, column: 34, scope: !243, inlinedAt: !248)
!294 = !DILocation(line: 87, column: 43, scope: !243, inlinedAt: !248)
!295 = !DILocation(line: 89, column: 6, scope: !296, inlinedAt: !248)
!296 = distinct !DILexicalBlock(scope: !243, file: !237, line: 89, column: 6)
!297 = !DILocation(line: 89, column: 17, scope: !296, inlinedAt: !248)
!298 = !DILocation(line: 89, column: 14, scope: !296, inlinedAt: !248)
!299 = !DILocation(line: 89, column: 6, scope: !243, inlinedAt: !248)
!300 = !DILocation(line: 90, column: 10, scope: !301, inlinedAt: !248)
!301 = distinct !DILexicalBlock(scope: !296, file: !237, line: 89, column: 24)
!302 = !DILocation(line: 90, column: 32, scope: !301, inlinedAt: !248)
!303 = !DILocation(line: 90, column: 21, scope: !301, inlinedAt: !248)
!304 = !DILocation(line: 90, column: 37, scope: !301, inlinedAt: !248)
!305 = !DILocation(line: 90, column: 3, scope: !301, inlinedAt: !248)
!306 = !DILocation(line: 95, column: 7, scope: !269, inlinedAt: !248)
!307 = !DILocation(line: 95, column: 6, scope: !243, inlinedAt: !248)
!308 = !DILocation(line: 96, column: 23, scope: !268, inlinedAt: !248)
!309 = !DILocation(line: 96, column: 36, scope: !268, inlinedAt: !248)
!310 = !DILocation(line: 96, column: 46, scope: !268, inlinedAt: !248)
!311 = !DILocation(line: 96, column: 44, scope: !268, inlinedAt: !248)
!312 = !DILocation(line: 96, column: 55, scope: !268, inlinedAt: !248)
!313 = !DILocation(line: 98, column: 7, scope: !314, inlinedAt: !248)
!314 = distinct !DILexicalBlock(scope: !268, file: !237, line: 98, column: 7)
!315 = !DILocation(line: 98, column: 7, scope: !268, inlinedAt: !248)
!316 = !DILocation(line: 99, column: 10, scope: !317, inlinedAt: !248)
!317 = distinct !DILexicalBlock(scope: !314, file: !237, line: 98, column: 17)
!318 = !DILocation(line: 99, column: 19, scope: !317, inlinedAt: !248)
!319 = !DILocation(line: 99, column: 8, scope: !317, inlinedAt: !248)
!320 = !DILocation(line: 100, column: 3, scope: !317, inlinedAt: !248)
!321 = !DILocation(line: 100, column: 14, scope: !322, inlinedAt: !248)
!322 = distinct !DILexicalBlock(scope: !314, file: !237, line: 100, column: 14)
!323 = !DILocation(line: 100, column: 14, scope: !314, inlinedAt: !248)
!324 = !DILocation(line: 101, column: 10, scope: !325, inlinedAt: !248)
!325 = distinct !DILexicalBlock(scope: !322, file: !237, line: 100, column: 25)
!326 = !DILocation(line: 101, column: 19, scope: !325, inlinedAt: !248)
!327 = !DILocation(line: 101, column: 8, scope: !325, inlinedAt: !248)
!328 = !DILocation(line: 102, column: 3, scope: !325, inlinedAt: !248)
!329 = !DILocation(line: 103, column: 2, scope: !268, inlinedAt: !248)
!330 = !DILocation(line: 110, column: 6, scope: !331, inlinedAt: !248)
!331 = distinct !DILexicalBlock(scope: !243, file: !237, line: 110, column: 6)
!332 = !DILocation(line: 110, column: 6, scope: !243, inlinedAt: !248)
!333 = !DILocation(line: 111, column: 8, scope: !334, inlinedAt: !248)
!334 = distinct !DILexicalBlock(scope: !331, file: !237, line: 110, column: 17)
!335 = !DILocation(line: 111, column: 5, scope: !334, inlinedAt: !248)
!336 = !DILocation(line: 112, column: 7, scope: !337, inlinedAt: !248)
!337 = distinct !DILexicalBlock(scope: !334, file: !237, line: 112, column: 7)
!338 = !DILocation(line: 112, column: 16, scope: !337, inlinedAt: !248)
!339 = !DILocation(line: 112, column: 20, scope: !337, inlinedAt: !248)
!340 = !DILocation(line: 112, column: 22, scope: !337, inlinedAt: !248)
!341 = !DILocation(line: 112, column: 7, scope: !334, inlinedAt: !248)
!342 = !DILocation(line: 113, column: 22, scope: !343, inlinedAt: !248)
!343 = distinct !DILexicalBlock(scope: !337, file: !237, line: 112, column: 36)
!344 = !DILocation(line: 113, column: 28, scope: !343, inlinedAt: !248)
!345 = !DILocation(line: 113, column: 38, scope: !343, inlinedAt: !248)
!346 = !DILocation(line: 113, column: 36, scope: !343, inlinedAt: !248)
!347 = !DILocation(line: 113, column: 25, scope: !343, inlinedAt: !248)
!348 = !DILocation(line: 113, column: 11, scope: !343, inlinedAt: !248)
!349 = !DILocation(line: 113, column: 4, scope: !343, inlinedAt: !248)
!350 = !DILocation(line: 115, column: 11, scope: !351, inlinedAt: !248)
!351 = distinct !DILexicalBlock(scope: !337, file: !237, line: 114, column: 10)
!352 = !DILocation(line: 115, column: 16, scope: !351, inlinedAt: !248)
!353 = !DILocation(line: 115, column: 26, scope: !351, inlinedAt: !248)
!354 = !DILocation(line: 115, column: 24, scope: !351, inlinedAt: !248)
!355 = !DILocation(line: 115, column: 15, scope: !351, inlinedAt: !248)
!356 = !DILocation(line: 115, column: 13, scope: !351, inlinedAt: !248)
!357 = !DILocation(line: 115, column: 4, scope: !351, inlinedAt: !248)
!358 = !DILocation(line: 117, column: 13, scope: !359, inlinedAt: !248)
!359 = distinct !DILexicalBlock(scope: !331, file: !237, line: 117, column: 13)
!360 = !DILocation(line: 117, column: 13, scope: !331, inlinedAt: !248)
!361 = !DILocation(line: 118, column: 7, scope: !362, inlinedAt: !248)
!362 = distinct !DILexicalBlock(scope: !363, file: !237, line: 118, column: 7)
!363 = distinct !DILexicalBlock(scope: !359, file: !237, line: 117, column: 24)
!364 = !DILocation(line: 118, column: 7, scope: !363, inlinedAt: !248)
!365 = !DILocation(line: 119, column: 22, scope: !366, inlinedAt: !248)
!366 = distinct !DILexicalBlock(scope: !362, file: !237, line: 118, column: 17)
!367 = !DILocation(line: 119, column: 28, scope: !366, inlinedAt: !248)
!368 = !DILocation(line: 119, column: 36, scope: !366, inlinedAt: !248)
!369 = !DILocation(line: 119, column: 34, scope: !366, inlinedAt: !248)
!370 = !DILocation(line: 119, column: 25, scope: !366, inlinedAt: !248)
!371 = !DILocation(line: 119, column: 11, scope: !366, inlinedAt: !248)
!372 = !DILocation(line: 119, column: 4, scope: !366, inlinedAt: !248)
!373 = !DILocation(line: 121, column: 11, scope: !374, inlinedAt: !248)
!374 = distinct !DILexicalBlock(scope: !362, file: !237, line: 120, column: 10)
!375 = !DILocation(line: 121, column: 16, scope: !374, inlinedAt: !248)
!376 = !DILocation(line: 121, column: 24, scope: !374, inlinedAt: !248)
!377 = !DILocation(line: 121, column: 22, scope: !374, inlinedAt: !248)
!378 = !DILocation(line: 121, column: 15, scope: !374, inlinedAt: !248)
!379 = !DILocation(line: 121, column: 13, scope: !374, inlinedAt: !248)
!380 = !DILocation(line: 121, column: 4, scope: !374, inlinedAt: !248)
!381 = !DILocation(line: 124, column: 7, scope: !382, inlinedAt: !248)
!382 = distinct !DILexicalBlock(scope: !383, file: !237, line: 124, column: 7)
!383 = distinct !DILexicalBlock(scope: !359, file: !237, line: 123, column: 9)
!384 = !DILocation(line: 124, column: 7, scope: !383, inlinedAt: !248)
!385 = !DILocation(line: 125, column: 23, scope: !386, inlinedAt: !248)
!386 = distinct !DILexicalBlock(scope: !382, file: !237, line: 124, column: 17)
!387 = !DILocation(line: 125, column: 27, scope: !386, inlinedAt: !248)
!388 = !DILocation(line: 125, column: 25, scope: !386, inlinedAt: !248)
!389 = !DILocation(line: 125, column: 35, scope: !386, inlinedAt: !248)
!390 = !DILocation(line: 125, column: 33, scope: !386, inlinedAt: !248)
!391 = !DILocation(line: 125, column: 42, scope: !386, inlinedAt: !248)
!392 = !DILocation(line: 125, column: 40, scope: !386, inlinedAt: !248)
!393 = !DILocation(line: 125, column: 21, scope: !386, inlinedAt: !248)
!394 = !DILocation(line: 125, column: 11, scope: !386, inlinedAt: !248)
!395 = !DILocation(line: 125, column: 4, scope: !386, inlinedAt: !248)
!396 = !DILocation(line: 127, column: 12, scope: !397, inlinedAt: !248)
!397 = distinct !DILexicalBlock(scope: !382, file: !237, line: 126, column: 10)
!398 = !DILocation(line: 127, column: 16, scope: !397, inlinedAt: !248)
!399 = !DILocation(line: 127, column: 14, scope: !397, inlinedAt: !248)
!400 = !DILocation(line: 127, column: 24, scope: !397, inlinedAt: !248)
!401 = !DILocation(line: 127, column: 22, scope: !397, inlinedAt: !248)
!402 = !DILocation(line: 127, column: 31, scope: !397, inlinedAt: !248)
!403 = !DILocation(line: 127, column: 29, scope: !397, inlinedAt: !248)
!404 = !DILocation(line: 127, column: 4, scope: !397, inlinedAt: !248)
!405 = !DILocation(line: 130, column: 1, scope: !243, inlinedAt: !248)
!406 = !DILocation(line: 372, column: 2, scope: !236)
!407 = distinct !DISubprogram(name: "k_sem_take", linkageName: "_ZL10k_sem_takeP5k_sem11k_timeout_t", scope: !223, file: !223, line: 746, type: !408, scopeLine: 747, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !4)
!408 = !DISubroutineType(types: !409)
!409 = !{!43, !226, !410}
!410 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_timeout_t", file: !7, line: 69, baseType: !411)
!411 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !7, line: 67, size: 64, flags: DIFlagTypePassByValue, elements: !412, identifier: "_ZTS11k_timeout_t")
!412 = !{!413}
!413 = !DIDerivedType(tag: DW_TAG_member, name: "ticks", scope: !411, file: !7, line: 68, baseType: !6, size: 64)
!414 = !DILocalVariable(name: "sem", arg: 1, scope: !407, file: !223, line: 746, type: !226)
!415 = !DILocation(line: 746, column: 63, scope: !407)
!416 = !DILocalVariable(name: "timeout", arg: 2, scope: !407, file: !223, line: 746, type: !410)
!417 = !DILocation(line: 746, column: 80, scope: !407)
!418 = !DILocation(line: 755, column: 2, scope: !407)
!419 = !DILocation(line: 755, column: 2, scope: !420)
!420 = distinct !DILexicalBlock(scope: !407, file: !223, line: 755, column: 2)
!421 = !{i32 -2141845074}
!422 = !DILocation(line: 756, column: 27, scope: !407)
!423 = !DILocation(line: 756, column: 32, scope: !407)
!424 = !DILocation(line: 756, column: 9, scope: !407)
!425 = !DILocation(line: 756, column: 2, scope: !407)
!426 = distinct !DISubprogram(linkageName: "_GLOBAL__sub_I_main.cpp", scope: !3, file: !3, type: !427, flags: DIFlagArtificial, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !4)
!427 = !DISubroutineType(types: !4)
!428 = !DILocation(line: 0, scope: !426)
!429 = distinct !DISubprogram(name: "__cxx_global_var_init", scope: !22, file: !22, line: 113, type: !163, scopeLine: 113, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !4)
!430 = !DILocation(line: 113, column: 15, scope: !429)
!431 = distinct !DISubprogram(name: "__cxx_global_var_init.1", scope: !22, file: !22, line: 114, type: !163, scopeLine: 114, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !4)
!432 = !DILocation(line: 114, column: 15, scope: !431)
!433 = distinct !DISubprogram(name: "cpp_semaphore", linkageName: "_ZN13cpp_semaphoreC2Ev", scope: !33, file: !22, line: 64, type: !82, scopeLine: 65, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, declaration: !81, retainedNodes: !4)
!434 = !DILocalVariable(name: "this", arg: 1, scope: !433, type: !192, flags: DIFlagArtificial | DIFlagObjectPointer)
!435 = !DILocation(line: 0, scope: !433)
!436 = !DILocation(line: 65, column: 1, scope: !433)
!437 = !DILocation(line: 64, column: 16, scope: !433)
!438 = !DILocation(line: 66, column: 2, scope: !439)
!439 = distinct !DILexicalBlock(scope: !433, file: !22, line: 65, column: 1)
!440 = !DILocation(line: 67, column: 14, scope: !439)
!441 = !DILocation(line: 67, column: 2, scope: !439)
!442 = !DILocation(line: 68, column: 1, scope: !433)
!443 = distinct !DISubprogram(name: "semaphore", linkageName: "_ZN9semaphoreC2Ev", scope: !36, file: !22, line: 29, type: !52, scopeLine: 29, flags: DIFlagArtificial | DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, declaration: !444, retainedNodes: !4)
!444 = !DISubprogram(name: "semaphore", scope: !36, type: !52, flags: DIFlagPublic | DIFlagArtificial | DIFlagPrototyped, spFlags: 0)
!445 = !DILocalVariable(name: "this", arg: 1, scope: !443, type: !446, flags: DIFlagArtificial | DIFlagObjectPointer)
!446 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !36, size: 32)
!447 = !DILocation(line: 0, scope: !443)
!448 = !DILocation(line: 29, column: 7, scope: !443)
!449 = distinct !DISubprogram(name: "k_sem_init", linkageName: "_ZL10k_sem_initP5k_semjj", scope: !223, file: !223, line: 733, type: !450, scopeLine: 734, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !4)
!450 = !DISubroutineType(types: !451)
!451 = !{!43, !226, !18, !18}
!452 = !DILocalVariable(name: "sem", arg: 1, scope: !449, file: !223, line: 733, type: !226)
!453 = !DILocation(line: 733, column: 63, scope: !449)
!454 = !DILocalVariable(name: "initial_count", arg: 2, scope: !449, file: !223, line: 733, type: !18)
!455 = !DILocation(line: 733, column: 81, scope: !449)
!456 = !DILocalVariable(name: "limit", arg: 3, scope: !449, file: !223, line: 733, type: !18)
!457 = !DILocation(line: 733, column: 109, scope: !449)
!458 = !DILocation(line: 740, column: 2, scope: !449)
!459 = !DILocation(line: 740, column: 2, scope: !460)
!460 = distinct !DILexicalBlock(scope: !449, file: !223, line: 740, column: 2)
!461 = !{i32 -2141845140}
!462 = !DILocation(line: 741, column: 27, scope: !449)
!463 = !DILocation(line: 741, column: 32, scope: !449)
!464 = !DILocation(line: 741, column: 47, scope: !449)
!465 = !DILocation(line: 741, column: 9, scope: !449)
!466 = !DILocation(line: 741, column: 2, scope: !449)
!467 = distinct !DISubprogram(name: "coop_thread_entry", linkageName: "_Z17coop_thread_entryv", scope: !22, file: !22, line: 116, type: !163, scopeLine: 117, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !4)
!468 = !DILocalVariable(name: "timer", scope: !467, file: !22, line: 118, type: !469)
!469 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_timer", file: !56, line: 1753, size: 448, flags: DIFlagTypePassByValue, elements: !470, identifier: "_ZTS7k_timer")
!470 = !{!471, !472, !473, !478, !479, !480, !481}
!471 = !DIDerivedType(tag: DW_TAG_member, name: "timeout", scope: !469, file: !56, line: 1759, baseType: !136, size: 192)
!472 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !469, file: !56, line: 1762, baseType: !59, size: 64, offset: 192)
!473 = !DIDerivedType(tag: DW_TAG_member, name: "expiry_fn", scope: !469, file: !56, line: 1765, baseType: !474, size: 32, offset: 256)
!474 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !475, size: 32)
!475 = !DISubroutineType(types: !476)
!476 = !{null, !477}
!477 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !469, size: 32)
!478 = !DIDerivedType(tag: DW_TAG_member, name: "stop_fn", scope: !469, file: !56, line: 1768, baseType: !474, size: 32, offset: 288)
!479 = !DIDerivedType(tag: DW_TAG_member, name: "period", scope: !469, file: !56, line: 1771, baseType: !410, size: 64, offset: 320)
!480 = !DIDerivedType(tag: DW_TAG_member, name: "status", scope: !469, file: !56, line: 1774, baseType: !17, size: 32, offset: 384)
!481 = !DIDerivedType(tag: DW_TAG_member, name: "user_data", scope: !469, file: !56, line: 1777, baseType: !16, size: 32, offset: 416)
!482 = !DILocation(line: 118, column: 17, scope: !467)
!483 = !DILocation(line: 120, column: 2, scope: !467)
!484 = !DILocation(line: 122, column: 2, scope: !467)
!485 = !DILocation(line: 124, column: 12, scope: !486)
!486 = distinct !DILexicalBlock(scope: !467, file: !22, line: 122, column: 12)
!487 = !DILocation(line: 127, column: 3, scope: !486)
!488 = !DILocation(line: 130, column: 25, scope: !486)
!489 = !DILocation(line: 130, column: 44, scope: !486)
!490 = !DILocation(line: 130, column: 3, scope: !486)
!491 = !DILocation(line: 131, column: 3, scope: !486)
!492 = !DILocation(line: 132, column: 12, scope: !486)
!493 = distinct !{!493, !484, !494}
!494 = !DILocation(line: 133, column: 2, scope: !467)
!495 = distinct !DISubprogram(name: "k_timer_start", linkageName: "_ZL13k_timer_startP7k_timer11k_timeout_tS1_", scope: !223, file: !223, line: 389, type: !496, scopeLine: 390, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !4)
!496 = !DISubroutineType(types: !497)
!497 = !{null, !477, !410, !410}
!498 = !DILocalVariable(name: "timer", arg: 1, scope: !495, file: !223, line: 389, type: !477)
!499 = !DILocation(line: 389, column: 69, scope: !495)
!500 = !DILocalVariable(name: "duration", arg: 2, scope: !495, file: !223, line: 389, type: !410)
!501 = !DILocation(line: 389, column: 88, scope: !495)
!502 = !DILocalVariable(name: "period", arg: 3, scope: !495, file: !223, line: 389, type: !410)
!503 = !DILocation(line: 389, column: 110, scope: !495)
!504 = !DILocation(line: 401, column: 2, scope: !495)
!505 = !DILocation(line: 401, column: 2, scope: !506)
!506 = distinct !DILexicalBlock(scope: !495, file: !223, line: 401, column: 2)
!507 = !{i32 -2141846790}
!508 = !DILocation(line: 402, column: 23, scope: !495)
!509 = !DILocation(line: 402, column: 30, scope: !495)
!510 = !DILocation(line: 402, column: 40, scope: !495)
!511 = !DILocation(line: 402, column: 2, scope: !495)
!512 = !DILocation(line: 403, column: 1, scope: !495)
!513 = distinct !DISubprogram(name: "k_timer_status_sync", linkageName: "_ZL19k_timer_status_syncP7k_timer", scope: !223, file: !223, line: 434, type: !514, scopeLine: 435, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !4)
!514 = !DISubroutineType(types: !515)
!515 = !{!17, !477}
!516 = !DILocalVariable(name: "timer", arg: 1, scope: !513, file: !223, line: 434, type: !477)
!517 = !DILocation(line: 434, column: 79, scope: !513)
!518 = !DILocation(line: 441, column: 2, scope: !513)
!519 = !DILocation(line: 441, column: 2, scope: !520)
!520 = distinct !DILexicalBlock(scope: !513, file: !223, line: 441, column: 2)
!521 = !{i32 -2141846592}
!522 = !DILocation(line: 442, column: 36, scope: !513)
!523 = !DILocation(line: 442, column: 9, scope: !513)
!524 = !DILocation(line: 442, column: 2, scope: !513)
!525 = distinct !DISubprogram(name: "main", linkageName: "_Z4mainv", scope: !22, file: !22, line: 136, type: !163, scopeLine: 137, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !4)
!526 = !DILocalVariable(name: "timer", scope: !525, file: !22, line: 138, type: !469)
!527 = !DILocation(line: 138, column: 17, scope: !525)
!528 = !DILocation(line: 142, column: 41, scope: !525)
!529 = !DILocation(line: 140, column: 2, scope: !525)
!530 = !DILocation(line: 143, column: 2, scope: !525)
!531 = !DILocation(line: 145, column: 2, scope: !525)
!532 = !DILocation(line: 147, column: 3, scope: !533)
!533 = distinct !DILexicalBlock(scope: !525, file: !22, line: 145, column: 12)
!534 = !DILocation(line: 150, column: 25, scope: !533)
!535 = !DILocation(line: 150, column: 44, scope: !533)
!536 = !DILocation(line: 150, column: 3, scope: !533)
!537 = !DILocation(line: 151, column: 3, scope: !533)
!538 = !DILocation(line: 152, column: 12, scope: !533)
!539 = !DILocation(line: 155, column: 12, scope: !533)
!540 = distinct !{!540, !531, !541}
!541 = !DILocation(line: 156, column: 2, scope: !525)
!542 = distinct !DISubprogram(name: "k_thread_create", linkageName: "_ZL15k_thread_createP8k_threadP22z_thread_stack_elementjPFvPvS3_S3_ES3_S3_S3_ij11k_timeout_t", scope: !223, file: !223, line: 66, type: !543, scopeLine: 67, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !4)
!543 = !DISubroutineType(types: !544)
!544 = !{!545, !546, !547, !173, !11, !16, !16, !16, !43, !17, !410}
!545 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_tid_t", file: !56, line: 648, baseType: !546)
!546 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !95, size: 32)
!547 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !548, size: 32)
!548 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_stack_t", file: !12, line: 44, baseType: !24)
!549 = !DILocalVariable(name: "new_thread", arg: 1, scope: !542, file: !223, line: 66, type: !546)
!550 = !DILocation(line: 66, column: 75, scope: !542)
!551 = !DILocalVariable(name: "stack", arg: 2, scope: !542, file: !223, line: 66, type: !547)
!552 = !DILocation(line: 66, column: 106, scope: !542)
!553 = !DILocalVariable(name: "stack_size", arg: 3, scope: !542, file: !223, line: 66, type: !173)
!554 = !DILocation(line: 66, column: 120, scope: !542)
!555 = !DILocalVariable(name: "entry", arg: 4, scope: !542, file: !223, line: 66, type: !11)
!556 = !DILocation(line: 66, column: 149, scope: !542)
!557 = !DILocalVariable(name: "p1", arg: 5, scope: !542, file: !223, line: 66, type: !16)
!558 = !DILocation(line: 66, column: 163, scope: !542)
!559 = !DILocalVariable(name: "p2", arg: 6, scope: !542, file: !223, line: 66, type: !16)
!560 = !DILocation(line: 66, column: 174, scope: !542)
!561 = !DILocalVariable(name: "p3", arg: 7, scope: !542, file: !223, line: 66, type: !16)
!562 = !DILocation(line: 66, column: 185, scope: !542)
!563 = !DILocalVariable(name: "prio", arg: 8, scope: !542, file: !223, line: 66, type: !43)
!564 = !DILocation(line: 66, column: 193, scope: !542)
!565 = !DILocalVariable(name: "options", arg: 9, scope: !542, file: !223, line: 66, type: !17)
!566 = !DILocation(line: 66, column: 208, scope: !542)
!567 = !DILocalVariable(name: "delay", arg: 10, scope: !542, file: !223, line: 66, type: !410)
!568 = !DILocation(line: 66, column: 229, scope: !542)
!569 = !DILocation(line: 83, column: 2, scope: !542)
!570 = !DILocation(line: 83, column: 2, scope: !571)
!571 = distinct !DILexicalBlock(scope: !542, file: !223, line: 83, column: 2)
!572 = !{i32 -2141848308}
!573 = !DILocation(line: 84, column: 32, scope: !542)
!574 = !DILocation(line: 84, column: 44, scope: !542)
!575 = !DILocation(line: 84, column: 51, scope: !542)
!576 = !DILocation(line: 84, column: 63, scope: !542)
!577 = !DILocation(line: 84, column: 70, scope: !542)
!578 = !DILocation(line: 84, column: 74, scope: !542)
!579 = !DILocation(line: 84, column: 78, scope: !542)
!580 = !DILocation(line: 84, column: 82, scope: !542)
!581 = !DILocation(line: 84, column: 88, scope: !542)
!582 = !DILocation(line: 84, column: 97, scope: !542)
!583 = !DILocation(line: 84, column: 9, scope: !542)
!584 = !DILocation(line: 84, column: 2, scope: !542)
