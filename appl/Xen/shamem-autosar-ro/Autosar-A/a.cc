#include "autosar/os.h"
#include "xen/events.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(A);
domid_t receiver_dom = 1;
shared_memory_id id = 42;

int main(void) {
	StartOS(0);
}

TASK(A) {

	ara_timing_info(10, 20);
	kout << "A"<< endl;

	// TODO: define memory here
	hypersse_shared_memory mem = nullptr;
	XEN_wrap_share_memory(receiver_dom, id, mem);

	ara_timing_info(100, 110);
	kout << "A2"<< endl;

	XEN_wrap_annotate_shared_read(id);

	ara_timing_info(15, 25);
	kout << "A3"<< endl;

	TerminateTask();
}
