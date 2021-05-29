
#include <unistd.h>

int caller(int (*ind_call)(void)) {
    ind_call();
    return 0;
}

int main() {
    int (*ind_call)(void);
    //ind_call = pause;
    caller(ind_call);
}