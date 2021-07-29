
#include <pthread.h>
#include <stdlib.h>

struct Struct_obj {
    pthread_mutex_t instance;
};

typedef struct Struct_obj Struct_obj;

int main() {
    Struct_obj obj;
    
    pthread_mutex_init(&obj.instance, NULL);
    pthread_mutex_lock(&obj.instance);
}