#include "dispatch.h"

static char idlestack[MAX_CPUS][arch::IDLESTACKSIZE];
void * arch::Dispatcher::idle_sp[MAX_CPUS];

arch::TCB arch::Dispatcher::m_idle[MAX_CPUS] = {
    arch::TCB(Dispatcher::idleEntry, idlestack[0], arch::Dispatcher::idle_sp[0], 0, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[1], arch::Dispatcher::idle_sp[1], 1, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[2], arch::Dispatcher::idle_sp[2], 2, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[3], arch::Dispatcher::idle_sp[3], 3, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[4], arch::Dispatcher::idle_sp[4], 4, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[5], arch::Dispatcher::idle_sp[5], 5, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[6], arch::Dispatcher::idle_sp[6], 6, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[7], arch::Dispatcher::idle_sp[7], 7, arch::IDLESTACKSIZE),
};
const arch::TCB* arch::Dispatcher::m_current[MAX_CPUS] = {0};
uint32_t arch::current_abb[32];

int arch::Dispatcher::spinlocks[MAX_CPUS] = {0};
bool arch::Dispatcher::m_core_dispatched[MAX_CPUS] = {false};