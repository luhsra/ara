// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef MMU_H_
#define MMU_H_

#define NUM_PAGE_TABLE_ENTRIES 4096 // for up to 4G
#define LEVEL1_BLOCKSIZE (1 << 20)  // 1M
#define TLB_ALIGNMENT 16384

#define MT_DEVICE_NS 0x10412 // device no share (strongly ordered)
#define MT_DEVICE 0x10416    // device + shareable
#define MT_NORMAL 0x1040E    // normal cache + shareable
#define MT_NORMAL_NS 0x1040A // normal cache no share
#define MT_NORMAL_XN 0x1041E // normal cache + shareable and execute never

namespace arch {
	class MMU {
	  public:
		static unsigned int __attribute__((aligned(TLB_ALIGNMENT))) identity_map[NUM_PAGE_TABLE_ENTRIES];

		static void setup_pagetable();
		static void enable();
	};
} // namespace arch
#endif