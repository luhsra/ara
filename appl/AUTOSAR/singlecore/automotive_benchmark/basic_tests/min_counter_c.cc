#include "os.h"
#include "test/test.h"
#include "arch/arm/platforms/raspberry/perf.cc"

DeclareTask(MS1);
DeclareCounter(C1);
DeclareAlarm(AMS1);

TEST_MAKE_OS_MAIN(StartOS(0))

/**
 * Testing a simple counter.
 * for multisee timing == true
 */
static bool first = true;
static int cycle_count = 0;

TASK(MS1) {
	ara_timing_info(10,50);
	kout << "Working" << endl;
	TerminateTask();
}

void PreIdleHook() {

	kout << "Idle Hook" << endl;
	// must be 0 since arch::Per::start() not called yet
	ara_timing_info(0,1);
	
	if (first) {
		kout << "Start setup" << endl;
		arch::Perf::start();

		first = false;
		kout << "End setup" << endl;
	}

	ara_timing_info(2,3);
  cycle_count++;
	if (cycle_count > 10) {
		ara_timing_info(4,5);

		kout << "Done!" << endl;
		ShutdownMachine();
	}
}
