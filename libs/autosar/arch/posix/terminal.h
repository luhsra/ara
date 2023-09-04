// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef __TERMINAL_H__
#define __TERMINAL_H__

/**
 * @file
 *
 * @ingroup posix
 *
 * \brief POSIX TERMINAL output on terminal
 */

#include "../generic/ostream.h"

#include <stdint.h>
#include <unistd.h>

class Terminal : public O_Stream<Terminal> {
  protected:
	const uint16_t m_channel;

  public:
	enum port_t { STDOUT = STDOUT_FILENO, STDERR = STDERR_FILENO };

	Terminal(port_t port) : m_channel(port){};

	virtual void putchar(char c);

	void puts(const char* data);
};

#endif // __TERMINAL_H__
