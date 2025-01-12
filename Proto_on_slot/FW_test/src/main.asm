    device ZXSPECTRUM48

begin:

mem_window_0_port EQU 0x0010
mem_window_1_port EQU 0x0011
mem_window_2_port EQU 0x0012
mem_window_3_port EQU 0x0014
system_port       EQU 0x0020

; uart_16550_port   EQU 0x00ef
uart_reg_0        EQU 0xf8ef
uart_reg_1        EQU 0xf9ef
uart_reg_2        EQU 0xfaef
uart_reg_3        EQU 0xfbef
uart_reg_4        EQU 0xfcef
uart_reg_5        EQU 0xfdef
uart_reg_6        EQU 0xfeef
uart_reg_7        EQU 0xffef

    org 0x0000
    ; Запрещаем прерывания.
    di

    org 0x0000
    ; Запрещаем прерывания.
    di

    ld	a, 0x0d
    ld	bc, 0xfcef
    out	(c),a

    ; ld	a, 0x06
    ld	a, 0x87
    ld	bc, 0xfaef
    out	(c),a

    ld	a, 0x83
    ld	bc, 0xfbef
    out	(c),a

    ld	a, 0x01
    ld	bc, 0xf8ef
    out	(c),a

    ld	a, 0x00
    ld	bc, 0xf9ef
    out	(c),a

    ld	a, 0x03
    ld	bc, 0xfbef
    out	(c),a

    ld	a, 0x00
    ld	bc, 0xf9ef
    out	(c),a

    ; ld	a, 0x2f
    ld	a, 0x0f
    ld bc, 0xfcef
    out	(c),a


    nop
    nop
    nop
    ; Z80 clock
    ld	a, 0x02
    ld	bc, system_port
    out	(c), a
    nop
    nop
    nop
    nop
    nop
    in	a, (c)
    nop
    nop
    nop
    nop
    nop


    ld e, 0
    ld a, 0x53; S
    ld	bc, 0xf8ef
    out	(c), a
    ld e, 0
    ld a, 0x0a
    ld	bc, 0xf8ef
    out	(c), a
    ld e, 0
    ld a, 0x0d
    ld	bc, 0xf8ef
    out	(c), a
    
main_loop:
    ld a, 0x55; U
    ld	bc, 0xf8ef
    out	(c), a

    ; ld a, 64
    ; ld bc, mem_window_3_port
    ; out (c), a
    ; ld (0xc001), 0x60
    ; ld a, (0xc001)
    ; ld	bc, 0xf8ef
    ; out	(c), a

    ld a, e
    ld bc, mem_window_1_port
    out (c), a
    ld hl, 0x4ff0
    ld (hl), 0x58 ; X
    ld a, (hl)
    ld	bc, 0xf8ef
    out	(c), a

    inc e

    ld	bc, 0x0ffe
delay:
    dec bc
    ld a, b
    or c
    jr nz, delay
    
    jr main_loop

end:
    ; Выводим размер банарника.
    display "code size: ", /d, end - begin
    SAVEBIN "./build/test.bin", begin, 16384;  размер бинарного файла для прошивки ПЗУ\ОЗУ