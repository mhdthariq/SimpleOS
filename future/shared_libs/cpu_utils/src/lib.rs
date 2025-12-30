#![no_std]
#![allow(dead_code)]
#![feature(asm_const)]

pub mod structures;

// Re-export commonly used items
pub use structures::global_descriptor_table::*;
pub use structures::paging;
