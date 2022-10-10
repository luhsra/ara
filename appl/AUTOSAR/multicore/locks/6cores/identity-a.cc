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

void ara_timing_info(int, int);

#if TRACE_JSON
{
  "vertices": {
    "1": 6,
    "15": 6,
    "16": 6,
    "20": 6,
    "21": 6,
    "25": 2,
    "26": 2,
    "34": 6,
    "35": 6,
    "36": 6,
    "37": 6,
    "41": 6,
    "42": 6,
    "43": 6,
    "44": 6,
    "48": 2,
    "49": 2,
    "55": 6,
    "56": 6,
    "57": 6,
    "58": 6,
    "62": 6,
    "63": 6,
    "64": 6,
    "65": 6,
    "69": 2,
    "70": 2,
    "76": 6,
    "77": 6,
    "78": 6,
    "79": 6,
    "83": 6,
    "84": 6,
    "85": 6,
    "86": 6,
    "90": 2,
    "91": 2,
    "97": 6,
    "98": 6,
    "99": 6,
    "100": 6,
    "104": 6,
    "105": 6,
    "106": 6,
    "107": 6,
    "111": 2,
    "112": 2,
    "118": 6,
    "119": 6,
    "120": 6,
    "121": 6,
    "125": 6,
    "126": 6,
    "127": 6,
    "128": 6,
    "132": 2,
    "133": 2,
    "136": 6,
    "137": 6,
    "138": 6,
    "139": 6
  },
  "edges": [
    [
      "1",
      "15"
    ],
    [
      "1",
      "15"
    ],
    [
      "15",
      "16"
    ],
    [
      "16",
      "20"
    ],
    [
      "16",
      "20"
    ],
    [
      "20",
      "21"
    ],
    [
      "21",
      "25"
    ],
    [
      "21",
      "25"
    ],
    [
      "21",
      "34"
    ],
    [
      "21",
      "36"
    ],
    [
      "25",
      "26"
    ],
    [
      "26",
      "34"
    ],
    [
      "26",
      "36"
    ],
    [
      "34",
      "35"
    ],
    [
      "35",
      "41"
    ],
    [
      "35",
      "41"
    ],
    [
      "36",
      "37"
    ],
    [
      "37",
      "41"
    ],
    [
      "37",
      "41"
    ],
    [
      "37",
      "43"
    ],
    [
      "37",
      "43"
    ],
    [
      "41",
      "42"
    ],
    [
      "42",
      "48"
    ],
    [
      "42",
      "48"
    ],
    [
      "42",
      "57"
    ],
    [
      "42",
      "55"
    ],
    [
      "43",
      "44"
    ],
    [
      "44",
      "48"
    ],
    [
      "44",
      "48"
    ],
    [
      "44",
      "55"
    ],
    [
      "44",
      "57"
    ],
    [
      "48",
      "49"
    ],
    [
      "49",
      "55"
    ],
    [
      "49",
      "57"
    ],
    [
      "55",
      "56"
    ],
    [
      "56",
      "62"
    ],
    [
      "56",
      "62"
    ],
    [
      "56",
      "64"
    ],
    [
      "56",
      "64"
    ],
    [
      "57",
      "58"
    ],
    [
      "58",
      "62"
    ],
    [
      "58",
      "62"
    ],
    [
      "62",
      "63"
    ],
    [
      "63",
      "69"
    ],
    [
      "63",
      "69"
    ],
    [
      "63",
      "78"
    ],
    [
      "63",
      "76"
    ],
    [
      "64",
      "65"
    ],
    [
      "65",
      "69"
    ],
    [
      "65",
      "69"
    ],
    [
      "65",
      "76"
    ],
    [
      "65",
      "78"
    ],
    [
      "69",
      "70"
    ],
    [
      "70",
      "76"
    ],
    [
      "70",
      "78"
    ],
    [
      "76",
      "77"
    ],
    [
      "77",
      "83"
    ],
    [
      "77",
      "83"
    ],
    [
      "77",
      "85"
    ],
    [
      "77",
      "85"
    ],
    [
      "78",
      "79"
    ],
    [
      "79",
      "83"
    ],
    [
      "79",
      "83"
    ],
    [
      "83",
      "84"
    ],
    [
      "84",
      "90"
    ],
    [
      "84",
      "90"
    ],
    [
      "84",
      "97"
    ],
    [
      "84",
      "99"
    ],
    [
      "85",
      "86"
    ],
    [
      "86",
      "90"
    ],
    [
      "86",
      "90"
    ],
    [
      "86",
      "99"
    ],
    [
      "86",
      "97"
    ],
    [
      "90",
      "91"
    ],
    [
      "91",
      "97"
    ],
    [
      "91",
      "99"
    ],
    [
      "97",
      "98"
    ],
    [
      "98",
      "104"
    ],
    [
      "98",
      "104"
    ],
    [
      "99",
      "100"
    ],
    [
      "100",
      "104"
    ],
    [
      "100",
      "104"
    ],
    [
      "100",
      "106"
    ],
    [
      "100",
      "106"
    ],
    [
      "104",
      "105"
    ],
    [
      "105",
      "111"
    ],
    [
      "105",
      "111"
    ],
    [
      "105",
      "118"
    ],
    [
      "105",
      "120"
    ],
    [
      "106",
      "107"
    ],
    [
      "107",
      "111"
    ],
    [
      "107",
      "111"
    ],
    [
      "107",
      "120"
    ],
    [
      "107",
      "118"
    ],
    [
      "111",
      "112"
    ],
    [
      "112",
      "118"
    ],
    [
      "112",
      "120"
    ],
    [
      "118",
      "119"
    ],
    [
      "119",
      "125"
    ],
    [
      "119",
      "125"
    ],
    [
      "119",
      "127"
    ],
    [
      "119",
      "127"
    ],
    [
      "120",
      "121"
    ],
    [
      "121",
      "125"
    ],
    [
      "121",
      "125"
    ],
    [
      "125",
      "126"
    ],
    [
      "126",
      "132"
    ],
    [
      "126",
      "132"
    ],
    [
      "126",
      "136"
    ],
    [
      "126",
      "15"
    ],
    [
      "127",
      "128"
    ],
    [
      "128",
      "132"
    ],
    [
      "128",
      "132"
    ],
    [
      "128",
      "136"
    ],
    [
      "128",
      "15"
    ],
    [
      "132",
      "133"
    ],
    [
      "133",
      "136"
    ],
    [
      "133",
      "15"
    ],
    [
      "136",
      "137"
    ],
    [
      "137",
      "138"
    ],
    [
      "137",
      "138"
    ],
    [
      "137",
      "20"
    ],
    [
      "137",
      "20"
    ],
    [
      "138",
      "139"
    ],
    [
      "139",
      "25"
    ],
    [
      "139",
      "25"
    ]
  ]
}
#endif //TRACE_JSON

#if TIMING_JSON
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
    {
      "src": "0",
      "tgt": "1",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "0",
      "tgt": "1",
      "bcet": 3,
      "wcet": 6
    },
    {
      "src": "1",
      "tgt": "2",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "2",
      "tgt": "3",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "2",
      "tgt": "3",
      "bcet": 1,
      "wcet": 3
    },
    {
      "src": "3",
      "tgt": "4",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "4",
      "tgt": "5",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "4",
      "tgt": "5",
      "bcet": 1,
      "wcet": 3
    },
    {
      "src": "4",
      "tgt": "7",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "5",
      "tgt": "6",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "6",
      "tgt": "7",
      "bcet": 3,
      "wcet": 6
    },
    {
      "src": "7",
      "tgt": "8",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "8",
      "tgt": "9",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "8",
      "tgt": "9",
      "bcet": 1,
      "wcet": 3
    },
    {
      "src": "9",
      "tgt": "10",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "10",
      "tgt": "11",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "10",
      "tgt": "11",
      "bcet": 1,
      "wcet": 3
    },
    {
      "src": "10",
      "tgt": "13",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "11",
      "tgt": "12",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "12",
      "tgt": "13",
      "bcet": 3,
      "wcet": 6
    },
    {
      "src": "13",
      "tgt": "14",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "14",
      "tgt": "15",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "14",
      "tgt": "15",
      "bcet": 1,
      "wcet": 3
    },
    {
      "src": "15",
      "tgt": "16",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "16",
      "tgt": "17",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "16",
      "tgt": "17",
      "bcet": 1,
      "wcet": 3
    },
    {
      "src": "16",
      "tgt": "19",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "17",
      "tgt": "18",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "18",
      "tgt": "19",
      "bcet": 3,
      "wcet": 6
    },
    {
      "src": "19",
      "tgt": "20",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "20",
      "tgt": "21",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "20",
      "tgt": "21",
      "bcet": 1,
      "wcet": 3
    },
    {
      "src": "21",
      "tgt": "22",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "22",
      "tgt": "23",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "22",
      "tgt": "23",
      "bcet": 1,
      "wcet": 3
    },
    {
      "src": "22",
      "tgt": "25",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "23",
      "tgt": "24",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "24",
      "tgt": "25",
      "bcet": 3,
      "wcet": 6
    },
    {
      "src": "25",
      "tgt": "26",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "26",
      "tgt": "27",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "26",
      "tgt": "27",
      "bcet": 1,
      "wcet": 3
    },
    {
      "src": "27",
      "tgt": "28",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "28",
      "tgt": "29",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "28",
      "tgt": "29",
      "bcet": 1,
      "wcet": 3
    },
    {
      "src": "28",
      "tgt": "31",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "29",
      "tgt": "30",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "30",
      "tgt": "31",
      "bcet": 3,
      "wcet": 6
    },
    {
      "src": "31",
      "tgt": "32",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "32",
      "tgt": "33",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "32",
      "tgt": "33",
      "bcet": 1,
      "wcet": 3
    },
    {
      "src": "33",
      "tgt": "34",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "34",
      "tgt": "35",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "34",
      "tgt": "35",
      "bcet": 1,
      "wcet": 3
    },
    {
      "src": "34",
      "tgt": "1",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "35",
      "tgt": "36",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "36",
      "tgt": "1",
      "bcet": 3,
      "wcet": 6
    }
  ]
}
#endif //TIMING_JSON

#if LOCKS_JSON
{"no_timing": {"spin_states": {"S1": 0, "S2": 0}},
 "with_timing": {"spin_states": {"S1": 0, "S2": 0}}}
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
	ara_timing_info(3, 6);
	GetSpinlock(S1);
	ara_timing_info(1, 3);
	ReleaseSpinlock(S1);
	ara_timing_info(1, 3);
	ActivateTask(T11);
	ara_timing_info(1, 1);
	TerminateTask();
}

TASK(T11) {
	ara_timing_info(3, 6);
	GetSpinlock(S1);
	ara_timing_info(1, 3);
	ReleaseSpinlock(S1);
	ara_timing_info(1, 3);
	ActivateTask(T21);
	ara_timing_info(1, 1);
	TerminateTask();
}

TASK(T21) {
	ara_timing_info(3, 6);
	GetSpinlock(S1);
	ara_timing_info(1, 3);
	ReleaseSpinlock(S1);
	ara_timing_info(1, 3);
	ActivateTask(T31);
	ara_timing_info(1, 1);
	TerminateTask();
}

TASK(T31) {
	ara_timing_info(3, 6);
	GetSpinlock(S1);
	ara_timing_info(1, 3);
	ReleaseSpinlock(S1);
	ara_timing_info(1, 3);
	ActivateTask(T41);
	ara_timing_info(1, 1);
	TerminateTask();
}

TASK(T41) {
	ara_timing_info(3, 6);
	GetSpinlock(S1);
	ara_timing_info(1, 3);
	ReleaseSpinlock(S1);
	ara_timing_info(1, 3);
	ActivateTask(T51);
	ara_timing_info(1, 1);
	TerminateTask();
}

TASK(T51) {
	ara_timing_info(3, 6);
	GetSpinlock(S1);
	ara_timing_info(1, 3);
	ReleaseSpinlock(S1);
	ara_timing_info(1, 3);
	ActivateTask(T01);
	ara_timing_info(1, 1);
	TerminateTask();
}


