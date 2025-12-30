#![allow(dead_code)]

use core::fmt;

/// Errors that can occur during paging operations
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PagingError {
    /// The table is not a root table
    NotRootTable,
    /// The table is full
    TableFull,
    /// There is no mapping to this entry
    NoMapping,
    /// This entry contains memory block and not a table
    NotATable,
    /// Invalid address alignment
    InvalidAlignment,
    /// Out of memory
    OutOfMemory,
}

impl fmt::Display for PagingError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::NotRootTable => write!(f, "The table is not a root table"),
            Self::TableFull => write!(f, "The table is full"),
            Self::NoMapping => write!(f, "There is no mapping to this entry"),
            Self::NotATable => write!(f, "This entry contains memory block and not a table"),
            Self::InvalidAlignment => write!(f, "Invalid address alignment"),
            Self::OutOfMemory => write!(f, "Out of memory"),
        }
    }
}

/// Alias for Result with PagingError
pub type PagingResult<T> = Result<T, PagingError>;
