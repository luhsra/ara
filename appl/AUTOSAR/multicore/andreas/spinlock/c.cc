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
    test_trace('0');
    WaitEvent(E1); // error hook because of lock

    TerminateTask();
}

TASK(T01) {
    test_trace('1');
    TerminateTask();
}

TASK(T10) {
    test_trace('2');
    TerminateTask();
}

TASK(T11) {
    test_trace('3');
    TerminateTask();
}

void ErrorHook(StatusType status) {
    (void) status;
    /* The testcase has finished, check the output */
    test_trace_assert("0");
    test_finish();
}
