#include "autosar/os.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(B);

int main(void) {
	StartOS(0);
}

TASK(B) {
	kout << "Hello World - B"<< endl;
	ara_timing_info(3, 4);

	unsigned int addr = 0;
	unsigned int val = 0;
	AreaIdType area = 1;
	AddressType ad = &addr;
	WriteValueType w = &val;
	ReadPeripheral(area, ad, w);

	ara_timing_info(7, 8);
	TerminateTask();
}

void PreIdleHook() {
	ShutdownMachine();
}
