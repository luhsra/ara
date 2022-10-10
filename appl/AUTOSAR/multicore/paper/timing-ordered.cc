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

void fetch_sensor_a();
void fetch_sensor_b();
void compute_with_a();
void compute_with_b();
void update_status(int);
extern "C" void ara_timing_info(int, int);

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
    "7": 2,
    "8": 2,
    "9": 3,
    "10": 3,
    "11": 3,
    "12": 3,
    "13": 3,
    "14": 3,
    "15": 3,
    "16": 3,
    "17": 3,
    "18": 3,
    "19": 3,
    "20": 3,
    "21": 3,
    "22": 3,
    "23": 3,
    "24": 3
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
      "4",
      "11"
    ],
    [
      "4",
      "13"
    ],
    [
      "4",
      "15"
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
      "11"
    ],
    [
      "8",
      "13"
    ],
    [
      "8",
      "15"
    ],
    [
      "9",
      "10"
    ],
    [
      "10",
      "17"
    ],
    [
      "10",
      "17"
    ],
    [
      "10",
      "19"
    ],
    [
      "10",
      "19"
    ],
    [
      "11",
      "12"
    ],
    [
      "12",
      "21"
    ],
    [
      "12",
      "21"
    ],
    [
      "12",
      "19"
    ],
    [
      "12",
      "19"
    ],
    [
      "13",
      "14"
    ],
    [
      "14",
      "19"
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
      "21"
    ],
    [
      "16",
      "21"
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
      "16",
      "19"
    ],
    [
      "16",
      "23"
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
      "19",
      "20"
    ],
    [
      "21",
      "22"
    ],
    [
      "23",
      "24"
    ]
  ]
}
#endif //TRACE_JSON

#if TIMING_JSON
{
  "vertices": {
    "0": 3,
    "1": 3,
    "2": 3,
    "3": 3,
    "4": 3,
    "5": 2,
    "6": 2,
    "7": 2,
    "8": 2,
    "9": 3,
    "10": 3,
    "11": 3,
    "12": 3
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
      "bcet": 2,
      "wcet": 7
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
      "bcet": 30,
      "wcet": 50
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
      "bcet": 2,
      "wcet": 3
    },
    {
      "src": "4",
      "tgt": "7",
      "bcet": 0,
      "wcet": 0
    },
    {
      "src": "4",
      "tgt": "9",
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
      "bcet": 20,
      "wcet": 300
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
      "bcet": 2,
      "wcet": 7
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
      "bcet": 10,
      "wcet": 17
    },
    {
      "src": "11",
      "tgt": "12",
      "bcet": 0,
      "wcet": 0
    }
  ]
}
#endif //TIMING_JSON

#if LOCKS_JSON
{"no_timing": {"spin_states": {"S1": 0}}, "with_timing": {"spin_states": {"S1": 0}}}
#endif //LOCKS_JSON

// CPU 0
DeclareTask(T1); // autostart
// CPU 1
DeclareTask(T2);
DeclareTask(T3);

// CPU2
DeclareTask(T4);

DeclareSpinlock(S1);

TEST_MAKE_OS_MAIN( StartOS(0) )

TASK(T1) {
	ara_timing_info(2, 7);
	GetSpinlock(S1);
	ara_timing_info(30, 50);
	update_status(1);
	ReleaseSpinlock(S1);
	ara_timing_info(2, 3);
	fetch_sensor_a();
	ActivateTask(T3);
	ara_timing_info(5, 8);
	fetch_sensor_b();
	TerminateTask();
}

TASK(T3) {
	ara_timing_info(20, 300);
	compute_with_a();
	ActivateTask(T4);
	TerminateTask();
}

TASK(T2) {
	ara_timing_info(50, 100);
	compute_with_b();
	GetSpinlock(S1);
	ara_timing_info(40, 50);
	update_status(2);
	ReleaseSpinlock(S1);
	ara_timing_info(10, 20);
	ActivateTask(T2);
	ara_timing_info(1, 2);
	TerminateTask();
}


TASK(T4) {
	ara_timing_info(2, 7);
	GetSpinlock(S1);
	ara_timing_info(10, 17);
	update_status(4);
	ReleaseSpinlock(S1);
	ara_timing_info(2, 19);
	TerminateTask();
}
