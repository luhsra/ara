#include "autosar/os.h"
#include "test/test.h"

DeclareTask(T00);
DeclareTask(T01);
DeclareTask(T02);
DeclareTask(T10);

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

_Atomic(int) counter = 4;

TASK(T00) {
    while (counter) {
        /* block CPU with PRIO 2 */
    }
    test_trace('0');
    ShutdownAllCores(E_OK);
}

TASK(T01) {
    test_trace('1');
    ShutdownAllCores(E_OK);
}

TASK(T02) {
    test_trace('2');
    TerminateTask();
}

TASK(T10) {
    if (counter-- % 2)
        ActivateTask(T01); // PRIO 1 - does not need IPI
    else
        ActivateTask(T02); // PRIO 3 - does need IPI

    TerminateTask();
}


void ShutdownHook(StatusType status) {
    (void) status;
    /* The testcase has finished, check the output */
    if (GetCoreID() == OS_CORE_ID_0) {
        test_trace_assert("220");
        test_finish();
    }
}
