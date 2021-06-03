#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h> 

struct thread_struct {
    pthread_t handle;
    pthread_t dummy_handle;
};

void* new_thread_routine(void* arg) {
    printf("arg = \"%s\"\n", (char*)arg);
    pause();
    return NULL;
}

int main() {
    struct thread_struct* dyn_thread_str = calloc(1, sizeof(struct thread_struct));
    pthread_create(&(dyn_thread_str->handle), NULL, new_thread_routine, "test argument");
    void* output;
    pthread_join(dyn_thread_str->handle, &output);
    free(dyn_thread_str);
}