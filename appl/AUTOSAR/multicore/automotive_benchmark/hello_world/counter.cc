#include "os.h"
#include "test/test.h"
#include "arch/arm/platforms/raspberry/perf.cc"

DeclareTask(H1);

TEST_MAKE_OS_MAIN(StartOS(0))

TASK(H1) {
	// needed for wait functions
	arch::Perf::start();

	kout << "Starting Counter Test!" <<  endl;

	for (unsigned i = 0; i < 10; i++) {
		
		micro_sec_wait(1000000);
		// cycles_wait(0xFFFFFFFF);

		kout << "step: " << i+1 << endl;
		
	}

	kout << "Done!" << endl;
	
	TerminateTask();
}

// after single Task is finished this is called
void PreIdleHook() {
	test_finish();
	ShutdownMachine();
}
