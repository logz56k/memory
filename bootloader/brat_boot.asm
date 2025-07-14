[BITS 16]
[ORG 0x7C00]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; switch to VGA mode 13h (320x200x256)
    mov ax, 0x0013
    int 0x10

    ; clear screen by filling video memory with zero
    mov ax, 0xA000
    mov es, ax
    xor di, di
    xor ax, ax
    mov cx, 32000
    rep stosw

    ; blink the title a few times
    mov byte [blink_count], 4
blink_loop:
    mov bl, 10
    call draw_title
    call delay
    mov bl, 0        ; draw in black to hide
    call draw_title
    call delay
    dec byte [blink_count]
    jnz blink_loop

    ; draw title one final time in green
    mov bl, 10
    call draw_title

    ; draw heart in hot pink
    call draw_heart

    ; wait for a key press
    xor ah, ah
    int 0x16

    ; return to text mode 03h
    mov ax, 0x0003
    int 0x10

    ; show exit message
    mov si, exit_msg
    mov bl, 0x0A
    call print_string

hang:
    jmp hang

; --- routines ---
; draw title string at row 4, centered
; BL = color
draw_title:
    push ax
    push bx
    push cx
    push dx
    push bp
    mov ax, cs
    mov es, ax
    mov bp, title_msg
    mov cx, title_len
    mov ax, 0x1301
    mov bh, 0
    mov dh, 4
    mov dl, 11
    int 0x10
    pop bp
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; simple delay loop
; crude wait using nested loops
; destroys cx
delay:
    mov cx, 0xFFFF
.delay1:
    nop
    loop .delay1
    ret

; draw a small 8x8 heart centered on the screen in color 13
; uses ES already set to 0xA000
; preserves registers except ax and di

heart_x equ 156
heart_y equ 96

draw_heart:
    push ax
    push bx
    push cx
    push dx
    push di
    mov ax, 0xA000
    mov es, ax
    mov ax, heart_y
    mov bx, 320
    mul bx             ; ax = heart_y*320
    add ax, heart_x
    mov di, ax
    mov si, heart
    mov bx, 8          ; 8 rows
row_loop:
    mov al, [si]
    inc si
    mov cx, 8
bit_loop:
    shl al, 1
    jnc skip_px
    mov byte [es:di], 13
skip_px:
    inc di
    loop bit_loop
    add di, 312        ; move to next row (320-8)
    dec bx
    jnz row_loop
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; print string at SI with color BL
print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0
    int 0x10
    jmp print_string
.done:
    ret

; --- data ---
blink_count db 0

title_msg db 'BRAT MODE \xF0\x9F\xA7\x83\xF0\x9F\x92\x9A',0
; length of the above string (12 visible chars plus emoji bytes)
title_len equ $-title_msg
exit_msg db 'okay fine, we back \xF0\x9F\x99\x84',13,10,0

heart db 0x00,0x66,0xFF,0xFF,0x7E,0x3C,0x18,0x00

    times 510-($-$$) db 0
    dw 0xAA55
