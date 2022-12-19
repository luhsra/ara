/**
 * @file
 * @ingroup posix
 * @brief Default output streams
 */

#include "output.h"

#if DEBUG

ColorTerminal kout(Terminal::STDOUT);
ColorTerminal debug(Terminal::STDERR);


BufferedTerminal debug_core_arr[MAX_CPUS] = {
    BufferedTerminal(Terminal::STDERR),
    BufferedTerminal(Terminal::STDERR),
    BufferedTerminal(Terminal::STDERR),
    BufferedTerminal(Terminal::STDERR),
    BufferedTerminal(Terminal::STDERR),
    BufferedTerminal(Terminal::STDERR),
    BufferedTerminal(Terminal::STDERR),
    BufferedTerminal(Terminal::STDERR),
};

#else // DEBUG

ColorTerminal kout(Terminal::STDOUT);
Null_Stream debug;

#endif // DEBUG
