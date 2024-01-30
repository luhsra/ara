// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef __BUFFEREDSERIAL_H__
#define __BUFFEREDSERIAL_H__

/**
 * @file
 *
 * @ingroup ARM
 *
 * \brief Serial driver with buffer
 */

#include "arch/generic/ostream.h"
#include "hardware_threads.h"
#include "serial.h"
#include "ticketlock.h"

#define BUF_LEN 80

class BufferedSerial : public O_Stream<BufferedSerial> {
  public:
	char buf[BUF_LEN] = {0};
	int idx = 0;
	bool printcpu = false;

	static os::Ticketlock serial_spinlock;

  public:
	BufferedSerial(bool printcpu = false) : printcpu(printcpu){};
	void putchar(char character);
};

#endif
