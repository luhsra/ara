#include "dispatch.h"

#ifndef CONFIG_OS_SYSTEMCALLS_WIRED

static char __attribute__(( aligned (16) )) idlestack[MAX_CPUS][arch::IDLESTACKSIZE];
arch::TCB::dynamic_state idle_dynamic_state[MAX_CPUS];

arch::TCB arch::Dispatcher::m_idle[MAX_CPUS] = {
    arch::TCB(Dispatcher::idleEntry, idlestack[0], idle_dynamic_state[0], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[1], idle_dynamic_state[1], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[2], idle_dynamic_state[2], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[3], idle_dynamic_state[3], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[4], idle_dynamic_state[4], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[5], idle_dynamic_state[5], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[6], idle_dynamic_state[6], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[7], idle_dynamic_state[7], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[8], idle_dynamic_state[8], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[9], idle_dynamic_state[9], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[10], idle_dynamic_state[10], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[11], idle_dynamic_state[11], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[12], idle_dynamic_state[12], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[13], idle_dynamic_state[13], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[14], idle_dynamic_state[14], arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[15], idle_dynamic_state[15], arch::IDLESTACKSIZE),
};
const arch::TCB* arch::Dispatcher::m_current[MAX_CPUS] = {0};

#endif
