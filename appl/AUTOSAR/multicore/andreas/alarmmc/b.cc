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

_Atomic(int) counter0 = 0;
_Atomic(int) counter1 = 0;
_Atomic(int) counter2 = 0;

TASK(T00) { //Core 0
	while(true) {
		Machine::nop();
	}
}

TASK(T01) { //Core 0
	counter0++;
	counter1++;
	TerminateTask();
}

TASK(T10) { //Core 1
	while (true)
	{
		Machine::nop();
	}
}

TASK(T11) { //Core 1
	counter0++;
	counter2++;
	TerminateTask();
}

void PreIdleHook() {


	if(counter0 > 6) {

		if(counter1 == counter2) {
			test_trace('1');
		}else if(counter1 + 1 == counter2) {
			test_trace('1');
		}else if(counter1 == counter2 + 1) {
			test_trace('1');
		}
		test_trace_assert("1");
		test_finish();
		ShutdownMachine();
	}
	
}


