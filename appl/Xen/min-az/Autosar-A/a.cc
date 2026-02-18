#include "autosar/os.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(A);

int main(void) {
	StartOS(0);
}

TASK(A) {
	kout << "Hello World - A"<< endl;
	ara_timing_info(1, 2);

	unsigned int addr = 0;
	unsigned int val = 0;
	AreaIdType area = 1;
	AddressType ad = &addr;
	WriteValueType w = &val;
	ReadPeripheral(area, ad, w);

	ara_timing_info(5, 6);
	TerminateTask();
}

void PreIdleHook() {
	ShutdownMachine();
}
