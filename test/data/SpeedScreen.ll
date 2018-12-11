; ModuleID = '../../../GPSLogger/Src/Screens/SpeedScreen.cpp'
source_filename = "../../../GPSLogger/Src/Screens/SpeedScreen.cpp"
target datalayout = "e-m:e-p:32:32-f64:32:64-f80:32-n8:16:32-S128"
target triple = "i386-pc-linux-gnu"

%class.AltitudeScreen = type { %class.Screen }
%class.Screen = type { i32 (...)**, %class.Screen* }
%class.SpeedScreen = type { %class.ParentScreen }
%class.ParentScreen = type { %class.Screen, %class.Screen* }
%class.gps_fix = type { i8 }
%class.GPSDataModel = type { %class.gps_fix, %class.gps_fix, %class.GPSSatellitesData, [3 x %class.GPSOdometer*], [3 x i8], %struct.QueueDefinition* }
%class.GPSSatellitesData = type { [20 x %"struct.GPSSatellitesData::SatteliteData"], i8 }
%"struct.GPSSatellitesData::SatteliteData" = type { i8, i8 }
%class.GPSOdometer = type opaque
%struct.QueueDefinition = type opaque

@altitudeScreen = global %class.AltitudeScreen zeroinitializer, align 4
@_ZTV11SpeedScreen = unnamed_addr constant { [8 x i8*] } { [8 x i8*] [i8* null, i8* bitcast ({ i8*, i8*, i8* }* @_ZTI11SpeedScreen to i8*), i8* bitcast (void (%class.SpeedScreen*)* @_ZNK11SpeedScreen10drawScreenEv to i8*), i8* bitcast (void (%class.Screen*)* @_ZNK6Screen10drawHeaderEv to i8*), i8* bitcast (void (%class.Screen*)* @_ZN6Screen11onSelButtonEv to i8*), i8* bitcast (void (%class.ParentScreen*)* @_ZN12ParentScreen10onOkButtonEv to i8*), i8* bitcast (i8* (%class.Screen*)* @_ZNK6Screen16getSelButtonTextEv to i8*), i8* bitcast (i8* (%class.SpeedScreen*)* @_ZNK11SpeedScreen15getOkButtonTextEv to i8*)] }, align 4
@.str = private unnamed_addr constant [2 x i8] c"N\00", align 1
@.str.1 = private unnamed_addr constant [3 x i8] c"NE\00", align 1
@.str.2 = private unnamed_addr constant [2 x i8] c"E\00", align 1
@.str.3 = private unnamed_addr constant [3 x i8] c"SE\00", align 1
@.str.4 = private unnamed_addr constant [2 x i8] c"S\00", align 1
@.str.5 = private unnamed_addr constant [3 x i8] c"SW\00", align 1
@.str.6 = private unnamed_addr constant [2 x i8] c"W\00", align 1
@.str.7 = private unnamed_addr constant [3 x i8] c"NW\00", align 1
@_ZZNK11SpeedScreen15getOkButtonTextEvE4text = internal constant [9 x i8] c"ALTITUDE\00", align 1
@_ZTVN10__cxxabiv120__si_class_type_infoE = external global i8*
@_ZTS11SpeedScreen = constant [14 x i8] c"11SpeedScreen\00"
@_ZTI12ParentScreen = external constant i8*
@_ZTI11SpeedScreen = constant { i8*, i8*, i8* } { i8* bitcast (i8** getelementptr inbounds (i8*, i8** @_ZTVN10__cxxabiv120__si_class_type_infoE, i32 2) to i8*), i8* getelementptr inbounds ([14 x i8], [14 x i8]* @_ZTS11SpeedScreen, i32 0, i32 0), i8* bitcast (i8** @_ZTI12ParentScreen to i8*) }
@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* @_GLOBAL__sub_I_SpeedScreen.cpp, i8* null }]

@_ZN11SpeedScreenC1Ev = alias void (%class.SpeedScreen*), void (%class.SpeedScreen*)* @_ZN11SpeedScreenC2Ev

; Function Attrs: noinline
define internal void @__cxx_global_var_init() #0 section ".text.startup" {
  call void @_ZN14AltitudeScreenC1Ev(%class.AltitudeScreen* @altitudeScreen)
  ret void
}

declare void @_ZN14AltitudeScreenC1Ev(%class.AltitudeScreen*) unnamed_addr #1

; Function Attrs: noinline optnone
define void @_ZN11SpeedScreenC2Ev(%class.SpeedScreen* %this) unnamed_addr #2 align 2 {
  %this.addr = alloca %class.SpeedScreen*, align 4
  store %class.SpeedScreen* %this, %class.SpeedScreen** %this.addr, align 4
  %this1 = load %class.SpeedScreen*, %class.SpeedScreen** %this.addr, align 4
  %1 = bitcast %class.SpeedScreen* %this1 to %class.ParentScreen*
  call void @_ZN12ParentScreenC2Ev(%class.ParentScreen* %1)
  %2 = bitcast %class.SpeedScreen* %this1 to i32 (...)***
  store i32 (...)** bitcast (i8** getelementptr inbounds ({ [8 x i8*] }, { [8 x i8*] }* @_ZTV11SpeedScreen, i32 0, inrange i32 0, i32 2) to i32 (...)**), i32 (...)*** %2, align 4
  %3 = bitcast %class.SpeedScreen* %this1 to %class.ParentScreen*
  %call = call %class.Screen* @_ZN12ParentScreen14addChildScreenEP6Screen(%class.ParentScreen* %3, %class.Screen* getelementptr inbounds (%class.AltitudeScreen, %class.AltitudeScreen* @altitudeScreen, i32 0, i32 0))
  ret void
}

declare void @_ZN12ParentScreenC2Ev(%class.ParentScreen*) unnamed_addr #1

declare %class.Screen* @_ZN12ParentScreen14addChildScreenEP6Screen(%class.ParentScreen*, %class.Screen*) #1

; Function Attrs: noinline optnone
define void @_ZNK11SpeedScreen10drawScreenEv(%class.SpeedScreen* %this) unnamed_addr #2 align 2 {
  %this.addr = alloca %class.SpeedScreen*, align 4
  %gpsFix = alloca %class.gps_fix, align 1
  store %class.SpeedScreen* %this, %class.SpeedScreen** %this.addr, align 4
  %this1 = load %class.SpeedScreen*, %class.SpeedScreen** %this.addr, align 4
  %call = call dereferenceable(64) %class.GPSDataModel* @_ZN12GPSDataModel8instanceEv()
  call void @_ZNK12GPSDataModel9getGPSFixEv(%class.gps_fix* sret %gpsFix, %class.GPSDataModel* %call)
  ret void
}

declare dereferenceable(64) %class.GPSDataModel* @_ZN12GPSDataModel8instanceEv() #1

declare void @_ZNK12GPSDataModel9getGPSFixEv(%class.gps_fix* sret, %class.GPSDataModel*) #1

; Function Attrs: noinline nounwind optnone
define i8* @_ZN11SpeedScreen15headingAsLetterEt(i16 zeroext %heading) #3 align 2 {
  %retval = alloca i8*, align 4
  %heading.addr = alloca i16, align 2
  store i16 %heading, i16* %heading.addr, align 2
  %1 = load i16, i16* %heading.addr, align 2
  %conv = zext i16 %1 to i32
  %cmp = icmp slt i32 %conv, 22
  br i1 %cmp, label %2, label %3

; <label>:2:                                      ; preds = %0
  store i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str, i32 0, i32 0), i8** %retval, align 4
  br label %25

; <label>:3:                                      ; preds = %0
  %4 = load i16, i16* %heading.addr, align 2
  %conv1 = zext i16 %4 to i32
  %cmp2 = icmp slt i32 %conv1, 67
  br i1 %cmp2, label %5, label %6

; <label>:5:                                      ; preds = %3
  store i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.1, i32 0, i32 0), i8** %retval, align 4
  br label %25

; <label>:6:                                      ; preds = %3
  %7 = load i16, i16* %heading.addr, align 2
  %conv3 = zext i16 %7 to i32
  %cmp4 = icmp slt i32 %conv3, 122
  br i1 %cmp4, label %8, label %9

; <label>:8:                                      ; preds = %6
  store i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str.2, i32 0, i32 0), i8** %retval, align 4
  br label %25

; <label>:9:                                      ; preds = %6
  %10 = load i16, i16* %heading.addr, align 2
  %conv5 = zext i16 %10 to i32
  %cmp6 = icmp slt i32 %conv5, 157
  br i1 %cmp6, label %11, label %12

; <label>:11:                                     ; preds = %9
  store i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.3, i32 0, i32 0), i8** %retval, align 4
  br label %25

; <label>:12:                                     ; preds = %9
  %13 = load i16, i16* %heading.addr, align 2
  %conv7 = zext i16 %13 to i32
  %cmp8 = icmp slt i32 %conv7, 202
  br i1 %cmp8, label %14, label %15

; <label>:14:                                     ; preds = %12
  store i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str.4, i32 0, i32 0), i8** %retval, align 4
  br label %25

; <label>:15:                                     ; preds = %12
  %16 = load i16, i16* %heading.addr, align 2
  %conv9 = zext i16 %16 to i32
  %cmp10 = icmp slt i32 %conv9, 247
  br i1 %cmp10, label %17, label %18

; <label>:17:                                     ; preds = %15
  store i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.5, i32 0, i32 0), i8** %retval, align 4
  br label %25

; <label>:18:                                     ; preds = %15
  %19 = load i16, i16* %heading.addr, align 2
  %conv11 = zext i16 %19 to i32
  %cmp12 = icmp slt i32 %conv11, 292
  br i1 %cmp12, label %20, label %21

; <label>:20:                                     ; preds = %18
  store i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str.6, i32 0, i32 0), i8** %retval, align 4
  br label %25

; <label>:21:                                     ; preds = %18
  %22 = load i16, i16* %heading.addr, align 2
  %conv13 = zext i16 %22 to i32
  %cmp14 = icmp slt i32 %conv13, 337
  br i1 %cmp14, label %23, label %24

; <label>:23:                                     ; preds = %21
  store i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.7, i32 0, i32 0), i8** %retval, align 4
  br label %25

; <label>:24:                                     ; preds = %21
  store i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str, i32 0, i32 0), i8** %retval, align 4
  br label %25

; <label>:25:                                     ; preds = %24, %23, %20, %17, %14, %11, %8, %5, %2
  %26 = load i8*, i8** %retval, align 4
  ret i8* %26
}

; Function Attrs: noinline nounwind optnone
define i8* @_ZNK11SpeedScreen15getOkButtonTextEv(%class.SpeedScreen* %this) unnamed_addr #3 align 2 {
  %this.addr = alloca %class.SpeedScreen*, align 4
  store %class.SpeedScreen* %this, %class.SpeedScreen** %this.addr, align 4
  %this1 = load %class.SpeedScreen*, %class.SpeedScreen** %this.addr, align 4
  ret i8* getelementptr inbounds ([9 x i8], [9 x i8]* @_ZZNK11SpeedScreen15getOkButtonTextEvE4text, i32 0, i32 0)
}

declare void @_ZNK6Screen10drawHeaderEv(%class.Screen*) unnamed_addr #1

declare void @_ZN6Screen11onSelButtonEv(%class.Screen*) unnamed_addr #1

declare void @_ZN12ParentScreen10onOkButtonEv(%class.ParentScreen*) unnamed_addr #1

declare i8* @_ZNK6Screen16getSelButtonTextEv(%class.Screen*) unnamed_addr #1

; Function Attrs: noinline
define internal void @_GLOBAL__sub_I_SpeedScreen.cpp() #0 section ".text.startup" {
  call void @__cxx_global_var_init()
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
