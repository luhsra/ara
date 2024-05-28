#include "machine.h"
#include "frontend.h"
#include "output.h"
#include "htif.h"
#include "os.h"


#if DEBUG

//TODO Buffer for multicore
Serial kout{};
Serial debug{};
Serial debug_core_arr[MAX_CPUS];

#else // DEBUG

Serial kout;
Null_Stream debug;
Null_Stream debug_core;

#endif // DEBUG