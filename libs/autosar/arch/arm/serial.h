// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef __SERIAL_H__
#define __SERIAL_H__

/**
 * @file
 *
 * @ingroup ARM
 *
 * \brief Serial driver
 */

#include "arch/generic/ostream.h"

#include <stdint.h>

/** \brief  Colors (just copied from cga), actually not used */
typedef enum class Color {
	BLACK = 0,
	BLUE = 1,
	GREEN = 2,
	CYAN = 3,
	RED = 4,
	MAGENTA = 5,
	YELLOW = 6,
	WHITE = 15,
} Color;

class Serial : public O_Stream<Serial> {
  public:
	Serial();

	void putchar(char c);

	void puts(const char* data);

	template <typename T>
	void setcolor(__attribute__((unused)) T fg, __attribute__((unused)) T bg){};
};

#endif // __SERIAL_H__
