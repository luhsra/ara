/**
 * @defgroup apps Applications
 * @brief The applications...
 */

/**
 * @file
 * @ingroup apps
 * @brief Just a simple test application
 */
#include "autosar/os.h"
#include "test/test.h"
#include "machine.h"

#include "perf.h"
extern "C" const int PERF_TRACE = arch::Perf::trace::NONE;

typedef struct {int a;} result;

result* do_computation() {return nullptr;}
void ara_timing_info(int, int);

#if LOCKS_JSON
{"no_timing": {"spin_states": {"S1": 4}}, "with_timing": {"spin_states": {"S1": 0}}}
#endif //LOCKS_JSON

// CPU 0
DeclareTask(T01);
DeclareTask(T02);
// CPU 1
DeclareTask(T11); // autostart
// CPU 2
DeclareTask(T21);

DeclareSpinlock(S1);
DeclareSpinlock(S2);


void start() {
	StatusType rv;
	switch (GetCoreID()) {
	case OS_CORE_ID_MASTER:
		StartCore(OS_CORE_ID_1, &rv);
		StartCore(OS_CORE_ID_2, &rv);
	default:
		StartOS(0);
	}
}

TEST_MAKE_OS_MAIN( start() )

/* 
 * CPU0
 */
TASK(T01) {
	test_trace('H');
#ifdef VARIANT_T01
	arch::Perf::trace_cycles();
#endif
	ara_timing_info(20, 25);
	GetSpinlock(S1);
	ara_timing_info(5, 10);
	/* ... some computation */
	ReleaseSpinlock(S1);
	ara_timing_info(2, 4);

#ifdef VARIANT_T01
	arch::Perf::trace_cycles();
#endif
	arch::Perf::print_cycles();

	test_trace_assert("1LH");
	test_finish();

	ShutdownMachine();
}

TASK(T02) {
	arch::Perf::start();
	test_trace('L');
#ifdef VARIANT_T02
	arch::Perf::trace_cycles();
#endif
	/* ... some computation ... */
	ara_timing_info(60, 80);
#ifdef VARIANT_T02
	arch::Perf::trace_cycles();
#endif
	TerminateTask();
}

/*
 * CPU 1
 */


TASK(T11) {
	test_trace('1');
	arch::Perf::start();
	// heat up measurement caching
	ara_timing_info(1, 1);
#ifdef VARIANT_T11
	arch::Perf::trace_cycles();
	arch::Perf::reset_counters();
	arch::Perf::reset();

	arch::Perf::trace_cycles(); // T11 start
#endif
	ara_timing_info(1, 2);		//
	/* ... some computation ... */
	GetSpinlock(S1);
#ifdef VARIANT_T11
	arch::Perf::trace_cycles(); // ABB9+10
#endif
	ara_timing_info(8, 16);		//
	/* ... */
	ReleaseSpinlock(S1);
#ifdef VARIANT_T11
	arch::Perf::trace_cycles(); // ABB11+12
#endif
	ara_timing_info(1, 3);
	//test_trace('2');
	ActivateTask(T02);
#ifdef VARIANT_T11
	arch::Perf::trace_cycles(); // ABB13+14
#endif
	ara_timing_info(10, 20);	// 
	//test_trace('4');
	ActivateTask(T01);
#ifdef VARIANT_T11
	arch::Perf::trace_cycles(); // ABB15+16
#endif
	ara_timing_info(20, 30);	// 
	ActivateTask(T21);
#ifdef VARIANT_T11
	arch::Perf::trace_cycles(); // ABB17+18
#endif
	ara_timing_info(3, 4);

	TerminateTask();
}

/*
 * CPU 2
 */
TASK(T21) {
	arch::Perf::start();
	ara_timing_info(5, 9);
	/* ... some computation ... */
	GetSpinlock(S1);
	ara_timing_info(8, 16);
	/* ... */
	ReleaseSpinlock(S1);
	ara_timing_info(1, 2);
	TerminateTask();
}
