
#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>

void signal_catching_func(int sig) {
    const char* buf = "signal_catching_func called!\n"; 
    write(0, buf, strlen(buf) + 1);
    pause();
    return;
}

struct sigaction act;

int main() {
    act.sa_handler = signal_catching_func;
    sigaction(SIGTERM, &act, NULL);
    while (1) {};
}