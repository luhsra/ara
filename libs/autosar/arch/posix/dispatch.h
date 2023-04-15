/**
 * @file
 * @ingroup posix
 * @brief Posix task dispatching
 */

#ifndef __DISPATCH_H__
#define __DISPATCH_H__

#include "hardware_threads.h"
#include "os/hooks.h"
#include "os/scheduler/task.h"
#include "os/util/inline.h"
#include "output.h"
#include "signalinfo.h"
#include "tcb.h"
namespace arch {

	static const int IDLESTACKSIZE = 4096;

	class Dispatcher {
		static const TCB* m_current[MAX_CPUS];
		static TCB m_idle[MAX_CPUS];
		static void* idle_sp[MAX_CPUS];

		static noinline void idleEntry(void) {
			CALL_HOOK(PreIdleHook);
			while (true) {
				Machine::nop();
			}
		}

		static forceinline void doDispatch(const TCB* from, const TCB* to) {
			// update current context
			m_current[get_cpuid()] = to;

			/* If we do not reset the idle loop, when leaving it the
			   PreIdleHook is not called correctly on the next dispatch
			   to idle */
			if (from == &m_idle[get_cpuid()] && to != &m_idle[get_cpuid()]) {
				m_idle[get_cpuid()].reset();
			}

			CALL_HOOK(PreTaskHook);

			// start up
			if (!from) {
				/*
				if (to->basic_task)
				    to->switch_to_basic_task(from);
				else
				            to->start(from);
				*/
				to->startFirst();
				Machine::unreachable();
			}

			if (to->basic_task) {
				to->switch_to_basic_task(from);
			} else {
				if (!from->is_running()) {
					to->start(from);
				} else {
					from->switchTo(to);
				}
			}
		}

	  public:
		static void init(void) {
			// setup idle context
			for (int i = 0; i < MAX_CPUS; i++) {
				m_idle[i].reset();
			}
		}

		static forceinline void Idle(void) {
			if (m_current[get_cpuid()] != &m_idle[get_cpuid()]) {
				debug_core << "Enter idle" << endl;
				doDispatch(m_current[get_cpuid()], &m_idle[get_cpuid()]);
			}
		}

		static forceinline void Prepare(const os::scheduler::Task& task) { task.tcb.reset(); }

		static forceinline void Destroy(const os::scheduler::Task& task) { task.tcb.reset(); }

		static forceinline void Dispatch(const os::scheduler::Task& next, const os::scheduler::Task* current = 0) {
			// Do not resume yourself...
			// kout << (void*)current << " " << (void*) &next << endl;
			const TCB* cur = current ? &current->tcb : m_current[get_cpuid()];
			if (cur == &next.tcb) {
				debug_core << "Dispatch to ID " << (int)next.id << " via return" << endl;
				return;
			}

			debug_core << "Dispatch to ID: " << (int)next.id << endl;

			doDispatch(cur, &next.tcb);
		}

		static forceinline void ResumeToTask(const os::scheduler::Task& next, const os::scheduler::Task* current = 0) {
			// assume(next.tcb.is_running());
			Dispatch(next, current);
		}

		static forceinline void StartToTask(const os::scheduler::Task next, const os::scheduler::Task* current = 0) {
			// assume(!next.tcb.is_running());
			Dispatch(next, current);
		}

		static forceinline void setCurrentABB(uint32_t abb) {
			if (m_current[get_cpuid()]) {
				current_abb[m_current[get_cpuid()]->thread_id] = abb;
			}
		}
	};

} // namespace arch

#endif // __DISPATCH_H__
