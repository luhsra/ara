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
    "0": 6,
    "1": 6,
    "2": 6,
    "3": 6,
    "4": 6,
    "5": 2,
    "6": 2,
    "7": 6,
    "8": 6,
    "9": 6,
    "10": 6,
    "11": 2,
    "12": 2,
    "13": 6,
    "14": 6,
    "15": 6,
    "16": 6,
    "17": 2,
    "18": 2,
    "19": 6,
    "20": 6,
    "21": 6,
    "22": 6,
    "23": 2,
    "24": 2,
    "25": 6,
    "26": 6,
    "27": 6,
    "28": 6,
    "29": 2,
    "30": 2,
    "31": 6,
    "32": 6,
    "33": 6,
    "34": 6,
    "35": 2,
    "36": 2
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
      "5",
      "6"
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
      "8",
      "9"
    ],
    [
      "8",
      "9"
    ],
    [
      "9",
      "10"
    ],
    [
      "10",
      "11"
    ],
    [
      "10",
      "11"
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
      "13"
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
      "15",
      "16"
    ],
    [
      "16",
      "17"
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
      "17",
      "18"
    ],
    [
      "18",
      "19"
    ],
    [
      "19",
      "20"
    ],
    [
      "20",
      "21"
    ],
    [
      "20",
      "21"
    ],
    [
      "21",
      "22"
    ],
    [
      "22",
      "23"
    ],
    [
      "22",
      "23"
    ],
    [
      "22",
      "25"
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
      "25",
      "26"
    ],
    [
      "26",
      "27"
    ],
    [
      "26",
      "27"
    ],
    [
      "27",
      "28"
    ],
    [
      "28",
      "29"
    ],
    [
      "28",
      "29"
    ],
    [
      "28",
      "31"
    ],
    [
      "29",
      "30"
    ],
    [
      "30",
      "31"
    ],
    [
      "31",
      "32"
    ],
    [
      "32",
      "33"
    ],
    [
      "32",
      "33"
    ],
    [
      "33",
      "34"
    ],
    [
      "34",
      "35"
    ],
    [
      "34",
      "35"
    ],
    [
      "34",
      "1"
    ],
    [
      "35",
      "36"
    ],
    [
      "36",
      "1"
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
DeclareTask(T31);
DeclareTask(T41);
DeclareTask(T51);
DeclareSpinlock(S1);
DeclareSpinlock(S2);

TEST_MAKE_OS_MAIN( StartOS(0) )

TASK(T01) {
	GetSpinlock(S1);
	ReleaseSpinlock(S1);
	ChainTask(T11);
}

TASK(T11) {
	GetSpinlock(S1);
	ReleaseSpinlock(S1);
	ChainTask(T21);
}

TASK(T21) {
	GetSpinlock(S1);
	ReleaseSpinlock(S1);
	ChainTask(T31);
}

TASK(T31) {
	GetSpinlock(S1);
	ReleaseSpinlock(S1);
	ChainTask(T41);
}

TASK(T41) {
	GetSpinlock(S1);
	ReleaseSpinlock(S1);
	ChainTask(T51);
}

TASK(T51) {
	GetSpinlock(S1);
	ReleaseSpinlock(S1);
	ChainTask(T01);
}


