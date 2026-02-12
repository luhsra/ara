#include <zephyr/kernel.h>
#include "events.h" // from ara/libs/xen

void ara_timing_info(int a, int b);

// unsed callback 
void callback(void* priv) {
	ara_timing_info(700, 800);
	printf("Callback!\n");
}	

int main(void)
{
	domid_t REMOTE_DOMAIN = 0;
	channel_t REMOTE_CHANNEL = 42;

	ara_timing_info(100, 200);
	XEN_wrap_evtchn_alloc_unbound(REMOTE_DOMAIN, REMOTE_CHANNEL, callback);

	ara_timing_info(300, 400);
	XEN_wrap_evtchn_send(REMOTE_CHANNEL);

	ara_timing_info(500, 600);
	return 0;
}
