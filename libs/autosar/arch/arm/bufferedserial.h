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

class BufferedSerial : public Serial {
  public:
	char buf[BUF_LEN] = {0};
	int idx = 0;
	bool printcpu;

	static os::Ticketlock serial_spinlock;

  public:
	BufferedSerial(bool printcpu = true) : printcpu(printcpu){};
	virtual void putchar(char character) override;
};

#endif
