/**
 ******************************************************************************
 * @addtogroup UAVObjects OpenPilot UAVObjects
 * @{ 
 * @addtogroup StabilizationBank StabilizationBank
 * @brief Currently selected PID bank
 *
 * Autogenerated files and functions for StabilizationBank Object
 * @{ 
 *
 * @file       stabilizationbank.c
 * @author     The OpenPilot Team, http://www.openpilot.org Copyright (C) 2010-2013.
 * @brief      Implementation of the StabilizationBank object. This file has been 
 *             automatically generated by the UAVObjectGenerator.
 * 
 * @note       Object definition file: stabilizationbank.xml. 
 *             This is an automatically generated file.
 *             DO NOT modify manually.
 *
 * @see        The GNU Public License (GPL) Version 3
 *
 *****************************************************************************/
/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
 * for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

#include <openpilot.h>
#include "stabilizationbank.h"

// Private variables
#if (defined(__MACH__) && defined(__APPLE__))
static UAVObjHandle handle __attribute__((section("__DATA,_uavo_handles")));
#else
static UAVObjHandle handle __attribute__((section("_uavo_handles")));
#endif

#if STABILIZATIONBANK_ISSETTINGS
SETTINGS_INITCALL(StabilizationBankInitialize);
#endif

/**
 * Initialize object.
 * \return 0 Success
 * \return -1 Failure to initialize or -2 for already initialized
 */
int32_t StabilizationBankInitialize(void)
{
    // Compile time assertion that the StabilizationBankDataPacked and StabilizationBankData structs
    // have the same size (though instances of StabilizationBankData
    // should be placed in memory by the linker/compiler on a 4 byte alignment).
    PIOS_STATIC_ASSERT(sizeof(StabilizationBankDataPacked) == sizeof(StabilizationBankData));
    
    // Don't set the handle to null if already registered
    if (UAVObjGetByID(STABILIZATIONBANK_OBJID)) {
        return -2;
    }

    static const UAVObjType objType = {
       .id = STABILIZATIONBANK_OBJID,
       .instance_size = STABILIZATIONBANK_NUMBYTES,
       .init_callback = &StabilizationBankSetDefaults,
    };

    // Register object with the object manager
    handle = UAVObjRegister(&objType,
        STABILIZATIONBANK_ISSINGLEINST, STABILIZATIONBANK_ISSETTINGS, STABILIZATIONBANK_ISPRIORITY);

    // Done
    return handle ? 0 : -1;
}

static inline void DataOverrideDefaults(__attribute__((unused)) StabilizationBankData * data) {}

void StabilizationBankDataOverrideDefaults(StabilizationBankData * data) __attribute__((weak, alias("DataOverrideDefaults")));

/**
 * Initialize object fields and metadata with the default values.
 * If a default value is not specified the object fields
 * will be initialized to zero.
 */
void StabilizationBankSetDefaults(UAVObjHandle obj, uint16_t instId)
{
    StabilizationBankData data;

    // Initialize object fields to their default values
    UAVObjGetInstanceData(obj, instId, &data);
    memset(&data, 0, sizeof(StabilizationBankData));
    data.AttitudeFeedForward.Roll = 0.000000e+00f;
    data.AttitudeFeedForward.Pitch = 0.000000e+00f;
    data.AttitudeFeedForward.Yaw = 0.000000e+00f;
    data.RollRatePID.Kp = 3.000000e-03f;
    data.RollRatePID.Ki = 6.500000e-03f;
    data.RollRatePID.Kd = 3.300000e-05f;
    data.RollRatePID.ILimit = 3.000000e-01f;
    data.PitchRatePID.Kp = 3.000000e-03f;
    data.PitchRatePID.Ki = 6.500000e-03f;
    data.PitchRatePID.Kd = 3.300000e-05f;
    data.PitchRatePID.ILimit = 3.000000e-01f;
    data.YawRatePID.Kp = 6.200000e-03f;
    data.YawRatePID.Ki = 1.000000e-02f;
    data.YawRatePID.Kd = 5.000000e-05f;
    data.YawRatePID.ILimit = 3.000000e-01f;
    data.RollPI.Kp = 2.500000e+00f;
    data.RollPI.Ki = 0.000000e+00f;
    data.RollPI.ILimit = 5.000000e+01f;
    data.PitchPI.Kp = 2.500000e+00f;
    data.PitchPI.Ki = 0.000000e+00f;
    data.PitchPI.ILimit = 5.000000e+01f;
    data.ManualRate.Roll = 150;
    data.ManualRate.Pitch = 150;
    data.ManualRate.Yaw = 175;
    data.MaximumRate.Roll = 300;
    data.MaximumRate.Pitch = 300;
    data.MaximumRate.Yaw = 50;
    data.RollMax = 42;
    data.PitchMax = 42;
    data.YawMax = 42;
    data.StickExpo.Roll = 0;
    data.StickExpo.Pitch = 0;
    data.StickExpo.Yaw = 0;
    data.AcroInsanityFactor.Roll = 40;
    data.AcroInsanityFactor.Pitch = 40;
    data.AcroInsanityFactor.Yaw = 40;
    data.EnablePiroComp = 1;
    data.FpvCamTiltCompensation = 0;
    data.EnableThrustPIDScaling = 0;
    data.ThrustPIDScaleCurve[0] = 30;
    data.ThrustPIDScaleCurve[1] = 15;
    data.ThrustPIDScaleCurve[2] = 0;
    data.ThrustPIDScaleCurve[3] = -15;
    data.ThrustPIDScaleCurve[4] = -30;
    data.ThrustPIDScaleSource = 2;
    data.ThrustPIDScaleTarget = 0;
    data.ThrustPIDScaleAxes = 1;

    StabilizationBankDataOverrideDefaults(&data);
    UAVObjSetInstanceData(obj, instId, &data);

    // Initialize object metadata to their default values
    if ( instId == 0 ) {
        UAVObjMetadata metadata;
        metadata.flags =
            ACCESS_READWRITE << UAVOBJ_ACCESS_SHIFT |
            ACCESS_READWRITE << UAVOBJ_GCS_ACCESS_SHIFT |
            0 << UAVOBJ_TELEMETRY_ACKED_SHIFT |
            0 << UAVOBJ_GCS_TELEMETRY_ACKED_SHIFT |
            UPDATEMODE_PERIODIC << UAVOBJ_TELEMETRY_UPDATE_MODE_SHIFT |
            UPDATEMODE_MANUAL << UAVOBJ_GCS_TELEMETRY_UPDATE_MODE_SHIFT |
            UPDATEMODE_MANUAL << UAVOBJ_LOGGING_UPDATE_MODE_SHIFT;
        metadata.telemetryUpdatePeriod = 1000;
        metadata.gcsTelemetryUpdatePeriod = 0;
        metadata.loggingUpdatePeriod = 0;
        UAVObjSetMetadata(obj, &metadata);
    }
}

/**
 * Get object handle
 */
UAVObjHandle StabilizationBankHandle()
{
    return handle;
}

/**
 * Get/Set object Functions
 */
void StabilizationBankAttitudeFeedForwardSet( StabilizationBankAttitudeFeedForwardData *NewAttitudeFeedForward )
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewAttitudeFeedForward, offsetof(StabilizationBankData, AttitudeFeedForward), 3*sizeof(float));
}
void StabilizationBankAttitudeFeedForwardGet( StabilizationBankAttitudeFeedForwardData *NewAttitudeFeedForward )
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewAttitudeFeedForward, offsetof(StabilizationBankData, AttitudeFeedForward), 3*sizeof(float));
}
void StabilizationBankAttitudeFeedForwardArraySet( float *NewAttitudeFeedForward )
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewAttitudeFeedForward, offsetof(StabilizationBankData, AttitudeFeedForward), 3*sizeof(float));
}
void StabilizationBankAttitudeFeedForwardArrayGet( float *NewAttitudeFeedForward )
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewAttitudeFeedForward, offsetof(StabilizationBankData, AttitudeFeedForward), 3*sizeof(float));
}
void StabilizationBankRollRatePIDSet( StabilizationBankRollRatePIDData *NewRollRatePID )
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewRollRatePID, offsetof(StabilizationBankData, RollRatePID), 4*sizeof(float));
}
void StabilizationBankRollRatePIDGet( StabilizationBankRollRatePIDData *NewRollRatePID )
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewRollRatePID, offsetof(StabilizationBankData, RollRatePID), 4*sizeof(float));
}
void StabilizationBankRollRatePIDArraySet( float *NewRollRatePID )
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewRollRatePID, offsetof(StabilizationBankData, RollRatePID), 4*sizeof(float));
}
void StabilizationBankRollRatePIDArrayGet( float *NewRollRatePID )
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewRollRatePID, offsetof(StabilizationBankData, RollRatePID), 4*sizeof(float));
}
void StabilizationBankPitchRatePIDSet( StabilizationBankPitchRatePIDData *NewPitchRatePID )
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewPitchRatePID, offsetof(StabilizationBankData, PitchRatePID), 4*sizeof(float));
}
void StabilizationBankPitchRatePIDGet( StabilizationBankPitchRatePIDData *NewPitchRatePID )
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewPitchRatePID, offsetof(StabilizationBankData, PitchRatePID), 4*sizeof(float));
}
void StabilizationBankPitchRatePIDArraySet( float *NewPitchRatePID )
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewPitchRatePID, offsetof(StabilizationBankData, PitchRatePID), 4*sizeof(float));
}
void StabilizationBankPitchRatePIDArrayGet( float *NewPitchRatePID )
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewPitchRatePID, offsetof(StabilizationBankData, PitchRatePID), 4*sizeof(float));
}
void StabilizationBankYawRatePIDSet( StabilizationBankYawRatePIDData *NewYawRatePID )
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewYawRatePID, offsetof(StabilizationBankData, YawRatePID), 4*sizeof(float));
}
void StabilizationBankYawRatePIDGet( StabilizationBankYawRatePIDData *NewYawRatePID )
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewYawRatePID, offsetof(StabilizationBankData, YawRatePID), 4*sizeof(float));
}
void StabilizationBankYawRatePIDArraySet( float *NewYawRatePID )
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewYawRatePID, offsetof(StabilizationBankData, YawRatePID), 4*sizeof(float));
}
void StabilizationBankYawRatePIDArrayGet( float *NewYawRatePID )
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewYawRatePID, offsetof(StabilizationBankData, YawRatePID), 4*sizeof(float));
}
void StabilizationBankRollPISet( StabilizationBankRollPIData *NewRollPI )
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewRollPI, offsetof(StabilizationBankData, RollPI), 3*sizeof(float));
}
void StabilizationBankRollPIGet( StabilizationBankRollPIData *NewRollPI )
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewRollPI, offsetof(StabilizationBankData, RollPI), 3*sizeof(float));
}
void StabilizationBankRollPIArraySet( float *NewRollPI )
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewRollPI, offsetof(StabilizationBankData, RollPI), 3*sizeof(float));
}
void StabilizationBankRollPIArrayGet( float *NewRollPI )
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewRollPI, offsetof(StabilizationBankData, RollPI), 3*sizeof(float));
}
void StabilizationBankPitchPISet( StabilizationBankPitchPIData *NewPitchPI )
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewPitchPI, offsetof(StabilizationBankData, PitchPI), 3*sizeof(float));
}
void StabilizationBankPitchPIGet( StabilizationBankPitchPIData *NewPitchPI )
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewPitchPI, offsetof(StabilizationBankData, PitchPI), 3*sizeof(float));
}
void StabilizationBankPitchPIArraySet( float *NewPitchPI )
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewPitchPI, offsetof(StabilizationBankData, PitchPI), 3*sizeof(float));
}
void StabilizationBankPitchPIArrayGet( float *NewPitchPI )
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewPitchPI, offsetof(StabilizationBankData, PitchPI), 3*sizeof(float));
}
void StabilizationBankYawPISet( StabilizationBankYawPIData *NewYawPI )
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewYawPI, offsetof(StabilizationBankData, YawPI), 3*sizeof(float));
}
void StabilizationBankYawPIGet( StabilizationBankYawPIData *NewYawPI )
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewYawPI, offsetof(StabilizationBankData, YawPI), 3*sizeof(float));
}
void StabilizationBankYawPIArraySet( float *NewYawPI )
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewYawPI, offsetof(StabilizationBankData, YawPI), 3*sizeof(float));
}
void StabilizationBankYawPIArrayGet( float *NewYawPI )
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewYawPI, offsetof(StabilizationBankData, YawPI), 3*sizeof(float));
}
void StabilizationBankManualRateSet( StabilizationBankManualRateData *NewManualRate )
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewManualRate, offsetof(StabilizationBankData, ManualRate), 3*sizeof(uint16_t));
}
void StabilizationBankManualRateGet( StabilizationBankManualRateData *NewManualRate )
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewManualRate, offsetof(StabilizationBankData, ManualRate), 3*sizeof(uint16_t));
}
void StabilizationBankManualRateArraySet( uint16_t *NewManualRate )
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewManualRate, offsetof(StabilizationBankData, ManualRate), 3*sizeof(uint16_t));
}
void StabilizationBankManualRateArrayGet( uint16_t *NewManualRate )
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewManualRate, offsetof(StabilizationBankData, ManualRate), 3*sizeof(uint16_t));
}
void StabilizationBankMaximumRateSet( StabilizationBankMaximumRateData *NewMaximumRate )
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewMaximumRate, offsetof(StabilizationBankData, MaximumRate), 3*sizeof(uint16_t));
}
void StabilizationBankMaximumRateGet( StabilizationBankMaximumRateData *NewMaximumRate )
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewMaximumRate, offsetof(StabilizationBankData, MaximumRate), 3*sizeof(uint16_t));
}
void StabilizationBankMaximumRateArraySet( uint16_t *NewMaximumRate )
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewMaximumRate, offsetof(StabilizationBankData, MaximumRate), 3*sizeof(uint16_t));
}
void StabilizationBankMaximumRateArrayGet( uint16_t *NewMaximumRate )
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewMaximumRate, offsetof(StabilizationBankData, MaximumRate), 3*sizeof(uint16_t));
}
void StabilizationBankRollMaxSet(uint8_t *NewRollMax)
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewRollMax, offsetof(StabilizationBankData, RollMax), sizeof(uint8_t));
}
void StabilizationBankRollMaxGet(uint8_t *NewRollMax)
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewRollMax, offsetof(StabilizationBankData, RollMax), sizeof(uint8_t));
}
void StabilizationBankPitchMaxSet(uint8_t *NewPitchMax)
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewPitchMax, offsetof(StabilizationBankData, PitchMax), sizeof(uint8_t));
}
void StabilizationBankPitchMaxGet(uint8_t *NewPitchMax)
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewPitchMax, offsetof(StabilizationBankData, PitchMax), sizeof(uint8_t));
}
void StabilizationBankYawMaxSet(uint8_t *NewYawMax)
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewYawMax, offsetof(StabilizationBankData, YawMax), sizeof(uint8_t));
}
void StabilizationBankYawMaxGet(uint8_t *NewYawMax)
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewYawMax, offsetof(StabilizationBankData, YawMax), sizeof(uint8_t));
}
void StabilizationBankStickExpoSet( StabilizationBankStickExpoData *NewStickExpo )
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewStickExpo, offsetof(StabilizationBankData, StickExpo), 3*sizeof(int8_t));
}
void StabilizationBankStickExpoGet( StabilizationBankStickExpoData *NewStickExpo )
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewStickExpo, offsetof(StabilizationBankData, StickExpo), 3*sizeof(int8_t));
}
void StabilizationBankStickExpoArraySet( int8_t *NewStickExpo )
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewStickExpo, offsetof(StabilizationBankData, StickExpo), 3*sizeof(int8_t));
}
void StabilizationBankStickExpoArrayGet( int8_t *NewStickExpo )
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewStickExpo, offsetof(StabilizationBankData, StickExpo), 3*sizeof(int8_t));
}
void StabilizationBankAcroInsanityFactorSet( StabilizationBankAcroInsanityFactorData *NewAcroInsanityFactor )
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewAcroInsanityFactor, offsetof(StabilizationBankData, AcroInsanityFactor), 3*sizeof(uint8_t));
}
void StabilizationBankAcroInsanityFactorGet( StabilizationBankAcroInsanityFactorData *NewAcroInsanityFactor )
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewAcroInsanityFactor, offsetof(StabilizationBankData, AcroInsanityFactor), 3*sizeof(uint8_t));
}
void StabilizationBankAcroInsanityFactorArraySet( uint8_t *NewAcroInsanityFactor )
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewAcroInsanityFactor, offsetof(StabilizationBankData, AcroInsanityFactor), 3*sizeof(uint8_t));
}
void StabilizationBankAcroInsanityFactorArrayGet( uint8_t *NewAcroInsanityFactor )
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewAcroInsanityFactor, offsetof(StabilizationBankData, AcroInsanityFactor), 3*sizeof(uint8_t));
}
void StabilizationBankEnablePiroCompSet(StabilizationBankEnablePiroCompOptions *NewEnablePiroComp)
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewEnablePiroComp, offsetof(StabilizationBankData, EnablePiroComp), sizeof(StabilizationBankEnablePiroCompOptions));
}
void StabilizationBankEnablePiroCompGet(StabilizationBankEnablePiroCompOptions *NewEnablePiroComp)
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewEnablePiroComp, offsetof(StabilizationBankData, EnablePiroComp), sizeof(StabilizationBankEnablePiroCompOptions));
}
void StabilizationBankFpvCamTiltCompensationSet(uint8_t *NewFpvCamTiltCompensation)
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewFpvCamTiltCompensation, offsetof(StabilizationBankData, FpvCamTiltCompensation), sizeof(uint8_t));
}
void StabilizationBankFpvCamTiltCompensationGet(uint8_t *NewFpvCamTiltCompensation)
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewFpvCamTiltCompensation, offsetof(StabilizationBankData, FpvCamTiltCompensation), sizeof(uint8_t));
}
void StabilizationBankEnableThrustPIDScalingSet(StabilizationBankEnableThrustPIDScalingOptions *NewEnableThrustPIDScaling)
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewEnableThrustPIDScaling, offsetof(StabilizationBankData, EnableThrustPIDScaling), sizeof(StabilizationBankEnableThrustPIDScalingOptions));
}
void StabilizationBankEnableThrustPIDScalingGet(StabilizationBankEnableThrustPIDScalingOptions *NewEnableThrustPIDScaling)
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewEnableThrustPIDScaling, offsetof(StabilizationBankData, EnableThrustPIDScaling), sizeof(StabilizationBankEnableThrustPIDScalingOptions));
}
void StabilizationBankThrustPIDScaleCurveSet( int8_t *NewThrustPIDScaleCurve )
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewThrustPIDScaleCurve, offsetof(StabilizationBankData, ThrustPIDScaleCurve), 5*sizeof(int8_t));
}
void StabilizationBankThrustPIDScaleCurveGet( int8_t *NewThrustPIDScaleCurve )
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewThrustPIDScaleCurve, offsetof(StabilizationBankData, ThrustPIDScaleCurve), 5*sizeof(int8_t));
}
void StabilizationBankThrustPIDScaleSourceSet(StabilizationBankThrustPIDScaleSourceOptions *NewThrustPIDScaleSource)
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewThrustPIDScaleSource, offsetof(StabilizationBankData, ThrustPIDScaleSource), sizeof(StabilizationBankThrustPIDScaleSourceOptions));
}
void StabilizationBankThrustPIDScaleSourceGet(StabilizationBankThrustPIDScaleSourceOptions *NewThrustPIDScaleSource)
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewThrustPIDScaleSource, offsetof(StabilizationBankData, ThrustPIDScaleSource), sizeof(StabilizationBankThrustPIDScaleSourceOptions));
}
void StabilizationBankThrustPIDScaleTargetSet(StabilizationBankThrustPIDScaleTargetOptions *NewThrustPIDScaleTarget)
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewThrustPIDScaleTarget, offsetof(StabilizationBankData, ThrustPIDScaleTarget), sizeof(StabilizationBankThrustPIDScaleTargetOptions));
}
void StabilizationBankThrustPIDScaleTargetGet(StabilizationBankThrustPIDScaleTargetOptions *NewThrustPIDScaleTarget)
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewThrustPIDScaleTarget, offsetof(StabilizationBankData, ThrustPIDScaleTarget), sizeof(StabilizationBankThrustPIDScaleTargetOptions));
}
void StabilizationBankThrustPIDScaleAxesSet(StabilizationBankThrustPIDScaleAxesOptions *NewThrustPIDScaleAxes)
{
    UAVObjSetDataField(StabilizationBankHandle(), (void *)NewThrustPIDScaleAxes, offsetof(StabilizationBankData, ThrustPIDScaleAxes), sizeof(StabilizationBankThrustPIDScaleAxesOptions));
}
void StabilizationBankThrustPIDScaleAxesGet(StabilizationBankThrustPIDScaleAxesOptions *NewThrustPIDScaleAxes)
{
    UAVObjGetDataField(StabilizationBankHandle(), (void *)NewThrustPIDScaleAxes, offsetof(StabilizationBankData, ThrustPIDScaleAxes), sizeof(StabilizationBankThrustPIDScaleAxesOptions));
}


/**
 * @}
 */
