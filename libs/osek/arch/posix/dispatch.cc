#include "dispatch.h"

static char idlestack[arch::IDLESTACKSIZE];
void * arch::Dispatcher::idle_sp;
arch::TCB arch::Dispatcher::m_idle(Dispatcher::idleEntry, idlestack, arch::Dispatcher::idle_sp, 0, arch::IDLESTACKSIZE);
const arch::TCB* arch::Dispatcher::m_current = 0;
uint32_t arch::current_abb[32];
