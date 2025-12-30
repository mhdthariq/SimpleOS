# SimpleOS

A minimal bare-metal operating system written in Rust, featuring a custom bootloader that loads a kernel from disk. This is an educational project designed to demonstrate fundamental OS development concepts.

## Overview

SimpleOS demonstrates fundamental OS development concepts:
- Custom bootloader written in 16-bit real mode
- Disk I/O using BIOS interrupts
- Kernel loading from disk sectors
- **Colorful VGA text mode output** with 16-color palette
- Bare-metal Rust programming

## Features

- **Multi-stage Boot Process**: Bootloader loads kernel from disk using BIOS INT 13h
- **Custom Bootloader**: 512-byte boot sector that displays boot messages
- **Colorful Display**: 16-color VGA text mode with colored boot messages and status indicators
- **Standalone Kernel**: Runs in protected/long mode with VGA text output
- **Workspace Architecture**: Organized as a Cargo workspace with separate bootloader and kernel crates
- **No Standard Library**: Pure `no_std` environment for complete hardware control

## Project Structure

```
simpleos/
├── bootloader/              # 16-bit bootloader (512 bytes)
│   ├── src/
│   │   └── main.rs         # Bootloader entry point
│   ├── linker.ld           # Bootloader linker script
│   └── Cargo.toml
├── kernel/                  # Main kernel
│   ├── src/
│   │   └── main.rs         # Kernel entry point
│   ├── linker.ld           # Kernel linker script
│   └── Cargo.toml
├── future/                  # Future features (not built yet)
│   ├── shared_libs/        # Shared utilities
│   ├── advanced_bootloader/  # Multi-stage bootloader
│   └── drivers/            # Advanced drivers
├── docs/                    # Comprehensive documentation
│   ├── COMMANDS.md         # Command reference
│   ├── COLORS.md           # VGA color system
│   ├── PROJECT_STRUCTURE.md # Project organization
│   ├── SETUP.md            # Setup and troubleshooting
│   ├── ROADMAP.md          # Development roadmap
│   └── CONTRIBUTING.md     # Contributing guidelines
├── build/
│   └── targets/
│       └── 16bit_target.json   # Custom 16-bit x86 target
├── Makefile                # Main build system
└── Cargo.toml              # Workspace configuration
```

## Prerequisites

- **Rust Nightly**: Required for unstable features and `build-std`
- **QEMU**: For testing the OS (`qemu-system-x86_64`)
- Standard build tools: `cargo`, `rustup`

### Installation

```bash
# Install Rust (if not already installed)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install nightly toolchain
rustup toolchain install nightly
rustup default nightly

# Add required components
rustup component add rust-src llvm-tools-preview

# Install QEMU
# Ubuntu/Debian:
sudo apt install qemu-system-x86

# macOS:
brew install qemu

# Fedora:
sudo dnf install qemu-system-x86
```

## Building

### Quick Build and Run

```bash
# Build and run in one command (recommended)
make run

# Or just build everything
make

# Build in debug mode
make BUILD_MODE=debug
```

This creates:
- `target/16bit_target/release/bootloader` - The boot sector (512 bytes)
- `target/x86_64-unknown-none/release/kernel` - The kernel binary
- `target/image/simpleos.img` - Complete bootable disk image (10MB)

## Running

### Using QEMU

```bash
# Method 1: Use Makefile (recommended)
make run

# Method 2: Direct QEMU command
qemu-system-x86_64 -drive format=raw,file=target/image/simpleos.img -m 512M
```

### Expected Output

When you run the OS, you should see colorful output:

```
SeaBIOS (Version 1.x.x)
...
[BOOT] Booting from Hard Disk...
[ OK ] Kernel loaded successfully
[INFO] Jumping to kernel...

SimpleOS - A Rust Operating System          (Yellow/White on Blue)

  [OK] Bootloader loaded successfully        (Green on Black)
  [OK] Kernel initialized                    (Green on Black)
  [OK] VGA text mode enabled                 (Green on Black)

  Hello, World!                              (Cyan on Black)
  Welcome to SimpleOS!                       (Pink on Black)

  [Rainbow color bar]                        (Multi-color gradient)

  System Status: Running | Press Ctrl+A...   (Status bar at bottom)
```

**Color Features:**
- **Bootloader messages** - Colored text using BIOS (Yellow/Green/Cyan)
- **Kernel display** - Full 16-color VGA palette with colored status messages
- **Rainbow effect** - Multi-color gradient bar demonstration
- **Status indicators** - Green `[OK]` tags, color-coded messages

See [docs/COLORS.md](docs/COLORS.md) for detailed color documentation.

### QEMU Controls

- **Exit QEMU**: Press `Ctrl+A` then `X`
- **Pause/Resume**: Press `Ctrl+A` then `C` for console, then `c` to continue
- **Reset**: Press `Ctrl+A` then `R`

## Makefile Targets

SimpleOS uses a comprehensive Makefile for all build tasks:

```bash
make              # Build everything (release mode)
make run          # Build and run in QEMU
make debug        # Run with GDB debugger (port 1234)
make clean        # Clean build artifacts
make check        # Check code without building
make info         # Show build information
make help         # Show all available targets

# Development helpers
make fmt          # Format code with rustfmt
make lint         # Run clippy lints
make hexdump-boot # Show bootloader hex dump
make disasm-boot  # Disassemble bootloader
```

For all targets and detailed command documentation, see: [docs/COMMANDS.md](docs/COMMANDS.md)

## How It Works

### Boot Process

1. **BIOS Stage**
   - BIOS loads the first sector (512 bytes) from disk to `0x7C00`
   - Checks for boot signature `0xAA55` at bytes 510-511
   - Jumps to `0x7C00` to start bootloader

2. **Bootloader Stage** (`bootloader/src/main.rs`)
   - Sets up segment registers (DS, ES, SS)
   - Prints "Booting from Hard Disk..." using BIOS INT 10h
   - Loads kernel from disk using BIOS INT 13h:
     - Reads 16 sectors starting from sector 2
     - Loads to memory address `0x10000`
   - Prints "Jumping to kernel..."
   - Jumps to kernel at `0x10000`

3. **Kernel Stage** (`kernel/src/main.rs`)
   - Clears VGA text buffer at `0xB8000`
   - Prints "Hello, World!" directly to VGA memory
   - Halts the CPU with `hlt` instruction

### Memory Map

```
0x00000000 - 0x000003FF  : Real Mode IVT (Interrupt Vector Table)
0x00000400 - 0x000004FF  : BIOS Data Area
0x00000500 - 0x00007BFF  : Free memory (real mode)
0x00007C00 - 0x00007DFF  : Bootloader (512 bytes)
0x00007E00 - 0x0000FFFF  : Free memory
0x00010000 - 0x0001FFFF  : Kernel code (loaded here)
0x000A0000 - 0x000BFFFF  : VGA memory
0x000B8000 - 0x000B8FA0  : VGA text mode buffer (80x25)
0x00100000+              : Extended memory (1MB+)
```

## Development

### Modifying the Bootloader

Edit `bootloader/src/main.rs`:

```rust
// Example: Change boot message
print_string(b"My Custom OS Loading...\r\n");
```

### Modifying the Kernel

Edit `kernel/src/main.rs`:

```rust
// Example: Print different message
print_string(b"Welcome to MyOS!", 0, 0);
```

### Building Individual Components

```bash
# Build only bootloader
make bootloader

# Build only kernel
make kernel

# Or manually with cargo
cd bootloader && cargo build --release --target=../build/targets/16bit_target.json
cd kernel && cargo build --release --target=x86_64-unknown-none
```

## Technical Details

### Bootloader Specifications

- **Size**: Exactly 512 bytes (boot sector size)
- **Load Address**: `0x7C00` (BIOS loads here)
- **Architecture**: x86 16-bit real mode
- **Boot Signature**: `0xAA55` at bytes 510-511
- **Disk Interface**: BIOS INT 13h (CHS addressing)

### Kernel Specifications

- **Load Address**: `0x100000` (1MB - standard kernel location)
- **Architecture**: x86-64 long mode
- **Binary Format**: Raw binary (no ELF headers)
- **Display**: VGA text mode (80x25 characters)
- **Memory**: Direct VGA buffer access at `0xB8000`

### Compilation Targets

**Bootloader**: Custom 16-bit target (`build/targets/16bit_target.json`)
- CPU: i386 with 16-bit code generation
- Features: No SSE, no red-zone, static linking
- Output: Raw binary format

**Kernel**: x86_64-unknown-none
- CPU: x86-64
- Model: Kernel code model
- Features: No standard library, no unwinding
- Output: Raw binary format

## Troubleshooting

### Build Errors

**Error**: "error: failed to run custom build command"
```bash
# Solution: Make sure you're using nightly Rust
rustup default nightly
rustup component add rust-src
```

**Error**: "Make: command not found"
```bash
# Install make:
# Ubuntu/Debian: sudo apt install build-essential
# macOS: xcode-select --install
# Or use cargo directly - see "Building Individual Components"
```

**Error**: "linker script not found"
```bash
# Solution: Ensure you're in the project root directory
cd /path/to/simpleos
make
```

### Runtime Issues

**QEMU shows blank screen**
- Check that the disk image was created: `ls -lh target/image/simpleos.img`
- Verify bootloader size is exactly 512 bytes: `make info`
- Try with debug output: `qemu-system-x86_64 -drive format=raw,file=target/image/simpleos.img -serial stdio -d int`

**"No bootable device" error**
- Bootloader must be exactly 512 bytes
- Must have magic signature `0xAA55` at end
- Verify: `hexdump -C target/16bit_target/release/bootloader | tail -1`

**Kernel doesn't load**
- Check kernel binary exists: `ls -lh target/x86_64-unknown-none/release/kernel`
- Verify disk image contains kernel: `make hexdump-disk`
- Bootloader reads starting at sector 2 (byte 512)

## Cleaning

```bash
# Clean build artifacts (keeps dependencies)
make clean

# Deep clean everything (including dependencies)
make distclean

# Clean with cargo directly
cargo clean
```

## Development Roadmap

SimpleOS has a comprehensive development plan with 10 phases:

**Completed:**
- ✅ Phase 1: Foundation (bootloader, kernel, VGA colors)

**Upcoming:**
- 🔜 Phase 2: Protected Mode (GDT, A20 line)
- 📋 Phase 3: Long Mode (64-bit, paging)
- 📋 Phase 4: Memory Management
- 📋 Phase 5: Interrupt Handling
- 📋 Phase 6: Device Drivers
- 📋 Phase 7: File System
- 📋 Phase 8: Process Management
- 📋 Phase 9: User Space
- 📋 Phase 10: Advanced Features

The `future/` directory contains code ready for integration:
- **Advanced Bootloader** (`future/advanced_bootloader/`): Multi-stage boot
- **Shared Libraries** (`future/shared_libs/`): GDT, paging utilities
- **Advanced Drivers** (`future/drivers/`): Enhanced VGA driver

See [docs/ROADMAP.md](docs/ROADMAP.md) for the complete development plan and timeline.

## Documentation

Comprehensive documentation is available in the `docs/` directory:

- **[QUICKSTART.md](QUICKSTART.md)** - Get started in 30 seconds
- **[docs/COMMANDS.md](docs/COMMANDS.md)** - Complete command reference
- **[docs/COLORS.md](docs/COLORS.md)** - VGA color system guide
- **[docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md)** - Project organization
- **[docs/SETUP.md](docs/SETUP.md)** - Setup and troubleshooting
- **[docs/ROADMAP.md](docs/ROADMAP.md)** - Development roadmap
- **[docs/CONTRIBUTING.md](docs/CONTRIBUTING.md)** - How to contribute
- **[CHANGELOG.md](CHANGELOG.md)** - Version history

## Resources

- [OSDev Wiki](https://wiki.osdev.org/) - Comprehensive OS development resource
- [Writing an OS in Rust](https://os.phil-opp.com/) - Excellent tutorial series
- [Rust Embedded Book](https://rust-embedded.github.io/book/) - Embedded Rust guide
- [Intel x86 Manual](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html) - CPU architecture reference
- [BIOS Interrupt List](http://www.ctyme.com/intr/int.htm) - BIOS interrupt reference

## License

[Specify your license here]

## Author

Muhammad Thariq

## Contributing

Contributions are welcome! Please read [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines on:
- Development setup
- Coding standards
- Testing procedures
- Submitting pull requests
- Areas needing help

Feel free to submit issues or pull requests. Check [docs/ROADMAP.md](docs/ROADMAP.md) for planned features.