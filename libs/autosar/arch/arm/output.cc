// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

/**
 * @file
 * @ingroup i386
 * @brief Default output streams
 */

#include "output.h"

#include "os.h"

#if DEBUG

BufferedSerial kout{false};
BufferedSerial debug{false};
BufferedSerial debug_core_arr[MAX_CPUS];

#else // DEBUG

Serial kout;
Null_Stream debug;
Null_Stream debug_core;

#endif // DEBUG
