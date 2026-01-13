/*
 * Copyright (c) 2021 EPAM Systems
 * Copyright (c) 2022 Arm Limited (or its affiliates). All rights reserved.
 * SPDX-FileCopyrightText: 2025 Mareike Burg
 * 
 * SPDX-License-Identifier: Apache-2.0
 */
#ifndef __XEN_EVENTS_H__
#define __XEN_EVENTS_H__

#include "event_channel.h"

/*
 * Since current OSs do not implement Xen, this wrapper is used for analysis. Applications import this file
 * and can use the provided syscalls, and the analysis is able to simulate it. For a HW-deployment, the wrapper 
 * syscalls would need to be included in the respective OS (for example Autosar).
 */

#ifdef __cplusplus
extern "C" {
#endif

	// Function that is triggered on the event. An OS-specific implementation might add a instead add an interrupt
	typedef void * evtchn_cb_t;

	// This wrapper uses different id than the ports from Xen, to allow multiple connections/channels between two guests.
	// A real OS implementation would need to map this new ports towards the ports it receives from the hypercalls
	typedef int channel_t;


	void XEN_wrap_evtchn_alloc_unbound(domid_t remote_dom, channel_t channel, evtchn_cb_t cb) {
		/**
		 * Create a new event channel
		 * @param domid_t remote_dom: target domain
		 * @param channel_t channel: choosen channel, needs to be the same for sender/receiver
		 * @param evtchn_cb_t cb: callback routine that is executed when signal is received
		 * @return a real syscall would return its status code here
		 */

		// TODO - only proof of concept
		/*
		struct evtchn_alloc_unbound event; 
		event.dom = GET_OWN_DOM_ID;
		event.remote_dom = remote_dom;

		evtchn_port_t port;
		if (port = HYPERVISOR_event_channel_op(EVTCHNOP_alloc_unbound, &event) != 0){
			// error handling
		}
		OS-SPECIFIC_map(channel, port);
		xen_store_write(port);
		*/
	}

	void XEN_wrap_evtchn_bind_interdomain(domid_t remote_dom, channel_t channel, evtchn_cb_t cb) {
		/**
		 * Bind to a new event channel
		 * @param domid_t remote_dom: target domain
		 * @param channel_t channel: choosen channel, needs to be the same for sender/receiver
		 * @param evtchn_cb_t cb: callback routine that is executed when signal is received
		 * @return a real syscall would return its status code here
		 */

		// TODO - only proof of concept
		/*
		evtchn_port_t remote_port = xen_store_read(port);

		struct evtchn_bind_interdomain event; 
		event.remote_dom = remote_dom;
		event.remote_port = remote_port;

		evtchn_port_t local_port;
		if (local_port = HYPERVISOR_event_channel_op(EVTCHNOP_bind_interdomain, &event) != 0){
			// error handling
		}
		OS-SPECIFIC_map(channel, local_port);
		*/
	}

	void XEN_wrap_evtchn_send(channel_t channel) {
		/**
		 * Send event on an existing channel
		 * @param channel_t channel: choosen channel
		 * @return a real syscall would return its status code here
		 */

		// TODO - only proof of concept
		/*
		evtchn_port_t port = OS-SPECIFIC_retrieve(channel);

		struct evtchn_send event;
		event.port = port;

		if (HYPERVISOR_event_channel_op(evtchn_send, &event) != 0){
			// error handling
		}
		*/
	}

#ifdef __cplusplus
}
#endif


// -----------------------------------------------------------------------------------

/*
 * Following functions just wrap Xen hypercalls, detailed description
 * of parameters and return values are located in include/xen/public/event_channel.h
 */
int evtchn_status(evtchn_status_t *status);
int evtchn_close(evtchn_port_t port);
int evtchn_set_priority(evtchn_port_t port, unsigned int priority);
void notify_evtchn(evtchn_port_t port)
{
	// TODO
	return;
}

/*
 * Allocate event-channel between caller and remote domain
 *
 * @param remote_dom - remote domain domid
 * @return - local event channel port on success, negative on error
 */
int alloc_unbound_event_channel(domid_t remote_dom);


/*
 * Allocate local event channel, binded to remote port and attach specified callback
 * to it
 *
 * @param remote_dom - remote domain domid
 * @param remote_port - remote domain event channel port number
 * @param cb - callback, attached to locat port
 * @param data - private data, that will be passed to cb
 * @return - local event channel port on success, negative on error
 */
int bind_interdomain_event_channel(domid_t remote_dom, evtchn_port_t remote_port,
		evtchn_cb_t cb, void *data)
{
	return 10; //TODO
}

/*
 * Bind user-defined handler to specified event-channel
 *
 * @param port - event channel number
 * @param cb - pointer to event channel handler
 * @param data - private data, that will be passed to handler as parameter
 * @return - zero on success
 */
int bind_event_channel(evtchn_port_t port, evtchn_cb_t cb, void *data);

/*
 * Unbind handler from event channel, substitute it with empty callback
 *
 * @param port - event channel number to unbind
 * @return - zero on success
 */
int unbind_event_channel(evtchn_port_t port);
int get_missed_events(evtchn_port_t port);

int xen_events_init(void)
{
	//TODO
	return 0;
}

#endif /* __XEN_EVENTS_H__ */
