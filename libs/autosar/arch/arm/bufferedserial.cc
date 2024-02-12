// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "bufferedserial.h"
#include "gic.h"
#include "ticketlock.h"

os::Ticketlock BufferedSerial::serial_spinlock{};

extern "C" void memset(void* dest, int pat, size_t size);

void BufferedSerial::putchar(char character) {
	if (this->printcpu) {
		if (idx == 0) {
			int cpuid = arch::get_cpuid();
			buf[idx++] = cpuid + (cpuid > 9 ? 55 : '0');
			buf[idx++] = ':';
		}
	}
	buf[idx++] = character;

	if (idx == BUF_LEN - 1) {
		character = '\n';
		buf[idx++] = character;
	}

	if (character == '\n') {
		int current_prio = arch::GIC::get_task_prio();
		arch::GIC::set_task_prio(0); // pause interrupts
		BufferedSerial::serial_spinlock.lock();
		Serial::puts(buf);
		BufferedSerial::serial_spinlock.unlock();
		memset(buf, 0x00, BUF_LEN);

		idx = 0;
		arch::GIC::set_task_prio(current_prio);
	}
}
