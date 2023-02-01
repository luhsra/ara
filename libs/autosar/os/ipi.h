#ifndef _IPI_DATA_H_
#define _IPI_DATA_H_

namespace os {
namespace IPI {

typedef enum {
    ActivateTask,
    SetEvent,
} IPIType;

struct Data {
    IPIType id;
    int target_task_id;
    int set_event_mask;
};

}
}

#endif
