/**
 ******************************************************************************
 * @addtogroup UAVObjects OpenPilot UAVObjects
 * @{
 * @addtogroup MixerStatus MixerStatus
 * @brief Status for the matrix mixer showing the output of each mixer after all scaling
 *
 * Autogenerated files and functions for MixerStatus Object
 *
 * @{
 *
 * @file       mixerstatus.h
 * @author     The OpenPilot Team, http://www.openpilot.org Copyright (C) 2010-2013.
 * @brief      Implementation of the MixerStatus object. This file has been
 *             automatically generated by the UAVObjectGenerator.
 *
 * @note       Object definition file: mixerstatus.xml.
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

#ifndef MIXERSTATUS_H
#define MIXERSTATUS_H
#include <stdbool.h>

/* Object constants */
#define MIXERSTATUS_OBJID 0x354C0F40
#define MIXERSTATUS_ISSINGLEINST 1
#define MIXERSTATUS_ISSETTINGS 0
#define MIXERSTATUS_ISPRIORITY 0
#define MIXERSTATUS_NUMBYTES sizeof(MixerStatusData)

/* Generic interface functions */
int32_t MixerStatusInitialize();
UAVObjHandle MixerStatusHandle();
void MixerStatusSetDefaults(UAVObjHandle obj, uint16_t instId);

/* Field Mixer1 information */

/* Field Mixer2 information */

/* Field Mixer3 information */

/* Field Mixer4 information */

/* Field Mixer5 information */

/* Field Mixer6 information */

/* Field Mixer7 information */

/* Field Mixer8 information */

/* Field Mixer9 information */

/* Field Mixer10 information */

/* Field Mixer11 information */

/* Field Mixer12 information */




/*
 * Packed Object data (unaligned).
 * Should only be used where 4 byte alignment can be guaranteed
 * (eg a single instance on the heap)
 */
typedef struct {
        float Mixer1;
    float Mixer2;
    float Mixer3;
    float Mixer4;
    float Mixer5;
    float Mixer6;
    float Mixer7;
    float Mixer8;
    float Mixer9;
    float Mixer10;
    float Mixer11;
    float Mixer12;

} __attribute__((packed)) MixerStatusDataPacked;

/*
 * Packed Object data.
 * Alignment is forced to 4 bytes so as to avoid the potential for CPU usage faults
 * on Cortex M4F during load/store of float UAVO fields
 */
typedef MixerStatusDataPacked __attribute__((aligned(4))) MixerStatusData;

void MixerStatusDataOverrideDefaults(MixerStatusData * data);

/* Typesafe Object access functions */
static inline int32_t MixerStatusGet(MixerStatusData * dataOut) {
    return UAVObjGetData(MixerStatusHandle(), dataOut);
}
static inline int32_t MixerStatusSet(const MixerStatusData * dataIn) {
    return UAVObjSetData(MixerStatusHandle(), dataIn);
}
static inline int32_t MixerStatusInstGet(uint16_t instId, MixerStatusData * dataOut) {
    return UAVObjGetInstanceData(MixerStatusHandle(), instId, dataOut);
}
static inline int32_t MixerStatusInstSet(uint16_t instId, const MixerStatusData * dataIn) {
    return UAVObjSetInstanceData(MixerStatusHandle(), instId, dataIn);
}
static inline int32_t MixerStatusConnectQueue(xQueueHandle queue) {
    return UAVObjConnectQueue(MixerStatusHandle(), queue, EV_MASK_ALL_UPDATES);
}
static inline int32_t MixerStatusConnectCallback(UAVObjEventCallback cb) {
    return UAVObjConnectCallback(MixerStatusHandle(), cb, EV_MASK_ALL_UPDATES, false);
}
static inline int32_t MixerStatusConnectFastCallback(UAVObjEventCallback cb) {
    return UAVObjConnectCallback(MixerStatusHandle(), cb, EV_MASK_ALL_UPDATES, true);
}
static inline uint16_t MixerStatusCreateInstance() {
    return UAVObjCreateInstance(MixerStatusHandle());
}
static inline void MixerStatusRequestUpdate() {
    UAVObjRequestUpdate(MixerStatusHandle());
}
static inline void MixerStatusRequestInstUpdate(uint16_t instId) {
    UAVObjRequestInstanceUpdate(MixerStatusHandle(), instId);
}
static inline void MixerStatusUpdated() {
    UAVObjUpdated(MixerStatusHandle());
}
static inline void MixerStatusInstUpdated(uint16_t instId) {
    UAVObjInstanceUpdated(MixerStatusHandle(), instId);
}
static inline void MixerStatusLogging() {
    UAVObjLogging(MixerStatusHandle());
}
static inline void MixerStatusInstLogging(uint16_t instId) {
    UAVObjInstanceLogging(MixerStatusHandle(), instId);
}
static inline int32_t MixerStatusGetMetadata(UAVObjMetadata * dataOut) {
    return UAVObjGetMetadata(MixerStatusHandle(), dataOut);
}
static inline int32_t MixerStatusSetMetadata(const UAVObjMetadata * dataIn) {
    return UAVObjSetMetadata(MixerStatusHandle(), dataIn);
}
static inline int8_t MixerStatusReadOnly() {
    return UAVObjReadOnly(MixerStatusHandle());
}

/* Set/Get functions */
extern void MixerStatusMixer1Set(float *NewMixer1);
extern void MixerStatusMixer1Get(float *NewMixer1);
extern void MixerStatusMixer2Set(float *NewMixer2);
extern void MixerStatusMixer2Get(float *NewMixer2);
extern void MixerStatusMixer3Set(float *NewMixer3);
extern void MixerStatusMixer3Get(float *NewMixer3);
extern void MixerStatusMixer4Set(float *NewMixer4);
extern void MixerStatusMixer4Get(float *NewMixer4);
extern void MixerStatusMixer5Set(float *NewMixer5);
extern void MixerStatusMixer5Get(float *NewMixer5);
extern void MixerStatusMixer6Set(float *NewMixer6);
extern void MixerStatusMixer6Get(float *NewMixer6);
extern void MixerStatusMixer7Set(float *NewMixer7);
extern void MixerStatusMixer7Get(float *NewMixer7);
extern void MixerStatusMixer8Set(float *NewMixer8);
extern void MixerStatusMixer8Get(float *NewMixer8);
extern void MixerStatusMixer9Set(float *NewMixer9);
extern void MixerStatusMixer9Get(float *NewMixer9);
extern void MixerStatusMixer10Set(float *NewMixer10);
extern void MixerStatusMixer10Get(float *NewMixer10);
extern void MixerStatusMixer11Set(float *NewMixer11);
extern void MixerStatusMixer11Get(float *NewMixer11);
extern void MixerStatusMixer12Set(float *NewMixer12);
extern void MixerStatusMixer12Get(float *NewMixer12);


#endif // MIXERSTATUS_H

/**
 * @}
 * @}
 */