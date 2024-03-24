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
    ld hl, msg_7ffd
    ld de, 0x0000
    call print_string

main_loop:
    ld a, 0b0000001
    ld bc, 0x7ffd
    out (c), a

    ld bc, 10
    call delay

    ld bc, 0x7ffd
    in a, (c)

    ld hl, temp
    ld (hl), a

    cp a, 0b0000001
    call z, print_ok
    ld hl, temp
    ld a, (hl)
    cp a, 0b0000001
    call nz, print_fail

    ld bc, 1200
    call delay

    ld a, 0b0000000
    ld bc, 0x7ffd
    out (c), a

    ld bc, 10
    call delay

    ld bc, 0x7ffd
    in a, (c)

    ld hl, temp
    ld (hl), a

    cp a, 0b0000000
    call z, print_ok
    ld hl, temp
    ld a, (hl)
    cp a, 0b0000000
    call nz, print_fail

    ld a, 0b00000111
    out (0xfe), a
    halt
    jp main_loop


print_ok:
    ld hl, msg_ok
    ld de, 0x0008
    call print_string
    ret

print_fail:
    ld hl, msg_fail
    ld de, 0x0008
    call print_string
    ret

cash_on:
    in a, (0xfb) ; включить cash
    ret

cash_off:
    in a, (0x7b) ; выключить cash
    ret

temp:
    db 0
msg_7ffd
    db "0x7ffd: ", 0
msg_ok:
    db "OK  ", 0
msg_fail:
    db "FAIL", 0
    display "msg_ok adr: ", /h, msg_ok
    

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