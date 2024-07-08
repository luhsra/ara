
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
  kout << "T" << endl;
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

/** 
//Spinlock for RISC-V
StatusType Spinlock::lock() {
  kout << "L" << endl;

  int expected = 0;
  int desired = 1;

  
  

  while(expected == 0){
    asm volatile("amoswap.w.aq %0, %2, %1\n"        //%0 = expected, %1 = this->sl, %2 = desired
                                                    //amoswap.w.aq = atomic memory swap word acquire
                 : "=r"(expected), "+A"(this->sl)  //output sl ist put in expected
                 : "r"(desired)                     //desired is inputregister
                 : "memory");                       //memory has changed
                 kout << "W" << endl;
  }
  kout << "R" << endl;
  return E_OK;
}

StatusType Spinlock::trylock(TryToGetSpinlockType* success) {
  kout << "T" << endl;
  
  int expected = 0;
  int desired = 1;

  asm volatile("amoswap.w.aq %0, %2, %1\n"
                  : "=r"(expected), "+A"(this->sl)
                  : "r"(desired)
                  : "memory");

  if(expected == 0){
    *success = TRYTOGETSPINLOCK_SUCCESS;
    return E_OK;
  } else {
    *success = TRYTOGETSPINLOCK_NOSUCCESS;
    return E_OK;
  }
}

StatusType Spinlock::unlock() {
  kout << "U" << endl; 

  int desired = 0;
  int result;

  asm volatile("amoswap.w.rl %0, %2, %1\n"
               : "=r"(result), "+A"(this->sl)
               : "r"(desired)
               : "memory");

  kout << "S" << endl;  
  return E_OK;
}
*/
