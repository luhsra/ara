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

/**
Cores A,B, C
Tasks 1, 2, 3

A  B  C
1
a
r
c  2
-  a
-  r
-  c
-  -  3
-  -  a
-  -  r
-  -  t
*/


#if SYSTEM_JSON
{
  "cpus": [
    {
      "id": 0,
      "tasks": {
        "T01": {
          "activation": 1,
          "autostart": true,
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
    }
  ],
  "spinlocks": [
      ["S1"],
      ["S2"]
  ]
}
#endif //SYSTEM_JSON

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
{"S1": 2, "S2": 2}
#endif //LOCKS_JSON




// Test memory protection (spanning over more than one 4k page in x86)
//volatile int testme[1024*4*10] __attribute__ ((section (".data.Handler12")));

DeclareTask(T01);
DeclareTask(T11);
DeclareTask(T21);
DeclareSpinlock(S1);
DeclareSpinlock(S2);

TEST_MAKE_OS_MAIN( StartOS(0) )

TASK(T01) {
	ActivateTask(T11);
	GetSpinlock(S1);
	ReleaseSpinlock(S1);
	TerminateTask();
}

TASK(T11) {
	GetSpinlock(S1);
	ReleaseSpinlock(S1);
	ActivateTask(T21);
	GetSpinlock(S2);
	ReleaseSpinlock(S2);
	TerminateTask();
}

TASK(T21) {
	GetSpinlock(S1);
	ReleaseSpinlock(S1);

	GetSpinlock(S2);
	ReleaseSpinlock(S2);
	TerminateTask();
}
