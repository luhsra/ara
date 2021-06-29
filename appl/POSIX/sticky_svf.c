#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

size_t new_thread_routine(void* _, void* __, void* ___) {
    pause();
    return 0;
}

struct stickyStruct {
    size_t (*new_thread_routine_ptr)(void* _, void* __, void* ___);
};

struct stickyStruct sticky_struct; 

int main() {
    FILE* file = fopen("yaml.txt", "r");
    sticky_struct.new_thread_routine_ptr = &new_thread_routine;
    fwrite(&sticky_struct, sizeof(struct stickyStruct), 1, file);
    sticky_struct.new_thread_routine_ptr(NULL, NULL, NULL);
}