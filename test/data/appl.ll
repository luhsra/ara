; ModuleID = '../appl/OSEK/a.cc'
source_filename = "../appl/OSEK/a.cc"
target datalayout = "e-m:e-p:32:32-f64:32:64-f80:32-n8:16:32-S128"
target triple = "i386-pc-linux-gnu"

%class.Null_Stream = type { %class.O_Stream }
%class.O_Stream = type { i8 }
%class.ColorTerminal = type <{ %class.Terminal, [11 x i8], i8 }>
%class.Terminal = type { %class.O_Stream.0, i16 }
%class.O_Stream.0 = type { i8 }

$_ZN11Null_Stream8setcolorI5ColorEEvT_S2_ = comdat any

$_ZN11Null_StreamlsIPKcEERS_T_ = comdat any

$_ZN11Null_StreamlsIS_EERS_PFR8O_StreamIT_ES5_E = comdat any

$_Z4endlI11Null_StreamER8O_StreamIT_ES4_ = comdat any

$_ZN8O_StreamI11Null_StreamElsEc = comdat any

$_ZN8O_StreamI11Null_StreamE7putcharEc = comdat any

$_ZN11Null_Stream7putcharEc = comdat any

$_ZN13ColorTerminal8setcolorE5ColorS0_ = comdat any

$_ZN8O_StreamI8TerminalElsEPKc = comdat any

$_ZN8O_StreamI8TerminalElsEj = comdat any

$_ZN8O_StreamI8TerminalElsEPFRS1_S2_E = comdat any

$_Z4endlI8TerminalER8O_StreamIT_ES4_ = comdat any

$_ZN8O_StreamI8TerminalElsEPc = comdat any

$_ZN8O_StreamI8TerminalE7putcharEc = comdat any

$_ZN8O_StreamI8TerminalE4itoaIjEERS1_T_ = comdat any

$_ZN8O_StreamI8TerminalElsEc = comdat any

@OSEKOS_TASK_taskSend = external constant i32, align 4
@OSEKOS_TASK_taskContact = external constant i32, align 4
@debug = external global %class.Null_Stream, align 1
@.str = private unnamed_addr constant [12 x i8] c"dOSEK start\00", align 1
@trace_table_idx = external global i8, align 1
@experiment_number = external global i32, align 4
@global_all_ok = external global i8, align 1
@positive_tests = external global i32, align 4
@kout = external global %class.ColorTerminal, align 2
@.str.1 = private unnamed_addr constant [6 x i8] c"Test \00", align 1
@.str.2 = private unnamed_addr constant [3 x i8] c": \00", align 1
@.str.3 = private unnamed_addr constant [32 x i8] c"fedcba9876543210123456789abcdef\00", align 1
@llvm.used = appending global [1 x i8*] [i8* bitcast (void ()* @OSEKOS_ISR_isr_button_start to i8*)], section "llvm.metadata"

; Function Attrs: noinline optnone
define void @os_main() #0 {
  call void @_ZN11Null_Stream8setcolorI5ColorEEvT_S2_(%class.Null_Stream* @debug, i32 1, i32 7)
  %1 = call dereferenceable(1) %class.Null_Stream* @_ZN11Null_StreamlsIPKcEERS_T_(%class.Null_Stream* @debug, i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i32 0, i32 0))
  %2 = call dereferenceable(1) %class.Null_Stream* @_ZN11Null_StreamlsIS_EERS_PFR8O_StreamIT_ES5_E(%class.Null_Stream* %1, %class.O_Stream* (%class.O_Stream*)* @_Z4endlI11Null_StreamER8O_StreamIT_ES4_)
  call void @_ZN11Null_Stream8setcolorI5ColorEEvT_S2_(%class.Null_Stream* @debug, i32 3, i32 0)
  store i8 0, i8* @trace_table_idx, align 1
  store i32 0, i32* @experiment_number, align 4
  store i8 1, i8* @global_all_ok, align 1
  br i1 icmp ne (void ()* @test_prepare, void ()* null), label %3, label %4

; <label>:3:                                      ; preds = %0
  call void @test_prepare()
  br label %4

; <label>:4:                                      ; preds = %0, %3
  call void @test()
  ret void
}

; Function Attrs: noinline optnone
define void @test() #0 {
  %1 = load i32, i32* @experiment_number, align 4
  %2 = add nsw i32 %1, 1
  store i32 %2, i32* @experiment_number, align 4
  store i32 0, i32* @positive_tests, align 4
  call void @_ZN13ColorTerminal8setcolorE5ColorS0_(%class.ColorTerminal* @kout, i32 7, i32 0)
  %3 = call dereferenceable(1) %class.O_Stream.0* @_ZN8O_StreamI8TerminalElsEPKc(%class.O_Stream.0* getelementptr inbounds (%class.ColorTerminal, %class.ColorTerminal* @kout, i32 0, i32 0, i32 0), i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.1, i32 0, i32 0))
  %4 = load i32, i32* @experiment_number, align 4
  %5 = call dereferenceable(1) %class.O_Stream.0* @_ZN8O_StreamI8TerminalElsEj(%class.O_Stream.0* %3, i32 %4)
  %6 = call dereferenceable(1) %class.O_Stream.0* @_ZN8O_StreamI8TerminalElsEPKc(%class.O_Stream.0* %5, i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.2, i32 0, i32 0))
  %7 = call dereferenceable(1) %class.O_Stream.0* @_ZN8O_StreamI8TerminalElsEPFRS1_S2_E(%class.O_Stream.0* %6, %class.O_Stream.0* (%class.O_Stream.0*)* @_Z4endlI8TerminalER8O_StreamIT_ES4_)
  call void @_ZN13ColorTerminal8setcolorE5ColorS0_(%class.ColorTerminal* @kout, i32 3, i32 0)
  call void @StartOS(i32 0)
  ret void
}

declare void @StartOS(i32) #1

; Function Attrs: noinline optnone
define void @OSEKOS_TASK_FUNC_taskContact() #0 {
  %1 = alloca i32, align 4
  store volatile i32 1, i32* %1, align 4
  br label %2

; <label>:2:                                      ; preds = %5, %0
  %3 = load volatile i32, i32* %1, align 4
  %4 = icmp slt i32 %3, 200000
  br i1 %4, label %5, label %8

; <label>:5:                                      ; preds = %2
  %6 = load volatile i32, i32* %1, align 4
  %7 = add nsw i32 %6, 1
  store volatile i32 %7, i32* %1, align 4
  br label %2

; <label>:8:                                      ; preds = %2
  call void @test_trace(i8 signext 97)
  %9 = load i32, i32* @OSEKOS_TASK_taskSend, align 4
  %10 = call i32 @OSEKOS_ActivateTask(i32 %9)
  store volatile i32 0, i32* %1, align 4
  br label %11

; <label>:11:                                     ; preds = %14, %8
  %12 = load volatile i32, i32* %1, align 4
  %13 = icmp slt i32 %12, 200000
  br i1 %13, label %14, label %17

; <label>:14:                                     ; preds = %11
  %15 = load volatile i32, i32* %1, align 4
  %16 = add nsw i32 %15, 1
  store volatile i32 %16, i32* %1, align 4
  br label %11

; <label>:17:                                     ; preds = %11
  call void @test_trace(i8 signext 98)
  %18 = load i32, i32* @OSEKOS_TASK_taskContact, align 4
  %19 = call i32 @OSEKOS_ActivateTask(i32 %18)
  call void @test_trace(i8 signext 99)
  %20 = call i32 @OSEKOS_TerminateTask() #5
  unreachable
                                                  ; No predecessors!
  ret void
}

declare void @test_trace(i8 signext) #1

declare i32 @OSEKOS_ActivateTask(i32) #1

; Function Attrs: noreturn
declare i32 @OSEKOS_TerminateTask() #2

; Function Attrs: noinline optnone
define void @OSEKOS_TASK_FUNC_taskSend() #0 {
  call void @test_trace(i8 signext 50)
  %1 = call i32 @OSEKOS_TerminateTask() #5
  unreachable
                                                  ; No predecessors!
  ret void
}

; Function Attrs: noinline optnone
define void @OSEKOS_TASK_FUNC_Handler13() #0 {
  call void @test_trace(i8 signext 51)
  %1 = call i32 @OSEKOS_TerminateTask() #5
  unreachable
                                                  ; No predecessors!
  ret void
}

; Function Attrs: alwaysinline nounwind
define void @OSEKOS_ISR_isr_button_start() #3 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  br label %3

; <label>:3:                                      ; preds = %7, %0
  %4 = load i32, i32* %1, align 4
  %5 = icmp slt i32 %4, 100
  br i1 %5, label %6, label %10

; <label>:6:                                      ; preds = %3
  store i32 20, i32* %2, align 4
  br label %7

; <label>:7:                                      ; preds = %6
  %8 = load i32, i32* %1, align 4
  %9 = add nsw i32 %8, 1
  store i32 %9, i32* %1, align 4
  br label %3

; <label>:10:                                     ; preds = %3
  ret void
}

; Function Attrs: noinline nounwind optnone
define linkonce_odr void @_ZN11Null_Stream8setcolorI5ColorEEvT_S2_(%class.Null_Stream*, i32, i32) #4 comdat align 2 {
  %4 = alloca %class.Null_Stream*, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  store %class.Null_Stream* %0, %class.Null_Stream** %4, align 4
  store i32 %1, i32* %5, align 4
  store i32 %2, i32* %6, align 4
  %7 = load %class.Null_Stream*, %class.Null_Stream** %4, align 4
  ret void
}

; Function Attrs: noinline nounwind optnone
define linkonce_odr dereferenceable(1) %class.Null_Stream* @_ZN11Null_StreamlsIPKcEERS_T_(%class.Null_Stream*, i8*) #4 comdat align 2 {
  %3 = alloca %class.Null_Stream*, align 4
  %4 = alloca i8*, align 4
  store %class.Null_Stream* %0, %class.Null_Stream** %3, align 4
  store i8* %1, i8** %4, align 4
  %5 = load %class.Null_Stream*, %class.Null_Stream** %3, align 4
  ret %class.Null_Stream* %5
}

; Function Attrs: noinline nounwind optnone
define linkonce_odr dereferenceable(1) %class.Null_Stream* @_ZN11Null_StreamlsIS_EERS_PFR8O_StreamIT_ES5_E(%class.Null_Stream*, %class.O_Stream* (%class.O_Stream*)*) #4 comdat align 2 {
  %3 = alloca %class.Null_Stream*, align 4
  %4 = alloca %class.O_Stream* (%class.O_Stream*)*, align 4
  store %class.Null_Stream* %0, %class.Null_Stream** %3, align 4
  store %class.O_Stream* (%class.O_Stream*)* %1, %class.O_Stream* (%class.O_Stream*)** %4, align 4
  %5 = load %class.Null_Stream*, %class.Null_Stream** %3, align 4
  ret %class.Null_Stream* %5
}

; Function Attrs: noinline optnone
define linkonce_odr dereferenceable(1) %class.O_Stream* @_Z4endlI11Null_StreamER8O_StreamIT_ES4_(%class.O_Stream* dereferenceable(1)) #0 comdat {
  %2 = alloca %class.O_Stream*, align 4
  store %class.O_Stream* %0, %class.O_Stream** %2, align 4
  %3 = load %class.O_Stream*, %class.O_Stream** %2, align 4
  %4 = call dereferenceable(1) %class.O_Stream* @_ZN8O_StreamI11Null_StreamElsEc(%class.O_Stream* %3, i8 signext 10)
  %5 = load %class.O_Stream*, %class.O_Stream** %2, align 4
  ret %class.O_Stream* %5
}

; Function Attrs: noinline optnone
define linkonce_odr dereferenceable(1) %class.O_Stream* @_ZN8O_StreamI11Null_StreamElsEc(%class.O_Stream*, i8 signext) #0 comdat align 2 {
  %3 = alloca %class.O_Stream*, align 4
  %4 = alloca i8, align 1
  store %class.O_Stream* %0, %class.O_Stream** %3, align 4
  store i8 %1, i8* %4, align 1
  %5 = load %class.O_Stream*, %class.O_Stream** %3, align 4
  %6 = load i8, i8* %4, align 1
  call void @_ZN8O_StreamI11Null_StreamE7putcharEc(%class.O_Stream* %5, i8 signext %6)
  ret %class.O_Stream* %5
}

; Function Attrs: noinline optnone
define linkonce_odr void @_ZN8O_StreamI11Null_StreamE7putcharEc(%class.O_Stream*, i8 signext) #0 comdat align 2 {
  %3 = alloca %class.O_Stream*, align 4
  %4 = alloca i8, align 1
  store %class.O_Stream* %0, %class.O_Stream** %3, align 4
  store i8 %1, i8* %4, align 1
  %5 = load %class.O_Stream*, %class.O_Stream** %3, align 4
  %6 = bitcast %class.O_Stream* %5 to %class.Null_Stream*
  %7 = load i8, i8* %4, align 1
  call void @_ZN11Null_Stream7putcharEc(%class.Null_Stream* %6, i8 signext %7)
  ret void
}

; Function Attrs: noinline nounwind optnone
define linkonce_odr void @_ZN11Null_Stream7putcharEc(%class.Null_Stream*, i8 signext) #4 comdat align 2 {
  %3 = alloca %class.Null_Stream*, align 4
  %4 = alloca i8, align 1
  store %class.Null_Stream* %0, %class.Null_Stream** %3, align 4
  store i8 %1, i8* %4, align 1
  %5 = load %class.Null_Stream*, %class.Null_Stream** %3, align 4
  ret void
}

declare extern_weak void @test_prepare() #1

; Function Attrs: noinline optnone
define linkonce_odr void @_ZN13ColorTerminal8setcolorE5ColorS0_(%class.ColorTerminal*, i32, i32) #0 comdat align 2 {
  %4 = alloca %class.ColorTerminal*, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  store %class.ColorTerminal* %0, %class.ColorTerminal** %4, align 4
  store i32 %1, i32* %5, align 4
  store i32 %2, i32* %6, align 4
  %7 = load %class.ColorTerminal*, %class.ColorTerminal** %4, align 4
  %8 = load i32, i32* %5, align 4
  %9 = trunc i32 %8 to i8
  %10 = zext i8 %9 to i32
  %11 = add nsw i32 48, %10
  %12 = trunc i32 %11 to i8
  %13 = getelementptr inbounds %class.ColorTerminal, %class.ColorTerminal* %7, i32 0, i32 1
  %14 = getelementptr inbounds [11 x i8], [11 x i8]* %13, i32 0, i32 5
  store i8 %12, i8* %14, align 1
  %15 = load i32, i32* %6, align 4
  %16 = trunc i32 %15 to i8
  %17 = zext i8 %16 to i32
  %18 = add nsw i32 48, %17
  %19 = trunc i32 %18 to i8
  %20 = getelementptr inbounds %class.ColorTerminal, %class.ColorTerminal* %7, i32 0, i32 1
  %21 = getelementptr inbounds [11 x i8], [11 x i8]* %20, i32 0, i32 8
  store i8 %19, i8* %21, align 2
  %22 = bitcast %class.ColorTerminal* %7 to %class.O_Stream.0*
  %23 = getelementptr inbounds %class.ColorTerminal, %class.ColorTerminal* %7, i32 0, i32 1
  %24 = getelementptr inbounds [11 x i8], [11 x i8]* %23, i32 0, i32 0
  %25 = call dereferenceable(1) %class.O_Stream.0* @_ZN8O_StreamI8TerminalElsEPc(%class.O_Stream.0* %22, i8* %24)
  ret void
}

; Function Attrs: noinline optnone
define linkonce_odr dereferenceable(1) %class.O_Stream.0* @_ZN8O_StreamI8TerminalElsEPKc(%class.O_Stream.0*, i8*) #0 comdat align 2 {
  %3 = alloca %class.O_Stream.0*, align 4
  %4 = alloca i8*, align 4
  store %class.O_Stream.0* %0, %class.O_Stream.0** %3, align 4
  store i8* %1, i8** %4, align 4
  %5 = load %class.O_Stream.0*, %class.O_Stream.0** %3, align 4
  %6 = load i8*, i8** %4, align 4
  %7 = call dereferenceable(1) %class.O_Stream.0* @_ZN8O_StreamI8TerminalElsEPc(%class.O_Stream.0* %5, i8* %6)
  ret %class.O_Stream.0* %5
}

; Function Attrs: noinline optnone
define linkonce_odr dereferenceable(1) %class.O_Stream.0* @_ZN8O_StreamI8TerminalElsEj(%class.O_Stream.0*, i32) #0 comdat align 2 {
  %3 = alloca %class.O_Stream.0*, align 4
  %4 = alloca i32, align 4
  store %class.O_Stream.0* %0, %class.O_Stream.0** %3, align 4
  store i32 %1, i32* %4, align 4
  %5 = load %class.O_Stream.0*, %class.O_Stream.0** %3, align 4
  %6 = load i32, i32* %4, align 4
  %7 = call dereferenceable(1) %class.O_Stream.0* @_ZN8O_StreamI8TerminalE4itoaIjEERS1_T_(%class.O_Stream.0* %5, i32 %6)
  ret %class.O_Stream.0* %7
}

; Function Attrs: noinline optnone
define linkonce_odr dereferenceable(1) %class.O_Stream.0* @_ZN8O_StreamI8TerminalElsEPFRS1_S2_E(%class.O_Stream.0*, %class.O_Stream.0* (%class.O_Stream.0*)*) #0 comdat align 2 {
  %3 = alloca %class.O_Stream.0*, align 4
  %4 = alloca %class.O_Stream.0* (%class.O_Stream.0*)*, align 4
  store %class.O_Stream.0* %0, %class.O_Stream.0** %3, align 4
  store %class.O_Stream.0* (%class.O_Stream.0*)* %1, %class.O_Stream.0* (%class.O_Stream.0*)** %4, align 4
  %5 = load %class.O_Stream.0*, %class.O_Stream.0** %3, align 4
  %6 = load %class.O_Stream.0* (%class.O_Stream.0*)*, %class.O_Stream.0* (%class.O_Stream.0*)** %4, align 4
  %7 = call dereferenceable(1) %class.O_Stream.0* %6(%class.O_Stream.0* dereferenceable(1) %5)
  ret %class.O_Stream.0* %7
}

; Function Attrs: noinline optnone
define linkonce_odr dereferenceable(1) %class.O_Stream.0* @_Z4endlI8TerminalER8O_StreamIT_ES4_(%class.O_Stream.0* dereferenceable(1)) #0 comdat {
  %2 = alloca %class.O_Stream.0*, align 4
  store %class.O_Stream.0* %0, %class.O_Stream.0** %2, align 4
  %3 = load %class.O_Stream.0*, %class.O_Stream.0** %2, align 4
  %4 = call dereferenceable(1) %class.O_Stream.0* @_ZN8O_StreamI8TerminalElsEc(%class.O_Stream.0* %3, i8 signext 10)
  %5 = load %class.O_Stream.0*, %class.O_Stream.0** %2, align 4
  ret %class.O_Stream.0* %5
}

; Function Attrs: noinline optnone
define linkonce_odr dereferenceable(1) %class.O_Stream.0* @_ZN8O_StreamI8TerminalElsEPc(%class.O_Stream.0*, i8*) #0 comdat align 2 {
  %3 = alloca %class.O_Stream.0*, align 4
  %4 = alloca i8*, align 4
  store %class.O_Stream.0* %0, %class.O_Stream.0** %3, align 4
  store i8* %1, i8** %4, align 4
  %5 = load %class.O_Stream.0*, %class.O_Stream.0** %3, align 4
  br label %6

; <label>:6:                                      ; preds = %11, %2
  %7 = load i8*, i8** %4, align 4
  %8 = load i8, i8* %7, align 1
  %9 = sext i8 %8 to i32
  %10 = icmp ne i32 %9, 0
  br i1 %10, label %11, label %15

; <label>:11:                                     ; preds = %6
  %12 = load i8*, i8** %4, align 4
  %13 = getelementptr inbounds i8, i8* %12, i32 1
  store i8* %13, i8** %4, align 4
  %14 = load i8, i8* %12, align 1
  call void @_ZN8O_StreamI8TerminalE7putcharEc(%class.O_Stream.0* %5, i8 signext %14)
  br label %6

; <label>:15:                                     ; preds = %6
  ret %class.O_Stream.0* %5
}

; Function Attrs: noinline optnone
define linkonce_odr void @_ZN8O_StreamI8TerminalE7putcharEc(%class.O_Stream.0*, i8 signext) #0 comdat align 2 {
  %3 = alloca %class.O_Stream.0*, align 4
  %4 = alloca i8, align 1
  store %class.O_Stream.0* %0, %class.O_Stream.0** %3, align 4
  store i8 %1, i8* %4, align 1
  %5 = load %class.O_Stream.0*, %class.O_Stream.0** %3, align 4
  %6 = bitcast %class.O_Stream.0* %5 to %class.Terminal*
  %7 = load i8, i8* %4, align 1
  call void @_ZN8Terminal7putcharEc(%class.Terminal* %6, i8 signext %7)
  ret void
}

declare void @_ZN8Terminal7putcharEc(%class.Terminal*, i8 signext) #1

; Function Attrs: noinline optnone
define linkonce_odr dereferenceable(1) %class.O_Stream.0* @_ZN8O_StreamI8TerminalE4itoaIjEERS1_T_(%class.O_Stream.0*, i32) #0 comdat align 2 {
  %3 = alloca %class.O_Stream.0*, align 4
  %4 = alloca %class.O_Stream.0*, align 4
  %5 = alloca i32, align 4
  %6 = alloca [32 x i8], align 1
  %7 = alloca i8*, align 4
  %8 = alloca i32, align 4
  store %class.O_Stream.0* %0, %class.O_Stream.0** %4, align 4
  store i32 %1, i32* %5, align 4
  %9 = load %class.O_Stream.0*, %class.O_Stream.0** %4, align 4
  %10 = getelementptr inbounds [32 x i8], [32 x i8]* %6, i32 0, i32 0
  store i8* %10, i8** %7, align 4
  %11 = getelementptr inbounds %class.O_Stream.0, %class.O_Stream.0* %9, i32 0, i32 0
  %12 = load i8, i8* %11, align 1
  %13 = zext i8 %12 to i32
  %14 = icmp slt i32 %13, 2
  br i1 %14, label %20, label %15

; <label>:15:                                     ; preds = %2
  %16 = getelementptr inbounds %class.O_Stream.0, %class.O_Stream.0* %9, i32 0, i32 0
  %17 = load i8, i8* %16, align 1
  %18 = zext i8 %17 to i32
  %19 = icmp sgt i32 %18, 16
  br i1 %19, label %20, label %21

; <label>:20:                                     ; preds = %15, %2
  store %class.O_Stream.0* %9, %class.O_Stream.0** %3, align 4
  br label %60

; <label>:21:                                     ; preds = %15
  %22 = load i32, i32* %5, align 4
  %23 = icmp ult i32 %22, 0
  br i1 %23, label %24, label %25

; <label>:24:                                     ; preds = %21
  call void @_ZN8O_StreamI8TerminalE7putcharEc(%class.O_Stream.0* %9, i8 signext 45)
  br label %25

; <label>:25:                                     ; preds = %24, %21
  br label %26

; <label>:26:                                     ; preds = %45, %25
  %27 = load i32, i32* %5, align 4
  store i32 %27, i32* %8, align 4
  %28 = getelementptr inbounds %class.O_Stream.0, %class.O_Stream.0* %9, i32 0, i32 0
  %29 = load i8, i8* %28, align 1
  %30 = zext i8 %29 to i32
  %31 = load i32, i32* %5, align 4
  %32 = udiv i32 %31, %30
  store i32 %32, i32* %5, align 4
  %33 = load i32, i32* %8, align 4
  %34 = load i32, i32* %5, align 4
  %35 = getelementptr inbounds %class.O_Stream.0, %class.O_Stream.0* %9, i32 0, i32 0
  %36 = load i8, i8* %35, align 1
  %37 = zext i8 %36 to i32
  %38 = mul i32 %34, %37
  %39 = sub i32 %33, %38
  %40 = add i32 15, %39
  %41 = getelementptr inbounds [32 x i8], [32 x i8]* @.str.3, i32 0, i32 %40
  %42 = load i8, i8* %41, align 1
  %43 = load i8*, i8** %7, align 4
  %44 = getelementptr inbounds i8, i8* %43, i32 1
  store i8* %44, i8** %7, align 4
  store i8 %42, i8* %43, align 1
  br label %45

; <label>:45:                                     ; preds = %26
  %46 = load i32, i32* %5, align 4
  %47 = icmp ne i32 %46, 0
  br i1 %47, label %26, label %48

; <label>:48:                                     ; preds = %45
  %49 = load i8*, i8** %7, align 4
  %50 = getelementptr inbounds i8, i8* %49, i32 -1
  store i8* %50, i8** %7, align 4
  br label %51

; <label>:51:                                     ; preds = %55, %48
  %52 = load i8*, i8** %7, align 4
  %53 = getelementptr inbounds [32 x i8], [32 x i8]* %6, i32 0, i32 0
  %54 = icmp uge i8* %52, %53
  br i1 %54, label %55, label %59

; <label>:55:                                     ; preds = %51
  %56 = load i8*, i8** %7, align 4
  %57 = getelementptr inbounds i8, i8* %56, i32 -1
  store i8* %57, i8** %7, align 4
  %58 = load i8, i8* %56, align 1
  call void @_ZN8O_StreamI8TerminalE7putcharEc(%class.O_Stream.0* %9, i8 signext %58)
  br label %51

; <label>:59:                                     ; preds = %51
  store %class.O_Stream.0* %9, %class.O_Stream.0** %3, align 4
  br label %60

; <label>:60:                                     ; preds = %59, %20
  %61 = load %class.O_Stream.0*, %class.O_Stream.0** %3, align 4
  ret %class.O_Stream.0* %61
}

; Function Attrs: noinline optnone
define linkonce_odr dereferenceable(1) %class.O_Stream.0* @_ZN8O_StreamI8TerminalElsEc(%class.O_Stream.0*, i8 signext) #0 comdat align 2 {
  %3 = alloca %class.O_Stream.0*, align 4
  %4 = alloca i8, align 1
  store %class.O_Stream.0* %0, %class.O_Stream.0** %3, align 4
  store i8 %1, i8* %4, align 1
  %5 = load %class.O_Stream.0*, %class.O_Stream.0** %3, align 4
  %6 = load i8, i8* %4, align 1
  call void @_ZN8O_StreamI8TerminalE7putcharEc(%class.O_Stream.0* %5, i8 signext %6)
  ret %class.O_Stream.0* %5
}

attributes #0 = { noinline optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noreturn "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { alwaysinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { noreturn }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"NumRegisterParameters", i32 0}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
