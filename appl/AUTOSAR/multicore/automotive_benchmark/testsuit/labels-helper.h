// SPDX-FileCopyrightText: 2025 Mareike Burg
//
// SPDX-License-Identifier: GPL-3.0-or-later

/**
 ******************** STATIC VARIABLES ********************
 */

// Size of a single label in Byte, calculated by (1*35+2*49+4*13+8*0.8+16*1.3+32*0.5+64*0.2+128*0.2)/ 100 -> 2.66 Byte
// 90% of Labels are 1,2,4 Bytes, calculated average was 3 Bytes
constexpr unsigned AVAERAGE_LABEL_SIZE = 3;
constexpr unsigned LABELS_PER_RUNABLE = NUMBER_OF_LABELS / NUMBER_OF_RUNABLES;

// Of that: 40% read, 10% write, 50% read/write
constexpr unsigned RO_SHARE = 40;
// constexpr unsigned WO_SHARE = 10; // ignored for now
constexpr unsigned RW_SHARE = 50;
constexpr unsigned RO_MEMORY = (NUMBER_OF_LABELS / 100) * RO_SHARE * AVAERAGE_LABEL_SIZE;
// constexpr unsigned WO_MEMORY = (NUMBER_OF_LABELS / 100) * WO_SHARE * AVAERAGE_LABEL_SIZE; // ignored for now
constexpr unsigned INTERCOM_MEMORY = (NUMBER_OF_LABELS / 100) * RW_SHARE * AVAERAGE_LABEL_SIZE;

constexpr unsigned ro_memory_size[NR_TASKS] = {
	(RO_MEMORY / 100) * RUNABLES_SHARE[MS1_id],
	(RO_MEMORY / 100) * RUNABLES_SHARE[MS2_id],
	(RO_MEMORY / 100) * RUNABLES_SHARE[MS5_id],
	(RO_MEMORY / 100) * RUNABLES_SHARE[MS10_id],
	(RO_MEMORY / 100) * RUNABLES_SHARE[MS20_id],
	(RO_MEMORY / 100) * RUNABLES_SHARE[MS50_id],
	(RO_MEMORY / 100) * RUNABLES_SHARE[MS100_id],
	(RO_MEMORY / 100) * RUNABLES_SHARE[MS200_id],
	(RO_MEMORY / 100) * RUNABLES_SHARE[MS1000_id],
	(RO_MEMORY / 100) * RUNABLES_SHARE[MSANGLE_id]
};
// Final one is end of memory -> cant write further
constexpr unsigned ro_memory_offset[NR_TASKS + 1] = {
	0,
	ro_memory_offset[0] + ro_memory_size[MS1_id],
	ro_memory_offset[1] + ro_memory_size[MS2_id],
	ro_memory_offset[2] + ro_memory_size[MS5_id],
	ro_memory_offset[3] + ro_memory_size[MS10_id],
	ro_memory_offset[4] + ro_memory_size[MS20_id],
	ro_memory_offset[5] + ro_memory_size[MS50_id],
	ro_memory_offset[6] + ro_memory_size[MS100_id],
	ro_memory_offset[7] + ro_memory_size[MS200_id],
	ro_memory_offset[8] + ro_memory_size[MS1000_id],
	ro_memory_offset[9] + ro_memory_size[MSANGLE_id]
};

// Write only memory skipped for now, since it is only 10% and hard to measure.
// constexpr unsigned wo_memory_size[NR_TASKS] = {
// 	(WO_MEMORY / 100) * RUNABLES_SHARE[MS1_id],
// 	(WO_MEMORY / 100) * RUNABLES_SHARE[MS2_id],
// 	(WO_MEMORY / 100) * RUNABLES_SHARE[MS5_id],
// 	(WO_MEMORY / 100) * RUNABLES_SHARE[MS10_id],
// 	(WO_MEMORY / 100) * RUNABLES_SHARE[MS20_id],
// 	(WO_MEMORY / 100) * RUNABLES_SHARE[MS50_id],
// 	(WO_MEMORY / 100) * RUNABLES_SHARE[MS100_id],
// 	(WO_MEMORY / 100) * RUNABLES_SHARE[MS200_id],
// 	(WO_MEMORY / 100) * RUNABLES_SHARE[MS1000_id],
// 	(WO_MEMORY / 100) * RUNABLES_SHARE[MSANGLE_id]
// };
// Final one is end of memory -> cant write further
// constexpr unsigned wo_memory_offset[NR_TASKS + 1] = {
// 	0,
// 	wo_memory_offset[0] + wo_memory_size[MS1_id],
// 	wo_memory_offset[1] + wo_memory_size[MS2_id],
// 	wo_memory_offset[2] + wo_memory_size[MS5_id],
// 	wo_memory_offset[3] + wo_memory_size[MS10_id],
// 	wo_memory_offset[4] + wo_memory_size[MS20_id],
// 	wo_memory_offset[5] + wo_memory_size[MS50_id],
// 	wo_memory_offset[6] + wo_memory_size[MS100_id],
// 	wo_memory_offset[7] + wo_memory_size[MS200_id],
// 	wo_memory_offset[8] + wo_memory_size[MS1000_id],
// 	wo_memory_offset[9] + wo_memory_size[MSANGLE_id]
// };

#ifndef READ_ONLY
    // Total number of bytes of each task for intercom
    constexpr unsigned intercom_memory_size[NR_TASKS] = {
        (INTERCOM_MEMORY / 100) * RUNABLES_SHARE[MS1_id],
        (INTERCOM_MEMORY / 100) * RUNABLES_SHARE[MS2_id],
        (INTERCOM_MEMORY / 100) * RUNABLES_SHARE[MS5_id],
        (INTERCOM_MEMORY / 100) * RUNABLES_SHARE[MS10_id],
        (INTERCOM_MEMORY / 100) * RUNABLES_SHARE[MS20_id],
        (INTERCOM_MEMORY / 100) * RUNABLES_SHARE[MS50_id],
        (INTERCOM_MEMORY / 100) * RUNABLES_SHARE[MS100_id],
        (INTERCOM_MEMORY / 100) * RUNABLES_SHARE[MS200_id],
        (INTERCOM_MEMORY / 100) * RUNABLES_SHARE[MS1000_id],
        (INTERCOM_MEMORY / 100) * RUNABLES_SHARE[MSANGLE_id]
    };
    // Final one is end of memory -> cant write further, position in array
    constexpr unsigned intercom_memory_offset[NR_TASKS + 1] = {
        0,
        intercom_memory_offset[0] + intercom_memory_size[MS1_id],
        intercom_memory_offset[1] + intercom_memory_size[MS2_id],
        intercom_memory_offset[2] + intercom_memory_size[MS5_id],
        intercom_memory_offset[3] + intercom_memory_size[MS10_id],
        intercom_memory_offset[4] + intercom_memory_size[MS20_id],
        intercom_memory_offset[5] + intercom_memory_size[MS50_id],
        intercom_memory_offset[6] + intercom_memory_size[MS100_id],
        intercom_memory_offset[7] + intercom_memory_size[MS200_id],
        intercom_memory_offset[8] + intercom_memory_size[MS1000_id],
        intercom_memory_offset[9] + intercom_memory_size[MSANGLE_id]
    };

    // InterTask Communication Patter
    // with MS1 MS2 MS5 MS10 MS20 MS50 MS100 MS200 MS1000
    // 0 = 0, I = 5, II = 25, III = 75, IV = 250, V = 750, VI = 1250
    constexpr unsigned INTER_TASK_RATIO[NR_TASKS][NR_TASKS] = {
                                            {25, 0, 0, 5, 5, 0, 5, 0, 0, 5},
                                            {0, 25, 0, 5, 5, 0, 5, 0, 0, 0},
                                            {0, 5, 250, 250, 25, 25, 5, 0, 0, 0},
                                            {25, 25, 25, 1250, 250, 25, 250, 25, 75, 250},
                                            {5, 5, 5, 250, 1250, 25, 250, 5, 25, 250},
                                            {0, 0, 25, 25, 25, 75, 5, 0, 0, 0},
                                            {0, 5, 5, 750, 250, 25, 1250, 25, 75, 250},
                                            {0, 0, 0, 5, 5, 0, 5, 5, 5, 0},
                                            {0, 0, 0, 75, 25, 0, 75, 5, 250, 5},
                                            {5, 5, 5, 250, 250, 5, 75, 5, 5, 750}
                                            };
#endif

/**
 ******************** RUN VARIABLES ********************
 */
// read only memory
static unsigned ro_mem[RO_MEMORY] = {0};
static unsigned volatile ro_mem_results[TASK_COUNT] = {0};

// intercom memory
// somehow are more idle cycles there when intercom_mem is added and filled
static unsigned volatile intercom_mem[INTERCOM_MEMORY] = {0};

/**
 ******************** DEBUG VARIABLES ********************
 */
#define MEMORY
