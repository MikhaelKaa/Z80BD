; Печатает нуль терминированную строку
; hl - адрес строки ascii.
; de - адрес в знакоместах. d - X, e - Y.
print_string:
    call get_adr_on_screen
print_string_loop:
    ld a, (hl)
    and a
    ret z
    push hl
    ld h, 0
    ld l, a
    add hl, hl
    add hl, hl
    add hl, hl
    ld bc, font-8*32 ; -8*32 это пропуск первых непечатных символов ascii 
    add hl, bc
    push de
    call print_char
    pop de
    pop hl
    inc hl
    inc de
    jp print_string_loop
    ret

; Печать символа.
; hl адрес символа в шрифте.
; de адрес на экране.
print_char:
    ld b, 8
pchar_loop:
    ld a, (hl)
    ld (de), a
    inc d
    inc hl
    djnz pchar_loop
    ret

; d - позиция X
; e - позиция Y
; Возвращает адрес на экране в de
get_adr_on_screen:       
    ld a,d
    and 0b00000111
    rra
    rra
    rra
    rra
    or e
    ld e,a
    ld a,d
    and 0b00011000
    or 0b01000000
    ld d,a
    ret 

cls:
    xor a
    ld hl, 0x4000 ;начало экрана
    ld de, 0x4001
    ld bc, (256/8)*192+768 ;экранн+атрибуты
    ld (hl), a
    ldir
    ret

green_paper:
    ld a, 0b00000100
    ld hl, 0x4000 + (256/8)*192
    ld de, 0x4001 + (256/8)*192
    ld bc, 768 
    ld (hl), a
    ldir
    ret

font:
    incbin "font_en.ch8"
    incbin "font_rus.ch8"