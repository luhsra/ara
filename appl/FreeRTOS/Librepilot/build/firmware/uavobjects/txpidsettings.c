/**
 ******************************************************************************
 * @addtogroup UAVObjects OpenPilot UAVObjects
 * @{ 
 * @addtogroup TxPIDSettings TxPIDSettings
 * @brief Settings used by @ref TxPID optional module to tune PID settings using R/C transmitter
 *
 * Autogenerated files and functions for TxPIDSettings Object
 * @{ 
 *
 * @file       txpidsettings.c
 * @author     The OpenPilot Team, http://www.openpilot.org Copyright (C) 2010-2013.
 * @brief      Implementation of the TxPIDSettings object. This file has been 
 *             automatically generated by the UAVObjectGenerator.
 * 
 * @note       Object definition file: txpidsettings.xml. 
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
#include "txpidsettings.h"

// Private variables
#if (defined(__MACH__) && defined(__APPLE__))
static UAVObjHandle handle __attribute__((section("__DATA,_uavo_handles")));
#else
static UAVObjHandle handle __attribute__((section("_uavo_handles")));
#endif

#if TXPIDSETTINGS_ISSETTINGS
SETTINGS_INITCALL(TxPIDSettingsInitialize);
#endif

/**
 * Initialize object.
 * \return 0 Success
 * \return -1 Failure to initialize or -2 for already initialized
 */
int32_t TxPIDSettingsInitialize(void)
{
    // Compile time assertion that the TxPIDSettingsDataPacked and TxPIDSettingsData structs
    // have the same size (though instances of TxPIDSettingsData
    // should be placed in memory by the linker/compiler on a 4 byte alignment).
    PIOS_STATIC_ASSERT(sizeof(TxPIDSettingsDataPacked) == sizeof(TxPIDSettingsData));
    
    // Don't set the handle to null if already registered
    if (UAVObjGetByID(TXPIDSETTINGS_OBJID)) {
        return -2;
    }

    static const UAVObjType objType = {
       .id = TXPIDSETTINGS_OBJID,
       .instance_size = TXPIDSETTINGS_NUMBYTES,
       .init_callback = &TxPIDSettingsSetDefaults,
    };

    // Register object with the object manager
    handle = UAVObjRegister(&objType,
        TXPIDSETTINGS_ISSINGLEINST, TXPIDSETTINGS_ISSETTINGS, TXPIDSETTINGS_ISPRIORITY);

    // Done
    return handle ? 0 : -1;
}

static inline void DataOverrideDefaults(__attribute__((unused)) TxPIDSettingsData * data) {}

void TxPIDSettingsDataOverrideDefaults(TxPIDSettingsData * data) __attribute__((weak, alias("DataOverrideDefaults")));

/**
 * Initialize object fields and metadata with the default values.
 * If a default value is not specified the object fields
 * will be initialized to zero.
 */
void TxPIDSettingsSetDefaults(UAVObjHandle obj, uint16_t instId)
{
    TxPIDSettingsData data;

    // Initialize object fields to their default values
    UAVObjGetInstanceData(obj, instId, &data);
    memset(&data, 0, sizeof(TxPIDSettingsData));
    data.ThrottleRange.Min = 2.000000e-01f;
    data.ThrottleRange.Max = 8.000000e-01f;
    data.MinPID.Instance1 = 0.000000e+00f;
    data.MinPID.Instance2 = 0.000000e+00f;
    data.MinPID.Instance3 = 0.000000e+00f;
    data.MaxPID.Instance1 = 0.000000e+00f;
    data.MaxPID.Instance2 = 0.000000e+00f;
    data.MaxPID.Instance3 = 0.000000e+00f;
    data.EasyTunePitchRollRateFactors.I = 3.000000e+00f;
    data.EasyTunePitchRollRateFactors.D = 1.350000e-02f;
    data.EasyTuneYawRateFactors.P = 1.500000e+00f;
    data.EasyTuneYawRateFactors.I = 1.900000e+00f;
    data.EasyTuneYawRateFactors.D = 8.500000e-03f;
    data.UpdateMode = 1;
    data.BankNumber = 0;
    data.Inputs.Instance1 = 0;
    data.Inputs.Instance2 = 1;
    data.Inputs.Instance3 = 2;
    data.PIDs.Instance1 = 0;
    data.PIDs.Instance2 = 0;
    data.PIDs.Instance3 = 0;
    data.EasyTuneRatePIDRecalculateYaw = 1;

    TxPIDSettingsDataOverrideDefaults(&data);
    UAVObjSetInstanceData(obj, instId, &data);

    // Initialize object metadata to their default values
    if ( instId == 0 ) {
        UAVObjMetadata metadata;
        metadata.flags =
            ACCESS_READWRITE << UAVOBJ_ACCESS_SHIFT |
            ACCESS_READWRITE << UAVOBJ_GCS_ACCESS_SHIFT |
            1 << UAVOBJ_TELEMETRY_ACKED_SHIFT |
            1 << UAVOBJ_GCS_TELEMETRY_ACKED_SHIFT |
            UPDATEMODE_ONCHANGE << UAVOBJ_TELEMETRY_UPDATE_MODE_SHIFT |
            UPDATEMODE_ONCHANGE << UAVOBJ_GCS_TELEMETRY_UPDATE_MODE_SHIFT |
            UPDATEMODE_MANUAL << UAVOBJ_LOGGING_UPDATE_MODE_SHIFT;
        metadata.telemetryUpdatePeriod = 0;
        metadata.gcsTelemetryUpdatePeriod = 0;
        metadata.loggingUpdatePeriod = 0;
        UAVObjSetMetadata(obj, &metadata);
    }
}

/**
 * Get object handle
 */
UAVObjHandle TxPIDSettingsHandle()
{
    return handle;
}

/**
 * Get/Set object Functions
 */
void TxPIDSettingsThrottleRangeSet( TxPIDSettingsThrottleRangeData *NewThrottleRange )
{
    UAVObjSetDataField(TxPIDSettingsHandle(), (void *)NewThrottleRange, offsetof(TxPIDSettingsData, ThrottleRange), 2*sizeof(float));
}
void TxPIDSettingsThrottleRangeGet( TxPIDSettingsThrottleRangeData *NewThrottleRange )
{
    UAVObjGetDataField(TxPIDSettingsHandle(), (void *)NewThrottleRange, offsetof(TxPIDSettingsData, ThrottleRange), 2*sizeof(float));
}
void TxPIDSettingsThrottleRangeArraySet( float *NewThrottleRange )
{
    UAVObjSetDataField(TxPIDSettingsHandle(), (void *)NewThrottleRange, offsetof(TxPIDSettingsData, ThrottleRange), 2*sizeof(float));
}
void TxPIDSettingsThrottleRangeArrayGet( float *NewThrottleRange )
{
    UAVObjGetDataField(TxPIDSettingsHandle(), (void *)NewThrottleRange, offsetof(TxPIDSettingsData, ThrottleRange), 2*sizeof(float));
}
void TxPIDSettingsMinPIDSet( TxPIDSettingsMinPIDData *NewMinPID )
{
    UAVObjSetDataField(TxPIDSettingsHandle(), (void *)NewMinPID, offsetof(TxPIDSettingsData, MinPID), 3*sizeof(float));
}
void TxPIDSettingsMinPIDGet( TxPIDSettingsMinPIDData *NewMinPID )
{
    UAVObjGetDataField(TxPIDSettingsHandle(), (void *)NewMinPID, offsetof(TxPIDSettingsData, MinPID), 3*sizeof(float));
}
void TxPIDSettingsMinPIDArraySet( float *NewMinPID )
{
    UAVObjSetDataField(TxPIDSettingsHandle(), (void *)NewMinPID, offsetof(TxPIDSettingsData, MinPID), 3*sizeof(float));
}
void TxPIDSettingsMinPIDArrayGet( float *NewMinPID )
{
    UAVObjGetDataField(TxPIDSettingsHandle(), (void *)NewMinPID, offsetof(TxPIDSettingsData, MinPID), 3*sizeof(float));
}
void TxPIDSettingsMaxPIDSet( TxPIDSettingsMaxPIDData *NewMaxPID )
{
    UAVObjSetDataField(TxPIDSettingsHandle(), (void *)NewMaxPID, offsetof(TxPIDSettingsData, MaxPID), 3*sizeof(float));
}
void TxPIDSettingsMaxPIDGet( TxPIDSettingsMaxPIDData *NewMaxPID )
{
    UAVObjGetDataField(TxPIDSettingsHandle(), (void *)NewMaxPID, offsetof(TxPIDSettingsData, MaxPID), 3*sizeof(float));
}
void TxPIDSettingsMaxPIDArraySet( float *NewMaxPID )
{
    UAVObjSetDataField(TxPIDSettingsHandle(), (void *)NewMaxPID, offsetof(TxPIDSettingsData, MaxPID), 3*sizeof(float));
}
void TxPIDSettingsMaxPIDArrayGet( float *NewMaxPID )
{
    UAVObjGetDataField(TxPIDSettingsHandle(), (void *)NewMaxPID, offsetof(TxPIDSettingsData, MaxPID), 3*sizeof(float));
}
void TxPIDSettingsEasyTunePitchRollRateFactorsSet( TxPIDSettingsEasyTunePitchRollRateFactorsData *NewEasyTunePitchRollRateFactors )
{
    UAVObjSetDataField(TxPIDSettingsHandle(), (void *)NewEasyTunePitchRollRateFactors, offsetof(TxPIDSettingsData, EasyTunePitchRollRateFactors), 2*sizeof(float));
}
void TxPIDSettingsEasyTunePitchRollRateFactorsGet( TxPIDSettingsEasyTunePitchRollRateFactorsData *NewEasyTunePitchRollRateFactors )
{
    UAVObjGetDataField(TxPIDSettingsHandle(), (void *)NewEasyTunePitchRollRateFactors, offsetof(TxPIDSettingsData, EasyTunePitchRollRateFactors), 2*sizeof(float));
}
void TxPIDSettingsEasyTunePitchRollRateFactorsArraySet( float *NewEasyTunePitchRollRateFactors )
{
    UAVObjSetDataField(TxPIDSettingsHandle(), (void *)NewEasyTunePitchRollRateFactors, offsetof(TxPIDSettingsData, EasyTunePitchRollRateFactors), 2*sizeof(float));
}
void TxPIDSettingsEasyTunePitchRollRateFactorsArrayGet( float *NewEasyTunePitchRollRateFactors )
{
    UAVObjGetDataField(TxPIDSettingsHandle(), (void *)NewEasyTunePitchRollRateFactors, offsetof(TxPIDSettingsData, EasyTunePitchRollRateFactors), 2*sizeof(float));
}
void TxPIDSettingsEasyTuneYawRateFactorsSet( TxPIDSettingsEasyTuneYawRateFactorsData *NewEasyTuneYawRateFactors )
{
    UAVObjSetDataField(TxPIDSettingsHandle(), (void *)NewEasyTuneYawRateFactors, offsetof(TxPIDSettingsData, EasyTuneYawRateFactors), 3*sizeof(float));
}
void TxPIDSettingsEasyTuneYawRateFactorsGet( TxPIDSettingsEasyTuneYawRateFactorsData *NewEasyTuneYawRateFactors )
{
    UAVObjGetDataField(TxPIDSettingsHandle(), (void *)NewEasyTuneYawRateFactors, offsetof(TxPIDSettingsData, EasyTuneYawRateFactors), 3*sizeof(float));
}
void TxPIDSettingsEasyTuneYawRateFactorsArraySet( float *NewEasyTuneYawRateFactors )
{
    UAVObjSetDataField(TxPIDSettingsHandle(), (void *)NewEasyTuneYawRateFactors, offsetof(TxPIDSettingsData, EasyTuneYawRateFactors), 3*sizeof(float));
}
void TxPIDSettingsEasyTuneYawRateFactorsArrayGet( float *NewEasyTuneYawRateFactors )
{
    UAVObjGetDataField(TxPIDSettingsHandle(), (void *)NewEasyTuneYawRateFactors, offsetof(TxPIDSettingsData, EasyTuneYawRateFactors), 3*sizeof(float));
}
void TxPIDSettingsUpdateModeSet(TxPIDSettingsUpdateModeOptions *NewUpdateMode)
{
    UAVObjSetDataField(TxPIDSettingsHandle(), (void *)NewUpdateMode, offsetof(TxPIDSettingsData, UpdateMode), sizeof(TxPIDSettingsUpdateModeOptions));
}
void TxPIDSettingsUpdateModeGet(TxPIDSettingsUpdateModeOptions *NewUpdateMode)
{
    UAVObjGetDataField(TxPIDSettingsHandle(), (void *)NewUpdateMode, offsetof(TxPIDSettingsData, UpdateMode), sizeof(TxPIDSettingsUpdateModeOptions));
}
void TxPIDSettingsBankNumberSet(TxPIDSettingsBankNumberOptions *NewBankNumber)
{
    UAVObjSetDataField(TxPIDSettingsHandle(), (void *)NewBankNumber, offsetof(TxPIDSettingsData, BankNumber), sizeof(TxPIDSettingsBankNumberOptions));
}
void TxPIDSettingsBankNumberGet(TxPIDSettingsBankNumberOptions *NewBankNumber)
{
    UAVObjGetDataField(TxPIDSettingsHandle(), (void *)NewBankNumber, offsetof(TxPIDSettingsData, BankNumber), sizeof(TxPIDSettingsBankNumberOptions));
}
void TxPIDSettingsInputsSet( TxPIDSettingsInputsData *NewInputs )
{
    UAVObjSetDataField(TxPIDSettingsHandle(), (void *)NewInputs, offsetof(TxPIDSettingsData, Inputs), 3*sizeof(TxPIDSettingsInputsOptions));
}
void TxPIDSettingsInputsGet( TxPIDSettingsInputsData *NewInputs )
{
    UAVObjGetDataField(TxPIDSettingsHandle(), (void *)NewInputs, offsetof(TxPIDSettingsData, Inputs), 3*sizeof(TxPIDSettingsInputsOptions));
}
void TxPIDSettingsInputsArraySet( TxPIDSettingsInputsOptions *NewInputs )
{
    UAVObjSetDataField(TxPIDSettingsHandle(), (void *)NewInputs, offsetof(TxPIDSettingsData, Inputs), 3*sizeof(TxPIDSettingsInputsOptions));
}
void TxPIDSettingsInputsArrayGet( TxPIDSettingsInputsOptions *NewInputs )
{
    UAVObjGetDataField(TxPIDSettingsHandle(), (void *)NewInputs, offsetof(TxPIDSettingsData, Inputs), 3*sizeof(TxPIDSettingsInputsOptions));
}
void TxPIDSettingsPIDsSet( TxPIDSettingsPIDsData *NewPIDs )
{
    UAVObjSetDataField(TxPIDSettingsHandle(), (void *)NewPIDs, offsetof(TxPIDSettingsData, PIDs), 3*sizeof(TxPIDSettingsPIDsOptions));
}
void TxPIDSettingsPIDsGet( TxPIDSettingsPIDsData *NewPIDs )
{
    UAVObjGetDataField(TxPIDSettingsHandle(), (void *)NewPIDs, offsetof(TxPIDSettingsData, PIDs), 3*sizeof(TxPIDSettingsPIDsOptions));
}
void TxPIDSettingsPIDsArraySet( TxPIDSettingsPIDsOptions *NewPIDs )
{
    UAVObjSetDataField(TxPIDSettingsHandle(), (void *)NewPIDs, offsetof(TxPIDSettingsData, PIDs), 3*sizeof(TxPIDSettingsPIDsOptions));
}
void TxPIDSettingsPIDsArrayGet( TxPIDSettingsPIDsOptions *NewPIDs )
{
    UAVObjGetDataField(TxPIDSettingsHandle(), (void *)NewPIDs, offsetof(TxPIDSettingsData, PIDs), 3*sizeof(TxPIDSettingsPIDsOptions));
}
void TxPIDSettingsEasyTuneRatePIDRecalculateYawSet(TxPIDSettingsEasyTuneRatePIDRecalculateYawOptions *NewEasyTuneRatePIDRecalculateYaw)
{
    UAVObjSetDataField(TxPIDSettingsHandle(), (void *)NewEasyTuneRatePIDRecalculateYaw, offsetof(TxPIDSettingsData, EasyTuneRatePIDRecalculateYaw), sizeof(TxPIDSettingsEasyTuneRatePIDRecalculateYawOptions));
}
void TxPIDSettingsEasyTuneRatePIDRecalculateYawGet(TxPIDSettingsEasyTuneRatePIDRecalculateYawOptions *NewEasyTuneRatePIDRecalculateYaw)
{
    UAVObjGetDataField(TxPIDSettingsHandle(), (void *)NewEasyTuneRatePIDRecalculateYaw, offsetof(TxPIDSettingsData, EasyTuneRatePIDRecalculateYaw), sizeof(TxPIDSettingsEasyTuneRatePIDRecalculateYawOptions));
}


/**
 * @}
 */
