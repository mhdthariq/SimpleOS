#![no_std]
#![no_main]

use core::arch::asm;

// Boot sector entry point
#[unsafe(no_mangle)]
#[unsafe(link_section = ".text")]
pub extern "C" fn _start() -> ! {
    // Set up segments for real mode
    unsafe {
        asm!(
            "xor ax, ax",     // Zero out ax
            "mov ds, ax",     // Set data segment to 0
            "mov es, ax",     // Set extra segment to 0
            "mov ss, ax",     // Set stack segment to 0
            "mov sp, 0x7c00", // Set stack pointer just before boot sector
            options(nostack, preserves_flags)
        );
    }

    // Print boot message with colors
    print_string_colored(b"[", 0x0B); // Light cyan
    print_string_colored(b"BOOT", 0x0E); // Yellow
    print_string_colored(b"] ", 0x0B); // Light cyan
    print_string_colored(b"Booting from Hard Disk...\r\n", 0x0F); // White

    // Load kernel from disk using BIOS interrupt
    // Read sectors 1-16 (kernel) to memory at 0x10000
    load_kernel();

    // Print success message
    print_string_colored(b"[", 0x0B); // Light cyan
    print_string_colored(b" OK ", 0x0A); // Light green
    print_string_colored(b"] ", 0x0B); // Light cyan
    print_string_colored(b"Kernel loaded successfully\r\n", 0x0F); // White

    print_string_colored(b"[", 0x0B); // Light cyan
    print_string_colored(b"INFO", 0x0E); // Yellow
    print_string_colored(b"] ", 0x0B); // Light cyan
    print_string_colored(b"Jumping to kernel...\r\n", 0x0F); // White

    // Jump to kernel (loaded at 0x10000 in protected mode setup)
    // For now, we'll just jump to it directly
    unsafe {
        asm!("ljmp $0x0, $0x10000", options(noreturn, att_syntax));
    }
}

// Load kernel from disk using BIOS INT 13h
fn load_kernel() {
    unsafe {
        asm!(
            // Set up ES segment
            "push ax",
            "mov ax, 0x1000",
            "mov es, ax",
            "pop ax",

            // Set up disk read parameters
            "mov ah, 0x02",      // Function 02h: Read sectors
            "mov al, 16",        // Number of sectors to read
            "mov ch, 0",         // Cylinder number (low 8 bits)
            "mov cl, 2",         // Sector number (starts at 2, after boot sector)
            "mov dh, 0",         // Head number
            "mov dl, 0x80",      // Drive number (0x80 = first hard disk)
            "xor bx, bx",        // ES:BX = 0x1000:0x0000 = 0x10000
            "int 0x13",          // Call BIOS disk interrupt
            "jnc 2f",            // Jump if no error (carry flag clear)

            // Error handling - print 'E'
            "mov ah, 0x0E",
            "mov al, 'E'",
            "int 0x10",

            "2:",                // Success label
            out("ax") _,
            out("cx") _,
            out("dx") _,
            options(nostack)
        );
    }
}

// Print a null-terminated or length-based string using BIOS interrupts
fn print_string(s: &[u8]) {
    print_string_colored(s, 0x0F); // White on black by default
}

// Print a string with specified color
// color: 0xBF where B = background (4 bits), F = foreground (4 bits)
// Examples: 0x0F = white on black, 0x0A = light green on black, 0x0E = yellow on black
fn print_string_colored(s: &[u8], color: u8) {
    for &byte in s {
        unsafe {
            asm!(
                "mov ah, 0x0E",   // BIOS teletype function
                "mov al, {0}",    // Character to print
                "mov bl, {1}",    // Color attribute
                "xor bh, bh",     // Page number 0
                "int 0x10",       // Call BIOS interrupt
                in(reg_byte) byte,
                in(reg_byte) color,
                out("ax") _,
                options(nostack, preserves_flags)
            );
        }
    }
}

#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    // Print panic message
    print_string(b"\r\nPANIC!\r\n");

    loop {
        unsafe {
            asm!("hlt", options(nomem, nostack, preserves_flags));
        }
    }
}
