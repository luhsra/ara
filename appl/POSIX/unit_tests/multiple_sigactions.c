
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
struct sigaction act_scf;
struct sigaction act_cs;

int main() {
    act_ign.sa_handler = SIG_IGN;
    sigaction(SIGTERM, &act_ign, NULL);
    sigaction(SIGINT, &act_ign, NULL);
    act_scf.sa_handler = signal_catching_func_1;
    sigaction(SIGUSR1, &act_scf, NULL);
    sigaction(SIGUSR2, &act_scf, NULL);
    act_cs.sa_handler = signal_catching_func_2;
    sigaction(SIGSYS, &act_cs, NULL);
    while (1) {};
}