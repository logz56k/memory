; Brat OS Bootloader
; 16-bit real mode boot sector (NASM syntax)

BITS 16
ORG 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; set video mode 03h
    mov ax, 0x0003
    int 0x10

    ; print welcome message
    mov si, welcome_msg
    mov bl, 0x0A
    call print_string

prompt:
    mov si, prompt_msg
    mov bl, 0x0A
    call print_string

    ; read input
    mov di, buffer
read_loop:
    xor ax, ax
    int 0x16
    cmp al, 13
    je check_input
    mov ah,0x0E
    mov bh,0
    mov bl,0x0A
    int 0x10
    stosb
    jmp read_loop

check_input:
    mov byte [di],0
    mov si, buffer
    mov di, magic
    mov cx,6
    repe cmpsb
    jne wrong

correct:
    mov si, success_msg
    mov bl,0x0A
    call print_string
hang:
    jmp hang

wrong:
    mov si, fail_msg
    mov bl,0x0A
    call print_string
    jmp prompt

print_string:
    lodsb
    or al,al
    jz .done
    mov ah,0x0E
    mov bh,0
    int 0x10
    jmp print_string
.done:
    ret

welcome_msg db 0xF0,0x9F,0xA7,0x83," BRAT OS v0.0.1 ",0xF0,0x9F,0xA7,0x83,13,10
            db "u booted a baddie... congrats ",0xF0,0x9F,0x92,0x85,13,10,0
prompt_msg db "type 'vroom' to slay >",0
success_msg db "SKRRTT... now launching vibes ",0xF0,0x9F,0x9A,0x97,0xF0,0x9F,0x92,0xA8,13,10,0
fail_msg db "umm no ",0xF0,0x9F,0x92,0x9A," try again xoxo",13,10,0
magic db "vroom",0
buffer times 8 db 0

times 510-($-$$) db 0
DW 0xAA55
