
#include <fcntl.h>
#include <sys/stat.h>
#include <pthread.h>
#include <mqueue.h>
#include <stdio.h>
#include <string.h>

void* sender_thread(void* arg) {
    mqd_t queue = mq_open("/test_queue", O_WRONLY);
    const char* msg = "Hallo Main Thread.";
    mq_send(queue, msg, strlen(msg), 0);
    return NULL;
}

int main() {
    struct mq_attr msg_size = {.mq_flags = 0, .mq_maxmsg = 10, .mq_msgsize = 100, .mq_curmsgs = 0};
    mqd_t queue = mq_open("/test_queue", O_RDONLY|O_CREAT, S_IRWXU, &msg_size);
    if (queue == -1) {
        perror(NULL);
    }
    pthread_t new_thread;
    pthread_create(&new_thread, NULL, sender_thread, NULL);
    char msg_buf[101];
    mq_receive(queue, msg_buf, 101, NULL);
    puts(msg_buf);
}