; ModuleID = 'Screens/ScreenManager.cpp'
source_filename = "Screens/ScreenManager.cpp"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%class.Screen = type { i32 (...)**, %class.Screen* }
%class.CurrentTimeScreen = type { %class.ParentScreen }
%class.ParentScreen = type { %class.Screen, %class.Screen* }
%class.CurrentPositionScreen = type { %class.Screen }
%class.SpeedScreen = type { %class.ParentScreen }
%class.OdometerScreen = type { %class.Screen, i8, i8, [6 x i8], %class.OdometerActionScreen }
%class.OdometerActionScreen = type { %class.SelectorScreen.base, i8, [6 x i8] }
%class.SelectorScreen.base = type <{ %class.Screen, i8 }>
%class.SatellitesScreen = type { %class.ParentScreen }
%class.SettingsGroupScreen = type { %class.Screen }
%struct.ButtonMessage = type { i32, i32 }

$_ZN21CurrentPositionScreenC2Ev = comdat any

@screenStack = global [5 x %class.Screen*] zeroinitializer, align 16
@screenIdx = global i32 0, align 4
@timeScreen = global %class.CurrentTimeScreen zeroinitializer, align 8
@positionScreen = global %class.CurrentPositionScreen zeroinitializer, align 8
@speedScreen = global %class.SpeedScreen zeroinitializer, align 8
@odometerScreen = global %class.OdometerScreen zeroinitializer, align 8
@satellitesScreen = global %class.SatellitesScreen zeroinitializer, align 8
@rootSettingsScreen = global %class.SettingsGroupScreen zeroinitializer, align 8
@_ZTV21CurrentPositionScreen = external unnamed_addr constant { [8 x i8*] }
@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* @_GLOBAL__sub_I_ScreenManager.cpp, i8* null }]

; Function Attrs: noinline uwtable
define internal void @__cxx_global_var_init() #0 section ".text.startup" {
  call void @_ZN17CurrentTimeScreenC1Ev(%class.CurrentTimeScreen* @timeScreen)
  ret void
}

declare void @_ZN17CurrentTimeScreenC1Ev(%class.CurrentTimeScreen*) unnamed_addr #1

; Function Attrs: noinline uwtable
define internal void @__cxx_global_var_init.1() #0 section ".text.startup" {
  call void @_ZN21CurrentPositionScreenC2Ev(%class.CurrentPositionScreen* @positionScreen)
  ret void
}

; Function Attrs: noinline optnone uwtable
define linkonce_odr void @_ZN21CurrentPositionScreenC2Ev(%class.CurrentPositionScreen*) unnamed_addr #2 comdat align 2 {
  %2 = alloca %class.CurrentPositionScreen*, align 8
  store %class.CurrentPositionScreen* %0, %class.CurrentPositionScreen** %2, align 8
  %3 = load %class.CurrentPositionScreen*, %class.CurrentPositionScreen** %2, align 8
  %4 = bitcast %class.CurrentPositionScreen* %3 to %class.Screen*
  call void @_ZN6ScreenC2Ev(%class.Screen* %4)
  %5 = bitcast %class.CurrentPositionScreen* %3 to i32 (...)***
  store i32 (...)** bitcast (i8** getelementptr inbounds ({ [8 x i8*] }, { [8 x i8*] }* @_ZTV21CurrentPositionScreen, i32 0, inrange i32 0, i32 2) to i32 (...)**), i32 (...)*** %5, align 8
  ret void
}

; Function Attrs: noinline uwtable
define internal void @__cxx_global_var_init.2() #0 section ".text.startup" {
  call void @_ZN11SpeedScreenC1Ev(%class.SpeedScreen* @speedScreen)
  ret void
}

declare void @_ZN11SpeedScreenC1Ev(%class.SpeedScreen*) unnamed_addr #1

; Function Attrs: noinline uwtable
define internal void @__cxx_global_var_init.3() #0 section ".text.startup" {
  call void @_ZN14OdometerScreenC1Eh(%class.OdometerScreen* @odometerScreen, i8 zeroext 0)
  ret void
}

declare void @_ZN14OdometerScreenC1Eh(%class.OdometerScreen*, i8 zeroext) unnamed_addr #1

; Function Attrs: noinline uwtable
define internal void @__cxx_global_var_init.4() #0 section ".text.startup" {
  call void @_ZN16SatellitesScreenC1Ev(%class.SatellitesScreen* @satellitesScreen)
  ret void
}

declare void @_ZN16SatellitesScreenC1Ev(%class.SatellitesScreen*) unnamed_addr #1

; Function Attrs: noinline uwtable
define internal void @__cxx_global_var_init.5() #0 section ".text.startup" {
  call void @_ZN19SettingsGroupScreenC1Ev(%class.SettingsGroupScreen* @rootSettingsScreen)
  ret void
}

declare void @_ZN19SettingsGroupScreenC1Ev(%class.SettingsGroupScreen*) unnamed_addr #1

; Function Attrs: noinline nounwind optnone uwtable
define void @_Z16setCurrentScreenP6Screen(%class.Screen*) #3 {
  %2 = alloca %class.Screen*, align 8
  store %class.Screen* %0, %class.Screen** %2, align 8
  %3 = load %class.Screen*, %class.Screen** %2, align 8
  %4 = load i32, i32* @screenIdx, align 4
  %5 = sext i32 %4 to i64
  %6 = getelementptr inbounds [5 x %class.Screen*], [5 x %class.Screen*]* @screenStack, i64 0, i64 %5
  store %class.Screen* %3, %class.Screen** %6, align 8
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define %class.Screen* @_Z16getCurrentScreenv() #3 {
  %1 = load i32, i32* @screenIdx, align 4
  %2 = sext i32 %1 to i64
  %3 = getelementptr inbounds [5 x %class.Screen*], [5 x %class.Screen*]* @screenStack, i64 0, i64 %2
  %4 = load %class.Screen*, %class.Screen** %3, align 8
  ret %class.Screen* %4
}

; Function Attrs: noinline nounwind optnone uwtable
define void @_Z16enterChildScreenP6Screen(%class.Screen*) #3 {
  %2 = alloca %class.Screen*, align 8
  store %class.Screen* %0, %class.Screen** %2, align 8
  %3 = load i32, i32* @screenIdx, align 4
  %4 = add nsw i32 %3, 1
  store i32 %4, i32* @screenIdx, align 4
  %5 = load %class.Screen*, %class.Screen** %2, align 8
  %6 = load i32, i32* @screenIdx, align 4
  %7 = sext i32 %6 to i64
  %8 = getelementptr inbounds [5 x %class.Screen*], [5 x %class.Screen*]* @screenStack, i64 0, i64 %7
  store %class.Screen* %5, %class.Screen** %8, align 8
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define void @_Z18backToParentScreenv() #3 {
  %1 = load i32, i32* @screenIdx, align 4
  %2 = icmp ne i32 %1, 0
  br i1 %2, label %3, label %6

; <label>:3:                                      ; preds = %0
  %4 = load i32, i32* @screenIdx, align 4
  %5 = add nsw i32 %4, -1
  store i32 %5, i32* @screenIdx, align 4
  br label %6

; <label>:6:                                      ; preds = %3, %0
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define void @_Z11initDisplayv() #3 {
  ret void
}

; Function Attrs: noinline optnone uwtable
define void @_Z11initScreensv() #2 {
  call void @_Z16setCurrentScreenP6Screen(%class.Screen* getelementptr inbounds (%class.CurrentTimeScreen, %class.CurrentTimeScreen* @timeScreen, i32 0, i32 0, i32 0))
  %1 = call %class.Screen* @_ZN6Screen9addScreenEPS_(%class.Screen* getelementptr inbounds (%class.CurrentTimeScreen, %class.CurrentTimeScreen* @timeScreen, i32 0, i32 0, i32 0), %class.Screen* getelementptr inbounds (%class.CurrentPositionScreen, %class.CurrentPositionScreen* @positionScreen, i32 0, i32 0))
  %2 = call %class.Screen* @_ZN6Screen9addScreenEPS_(%class.Screen* getelementptr inbounds (%class.CurrentPositionScreen, %class.CurrentPositionScreen* @positionScreen, i32 0, i32 0), %class.Screen* getelementptr inbounds (%class.SpeedScreen, %class.SpeedScreen* @speedScreen, i32 0, i32 0, i32 0))
  %3 = call %class.Screen* @_ZN6Screen9addScreenEPS_(%class.Screen* getelementptr inbounds (%class.SpeedScreen, %class.SpeedScreen* @speedScreen, i32 0, i32 0, i32 0), %class.Screen* getelementptr inbounds (%class.OdometerScreen, %class.OdometerScreen* @odometerScreen, i32 0, i32 0))
  %4 = call %class.Screen* @_ZN6Screen9addScreenEPS_(%class.Screen* getelementptr inbounds (%class.OdometerScreen, %class.OdometerScreen* @odometerScreen, i32 0, i32 0), %class.Screen* getelementptr inbounds (%class.SatellitesScreen, %class.SatellitesScreen* @satellitesScreen, i32 0, i32 0, i32 0))
  %5 = call %class.Screen* @_ZN6Screen9addScreenEPS_(%class.Screen* getelementptr inbounds (%class.SatellitesScreen, %class.SatellitesScreen* @satellitesScreen, i32 0, i32 0, i32 0), %class.Screen* getelementptr inbounds (%class.SettingsGroupScreen, %class.SettingsGroupScreen* @rootSettingsScreen, i32 0, i32 0))
  ret void
}

declare %class.Screen* @_ZN6Screen9addScreenEPS_(%class.Screen*, %class.Screen*) #1

; Function Attrs: noinline optnone uwtable
define void @_Z11drawDisplayv() #2 {
  %1 = alloca %class.Screen*, align 8
  %2 = call %class.Screen* @_Z16getCurrentScreenv()
  store %class.Screen* %2, %class.Screen** %1, align 8
  %3 = load %class.Screen*, %class.Screen** %1, align 8
  %4 = bitcast %class.Screen* %3 to void (%class.Screen*)***
  %5 = load void (%class.Screen*)**, void (%class.Screen*)*** %4, align 8
  %6 = getelementptr inbounds void (%class.Screen*)*, void (%class.Screen*)** %5, i64 1
  %7 = load void (%class.Screen*)*, void (%class.Screen*)** %6, align 8
  call void %7(%class.Screen* %3)
  %8 = load %class.Screen*, %class.Screen** %1, align 8
  %9 = bitcast %class.Screen* %8 to void (%class.Screen*)***
  %10 = load void (%class.Screen*)**, void (%class.Screen*)*** %9, align 8
  %11 = getelementptr inbounds void (%class.Screen*)*, void (%class.Screen*)** %10, i64 0
  %12 = load void (%class.Screen*)*, void (%class.Screen*)** %11, align 8
  call void %12(%class.Screen* %8)
  ret void
}

; Function Attrs: noinline optnone uwtable
define void @_Z14showMessageBoxPKc(i8*) #2 {
  %2 = alloca i8*, align 8
  %3 = alloca i8, align 1
  store i8* %0, i8** %2, align 8
  %4 = load i8*, i8** %2, align 8
  %5 = call i32 @_Z8strlen_PPKc(i8* %4)
  %6 = mul nsw i32 %5, 8
  %7 = sdiv i32 %6, 2
  %8 = sub nsw i32 64, %7
  %9 = add nsw i32 %8, 1
  %10 = trunc i32 %9 to i8
  store i8 %10, i8* %3, align 1
  call void @vTaskDelay(i32 1000)
  ret void
}

declare i32 @_Z8strlen_PPKc(i8*) #1

declare void @vTaskDelay(i32) #1

; Function Attrs: noinline optnone uwtable
define void @_Z13processButtonRK13ButtonMessage(%struct.ButtonMessage* dereferenceable(8)) #2 {
  %2 = alloca %struct.ButtonMessage*, align 8
  store %struct.ButtonMessage* %0, %struct.ButtonMessage** %2, align 8
  %3 = load %struct.ButtonMessage*, %struct.ButtonMessage** %2, align 8
  %4 = getelementptr inbounds %struct.ButtonMessage, %struct.ButtonMessage* %3, i32 0, i32 0
  %5 = load i32, i32* %4, align 4
  %6 = icmp eq i32 %5, 1
  br i1 %6, label %7, label %18

; <label>:7:                                      ; preds = %1
  %8 = load %struct.ButtonMessage*, %struct.ButtonMessage** %2, align 8
  %9 = getelementptr inbounds %struct.ButtonMessage, %struct.ButtonMessage* %8, i32 0, i32 1
  %10 = load i32, i32* %9, align 4
  %11 = icmp eq i32 %10, 0
  br i1 %11, label %12, label %18

; <label>:12:                                     ; preds = %7
  %13 = call %class.Screen* @_Z16getCurrentScreenv()
  %14 = bitcast %class.Screen* %13 to void (%class.Screen*)***
  %15 = load void (%class.Screen*)**, void (%class.Screen*)*** %14, align 8
  %16 = getelementptr inbounds void (%class.Screen*)*, void (%class.Screen*)** %15, i64 2
  %17 = load void (%class.Screen*)*, void (%class.Screen*)** %16, align 8
  call void %17(%class.Screen* %13)
  br label %18

; <label>:18:                                     ; preds = %12, %7, %1
  %19 = load %struct.ButtonMessage*, %struct.ButtonMessage** %2, align 8
  %20 = getelementptr inbounds %struct.ButtonMessage, %struct.ButtonMessage* %19, i32 0, i32 0
  %21 = load i32, i32* %20, align 4
  %22 = icmp eq i32 %21, 2
  br i1 %22, label %23, label %34

; <label>:23:                                     ; preds = %18
  %24 = load %struct.ButtonMessage*, %struct.ButtonMessage** %2, align 8
  %25 = getelementptr inbounds %struct.ButtonMessage, %struct.ButtonMessage* %24, i32 0, i32 1
  %26 = load i32, i32* %25, align 4
  %27 = icmp eq i32 %26, 0
  br i1 %27, label %28, label %34

; <label>:28:                                     ; preds = %23
  %29 = call %class.Screen* @_Z16getCurrentScreenv()
  %30 = bitcast %class.Screen* %29 to void (%class.Screen*)***
  %31 = load void (%class.Screen*)**, void (%class.Screen*)*** %30, align 8
  %32 = getelementptr inbounds void (%class.Screen*)*, void (%class.Screen*)** %31, i64 3
  %33 = load void (%class.Screen*)*, void (%class.Screen*)** %32, align 8
  call void %33(%class.Screen* %29)
  br label %34

; <label>:34:                                     ; preds = %28, %23, %18
  ret void
}

; Function Attrs: noinline optnone uwtable
define void @_Z12vDisplayTaskPv(i8*) #2 {
  %2 = alloca i8*, align 8
  %3 = alloca i32, align 4
  %4 = alloca %struct.ButtonMessage, align 4
  store i8* %0, i8** %2, align 8
  call void @_Z11initDisplayv()
  call void @_Z11initScreensv()
  %5 = call i32 @xTaskGetTickCount()
  store i32 %5, i32* %3, align 4
  br label %6

; <label>:6:                                      ; preds = %18, %1
  %7 = call zeroext i1 @_Z20waitForButtonMessageP13ButtonMessagej(%struct.ButtonMessage* %4, i32 100)
  br i1 %7, label %8, label %10

; <label>:8:                                      ; preds = %6
  call void @_Z13processButtonRK13ButtonMessage(%struct.ButtonMessage* dereferenceable(8) %4)
  %9 = call i32 @xTaskGetTickCount()
  store i32 %9, i32* %3, align 4
  br label %10

; <label>:10:                                     ; preds = %8, %6
  %11 = call i32 @xTaskGetTickCount()
  %12 = load i32, i32* %3, align 4
  %13 = sub i32 %11, %12
  %14 = icmp ugt i32 %13, 10000
  br i1 %14, label %15, label %18

; <label>:15:                                     ; preds = %10
  %16 = call zeroext i1 @_Z20waitForButtonMessageP13ButtonMessagej(%struct.ButtonMessage* %4, i32 -1)
  %17 = call i32 @xTaskGetTickCount()
  store i32 %17, i32* %3, align 4
  br label %18

; <label>:18:                                     ; preds = %15, %10
  call void @_Z11drawDisplayv()
  br label %6
                                                  ; No predecessors!
  ret void
}

declare i32 @xTaskGetTickCount() #1

declare zeroext i1 @_Z20waitForButtonMessageP13ButtonMessagej(%struct.ButtonMessage*, i32) #1

declare void @_ZN6ScreenC2Ev(%class.Screen*) unnamed_addr #1

; Function Attrs: noinline uwtable
define internal void @_GLOBAL__sub_I_ScreenManager.cpp() #0 section ".text.startup" {
  call void @__cxx_global_var_init()
  call void @__cxx_global_var_init.1()
  call void @__cxx_global_var_init.2()
  call void @__cxx_global_var_init.3()
  call void @__cxx_global_var_init.4()
  call void @__cxx_global_var_init.5()
  ret void
}

attributes #0 = { noinline uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noinline optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
