# 16-bit Target Configuration Documentation

This document explains the configuration options used in `16bit_target.json` for building 16-bit x86 code with Rust.

## Configuration Fields

### `arch`: "x86"
The general architecture to compile to - x86 CPU architecture in our case.

### `cpu`: "i386"
Specific CPU target - Intel i386 CPU which is the original 32-bit CPU. This is compatible with 16-bit real mode instructions.

### `data-layout`: "e-m:e-p:32:32-p270:32:32-p271:32:32-p272:64:64-i128:128-f64:32:64-f80:32-n8:16:32-S128"
Describes how data is laid out in memory for the LLVM backend. Split by '-':
- `e` → Little endianness (E for big endianness)
- `m:e` → ELF style name mangling
- `p:32:32` → The default pointer is 32-bit with 32-bit address space
- `p270:32:32` → Special pointer type ID-270 with 32-bit size and alignment
- `p271:32:32` → Special pointer type ID-271 with 32-bit size and alignment
- `p272:64:64` → Special pointer type ID-272 with 64-bit size and alignment
- `i128:128` → 128-bit integers are 128-bit aligned
- `f64:32:64` → 64-bit floats are 32-bit or 64-bit aligned
- `f80:32` → 80-bit floats are 32-bit aligned
- `n8:16:32` → Native integers are 8-bit, 16-bit, 32-bit
- `S128` → Stack is 128-bit aligned

### `dynamic-linking`: false
No dynamic linking is supported, because there is no OS runtime loader.

### `executables`: true
This target is allowed to produce executable binaries.

### `linker-flavor`: "ld.lld"
Use LLD's GNU compatible frontend (`ld.lld`) for linking.

### `linker`: "rust-lld"
Use the Rust provided LLD linker binary (bundled with rustup). This ensures that the binary can be compiled on every machine that has Rust installed.

### `llvm-target`: "i386-unknown-none-code16"
LLVM target triple. The `code16` suffix indicates 16-bit code generation.

### `max-atomic-width`: 64
The widest atomic operation is 64-bit.
**TODO**: Check if this can be removed for 16-bit targets.

### `position-independent-executables`: false
Disable position independent executables. The position of this executable matters because it is loaded at address 0x7C00 (boot sector address).

### `disable-redzone`: true
Disable the redzone optimization, which reserves memory on a function's stack without moving the stack pointer (saves some instructions because the prologue and epilogue of the function are removed). This is a convention which means that the guest OS won't overwrite this otherwise 'volatile' memory. Critical for bare-metal development.

### `target-c-int-width`: 32
The default int type is 32-bit.

### `target-pointer-width`: 32
The default pointer type is 32-bit.

### `target-endian`: "little"
The endianness of the target - little endian (least significant byte first).

### `panic-strategy`: "abort"
Panic strategy - aborts execution instead of unwinding. This is also set in `Cargo.toml`. Essential for bare-metal environments where unwinding support isn't available.

### `os`: "none"
There is no target operating system (bare-metal).

### `vendor`: "unknown"
There is no target vendor.

### `relocation-model`: "static"
Use static relocation (no dynamic symbol tables or relocation at runtime). This also means that the code is statically linked.

## Usage

This target specification file is used when building Rust code for 16-bit x86 real mode execution, such as bootloaders or BIOS code.

To use this target:
```bash
cargo build --target=build/targets/16bit_target.json
```

## References

- [Rust Custom Targets](https://doc.rust-lang.org/rustc/targets/custom.html)
- [LLVM Target Triples](https://llvm.org/docs/LangRef.html#target-triple)
- [LLVM Data Layout](https://llvm.org/docs/LangRef.html#data-layout)