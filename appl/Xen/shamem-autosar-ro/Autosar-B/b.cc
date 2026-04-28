#include "autosar/os.h"
#include "xen/events.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(B);
domid_t sharing_dom = 0;
shared_memory_id id = 42;

int main(void) {
	StartOS(0);
}

TASK(B) {

  	ara_timing_info(30, 40);
	kout << "B"<< endl;

	// TODO: define memory here
	hypersse_shared_memory mem = nullptr;
	XEN_wrap_receive_memory(sharing_dom, id, mem);

  	ara_timing_info(80, 90);
	kout << "B2"<< endl;

	XEN_wrap_annotate_shared_read(id);

  	ara_timing_info(5, 10);
	kout << "B3"<< endl;

	TerminateTask();
}
