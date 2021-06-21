
#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>

struct sigaction act;

int main() {
    act.sa_handler = SIG_IGN;
    sigaction(SIGTERM, &act, NULL);
    //sigaction(SIGINT, &act, NULL);
    while (1) {};
}