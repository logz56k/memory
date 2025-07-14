; Brat OS Shell Bootloader
; 16-bit real mode boot sector with simple command parser

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

    ; video mode 03h, text mode
    mov ax, 0x0003
    int 0x10

    ; display welcome text in bright green
    mov si, welcome_msg
    mov bl, 0x0A
    call print_string

shell:
    mov si, prompt_msg
    mov bl, 0x0A
    call print_string
    call read_line
    call parse_cmd
    jmp shell

; read line into buffer (max 31 chars)
read_line:
    mov di, buffer
    mov cx, 31
.rl:
    xor ax, ax
    int 0x16
    cmp al, 13
    je .done
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x0A
    int 0x10
    stosb
    loop .rl
.done:
    mov byte [di], 0
    ret

; parse commands in buffer
parse_cmd:
    mov si, buffer
    mov di, cmd_whoami
    call str_eq
    jc .whoami
    mov si, buffer
    mov di, cmd_leak
    call str_eq
    jc .leak
    mov si, buffer
    mov di, cmd_mom
    call str_eq
    jc .mom
    mov si, buffer
    mov di, cmd_yeet
    call str_pref
    jc .yeet
    mov si, unknown_msg
    jmp .print
.whoami:
    mov si, whoami_msg
    jmp .print
.leak:
    mov si, leak_msg
    jmp .print
.mom:
    mov si, mom_msg
    jmp .print
.yeet:
    mov si, yeet_msg
.print:
    mov bl, 0x0A
    call print_string
    ret

; check equality of strings at [si] and [di]
str_eq:
    push si
    push di
.eq_loop:
    lodsb
    scasb
    jne .no
    test al, al
    jnz .eq_loop
    cmp byte [si], 0
    jne .no
    stc
    jmp .done
.no:
    clc
.done:
    pop di
    pop si
    ret

; check if [si] starts with string at [di]
str_pref:
    push si
    push di
.pr_loop:
    lodsb
    scasb
    jne .no_pref
    test al, al
    jz .yes_pref
    jmp .pr_loop
.yes_pref:
    stc
    jmp .pr_ret
.no_pref:
    clc
.pr_ret:
    pop di
    pop si
    ret

; print string at SI in color BL
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

; ---- data ----
welcome_msg db 0xF0,0x9F,0xA7,0x83,' BRAT OS v0.0.1 ',0xF0,0x9F,0xA7,0x83,13,10
            db 'u booted a baddie... congrats ',0xF0,0x9F,0x92,0x85,13,10,0
prompt_msg db 'brat> ',0
whoami_msg db 'ur fave brat ',0xF0,0x9F,0x98,0x98,13,10,0
yeet_msg   db 'file yeeted ',0xF0,0x9F,0x92,0x85,13,10,0
leak_msg   db 'leaking... ur secrets: ',0xF0,0x9F,0x92,0x96,' crush.txt, ',0xF0,0x9F,0x8D,0x95,' pizza_habits.csv',13,10,0
mom_msg    db "Admin mode unlocked. Don't abuse it ",0xF0,0x9F,0x99,0x84,13,10,0
unknown_msg db "I don't speak flop. Try again.",13,10,0
cmd_whoami db 'whoami',0
cmd_yeet   db 'yeet',0
cmd_leak   db 'leak',0
cmd_mom    db 'momplease',0
buffer     times 32 db 0

    times 510-($-$$) db 0
    dw 0xAA55
