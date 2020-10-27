#include "printer.h"
#include <zephyr.h>
#include <sys/printk.h>

void printCoolStuff(const char* s, int n){
    for (int i = 0; i < n; i++) {
        printk("%s", s);
    }
}
