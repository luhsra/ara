// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "test/test.h"

extern "C" {
_Atomic(bool) global_all_ok;
_Atomic(int) positive_tests;
_Atomic(int) experiment_number;
expected_value_t expected_values[EXPECTED_VALUES_MAX];
_Atomic(bool) interrupts_suspended = false;
_Atomic(char) trace_table[TRACE_LENGTH];
_Atomic(unsigned) trace_table_idx = 0;

volatile uint32_t fail_trace = 0;

void test_prepare(void) {};

noinline void test(void);

noinline void test_finish(int tests) {
	if ((tests > 0) && (tests != experiment_number)) {
		kout << "INCORRECT NUMBER of tests run: ";
		kout << dec << experiment_number << " instead of " << tests;
		kout << endl;
	} else {
		kout << "Tests finished: ";
		kout << (global_all_ok ? "ALL OK" : "some tests failed");
		kout << endl;
	}
}

noinline void test_trace_dump(void) {
	kout << "traced: ";
	for (unsigned i = 0; i < trace_table_idx; i++) {
		kout << trace_table[i];
	}
}

noinline void test_trace_assert(const char* expected) {
	int good = 1;
	unsigned count = 0;
	test_start_check();
	for (; expected[count] != 0 && count < (TRACE_LENGTH - 1); count++) {
	}
	if (count != trace_table_idx) {
		kout << "trace length != expected " << (int)trace_table_idx << endl;
		good = 0;
	} else {
		for (unsigned i = 0; i < trace_table_idx; i++) {
			if (trace_table[i] != expected[i] && expected[i] != 'X') { // dont care
				kout << "too unqeual: " << trace_table[i] << " at " << (int)i << endl;
				good = 0;
				break;
			}
		}
	}

	kout << "expect: " << expected << endl;
	test_trace_dump();
	kout << endl;

	test_assert(good);
	test_positive_tests_gt(0);
}

// returns how often chr occurs in trace
unsigned count_trace(char chr) {
	unsigned count = 0;
	for (unsigned i = 0; i < TRACE_LENGTH; i++) {
		if (trace_table[i] == chr) {
			count++;
		}
	}
	return count;
}

void test_trace(char chr) {
	//debug_core << "test_trace: " << chr << endl;
	fail_trace = (uint32_t)chr;
	if (trace_table_idx < TRACE_LENGTH)
		trace_table[trace_table_idx++] = chr;
	// kout << trace_table[trace_table_idx-1] << endl;
}

}