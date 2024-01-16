// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "pmu.h"

int arch::PMU::cycles[MAX_TRACES] = {0};
int arch::PMU::cycles_nr = 0;
int arch::PMU::counter0[MAX_TRACES] = {0};
int arch::PMU::counter0_nr = 0;