
/*
 * Minimal Bare Metal OS App
 */

#include "bare_metal/os.h"
#include "xen/events.h"

domid_t remote_dom = 1;
channel_t channel = 42;

extern "C" void event(void* priv) {
  	ara_timing_info(55, 65);
	printf("Event!\n");
	
    BareMetal_Idle();
}	

int main(){
  	ara_timing_info(15, 25);
	printf("A\n");

	XEN_wrap_evtchn_bind_interdomain(remote_dom, channel, (void *) event);

  	ara_timing_info(35, 45);
	printf("A2\n");
	
    BareMetal_Idle();
}
