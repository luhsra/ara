#include "autosar/os.h"
#pragma once

#define NUMBER_OF_CORES 99
#define uint32 uint32_t

__attribute__((weak)) extern "C" int GetCoreID() {return -1;}
__attribute__((weak)) extern "C" StatusType GetNumberOfActivatedCores() {return E_OK;}
#define OS_CORE_ID_MASTER 0
#define OS_CORE_ID_1 1


// fake functions for trampoline
#define SCHEDULING_CHECK_INIT(a)
#define SCHEDULING_CHECK_AND_EQUAL_INT(a, b, c)
#define SCHEDULING_CHECK_STEP(a)

using CoreFunc = void (*)();
using TestRef = unsigned int;
using TryToGetSpinlockType = int;
#define TestRef int

#define TestRunner_start()
#define TestRunner_runTest(t) t
#define TestRunner_end()
#define addFailure(msg, line, file)


#define StartCore(id, rv)
#define OSDEFAULTAPPMODE 0

#define new_TestFixture(unused, func) func();
#define SyncAllCores(lock_name) GetSpinlock(lock_name)
#define SyncAllCores_Init()


#define EMB_UNIT_TESTFIXTURES(unused)
#define EMB_UNIT_TESTCALLER(c, n, null0, null1, fix) TestRef c;


#define FUNC(type, x) int
#define VAR(type, derive) type

#define PRO_TERMINATETASKISR 0

#define NULL_PTR nullptr

#define ISR(name) ISR2(name)
#define UNUSED_ISR(name) ISR2(name) {};
#define DeclareInterrupt(name);
#define sendSoftwareIt(core, name)


//TODO make this calls working as expected by AUTOSAR
#define DeclareApplication(name)
#define TerminateApplication(name, x) E_OK;
#define GetSpinlock_IE(name) GetSpinlock(name)


#define DeclareEvent(x)							\
	extern const EventMaskType AUTOSAR_EVENT_ ## x;			\
    static dosek_unused const EventMaskType &x = AUTOSAR_EVENT_ ## x
