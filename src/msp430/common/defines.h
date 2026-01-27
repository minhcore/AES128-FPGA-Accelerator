#ifndef DEFINES_H
#define DEFINES_H

#define ARRAY_SIZE(array) (sizeof(array) / sizeof(array[0]))

#define CYCLES_1MHZ (1000000u)
#define CYCLES_16MHZ (16u * CYCLES_1MHZ)
#define CYCLES_PER_MS (CYCLES_16MHZ / 1000UL)
#define ms_TO_CYCLES(ms) ((unsigned long)CYCLES_PER_MS * ms)
#define BUSY_WAIT_ms(ms) (__delay_cycles(ms_TO_CYCLES(ms)))

#endif