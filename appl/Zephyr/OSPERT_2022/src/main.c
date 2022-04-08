
#include <zephyr.h>

struct Message {
    void* reserved; // Reserved for queue management
    int data;
};
typedef struct Message Message;

Message produce() {
    Message ret = {.reserved=NULL, .data=0};
    return ret;
}

void consume(Message* m) {}

#define t1_action() void t1_action(void* a, void* b, void* c)
#define t2_action() void t2_action(void* a, void* b, void* c)

K_THREAD_STACK_DEFINE(stack_area, 1024);

//#define _K_THREAD_DEFINE(name, stack_size, entry, p1, p2, p3, prio, options, delay) \
//         K_THREAD_DEFINE(name, stack_size, entry, p1, p2, p3, prio, options, delay)
//#undef K_THREAD_DEFINE
//#define K_THREAD_DEFINE(name, entry, prio) K_THREAD_DEFINE(name, 1024, entry, NULL, NULL, NULL, prio, 0, 0)
typedef struct k_thread k_thread;
#define k_thread_create(new_thread, entry, prio) k_thread_create(&new_thread, stack_area, 1024, entry, NULL, NULL, NULL, prio, 0, K_NO_WAIT)
#pragma clang diagnostic ignored "-Wreturn-type"

// --- Paper include --- // (Remove K_THREAD_DEFINE and uncomment the rest)
// struct Message {...};
K_FIFO_DEFINE(q1);

t1_action() {
	Message m = produce();
	k_fifo_put(&q1, &m);
}

t2_action() {
	Message* m = k_fifo_get(&q1, K_FOREVER);
	consume(m);
}

// K_THREAD_DEFINE(t1, t1_action, 1);
K_THREAD_DEFINE(t1, 1024, t1_action, NULL, NULL, NULL, 1, 0, 0);
k_thread t2;

int main() {
	k_thread_create(t2, t2_action, 2);
}