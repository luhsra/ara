#include "autosar/os.h"
#include "test/test.h"

/* Priority Ceiling Protocol example from "Real-Time Systems" from Liu
 *
 * Note that the PCP described in the book works different of the protocol specified by AUTOSAR. Leaving this here as interesting example anyway.
 */

DeclareTask(J1);
DeclareTask(J2);
DeclareTask(J3);
DeclareResource(black);
DeclareResource(dotted);
DeclareResource(shaded);

TEST_MAKE_OS_MAIN(StartOS(0))

TASK(J1) {
	GetResource(dotted);
	ReleaseResource(dotted);
	TerminateTask();
}

TASK(J2) {
	GetResource(black);
	ReleaseResource(black);
	GetResource(shaded);
	ReleaseResource(shaded);
	GetResource(black);
	ReleaseResource(black);
	TerminateTask();
}

TASK(J3) {
	GetResource(shaded);
	ActivateTask(J2);
	ReleaseResource(shaded);
	GetResource(black);
	ActivateTask(J1);
	ReleaseResource(black);
	GetResource(shaded);
	ReleaseResource(shaded);
	TerminateTask();
}
