#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>

int main() {
    FILE* file = fopen("file_stream.txt", "r");
    fclose(file);
}