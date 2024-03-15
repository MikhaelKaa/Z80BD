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
    ; ld a, 0b00000111
    ; out (0xfe), a
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
    ld sp, 0xffff ; 
    ei
    
    ld a, 0b00000111
    out (0xfe), a
    ld hl, file_dot_scr
    ld de, 0x4000
    ld bc, 0x1b00
    ldir


main_loop:
    ld bc, 1024
    call delay
    in a, (0xfb)
    ld bc, 1024
    call delay
    in a, (0x7b)
    ;halt
    jp main_loop


file_dot_scr:
    ; incbin "sleep.scr"
    incbin "Eva.scr"

; Процедура задержки
; bc - время
delay:
    dec bc
    ld a, b
    or c
    jr nz, delay
    ret

cls:
    xor a
    out (0xfe), a
    ld hl, 0x4000
    ld de, 0x4001
    ld bc, 0x1aff
    ld (hl), a
    ldir
    ret

border:
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
    ret
    
;     org 16384
; load_scr:
;     incbin "sleep.scr"


end:
    ; Выводим размер банарника.
    display "code size: ", /d, end - begin
    SAVEBIN "out.bin", begin, 16384;  размер бинарного файла для прошивки ПЗУ\ОЗУ