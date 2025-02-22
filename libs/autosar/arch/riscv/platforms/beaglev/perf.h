#pragma once

#include "inline.h"
#include "output.h"
#include "csr.h"

#define MAX_TRACES 64

#define CSR_MCOUNTINHIBIT 0x320
#define MCOUNTINHIBIT_CYCLE (1 << 0)
#define MCOUNTINHIBIT_HPM3 (1 << 3)

// Specific to U54 cores (beaglv) see:
// https://static.dev.sifive.com/U54-MC-RVCoreIP.pdf

/**************EVENT classes************/
#define INSTRUCTION_COMMIT_EVENTS 0x0
#define MICROARCHITECTURAL_EVENTS 0x1
#define MEMORY_SYSTEM_EVENTS 0x2

//********FILLER************/
#define NO_EVENTS (0 << 0)

/***********INSTRUCTION_COMMIT_EVENTS***************/
#define EXCEPTION_TAKEN                     (1 << 8)
#define INTEGER_LOAD_INSTR_RETIRED          (1 << 9)
#define INTEGER_STORE_INSTR_RETIRED         (1 << 10)
#define ATOMIC_MEMORY_OP_RETIRED            (1 << 11)
#define SYSTEM_INSTR_RETIRED                (1 << 12)
#define INTEGER_ARITHMETIC_INSTR_RETIRED    (1 << 13)
#define CONDITIONAL_BRANCH_RETIRED          (1 << 14)
#define JAL_INSTR_RETIRED                   (1 << 15)
#define JALR_INSTR_RETIRED                  (1 << 16)
#define INTEGER_MULTIPLICATION_RETIRED      (1 << 17)
#define INTEGER_DIVISION_RETIRED            (1 << 18)
#define FP_LOAD_INSTR_RETIRED               (1 << 19)
#define FP_STORE_INSTR_RETIRED              (1 << 20)
#define FP_ADDITION_RETIRED                 (1 << 21)
#define FP_MULTIPLICATION_RETIRED           (1 << 22)
#define FP_FUSED_MADD_RETIRED               (1 << 23)
#define FP_DIV_SQRT_RETIRED                 (1 << 24)
#define FP_OTHER_INSTR_RETIRED              (1 << 25)

/***********MICROARCHITECTURAL_EVENTS***************/
#define LOAD_USE_INTERLOCK                  (1 << 8)
#define LONG_LATENCY_INTERLOCK              (1 << 9)
#define CSR_READ_INTERLOCK                  (1 << 10)
#define INSTRUCTION_CACHE_BUSY              (1 << 11)
#define DATA_CACHE_BUSY                     (1 << 12)
#define BRANCH_DIRECTION_MISPREDICTION      (1 << 13)
#define BRANCH_TARGET_MISPREDICTION         (1 << 14)
#define PIPELINE_FLUSH_CSR_WRITE            (1 << 15)
#define PIPELINE_FLUSH_OTHER_EVENT          (1 << 16)
#define INTEGER_MULTIPLICATION_INTERLOCK    (1 << 17)
#define FLOATING_POINT_INTERLOCK            (1 << 18)

/***********MEMORY_SYSTEM_EVENTS***************/
#define INSTRUCTION_CACHE_MISS             (1 << 8)
#define DATA_CACHE_MISS_OR_MMIO_ACCESS     (1 << 9)
#define DATA_CACHE_WRITE_BACK              (1 << 10)
#define INSTRUCTION_TLB_MISS               (1 << 11)
#define DATA_TLB_MISS                      (1 << 12)
#define UTLB_MISS                          (1 << 13)

extern "C" void wait(int a, int b);

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
            //debug_core << "Starting performance setup" << endl;
#ifndef MCOUNTINHIBIT_NOT_IMPLEMENTED
            clear_csr(CSR_MCOUNTINHIBIT, MCOUNTINHIBIT_CYCLE); // enable cycles counter
            clear_csr(CSR_MCOUNTINHIBIT, MCOUNTINHIBIT_HPM3); // enable event counter
#endif
            // General cycle counter
            write_csr(CSR_MCYCLE, 0); // counter reset

            // Specific event counter
            unsigned int event_mask = INSTRUCTION_COMMIT_EVENTS | NO_EVENTS;
            write_csr(CSR_MHPMEVENT3, event_mask); // configuration
            write_csr(CSR_MHPMCOUNTER3, 0); // counter reset
        }

		static forceinline void reset() {
            //debug_core << "Reseting performance register" << endl;
            write_csr(CSR_MCYCLE, 0);
            write_csr(CSR_MHPMCOUNTER3, 0); 
        }

		static forceinline void trace_cycles() {
            //debug_core << "Tracing cycles" << endl;
            unsigned int output = read_csr(CSR_MCYCLE);
			cycles[cycles_nr++] = output;
        }

		static forceinline unsigned int get_cycles() { 
            //debug_core << "Getting cycles" << endl;
            unsigned int output = read_csr(CSR_MCYCLE);
			return output;
        }

		static forceinline void trace_counter0() {
            //debug_core << "Tracing counter0" << endl;
            unsigned int output = read_csr(CSR_MHPMCOUNTER3);
			counter0[counter0_nr++] = output;
        }

#ifndef MCOUNTINHIBIT_NOT_IMPLEMENTED
		static forceinline void stop() { 
            // Stops the counter from counting ( registers enable)
            //debug_core << "Stopping performance monitor" << endl;
            set_csr(CSR_MCOUNTINHIBIT, MCOUNTINHIBIT_CYCLE); // disable counter incrementing
            set_csr(CSR_MCOUNTINHIBIT, MCOUNTINHIBIT_HPM3);
        }
#endif

		static forceinline void reset_counters() {
            //debug_core << "Resetting counters" << endl;
            cycles_nr = 0;
			counter0_nr = 0;
        }

		static forceinline void print_cycles() {
            //debug_core << "Printing cycles" << endl;

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
            //debug_core << "Printing counter0" << endl;

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