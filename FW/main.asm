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
    ; push af
    ; push bc
    ; push hl
    ; push de
    ;int programm

    ; end int programm
    ; pop de
    ; pop hl
    ; pop bc
    ; pop af
    ;ei
    reti

    org 0x0100
start:
    
    ; Устанавливаем дно стека.
    ld sp, 0x1000 ; 

    ; Разрешаем прерывания.
    ;ei   
    ;jr skip 

    xor a
    out (0xfe), a
    ld hl, 0x4000
    ld de, 0x4001
    ld bc, 0x1aff
    ld (hl), a
    ldir

    ld a, 0b00000100
    ld (0x5800), a
    ld (0x5801), a
    ld (0x5802), a
    ld (0x5803), a
    ld (0x5804), a
    ld (0x5805), a
    

    ld a, 0x55
    ld (16384), a
    ld a, 0x55
    ld (16385), a
    ld a, 0xff
    ld (16386), a
    ld a, 0x00
    ld (16387), a
    ld a, 0x55
    ld (16388), a

main_loop:

    ld a, 0b00000000
    out (0xfe), a
    ld a, 0b00000001
    out (0xfe), a
    ld a, 0b00000010
    out (0xfe), a
    ld a, 0b00000011
    out (0xfe), a
    ld a, 0b00000100
    out (0xfe), a
    ld a, 0b00000101
    out (0xfe), a
    ld a, 0b00000110
    out (0xfe), a
    ld a, 0b00000111
    out (0xfe), a
    jp main_loop

; Процедура задержки
; bc - время
delay:
    dec bc
    ld a, b
    or c
    jr nz, delay
    ret

end:
    ; Выводим размер банарника.
    display "code size: ", /d, end - begin
    SAVEBIN "out.bin", begin, 32768; 32768 - размер бинарного файла для прошивки ПЗУ\ОЗУ