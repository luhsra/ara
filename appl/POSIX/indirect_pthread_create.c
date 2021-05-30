
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

struct thread_struct {
    void *(*start_routine)(void*);
    int dummy_int;
};

void* new_thread_routine(void* arg) {
    printf("arg = \"%s\"\n", (char*)arg);
    pause();
    return NULL;
}

int main() {
    struct thread_struct* dyn_thread_str = malloc(sizeof(struct thread_struct));
    dyn_thread_str->start_routine = new_thread_routine;
    dyn_thread_str->dummy_int = 42;
    pthread_t new_thread;
    pthread_create(&new_thread, NULL, dyn_thread_str->start_routine, "test argument");
    void* output;
    pthread_join(new_thread, &output);
    free(dyn_thread_str);
}