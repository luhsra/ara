#include "machine.h"
#include "frontend.h"
#include "output.h"
#include "htif.h"
#include "os.h"
#include "bufferedserial.h"


#if DEBUG

//TODO Buffer for multicore
BufferedSerial kout{false};
BufferedSerial debug{false};
BufferedSerial debug_core_arr[MAX_CPUS];

#else // DEBUG

Serial kout;
Null_Stream debug;
Null_Stream debug_core;

#endif // DEBUG

//initialize BufferedSerial

