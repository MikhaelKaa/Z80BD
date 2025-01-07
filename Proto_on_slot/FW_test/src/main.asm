    device ZXSPECTRUM48

begin:

mem_window_0_port EQU 0x0010
mem_window_1_port EQU 0x0011
mem_window_2_port EQU 0x0012
mem_window_3_port EQU 0x0014
system_port       EQU 0x0020
uart_16550_port   EQU 0x00ef

    org 0x0000
    ; Запрещаем прерывания.
    di

    org 0x0000
    ; Запрещаем прерывания.
    di
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    ld	a, 0x0d
    ld	bc, 0xfcef
    out	(c),a

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

    ld	a, 0x2f
    ld bc, 0xfcef
    out	(c),a
    
main_loop:

    ld a, e
    ld bc, mem_window_1_port
    out (c), a

    ld (0x4000), a
    inc e

    ld a, e
    ld	bc, 0xf8ef
	out	(c), a

    ld	bc, 0x2ffe
delay:
    dec bc
    ld a, b
    or c
    jr nz, delay
    
    jp main_loop

end:
    ; Выводим размер банарника.
    display "code size: ", /d, end - begin
    SAVEBIN "./build/test.bin", begin, 16384;  размер бинарного файла для прошивки ПЗУ\ОЗУ