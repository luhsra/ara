/**
 * @file
 * @ingroup posix
 * @brief Default output streams
 */

#include "output.h"

#if DEBUG

BufferedTerminal kout(Terminal::STDOUT, false);
BufferedTerminal debug(Terminal::STDERR, false);

BufferedTerminal debug_core_arr[MAX_CPUS];

#else // DEBUG

BufferedTerminal kout(Terminal::STDOUT);
Null_Stream debug;

#endif // DEBUG
