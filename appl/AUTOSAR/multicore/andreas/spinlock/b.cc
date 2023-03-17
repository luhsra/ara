#include "autosar/os.h"
#include "test/test.h"

DeclareTask(T00);
DeclareTask(T01);
DeclareTask(T10);
DeclareTask(T11);

DeclareSpinlock(S1);

void start()
{
    StatusType rv;
    switch(GetCoreID()) {
    case OS_CORE_ID_MASTER:
        StartCore(OS_CORE_ID_1, &rv);
        SyncCore(OS_CORE_ID_1);
    default:
        StartOS(0);
    }
}

TEST_MAKE_OS_MAIN(start())

TASK(T00) {
    GetSpinlock(S1);
    ActivateTask(T01); // deadlock
    ReleaseSpinlock(S1);
    TerminateTask();
}

TASK(T01) {
	GetSpinlock(S1);
    test_trace('1');
	ActivateTask(T10);
	ReleaseSpinlock(S1);
    TerminateTask();
}

TASK(T10) {
	GetSpinlock(S1);
    test_trace('2');
    ActivateTask(T11); // deadlock
	ReleaseSpinlock(S1);
    TerminateTask();
}

TASK(T11) {
	GetSpinlock(S1);
    test_trace('3');
	GetSpinlock(S1);
    ShutdownAllCores(E_OK);
}

void ShutdownHook(StatusType status) {
    (void) status;
    /* The testcase has finished, check the output */
    if (GetCoreID() == OS_CORE_ID_1) {
        test_trace_assert("0123");
        test_finish();
    }
}
