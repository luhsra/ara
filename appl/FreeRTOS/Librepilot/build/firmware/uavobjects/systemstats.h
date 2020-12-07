/**
 ******************************************************************************
 * @addtogroup UAVObjects OpenPilot UAVObjects
 * @{
 * @addtogroup SystemStats SystemStats
 * @brief CPU and memory usage from OpenPilot computer. 
 *
 * Autogenerated files and functions for SystemStats Object
 *
 * @{
 *
 * @file       systemstats.h
 * @author     The OpenPilot Team, http://www.openpilot.org Copyright (C) 2010-2013.
 * @brief      Implementation of the SystemStats object. This file has been
 *             automatically generated by the UAVObjectGenerator.
 *
 * @note       Object definition file: systemstats.xml.
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

#ifndef SYSTEMSTATS_H
#define SYSTEMSTATS_H
#include <stdbool.h>

/* Object constants */
#define SYSTEMSTATS_OBJID 0xF1EC270E
#define SYSTEMSTATS_ISSINGLEINST 1
#define SYSTEMSTATS_ISSETTINGS 0
#define SYSTEMSTATS_ISPRIORITY 0
#define SYSTEMSTATS_NUMBYTES sizeof(SystemStatsData)

/* Generic interface functions */
int32_t SystemStatsInitialize();
UAVObjHandle SystemStatsHandle();
void SystemStatsSetDefaults(UAVObjHandle obj, uint16_t instId);

/* Field FlightTime information */

/* Field HeapRemaining information */

/* Field CPUIdleTicks information */

/* Field CPUZeroLoadTicks information */

/* Field EventSystemWarningID information */

/* Field ObjectManagerCallbackID information */

/* Field ObjectManagerQueueID information */

/* Field IRQStackRemaining information */

/* Field SystemModStackRemaining information */

/* Field SysSlotsFree information */

/* Field SysSlotsActive information */

/* Field UsrSlotsFree information */

/* Field UsrSlotsActive information */

/* Field CPULoad information */

/* Field CPUTemp information */




/*
 * Packed Object data (unaligned).
 * Should only be used where 4 byte alignment can be guaranteed
 * (eg a single instance on the heap)
 */
typedef struct {
        uint32_t FlightTime;
    uint32_t HeapRemaining;
    uint32_t CPUIdleTicks;
    uint32_t CPUZeroLoadTicks;
    uint32_t EventSystemWarningID;
    uint32_t ObjectManagerCallbackID;
    uint32_t ObjectManagerQueueID;
    uint16_t IRQStackRemaining;
    uint16_t SystemModStackRemaining;
    uint16_t SysSlotsFree;
    uint16_t SysSlotsActive;
    uint16_t UsrSlotsFree;
    uint16_t UsrSlotsActive;
    uint8_t CPULoad;
    int8_t CPUTemp;

} __attribute__((packed)) SystemStatsDataPacked;

/*
 * Packed Object data.
 * Alignment is forced to 4 bytes so as to avoid the potential for CPU usage faults
 * on Cortex M4F during load/store of float UAVO fields
 */
typedef SystemStatsDataPacked __attribute__((aligned(4))) SystemStatsData;

void SystemStatsDataOverrideDefaults(SystemStatsData * data);

/* Typesafe Object access functions */
static inline int32_t SystemStatsGet(SystemStatsData * dataOut) {
    return UAVObjGetData(SystemStatsHandle(), dataOut);
}
static inline int32_t SystemStatsSet(const SystemStatsData * dataIn) {
    return UAVObjSetData(SystemStatsHandle(), dataIn);
}
static inline int32_t SystemStatsInstGet(uint16_t instId, SystemStatsData * dataOut) {
    return UAVObjGetInstanceData(SystemStatsHandle(), instId, dataOut);
}
static inline int32_t SystemStatsInstSet(uint16_t instId, const SystemStatsData * dataIn) {
    return UAVObjSetInstanceData(SystemStatsHandle(), instId, dataIn);
}
static inline int32_t SystemStatsConnectQueue(xQueueHandle queue) {
    return UAVObjConnectQueue(SystemStatsHandle(), queue, EV_MASK_ALL_UPDATES);
}
static inline int32_t SystemStatsConnectCallback(UAVObjEventCallback cb) {
    return UAVObjConnectCallback(SystemStatsHandle(), cb, EV_MASK_ALL_UPDATES, false);
}
static inline int32_t SystemStatsConnectFastCallback(UAVObjEventCallback cb) {
    return UAVObjConnectCallback(SystemStatsHandle(), cb, EV_MASK_ALL_UPDATES, true);
}
static inline uint16_t SystemStatsCreateInstance() {
    return UAVObjCreateInstance(SystemStatsHandle());
}
static inline void SystemStatsRequestUpdate() {
    UAVObjRequestUpdate(SystemStatsHandle());
}
static inline void SystemStatsRequestInstUpdate(uint16_t instId) {
    UAVObjRequestInstanceUpdate(SystemStatsHandle(), instId);
}
static inline void SystemStatsUpdated() {
    UAVObjUpdated(SystemStatsHandle());
}
static inline void SystemStatsInstUpdated(uint16_t instId) {
    UAVObjInstanceUpdated(SystemStatsHandle(), instId);
}
static inline void SystemStatsLogging() {
    UAVObjLogging(SystemStatsHandle());
}
static inline void SystemStatsInstLogging(uint16_t instId) {
    UAVObjInstanceLogging(SystemStatsHandle(), instId);
}
static inline int32_t SystemStatsGetMetadata(UAVObjMetadata * dataOut) {
    return UAVObjGetMetadata(SystemStatsHandle(), dataOut);
}
static inline int32_t SystemStatsSetMetadata(const UAVObjMetadata * dataIn) {
    return UAVObjSetMetadata(SystemStatsHandle(), dataIn);
}
static inline int8_t SystemStatsReadOnly() {
    return UAVObjReadOnly(SystemStatsHandle());
}

/* Set/Get functions */
extern void SystemStatsFlightTimeSet(uint32_t *NewFlightTime);
extern void SystemStatsFlightTimeGet(uint32_t *NewFlightTime);
extern void SystemStatsHeapRemainingSet(uint32_t *NewHeapRemaining);
extern void SystemStatsHeapRemainingGet(uint32_t *NewHeapRemaining);
extern void SystemStatsCPUIdleTicksSet(uint32_t *NewCPUIdleTicks);
extern void SystemStatsCPUIdleTicksGet(uint32_t *NewCPUIdleTicks);
extern void SystemStatsCPUZeroLoadTicksSet(uint32_t *NewCPUZeroLoadTicks);
extern void SystemStatsCPUZeroLoadTicksGet(uint32_t *NewCPUZeroLoadTicks);
extern void SystemStatsEventSystemWarningIDSet(uint32_t *NewEventSystemWarningID);
extern void SystemStatsEventSystemWarningIDGet(uint32_t *NewEventSystemWarningID);
extern void SystemStatsObjectManagerCallbackIDSet(uint32_t *NewObjectManagerCallbackID);
extern void SystemStatsObjectManagerCallbackIDGet(uint32_t *NewObjectManagerCallbackID);
extern void SystemStatsObjectManagerQueueIDSet(uint32_t *NewObjectManagerQueueID);
extern void SystemStatsObjectManagerQueueIDGet(uint32_t *NewObjectManagerQueueID);
extern void SystemStatsIRQStackRemainingSet(uint16_t *NewIRQStackRemaining);
extern void SystemStatsIRQStackRemainingGet(uint16_t *NewIRQStackRemaining);
extern void SystemStatsSystemModStackRemainingSet(uint16_t *NewSystemModStackRemaining);
extern void SystemStatsSystemModStackRemainingGet(uint16_t *NewSystemModStackRemaining);
extern void SystemStatsSysSlotsFreeSet(uint16_t *NewSysSlotsFree);
extern void SystemStatsSysSlotsFreeGet(uint16_t *NewSysSlotsFree);
extern void SystemStatsSysSlotsActiveSet(uint16_t *NewSysSlotsActive);
extern void SystemStatsSysSlotsActiveGet(uint16_t *NewSysSlotsActive);
extern void SystemStatsUsrSlotsFreeSet(uint16_t *NewUsrSlotsFree);
extern void SystemStatsUsrSlotsFreeGet(uint16_t *NewUsrSlotsFree);
extern void SystemStatsUsrSlotsActiveSet(uint16_t *NewUsrSlotsActive);
extern void SystemStatsUsrSlotsActiveGet(uint16_t *NewUsrSlotsActive);
extern void SystemStatsCPULoadSet(uint8_t *NewCPULoad);
extern void SystemStatsCPULoadGet(uint8_t *NewCPULoad);
extern void SystemStatsCPUTempSet(int8_t *NewCPUTemp);
extern void SystemStatsCPUTempGet(int8_t *NewCPUTemp);


#endif // SYSTEMSTATS_H

/**
 * @}
 * @}
 */
