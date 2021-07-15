
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <semaphore.h>

typedef struct Item {
    int integer;
    int from_producer;
} Item;

typedef struct RingBuffer {
    Item* buffer;
    size_t buffer_size;
    sem_t buffer_access;
    sem_t producable_items;
    sem_t consumable_items;
    Item* head;
    Item* tail;
} RingBuffer;

void init_ringbuffer(RingBuffer* ring_buffer, Item* buffer, const size_t buffer_size) {
    ring_buffer->buffer = buffer;
    ring_buffer->buffer_size = buffer_size;
    sem_init(&ring_buffer->buffer_access, 1, 1); // pshared = 1 -> to verify detection of this value in the analysis
    sem_init(&ring_buffer->producable_items, 0, buffer_size);
    sem_init(&ring_buffer->consumable_items, 0, 0);
    ring_buffer->head = buffer;
    ring_buffer->tail = buffer;
}

Item* increment_without_overflow(Item* pointer, Item* array, size_t size) {
    pointer += 1;
    if (pointer >= (array + size)) {
        pointer = array;
    }
    return pointer;
}

Item consume_item(RingBuffer* ring_buffer) {
    sem_wait(&ring_buffer->consumable_items);
    sem_wait(&ring_buffer->buffer_access);
    Item ret = *ring_buffer->head;
    ring_buffer->head = increment_without_overflow(ring_buffer->head, ring_buffer->buffer, ring_buffer->buffer_size);
    sem_post(&ring_buffer->buffer_access);
    sem_post(&ring_buffer->producable_items);
    return ret;
}

void produce_item(RingBuffer* ring_buffer, Item item) {
    sem_wait(&ring_buffer->producable_items);
    sem_wait(&ring_buffer->buffer_access);
    *ring_buffer->tail = item;
    ring_buffer->tail = increment_without_overflow(ring_buffer->tail, ring_buffer->buffer, ring_buffer->buffer_size);
    sem_post(&ring_buffer->buffer_access);
    sem_post(&ring_buffer->consumable_items);
}

const size_t buffer_size = 25;
Item buffer[buffer_size];
RingBuffer ring_buffer;

void* consumer_thread_routine(void* arg) {
    while (1) {
        Item item = consume_item(&ring_buffer);
        printf("Got %d from producer %d\n", item.integer, item.from_producer);
    }
    return NULL;
}

void* producer_thread_routine(void* arg) {
    int producer = *((int*)arg);
    for (int i = 0; i < 20; ++i) {
        Item item = {.integer = i, .from_producer=producer};
        produce_item(&ring_buffer, item);
    }
    return NULL;
}

int main() {
    init_ringbuffer(&ring_buffer, buffer, buffer_size);
    pthread_t consumer_thread;
    pthread_t producer_thread_1;
    pthread_t producer_thread_2;
    pthread_create(&consumer_thread, NULL, &consumer_thread_routine, NULL);
    int one = 1;
    int two = 2;
    pthread_create(&producer_thread_1, NULL, &producer_thread_routine, &one);
    pthread_create(&producer_thread_2, NULL, &producer_thread_routine, &two);
    void* output;
    pthread_join(consumer_thread, &output);
    pthread_join(producer_thread_1, &output);
    pthread_join(producer_thread_2, &output);
}