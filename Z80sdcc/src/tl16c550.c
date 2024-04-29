
#include "tl16c550.h"

void delay(unsigned int t);
void delay(unsigned int t) {
    for(char j = 0; j != t; j++) {
        __asm
        nop
        __endasm;
    }
}

char uart_get(void) {
    return port_0xf8ef;
}

// tl16c550 init.
void uart_init(void) {
    port_0xfcef = 0x0d; // Assert RTS
    port_0xfaef = 0x87; // Enable fifo 8 level, and clear it
    port_0xfbef = 0x83; // 8n1, DLAB=1
    port_0xf8ef = 0x01; // 115200 (divider 1)
    port_0xf9ef = 0x00; // (divider 0). Divider is 16 bit, so we get (0x0001 divider)
    port_0xfbef = 0x03; // 8n1, DLAB=0
    port_0xf9ef = 0x00; // Disable int
    port_0xfcef = 0x2f; // Enable AFE
}

void uart_print(char* text) {
    char ii = 0;
    while(*(text+ii) != 0) {
        port_0xf8ef = *(text+ii++);
        delay(10);
    }
}
