#pragma once

#include "inline.h"
#include "output.h"
#include "csr.h"

#define MAX_TRACES 64

extern "C" void wait(int a, int b);


#define CSR_MCOUNTINHIBIT 0x320

#define MCOUNTINHIBIT_CYCLE 1 << 0


namespace arch {
	class Perf {

        static int cycles[MAX_TRACES];
        static int cycles_nr;

        static int counter0[MAX_TRACES];
        static int counter0_nr;


	  public:
		enum trace {
			NONE = 0,
			SYSCALL = 1,
			IRQ = 2
		};

		static forceinline void start() {
            // General setup
            debug_core << "Starting performance setup" << endl;

            clear_csr(CSR_MCOUNTINHIBIT, MCOUNTINHIBIT_CYCLE); // enable cycles

            write_csr(CSR_MCYCLE, 0); // reset cycles
        }

		static forceinline void reset() {
            // Setzt state auf start state
            debug_core << "Reseting performance register" << endl;
            write_csr(CSR_MCYCLE, 0);
        }

		static forceinline void trace_cycles() {
            // Basically snapshot of current cycles in cycles
            debug_core << "Tracing cycles" << endl;

            unsigned int output = read_csr(CSR_MCYCLE);
			cycles[cycles_nr++] = output;
        }

		static forceinline unsigned int get_cycles() { 
            // returns the current cycles
            debug_core << "Getting cycles" << endl;
            // TODO adjust for 32 bit architecture (MCYCLEH)
            unsigned int output = read_csr(CSR_MCYCLE);
			return output;
        }


        // TODO
		static forceinline void trace_counter0() {
            // same as trace but with counter
            debug_core << "Tracing counter0" << endl;

            unsigned int output;
			//asm volatile("MRC p15, 0, %0, c9, c13, 2 \t\n" : "=r"(output));
			counter0[counter0_nr++] = output;
        }

		static forceinline void stop() { 
            // Stops the counter from counting ( registers enable)
            debug_core << "Stopping performance monitor" << endl;

            set_csr(CSR_MCOUNTINHIBIT, MCOUNTINHIBIT_CYCLE); // Yes, setting the bit disables counter
        }

		static forceinline void reset_counters() {
            debug_core << "Resetting counters" << endl;
            cycles_nr = 0;
			counter0_nr = 0;
        }

		static forceinline void print_cycles() {
            debug_core << "Printing cycles" << endl;

            for (int i = 0; i < cycles_nr; i++) {
				// print cycles
				kout << "val[" << i << "]=" << cycles[i] << endl;
			}
			for (int i = 1; i < cycles_nr; i++) {
				// print diff
				kout << "d[" << i - 1 << ">" << i << "]=" << cycles[i] - cycles[i - 1] << endl;
			}
        }

		static forceinline void print_counter0() {
            debug_core << "Printing counter0" << endl;

            for (int i = 0; i < counter0_nr; i++) {
				// print cycles
				kout << "val[" << i << "]=" << counter0[i] << endl;
			}
			for (int i = 1; i < counter0_nr; i++) {
				// print diff
				kout << "d[" << i - 1 << ">" << i << "]=" << counter0[i] - counter0[i - 1] << endl;
			}
        }
	};
} // namespace arch