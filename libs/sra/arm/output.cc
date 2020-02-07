#include "output.h"

#if DEBUG

Serial kout;
Serial debug;

#else
Serial kout;
Null_Stream debug;

#endif
