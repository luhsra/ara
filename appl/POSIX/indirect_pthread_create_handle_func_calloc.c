#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

struct double_thread {
    pthread_t thread1;
    pthread_t thread2;
};

struct thread_struct {
    struct double_thread handle;
    int dummy_handle;
};

void* new_thread_routine2(void* arg) {
    printf("arg = \"%s\"\n", (char*)arg);
    pause();
    return NULL;
}

struct thread_struct* ret_thread_struct() {
    struct thread_struct* ts = calloc(1, sizeof(struct thread_struct));
    ts->dummy_handle = 0;
    return ts;
}

void* new_thread_routine(void* arg) {
    struct thread_struct* ts = calloc(1, sizeof(struct thread_struct));
    ts->dummy_handle = 1;
    pthread_create(&(ts->handle.thread1), NULL, new_thread_routine2, "test argument");
    void* output;
    pthread_join(ts->handle.thread1, &output);
    return NULL;
}

void create_that_thread(struct thread_struct* ts) {
    pthread_create(&(ts->handle.thread1), NULL, new_thread_routine, "test argument");
    void* output;
    pthread_join(ts->handle.thread1, &output);
}

int main() {
    struct thread_struct* dyn_thread_str = ret_thread_struct();
    create_that_thread(dyn_thread_str);
    free(dyn_thread_str);
}