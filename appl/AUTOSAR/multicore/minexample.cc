#include "autosar/os.h"
#include "test/test.h"

/** TEST
 * ara/steps/multisse_helper/pairing_partner_search.py", line 333, in _find_timed_predecessor
 *  assert len(predecessors) > 0
 *  AssertionError
*/
DeclareTask(TaskA);
DeclareTask(TaskB);
DeclareTask(TaskC);
DeclareTask(TaskD);
DeclareTask(TaskE);
DeclareTask(TaskF);

ISR2(Interrupt1) {
    test_trace('1');
}

TASK(TaskA) {
    test_trace('A');
    TerminateTask();
}

TASK(TaskB) {
    test_trace('B');
    TerminateTask();
}

TASK(TaskC) {
    test_trace('C');
    TerminateTask();
}

TASK(TaskD) {
    test_trace('D');
    ActivateTask(TaskA);
    TerminateTask();
}

TASK(TaskE) {
    test_trace('E');
    ShutdownAllCores(E_OK);
    TerminateTask();
}

TASK(TaskF) {
    test_trace('F');
    ActivateTask(TaskE);
    TerminateTask();
}

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

void ShutdownHook(StatusType status) {
    (void) status;
    /* The testcase has finished, check the output */
    if (GetCoreID() == OS_CORE_ID_1) {
        test_trace_assert("DAFE");
        test_finish();
    }
}