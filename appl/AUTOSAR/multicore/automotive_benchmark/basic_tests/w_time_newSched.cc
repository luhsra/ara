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

	ara_timing_info(5, 6);
	kout << "Init in new scheduling Test!" <<  endl;

	TerminateTask();
}
const unsigned ROUNDS = 20;
static unsigned round_counter = 0;

// find maximum time
const unsigned T2_WORKTIME = 1950;

// main scheduler
TASK(S1) {

    round_counter++;
    if (round_counter > ROUNDS) {
        kout << "\n\nDone - #H1_runs: " << count_trace('1') << " and #H2_runs: " << count_trace('2') << endl;
            
		ara_timing_info(7, 8);
        #ifndef QEMU
        // to better see results on PI wait at the end before rebooting
        micro_sec_wait(3000000);
        #endif

        test_finish();
        ShutdownMachine();
    }

    //kout << "\nSchedule round:" << round_counter << endl;

	ara_timing_info(1, 3);
    StatusType res;
    res = ActivateTask(H1);
		/*
    if (res == StatusType::E_OK)  {
        kout << "Go H1" << endl;
    } else if (res == StatusType::E_OS_LIMIT) {
        kout << "H1 blocked" << endl;
    }*/

		if (round_counter % 2 == 0) {
			res = ActivateTask(H2);
			/*
			if (res == StatusType::E_OK)  {
					kout << "Go H2" << endl;
			} else if (res == StatusType::E_OS_LIMIT) {
					kout << "H2 blocked" << endl;
			}*/
		}
	TerminateTask();
}

TASK(H1) {
  // kout << "H1" << endl;
	test_trace('1');
	ara_timing_info(11,13);
	micro_sec_wait(11);
  //kout << "\tEnd H1" << endl;
	TerminateTask();
}

TASK(H2) {
	//kout << "H2" << endl;
	test_trace('2');
	ara_timing_info(T2_WORKTIME,T2_WORKTIME + 1);
	micro_sec_wait(T2_WORKTIME);
  // kout << "\tEnd H2" << endl;
	TerminateTask();
}

