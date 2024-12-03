#include "os.h"
#include "test/test.h"
#include "arch/arm/platforms/raspberry/perf.cc"


DeclareTask(S0);
DeclareTask(S1);
DeclareTask(H1);
DeclareTask(H2);
DeclareCounter(C1);
DeclareAlarm(A1);

TEST_MAKE_OS_MAIN(StartOS(0))

/**
 * Test the new scheduling mechanism
 */

// small init task
TASK(S0) {
	// needed for wait functions
	arch::Perf::start();

	kout << "Init in new scheduling Test!" <<  endl;

	TerminateTask();
}
const unsigned ROUNDS = 10;
static unsigned round_counter = 0;

// main scheduler
TASK(S1) {


    round_counter++;
    if (round_counter > ROUNDS) {
        kout << "\n\nDone - #H1_runs: " << count_trace('1') << " and #H2_runs: " << count_trace('2') << endl;
            
        #ifndef QEMU
        // to better see results on PI wait at the end before rebooting
        micro_sec_wait(3000000);
        #endif

        test_finish();
        ShutdownMachine();
    }

    kout << "\nSchedule round:" << round_counter << endl;

    StatusType res;
    res = ActivateTask(H1);
    if (res == StatusType::E_OK)  {
        kout << "Go H1" << endl;
    } else if (res == StatusType::E_OS_LIMIT) {
        kout << "H1 blocked" << endl;
    }

    res = ActivateTask(H2);
    if (res == StatusType::E_OK)  {
        kout << "Go H2" << endl;
    } else if (res == StatusType::E_OS_LIMIT) {
        kout << "H2 blocked" << endl;
    }

	TerminateTask();
}

TASK(H1) {
    kout << "\tStart H1" << endl;
	test_trace('1');
	micro_sec_wait(100000);
    kout << "\tEnd H1" << endl;
	TerminateTask();
}

TASK(H2) {
    kout << "\tStart H2" << endl;
	test_trace('2');
	micro_sec_wait(2600000);
    kout << "\tEnd H2" << endl;
	TerminateTask();
}

