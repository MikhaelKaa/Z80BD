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
    ld hl, cnt
    inc (hl)
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
    
    ld a, 0b00000000
    out (0xfe), a
    ld hl, file_dot_scr
    ld de, 0x4000
    ld bc, 0x1b00
    ldir
    ld bc, 65535
    call delay

    ; ld hl, font_rus
    ; ld de, 0x4000
    ; ld bc, 768
    ; ldir
    ; ld bc, 65535
    ; call delay

    ; ld a, 0b00000000
    ; ld hl, 0x4000-1
    ; ld (hl), a
    ; ld de, 0x4000
    ; ld bc, 0x1b00
    ; ldir

main_loop:
    ld bc, 10
    call delay

    ld a, 0xbf
    in a, (0xfe)
    bit 2, a
    call z, cash_on ; k key

    ld a, 0xbf
    in a, (0xfe)
    bit 1, a
    call z, cash_off ; l key

    ld a, 0b10000010
    ld hl, 0x4000
    ld (hl), a
    ld bc, 0x7ffd 
    out (c), a
    in a, (c)
    ld hl, 0x4000+32
    ld (hl), a

    ld bc, 100
    call delay

    ld a, 0b01000000
    ld hl, 0x4001
    ld (hl), a 
    ld bc, 0x7ffd 
    out (c), a   
    in a, (c)
    ld hl, 0x4001+32
    ld (hl), a
    ; ld hl, 0x4000
    ; ld de, 0x1b00-768
    ; ld a, (cnt)
    ; call fill_area

    ;halt
    jp main_loop

; HL - это начальный адрес области памяти,
; DE - количество байтов для заполнения,
; A - байт, которым мы заполняем область памяти.
fill_area:
    ld a, (cnt)
    ld (hl), a  ; Записываем байт в память по адресу, указанному в HL
    inc hl      ; Увеличиваем HL, чтобы перейти к следующему байту
    dec de      ; Уменьшаем счетчик DE
    ld a, d     ; Перемещаем старший байт DE в A
    or e        ; Логическое ИЛИ с младшим байтом DE
    jp nz, fill_area ; Если DE не равно 0, повторяем цикл
    ret

cash_on:
    in a, (0xfb) ; включить cash
    ret

cash_off:
    in a, (0x7b) ; выключить cash
    ret

cnt:
    db 0

file_dot_scr:
    incbin "Eva.scr"

font_rus:
    incbin "font_rus.ch8"

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