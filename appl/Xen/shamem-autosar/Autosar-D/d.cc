#include "autosar/os.h"
#include "xen/events.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(D);
domid_t sharing_dom = 0;
shared_memory_id id = 44;

int main(void) {
	StartOS(0);
}

// Reads after Write
TASK(D) {

  	ara_timing_info(55, 60);

	// TODO: define memory here
	hypersse_shared_memory mem = nullptr;
	XEN_wrap_receive_memory(sharing_dom, id, mem);

  	ara_timing_info(350, 450);
	XEN_wrap_annotate_shared_read(id);

  	ara_timing_info(5, 10);
	TerminateTask();
}
