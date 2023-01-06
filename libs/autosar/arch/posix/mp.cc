
#include "arch/generic/hardware_threads.h"
#include <pthread.h>
#include "output.h"
#include "machine.h"
pthread_t cpuid[MAX_CPUS];
int threads = 0;

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

		debug_core << "thread " << hex << thread << " hw " << hardware_number << endl;
		cpuid[hardware_number] = thread;
		threads++;
		pthread_detach(thread);
		return !error;
	}

	pthread_t get_thread_id() {
		return pthread_self();
	}

	int get_cpuid() {
		pthread_t id = get_thread_id();
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
			cpuid[i] = -1;
		}

		cpuid[0] = get_thread_id();
		debug_core << "thread " << hex << cpuid[0] << " hw " << 0 << endl;
	}

	void wait_for_cpus()
	{
		while (true)
		{
			if (threads == 0){
				return;
			}
		}
	}

	void stop_hardware_thread()
	{
		threads--;
		while(true){
			Machine::nop();
		}
	}
}


