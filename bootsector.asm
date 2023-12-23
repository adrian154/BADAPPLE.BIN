BITS 16
ORG 0x7c00

start:

    ; Set up a stack right below the bootsector
    cli
    xor ax, ax
    mov ss, ax 
    mov ds, ax
    mov sp, 0x7bff
    
    ; Make sure that we're in textmode
    xor ah, ah   ; INT 0x10 AH=0x00: set video mode 
    mov al, 0x03 ; AL = desired video mode (mode 3 is textmode)
    int 0x10

    ; Set ES so that we can access the textmode framebuffer
    mov ax, 0xb800
    mov es, ax

    ; set PIT divisor
    mov al, 0x36
    out 0x43, al
    mov al, 0x5d
    out 0x40, al
    mov al, 0x9b
    out 0x40, al

    ; install interrupt handler
    mov WORD [0x22], 0x0000
    mov WORD [0x20], int_handler
    sti

loop:
    hlt
    jmp loop

int_handler:

    inc ecx

    ; load the video
    mov ah, 0x42 ; INT 0x13 AH=0x42: read sectors from disk
    mov si, DAP
    int 0x13

    ; blit
    xor di, di
    mov si, 0x8000
.blit_loop:
    mov eax, DWORD [si]
    mov [es:di], eax
    add di, 4
    add si, 4
    cmp di, 4000
    je .blit_done
    jmp .blit_loop

.blit_done:
    mov eax, DWORD [DAP.start_seg]
    add eax, 8
    mov DWORD [DAP.start_seg], eax
    mov al, 0x20
    out 0x20, al
    iret

DAP:
    db 0x10 ; size
    db 0x00 ; zero field
    dw 0x8  ; sectors
    dw 0x8000 ; dst offset
    dw 0x0000 ; dst segment
    .start_seg dd 1    ; start segment
    dd 0

TIMES 448-($-$$) db 0

; fake MBR
db 0x02,0x00,0xee,0xff,0xff,0xff,0x01,0x00,0x00,0x00,0xff,0x7f

TIMES 510-($-$$) db 0
dw 0xAA55