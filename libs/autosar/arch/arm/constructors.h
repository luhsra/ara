// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef _UTIL_CONSTRUCTORS_H
#define _UTIL_CONSTRUCTORS_H
/**
 *  @ingroup arch
 *  @defgroup generic Generic architecture functionalities
 *  @brief Generic hardware near implementations.
 *
 *  This includes, for example, the execution of global constructors.
 */

/**
 * @file
 * @ingroup generic
 * @brief Run global constructors at system startup.
 */

extern "C" {
/**
 * @brief To be execute at startup.
 */
void run_constructors();
}
#endif
