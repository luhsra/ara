#include "autosar/os.h"
#include "perf.h"
#include "test/test.h"

DeclareTask(T00);

void start() {
	StatusType rv;
	switch (GetCoreID()) {
	case OS_CORE_ID_MASTER:
		//StartCore(OS_CORE_ID_1, &rv);
	default:
		StartOS(0);
	}
}

TEST_MAKE_OS_MAIN(start())

TASK(T00) {
	arch::Perf::start();
	arch::Perf::trace_counter0();
    arch::Perf::trace_cycles();

	test_trace('a');

	arch::Perf::trace_counter0();
	arch::Perf::trace_cycles();
	arch::Perf::stop();
	arch::Perf::print_counter0();
	arch::Perf::print_cycles();

	int cycles = arch::Perf::get_cycles();
	test_ne(cycles, 0);
	test_finish();
	ShutdownOS(E_OK);
}
