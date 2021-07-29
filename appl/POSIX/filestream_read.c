#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

int main() {
    FILE* file = fopen("file_stream.txt", "r");
    char str[20];
    fread(str, 1, 20, file);
    puts(str);
    fclose(file);
}