// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later
#pragma once

#include "atomics.h"

namespace os {
	class Ticketlock {
	  private:
		volatile unsigned int ticket;
		volatile unsigned int turn;

	  public:
		Ticketlock() {
			this->ticket = 0;
			this->turn = 0;
		}

		void lock() {
			unsigned int my_ticket = __sync_fetch_and_add(&ticket, 1);

			while (my_ticket != turn) {
				// Spin-wait until it's our turn
				asm volatile("nop");
			}
		}

		void unlock() {
			// Increment the turn to allow the next ticket holder to enter
			__sync_fetch_and_add(&turn, 1);
		}
	};

} // namespace os