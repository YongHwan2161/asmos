; Common utilities and functions for MyOS
[bits 32]
hex_digits: db "0123456789ABCDEF"

; Constants
VGA_MEMORY equ 0xFD000000   ; VESA linear framebuffer address for mode 0x101
SCREEN_WIDTH equ 640
SCREEN_HEIGHT equ 480
KEYBOARD_DATA    equ 0x60
KEYBOARD_STATUS  equ 0x64

; Keyboard scan codes
KEY_ESC          equ 0x01
KEY_1            equ 0x02
KEY_2            equ 0x03
KEY_3            equ 0x04
KEY_4            equ 0x05
KEY_5            equ 0x06
KEY_6            equ 0x07
KEY_7            equ 0x08
KEY_8            equ 0x09
KEY_9            equ 0x0A
KEY_0            equ 0x0B
KEY_MINUS        equ 0x0C
KEY_EQUALS       equ 0x0D
KEY_BACKSPACE    equ 0x0E
KEY_TAB          equ 0x0F
KEY_Q            equ 0x10
KEY_W            equ 0x11
KEY_E            equ 0x12
KEY_R            equ 0x13
KEY_T            equ 0x14
KEY_Y            equ 0x15
KEY_U            equ 0x16
KEY_I            equ 0x17
KEY_O            equ 0x18
KEY_P            equ 0x19
KEY_LBRACKET     equ 0x1A
KEY_RBRACKET     equ 0x1B
KEY_ENTER        equ 0x1C
KEY_LCTRL        equ 0x1D
KEY_A            equ 0x1E
KEY_S            equ 0x1F
KEY_D            equ 0x20
KEY_F            equ 0x21
KEY_G            equ 0x22
KEY_H            equ 0x23
KEY_J            equ 0x24
KEY_K            equ 0x25
KEY_L            equ 0x26
KEY_SEMICOLON    equ 0x27
KEY_QUOTE        equ 0x28
KEY_BACKTICK     equ 0x29
KEY_LSHIFT_PRESSED       equ 0x2A
KEY_BACKSLASH    equ 0x2B
KEY_Z            equ 0x2C
KEY_X            equ 0x2D
KEY_C            equ 0x2E
KEY_V            equ 0x2F
KEY_B            equ 0x30
KEY_N            equ 0x31
KEY_M            equ 0x32
KEY_COMMA        equ 0x33
KEY_DOT          equ 0x34
KEY_SLASH        equ 0x35
KEY_RSHIFT_PRESSED       equ 0x36
KEY_KP_ASTERISK  equ 0x37
KEY_LALT         equ 0x38
KEY_SPACE        equ 0x39
KEY_CAPSLOCK     equ 0x3A
KEY_F1           equ 0x3B
KEY_F2           equ 0x3C
KEY_F3           equ 0x3D
KEY_F4           equ 0x3E
KEY_F5           equ 0x3F
KEY_F6           equ 0x40
KEY_F7           equ 0x41
KEY_F8           equ 0x42
KEY_F9           equ 0x43
KEY_F10          equ 0x44
KEY_NUMLOCK      equ 0x45
KEY_SCROLLLOCK   equ 0x46
KEY_KP_7         equ 0x47
KEY_UP           equ 0x48  ; Was KEY_UP_PRESSED
KEY_KP_9         equ 0x49
KEY_KP_MINUS     equ 0x4A
KEY_LEFT         equ 0x4B  ; Was KEY_LEFT_PRESSED
KEY_KP_5         equ 0x4C
KEY_RIGHT        equ 0x4D  ; Was KEY_RIGHT_PRESSED
KEY_KP_PLUS      equ 0x4E
KEY_KP_1         equ 0x4F
KEY_DOWN         equ 0x50  ; Was KEY_DOWN_PRESSED
KEY_KP_3         equ 0x51
KEY_KP_0         equ 0x52
KEY_KP_DOT       equ 0x53
KEY_F11          equ 0x57
KEY_F12          equ 0x58
KEY_RALT         equ 0x59
KEY_PRINTSCREEN  equ 0x5A
KEY_PAUSE        equ 0x5B
KEY_INSERT       equ 0x5C
KEY_HOME         equ 0x5D
KEY_PAGEUP       equ 0x5E
KEY_PAGEDOWN     equ 0x5F

KEY_LSHIFT_RELEASED   equ 0xAA
KEY_RSHIFT_RELEASED   equ 0xB6  ; Adding right shift release code


; Add new constant for coordinate display area
COORD_DISPLAY_WIDTH equ 56    ; Width needed for both X and Y coordinates (7*8 pixels)
COORD_DISPLAY_HEIGHT equ 7    ; Height of the number display

; Add new constant for coordinate display background color
COORD_BG_COLOR equ 0x08    ; Dark gray background

; Add constants for fade effect
FADE_STEPS equ 16
FADE_DELAY equ 1000

; Add these constants at the top of the file with other constants
LINE_HEIGHT      equ 10        ; Height between lines in pixels
BYTES_PER_LINE   equ 16        ; Number of bytes displayed per line

section .data
pixel_x dd 160           ; Initial X position (center)
pixel_y dd 100           ; Initial Y position (center)
current_color db 0x0F    ; White color
text_x dd 10    ; Initial X position for text
text_y dd 10    ; Initial Y position for text
; Add shift state variable
shift_pressed db 0
msg_buffer: resb 512
ASCII_patterns:
    ; ASCII patterns (5x7 pixels each)
    ; 0x00-0x07
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; NUL
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; SOH
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; STX
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; ETX
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; EOT
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; ENQ
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; ACK
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; BEL

    ; 0x08-0x0F
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; BS
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; TAB
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; LF
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; VT
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; FF
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; CR
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; SO
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; SI

    ; 0x10-0x17
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; DLE
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; DC1
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; DC2
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; DC3
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; DC4
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; NAK
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; SYN
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; ETB

    ; 0x18-0x1F
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; CAN
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; EM
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; SUB
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; ESC
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; FS
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; GS
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; RS
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0  ; US

    ; Space (32) 0x20
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0
    ; ! (33)
    db 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,0,0,0, 0,0,1,0,0
    ; " (34)
    db 0,1,0,1,0, 0,1,0,1,0, 0,1,0,1,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0
    ; # (35)
    db 0,1,0,1,0, 0,1,0,1,0, 1,1,1,1,1, 0,1,0,1,0, 1,1,1,1,1, 0,1,0,1,0, 0,1,0,1,0
    ; $ (36)
    db 0,0,1,0,0, 0,1,1,1,1, 1,0,1,0,0, 0,1,1,1,0, 0,0,1,0,1, 1,1,1,1,0, 0,0,1,0,0
    ; % (37)
    db 1,1,0,0,1, 1,1,0,1,0, 0,0,1,0,0, 0,1,0,0,0, 0,1,0,1,1, 1,0,0,1,1, 0,0,0,0,0
    ; & (38)
    db 0,1,1,0,0, 1,0,0,1,0, 0,1,1,0,0, 0,1,0,0,0, 1,0,1,0,1, 1,0,0,1,0, 0,1,1,0,1
    ; ' (39)
    db 0,0,1,0,0, 0,0,1,0,0, 0,1,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0
    ; ( (40)
    db 0,0,0,1,0, 0,0,1,0,0, 0,1,0,0,0, 0,1,0,0,0, 0,1,0,0,0, 0,0,1,0,0, 0,0,0,1,0
    ; ) (41)
    db 0,1,0,0,0, 0,0,1,0,0, 0,0,0,1,0, 0,0,0,1,0, 0,0,0,1,0, 0,0,1,0,0, 0,1,0,0,0
    ; * (42)
    db 0,0,0,0,0, 0,1,0,1,0, 0,0,1,0,0, 1,1,1,1,1, 0,0,1,0,0, 0,1,0,1,0, 0,0,0,0,0
    ; + (43)
    db 0,0,0,0,0, 0,0,1,0,0, 0,0,1,0,0, 1,1,1,1,1, 0,0,1,0,0, 0,0,1,0,0, 0,0,0,0,0
    ; , (44)
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,1,0,0,0
    ; - (45)
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 1,1,1,1,1, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0
    ; . (46)
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,1,1,0,0, 0,1,1,0,0
    ; / (47)
    db 0,0,0,0,1, 0,0,0,1,0, 0,0,1,0,0, 0,1,0,0,0, 1,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0
    ; Numbers 0-9 
    db 0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0  ; 0 (48)
    db 0,1,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 1,1,1,1,1  ; 1 (49)
    db 1,1,1,1,0, 0,0,0,0,1, 0,0,0,0,1, 0,1,1,1,0, 1,0,0,0,0, 1,0,0,0,0, 1,1,1,1,1  ; 2 (50)
    db 1,1,1,1,0, 0,0,0,0,1, 0,0,0,0,1, 0,1,1,1,0, 0,0,0,0,1, 0,0,0,0,1, 1,1,1,1,0  ; 3 (51)
    db 0,0,0,1,0, 0,0,1,1,0, 0,1,0,1,0, 1,0,0,1,0, 1,1,1,1,1, 0,0,0,1,0, 0,0,0,1,0  ; 4 (52)
    db 1,1,1,1,1, 1,0,0,0,0, 1,0,0,0,0, 1,1,1,1,0, 0,0,0,0,1, 0,0,0,0,1, 1,1,1,1,0  ; 5 (53)
    db 0,1,1,1,0, 1,0,0,0,0, 1,0,0,0,0, 1,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0  ; 6 (54)
    db 1,1,1,1,1, 0,0,0,0,1, 0,0,0,1,0, 0,0,1,0,0, 0,1,0,0,0, 0,1,0,0,0, 0,1,0,0,0  ; 7 (55)
    db 0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0  ; 8 (56)
    db 0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,1, 0,0,0,0,1, 0,0,0,0,1, 0,1,1,1,0  ; 9 (57)
    ; : (58)
    db 0,0,0,0,0, 0,1,1,0,0, 0,1,1,0,0, 0,0,0,0,0, 0,1,1,0,0, 0,1,1,0,0, 0,0,0,0,0
    ; ; (59)
    db 0,0,0,0,0, 0,1,1,0,0, 0,1,1,0,0, 0,0,0,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,1,0,0,0
    ; < (60)
    db 0,0,0,1,0, 0,0,1,0,0, 0,1,0,0,0, 1,0,0,0,0, 0,1,0,0,0, 0,0,1,0,0, 0,0,0,1,0
    ; = (61)
    db 0,0,0,0,0, 0,0,0,0,0, 1,1,1,1,1, 0,0,0,0,0, 1,1,1,1,1, 0,0,0,0,0, 0,0,0,0,0
    ; > (62) 0x3E
    db 0,1,0,0,0, 0,0,1,0,0, 0,0,0,1,0, 0,0,0,0,1, 0,0,0,1,0, 0,0,1,0,0, 0,1,0,0,0
    ; ? (63) 0x3F
    db 0,1,1,1,0, 1,0,0,0,1, 0,0,0,1,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,0,0,0, 0,0,1,0,0
    ; @ (64) 0x40
    db 0,1,1,1,0, 1,0,0,0,1, 1,0,1,1,1, 1,0,1,0,1, 1,0,1,1,1, 1,0,0,0,0, 0,1,1,1,0
    ; Letters A-Z (65-90)
    db 0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 1,1,1,1,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1  ; A (65) (0x41)
    db 1,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 1,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 1,1,1,1,0  ; B (66) 0x42
    db 0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,0, 1,0,0,0,0, 1,0,0,0,0, 1,0,0,0,1, 0,1,1,1,0  ; C (67) 0x43
    db 1,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,1,1,1,0  ; D (68) 0x44
    db 1,1,1,1,1, 1,0,0,0,0, 1,0,0,0,0, 1,1,1,1,0, 1,0,0,0,0, 1,0,0,0,0, 1,1,1,1,1  ; E (69) 0x45
    db 1,1,1,1,1, 1,0,0,0,0, 1,0,0,0,0, 1,1,1,1,0, 1,0,0,0,0, 1,0,0,0,0, 1,0,0,0,0  ; F (70) 0x46
    db 0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,0, 1,0,1,1,1, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0  ; G (71) 0x47
    db 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,1,1,1,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1  ; H (72) 0x48
    db 1,1,1,1,1, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 1,1,1,1,1  ; I (73) 0x49
    db 0,0,1,1,1, 0,0,0,1,0, 0,0,0,1,0, 0,0,0,1,0, 1,0,0,1,0, 1,0,0,1,0, 0,1,1,0,0  ; J (74) 0x4A
    db 1,0,0,0,1, 1,0,0,1,0, 1,0,1,0,0, 1,1,0,0,0, 1,0,1,0,0, 1,0,0,1,0, 1,0,0,0,1  ; K (75) 0x4B
    db 1,0,0,0,0, 1,0,0,0,0, 1,0,0,0,0, 1,0,0,0,0, 1,0,0,0,0, 1,0,0,0,0, 1,1,1,1,1  ; L (76) 0x4C
    db 1,0,0,0,1, 1,1,0,1,1, 1,0,1,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1  ; M (77) 0x4D
    db 1,0,0,0,1, 1,1,0,0,1, 1,0,1,0,1, 1,0,0,1,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1  ; N (78) 0x4E
    db 0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0  ; O (79) 0x4F
    db 1,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 1,1,1,1,0, 1,0,0,0,0, 1,0,0,0,0, 1,0,0,0,0  ; P (80) 0x50
    db 0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,1,0,1, 1,0,0,1,0, 0,1,1,0,1  ; Q (81) 0x51
    db 1,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 1,1,1,1,0, 1,0,1,0,0, 1,0,0,1,0, 1,0,0,0,1  ; R (82) 0x52
    db 0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,0, 0,1,1,1,0, 0,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0  ; S (83) 0x53
    db 1,1,1,1,1, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0  ; T (84)
    db 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0  ; U (85)
    db 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 0,1,0,1,0, 0,1,0,1,0, 0,0,1,0,0  ; V (86)
    db 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,1,0,1, 1,0,1,0,1, 1,1,0,1,1, 1,0,0,0,1  ; W (87)
    db 1,0,0,0,1, 0,1,0,1,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,1,0,1,0, 1,0,0,0,1  ; X (88)
    db 1,0,0,0,1, 1,0,0,0,1, 0,1,0,1,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0  ; Y (89)
    db 1,1,1,1,1, 0,0,0,0,1, 0,0,0,1,0, 0,0,1,0,0, 0,1,0,0,0, 1,0,0,0,0, 1,1,1,1,1  ; Z (90)
    ; [ (91) 0x5B
    db 0,1,1,1,0, 0,1,0,0,0, 0,1,0,0,0, 0,1,0,0,0, 0,1,0,0,0, 0,1,0,0,0, 0,1,1,1,0
    ; \ (92) 0x5C
    db 1,0,0,0,0, 0,1,0,0,0, 0,0,1,0,0, 0,0,0,1,0, 0,0,0,0,1, 0,0,0,0,0, 0,0,0,0,0
    ; ] (93) 0x5D
    db 0,1,1,1,0, 0,0,0,1,0, 0,0,0,1,0, 0,0,0,1,0, 0,0,0,1,0, 0,0,0,1,0, 0,1,1,1,0
    ; ^ (94) 0x5E
    db 0,0,1,0,0, 0,1,0,1,0, 1,0,0,0,1, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0
    ; _ (95) 0x5F
    db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 1,1,1,1,1
    ; ` (96) 0x60
    db 0,1,0,0,0, 0,0,1,0,0, 0,0,0,1,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0
    ; Letters a-z (lowercase) - similar to uppercase but smaller
    db 0,0,0,0,0, 0,1,1,1,0, 0,0,0,0,1, 0,1,1,1,1, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,1  ; a (97) 0x61
    db 1,0,0,0,0, 1,0,0,0,0, 1,0,1,1,0, 1,1,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0  ; b (98) 0x62
    db 0,0,0,0,0, 0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,0, 1,0,0,0,0, 1,0,0,0,1, 0,1,1,1,0  ; c (99) 0x63
    db 0,0,0,0,1, 0,0,0,0,1, 0,1,1,0,1, 1,0,0,1,1, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,1  ; d (100) 0x64
    db 0,0,0,0,0, 0,1,1,1,0, 1,0,0,0,1, 1,1,1,1,1, 1,0,0,0,0, 1,0,0,0,1, 0,1,1,1,0  ; e (101) 0x65
    db 0,0,1,1,0, 0,1,0,0,1, 0,1,0,0,0, 1,1,1,0,0, 0,1,0,0,0, 0,1,0,0,0, 0,1,0,0,0  ; f (102) 0x66
    db 0,0,0,0,0, 0,1,1,1,1, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,1, 0,0,0,0,1, 0,1,1,1,0  ; g (103) 0x67
    db 1,0,0,0,0, 1,0,0,0,0, 1,0,1,1,0, 1,1,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1  ; h (104) 0x68
    db 0,0,1,0,0, 0,0,0,0,0, 0,1,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,1,1,1,0  ; i (105) 0x69
    db 0,0,0,1,0, 0,0,0,0,0, 0,0,1,1,0, 0,0,0,1,0, 0,0,0,1,0, 1,0,0,1,0, 0,1,1,0,0  ; j (106) 0x6A
    db 1,0,0,0,0, 1,0,0,0,0, 1,0,0,1,0, 1,0,1,0,0, 1,1,0,0,0, 1,0,1,0,0, 1,0,0,1,0  ; k (107) 0x6B
    db 0,1,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,1,1,1,0  ; l (108) 0x6C
    db 0,0,0,0,0, 1,1,0,1,0, 1,0,1,0,1, 1,0,1,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1  ; m (109) 0x6D
    db 0,0,0,0,0, 1,0,1,1,0, 1,1,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1  ; n (110) 0x6E
    db 0,0,0,0,0, 0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0  ; o (111) 0x6F
    db 0,0,0,0,0, 1,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 1,1,1,1,0, 1,0,0,0,0, 1,0,0,0,0  ; p (112) 0x70
    db 0,0,0,0,0, 0,1,1,1,1, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,1, 0,0,0,0,1, 0,0,0,0,1  ; q (113) 0x71
    db 0,0,0,0,0, 1,0,1,1,0, 1,1,0,0,1, 1,0,0,0,0, 1,0,0,0,0, 1,0,0,0,0, 1,0,0,0,0  ; r (114) 0x72
    db 0,0,0,0,0, 0,1,1,1,0, 1,0,0,0,1, 0,1,1,1,0, 0,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0  ; s (115) 0x73
    db 0,1,0,0,0, 0,1,0,0,0, 1,1,1,1,0, 0,1,0,0,0, 0,1,0,0,0, 0,1,0,0,1, 0,0,1,1,0  ; t (116) 0x74
    db 0,0,0,0,0, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,1,1, 0,1,1,0,1  ; u (117) 0x75
    db 0,0,0,0,0, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 0,1,0,1,0, 0,0,1,0,0  ; v (118) 0x76
    db 0,0,0,0,0, 1,0,0,0,1, 1,0,0,0,1, 1,0,1,0,1, 1,0,1,0,1, 1,0,1,0,1, 0,1,0,1,0  ; w (119) 0x77
    db 0,0,0,0,0, 1,0,0,0,1, 0,1,0,1,0, 0,0,1,0,0, 0,0,1,0,0, 0,1,0,1,0, 1,0,0,0,1  ; x (120) 0x78
    db 0,0,0,0,0, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,1, 0,0,0,0,1, 0,1,1,1,0  ; y (121) 0x79
    db 0,0,0,0,0, 1,1,1,1,1, 0,0,0,1,0, 0,0,1,0,0, 0,1,0,0,0, 1,0,0,0,0, 1,1,1,1,1  ; z (122) 0x7A
    ; { (123) 0x7B
    db 0,0,1,1,0, 0,1,0,0,0, 0,1,0,0,0, 1,0,0,0,0, 0,1,0,0,0, 0,1,0,0,0, 0,0,1,1,0
    ; | (124) 0x7C
    db 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0
    ; } (125) 0x7D
    db 0,1,1,0,0, 0,0,0,1,0, 0,0,0,1,0, 0,0,0,0,1, 0,0,0,1,0, 0,0,0,1,0, 0,1,1,0,0
    ; ~ (126) 0x7E
    db 0,0,0,0,0, 0,1,0,0,0, 1,0,1,0,1, 0,0,0,1,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0
; Scan code to ASCII conversion table
scancode_to_ascii:
    ; First 16 bytes (0x00-0x0F)
    ; db 0,    27,   '1',  '2',  '3',  '4',  '5',  '6'  ; 0x00-0x07
    ; db '7',  '8',  '9',  '0',  '-',  '=',  8,    9    ; 0x08-0x0F
    db 0x00, 0x1B, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36  ; 0x00-0x07
    db 0x37, 0x38, 0x39, 0x30, 0x2D, 0x3D, 0x08, 0x09  ; 0x08-0x0F
    ; Next 16 bytes (0x10-0x1F)
    ; db 'q',  'w',  'e',  'r',  't',  'y',  'u',  'i'  ; 0x10-0x17
    ; db 'o',  'p',  '[',  ']',  13,    0,    'a',  's'  ; 0x18-0x1F
    db 0x71, 0x77, 0x65, 0x72, 0x74, 0x79, 0x75, 0x69  ; 0x10-0x17
    db 0x6F, 0x70, 0x5B, 0x5D, 0x0D, 0x00, 0x61, 0x73  ; 0x18-0x1F
    ; Next 16 bytes (0x20-0x2F)
    ; db 'd',  'f',  'g',  'h',  'j',  'k',  'l',  ':'  ; 0x20-0x27
    ; db '"',  '~',  0,    '|',  'z',  'x',  'c',  'v'  ; 0x28-0x2F
    db 0x64, 0x66, 0x67, 0x68, 0x6A, 0x6B, 0x6C, 0x3B  ; 0x20-0x27
    db 0x27, 0x60, 0x00, 0x5C, 0x7A, 0x78, 0x63, 0x76  ; 0x28-0x2F
    ; Next 16 bytes (0x30-0x3F)
    ; db 'b',  'n',  'm',  ',',  '.',  '/',  0,    '*'  ; 0x30-0x37
    ; db 0,    ' ',  0,    0,    0,    0,    0,    0    ; 0x38-0x3F
    db 0x62, 0x6E, 0x6D, 0x2C, 0x2E, 0x2F, 0x00, 0x2A  ; 0x30-0x37
    db 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x38-0x3F


; Scan code to ASCII conversion table for shifted keys
scancode_to_ascii_shift:
    ; First 16 bytes (0x00-0x0F)
    db 0x00, 0x1B, 0x21, 0x40, 0x23, 0x24, 0x25, 0x5E  ; 0x00-0x07
    db 0x26, 0x2A, 0x28, 0x29, 0x5F, 0x2B, 0x08, 0x09  ; 0x08-0x0F
    ; Next 16 bytes (0x10-0x1F)
    db 0x51, 0x57, 0x45, 0x52, 0x54, 0x59, 0x55, 0x49  ; 0x10-0x17
    db 0x4F, 0x50, 0x7B, 0x7D, 0x0D, 0x00, 0x41, 0x53  ; 0x18-0x1F
    ; Next 16 bytes (0x20-0x2F)
    db 0x44, 0x46, 0x47, 0x48, 0x4A, 0x4B, 0x4C, 0x3A  ; 0x20-0x27
    db 0x22, 0x7E, 0x00, 0x7C, 0x5A, 0x58, 0x43, 0x56  ; 0x28-0x2F
    ; Next 16 bytes (0x30-0x3F)
    db 0x42, 0x4E, 0x4D, 0x3C, 0x3E, 0x3F, 0x00, 0x2A  ; 0x30-0x37
    db 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x38-0x3F


NUMBER_WIDTH equ 5
NUMBER_HEIGHT equ 7
PATTERN_SIZE equ NUMBER_WIDTH * NUMBER_HEIGHT
NUMBER_SPACING equ 2
initial_text_x: dd 10         ; Default initial X position
initial_text_y: dd 10         ; Default initial Y position

section .text
global draw_pixel
global handle_input
global clear_screen
global print_coords
; Function to draw pixel
draw_pixel:
    pusha
    mov eax, SCREEN_WIDTH
    mul dword [pixel_y]    ; y * width
    add eax, [pixel_x]     ; + x
    add eax, VGA_MEMORY    ; + base address
    mov bl, [current_color]
    mov [eax], bl
    call print_coords
    popa
    ret
get_shifted_ascii:
    movzx ebx, al              ; Zero extend AL to EBX (scan code)
    mov al, [scancode_to_ascii_shift + ebx]  ; Get shifted ASCII value
    ret
get_ascii:
    movzx ebx, al              ; Zero extend AL to EBX (scan code)
    mov al, [scancode_to_ascii + ebx]  ; Get shifted ASCII value
    ret
; Handle keyboard input
handle_input:
    pusha
    
    ; Wait for keyboard buffer to be ready
    in al, KEYBOARD_STATUS
    test al, 0x01
    jz .done
    
    ; Read scan code
    in al, KEYBOARD_DATA
    
    ; Check for shift key press/release
    cmp al, KEY_LSHIFT_PRESSED
    je .shift_press
    cmp al, KEY_RSHIFT_PRESSED
    je .shift_press
    cmp al, KEY_LSHIFT_RELEASED
    je .shift_release
    cmp al, KEY_RSHIFT_RELEASED
    je .shift_release
    
    ; Check for key release of other keys
    test al, 0x80
    jnz .done

    
    ; First check for special keys (arrow keys, space)
    cmp al, KEY_UP
    je .move_up
    cmp al, KEY_DOWN
    je .move_down
    cmp al, KEY_LEFT
    je .move_left
    cmp al, KEY_RIGHT
    je .move_right
    ; cmp al, KEY_SPACE
    ; je .reset

    jmp .draw_char

.shift_press:
    mov byte [shift_pressed], 1
    jmp .done

.shift_release:
    mov byte [shift_pressed], 0
    jmp .done

.draw_char:
    push eax
    
    ; Check for shift key state
    cmp byte [shift_pressed], 0
    je .no_shift
    
    ; Use shifted ASCII table if shift is pressed
    call get_shifted_ascii     ; Get shifted ASCII value for scan code
    jmp .draw_ascii

    
.no_shift:
    call get_ascii

.draw_ascii:
    ; Get current text position
    mov esi, [text_x]
    mov edi, [text_y]
    call draw_character
    
    ; Move text position
    add dword [text_x], 8  ; Move right by character width + spacing
    
    ; Check if we need to wrap to next line
    cmp dword [text_x], SCREEN_WIDTH - NUMBER_WIDTH
    jl .done_char
    
    ; Wrap to next line
    mov dword [text_x], 10
    add dword [text_y], 9  ; Move down by character height + spacing
    
    ; Check if we're at bottom of screen
    cmp dword [text_y], SCREEN_HEIGHT - NUMBER_HEIGHT
    jl .done_char
    
    ; Reset to top if we hit bottom
    mov dword [text_y], 10
    jmp .done
    
.done_char:
    pop eax
    jmp .done

.move_up:
    cmp dword [pixel_y], 1     ; Leave 1 pixel margin from top
    jle .done                  ; If at or below margin, don't move
    dec dword [pixel_y]
    xor al, al                 ; Direction 0 = up
    call draw_line
    jmp .done

.move_down:
    mov eax, SCREEN_HEIGHT
    sub eax, 2                 ; Leave 1 pixel margin from bottom
    cmp dword [pixel_y], eax
    jge .done                  ; If at or above margin, don't move
    inc dword [pixel_y]
    mov al, 1                  ; Direction 1 = down
    call draw_line
    jmp .done

.move_left:
    cmp dword [pixel_x], 1     ; Leave 1 pixel margin from left
    jle .done                  ; If at or below margin, don't move
    dec dword [pixel_x]
    mov al, 2                  ; Direction 2 = left
    call draw_line
    jmp .done

.move_right:
    mov eax, SCREEN_WIDTH
    sub eax, 2                 ; Leave 1 pixel margin from right
    cmp dword [pixel_x], eax
    jge .done                  ; If at or above margin, don't move
    inc dword [pixel_x]
    mov al, 3                  ; Direction 3 = right
    call draw_line
    jmp .done

.reset:
    call fade_screen
    call reset_position
    call draw_pixel
    jmp .done

.done:
    popa
    ret

; Modify clear_screen function to accept parameters
; Input: EAX = start x
;        EBX = start y
;        ECX = width
;        EDX = height
clear_screen:
    pusha
    push edx           ; Save height counter
    
    ; Calculate start position
    push eax          ; Save start x
    mov eax, SCREEN_WIDTH
    mul ebx           ; y * width
    pop ebx           ; Restore start x into ebx
    add eax, ebx      ; + x
    add eax, VGA_MEMORY
    mov edi, eax      ; Set destination
    
.clear_row:
    push ecx          ; Save width
    xor al, al        ; Black color
    rep stosb         ; Clear one row
    
    pop ecx           ; Restore width
    add edi, SCREEN_WIDTH
    sub edi, ecx      ; Move to next row start
    
    pop edx           ; Get height counter
    dec edx
    push edx          ; Save updated height
    jnz .clear_row
    
    pop edx           ; Clean up stack
    popa
    ret

; Modify print_coords to add background
print_coords:
    pusha
    
    ; First fill background for coordinate display area
    push dword [current_color]  ; Save current color
    
    mov byte [current_color], COORD_BG_COLOR
    mov edi, VGA_MEMORY        ; Start of video memory
    mov ecx, COORD_DISPLAY_WIDTH
    mov edx, COORD_DISPLAY_HEIGHT
    
.fill_bg_row:
    push ecx
.fill_bg_col:
    mov byte [edi], COORD_BG_COLOR
    inc edi
    loop .fill_bg_col
    
    pop ecx
    add edi, SCREEN_WIDTH
    sub edi, COORD_DISPLAY_WIDTH
    dec edx
    jnz .fill_bg_row
    
    pop dword [current_color]   ; Restore drawing color
    
    ; Draw X coordinate
    mov eax, [pixel_x]
    xor bl, bl                  ; Start at x position 0
    call render_number
    
    ; Draw Y coordinate
    mov eax, [pixel_y]
    mov bl, 28                  ; Start Y coordinate after X
    call render_number
    
    popa
    ret



section .data
; Color table
color_table:
    db 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x0F

; Add new function to reset position
reset_position:
    pusha
    ; Calculate center position
    mov eax, SCREEN_WIDTH
    shr eax, 1                 ; Divide by 2 for center X
    mov dword [pixel_x], eax
    
    mov eax, SCREEN_HEIGHT
    shr eax, 1                 ; Divide by 2 for center Y
    mov dword [pixel_y], eax
    
    ; Validate center position
    call validate_coordinates
    jc .adjust_position        ; If invalid, adjust position
    
    popa
    ret

.adjust_position:
    ; Ensure position is within valid bounds
    mov eax, [pixel_x]
    cmp eax, SCREEN_WIDTH - 1
    jle .check_y
    mov eax, SCREEN_WIDTH - 2
    mov [pixel_x], eax
    
.check_y:
    mov eax, [pixel_y]
    cmp eax, SCREEN_HEIGHT - 1
    jle .done_adjust
    mov eax, SCREEN_HEIGHT - 2
    mov [pixel_y], eax
    
.done_adjust:
    popa
    ret

; Replace the separate line drawing functions with a single one
; Input: AL = direction (0=up, 1=down, 2=left, 3=right)
draw_line:
    pusha
    mov ecx, 1          ; Line length
.loop:
    call draw_pixel
    
    cmp al, 0          ; Check direction
    je .move_up
    cmp al, 1
    je .move_down
    cmp al, 2
    je .move_left
    cmp al, 3
    je .move_right
    jmp .continue
    
.move_up:
    dec dword [pixel_y]
    jmp .continue
.move_down:
    inc dword [pixel_y]
    jmp .continue
.move_left:
    dec dword [pixel_x]
    jmp .continue
.move_right:
    inc dword [pixel_x]
    
.continue:
    loop .loop
    popa
    ret


; Convert number to digits and render
; Input: EAX = number to display
;        BL = x position
render_number:
    pusha
    mov ecx, 100        ; Divisor for hundreds
    xor edx, edx
    div ecx            ; Divide by 100
    push edx           ; Save remainder
    
    ; Draw hundreds digit
    mov bl, bl         ; X position already in bl
    movzx eax, al              
    mov al, [scancode_to_ascii + eax]
    call draw_character
    
    ; Draw tens
    pop eax            ; Get remainder
    mov ecx, 10
    xor edx, edx
    div ecx
    push edx           ; Save ones digit
    
    ; Draw tens digit
    add bl, 7          ; Move 7 pixels right
    movzx eax, al              
    mov al, [scancode_to_ascii + eax]
    call draw_character
    
    ; Draw ones digit
    pop eax
    add bl, 7          ; Move another 7 pixels right
    movzx eax, al              
    mov al, [scancode_to_ascii + eax]
    call draw_character
    
    popa
    ret

; Add new function to validate coordinates
; Input: None
; Output: Sets carry flag if coordinates are invalid
validate_coordinates:
    push eax
    
    ; Check X coordinate
    cmp dword [pixel_x], 0
    jl .invalid
    mov eax, SCREEN_WIDTH
    dec eax
    cmp dword [pixel_x], eax
    jg .invalid
    
    ; Check Y coordinate
    cmp dword [pixel_y], 0
    jl .invalid
    mov eax, SCREEN_HEIGHT
    dec eax
    cmp dword [pixel_y], eax
    jg .invalid
    
    ; Valid coordinates
    pop eax
    clc                     ; Clear carry flag
    ret
    
.invalid:
    pop eax
    stc                     ; Set carry flag
    ret

; Add new fade screen function
fade_screen:
    pusha
    mov ecx, FADE_STEPS        ; Number of fade steps
    
.fade_loop:
    push ecx
    
    ; Calculate fade color based on step
    mov eax, ecx
    shl eax, 4                 ; Multiply by 16 for grayscale value
    mov byte [current_color], al
    
    ; Fill entire screen with current fade color
    mov edi, VGA_MEMORY
    mov ecx, SCREEN_WIDTH * SCREEN_HEIGHT
    mov al, byte [current_color]
    rep stosb
    
    ; Add delay
    mov ecx, FADE_DELAY
.delay:
    loop .delay
    
    pop ecx
    loop .fade_loop
    
    ; Clear screen to black
    mov edi, VGA_MEMORY
    mov ecx, SCREEN_WIDTH * SCREEN_HEIGHT
    xor al, al
    rep stosb
    
    ; Restore default color
    mov byte [current_color], 0x0F
    popa
    ret

; Add new function to draw a character
draw_character:
    pusha
    movzx eax, al              ; Character index
    push eax                   ; Save character index
    
    ; Calculate screen position
    mov eax, SCREEN_WIDTH
    mul edi                    ; y * width in eax
    add eax, esi              ; Add x position
    add eax, VGA_MEMORY       ; Add VGA base address
    mov edi, eax              ; EDI now has final screen position
    
    pop eax                    ; Restore character index
    mov ecx, PATTERN_SIZE      ; Pattern size
    mul ecx                    ; Calculate pattern offset
    mov esi, ASCII_patterns    ; Get pattern base address
    add esi, eax              ; Add offset to get correct pattern
    
    mov ecx, NUMBER_HEIGHT    ; Height counter
.row_loop:
    push ecx
    mov ecx, NUMBER_WIDTH     ; Width counter
    
.pixel_loop:
    mov al, byte [esi]        ; Get pixel value
    test al, al
    jz .skip_pixel           ; If pixel is 0, keep background
    
    push eax
    mov al, [current_color]   ; Use current color for character
    mov [edi], al            ; Draw pixel
    pop eax
    
.skip_pixel:
    inc esi                   ; Next pattern byte
    inc edi                   ; Next screen position
    loop .pixel_loop
    
    pop ecx
    add edi, SCREEN_WIDTH - NUMBER_WIDTH  ; Move to next row
    loop .row_loop
    
    popa
    ret

; Function to draw a hexadecimal number
; Input: AL = value to display
;        ESI = x position (32-bit)
;        EDI = y position (32-bit)
draw_hex:
    pusha
    mov dl, al          ; Save original value
    push esi            ; Save original X position
    push edi            ; Save original Y position
    
    ; Draw first digit (high nibble)
    mov al, dl
    shr al, 4           ; Get high nibble
    movzx ebx, al       ; Zero extend AL to EBX for array index
    mov al, [hex_digits + ebx]  ; Get ASCII character
    call draw_character
    
    ; Move to next position
    pop edi             ; Restore Y position
    pop esi             ; Restore X position
    add esi, 6          ; Move right by character width + 1
    
    ; Draw second digit (low nibble)
    mov al, dl
    and al, 0x0F       ; Get low nibble
    movzx ebx, al      ; Zero extend AL to EBX for array index
    mov al, [hex_digits + ebx]  ; Get ASCII character
    call draw_character
    
    popa
    ret

; Add after ASCII_patterns section
section .data
; Add string buffer
string_buffer: times 256 db 0  ; Buffer for string operations
string_length: dd 0            ; Current string length

section .text
; Add new string rendering functions
global render_string
global render_string_at

; Function to render string at current text position
; Input: ESI = pointer to null-terminated string
render_string:
    pusha
    call get_string_length
    mov ecx, [string_length]   ; Get string length
    test ecx, ecx
    jz .done                   ; If empty string, done
    
.render_loop:
    lodsb                      ; Load character from string
    push ecx
    push esi
    
    ; Get current text position
    mov esi, [text_x]         ; Use full 32-bit X position
    mov edi, [text_y]         ; Use full 32-bit Y position
    call draw_character
    
    ; Move text position
    add dword [text_x], 8      ; Move right by character width + spacing
    
    ; Check if we need to wrap
    mov eax, SCREEN_WIDTH
    sub eax, 8                 ; Leave margin for character width
    cmp dword [text_x], eax
    jl .continue
    
    ; Wrap to next line
    mov dword [text_x], 10     ; Reset to left margin
    add dword [text_y], 9      ; Move down by character height + spacing
    
    ; Check if we're at bottom
    mov eax, SCREEN_HEIGHT
    sub eax, 9                 ; Leave margin for character height
    cmp dword [text_y], eax
    jl .continue
    
    ; Reset to top if at bottom
    mov dword [text_y], 10
    
.continue:
    pop esi
    pop ecx
    loop .render_loop
    
.done:
    popa
    ret

; Function to render string at specific position
; Input: ESI = pointer to null-terminated string
;        EBX = x position (full 32-bit)
;        EDX = y position (full 32-bit)
render_string_at:
    pusha
    
    ; Save original text position
    push dword [text_x]
    push dword [text_y]
    
    ; Set new position
    mov [text_x], ebx
    mov [text_y], edx
    
    ; Render string
    call render_string
    
    ; Restore original position
    pop dword [text_y]
    pop dword [text_x]
    
    popa
    ret

; Helper function to get string length
; Input: ESI = pointer to string
; Output: [string_length] = length of string
get_string_length:
    pusha
    xor ecx, ecx            ; Clear counter
    mov edi, esi            ; Copy string pointer
    
.count_loop:
    lodsb                   ; Load byte from string
    test al, al            ; Check for null terminator
    jz .done
    inc ecx
    jmp .count_loop
    
.done:
    mov [string_length], ecx
    popa
    ret


; Function to display 16 bytes in hex format at specified line address
; Input: EAX = line address (offset from sector start)
;        EDI = y position
;        ESI = pointer to sector data
display_16bytes_hex:
    pusha
    push esi                ; Save sector data pointer
    mov ebp, eax            ; Save line address
    
    ; Display line address in hex (high byte)
    push eax                ; Save line address
    shr eax, 8              ; Get high byte
    and al, 0xFF            ; Ensure clean high byte
    mov esi, 20             ; X position for high byte
    call draw_hex           ; Display high byte
    
    ; Display line address in hex (low byte)
    pop eax                 ; Restore line address
    and al, 0xFF            ; Get low byte
    mov esi, 32             ; X position for low byte
    call draw_hex           ; Display low byte
    
    ; Display separator
    mov al, ':'             ; Separator character
    mov esi, 44             ; X position for separator
    call draw_character
    
    ; Display 16 bytes in hex
    mov ecx, BYTES_PER_LINE ; Display 16 bytes
    mov esi, 56             ; Initial X position for hex values
    pop ebx                 ; Restore sector data pointer to ebx
    add ebx, ebp           ; Add offset to get current position in sector
    
.byte_loop:
    mov al, [ebx]           ; Load byte from sector data
    push ecx
    call draw_hex           ; Display byte in hex
    pop ecx
    
    add esi, 20             ; Move to next hex position
    inc ebx                 ; Next byte in sector
    loop .byte_loop
    
    popa
    ret
; Function to display an entire sector in hex format
; Input: ESI = pointer to sector data
;        EAX = starting offset (usually 0)
;        EDI = initial Y position
display_sector_hex:
    pusha
    mov ecx, 32                ; Number of lines to display
.display_loop:
    call display_16bytes_hex   ; Display current line
    add eax, 0x10             ; Increment offset by 16 bytes
    add edi, 10               ; Move Y position down
    loop .display_loop        ; Repeat for all lines
    popa
    ret

; Function to read and display sector in hex format
; Input: EAX = sector number to read and display
global read_and_display_sector
read_and_display_sector:
    pusha
    push eax                    ; Save sector number
    
    ; Read the sector
    mov edi, msg_buffer        ; Set buffer for reading
    call read_sector           ; Read sector (sector number already in EAX)
    
    ; Check for read error
    jc .read_error
    
    ; Display sector data in hex format
    mov esi, msg_buffer        ; Set buffer pointer for display
    xor eax, eax              ; Start at offset 0 in buffer
    mov edi, 10               ; Initial Y position
    call display_sector_hex
    
    pop eax                    ; Clean up stack
    popa
    ret

.read_error:
    ; Display error message
    mov esi, disk_error_msg
    mov ebx, 320              ; Center X position
    mov edx, 140              ; Center Y position
    call render_string_at
    
    pop eax                    ; Clean up stack
    popa
    stc                       ; Set carry flag to indicate error
    ret