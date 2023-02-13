#include "autosar/os.h"
#include "test/test.h"
#include "machine.h"

//#include "fail/trace.h"

void ara_timing_info(int, int);



DeclareSpinlock(LOCK0);


DeclareEvent(EVENT0, 1);
DeclareEvent(EVENT1, 2);
DeclareEvent(EVENT2, 3);
DeclareEvent(EVENT3, 4);
DeclareEvent(EVENT4, 5);


DeclareTask(CPU0Task0Subtask1);
DeclareTask(CPU0Task0Subtask2);
DeclareTask(CPU0Task5Subtask5);
DeclareTask(CPU0Task5Subtask11);
DeclareTask(CPU1Task1Subtask4);
DeclareTask(CPU1Task1Subtask14);
DeclareTask(CPU1Task2Subtask0);
DeclareTask(CPU1Task2Subtask13);
DeclareTask(CPU2Task3Subtask3);
DeclareTask(CPU2Task3Subtask7);
DeclareTask(CPU2Task3Subtask8);
DeclareTask(CPU2Task3Subtask10);
DeclareTask(CPU2Task4Subtask6);
DeclareTask(CPU2Task4Subtask9);
DeclareTask(CPU2Task4Subtask12);


TEST_MAKE_OS_MAIN( StartOS(0) )

// Prototypes

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU0Task0Subtask1 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU0Task0Subtask2 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU0Task5Subtask11 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU0Task5Subtask5 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU1Task1Subtask14 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU1Task1Subtask4 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU1Task2Subtask0 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU1Task2Subtask13 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU2Task3Subtask10 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU2Task3Subtask3 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU2Task3Subtask7 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU2Task3Subtask8 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU2Task4Subtask12 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU2Task4Subtask6 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU2Task4Subtask9 (void);



void AUTOSAR_TASK_FUNC_CPU0Task0Subtask1 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU0Task0Subtask1" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task0Subtask1.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(14, 129); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task0Subtask1.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(5, 173); // 0
  GetSpinlock(LOCK0);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task0Subtask1.4 sys_allowed=False inside_critical=True> x*/
  ara_timing_info(5, 12); // 1
  ReleaseSpinlock(LOCK0);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task0Subtask1.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(3, 155); // 0
  ActivateTask(CPU2Task3Subtask8);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task0Subtask1.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(4, 67); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task0Subtask1.5 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(19, 34); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU0Task0Subtask2 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU0Task0Subtask2" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task0Subtask2.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(19, 90); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task0Subtask2.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(19, 104); // 0
  ActivateTask(CPU0Task0Subtask1);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task0Subtask2.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(6, 46); // 0
  SetEvent(CPU1Task1Subtask4,EVENT3);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task0Subtask2.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(10, 81); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task0Subtask2.4 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(15, 40); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU0Task5Subtask11 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU0Task5Subtask11" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task5Subtask11.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(19, 105); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task5Subtask11.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(15, 123); // 0
  WaitEvent(EVENT4);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task5Subtask11.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(6, 118); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task5Subtask11.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(4, 89); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU0Task5Subtask5 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU0Task5Subtask5" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task5Subtask5.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(19, 78); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task5Subtask5.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(12, 134); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task5Subtask5.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(15, 164); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU1Task1Subtask14 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU1Task1Subtask14" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task1Subtask14.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(15, 156); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task1Subtask14.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(15, 64); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task1Subtask14.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(17, 156); // 0
  ActivateTask(CPU1Task1Subtask4);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task1Subtask14.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(8, 16); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU1Task1Subtask4 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU1Task1Subtask4" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task1Subtask4.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(15, 123); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task1Subtask4.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(16, 30); // 0
  WaitEvent(EVENT3);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task1Subtask4.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(17, 87); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task1Subtask4.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(19, 73); // 0
  GetSpinlock(LOCK0);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task1Subtask4.4 sys_allowed=False inside_critical=True> x*/
  ara_timing_info(4, 6); // 1
  ReleaseSpinlock(LOCK0);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task1Subtask4.5 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(10, 31); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU1Task2Subtask0 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU1Task2Subtask0" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask0.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(20, 86); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask0.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(12, 59); // 0
  ActivateTask(CPU0Task5Subtask5);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask0.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(7, 58); // 0
  SetEvent(CPU2Task4Subtask9,EVENT0);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask0.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(15, 148); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask0.4 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(12, 68); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU1Task2Subtask13 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU1Task2Subtask13" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask13.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(14, 67); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask13.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(12, 93); // 0
  SetEvent(CPU2Task3Subtask8,EVENT2);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask13.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(17, 142); // 0
  ActivateTask(CPU1Task2Subtask0);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask13.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(2, 125); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask13.4 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(11, 95); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU2Task3Subtask10 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU2Task3Subtask10" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task3Subtask10.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(4, 137); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task3Subtask10.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(17, 92); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task3Subtask10.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(9, 168); // 0
  WaitEvent(EVENT1);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task3Subtask10.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(6, 122); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU2Task3Subtask3 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU2Task3Subtask3" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task3Subtask3.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(4, 81); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task3Subtask3.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(18, 44); // 0
  ActivateTask(CPU2Task3Subtask7);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task3Subtask3.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(19, 93); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task3Subtask3.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(11, 162); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU2Task3Subtask7 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU2Task3Subtask7" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task3Subtask7.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(8, 88); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task3Subtask7.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(17, 123); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task3Subtask7.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(13, 44); // 0
  SetEvent(CPU2Task3Subtask10,EVENT1);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task3Subtask7.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(3, 62); // 0
  ActivateTask(CPU2Task3Subtask10);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task3Subtask7.4 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(11, 41); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU2Task3Subtask8 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU2Task3Subtask8" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task3Subtask8.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(8, 73); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task3Subtask8.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(3, 57); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task3Subtask8.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(9, 175); // 0
  WaitEvent(EVENT2);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task3Subtask8.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(7, 80); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU2Task4Subtask12 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU2Task4Subtask12" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task4Subtask12.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(20, 141); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task4Subtask12.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(11, 134); // 0
  SetEvent(CPU0Task5Subtask11,EVENT4);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task4Subtask12.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(11, 167); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task4Subtask12.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(9, 110); // 0
  ActivateTask(CPU0Task5Subtask11);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task4Subtask12.4 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(10, 169); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU2Task4Subtask6 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU2Task4Subtask6" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task4Subtask6.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(15, 135); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task4Subtask6.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(4, 106); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task4Subtask6.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(13, 197); // 0
  ActivateTask(CPU2Task4Subtask9);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task4Subtask6.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(17, 182); // 0
  ActivateTask(CPU2Task4Subtask12);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task4Subtask6.4 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(14, 18); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU2Task4Subtask9 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU2Task4Subtask9" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task4Subtask9.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(16, 64); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task4Subtask9.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(8, 88); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task4Subtask9.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(17, 188); // 0
  WaitEvent(EVENT0);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU2Task4Subtask9.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(17, 141); // 0
  TerminateTask();

}
