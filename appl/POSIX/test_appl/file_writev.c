
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/uio.h>
#include <string.h>

int main() {
    int fd = open("testfile.txt", O_WRONLY);
    char* msg_buf_1 = "Test text";
    char* msg_buf_2 = " combined with ";
    char* msg_buf_3 = "multiple buffers";
    struct iovec iov[3];
    iov[0].iov_base = msg_buf_1;
    iov[0].iov_len = strlen(msg_buf_1);
    iov[1].iov_base = msg_buf_2;
    iov[1].iov_len = strlen(msg_buf_2);
    iov[2].iov_base = msg_buf_3;
    iov[2].iov_len = strlen(msg_buf_3);
    writev(fd, iov, 3);
    close(fd);
}