#ifndef __MACHINE_H__
#define __MACHINE_H__


#include "os/util/inline.h"

#include "htif.h"
#include "csr.h"
#include "bits.h"
#include "timer.h"
//#include "fdt.h"

#include "output.h"
#include "hardware_threads.h"


#include "perf.h"


/**
 *  @ingroup arch
 *  @defgroup posix Posix "Hardware" abstraction
 *  @brief Architecture specific code for the posix "hardware".
 */

/**
 * @file
 *
 * @ingroup osek-v
 *
 * @brief Machine dependent special instructions.
 */

#include <stdint.h>

#define HLS() OTHER_HLS(arch::get_cpuid())
#define OTHER_HLS(id) (&::arch::hart_local_storage[(id)])

typedef struct hls_t{
    volatile uint32_t* ipi; //= (uint32_t *) (CLINT_BASE + (4 * arch::get_cpuid()));
    volatile int mipi_pending;

    volatile uint64_t* timecmp; //= (uint64_t *) (CLINT_BASE + MTIMECMP_BASE + (8 * arch::get_cpuid()));
    volatile uint32_t* plic_m_thresh;
    volatile uintptr_t* plic_m_ie;
    volatile uint32_t* plic_s_thresh;
    volatile uintptr_t* plic_s_ie;
} hls_t;

namespace arch {
	extern hls_t hart_local_storage[MAX_HARTS];
}

extern "C" _Atomic(bool) core_is_ready[MAX_CPUS];



class Machine
{
public:
    static uint64_t soft_irq_cause[MAX_CPUS];

    static void init(void) {
    }

	/**
	 * \brief Emits a nop opcode. (nop)
	 */
	static forceinline void nop(void) {
		asm volatile ("nop");
	};

	/**
	 * \brief Emits an undefined instruction trap.
	 * Used for runtime asserts.
	 */
	static forceinline void debug_trap(void) {
	}

	/**
	 * \brief Disable all interrupts
	 */
	static forceinline bool disable_interrupts() {
	   unsigned mstatus = clear_csr(CSR_MSTATUS, MSTATUS_MIE);
       return ((mstatus & MSTATUS_MIE) != 0);
    }

	/**
	 * \brief Enable all interrupts
	 */
	static forceinline void enable_interrupts() {
		set_csr(CSR_MSTATUS, MSTATUS_MIE);
        // We wait until the interrupt becomes actually pending.
        if (Machine::soft_irq_cause[arch::get_cpuid()] != 0 && read_csr(CSR_MIP) & MIP_MSIP) {
            while(Machine::soft_irq_cause[arch::get_cpuid()] != 0);
        }
    }

	static forceinline void set_sp(const void* sp) {
		asm volatile ("mv sp, %0" :: "r"(sp) : "memory");
    }

	static forceinline void * get_sp() {
        void* sp;
		asm volatile ("mv %0, sp" : "=r"(sp) :: "memory");
        return sp;
    }


	/**
	 * \brief Return if interrupts are enabled
	 */
	static forceinline bool interrupts_enabled(void) {
		return read_csr(CSR_MSTATUS) & MSTATUS_MIE;
	}

	/**
	 * \brief Unreachable code
	 * Will trigger interrupt if this is actually executed.
	 */
	static noinline void unreachable(void) {
		__builtin_unreachable(); // allow compiler optimization
	}

	static noinline void shutdown(void) {
		// QEMU shutdown
		//(*(volatile uint32_t *) 0x100000) = 0x5555;
		//htif_poweroff();
		//asm("j do_reset");

		// BeagleV "Shutdown" (No conventional shutdown feature)
		kout << "Shutting down..." << endl;
		while (true) {
			halt();
		}
		
	}

	static noinline void halt(void) {
		asm volatile ("wfi");
	}

	static forceinline void * exchange_saved_ip(unsigned id, void *pc) {
		void *ret;
        // FIXME for OSEK-v
        // asm volatile ("osek.ld %0, %1, %2;" : "=r"(ret) : "r"(pc), "r"(id));
        ret = pc; id++;
		return ret;
	}

	static forceinline unsigned syscall(const unsigned number) {
		unsigned ret;
        // FIXME for OSEK-V
		// asm volatile ("osek %0, %1" : "=r"(ret) : "I"(number));
        ret = number;
		return ret;
	}


	/**
	 * \brief Trigger an interrupt
	 */
	static forceinline void trigger_interrupt(uint8_t irq_, uint8_t cpuid = 0, bool sync = false) {
		
		arch::Perf::trace_cycles();

		if(core_is_ready[cpuid] == false) {
			debug_core << "Target CPU " << (int) cpuid << " is offline" << endl;
			//return;
		}
		
		bool interrupts = disable_interrupts();

        // Set the soft interrupt
		soft_irq_cause[cpuid] |= (((uint64_t)1) << (irq_ % 64));

		if(!sync) {
			
			*(OTHER_HLS(cpuid)->ipi) = 1;

			if (interrupts) { enable_interrupts(); }
			return;
		}
		
		ipi_cleared[cpuid] = false;
		debug_core << "Triggering IPI-Sync on core " << (int) cpuid << endl;

		*(OTHER_HLS(cpuid)->ipi) = 1;
		arch::Perf::trace_cycles();
		while (!ipi_cleared[cpuid]) {
			Machine::nop();
		}
		arch::Perf::trace_cycles();
		if (interrupts) { enable_interrupts(); }
		
	}


	static forceinline void trigger_interrupt_from_user(uint8_t irq_, uint8_t cpuid = 0, bool sync = false) {
		trigger_interrupt(irq_, cpuid, sync);
	}

	static forceinline void sync() {
		asm volatile ("fence");
	}

	static forceinline void sleep() {
		asm volatile ("wfi");
	}
};

#define __asm_label(a) #a
#define _asm_label(a) __asm_label(a)
#define asm_label(label) asm volatile (".asm_label." label "_%=:" :: "m" (*(uint32_t *)0))
// #define asm_label(label)




#endif // __MACHINE_H__
