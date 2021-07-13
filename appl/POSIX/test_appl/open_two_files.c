
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/stat.h>

int main() {
    int fd1 = open("testdir/testdir2/testfile1.txt",  O_WRONLY | O_CREAT, S_IRWXU | S_IRWXG);
    int fd2 = open("testdir/testdir2/testfile2.txt",  O_WRONLY | O_CREAT, S_IRWXU | S_IRWXG);
    close(fd1);
    close(fd2);
}