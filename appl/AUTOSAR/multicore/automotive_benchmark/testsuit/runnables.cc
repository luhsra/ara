#include "os.h"
#include "test/test.h"
#include "arch/arm/platforms/raspberry/perf.cc"
#include "parameters.h"

DeclareTask(SCHED1);
DeclareTask(MS1);
DeclareTask(MS2);
DeclareTask(MS5);
DeclareTask(MS10);
DeclareTask(MS20);
DeclareTask(MS50);
DeclareTask(MS100);
DeclareTask(MS200);
DeclareTask(MS1000);
DeclareTask(MSANGLE);

TEST_MAKE_OS_MAIN(StartOS(0))

/**
 * Test large number of runnables that get started in predifined periods
 * FROM: REAL WORLD AUTOMOTIVE BENCHMARKS FOR FREE
 */

/**
 ******************** SCHEDULER ********************
 startup + control Task, lowest scheduling priority
 */

TASK(SCHED1) {
	arch::Perf::start();

	kout << "\nRunnables Testcase" << endl;
	kout_run_info();

	#ifndef QEMU
	micro_sec_wait(3000000);
	#endif

	uint32_t start_cycle, end_cycle;
	bool in_time;

	for (unsigned cycle= 0; cycle < CYCLES; cycle++) {

		start_cycle = arch::Perf::get_cycles();

		if (cycle% RUNABLES_PERIOD[MS1_id] == 0) {
			ActivateTask(MS1);
		}
		if (cycle% RUNABLES_PERIOD[MS2_id] == 0) {
			ActivateTask(MS2);
		}
		if (cycle% RUNABLES_PERIOD[MS5_id] == 0) {
			ActivateTask(MS5);
		}
		if (cycle% RUNABLES_PERIOD[MS10_id] == 0) {
			ActivateTask(MS10);
		}
		if (cycle% RUNABLES_PERIOD[MS20_id] == 0) {
			ActivateTask(MS20);
		}
		if (cycle% RUNABLES_PERIOD[MS50_id] == 0) {
			ActivateTask(MS50);
		}
		if (cycle% RUNABLES_PERIOD[MS100_id] == 0) {
			ActivateTask(MS100);
		}
		if (cycle% RUNABLES_PERIOD[MS200_id] == 0) {
			ActivateTask(MS200);
		}
		if (cycle% RUNABLES_PERIOD[MS1000_id] == 0) {
			ActivateTask(MS1000);
		}
		if (cycle% RUNABLES_PERIOD[MSANGLE_id] == 0) {
			ActivateTask(MSANGLE);
		}

		end_cycle = arch::Perf::get_cycles();

		in_time = micro_sec_wait_upto(start_cycle, SCHEDUL_INTERVAL);
		in_time ? test_trace('1') : test_trace('0');
		
		
		// Debug help
		
		if (!in_time) {
			kout << "Cycle:\t" << cycle << "\tfailed its timing!" << endl;
		}
		
		/*
		kout << "Max_time: " << SCHEDUL_INTERVAL * WAIT_FREQUENCE << "\tused: " << end_cycle - start_cycle << endl;	
		kout << "start_cycle: " << start_cycle << "\tend_cycle: " << end_cycle << endl;	
		kout << "Cycle Nr:\t" << cycle << "\tIn time? " << in_time << "\n" << endl;
		*/
	}

	TerminateTask();
}


/**
 ******************** Tasks ********************
 */
void workTask(task_id task) {

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
TASK(MS5) {
	workTask(MS5_id);
	//test_trace('5');
	TerminateTask();
}
TASK(MS10) {
	workTask(MS10_id);
	//test_trace('A');
	TerminateTask();
}
TASK(MS20) {
	workTask(MS20_id);
	//test_trace('B');
	TerminateTask();
}
TASK(MS50) {
	workTask(MS50_id);
	//test_trace('C');
	TerminateTask();
}
TASK(MS100) {
	workTask(MS100_id);
	//test_trace('D');
	TerminateTask();
}
TASK(MS200) {
	workTask(MS200_id);
	//test_trace('E');
	TerminateTask();
}
TASK(MS1000) {
	workTask(MS1000_id);
	//test_trace('F');
	TerminateTask();
}
TASK(MSANGLE) {
	workTask(MSANGLE_id);
	//test_trace('G');
	TerminateTask();
}

void PreIdleHook() {

    kout << "\n*******************" << endl;
	kout << "Trace Dump:" << endl;
	test_trace_dump();

	kout_task_data();
	
	kout << "\n\nFrom: " << CYCLES << " Cycles are:" << endl;
	kout << "\t# in Time: " << count_trace('1') << "\t\t| Failed: " << count_trace('0') << "\n" << endl;
#ifndef QEMU
	// to better see results on PI wait at the end before rebooting
	micro_sec_wait(5000000);
#endif

	test_finish();
	ShutdownMachine();

}
