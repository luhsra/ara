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

TEST_MAKE_OS_MAIN(StartOS(0))

/**
 * Test large number of runnables that get started in predifined periods
 * FROM: REAL WORLD AUTOMOTIVE BENCHMARKS FOR FREE
 */

/**
 ******************** SCHEDULER ********************
 */
// small init task
TASK(INIT) {
	arch::Perf::start();

	kout << "\nRun minimal Testcase" << endl;

	ara_timing_info(0, 1);
	TerminateTask();	
}

unsigned cycle = 0;
StatusType res;
unsigned blocked_counter[NR_TASKS] = {0};

// main scheduler
TASK(SCHED) {

	ara_timing_info(2, 3);
  cycle++;
  kout << cycle << " " << CYCLES << endl;
  if (cycle > CYCLES) {
    // kout << "\nEND" << endl;
    // kout << "\n*******************" << endl;
    /*
    kout << "Trace Dump:" << endl;
    # test_trace_dump();


    kout_task_data();

    kout << "\n" << endl;
    for (unsigned i = 0; i < NR_TASKS; i++) {
      kout << taskStrings[i] << "\tblocked: " << blocked_counter[i] << "\tof #runs: " << CYCLES / RUNABLES_PERIOD[i] << endl;
    }
    kout << "\n" << endl;
    #ifndef QEMU
      // to better see results on PI wait at the end before rebooting
      micro_sec_wait(5000000);
    #endif
    */
    test_finish();
    ShutdownMachine();
  }

    // kout << "\nSchedule round:" << cycle << endl;

	ara_timing_info(4, 5);
	if (cycle % RUNABLES_PERIOD[MS1_id] == 0) {
		res = ActivateTask(MS1);
		if (res == StatusType::E_OS_LIMIT) {
			kout << taskStrings[MS1_id] << " still runnning!" << endl;
			blocked_counter[MS1_id]++;
		}
	}
  
	if (cycle % RUNABLES_PERIOD[MS2_id] == 0) {
		res = ActivateTask(MS2);
		if (res == StatusType::E_OS_LIMIT) {
			kout << taskStrings[MS2_id] << " still runnning!" << endl;
			blocked_counter[MS2_id]++;
		}
	}
  /*
	if (cycle % RUNABLES_PERIOD[MS5_id] == 0) {
		ara_timing_info(1, 020);
		res = ActivateTask(MS5);
		if (res == StatusType::E_OS_LIMIT) {
			kout << taskStrings[MS5_id] << " still runnning!" << endl;
			blocked_counter[MS5_id]++;
		}
	}
	if (cycle % RUNABLES_PERIOD[MS10_id] == 0) {
		res = ActivateTask(MS10);
		if (res == StatusType::E_OS_LIMIT) {
			kout << taskStrings[MS10_id] << " still runnning!" << endl;
			blocked_counter[MS10_id]++;
		}
	}
	
	if (cycle % RUNABLES_PERIOD[MS20_id] == 0) {
		res = ActivateTask(MS20);
		if (res == StatusType::E_OS_LIMIT) {
			kout << taskStrings[MS20_id] << " still runnning!" << endl;
			blocked_counter[MS20_id]++;
		}
	}
	/*
	if (cycle % RUNABLES_PERIOD[MS50_id] == 0) {
		res = ActivateTask(MS50);
		if (res == StatusType::E_OS_LIMIT) {
			kout << taskStrings[MS50_id] << " still runnning!" << endl;
			blocked_counter[MS50_id]++;
		}
	}
	if (cycle % RUNABLES_PERIOD[MS100_id] == 0) {
		res = ActivateTask(MS100);
		if (res == StatusType::E_OS_LIMIT) {
			kout << taskStrings[MS100_id] << " still runnning!" << endl;
			blocked_counter[MS100_id]++;
		}
	}
	if (cycle % RUNABLES_PERIOD[MS200_id] == 0) {
		res = ActivateTask(MS200);
		if (res == StatusType::E_OS_LIMIT) {
			kout << taskStrings[MS200_id] << " still runnning!" << endl;
			blocked_counter[MS200_id]++;
		}
	}
	if (cycle % RUNABLES_PERIOD[MS1000_id] == 0) {
		res = ActivateTask(MS1000);
		if (res == StatusType::E_OS_LIMIT) {
			kout << taskStrings[MS1000_id] << " still runnning!" << endl;
			blocked_counter[MS1000_id]++;
		}
	}
	if (cycle % RUNABLES_PERIOD[MSANGLE_id] == 0) {
		res = ActivateTask(MSANGLE);
		if (res == StatusType::E_OS_LIMIT) {
			kout << taskStrings[MSANGLE_id] << " still runnning!" << endl;
			blocked_counter[MSANGLE_id]++;
		}
	}*/
	ara_timing_info(6, 7);
	TerminateTask();
}

/**
 ******************** Tasks ********************
 */
void workTask(task_id task) {
	ara_timing_info(100,200);
	micro_sec_wait((NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[task] * TIME_PER_RUNNABLE[task]);
}

TASK(MS1) {
	workTask(MS1_id);
	//test_trace('1');
	TerminateTask();
}

TASK(MS2) {
	workTask(MS2_id);
	//test_trace('2');
	TerminateTask();
}
/*
TASK(MS5) {
	ara_timing_info(1, 2);
	workTask(MS5_id);
	//test_trace('5');
	TerminateTask();
}
TASK(MS10) {
	ara_timing_info(1, 2);
	workTask(MS10_id);
	//test_trace('A');
	TerminateTask();
}
TASK(MS20) {
	ara_timing_info(1, 2);
	workTask(MS20_id);
	//test_trace('B');
	TerminateTask();
}
/*
TASK(MS50) {
	ara_timing_info(1, 2);
	workTask(MS50_id);
	//test_trace('C');
	TerminateTask();
}
TASK(MS100) {
	ara_timing_info(1, 2);
	workTask(MS100_id);
	//test_trace('D');
	TerminateTask();
}
TASK(MS200) {
	ara_timing_info(10, 20);
	workTask(MS200_id);
	//test_trace('E');
	TerminateTask();
}
TASK(MS1000) {
	ara_timing_info(100, 200);
	workTask(MS1000_id);
	//test_trace('F');
	TerminateTask();
}
TASK(MSANGLE) {
	ara_timing_info(1, 2);
	workTask(MSANGLE_id);
	//test_trace('G');
	TerminateTask();
}
*/
