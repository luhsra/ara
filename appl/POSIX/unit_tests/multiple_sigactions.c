
#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>

volatile int catched_signal;

void signal_catching_func_1(int sig) {
    const char* buf = "signal_catching_func called!\n"; 
    write(0, buf, strlen(buf) + 1);
    pause();
    return;
}

void signal_catching_func_2(int sig) {
    catched_signal = sig;
    return;
}

struct sigaction act_ign;
struct sigaction act_scf_1 = {.sa_handler = signal_catching_func_1};
struct sigaction act_scf_2 = {.sa_handler = signal_catching_func_1};
struct sigaction act_cs;

int main() {
    act_ign.sa_handler = SIG_IGN;
    sigaction(SIGTERM, &act_ign, NULL);
    sigaction(SIGINT, &act_ign, NULL);
    sigaction(SIGUSR1, &act_scf_1, NULL);
    sigaction(SIGUSR2, &act_scf_2, NULL);
    act_cs.sa_handler = signal_catching_func_2;
    sigaction(SIGSYS, &act_cs, NULL);
    while (1) {};
}