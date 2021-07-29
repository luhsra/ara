/*
    The only purpose of this file is to provide an implementation for some LLVM compiler-rt builtins used by musl-libc.
    wllvm/clang with '-fno-builtin' can not fix this issue. So we need to provide this simple file. 
*/

#include <complex.h>

#define MULTIPLY_COMPLEX(a, b, c, d) (a + I * b) * (c + I * d)

complex float __mulsc3 (float a, float b, float c, float d) {
    return MULTIPLY_COMPLEX(a, b, c, d);
}

complex double __muldc3 (double a, double b, double c, double d) {
    return MULTIPLY_COMPLEX(a, b, c, d);
}

complex double __multc3 (long double a, long double b, long double c, long double d) {
    return MULTIPLY_COMPLEX(a, b, c, d);
}

complex long double __mulxc3 (long double a, long double b, long double c, long double d) {
    return MULTIPLY_COMPLEX(a, b, c, d);
}