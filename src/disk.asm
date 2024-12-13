; Disk I/O functionality
[bits 32]

; Constants
SECTOR_SIZE equ 512
MAX_RETRIES equ 3

; Disk controller ports
ATA_DATA        equ 0x1F0
ATA_FEATURES    equ 0x1F1
ATA_SECTOR_CNT  equ 0x1F2
ATA_LBA_LOW     equ 0x1F3
ATA_LBA_MID     equ 0x1F4
ATA_LBA_HIGH    equ 0x1F5
ATA_DRIVE_HEAD  equ 0x1F6
ATA_STATUS      equ 0x1F7
ATA_COMMAND     equ 0x1F7

; ATA commands
CMD_READ_SECTORS  equ 0x20
CMD_WRITE_SECTORS equ 0x30

section .data
disk_buffer: times SECTOR_SIZE db 0

section .text
global read_sector
global write_sector
global init_disk

; Initialize disk controller
init_disk:
    pusha
    ; Wait for disk to be ready
    call wait_disk
    ; Reset disk controller
    mov dx, ATA_DRIVE_HEAD
    mov al, 0xE0        ; LBA mode, master drive
    out dx, al
    ; Wait again after reset
    call wait_disk
    popa
    ret

; Read a sector from disk
; Input: EAX = LBA address
;        EDI = destination buffer
read_sector:
    pusha
    mov ebx, eax        ; Save LBA
    mov ecx, MAX_RETRIES
    
.retry:
    push ecx
    call wait_disk
    
    ; Send disk command
    mov dx, ATA_DRIVE_HEAD
    mov al, 0xE0        ; LBA mode, master drive
    out dx, al
    
    mov dx, ATA_SECTOR_CNT
    mov al, 1           ; Read one sector
    out dx, al
    
    ; Send LBA address
    mov eax, ebx
    mov dx, ATA_LBA_LOW
    out dx, al
    shr eax, 8
    mov dx, ATA_LBA_MID
    out dx, al
    shr eax, 8
    mov dx, ATA_LBA_HIGH
    out dx, al
    
    ; Send read command
    mov dx, ATA_COMMAND
    mov al, CMD_READ_SECTORS
    out dx, al
    
    ; Wait until drive is ready with data
.wait_drq:
    mov dx, ATA_STATUS
    in al, dx
    test al, 0x80       ; Test BSY bit
    jnz .wait_drq       ; If busy, keep waiting
    test al, 0x08       ; Test DRQ bit
    jz .wait_drq        ; If not ready with data, keep waiting
    test al, 0x01       ; Test ERR bit
    jnz .error          ; If error, handle it
    
    ; Read data
    mov ecx, 256        ; 256 words = 512 bytes
    mov dx, ATA_DATA
    rep insw            ; Read words from port to [EDI]
    
    ; Verify read completion
    mov dx, ATA_STATUS
    in al, dx
    test al, 0x01       ; Test ERR bit
    jnz .error
    
    pop ecx
    clc                 ; Clear carry flag to indicate success
    jmp .exit
    
.error:
    pop ecx
    dec ecx
    jnz .retry          ; Retry if attempts remain
    stc                 ; Set carry flag to indicate error
    
.exit:
    popa
    ret

; Write a sector to disk
; Input: EAX = LBA address
;        ESI = source buffer
write_sector:
    pusha
    mov ebx, eax        ; Save LBA
    mov ecx, MAX_RETRIES
    
.retry:
    push ecx
    call wait_disk
    
    ; Send disk command
    mov dx, ATA_DRIVE_HEAD
    mov al, 0xE0        ; LBA mode, master drive
    out dx, al
    
    mov dx, ATA_SECTOR_CNT
    mov al, 1           ; Write one sector
    out dx, al
    
    ; Send LBA address
    mov eax, ebx
    mov dx, ATA_LBA_LOW
    out dx, al
    shr eax, 8
    mov dx, ATA_LBA_MID
    out dx, al
    shr eax, 8
    mov dx, ATA_LBA_HIGH
    out dx, al
    
    ; Send write command
    mov dx, ATA_COMMAND
    mov al, CMD_WRITE_SECTORS
    out dx, al
    
    ; Wait until drive is ready to accept data
.wait_drq:
    mov dx, ATA_STATUS
    in al, dx
    test al, 0x80       ; Test BSY bit
    jnz .wait_drq       ; If busy, keep waiting
    test al, 0x08       ; Test DRQ bit
    jz .wait_drq        ; If not ready for data, keep waiting
    test al, 0x01       ; Test ERR bit
    jnz .error          ; If error, handle it
    
    ; Write data
    mov dx, ATA_DATA
    mov ecx, 256        ; 256 words = 512 bytes
.write_loop:
    lodsw               ; Load word from [ESI] to AX
    out dx, ax          ; Write word to port
    loop .write_loop
    
    ; Wait for write to complete and verify
    call wait_disk
    mov dx, ATA_STATUS
    in al, dx
    test al, 0x01       ; Test ERR bit
    jnz .error
    
    pop ecx
    clc                 ; Clear carry flag to indicate success
    jmp .exit
    
.error:
    pop ecx
    dec ecx
    jnz .retry          ; Retry if attempts remain
    stc                 ; Set carry flag to indicate error
    
.exit:
    popa
    ret

; Wait for disk to be ready
; Sets carry flag if error
wait_disk:
    push ecx
    mov ecx, 10000     ; Timeout counter
    
.wait:
    mov dx, ATA_STATUS
    in al, dx
    test al, 0x80      ; Check BSY bit
    jz .not_busy
    loop .wait
    stc                ; Timeout - set carry flag
    jmp .done
    
.not_busy:
    test al, 0x08      ; Check DRQ bit
    jnz .ready
    test al, 0x01      ; Check ERR bit
    jnz .error
    loop .wait
    stc                ; Timeout - set carry flag
    jmp .done
    
.error:
    stc                ; Error - set carry flag
    jmp .done
    
.ready:
    clc                ; Success - clear carry flag
    
.done:
    pop ecx
    ret 