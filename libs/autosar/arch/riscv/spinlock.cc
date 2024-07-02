
#include "spinlock.h"
#include "output.h"

using namespace os;

Spinlock::Spinlock(int id) : id(id) { this->sl = 0; }


//Spinlock for RISC-V
StatusType Spinlock::lock() {
  kout << "L" << endl;
  int result = 1;

    while (result) {
        asm volatile(
            "lr.w %[result], (%[lock])\n"   // Load-reserved
            "bnez %[result], 0f\n"          // Check if lock is already taken
            "sc.w %[result], %[value], (%[lock])\n" // Store-conditional
            "0:\n"
            : [result] "=&r"(result)
            : [lock] "r"(&this->sl), [value] "r"(1)
            : "memory"
        );
    }
    kout << "R" << endl;
    return E_OK;
  
}

StatusType Spinlock::trylock(TryToGetSpinlockType* success) {
  kout << "T" << endl;
  return E_OK;
}

StatusType Spinlock::unlock() {
  kout << "U" << endl;
  int result;

    asm volatile(
        "amoswap.w.rl %[result], %[value], (%[lock])\n"
        : [result] "=&r"(result)
        : [lock] "r"(&this->sl), [value] "r"(0)
        : "memory"
    );
    kout << "S" << endl;

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
