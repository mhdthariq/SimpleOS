# SimpleOS

A minimal bare-metal operating system written in Rust.

## Overview

SimpleOS is a bare-bones OS project built from scratch using Rust's `no_std` environment. This project demonstrates fundamental OS development concepts including direct hardware interaction, custom linker scripts, and panic handling without relying on the Rust standard library.

## Features

- **`no_std` Environment**: Runs without the Rust standard library, providing complete control over the runtime
- **Custom Panic Handler**: Implements custom panic behavior for bare-metal execution
- **Custom Linker Script**: Uses a custom linker script for precise memory layout control
- **16-bit Real Mode**: Targets x86 16-bit real mode execution (bootloader compatible)
- **Nightly Rust**: Leverages cutting-edge Rust features for OS development
- **Boot Sector Compatible**: Generates bootable binary with proper boot signature

## Binary Specifications

### Target Architecture
- **Architecture**: x86 (i386)
- **Execution Mode**: 16-bit real mode (code16)
- **Target Triple**: `i386-unknown-none-code16`
- **CPU**: Intel i386 (compatible with 16-bit instructions)
- **Endianness**: Little-endian
- **Pointer Width**: 32-bit
- **Linking**: Static linking only (no dynamic linking)

### Memory Layout
- **Load Address**: `0x7C00` (standard BIOS boot sector address)
- **Binary Size**: Padded to 512 bytes (boot sector size)
- **Boot Signature**: `0xAA55` at bytes 510-511
- **Stack Alignment**: 128-bit
- **Position Independent**: No (absolute addressing from 0x7C00)

### Compilation Features
- **Panic Strategy**: Abort (no unwinding)
- **Relocation Model**: Static
- **Redzone**: Disabled (essential for bare-metal)
- **Linker**: rust-lld (LLVM linker bundled with Rust)
- **Build Standard Library**: Builds `core` from source

### Binary Format
- **Format**: ELF 32-bit LSB executable
- **Sections**: 
  - `.eh_frame_hdr` - Exception handling frame header
  - `.eh_frame` - Exception handling frame
  - `.comment` - Compiler and linker metadata

## Prerequisites

- [Rust](https://www.rust-lang.org/tools/install) (nightly toolchain)
- Cargo (comes with Rust)

## Project Structure

```
simpleos/
├── .cargo/
│   └── config.toml          # Cargo build configuration
├── build/
│   └── targets/
│       ├── 16bit_target.json    # Custom target specification
│       └── 16bit_target.md      # Target documentation
├── src/
│   ├── main.rs              # Main entry point
│   └── build.rs             # Build script for linker configuration
├── linker.ld                # Custom linker script (REQUIRED)
├── Cargo.toml               # Project dependencies and configuration
├── rust-toolchain.toml      # Rust toolchain specification
├── examine.sh               # Binary examination helper script
└── README.md                # This file
```

## Building

The project uses a custom 16-bit target specification and builds the core library from source:

```bash
# Development build
cargo build --target=build/targets/16bit_target.json

# Release build
cargo build --release --target=build/targets/16bit_target.json
```

The compiled binary will be located at:
```
target/16bit_target/release/simpleos
```

## Examining the Binary

### Using hexdump
```bash
# View hexdump
hexdump -C target/16bit_target/release/simpleos | less

# View first 20 lines
hexdump -C target/16bit_target/release/simpleos | head -n 20
```

### Using the helper script
```bash
# Make it executable (first time only)
chmod +x examine.sh

# Show hexdump
./examine.sh hex

# Show full hexdump with pager
./examine.sh fullhex

# Disassemble the binary
./examine.sh disasm

# Extract strings from binary
./examine.sh strings

# Show symbol table
./examine.sh symbols

# Show ELF headers and sections
./examine.sh readelf

# Show all available commands
./examine.sh info
```

## Configuration

### Custom Target (`build/targets/16bit_target.json`)

The custom target file configures the compiler for 16-bit x86 code generation:
- Sets architecture to x86 with i386 CPU
- Configures LLVM for 16-bit code generation (`code16`)
- Disables features incompatible with bare-metal (PIE, dynamic linking, redzone)
- Sets proper data layout for 16-bit addressing

See `build/targets/16bit_target.md` for detailed documentation on each configuration field.

### Cargo Configuration (`.cargo/config.toml`)

Configures unstable Rust features:
- `build-std = ["core"]` - Builds core library from source
- `build-std-features = ["compiler-builtins-mem"]` - Includes memory intrinsics
- Enables unstable options required for custom targets

### Linker Script (`linker.ld`)

**⚠️ REQUIRED - Do not delete!**

The custom linker script is essential for:
1. **Load Address**: Sets the binary to load at `0x7C00` (BIOS boot sector address)
2. **Padding**: Fills the binary with zeros up to 510 bytes
3. **Boot Signature**: Writes `0xAA55` at bytes 510-511 to make the sector bootable

The `build.rs` script automatically passes this linker script to the compiler.

### Panic Behavior

Both development and release profiles use `panic = "abort"` to avoid unwinding, which is essential for bare-metal environments where unwinding support is unavailable.

## Technical Details

### No Standard Library

This project uses `#![no_std]` to exclude the Rust standard library, which is necessary for bare-metal programming where there's no underlying operating system.

### No Main

The `#![no_main]` attribute is used because the standard Rust runtime is not available. The entry point is defined with `#[no_mangle]` to prevent name mangling.

### Custom Panic Handler

A custom panic handler is implemented as required in `no_std` environments:

```rust
#[panic_handler]
pub fn panic_handler(_info: &core::panic::PanicInfo) -> ! {
    loop {}
}
```

Currently, it enters an infinite loop. In a real OS, this would halt the CPU or display an error message.

### Boot Sector Requirements

For a binary to be bootable by the BIOS, it must:
1. Be exactly 512 bytes
2. Have the magic signature `0xAA55` at bytes 510-511
3. Be loaded at memory address `0x7C00`

The linker script ensures all these requirements are met.

## Running the OS

To run this OS, you'll need to:

1. **Build the binary** (as shown above)
2. **Write to a bootable medium** (USB drive, floppy image, or hard drive image)
3. **Boot from the medium** using real hardware or an emulator

### Using an Emulator (QEMU example)
```bash
# Install QEMU
sudo apt install qemu-system-x86  # Ubuntu/Debian
# or
brew install qemu                  # macOS

# Run the binary
qemu-system-i386 -drive format=raw,file=target/16bit_target/release/simpleos
```

## Development Roadmap

This is a foundational project that can be extended with:
- [ ] VGA text mode output
- [ ] BIOS interrupt handling
- [ ] Keyboard input via BIOS interrupts
- [ ] Transition to 32-bit protected mode
- [ ] Memory management
- [ ] File systems
- [ ] Process scheduling

## Resources

- [Writing an OS in Rust](https://os.phil-opp.com/) - Excellent tutorial series
- [The Rust Programming Language](https://doc.rust-lang.org/book/) - Official Rust book
- [Rust Embedded Book](https://rust-embedded.github.io/book/) - Embedded Rust guide
- [OSDev Wiki](https://wiki.osdev.org/) - Comprehensive OS development resource
- [Rust Custom Targets](https://doc.rust-lang.org/rustc/targets/custom.html) - Custom target documentation
- [x86 Assembly Guide](https://wiki.osdev.org/X86_Assembly) - x86 assembly reference

## Troubleshooting

### Binary not found
If you get "Binary not found" errors, ensure you've built with the correct target:
```bash
cargo build --release --target=build/targets/16bit_target.json
```

### Build errors with linker script
The `linker.ld` file is **required** and referenced by `build.rs`. Do not delete or move it.

### JSON parsing errors
The target JSON file (`build/targets/16bit_target.json`) must be valid JSON without comments. Comments are documented in the accompanying `.md` file.

## License

[Specify your license here]

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Author

Muhammad Thariq
