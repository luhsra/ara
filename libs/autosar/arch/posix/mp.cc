
#include "arch/generic/hardware_threads.h"
#include <pthread.h>
#include "output.h"
#include "machine.h"
#include "spinlock.h"
#include <sys/sysinfo.h>

extern "C" int main(void);

pthread_t cpuid[MAX_CPUS];
_Atomic(int) cores = 1;

_Atomic(int) syncing_cores[4] = {0};

namespace arch
{
    extern "C" void* start_hardware_thread_stage2(void* arg) {
        int hardware_number = *((int*)arg);
        cpuid[hardware_number] = pthread_self();

        cores++;

        debug_core << "started core " << hardware_number << endl;

        main();
    }

    StatusType start_hardware_thread(unsigned int hardware_number,
                               void *bottom_of_stack,
                               unsigned int size_of_stack)
    {
        /* These parameter are not required, since on posix there is already
         * an operating system handling the stack and cpu startup. */
        (void) bottom_of_stack;
        (void) size_of_stack;
        pthread_t thread;

        if (cpu_online(hardware_number)) // this core was already started
        {
            return E_OS_STATE;
        }

        int host_cpus = get_nprocs();

        if (hardware_number > host_cpus)
        {
            debug_core << "This POSIX machine cannot handle " << hardware_number << " cpus" << endl;
            return E_OS_ID;
        }

        int curr_cores = cores;

        /* set CPU affinity to hardware_number */
        pthread_attr_t attr;
        cpu_set_t cpus;
        CPU_ZERO(&cpus);
        CPU_SET(hardware_number, &cpus);
        pthread_attr_init(&attr);
        pthread_attr_setaffinity_np(&attr, sizeof(cpu_set_t), &cpus);

        int rc = pthread_create(&thread, &attr, start_hardware_thread_stage2, &hardware_number);
        if (rc) {
            return E_NOT_OK;
        }

        pthread_detach(thread);

        // wait until core is started
        while (curr_cores == cores);

        return E_OK;
    }

    unsigned int get_thread_id(int id)
    {
        return (unsigned int) cpuid[id];
    }

    bool cpu_online(int cpuid)
    {
        return (bool) get_thread_id(cpuid);
    }

    unsigned int get_num_cores()
    {
        return cores;
    }

    void stop_hardware_thread()
    {
        Machine::disable_interrupts();

        /* sync all cores before machine shutdown */
        arch::sync_all_hardware_threads(3);

        if (arch::get_cpuid() == 0) {
            Machine::shutdown();
            Machine::unreachable();
        } else {
            while(1) {
                Machine::nop();
            }
        }
    }

    void stop_other_hardware_threads()
    {
        if (cores > 1) {
            int curr_cpuid = get_cpuid();
            for (int i = 0; i < MAX_CPUS; i++) {
                if (i == curr_cpuid || !cpu_online(i) )
                    continue;
                Machine::trigger_interrupt(SIGUSR2, i);
            }
        }
    }
    /**
     * This function must be called on every thread.
     * On return, all threads are synchronized.
     * A syncing slot is used to protect against
     * recurrent access from the same cpu.
     */
    void sync_all_hardware_threads(int slot)
    {
        syncing_cores[slot] ++;
        debug_core << "Syncing[" << slot << "]: "<< syncing_cores[slot] << "/" << cores << endl;

        // wait until all cores have synced
        while (syncing_cores[slot] != cores);
    }

    int get_cpuid()
    {
        pthread_t id = pthread_self();
        for (int i = 0; i < MAX_CPUS; i++) {
            if (id == cpuid[i])
                return i;
        }
        debug << "CPU ID not initialized!" << endl;
        Machine::shutdown();
    }

    void init_cpuid()
    {
        for (int i = 0; i < MAX_CPUS; i++) {
            cpuid[i] = 0;
        }
        cpuid[0] = pthread_self();
    }
}


