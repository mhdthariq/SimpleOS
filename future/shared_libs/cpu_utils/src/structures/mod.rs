#![allow(dead_code)]

pub mod global_descriptor_table;
pub mod paging;

// Re-export commonly used structures
pub use global_descriptor_table::*;
