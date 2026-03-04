#include "os.h"
#include "test/test.h"
#include "arch/arm/platforms/raspberry/perf.cc"

DeclareTask(S1);
DeclareTask(H1);
DeclareTask(H2);

TEST_MAKE_OS_MAIN(StartOS(0))

/**
 * Test the return value from activateTask
 */

// result depends on system.json:
// if prio S1 < HX, then HX always displaces and runs 10x.
// if prio S1 > HX, then HX waits after the first run and only runs 1x.
TASK(S1) {
	// needed for wait functions
	arch::Perf::start();

	kout << "Starting activateTask return value Test!" <<  endl;
    
    #ifndef QEMU
	// to better see results on PI wait at the end before rebooting
	micro_sec_wait(3000000);
    #endif
    
    StatusType res;
	for (unsigned i = 0; i < 10; i++) {
		
        kout << "\nRound i:" << i << endl;

        res = ActivateTask(H1);
        if (res == StatusType::E_OK)  {
            kout << "Started H1 suc" << endl;
        } else if (res == StatusType::E_OS_LIMIT) {
            kout << "H1 already running" << endl;
        }
        
		micro_sec_wait(500000);

        res = ActivateTask(H2);
        if (res == StatusType::E_OK)  {
            kout << "Started H2 suc" << endl;
        } else if (res == StatusType::E_OS_LIMIT) {
            kout << "H2 already running" << endl;
        }
        
        
		micro_sec_wait(500000);
	}

	TerminateTask();
}

TASK(H1) {
    kout << "Start H1" << endl;
	test_trace('1');
	micro_sec_wait(100000);
    kout << "End H1" << endl;
	TerminateTask();
}

TASK(H2) {
    kout << "Start H2" << endl;
	test_trace('2');
	micro_sec_wait(200000);
    kout << "End H2" << endl;
	TerminateTask();
}

// after single Task is finished this is called
void PreIdleHook() {

    kout << "\n\nDone - #H1_runs: " << count_trace('1') << " and #H2_runs: " << count_trace('2') << endl;
    
    #ifndef QEMU
	// to better see results on PI wait at the end before rebooting
	micro_sec_wait(3000000);
    #endif
	test_finish();
	ShutdownMachine();
}
