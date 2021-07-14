
#include <fcntl.h>
#include <sys/uio.h>
#include <string.h>
#include <time.h>

#define SYS_READ 0
#define SYS_WRITE 1
#define SYS_OPEN 2
#define SYS_WRITEV 20
#define SYS_PAUSE 34

long __syscall3(long n, long a1, long a2, long a3) {
    return 0;
}

long __syscall2(long n, long a1, long a2) {
    return 0;
}

long __syscall0(long n) {
    return 0;
}

int main() {
    int fd = __syscall3(SYS_OPEN, (long)"testdir/testfile.txt", O_RDWR, (long)NULL);
    char input[25];
    __syscall3(SYS_READ, (long)fd, (long)input, sizeof(25));
    char* str = "write this to the file";
    __syscall3(SYS_WRITE, (long)fd, (long)str, strlen(str) + 1);
    char* msg_buf_1 = "Test data to write";
    char* msg_buf_2 = " to the file.";
    struct iovec iov[2];
    iov[0].iov_base = msg_buf_1;
    iov[0].iov_len = strlen(msg_buf_1);
    iov[1].iov_base = msg_buf_2;
    iov[1].iov_len = strlen(msg_buf_2);
    __syscall3(SYS_WRITEV, (long)fd, (long)iov, 2);

    __syscall0(SYS_PAUSE);
}