#include "os.h"
#include "test/test.h"
#include "arch/arm/platforms/raspberry/perf.cc"

DeclareTask(SCHED1);
DeclareTask(MS1);
DeclareTask(MS2);
DeclareTask(MS5);
DeclareTask(MS10);
DeclareTask(MS20);
DeclareTask(MS50);
DeclareTask(MS100);
DeclareTask(MS200);
DeclareTask(MS1000);

TEST_MAKE_OS_MAIN(StartOS(0))

unsigned version = 1;

// how often the scheduler gets started, 1ms each
unsigned runs = 5000;

// number of runnables
unsigned RUNNABLES = 1000;

// Predifined periods to trigger runnables (in ms) + share of these periods (in %)
unsigned PERIOD[] = {1, 2, 5, 10, 20, 50, 100, 200, 1000};
unsigned SHARE[] = {3, 2, 2, 25, 25, 3, 20, 1, 4, 15};

// startup + control Task, loweest prio
TASK(SCHED1) {
	arch::Perf::start();
    kout << "V:" << version << " Started Auto Test!" << endl;
	test_trace('S');

	for (unsigned i = 0; i < runs; i++) {

		// uint32_t current_cycle = arch::Perf::get_cycles();

		ActivateTask(MS1);
		// record cycle

		if (i % 2 == 0) {
			ActivateTask(MS2);
		}
		if (i % 5 == 0) {
			ActivateTask(MS5);
		}
		if (i % 10 == 0) {
			ActivateTask(MS10);
		}
		if (i % 20 == 0) {
			ActivateTask(MS20);
		}
		if (i % 50 == 0) {
			ActivateTask(MS50);
		}
		if (i % 100 == 0) {
			ActivateTask(MS100);
		}
		if (i % 200 == 0) {
			ActivateTask(MS200);
		}
		if (i % 1000 == 0) {
			ActivateTask(MS1000);
		}
		micro_sec_wait(1000);
		//micro_sec_wait_upto(current_cycle, 1000000);
	}
	
	TerminateTask();
}

TASK(MS1) {
    kout << "MS1" << endl;
	micro_sec_wait(5);
	test_trace('1');
	TerminateTask();
}
TASK(MS2) {
    kout << "MS2" << endl;
	micro_sec_wait(4);
	test_trace('2');
	TerminateTask();
}
TASK(MS5) {
    kout << "MS5" << endl;
	micro_sec_wait(11);
	test_trace('5');
	TerminateTask();
}
TASK(MS10) {
    kout << "MS10" << endl;
	micro_sec_wait(10);
	test_trace('A');
	TerminateTask();
}
TASK(MS20) {
    kout << "MS20" << endl;
	micro_sec_wait(9);
	test_trace('B');
	TerminateTask();
}
TASK(MS50) {
    kout << "MS50" << endl;
	micro_sec_wait(18);
	test_trace('C');
	TerminateTask();
}
TASK(MS100) {
    kout << "MS100" << endl;
	micro_sec_wait(11);
	test_trace('D');
	TerminateTask();
}
TASK(MS200) {
    kout << "MS200" << endl;
	micro_sec_wait(3);
	test_trace('E');
	TerminateTask();
}
TASK(MS1000) {
    kout << "MS1000" << endl;
	micro_sec_wait(1);
	test_trace('F');
	TerminateTask();
}

void PreIdleHook() {

	test_trace_assert("TODO");
	test_finish();
	ShutdownMachine();

}
