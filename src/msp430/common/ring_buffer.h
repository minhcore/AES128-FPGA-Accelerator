#ifndef RING_BUFFER_H
#define RING_BUFFER_H

#include <stdint.h>
#include <stdbool.h>

struct ring_buffer
{
    uint8_t *buffer;
    uint8_t size;
    uint8_t head;
    uint8_t tail;
};

void ring_buffer_put(struct ring_buffer *rb, uint8_t data);
uint8_t ring_buffer_get(struct ring_buffer *rb);
bool empty_ring_buffer(const struct ring_buffer *rb);
bool full_ring_buffer(const struct ring_buffer *rb);

#endif