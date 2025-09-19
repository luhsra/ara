void callback(void* priv) {
	printf("Received callback!\n");
}	

int main(int argc, char *argv[])
{   
    printf("Starting binder.\n");

    domid_t REMOTE_DOMAIN = 0;
	channel_t REMOTE_CHANNEL = 42;

    wrap_evtchn_bind_interdomain(remote_domain, REMOTE_CHANNEL, callback);

    printf("Binder is done, handler was forked.\n");
}