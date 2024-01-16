#include "mmu.h"

namespace arch {
	unsigned int __attribute__((aligned(TLB_ALIGNMENT))) MMU::identity_map[NUM_PAGE_TABLE_ENTRIES] = {0};

	void MMU::setup_pagetable() {
		unsigned int base;

		/* shared RAM up tu (0x3b3fffff + 1) / (1<<20)
		 * https://wiki.osdev.org/Raspberry_Pi_4
		 */
		for (base = 0; base < 948; base++) {
			identity_map[base] = base << 20 | MT_NORMAL;
		}

		/* all the rest ist not sharable */
		for (; base < NUM_PAGE_TABLE_ENTRIES; base++) {
			identity_map[base] = base << 20 | MT_DEVICE_NS;
		}
	}

	void MMU::enable() {
		asm volatile(
		    // Set Translation Table Base Register (TTBR)
		    "mcr p15, 0, %[identity_map], c2, c0, 0 \n\t"

		    // Set Domain Access Control Register (DACR)
		    "mov r0, #0b1111 \n\t"
		    "mcr p15, 0, r0, c3, c0, 0 \n\t"

		    // Set Control Register (SCTLR) to enable MMU
		    "mrc p15, 0,  r0, c1, c0, 0 \n\t"
		    "orr r0, r0, #1 \n\t"      /* Enable MMU */
		    "orr r0, r0, #0x800 \n\t"  /* Enable branch predictor */
		    "orr r0, r0, #0x4 \n\t"    /* Enable cache */
		    "orr r0, r0, #0x1000 \n\t" /* Enable icache */
		    "mcr p15, 0, r0, c1, c0, 0 \n\t"

		    // Invalidate TLB
		    "mov r0, #0 \n\t"
		    "mcr p15, 0, r0, c8, c7, 0 \n\t"

		    // barrier
		    "isb \n\t"
		    :
		    : [identity_map] "r"(identity_map)
		    :);
		return;
	}
} // namespace arch