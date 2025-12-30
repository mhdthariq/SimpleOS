#![allow(dead_code)]

/// Page table levels for x86_64 paging
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
#[repr(u8)]
pub enum PageTableLevel {
    /// Page Table Entry (Level 1)
    PTE = 1,
    /// Page Directory Entry (Level 2)
    PDE = 2,
    /// Page Directory Pointer Table Entry (Level 3)
    PDPTE = 3,
    /// Page Map Level 4 Entry (Level 4)
    PML4E = 4,
}

impl PageTableLevel {
    /// Get the shift amount for this level
    pub const fn shift(self) -> usize {
        12 + (self as usize - 1) * 9
    }

    /// Get the index mask for this level
    pub const fn index_mask(self) -> usize {
        0o777 // 9 bits = 0x1FF
    }

    /// Get the next lower level
    pub const fn next_lower(self) -> Option<Self> {
        match self {
            Self::PML4E => Some(Self::PDPTE),
            Self::PDPTE => Some(Self::PDE),
            Self::PDE => Some(Self::PTE),
            Self::PTE => None,
        }
    }

    /// Check if this is the lowest level
    pub const fn is_lowest(self) -> bool {
        matches!(self, Self::PTE)
    }

    /// Check if this is the highest level
    pub const fn is_highest(self) -> bool {
        matches!(self, Self::PML4E)
    }
}

impl From<u8> for PageTableLevel {
    fn from(value: u8) -> Self {
        match value {
            1 => Self::PTE,
            2 => Self::PDE,
            3 => Self::PDPTE,
            4 => Self::PML4E,
            _ => panic!("Invalid page table level"),
        }
    }
}

impl From<PageTableLevel> for u8 {
    fn from(level: PageTableLevel) -> Self {
        level as u8
    }
}

impl From<PageTableLevel> for usize {
    fn from(level: PageTableLevel) -> Self {
        level as usize
    }
}

/// Memory region types
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
#[repr(u8)]
pub enum MemoryRegionType {
    /// Usable memory
    Usable = 1,
    /// Reserved memory
    Reserved = 2,
    /// ACPI reclaimable memory
    AcpiReclaimable = 3,
    /// ACPI NVS memory
    AcpiNvs = 4,
    /// Bad memory
    BadMemory = 5,
}
