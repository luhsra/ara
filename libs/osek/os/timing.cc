#include "timing-arch.h"
#include "os/util/inline.h"
#include "output.h"
#include "stdint.h"

extern "C" {

extern uint64_t arch_timing_get();

constexpr int CIRCUIT_MAX = 10;
static uint64_t circuits[CIRCUIT_MAX];
static uint32_t circuits_duration[CIRCUIT_MAX];

noinline void timing_start(int circuit) {
    circuits[circuit & 0xff] = arch_timing_get();
}

noinline uint64_t timing_end(int circuit) {
    uint64_t end = arch_timing_get();
    uint32_t delta = (uint32_t) end - circuits[circuit & 0xff];
    circuits_duration[circuit & 0xff] = delta;
    return delta;
}

noinline int timing_print() {
    unsigned found = 0;
    for (unsigned i = 0; i < CIRCUIT_MAX; ++i) {
        if (circuits[i]) {
            kout << "timing-" << i << " " << circuits_duration[i] << endl;
            circuits[i] = 0;
            found ++;
        }
    }
    return found;
}

}
