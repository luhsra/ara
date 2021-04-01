#include <stdio.h>
#include "foo.h"

long super_puts(char* str) {
    puts("super ");
    puts(str);
    return 24;
}

int main() {
    return foo('>');
}