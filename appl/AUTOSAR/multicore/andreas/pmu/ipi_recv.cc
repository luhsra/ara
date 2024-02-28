#include "autosar/os.h"
#include "perf.h"
#include "test/test.h"

DeclareTask(T00);
DeclareTask(T01);
DeclareTask(T10);

extern "C" const int PERF_TRACE = arch::Perf::trace::IRQ;

bool ready = false;

void start() {
	StatusType rv;
	switch (GetCoreID()) {
	case OS_CORE_ID_MASTER:
		StartCore(OS_CORE_ID_1, &rv);
	default:
		StartOS(0);
	}
}

TEST_MAKE_OS_MAIN(start())

TASK(T00) {
	test_trace('0');

	arch::Perf::start();
	arch::Perf::reset_counters();
	arch::Perf::reset();
	arch::Perf::trace_cycles();
	ready = true;
	while (1) {
		arch::Perf::reset();
	}
	TerminateTask();
}

TASK(T01) {
	arch::Perf::trace_cycles();
	test_trace('2');
	arch::Perf::stop();
	arch::Perf::print_cycles();
	test_trace_assert("012");
	test_finish();
	ShutdownAllCores(E_OK);
}

TASK(T10) {
	while (!ready) {
		Machine::nop();
	}
	test_trace('1');
	ActivateTask(T01);
	TerminateTask();
}

