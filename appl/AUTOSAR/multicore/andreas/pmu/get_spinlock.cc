#include "autosar/os.h"
#include "pmu.h"
#include "test/test.h"

DeclareTask(T00);
DeclareSpinlock(S1);

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
	arch::PMU::start();
	arch::PMU::trace_cycles();
	GetSpinlock(S1);
	arch::PMU::trace_cycles();
	ReleaseSpinlock(S1);
	arch::PMU::trace_cycles();

	arch::PMU::stop();
	arch::PMU::print_cycles();

	ShutdownOS(E_OK);
}


