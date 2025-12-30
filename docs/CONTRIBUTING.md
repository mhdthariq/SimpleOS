# Contributing to SimpleOS

Thank you for your interest in contributing to SimpleOS! This document provides guidelines and instructions for contributing to the project.

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Development Setup](#development-setup)
3. [Project Structure](#project-structure)
4. [Coding Standards](#coding-standards)
5. [Making Changes](#making-changes)
6. [Testing](#testing)
7. [Documentation](#documentation)
8. [Submitting Changes](#submitting-changes)
9. [Areas for Contribution](#areas-for-contribution)
10. [Community Guidelines](#community-guidelines)

---

## Getting Started

### Prerequisites

Before contributing, ensure you have:
- Rust nightly toolchain installed
- QEMU for testing
- Basic understanding of OS development concepts
- Familiarity with Rust (especially `no_std` environment)

### First Time Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/simpleos.git
cd simpleos

# Install Rust nightly
rustup default nightly
rustup component add rust-src llvm-tools-preview

# Install QEMU
# Ubuntu/Debian: sudo apt install qemu-system-x86
# macOS: brew install qemu
# Fedora: sudo dnf install qemu-system-x86

# Build the project
make

# Run the OS
make run
```

---

## Development Setup

### Required Tools

- **Rust Nightly**: For unstable features and `build-std`
- **QEMU**: For testing the OS
- **Make**: For build automation
- **Git**: For version control

### Optional Tools

- **GDB**: For debugging
- **Hexdump/xxd**: For inspecting binaries
- **objdump**: For disassembly

### Recommended IDE Setup

- **VS Code** with:
  - rust-analyzer extension
  - CodeLLDB extension (for debugging)
- **Vim/Neovim** with:
  - rust.vim plugin
  - coc-rust-analyzer
- **Any IDE** with Rust Language Server support

---

## Project Structure

```
simpleos/
├── bootloader/          # 16-bit bootloader
│   └── src/main.rs     # Bootloader entry point
├── kernel/             # Main kernel
│   └── src/main.rs     # Kernel entry point
├── future/             # Future features (not built yet)
│   ├── shared_libs/    # Shared utilities
│   ├── advanced_bootloader/  # Multi-stage boot
│   └── drivers/        # Advanced drivers
├── docs/               # Documentation
│   ├── COMMANDS.md     # Command reference
│   ├── COLORS.md       # VGA color system
│   ├── ROADMAP.md      # Development roadmap
│   └── ...
├── Makefile            # Build system
└── Cargo.toml          # Workspace configuration
```

### Active vs Future Code

- **Active Code** (`bootloader/`, `kernel/`): Currently compiled and used
- **Future Code** (`future/`): Prepared for future integration

See `docs/ROADMAP.md` for integration plan.

---

## Coding Standards

### Rust Style

Follow the official Rust style guidelines:

```bash
# Format your code before committing
make fmt

# Or manually
cargo fmt
```

### Code Organization

- **Keep functions small**: Aim for <50 lines per function
- **Use descriptive names**: Avoid abbreviations unless standard
- **Add comments**: Explain "why", not "what"
- **Document public APIs**: Use Rust doc comments (`///`)

### Example

```rust
/// Prints a colored string to the VGA buffer at the specified position.
///
/// # Arguments
/// * `text` - The text to print (ASCII only)
/// * `row` - Row position (0-24)
/// * `col` - Column position (0-79)
/// * `fg` - Foreground color
/// * `bg` - Background color
///
/// # Safety
/// This function writes directly to VGA memory (0xB8000).
fn print_colored(text: &[u8], row: usize, col: usize, fg: Color, bg: Color) {
    // Implementation...
}
```

### Safety Guidelines

Since we're working with `unsafe` code:

1. **Minimize unsafe blocks**: Keep them as small as possible
2. **Document safety invariants**: Explain why the code is safe
3. **Use abstractions**: Wrap unsafe operations in safe APIs
4. **Test thoroughly**: Unsafe code needs extra testing

Example:
```rust
/// Writes a byte to the VGA buffer.
///
/// # Safety
/// Caller must ensure:
/// - `offset` is within VGA buffer bounds (0..4000)
/// - VGA buffer is properly mapped at 0xB8000
unsafe fn write_vga_byte(offset: usize, value: u8) {
    const VGA_BUFFER: *mut u8 = 0xb8000 as *mut u8;
    *VGA_BUFFER.add(offset) = value;
}
```

### Error Handling

- Use `Result` for operations that can fail
- Use `Option` for values that may be absent
- Panic only for truly unrecoverable errors
- In kernel code, prefer custom panic handler

```rust
// Good
fn read_sector(sector: u32) -> Result<[u8; 512], DiskError> {
    // ...
}

// Avoid in kernel
fn read_sector(sector: u32) -> [u8; 512] {
    // ... panics on error
}
```

---

## Making Changes

### Branching Strategy

1. **Main branch**: Stable, working code
2. **Feature branches**: For new features (`feature/name`)
3. **Fix branches**: For bug fixes (`fix/description`)

### Workflow

```bash
# Create a new branch
git checkout -b feature/keyboard-driver

# Make your changes
vim kernel/src/drivers/keyboard.rs

# Test your changes
make check
make
make run

# Commit your changes
git add .
git commit -m "Add keyboard driver with PS/2 support"

# Push to your fork
git push origin feature/keyboard-driver

# Open a pull request
```

### Commit Messages

Follow conventional commit format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Build system, dependencies

**Examples:**
```
feat(kernel): add keyboard driver

Implements PS/2 keyboard driver with scan code translation
and key event queue.

Closes #42
```

```
fix(bootloader): correct A20 line detection

The previous implementation didn't check all methods.
Now tries keyboard controller, BIOS, and fast A20.
```

---

## Testing

### Running Tests

```bash
# Build and run
make run

# Run with debugging
make debug

# Check for compilation errors
make check

# Run clippy lints
make lint
```

### Manual Testing

Test on both QEMU and real hardware if possible:

```bash
# QEMU testing (fast)
make run

# Real hardware (write to USB)
sudo dd if=target/image/simpleos.img of=/dev/sdX bs=512
```

### Regression Testing

Before submitting:
1. ✅ Code compiles without errors
2. ✅ Code compiles without warnings
3. ✅ Boot process completes
4. ✅ All existing features still work
5. ✅ New feature works as expected

---

## Documentation

### Code Documentation

- Add doc comments to public functions/types
- Explain parameters and return values
- Include examples where helpful
- Document safety requirements for unsafe code

### User Documentation

When adding a feature, update:
- `README.md` - If it changes basic usage
- `docs/COMMANDS.md` - If you add new commands
- `docs/ROADMAP.md` - Mark tasks as complete
- `CHANGELOG.md` - Document the change

### Example Documentation Update

```markdown
## Added Keyboard Support

New keyboard driver in `kernel/src/drivers/keyboard.rs`:
- PS/2 keyboard support
- Scan code translation
- Key event queue
- Special key handling (Shift, Ctrl, Alt)

Usage:
```rust
let key = keyboard::read_key();
match key {
    Key::Char(c) => print_char(c),
    Key::Enter => handle_enter(),
    _ => {}
}
```
```

---

## Submitting Changes

### Pull Request Process

1. **Fork the repository** (if not a core contributor)
2. **Create a feature branch**
3. **Make your changes**
4. **Test thoroughly**
5. **Update documentation**
6. **Submit pull request**

### Pull Request Template

```markdown
## Description
Brief description of what this PR does.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Code refactoring

## Testing
- [ ] Tested on QEMU
- [ ] Tested on real hardware (if applicable)
- [ ] No compilation errors
- [ ] No compilation warnings

## Checklist
- [ ] Code follows project style guidelines
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] All tests pass
```

### Review Process

1. Maintainers will review your PR
2. Address any feedback
3. Make requested changes
4. Once approved, it will be merged

---

## Areas for Contribution

### High Priority

- [ ] **Protected Mode Transition** (Phase 2)
- [ ] **Long Mode Setup** (Phase 3)
- [ ] **Memory Management** (Phase 4)
- [ ] **Interrupt Handling** (Phase 5)

### Medium Priority

- [ ] **Enhanced VGA Driver** (from `future/drivers/`)
- [ ] **Keyboard Driver**
- [ ] **Timer Driver**
- [ ] **Serial Port Driver**

### Documentation

- [ ] Add more examples
- [ ] Improve existing docs
- [ ] Create tutorials
- [ ] Add architecture diagrams

### Testing

- [ ] Test on different hardware
- [ ] Create automated tests
- [ ] Performance benchmarks
- [ ] Stress testing

### Good First Issues

Look for issues labeled `good-first-issue`:
- Small, self-contained changes
- Good for learning the codebase
- Well-documented expectations

---

## Community Guidelines

### Be Respectful

- Treat everyone with respect
- Be constructive in feedback
- Welcome newcomers
- Celebrate contributions

### Communication

- Use clear, concise language
- Provide context in discussions
- Ask questions if unclear
- Share knowledge generously

### Code of Conduct

We follow the Rust Code of Conduct:
- Be friendly and patient
- Be welcoming
- Be considerate
- Be respectful
- Be careful with words

---

## Getting Help

### Where to Ask

- **GitHub Issues**: Bug reports, feature requests
- **GitHub Discussions**: Questions, ideas
- **Documentation**: Check `docs/` first

### Reporting Bugs

Use the bug report template:

```markdown
**Description**
Clear description of the bug.

**Steps to Reproduce**
1. Build with `make`
2. Run with `make run`
3. Press X key
4. Observe crash

**Expected Behavior**
What should happen.

**Actual Behavior**
What actually happens.

**Environment**
- OS: Ubuntu 22.04
- QEMU version: 7.2.0
- Rust version: nightly-2025-12-01

**Logs**
```
[Paste any error messages or logs]
```
```

---

## Development Tips

### Debugging

```bash
# Use GDB for debugging
make debug
# In another terminal:
gdb
(gdb) target remote :1234
(gdb) break *0x7c00
(gdb) continue
```

### Inspecting Binaries

```bash
# View bootloader in hex
make hexdump-boot

# Disassemble bootloader
make disasm-boot

# Check file sizes
make sizes

# View build info
make info
```

### Iterating Quickly

```bash
# Quick rebuild and run
make run

# Just check for errors (fast)
make check
```

---

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

## Acknowledgments

Thank you for contributing to SimpleOS! Every contribution, no matter how small, helps make this project better.

### Contributors

See [CONTRIBUTORS.md](CONTRIBUTORS.md) for the list of contributors.

---

## Questions?

If you have questions about contributing, feel free to:
- Open a GitHub Discussion
- Ask in an issue
- Contact the maintainers

**Happy coding!** 🚀
