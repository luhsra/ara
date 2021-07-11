
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

int main() {
    int fd = open("testfile.txt", O_RDWR);
    const char* msg = "File writing Test";
    write(fd, msg, strlen(msg));
    close(fd);
}