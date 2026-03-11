#include "os.h"
#include "test/test.h"
#include "perf.h"

DeclareTask(H1);

TEST_MAKE_OS_MAIN(StartOS(0))

/**
 * Test everything about waiting/perf
 */

const unsigned RUNS = 3;
static uint64_t s[RUNS] = {0};
static uint64_t e[RUNS] = {0};
static uint64_t t[RUNS] = {0};

TASK(H1) {
	// needed for wait functions
	arch::Perf::start();

	kout << "Starting Waiting Test!" <<  endl;

	// Test for starting an already running task
	// StatusType res = ActivateTask(H1);
	// kout << res << endl;

	for (unsigned i = 0; i < RUNS; i++) {

		t[i] = *arch::mtime;
		s[i] = arch::Perf::get_cycles();
		// test wait
		micro_sec_wait(1000000);

		// test wait_upto
		// micro_sec_wait_upto(s[i], 3000000);

		// test cycles
		// cycles_wait(0xFFFFFFFF);

		// kout << "step: " << i+1 << endl;
		e[i] = arch::Perf::get_cycles();
		
	}
	for (unsigned i = 0; i < RUNS; i++) {
		kout << "Run: " << i << " delta[us]: " << (e[i] - s[i]) / WAIT_FREQUENCE << " s: " << s[i] / WAIT_FREQUENCE  << " e: " << e[i] / WAIT_FREQUENCE  << endl;
		// kout << "t: " << t[i] << endl;
	}

	kout << "Done!" << endl;
	
	TerminateTask();
}

// after single Task is finished this is called
void PreIdleHook() {
	test_finish();
	ShutdownMachine();
}
