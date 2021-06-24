
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

int main() {
    FILE* file = fopen("file_stream.txt", "w");
    int i = 42;
    fprintf(file, "File stream writing test with integer %d\n", i);
    fclose(file);
}