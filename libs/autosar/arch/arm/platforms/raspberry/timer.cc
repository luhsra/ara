// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

/**
 * @file
 * @ingroup arm
 * @brief ARM Private Timer
 */

#include "timer.h"

#include "gic.h"
#include "os/counter.h"

extern "C" void PUT32(int, int);
extern "C" int GET32(int);

void enable_cntv(void) {
	uint32_t cntv_ctl;
	cntv_ctl = 1;
	asm volatile("mcr p15, 0, %0, c14, c3, 1" ::"r"(cntv_ctl)); // write CNTV_CTL
}

void disable_cntv(void) {
	uint32_t cntv_ctl;
	cntv_ctl = 0;
	asm volatile("mcr p15, 0, %0, c14, c3, 1" ::"r"(cntv_ctl)); // write CNTV_CTL
}

uint64_t read_cntvct(void) {
	uint64_t val;
	asm volatile("mrrc p15, 1, %Q0, %R0, c14" : "=r"(val));
	return (val);
}

uint64_t read_cntvoff(void) {
	uint64_t val;
	asm volatile("mrrc p15, 4, %Q0, %R0, c14" : "=r"(val));
	return (val);
}

uint32_t read_cntv_tval(void) {
	uint32_t val;
	asm volatile("mrc p15, 0, %0, c14, c3, 0" : "=r"(val));
	return val;
}

void write_cntv_tval(uint32_t val) {
	asm volatile("mcr p15, 0, %0, c14, c3, 0" ::"r"(val));
	return;
}

uint32_t forceinline read_cntfrq(void) {
	uint32_t val;
	asm volatile("mrc p15, 0, %0, c14, c0, 0" : "=r"(val));
	return val;
}

namespace arch {
	uint32_t Timer::cntfrq = 0;

	void Timer::init() {
		// Creates a timer that triggers every 1ms
		cntfrq = read_cntfrq() / 1000;
		// read_cntfrq -> 54000000 returns this, cntfrq -> 54000
		// kout << "Init Timer" << static_cast<unsigned int>(read_cntfrq()) << "cntfrq" <<  static_cast<unsigned int>(cntfrq) << endl;
		write_cntv_tval(cntfrq); // clear cntv interrupt and set 1 kHz timer.
		enable_cntv();

		GIC::set_irq_priority(IRQ_V_TIMER, IRQ_PRIO_LOCAL_TIMER);
		GIC::enable_irq(IRQ_V_TIMER);
	}

	void Timer::stop() { disable_cntv(); }

	void Timer::set_periodic(uint16_t rate_in_ms) {
		// TODO
	}

	void Timer::ack_isr() {
		write_cntv_tval(cntfrq); // clear cntv interrupt and set next 1sec timer.
	}

	IRQ_HANDLER(IRQ_V_TIMER) {
		(void)irq;

		Timer::ack_isr(); // acknowledge timer IRQ

		GIC::set_task_prio(IRQ_PRIO_LOWEST); // TODO: enable ISR2, in_syscall -> false
		os::Counter::tick();

		return task_sp;
	}

}; // namespace arch
