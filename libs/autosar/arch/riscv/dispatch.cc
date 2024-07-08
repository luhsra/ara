#include "dispatch.h"

#ifndef CONFIG_OS_SYSTEMCALLS_WIRED

static char __attribute__(( aligned (16) )) idlestack[MAX_CPUS][arch::IDLESTACKSIZE];
arch::TCB::dynamic_state idle_dynamic_state;

arch::TCB arch::Dispatcher::m_idle[MAX_CPUS] = {
    arch::TCB(Dispatcher::idleEntry, idlestack[0], idle_dynamic_state, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[1], idle_dynamic_state, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[2], idle_dynamic_state, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[3], idle_dynamic_state, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[4], idle_dynamic_state, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[5], idle_dynamic_state, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[6], idle_dynamic_state, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[7], idle_dynamic_state, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[8], idle_dynamic_state, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[9], idle_dynamic_state, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[10], idle_dynamic_state, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[11], idle_dynamic_state, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[12], idle_dynamic_state, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[13], idle_dynamic_state, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[14], idle_dynamic_state, arch::IDLESTACKSIZE),
    arch::TCB(Dispatcher::idleEntry, idlestack[15], idle_dynamic_state, arch::IDLESTACKSIZE),
};
const arch::TCB* arch::Dispatcher::m_current[MAX_CPUS] = {0};

#endif
