#![allow(dead_code)]

// Memory addresses
pub const DISK_NUMBER_OFFSET: usize = 0x7BFF;
pub const MEMORY_MAP_OFFSET: usize = 0x8000;
pub const MEMORY_MAP_LENGTH: usize = 0x7FFF;
pub const MEMORY_MAP_MAGIC_NUMBER: u32 = 0x534D4150; // "SMAP"
pub const SECOND_STAGE_OFFSET: usize = 0x7E00;

pub mod addresses {
    pub const KERNEL_OFFSET: usize = 0x100000; // 1MB - standard kernel load address
    pub const VGA_BUFFER: usize = 0xB8000;
}
