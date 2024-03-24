    ; указываем ассемблеру, что целевая платформа - spectrum48, хотя это и не так, но похуй...
    device ZXSPECTRUM48
    ;SIZE 32768
begin:
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
    ld a, 0b00000000
    out (0xfe), a
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
    ld sp, 16383 
    ei

    call cls
    call green_paper
    ld hl, msg_test
    ld de, 0x0209
    call print_string

main_loop:

    ld bc, 1200
    call delay

    ld a, 0b00000111
    out (0xfe), a
    halt
    jp main_loop


cash_on:
    in a, (0xfb) ; включить cash
    ret

cash_off:
    in a, (0x7b) ; выключить cash
    ret

msg_test:
    db "test", 0


; Процедура задержки
; bc - время
delay:
    dec bc
    ld a, b
    or c
    jr nz, delay
    ret

    include "src/print.asm"

end:
    ; Выводим размер банарника.
    display "code size: ", /d, end - begin
    SAVEBIN "build/out.bin", begin, 16384;  размер бинарного файла для прошивки ПЗУ\ОЗУ