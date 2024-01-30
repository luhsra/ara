#include "autosar/os.h"
#include "test/test.h"

int expected_cores = 12;

void start() {
	StatusType rv;
	switch (GetCoreID()) {
	case OS_CORE_ID_MASTER:
		StartCore(OS_CORE_ID_1, &rv);
		if (rv != E_OK) expected_cores--;
		StartCore(OS_CORE_ID_2, &rv);
		if (rv != E_OK) expected_cores--;
		StartCore(OS_CORE_ID_3, &rv);
		if (rv != E_OK) expected_cores--;
		StartCore(OS_CORE_ID_4, &rv);
		if (rv != E_OK) expected_cores--;
		StartCore(OS_CORE_ID_5, &rv);
		if (rv != E_OK) expected_cores--;
		StartCore(OS_CORE_ID_6, &rv);
		if (rv != E_OK) expected_cores--;
		StartCore(OS_CORE_ID_7, &rv);
		if (rv != E_OK) expected_cores--;
		StartCore(OS_CORE_ID_8, &rv);
		if (rv != E_OK) expected_cores--;
		StartCore(OS_CORE_ID_9, &rv);
		if (rv != E_OK) expected_cores--;
		StartCore(OS_CORE_ID_10, &rv);
		if (rv != E_OK) expected_cores--;
		StartCore(OS_CORE_ID_11, &rv);
		if (rv != E_OK) expected_cores--;
	default:
		StartOS(0);
	}
}

TEST_MAKE_OS_MAIN(start())

TASK(T0) {
	int cores = GetNumberOfActivatedCores();
	test_init();
	test_start();
	test_eq(cores, expected_cores);
	test_positive_tests_eq(1);
	test_finish();
	ShutdownAllCores(E_OK);
}
