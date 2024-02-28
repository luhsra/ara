#include "autosar/os.h"
#include "perf.h"
#include "test/test.h"

DeclareTask(T00);
DeclareTask(T10);

extern "C" const int PERF_TRACE = arch::Perf::trace::SYSCALL;

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
	arch::Perf::trace_cycles();
	ActivateTask(T10);
	arch::Perf::trace_cycles();
	arch::Perf::stop();
	arch::Perf::print_cycles();
	test_trace_assert("01");
	test_ne(arch::Perf::get_cycles(), 0);
	test_finish();
	ShutdownOS(E_OK);
}

TASK(T10) {
	test_trace('1');
	ShutdownOS(E_OK);
}
