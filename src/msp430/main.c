#include <msp430.h>
#include <stdint.h>

#include "drivers/mcu_init.h"
#include "drivers/uart.h"

int main (void)
{
    mcu_init();
    uart_init();
    char c;
    while (1) { 
        if (uart_get_char(&c))
        {
            uart_put_char(c);
            uart_put_char('\r');
            uart_put_char('\n');
        }
    }
}