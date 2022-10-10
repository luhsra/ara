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

#if LOCKS_JSON
{"no_timing": {"spin_states": {"S1": 0, "S2": 0}}}
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
