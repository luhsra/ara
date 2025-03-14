#include "os.h"
#include "test/test.h"
#include "arch/arm/platforms/raspberry/perf.cc"

DeclareTask(H1);

TEST_MAKE_OS_MAIN(StartOS(0))

/**
 * Test everything about waiting/perf
 */

const unsigned RUNS = 5;
static unsigned int s[RUNS] = {0};
static unsigned int e[RUNS] = {0};

TASK(H1) {
	// needed for wait functions
	arch::Perf::start();

	kout << "Starting Waiting Test!" <<  endl;

	// Test for starting an already running task
	// StatusType res = ActivateTask(H1);
	// kout << res << endl;

	for (unsigned i = 0; i < RUNS; i++) {
		
		// test wait_upto
		// uint32_t start_cycle = arch::Perf::get_cycles();

		s[i] = arch::Perf::get_cycles();
		// test wait
		micro_sec_wait(1000000);

		// test wait_upto
		// bool in_time = micro_sec_wait_upto(start_cycle, 1000000);

		// test cycles
		// cycles_wait(0xFFFFFFFF);

		// kout << "step: " << i+1 << endl;
		e[i] = arch::Perf::get_cycles();
		
	}
	for (unsigned i = 0; i < RUNS; i++) {
		kout << "Run: " << i << " delta[us]: " << (e[i] - s[i]) / WAIT_FREQUENCE << " s: " << s[i] / WAIT_FREQUENCE  << " e: " << e[i] / WAIT_FREQUENCE  << endl;
	}

	kout << "Done!" << endl;
	
	TerminateTask();
}

// after single Task is finished this is called
void PreIdleHook() {
	test_finish();
	ShutdownMachine();
}
