// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "machine.h"

#include "syscall.h"

using namespace arch;

void Machine::trigger_interrupt(uint8_t irq) { arch::GIC::trigger(irq); }

void Machine::trigger_interrupt_from_user(uint8_t irq) { arch::GIC::trigger(irq); }
