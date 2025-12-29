#![no_std]
#![no_main]

use core::arch::asm;

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
        );
    }

    main();
}

#[inline(never)]
fn main() -> ! {
    let msg = b"Hello, World!";
    for &ch in msg {
        unsafe {
            asm!(
                "mov ah, 0x0E",   // INT 10h function to print a char
                "mov al, {0}",    // The input ASCII char
                "int 0x10",       // Call the BIOS Interrupt Function
                in(reg_byte) ch,  // {0} Will become the register with the char
                out("ax") _,      // Lock the 'ax' as output reg
            );
        }
    }

    unsafe {
        asm!("hlt", options(noreturn)); // Halt the system
    }
}

#[panic_handler]
pub fn panic_handler(_info: &core::panic::PanicInfo) -> ! {
    loop {}
}
