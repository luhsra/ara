
#include <unistd.h>
#include <pthread.h>
#include <stdio.h>
#include <string.h>

#pragma clang diagnostic ignored "-Wint-conversion"

#define PIPE_READ 0
#define PIPE_WRITE 1
int pipe_fds[2];

pthread_mutex_t mutex;

struct undetectable {int* i;};
struct undetectable undi;

void write_to() {
    const char* msg = "Hallo Main Thread.";
    write(pipe_fds[PIPE_WRITE], msg, strlen(msg));
}

void read_from() {
    char msg_buf[100];
    read((int*)(undi.i), msg_buf, 100); // This one should fail
}

void mutex_lock() {
    pthread_mutex_lock(NULL); // This one should fail
}

void mutex_unlock() {
    pthread_mutex_unlock(&mutex);
}

int main() {
    pipe(pipe_fds);

    const char* msg = "Hallo Main Thread.";
    write(pipe_fds[PIPE_WRITE], msg, strlen(msg));

    char msg_buf[100];
    read((int*)(undi.i), msg_buf, 100); // This one should fail

    write_to();
    write_to();
    read_from();
    read_from();

    pthread_mutex_init(&mutex, NULL);
    pthread_mutex_lock(&mutex);
    pthread_mutex_unlock(NULL); // This one should fail
    mutex_lock();
    mutex_lock();
    mutex_unlock();
    mutex_unlock();
}