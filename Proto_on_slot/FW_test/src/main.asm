    device ZXSPECTRUM48

begin:

mem_window_0_port EQU 0x0010
mem_window_1_port EQU 0x0011
mem_window_2_port EQU 0x0012
mem_window_3_port EQU 0x0014
system_port       EQU 0x0020
uart_16550_port   EQU 0x00ef

; MACRO DELAY time
;     ld bc, time
; delay
;     dec bc
;     ld a, b
;     or c
;     jr nz, delay
; ENDM

    org 0x0000
    ; Запрещаем прерывания.
    di

    jp start

    org 0x0038 ; 56 
    di
    push af
    push bc
    push hl
    push de
    ;int programm
    
    ;end int programm
    pop de
    pop hl
    pop bc
    pop af
    ei
    reti

    org 0x100
start:
    
    ; Устанавливаем дно стека.
    ld sp, 0xffff 
    ld e, 0
main_loop:

    ld a, e
    ld bc, mem_window_1_port
    out (c), a

    ld (0x4000), a
    inc e

    ld bc, 10
delay:
    dec bc
    ld a, b
    or c
    jr nz, delay

    jp main_loop


; Процедура задержки
; bc - время
; delay:
;     dec bc
;     ld a, b
;     or c
;     jr nz, delay
;     ret

end:
    ; Выводим размер банарника.
    display "code size: ", /d, end - begin
    SAVEBIN "./build/test.bin", begin, 16384;  размер бинарного файла для прошивки ПЗУ\ОЗУ