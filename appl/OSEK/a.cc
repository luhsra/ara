
#include "source/os/os.h"
#include "source/test/test.h"


// Test memory protection (spanning over more than one 4k page in x86)
//volatile int testme[1024*4*10] __attribute__ ((section (".data.Handler12")));

DeclareTask(Handler11);
DeclareTask(Handler12);
DeclareTask(Handler13);

TEST_MAKE_OS_MAIN( StartOS(0) )

TASK(Handler11) {
#if !defined(CONFIG_ARCH_PATMOS)
    volatile int i = 1;
    while (i <  200000) i++;
#endif

    test_trace('a');
    ActivateTask(Handler12);


#if !defined(CONFIG_ARCH_PATMOS)
    i = 0;
    while (i <  200000) i++;
#endif
    test_trace('b');
    ActivateTask(Handler13);
    test_trace('c');
    TerminateTask();
}

TASK(Handler12) {
    test_trace('2');
    TerminateTask();
}

TASK(Handler13) {
	test_trace('3');
	TerminateTask();
}

/*	
    extern const uint32_t OSEKOS_TASK_Handler11;		
    static __attribute__((unused)) const uint32_t &Handler11 = OSEKOS_TASK_Handler11;	
    
    extern const uint32_t OSEKOS_TASK_Handler12;		
    static __attribute__((unused)) const uint32_t &Handler11 = OSEKOS_TASK_Handler12;
    
    extern const uint32_t OSEKOS_TASK_Handler13;		
    static __attribute__((unused)) const uint32_t &Handler11 = OSEKOS_TASK_Handler13;
 
    extern void os_main(void) {	\
	test_main();		\
    }				\
					\
    void test() {			\
        test_start();		\
        body;			\
    }		
 * 
 * noinline extern void OSEKOS_TASK_FUNC_Handler11(void){
 
        volatile int i = 1;
        while (i <  200000) i++;
        
        
        OSEKOS_ActivateTask(OSEKOS_TASK_Handler12)
        
        i = 0;
        while (i <  200000) i++;
        

        OSEKOS_ActivateTask(OSEKOS_TASK_Handler13)

        OSEKOS_TerminateTask();
        
    }
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * */