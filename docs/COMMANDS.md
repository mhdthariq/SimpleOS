# SimpleOS Command Reference

Complete guide to all available commands and workflows for SimpleOS development.

---

## Quick Reference

### Most Common Commands

```bash
make              # Build everything
make run          # Build and run in QEMU
make clean        # Clean build artifacts
make help         # Show all targets
```

---

## Build Commands

### Basic Building

```bash
# Build everything (release mode, default)
make

# Build in debug mode
make BUILD_MODE=debug

# Build specific component
make bootloader   # Build only bootloader
make kernel       # Build only kernel
make image        # Create disk image from components
```

### Build Information

```bash
# Show detailed build information
make info

# Show component sizes
make sizes

# Verify build dependencies
make verify-deps
```

---

## Running & Testing

### QEMU Execution

```bash
# Build and run in QEMU
make run

# Run with GDB debugging (port 1234)
make debug

# Manual QEMU invocation
qemu-system-x86_64 -drive format=raw,file=target/image/simpleos.img -m 512M

# QEMU with more memory
qemu-system-x86_64 -drive format=raw,file=target/image/simpleos.img -m 1G

# QEMU with serial output
qemu-system-x86_64 -drive format=raw,file=target/image/simpleos.img -serial stdio
```

### Testing

```bash
# Run test suite (when available)
make test

# Check code without building
make check
```

---

## Code Quality

### Checking & Linting

```bash
# Check code for errors (no build)
make check

# Format code with rustfmt
make fmt

# Run clippy lints
make lint

# Check with cargo directly
cd bootloader && cargo check
cd kernel && cargo check
```

### Manual Cargo Commands

```bash
# Check bootloader
cd bootloader
cargo check --target=../build/targets/16bit_target.json

# Check kernel
cd kernel
cargo check --target=x86_64-unknown-none

# Format specific crate
cd bootloader && cargo fmt
cd kernel && cargo fmt
```

---

## Cleaning

### Clean Commands

```bash
# Clean build artifacts (keeps dependencies)
make clean

# Deep clean (removes all downloaded dependencies)
make distclean

# Clean with cargo
cargo clean
```

---

## Binary Inspection

### Hexdump Commands

```bash
# Hexdump bootloader (first 512 bytes)
make hexdump-boot

# Hexdump disk image (first 1024 bytes)
make hexdump-disk

# Full manual hexdump
hexdump -C target/16bit_target/release/bootloader
hexdump -C target/x86_64-unknown-none/release/kernel
hexdump -C target/image/simpleos.img
```

### Disassembly Commands

```bash
# Disassemble bootloader (16-bit)
make disasm-boot

# Disassemble kernel (64-bit)
make disasm-kernel

# Manual disassembly
objdump -D -b binary -m i8086 target/16bit_target/release/bootloader
objdump -D -b binary -m i386:x86-64 target/x86_64-unknown-none/release/kernel
```

### File Information

```bash
# Check bootloader size (must be 512 bytes)
stat -c%s target/16bit_target/release/bootloader

# Check boot signature (should end with 55 aa)
xxd target/16bit_target/release/bootloader | tail -1

# List all build artifacts
ls -lh target/16bit_target/release/bootloader
ls -lh target/x86_64-unknown-none/release/kernel
ls -lh target/image/simpleos.img
```

---

## Development Workflows

### Standard Development

```bash
# 1. Edit code
vim kernel/src/main.rs

# 2. Check for errors
make check

# 3. Build
make

# 4. Run and test
make run
```

### Quick Iteration

```bash
# Build and run in one command
make run

# Or with auto-rebuild (if inotify available)
make watch
```

### Debugging Workflow

```bash
# Terminal 1: Start QEMU with GDB server
make debug

# Terminal 2: Connect with GDB
gdb
(gdb) target remote :1234
(gdb) continue
(gdb) break *0x7c00    # Break at bootloader
(gdb) break *0x10000   # Break at kernel
```

---

## QEMU Controls

### Inside QEMU

```
Ctrl+A then X     Exit QEMU
Ctrl+A then C     QEMU monitor console
Ctrl+A then S     Save snapshot
Ctrl+A then R     Reset/reboot
```

### QEMU Monitor Commands

After pressing `Ctrl+A then C`:

```
info registers    Show CPU registers
info mem          Show memory mappings
quit              Exit QEMU
system_reset      Reset the system
```

---

## Debugging Commands

### GDB Commands for OS Development

```bash
# Connect to QEMU
gdb
(gdb) target remote :1234

# Set breakpoints
(gdb) break *0x7c00          # Bootloader entry
(gdb) break *0x10000         # Kernel entry

# Step through code
(gdb) si                     # Step instruction
(gdb) ni                     # Next instruction
(gdb) c                      # Continue

# Examine memory
(gdb) x/16xb 0x7c00          # Hex bytes at bootloader
(gdb) x/16xb 0xb8000         # VGA buffer
(gdb) x/16i 0x7c00           # Disassemble 16 instructions

# Show registers
(gdb) info registers
(gdb) info all-registers

# Set architecture
(gdb) set architecture i8086  # For 16-bit bootloader
(gdb) set architecture i386   # For 32-bit
```

---

## Rust Commands

### Toolchain Management

```bash
# Check Rust version
rustc --version
cargo --version

# Switch to nightly
rustup default nightly

# Add required components
rustup component add rust-src llvm-tools-preview

# Update Rust
rustup update

# Show installed toolchains
rustup show
```

### Direct Cargo Builds

```bash
# Build bootloader with cargo
cd bootloader
cargo build --release --target=../build/targets/16bit_target.json

# Build kernel with cargo
cd kernel
cargo build --release --target=x86_64-unknown-none

# Run cargo commands
cargo clean
cargo check
cargo fmt
cargo clippy
```

---

## File Operations

### Editing Key Files

```bash
# Edit bootloader
vim bootloader/src/main.rs

# Edit kernel
vim kernel/src/main.rs

# Edit Makefile
vim Makefile

# Edit documentation
vim README.md
```

### View Build Outputs

```bash
# View generated files
ls -lh target/16bit_target/release/
ls -lh target/x86_64-unknown-none/release/
ls -lh target/image/

# Check disk image
file target/image/simpleos.img
```

---

## Installation & Setup

### Initial Setup

```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install dependencies (one command)
make install-deps

# Or manually
rustup default nightly
rustup component add rust-src llvm-tools-preview
```

### QEMU Installation

```bash
# Ubuntu/Debian
sudo apt install qemu-system-x86 build-essential

# Fedora
sudo dnf install qemu-system-x86 make

# macOS
brew install qemu
xcode-select --install
```

---

## Troubleshooting Commands

### Verify Setup

```bash
# Check all dependencies
make verify-deps

# Check Rust toolchain
rustc --version
cargo --version
rustup show

# Check QEMU
qemu-system-x86_64 --version

# Check make
make --version
```

### Clean Rebuild

```bash
# Full clean and rebuild
make distclean
make

# Or step by step
make clean
make bootloader
make kernel
make image
```

### Diagnostic Commands

```bash
# Show what would be built
make -n

# Verbose make output
make V=1

# Check file sizes
make sizes

# Show build info
make info
```

---

## Advanced Commands

### Creating Bootable Media

```bash
# Write to USB drive (BE CAREFUL!)
sudo dd if=target/image/simpleos.img of=/dev/sdX bs=512

# Write to floppy image
dd if=target/image/simpleos.img of=floppy.img bs=512 count=2880

# Create ISO (requires additional tools)
# See OSDev wiki for details
```

### Extracting Components

```bash
# Extract just bootloader from image
dd if=target/image/simpleos.img of=bootloader.bin bs=512 count=1

# Extract kernel from image
dd if=target/image/simpleos.img of=kernel.bin bs=512 skip=1
```

---

## Environment Variables

### Build Configuration

```bash
# Set build mode
export BUILD_MODE=debug
make

# Or inline
BUILD_MODE=release make

# Set QEMU path (if not in PATH)
export QEMU=/path/to/qemu-system-x86_64
make run
```

---

## Quick Recipes

### Change Boot Message

```bash
vim bootloader/src/main.rs
# Edit print_string_colored() calls
make run
```

### Change Kernel Colors

```bash
vim kernel/src/main.rs
# Edit Color:: enums in print_colored() calls
make run
```

### Add New Feature

```bash
vim kernel/src/main.rs
# Add your code
make check          # Check for errors
make                # Build
make run            # Test
```

### Debug Crash

```bash
make debug          # Terminal 1
gdb                 # Terminal 2
(gdb) target remote :1234
(gdb) c             # Continue until crash
(gdb) info registers
(gdb) bt            # Backtrace
```

---

## Summary Table

| Task | Command |
|------|---------|
| **Build** | `make` |
| **Run** | `make run` |
| **Clean** | `make clean` |
| **Debug** | `make debug` |
| **Check** | `make check` |
| **Format** | `make fmt` |
| **Info** | `make info` |
| **Help** | `make help` |

---

## Getting Help

```bash
# Show all Makefile targets
make help

# Show build information
make info

# Read documentation
cat README.md
cat QUICKSTART.md
cat PROJECT_STRUCTURE.md
cat future/README.md
```

---

**For more information:**
- `README.md` - Full project documentation
- `QUICKSTART.md` - 30-second start guide
- `PROJECT_STRUCTURE.md` - Project organization
- `COLORS.md` - VGA color system
- `future/README.md` - Development roadmap

---

**Last Updated:** December 30, 2025  
**Version:** 1.2.0
