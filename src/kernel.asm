[bits 32]
[org 0x1000]

section .data
test_message1 db "Welcome to MyOS!", 0
test_message2 db "String rendering test", 0
test_message3 db "Press any key to continue...", 0
disk_read_msg db "Reading messages from disk...", 0
disk_write_msg db "Writing messages to disk...", 0
disk_error_msg db "Disk operation failed!", 0
disk_success_msg db "Disk operation successful!", 0

; Constants for disk operations
MSG_MAX_LENGTH equ 32     ; Maximum length for each message
LINE_HEIGHT equ 10           ; Vertical spacing between lines
message_x_offset equ 380
section .bss
sector_buffer: resb 512    ; Must be full sector size (512 bytes)
; msg_buffer: resb MSG_MAX_LENGTH * MSG_COUNT  ; Buffer for reading messages
; msg_buffer: resb 512

section .text
_start:
    ; Initialize disk system
    call init_disk
    
    ; Clear screen before starting
    xor eax, eax
    xor ebx, ebx
    mov ecx, SCREEN_WIDTH
    mov edx, SCREEN_HEIGHT
    call clear_screen
    
    ; Read and display sector 0
    mov eax, 0              ; Sector 0
    call read_and_display_sector
    
    
main_loop:
    call handle_input
    call draw_pixel
    jmp main_loop

; Helper function to copy null-terminated string
; Input: ESI = source string, EDI = destination
copy_string:
    pusha
    mov ecx, MSG_MAX_LENGTH
.copy_loop:
    lodsb
    stosb
    test al, al
    jz .pad_remaining
    loop .copy_loop
    jmp .done
.pad_remaining:
    dec ecx
    jz .done
    xor al, al
    rep stosb
.done:
    popa
    ret

%include "src/utils.asm" 
%include "src/disk.asm"

; Add helper function for waiting for keypress
wait_for_key:
    pusha
.wait_loop:
    in al, KEYBOARD_STATUS
    test al, 0x01
    jz .wait_loop
    in al, KEYBOARD_DATA              ; Clear the keystroke
    popa
    ret

; Add delay function
delay:
    pusha
.loop:
    nop
    loop .loop
    popa
    ret
