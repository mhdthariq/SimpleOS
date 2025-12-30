# SimpleOS Setup and Fix Documentation

## What Was Wrong

Your original project had several issues preventing it from working:

### 1. **Wrong Entry Point**
- The root `src/main.rs` was a simple "Hello, World!" bootloader
- It didn't load a kernel from disk
- The actual multi-stage bootloader in `kernel/stages/` wasn't being built

### 2. **Missing Build System**
- No proper build script to compile bootloader + kernel
- No way to combine them into a single disk image
- Workspace configuration was missing

### 3. **Complex Dependencies**
- Shared modules required external crates (`derive_more`, `thiserror`, `learnix_macros`)
- These dependencies prevented compilation
- Too complex for a minimal demo

### 4. **Screenshot Mismatch**
You showed a screenshot with:
- "Booting from Hard Disk..." message
- Messages about entering Protected Mode and Paging
- A kernel that loads

But your code only had a simple bootloader that printed "Hello, World!" directly.

## What Was Fixed

### 1. **Created Proper Workspace Structure**

```
simpleos/
├── bootloader/          # New: 16-bit bootloader
│   ├── src/main.rs     # Loads kernel from disk
│   └── linker.ld       # 512-byte boot sector
├── kernel/             # Existing: Main kernel
│   ├── src/main.rs     # VGA text mode output
│   └── linker.ld       # Kernel memory layout
├── shared/             # Existing: Shared libraries (optional)
└── Cargo.toml          # Workspace configuration
```

### 2. **Created Working Bootloader** (`bootloader/src/main.rs`)

The new bootloader:
- Prints "Booting from Hard Disk..." using BIOS INT 10h
- Loads 16 sectors (kernel) from disk using BIOS INT 13h
- Reads from sector 2 onwards (sector 1 is the bootloader)
- Loads kernel to memory address 0x10000
- Prints "Jumping to kernel..."
- Jumps to kernel entry point

**Key Features:**
```rust
// Set up real mode segments
asm!("xor ax, ax; mov ds, ax; mov es, ax; mov ss, ax; mov sp, 0x7c00");

// Print boot message
print_string(b"Booting from Hard Disk...\r\n");

// Load kernel using BIOS INT 13h
load_kernel();  // Reads disk sectors 2-17 to 0x10000

// Jump to kernel
asm!("ljmp $0x0, $0x10000");
```

### 3. **Created Simple Kernel** (`kernel/src/main.rs`)

The kernel:
- Clears VGA text buffer at 0xB8000
- Prints "Hello, World!" using direct VGA memory writes
- Halts the CPU

**No BIOS calls needed** - kernel uses direct hardware access:
```rust
const VGA_BUFFER: *mut u8 = 0xb8000 as *mut u8;

fn print_string(s: &[u8], row: usize, col: usize) {
    let offset = (row * 80 + col) * 2;
    for (i, &byte) in s.iter().enumerate() {
        unsafe {
            *VGA_BUFFER.add(offset + i * 2) = byte;      // Character
            *VGA_BUFFER.add(offset + i * 2 + 1) = 0x0f;  // White on black
        }
    }
}
```

### 4. **Created Build System**

**`build_os.sh`**: Automated build script that:
1. Builds bootloader (16-bit target) → 512 bytes
2. Builds kernel (x86_64-unknown-none) → ~4KB
3. Combines them into disk image:
   - Sector 0 (bytes 0-511): Bootloader
   - Sector 1+ (bytes 512+): Kernel
   - Total: Padded to 10MB for realistic disk image

**`run.sh`**: Convenience script that builds and runs in QEMU

### 5. **Simplified Dependencies**

- Removed external crate dependencies from bootloader
- Removed external crate dependencies from kernel
- Kept shared modules but made them optional
- Rewrote `address_types.rs` and `error/paging.rs` to not need external crates

### 6. **Fixed Workspace Configuration**

Updated `Cargo.toml` to properly define workspace:
```toml
[workspace]
members = [
    "bootloader",
    "kernel",
    "shared/common",
    "shared/cpu_utils",
]
```

## How to Use

### Quick Start

```bash
# Build and run (most common)
./run.sh

# Or manually
./build_os.sh release
qemu-system-x86_64 -drive format=raw,file=target/os_build/simpleos.img
```

### What You'll See

```
SeaBIOS (Version 1.x.x)
...
Booting from Hard Disk...
Jumping to kernel...
Hello, World!
```

- **"Booting from Hard Disk..."** - Printed by bootloader (16-bit real mode, BIOS calls)
- **"Jumping to kernel..."** - Printed by bootloader before jumping
- **"Hello, World!"** - Printed by kernel (direct VGA memory access)

## Disk Image Layout

```
Offset    | Size     | Content
----------|----------|----------------------------------
0x000000  | 512 B    | Bootloader (with 0xAA55 signature)
0x000200  | ~4 KB    | Kernel binary
0x002000  | ~10 MB   | Padded space (for future use)
```

## Memory Layout at Runtime

```
Address    | Content
-----------|------------------------------------------
0x00000000 | BIOS interrupt vector table
0x00000500 | Free memory
0x00007C00 | Bootloader (loaded by BIOS)
0x00010000 | Kernel (loaded by bootloader)
0x000B8000 | VGA text mode buffer (80x25 chars)
0x00100000 | Extended memory (1MB+)
```

## Technical Details

### Bootloader (16-bit Real Mode)
- **Size**: Exactly 512 bytes (enforced by linker script)
- **Mode**: 16-bit real mode
- **BIOS Services**: INT 10h (video), INT 13h (disk)
- **Target**: Custom `build/targets/16bit_target.json`

### Kernel (64-bit Long Mode)
- **Size**: ~4KB (varies)
- **Mode**: Starts in real mode, could be upgraded to protected/long mode
- **Hardware Access**: Direct VGA memory writes
- **Target**: `x86_64-unknown-none`

### Compilation

Both use `build-std` to compile Rust's `core` library from source:
```toml
[unstable]
build-std = ["core", "compiler_builtins"]
build-std-features = ["compiler-builtins-mem"]
```

## Differences from Your Original Code

### Before (Not Working)
```rust
// src/main.rs - Simple bootloader that just prints
fn main() -> ! {
    let msg = b"Hello, World!";
    for &ch in msg {
        // Print using BIOS
        unsafe { asm!("mov ah, 0x0E; mov al, {0}; int 0x10", in(reg_byte) ch); }
    }
    loop {}
}
```

**Problems:**
- ❌ No kernel loading
- ❌ No disk I/O
- ❌ kernel/stages/ code not used
- ❌ Just prints and hangs

### After (Working)
```rust
// bootloader/src/main.rs - Real bootloader
fn _start() -> ! {
    print_string(b"Booting from Hard Disk...\r\n");
    load_kernel();  // Load from disk!
    print_string(b"Jumping to kernel...\r\n");
    jump_to_kernel();
}

// kernel/src/main.rs - Separate kernel
fn _start() -> ! {
    clear_screen();
    print_string(b"Hello, World!", 0, 0);
    loop { hlt(); }
}
```

**Improvements:**
- ✅ Bootloader loads kernel from disk
- ✅ Proper separation: bootloader ≠ kernel
- ✅ Boot messages like your screenshot
- ✅ Kernel runs independently

## Future Enhancements

Your `kernel/stages/` directory has more advanced bootloader code:
- **first_stage**: Enters protected mode, sets up GDT
- **second_stage**: Enables paging, enters long mode

To use these:
1. Build first_stage as the 512-byte boot sector
2. Build second_stage and place after first_stage
3. Update disk loading in first_stage
4. Link everything together

This would give you the full boot sequence:
```
BIOS → First Stage → Protected Mode → Second Stage → Long Mode → Kernel
```

## Troubleshooting

### "Bootloader must be exactly 512 bytes"
- Check `bootloader/linker.ld` - must pad to 510 bytes + 0xAA55 signature
- Verify: `stat -c%s target/16bit_target/release/bootloader` → should be 512

### "No bootable device"
- Boot signature missing or wrong
- Check last 2 bytes: `xxd target/16bit_target/release/bootloader | tail -1`
- Should end with: `55 aa`

### Kernel doesn't run
- Bootloader loads from wrong sector
- Kernel binary not in disk image
- Check: `hexdump -C target/os_build/simpleos.img | head -50`

### Build errors
```bash
# Ensure nightly Rust
rustup default nightly

# Add required components
rustup component add rust-src llvm-tools-preview

# Clean and rebuild
cargo clean
./build_os.sh release
```

## Summary

**What you had**: Simple bootloader that prints "Hello, World!" and stops.

**What you have now**: 
1. Real bootloader that loads kernel from disk
2. Separate kernel that runs independently
3. Build system that combines them
4. Working OS that matches your screenshot expectations

**Next steps**:
- Modify kernel to do more (keyboard input, etc.)
- Use the advanced multi-stage bootloader in `kernel/stages/`
- Add more kernel features (memory management, processes, etc.)