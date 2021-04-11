#include <stdio.h>
//#include <stdlib.h>
//#include <string.h>
#include "bar.h"

int foo(char value) {
    putchar(value);
    putchar(' ');
    char* super_puts_str = "> Test";
    //char* super_puts_str = (char*)malloc(7);
    //strcpy(super_puts_str, "> Test");
    super_puts(super_puts_str);
    //free(super_puts_str);
    return 5;
}