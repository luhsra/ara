#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>

struct _FILE {
    size_t (*write)(char);
    char buffer[25];
};

size_t _fwrite(void *obj, struct _FILE *f) {
    memcpy(f->buffer, obj, 25);
    return f->write(' ');
}

size_t sticky_func(void* _) {
    return open("hallo.txt", O_RDONLY);
}

struct stickyStruct {
    size_t (*func_ptr)(void* _);
};

struct stickyStruct sticky_struct; 
struct _FILE file_struct;

int main() {
    sticky_struct.func_ptr = &sticky_func;
    write(_fwrite(&sticky_struct, &file_struct), NULL, 0);
    sticky_struct.func_ptr(NULL);
}