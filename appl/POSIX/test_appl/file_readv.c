
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/uio.h>

int main() {
    int fd = open("testfile.txt", O_RDONLY);
    char msg_buf_1[10];
    char msg_buf_2[20];
    char msg_buf_3[7];
    msg_buf_1[0] = '\0';
    msg_buf_2[0] = '\0';
    msg_buf_3[0] = '\0';
    struct iovec iov[3];
    iov[0].iov_base = msg_buf_1;
    iov[0].iov_len = 9;
    iov[1].iov_base = msg_buf_2;
    iov[1].iov_len = 19;
    iov[2].iov_base = msg_buf_3;
    iov[2].iov_len = 6;
    readv(fd, iov, 3);
    msg_buf_1[9] = '\0';
    msg_buf_2[19] = '\0';
    msg_buf_3[6] = '\0';
    puts(msg_buf_1);
    puts(msg_buf_2);
    puts(msg_buf_3);
    close(fd);
}