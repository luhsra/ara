
#include <unistd.h>
#include <pthread.h>
#include <stdio.h>
#include <string.h>

#define PIPE_READ 0
#define PIPE_WRITE 1
int pipe_fds[2];

void* sender_thread(void* arg) {
    const char* msg = "Hallo Main Thread.";
    write(pipe_fds[PIPE_READ], msg, strlen(msg));

    return NULL;
}

int main() {
    pipe(pipe_fds);

    pthread_t new_thread;
    pthread_create(&new_thread, NULL, sender_thread, NULL);

    char msg_buf[100];
    read(pipe_fds[PIPE_WRITE], msg_buf, 100);

    puts(msg_buf);
    void* output;
    pthread_join(new_thread, &output);
}