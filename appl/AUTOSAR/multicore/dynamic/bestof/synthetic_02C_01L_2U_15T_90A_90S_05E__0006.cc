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


DeclareTask(CPU0Task3Subtask8);
DeclareTask(CPU0Task4Subtask9);
DeclareTask(CPU0Task4Subtask14);
DeclareTask(CPU1Task0Subtask2);
DeclareTask(CPU1Task0Subtask5);
DeclareTask(CPU1Task0Subtask7);
DeclareTask(CPU1Task1Subtask0);
DeclareTask(CPU1Task2Subtask4);
DeclareTask(CPU1Task2Subtask10);
DeclareTask(CPU1Task2Subtask12);
DeclareTask(CPU1Task2Subtask13);
DeclareTask(CPU1Task5Subtask1);
DeclareTask(CPU1Task5Subtask3);
DeclareTask(CPU1Task5Subtask6);
DeclareTask(CPU1Task5Subtask11);


TEST_MAKE_OS_MAIN( StartOS(0) )

// Prototypes

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU0Task3Subtask8 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU0Task4Subtask14 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU0Task4Subtask9 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU1Task0Subtask2 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU1Task0Subtask5 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU1Task0Subtask7 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU1Task1Subtask0 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU1Task2Subtask10 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU1Task2Subtask12 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU1Task2Subtask13 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU1Task2Subtask4 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU1Task5Subtask1 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU1Task5Subtask11 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU1Task5Subtask3 (void);

noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_CPU1Task5Subtask6 (void);



void AUTOSAR_TASK_FUNC_CPU0Task3Subtask8 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU0Task3Subtask8" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task3Subtask8.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(4, 79); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task3Subtask8.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(2, 142); // 0
  ActivateTask(CPU1Task2Subtask4);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task3Subtask8.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(15, 156); // 0
  ActivateTask(CPU1Task5Subtask11);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task3Subtask8.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(15, 150); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task3Subtask8.4 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(18, 185); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU0Task4Subtask14 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU0Task4Subtask14" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task4Subtask14.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(14, 177); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task4Subtask14.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(11, 191); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task4Subtask14.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(19, 69); // 0
  ActivateTask(CPU0Task4Subtask9);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task4Subtask14.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(18, 184); // 0
  GetSpinlock(LOCK0);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task4Subtask14.4 sys_allowed=False inside_critical=True> x*/
  ara_timing_info(10, 13); // 1
  ReleaseSpinlock(LOCK0);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task4Subtask14.5 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(13, 116); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU0Task4Subtask9 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU0Task4Subtask9" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task4Subtask9.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(3, 113); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task4Subtask9.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(18, 177); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task4Subtask9.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(7, 132); // 0
  SetEvent(CPU1Task0Subtask7,EVENT4);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task4Subtask9.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(4, 138); // 0
  ActivateTask(CPU1Task5Subtask3);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU0Task4Subtask9.4 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(14, 46); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU1Task0Subtask2 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU1Task0Subtask2" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task0Subtask2.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(20, 102); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task0Subtask2.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(18, 62); // 0
  SetEvent(CPU1Task2Subtask13,EVENT3);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task0Subtask2.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(8, 39); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task0Subtask2.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(16, 139); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU1Task0Subtask5 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU1Task0Subtask5" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task0Subtask5.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(3, 114); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task0Subtask5.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(2, 158); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task0Subtask5.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(8, 49); // 0
  ActivateTask(CPU1Task0Subtask7);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task0Subtask5.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(18, 167); // 0
  ActivateTask(CPU1Task0Subtask2);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task0Subtask5.4 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(18, 53); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU1Task0Subtask7 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU1Task0Subtask7" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task0Subtask7.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(20, 166); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task0Subtask7.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(5, 158); // 0
  WaitEvent(EVENT4);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task0Subtask7.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(19, 40); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task0Subtask7.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(2, 151); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU1Task1Subtask0 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU1Task1Subtask0" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task1Subtask0.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(10, 178); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task1Subtask0.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(15, 76); // 0
  SetEvent(CPU1Task5Subtask3,EVENT2);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task1Subtask0.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(16, 82); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task1Subtask0.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(20, 139); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU1Task2Subtask10 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU1Task2Subtask10" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask10.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(20, 106); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask10.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(14, 29); // 0
  ActivateTask(CPU1Task2Subtask12);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask10.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(5, 45); // 0
  ActivateTask(CPU1Task2Subtask13);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask10.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(4, 124); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask10.4 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(15, 19); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU1Task2Subtask12 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU1Task2Subtask12" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask12.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(14, 54); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask12.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(19, 200); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask12.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(16, 37); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU1Task2Subtask13 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU1Task2Subtask13" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask13.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(4, 155); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask13.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(9, 114); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask13.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(10, 65); // 0
  WaitEvent(EVENT3);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask13.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(9, 170); // 0
  SetEvent(CPU1Task5Subtask1,EVENT0);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask13.4 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(7, 156); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU1Task2Subtask4 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU1Task2Subtask4" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask4.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(8, 70); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask4.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(10, 75); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask4.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(15, 105); // 0
  WaitEvent(EVENT1);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task2Subtask4.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(14, 28); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU1Task5Subtask1 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU1Task5Subtask1" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task5Subtask1.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(16, 196); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task5Subtask1.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(17, 156); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task5Subtask1.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(10, 155); // 0
  WaitEvent(EVENT0);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task5Subtask1.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(9, 10); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU1Task5Subtask11 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU1Task5Subtask11" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task5Subtask11.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(4, 54); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task5Subtask11.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(13, 53); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task5Subtask11.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(3, 146); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU1Task5Subtask3 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU1Task5Subtask3" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task5Subtask3.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(18, 129); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task5Subtask3.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(7, 119); // 0
  WaitEvent(EVENT2);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task5Subtask3.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(3, 195); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task5Subtask3.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(17, 188); // 0
  SetEvent(CPU1Task2Subtask4,EVENT1);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task5Subtask3.4 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(14, 84); // 0
  GetSpinlock(LOCK0);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task5Subtask3.5 sys_allowed=False inside_critical=True> x*/
  ara_timing_info(10, 14); // 1
  ReleaseSpinlock(LOCK0);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task5Subtask3.6 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(17, 99); // 0
  TerminateTask();

}

void AUTOSAR_TASK_FUNC_CPU1Task5Subtask6 (void) {
  // kout << "AUTOSAR_TASK_FUNC_CPU1Task5Subtask6" << endl;
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task5Subtask6.0 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(1, 65); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task5Subtask6.1 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(11, 66); // 0
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task5Subtask6.2 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(16, 73); // 0
  ActivateTask(CPU1Task5Subtask1);
  /* <InsertionPoint AUTOSAR_TASK_FUNC_CPU1Task5Subtask6.3 sys_allowed=True inside_critical=False> x*/
  ara_timing_info(15, 113); // 0
  TerminateTask();

}
