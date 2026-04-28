#include "autosar/os.h"
#include "xen/events.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(A);
domid_t receiver_dom_b = 1;
shared_memory_id id_b = 42;
domid_t receiver_dom_c = 2;
shared_memory_id id_c = 43;
domid_t receiver_dom_d = 3;
shared_memory_id id_d = 44;

int main(void) {
	StartOS(0);
}

TASK(A) {

	ara_timing_info(10, 20);

	// TODO: define memory here
	hypersse_shared_memory mem = nullptr;
	XEN_wrap_share_memory(receiver_dom_b, id_b, mem);

	ara_timing_info(3, 5);
	XEN_wrap_share_memory(receiver_dom_c, id_c, mem);

	ara_timing_info(3, 5);
	XEN_wrap_share_memory(receiver_dom_d, id_d, mem);


	ara_timing_info(300, 350);

	XEN_wrap_shared_write(id_b);
	ara_timing_info(10, 20);

	XEN_wrap_shared_write(id_c);
	ara_timing_info(75, 85);

	XEN_wrap_shared_write(id_d);
	ara_timing_info(5, 10);

	TerminateTask();
}
