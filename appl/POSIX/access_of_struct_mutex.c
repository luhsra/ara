
#include <pthread.h>

struct MutexStruct {
    pthread_mutex_t mutex1;
    pthread_mutex_t mutex2;
};

struct MutexStruct mutex_struct;

int main() {
    pthread_mutex_init(&mutex_struct.mutex1, NULL);
    pthread_mutex_init(&mutex_struct.mutex2, NULL);
    pthread_mutex_unlock(&mutex_struct.mutex1);
    pthread_mutex_unlock(&mutex_struct.mutex2);
}