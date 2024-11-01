#include "os.h"
#include "test/test.h"
#include "arch/arm/platforms/raspberry/perf.cc"

DeclareTask(H1);

TEST_MAKE_OS_MAIN(StartOS(0))

/**
 * Test everything about waiting/perf
 */

TASK(H1) {
	// needed for wait functions
	arch::Perf::start();

	kout << "Starting Waiting Test!" <<  endl;

	for (unsigned i = 0; i < 10; i++) {
		
		// test wait_upto
		// uint32_t start_cycle = arch::Perf::get_cycles();

		// test wait
		micro_sec_wait(1000000);

		// test wait_upto
		// bool in_time = micro_sec_wait_upto(start_cycle, 1000000);

		// test cycles
		// cycles_wait(0xFFFFFFFF);

		// kout << "step: " << i+1 << endl;
		
	}

	kout << "Done!" << endl;
	
	TerminateTask();
}

// after single Task is finished this is called
void PreIdleHook() {
	test_finish();
	ShutdownMachine();
}
