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
const unsigned runs = 100;


// FROM: REAL WORLD AUTOMOTIVE BENCHMARKS FOR FREE
// #runnables / 100 -> how many runnables are 1% of system
const unsigned RUNNABLES = 10;
// Predifined periods to trigger runnables (in ms)
const unsigned PERIOD[] = {1, 2, 5, 10, 20, 50, 100, 200, 1000};
// Share of these periods (in %)
const unsigned SHARE[] = {3, 2, 2, 25, 25, 3, 20, 1, 4};
// Average execution time in microseconds (in ys)
const unsigned TIME[] = {5, 5, 12, 11, 9, 18, 11, 3, 1};

// startup + control Task, loweest prio
TASK(SCHED1) {
	arch::Perf::start();
    kout << "V:" << version << " Started Auto Test!" << endl;
	micro_sec_wait(50000000);
	test_trace('S');

	for (unsigned i = 0; i < runs; i++) {

		uint32_t current_cycle = arch::Perf::get_cycles();

		if (i % PERIOD[0] == 0) {
			ActivateTask(MS1);
		}
		if (i % PERIOD[1] == 0) {
			ActivateTask(MS2);
		}
		if (i % PERIOD[2] == 0) {
			ActivateTask(MS5);
		}
		if (i % PERIOD[3] == 0) {
			ActivateTask(MS10);
		}
		if (i % PERIOD[4] == 0) {
			ActivateTask(MS20);
		}
		if (i % PERIOD[5] == 0) {
			ActivateTask(MS50);
		}
		if (i % PERIOD[6] == 0) {
			ActivateTask(MS100);
		}
		if (i % PERIOD[7] == 0) {
			ActivateTask(MS200);
		}
		if (i % PERIOD[8] == 0) {
			ActivateTask(MS1000);
		}

		// micro_sec_wait(1000);
		bool in_time = micro_sec_wait_upto(current_cycle, 1000);
		in_time ? test_trace('1') : test_trace('0');
		kout << "Run: " << i << " In time? " << in_time << endl;
	}

	TerminateTask();
}

TASK(MS1) {
    kout << "MS1" << endl;
	micro_sec_wait(RUNNABLES * SHARE[0] * TIME[0]);
	//test_trace('1');
	TerminateTask();
}
TASK(MS2) {
    kout << "MS2" << endl;
	micro_sec_wait(RUNNABLES * SHARE[1] * TIME[1]);
	//test_trace('2');
	TerminateTask();
}
TASK(MS5) {
    kout << "MS5" << endl;
	micro_sec_wait(RUNNABLES * SHARE[2] * TIME[2]);
	//test_trace('5');
	TerminateTask();
}
TASK(MS10) {
    kout << "MS10" << endl;
	micro_sec_wait(RUNNABLES * SHARE[3] * TIME[3]);
	//test_trace('A');
	TerminateTask();
}
TASK(MS20) {
    kout << "MS20" << endl;
	micro_sec_wait(RUNNABLES * SHARE[4] * TIME[4]);
	//test_trace('B');
	TerminateTask();
}
TASK(MS50) {
    kout << "MS50" << endl;
	micro_sec_wait(RUNNABLES * SHARE[5] * TIME[5]);
	//test_trace('C');
	TerminateTask();
}
TASK(MS100) {
    kout << "MS100" << endl;
	micro_sec_wait(RUNNABLES * SHARE[6] * TIME[6]);
	//test_trace('D');
	TerminateTask();
}
TASK(MS200) {
    kout << "MS200" << endl;
	micro_sec_wait(RUNNABLES * SHARE[7] * TIME[7]);
	//test_trace('E');
	TerminateTask();
}
TASK(MS1000) {
    kout << "MS1000" << endl;
	micro_sec_wait(RUNNABLES * SHARE[8] * TIME[8]);
	//test_trace('F');
	TerminateTask();
}

void PreIdleHook() {

	test_trace_assert("TODO");
	test_finish();
	
	kout << "# in Time: " << count_trace('1') << " failed: " << count_trace('0') << endl;

	micro_sec_wait(50000000);

	ShutdownMachine();

}
