#include "output.h"
#include "machine.h"
#include "timer.h"
#include "interrupt.h"
#include "os/scheduler/scheduler.h"

#ifndef CONFIG_OS_SYSTEMCALLS_WIRED
static bool ast_requested;
static int ast_level;

void arch::request_reschedule_ast() {
	ast_requested = true;
}

bool arch::in_syscall() {
	return ast_level == 0;
}
#endif

uint64_t Machine::soft_irq_cause[MAX_CPUS] = {0};

extern "C" void AUTOSAR_DisableAllInterrupts() {
	Machine::disable_interrupts();
}

extern "C" void AUTOSAR_EnableAllInterrupts() {
	Machine::enable_interrupts();
}


extern "C" void bad_trap() {
	kout << "machine mode: unhandlable trap "
		<< hex << read_csr(CSR_MCAUSE) << " @ "
		<< read_csr(CSR_MEPC)
        << " "
        << read_csr(CSR_MTVAL) << endl;
    for (volatile int i = 0; i < 0xfffff; i++);
	Machine::shutdown();
}

// Referenced from the generator: arch_osekv.py
void arch::bad_soft_irq(unsigned char cause) {
	kout << "machine mode: unhandlable soft_irq "
		 << hex << (int)cause << " @ " << read_csr(CSR_MEPC) << endl;
	Machine::shutdown();
}




extern "C" void interrupt_handler_c(long long mcause, unsigned long long * irq_context) {

	//kout << " >irq: " << (int) mcause << hex << " at core " << arch::get_cpuid() << " context: " << *irq_context << endl;
    // for (unsigned int i = 1; i < 32; i++)
    //     kout << irq_context[i] << " ";
    // kout << endl;
#ifndef CONFIG_OS_SYSTEMCALLS_WIRED
	ast_level ++;
#endif
	
	if (mcause < 0) { // Interrupt
		uintptr_t device = mcause & 0xffffffff;
		if (device == 2) { // htif
			// uintptr_t fromhost = Machine::swap_csr(mfromhost, 0);
			// if (fromhost == 0) {
			// 	goto out;
			// }
			//kout << "htif interrupt" << endl;
			//kout << "htif interrupt" << endl;
			bad_trap();
		} else if (device == IRQ_M_TIMER) {
			//kout << "timer interrupt" << endl;
			kout << "Tick at core " << arch::get_cpuid() << endl;
			arch::Timer::tick();
			goto out;
		} else if (device == IRQ_M_SOFT) { // IPI

			//kout << "IPI interrupt" << device << endl;
			kout << "Entering IPI interrupt on core " << arch::get_cpuid() << endl;
			// ack the interrupt;
            while (Machine::soft_irq_cause[arch::get_cpuid()]) {
                // __builtin_ffs: Returns one plus the index of the
                // least significant 1-bit of x, or if x is zero,
                // returns zero.
                uint8_t IRQ = __builtin_ffsll(Machine::soft_irq_cause[arch::get_cpuid()]) - 1;

				kout << "IPI interrupt: " << (int) IRQ << endl;

				if(IRQ == 12) {
					kout << "Kill Core " << arch::get_cpuid() << endl;
					Machine::shutdown();
					Machine::unreachable();
				}

                arch::isr_table[IRQ](IRQ);

                // Clear that interrupt
                Machine::soft_irq_cause[arch::get_cpuid()] &= ~(((uint64_t)1) << IRQ);
            }
			
            *HLS()->ipi = 0;

			kout << "IPI interrupt finished" << endl;

			goto out;
		}
		kout << "device " << device << endl;
		bad_trap();
	} else {
		kout << "trap " << (int) mcause << endl;
		bad_trap();
	}
out:
#ifndef CONFIG_OS_SYSTEMCALLS_WIRED
	ast_level --;
	if (ast_requested) {
		ast_requested = false;
		__OS_ASTSchedule(0);
	}
#endif
    // We always return to the machine mode with open interrupts
    // kout << "resume to: " << hex;
    // for (unsigned int i = 1; i < 32; i++)
    //     kout << irq_context[i] << " ";
    // kout << endl;
    unsigned mstatus = read_csr(CSR_MSTATUS);
    mstatus |= MSTATUS_MPP;
    mstatus |= MSTATUS_MPIE;
    write_csr(CSR_MSTATUS, mstatus);
	return;
}
