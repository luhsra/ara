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

    kout << "\nRun new Scheduler Testcase" << endl;
	kout_task_data();

	#ifndef QEMU
		// to better see results on PI wait at the end before rebooting
		micro_sec_wait(2000000);
	#endif

    ara_timing_info(0, 1);
	kout << "\n*******************" << endl;
	kout << "Start" << endl;
    TerminateTask();	
}


static unsigned int c[CYCLES] = {0};
static unsigned int r[TASK_COUNT][CYCLES] = {0};
static unsigned int cycle_count[TASK_COUNT] = {0};


const bool debug_print = false;

static StatusType res;
static unsigned cycle = 0;
static unsigned blocked_counter[TASK_COUNT] = {0};
static unsigned start_counter[TASK_COUNT] = {0};
static unsigned finish_counter[TASK_COUNT] = {0};
static unsigned int prev = 0;

// main scheduler
TASK(SCHED) {


    ara_timing_info(10, 20);

    if (cycle >= CYCLES) {
		ara_timing_info(1, 2);

		kout << "End" << endl;
		kout << "*******************\n" << endl;
		
		for (unsigned i = 0; i < CYCLES; i++){
			kout << i << " c: " << c[i] / WAIT_FREQUENCE << "us" << endl;
			if (i == WARMUP) {
				kout << "Start of run" << endl;
			} else if (i == COOLDOWN) {
				kout << "End of run" << endl;
			}
		}
		for (unsigned t = 0; t < TASK_COUNT; t++) {
			for (unsigned i = 0; i < CYCLES; i++){
				if (r[t][i] != 0){
					kout << "Task_id: " << t << " run_nr: " << i << " r: " << r[t][i] / WAIT_FREQUENCE << "us" << endl;
				}
			}
		}

        kout << "\nResults for " << COOLDOWN - WARMUP << " scheduling cycles, each cycle " << SCHEDUL_INTERVAL << "us long:" << endl;
        for (unsigned i = 0; i < TASK_COUNT; i++) {
            kout << taskStrings[i] << "\tblocked #/%: " << blocked_counter[i] << "/" << (100 * blocked_counter[i]) / start_counter[i];
			kout << "\tof #started_runs: " << start_counter[i] << "\tof #finished_runs: " << finish_counter[i] << endl;
        }
		/*
		for (unsigned i = 0; i < NR_TASKS; i++) {
			kout << start_counter[i] << endl;
		}*/
        kout << "\n" << endl;

        #ifndef QEMU
            // to better see results on PI wait at the end before rebooting
            micro_sec_wait(5000000);
        #endif

        ShutdownMachine();
    }

	c[cycle] =  arch::Perf::get_cycles() - prev;
	prev = arch::Perf::get_cycles();
	
	if (debug_print) {
        kout << "\nSchedule round:" << cycle << endl;
	}
	

	if (WARMUP <= cycle && cycle < COOLDOWN){

		if (TASK_COUNT >= 1) {
			if (cycle % RUNABLES_PERIOD[MS1_id] == 0) {
				ara_timing_info(4, 5);
				res = ActivateTask(MS1);
				start_counter[MS1_id]++;
				if (debug_print) {
					kout << "S MS1" << endl;
				}
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
				start_counter[MS2_id]++;
				if (debug_print) {
					kout << "S MS2" << endl;
				}
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
				start_counter[MS5_id]++;
				if (debug_print) {
					kout << "S MS5" << endl;
				}
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
				start_counter[MS10_id]++;
				if (debug_print) {
					kout << "S MS10" << endl;
				}
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
				start_counter[MS20_id]++;
				if (debug_print) {
					kout << "S MS20" << endl;
				}
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
				start_counter[MS50_id]++;
				if (debug_print) {
					kout << "S MS50" << endl;
				}
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
				start_counter[MS100_id]++;
				if (debug_print) {
					kout << "S MS100" << endl;
				}
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
				start_counter[MS200_id]++;
				if (debug_print) {
					kout << "S MS200" << endl;
				}
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
				start_counter[MS1000_id]++;
				if (debug_print) {
					kout << "S MS1000" << endl;
				}
				if (res == StatusType::E_OS_LIMIT) {
					if (debug_print) {
						kout << taskStrings[MS1000_id] << " still runnning!" << endl; 
					}
					blocked_counter[MS1000_id]++;
				}
			}
		}
	}
	ara_timing_info(10, 11);
    cycle++;

	TerminateTask();
}

/*
void PreTaskHook() {

	TaskRefType a;
	uint32_t id = 1337;
	a = &id;
	GetTaskID(a);
	kout << arch::Perf::get_cycles() << endl;
	if (id == 1) {
		kout << "P Init" << endl;
	 } else if (id == 2) {
		kout << "P Sched" << endl;
	 } else if (id == 3) {
		kout << "P MS1" << endl;
	 } else if (id == 4) {
		kout << "P MS2" << endl;
	 } else if (id == 5) {
		kout << "P MS5" << endl;
	 } else if (id == 6) {
		kout << "P MS10" << endl;
	 } else if (id == 7) {
		kout << "P MS20" << endl;
	 } else if (id == 8) {
		kout << "P MS50" << endl;
	 } else if (id == 9) {
		kout << "P MS100" << endl;
	 } else if (id == 10) {
		kout << "P MS200" << endl;
	 } else if (id == 11) {
		kout << "P MS1000" << endl;
	 } else      {
		kout << "P unknown??" << endl;
	 }
	
}
*/

TASK(MS1) {
	
	unsigned int c = arch::Perf::get_cycles();
    unsigned const t = TOTAL_RUNTIME[MS1_id];
	if (debug_print) {
		kout << cycle_count[MS1_id] << endl;
		kout << "1g" << endl;
	}
	ara_timing_info(t,t + 1);
	micro_sec_wait(t);
	finish_counter[MS1_id]++;
	if (debug_print) {
		kout << "e1" << endl;
	}
	r[MS1_id][cycle_count[MS1_id]] = arch::Perf::get_cycles() - c;
	cycle_count[MS1_id]++;
	
	TerminateTask();
}
TASK(MS2) {
	unsigned int c = arch::Perf::get_cycles();
    unsigned const t = TOTAL_RUNTIME[MS2_id];
	if (debug_print) {
		kout << cycle_count[MS2_id] << endl;
		kout << "2g" << endl;
	}
	ara_timing_info(t,t + 1);
	micro_sec_wait(t);
	finish_counter[MS2_id]++;
	if (debug_print) {
		kout << "e2" << endl;
	}
	r[MS2_id][cycle_count[MS2_id]] =  arch::Perf::get_cycles() - c;
	cycle_count[MS2_id]++;
	
	TerminateTask();
}
TASK(MS5) {
    unsigned const t = TOTAL_RUNTIME[MS5_id];
	if (debug_print) {
		kout << "5g" << endl;
	}
	ara_timing_info(t,t + 1);
	micro_sec_wait(t);
	finish_counter[MS5_id]++;
	if (debug_print) {
		kout << "e5" << endl;
	}
	TerminateTask();
}
TASK(MS10) {
    unsigned const t = TOTAL_RUNTIME[MS10_id];
	if (debug_print) {
		kout << "10g" << endl;
	}
	ara_timing_info(t,t + 1);
	micro_sec_wait(t);
	finish_counter[MS10_id]++;
	if (debug_print) {
		kout << "e10" << endl;
	}
	TerminateTask();
}
TASK(MS20) {
    unsigned const t = TOTAL_RUNTIME[MS20_id];
	if (debug_print) {
		kout << "20g" << endl;
	}
	ara_timing_info(t,t + 1);
	micro_sec_wait(t);
	finish_counter[MS20_id]++;
	if (debug_print) {
		kout << "e20" << endl;
	}
	TerminateTask();
}
TASK(MS50) {
    unsigned const t = TOTAL_RUNTIME[MS50_id];
	if (debug_print) {
		kout << "50g" << endl;
	}
	ara_timing_info(t,t + 1);
	micro_sec_wait(t);
	finish_counter[MS50_id]++;
	if (debug_print) {
		kout << "e50" << endl;
	}
	TerminateTask();
}
TASK(MS100) {
    unsigned const t = TOTAL_RUNTIME[MS100_id];
	if (debug_print) {
		kout << "100g" << endl;
	}
	ara_timing_info(t,t + 1);
	micro_sec_wait(t);
	finish_counter[MS100_id]++;
	if (debug_print) {
		kout << "e100" << endl;
	}
	TerminateTask();
}
TASK(MS200) {
    unsigned const t = TOTAL_RUNTIME[MS200_id];
	if (debug_print) {
		kout << "200g" << endl;
	}
	ara_timing_info(t,t + 1);
	micro_sec_wait(t);
	finish_counter[MS200_id]++;
	if (debug_print) {
		kout << "e200" << endl;
	}
	TerminateTask();
}
TASK(MS1000) {
    unsigned const t = TOTAL_RUNTIME[MS1000_id];
	if (debug_print) {
		kout << "1000g" << endl;
	}
	ara_timing_info(t,t + 1);
	micro_sec_wait(t);
	finish_counter[MS1000_id]++;
	if (debug_print) {
		kout << "e1000" << endl;
	}
	TerminateTask();
}
