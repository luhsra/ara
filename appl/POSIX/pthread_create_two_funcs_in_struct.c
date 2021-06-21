#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

void* new_thread_routine_1(void* arg) {
    printf("new_thread_routine_1: arg = \"%s\"\n", (char*)arg);
    pause();
    return NULL;
}

void* new_thread_routine_2(void* arg) {
    printf("new_thread_routine_2: arg = \"%s\"\n", (char*)arg);
    pause();
    return NULL;
}

struct ThreadStruct {
    void* (*new_thread_routine_1)(void* arg);
    void* (*new_thread_routine_2)(void* arg);
};

struct ThreadStruct thread_struct;

int main() {
    //struct ThreadStruct* ptr = &thread_struct;
    thread_struct.new_thread_routine_1 = new_thread_routine_1;
    thread_struct.new_thread_routine_2 = new_thread_routine_2;
    pthread_t new_thread_1;
    pthread_t new_thread_2;
    pthread_create(&new_thread_1, NULL, thread_struct.new_thread_routine_1, "test argument");
    pthread_create(&new_thread_2, NULL, thread_struct.new_thread_routine_2, "test argument");
}