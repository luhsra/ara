#include "autosar/os.h"
#include "test/test.h"

DeclareTask(T00);
DeclareTask(T10);
DeclareTask(T20);
DeclareTask(T30);

void start()
{
    StatusType rv;
    switch(GetCoreID()) {
    case OS_CORE_ID_MASTER:
        StartCore(OS_CORE_ID_1, &rv);
        StartCore(OS_CORE_ID_2, &rv);
        StartCore(OS_CORE_ID_3, &rv);

        // wait until all cores are idling
        SyncCore(OS_CORE_ID_1);
        SyncCore(OS_CORE_ID_2);
        SyncCore(OS_CORE_ID_3);
    default:
        StartOS(0);
    }
}

TEST_MAKE_OS_MAIN(start())

TASK(T00) {
    test_trace('0');
    // Test synchronicity
    ActivateTask(T10);
    ActivateTask(T20);
    ActivateTask(T30);
    TerminateTask();
}

TASK(T10) {
    test_trace('1');
    TerminateTask();
}

TASK(T20) {
    test_trace('2');
    TerminateTask();
}

TASK(T30) {
    test_trace('3');
    ShutdownAllCores(E_OK);
}

void ShutdownHook(StatusType status) {
    (void) status;
    /* The testcase has finished, check the output */
    if (GetCoreID() == OS_CORE_ID_3) {
        test_trace_assert("0123");
        test_finish();
    }
}
