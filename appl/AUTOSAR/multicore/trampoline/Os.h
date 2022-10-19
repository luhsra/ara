#include "autosar/os.h"

#define NUMBER_OF_CORES 99

__attribute__((weak)) extern "C" int GetCoreID() {return -1;}
#define OS_CORE_ID_MASTER 0
#define OS_CORE_ID_1 1


// fake functions for trampoline
#define SCHEDULING_CHECK_INIT(a)
#define SCHEDULING_CHECK_AND_EQUAL_INT(a, b, c)

using CoreFunc = void (*)();
using TestRef = unsigned int;
#define TestRef int

#define TestRunner_start()
#define TestRunner_runTest(t)
#define TestRunner_end()
#define addFailure(msg, line, file)


#define StartCore(id, rv)
#define OSDEFAULTAPPMODE 0

#define new_TestFixture(unused, func) func();
#define SyncAllCores(lock_name) GetSpinlock(lock_name)
#define SyncAllCores_Init()


#define EMB_UNIT_TESTFIXTURES(unused) TestRef caller;
#define EMB_UNIT_TESTCALLER(c, n, null0, null1, fix)


#define NULL_PTR nullptr



#define DeclareEvent(x)							\
	extern const EventMaskType AUTOSAR_EVENT_ ## x;			\
    static dosek_unused const EventMaskType &x = AUTOSAR_EVENT_ ## x
