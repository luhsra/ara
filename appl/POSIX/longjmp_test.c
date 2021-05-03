
#include <setjmp.h>

int main() {
    jmp_buf env;
    if(setjmp(env) == 1)
        return 0;
    longjmp(env, 1);
    return 1;
}