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
    ;ld sp, 16383 ;
    ld sp, 0xffff ; 
    ei
    ;di

    ; ld a, 0b00000000
    ; out (0xfe), a
    ; ld hl, file_dot_scr
    ; ld de, 0x4000
    ; ld bc, 0x1b00
    ; ldir
    ; ld bc, 65535
    ; call delay
    ; call cls


    ld a, 0b00000000
    out (0xfe), a

    ld hl, Eva0
    ld de, 0x4000
    ld bc, 0x1800-1
    ldir

    ld bc, 65535
    call delay

    ld a, 0b00001111
    ld bc, 0x7ffd 
    out (c), a

    ld hl, Eva1
    ld de, 0xC000
    ld bc, 0x1b00
    ldir

    ld bc, 65535
    call delay

main_loop:
    ld a, 0b00000111
    out (0xfe), a

    ld bc, 1000
    call delay

    ld a, 0b00000001
    out (0xfe), a

    ld bc, 942
    call delay

    ld a, 0b00000010
    out (0xfe), a

    ld bc, 420
    call delay

    ; ld a, 0b00000000
    ; out (0xfe), a

    ld hl, cnt
    ld a, (hl)
    xor 0b00001000
    ld (hl), a
    ld bc, 0x7ffd 
    out (c), a 

    halt
    jp main_loop

; Печатает нуль терминированную строку
; hl - адрес строки.
; de - адрес в экранной области.
; print_string:
;     ld a, (hl)
;     and a
;     ret z
;     push hl
;     ld h, 0
;     ld l, a
;     add hl, hl
;     add hl, hl
;     add hl, hl
;     ld bc, font-8*32 ; -8*32 это пропуск первых непечатных символов ascii 
;     add hl, bc
;     push de
;     call print_char
;     pop de
;     pop hl
;     inc hl
;     inc de
;     jp print_string
;     ret

; Печать символа.
; hl адрес символа в шрифте.
; de адрес на экране.
; print_char:
;     ld b, 8
; pchar_loop:
;     ld a, (hl)
;     ld (de), a
;     inc d
;     inc hl
;     djnz pchar_loop
;     ret

; HL - это начальный адрес области памяти,
; DE - количество байтов для заполнения,
; A - байт, которым мы заполняем область памяти.
; fill_area:
;     ;ld a, (cnt)
;     ld (hl), a  ; Записываем байт в память по адресу, указанному в HL
;     inc hl      ; Увеличиваем HL, чтобы перейти к следующему байту
;     dec de      ; Уменьшаем счетчик DE
;     ld a, d     ; Перемещаем старший байт DE в A
;     or e        ; Логическое ИЛИ с младшим байтом DE
;     jp nz, fill_area ; Если DE не равно 0, повторяем цикл
;     ret

cash_on:
    in a, (0xfb) ; включить cash
    ret

cash_off:
    in a, (0x7b) ; выключить cash
    ret

; cnt:
;     db 0

; msg_hello_world:
;     db "Hello world!!!", 0
; msg_sthanks:
;     db "Special thanks to JecasNameless!", 0

; file_dot_scr:
;     incbin "Eva.scr"

Eva0:
    incbin "Eva0.scr"
Eva1:
    incbin "Eva1.scr"

font:
    incbin "font_en.ch8"
    incbin "font_rus.ch8"
font_rus_end:

; Процедура задержки
; bc - время
delay:
    dec bc
    ld a, b
    or c
    jr nz, delay
    ret

; cls:
;     xor a
;     out (0xfe), a
;     ld hl, 0x4000
;     ld de, 0x4001
;     ;ld bc, 0x1aff
;     ld bc, 2048*3-1
;     ld (hl), a
;     ldir
;     ret

; border:
;     ld a, 0b00000000
;     out (0xfe), a
;     ld a, 0b00000001
;     out (0xfe), a
;     ld a, 0b00000010
;     out (0xfe), a
;     ld a, 0b00000011
;     out (0xfe), a
;     ld a, 0b00000100
;     out (0xfe), a
;     ld a, 0b00000101
;     out (0xfe), a
;     ld a, 0b00000110
;     out (0xfe), a
;     ld a, 0b00000111
;     out (0xfe), a
;     ret
    
;     org 16384
; load_scr:
;     incbin "sleep.scr"


end:
    ; Выводим размер банарника.
    display "code size: ", /d, end - begin
    SAVEBIN "out.bin", begin, 16384;  размер бинарного файла для прошивки ПЗУ\ОЗУ