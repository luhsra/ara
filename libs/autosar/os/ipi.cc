#include "ipi.h"
#include "output.h"

os::IPI::Data ipi_data[MAX_CPUS];
os::Spinlock ipi_lock[MAX_CPUS];

extern "C" bool os::IPI::ActivateTaskIPI(const os::scheduler::Task &task, bool sync)
{
    if (task.target_cpuid != arch::get_cpuid()) {
        debug_core << __FUNCTION__ << "(" << (int) task.id << ")" << endl;

        ipi_lock[task.target_cpuid].lock(); // only one thread is allowed to modify ipi_data

        while (ipi_data[task.target_cpuid].id != os::IPI::Cleared); // wait for previous IPIs

        ipi_data[task.target_cpuid].id = os::IPI::ActivateTask;
        ipi_data[task.target_cpuid].target_task_id = task.id;

        Machine::trigger_interrupt(SIGUSR1, task.target_cpuid);

        ipi_lock[task.target_cpuid].unlock();

        if (sync) {
            while (ipi_data[task.target_cpuid].id != os::IPI::Cleared); // wait until IPI succeeded
            debug_core << __FUNCTION__ << " waiting finished" << endl;
        }
        return true;
    }
    return false;
}

extern "C" bool os::IPI::SetEventIPI(const os::scheduler::Task &task, EventMaskType mask, bool sync)
{
    if (task.target_cpuid != arch::get_cpuid()) {
        debug_core << __FUNCTION__ << "(" << (int) task.id << ", " << mask << ")" << endl;

        ipi_lock[task.target_cpuid].lock(); // only one thread is allowed to modify ipi_data

        while (ipi_data[task.target_cpuid].id != os::IPI::Cleared); // wait for previous IPIs

        ipi_data[task.target_cpuid].id = os::IPI::SetEvent;
        ipi_data[task.target_cpuid].target_task_id = task.id;
        ipi_data[task.target_cpuid].set_event_mask = mask;

        Machine::trigger_interrupt(SIGUSR1, task.target_cpuid);

        ipi_lock[task.target_cpuid].unlock();

        if (sync) {
            while (ipi_data[task.target_cpuid].id != os::IPI::Cleared); // wait until IPI succeeded
            debug_core << __FUNCTION__ << " waiting finished" << endl;
        }
        return true;
    }
    return false;
}