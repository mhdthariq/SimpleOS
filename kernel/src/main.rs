#![no_std]
#![no_main]
#![feature(abi_x86_interrupt)]

use core::panic::PanicInfo;

// VGA text buffer address
const VGA_BUFFER: *mut u8 = 0xb8000 as *mut u8;

// VGA Color codes
#[allow(dead_code)]
#[repr(u8)]
#[derive(Copy, Clone)]
enum Color {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGray = 7,
    DarkGray = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    Pink = 13,
    Yellow = 14,
    White = 15,
}

// Create color attribute byte from foreground and background colors
const fn color_code(fg: Color, bg: Color) -> u8 {
    (bg as u8) << 4 | (fg as u8)
}

#[no_mangle]
pub extern "C" fn _start() -> ! {
    // Clear screen with blue background
    clear_screen(Color::Blue);

    // Print colorful welcome message
    print_colored(b"SimpleOS", 0, 0, Color::Yellow, Color::Blue);
    print_colored(
        b" - A Rust Operating System",
        0,
        8,
        Color::White,
        Color::Blue,
    );

    // Print system info with different colors
    print_colored(b"[OK]", 2, 2, Color::LightGreen, Color::Black);
    print_colored(
        b" Bootloader loaded successfully",
        2,
        7,
        Color::LightGray,
        Color::Black,
    );

    print_colored(b"[OK]", 3, 2, Color::LightGreen, Color::Black);
    print_colored(b" Kernel initialized", 3, 7, Color::LightGray, Color::Black);

    print_colored(b"[OK]", 4, 2, Color::LightGreen, Color::Black);
    print_colored(
        b" VGA text mode enabled",
        4,
        7,
        Color::LightGray,
        Color::Black,
    );

    // Print a colorful message
    print_colored(b"Hello, World!", 6, 2, Color::LightCyan, Color::Black);
    print_colored(b"Welcome to SimpleOS!", 7, 2, Color::Pink, Color::Black);

    // Print some colored bars
    print_colored(
        b"================================",
        9,
        2,
        Color::Yellow,
        Color::Black,
    );

    // Status line at bottom with different background
    print_colored(
        b"System Status: Running",
        24,
        2,
        Color::Black,
        Color::LightGreen,
    );
    print_colored(
        b" | Press Ctrl+A then X to exit QEMU",
        24,
        25,
        Color::Black,
        Color::LightGray,
    );

    // Rainbow effect demo
    draw_rainbow(11);

    // Halt
    loop {
        unsafe {
            core::arch::asm!("hlt");
        }
    }
}

fn clear_screen(bg_color: Color) {
    let color = color_code(Color::White, bg_color);
    unsafe {
        for i in 0..(80 * 25) {
            *VGA_BUFFER.add(i * 2) = b' ';
            *VGA_BUFFER.add(i * 2 + 1) = color;
        }
    }
}

fn print_colored(s: &[u8], row: usize, col: usize, fg: Color, bg: Color) {
    let offset = (row * 80 + col) * 2;
    let color = color_code(fg, bg);
    unsafe {
        for (i, &byte) in s.iter().enumerate() {
            if col + i < 80 {
                // Don't overflow line
                *VGA_BUFFER.add(offset + i * 2) = byte;
                *VGA_BUFFER.add(offset + i * 2 + 1) = color;
            }
        }
    }
}

// Draw a rainbow bar across the screen
fn draw_rainbow(row: usize) {
    let colors = [
        Color::Red,
        Color::LightRed,
        Color::Yellow,
        Color::LightGreen,
        Color::LightCyan,
        Color::LightBlue,
        Color::Magenta,
        Color::Pink,
    ];

    let offset = row * 80 * 2;
    unsafe {
        for i in 0..80 {
            let color_idx = (i * colors.len()) / 80;
            let color = color_code(colors[color_idx], colors[color_idx]);
            *VGA_BUFFER.add(offset + i * 2) = b' ';
            *VGA_BUFFER.add(offset + i * 2 + 1) = color;
        }
    }
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    // Clear screen to red background on panic
    clear_screen(Color::Red);

    // Print panic message in white on red
    print_colored(b"KERNEL PANIC!", 10, 30, Color::White, Color::Red);

    // Print location message
    print_colored(
        b"Location: [not available]",
        12,
        10,
        Color::Yellow,
        Color::Red,
    );

    print_colored(
        b"System halted. Please reset.",
        14,
        20,
        Color::LightGray,
        Color::Red,
    );

    loop {
        unsafe {
            core::arch::asm!("hlt");
        }
    }
}
