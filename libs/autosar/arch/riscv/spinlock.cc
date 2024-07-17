
#include "spinlock.h"
#include "output.h"

using namespace os;

Spinlock::Spinlock(int id) : id(id) { this->sl = 0; }


//Spinlock for RISC-V
StatusType Spinlock::lock() {
  
  //kout << "L" << endl; //Lock
  int result = 1;

    while (result) {
        asm volatile(
            //result = 1 if lock is already taken
            //lock = 1 if lock is taken

            // Atomic memory load-reserved word acquire (lr.w)
            // Load the value of the lock into result
            "lr.w %[result], (%[lock])\n\t"
            // Check if lock is already taken
            // If result is not 0, jump to 0f
            "bnez %[result], 0f\n\t"
            // Store-conditional only if lock is not taken
            // result = 0 if store-conditional was successful
            // value = 1 and is stored in lock
            "sc.w %[result], %[value], (%[lock])\n\t"
            "0:"
            // Output operands (result)
            : [result] "=&r"(result)
            // Input operands (lock (&this->sl), value(1))
            : [lock] "r"(&this->sl), [value] "r"(1)
            // Clobbered registers: "cc", "memory"
            : "cc", "memory"
        );
    }
    //kout << "R" << endl; //Release
    return E_OK;
  
}


StatusType Spinlock::trylock(TryToGetSpinlockType* success) {

  int result = 1;

    asm volatile(
        // Atomic memory load-reserved word acquire (lr.w)
        // Load the value of the lock into result
        "lr.w %[result], (%[lock])\n\t"
        // Check if lock is already taken
        // If result is not 0, jump to 0f
        "bnez %[result], 0f\n\t"
        // Store-conditional only if lock is not taken
        // result = 0 if store-conditional was successful
        // value = 1 and is stored in lock
        "sc.w %[result], %[value], (%[lock])\n\t"
        "0:"
        // Output operands (result)
        : [result] "=&r"(result)
        // Input operands (lock (&this->sl), value(1))
        : [lock] "r"(&this->sl), [value] "r"(1)
        // Clobbered registers: "cc", "memory"
        : "cc", "memory"
    );

    if (result == 0) {
        *success = TRYTOGETSPINLOCK_SUCCESS;
    } else {
        *success = TRYTOGETSPINLOCK_NOSUCCESS;
    }

  return E_OK;
}

StatusType Spinlock::unlock() {
  //kout << "U" << endl; //Unlock

    asm volatile(
        // Atomic memory swap word acquire-release
        // Store 0 in lock
        // This releases the lock
        "amoswap.w.aqrl zero, zero, (%[lock])\n\t"
        :
        : [lock] "r"(&this->sl)
        : "memory"
    );
    //kout << "S" << endl; //Success

    return E_OK;
}