BITS 16
ORG 0x7c00

start:
    cli
    mov ax, 0xb800
    mov es, ax
    xor di, di
    mov ax, 0x0f00

; write characters
loop:
    mov [es:di], al
    inc ax
    add di, 2
    test al, al
    jz loop2
    jmp loop

; clear rest of screen--this isn't necessary, but why not?
loop2:
    mov WORD [es:di], 0x0f20
    add di, 2
    cmp di, 4000
    je done
    jmp loop2

done:
    hlt
    jmp done

TIMES 510-($-$$) db 0
dw 0xAA55