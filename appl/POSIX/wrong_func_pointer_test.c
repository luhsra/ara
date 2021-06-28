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

struct InnerThreadStruct {
    void* (*new_thread_routine_2)(void* arg);
};

struct ThreadStruct {
    struct InnerThreadStruct* istr;
    void* (*new_thread_routine)(void* arg);
};

struct InnerThreadStruct* istr;
struct ThreadStruct* thread_struct;

int main() {
    istr = malloc(sizeof(struct InnerThreadStruct) + 123);
    thread_struct = malloc(sizeof(struct ThreadStruct) + 23);
    thread_struct->istr = &istr;
    thread_struct->new_thread_routine = new_thread_routine_2;
    char* c_istr = (char*)thread_struct->istr;
    for (int i = 0; i < 150; ++i)
        c_istr[i] = '\0';
    istr = (struct InnerThreadStruct*)c_istr;
    istr->new_thread_routine_2(NULL);
}