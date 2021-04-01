#include <stdio.h>
#include "bar.h"

int foo(char value) {
    putchar(value);
    putchar(' ');
    super_puts("> Test");
    return 5;
}