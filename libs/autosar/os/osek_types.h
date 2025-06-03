// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
// SPDX-FileCopyrightText: 2025 Mareike Burg
//
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef __dosek_osek_types
#define __dosek_osek_types

#include <stdint.h>

/**
 *  @defgroup os Operating System Layer
 *  @brief This modules provides all OS functionalities
 */

/**
 * @file
 * @ingroup os
 * @brief OSEK API header
 */

/**
 * @satisfies{13,1}
 */
typedef enum {
	E_OK = 0,
	E_OS_ACCESS = 1,
	E_OS_CALLEVEL = 2,
	E_OS_ID = 3,
	E_OS_LIMIT = 4,
	E_OS_NOFUNC = 5,
	E_OS_RESOURCE = 6,
	E_OS_STATE = 7,
	E_OS_VALUE = 8,
	E_NOT_OK = 9,
	E_OS_CORE = 10,
	E_OS_SPINLOCK = 11,
	E_OS_NESTING_DEADLOCK = 12,
	E_OS_INTERFERENCE_DEADLOCK = 13,
	E_OS_MISSINGEND = 14, // hard-coded in IR generator
} StatusType;

/**
 * @satisfies{13,2,4}
 */
enum TaskStateType {
	RUNNING = 1,  //!< Constant of data type TaskStateType for task state *running*
	WAITING,      //!< Constant of data type TaskStateType for task state *waiting*
	READY,        //!< Constant of data type TaskStateType for task state *ready*
	SUSPENDED,    //!< Constant of data type TaskStateType for task state *suspended*
	INVALID_TASK, //!< Constant of data type TaskStateType for a not defined task
};

/******************************************************************************
 *                                                                            *
 * Data Type Definitions                                                      *
 *                                                                            *
 ******************************************************************************/

typedef uint32_t TaskType;
typedef uint32_t* TaskRefType;

typedef uint32_t ResourceType;
typedef uint32_t SpinlockType;
typedef uint32_t CoreIdType;

typedef uint16_t RemoteDomainType;
typedef uint32_t PortType;
typedef void * EventChannelCallbackType;

typedef unsigned long EventMaskType;
typedef unsigned long* EventMaskRefType;

typedef uint32_t AlarmType;

typedef struct {
	unsigned long maxallowedvalue;
	unsigned long ticksperbase;
	unsigned long mincycle;
} AlarmBaseType;

typedef enum { TRYTOGETSPINLOCK_SUCCESS, TRYTOGETSPINLOCK_NOSUCCESS } TryToGetSpinlockType;

typedef AlarmBaseType* AlarmBaseRefType;

typedef uint32_t CounterType;

typedef uint32_t MessageIdentifier;

typedef uint16_t TickType;
typedef TickType* TickRefType;

#endif
