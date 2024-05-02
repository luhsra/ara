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
	static void putchar(char c);

	static void puts(const char* data);
};

#endif // __SERIAL_H__