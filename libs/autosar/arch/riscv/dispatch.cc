#include "dispatch.h"

#ifndef CONFIG_OS_SYSTEMCALLS_WIRED

static char idlestack[MAX_CPUS][arch::IDLESTACKSIZE];
void* arch::Dispatcher::idle_dynamic_state[MAX_CPUS];

arch::TCB arch::Dispatcher::m_idle[MAX_CPUS] = {
    arch::TCB(Dispatcher::idleEntry, idlestack[0], arch::Dispatcher::idle_dynamic_state[0], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[1], arch::Dispatcher::idle_dynamic_state[1], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[2], arch::Dispatcher::idle_dynamic_state[2], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[3], arch::Dispatcher::idle_dynamic_state[3], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[4], arch::Dispatcher::idle_dynamic_state[4], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[5], arch::Dispatcher::idle_dynamic_state[5], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[6], arch::Dispatcher::idle_dynamic_state[6], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[7], arch::Dispatcher::idle_dynamic_state[7], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[8], arch::Dispatcher::idle_dynamic_state[8], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[9], arch::Dispatcher::idle_dynamic_state[9], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[10], arch::Dispatcher::idle_dynamic_state[10], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[11], arch::Dispatcher::idle_dynamic_state[11], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[12], arch::Dispatcher::idle_dynamic_state[12], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[13], arch::Dispatcher::idle_dynamic_state[13], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[14], arch::Dispatcher::idle_dynamic_state[14], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[15], arch::Dispatcher::idle_dynamic_state[15], arch::IDLESTACKSIZE),
};
const arch::TCB* arch::Dispatcher::m_current[MAX_CPUS] = {0};

#endif
