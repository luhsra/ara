#include "autosar/os.h"
#include "test/test.h"

DeclareTask(H1);
DeclareTask(H2);
DeclareTask(H3);
DeclareTask(H4);
DeclareTask(H5);

DeclareAlarm(A1);
DeclareCounter(C1);
DeclareEvent(E1, 1);

DeclareSpinlock(S1);

void start()
{
    StatusType rv;
    switch(GetCoreID()) {
    case OS_CORE_ID_MASTER:
        StartCore(OS_CORE_ID_1, &rv);
        StartCore(OS_CORE_ID_2, &rv);
        StartCore(OS_CORE_ID_3, &rv);
        StartCore(OS_CORE_ID_4, &rv);
        StartCore(OS_CORE_ID_5, &rv);
        StartOS(0);
        break;
    case OS_CORE_ID_1:
    case OS_CORE_ID_2:
    case OS_CORE_ID_3:
    case OS_CORE_ID_4:
    case OS_CORE_ID_5:
        StartOS(0);
        break;
    default:
        exit(1);
    }
}

TEST_MAKE_OS_MAIN(start())

TASK(H1) {
    static int cnt = 0;

    AUTOSAR_kickoff();

    if (cnt++ == 3) {
        test_trace('1');
        ShutdownAllCores(E_OK);
    }

    TerminateTask();
}

TASK(H2) {
    AUTOSAR_kickoff();
    WaitEvent(E1);
    test_trace('2');
    ActivateTask(H1);
    TerminateTask();
}

TASK(H3) {
    AUTOSAR_kickoff();
    test_trace('3');
    SetEvent(H2, E1);
    TerminateTask();
}

TASK(H4) {
    AUTOSAR_kickoff();
    test_trace('4');
    ChainTask(H3);
}

TASK(H5) {
    AUTOSAR_kickoff();
    Machine::trigger_interrupt_from_user(SIGUSR2, 2);
    ActivateTask(H2);
    ActivateTask(H4);
    TerminateTask();
}

ISR2(ISR1) {
    test_trace('5');
}

ALARMCALLBACK(A1) {
    debug_core << "alarm" << endl;
}

void PreIdleHook() {
}

void ShutdownHook(StatusType status) {
    (void) status;
    /* The testcase has finished, check the output */

    test_trace_assert("54321");
    test_finish();
}
