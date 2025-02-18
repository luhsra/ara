#include "os.h"
#include "test/test.h"
#include "arch/arm/platforms/raspberry/perf.cc"
#include "parameters.h"

DeclareTask(INIT);
DeclareTask(SCHED);
DeclareCounter(C1);
DeclareAlarm(A1);

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


/**
 * Test scheduling, where counter activates scheduler which sets tasks as active
 */

/**
 ******************** SCHEDULER ********************
 */
// small init task
TASK(INIT) {
    arch::Perf::start();

    kout << "\nRun new Scheduler Testcase with " << TASK_COUNT << " tasks" << endl;
	kout_task_data();

	#ifndef QEMU
		// to better see results on PI wait at the end before rebooting
		micro_sec_wait(2000000);
	#endif

    ara_timing_info(0, 1);
    TerminateTask();	
}

const bool debug_print = true;

static StatusType res;
static unsigned cycle = 0;
static unsigned blocked_counter[NR_TASKS] = {0};
static unsigned run_counter[NR_TASKS] = {0};

// main scheduler
TASK(SCHED) {

    ara_timing_info(1, 2);
    cycle++;

    if (cycle > CYCLES) {
		ara_timing_info(1, 2);

		kout << "\n*******************" << endl;
		kout << "Done" << endl;
		kout << "*******************\n" << endl;

        kout << "\nResults for " << CYCLES << " scheduling cycles, each cycle " << SCHEDUL_INTERVAL << "us long:" << endl;
        for (unsigned i = 0; i < NR_TASKS; i++) {
            kout << taskStrings[i] << "\tblocked #/%: " << blocked_counter[i] << "/" << (100 * blocked_counter[i]) / run_counter[i];
			kout << "\tof #runs: " << run_counter[i] << endl;
        }
        kout << "\n" << endl;

        #ifndef QEMU
            // to better see results on PI wait at the end before rebooting
            micro_sec_wait(5000000);
        #endif

        ShutdownMachine();
    }

	/*
	if (debug_print) {
        kout << "\nSchedule round:" << cycle << endl;
	}
	*/

	if (TASK_COUNT >= 1) {
		if (cycle % RUNABLES_PERIOD[MS1_id] == 0) {
			ara_timing_info(4, 5);
			res = ActivateTask(MS1);
			run_counter[MS1_id]++;
			if (res == StatusType::E_OS_LIMIT) {
				if (debug_print) {
					kout << taskStrings[MS1_id] << " still runnning!" << endl;
				}
				blocked_counter[MS1_id]++;
			}
		}
	}
	if (TASK_COUNT >= 2) {
		if (cycle % RUNABLES_PERIOD[MS2_id] == 0) {
			ara_timing_info(4, 5);
			res = ActivateTask(MS2);
			run_counter[MS2_id]++;
			if (res == StatusType::E_OS_LIMIT) {
				if (debug_print) {
					kout << taskStrings[MS2_id] << " still runnning!" << endl;
				}
				blocked_counter[MS2_id]++;
			}
		}
	}
	if (TASK_COUNT >= 3) {
		if (cycle % RUNABLES_PERIOD[MS5_id] == 0) {
			ara_timing_info(4, 5);
			res = ActivateTask(MS5);
			run_counter[MS5_id]++;
			if (res == StatusType::E_OS_LIMIT) {
				if (debug_print) {
					kout << taskStrings[MS5_id] << " still runnning!" << endl;
				}
				blocked_counter[MS5_id]++;
			}
		}
	}
	if (TASK_COUNT >= 4) {
		if (cycle % RUNABLES_PERIOD[MS10_id] == 0) {
			ara_timing_info(4, 5);
			res = ActivateTask(MS10);
			run_counter[MS10_id]++;
			if (res == StatusType::E_OS_LIMIT) {
				if (debug_print) {
					kout << taskStrings[MS10_id] << " still runnning!" << endl;
				}
				blocked_counter[MS10_id]++;
			}
		}
    
	}
	if (TASK_COUNT >= 5) {
		if (cycle % RUNABLES_PERIOD[MS20_id] == 0) {
			ara_timing_info(4, 5);
			res = ActivateTask(MS20);
			run_counter[MS20_id]++;
			if (res == StatusType::E_OS_LIMIT) {
				if (debug_print) {
					kout << taskStrings[MS20_id] << " still runnning!" << endl; 
				}
				blocked_counter[MS20_id]++;
			}
		}
	}
	if (TASK_COUNT >= 6) {
		if (cycle % RUNABLES_PERIOD[MS50_id] == 0) {
			ara_timing_info(4, 5);
			res = ActivateTask(MS50);
			run_counter[MS50_id]++;
			if (res == StatusType::E_OS_LIMIT) {
				if (debug_print) {
					kout << taskStrings[MS50_id] << " still runnning!" << endl; 
				}
				blocked_counter[MS50_id]++;
			}
		}
	}
	if (TASK_COUNT >= 7) {
		if (cycle % RUNABLES_PERIOD[MS100_id] == 0) {
			ara_timing_info(4, 5);
			res = ActivateTask(MS100);
			run_counter[MS100_id]++;
			if (res == StatusType::E_OS_LIMIT) {
				if (debug_print) {
					kout << taskStrings[MS100_id] << " still runnning!" << endl; 
				}
				blocked_counter[MS100_id]++;
			}
		}
	}	
	if (TASK_COUNT >= 8) {
		if (cycle % RUNABLES_PERIOD[MS200_id] == 0) {
			ara_timing_info(4, 5);
			res = ActivateTask(MS200);
			run_counter[MS200_id]++;
			if (res == StatusType::E_OS_LIMIT) {
				if (debug_print) {
					kout << taskStrings[MS200_id] << " still runnning!" << endl; 
				}
				blocked_counter[MS200_id]++;
			}
		}
	}
	if (TASK_COUNT >= 9) {
		if (cycle % RUNABLES_PERIOD[MS1000_id] == 0) {
			ara_timing_info(4, 5);
			res = ActivateTask(MS1000);
			run_counter[MS1000_id]++;
			if (res == StatusType::E_OS_LIMIT) {
				if (debug_print) {
					kout << taskStrings[MS1000_id] << " still runnning!" << endl; 
				}
				blocked_counter[MS1000_id]++;
			}
		}
	}
	
	ara_timing_info(10, 11);
	TerminateTask();
}

TASK(MS1) {
    unsigned const t = (NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS1_id] * TIME_PER_RUNNABLE[MS1_id];
    // kout << MS1_id << "in " << t << "us" << endl;
	ara_timing_info(t,t + 1);
	micro_sec_wait(t);
	TerminateTask();
}
TASK(MS2) {
    unsigned const t = (NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS2_id] * TIME_PER_RUNNABLE[MS2_id];
    // kout << MS2_id << "in " << t << "us" << endl;
	ara_timing_info(t,t + 1);
	micro_sec_wait(t);
	TerminateTask();
}
TASK(MS5) {
    unsigned const t = (NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS5_id] * TIME_PER_RUNNABLE[MS5_id];
    // kout << MS5_id << "in " << t << "us" << endl;
	ara_timing_info(t,t + 1);
	micro_sec_wait(t);
	TerminateTask();
}
TASK(MS10) {
    unsigned const t = (NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS10_id] * TIME_PER_RUNNABLE[MS10_id];
    // kout << MS10_id << "in " << t << "us" << endl;
	ara_timing_info(t,t + 1);
	micro_sec_wait(t);
	TerminateTask();
}
TASK(MS20) {
    unsigned const t = (NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS20_id] * TIME_PER_RUNNABLE[MS20_id];
    // kout << MS20_id << "in " << t << "us" << endl;
	ara_timing_info(t,t + 1);
	micro_sec_wait(t);
	TerminateTask();
}
TASK(MS50) {
    unsigned const t = (NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS50_id] * TIME_PER_RUNNABLE[MS50_id];
    // kout << MS50_id << "in " << t << "us" << endl;
	ara_timing_info(t,t + 1);
	micro_sec_wait(t);
	TerminateTask();
}
TASK(MS100) {
    unsigned const t = (NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS100_id] * TIME_PER_RUNNABLE[MS100_id];
    // kout << MS100_id << "in " << t << "us" << endl;
	ara_timing_info(t,t + 1);
	micro_sec_wait(t);
	TerminateTask();
}
TASK(MS200) {
    unsigned const t = (NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS200_id] * TIME_PER_RUNNABLE[MS200_id];
    // kout << MS200_id << "in " << t << "us" << endl;
	ara_timing_info(t,t + 1);
	micro_sec_wait(t);
	TerminateTask();
}
TASK(MS1000) {
    unsigned const t = (NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS1000_id] * TIME_PER_RUNNABLE[MS1000_id];
    // kout << MS1000_id << "in " << t << "us" << endl;
	ara_timing_info(t,t + 1);
	micro_sec_wait(t);
	TerminateTask();
}
