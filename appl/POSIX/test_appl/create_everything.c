
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <semaphore.h>
#include <signal.h>

void* new_thread_routine(void* arg) {
    printf("arg = \"%s\"\n", (char*)arg);
    pause();
    return NULL;
}

void signal_catching_func(int sig) {
    pause();
    return;
}

// create every instance once
int main() {

    pthread_attr_t attr;
    pthread_attr_init(&attr);
    struct sched_param sched_prio;
    sched_prio.sched_priority = 5;
    pthread_attr_setschedparam(&attr, &sched_prio);
    pthread_attr_setschedpolicy(&attr, SCHED_FIFO);
    pthread_attr_setname_np(&attr, "A new Thread!");

    pthread_t new_thread;
    pthread_create(&new_thread, &attr, new_thread_routine, "test argument");
    pthread_attr_destroy(&attr);
    pthread_join(new_thread, NULL);

    pthread_mutex_t mutex;
    pthread_cond_t cond;
    pthread_mutex_init(&mutex, NULL);
    pthread_cond_init(&cond, NULL);

    int fd = open("testfile.txt", O_WRONLY | O_CREAT, S_IRWXU | S_IRGRP);
    int pipe_fds[2];
    pipe(pipe_fds);
    close(fd);

    sem_t semaphore;
    sem_init(&semaphore, 0, 3);

    struct sigaction act;
    act.sa_handler = signal_catching_func;
    sigaction(SIGALRM, &act, NULL);

}