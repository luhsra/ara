
#include <zephyr.h>

#define STACKSIZE 1024

#define PRIORITY 7

#define HEAP_SIZE 2048

struct k_heap shared_heap;
unsigned char buf[2048];

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

void main() {
    zephyr_dummy_syscall();
    k_heap_init(&shared_heap, buf, sizeof(buf));
    while(true){
        void* chunk = k_malloc(123);
        k_heap_alloc(&shared_heap, 0xaa, K_NO_WAIT);
        k_free(chunk);
    }
}
