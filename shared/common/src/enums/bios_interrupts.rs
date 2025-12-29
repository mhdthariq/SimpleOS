#[repr(u8)]
/// BIOS interrupts number for each interrupt type used in
/// the kernel.
pub enum BiosInterrupts {
    Video = 0x10,
    Disk = 0x13,
    Memory = 0x15,
}
#[repr(u8)]
/// Disk interrupt number for each function used in the
/// kernel.
pub enum DiskInterrupt {
    ExtendedRead = 0x42,
}
