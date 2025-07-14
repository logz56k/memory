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

    mov si, welcome_msg
    call print_str

shell_loop:
    mov si, prompt
    call print_str
    call read_line
    mov si, cmd_buf
    mov di, cry_cmd
    call str_cmp
    cmp al, 0
    je shell_end
    mov di, yeet_cmd
    call str_cmp
    cmp al, 0
    je do_yeet
    mov di, vroom_cmd
    call str_cmp
    cmp al, 0
    je do_vroom
    mov di, drama_cmd
    call str_cmp
    cmp al, 0
    je do_drama
    mov di, charli_cmd
    call str_cmp
    cmp al, 0
    je do_charli
    mov si, unk_msg
    call print_str
    jmp shell_loop

do_yeet:
    mov si, yeet_msg
    call print_str
    jmp shell_loop

do_vroom:
    call rave
    jmp shell_loop

do_drama:
    mov si, drama_msg
    call print_str
    jmp shell_loop

do_charli:
    mov si, charli_msg
    call print_str
    jmp shell_loop

shell_end:
    mov si, bye_msg
    call print_str
hang:
    jmp hang

; --- routines ---
print_str:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x0A
    int 0x10
    jmp print_str
.done:
    ret

read_line:
    mov di, cmd_buf
    mov cx, 0
.rl1:
    xor ah, ah
    int 0x16
    cmp al, 13
    je .end
    cmp cx, 39
    jae .echo
    mov [di], al
    inc di
    inc cx
.echo:
    mov ah,0x0E
    mov bh,0
    mov bl,0x0A
    int 0x10
    jmp .rl1
.end:
    mov byte [di],0
    mov ah,0x0E
    mov al,13
    int 0x10
    mov al,10
    int 0x10
    ret

str_cmp:
    push si
    push di
.sc1:
    mov al,[si]
    mov bl,[di]
    cmp al,bl
    jne .no
    or al,al
    jz .eq
    inc si
    inc di
    jmp .sc1
.eq:
    mov al,0
    jmp .out
.no:
    mov al,1
.out:
    pop di
    pop si
    ret

rave:
    mov cx,5
.rv1:
    mov ax,0x0600
    mov bh,0x1F
    mov cx,0
    mov dx,0x184F
    int 0x10
    call delay
    mov ax,0x0600
    mov bh,0x4E
    mov cx,0
    mov dx,0x184F
    int 0x10
    call delay
    loop .rv1
    ret

delay:
    mov cx,0xFFFF
.dl1:
    loop .dl1
    ret

; --- data ---
prompt db 'XCXSH >',0
welcome_msg db 'XCX shell ready',13,10,0
yeet_cmd db 'yeet',0
vroom_cmd db 'vroom',0
drama_cmd db 'drama',0
charli_cmd db 'charli',0
cry_cmd db 'cry',0
yeet_msg db 'file yeeted \xF0\x9F\x92\x85',13,10,0
drama_msg db 'so dramatic \xF0\x9F\x98\xA2',13,10,0
charli_msg db 'lets ride... vroom vroom',13,10,0
unk_msg db "I don't speak flop. Try again.",13,10,0
bye_msg db 'bye',13,10,0
cmd_buf times 40 db 0

    times 510-($-$$) db 0
    dw 0xAA55
