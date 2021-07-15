
#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <pthread.h>

pthread_mutex_t mutex;

void signal_catching_func(int sig) {
    pause();
    pthread_mutex_init(&mutex, NULL); // Must throw an error
}

struct sigaction act;

int main() {
    act.sa_handler = signal_catching_func;
    sigaction(SIGCHLD, &act, NULL);
    while (1) {};
}