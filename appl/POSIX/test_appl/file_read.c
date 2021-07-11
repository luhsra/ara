
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>

int main() {
    int fd = open("testfile.txt", O_RDONLY);
    char msg_buf[100];
    read(fd, msg_buf, 100);
    puts(msg_buf);
    close(fd);
}