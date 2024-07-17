// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "bufferedserial.h"
#include "spinlock.h"
#include "serial.h"

os::Spinlock BufferedSerial::serial_spinlock{};

void memset(void* dest, int pat, int size) {
	uint8_t pattern = (uint8_t)pat;
	uint8_t* destination = (uint8_t*)dest;

	for (int i = 0; i != size; ++i) {
		destination[i] = pattern;
	}
}

void BufferedSerial::putchar(char character) {
	if (this->printcpu) {
		if (idx == 0) {
			int cpuid = arch::get_cpuid();
			buf[idx++] = cpuid + (cpuid > 9 ? 55 : '0');
			buf[idx++] = ':';
		}
	}
	buf[idx++] = character;
//
	if (idx >= BUF_LEN - 1) {
		character = '\n';
		buf[idx++] = character;
	}

	if (character == '\n') {
		//int current_prio = arch::GIC::get_task_prio();
		//arch::GIC::set_task_prio(0); // pause interrupts
		BufferedSerial::serial_spinlock.lock();
		Serial::puts(buf);
		BufferedSerial::serial_spinlock.unlock();
		memset(buf, 0x00, BUF_LEN);
	}
}

void BufferedSerial::puts(const char* data) {
	while (*data) putchar(*data++);
}



