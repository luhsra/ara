
#include <semaphore.h>

struct SemStruct {
    sem_t sem1;
    sem_t sem2;
};

struct SemStruct sem_struct;

int main() {
    sem_init(&sem_struct.sem1, 0, 0);
    sem_init(&sem_struct.sem2, 0, 0);
    sem_post(&sem_struct.sem1);
    sem_post(&sem_struct.sem2);
}