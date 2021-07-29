#include <unistd.h>

int main() {
    int fd[2];
    pipe2(fd, 0);
    char buf[25];
    write(fd[0], buf, 25);
}