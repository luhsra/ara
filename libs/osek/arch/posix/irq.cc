#include <string.h>
#include <unistd.h>
#include "os/util/inline.h"

#include "irq.h"
#include "os/scheduler/scheduler.h"
#include "dispatch.h"


using namespace arch;

static void panic(int signal) {
	kout << "spurious interrupt: " << signal << endl;
}

IRQ::IRQ() {
    for(unsigned int i = 0; i < SIGMAX; i++)
        m_gate[i] = &panic;
    ast_level = 0;
    sigfillset(&full_mask);
}

void IRQ::set_handler(int signum, irq_handler_t handler) {
    m_gate[signum] = handler;
}

void IRQ::enable(int signum) {
    struct sigaction sig;

    memset(&sig, 0, sizeof(sig));
    sig.sa_handler = guardian;
    sig.sa_flags = SA_RESTART;
    sigfillset(&sig.sa_mask);

    sigaction(signum, &sig, NULL);
}

void IRQ::disable(int signum) {
    struct sigaction sig;

    memset(&sig, 0, sizeof(sig));
    sig.sa_handler = SIG_IGN;
    sig.sa_flags = SA_RESTART;

    sigaction(signum, &sig, NULL);
}

void IRQ::trigger_interrupt(int irq) {
    /* Send an signal to our own thread */
    kill(getpid(), irq);
}

extern void __OS_enable_irq_after_kernel(void);

noinline void IRQ::deliver_interrupt(int irq) {
    if (interrupts_enabled(irq)) {
        sigset_t old_mask;
        disable_interrupts(&old_mask);
        guardian(irq);
        __OS_enable_irq_after_kernel();
    }
}

void IRQ::disable_interrupts(sigset_t *old_mask) {
    sigprocmask(SIG_BLOCK, &full_mask, old_mask);
}

void IRQ::enable_interrupts(sigset_t *new_mask) {
    sigset_t *mask = new_mask != nullptr ? new_mask: &full_mask;
    sigprocmask(SIG_UNBLOCK, mask, NULL);
}

static int my_sigisemptyset(sigset_t *sigset) {
    for (int i = 1; i < 8*8; i++) {
        if (sigismember(sigset, i)) {
            return 0;
        }
    }
    return 1;
}

void IRQ::clear_interrupts() {
    sigset_t mask;

    while (1) {
        sigpending(&mask);
        if (my_sigisemptyset(&mask)) break;
        int signal;

        sigwait(&full_mask, &signal);
    }
}

bool IRQ::interrupts_enabled(int irq) {
	sigset_t mask;
    sigprocmask(0, NULL, &mask);
    if (irq == 0) {
        return my_sigisemptyset(&mask);
    } else {
        return !sigismember(&mask, irq);
    }
}

void IRQ::guardian(int signum) {
	/* Interrupts are prohibited during the ISR */
	irq.ast_level++;
        irq.m_gate[signum](signum);
	irq.ast_level--;
	if (irq.ast_level == 0 && irq.ast_requested) {
		irq.ast_requested = false;
		__OS_ASTSchedule(0);
	}
}

IRQ arch::irq;
