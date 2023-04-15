/**
 * @file
 * @ingroup i386
 * @brief Default output streams
 */

#include "output.h"

#include "os.h"

#if DEBUG

Serial kout;
Serial debug;

#else // DEBUG

Serial kout;
Null_Stream debug;

#endif // DEBUG
