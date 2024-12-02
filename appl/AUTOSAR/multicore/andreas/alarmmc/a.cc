#include "autosar/os.h"
#include "test/test.h"

DeclareTask(T00);
DeclareTask(T01);
DeclareTask(T10);
DeclareTask(T11);
DeclareAlarm(A1);
DeclareAlarm(A2);
DeclareCounter(C1);
DeclareCounter(C2);

/*This Test checks if the Alarm is able to run on 2 Cores*/

void start() {
	StatusType rv;
	switch (GetCoreID()) {
	case OS_CORE_ID_MASTER:
		StartCore(OS_CORE_ID_1, &rv);
	default:
		StartOS(0);
	}
}

TEST_MAKE_OS_MAIN(start())

_Atomic(int) counter1 = 0;
_Atomic(int) counter2 = 0;

TASK(T00) { //Core 0 Prio 1 + Autostart
	TerminateTask();
}

TASK(T01) { //Core 0 Prio 2
	counter1++;
	if (counter1 == 3) {
		CancelAlarm(A1);
	}
	TerminateTask();
}

TASK(T10) { //Core 1 Prio 1 + Autostart
	TerminateTask();
}

TASK(T11) { //Core 1 Prio 2
	counter2++;
	if (counter2 == 3) {
		CancelAlarm(A2);
	}
	TerminateTask();
}

void PreIdleHook() {
	debug_core << "idle" << endl;
	if (GetCoreID() == OS_CORE_ID_MASTER && counter1 == 3) {
		test_start();
		for (int i = 0; i < 1000000000; i++) { Machine::nop(); };
		test_eq(counter1, counter2);
		test_finish();
		ShutdownMachine();
	}
}


