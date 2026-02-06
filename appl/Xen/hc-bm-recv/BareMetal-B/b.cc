#include <stdint.h>
#include "bare_metal/os.h"
#include "xen/events.h"

extern "C" void callback(void* priv) {
  	ara_timing_info(10, 20);
	printf("Received hmi_update!\n");
	
    BareMetal_Idle();
}	


int main(int argc, char *argv[])
{   
    printf("Starting binder.\n");

	domid_t REMOTE_DOMAIN = 0;
	channel_t REMOTE_CHANNEL = 42;

  	ara_timing_info(20, 30);
    wrap_evtchn_bind_interdomain(REMOTE_DOMAIN, REMOTE_CHANNEL, (void *) callback);
    
  	ara_timing_info(20, 30);
    BareMetal_Idle();
}


