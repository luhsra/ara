#include "autosar/os.h"
#include "test/test.h"

DeclareTask(T00);
DeclareTask(T10);
DeclareTask(T11);
DeclareTask(T12);
DeclareTask(T13);

DeclareSpinlock(S1);

void start() {
    StatusType rv;
    switch (GetCoreID()) {
    case OS_CORE_ID_MASTER:
        StartCore(OS_CORE_ID_1, &rv);
        StartCore(OS_CORE_ID_2, &rv);
        StartCore(OS_CORE_ID_3, &rv);
    default:
        StartOS(0);
    }
}

TEST_MAKE_OS_MAIN(start())

TASK(T00) {
    uint32_t cores = GetNumberOfActivatedCores();
	debug_core << "Cores: " << cores << endl;
    test_trace('0');
    ActivateTask(T10);
    test_trace('5');
    ActivateTask(T10);
    TerminateTask();
}

TASK(T10) {
    test_trace('1');
    GetSpinlock(S1);
    test_trace('1');
    ReleaseSpinlock(S1);
    ActivateTask(T11);

    TerminateTask();
    
}

TASK(T11) {

    test_trace('2');
    ActivateTask(T12);
    TerminateTask();
}

TASK(T12) {
    test_trace('3');
    ActivateTask(T13);
    TerminateTask();
}

TASK(T13) {
    test_trace('4');
    ShutdownAllCores(E_OK);
}

void ShutdownHook(StatusType status) {
	(void)status;
	/* The testcase has finished, check the output */
	if (GetCoreID() == OS_CORE_ID_1) {
		test_trace_assert("0151234");
		test_finish();
	}
}

void ErrorHook(StatusType status) {
	(void)status;
	/* The testcase has finished, check the output */
	if (status == E_OS_MISSINGEND) {
		test_trace_assert("012");
		test_finish();
	}
}