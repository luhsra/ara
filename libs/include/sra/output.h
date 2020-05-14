#pragma once

#include "ostream.h"

#ifndef FAIL
#if DEBUG

// debugging: print kout+debug on UART
#include "serial.h"
extern Serial kout;
extern Serial debug;

#else // DEBUG

// not debugging: print kout on UART, ignore debug
#include "serial.h"
extern Serial kout;
extern Null_Stream debug;

#endif // DEBUG

#else // FAIL

// FAIL* testing: no output
extern Null_Stream kout;
extern Null_Stream debug;

// define dummy colors here as Null_Stream doesn't
typedef enum class Color { BLACK, BLUE, GREEN, CYAN, RED, MAGENTA, YELLOW, WHITE } Color;

void vPrintString(const char *string);
void vPrintStringAndNumber(const char *string, int number);

#endif // FAIL
