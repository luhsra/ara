#ifndef _IPI_DATA_H_
#define _IPI_DATA_H_

#include "hardware_threads.h"
#include "spinlock.h"

#include "scheduler/task.h"

namespace os {
    namespace IPI {

        typedef enum {
            Cleared,
            ActivateTask,
            SetEvent,
        } IPIType;


        struct Data {
            IPIType id;
            int target_task_id;
            int set_event_mask;
        };

        extern "C" {
            bool ActivateTaskIPI(const os::scheduler::Task &task, bool sync);
            bool SetEventIPI(const os::scheduler::Task &task, EventMaskType mask, bool sync);
        }
    }
}

extern os::IPI::Data ipi_data [MAX_CPUS];
extern os::Spinlock ipi_lock[MAX_CPUS];

#endif
