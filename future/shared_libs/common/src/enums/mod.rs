#![allow(dead_code)]

pub mod bios_interrupts;
pub mod general;
pub mod vga;

// Re-export all enums
pub use bios_interrupts::*;
pub use general::*;
pub use vga::*;
