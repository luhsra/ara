#include "os.h"
#include "tcb.h"
#include "os/scheduler/task.h"
#include "os/counter.h"
#include "os/alarm.h"
#include "os/spinlock.h"
#include <errno.h>
#include "os/scheduler/scheduler.h"
#include "os/util/redundant.h"
#include "syscall.h"
#include "machine.h"
#include "hardware_threads.h"

extern "C" void  AUTOSAR_TASK_FUNC_H1();
extern "C" void  AUTOSAR_TASK_FUNC_H2();
extern "C" void  AUTOSAR_TASK_FUNC_H3();
extern "C" void  AUTOSAR_TASK_FUNC_H4();
extern "C" void  AUTOSAR_TASK_FUNC_H5();
extern "C" void  __OS_StartOS_dispatch(int);
extern "C" void  StartOS(int);
extern "C" void  AUTOSAR_ShutdownOS(StatusType);
extern "C" void  AUTOSAR_ShutdownAllCores(StatusType);
extern "C" void  __OS_ASTSchedule(int);

extern "C" bool ActivateTask_IPI_helper(const Task &task, bool sync = true);
extern "C" bool SetEvent_IPI_helper(const Task &task, EventMaskType mask, bool sync = true);

void  __OS_HOOK_PreIdleHook();
void  __OS_HOOK_FaultDetectedHook(DetectedFault_t,uint32_t,uint32_t);
void  __OS_HOOK_StartupHook();
void  __OS_HOOK_PreTaskHook();
void  __OS_HOOK_PostTaskHook();
void  __OS_HOOK_ShutdownHook(StatusType);
void  __OS_enable_irq_after_kernel();

extern "C" uint8_t H1_stack[4096];
extern "C" uint8_t H2_stack[4096];
extern "C" uint8_t H3_stack[4096];
extern "C" uint8_t H4_stack[4096];
extern "C" uint8_t H5_stack[4096];
extern "C" const TaskType AUTOSAR_TASK_H1;
extern "C" const TaskType AUTOSAR_TASK_H2;
extern "C" const TaskType AUTOSAR_TASK_H3;
extern "C" const TaskType AUTOSAR_TASK_H4;
extern "C" const TaskType AUTOSAR_TASK_H5;
extern "C" const ResourceType AUTOSAR_RESOURCE_R234;
extern "C" const ResourceType AUTOSAR_RESOURCE_R345;
extern "C" const ResourceType AUTOSAR_RESOURCE_RES_SCHEDULER;
extern "C" const SpinlockType AUTOSAR_SPINLOCK_S1;

namespace arch{
    extern void * OS_H1_stackptr;
    extern void * OS_H2_stackptr;
    extern void * OS_H3_stackptr;
    extern void * OS_H4_stackptr;
    extern void * OS_H5_stackptr;
    extern "C" uint8_t __attribute__((aligned(4096))) shared_basic_stack[4096];
    extern "C" void * OS_basic_task_stackptr;
    extern const arch::TCB OS_H1_tcb;
    extern const arch::TCB OS_H2_tcb;
    extern const arch::TCB OS_H3_tcb;
    extern const arch::TCB OS_H4_tcb;
    extern const arch::TCB OS_H5_tcb;
}

namespace os{
    namespace tasks{
        extern const os::scheduler::Task OS_H1_task;
        extern const os::scheduler::Task OS_H2_task;
        extern const os::scheduler::Task OS_H3_task;
        extern const os::scheduler::Task OS_H4_task;
        extern const os::scheduler::Task OS_H5_task;
    }
}


uint8_t H1_stack[4096];
uint8_t H2_stack[4096];
uint8_t H3_stack[4096];
uint8_t H4_stack[4096];
uint8_t H5_stack[4096];
const TaskType AUTOSAR_TASK_H1 = 1;
const TaskType AUTOSAR_TASK_H2 = 2;
const TaskType AUTOSAR_TASK_H3 = 3;
const TaskType AUTOSAR_TASK_H4 = 4;
const TaskType AUTOSAR_TASK_H5 = 5;
const ResourceType AUTOSAR_RESOURCE_R234 = 6;
const ResourceType AUTOSAR_RESOURCE_R345 = 4;
const ResourceType AUTOSAR_RESOURCE_RES_SCHEDULER = 8;

const SpinlockType AUTOSAR_SPINLOCK_S1 = 9;

namespace arch{
    void * OS_H1_stackptr;
    void * OS_H2_stackptr;
    void * OS_H3_stackptr;
    void * OS_H4_stackptr;
    void * OS_H5_stackptr;
    uint8_t __attribute__((aligned(4096))) shared_basic_stack[4096];
    void * OS_basic_task_stackptr = shared_basic_stack+ 4096;
    constexpr const arch::TCB OS_H1_tcb(&AUTOSAR_TASK_FUNC_H1, H1_stack, OS_H1_stackptr, 1, 4096);
    constexpr const arch::TCB OS_H2_tcb(&AUTOSAR_TASK_FUNC_H2, H2_stack, OS_H2_stackptr, 2, 4096);
    constexpr const arch::TCB OS_H3_tcb(&AUTOSAR_TASK_FUNC_H3, H3_stack, OS_H3_stackptr, 3, 4096);
    constexpr const arch::TCB OS_H4_tcb(&AUTOSAR_TASK_FUNC_H4, H4_stack, OS_H4_stackptr, 4, 4096);
    constexpr const arch::TCB OS_H5_tcb(&AUTOSAR_TASK_FUNC_H5, H5_stack, OS_H5_stackptr, 5, 4096);
}

namespace os{
    os::Spinlock OS_S1(AUTOSAR_SPINLOCK_S1);

    os::Spinlock* getSpinlockFromType(SpinlockType type) {
        switch(type) {
            case AUTOSAR_SPINLOCK_S1:
                return &OS_S1;
            default:
                return nullptr;
        }
    }
}

namespace os{
    namespace tasks{
        constexpr const os::scheduler::Task OS_H1_task(1, 1, 7, true, arch::OS_H1_tcb);
        constexpr const os::scheduler::Task OS_H2_task(2, 1, 5, true, arch::OS_H2_tcb);
        constexpr const os::scheduler::Task OS_H3_task(3, 0, 3, true, arch::OS_H3_tcb);
        constexpr const os::scheduler::Task OS_H4_task(4, 0, 2, true, arch::OS_H4_tcb);
        constexpr const os::scheduler::Task OS_H5_task(5, 0, 1, true, arch::OS_H5_tcb);
    }

    const os::scheduler::Task& getTask(id_t task_id) {
        switch(task_id) {
            case 1: return tasks::OS_H1_task;
            case 2: return tasks::OS_H2_task;
            case 3: return tasks::OS_H3_task;
            case 4: return tasks::OS_H4_task;
            case 5: return tasks::OS_H5_task;
        }
    }
}

using namespace arch;
using namespace os::tasks;

// ****************************************************************
// TaskList Implementation
// ****************************************************************
namespace os { namespace scheduler {

// only needed for Tasklist constructor comma placement
class UnencodedTaskListStatic {};

/* Simpler array based task queue */
struct TaskList : public UnencodedTaskListStatic {
    typedef uint32_t event_mask_t;

    typedef Task::prio_t current_prio_t;
    typedef Task::id_t current_task_t;

    static constexpr auto scheduler_prio = 8;

    Task::prio_t H1;
    event_mask_t H1_events_waiting;
    event_mask_t H1_events_set;

    Task::prio_t H2;
    event_mask_t H2_events_waiting;
    event_mask_t H2_events_set;

    Task::prio_t H3;
    event_mask_t H3_events_waiting;
    event_mask_t H3_events_set;

    Task::prio_t H4;
    event_mask_t H4_events_waiting;
    event_mask_t H4_events_set;

    Task::prio_t H5;
    event_mask_t H5_events_waiting;
    event_mask_t H5_events_set;

    // idle task id/priority
    static constexpr Task::id_t idle_id     = 0;
    static constexpr Task::prio_t idle_prio = 0;

    TaskList() : UnencodedTaskListStatic()
        , H1(0), H1_events_waiting(0), H1_events_set(0)
        , H2(0), H2_events_waiting(0), H2_events_set(0)
        , H3(0), H3_events_waiting(0), H3_events_set(0)
        , H4(0), H4_events_waiting(0), H4_events_set(0)
        , H5(0), H5_events_waiting(0), H5_events_set(0)

    { /* empty constructor */ }

    forceinline uint32_t isReady(const Task::id_t id) {
        if (id == 1) {
            return H1;
        } else if (id == 2) {
            return H2;
        } else if (id == 3) {
            return H3;
        } else if (id == 4) {
            return H4;
        } else if (id == 5) {
            return H5;
        } else {
            assert(false);
            return false;
        }
    }

    /** Set priority of task id to prio **/
    forceinline void set(const Task::id_t id, const Task::prio_t prio) {
        if (id == 1) {
           H1 = prio;
        } else if (id == 2) {
           H2 = prio;
        } else if (id == 3) {
           H3 = prio;
        } else if (id == 4) {
           H4 = prio;
        } else if (id == 5) {
           H5 = prio;
        } else       {
             assert(false);
         }
    }

    /** Set priority of task id to prio **/
    forceinline void activate(const Task::id_t id, const Task::prio_t prio) {
        if (id == 1) {
            if (H1 < prio) {
                H1 = prio;
                H1_events_waiting = 0;
                H1_events_set = 0;
            }
        } else if (id == 2) {
            if (H2 < prio) {
                H2 = prio;
                H2_events_waiting = 0;
                H2_events_set = 0;
            }
        } else if (id == 3) {
            if (H3 < prio) {
                H3 = prio;
                H3_events_waiting = 0;
                H3_events_set = 0;
            }
        } else if (id == 4) {
            if (H4 < prio) {
                H4 = prio;
                H4_events_waiting = 0;
                H4_events_set = 0;
            }
        } else if (id == 5) {
            if (H5 < prio) {
                H5 = prio;
                H5_events_waiting = 0;
                H5_events_set = 0;
            }
        } else {
            assert(false);
        }
    }

    template<const bool* possible_tasks = nullptr>
    forceinline void head(Task::id_t& id, Task::prio_t& prio) const {
        // start with idle id/priority
        id = idle_id;
        prio = idle_prio;

        if (get_cpuid() == 1) {
            if (possible_tasks == nullptr || possible_tasks[1]) {
                if(H1 > prio && ((H1_events_waiting == 0) || (H1_events_waiting & H1_events_set) != 0)) {
                    prio = H1;
                    id = 1;
                }
            }
            if (possible_tasks == nullptr || possible_tasks[2]) {
                if(H2 > prio && ((H1_events_waiting == 0) || (H2_events_waiting & H2_events_set) != 0)) {
                    prio = H2;
                    id = 2;
                }
            }
        }
        else if (get_cpuid() == 0) {
            if (possible_tasks == nullptr || possible_tasks[3]) {
                if(H3 > prio && ((H3_events_waiting == 0) || (H3_events_waiting & H3_events_set) != 0)) {
                    prio = H3;
                    id = 3;
                }
            }
            if (possible_tasks == nullptr || possible_tasks[4]) {
                if(H4 > prio && ((H4_events_waiting == 0) || (H4_events_waiting & H4_events_set) != 0)) {
                    prio = H4;
                    id = 4;
                }
            }
            if (possible_tasks == nullptr || possible_tasks[5]) {
                if(H5 > prio && ((H5_events_waiting == 0) || (H5_events_waiting & H5_events_set) != 0)) {
                    prio = H5;
                    id = 5;
                }
            }
        }
    }

    /** Wait for a specific event mask **/
    forceinline void wait_events(const Task::id_t id, const event_mask_t mask) {
        (void) id;
        (void) mask;

        if (id == 1) {
           H1_events_waiting = mask;
        } else if (id == 2) {
           H2_events_waiting = mask;
        } else if (id == 3) {
           H3_events_waiting = mask;
        } else if (id == 4) {
           H4_events_waiting = mask;
        } else if (id == 5) {
           H5_events_waiting = mask;
        } else {
            assert(false);
        }
    }

    /** Set Events **/
    forceinline void set_events(const Task::id_t id, const event_mask_t mask) {
        (void) id;
        (void) mask;
        if (id == 1) {
           H1_events_set |= mask;
        } else if (id == 2) {
           H2_events_set |= mask;
        } else if (id == 3) {
           H3_events_set |= mask;
        } else if (id == 4) {
           H4_events_set |= mask;
        } else if (id == 5) {
           H5_events_set |= mask;
        } else {
            assert(false);
        }
    }

    /** Clear Events **/
    forceinline void clear_events(const Task::id_t id, const event_mask_t mask) {
        (void) id;
        (void) mask;
        if (id == 1) {
           H1_events_waiting &= ~mask;
           H1_events_set &= ~mask;
        } else if (id == 2) {
           H2_events_waiting &= ~mask;
           H2_events_set &= ~mask;
        } else if (id == 3) {
           H3_events_waiting &= ~mask;
           H3_events_set &= ~mask;
        } else if (id == 4) {
           H4_events_waiting &= ~mask;
           H4_events_set &= ~mask;
        } else if (id == 5) {
           H5_events_waiting &= ~mask;
           H5_events_set &= ~mask;
        } else {
            assert(false);
        }
    }

    forceinline void remove(const Task::id_t& id) {
        set(id, 0);
    }

    /** Get Events **/
    forceinline event_mask_t get_events(const Task::id_t id) {
        (void) id;
        if (id == 1) {
            return H1_events_set;
        } else if (id == 2) {
            return H2_events_set;
        } else if (id == 3) {
            return H3_events_set;
        } else if (id == 4) {
            return H4_events_set;
        } else if (id == 5) {
            return H5_events_set;
        } else {
            assert(false);
        }
        return 0;
    }

    static Task::id_t decode_task_id(Task::id_t id){
        return id;
    }

    static Task::id_t encode_task_id(Task::id_t id){
        return id;
    }

    static Task::prio_t encode_task_prio(Task::prio_t prio){
        return prio;
    }


};

/** Equality operator (used for TMR) [enc=0] **/
bool operator==(const TaskList& lhs, const TaskList& rhs) {
    if(lhs.H1 != rhs.H1) return false;
    if(lhs.H1_events_waiting != rhs.H1_events_waiting) return false;
    if(lhs.H1_events_set != rhs.H1_events_set) return false;

    if(lhs.H2 != rhs.H2) return false;
    if(lhs.H2_events_waiting != rhs.H2_events_waiting) return false;
    if(lhs.H2_events_set != rhs.H2_events_set) return false;

    if(lhs.H3 != rhs.H3) return false;
    if(lhs.H3_events_waiting != rhs.H3_events_waiting) return false;
    if(lhs.H3_events_set != rhs.H3_events_set) return false;

    if(lhs.H4 != rhs.H4) return false;
    if(lhs.H4_events_waiting != rhs.H4_events_waiting) return false;
    if(lhs.H4_events_set != rhs.H4_events_set) return false;

    if(lhs.H5 != rhs.H5) return false;
    if(lhs.H5_events_waiting != rhs.H5_events_waiting) return false;
    if(lhs.H5_events_set != rhs.H5_events_set) return false;

    return true;
}

bool operator!=(const TaskList& lhs, const TaskList& rhs) { return !(lhs == rhs); }

}; // scheduler
}; // os
namespace os { namespace tasks {};};
namespace os {
namespace scheduler {


using namespace os::tasks;
using namespace arch;



struct Scheduler {
    os::scheduler::TaskList tlist;

    os::scheduler::TaskList::current_prio_t current_prio;
    os::scheduler::TaskList::current_task_t current_task;

    Task::id_t ipi_activated_task_id = 0;
    EventMaskType ipi_event_mask = 0;
    Task::id_t ipi_event_task_id = 0;

    template<const bool *possible_tasks = nullptr>
    forceinline void PartialReschedule() {
        if (Dispatcher::getSpinlockCnt(get_cpuid())) {
            debug_core << "Task still holding Spinlocks, cannot reschedule" << endl;
            return;
        }

        tlist.head<possible_tasks>(current_task, current_prio);

        dispatchToCurrentTask();
    }

    forceinline void InlinedReschedule(void) {

        if (Dispatcher::getSpinlockCnt(get_cpuid())) {
            debug_core << "Task still holding Spinlocks, cannot reschedule" << endl;
            return;
        }

        // update current_task
        tlist.head(current_task, current_prio);
        // dispatch
        dispatchToCurrentTask();
    }

    noinline void Reschedule() {

        if (Dispatcher::getSpinlockCnt(get_cpuid())) {
            debug_core << "Task still holding Spinlocks, cannot reschedule" << endl;
            return;
        }
        // update current_task
        tlist.head(current_task, current_prio);
        // dispatch
        dispatchToCurrentTask();
    }

    forceinline void Schedule_impl(bool from_interrupt=false) {
        debug_core << __FUNCTION__ << "(" << from_interrupt << ")" << endl;
        // TODO: in_syscall replacement needed ?
        if(!from_interrupt /*&& in_syscall()*/) {
            // in syscall: reschedule directly
#ifdef CONFIG_OS_INLINE_SCHEDULER
            InlinedReschedule();
#else
            Reschedule();
#endif
        } else {
            // not in syscall (probably in ISR): request reschedule AST
            // Calls also Reschedule()
            debug_core << "request_reschedule_ast" << endl;
            request_reschedule_ast();
        }
    }

    forceinline void SetReady_impl(const Task &task) {
        debug_core << __FUNCTION__ << "(" << (int) task.id << ")" << endl;
        tlist.activate(task.id, task.prio);
    }


    forceinline void SetSuspended_impl(const Task &t) {
        debug_core << __FUNCTION__ << "(" << (int) t.id << ")" << endl;
        Dispatcher::Destroy(t);
        tlist.remove(t.id);
    }

    forceinline void ActivateTask_impl(const Task &task, bool from_interrupt=false, bool sync=true) {
        debug_core << __FUNCTION__ << "(" << (int) task.id << ")" << endl;

        if (ActivateTask_IPI_helper(task, sync)) {
            return; // no need to reschedule on this core
        }
        SetReady_impl(task);
        Schedule_impl(from_interrupt);
    }

    forceinline void ChainTask_impl(const Task &from, const Task &to) {
        debug_core << __FUNCTION__ << "(" << (int) from.id << "," << (int)to.id <<")" << endl;
        SetSuspended_impl(from);
        SetReady_impl(to);
        Schedule_impl();
    }

    forceinline void TerminateTask_impl(const Task &from) {
        debug_core << __FUNCTION__ << "(" << (int) from.id << ")" << endl;
        SetSuspended_impl(from);
        Schedule_impl();
    }

    forceinline void GetResource_impl(const Task &current_task, const Task::prio_t new_prio) {
        debug_core << __FUNCTION__ << "(" << (int) current_task.id << ")" << endl;
        SetPriority(current_task, new_prio);
        SetSystemPriority(new_prio);
    }

    forceinline void ReleaseResource_impl(const Task &current_task, const Task::prio_t new_prio) {
        debug_core << __FUNCTION__ << "(" << (int) current_task.id << ")" << endl;
        SetPriority(current_task, new_prio);
        SetSystemPriority(new_prio);
        Schedule_impl();
    }

    forceinline void SetEvent_impl(const Task &other_task, const int event_mask, bool sync=true) {
        debug_core << __FUNCTION__ << "(" << (int) other_task.id << ")" << endl;


        if (SetEvent_IPI_helper(other_task, event_mask, sync)) {
            return; // no need to reschedule on this core
        }

        tlist.set_events(other_task.id, event_mask);
        Schedule_impl();
    }

    forceinline void WaitEvent_impl(const Task &current_task, const int event_mask) {
        debug_core << __FUNCTION__ << "(" << (int) current_task.id << ", " << event_mask << ")" << endl;
        tlist.wait_events(current_task.id, event_mask);
        Schedule_impl();
    }

    forceinline void ClearEvent_impl(const Task &current_task, const int event_mask) {
        debug_core << __FUNCTION__ << "(" << (int) current_task.id << ", " << event_mask << ")" << endl;
        tlist.clear_events(current_task.id, event_mask);
    }

    forceinline uint32_t GetEvent_impl(const Task &current_task) {
        debug_core << __FUNCTION__ << "(" << (int) current_task.id << ")" << endl;
        return tlist.get_events(current_task.id);
    }

    forceinline void SetReadyFromSuspended_impl(const Task &task) {
        debug_core << __FUNCTION__ << "(" << (int) task.id << ")" << endl;
        SetPriority(task, task.prio);
        // Clear all Events
        tlist.clear_events(task.id, ~0);
    }

    // Low level interface to the task list
    forceinline void SetCurrentTask(const Task &task) {
        if (task.preemptable == false) {
            // promote non-preemptable task to RES_SCHEDULER
            tlist.set(task.id, tlist.scheduler_prio);
            current_prio = tlist.scheduler_prio;
        }
        current_task = tlist.encode_task_id(task.id);
    }

    forceinline void SetSystemPriority(const Task::prio_t new_prio) {
        current_prio = tlist.encode_task_prio(new_prio);
    }

    forceinline void SetPriority(const Task &task, const Task::prio_t new_prio) {
        tlist.set(task.id, new_prio);
    }

    forceinline uint32_t isReady(const Task &task) {
        return tlist.isReady(task.id);
    }

    forceinline Task::id_t getCurrent_TaskID(void) const {
        return tlist.decode_task_id(current_task);
    }

    forceinline void dispatchToCurrentTask(void) {
        // dispatch or enter idle
        if(current_task == 1) {
            Dispatcher::Dispatch(OS_H1_task);
        } else if(current_task == 2) {
            Dispatcher::Dispatch(OS_H2_task);
        } else if(current_task == 3) {
            Dispatcher::Dispatch(OS_H3_task);
        } else if(current_task == 4) {
            Dispatcher::Dispatch(OS_H4_task);
        } else if(current_task == 5) {
            Dispatcher::Dispatch(OS_H5_task);
        } else if(current_task == TaskList::idle_id) {
            Dispatcher::Idle();
        } else {
        CALL_HOOK(FaultDetectedHook, LOGIC_ERRORdetected, 0, 0);
        }
    }

    forceinline StatusType GetSpinlock_impl(SpinlockType r) {
        debug_core << __FUNCTION__ << "(" << r << ")" << endl;
        os::Spinlock* sl = getSpinlockFromType(r);

        if (sl->lock()) {
            return E_NOT_OK;
        }
        Dispatcher::spinlockInc(get_cpuid());
        return E_OK;
    }

    forceinline StatusType TryToGetSpinlock_impl(SpinlockType r, int* success) {
        debug_core << __FUNCTION__ << "(" << r << ")" << endl;
        os::Spinlock* sl = getSpinlockFromType(r);

        int rc = sl->trylock();

        if (rc == EBUSY) {
            *success = false;
            debug_core << __FUNCTION__ << " BUSY" << endl;
            return E_OK;
        }
        if (rc != 0) {
            *success = false;
            return E_NOT_OK;
        }

        *success = true;
        Dispatcher::spinlockInc(get_cpuid());
        return E_OK;
    }

    forceinline StatusType ReleaseSpinlock_impl(SpinlockType r) {
    debug_core << __FUNCTION__ << "(" << r << ")" << endl;
    os::Spinlock* sl = getSpinlockFromType(r);

    if (sl->unlock()) {
        return E_NOT_OK;
    }
    Dispatcher::spinlockDec(get_cpuid());
    return E_OK;
}
};


Scheduler scheduler_[MAX_CPUS];

extern "C" bool ActivateTask_IPI_helper(const Task &task, bool sync) {
    if (task.target_cpuid != get_cpuid()) {
        debug_core << __FUNCTION__ << "(" << task.id << ")" << endl;
        scheduler_[task.target_cpuid].ipi_activated_task_id = task.id; // store task id to activate

        Machine::trigger_interrupt(SIGUSR1, task.target_cpuid);

        if (sync) {
            while (scheduler_[task.target_cpuid].ipi_activated_task_id == task.id); // wait until IPI succeeded
            debug_core << __FUNCTION__ << " waiting finished" << endl;
        }
        return true;
    }
    return false;
}

extern "C" bool SetEvent_IPI_helper(const Task &task, EventMaskType mask, bool sync) {
    if (task.target_cpuid != get_cpuid()) {
        debug_core << __FUNCTION__ << "(" << (int) task.id << ", " << mask << ")" << endl;

        scheduler_[task.target_cpuid].ipi_event_mask = mask;

        scheduler_[task.target_cpuid].ipi_event_task_id = task.id;
        Machine::trigger_interrupt(SIGUSR2, task.target_cpuid);

        if (sync) {
            while (scheduler_[task.target_cpuid].ipi_event_mask == mask); // wait until IPI succeeded
            debug_core << __FUNCTION__ << " waiting finished" << endl;
        }
        return true;
    }
    return false;
}

extern "C" StatusType AUTOSAR_GetTaskID(TaskRefType a) {
    *a = scheduler_[get_cpuid()].getCurrent_TaskID();
    return E_OK;
}

extern "C" CoreIdType AUTOSAR_GetCoreID() {
    return get_cpuid();
}

extern "C" StatusType AUTOSAR_GetSpinlock(SpinlockType r) {

    Machine::disable_interrupts();
    StatusType rc = scheduler_[get_cpuid()].GetSpinlock_impl(r);
    __OS_enable_irq_after_kernel();
    return rc;
}

extern "C" StatusType AUTOSAR_TryToGetSpinlock(SpinlockType r, int* success) {
    Machine::disable_interrupts();
    StatusType rc = scheduler_[get_cpuid()].TryToGetSpinlock_impl(r, success);
    __OS_enable_irq_after_kernel();
    return rc;
}

extern "C" StatusType AUTOSAR_ReleaseSpinlock(SpinlockType r) {
    Machine::disable_interrupts();
    StatusType rc = scheduler_[get_cpuid()].ReleaseSpinlock_impl(r);
    __OS_enable_irq_after_kernel();
    return rc;
}


}; // scheduler
}; // os
#include "counter.h"
#include "alarm.h"

namespace os {

void inlinehint Counter::tick() {
}

} // os

extern "C" void __OS_StartOS_dispatch(int arg0){
    (void) arg0;
    scheduler_[get_cpuid()].InlinedReschedule();
}

static int cores = 0;

extern "C" void AUTOSAR_StartCore() {
    debug_core << __FUNCTION__ << endl;

    cores++;
    
    CALL_HOOK(StartupHook);
    syscall(__OS_StartOS_dispatch);

    Machine::unreachable();
}

void irq_handler (int signo) {

    debug_core << "IRQ " << signo << endl;

    if (signo == SIGUSR1) {
        scheduler_[get_cpuid()].SetReady_impl(os::getTask(scheduler_[get_cpuid()].ipi_activated_task_id));
        scheduler_[get_cpuid()].Schedule_impl(true);
        scheduler_[get_cpuid()].ipi_activated_task_id = 0; // mark IPI as completed

    } else if (signo == SIGUSR2) {
        scheduler_[get_cpuid()].tlist.set_events(scheduler_[get_cpuid()].ipi_event_task_id, scheduler_[get_cpuid()].ipi_event_mask);
        scheduler_[get_cpuid()].Schedule_impl(true);
        scheduler_[get_cpuid()].ipi_event_mask = 0; // mark IPI as completed
        scheduler_[get_cpuid()].ipi_event_task_id = 0; // mark IPI as completed

    } else if (signo == SIGTERM) {
        cores --;
        debug_core << "Force stopping this core" << endl;
        Machine::halt();
    }

    // unblock more interrupts
    debug_core << "IRQ completed" << endl;
    __OS_enable_irq_after_kernel();
}

// TODO: handle 7.9.4 Multi-Core start-up concept correctly

extern "C" void StartOS(int arg0){
    (void) arg0;

    Dispatcher::Prepare(OS_H1_task);
    Dispatcher::Prepare(OS_H2_task);
    Dispatcher::Prepare(OS_H3_task);
    Dispatcher::Prepare(OS_H4_task);
    Dispatcher::Prepare(OS_H5_task);
    scheduler_[get_cpuid()].SetReadyFromSuspended_impl(OS_H5_task);

    arch::irq.set_handler(SIGUSR1, irq_handler);
    arch::irq.enable(SIGUSR1);
    arch::irq.set_handler(SIGUSR2, irq_handler);
    arch::irq.enable(SIGUSR2);

    arch::irq.set_handler(SIGTERM, irq_handler);
    arch::irq.enable(SIGTERM);

    int curr_cores = cores;
    arch::start_hardware_thread(1, nullptr, NULL, AUTOSAR_StartCore);

    // wait until core is started
    while (curr_cores == cores);

    AUTOSAR_StartCore();

    Machine::unreachable();
}

extern "C" void AUTOSAR_ShutdownOS(StatusType arg0){
    debug_core << __FUNCTION__ << endl;

    if (cores-- > 1) {
        Machine::halt();
    } else { // last core
        AUTOSAR_ShutdownAllCores(arg0);
    }
    Machine::unreachable();
}

extern "C" void AUTOSAR_ShutdownAllCores(StatusType arg0){
    debug_core << __FUNCTION__ << endl;

    if (cores-- > 1) {
        int curr_cpuid = get_cpuid();
        for (int i = 0; i < MAX_CPUS; i++) {
            if (i == curr_cpuid || get_thread_id(i) == 0)
                continue;
            Machine::trigger_interrupt(SIGTERM, i);
        }
    }

    while (cores > 0);

    CALL_HOOK(ShutdownHook, arg0);
    ShutdownMachine();
    Machine::unreachable();
}


extern "C" void __OS_ASTSchedule(int arg0){
    (void) arg0;
    scheduler_[get_cpuid()].InlinedReschedule();
}

extern "C" StatusType AUTOSAR_ActivateTask(TaskType arg0) {
    
    Machine::disable_interrupts();
    {
        scheduler_[get_cpuid()].ActivateTask_impl(os::getTask(arg0), /* from_interrupt */ false, /*sync*/ true);
    }

    __OS_enable_irq_after_kernel();
    (void) arg0;
    return E_OK;
}

extern "C" StatusType AUTOSAR_ActivateTaskAsync(TaskType arg0) {

    Machine::disable_interrupts();
    {
        scheduler_[get_cpuid()].ActivateTask_impl(os::getTask(arg0), /* from_interrupt */ false, /*sync*/ false);
    }

    __OS_enable_irq_after_kernel();
    (void) arg0;
    return E_OK;
}

extern "C" StatusType AUTOSAR_TerminateTask(){
    
    Machine::disable_interrupts();
    {
        scheduler_[get_cpuid()].TerminateTask_impl(os::getTask(scheduler_[get_cpuid()].current_task));
    }
    // Return with closed interrupts
    return E_OK;
}

extern "C" void AUTOSAR_kickoff(){
    __OS_enable_irq_after_kernel();
}

extern "C" StatusType AUTOSAR_ChainTask(TaskType arg0){
    
    Machine::disable_interrupts();
    {
        scheduler_[get_cpuid()].ChainTask_impl(os::getTask(scheduler_[get_cpuid()].current_task), os::getTask(arg0));
    }
    // Return with closed interrupts
    (void) arg0;
    return E_OK;
}

// TODO: Test get/release resource
extern "C" StatusType AUTOSAR_GetResource(ResourceType arg0){
    
    Machine::disable_interrupts();
    {
        scheduler_[get_cpuid()].GetResource_impl(os::getTask(scheduler_[get_cpuid()].current_task), 8); // new prio

        Dispatcher::ResumeToTask(os::getTask(scheduler_[get_cpuid()].current_task));
    }
    __OS_enable_irq_after_kernel();
    
    return E_OK;
}

extern "C" StatusType AUTOSAR_ReleaseResource(ResourceType arg0){
    
    Machine::disable_interrupts();
    {
        scheduler_[get_cpuid()].ReleaseResource_impl(os::getTask(scheduler_[get_cpuid()].current_task), 2); // new prio
    }
    __OS_enable_irq_after_kernel();
    
    return E_OK;
}

extern "C" StatusType AUTOSAR_SetEvent(TaskType arg0, EventMaskType arg1){

    Machine::disable_interrupts();

    {
        const os::scheduler::Task &task = os::getTask(arg0);

        scheduler_[get_cpuid()].SetEvent_impl(task, arg1, /* sync */ true);
    }

    __OS_enable_irq_after_kernel();

    return E_OK;
}

extern "C" StatusType AUTOSAR_SetEventAsync(TaskType arg0, EventMaskType arg1){

    Machine::disable_interrupts();

    {
        const os::scheduler::Task &task = os::getTask(arg0);

        scheduler_[get_cpuid()].SetEvent_impl(task, arg1, /* sync */ false);
    }

    __OS_enable_irq_after_kernel();

    return E_OK;
}

extern "C" StatusType AUTOSAR_WaitEvent(EventMaskType arg0){

    Machine::disable_interrupts();
    {

        const os::scheduler::Task &curr_task = os::getTask(scheduler_[get_cpuid()].getCurrent_TaskID());
        scheduler_[get_cpuid()].WaitEvent_impl(curr_task, arg0);
    }
    __OS_enable_irq_after_kernel();
    (void) arg0;
    return E_OK;
}

extern "C" StatusType AUTOSAR_ClearEvent(EventMaskType arg0){
    Machine::disable_interrupts();
    {
        const os::scheduler::Task &curr_task = os::getTask(scheduler_[get_cpuid()].getCurrent_TaskID());
        scheduler_[get_cpuid()].ClearEvent_impl(curr_task, arg0);
        // Dispatch directly back to Userland
        Dispatcher::ResumeToTask(curr_task);
    }
    __OS_enable_irq_after_kernel();

    (void) arg0;
    return E_OK;
}


void __OS_HOOK_PreIdleHook(){
    AUTOSAR_kickoff();
    __OS_HOOK_DEFINED_PreIdleHook();
}

void __OS_HOOK_FaultDetectedHook(DetectedFault_t arg0,uint32_t arg1,uint32_t arg2){
    (void) arg0;
    (void) arg1;
    (void) arg2;
    debug << "FaultDetectedHook " << arg0<< endl;
    ShutdownMachine();
    Machine::unreachable();
}

void __OS_HOOK_StartupHook(){
}

void __OS_HOOK_PreTaskHook(){
}

void __OS_HOOK_PostTaskHook(){
}

void __OS_HOOK_ShutdownHook(StatusType arg0){
    __OS_HOOK_DEFINED_ShutdownHook(arg0);
}

void __OS_enable_irq_after_kernel(){
    sigset_t mask; sigfillset(&mask);
    irq.enable_interrupts(&mask);
}
