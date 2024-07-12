/**
 * @file
 * @ingroup i386
 * @brief Default output streams
 */
#ifndef __OUTPUT_H__
#define __OUTPUT_H__

#include "arch/generic/ostream.h"
#include "hardware_threads.h"

#ifndef FAIL
#if DEBUG

// debugging: print kout+debug on UART
//#include "bufferedserial.h"
#include "bufferedserial.h"
#include "serial.h"
extern Serial kout;
extern Serial debug;
extern BufferedSerial debug_core_arr[MAX_CPUS];

#define debug_core (debug_core_arr[arch::get_cpuid()])

#else // DEBUG

// not debugging: print kout on UART, ignore debug
#include "serial.h"
extern Serial kout;
extern Null_Stream debug;
extern Null_Stream debug_core;

#endif // DEBUG

#else // FAIL

// FAIL* testing: no output
extern Null_Stream kout;
extern Null_Stream debug;

// define dummy colors here as Null_Stream doesn't
typedef enum class Color { BLACK, BLUE, GREEN, CYAN, RED, MAGENTA, YELLOW, WHITE } Color;

#endif // FAIL

#endif // __OUTPUT_H__
