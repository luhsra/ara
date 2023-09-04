// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include <stdint.h>
typedef unsigned int size_t;

extern "C" void memcpy(void* dest, void const* src, size_t size) {
	uint8_t* destination = (uint8_t*)dest;
	uint8_t const* source = (uint8_t const*)src;

	for (size_t i = 0; i != size; ++i) {
		destination[i] = source[i];
	}
}

extern "C" void memmove(void* dest, void const* src, size_t size) {
	uint8_t* destination = (uint8_t*)dest;
	uint8_t const* source = (uint8_t const*)src;

	if (source > destination) {
		for (size_t i = 0; i != size; ++i) {
			destination[i] = source[i];
		}
	} else {
		for (size_t i = size; i != 0; --i) {
			destination[i - 1] = source[i - 1];
		}
	}
}

extern "C" void memset(void* dest, int pat, size_t size) {
	uint8_t pattern = (uint8_t)pat;
	uint8_t* destination = (uint8_t*)dest;

	for (size_t i = 0; i != size; ++i) {
		destination[i] = pattern;
	}
}
