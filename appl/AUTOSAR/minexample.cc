#include "os/os.h"
#include "test/test.h"

DeclareTask(TaskA);
DeclareTask(TaskB);
DeclareTask(TaskC);
DeclareTask(TaskD);
DeclareTask(TaskE);

TASK(TaskA) {
    doSomethingBefore();
    ActivateTask(TaskD);
    doSomethingAfter();
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

int  main(void){
    char * appmode = {"tmp"};
    StartOS(appmode);
    return 0;
}