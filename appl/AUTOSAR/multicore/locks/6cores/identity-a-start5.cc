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
{"S1": 0, "S2": 0}
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
	ActivateTask(T31);
	TerminateTask();
}

TASK(T31) {
	GetSpinlock(S1);
	ReleaseSpinlock(S1);
	ActivateTask(T41);
	TerminateTask();
}

TASK(T41) {
	GetSpinlock(S1);
	ReleaseSpinlock(S1);
	ActivateTask(T51);
	TerminateTask();
}

TASK(T51) {
	GetSpinlock(S1);
	ReleaseSpinlock(S1);
	ActivateTask(T01);
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
