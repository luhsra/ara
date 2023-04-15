// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

/**
 * @file
 * @ingroup posix
 * @brief Default output streams
 */

#include "output.h"

#if DEBUG

BufferedTerminal kout(Terminal::STDOUT, false);
BufferedTerminal debug(Terminal::STDERR, false);

BufferedTerminal debug_core_arr[MAX_CPUS];

#else // DEBUG

BufferedTerminal kout(Terminal::STDOUT, false);
Null_Stream debug;

#endif // DEBUG
