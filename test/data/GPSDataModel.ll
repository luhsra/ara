; ModuleID = '../../../GPSLogger/Src/GPS/GPSDataModel.cpp'
source_filename = "../../../GPSLogger/Src/GPS/GPSDataModel.cpp"
target datalayout = "e-m:e-p:32:32-f64:32:64-f80:32-n8:16:32-S128"
target triple = "i386-pc-linux-gnu"

%class.GPSOdometer = type { %class.GPSOdometerData }
%class.GPSOdometerData = type { i8, float, i16, i16, i32, i32, i32, i32, i32, float }
%class.GPSDataModel = type { %class.gps_fix, %class.gps_fix, %class.GPSSatellitesData, [3 x %class.GPSOdometer*], [3 x i8], %struct.QueueDefinition* }
%class.gps_fix = type { i8 }
%class.GPSSatellitesData = type { [20 x %"struct.GPSSatellitesData::SatteliteData"], i8 }
%"struct.GPSSatellitesData::SatteliteData" = type { i8, i8 }
%struct.QueueDefinition = type opaque
%class.MutexLocker = type { %struct.QueueDefinition* }

$_ZN11MutexLockerC2EP15QueueDefinition = comdat any

$_ZN11MutexLockerD2Ev = comdat any

$_ZN11GPSOdometer7getDataEv = comdat any

$_ZNK11GPSOdometer8isActiveEv = comdat any

$__clang_call_terminate = comdat any

$_ZNK15GPSOdometerData8isActiveEv = comdat any

@odometer0 = global %class.GPSOdometer zeroinitializer, align 4
@odometer1 = global %class.GPSOdometer zeroinitializer, align 4
@odometer2 = global %class.GPSOdometer zeroinitializer, align 4
@_ZZN12GPSDataModel8instanceEvE1s = internal global %class.GPSDataModel zeroinitializer, align 4
@_ZGVZN12GPSDataModel8instanceEvE1s = internal global i64 0, align 4
@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* @_GLOBAL__sub_I_GPSDataModel.cpp, i8* null }]

@_ZN12GPSDataModelC1Ev = alias void (%class.GPSDataModel*), void (%class.GPSDataModel*)* @_ZN12GPSDataModelC2Ev

; Function Attrs: noinline
define internal void @__cxx_global_var_init() #0 section ".text.startup" {
  call void @_ZN11GPSOdometerC1Ev(%class.GPSOdometer* @odometer0)
  ret void
}

declare void @_ZN11GPSOdometerC1Ev(%class.GPSOdometer*) unnamed_addr #1

; Function Attrs: noinline
define internal void @__cxx_global_var_init.1() #0 section ".text.startup" {
  call void @_ZN11GPSOdometerC1Ev(%class.GPSOdometer* @odometer1)
  ret void
}

; Function Attrs: noinline
define internal void @__cxx_global_var_init.2() #0 section ".text.startup" {
  call void @_ZN11GPSOdometerC1Ev(%class.GPSOdometer* @odometer2)
  ret void
}

; Function Attrs: noinline optnone
define void @_ZN12GPSDataModelC2Ev(%class.GPSDataModel* %this) unnamed_addr #2 align 2 {
  %this.addr = alloca %class.GPSDataModel*, align 4
  store %class.GPSDataModel* %this, %class.GPSDataModel** %this.addr, align 4
  %this1 = load %class.GPSDataModel*, %class.GPSDataModel** %this.addr, align 4
  %cur_fix = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 0
  %prev_fix = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 1
  %sattelitesData = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 2
  call void @_ZN17GPSSatellitesDataC1Ev(%class.GPSSatellitesData* %sattelitesData)
  %call = call %struct.QueueDefinition* @xQueueCreateMutex(i8 zeroext 1)
  %xGPSDataMutex = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 5
  store %struct.QueueDefinition* %call, %struct.QueueDefinition** %xGPSDataMutex, align 4
  %odometers = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 3
  %arrayidx = getelementptr inbounds [3 x %class.GPSOdometer*], [3 x %class.GPSOdometer*]* %odometers, i32 0, i32 0
  store %class.GPSOdometer* @odometer0, %class.GPSOdometer** %arrayidx, align 4
  %odometers2 = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 3
  %arrayidx3 = getelementptr inbounds [3 x %class.GPSOdometer*], [3 x %class.GPSOdometer*]* %odometers2, i32 0, i32 1
  store %class.GPSOdometer* @odometer1, %class.GPSOdometer** %arrayidx3, align 4
  %odometers4 = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 3
  %arrayidx5 = getelementptr inbounds [3 x %class.GPSOdometer*], [3 x %class.GPSOdometer*]* %odometers4, i32 0, i32 2
  store %class.GPSOdometer* @odometer2, %class.GPSOdometer** %arrayidx5, align 4
  %odometerWasActive = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 4
  %arrayidx6 = getelementptr inbounds [3 x i8], [3 x i8]* %odometerWasActive, i32 0, i32 0
  store i8 0, i8* %arrayidx6, align 4
  %odometerWasActive7 = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 4
  %arrayidx8 = getelementptr inbounds [3 x i8], [3 x i8]* %odometerWasActive7, i32 0, i32 1
  store i8 0, i8* %arrayidx8, align 1
  %odometerWasActive9 = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 4
  %arrayidx10 = getelementptr inbounds [3 x i8], [3 x i8]* %odometerWasActive9, i32 0, i32 2
  store i8 0, i8* %arrayidx10, align 2
  ret void
}

declare void @_ZN17GPSSatellitesDataC1Ev(%class.GPSSatellitesData*) unnamed_addr #1

declare %struct.QueueDefinition* @xQueueCreateMutex(i8 zeroext) #1

; Function Attrs: noinline optnone
define void @_ZN12GPSDataModel16processNewGPSFixERK7gps_fix(%class.GPSDataModel* %this, %class.gps_fix* dereferenceable(1) %fix) #2 align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
  %this.addr = alloca %class.GPSDataModel*, align 4
  %fix.addr = alloca %class.gps_fix*, align 4
  %lock = alloca %class.MutexLocker, align 4
  %exn.slot = alloca i8*
  %ehselector.slot = alloca i32
  store %class.GPSDataModel* %this, %class.GPSDataModel** %this.addr, align 4
  store %class.gps_fix* %fix, %class.gps_fix** %fix.addr, align 4
  %this1 = load %class.GPSDataModel*, %class.GPSDataModel** %this.addr, align 4
  %xGPSDataMutex = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 5
  %1 = load %struct.QueueDefinition*, %struct.QueueDefinition** %xGPSDataMutex, align 4
  call void @_ZN11MutexLockerC2EP15QueueDefinition(%class.MutexLocker* %lock, %struct.QueueDefinition* %1)
  %cur_fix = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 0
  %prev_fix = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 1
  %2 = load %class.gps_fix*, %class.gps_fix** %fix.addr, align 4
  %cur_fix2 = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 0
  %odometers = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 3
  %arrayidx = getelementptr inbounds [3 x %class.GPSOdometer*], [3 x %class.GPSOdometer*]* %odometers, i32 0, i32 0
  %3 = load %class.GPSOdometer*, %class.GPSOdometer** %arrayidx, align 4
  %4 = load %class.gps_fix*, %class.gps_fix** %fix.addr, align 4
  invoke void @_ZN11GPSOdometer13processNewFixERK7gps_fix(%class.GPSOdometer* %3, %class.gps_fix* dereferenceable(1) %4)
          to label %5 unwind label %12

; <label>:5:                                      ; preds = %0
  %odometers3 = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 3
  %arrayidx4 = getelementptr inbounds [3 x %class.GPSOdometer*], [3 x %class.GPSOdometer*]* %odometers3, i32 0, i32 1
  %6 = load %class.GPSOdometer*, %class.GPSOdometer** %arrayidx4, align 4
  %7 = load %class.gps_fix*, %class.gps_fix** %fix.addr, align 4
  invoke void @_ZN11GPSOdometer13processNewFixERK7gps_fix(%class.GPSOdometer* %6, %class.gps_fix* dereferenceable(1) %7)
          to label %8 unwind label %12

; <label>:8:                                      ; preds = %5
  %odometers5 = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 3
  %arrayidx6 = getelementptr inbounds [3 x %class.GPSOdometer*], [3 x %class.GPSOdometer*]* %odometers5, i32 0, i32 2
  %9 = load %class.GPSOdometer*, %class.GPSOdometer** %arrayidx6, align 4
  %10 = load %class.gps_fix*, %class.gps_fix** %fix.addr, align 4
  invoke void @_ZN11GPSOdometer13processNewFixERK7gps_fix(%class.GPSOdometer* %9, %class.gps_fix* dereferenceable(1) %10)
          to label %11 unwind label %12

; <label>:11:                                     ; preds = %8
  call void @_ZN11MutexLockerD2Ev(%class.MutexLocker* %lock) #5
  ret void

; <label>:12:                                     ; preds = %8, %5, %0
  %13 = landingpad { i8*, i32 }
          cleanup
  %14 = extractvalue { i8*, i32 } %13, 0
  store i8* %14, i8** %exn.slot, align 4
  %15 = extractvalue { i8*, i32 } %13, 1
  store i32 %15, i32* %ehselector.slot, align 4
  call void @_ZN11MutexLockerD2Ev(%class.MutexLocker* %lock) #5
  br label %16

; <label>:16:                                     ; preds = %12
  %exn = load i8*, i8** %exn.slot, align 4
  %sel = load i32, i32* %ehselector.slot, align 4
  %lpad.val = insertvalue { i8*, i32 } undef, i8* %exn, 0
  %lpad.val7 = insertvalue { i8*, i32 } %lpad.val, i32 %sel, 1
  resume { i8*, i32 } %lpad.val7
}

; Function Attrs: noinline optnone
define linkonce_odr void @_ZN11MutexLockerC2EP15QueueDefinition(%class.MutexLocker* %this, %struct.QueueDefinition* %mtx) unnamed_addr #2 comdat align 2 {
  %this.addr = alloca %class.MutexLocker*, align 4
  %mtx.addr = alloca %struct.QueueDefinition*, align 4
  store %class.MutexLocker* %this, %class.MutexLocker** %this.addr, align 4
  store %struct.QueueDefinition* %mtx, %struct.QueueDefinition** %mtx.addr, align 4
  %this1 = load %class.MutexLocker*, %class.MutexLocker** %this.addr, align 4
  %1 = load %struct.QueueDefinition*, %struct.QueueDefinition** %mtx.addr, align 4
  %mutex = getelementptr inbounds %class.MutexLocker, %class.MutexLocker* %this1, i32 0, i32 0
  store %struct.QueueDefinition* %1, %struct.QueueDefinition** %mutex, align 4
  %mutex2 = getelementptr inbounds %class.MutexLocker, %class.MutexLocker* %this1, i32 0, i32 0
  %2 = load %struct.QueueDefinition*, %struct.QueueDefinition** %mutex2, align 4
  %call = call i32 @xQueueSemaphoreTake(%struct.QueueDefinition* %2, i32 -1)
  ret void
}

declare void @_ZN11GPSOdometer13processNewFixERK7gps_fix(%class.GPSOdometer*, %class.gps_fix* dereferenceable(1)) #1

declare i32 @__gxx_personality_v0(...)

; Function Attrs: noinline nounwind optnone
define linkonce_odr void @_ZN11MutexLockerD2Ev(%class.MutexLocker* %this) unnamed_addr #3 comdat align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
  %this.addr = alloca %class.MutexLocker*, align 4
  store %class.MutexLocker* %this, %class.MutexLocker** %this.addr, align 4
  %this1 = load %class.MutexLocker*, %class.MutexLocker** %this.addr, align 4
  %mutex = getelementptr inbounds %class.MutexLocker, %class.MutexLocker* %this1, i32 0, i32 0
  %1 = load %struct.QueueDefinition*, %struct.QueueDefinition** %mutex, align 4
  %call = invoke i32 @xQueueGenericSend(%struct.QueueDefinition* %1, i8* null, i32 0, i32 0)
          to label %2 unwind label %3

; <label>:2:                                      ; preds = %0
  ret void

; <label>:3:                                      ; preds = %0
  %4 = landingpad { i8*, i32 }
          catch i8* null
  %5 = extractvalue { i8*, i32 } %4, 0
  call void @__clang_call_terminate(i8* %5) #4
  unreachable
}

; Function Attrs: noinline optnone
define void @_ZN12GPSDataModel24processNewSatellitesDataEPvh(%class.GPSDataModel* %this, i8* %sattelites, i8 zeroext %count) #2 align 2 {
  %this.addr = alloca %class.GPSDataModel*, align 4
  %sattelites.addr = alloca i8*, align 4
  %count.addr = alloca i8, align 1
  %lock = alloca %class.MutexLocker, align 4
  store %class.GPSDataModel* %this, %class.GPSDataModel** %this.addr, align 4
  store i8* %sattelites, i8** %sattelites.addr, align 4
  store i8 %count, i8* %count.addr, align 1
  %this1 = load %class.GPSDataModel*, %class.GPSDataModel** %this.addr, align 4
  %xGPSDataMutex = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 5
  %1 = load %struct.QueueDefinition*, %struct.QueueDefinition** %xGPSDataMutex, align 4
  call void @_ZN11MutexLockerC2EP15QueueDefinition(%class.MutexLocker* %lock, %struct.QueueDefinition* %1)
  call void @_ZN11MutexLockerD2Ev(%class.MutexLocker* %lock) #5
  ret void
}

; Function Attrs: noinline optnone
define void @_ZNK12GPSDataModel9getGPSFixEv(%class.gps_fix* noalias sret %agg.result, %class.GPSDataModel* %this) #2 align 2 {
  %this.addr = alloca %class.GPSDataModel*, align 4
  %lock = alloca %class.MutexLocker, align 4
  store %class.GPSDataModel* %this, %class.GPSDataModel** %this.addr, align 4
  %this1 = load %class.GPSDataModel*, %class.GPSDataModel** %this.addr, align 4
  %xGPSDataMutex = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 5
  %1 = load %struct.QueueDefinition*, %struct.QueueDefinition** %xGPSDataMutex, align 4
  call void @_ZN11MutexLockerC2EP15QueueDefinition(%class.MutexLocker* %lock, %struct.QueueDefinition* %1)
  %cur_fix = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 0
  call void @_ZN11MutexLockerD2Ev(%class.MutexLocker* %lock) #5
  ret void
}

; Function Attrs: noinline optnone
define void @_ZNK12GPSDataModel17getSattelitesDataEv(%class.GPSSatellitesData* noalias sret %agg.result, %class.GPSDataModel* %this) #2 align 2 {
  %this.addr = alloca %class.GPSDataModel*, align 4
  %lock = alloca %class.MutexLocker, align 4
  store %class.GPSDataModel* %this, %class.GPSDataModel** %this.addr, align 4
  %this1 = load %class.GPSDataModel*, %class.GPSDataModel** %this.addr, align 4
  %xGPSDataMutex = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 5
  %1 = load %struct.QueueDefinition*, %struct.QueueDefinition** %xGPSDataMutex, align 4
  call void @_ZN11MutexLockerC2EP15QueueDefinition(%class.MutexLocker* %lock, %struct.QueueDefinition* %1)
  call void @llvm.trap()
  unreachable
                                                  ; No predecessors!
  ret void
}

; Function Attrs: noreturn nounwind
declare void @llvm.trap() #4

; Function Attrs: noinline optnone
define float @_ZNK12GPSDataModel16getVerticalSpeedEv(%class.GPSDataModel* %this) #2 align 2 {
  %this.addr = alloca %class.GPSDataModel*, align 4
  %lock = alloca %class.MutexLocker, align 4
  store %class.GPSDataModel* %this, %class.GPSDataModel** %this.addr, align 4
  %this1 = load %class.GPSDataModel*, %class.GPSDataModel** %this.addr, align 4
  %xGPSDataMutex = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 5
  %1 = load %struct.QueueDefinition*, %struct.QueueDefinition** %xGPSDataMutex, align 4
  call void @_ZN11MutexLockerC2EP15QueueDefinition(%class.MutexLocker* %lock, %struct.QueueDefinition* %1)
  call void @_ZN11MutexLockerD2Ev(%class.MutexLocker* %lock) #5
  ret float 1.000000e+00
}

; Function Attrs: noinline optnone
define i32 @_ZNK12GPSDataModel14timeDifferenceEv(%class.GPSDataModel* %this) #2 align 2 {
  %this.addr = alloca %class.GPSDataModel*, align 4
  %lock = alloca %class.MutexLocker, align 4
  store %class.GPSDataModel* %this, %class.GPSDataModel** %this.addr, align 4
  %this1 = load %class.GPSDataModel*, %class.GPSDataModel** %this.addr, align 4
  %xGPSDataMutex = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 5
  %1 = load %struct.QueueDefinition*, %struct.QueueDefinition** %xGPSDataMutex, align 4
  call void @_ZN11MutexLockerC2EP15QueueDefinition(%class.MutexLocker* %lock, %struct.QueueDefinition* %1)
  call void @_ZN11MutexLockerD2Ev(%class.MutexLocker* %lock) #5
  ret i32 1
}

; Function Attrs: noinline optnone
define void @_ZNK12GPSDataModel15getOdometerDataEh(%class.GPSOdometerData* noalias sret %agg.result, %class.GPSDataModel* %this, i8 zeroext %idx) #2 align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
  %this.addr = alloca %class.GPSDataModel*, align 4
  %idx.addr = alloca i8, align 1
  %lock = alloca %class.MutexLocker, align 4
  %exn.slot = alloca i8*
  %ehselector.slot = alloca i32
  store %class.GPSDataModel* %this, %class.GPSDataModel** %this.addr, align 4
  store i8 %idx, i8* %idx.addr, align 1
  %this1 = load %class.GPSDataModel*, %class.GPSDataModel** %this.addr, align 4
  %xGPSDataMutex = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 5
  %1 = load %struct.QueueDefinition*, %struct.QueueDefinition** %xGPSDataMutex, align 4
  call void @_ZN11MutexLockerC2EP15QueueDefinition(%class.MutexLocker* %lock, %struct.QueueDefinition* %1)
  %odometers = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 3
  %2 = load i8, i8* %idx.addr, align 1
  %idxprom = zext i8 %2 to i32
  %arrayidx = getelementptr inbounds [3 x %class.GPSOdometer*], [3 x %class.GPSOdometer*]* %odometers, i32 0, i32 %idxprom
  %3 = load %class.GPSOdometer*, %class.GPSOdometer** %arrayidx, align 4
  invoke void @_ZN11GPSOdometer7getDataEv(%class.GPSOdometerData* sret %agg.result, %class.GPSOdometer* %3)
          to label %4 unwind label %5

; <label>:4:                                      ; preds = %0
  call void @_ZN11MutexLockerD2Ev(%class.MutexLocker* %lock) #5
  ret void

; <label>:5:                                      ; preds = %0
  %6 = landingpad { i8*, i32 }
          cleanup
  %7 = extractvalue { i8*, i32 } %6, 0
  store i8* %7, i8** %exn.slot, align 4
  %8 = extractvalue { i8*, i32 } %6, 1
  store i32 %8, i32* %ehselector.slot, align 4
  call void @_ZN11MutexLockerD2Ev(%class.MutexLocker* %lock) #5
  br label %9

; <label>:9:                                      ; preds = %5
  %exn = load i8*, i8** %exn.slot, align 4
  %sel = load i32, i32* %ehselector.slot, align 4
  %lpad.val = insertvalue { i8*, i32 } undef, i8* %exn, 0
  %lpad.val2 = insertvalue { i8*, i32 } %lpad.val, i32 %sel, 1
  resume { i8*, i32 } %lpad.val2
}

; Function Attrs: noinline nounwind optnone
define linkonce_odr void @_ZN11GPSOdometer7getDataEv(%class.GPSOdometerData* noalias sret %agg.result, %class.GPSOdometer* %this) #3 comdat align 2 {
  %this.addr = alloca %class.GPSOdometer*, align 4
  store %class.GPSOdometer* %this, %class.GPSOdometer** %this.addr, align 4
  %this1 = load %class.GPSOdometer*, %class.GPSOdometer** %this.addr, align 4
  %data = getelementptr inbounds %class.GPSOdometer, %class.GPSOdometer* %this1, i32 0, i32 0
  %1 = bitcast %class.GPSOdometerData* %agg.result to i8*
  %2 = bitcast %class.GPSOdometerData* %data to i8*
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %1, i8* %2, i32 36, i32 4, i1 false)
  ret void
}

; Function Attrs: noinline optnone
define void @_ZN12GPSDataModel14resumeOdometerEh(%class.GPSDataModel* %this, i8 zeroext %idx) #2 align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
  %this.addr = alloca %class.GPSDataModel*, align 4
  %idx.addr = alloca i8, align 1
  %lock = alloca %class.MutexLocker, align 4
  %exn.slot = alloca i8*
  %ehselector.slot = alloca i32
  store %class.GPSDataModel* %this, %class.GPSDataModel** %this.addr, align 4
  store i8 %idx, i8* %idx.addr, align 1
  %this1 = load %class.GPSDataModel*, %class.GPSDataModel** %this.addr, align 4
  %xGPSDataMutex = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 5
  %1 = load %struct.QueueDefinition*, %struct.QueueDefinition** %xGPSDataMutex, align 4
  call void @_ZN11MutexLockerC2EP15QueueDefinition(%class.MutexLocker* %lock, %struct.QueueDefinition* %1)
  %odometers = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 3
  %2 = load i8, i8* %idx.addr, align 1
  %idxprom = zext i8 %2 to i32
  %arrayidx = getelementptr inbounds [3 x %class.GPSOdometer*], [3 x %class.GPSOdometer*]* %odometers, i32 0, i32 %idxprom
  %3 = load %class.GPSOdometer*, %class.GPSOdometer** %arrayidx, align 4
  invoke void @_ZN11GPSOdometer13startOdometerEv(%class.GPSOdometer* %3)
          to label %4 unwind label %5

; <label>:4:                                      ; preds = %0
  call void @_ZN11MutexLockerD2Ev(%class.MutexLocker* %lock) #5
  ret void

; <label>:5:                                      ; preds = %0
  %6 = landingpad { i8*, i32 }
          cleanup
  %7 = extractvalue { i8*, i32 } %6, 0
  store i8* %7, i8** %exn.slot, align 4
  %8 = extractvalue { i8*, i32 } %6, 1
  store i32 %8, i32* %ehselector.slot, align 4
  call void @_ZN11MutexLockerD2Ev(%class.MutexLocker* %lock) #5
  br label %9

; <label>:9:                                      ; preds = %5
  %exn = load i8*, i8** %exn.slot, align 4
  %sel = load i32, i32* %ehselector.slot, align 4
  %lpad.val = insertvalue { i8*, i32 } undef, i8* %exn, 0
  %lpad.val2 = insertvalue { i8*, i32 } %lpad.val, i32 %sel, 1
  resume { i8*, i32 } %lpad.val2
}

declare void @_ZN11GPSOdometer13startOdometerEv(%class.GPSOdometer*) #1

; Function Attrs: noinline optnone
define void @_ZN12GPSDataModel13pauseOdometerEh(%class.GPSDataModel* %this, i8 zeroext %idx) #2 align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
  %this.addr = alloca %class.GPSDataModel*, align 4
  %idx.addr = alloca i8, align 1
  %lock = alloca %class.MutexLocker, align 4
  %exn.slot = alloca i8*
  %ehselector.slot = alloca i32
  store %class.GPSDataModel* %this, %class.GPSDataModel** %this.addr, align 4
  store i8 %idx, i8* %idx.addr, align 1
  %this1 = load %class.GPSDataModel*, %class.GPSDataModel** %this.addr, align 4
  %xGPSDataMutex = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 5
  %1 = load %struct.QueueDefinition*, %struct.QueueDefinition** %xGPSDataMutex, align 4
  call void @_ZN11MutexLockerC2EP15QueueDefinition(%class.MutexLocker* %lock, %struct.QueueDefinition* %1)
  %odometers = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 3
  %2 = load i8, i8* %idx.addr, align 1
  %idxprom = zext i8 %2 to i32
  %arrayidx = getelementptr inbounds [3 x %class.GPSOdometer*], [3 x %class.GPSOdometer*]* %odometers, i32 0, i32 %idxprom
  %3 = load %class.GPSOdometer*, %class.GPSOdometer** %arrayidx, align 4
  invoke void @_ZN11GPSOdometer13pauseOdometerEv(%class.GPSOdometer* %3)
          to label %4 unwind label %5

; <label>:4:                                      ; preds = %0
  call void @_ZN11MutexLockerD2Ev(%class.MutexLocker* %lock) #5
  ret void

; <label>:5:                                      ; preds = %0
  %6 = landingpad { i8*, i32 }
          cleanup
  %7 = extractvalue { i8*, i32 } %6, 0
  store i8* %7, i8** %exn.slot, align 4
  %8 = extractvalue { i8*, i32 } %6, 1
  store i32 %8, i32* %ehselector.slot, align 4
  call void @_ZN11MutexLockerD2Ev(%class.MutexLocker* %lock) #5
  br label %9

; <label>:9:                                      ; preds = %5
  %exn = load i8*, i8** %exn.slot, align 4
  %sel = load i32, i32* %ehselector.slot, align 4
  %lpad.val = insertvalue { i8*, i32 } undef, i8* %exn, 0
  %lpad.val2 = insertvalue { i8*, i32 } %lpad.val, i32 %sel, 1
  resume { i8*, i32 } %lpad.val2
}

declare void @_ZN11GPSOdometer13pauseOdometerEv(%class.GPSOdometer*) #1

; Function Attrs: noinline optnone
define void @_ZN12GPSDataModel13resetOdometerEh(%class.GPSDataModel* %this, i8 zeroext %idx) #2 align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
  %this.addr = alloca %class.GPSDataModel*, align 4
  %idx.addr = alloca i8, align 1
  %lock = alloca %class.MutexLocker, align 4
  %exn.slot = alloca i8*
  %ehselector.slot = alloca i32
  store %class.GPSDataModel* %this, %class.GPSDataModel** %this.addr, align 4
  store i8 %idx, i8* %idx.addr, align 1
  %this1 = load %class.GPSDataModel*, %class.GPSDataModel** %this.addr, align 4
  %xGPSDataMutex = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 5
  %1 = load %struct.QueueDefinition*, %struct.QueueDefinition** %xGPSDataMutex, align 4
  call void @_ZN11MutexLockerC2EP15QueueDefinition(%class.MutexLocker* %lock, %struct.QueueDefinition* %1)
  %odometers = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 3
  %2 = load i8, i8* %idx.addr, align 1
  %idxprom = zext i8 %2 to i32
  %arrayidx = getelementptr inbounds [3 x %class.GPSOdometer*], [3 x %class.GPSOdometer*]* %odometers, i32 0, i32 %idxprom
  %3 = load %class.GPSOdometer*, %class.GPSOdometer** %arrayidx, align 4
  invoke void @_ZN11GPSOdometer13resetOdometerEv(%class.GPSOdometer* %3)
          to label %4 unwind label %5

; <label>:4:                                      ; preds = %0
  call void @_ZN11MutexLockerD2Ev(%class.MutexLocker* %lock) #5
  ret void

; <label>:5:                                      ; preds = %0
  %6 = landingpad { i8*, i32 }
          cleanup
  %7 = extractvalue { i8*, i32 } %6, 0
  store i8* %7, i8** %exn.slot, align 4
  %8 = extractvalue { i8*, i32 } %6, 1
  store i32 %8, i32* %ehselector.slot, align 4
  call void @_ZN11MutexLockerD2Ev(%class.MutexLocker* %lock) #5
  br label %9

; <label>:9:                                      ; preds = %5
  %exn = load i8*, i8** %exn.slot, align 4
  %sel = load i32, i32* %ehselector.slot, align 4
  %lpad.val = insertvalue { i8*, i32 } undef, i8* %exn, 0
  %lpad.val2 = insertvalue { i8*, i32 } %lpad.val, i32 %sel, 1
  resume { i8*, i32 } %lpad.val2
}

declare void @_ZN11GPSOdometer13resetOdometerEv(%class.GPSOdometer*) #1

; Function Attrs: noinline optnone
define void @_ZN12GPSDataModel18resumeAllOdometersEv(%class.GPSDataModel* %this) #2 align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
  %this.addr = alloca %class.GPSDataModel*, align 4
  %lock = alloca %class.MutexLocker, align 4
  %exn.slot = alloca i8*
  %ehselector.slot = alloca i32
  store %class.GPSDataModel* %this, %class.GPSDataModel** %this.addr, align 4
  %this1 = load %class.GPSDataModel*, %class.GPSDataModel** %this.addr, align 4
  %xGPSDataMutex = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 5
  %1 = load %struct.QueueDefinition*, %struct.QueueDefinition** %xGPSDataMutex, align 4
  call void @_ZN11MutexLockerC2EP15QueueDefinition(%class.MutexLocker* %lock, %struct.QueueDefinition* %1)
  %odometerWasActive = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 4
  %arrayidx = getelementptr inbounds [3 x i8], [3 x i8]* %odometerWasActive, i32 0, i32 0
  %2 = load i8, i8* %arrayidx, align 4
  %tobool = trunc i8 %2 to i1
  br i1 %tobool, label %3, label %10

; <label>:3:                                      ; preds = %0
  %odometers = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 3
  %arrayidx2 = getelementptr inbounds [3 x %class.GPSOdometer*], [3 x %class.GPSOdometer*]* %odometers, i32 0, i32 0
  %4 = load %class.GPSOdometer*, %class.GPSOdometer** %arrayidx2, align 4
  invoke void @_ZN11GPSOdometer13startOdometerEv(%class.GPSOdometer* %4)
          to label %5 unwind label %6

; <label>:5:                                      ; preds = %3
  br label %10

; <label>:6:                                      ; preds = %17, %12, %3
  %7 = landingpad { i8*, i32 }
          cleanup
  %8 = extractvalue { i8*, i32 } %7, 0
  store i8* %8, i8** %exn.slot, align 4
  %9 = extractvalue { i8*, i32 } %7, 1
  store i32 %9, i32* %ehselector.slot, align 4
  call void @_ZN11MutexLockerD2Ev(%class.MutexLocker* %lock) #5
  br label %21

; <label>:10:                                     ; preds = %5, %0
  %odometerWasActive3 = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 4
  %arrayidx4 = getelementptr inbounds [3 x i8], [3 x i8]* %odometerWasActive3, i32 0, i32 1
  %11 = load i8, i8* %arrayidx4, align 1
  %tobool5 = trunc i8 %11 to i1
  br i1 %tobool5, label %12, label %15

; <label>:12:                                     ; preds = %10
  %odometers6 = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 3
  %arrayidx7 = getelementptr inbounds [3 x %class.GPSOdometer*], [3 x %class.GPSOdometer*]* %odometers6, i32 0, i32 1
  %13 = load %class.GPSOdometer*, %class.GPSOdometer** %arrayidx7, align 4
  invoke void @_ZN11GPSOdometer13startOdometerEv(%class.GPSOdometer* %13)
          to label %14 unwind label %6

; <label>:14:                                     ; preds = %12
  br label %15

; <label>:15:                                     ; preds = %14, %10
  %odometerWasActive8 = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 4
  %arrayidx9 = getelementptr inbounds [3 x i8], [3 x i8]* %odometerWasActive8, i32 0, i32 2
  %16 = load i8, i8* %arrayidx9, align 2
  %tobool10 = trunc i8 %16 to i1
  br i1 %tobool10, label %17, label %20

; <label>:17:                                     ; preds = %15
  %odometers11 = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 3
  %arrayidx12 = getelementptr inbounds [3 x %class.GPSOdometer*], [3 x %class.GPSOdometer*]* %odometers11, i32 0, i32 2
  %18 = load %class.GPSOdometer*, %class.GPSOdometer** %arrayidx12, align 4
  invoke void @_ZN11GPSOdometer13startOdometerEv(%class.GPSOdometer* %18)
          to label %19 unwind label %6

; <label>:19:                                     ; preds = %17
  br label %20

; <label>:20:                                     ; preds = %19, %15
  call void @_ZN11MutexLockerD2Ev(%class.MutexLocker* %lock) #5
  ret void

; <label>:21:                                     ; preds = %6
  %exn = load i8*, i8** %exn.slot, align 4
  %sel = load i32, i32* %ehselector.slot, align 4
  %lpad.val = insertvalue { i8*, i32 } undef, i8* %exn, 0
  %lpad.val13 = insertvalue { i8*, i32 } %lpad.val, i32 %sel, 1
  resume { i8*, i32 } %lpad.val13
}

; Function Attrs: noinline optnone
define void @_ZN12GPSDataModel17pauseAllOdometersEv(%class.GPSDataModel* %this) #2 align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
  %this.addr = alloca %class.GPSDataModel*, align 4
  %lock = alloca %class.MutexLocker, align 4
  %exn.slot = alloca i8*
  %ehselector.slot = alloca i32
  store %class.GPSDataModel* %this, %class.GPSDataModel** %this.addr, align 4
  %this1 = load %class.GPSDataModel*, %class.GPSDataModel** %this.addr, align 4
  %xGPSDataMutex = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 5
  %1 = load %struct.QueueDefinition*, %struct.QueueDefinition** %xGPSDataMutex, align 4
  call void @_ZN11MutexLockerC2EP15QueueDefinition(%class.MutexLocker* %lock, %struct.QueueDefinition* %1)
  %odometers = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 3
  %arrayidx = getelementptr inbounds [3 x %class.GPSOdometer*], [3 x %class.GPSOdometer*]* %odometers, i32 0, i32 0
  %2 = load %class.GPSOdometer*, %class.GPSOdometer** %arrayidx, align 4
  %call = invoke zeroext i1 @_ZNK11GPSOdometer8isActiveEv(%class.GPSOdometer* %2)
          to label %3 unwind label %14

; <label>:3:                                      ; preds = %0
  %odometerWasActive = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 4
  %arrayidx2 = getelementptr inbounds [3 x i8], [3 x i8]* %odometerWasActive, i32 0, i32 0
  %frombool = zext i1 %call to i8
  store i8 %frombool, i8* %arrayidx2, align 4
  %odometers3 = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 3
  %arrayidx4 = getelementptr inbounds [3 x %class.GPSOdometer*], [3 x %class.GPSOdometer*]* %odometers3, i32 0, i32 1
  %4 = load %class.GPSOdometer*, %class.GPSOdometer** %arrayidx4, align 4
  %call5 = invoke zeroext i1 @_ZNK11GPSOdometer8isActiveEv(%class.GPSOdometer* %4)
          to label %5 unwind label %14

; <label>:5:                                      ; preds = %3
  %odometerWasActive6 = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 4
  %arrayidx7 = getelementptr inbounds [3 x i8], [3 x i8]* %odometerWasActive6, i32 0, i32 1
  %frombool8 = zext i1 %call5 to i8
  store i8 %frombool8, i8* %arrayidx7, align 1
  %odometers9 = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 3
  %arrayidx10 = getelementptr inbounds [3 x %class.GPSOdometer*], [3 x %class.GPSOdometer*]* %odometers9, i32 0, i32 2
  %6 = load %class.GPSOdometer*, %class.GPSOdometer** %arrayidx10, align 4
  %call11 = invoke zeroext i1 @_ZNK11GPSOdometer8isActiveEv(%class.GPSOdometer* %6)
          to label %7 unwind label %14

; <label>:7:                                      ; preds = %5
  %odometerWasActive12 = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 4
  %arrayidx13 = getelementptr inbounds [3 x i8], [3 x i8]* %odometerWasActive12, i32 0, i32 2
  %frombool14 = zext i1 %call11 to i8
  store i8 %frombool14, i8* %arrayidx13, align 2
  %odometers15 = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 3
  %arrayidx16 = getelementptr inbounds [3 x %class.GPSOdometer*], [3 x %class.GPSOdometer*]* %odometers15, i32 0, i32 0
  %8 = load %class.GPSOdometer*, %class.GPSOdometer** %arrayidx16, align 4
  invoke void @_ZN11GPSOdometer13pauseOdometerEv(%class.GPSOdometer* %8)
          to label %9 unwind label %14

; <label>:9:                                      ; preds = %7
  %odometers17 = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 3
  %arrayidx18 = getelementptr inbounds [3 x %class.GPSOdometer*], [3 x %class.GPSOdometer*]* %odometers17, i32 0, i32 1
  %10 = load %class.GPSOdometer*, %class.GPSOdometer** %arrayidx18, align 4
  invoke void @_ZN11GPSOdometer13pauseOdometerEv(%class.GPSOdometer* %10)
          to label %11 unwind label %14

; <label>:11:                                     ; preds = %9
  %odometers19 = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 3
  %arrayidx20 = getelementptr inbounds [3 x %class.GPSOdometer*], [3 x %class.GPSOdometer*]* %odometers19, i32 0, i32 2
  %12 = load %class.GPSOdometer*, %class.GPSOdometer** %arrayidx20, align 4
  invoke void @_ZN11GPSOdometer13pauseOdometerEv(%class.GPSOdometer* %12)
          to label %13 unwind label %14

; <label>:13:                                     ; preds = %11
  call void @_ZN11MutexLockerD2Ev(%class.MutexLocker* %lock) #5
  ret void

; <label>:14:                                     ; preds = %11, %9, %7, %5, %3, %0
  %15 = landingpad { i8*, i32 }
          cleanup
  %16 = extractvalue { i8*, i32 } %15, 0
  store i8* %16, i8** %exn.slot, align 4
  %17 = extractvalue { i8*, i32 } %15, 1
  store i32 %17, i32* %ehselector.slot, align 4
  call void @_ZN11MutexLockerD2Ev(%class.MutexLocker* %lock) #5
  br label %18

; <label>:18:                                     ; preds = %14
  %exn = load i8*, i8** %exn.slot, align 4
  %sel = load i32, i32* %ehselector.slot, align 4
  %lpad.val = insertvalue { i8*, i32 } undef, i8* %exn, 0
  %lpad.val21 = insertvalue { i8*, i32 } %lpad.val, i32 %sel, 1
  resume { i8*, i32 } %lpad.val21
}

; Function Attrs: noinline optnone
define linkonce_odr zeroext i1 @_ZNK11GPSOdometer8isActiveEv(%class.GPSOdometer* %this) #2 comdat align 2 {
  %this.addr = alloca %class.GPSOdometer*, align 4
  store %class.GPSOdometer* %this, %class.GPSOdometer** %this.addr, align 4
  %this1 = load %class.GPSOdometer*, %class.GPSOdometer** %this.addr, align 4
  %data = getelementptr inbounds %class.GPSOdometer, %class.GPSOdometer* %this1, i32 0, i32 0
  %call = call zeroext i1 @_ZNK15GPSOdometerData8isActiveEv(%class.GPSOdometerData* %data)
  ret i1 %call
}

; Function Attrs: noinline optnone
define void @_ZN12GPSDataModel17resetAllOdometersEv(%class.GPSDataModel* %this) #2 align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
  %this.addr = alloca %class.GPSDataModel*, align 4
  %lock = alloca %class.MutexLocker, align 4
  %exn.slot = alloca i8*
  %ehselector.slot = alloca i32
  store %class.GPSDataModel* %this, %class.GPSDataModel** %this.addr, align 4
  %this1 = load %class.GPSDataModel*, %class.GPSDataModel** %this.addr, align 4
  %xGPSDataMutex = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 5
  %1 = load %struct.QueueDefinition*, %struct.QueueDefinition** %xGPSDataMutex, align 4
  call void @_ZN11MutexLockerC2EP15QueueDefinition(%class.MutexLocker* %lock, %struct.QueueDefinition* %1)
  %odometers = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 3
  %arrayidx = getelementptr inbounds [3 x %class.GPSOdometer*], [3 x %class.GPSOdometer*]* %odometers, i32 0, i32 0
  %2 = load %class.GPSOdometer*, %class.GPSOdometer** %arrayidx, align 4
  invoke void @_ZN11GPSOdometer13resetOdometerEv(%class.GPSOdometer* %2)
          to label %3 unwind label %8

; <label>:3:                                      ; preds = %0
  %odometers2 = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 3
  %arrayidx3 = getelementptr inbounds [3 x %class.GPSOdometer*], [3 x %class.GPSOdometer*]* %odometers2, i32 0, i32 1
  %4 = load %class.GPSOdometer*, %class.GPSOdometer** %arrayidx3, align 4
  invoke void @_ZN11GPSOdometer13resetOdometerEv(%class.GPSOdometer* %4)
          to label %5 unwind label %8

; <label>:5:                                      ; preds = %3
  %odometers4 = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 3
  %arrayidx5 = getelementptr inbounds [3 x %class.GPSOdometer*], [3 x %class.GPSOdometer*]* %odometers4, i32 0, i32 2
  %6 = load %class.GPSOdometer*, %class.GPSOdometer** %arrayidx5, align 4
  invoke void @_ZN11GPSOdometer13resetOdometerEv(%class.GPSOdometer* %6)
          to label %7 unwind label %8

; <label>:7:                                      ; preds = %5
  %odometerWasActive = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 4
  %arrayidx6 = getelementptr inbounds [3 x i8], [3 x i8]* %odometerWasActive, i32 0, i32 0
  store i8 0, i8* %arrayidx6, align 4
  %odometerWasActive7 = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 4
  %arrayidx8 = getelementptr inbounds [3 x i8], [3 x i8]* %odometerWasActive7, i32 0, i32 1
  store i8 0, i8* %arrayidx8, align 1
  %odometerWasActive9 = getelementptr inbounds %class.GPSDataModel, %class.GPSDataModel* %this1, i32 0, i32 4
  %arrayidx10 = getelementptr inbounds [3 x i8], [3 x i8]* %odometerWasActive9, i32 0, i32 2
  store i8 0, i8* %arrayidx10, align 2
  call void @_ZN11MutexLockerD2Ev(%class.MutexLocker* %lock) #5
  ret void

; <label>:8:                                      ; preds = %5, %3, %0
  %9 = landingpad { i8*, i32 }
          cleanup
  %10 = extractvalue { i8*, i32 } %9, 0
  store i8* %10, i8** %exn.slot, align 4
  %11 = extractvalue { i8*, i32 } %9, 1
  store i32 %11, i32* %ehselector.slot, align 4
  call void @_ZN11MutexLockerD2Ev(%class.MutexLocker* %lock) #5
  br label %12

; <label>:12:                                     ; preds = %8
  %exn = load i8*, i8** %exn.slot, align 4
  %sel = load i32, i32* %ehselector.slot, align 4
  %lpad.val = insertvalue { i8*, i32 } undef, i8* %exn, 0
  %lpad.val11 = insertvalue { i8*, i32 } %lpad.val, i32 %sel, 1
  resume { i8*, i32 } %lpad.val11
}

; Function Attrs: noinline optnone
define dereferenceable(64) %class.GPSDataModel* @_ZN12GPSDataModel8instanceEv() #2 align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
  %exn.slot = alloca i8*
  %ehselector.slot = alloca i32
  %1 = load atomic i8, i8* bitcast (i64* @_ZGVZN12GPSDataModel8instanceEvE1s to i8*) acquire, align 4
  %guard.uninitialized = icmp eq i8 %1, 0
  br i1 %guard.uninitialized, label %2, label %6, !prof !3

; <label>:2:                                      ; preds = %0
  %3 = call i32 @__cxa_guard_acquire(i64* @_ZGVZN12GPSDataModel8instanceEvE1s) #5
  %tobool = icmp ne i32 %3, 0
  br i1 %tobool, label %4, label %6

; <label>:4:                                      ; preds = %2
  invoke void @_ZN12GPSDataModelC1Ev(%class.GPSDataModel* @_ZZN12GPSDataModel8instanceEvE1s)
          to label %5 unwind label %7

; <label>:5:                                      ; preds = %4
  call void @__cxa_guard_release(i64* @_ZGVZN12GPSDataModel8instanceEvE1s) #5
  br label %6

; <label>:6:                                      ; preds = %5, %2, %0
  ret %class.GPSDataModel* @_ZZN12GPSDataModel8instanceEvE1s

; <label>:7:                                      ; preds = %4
  %8 = landingpad { i8*, i32 }
          cleanup
  %9 = extractvalue { i8*, i32 } %8, 0
  store i8* %9, i8** %exn.slot, align 4
  %10 = extractvalue { i8*, i32 } %8, 1
  store i32 %10, i32* %ehselector.slot, align 4
  call void @__cxa_guard_abort(i64* @_ZGVZN12GPSDataModel8instanceEvE1s) #5
  br label %11

; <label>:11:                                     ; preds = %7
  %exn = load i8*, i8** %exn.slot, align 4
  %sel = load i32, i32* %ehselector.slot, align 4
  %lpad.val = insertvalue { i8*, i32 } undef, i8* %exn, 0
  %lpad.val1 = insertvalue { i8*, i32 } %lpad.val, i32 %sel, 1
  resume { i8*, i32 } %lpad.val1
}

; Function Attrs: nounwind
declare i32 @__cxa_guard_acquire(i64*) #5

; Function Attrs: nounwind
declare void @__cxa_guard_abort(i64*) #5

; Function Attrs: nounwind
declare void @__cxa_guard_release(i64*) #5

declare i32 @xQueueSemaphoreTake(%struct.QueueDefinition*, i32) #1

declare i32 @xQueueGenericSend(%struct.QueueDefinition*, i8*, i32, i32) #1

; Function Attrs: noinline noreturn nounwind
define linkonce_odr hidden void @__clang_call_terminate(i8*) #6 comdat {
  %2 = call i8* @__cxa_begin_catch(i8* %0) #5
  call void @_ZSt9terminatev() #4
  unreachable
}

declare i8* @__cxa_begin_catch(i8*)

declare void @_ZSt9terminatev()

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i32(i8* nocapture writeonly, i8* nocapture readonly, i32, i32, i1) #7

; Function Attrs: noinline nounwind optnone
define linkonce_odr zeroext i1 @_ZNK15GPSOdometerData8isActiveEv(%class.GPSOdometerData* %this) #3 comdat align 2 {
  %this.addr = alloca %class.GPSOdometerData*, align 4
  store %class.GPSOdometerData* %this, %class.GPSOdometerData** %this.addr, align 4
  %this1 = load %class.GPSOdometerData*, %class.GPSOdometerData** %this.addr, align 4
  %active = getelementptr inbounds %class.GPSOdometerData, %class.GPSOdometerData* %this1, i32 0, i32 0
  %1 = load i8, i8* %active, align 4
  %tobool = trunc i8 %1 to i1
  ret i1 %tobool
}

; Function Attrs: noinline
define internal void @_GLOBAL__sub_I_GPSDataModel.cpp() #0 section ".text.startup" {
  call void @__cxx_global_var_init()
  call void @__cxx_global_var_init.1()
  call void @__cxx_global_var_init.2()
  ret void
}

attributes #0 = { noinline "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noinline optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { noreturn nounwind }
attributes #5 = { nounwind }
attributes #6 = { noinline noreturn nounwind }
attributes #7 = { argmemonly nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"NumRegisterParameters", i32 0}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
!3 = !{!"branch_weights", i32 1, i32 1048575}
