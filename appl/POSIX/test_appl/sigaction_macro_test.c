
#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>

void signal_catching_func(int sig) {
    pause();
    return;
}

int test_sigaction(int a, int b, int c) {
    return 0;
}

struct sigaction act;
struct sigaction old_act;

int main() {
    act.sa_handler = signal_catching_func;
    if (sigaction(SIGALRM, &act, NULL) != 0) {
        perror("sigaction(act)");
        return -1;
    }
    if (sigaction(SIGALRM, NULL, &old_act) != 0) {
        perror("sigaction(old_act)");
        return -2;
    }
    // The following should not be detected:
    int (*sigaction_ptr)(int, const struct sigaction *, struct sigaction *) = sigaction;
    sigaction_ptr(SIGSEGV, &act, NULL);
}