#include "autosar/os.h"
#include "test/test.h"

#include <sys/sysinfo.h>
void start() {
	StatusType rv;
	switch (GetCoreID()) {
	case OS_CORE_ID_MASTER:
		StartCore(OS_CORE_ID_1, &rv);
		StartCore(OS_CORE_ID_2, &rv);
		StartCore(OS_CORE_ID_3, &rv);
		StartCore(OS_CORE_ID_4, &rv);
		StartCore(OS_CORE_ID_5, &rv);
		StartCore(OS_CORE_ID_6, &rv);
		StartCore(OS_CORE_ID_7, &rv);
		StartCore(OS_CORE_ID_8, &rv);
		StartCore(OS_CORE_ID_9, &rv);
		StartCore(OS_CORE_ID_10, &rv);
		StartCore(OS_CORE_ID_11, &rv);
	default:
		StartOS(0);
	}
}

TEST_MAKE_OS_MAIN(start())

TASK(T0) {
	int cores = GetNumberOfActivatedCores();
	test_init();
	test_start();
	int expected_cores = get_nprocs() < 12 ? get_nprocs() : 12;
	test_eq(cores, expected_cores);
	test_positive_tests_eq(1);
	test_finish();
	ShutdownAllCores(E_OK);
}
