
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>

struct Struct_obj {
    int instance;
};

typedef struct Struct_obj Struct_obj;

int main() {
    Struct_obj obj;

    int inst = open("testfile.txt", O_RDONLY);
    obj.instance = inst;
    char buf[25];
    read(obj.instance, buf, 25);
}