// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef SIGNALINFO_H
#define SIGNALINFO_H

/* signal_functions.h
   Header file for signal_functions.c.
*/

#include <signal.h>

int printSigMask(const char* msg);

int printPendingSigs(const char* msg);

void printSigset(const char* ldr, const sigset_t* mask);

#endif
