
#ifndef _BARE_METAL_OS_H_
#define _BARE_METAL_OS_H_


/* This file includes common headers/extern and annotation syscall. */

/* Ara specific annotations */
void ara_timing_info(int a, int b);

/* Syscalls */
extern "C" void BareMetal_Idle();
extern "C" void BareMetal_Dummy(int);

/* Hypercall wrappers */
#define wrap_evtchn_alloc_unbound(remote_dom, channel, cb) XEN_wrap_evtchn_alloc_unbound(remote_dom, channel, cb)
#define wrap_evtchn_bind_interdomain(remote_dom, channel, cb) XEN_wrap_evtchn_bind_interdomain(remote_dom, channel, cb)
#define wrap_evtchn_send(channel) XEN_wrap_evtchn_send(channel)
#define wrap_evtchn_poll(channel, is_branch) XEN_wrap_evtchn_poll(channel, is_branch)

/* Other */
extern int printf (const char *__restrict __format, ...);

#endif
