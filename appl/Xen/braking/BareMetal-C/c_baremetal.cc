#include <stdint.h>
#include "bare_metal/os.h"
#include "xen/events.h"

extern "C" void hmi_update(void* priv) {
	printf("Received hmi_update!\n");
	ara_timing_info(5, 5);
    BareMetal_Idle();
}	

extern "C" void driver_input(void* priv) {
	printf("Driver Input\n");
	ara_timing_info(10, 10);
    BareMetal_Idle();
}	

// void display() {
//     return;
// }

int main(int argc, char *argv[])
{   
    printf("Starting binder.\n");

    // in analysis this values are hard coded
    int remote_domain;
    remote_domain = 1;
	domid_t REMOTE_DOMAIN = remote_domain;
	channel_t REMOTE_CHANNEL = 44;

	ara_timing_info(5, 5);
    wrap_evtchn_bind_interdomain(REMOTE_DOMAIN, REMOTE_CHANNEL, (void *) hmi_update);

    // display();
	ara_timing_info(3, 3);
    BareMetal_Idle();
}
