#include <unistd.h>
#include <pthread.h>
#include <stdio.h>
#include <string.h>

char received_msg[10];
void* thread_output;
#define READ_FD 0
#define WRITE_FD 1
#define write(fd, msg) write(fd, msg, strlen(msg))
#define read(fd, msg_buf) read(fd, msg_buf, 10)
#define pthread_create(thread, entry_point) pthread_create(&thread, NULL, entry_point, NULL)
#define pthread_join(thread) pthread_join(thread, &thread_output)
#define thread_1() void* thread_1(void* arg)
#define thread_2() void* thread_2(void* arg)
#pragma clang diagnostic ignored "-Wreturn-type"

// --- Paper include --- //
char* Message = "{...}";
int pipe_fds[2];
pthread_t t1;
pthread_t t2;

thread_1() {
    write(pipe_fds[WRITE_FD], Message);
}

thread_2() {
    read(pipe_fds[READ_FD], received_msg);
}

int main() {
    pipe(pipe_fds);
    pthread_create(t1, thread_1);
    pthread_create(t2, thread_2);
    pthread_join(t1);
    pthread_join(t2);
}