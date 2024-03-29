/**
 ******************************************************************************
 * @addtogroup UAVObjects OpenPilot UAVObjects
 * @{
 * @addtogroup CameraDesired CameraDesired
 * @brief Desired camera outputs.  Comes from @ref CameraStabilization module.
 *
 * Autogenerated files and functions for CameraDesired Object
 *
 * @{
 *
 * @file       cameradesired.h
 * @author     The OpenPilot Team, http://www.openpilot.org Copyright (C) 2010-2013.
 * @brief      Implementation of the CameraDesired object. This file has been
 *             automatically generated by the UAVObjectGenerator.
 *
 * @note       Object definition file: cameradesired.xml.
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

#ifndef CAMERADESIRED_H
#define CAMERADESIRED_H
#include <stdbool.h>

/* Object constants */
#define CAMERADESIRED_OBJID 0x6DFEE41E
#define CAMERADESIRED_ISSINGLEINST 1
#define CAMERADESIRED_ISSETTINGS 0
#define CAMERADESIRED_ISPRIORITY 0
#define CAMERADESIRED_NUMBYTES sizeof(CameraDesiredData)

/* Generic interface functions */
int32_t CameraDesiredInitialize();
UAVObjHandle CameraDesiredHandle();
void CameraDesiredSetDefaults(UAVObjHandle obj, uint16_t instId);

/* Field RollOrServo1 information */

/* Field PitchOrServo2 information */

/* Field Yaw information */

/* Field Trigger information */




/*
 * Packed Object data (unaligned).
 * Should only be used where 4 byte alignment can be guaranteed
 * (eg a single instance on the heap)
 */
typedef struct {
        float RollOrServo1;
    float PitchOrServo2;
    float Yaw;
    float Trigger;

} __attribute__((packed)) CameraDesiredDataPacked;

/*
 * Packed Object data.
 * Alignment is forced to 4 bytes so as to avoid the potential for CPU usage faults
 * on Cortex M4F during load/store of float UAVO fields
 */
typedef CameraDesiredDataPacked __attribute__((aligned(4))) CameraDesiredData;

void CameraDesiredDataOverrideDefaults(CameraDesiredData * data);

/* Typesafe Object access functions */
static inline int32_t CameraDesiredGet(CameraDesiredData * dataOut) {
    return UAVObjGetData(CameraDesiredHandle(), dataOut);
}
static inline int32_t CameraDesiredSet(const CameraDesiredData * dataIn) {
    return UAVObjSetData(CameraDesiredHandle(), dataIn);
}
static inline int32_t CameraDesiredInstGet(uint16_t instId, CameraDesiredData * dataOut) {
    return UAVObjGetInstanceData(CameraDesiredHandle(), instId, dataOut);
}
static inline int32_t CameraDesiredInstSet(uint16_t instId, const CameraDesiredData * dataIn) {
    return UAVObjSetInstanceData(CameraDesiredHandle(), instId, dataIn);
}
static inline int32_t CameraDesiredConnectQueue(xQueueHandle queue) {
    return UAVObjConnectQueue(CameraDesiredHandle(), queue, EV_MASK_ALL_UPDATES);
}
static inline int32_t CameraDesiredConnectCallback(UAVObjEventCallback cb) {
    return UAVObjConnectCallback(CameraDesiredHandle(), cb, EV_MASK_ALL_UPDATES, false);
}
static inline int32_t CameraDesiredConnectFastCallback(UAVObjEventCallback cb) {
    return UAVObjConnectCallback(CameraDesiredHandle(), cb, EV_MASK_ALL_UPDATES, true);
}
static inline uint16_t CameraDesiredCreateInstance() {
    return UAVObjCreateInstance(CameraDesiredHandle());
}
static inline void CameraDesiredRequestUpdate() {
    UAVObjRequestUpdate(CameraDesiredHandle());
}
static inline void CameraDesiredRequestInstUpdate(uint16_t instId) {
    UAVObjRequestInstanceUpdate(CameraDesiredHandle(), instId);
}
static inline void CameraDesiredUpdated() {
    UAVObjUpdated(CameraDesiredHandle());
}
static inline void CameraDesiredInstUpdated(uint16_t instId) {
    UAVObjInstanceUpdated(CameraDesiredHandle(), instId);
}
static inline void CameraDesiredLogging() {
    UAVObjLogging(CameraDesiredHandle());
}
static inline void CameraDesiredInstLogging(uint16_t instId) {
    UAVObjInstanceLogging(CameraDesiredHandle(), instId);
}
static inline int32_t CameraDesiredGetMetadata(UAVObjMetadata * dataOut) {
    return UAVObjGetMetadata(CameraDesiredHandle(), dataOut);
}
static inline int32_t CameraDesiredSetMetadata(const UAVObjMetadata * dataIn) {
    return UAVObjSetMetadata(CameraDesiredHandle(), dataIn);
}
static inline int8_t CameraDesiredReadOnly() {
    return UAVObjReadOnly(CameraDesiredHandle());
}

/* Set/Get functions */
extern void CameraDesiredRollOrServo1Set(float *NewRollOrServo1);
extern void CameraDesiredRollOrServo1Get(float *NewRollOrServo1);
extern void CameraDesiredPitchOrServo2Set(float *NewPitchOrServo2);
extern void CameraDesiredPitchOrServo2Get(float *NewPitchOrServo2);
extern void CameraDesiredYawSet(float *NewYaw);
extern void CameraDesiredYawGet(float *NewYaw);
extern void CameraDesiredTriggerSet(float *NewTrigger);
extern void CameraDesiredTriggerGet(float *NewTrigger);


#endif // CAMERADESIRED_H

/**
 * @}
 * @}
 */
