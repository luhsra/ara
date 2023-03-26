#ifndef __ARCH_POSIX_TCB
#define __ARCH_POSIX_TCB

#include  "machine.h"
#include "os/util/assert.h"
#include <stdio.h>

#define ASM_SAVE_REGISTERS \
    "push %%ebx\n"\
    "push %%esi\n"\
    "push %%edi\n"\
    "push %%ebp\n"
#define ASM_RESTORE_REGISTERS \
    "pop  %%ebp\n"\
    "pop  %%edi\n"\
    "pop  %%esi\n"\
    "pop  %%ebx\n"


#ifdef CONFIG_OS_BASIC_TASKS
extern "C" void *OS_basic_task_stackptr;
extern "C" uint8_t shared_basic_stack[];
#endif

namespace arch { struct TCB; }

extern "C" void kickoff(arch::TCB *);

namespace arch {

    extern uint32_t current_abb[32];

    struct TCB {
	typedef void (* const fptr_t)(void);

	bool basic_task;

	// task function
	fptr_t fun;

	// task stack
	void * const stack;

	// reference to saved stack pointer
	void* &sp;

        // System wide thread id
	const int thread_id;

	const int stacksize;

	constexpr inline void ** get_tos(void) const {
	    return (void **)(((char *)stack) + stacksize);
	}

	constexpr inline void* &running_marker(void) const {
	    return *(get_tos() - 1);
	}

	inline bool is_running(void) const {
	    return running_marker() != (void *) 0xaaaaffff;
	}

	inline void set_running() const {
	    running_marker() = (void *) 0xa5a5a5a5;
	}


	constexpr inline void* &basic_task_frame_pointer(void) const {
	    return *(get_tos() - 2);
	}

	inline void reset(void) const {
        current_abb[thread_id] = 0;
	    void **tos = get_tos();
	    *(--tos) = (void *) 0xaaaaffff; // is fresh

	    if (!basic_task) {
            *(--tos) = (void *) this->fun; // current task
            (--tos); // %rbx (%ebx)
            (--tos); // %r12 (%esi)
            (--tos); // %r13 (%edi)
            (--tos); // %r14 (%ebp)
            sp = tos;
	    }
	    assert (!is_running ());
	}

#ifdef CONFIG_OS_SEMI_EXTENDED_TASKS
	static forceinline bool runningOnSharedStack() {
            void *sp = Machine::get_stackptr();
	    return (sp > shared_basic_stack && sp <= OS_basic_task_stackptr);
	}
#endif //CONFIG_OS_SEMI_EXTENDED_TASKS

        // start the first task
	void inlinehint startFirst() const {
	    set_running();
            if (basic_task) {
		basic_task_frame_pointer() = sp;
		_startToBT(this);
	    } else {
		_returnTo(&this->sp);
	    }
	    Machine::unreachable();
	}

	void noinline switch_to_basic_task(const TCB *old) const {
	    // printf("\nto basic_task %p -> %p\n", old ? &(old->sp) : NULL, &sp);
	    // We will be running, so we mark ourself as running
	    bool was_not_running = !is_running();
	    set_running();

	    // 0 -> BT
	    // see startFirst()
	    // BT -> BT
	    if (old->basic_task) {
		// printf("Already on shared stack\n");
		if (was_not_running) {
		    // printf("old->is_running = %d\n", old->is_running());
		    if (old->is_running()) {
			_switchFromBTtoBT(this);
		    } else { // old was terminated, this was newly started
			// printf("Replace on Top 0x%x\n", (int)Machine::get_stackptr());
			basic_task_frame_pointer() = old->basic_task_frame_pointer();
			_chainFromBTtoBT(this);
			Machine::unreachable();
		    }
		} else { // old was terminated, we return to the next BT
		    // We want to terminate old. We know that the task we want to switch to
		    // lifes directly under old's frame pointer. Therefore we use startTo
                   // printf("Terminate old task %p\n", old->basic_task_frame_pointer());
		    _returnTo(&(old->basic_task_frame_pointer()));
		    Machine::unreachable();
		}
#ifdef CONFIG_OS_SEMI_EXTENDED_TASKS
		// SET -> BT
	    } else if(runningOnSharedStack()) {
                // printf("SET spawns BT: next=%p, old=%p\n", this, old);
		_switchFromSETtoBT(old, this);
#endif //CONFIG_OS_SEMI_EXTENDED_TASKS
	    } else { // ET -> BT i.e. !Shared Stack
		// We have to switch to the shared stack
		if (was_not_running) {
 		    // printf("Activate on Shared Stack\n");
                    // We save out context on the extended stack, move
		    // to basic stack and jump into the task.
		    void *dummy;
		    void **save_sp = old->is_running() ? &(old->sp) : &dummy;
		    basic_task_frame_pointer() = sp;
		    asm volatile (
			// Save Context on Extended Stack
			"push $1f;"
			ASM_SAVE_REGISTERS
                        // Save Context Pointer
			"mov  %%esp, (%0)\n"
			// to shared stack
			"mov %2, %%esp;"
			"jmp *%1;"      // into task
			// Return Point for extended task
			"1:\n"
			::
			 "r" (save_sp),
			 "m" (fun),
			 "m" (sp)
			: "memory", "eax", "ecx", "edx");
		} else {
		    // The old task is already running on shared
		    // stack. Therefore, we can simply switch to the
		    // saved context on the other stack
		    // printf("Resume to shared stack\n");
		    _switchTo(&old->sp, &this->sp);
		}
	    }
	}


	void noinline start(const TCB *old) const {
	    if (!old->is_running()) {
		if (old->basic_task) {
		    // We switch away from the basic stack. Therefore we have
		    // to reset the shared stack pointer.
		    old->sp = (void*)((int)old->basic_task_frame_pointer());
		}
		set_running();
		// Lets go to an extended stack
                // printf("BT returns to ET/SET: next=%p old=%p\n", this, old);
		_returnTo(&(this->sp));
	    } else {
                // printf("ET(dead) to ET: next=%p old=%p\n", this, old);
		old->switchTo(this);
	    }
	}

	    // switch to another task, ET or SET
	    // other == new
	void noinline switchTo(const TCB *other) const {
	    other->set_running();
#ifdef CONFIG_OS_SEMI_EXTENDED_TASKS
	    //if we are on the shared-stack but NOT a basic task
	    if(!basic_task && runningOnSharedStack()) {
		_switchFromSETtoETandBack(this, other);
	    }
	    else {
		_switchTo(&(this->sp), &other->sp);
	    }
#else // !CONFIG_OS_SEMI_EXTENDED_TASKS
	    _switchTo(&sp, &other->sp);
#endif //CONFIG_OS_SEMI_EXTENDED_TASKS
	}

#ifdef CONFIG_OS_SEMI_EXTENDED_TASKS
	//semi extended switches (starts not needed as we can not terminate on the
	//shared stack)
	static noinline void _switchFromSETtoETandBack(const TCB *from, const TCB *to) {
            void *tmp = OS_basic_task_stackptr;
	    asm __volatile__ (
                              "push $1f\n"
			      ASM_SAVE_REGISTERS
			      "mov  %%esp, OS_basic_task_stackptr\n"
			      "mov  %%esp, (%0)\n"  // From
			      "mov  (%1), %%esp\n"  // To
			      ASM_RESTORE_REGISTERS
			      "ret\n" //HERE the switch to the ET happens
			      "1:\n"
			      :
			      : "r" (&(from->sp)),  "r" (&(to->sp))
			      : "memory", "eax", "ecx", "edx"
		);
            OS_basic_task_stackptr = tmp;
	}

	static noinline void _switchFromSETtoBT(const TCB *from, const TCB *to) {
	    // the basic-task HAS to be startet not resumed!
	    // old->is_running is true because we do not allow
	    // terminateTask() whilst on the shared stack
            void *tmp = OS_basic_task_stackptr;

	    asm volatile ("push $1f\n" //push return address
			  ASM_SAVE_REGISTERS
                          "mov %%esp, (%0)\n"
                          "mov %%esp, (%1)\n"
			  "jmp *%2\n"
			  "1:\n"
			  :
			  : "r"(&(from->sp)), "r"(&(to->basic_task_frame_pointer())),  "r" (to->fun)
			  : "memory", "eax", "ecx", "edx"
		);
            OS_basic_task_stackptr = tmp;
	}
#endif //CONFIG_OS_SEMI_EXTENDED_TASKS

	// basic task start/switches

	// first start of a BT
	static noinline void _startToBT(const TCB *tcb) {
	    asm volatile("mov %1, %%esp\n"
			 "jmp *%0\n"
			 :
			 : "m" (tcb->fun),
			   "r" (tcb->basic_task_frame_pointer())
			 : /* No Clobber List, since unreachable here */
		);
	    Machine::unreachable();
	}
	static noinline void _switchFromBTtoBT(const TCB *tcb) {
	    // Here, we save a context which can be used
	    // by switchTo. If the activated BT chains to
	    // an extended task, we have resume here
	    asm volatile ("push $1f\n"
			  ASM_SAVE_REGISTERS
			  "mov %%esp, (%0)\n"
			  "jmp *%1\n"
			  "1:"
			  :
			  : "r" (&(tcb->basic_task_frame_pointer())),
			    "m" (tcb->fun)
			  : "memory", "eax", "ecx", "edx");
	}
	static noinline void _chainFromBTtoBT(const TCB* tcb) {
	    asm volatile ("mov %0, %%esp\n"
			  "jmp *%1\n"
			  :
			  : "r" (tcb->basic_task_frame_pointer()),
			    "m" (tcb->fun)
			  : /* No clobber list, since code is unreachable */);
	    Machine::unreachable();
	}

	// normal startTo/switchTo
	static noinline void _switchTo(void **from_sp, void **to_sp_ptr) {
            void *to_sp = *to_sp_ptr;
            *to_sp_ptr = 0;
	    asm __volatile__ ("push $1f\n"
                              ASM_SAVE_REGISTERS
			      "mov  %%esp, (%0)\n"
			      "mov  %1, %%esp\n"
			      ASM_RESTORE_REGISTERS
			      "ret\n"
                              "1:\n"
			      :
			      : "r" (from_sp), "r" (to_sp)
			      : "memory", "eax", "ecx", "edx"
		);
	}
	static forceinline void _returnTo(void **to_sp_ptr) {
            void *to_sp = *to_sp_ptr;
            *to_sp_ptr = 0;
	    asm __volatile__ ("mov  %0, %%esp\n"
			      ASM_RESTORE_REGISTERS
			      "ret\n"
			      :
			      : "r" (to_sp)
			      : "memory"
		);
	    Machine::unreachable();
	}

	constexpr TCB(fptr_t f, void *s, void* &sptr, int thread_id, int stacksize)
	    : basic_task(stacksize < 16), fun(f), stack(s), sp(sptr),  thread_id(thread_id), stacksize(stacksize) {} // 16 should be 4*sizeof(void*)

    };

};
#endif
