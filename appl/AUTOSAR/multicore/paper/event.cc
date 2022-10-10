/**
 * @defgroup apps Applications
 * @brief The applications...
 */

/**
 * @file
 * @ingroup apps
 * @brief Just a simple test application
 */
#include "autosar/os.h"
#include "test/test.h"
#include "machine.h"

typedef struct {int a;} result;

result* do_computation() {return nullptr;}

#if TRACE_JSON
{
  "vertices": {
    "0": 2,
    "1": 2,
    "2": 2,
    "3": 2,
    "4": 2,
    "5": 2,
    "6": 2,
    "7": 2,
    "8": 2,
    "9": 2,
    "10": 2,
    "11": 2,
    "12": 2
  },
  "edges": [
    [
      "0",
      "1"
    ],
    [
      "0",
      "1"
    ],
    [
      "1",
      "2"
    ],
    [
      "2",
      "3"
    ],
    [
      "2",
      "3"
    ],
    [
      "2",
      "5"
    ],
    [
      "2",
      "5"
    ],
    [
      "3",
      "4"
    ],
    [
      "4",
      "7"
    ],
    [
      "4",
      "7"
    ],
    [
      "4",
      "9"
    ],
    [
      "4",
      "9"
    ],
    [
      "5",
      "6"
    ],
    [
      "6",
      "11"
    ],
    [
      "6",
      "11"
    ],
    [
      "6",
      "9"
    ],
    [
      "6",
      "9"
    ],
    [
      "6",
      "7"
    ],
    [
      "6",
      "7"
    ],
    [
      "7",
      "8"
    ],
    [
      "9",
      "10"
    ],
    [
      "11",
      "12"
    ]
  ]
}
#endif //TRACE_JSON

#if LOCKS_JSON
{"no_timing": {"spin_states": {"S1": 0, "S2": 0}}}
#endif //LOCKS_JSON

DeclareTask(T1);
DeclareTask(T2);
DeclareTask(T3);
DeclareTask(T4);
DeclareTask(T5);
DeclareEvent(E1, 1);

TEST_MAKE_OS_MAIN( StartOS(0) )

TASK(T3) {
	ActivateTask(T4);
	SetEvent(T4, E1);
	ActivateTask(T2);
	TerminateTask();
}

TASK(T1) {
	/* ... */
	TerminateTask();
}



TASK(T4) {
	result* result = do_computation();
	WaitEvent(E1); //surely no wait -> no reschedule
	/* ... */
	TerminateTask();
}

TASK(T2) {
	/* ... */
	TerminateTask();
}

