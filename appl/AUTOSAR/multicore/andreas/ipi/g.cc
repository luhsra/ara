#include "autosar/os.h"
#include "test/test.h"

DeclareTask(T00);
DeclareTask(T10);
DeclareTask(T20);
DeclareTask(T30);

//#define DecEvent(x) DeclareEvent(x, 1 << __COUNTER__)
//DecEvent(E1);
//DecEvent(E2);

DeclareEvent(E1, 1 << 3);
DeclareEvent(E2, 1 << 6);

DeclareCounter(C1);
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
    if (events & E1)
        test_trace('E');
    if (events & E2)
        test_trace('e');

    ClearEvent(E1 | E2);
}

TASK(T00) {
    test_trace('0');
    ActivateTask(T10);
    check_events();
    ActivateTask(T30);
    check_events();
    ShutdownAllCores(E_OK);
}

TASK(T10) {
    test_trace('1');
    ChainTask(T20);
}

TASK(T20) {
    test_trace('2');
    SetEvent(T00, E2);
    TerminateTask();
}

TASK(T30) {
    test_trace('3');
    SetEvent(T00, E1);
    TerminateTask();
}

void ShutdownHook(StatusType status) {
    (void) status;
    /* The testcase has finished, check the output */
    if (GetCoreID() == OS_CORE_ID_0) {
        test_trace_assert("012e3E");
        test_finish();
    }
}
