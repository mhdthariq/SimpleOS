.code16
.intel_syntax noprefix
.section .text.start
.global _start

_start:
    # Print 'K' to confirm we reached kernel
    mov ah, 0x0E
    mov al, 'K'
    mov bl, 0x0E
    int 0x10

    # Clear screen
    mov ax, 0x0003
    int 0x10

    # Print title bar - " SimpleOS "
    mov si, offset title
    mov bl, 0x1E
    call print_colored

    mov si, offset subtitle
    mov bl, 0x1F
    call print_colored

    mov si, offset newline
    call print_string

    mov si, offset newline
    call print_string

    # Print status messages with [OK] tags
    # Status 1
    mov si, offset bracket_open
    mov bl, 0x0B
    call print_colored

    mov si, offset ok_text
    mov bl, 0x0A
    call print_colored

    mov si, offset bracket_close
    mov bl, 0x0B
    call print_colored

    mov si, offset msg1
    call print_string

    # Status 2
    mov si, offset bracket_open
    mov bl, 0x0B
    call print_colored

    mov si, offset ok_text
    mov bl, 0x0A
    call print_colored

    mov si, offset bracket_close
    mov bl, 0x0B
    call print_colored

    mov si, offset msg2
    call print_string

    # Status 3
    mov si, offset bracket_open
    mov bl, 0x0B
    call print_colored

    mov si, offset ok_text
    mov bl, 0x0A
    call print_colored

    mov si, offset bracket_close
    mov bl, 0x0B
    call print_colored

    mov si, offset msg3
    call print_string

    mov si, offset newline
    call print_string

    # Print welcome messages
    mov si, offset hello
    mov bl, 0x0B
    call print_colored

    mov si, offset newline
    call print_string

    mov si, offset welcome
    mov bl, 0x0D
    call print_colored

    mov si, offset newline
    call print_string

    mov si, offset newline
    call print_string

    # Print separator
    mov si, offset separator
    mov bl, 0x0E
    call print_colored

    mov si, offset newline
    call print_string

    mov si, offset newline
    call print_string

    # Print rainbow bar
    call print_rainbow

    mov si, offset newline
    call print_string

    mov si, offset newline
    call print_string

    # Print status
    mov si, offset status
    mov bl, 0x20
    call print_colored

    mov si, offset newline
    call print_string

    mov si, offset exit_msg
    call print_string

halt_loop:
    hlt
    jmp halt_loop

# Function: print_string (white on black)
print_string:
    push si
    push ax
    push bx
    mov bl, 0x0F
ps_loop:
    lodsb
    test al, al
    jz ps_done
    mov ah, 0x0E
    int 0x10
    jmp ps_loop
ps_done:
    pop bx
    pop ax
    pop si
    ret

# Function: print_colored (BL = color)
print_colored:
    push si
    push ax
pc_loop:
    lodsb
    test al, al
    jz pc_done
    mov ah, 0x0E
    int 0x10
    jmp pc_loop
pc_done:
    pop ax
    pop si
    ret

# Function: print_rainbow
print_rainbow:
    push si
    push cx
    push ax
    push bx
    push di
    xor di, di
    mov cx, 6
pr_loop:
    push cx
    mov bl, byte ptr [rainbow_colors + di]
    inc di
    mov si, offset rainbow_pattern
pr_char_loop:
    lodsb
    test al, al
    jz pr_next
    mov ah, 0x0E
    int 0x10
    jmp pr_char_loop
pr_next:
    pop cx
    loop pr_loop
    pop di
    pop bx
    pop ax
    pop cx
    pop si
    ret

# Data section
.section .rodata
title:
    .asciz " SimpleOS "
subtitle:
    .asciz "- A Rust Operating System"
bracket_open:
    .asciz "["
ok_text:
    .asciz " OK "
bracket_close:
    .asciz "]"
msg1:
    .asciz " Bootloader loaded successfully\r\n"
msg2:
    .asciz " Kernel initialized\r\n"
msg3:
    .asciz " VGA text mode enabled\r\n"
hello:
    .asciz "Hello, World!"
welcome:
    .asciz "Welcome to SimpleOS!"
separator:
    .asciz "================================"
status:
    .asciz " System Status: Running "
exit_msg:
    .asciz "Press Ctrl+A then X to exit QEMU\r\n"
newline:
    .asciz "\r\n"
rainbow_pattern:
    .asciz "####"
rainbow_colors:
    .byte 0x0C, 0x0E, 0x0A, 0x0B, 0x09, 0x0D
