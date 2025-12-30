# SimpleOS Project Structure

**Clean, organized, and ready for development!**

## Current Directory Layout

```
simpleos/
├── bootloader/                 # 16-bit bootloader (512 bytes)
│   ├── .cargo/
│   │   └── config.toml        # Bootloader build configuration
│   ├── src/
│   │   └── main.rs            # Bootloader entry point
│   ├── build.rs               # Build script for linker
│   ├── linker.ld              # Boot sector linker script
│   └── Cargo.toml             # Bootloader dependencies
│
├── kernel/                     # Main kernel (64-bit)
│   ├── .cargo/
│   │   └── config.toml        # Kernel build configuration
│   ├── src/
│   │   └── main.rs            # Kernel entry point with VGA
│   ├── build.rs               # Build script for linker
│   ├── linker.ld              # Kernel linker script
│   └── Cargo.toml             # Kernel dependencies
│
├── future/                     # Future features (not built)
│   ├── shared_libs/           # Shared libraries for later
│   │   ├── common/            # Common types & constants
│   │   └── cpu_utils/         # GDT, paging, etc.
│   ├── advanced_bootloader/   # Multi-stage bootloader
│   │   ├── first_stage/       # Protected mode transition
│   │   └── second_stage/      # Long mode setup
│   ├── drivers/               # Advanced drivers
│   │   └── vga_display/       # Full VGA driver
│   └── README.md              # Roadmap & integration guide
│
├── build/                      # Build artifacts
│   └── targets/
│       └── 16bit_target.json  # Custom 16-bit target spec
│
├── .cargo/
│   └── config.toml            # Workspace cargo config
│
├── target/                     # Build output (generated)
│   ├── 16bit_target/
│   │   └── release/
│   │       └── bootloader     # 512-byte boot sector
│   ├── x86_64-unknown-none/
│   │   └── release/
│   │       └── kernel         # Kernel binary
│   └── image/
│       └── simpleos.img       # Final bootable disk image
│
├── Makefile                    # Main build system
├── Cargo.toml                  # Workspace configuration
├── rust-toolchain.toml         # Rust toolchain specification
│
└── Documentation/
    ├── README.md               # Main project documentation
    ├── QUICKSTART.md           # 30-second getting started
    ├── SETUP.md                # What was fixed & why
    ├── COLORS.md               # VGA color system guide
    ├── CHANGELOG.md            # Version history
    └── PROJECT_STRUCTURE.md    # This file
```

## Clean Architecture

### Active Components (Built)

```
bootloader/  ──┐
               ├──> Makefile ──> target/image/simpleos.img
kernel/     ──┘
```

**What's included in the build:**
- `bootloader/` - 512-byte boot sector
- `kernel/` - Main OS kernel
- Both are combined into `simpleos.img`

### Future Components (Not Built)

```
future/
├── shared_libs/          [Ready to integrate when needed]
├── advanced_bootloader/  [For protected/long mode]
└── drivers/              [Advanced VGA driver]
```

**What's NOT in the build (yet):**
- Advanced multi-stage bootloader
- Shared utility libraries
- Complex drivers

These are saved for future development phases.

## File Purposes

### Root Level

| File | Purpose |
|------|---------|
| `Makefile` | **Main build system** - Use this for all builds |
| `Cargo.toml` | Workspace configuration |
| `rust-toolchain.toml` | Specifies Rust nightly |

### Bootloader Files

| File | Purpose |
|------|---------|
| `bootloader/src/main.rs` | Bootloader code (prints messages, loads kernel) |
| `bootloader/linker.ld` | Ensures exactly 512 bytes with 0xAA55 signature |
| `bootloader/build.rs` | Links with linker script |
| `bootloader/.cargo/config.toml` | 16-bit build configuration |

### Kernel Files

| File | Purpose |
|------|---------|
| `kernel/src/main.rs` | Kernel code (VGA output, colors) |
| `kernel/linker.ld` | Kernel memory layout (loads at 0x100000) |
| `kernel/build.rs` | Links with linker script |
| `kernel/.cargo/config.toml` | 64-bit build configuration |

## Build Flow

```
make
  │
  ├─> Build bootloader (16-bit)
  │   └─> target/16bit_target/release/bootloader (512 bytes)
  │
  ├─> Build kernel (64-bit)
  │   └─> target/x86_64-unknown-none/release/kernel (~4KB)
  │
  └─> Create disk image
      └─> target/image/simpleos.img (10MB)
          ├─ Sector 0: bootloader
          └─ Sectors 1+: kernel
```

## Memory Layout at Runtime

```
Address      | Content
-------------|------------------------------------------
0x00000000   | BIOS IVT & data area
0x00007C00   | Bootloader (loaded by BIOS)
0x00010000   | Kernel (loaded by bootloader)
0x000B8000   | VGA text buffer (80×25 chars)
0x00100000+  | Extended memory (for future use)
```

## Build Artifacts

### Generated by Build

```
target/
├── 16bit_target/release/bootloader    [512 bytes - boot sector]
├── x86_64-unknown-none/release/kernel [~4KB - main kernel]
└── image/simpleos.img                 [10MB - disk image]
```

### Generated by Cargo

```
target/
├── debug/              [Debug build cache]
├── release/            [Release build cache]
└── .rustc_info.json    [Rust compiler info]
```

## What Got Cleaned Up

### Deleted (No Longer Needed)

- ❌ `src/main.rs` - Old single-file bootloader
- ❌ `build.rs` - Root build script (moved to components)
- ❌ `linker.ld` - Root linker script (moved to components)
- ❌ `build_os.sh` - Replaced by Makefile
- ❌ `run.sh` - Replaced by `make run`
- ❌ `examine.sh` - Replaced by Makefile targets

### Moved to `future/`

- 📦 `shared/` → `future/shared_libs/`
- 📦 `kernel/stages/` → `future/advanced_bootloader/`
- 📦 `kernel/src/drivers/` → `future/drivers/`
- 📦 `simpleos-macros/` → Deleted (can recreate if needed)

## Dependencies

### External Crates (None!)

Current build has **ZERO external dependencies**:
- ✅ `bootloader/` - Only uses `core`
- ✅ `kernel/` - Only uses `core`

This keeps the project:
- Simple and understandable
- Fast to compile
- Easy to debug
- No dependency hell

### Build-Time Requirements

- Rust nightly (for `build-std`)
- `rust-src` component
- `llvm-tools-preview` component (optional)

Install with:
```bash
rustup default nightly
rustup component add rust-src llvm-tools-preview
```

## Makefile Targets

### Most Used

```bash
make           # Build everything
make run       # Build and run in QEMU
make clean     # Clean build artifacts
make help      # Show all targets
```

### Development

```bash
make check     # Check without building
make fmt       # Format code
make lint      # Run clippy
make info      # Show build info
```

### Debugging

```bash
make debug         # Run with GDB on port 1234
make hexdump-boot  # Show bootloader hex
make hexdump-disk  # Show disk image hex
make disasm-boot   # Disassemble bootloader
make disasm-kernel # Disassemble kernel
```

## Size Constraints

| Component | Size | Reason |
|-----------|------|--------|
| Bootloader | Exactly 512 bytes | BIOS boot sector requirement |
| Kernel | ~4-5 KB | No constraint, room to grow |
| Disk image | 10 MB | Arbitrary (for future file system) |

## Adding New Features

### To Current Build

1. Edit `bootloader/src/main.rs` or `kernel/src/main.rs`
2. Run `make`
3. Test with `make run`

### From Future Directory

1. Read `future/README.md` for roadmap
2. Move component when ready
3. Update `Cargo.toml` workspace
4. Update `Makefile` if needed

## Code Statistics

```
Bootloader: ~100 lines Rust + 30 lines assembly
Kernel:     ~180 lines Rust
Makefile:   ~280 lines
Docs:       ~2000 lines markdown
```

## Key Principles

1. **Simple First** - Current implementation is intentionally simple
2. **Room to Grow** - `future/` has advanced code ready
3. **Clean Build** - Makefile-based, no shell scripts
4. **Well Documented** - Every file has a purpose
5. **No Bloat** - Only what's needed is in the build

## Quick Reference

### I want to...

| Task | Command |
|------|---------|
| Build the OS | `make` |
| Run the OS | `make run` |
| Clean everything | `make clean` |
| Check for errors | `make check` |
| Format code | `make fmt` |
| See build info | `make info` |
| Debug with GDB | `make debug` |
| Add boot message | Edit `bootloader/src/main.rs` |
| Change colors | Edit `kernel/src/main.rs` |
| See roadmap | Read `future/README.md` |

## Summary

**Active (2 crates):**
- `bootloader/` - Loads kernel from disk
- `kernel/` - Displays colorful output

**Future (3 components):**
- `future/shared_libs/` - For later integration
- `future/advanced_bootloader/` - Multi-stage boot
- `future/drivers/` - Advanced drivers

**Build System:**
- Makefile with 20+ targets
- Zero external dependencies
- Fast, clean builds

**Result:**
- Clean, organized project ✅
- Easy to understand ✅
- Ready to extend ✅

---

**Last updated:** December 30, 2024  
**Version:** 1.1.0 (Color Update)