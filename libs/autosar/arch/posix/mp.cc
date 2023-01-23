
#include "arch/generic/hardware_threads.h"
#include <pthread.h>
#include "output.h"
#include "machine.h"
pthread_t cpuid[MAX_CPUS];

static void *pthread_wrapper(void* function)
{
	void (*startup_function)() = reinterpret_cast<void(*)()>(function);
	startup_function();
	return nullptr;
}

namespace arch
{
	bool start_hardware_thread(unsigned int hardware_number,
	                           void *bottom_of_stack,
	                           unsigned int size_of_stack,
	                           void (*startup_function)())
	{
		/* These parameter are not required, since on posix there is already
		 * an operating system handling the stack and cpu startup. */
		(void) bottom_of_stack;
		(void) size_of_stack;
		pthread_t thread;
		int error = pthread_create(&thread, nullptr, pthread_wrapper, reinterpret_cast<void*>(startup_function));

		cpuid[hardware_number] = thread;
		pthread_detach(thread);
		return !error;
	}

	unsigned int get_thread_id(int id)
	{
		return (unsigned int) cpuid[id];
	}

	int get_cpuid()
	{
		pthread_t id = pthread_self();
		for (int i = 0; i < MAX_CPUS; i++) {
			if (id == cpuid[i])
				return i;
		}
		debug << "CPU ID not initialized!" << endl;
		return MAX_CPUS-1;
	}

	void init_cpuid()
	{
		for (int i = 0; i < MAX_CPUS; i++) {
			cpuid[i] = 0;
		}

		cpuid[0] = pthread_self();
	}
}


