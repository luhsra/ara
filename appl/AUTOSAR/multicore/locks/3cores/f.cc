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


// TODO: wie geht das für multicore?
#if TRACE_JSON
{
  "vertices": {
    "0": 3,
    "1": 3,
    "2": 3,
    "3": 3,
    "4": 3,
    "5": 2,
    "6": 2,
    "7": 3,
    "8": 3,
    "9": 3,
    "10": 3,
    "11": 3,
    "12": 3,
    "13": 3,
    "14": 3,
    "15": 2,
    "16": 2,
    "17": 3,
    "18": 3,
    "19": 3,
    "20": 3,
    "21": 3,
    "22": 3,
    "23": 3,
    "24": 3,
    "25": 3,
    "26": 3,
    "27": 3,
    "28": 3,
    "29": 3,
    "30": 3,
    "31": 3,
    "32": 3
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
      "3",
      "4"
    ],
    [
      "4",
      "5"
    ],
    [
      "4",
      "5"
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
      "5",
      "6"
    ],
    [
      "6",
      "7"
    ],
    [
      "6",
      "9"
    ],
    [
      "7",
      "8"
    ],
    [
      "8",
      "11"
    ],
    [
      "8",
      "11"
    ],
    [
      "8",
      "13"
    ],
    [
      "8",
      "13"
    ],
    [
      "9",
      "10"
    ],
    [
      "10",
      "13"
    ],
    [
      "10",
      "13"
    ],
    [
      "11",
      "12"
    ],
    [
      "12",
      "15"
    ],
    [
      "12",
      "15"
    ],
    [
      "12",
      "19"
    ],
    [
      "12",
      "21"
    ],
    [
      "12",
      "17"
    ],
    [
      "12",
      "23"
    ],
    [
      "13",
      "14"
    ],
    [
      "14",
      "15"
    ],
    [
      "14",
      "15"
    ],
    [
      "14",
      "17"
    ],
    [
      "14",
      "19"
    ],
    [
      "15",
      "16"
    ],
    [
      "16",
      "17"
    ],
    [
      "16",
      "19"
    ],
    [
      "16",
      "21"
    ],
    [
      "16",
      "23"
    ],
    [
      "17",
      "18"
    ],
    [
      "18",
      "25"
    ],
    [
      "18",
      "25"
    ],
    [
      "19",
      "20"
    ],
    [
      "20",
      "27"
    ],
    [
      "20",
      "27"
    ],
    [
      "20",
      "25"
    ],
    [
      "20",
      "25"
    ],
    [
      "21",
      "22"
    ],
    [
      "22",
      "25"
    ],
    [
      "22",
      "25"
    ],
    [
      "22",
      "29"
    ],
    [
      "22",
      "29"
    ],
    [
      "22",
      "31"
    ],
    [
      "22",
      "31"
    ],
    [
      "22",
      "27"
    ],
    [
      "22",
      "27"
    ],
    [
      "23",
      "24"
    ],
    [
      "24",
      "25"
    ],
    [
      "24",
      "25"
    ],
    [
      "24",
      "29"
    ],
    [
      "24",
      "29"
    ],
    [
      "25",
      "26"
    ],
    [
      "27",
      "28"
    ],
    [
      "29",
      "30"
    ],
    [
      "31",
      "32"
    ]
  ]
}
#endif //TRACE_JSON

#if LOCKS_JSON
{"no_timing": {"spin_states": {"S1": 0, "S2": 0}}}
#endif //LOCKS_JSON





DeclareTask(T01);
DeclareTask(T11);
DeclareTask(T21);
DeclareSpinlock(S1);
DeclareSpinlock(S2);

TEST_MAKE_OS_MAIN( StartOS(0) )

TASK(T01) {
	GetSpinlock(S1);
	ReleaseSpinlock(S1);
	ActivateTask(T11);
	TerminateTask();
}

TASK(T11) {
	GetSpinlock(S1);
	ReleaseSpinlock(S1);
	ActivateTask(T21);
	TerminateTask();
}

TASK(T21) {
	GetSpinlock(S1);
	ReleaseSpinlock(S1);
	TerminateTask();
}

