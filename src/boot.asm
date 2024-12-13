[org 0x7C00]
[bits 16]

; Constants
KERNEL_OFFSET equ 0x1000
VIDEO_MEMORY equ 0xA0000
VBE_INFO equ 0x9000        ; Location to store VBE info
MODE_INFO equ 0x9500       ; Location to store mode info
KERNEL_SECTORS equ 30      ; Number of sectors to read for kernel

start:
    ; Initialize segment registers
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x9000

    ; Save boot drive number
    mov [BOOT_DRIVE], dl

    ; Reset disk system
    mov ah, 0
    int 0x13
    jc disk_error

    ; Load kernel from disk
    mov bx, KERNEL_OFFSET      ; Destination address
    mov ah, 0x02              ; BIOS read sector function
    mov al, KERNEL_SECTORS    ; Number of sectors to read
    mov ch, 0                 ; Cylinder 0
    mov cl, 2                 ; Start from sector 2 (1-based)
    mov dh, 0                 ; Head 0
    mov dl, [BOOT_DRIVE]      ; Drive number
    int 0x13
    jc disk_error

    ; Get VESA information
    mov ax, 0x4F00
    mov di, VBE_INFO
    int 0x10
    cmp ax, 0x4F
    jne vbe_error

    ; Get mode info (Mode 0x101 = 640x480x256)
    mov ax, 0x4F01
    mov cx, 0x101
    mov di, MODE_INFO
    int 0x10
    cmp ax, 0x4F
    jne vbe_error

    ; Set VESA mode
    mov ax, 0x4F02
    mov bx, 0x101 | (1 << 14)    ; Set bit 14 to enable linear framebuffer
    int 0x10
    cmp ax, 0x4F
    jne vbe_error

    ; Switch to protected mode
    cli
    lgdt [gdt_descriptor]
    
    ; Enable A20 line
    in al, 0x92
    or al, 2
    out 0x92, al
    
    ; Switch to protected mode
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    
    jmp CODE_SEG:init_pm

disk_error:
    mov si, DISK_ERROR_MSG
    call print_string
    jmp $

vbe_error:
    mov si, VBE_ERROR_MSG
    call print_string
    jmp $

; Function to print string in real mode
print_string:
    pusha
    mov ah, 0x0E        ; BIOS teletype function
.loop:
    lodsb               ; Load next character
    test al, al         ; Check for null terminator
    jz .done
    int 0x10            ; Print character
    jmp .loop
.done:
    popa
    ret

[bits 32]
init_pm:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    mov ebp, 0x90000
    mov esp, ebp
    
    ; Jump to kernel
    jmp KERNEL_OFFSET

; Data
BOOT_DRIVE: db 0
DISK_ERROR_MSG: db "Disk read error!", 0
VBE_ERROR_MSG: db "VESA error!", 0

; Include GDT
%include "src/gdt.asm"
; %include "src/disk.asm"

; Padding and boot signature
times 510-($-$$) db 0
dw 0xAA55