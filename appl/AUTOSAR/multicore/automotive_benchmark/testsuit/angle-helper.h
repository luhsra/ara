// SPDX-FileCopyrightText: 2025 Mareike Burg
//
// SPDX-License-Identifier: GPL-3.0-or-later

/**
 ******************** RUN VARIABLES ********************
 */
static uint32_t angle_calculate_until = 0;
static uint32_t angle_time_when_stopped = 0;

/**
 ******************** DEBUG VARIABLES ********************
 */
#define ANGLE
#ifdef PRINT_RUN_STATS 
    static unsigned angle_start_counter = 0;
    static unsigned angle_blocked_counter = 0;
    static unsigned angle_finish_counter = 0;
#endif

#ifdef PRINT_TASK_TIMING
    static unsigned int angle_cycle_count = 0;
    static unsigned int angle_task_time[CYCLES] = {0};
#endif