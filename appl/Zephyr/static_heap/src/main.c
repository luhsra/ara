
#include <zephyr.h>

#define STACKSIZE 1024

#define PRIORITY 7

#define HEAP_SIZE 2048

K_HEAP_DEFINE(shared_heap, HEAP_SIZE);

void do_stuff(void* mem_1, void* dummy2, void *dummy3)
{
	ARG_UNUSED(dummy2);
	ARG_UNUSED(dummy3);
        while(true){
            void* chunk = k_calloc(123, sizeof(char));
            k_heap_free(&shared_heap, mem_1);
            k_free(chunk);
        }
}

K_THREAD_DEFINE(thread_a, STACKSIZE, do_stuff, 0xdeadbeef, NULL, NULL,
		PRIORITY, 0, 0);

void zephyr_dummy_syscall(){};

void sleep_tight(struct k_thread* t, void* data){
}

void main() {
    zephyr_dummy_syscall();

    while(true){
        void* chunk = k_malloc(123);
        k_heap_alloc(&shared_heap, 0xaa, K_NO_WAIT);
        k_free(chunk);
    }
}
