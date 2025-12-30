# SimpleOS Quick Start Guide

## TL;DR - Get Running in 30 Seconds

```bash
# 1. Make sure you have Rust nightly
rustup default nightly
rustup component add rust-src

# 2. Build and run
make run

# That's it! You should see colorful output:
# [BOOT] Booting from Hard Disk...
# [ OK ] Kernel loaded successfully
# [INFO] Jumping to kernel...
# SimpleOS - A Rust Operating System (in colors!)
# [OK] status messages, Hello World, and a rainbow bar!
```

## Prerequisites Check

```bash
# Check Rust version (should say "nightly")
rustc --version

# Check QEMU is installed
qemu-system-x86_64 --version

# Check make is installed
make --version

# If not installed:
# Ubuntu/Debian: sudo apt install build-essential qemu-system-x86
# macOS: xcode-select --install && brew install qemu
# Fedora: sudo dnf install make qemu-system-x86
```

## Build Commands

```bash
# Build everything (recommended)
make

# Build in debug mode
make BUILD_MODE=debug

# Clean everything
make clean

# Deep clean (including dependencies)
make distclean
```

## Run Commands

```bash
# Build and run automatically
make run

# Run manually
qemu-system-x86_64 -drive format=raw,file=target/image/simpleos.img

# Run with more memory
qemu-system-x86_64 -drive format=raw,file=target/image/simpleos.img -m 1G

# Run with debugging (GDB on port 1234)
make debug
# In another terminal: gdb -ex "target remote :1234"
```

## What Gets Built

```
target/
├── 16bit_target/release/
│   └── bootloader              # 512 bytes (boot sector)
├── x86_64-unknown-none/release/
│   └── kernel                  # ~4KB (main kernel)
└── image/
    └── simpleos.img            # 10MB (complete disk image)
```

## Exit QEMU

- Press `Ctrl+A` then `X` to quit
- Press `Ctrl+A` then `C` to get QEMU console, then type `quit`

## Modify the Boot Message

Edit `bootloader/src/main.rs`:
```rust
// Change line ~24 - modify the colored boot message
print_string_colored(b"My Custom OS is Loading...\r\n", 0x0E); // Yellow
```

Then rebuild: `make`

## Modify the Kernel Message

Edit `kernel/src/main.rs`:
```rust
// Change the colorful welcome message
print_colored(b"Welcome to MyOS!", 6, 2, Color::LightCyan, Color::Black);
```

Then rebuild: `make`

## Change Colors

The kernel uses 16-color VGA palette. Edit `kernel/src/main.rs`:
```rust
// Available colors:
// Color::Black, Color::Blue, Color::Green, Color::Cyan
// Color::Red, Color::Magenta, Color::Brown, Color::LightGray
// Color::DarkGray, Color::LightBlue, Color::LightGreen, Color::LightCyan
// Color::LightRed, Color::Pink, Color::Yellow, Color::White

// Change the title bar color (line ~43)
print_colored(b"SimpleOS", 0, 0, Color::Pink, Color::DarkGray);
```

See `docs/COLORS.md` for complete color documentation.

## Common Issues

### "make: command not found"
```bash
# Install make:
# Ubuntu/Debian: sudo apt install build-essential
# macOS: xcode-select --install
# Fedora: sudo dnf install make
```

### "Bootloader must be exactly 512 bytes"
The linker script enforces this. If you see this error, you've added too much code to the bootloader.

### "No bootable device"
The boot signature (0xAA55) is missing. Check `bootloader/linker.ld` is present.

### "Kernel binary not found"
```bash
# Make sure you're in the project root
cd /path/to/simpleos
make
```

### Build errors about "rust-src"
```bash
rustup component add rust-src llvm-tools-preview
```

## Project Structure

```
simpleos/
├── bootloader/        # 16-bit code that loads kernel
│   └── src/main.rs   # Edit this for boot messages
├── kernel/           # Your main OS code
│   └── src/main.rs   # Edit this for kernel behavior
├── future/           # Future features (not built yet)
├── Makefile          # Build system
└── README.md         # Full documentation
```

## What Happens When You Run

1. **BIOS** loads bootloader (sector 0) to memory address 0x7C00
2. **Bootloader** prints colored messages "[BOOT] Booting from Hard Disk..."
3. **Bootloader** loads kernel (sectors 1+) to memory address 0x10000
4. **Bootloader** prints "[ OK ] Kernel loaded successfully"
5. **Bootloader** jumps to kernel entry point
6. **Kernel** clears screen to blue background
7. **Kernel** displays colorful title bar and status messages
8. **Kernel** prints "Hello, World!" in cyan
9. **Kernel** draws a rainbow color bar
10. **Kernel** halts CPU (infinite loop with `hlt`)

## Next Steps

- Read `README.md` for full documentation
- Read `docs/SETUP.md` to understand what was fixed
- **Read `docs/COLORS.md` for color system documentation**
- Read `docs/PROJECT_STRUCTURE.md` for clean project organization
- Read `docs/ROADMAP.md` for development roadmap
- Modify `kernel/src/main.rs` to customize colors and messages
- Check out `future/` directory for advanced features roadmap
- Add keyboard input, more VGA features, etc.

## Useful Commands

```bash
# Using Makefile helpers (recommended)
make hexdump-boot     # View bootloader in hex
make hexdump-disk     # View disk image
make disasm-boot      # Disassemble bootloader
make disasm-kernel    # Disassemble kernel
make info             # Show all build info
make sizes            # Show component sizes

# Or manually:
hexdump -C target/16bit_target/release/bootloader
hexdump -C target/image/simpleos.img | head -50
stat -c%s target/16bit_target/release/bootloader
xxd target/16bit_target/release/bootloader | tail -1
objdump -D -b binary -m i8086 target/16bit_target/release/bootloader
objdump -D -b binary -m i386:x86-64 target/x86_64-unknown-none/release/kernel
```

## Resources

- **OSDev Wiki**: https://wiki.osdev.org/
- **Writing an OS in Rust**: https://os.phil-opp.com/
- **BIOS Interrupts**: http://www.ctyme.com/intr/int.htm
- **VGA Text Mode**: https://wiki.osdev.org/Text_mode
- **VGA Colors**: https://wiki.osdev.org/VGA_Hardware#Color_palette
- **docs/COLORS.md**: Full color documentation in this project
- **docs/ROADMAP.md**: Development roadmap and future plans

## Support

If something doesn't work:
1. Check you're using Rust nightly: `rustup default nightly`
2. Clean and rebuild: `make clean && make`
3. Check dependencies: `make verify-deps`
4. Check QEMU version: `qemu-system-x86_64 --version`
5. Read the error messages carefully
6. Check `docs/SETUP.md` for detailed troubleshooting

Happy OS development! 🚀