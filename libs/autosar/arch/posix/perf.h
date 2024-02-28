// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include "output.h"

namespace arch {
	class Perf {

	  public:
		enum trace {
			NONE = 0,
			SYSCALL = 1,
			IRQ = 2
		};

		static forceinline void start() {}
		static forceinline void reset() {}
		static forceinline void trace_cycles() {}
		static forceinline unsigned int get_cycles() { return 0;}
		static forceinline void trace_counter0() {}
		static forceinline void stop() {}
		static forceinline void reset_counters() {}
		static forceinline void print_cycles() {}
		static forceinline void print_counter0() {}
	};
} // namespace arch