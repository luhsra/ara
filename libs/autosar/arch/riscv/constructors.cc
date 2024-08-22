/**
 * @file
 * @ingroup generic
 * @brief Invoke global objects' constructors
 */

#include "constructors.h"
#include "output.h"

extern "C" {
    //! Address of the first global constructor (Defined by the linker script)
    extern void (*__CTORS_START)(void);
    //! Address of the last global constructor (Defined by the linker script)
    extern void (*__CTORS_END)(void);

    extern char _fbss;
    extern char _ebss;

    void run_constructors(void) {
        // Zero out the bss segment
        for (volatile char *p = &_fbss; p != &_ebss; p++) { *p = '\0'; }

        //! Call constructors of all global object instances.
        //! @note Ensure that your linker script places
        //!       all `CTORS` between `__CTORS_START` and
        //! `__CTORS_END`
        for( void (** volatile ctor)() = &__CTORS_START; ctor != &__CTORS_END; ++ctor ) {
            (*ctor)();
        }
    }
}
