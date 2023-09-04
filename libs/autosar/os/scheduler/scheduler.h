// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

/**
 * @file

 * @brief Scheduler implementation
 */
#ifndef __SCHEDULER_H__
#define __SCHEDULER_H__

#include "dispatch.h"
#include "reschedule-ast.h"
#include "syscall.h"

extern "C" void __OS_ASTSchedule(int dummy);

#endif // __SCHEDULER_H__
