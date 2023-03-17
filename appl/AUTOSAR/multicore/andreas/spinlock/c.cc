#include "autosar/os.h"
#include "test/test.h"

DeclareTask(T00);
DeclareTask(T01);
DeclareTask(T10);
DeclareTask(T11);

DeclareSpinlock(S1);
DeclareEvent(E1, 1);

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

    //WaitEvent(E1); // no reschedule because of lock
    //debug_core << "WaitEvent here" << endl;
    TerminateTask(); // no terminate bacause of lock
    debug_core << "TerminateTask here" << endl;
    ReleaseSpinlock(S1);

    ShutdownAllCores(E_OK);
}

TASK(T01) {
    TerminateTask();
}

TASK(T10) {
    TerminateTask();
}

TASK(T11) {
    TerminateTask();
}

void ShutdownHook(StatusType status) {
    (void) status;
    /* The testcase has finished, check the output */
    if (GetCoreID() == OS_CORE_ID_1) {
        test_trace_assert("0123");
        test_finish();
    }
}
