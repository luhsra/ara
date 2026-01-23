#include "autosar/os.h"

/*
* Test how Ara's value analysis handles pointers being thrown arround.
* If the value of the dereferenced pointer is found it should know wheater B or C is called.
* For Ara: ninja subprojects/ara/appl/AUTOSAR/autosar_singlecore_examples_ara_pointer_noopt_mod.pi4.ll
* Qemu: ninja ara@@run_autosar_singlecore_examples_ara_pointer_noopt_pi4
*/

extern "C" void ara_timing_info(int a, int b);

DeclareTask(A);
DeclareTask(B);
DeclareTask(C);

int main(void) {
	StartOS(0);
}
TASK(B) {
	kout << "B" << endl;
	TerminateTask();
}
TASK(C) {
	kout << "C" << endl;
	TerminateTask();
}


inline void func(int * var_p) {
	*var_p + 5;
}

void func2(int * var_p) {
	*var_p + 5;
}


TASK(A) {
	kout << "A" << endl;
	int var = 0;
	int *var_p = &var;
	// this works
	if (*var_p < 10) {
		ActivateTask(B);
	} else {
		ActivateTask(C);
	}
	ara_timing_info(5, 5);


	int var2 = 0;
	int *var_p2 = &var2;
	func(var_p2);
	// this should work, but because of the -O0 optimization level it is not inlined
	if (*var_p2 < 10) {
		ActivateTask(B);
	} else {
		ActivateTask(C);
	}
	ara_timing_info(10, 10);

	int var3 = 0;
	int *var_p3 = &var3;
	func(var_p3);
	// this could also work, would need to be implemented
	if (*var_p3 < 10) {
		ActivateTask(B);
	} else {
		ActivateTask(C);
	}
	ara_timing_info(30, 30);


	StatusType s;
	AreaIdType area = 1;
	unsigned int addr = 0;
	unsigned int var4 = 0;
	AddressType ad = &addr;
	WriteValueType w = &var4;
	s = ReadPeripheral(area, ad, w);
	// this is hard to do
	if (*w < 10) {
		ActivateTask(B);
	} else {
		ActivateTask(C);
	}
	ara_timing_info(50, 50);
	// for hypercall event_status (pending), this should work
	if (s == 1) {
		ActivateTask(B);
	} else {
		ActivateTask(C);
	}
	ara_timing_info(70, 70);

	TerminateTask();
}

void PreIdleHook() {
	ShutdownMachine();
}
