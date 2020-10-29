#include "autosar/os.h"

void doSomethingBefore() { }
void doSomethingAfter() { }
void doSomethingImportant2() { }
void doSomethingImportant() { }
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

TASK(TaskA) {
    doSomethingBefore();
    DisableAllInterrupts();
    // ActivateTask(TaskE);
    doSomethingAfter();
    EnableAllInterrupts();
    TerminateTask(); 
}

TASK(TaskB) {
    doSomethingImportant();
    TerminateTask(); 
}

TASK(TaskC) {
    doSomethingC();
    doSomethingAfter();
    TerminateTask(); 
}

TASK(TaskD) {
    // while (true) {
    //     doSomethingD();
    //     ActivateTask(TaskB);
    // }
    doSomethingD();
    ActivateTask(TaskB);
    TerminateTask(); 
}

TASK(TaskE) {
    doSomethingE();
    ActivateTask(TaskF);
    TerminateTask(); 
}

TASK(TaskF) {
    doSomethingE();
    ActivateTask(TaskE);
    TerminateTask(); 
}

// ISR2(Interrupt1) {
//     handleSomeEvent();
// }

// ISR2(Interrupt2) {
//     ActivateTask(TaskF);
// }

// TASK(TaskA) {
//     doSomethingBefore(); //race condition between the runtime of this ABB
//     ActivateTask(TaskD);

//     TerminateTask();
// }

// TASK(TaskB) {
//     DisableAllInterrupts();
//     doCriticalWork();
//     EnableAllInterrupts();

//     TerminateTask();
// }

// TASK(TaskF) {
//     while(true) {
//         doSomethingAfter();
//     }
//     TerminateTask();
// }

// TASK(TaskC) {
//     doSomethingC(); //and between this ABB
//     ActivateTask(TaskE);
//     TerminateTask();
// }

// TASK(TaskD) {
//     // ActivateTask(TaskF);
//     while(true) {
//         doSomethingD();
//     }

//     TerminateTask();
// }

// TASK(TaskE) {
//     ActivateTask(TaskF);
//     while(true) {
//         doSomethingE();
//     }
    
//     TerminateTask();
// }

int main(void){
    char * appmode = {"tmp"};
    StartOS(appmode);
    return 0;
}
