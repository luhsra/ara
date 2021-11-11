#include "autosar/os.h"
#include "test/test.h"

DeclareTask(H1);
DeclareTask(H2);
DeclareTask(H3);
DeclareTask(H4);
DeclareTask(H5);
DeclareResource(RES_SCHEDULER);
DeclareResource(R234);
DeclareResource(R345);


TEST_MAKE_OS_MAIN(StartOS(0))

TASK(H1) {
	TerminateTask();
}

TASK(H2) {
	TerminateTask();
}

TASK(H3) {
	TerminateTask();
}

TASK(H4) {
	TerminateTask();
}


TASK(H5) {
	GetResource(R345);
	GetResource(R234);
	ReleaseResource(R234);
	ActivateTask(H2);
	ActivateTask(H4);
	ReleaseResource(R345);
	TerminateTask();
}
