#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

int main() {
    FILE* file = fopen("file_stream.txt", "w");
    char* str = "File stream writing test";
    fwrite(str, 1, strlen(str), file);
    fclose(file);
}