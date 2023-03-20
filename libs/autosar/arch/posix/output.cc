/**
 * @file
 * @ingroup posix
 * @brief Default output streams
 */

#include "output.h"

#if DEBUG

BufferedTerminal kout(Terminal::STDOUT);
BufferedTerminal debug(Terminal::STDERR);


BufferedTerminal debug_core_arr[MAX_CPUS] = {
    BufferedTerminal(Terminal::STDERR, true),
    BufferedTerminal(Terminal::STDERR, true),
    BufferedTerminal(Terminal::STDERR, true),
    BufferedTerminal(Terminal::STDERR, true),
    BufferedTerminal(Terminal::STDERR, true),
    BufferedTerminal(Terminal::STDERR, true),
    BufferedTerminal(Terminal::STDERR, true),
    BufferedTerminal(Terminal::STDERR, true),
};

#else // DEBUG

BufferedTerminal kout(Terminal::STDOUT);
Null_Stream debug;

#endif // DEBUG
