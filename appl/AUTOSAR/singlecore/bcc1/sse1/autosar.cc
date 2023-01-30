#include "os.h"
#include "tcb.h"
#include "os/scheduler/task.h"
#include "os/counter.h"
#include "os/alarm.h"
#include "os/scheduler/scheduler.h"
#include "os/util/redundant.h"
#include "syscall.h"
#include "machine.h"

extern "C" void  AUTOSAR_TASK_FUNC_H1();
extern "C" void  AUTOSAR_TASK_FUNC_H2();
extern "C" void  AUTOSAR_TASK_FUNC_H3();
extern "C" void  AUTOSAR_TASK_FUNC_H4();
extern "C" void  AUTOSAR_TASK_FUNC_H5();
extern "C" void  __OS_StartOS_dispatch(int);
extern "C" void  StartOS(int);
extern "C" void  AUTOSAR_ShutdownOS(StatusType);
extern "C" void  __OS_ASTSchedule(int);

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
    namespace tasks{
        constexpr const os::scheduler::Task OS_H1_task(1, 7, true, arch::OS_H1_tcb);
        constexpr const os::scheduler::Task OS_H2_task(2, 5, true, arch::OS_H2_tcb);
        constexpr const os::scheduler::Task OS_H3_task(3, 3, true, arch::OS_H3_tcb);
        constexpr const os::scheduler::Task OS_H4_task(4, 2, true, arch::OS_H4_tcb);
        constexpr const os::scheduler::Task OS_H5_task(5, 1, true, arch::OS_H5_tcb);
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
    Task::prio_t H2;
    Task::prio_t H3;
    Task::prio_t H4;
    Task::prio_t H5;

    // idle task id/priority
    static constexpr Task::id_t idle_id     = 0;
    static constexpr Task::prio_t idle_prio = 0;

    TaskList() : UnencodedTaskListStatic()
            , H1(0)
            , H2(0)
            , H3(0)
            , H4(0)
            , H5(0)

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
            }
        } else if (id == 2) {
            if (H2 < prio) {
                H2 = prio;
            }
        } else if (id == 3) {
            if (H3 < prio) {
                H3 = prio;
            }
        } else if (id == 4) {
            if (H4 < prio) {
                H4 = prio;
            }
        } else if (id == 5) {
            if (H5 < prio) {
                H5 = prio;
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

        if (possible_tasks == nullptr || possible_tasks[1]) {
            if(H1 > prio ) {
                prio = H1;
                id = 1;
            }
        }
        if (possible_tasks == nullptr || possible_tasks[2]) {
            if(H2 > prio ) {
                prio = H2;
                id = 2;
            }
        }
        if (possible_tasks == nullptr || possible_tasks[3]) {
            if(H3 > prio ) {
                prio = H3;
                id = 3;
            }
        }
        if (possible_tasks == nullptr || possible_tasks[4]) {
            if(H4 > prio ) {
                prio = H4;
                id = 4;
            }
        }
        if (possible_tasks == nullptr || possible_tasks[5]) {
            if(H5 > prio ) {
                prio = H5;
                id = 5;
            }
        }
    }

    /** Wait for a specific event mask **/
    forceinline void wait_events(const Task::id_t id, const event_mask_t mask) {
        (void) id;
        (void) mask;
     {
            assert(false);
        }
    }

    /** Set Events **/
    forceinline void set_events(const Task::id_t id, const event_mask_t mask) {
        (void) id;
        (void) mask;
     {
            assert(false);
        }
    }

    /** Clear Events **/
    forceinline void clear_events(const Task::id_t id, const event_mask_t mask) {
        (void) id;
        (void) mask;
     {
        }
    }

    forceinline void remove(const Task::id_t& id) {
        set(id, 0);
    }

    /** Get Events **/
    forceinline event_mask_t get_events(const Task::id_t id) {
        (void) id;
if (id == 1) {

        } else if (id == 2) {

        } else if (id == 3) {

        } else if (id == 4) {

        } else if (id == 5) {

        } else        {
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
     if(lhs.H2 != rhs.H2) return false;
     if(lhs.H3 != rhs.H3) return false;
     if(lhs.H4 != rhs.H4) return false;
     if(lhs.H5 != rhs.H5) return false;

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

    template<const bool *possible_tasks = nullptr>
    forceinline void PartialReschedule() {
        tlist.head<possible_tasks>(current_task, current_prio);

        dispatchToCurrentTask();
    }

    forceinline void InlinedReschedule(void) {

        if (Dispatcher::getSpinlockCnt()) {
            debug_core << "Task still holding Spinlocks, cannot reschedule" << endl;
        }
        // update current_task
        tlist.head(current_task, current_prio);
        // dispatch
        dispatchToCurrentTask();
    }

    noinline void Reschedule() {
        if (Dispatcher::getSpinlockCnt()) {
            debug_core << "Task still holding Spinlocks, cannot reschedule" << endl;
        }
        // update current_task
        tlist.head(current_task, current_prio);
        // dispatch
        dispatchToCurrentTask();
    }

    forceinline void Schedule_impl(bool from_interrupt=false) {
        if(!from_interrupt && in_syscall()) {
            // in syscall: reschedule directly
#ifdef CONFIG_OS_INLINE_SCHEDULER
            InlinedReschedule();
#else
            Reschedule();
#endif
        } else {
            // not in syscall (probably in ISR): request reschedule AST
            // Calls also Reschedule()
            request_reschedule_ast();
        }
    }

    forceinline void SetReady_impl(const Task &task) {
        tlist.activate(task.id, task.prio);
    }


    forceinline void SetSuspended_impl(const Task &t) {
        Dispatcher::Destroy(t);
        tlist.remove(t.id);
    }

    forceinline void ActivateTask_impl(const Task &task, bool from_interrupt=false) {
        SetReady_impl(task);
        Schedule_impl(from_interrupt);
    }

    forceinline void ChainTask_impl(const Task &from, const Task &to) {
        SetSuspended_impl(from);
        SetReady_impl(to);
        Schedule_impl();
    }

    forceinline void TerminateTask_impl(const Task &from) {
        SetSuspended_impl(from);
        Schedule_impl();
    }

    forceinline void GetResource_impl(const Task &current_task, const Task::prio_t new_prio) {
        SetPriority(current_task, new_prio);
        SetSystemPriority(new_prio);
    }

    forceinline void ReleaseResource_impl(const Task &current_task, const Task::prio_t new_prio) {
        SetPriority(current_task, new_prio);
        SetSystemPriority(new_prio);
        Schedule_impl();
    }

    forceinline void SetEvent_impl(const Task &other_task, const int event_mask) {
        tlist.set_events(other_task.id, event_mask);
        Schedule_impl();
    }

    forceinline void WaitEvent_impl(const Task &current_task, const int event_mask) {
        tlist.wait_events(current_task.id, event_mask);
        Schedule_impl();
    }

    forceinline void ClearEvent_impl(const Task &current_task, const int event_mask) {
        tlist.clear_events(current_task.id, event_mask);
    }

    forceinline uint32_t GetEvent_impl(const Task &current_task) {
        return tlist.get_events(current_task.id);
    }

    forceinline void SetReadyFromSuspended_impl(const Task &task) {
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
};


Scheduler scheduler_;

extern "C" StatusType AUTOSAR_GetTaskID(TaskRefType a) {
    *a = scheduler_.getCurrent_TaskID();
    return E_OK;
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
    scheduler_.InlinedReschedule();
}

extern "C" void StartOS(int arg0){
    (void) arg0;
    Dispatcher::Prepare(OS_H1_task);
    Dispatcher::Prepare(OS_H2_task);
    Dispatcher::Prepare(OS_H3_task);
    Dispatcher::Prepare(OS_H4_task);
    Dispatcher::Prepare(OS_H5_task);
    scheduler_.SetReadyFromSuspended_impl(OS_H5_task);
    CALL_HOOK(StartupHook);
    syscall(__OS_StartOS_dispatch);
    Machine::unreachable();
}

extern "C" void AUTOSAR_ShutdownOS(StatusType arg0){
    (void) arg0;
    CALL_HOOK(ShutdownHook, arg0);
    ShutdownMachine();
    Machine::unreachable();
}

extern "C" void __OS_ASTSchedule(int arg0){
    (void) arg0;
    scheduler_.InlinedReschedule();
}

extern "C" StatusType AUTOSAR_ActivateTask(TaskType arg0) {
    Machine::disable_interrupts();
    {
        scheduler_.ActivateTask_impl(os::getTask(arg0), /* from_interrupt */ false);
    }

    __OS_enable_irq_after_kernel();
    (void) arg0;
    return E_OK;
}

extern "C" StatusType AUTOSAR_TerminateTask(){

    Machine::disable_interrupts();
    {
        scheduler_.TerminateTask_impl(os::getTask(scheduler_.current_task));
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
        scheduler_.ChainTask_impl(os::getTask(scheduler_.current_task), os::getTask(arg0));
    }
    // Return with closed interrupts
    (void) arg0;
    return E_OK;
}

extern "C" StatusType AUTOSAR_GetResource(ResourceType arg0){
    Machine::disable_interrupts();
    {
        scheduler_.GetResource_impl(os::getTask(scheduler_.current_task), 8); // new prio

        Dispatcher::ResumeToTask(os::getTask(scheduler_.current_task));
    }
    __OS_enable_irq_after_kernel();
    return E_OK;
}

extern "C" StatusType AUTOSAR_ReleaseResource(ResourceType arg0){

    Machine::disable_interrupts();
    {
        scheduler_.ReleaseResource_impl(os::getTask(scheduler_.current_task), 2); // new prio
    }
    __OS_enable_irq_after_kernel();
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
    (void) arg0;
}

void __OS_enable_irq_after_kernel(){
    sigset_t mask; sigfillset(&mask);
    irq.enable_interrupts(&mask);
}
