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
    handleSomeEvent();
    ActivateTask(TaskB);
}

TASK(TaskA) {
    doSomethingBefore();
    DisableAllInterrupts();
    if (getBool()) {
        ActivateTask(TaskD);
        // doSomethingAfter();
    }
    EnableAllInterrupts();
    // for (int i = 0; i < 12; i++) {   
    //     doSomethingAfter();
    // }
    // ActivateTask(TaskD);
    TerminateTask();
}

TASK(TaskB) {
    doSomethingBefore();
    // ActivateTask(TaskF);
    TerminateTask();
}

TASK(TaskF) {
    // doSomethingImportant();
    doSomethingBefore();
    TerminateTask();
}

TASK(TaskC) {
    // while(true) {
    //     doSomethingC();
    //     ActivateTask(TaskF);
    // }
    ActivateTask(TaskF);
    doSomethingC();
    TerminateTask();
}

TASK(TaskD) {
    doSomethingD();
    ActivateTask(TaskE);
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
