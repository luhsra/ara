#include "autosar/os.h"
#include "test/test.h"

DeclareTask(T00);
DeclareTask(T01);

DeclareAlarm(A1);
DeclareCounter(C1);

void start()
{
    StatusType rv;
    switch(GetCoreID()) {
    case OS_CORE_ID_MASTER:
        StartCore(OS_CORE_ID_1, &rv);
    default:
        StartOS(0);
    }
}

TEST_MAKE_OS_MAIN(start())

TASK(T00) {
    for (int i = 0; i < 500000000; i++); // IPI from Alarm is needed
    test_trace('0');
    ShutdownAllCores(E_OK);
}

TASK(T01) {
    test_trace('1');
    TerminateTask();
}

TASK(T02) {
    test_trace('2');
    TerminateTask();
}

void ShutdownHook(StatusType status) {
    (void) status;
    /* The testcase has finished, check the output */
    if (GetCoreID() == OS_CORE_ID_0) {
        test_trace_assert("0");
        test_finish();
    }
}
