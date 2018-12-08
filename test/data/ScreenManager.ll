; ModuleID = '../../../GPSLogger/Src/Screens/ScreenManager.cpp'
source_filename = "../../../GPSLogger/Src/Screens/ScreenManager.cpp"
target datalayout = "e-m:e-p:32:32-f64:32:64-f80:32-n8:16:32-S128"
target triple = "i386-pc-linux-gnu"

%class.Screen = type { i32 (...)**, %class.Screen* }
%class.CurrentTimeScreen = type { %class.ParentScreen }
%class.ParentScreen = type { %class.Screen, %class.Screen* }
%class.CurrentPositionScreen = type { %class.Screen }
%class.SpeedScreen = type { %class.ParentScreen }
%class.OdometerScreen = type { %class.Screen, i8, i8, [2 x i8], %class.OdometerActionScreen }
%class.OdometerActionScreen = type { %class.SelectorScreen.base, i8, [2 x i8] }
%class.SelectorScreen.base = type <{ %class.Screen, i8 }>
%class.SatellitesScreen = type { %class.ParentScreen }
%class.SettingsGroupScreen = type { %class.Screen }
%struct.ButtonMessage = type { i32, i32 }

$_ZN21CurrentPositionScreenC2Ev = comdat any

@screenStack = global [5 x %class.Screen*] zeroinitializer, align 4
@screenIdx = global i32 0, align 4
@timeScreen = global %class.CurrentTimeScreen zeroinitializer, align 4
@positionScreen = global %class.CurrentPositionScreen zeroinitializer, align 4
@speedScreen = global %class.SpeedScreen zeroinitializer, align 4
@odometerScreen = global %class.OdometerScreen zeroinitializer, align 4
@satellitesScreen = global %class.SatellitesScreen zeroinitializer, align 4
@rootSettingsScreen = global %class.SettingsGroupScreen zeroinitializer, align 4
@_ZTV21CurrentPositionScreen = external unnamed_addr constant { [8 x i8*] }
@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* @_GLOBAL__sub_I_ScreenManager.cpp, i8* null }]

; Function Attrs: noinline
define internal void @__cxx_global_var_init() #0 section ".text.startup" {
  call void @_ZN17CurrentTimeScreenC1Ev(%class.CurrentTimeScreen* @timeScreen)
  ret void
}

declare void @_ZN17CurrentTimeScreenC1Ev(%class.CurrentTimeScreen*) unnamed_addr #1

; Function Attrs: noinline
define internal void @__cxx_global_var_init.1() #0 section ".text.startup" {
  call void @_ZN21CurrentPositionScreenC2Ev(%class.CurrentPositionScreen* @positionScreen)
  ret void
}

; Function Attrs: noinline optnone
define linkonce_odr void @_ZN21CurrentPositionScreenC2Ev(%class.CurrentPositionScreen* %this) unnamed_addr #2 comdat align 2 {
  %this.addr = alloca %class.CurrentPositionScreen*, align 4
  store %class.CurrentPositionScreen* %this, %class.CurrentPositionScreen** %this.addr, align 4
  %this1 = load %class.CurrentPositionScreen*, %class.CurrentPositionScreen** %this.addr, align 4
  %1 = bitcast %class.CurrentPositionScreen* %this1 to %class.Screen*
  call void @_ZN6ScreenC2Ev(%class.Screen* %1)
  %2 = bitcast %class.CurrentPositionScreen* %this1 to i32 (...)***
  store i32 (...)** bitcast (i8** getelementptr inbounds ({ [8 x i8*] }, { [8 x i8*] }* @_ZTV21CurrentPositionScreen, i32 0, inrange i32 0, i32 2) to i32 (...)**), i32 (...)*** %2, align 4
  ret void
}

; Function Attrs: noinline
define internal void @__cxx_global_var_init.2() #0 section ".text.startup" {
  call void @_ZN11SpeedScreenC1Ev(%class.SpeedScreen* @speedScreen)
  ret void
}

declare void @_ZN11SpeedScreenC1Ev(%class.SpeedScreen*) unnamed_addr #1

; Function Attrs: noinline
define internal void @__cxx_global_var_init.3() #0 section ".text.startup" {
  call void @_ZN14OdometerScreenC1Eh(%class.OdometerScreen* @odometerScreen, i8 zeroext 0)
  ret void
}

declare void @_ZN14OdometerScreenC1Eh(%class.OdometerScreen*, i8 zeroext) unnamed_addr #1

; Function Attrs: noinline
define internal void @__cxx_global_var_init.4() #0 section ".text.startup" {
  call void @_ZN16SatellitesScreenC1Ev(%class.SatellitesScreen* @satellitesScreen)
  ret void
}

declare void @_ZN16SatellitesScreenC1Ev(%class.SatellitesScreen*) unnamed_addr #1

; Function Attrs: noinline
define internal void @__cxx_global_var_init.5() #0 section ".text.startup" {
  call void @_ZN19SettingsGroupScreenC1Ev(%class.SettingsGroupScreen* @rootSettingsScreen)
  ret void
}

declare void @_ZN19SettingsGroupScreenC1Ev(%class.SettingsGroupScreen*) unnamed_addr #1

; Function Attrs: noinline nounwind optnone
define void @_Z16setCurrentScreenP6Screen(%class.Screen* %screen) #3 {
  %screen.addr = alloca %class.Screen*, align 4
  store %class.Screen* %screen, %class.Screen** %screen.addr, align 4
  %1 = load %class.Screen*, %class.Screen** %screen.addr, align 4
  %2 = load i32, i32* @screenIdx, align 4
  %arrayidx = getelementptr inbounds [5 x %class.Screen*], [5 x %class.Screen*]* @screenStack, i32 0, i32 %2
  store %class.Screen* %1, %class.Screen** %arrayidx, align 4
  ret void
}

; Function Attrs: noinline nounwind optnone
define %class.Screen* @_Z16getCurrentScreenv() #3 {
  %1 = load i32, i32* @screenIdx, align 4
  %arrayidx = getelementptr inbounds [5 x %class.Screen*], [5 x %class.Screen*]* @screenStack, i32 0, i32 %1
  %2 = load %class.Screen*, %class.Screen** %arrayidx, align 4
  ret %class.Screen* %2
}

; Function Attrs: noinline nounwind optnone
define void @_Z16enterChildScreenP6Screen(%class.Screen* %screen) #3 {
  %screen.addr = alloca %class.Screen*, align 4
  store %class.Screen* %screen, %class.Screen** %screen.addr, align 4
  %1 = load i32, i32* @screenIdx, align 4
  %inc = add nsw i32 %1, 1
  store i32 %inc, i32* @screenIdx, align 4
  %2 = load %class.Screen*, %class.Screen** %screen.addr, align 4
  %3 = load i32, i32* @screenIdx, align 4
  %arrayidx = getelementptr inbounds [5 x %class.Screen*], [5 x %class.Screen*]* @screenStack, i32 0, i32 %3
  store %class.Screen* %2, %class.Screen** %arrayidx, align 4
  ret void
}

; Function Attrs: noinline nounwind optnone
define void @_Z18backToParentScreenv() #3 {
  %1 = load i32, i32* @screenIdx, align 4
  %tobool = icmp ne i32 %1, 0
  br i1 %tobool, label %2, label %4

; <label>:2:                                      ; preds = %0
  %3 = load i32, i32* @screenIdx, align 4
  %dec = add nsw i32 %3, -1
  store i32 %dec, i32* @screenIdx, align 4
  br label %4

; <label>:4:                                      ; preds = %2, %0
  ret void
}

; Function Attrs: noinline nounwind optnone
define void @_Z11initDisplayv() #3 {
  ret void
}

; Function Attrs: noinline optnone
define void @_Z11initScreensv() #2 {
  call void @_Z16setCurrentScreenP6Screen(%class.Screen* getelementptr inbounds (%class.CurrentTimeScreen, %class.CurrentTimeScreen* @timeScreen, i32 0, i32 0, i32 0))
  %call = call %class.Screen* @_ZN6Screen9addScreenEPS_(%class.Screen* getelementptr inbounds (%class.CurrentTimeScreen, %class.CurrentTimeScreen* @timeScreen, i32 0, i32 0, i32 0), %class.Screen* getelementptr inbounds (%class.CurrentPositionScreen, %class.CurrentPositionScreen* @positionScreen, i32 0, i32 0))
  %call1 = call %class.Screen* @_ZN6Screen9addScreenEPS_(%class.Screen* getelementptr inbounds (%class.CurrentPositionScreen, %class.CurrentPositionScreen* @positionScreen, i32 0, i32 0), %class.Screen* getelementptr inbounds (%class.SpeedScreen, %class.SpeedScreen* @speedScreen, i32 0, i32 0, i32 0))
  %call2 = call %class.Screen* @_ZN6Screen9addScreenEPS_(%class.Screen* getelementptr inbounds (%class.SpeedScreen, %class.SpeedScreen* @speedScreen, i32 0, i32 0, i32 0), %class.Screen* getelementptr inbounds (%class.OdometerScreen, %class.OdometerScreen* @odometerScreen, i32 0, i32 0))
  %call3 = call %class.Screen* @_ZN6Screen9addScreenEPS_(%class.Screen* getelementptr inbounds (%class.OdometerScreen, %class.OdometerScreen* @odometerScreen, i32 0, i32 0), %class.Screen* getelementptr inbounds (%class.SatellitesScreen, %class.SatellitesScreen* @satellitesScreen, i32 0, i32 0, i32 0))
  %call4 = call %class.Screen* @_ZN6Screen9addScreenEPS_(%class.Screen* getelementptr inbounds (%class.SatellitesScreen, %class.SatellitesScreen* @satellitesScreen, i32 0, i32 0, i32 0), %class.Screen* getelementptr inbounds (%class.SettingsGroupScreen, %class.SettingsGroupScreen* @rootSettingsScreen, i32 0, i32 0))
  ret void
}

declare %class.Screen* @_ZN6Screen9addScreenEPS_(%class.Screen*, %class.Screen*) #1

; Function Attrs: noinline optnone
define void @_Z11drawDisplayv() #2 {
  %currentScreen = alloca %class.Screen*, align 4
  %call = call %class.Screen* @_Z16getCurrentScreenv()
  store %class.Screen* %call, %class.Screen** %currentScreen, align 4
  %1 = load %class.Screen*, %class.Screen** %currentScreen, align 4
  %2 = bitcast %class.Screen* %1 to void (%class.Screen*)***
  %vtable = load void (%class.Screen*)**, void (%class.Screen*)*** %2, align 4
  %vfn = getelementptr inbounds void (%class.Screen*)*, void (%class.Screen*)** %vtable, i64 1
  %3 = load void (%class.Screen*)*, void (%class.Screen*)** %vfn, align 4
  call void %3(%class.Screen* %1)
  %4 = load %class.Screen*, %class.Screen** %currentScreen, align 4
  %5 = bitcast %class.Screen* %4 to void (%class.Screen*)***
  %vtable1 = load void (%class.Screen*)**, void (%class.Screen*)*** %5, align 4
  %vfn2 = getelementptr inbounds void (%class.Screen*)*, void (%class.Screen*)** %vtable1, i64 0
  %6 = load void (%class.Screen*)*, void (%class.Screen*)** %vfn2, align 4
  call void %6(%class.Screen* %4)
  ret void
}

; Function Attrs: noinline optnone
define void @_Z14showMessageBoxPKc(i8* %text) #2 {
  %text.addr = alloca i8*, align 4
  %x = alloca i8, align 1
  store i8* %text, i8** %text.addr, align 4
  %1 = load i8*, i8** %text.addr, align 4
  %call = call i32 @_Z8strlen_PPKc(i8* %1)
  %mul = mul nsw i32 %call, 8
  %div = sdiv i32 %mul, 2
  %sub = sub nsw i32 64, %div
  %add = add nsw i32 %sub, 1
  %conv = trunc i32 %add to i8
  store i8 %conv, i8* %x, align 1
  call void @vTaskDelay(i32 1000)
  ret void
}

declare i32 @_Z8strlen_PPKc(i8*) #1

declare void @vTaskDelay(i32) #1

; Function Attrs: noinline optnone
define void @_Z13processButtonRK13ButtonMessage(%struct.ButtonMessage* dereferenceable(8) %msg) #2 {
  %msg.addr = alloca %struct.ButtonMessage*, align 4
  store %struct.ButtonMessage* %msg, %struct.ButtonMessage** %msg.addr, align 4
  %1 = load %struct.ButtonMessage*, %struct.ButtonMessage** %msg.addr, align 4
  %button = getelementptr inbounds %struct.ButtonMessage, %struct.ButtonMessage* %1, i32 0, i32 0
  %2 = load i32, i32* %button, align 4
  %cmp = icmp eq i32 %2, 1
  br i1 %cmp, label %3, label %9

; <label>:3:                                      ; preds = %0
  %4 = load %struct.ButtonMessage*, %struct.ButtonMessage** %msg.addr, align 4
  %event = getelementptr inbounds %struct.ButtonMessage, %struct.ButtonMessage* %4, i32 0, i32 1
  %5 = load i32, i32* %event, align 4
  %cmp1 = icmp eq i32 %5, 0
  br i1 %cmp1, label %6, label %9

; <label>:6:                                      ; preds = %3
  %call = call %class.Screen* @_Z16getCurrentScreenv()
  %7 = bitcast %class.Screen* %call to void (%class.Screen*)***
  %vtable = load void (%class.Screen*)**, void (%class.Screen*)*** %7, align 4
  %vfn = getelementptr inbounds void (%class.Screen*)*, void (%class.Screen*)** %vtable, i64 2
  %8 = load void (%class.Screen*)*, void (%class.Screen*)** %vfn, align 4
  call void %8(%class.Screen* %call)
  br label %9

; <label>:9:                                      ; preds = %6, %3, %0
  %10 = load %struct.ButtonMessage*, %struct.ButtonMessage** %msg.addr, align 4
  %button2 = getelementptr inbounds %struct.ButtonMessage, %struct.ButtonMessage* %10, i32 0, i32 0
  %11 = load i32, i32* %button2, align 4
  %cmp3 = icmp eq i32 %11, 2
  br i1 %cmp3, label %12, label %18

; <label>:12:                                     ; preds = %9
  %13 = load %struct.ButtonMessage*, %struct.ButtonMessage** %msg.addr, align 4
  %event4 = getelementptr inbounds %struct.ButtonMessage, %struct.ButtonMessage* %13, i32 0, i32 1
  %14 = load i32, i32* %event4, align 4
  %cmp5 = icmp eq i32 %14, 0
  br i1 %cmp5, label %15, label %18

; <label>:15:                                     ; preds = %12
  %call6 = call %class.Screen* @_Z16getCurrentScreenv()
  %16 = bitcast %class.Screen* %call6 to void (%class.Screen*)***
  %vtable7 = load void (%class.Screen*)**, void (%class.Screen*)*** %16, align 4
  %vfn8 = getelementptr inbounds void (%class.Screen*)*, void (%class.Screen*)** %vtable7, i64 3
  %17 = load void (%class.Screen*)*, void (%class.Screen*)** %vfn8, align 4
  call void %17(%class.Screen* %call6)
  br label %18

; <label>:18:                                     ; preds = %15, %12, %9
  ret void
}

; Function Attrs: noinline optnone
define void @_Z12vDisplayTaskPv(i8* %pvParameters) #2 {
  %pvParameters.addr = alloca i8*, align 4
  %lastActionTicks = alloca i32, align 4
  %msg = alloca %struct.ButtonMessage, align 4
  store i8* %pvParameters, i8** %pvParameters.addr, align 4
  call void @_Z11initDisplayv()
  call void @_Z11initScreensv()
  %call = call i32 @xTaskGetTickCount()
  store i32 %call, i32* %lastActionTicks, align 4
  br label %1

; <label>:1:                                      ; preds = %6, %0
  %call1 = call zeroext i1 @_Z20waitForButtonMessageP13ButtonMessagej(%struct.ButtonMessage* %msg, i32 100)
  br i1 %call1, label %2, label %3

; <label>:2:                                      ; preds = %1
  call void @_Z13processButtonRK13ButtonMessage(%struct.ButtonMessage* dereferenceable(8) %msg)
  %call2 = call i32 @xTaskGetTickCount()
  store i32 %call2, i32* %lastActionTicks, align 4
  br label %3

; <label>:3:                                      ; preds = %2, %1
  %call3 = call i32 @xTaskGetTickCount()
  %4 = load i32, i32* %lastActionTicks, align 4
  %sub = sub i32 %call3, %4
  %cmp = icmp ugt i32 %sub, 10000
  br i1 %cmp, label %5, label %6

; <label>:5:                                      ; preds = %3
  %call4 = call zeroext i1 @_Z20waitForButtonMessageP13ButtonMessagej(%struct.ButtonMessage* %msg, i32 -1)
  %call5 = call i32 @xTaskGetTickCount()
  store i32 %call5, i32* %lastActionTicks, align 4
  br label %6

; <label>:6:                                      ; preds = %5, %3
  call void @_Z11drawDisplayv()
  br label %1
                                                  ; No predecessors!
  ret void
}

declare i32 @xTaskGetTickCount() #1

declare zeroext i1 @_Z20waitForButtonMessageP13ButtonMessagej(%struct.ButtonMessage*, i32) #1

declare void @_ZN6ScreenC2Ev(%class.Screen*) unnamed_addr #1

; Function Attrs: noinline
define internal void @_GLOBAL__sub_I_ScreenManager.cpp() #0 section ".text.startup" {
  call void @__cxx_global_var_init()
  call void @__cxx_global_var_init.1()
  call void @__cxx_global_var_init.2()
  call void @__cxx_global_var_init.3()
  call void @__cxx_global_var_init.4()
  call void @__cxx_global_var_init.5()
  ret void
}

attributes #0 = { noinline "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noinline optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"NumRegisterParameters", i32 0}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
