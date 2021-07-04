#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

size_t new_thread_routine(void* _, void* __, void* ___) {
    pause();
    return 0;
}

struct stickyStruct {
    FILE* file;
    size_t (*new_thread_routine_ptr)(void* _, void* __, void* ___);
};

struct stickyStruct sticky_struct; 

int main() {
    sticky_struct.new_thread_routine_ptr = &new_thread_routine;
    sticky_struct.file = fopen("yaml.txt", "r");
    //fwrite(&sticky_struct, sizeof(struct stickyStruct), 1, file);
    sticky_struct.new_thread_routine_ptr(NULL, NULL, NULL);
}