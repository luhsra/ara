
#include <time.h>
#include <stdio.h>

int main() {
    const struct timespec rqtp = {.tv_sec = 5, .tv_nsec = 300};
    struct timespec rmtp;
    nanosleep(&rqtp, &rmtp);
    printf("Time left: sec: %d, nsec: %d\n", rmtp.tv_sec, rmtp.tv_nsec);
}