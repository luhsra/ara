#ifndef __OS_KRN_HELPER
#define __OS_KRN_HELPER

#include "machine.h"

/**
 * @file
 * @ingroup os
 * @brief Helper functions not defined in OSEK, that can be called
 * from the application
 */

__attribute__((weak)) extern "C" void ShutdownMachine(void) { Machine::shutdown(); }

#endif
