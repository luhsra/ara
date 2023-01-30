#include "machine.h"
#include "os.h"

/**
 * \brief Methods for interrupt disabling/enabling. This pair cannot
 *        be stacked.
 **/
void AUTOSAR_DisableAllInterrupts() { Machine::disable_interrupts(); }

void AUTOSAR_EnableAllInterrupts() { Machine::enable_interrupts(); }

/**
 * \brief Same as disable/enable but can be stacked.
 **/
static int __all_isr_count;
void AUTOSAR_SuspendAllInterrupts() {
	Machine::disable_interrupts();
	__all_isr_count++;
}

void AUTOSAR_ResumeAllInterrupts() {
	__all_isr_count--;
	if (__all_isr_count == 0) {
		Machine::enable_interrupts();
	}
}

static int __os_isr_count;

void AUTOSAR_SuspendOSInterrupts() {
	Machine::disable_interrupts();
	__os_isr_count++;
}

void AUTOSAR_ResumeOSInterrupts() {
	__os_isr_count--;
	if (__os_isr_count == 0) {
		Machine::enable_interrupts();
	}
}
