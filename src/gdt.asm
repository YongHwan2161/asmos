; Global Descriptor Table
gdt_start:
    ; Null descriptor (required)
    dq 0x0

; Code segment descriptor
gdt_code:
    dw 0xFFFF    ; Limit (0-15)
    dw 0x0       ; Base (0-15)
    db 0x0       ; Base (16-23)
    db 10011010b ; Access (present, ring 0, code segment, executable, direction 0, readable)
    db 11001111b ; Flags (4kb blocks, 32-bit protected mode) + Limit (16-19)
    db 0x0       ; Base (24-31)

; Data segment descriptor
gdt_data:
    dw 0xFFFF    ; Limit (0-15)
    dw 0x0       ; Base (0-15)
    db 0x0       ; Base (16-23)
    db 10010010b ; Access (present, ring 0, data segment, executable, direction 0, writable)
    db 11001111b ; Flags (4kb blocks, 32-bit protected mode) + Limit (16-19)
    db 0x0       ; Base (24-31)

gdt_end:

; GDT descriptor
gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; Size (16 bit)
    dd gdt_start                ; Address (32 bit)

; Segment descriptor offsets
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start 