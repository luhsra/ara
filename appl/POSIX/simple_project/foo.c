#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "bar.h"

int foo(char value) {
    putchar(value);
    putchar(' ');
    //char* super_puts_str = "> Test";
    char* super_puts_str = malloc(25);
    char* test = "> Test";
    //strcpy(super_puts_str, test);
    super_puts(test);
    free(super_puts_str);
    write(0, 0, 45);
    return 5;
}