#include "autosar/os.h"

DeclareTask(A);
DeclareTask(B);

int main(void) {
	StartOS(0);
}

int inc(int i){
	return i++;
}

TASK(A) {
	int i = 0;
	inc(i);
	i++;
	ActivateTask(B);
}


TASK(B) {
	kout << "B"<< endl;

	TerminateTask();
	
	// ShutdownMachine();
}

void PreIdleHook() {
	ShutdownMachine();
}
