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

const unsigned VERSION = 1;
/**
 * Test large number of runnables that get started in predifined periods
 * FROM: REAL WORLD AUTOMOTIVE BENCHMARKS FOR FREE
 */

// how often the scheduler gets started
const unsigned RUNS = 1000;
// start new runnables each ms = 1000um
const unsigned SCHEDUL_INTERVAL = 1000;

// #runnables / 100 -> how many runnables are 1% of system
const unsigned RUNNABLES = 10;
// Predifined periods to trigger runnables (in ms)
const unsigned PERIOD[] = {1, 2, 5, 10, 20, 50, 100, 200, 1000};
// const unsigned PERIOD[] = {1, 2, 7, 11, 23, 51, 104, 199, 1003};
// Share of these periods (in %)
const unsigned SHARE[] = {3, 2, 2, 25, 25, 3, 20, 1, 4};
// Average execution time in microseconds (in us)
const unsigned TIME[] = {5, 5, 12, 11, 9, 18, 11, 3, 1};

// startup + control Task, loweest prio
TASK(SCHED1) {
	arch::Perf::start();
    kout << "V:" << VERSION << " Started Runnables Test with " << RUNNABLES * 100 << " runnables." << endl;
	micro_sec_wait(30000000);
	test_trace('S');

	for (unsigned i = 0; i < RUNS; i++) {

		uint32_t start_cycle = arch::Perf::get_cycles();

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

		uint32_t end_cycle = arch::Perf::get_cycles();

		bool in_time = micro_sec_wait_upto(start_cycle, SCHEDUL_INTERVAL);
		in_time ? test_trace('1') : test_trace('0');
		
		/*
		kout << "t: " << 1000 * WAIT_FREQUENCE << " d: " << end_cycle - start_cycle << endl;	
		kout << "s: " << start_cycle << " e: " << end_cycle << endl;	
		kout << "Run: \t" << i << " | In time? " << in_time << "\n" << endl;
		*/
	}

	TerminateTask();
}

TASK(MS1) {
	micro_sec_wait(RUNNABLES * SHARE[0] * TIME[0]);
	//test_trace('1');
	TerminateTask();
}
TASK(MS2) {
	micro_sec_wait(RUNNABLES * SHARE[1] * TIME[1]);
	//test_trace('2');
	TerminateTask();
}
TASK(MS5) {
	micro_sec_wait(RUNNABLES * SHARE[2] * TIME[2]);
	//test_trace('5');
	TerminateTask();
}
TASK(MS10) {
	micro_sec_wait(RUNNABLES * SHARE[3] * TIME[3]);
	//test_trace('A');
	TerminateTask();
}
TASK(MS20) {
	micro_sec_wait(RUNNABLES * SHARE[4] * TIME[4]);
	//test_trace('B');
	TerminateTask();
}
TASK(MS50) {
	micro_sec_wait(RUNNABLES * SHARE[5] * TIME[5]);
	//test_trace('C');
	TerminateTask();
}
TASK(MS100) {
	micro_sec_wait(RUNNABLES * SHARE[6] * TIME[6]);
	//test_trace('D');
	TerminateTask();
}
TASK(MS200) {
	micro_sec_wait(RUNNABLES * SHARE[7] * TIME[7]);
	//test_trace('E');
	TerminateTask();
}
TASK(MS1000) {
	micro_sec_wait(RUNNABLES * SHARE[8] * TIME[8]);
	//test_trace('F');
	TerminateTask();
}

void PreIdleHook() {
	kout << "TASKPERIOD| NUMBER OF RUNNABLES | EXPECTED RUNTIME" << endl;
	kout << "MS1       | " << RUNNABLES * SHARE[0] << "x \t\t| " << RUNNABLES * SHARE[0] * TIME[0] << "us" << endl;
    kout << "MS2       | " << RUNNABLES * SHARE[1] << "x \t\t| " << RUNNABLES * SHARE[1] * TIME[1] << "us" << endl;
    kout << "MS5       | " << RUNNABLES * SHARE[2] << "x \t\t| " << RUNNABLES * SHARE[2] * TIME[2] << "us" << endl;
    kout << "MS10      | " << RUNNABLES * SHARE[3] << "x \t\t| " << RUNNABLES * SHARE[3] * TIME[3] << "us" << endl;
    kout << "MS20      | " << RUNNABLES * SHARE[4] << "x \t\t| " << RUNNABLES * SHARE[4] * TIME[4] << "us" << endl;
    kout << "MS50      | " << RUNNABLES * SHARE[5] << "x \t\t| " << RUNNABLES * SHARE[5] * TIME[5] << "us" << endl;
    kout << "MS100     | " << RUNNABLES * SHARE[6] << "x \t\t| " << RUNNABLES * SHARE[6] * TIME[6] << "us" << endl;
    kout << "MS200     | " << RUNNABLES * SHARE[7] << "x \t\t| " << RUNNABLES * SHARE[7] * TIME[7] << "us" << endl;
    kout << "MS1000    | " << RUNNABLES * SHARE[8] << "x \t\t| " << RUNNABLES * SHARE[8] * TIME[8] << "us" << endl;

	kout << "\n# in Time: " << count_trace('1') << "\t|\tFailed: " << count_trace('0') << "\n" << endl;

	test_trace_dump();
	test_finish();
	
	micro_sec_wait(30000000);

	ShutdownMachine();

}
