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
    arch::TCB(Dispatcher::idleEntry, idlestack[8], arch::Dispatcher::idle_sp[8], 8, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[9], arch::Dispatcher::idle_sp[9], 9, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[10], arch::Dispatcher::idle_sp[10], 10, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[11], arch::Dispatcher::idle_sp[11], 11, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[12], arch::Dispatcher::idle_sp[12], 12, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[13], arch::Dispatcher::idle_sp[13], 13, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[14], arch::Dispatcher::idle_sp[14], 14, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[15], arch::Dispatcher::idle_sp[15], 15, arch::IDLESTACKSIZE),
};
const arch::TCB* arch::Dispatcher::m_current[MAX_CPUS] = {0};
uint32_t arch::current_abb[32];
