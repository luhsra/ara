
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

struct Daemon {
    pthread_t new_thread;
    void* arg;
    struct Daemon* worker;
    int dummy_int;
};

void* new_thread_routine(void* arg) {
    printf("arg = \"%s\"\n", (char*)arg);
    return NULL;
}

int main() {

    struct Daemon daemon = {.arg = "Thread argument"};
    daemon.worker = calloc(8, sizeof(struct Daemon)); 
    for (int i = 0; i < 8; ++i) {
        struct Daemon* daemon_cpy = &daemon.worker[i]; 
        memcpy(daemon_cpy, &daemon, sizeof(struct Daemon));
        pthread_create(&daemon_cpy->new_thread, NULL, new_thread_routine, daemon_cpy->arg);
    }
    for (int i = 0; i < 8; ++i) {
        void* output;
        pthread_join(daemon.worker[i].new_thread, &output);   
    }
    free(daemon.worker);
}