/**
 ******************************************************************************
 * @addtogroup UAVObjects OpenPilot UAVObjects
 * @{
 * @addtogroup StabilizationSettingsBank3 StabilizationSettingsBank3
 * @brief Currently selected PID bank
 *
 * Autogenerated files and functions for StabilizationSettingsBank3 Object
 *
 * @{
 *
 * @file       stabilizationsettingsbank3.h
 * @author     The OpenPilot Team, http://www.openpilot.org Copyright (C) 2010-2013.
 * @brief      Implementation of the StabilizationSettingsBank3 object. This file has been
 *             automatically generated by the UAVObjectGenerator.
 *
 * @note       Object definition file: stabilizationsettingsbank3.xml.
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

#ifndef STABILIZATIONSETTINGSBANK3_H
#define STABILIZATIONSETTINGSBANK3_H
#include <stdbool.h>

/* Object constants */
#define STABILIZATIONSETTINGSBANK3_OBJID 0xAE15335A
#define STABILIZATIONSETTINGSBANK3_ISSINGLEINST 1
#define STABILIZATIONSETTINGSBANK3_ISSETTINGS 1
#define STABILIZATIONSETTINGSBANK3_ISPRIORITY 0
#define STABILIZATIONSETTINGSBANK3_NUMBYTES sizeof(StabilizationSettingsBank3Data)

/* Generic interface functions */
int32_t StabilizationSettingsBank3Initialize();
UAVObjHandle StabilizationSettingsBank3Handle();
void StabilizationSettingsBank3SetDefaults(UAVObjHandle obj, uint16_t instId);

/* Field AttitudeFeedForward information */

// Array element names for field AttitudeFeedForward
typedef enum {
    STABILIZATIONSETTINGSBANK3_ATTITUDEFEEDFORWARD_ROLL=0,
    STABILIZATIONSETTINGSBANK3_ATTITUDEFEEDFORWARD_PITCH=1,
    STABILIZATIONSETTINGSBANK3_ATTITUDEFEEDFORWARD_YAW=2
} StabilizationSettingsBank3AttitudeFeedForwardElem;

// Number of elements for field AttitudeFeedForward
#define STABILIZATIONSETTINGSBANK3_ATTITUDEFEEDFORWARD_NUMELEM 3

/* Field RollRatePID information */

// Array element names for field RollRatePID
typedef enum {
    STABILIZATIONSETTINGSBANK3_ROLLRATEPID_KP=0,
    STABILIZATIONSETTINGSBANK3_ROLLRATEPID_KI=1,
    STABILIZATIONSETTINGSBANK3_ROLLRATEPID_KD=2,
    STABILIZATIONSETTINGSBANK3_ROLLRATEPID_ILIMIT=3
} StabilizationSettingsBank3RollRatePIDElem;

// Number of elements for field RollRatePID
#define STABILIZATIONSETTINGSBANK3_ROLLRATEPID_NUMELEM 4

/* Field PitchRatePID information */

// Array element names for field PitchRatePID
typedef enum {
    STABILIZATIONSETTINGSBANK3_PITCHRATEPID_KP=0,
    STABILIZATIONSETTINGSBANK3_PITCHRATEPID_KI=1,
    STABILIZATIONSETTINGSBANK3_PITCHRATEPID_KD=2,
    STABILIZATIONSETTINGSBANK3_PITCHRATEPID_ILIMIT=3
} StabilizationSettingsBank3PitchRatePIDElem;

// Number of elements for field PitchRatePID
#define STABILIZATIONSETTINGSBANK3_PITCHRATEPID_NUMELEM 4

/* Field YawRatePID information */

// Array element names for field YawRatePID
typedef enum {
    STABILIZATIONSETTINGSBANK3_YAWRATEPID_KP=0,
    STABILIZATIONSETTINGSBANK3_YAWRATEPID_KI=1,
    STABILIZATIONSETTINGSBANK3_YAWRATEPID_KD=2,
    STABILIZATIONSETTINGSBANK3_YAWRATEPID_ILIMIT=3
} StabilizationSettingsBank3YawRatePIDElem;

// Number of elements for field YawRatePID
#define STABILIZATIONSETTINGSBANK3_YAWRATEPID_NUMELEM 4

/* Field RollPI information */

// Array element names for field RollPI
typedef enum {
    STABILIZATIONSETTINGSBANK3_ROLLPI_KP=0,
    STABILIZATIONSETTINGSBANK3_ROLLPI_KI=1,
    STABILIZATIONSETTINGSBANK3_ROLLPI_ILIMIT=2
} StabilizationSettingsBank3RollPIElem;

// Number of elements for field RollPI
#define STABILIZATIONSETTINGSBANK3_ROLLPI_NUMELEM 3

/* Field PitchPI information */

// Array element names for field PitchPI
typedef enum {
    STABILIZATIONSETTINGSBANK3_PITCHPI_KP=0,
    STABILIZATIONSETTINGSBANK3_PITCHPI_KI=1,
    STABILIZATIONSETTINGSBANK3_PITCHPI_ILIMIT=2
} StabilizationSettingsBank3PitchPIElem;

// Number of elements for field PitchPI
#define STABILIZATIONSETTINGSBANK3_PITCHPI_NUMELEM 3

/* Field YawPI information */

// Array element names for field YawPI
typedef enum {
    STABILIZATIONSETTINGSBANK3_YAWPI_KP=0,
    STABILIZATIONSETTINGSBANK3_YAWPI_KI=1,
    STABILIZATIONSETTINGSBANK3_YAWPI_ILIMIT=2
} StabilizationSettingsBank3YawPIElem;

// Number of elements for field YawPI
#define STABILIZATIONSETTINGSBANK3_YAWPI_NUMELEM 3

/* Field ManualRate information */

// Array element names for field ManualRate
typedef enum {
    STABILIZATIONSETTINGSBANK3_MANUALRATE_ROLL=0,
    STABILIZATIONSETTINGSBANK3_MANUALRATE_PITCH=1,
    STABILIZATIONSETTINGSBANK3_MANUALRATE_YAW=2
} StabilizationSettingsBank3ManualRateElem;

// Number of elements for field ManualRate
#define STABILIZATIONSETTINGSBANK3_MANUALRATE_NUMELEM 3

/* Field MaximumRate information */

// Array element names for field MaximumRate
typedef enum {
    STABILIZATIONSETTINGSBANK3_MAXIMUMRATE_ROLL=0,
    STABILIZATIONSETTINGSBANK3_MAXIMUMRATE_PITCH=1,
    STABILIZATIONSETTINGSBANK3_MAXIMUMRATE_YAW=2
} StabilizationSettingsBank3MaximumRateElem;

// Number of elements for field MaximumRate
#define STABILIZATIONSETTINGSBANK3_MAXIMUMRATE_NUMELEM 3

/* Field RollMax information */

/* Field PitchMax information */

/* Field YawMax information */

/* Field StickExpo information */

// Array element names for field StickExpo
typedef enum {
    STABILIZATIONSETTINGSBANK3_STICKEXPO_ROLL=0,
    STABILIZATIONSETTINGSBANK3_STICKEXPO_PITCH=1,
    STABILIZATIONSETTINGSBANK3_STICKEXPO_YAW=2
} StabilizationSettingsBank3StickExpoElem;

// Number of elements for field StickExpo
#define STABILIZATIONSETTINGSBANK3_STICKEXPO_NUMELEM 3

/* Field AcroInsanityFactor information */

// Array element names for field AcroInsanityFactor
typedef enum {
    STABILIZATIONSETTINGSBANK3_ACROINSANITYFACTOR_ROLL=0,
    STABILIZATIONSETTINGSBANK3_ACROINSANITYFACTOR_PITCH=1,
    STABILIZATIONSETTINGSBANK3_ACROINSANITYFACTOR_YAW=2
} StabilizationSettingsBank3AcroInsanityFactorElem;

// Number of elements for field AcroInsanityFactor
#define STABILIZATIONSETTINGSBANK3_ACROINSANITYFACTOR_NUMELEM 3

/* Field EnablePiroComp information */

// Enumeration options for field EnablePiroComp
typedef enum __attribute__ ((__packed__)) {
    STABILIZATIONSETTINGSBANK3_ENABLEPIROCOMP_FALSE=0,
    STABILIZATIONSETTINGSBANK3_ENABLEPIROCOMP_TRUE=1
} StabilizationSettingsBank3EnablePiroCompOptions;

/* Field FpvCamTiltCompensation information */

/* Field EnableThrustPIDScaling information */

// Enumeration options for field EnableThrustPIDScaling
typedef enum __attribute__ ((__packed__)) {
    STABILIZATIONSETTINGSBANK3_ENABLETHRUSTPIDSCALING_FALSE=0,
    STABILIZATIONSETTINGSBANK3_ENABLETHRUSTPIDSCALING_TRUE=1
} StabilizationSettingsBank3EnableThrustPIDScalingOptions;

/* Field ThrustPIDScaleCurve information */

// Array element names for field ThrustPIDScaleCurve
typedef enum {
    STABILIZATIONSETTINGSBANK3_THRUSTPIDSCALECURVE_0=0,
    STABILIZATIONSETTINGSBANK3_THRUSTPIDSCALECURVE_25=1,
    STABILIZATIONSETTINGSBANK3_THRUSTPIDSCALECURVE_50=2,
    STABILIZATIONSETTINGSBANK3_THRUSTPIDSCALECURVE_75=3,
    STABILIZATIONSETTINGSBANK3_THRUSTPIDSCALECURVE_100=4
} StabilizationSettingsBank3ThrustPIDScaleCurveElem;

// Number of elements for field ThrustPIDScaleCurve
#define STABILIZATIONSETTINGSBANK3_THRUSTPIDSCALECURVE_NUMELEM 5

/* Field ThrustPIDScaleSource information */

// Enumeration options for field ThrustPIDScaleSource
typedef enum __attribute__ ((__packed__)) {
    STABILIZATIONSETTINGSBANK3_THRUSTPIDSCALESOURCE_MANUALCONTROLTHROTTLE=0,
    STABILIZATIONSETTINGSBANK3_THRUSTPIDSCALESOURCE_STABILIZATIONDESIREDTHRUST=1,
    STABILIZATIONSETTINGSBANK3_THRUSTPIDSCALESOURCE_ACTUATORDESIREDTHRUST=2
} StabilizationSettingsBank3ThrustPIDScaleSourceOptions;

/* Field ThrustPIDScaleTarget information */

// Enumeration options for field ThrustPIDScaleTarget
typedef enum __attribute__ ((__packed__)) {
    STABILIZATIONSETTINGSBANK3_THRUSTPIDSCALETARGET_PID=0,
    STABILIZATIONSETTINGSBANK3_THRUSTPIDSCALETARGET_PI=1,
    STABILIZATIONSETTINGSBANK3_THRUSTPIDSCALETARGET_PD=2,
    STABILIZATIONSETTINGSBANK3_THRUSTPIDSCALETARGET_ID=3,
    STABILIZATIONSETTINGSBANK3_THRUSTPIDSCALETARGET_P=4,
    STABILIZATIONSETTINGSBANK3_THRUSTPIDSCALETARGET_I=5,
    STABILIZATIONSETTINGSBANK3_THRUSTPIDSCALETARGET_D=6
} StabilizationSettingsBank3ThrustPIDScaleTargetOptions;

/* Field ThrustPIDScaleAxes information */

// Enumeration options for field ThrustPIDScaleAxes
typedef enum __attribute__ ((__packed__)) {
    STABILIZATIONSETTINGSBANK3_THRUSTPIDSCALEAXES_ROLLPITCHYAW=0,
    STABILIZATIONSETTINGSBANK3_THRUSTPIDSCALEAXES_ROLLPITCH=1,
    STABILIZATIONSETTINGSBANK3_THRUSTPIDSCALEAXES_ROLLYAW=2,
    STABILIZATIONSETTINGSBANK3_THRUSTPIDSCALEAXES_ROLL=3,
    STABILIZATIONSETTINGSBANK3_THRUSTPIDSCALEAXES_PITCHYAW=4,
    STABILIZATIONSETTINGSBANK3_THRUSTPIDSCALEAXES_PITCH=5,
    STABILIZATIONSETTINGSBANK3_THRUSTPIDSCALEAXES_YAW=6
} StabilizationSettingsBank3ThrustPIDScaleAxesOptions;



typedef struct __attribute__ ((__packed__)) {
    float Roll;
    float Pitch;
    float Yaw;
}  StabilizationSettingsBank3AttitudeFeedForwardData ;
typedef struct __attribute__ ((__packed__)) {
    float array[3];
}  StabilizationSettingsBank3AttitudeFeedForwardDataArray ;
#define StabilizationSettingsBank3AttitudeFeedForwardToArray( var ) UAVObjectFieldToArray( StabilizationSettingsBank3AttitudeFeedForwardData, var )

typedef struct __attribute__ ((__packed__)) {
    float Kp;
    float Ki;
    float Kd;
    float ILimit;
}  StabilizationSettingsBank3RollRatePIDData ;
typedef struct __attribute__ ((__packed__)) {
    float array[4];
}  StabilizationSettingsBank3RollRatePIDDataArray ;
#define StabilizationSettingsBank3RollRatePIDToArray( var ) UAVObjectFieldToArray( StabilizationSettingsBank3RollRatePIDData, var )

typedef struct __attribute__ ((__packed__)) {
    float Kp;
    float Ki;
    float Kd;
    float ILimit;
}  StabilizationSettingsBank3PitchRatePIDData ;
typedef struct __attribute__ ((__packed__)) {
    float array[4];
}  StabilizationSettingsBank3PitchRatePIDDataArray ;
#define StabilizationSettingsBank3PitchRatePIDToArray( var ) UAVObjectFieldToArray( StabilizationSettingsBank3PitchRatePIDData, var )

typedef struct __attribute__ ((__packed__)) {
    float Kp;
    float Ki;
    float Kd;
    float ILimit;
}  StabilizationSettingsBank3YawRatePIDData ;
typedef struct __attribute__ ((__packed__)) {
    float array[4];
}  StabilizationSettingsBank3YawRatePIDDataArray ;
#define StabilizationSettingsBank3YawRatePIDToArray( var ) UAVObjectFieldToArray( StabilizationSettingsBank3YawRatePIDData, var )

typedef struct __attribute__ ((__packed__)) {
    float Kp;
    float Ki;
    float ILimit;
}  StabilizationSettingsBank3RollPIData ;
typedef struct __attribute__ ((__packed__)) {
    float array[3];
}  StabilizationSettingsBank3RollPIDataArray ;
#define StabilizationSettingsBank3RollPIToArray( var ) UAVObjectFieldToArray( StabilizationSettingsBank3RollPIData, var )

typedef struct __attribute__ ((__packed__)) {
    float Kp;
    float Ki;
    float ILimit;
}  StabilizationSettingsBank3PitchPIData ;
typedef struct __attribute__ ((__packed__)) {
    float array[3];
}  StabilizationSettingsBank3PitchPIDataArray ;
#define StabilizationSettingsBank3PitchPIToArray( var ) UAVObjectFieldToArray( StabilizationSettingsBank3PitchPIData, var )

typedef struct __attribute__ ((__packed__)) {
    float Kp;
    float Ki;
    float ILimit;
}  StabilizationSettingsBank3YawPIData ;
typedef struct __attribute__ ((__packed__)) {
    float array[3];
}  StabilizationSettingsBank3YawPIDataArray ;
#define StabilizationSettingsBank3YawPIToArray( var ) UAVObjectFieldToArray( StabilizationSettingsBank3YawPIData, var )

typedef struct __attribute__ ((__packed__)) {
    uint16_t Roll;
    uint16_t Pitch;
    uint16_t Yaw;
}  StabilizationSettingsBank3ManualRateData ;
typedef struct __attribute__ ((__packed__)) {
    uint16_t array[3];
}  StabilizationSettingsBank3ManualRateDataArray ;
#define StabilizationSettingsBank3ManualRateToArray( var ) UAVObjectFieldToArray( StabilizationSettingsBank3ManualRateData, var )

typedef struct __attribute__ ((__packed__)) {
    uint16_t Roll;
    uint16_t Pitch;
    uint16_t Yaw;
}  StabilizationSettingsBank3MaximumRateData ;
typedef struct __attribute__ ((__packed__)) {
    uint16_t array[3];
}  StabilizationSettingsBank3MaximumRateDataArray ;
#define StabilizationSettingsBank3MaximumRateToArray( var ) UAVObjectFieldToArray( StabilizationSettingsBank3MaximumRateData, var )

typedef struct __attribute__ ((__packed__)) {
    int8_t Roll;
    int8_t Pitch;
    int8_t Yaw;
}  StabilizationSettingsBank3StickExpoData ;
typedef struct __attribute__ ((__packed__)) {
    int8_t array[3];
}  StabilizationSettingsBank3StickExpoDataArray ;
#define StabilizationSettingsBank3StickExpoToArray( var ) UAVObjectFieldToArray( StabilizationSettingsBank3StickExpoData, var )

typedef struct __attribute__ ((__packed__)) {
    uint8_t Roll;
    uint8_t Pitch;
    uint8_t Yaw;
}  StabilizationSettingsBank3AcroInsanityFactorData ;
typedef struct __attribute__ ((__packed__)) {
    uint8_t array[3];
}  StabilizationSettingsBank3AcroInsanityFactorDataArray ;
#define StabilizationSettingsBank3AcroInsanityFactorToArray( var ) UAVObjectFieldToArray( StabilizationSettingsBank3AcroInsanityFactorData, var )


/*
 * Packed Object data (unaligned).
 * Should only be used where 4 byte alignment can be guaranteed
 * (eg a single instance on the heap)
 */
typedef struct {
        StabilizationSettingsBank3AttitudeFeedForwardData AttitudeFeedForward;
    StabilizationSettingsBank3RollRatePIDData RollRatePID;
    StabilizationSettingsBank3PitchRatePIDData PitchRatePID;
    StabilizationSettingsBank3YawRatePIDData YawRatePID;
    StabilizationSettingsBank3RollPIData RollPI;
    StabilizationSettingsBank3PitchPIData PitchPI;
    StabilizationSettingsBank3YawPIData YawPI;
    StabilizationSettingsBank3ManualRateData ManualRate;
    StabilizationSettingsBank3MaximumRateData MaximumRate;
    uint8_t RollMax;
    uint8_t PitchMax;
    uint8_t YawMax;
    StabilizationSettingsBank3StickExpoData StickExpo;
    StabilizationSettingsBank3AcroInsanityFactorData AcroInsanityFactor;
    StabilizationSettingsBank3EnablePiroCompOptions EnablePiroComp;
    uint8_t FpvCamTiltCompensation;
    StabilizationSettingsBank3EnableThrustPIDScalingOptions EnableThrustPIDScaling;
    int8_t ThrustPIDScaleCurve[5];
    StabilizationSettingsBank3ThrustPIDScaleSourceOptions ThrustPIDScaleSource;
    StabilizationSettingsBank3ThrustPIDScaleTargetOptions ThrustPIDScaleTarget;
    StabilizationSettingsBank3ThrustPIDScaleAxesOptions ThrustPIDScaleAxes;

} __attribute__((packed)) StabilizationSettingsBank3DataPacked;

/*
 * Packed Object data.
 * Alignment is forced to 4 bytes so as to avoid the potential for CPU usage faults
 * on Cortex M4F during load/store of float UAVO fields
 */
typedef StabilizationSettingsBank3DataPacked __attribute__((aligned(4))) StabilizationSettingsBank3Data;

void StabilizationSettingsBank3DataOverrideDefaults(StabilizationSettingsBank3Data * data);

/* Typesafe Object access functions */
static inline int32_t StabilizationSettingsBank3Get(StabilizationSettingsBank3Data * dataOut) {
    return UAVObjGetData(StabilizationSettingsBank3Handle(), dataOut);
}
static inline int32_t StabilizationSettingsBank3Set(const StabilizationSettingsBank3Data * dataIn) {
    return UAVObjSetData(StabilizationSettingsBank3Handle(), dataIn);
}
static inline int32_t StabilizationSettingsBank3InstGet(uint16_t instId, StabilizationSettingsBank3Data * dataOut) {
    return UAVObjGetInstanceData(StabilizationSettingsBank3Handle(), instId, dataOut);
}
static inline int32_t StabilizationSettingsBank3InstSet(uint16_t instId, const StabilizationSettingsBank3Data * dataIn) {
    return UAVObjSetInstanceData(StabilizationSettingsBank3Handle(), instId, dataIn);
}
static inline int32_t StabilizationSettingsBank3ConnectQueue(xQueueHandle queue) {
    return UAVObjConnectQueue(StabilizationSettingsBank3Handle(), queue, EV_MASK_ALL_UPDATES);
}
static inline int32_t StabilizationSettingsBank3ConnectCallback(UAVObjEventCallback cb) {
    return UAVObjConnectCallback(StabilizationSettingsBank3Handle(), cb, EV_MASK_ALL_UPDATES, false);
}
static inline int32_t StabilizationSettingsBank3ConnectFastCallback(UAVObjEventCallback cb) {
    return UAVObjConnectCallback(StabilizationSettingsBank3Handle(), cb, EV_MASK_ALL_UPDATES, true);
}
static inline uint16_t StabilizationSettingsBank3CreateInstance() {
    return UAVObjCreateInstance(StabilizationSettingsBank3Handle());
}
static inline void StabilizationSettingsBank3RequestUpdate() {
    UAVObjRequestUpdate(StabilizationSettingsBank3Handle());
}
static inline void StabilizationSettingsBank3RequestInstUpdate(uint16_t instId) {
    UAVObjRequestInstanceUpdate(StabilizationSettingsBank3Handle(), instId);
}
static inline void StabilizationSettingsBank3Updated() {
    UAVObjUpdated(StabilizationSettingsBank3Handle());
}
static inline void StabilizationSettingsBank3InstUpdated(uint16_t instId) {
    UAVObjInstanceUpdated(StabilizationSettingsBank3Handle(), instId);
}
static inline void StabilizationSettingsBank3Logging() {
    UAVObjLogging(StabilizationSettingsBank3Handle());
}
static inline void StabilizationSettingsBank3InstLogging(uint16_t instId) {
    UAVObjInstanceLogging(StabilizationSettingsBank3Handle(), instId);
}
static inline int32_t StabilizationSettingsBank3GetMetadata(UAVObjMetadata * dataOut) {
    return UAVObjGetMetadata(StabilizationSettingsBank3Handle(), dataOut);
}
static inline int32_t StabilizationSettingsBank3SetMetadata(const UAVObjMetadata * dataIn) {
    return UAVObjSetMetadata(StabilizationSettingsBank3Handle(), dataIn);
}
static inline int8_t StabilizationSettingsBank3ReadOnly() {
    return UAVObjReadOnly(StabilizationSettingsBank3Handle());
}

/* Set/Get functions */
extern void StabilizationSettingsBank3AttitudeFeedForwardSet(StabilizationSettingsBank3AttitudeFeedForwardData *NewAttitudeFeedForward);
extern void StabilizationSettingsBank3AttitudeFeedForwardGet(StabilizationSettingsBank3AttitudeFeedForwardData *NewAttitudeFeedForward);
extern void StabilizationSettingsBank3AttitudeFeedForwardArraySet(float *NewAttitudeFeedForward);
extern void StabilizationSettingsBank3AttitudeFeedForwardArrayGet(float *NewAttitudeFeedForward);
extern void StabilizationSettingsBank3RollRatePIDSet(StabilizationSettingsBank3RollRatePIDData *NewRollRatePID);
extern void StabilizationSettingsBank3RollRatePIDGet(StabilizationSettingsBank3RollRatePIDData *NewRollRatePID);
extern void StabilizationSettingsBank3RollRatePIDArraySet(float *NewRollRatePID);
extern void StabilizationSettingsBank3RollRatePIDArrayGet(float *NewRollRatePID);
extern void StabilizationSettingsBank3PitchRatePIDSet(StabilizationSettingsBank3PitchRatePIDData *NewPitchRatePID);
extern void StabilizationSettingsBank3PitchRatePIDGet(StabilizationSettingsBank3PitchRatePIDData *NewPitchRatePID);
extern void StabilizationSettingsBank3PitchRatePIDArraySet(float *NewPitchRatePID);
extern void StabilizationSettingsBank3PitchRatePIDArrayGet(float *NewPitchRatePID);
extern void StabilizationSettingsBank3YawRatePIDSet(StabilizationSettingsBank3YawRatePIDData *NewYawRatePID);
extern void StabilizationSettingsBank3YawRatePIDGet(StabilizationSettingsBank3YawRatePIDData *NewYawRatePID);
extern void StabilizationSettingsBank3YawRatePIDArraySet(float *NewYawRatePID);
extern void StabilizationSettingsBank3YawRatePIDArrayGet(float *NewYawRatePID);
extern void StabilizationSettingsBank3RollPISet(StabilizationSettingsBank3RollPIData *NewRollPI);
extern void StabilizationSettingsBank3RollPIGet(StabilizationSettingsBank3RollPIData *NewRollPI);
extern void StabilizationSettingsBank3RollPIArraySet(float *NewRollPI);
extern void StabilizationSettingsBank3RollPIArrayGet(float *NewRollPI);
extern void StabilizationSettingsBank3PitchPISet(StabilizationSettingsBank3PitchPIData *NewPitchPI);
extern void StabilizationSettingsBank3PitchPIGet(StabilizationSettingsBank3PitchPIData *NewPitchPI);
extern void StabilizationSettingsBank3PitchPIArraySet(float *NewPitchPI);
extern void StabilizationSettingsBank3PitchPIArrayGet(float *NewPitchPI);
extern void StabilizationSettingsBank3YawPISet(StabilizationSettingsBank3YawPIData *NewYawPI);
extern void StabilizationSettingsBank3YawPIGet(StabilizationSettingsBank3YawPIData *NewYawPI);
extern void StabilizationSettingsBank3YawPIArraySet(float *NewYawPI);
extern void StabilizationSettingsBank3YawPIArrayGet(float *NewYawPI);
extern void StabilizationSettingsBank3ManualRateSet(StabilizationSettingsBank3ManualRateData *NewManualRate);
extern void StabilizationSettingsBank3ManualRateGet(StabilizationSettingsBank3ManualRateData *NewManualRate);
extern void StabilizationSettingsBank3ManualRateArraySet(uint16_t *NewManualRate);
extern void StabilizationSettingsBank3ManualRateArrayGet(uint16_t *NewManualRate);
extern void StabilizationSettingsBank3MaximumRateSet(StabilizationSettingsBank3MaximumRateData *NewMaximumRate);
extern void StabilizationSettingsBank3MaximumRateGet(StabilizationSettingsBank3MaximumRateData *NewMaximumRate);
extern void StabilizationSettingsBank3MaximumRateArraySet(uint16_t *NewMaximumRate);
extern void StabilizationSettingsBank3MaximumRateArrayGet(uint16_t *NewMaximumRate);
extern void StabilizationSettingsBank3RollMaxSet(uint8_t *NewRollMax);
extern void StabilizationSettingsBank3RollMaxGet(uint8_t *NewRollMax);
extern void StabilizationSettingsBank3PitchMaxSet(uint8_t *NewPitchMax);
extern void StabilizationSettingsBank3PitchMaxGet(uint8_t *NewPitchMax);
extern void StabilizationSettingsBank3YawMaxSet(uint8_t *NewYawMax);
extern void StabilizationSettingsBank3YawMaxGet(uint8_t *NewYawMax);
extern void StabilizationSettingsBank3StickExpoSet(StabilizationSettingsBank3StickExpoData *NewStickExpo);
extern void StabilizationSettingsBank3StickExpoGet(StabilizationSettingsBank3StickExpoData *NewStickExpo);
extern void StabilizationSettingsBank3StickExpoArraySet(int8_t *NewStickExpo);
extern void StabilizationSettingsBank3StickExpoArrayGet(int8_t *NewStickExpo);
extern void StabilizationSettingsBank3AcroInsanityFactorSet(StabilizationSettingsBank3AcroInsanityFactorData *NewAcroInsanityFactor);
extern void StabilizationSettingsBank3AcroInsanityFactorGet(StabilizationSettingsBank3AcroInsanityFactorData *NewAcroInsanityFactor);
extern void StabilizationSettingsBank3AcroInsanityFactorArraySet(uint8_t *NewAcroInsanityFactor);
extern void StabilizationSettingsBank3AcroInsanityFactorArrayGet(uint8_t *NewAcroInsanityFactor);
extern void StabilizationSettingsBank3EnablePiroCompSet(StabilizationSettingsBank3EnablePiroCompOptions *NewEnablePiroComp);
extern void StabilizationSettingsBank3EnablePiroCompGet(StabilizationSettingsBank3EnablePiroCompOptions *NewEnablePiroComp);
extern void StabilizationSettingsBank3FpvCamTiltCompensationSet(uint8_t *NewFpvCamTiltCompensation);
extern void StabilizationSettingsBank3FpvCamTiltCompensationGet(uint8_t *NewFpvCamTiltCompensation);
extern void StabilizationSettingsBank3EnableThrustPIDScalingSet(StabilizationSettingsBank3EnableThrustPIDScalingOptions *NewEnableThrustPIDScaling);
extern void StabilizationSettingsBank3EnableThrustPIDScalingGet(StabilizationSettingsBank3EnableThrustPIDScalingOptions *NewEnableThrustPIDScaling);
extern void StabilizationSettingsBank3ThrustPIDScaleCurveSet(int8_t *NewThrustPIDScaleCurve);
extern void StabilizationSettingsBank3ThrustPIDScaleCurveGet(int8_t *NewThrustPIDScaleCurve);
extern void StabilizationSettingsBank3ThrustPIDScaleSourceSet(StabilizationSettingsBank3ThrustPIDScaleSourceOptions *NewThrustPIDScaleSource);
extern void StabilizationSettingsBank3ThrustPIDScaleSourceGet(StabilizationSettingsBank3ThrustPIDScaleSourceOptions *NewThrustPIDScaleSource);
extern void StabilizationSettingsBank3ThrustPIDScaleTargetSet(StabilizationSettingsBank3ThrustPIDScaleTargetOptions *NewThrustPIDScaleTarget);
extern void StabilizationSettingsBank3ThrustPIDScaleTargetGet(StabilizationSettingsBank3ThrustPIDScaleTargetOptions *NewThrustPIDScaleTarget);
extern void StabilizationSettingsBank3ThrustPIDScaleAxesSet(StabilizationSettingsBank3ThrustPIDScaleAxesOptions *NewThrustPIDScaleAxes);
extern void StabilizationSettingsBank3ThrustPIDScaleAxesGet(StabilizationSettingsBank3ThrustPIDScaleAxesOptions *NewThrustPIDScaleAxes);


#endif // STABILIZATIONSETTINGSBANK3_H

/**
 * @}
 * @}
 */
