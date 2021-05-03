
#include <pthread.h>

#define PTHREAD_CREATE_ARGS \
    pthread_t *__restrict thread, const pthread_attr_t *__restrict attr, void *(*start_routine)(void *), void *__restrict arg

//int __pthread_create(PTHREAD_CREATE_ARGS);
//int pthread_create(PTHREAD_CREATE_ARGS) {
//    return __pthread_create(thread, attr, start_routine, arg);
//}