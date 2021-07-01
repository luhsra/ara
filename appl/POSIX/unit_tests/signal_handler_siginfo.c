
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

struct sigaction act = {.sa_sigaction = signal_catching_func, .sa_flags = SA_SIGINFO | SA_RESTART};
struct sigaction oact;

int main() {
    sigaction(SIGSEGV, &act, &oact);
    while (1) {};
}