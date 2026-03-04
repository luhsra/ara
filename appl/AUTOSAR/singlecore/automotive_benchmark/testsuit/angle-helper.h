// SPDX-FileCopyrightText: 2025 Mareike Burg
//
// SPDX-License-Identifier: GPL-3.0-or-later

/**
 ******************** STATIC VARIABLES ********************
 */
// Angle Sync Values, assume the worst case, so the shortest period.
constexpr unsigned CYLINDERS = 4;
constexpr unsigned MIN_RPM = 1000;
constexpr unsigned MAX_RPM = 3000;
// Formular is 120/(CYLINDERS*RPM)

// in ms -> every 30ms angle sync calculation is needed
constexpr unsigned LONGEST_ANGLE_SYNC_PERIOD = 1000 * 120 / (CYLINDERS * MIN_RPM);
// in ms -> every 10ms angle sync calculation is needed
constexpr unsigned SHORTEST_ANGLE_SYNC_PERIOD = 1000 * 120 / (CYLINDERS * MAX_RPM);
// Average angle sync period, used for trig-angle testcase
constexpr unsigned ANGLE_SYNC_PERIOD = (SHORTEST_ANGLE_SYNC_PERIOD + LONGEST_ANGLE_SYNC_PERIOD) / 2;

/**
 ******************** RUN VARIABLES ********************
 */
static uint32_t angle_calculate_until = 0;
static uint32_t angle_time_when_stopped = 0;

/**
 ******************** DEBUG VARIABLES ********************
 */
#define ANGLE

#if defined(PRINT_RUN_STATS) || defined(BENCHMARK) 
    static unsigned angle_start_counter = 0;
    static unsigned angle_blocked_counter = 0;
    static unsigned angle_finish_counter = 0;
#endif

#ifdef PRINT_TASK_TIMING
    static unsigned int angle_cycle_count = 0;
    static unsigned int angle_task_time[CYCLES] = {0};
#endif
