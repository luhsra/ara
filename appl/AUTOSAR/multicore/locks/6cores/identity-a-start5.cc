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
  "vertices": [
  ],
  "edges": [
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



void ara_timing_info(int, int);


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


#if SYSTEM_JSON
{
  "cpus": [
    {
      "id": 0,
      "tasks": {
        "T01": {
          "activation": 1,
          "autostart": false,
          "priority": 4,
          "schedule": true,
          "spinlocks": ["S1", "S2"]
        }
      },
      "resources": {},
      "events": {},
      "alarms": {},
      "counters": {},
      "isrs": {}
    }, {
      "id": 1,
      "tasks": {
        "T11": {
          "activation": 1,
          "autostart": false,
          "priority": 1,
          "schedule": true,
          "spinlocks": ["S1", "S2"]
        }
      },
      "resources": {},
      "events": {},
      "alarms": {},
      "counters": {},
      "isrs": {}
    }, {
      "id": 2,
      "tasks": {
        "T21": {
          "activation": 1,
          "autostart": false,
          "priority": 1,
          "schedule": true,
          "spinlocks": ["S1", "S2"]
        }
      },
      "resources": {},
      "events": {},
      "alarms": {},
      "counters": {},
      "isrs": {}
    }, {
      "id": 3,
      "tasks": {
        "T31": {
          "activation": 1,
          "autostart": false,
          "priority": 1,
          "schedule": true,
          "spinlocks": ["S1", "S2"]
        }
      },
      "resources": {},
      "events": {},
      "alarms": {},
      "counters": {},
      "isrs": {}
    }, {
      "id": 4,
      "tasks": {
        "T41": {
          "activation": 1,
          "autostart": false,
          "priority": 1,
          "schedule": true,
          "spinlocks": ["S1", "S2"]
        }
      },
      "resources": {},
      "events": {},
      "alarms": {},
      "counters": {},
      "isrs": {}
    }, {
      "id": 5,
      "tasks": {
        "T51": {
          "activation": 1,
          "autostart": true,
          "priority": 1,
          "schedule": true,
          "spinlocks": ["S1", "S2"]
        }
      },
      "resources": {},
      "events": {},
      "alarms": {},
      "counters": {},
      "isrs": {}
    }
  ],
  "spinlocks": [
      ["S1"],
      ["S2"]
  ]
}
#endif //SYSTEM_JSON
