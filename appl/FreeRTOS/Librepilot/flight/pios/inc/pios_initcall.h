/**
 ******************************************************************************
 * @addtogroup PIOS PIOS Initcall infrastructure
 * @{
 * @addtogroup   PIOS_INITCALL Generic Initcall Macros
 * @brief Initcall Macros
 * @{
 *
 * @file       pios_initcall.h
 * @author     The LibrePilot Project, http://www.librepilot.org Copyright (C) 2015.
 *             The OpenPilot Team, http://www.openpilot.org Copyright (C) 2010-2015
 * @brief      Initcall header
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

#ifndef PIOS_INITCALL_H
#define PIOS_INITCALL_H

/*
 * This implementation is heavily based on the Linux Kernel initcall
 * infrastructure:
 *   http://lxr.linux.no/#linux/include/linux/init.h
 *   http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;f=include/linux/init.h
 */

/*
 * Used for initialization calls..
 */

typedef int32_t (*initcall_t)(void);
typedef struct {
    initcall_t fn_minit;
    initcall_t fn_tinit;
} initmodule_t;

/* Init module section */
extern initmodule_t __module_initcall_start[], __module_initcall_end[];
extern volatile int initTaskDone;

/* Init settings section */
extern initcall_t __settings_initcall_start[], __settings_initcall_end[];

#ifdef USE_SIM_POSIX

extern void InitModules();
extern void StartModules();
extern int32_t SystemModInitialize(void);

#define MODULE_INITCALL(ifn, sfn)

#define SETTINGS_INITCALL(fn)

#define MODULE_TASKCREATE_ALL \
    { \
        /* Start all module threads */ \
        StartModules(); \
    }

#define MODULE_INITIALISE_ALL \
    { \
        /* Initialize modules */ \
        InitModules(); \
        /* Initialize the system thread */ \
        SystemModInitialize(); \
        initTaskDone = 1; }

#else // ifdef USE_SIM_POSIX

/* initcalls are now grouped by functionality into separate
 * subsections. Ordering inside the subsections is determined
 * by link order.
 *
 * The `id' arg to __define_initcall() is needed so that multiple initcalls
 * can point at the same handler without causing duplicate-symbol build errors.
 */

#define __define_initcall(level, fn, id) \
    static initcall_t __initcall_##fn##id __attribute__((__used__)) \
    __attribute__((__section__(".initcall" level ".init"))) = fn

#define __define_module_initcall(level, ifn, sfn) \
    static initmodule_t __initcall_##ifn __attribute__((__used__)) \
    __attribute__((__section__(".initcall" level ".init"))) = { .fn_minit = ifn, .fn_tinit = sfn }

#define __define_settings_initcall(level, fn) \
    static initcall_t __initcall_##fn __attribute__((__used__)) \
    __attribute__((__section__(".initcall" level ".init"))) = fn


#define MODULE_INITCALL(ifn, sfn) __define_module_initcall("module", ifn, sfn)

#define SETTINGS_INITCALL(fn)     __define_settings_initcall("settings", fn)


#ifdef ARA_MOCK_UNROLL_MODINIT
//MODULE TASKCREATE
extern int32_t ActuatorInitialize();
extern int32_t AltitudeInitialize();
extern int32_t AttitudeInitialize();
extern int32_t CameraStabInitialize();
extern int32_t comUsbBridgeInitialize();
extern int32_t FirmwareIAPInitialize();
extern int32_t GPSInitialize();
extern int32_t ManualControlInitialize();
extern int32_t osdoutputInitialize();
extern int32_t ReceiverInitialize();
extern int32_t StabilizationInitialize();
extern int32_t SystemModInitialize();
extern int32_t TelemetryInitialize();
extern int32_t TxPIDInitialize();
extern int32_t uavoMSPBridgeInitialize();
extern int32_t uavoMavlinkBridgeInitialize();

//MODULE START
extern int32_t ActuatorStart();
extern int32_t AltitudeStart();
extern int32_t AttitudeStart();
extern int32_t CameraStabStart();
extern int32_t comUsbBridgeStart();
extern int32_t GPSStart();
extern int32_t ManualControlStart();
extern int32_t osdoutputStart();
extern int32_t ReceiverStart();
extern int32_t StabilizationStart();
extern int32_t TelemetryStart();
extern int32_t TxPIDStart();
extern int32_t uavoMSPBridgeStart();
extern int32_t uavoMavlinkBridgeStart();

//SETTTINGS
extern int32_t AccelGyroSettingsInitialize();
extern int32_t AccelStateInitialize();
extern int32_t AccessoryDesiredInitialize();
extern int32_t ActuatorCommandInitialize();
extern int32_t ActuatorDesiredInitialize();
extern int32_t ActuatorSettingsInitialize();
extern int32_t AttitudeSettingsInitialize();
extern int32_t AttitudeStateInitialize();
extern int32_t CameraDesiredInitialize();
extern int32_t CameraStabSettingsInitialize();
extern int32_t FirmwareIAPObjInitialize();
extern int32_t FlightModeSettingsInitialize();
extern int32_t FlightStatusInitialize();
extern int32_t FlightTelemetryStatsInitialize();
extern int32_t GCSTelemetryStatsInitialize();
extern int32_t GPSPositionSensorInitialize();
extern int32_t GPSSettingsInitialize();
extern int32_t GPSVelocitySensorInitialize();
extern int32_t GyroStateInitialize();
extern int32_t HwSettingsInitialize();
extern int32_t ManualControlCommandInitialize();
extern int32_t ManualControlSettingsInitialize();
extern int32_t MixerSettingsInitialize();
extern int32_t MixerStatusInitialize();
extern int32_t MPUGyroAccelSettingsInitialize();
extern int32_t ObjectPersistenceInitialize();
extern int32_t RateDesiredInitialize();
extern int32_t ReceiverActivityInitialize();
extern int32_t ReceiverStatusInitialize();
extern int32_t StabilizationBankInitialize();
extern int32_t StabilizationDesiredInitialize();
extern int32_t StabilizationSettingsInitialize();
extern int32_t StabilizationSettingsBank1Initialize();
extern int32_t StabilizationSettingsBank2Initialize();
extern int32_t StabilizationSettingsBank3Initialize();
extern int32_t StabilizationStatusInitialize();
extern int32_t SystemAlarmsInitialize();
extern int32_t SystemSettingsInitialize();
extern int32_t SystemStatsInitialize();
extern int32_t TxPIDSettingsInitialize();
extern int32_t TxPIDStatusInitialize();
extern int32_t WatchdogStatusInitialize();


#define MODULE_INITIALISE_ALL \
  {\
  ActuatorInitialize();\
  AttitudeInitialize();\
  CameraStabInitialize();\
  comUsbBridgeInitialize();\
  FirmwareIAPInitialize();\
  GPSInitialize();\
  ManualControlInitialize();\
  osdoutputInitialize();\
  ReceiverInitialize();\
  StabilizationInitialize();\
  SystemModInitialize();\
  TelemetryInitialize();\
  TxPIDInitialize();\
  uavoMSPBridgeInitialize();\
  uavoMavlinkBridgeInitialize();\
  };

#define MODULE_TASKCREATE_ALL \
  {\
  ActuatorStart();\
  AttitudeStart();\
  CameraStabStart();\
  comUsbBridgeStart();\
  GPSStart();\
  ManualControlStart();\
  osdoutputStart();\
  ReceiverStart();\
  StabilizationStart();\
  TelemetryStart();\
  TxPIDStart();\
  uavoMSPBridgeStart();\
  uavoMavlinkBridgeStart();\
  };

#define SETTINGS_INITIALISE_ALL\
  {\
  AccelGyroSettingsInitialize();\
  AccelStateInitialize();\
  AccessoryDesiredInitialize();\
  ActuatorCommandInitialize();\
  ActuatorDesiredInitialize();\
  ActuatorSettingsInitialize();\
  AttitudeSettingsInitialize();\
  AttitudeStateInitialize();\
  CameraDesiredInitialize();\
  CameraStabSettingsInitialize();\
  FirmwareIAPObjInitialize();\
  FlightModeSettingsInitialize();\
  FlightStatusInitialize();\
  FlightTelemetryStatsInitialize();\
  GCSTelemetryStatsInitialize();\
  GPSPositionSensorInitialize();\
  GPSSettingsInitialize();\
  GPSVelocitySensorInitialize();\
  GyroStateInitialize();\
  HwSettingsInitialize();\
  ManualControlCommandInitialize();\
  ManualControlSettingsInitialize();\
  MixerSettingsInitialize();\
  MixerStatusInitialize();\
  MPUGyroAccelSettingsInitialize();\
  ObjectPersistenceInitialize();\
  RateDesiredInitialize();\
  ReceiverActivityInitialize();\
  ReceiverStatusInitialize();\
  StabilizationBankInitialize();\
  StabilizationDesiredInitialize();\
  StabilizationSettingsInitialize();\
  StabilizationSettingsBank1Initialize();\
  StabilizationSettingsBank2Initialize();\
  StabilizationSettingsBank3Initialize();\
  StabilizationStatusInitialize();\
  SystemAlarmsInitialize();\
  SystemSettingsInitialize();\
  SystemStatsInitialize();\
  TxPIDSettingsInitialize();\
  TxPIDStatusInitialize();\
  WatchdogStatusInitialize();\
  };

#else // ARA_MOCK_UNROLL_MODINIT
#define MODULE_INITIALISE_ALL \
    { for (initmodule_t *fn = __module_initcall_start; fn < __module_initcall_end; fn++) { \
          if (fn->fn_minit) { \
              (fn->fn_minit)(); } \
      } \
      initTaskDone = 1; \
    }

#define MODULE_TASKCREATE_ALL    \
    { for (initmodule_t *fn = __module_initcall_start; fn < __module_initcall_end; fn++) { \
          if (fn->fn_tinit) {    \
              (fn->fn_tinit)();  \
              PIOS_WDG_Clear();  \
          } \
      } \
    }

#define SETTINGS_INITIALISE_ALL \
    { for (const initcall_t *fn = __settings_initcall_start; fn < __settings_initcall_end; fn++) { \
          if (*fn) { \
              (*fn)(); \
          } \
      } \
    }
#endif //ARA_MOCK_UNROLL_MODINIT

#endif /* USE_SIM_POSIX */

#endif /* PIOS_INITCALL_H */

/**
 * @}
 * @}
 */
