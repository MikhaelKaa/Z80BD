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
main_loop:

    ld a, e
    ld bc, mem_window_1_port
    out (c), a

    ld (0x4000), a
    inc e
    jp main_loop

end:
    ; Выводим размер банарника.
    display "code size: ", /d, end - begin
    SAVEBIN "./build/test.bin", begin, 16384;  размер бинарного файла для прошивки ПЗУ\ОЗУ