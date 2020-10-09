#include "autosar/os.h"

void doSomethingBefore() { }
void doSomethingAfter() { }
void doSomethingImportant2() { }
void doSomethingImportant() {
    doSomethingImportant2();
}
void doSomethingC() { }
void doSomethingD() { }
void doSomethingE() { }
extern bool getBool();
void handleSomeEvent() { }
void doCriticalWork() {}

DeclareTask(TaskA);
DeclareTask(TaskB);
DeclareTask(TaskC);
DeclareTask(TaskD);
DeclareTask(TaskE);
DeclareTask(TaskF);

// ISR2(Interrupt1) {
//     handleSomeEvent();
// }

ISR2(Interrupt2) {
    ActivateTask(TaskB);
}

TASK(TaskA) {
    while(true) {
        doSomethingBefore();
    } 
    TerminateTask();
}

TASK(TaskB) {
    DisableAllInterrupts();
    doCriticalWork();
    EnableAllInterrupts();

    TerminateTask();
}

TASK(TaskF) {
    ActivateTask(TaskB);
    TerminateTask();
}

TASK(TaskC) {
    while(true) {
        doSomethingC();
    }
    TerminateTask();
}

TASK(TaskD) {
    ActivateTask(TaskB);

    TerminateTask();
}

TASK(TaskE) {
    doSomethingE();
    ActivateTask(TaskD);
    TerminateTask();
}

int main(void){
    char * appmode = {"tmp"};
    StartOS(appmode);
    return 0;
}
