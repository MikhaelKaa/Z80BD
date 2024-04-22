// 15.04.2024 Михаил Каа

#include "main.h"
#include "font.h"

#define SCREEN_START_ADR (0x4000)
#define SCREEN_SIZE ((256/8)*192)
#define SCREEN_ATR_SIZE (768)

void init_screen(void);
char GetMagicNumber() __naked;
void cls(void) __naked;
void print(char x, char y, char* text) __naked;
int get_screen_adr(char x, char y) __naked;
void uart_print(char * text);

char *screen = 0x4000;
char w = 0;
char i = 0;
char key[8] = {0, 0, 0, 0, 0, 0, 0, 0};
static volatile char irq_0x38_flag = 0;
static volatile char nmi_0x66_flag = 0;
char msg[] = "Hello world!!!\r\n";


void main() {
    port_0x7ffd = 0x00;
    init_screen();
    print(10, 10, msg);

    // PSG init
    port_0xfffd = 0x07;
    port_0xbffd = 0x38;
    port_0xfffd = 0x08;
    port_0xbffd = 0x0a;

    // 16c550 init
    port_0xfcef = 0x0d; // Assert RTS
    port_0xfaef = 0x87; // Enable fifo 8 level, and clear it
    port_0xfbef = 0x83; // 8n1, DLAB=1
    port_0xf8ef = 0x01; // 115200 (divider 1)
    port_0xf9ef = 0x00; // (divider 0). Divider is 16 bit, so we get (0x0001 divider)
    port_0xfbef = 0x03; // 8n1, DLAB=0
    port_0xf9ef = 0x00; // Disable int
    port_0xfcef = 0x2f; // Enable AFE

    // port_0xfbef = 128;
    // port_0xf8ef = 1;
    // port_0xf9ef = 0;
    // port_0xfbef = 3;

    while(1) {
        *(screen + 4) = key[0];
        *(screen + 6) = key[1];

        if(irq_0x38_flag) {
            irq_0x38_flag = 0;
            //if(!(i%129)) port_0x00fe = w++;
            *(screen + 0) = i++;
            port_0xfffd = 0x00;
            port_0xbffd = i;
        }

        if(nmi_0x66_flag) {
            nmi_0x66_flag = 0;
            char tmp = *(screen + 2);
            *(screen + 2) = tmp + 1;
        }
        
        *(screen + 7) = port_0xf8ef;
        *(screen + 9) = port_0xfdef;
        *(screen + 8) = port_0xfeef;
        //port_0xf8ef = 0x55;
        uart_print(msg);
    }
}

void delay(unsigned int t);
void delay(unsigned int t) {
    for(char j = 0; j!=t; j++) {
        __asm
        nop
        __endasm;
    }
}

void uart_print(char * text) {
    char ii = 0;
    while(*(text+ii)!=0) {
        port_0xf8ef = *(text+ii++);
        delay(10);
    }
}

void init_screen(void) {
    port_0x00fe = 7;
    for (unsigned int i = SCREEN_START_ADR; i < (SCREEN_START_ADR+SCREEN_SIZE); i++) {
        *((char *)i) = 0;
    } 
    for (unsigned int i = SCREEN_START_ADR+SCREEN_SIZE; i < (SCREEN_START_ADR+SCREEN_SIZE+SCREEN_ATR_SIZE); i++) {
        *((char *)i) = 4;
    }
    port_0x00fe = 0;
}


// Возврашает адрес на экране для координат x и y.
int get_screen_adr(char x, char y) __naked {
    __asm
    ld iy, #2
    add iy, sp
    ld d, (iy)
    ld e, 1(iy)
    ld a,d
    and #7
    rra
    rra
    rra
    rra
    or e
    ld e,a
    ld a,d
    and #24
    or #64
    ld d,a
    push de
    pop hl
    ret 
    __endasm;
}

void print(char x, char y, char* text) __naked {
    __asm
    ld iy, #2
    add iy, sp
    ld d, 0(iy)   ;x
    ld e, 1(iy)   ;y
    ld l, 2(iy)
    ld h, 3(iy)
print_string:
    call get_adr_on_screen
print_string_loop:
    ld a, (hl)
    and a
    ret z
    push hl
    ld h, #0
    ld l, a
    add hl, hl
    add hl, hl
    add hl, hl
    ld bc, #_src_font_en_ch8 - #256 ;
    add hl, bc
    push de
    call print_char
    pop de
    pop hl
    inc hl
    inc de
    jp print_string_loop
    ret

print_char:
    ld b, #8
pchar_loop:
    ld a, (hl)
    ld (de), a
    inc d
    inc hl
    djnz pchar_loop
    ret

get_adr_on_screen:       
    ld a,d
    and #7
    rra
    rra
    rra
    rra
    or e
    ld e,a
    ld a,d
    and #24
    or #64
    ld d,a
    ret 

    __endasm;
}

// void cls(void) __naked {
//     __asm
//     xor a
//     ld hl, #0x4000 ;;начало экрана
//     ld de, #0x4001
//     ld bc, (#256/#8)*#192+#768 ;;экранн+атрибуты
//     ld (hl), a
//     ldir
//     ret
//     __endasm;
// }

// https://gist.github.com/Konamiman/af5645b9998c802753023cf1be8a2970
char GetMagicNumber() __naked {
    __asm
    ld l, #85
    ret
    __endasm;
}

volatile void irq_0x38(void) {
    irq_0x38_flag = 1;

    key[0] = port_0x7ffe;
    key[1] = port_0xeffe;
    key[2] = port_0xbffe;
    key[3] = port_0xdffe;
    key[4] = port_0xf7fe;
    key[5] = port_0xfefe;
    key[6] = port_0xfbfe;
    key[7] = port_0xfdfe;

    // __asm
    //  .ds	150
    // __endasm; 
}

volatile void nmi_0x66(void) {
    nmi_0x66_flag = 1;

    // __asm
    //  .ds	150
    // __endasm; 
}
