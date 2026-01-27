#include "ring_buffer.h"

void ring_buffer_put(struct ring_buffer *rb, uint8_t data)
{
    rb->buffer[rb->head] = data;
    rb->head++;
    if (rb->head == rb->size) {
        rb->head = 0;
    }
}

uint8_t ring_buffer_get(struct ring_buffer *rb)
{
    uint8_t data = rb->buffer[rb->tail];
    rb->tail++;
    if (rb->tail == rb->size) {
        rb->tail = 0;
    }
    return data;
}

bool empty_ring_buffer(const struct ring_buffer *rb)
{
    return (rb->head == rb->tail);
}

bool full_ring_buffer(const struct ring_buffer *rb)
{
    uint8_t next_head = rb->head + 1;
    if (next_head == rb->size) {
        next_head = 0;
    }
    return next_head == rb->tail;
}