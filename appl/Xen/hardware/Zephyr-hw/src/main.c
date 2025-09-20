#include <zephyr/kernel.h>
#include <zephyr/events.h>

void ara_timing_info(int a, int b);

// unsed callback 
void callback(void* priv) {
	printf("Callback!\n");
}	

int main(void)
{
	domid_t REMOTE_DOMAIN = 0;
	channel_t REMOTE_CHANNEL = 42;

	ara_timing_info(10, 20);
	XEN_wrap_evtchn_alloc_unbound(REMOTE_DOMAIN, REMOTE_CHANNEL, callback);

	ara_timing_info(30, 40);
	XEN_wrap_evtchn_send(REMOTE_CHANNEL);

	ara_timing_info(50, 60);
	return 0;
}
