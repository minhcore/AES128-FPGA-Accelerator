#include "mcu_init.h"
#include "io.h"
#include "uart.h"
#include "common/defines.h"

#include <msp430.h>

static void init_clocks(void)
{
    if(CALBC1_1MHZ == 0xFF || CALBC1_16MHZ == 0xFF) {
        while (1) { }
    }
    BCSCTL1 = CALBC1_16MHZ;
    DCOCTL = CALDCO_16MHZ;
}

static void watchdog_stop(void)
{
    WDTCTL = WDTPW + WDTHOLD;
}

void mcu_init(void)
{
    watchdog_stop();
    init_clocks();
    io_init();
    _enable_interrupts();
}
