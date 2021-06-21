
#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>

void signal_catching_func(int signo, siginfo_t *info, void *context) {
    const char* buf = "signal_catching_func called!\n"; 
    write(0, buf, strlen(buf) + 1);
    pause();
    return;
}

struct sigaction act;
struct sigaction oact;

int main() {
    act.sa_sigaction = signal_catching_func;
    act.sa_flags = SA_SIGINFO | SA_RESTART;
    sigaction(SIGSEGV, &act, &oact);
    while (1) {};
}