#include "autosar/os.h"
#include "test/test.h"

DeclareTask(T00);
DeclareTask(T01);
DeclareTask(T10);

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
	test_trace('0');
    TerminateTask();
}

TASK(T01) {
	test_trace('1');
    while (true); /* block cpu 0*/
    TerminateTask();
}

TASK(T10) {
	test_trace('2');
    ActivateTask(T01); // IPI needed
    ActivateTask(T00); // IPI not needed
    ShutdownAllCores(E_OK);
}

void ShutdownHook(StatusType status) {
    (void) status;
    /* The testcase has finished, check the output */
    if (GetCoreID() == OS_CORE_ID_1) {
        test_trace_assert("21");
        test_finish();
    }
}
