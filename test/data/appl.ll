; ModuleID = '../appl/FreeRTOS/argument_load.cc'
source_filename = "../appl/FreeRTOS/argument_load.cc"
target datalayout = "e-m:e-p:32:32-f64:32:64-f80:32-n8:16:32-S128"
target triple = "i386-pc-linux-gnu"

; Function Attrs: noinline nounwind optnone
define void @_Z9test_calli(i32 %a) #0 {
  %a.addr = alloca i32, align 4
  %c = alloca i32, align 4
  store i32 %a, i32* %a.addr, align 4
  store i32 0, i32* %c, align 4
  ret void
}

; Function Attrs: noinline nounwind optnone
define i32 @_Z4testid(i32 %a, double %c) #0 {
  %retval = alloca i32, align 4
  %a.addr = alloca i32, align 4
  %c.addr = alloca double, align 8
  %b = alloca i32, align 4
  %d = alloca i32, align 4
  store i32 %a, i32* %a.addr, align 4
  store double %c, double* %c.addr, align 8
  %1 = load i32, i32* %a.addr, align 4
  store i32 %1, i32* %b, align 4
  store i32 10, i32* %d, align 4
  %2 = load i32, i32* %a.addr, align 4
  call void @_Z9test_calli(i32 %2)
  call void @llvm.trap()
  unreachable
                                                  ; No predecessors!
  %4 = load i32, i32* %retval, align 4
  ret i32 %4
}

; Function Attrs: noreturn nounwind
declare void @llvm.trap() #1

; Function Attrs: noinline norecurse nounwind optnone
define i32 @main() #2 {
  %retval = alloca i32, align 4
  %a = alloca i32, align 4
  store i32 0, i32* %retval, align 4
  store i32 198200, i32* %a, align 4
  %1 = load i32, i32* %a, align 4
  %call = call i32 @_Z4testid(i32 %1, double 2.132130e+05)
  %call1 = call i32 @_Z4testid(i32 123, double 1.000000e+00)
  ret i32 0
}

attributes #0 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { noreturn nounwind }
attributes #2 = { noinline norecurse nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"NumRegisterParameters", i32 0}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
