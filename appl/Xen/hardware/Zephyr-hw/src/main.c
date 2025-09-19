#include <zephyr/kernel.h>
#include <zephyr/events.h>

domid_t REMOTE_DOMAIN = 0;
channel_t REMOTE_CHANNEL = 42;

void callback(void* priv) {
	printk("Callback!\n");
}	

int main(void)
{
	XEN_wrap_evtchn_bind_interdomain(REMOTE_DOMAIN, REMOTE_CHANNEL, callback);

	XEN_wrap_evtchn_send(REMOTE_CHANNEL);

	return 0;
}
