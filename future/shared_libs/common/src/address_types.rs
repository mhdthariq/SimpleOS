#![allow(dead_code)]

use core::ops::{Add, Sub};

/// Physical memory address wrapper
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, PartialOrd, Ord)]
#[repr(transparent)]
pub struct PhysicalAddress(pub usize);

impl PhysicalAddress {
    /// Create a new physical address
    pub const fn new(addr: usize) -> Self {
        Self(addr)
    }

    /// Create a new physical address without checking
    pub const unsafe fn new_unchecked(addr: usize) -> Self {
        Self(addr)
    }

    /// Get the inner address value
    pub const fn as_usize(self) -> usize {
        self.0
    }

    /// Check if address is aligned to given alignment
    pub const fn is_aligned(self, align: usize) -> bool {
        self.0 % align == 0
    }

    /// Align down to the given alignment
    pub const fn align_down(self, align: usize) -> Self {
        Self(self.0 - (self.0 % align))
    }

    /// Align up to the given alignment
    pub const fn align_up(self, align: usize) -> Self {
        Self((self.0 + align - 1) - ((self.0 + align - 1) % align))
    }
}

impl From<usize> for PhysicalAddress {
    fn from(value: usize) -> Self {
        Self(value)
    }
}

impl From<PhysicalAddress> for usize {
    fn from(addr: PhysicalAddress) -> Self {
        addr.0
    }
}

impl Add<usize> for PhysicalAddress {
    type Output = Self;

    fn add(self, rhs: usize) -> Self::Output {
        Self(self.0 + rhs)
    }
}

impl Sub<usize> for PhysicalAddress {
    type Output = Self;

    fn sub(self, rhs: usize) -> Self::Output {
        Self(self.0 - rhs)
    }
}

/// Virtual memory address wrapper
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, PartialOrd, Ord)]
#[repr(transparent)]
pub struct VirtualAddress(pub usize);

impl VirtualAddress {
    /// Create a new virtual address
    pub const fn new(addr: usize) -> Self {
        Self(addr)
    }

    /// Create a new virtual address without checking
    pub const unsafe fn new_unchecked(addr: usize) -> Self {
        Self(addr)
    }

    /// Get the inner address value
    pub const fn as_usize(self) -> usize {
        self.0
    }

    /// Check if address is aligned to given alignment
    pub const fn is_aligned(self, align: usize) -> bool {
        self.0 % align == 0
    }

    /// Align down to the given alignment
    pub const fn align_down(self, align: usize) -> Self {
        Self(self.0 - (self.0 % align))
    }

    /// Align up to the given alignment
    pub const fn align_up(self, align: usize) -> Self {
        Self((self.0 + align - 1) - ((self.0 + align - 1) % align))
    }

    /// Convert to pointer
    pub const fn as_ptr<T>(self) -> *const T {
        self.0 as *const T
    }

    /// Convert to mutable pointer
    pub const fn as_mut_ptr<T>(self) -> *mut T {
        self.0 as *mut T
    }
}

impl From<usize> for VirtualAddress {
    fn from(value: usize) -> Self {
        Self(value)
    }
}

impl From<VirtualAddress> for usize {
    fn from(addr: VirtualAddress) -> Self {
        addr.0
    }
}

impl Add<usize> for VirtualAddress {
    type Output = Self;

    fn add(self, rhs: usize) -> Self::Output {
        Self(self.0 + rhs)
    }
}

impl Sub<usize> for VirtualAddress {
    type Output = Self;

    fn sub(self, rhs: usize) -> Self::Output {
        Self(self.0 - rhs)
    }
}
