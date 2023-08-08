#include "autosar/os.h"
#include "test/test.h"

DeclareTask(H1);
DeclareTask(H2);
DeclareResource(R1);


TEST_MAKE_OS_MAIN(StartOS(0))

int unknown_condition();

TASK(H1) {
	GetResource(R1);
	ReleaseResource(R1);
	TerminateTask();
}

TASK(H2) {
	GetResource(R1);
	TerminateTask();
}
