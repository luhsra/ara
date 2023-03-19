#include "autosar/os.h"
#include "test/test.h"

DeclareTask(T00);
DeclareTask(T10);
DeclareTask(T20);
DeclareTask(T30);

#define DecEvent(x) DeclareEvent(x, 1 << __COUNTER__)

DecEvent(E1);
DeclareCounter(C1);
DecEvent(E2);
DeclareCounter(C2);

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

void check_events() {
    WaitEvent(E1 | E2);
    EventMaskType events;
    GetEvent(T00, &events);
    debug_core << "EVENTMASK" << events << endl;
    if (events & E1)
        test_trace('E');
    if (events & E2)
        test_trace('e');
}

TASK(T00) {
    test_trace('0');
    ActivateTask(T10);

    check_events();
    check_events();

    TerminateTask();
}

TASK(T10) {
    test_trace('1');
    ChainTask(T20);
}

TASK(T20) {
    test_trace('2');
    SetEvent(T00, E2);
    ActivateTask(T30);
    TerminateTask();
}

TASK(T30) {
    SetEvent(T00, E1);
    test_trace('3');
    ShutdownAllCores(E_OK);
}

void ShutdownHook(StatusType status) {
    (void) status;
    /* The testcase has finished, check the output */
    if (GetCoreID() == OS_CORE_ID_3) {
        test_trace_assert("0123eE");
        test_finish();
    }
}
