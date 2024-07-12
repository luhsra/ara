#include "autosar/os.h"
#include "test/test.h"

DeclareTask(T00);
DeclareTask(T10);
DeclareTask(T20);
DeclareTask(T30);

DeclareSpinlock(S1);

void start() {
	StatusType rv;
	switch (GetCoreID()) {
	case OS_CORE_ID_MASTER:
		StartCore(OS_CORE_ID_1, &rv);
		StartCore(OS_CORE_ID_2, &rv);
		StartCore(OS_CORE_ID_3, &rv);
	default:

        //kout << '#' <<  GetCoreID() << endl;
		StartOS(0);
	}
}

TEST_MAKE_OS_MAIN(start())

int counter = 0;

TASK(T00) {
	 //kout << "a" << endl;
	//GetSpinlock(S1);
	counter++;
	//ReleaseSpinlock(S1);
	TerminateTask();
}

TASK(T10) {
	 //kout << "b" << endl;
	//GetSpinlock(S1);
	counter++;
	//ReleaseSpinlock(S1);
	TerminateTask();
}

TASK(T20) {
	 //kout << "c" << endl;
	//GetSpinlock(S1);
	counter++;
	//ReleaseSpinlock(S1);
	TerminateTask();
}

TASK(T30) {
	 //kout << "d" << endl;
	//GetSpinlock(S1);
	counter++;
	//ReleaseSpinlock(S1);
	TerminateTask();
}

void PreIdleHook() {

	//kout << "^" << GetCoreID() << endl;

	if (GetCoreID() == OS_CORE_ID_0) {
		//usleep(100 * 1000);
		for(int i = 0; i < 100000000; i++) {
			Machine::nop();
		}
		test_start();
		test_eq(counter, 4);
		test_positive_tests_eq(1);
		test_finish();
		ShutdownAllCores(E_OK);
	}
	//kout << "$$$" << GetCoreID() << endl;
	while (1) {
		Machine::nop();
		//kout << GetCoreID() << endl;	
		for(int i = 0; i < 100000000; i++) {
			Machine::nop();
		}
		//kout << GetCoreID() << endl;	
	}
}