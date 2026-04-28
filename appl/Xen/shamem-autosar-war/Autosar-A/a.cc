#include "autosar/os.h"
#include "xen/events.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(A);
domid_t receiver_dom_b = 1;
shared_memory_id id_b = 42;

int main(void) {
	StartOS(0);
}

TASK(A) {

	ara_timing_info(10, 20);

	// TODO: define memory here
	hypersse_shared_memory mem = nullptr;
	XEN_wrap_share_memory(receiver_dom_b, id_b, mem);

  	ara_timing_info(125, 150);
	XEN_wrap_shared_write(id_b);

	ara_timing_info(5, 10);
	TerminateTask();
}
