/**
 * @file
 * @ingroup posix
 * @brief Default output streams
 */
#ifndef __OUTPUT_H__
#define __OUTPUT_H__

#if DEBUG

// debugging: print kout+debug on stdout/stderr
#include "colorterminal.h"
#include "bufferedterminal.h"
#include "hardware_threads.h"
extern ColorTerminal kout;
extern ColorTerminal debug;
extern BufferedTerminal debug_core_arr[MAX_CPUS];

#define debug_core (debug_core_arr[arch::get_cpuid()])

#else // DEBUG

// not debugging: print kout on stdout, ignore debug
#include "colorterminal.h"
extern ColorTerminal kout;
extern Null_Stream debug;

#define debug_core debug

#endif // DEBUG

#endif // __OUTPUT_H__
