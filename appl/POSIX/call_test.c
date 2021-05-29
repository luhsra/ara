
#include <unistd.h>

int call() {
    pause();
    return 0;
}

int main() {
    call();
}