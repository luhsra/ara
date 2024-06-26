
#include "spinlock.h"

#include "output.h"

using namespace os;

Spinlock::Spinlock(int id) : id(id) { this->sl = 0; }

//Spinlock for RISC-V
StatusType Spinlock::lock() {
  int result = 1;

  // Loop until the lock is successfully acquired
  while (result) {
    asm volatile("lr.w %[result], %[lock]"
                 "\n\t"
                 "bnez %[result], 1f"
                 "\n\t"
                 "sc.w %[result], %[value], %[lock]"
                 "\n\t"
                 "beqz %[result], 0f"
                 "\n\t"
                 "1:"
                 "\n\t"
                 "0:"
                 : [result] "=&r"(result)
                 : [lock] "r"(&this->sl), [value] "r"(1)
                 : "cc", "memory");
  }

  return E_OK;
}

StatusType Spinlock::trylock(TryToGetSpinlockType* success) {
  int result = 0;

  asm volatile("lr.w %[result], %[lock]"
               "\n\t"
               "bnez %[result], 1f"
               "\n\t"
               "sc.w %[result], %[value], %[lock]"
               "\n\t"
               "beqz %[result], 0f"
               "\n\t"
               "1:"
               "\n\t"
               "0:"
               : [result] "=&r"(result)
               : [lock] "r"(&this->sl), [value] "r"(1)
               : "cc", "memory");

  if (result == 0) {
    *success = TRYTOGETSPINLOCK_SUCCESS;
    return E_OK;
  } else {
    *success = TRYTOGETSPINLOCK_NOSUCCESS;
    return E_OK;
  }
}

StatusType Spinlock::unlock() {
  asm volatile("li t0, 0"
               "\n\t"
               "sc.w t0, t0, %[lock]"
               : [lock] "+r"(&this->sl)
               :
               : "cc", "memory");

  return E_OK;
}
