// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef __OS_KRN_HELPER
#define __OS_KRN_HELPER

#include "machine.h"

/**
 * @file
 * @ingroup os
 * @brief Helper functions not defined in OSEK, that can be called
 * from the application
 */

static void forceinline ShutdownMachine(void) { Machine::shutdown(); }

#endif
