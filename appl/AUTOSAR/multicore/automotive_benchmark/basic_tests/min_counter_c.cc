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
	ara_timing_info(0,5);
	TerminateTask();
}

void PreIdleHook() {
	ara_timing_info(0,3);
	
	if (first) {
		arch::Perf::start();
		first = false;
	}

	ara_timing_info(0,4);
  cycle_count++;
	if (cycle_count > 10) {
		ShutdownMachine();
	}
}
