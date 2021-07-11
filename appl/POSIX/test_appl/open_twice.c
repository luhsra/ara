
#include <unistd.h>
#include <fcntl.h>
#include <pthread.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>

void* sender_thread(void* arg) {
    int testfile = open("testdir/testfile.txt", O_WRONLY | O_CREAT, S_IRWXU);
    const char* msg = "Hallo Main Thread.";
    write(testfile, msg, strlen(msg));

    close(testfile);
    return NULL;
}

int main() {
    pthread_t new_thread;
    pthread_create(&new_thread, NULL, sender_thread, NULL);
    void* output;
    pthread_join(new_thread, &output);

    int testfile = open("testdir/testfile.txt", O_RDONLY);
    char msg_buf[100];
    read(testfile, msg_buf, 100);

    puts(msg_buf);
    close(testfile);
}