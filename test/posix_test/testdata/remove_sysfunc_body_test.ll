
; Let every function call me
define dso_local i8 @sleep() #0 {
	ret i8 1
}

define dso_local i32 @_printf() #0 {
	call i8* @___pause()
	ret i32 0
}

define dso_local i32 @pthread_join() #0 {
	call i8 @sleep()
	ret i32 0
}

define dso_local i8 @pause() #0 {
	call i8 @sleep()
	ret i8 1
}

define dso_local i8* @___pause() #0 {
	call i8 @sleep()
	ret i8* null
}

define dso_local i8* @no_syscall_() #0 {
	call i8 @sleep()
	ret i8* null
}

define dso_local i32 @__pthread_create() #0 {
	call i8* @no_syscall_()
	ret i32 2
}

define dso_local i32 @_open64() #0 {
	call i8 @sleep()
	ret i32 5
}

define dso_local i8 @pthread_cond_timedwait() #0 {
	call i8 @sleep()
	ret i8 48
}

define dso_local i32 @main() #0 {
	call i32 @_printf()
	call i32 @pthread_join()
	call i8 @pause()
	call i8* @___pause()
	call i32 @__pthread_create()
	call i32 @_open64()
	call i8 @pthread_cond_timedwait()
	%8 = add i32 2, 1
	ret i32 %8
}

attributes #0 = { noinline nounwind optnone sspstrong uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-builtins" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }