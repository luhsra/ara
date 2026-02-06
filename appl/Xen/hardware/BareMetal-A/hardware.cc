#include <stdint.h>
#include "bare_metal/os.h"
#include "xen/events.h"

extern "C" void callback(void* priv) {
	ara_timing_info(25, 35);
	printf("Received callback!\n");
    BareMetal_Idle();
}	

int main(int argc, char *argv[])
{   
    printf("Starting binder.\n");

    // in analysis this values are hard coded
    int remote_domain;
    // if (argc != 2) {
    //     printf("Usage: %s remote_domain\n", argv[0]);
    //     return 1;
    // }
    // if (sscanf(argv[1], "%d", &remote_domain) != 1) {
    //     printf("Invalid remote_domain: %s\n", argv[1]);
    //     return 1;
    // }
    remote_domain = 1;
	domid_t REMOTE_DOMAIN = remote_domain;
	channel_t REMOTE_CHANNEL = 42;

	ara_timing_info(5, 10);
    wrap_evtchn_bind_interdomain(REMOTE_DOMAIN, REMOTE_CHANNEL, (void *) callback);

	ara_timing_info(15, 20);
    printf("Binder is done, handler was forked.\n");
    BareMetal_Idle();
}