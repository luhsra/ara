#include "autosar/os.h"

void doSomethingBefore() { }
void doSomethingAfter() { }
void doSomethingImportant() { }
void doSomethingC() { }
void doSomethingD() { }
void doSomethingE() { }
extern bool getBool();

DeclareTask(TaskA);
DeclareTask(TaskB);
DeclareTask(TaskC);
DeclareTask(TaskD);
DeclareTask(TaskE);

TASK(TaskA) {
    doSomethingBefore();
    ActivateTask(TaskD);
    doSomethingAfter();
    if (getBool()) {
        ActivateTask(TaskB);
    }
    TerminateTask();
}

TASK(TaskB) {
    doSomethingImportant();
    TerminateTask();
}

TASK(TaskC) {
    while(true) {
        doSomethingC();
        ActivateTask(TaskB);
    }
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
