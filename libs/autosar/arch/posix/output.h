/**
 * @file
 * @ingroup posix
 * @brief Default output streams
 */
#ifndef __OUTPUT_H__
#define __OUTPUT_H__

#include "bufferedterminal.h"
#if DEBUG

// debugging: print kout+debug on stdout/stderr
#include "hardware_threads.h"
extern BufferedTerminal kout;
extern BufferedTerminal debug;
extern BufferedTerminal debug_core_arr[MAX_CPUS];

#define debug_core (debug_core_arr[arch::get_cpuid()])

#else // DEBUG

// not debugging: print kout on stdout, ignore debug
extern BufferedTerminal kout;
extern Null_Stream debug;
#define debug_core debug

#endif // DEBUG

#endif // __OUTPUT_H__
