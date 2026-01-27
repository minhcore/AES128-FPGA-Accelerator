#ifndef IO_H
#define IO_H

#include <stdbool.h>

typedef enum {
    IO_10,
    IO_11,
    IO_12,
    IO_13,
    IO_14,
    IO_15,
    IO_16,
    IO_17,
    IO_20,
    IO_21,
    IO_22,
    IO_23,
    IO_24,
    IO_25,
    IO_26,
    IO_27,
} io_generic_e;

typedef enum {
    IO_TEST_LED = IO_10,
    IO_UART_RXD = IO_11,
    IO_UART_TXD = IO_12,
    IO_UNUSED_1 = IO_13,
    IO_UNUSED_2 = IO_14,
    IO_UNUSED_3 = IO_15,
    IO_UNUSED_4 = IO_16,
    IO_UNUSED_5 = IO_17,
    IO_UNUSED_6 = IO_20,
    IO_UNUSED_7 = IO_21,
    IO_UNUSED_8 = IO_22,
    IO_UNUSED_9 = IO_23,
    IO_UNUSED_10 = IO_24,
    IO_UNUSED_11 = IO_25,
    IO_UNUSED_12 = IO_26,
    IO_UNUSED_13 = IO_27,
} io_e;

typedef enum {
    IO_SELECT_GPIO,
    IO_SELECT_ALT1,
    IO_SELECT_ALT2,
    IO_SELECT_ALT3,
} io_selected_e;

typedef enum {
    IO_RESISTOR_DISABLED,
    IO_RESISTOR_ENABLED,
} io_resistor_e;

typedef enum {
    IO_DIR_INPUT,
    IO_DIR_OUTPUT,
} io_dir_e;

typedef enum {
    IO_OUT_LOW,
    IO_OUT_HIGH,
} io_out_e;

struct io_config
{
    io_selected_e select;
    io_resistor_e resistor;
    io_dir_e direction;
    io_out_e out;
};

void io_init(void);
void io_configure(io_e io, const struct io_config *config);
void io_set_select(io_e io, io_selected_e select);
void io_set_direction(io_e io, io_dir_e direction);
void io_set_resistor(io_e io, io_resistor_e resistor);
void io_set_out(io_e io, io_out_e out);

#endif