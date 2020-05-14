#pragma once

/**
 * @file
 *
 * @ingroup ARM
 *
 * \brief Serial driver
 */

// #include <stdint.h>
#include "ostream.h"

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

	void init(void);

	void putchar(char c);

	void puts(const char* data);

	template <typename T>
	void setcolor(__attribute__((unused)) T fg, __attribute__((unused)) T bg);
};
