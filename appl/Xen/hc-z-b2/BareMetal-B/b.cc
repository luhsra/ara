
/*
 * Minimal Bare Metal OS App
 */

#include "bare_metal/os.h"
#include "xen/events.h"

domid_t remote_dom = 0;
channel_t channel = 42;


int main(){

	ara_timing_info(10, 20);
	printf("B\n");

	XEN_wrap_evtchn_alloc_unbound(remote_dom, channel, nullptr);

	ara_timing_info(100, 110);
	printf("B2\n");

	XEN_wrap_evtchn_send(channel);

	ara_timing_info(30, 40);
	printf("B3\n");
    
    BareMetal_Idle();
}
