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

#if LOCKS_JSON
{"S1": 0, "S2": 0}
#endif //LOCKS_JSON

DeclareTask(T01);
DeclareTask(T11);
DeclareSpinlock(S1);
DeclareSpinlock(S2);

TEST_MAKE_OS_MAIN( StartOS(0) )

TASK(T11) {
	GetSpinlock(S1);
	ReleaseSpinlock(S1);
	ActivateTask(T11);
	TerminateTask();
}

TASK(T01) {
	GetSpinlock(S1);
	ReleaseSpinlock(S1);
	TerminateTask();
}
