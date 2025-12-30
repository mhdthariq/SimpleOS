# SimpleOS Development Roadmap

**Last Updated:** December 30, 2025  
**Current Version:** 1.2.0  
**Status:** Foundation Complete ✅

---

## Table of Contents

1. [Overview](#overview)
2. [Current Status](#current-status)
3. [Development Phases](#development-phases)
4. [Phase 1: Foundation](#phase-1-foundation-complete-)
5. [Phase 2: Protected Mode](#phase-2-protected-mode)
6. [Phase 3: Long Mode (64-bit)](#phase-3-long-mode-64-bit)
7. [Phase 4: Memory Management](#phase-4-memory-management)
8. [Phase 5: Interrupt Handling](#phase-5-interrupt-handling)
9. [Phase 6: Device Drivers](#phase-6-device-drivers)
10. [Phase 7: File System](#phase-7-file-system)
11. [Phase 8: Process Management](#phase-8-process-management)
12. [Phase 9: User Space](#phase-9-user-space)
13. [Phase 10: Advanced Features](#phase-10-advanced-features)
14. [Timeline Estimate](#timeline-estimate)
15. [Integration Guide](#integration-guide)

---

## Overview

SimpleOS is designed to be a learning-focused operating system that demonstrates fundamental OS concepts using Rust. This roadmap outlines the planned evolution from the current basic bootloader+kernel to a feature-rich operating system.

### Design Goals

- **Educational**: Clear, well-documented code
- **Modern**: Written in safe Rust where possible
- **Modular**: Clean separation of concerns
- **Incremental**: Each phase builds on the previous
- **Practical**: Real hardware compatibility where feasible

---

## Current Status

### ✅ Completed Features (v1.2.0)

- [x] Custom 16-bit bootloader (512 bytes)
- [x] Kernel loading from disk via BIOS INT 13h
- [x] 16-color VGA text mode output
- [x] Direct VGA memory access
- [x] Colored boot messages and status indicators
- [x] Clean project structure with Makefile build system
- [x] Zero external dependencies
- [x] Comprehensive documentation

### 📊 Current Capabilities

- **Boot**: BIOS boot from disk
- **Display**: 80x25 VGA text mode with 16 colors
- **Architecture**: 16-bit real mode
- **Disk I/O**: BIOS interrupts only
- **Memory**: No memory management
- **Multitasking**: None

---

## Development Phases

```
Phase 1: Foundation          [████████████████████] 100% ✅
Phase 2: Protected Mode      [░░░░░░░░░░░░░░░░░░░░]   0% 🔜
Phase 3: Long Mode           [░░░░░░░░░░░░░░░░░░░░]   0%
Phase 4: Memory Management   [░░░░░░░░░░░░░░░░░░░░]   0%
Phase 5: Interrupt Handling  [░░░░░░░░░░░░░░░░░░░░]   0%
Phase 6: Device Drivers      [░░░░░░░░░░░░░░░░░░░░]   0%
Phase 7: File System         [░░░░░░░░░░░░░░░░░░░░]   0%
Phase 8: Process Management  [░░░░░░░░░░░░░░░░░░░░]   0%
Phase 9: User Space          [░░░░░░░░░░░░░░░░░░░░]   0%
Phase 10: Advanced Features  [░░░░░░░░░░░░░░░░░░░░]   0%
```

---

## Phase 1: Foundation (COMPLETE ✅)

**Status:** ✅ Completed  
**Version:** 1.0.0 - 1.2.0  
**Duration:** Completed

### Goals
- Create working bootloader that loads kernel
- Implement basic VGA output
- Establish clean project structure
- Create comprehensive build system

### Completed Tasks
- [x] 16-bit bootloader with disk loading
- [x] Kernel separation and loading
- [x] VGA text mode with colors
- [x] Makefile build system
- [x] Documentation suite
- [x] Clean workspace organization

### Deliverables
- ✅ Working bootable disk image
- ✅ Colorful VGA output
- ✅ Build automation
- ✅ Complete documentation

---

## Phase 2: Protected Mode

**Status:** 🔜 Next Phase  
**Priority:** High  
**Estimated Duration:** 2-3 weeks  
**Code Available:** `future/advanced_bootloader/first_stage/`

### Goals
- Transition from 16-bit real mode to 32-bit protected mode
- Set up Global Descriptor Table (GDT)
- Enable A20 line for full memory access
- Implement basic protected mode memory management

### Tasks

#### 2.1 A20 Line Activation
- [ ] Detect A20 line status
- [ ] Enable A20 via keyboard controller
- [ ] Fallback to BIOS method
- [ ] Verify A20 enabled

#### 2.2 Global Descriptor Table (GDT)
- [ ] Define GDT structure
- [ ] Create code segment descriptor (0x08)
- [ ] Create data segment descriptor (0x10)
- [ ] Load GDTR register
- [ ] Implement GDT helper functions

#### 2.3 Protected Mode Transition
- [ ] Disable interrupts
- [ ] Load GDT
- [ ] Set CR0.PE bit
- [ ] Far jump to 32-bit code
- [ ] Reload segment registers

#### 2.4 32-bit Bootloader Stage
- [ ] Implement 32-bit assembly entry
- [ ] Set up 32-bit stack
- [ ] Implement 32-bit VGA output
- [ ] Load kernel into higher memory
- [ ] Pass boot information to kernel

### Deliverables
- [ ] Working protected mode transition
- [ ] 32-bit bootloader stage
- [ ] GDT implementation
- [ ] A20 line handler

### Resources Needed
- `future/shared_libs/cpu_utils/src/gdt.rs` (ready to integrate)
- Intel Software Developer Manual Vol 3A (GDT documentation)
- OSDev Wiki: Protected Mode

---

## Phase 3: Long Mode (64-bit)

**Status:** 📋 Planned  
**Priority:** High  
**Estimated Duration:** 3-4 weeks  
**Code Available:** `future/advanced_bootloader/second_stage/`

### Goals
- Transition from 32-bit protected mode to 64-bit long mode
- Set up paging structures (PML4, PDPT, PD, PT)
- Enable CPU features (SSE, NX bit, etc.)
- Create 64-bit kernel environment

### Tasks

#### 3.1 CPU Feature Detection
- [ ] Detect CPUID support
- [ ] Check for long mode support
- [ ] Verify required CPU features
- [ ] Enable SSE/SSE2

#### 3.2 Paging Setup
- [ ] Allocate page tables (PML4, PDPT, PD, PT)
- [ ] Identity map first 2MB
- [ ] Map kernel to higher half (0xFFFFFFFF80000000+)
- [ ] Set up NX bit (if available)
- [ ] Enable PAE (CR4.PAE)

#### 3.3 Long Mode Transition
- [ ] Load page table base (CR3)
- [ ] Enable long mode (EFER.LME)
- [ ] Enable paging (CR0.PG)
- [ ] Far jump to 64-bit code
- [ ] Set up 64-bit GDT

#### 3.4 64-bit Kernel Entry
- [ ] Implement 64-bit entry point
- [ ] Set up 64-bit stack
- [ ] Initialize BSS section
- [ ] Call kernel main function

### Deliverables
- [ ] Working long mode transition
- [ ] 64-bit kernel execution
- [ ] Paging implementation
- [ ] Higher-half kernel

### Resources Needed
- `future/shared_libs/cpu_utils/src/paging.rs` (ready to integrate)
- Intel Software Developer Manual Vol 3A (Paging documentation)
- OSDev Wiki: Long Mode

---

## Phase 4: Memory Management

**Status:** 📋 Planned  
**Priority:** High  
**Estimated Duration:** 4-5 weeks

### Goals
- Implement physical memory manager
- Implement virtual memory manager
- Create heap allocator
- Support dynamic memory allocation

### Tasks

#### 4.1 Physical Memory Manager
- [ ] Parse memory map from bootloader (E820)
- [ ] Implement bitmap allocator
- [ ] Track free/used frames
- [ ] Implement frame allocation/deallocation
- [ ] Support multiple page sizes (4KB, 2MB, 1GB)

#### 4.2 Virtual Memory Manager
- [ ] Implement page table manipulation
- [ ] Map/unmap virtual addresses
- [ ] Change page permissions
- [ ] Handle page faults
- [ ] Implement copy-on-write

#### 4.3 Kernel Heap
- [ ] Implement bump allocator (simple)
- [ ] Upgrade to linked list allocator
- [ ] Eventually: slab allocator
- [ ] Integrate with Rust's global allocator
- [ ] Support alloc crate (Vec, Box, etc.)

#### 4.4 Memory Safety
- [ ] Implement guard pages
- [ ] Detect stack overflow
- [ ] Memory leak detection (debug mode)
- [ ] KASAN integration (if feasible)

### Deliverables
- [ ] Working physical memory manager
- [ ] Virtual memory abstraction
- [ ] Kernel heap allocator
- [ ] Support for Rust collections (Vec, String, etc.)

### Metrics
- [ ] Efficient memory utilization (>90%)
- [ ] Fast allocation (<100 cycles)
- [ ] Low fragmentation (<10%)

---

## Phase 5: Interrupt Handling

**Status:** 📋 Planned  
**Priority:** High  
**Estimated Duration:** 3-4 weeks

### Goals
- Set up Interrupt Descriptor Table (IDT)
- Handle CPU exceptions
- Implement IRQ handling
- Basic PIC/APIC support

### Tasks

#### 5.1 IDT Setup
- [ ] Define IDT structure
- [ ] Create 256 interrupt handlers
- [ ] Load IDTR register
- [ ] Implement interrupt gate descriptors

#### 5.2 Exception Handlers
- [ ] Divide by zero (#DE)
- [ ] Debug (#DB)
- [ ] Breakpoint (#BP)
- [ ] Invalid opcode (#UD)
- [ ] General protection fault (#GP)
- [ ] Page fault (#PF)
- [ ] Double fault (#DF)
- [ ] Other CPU exceptions

#### 5.3 PIC Configuration
- [ ] Remap PIC to avoid conflicts
- [ ] Mask/unmask IRQs
- [ ] Send EOI (End of Interrupt)
- [ ] Configure cascade mode

#### 5.4 IRQ Handlers
- [ ] Timer interrupt (IRQ 0)
- [ ] Keyboard interrupt (IRQ 1)
- [ ] Generic IRQ dispatcher
- [ ] Interrupt statistics

#### 5.5 APIC Support (Optional)
- [ ] Detect APIC availability
- [ ] Configure Local APIC
- [ ] Configure I/O APIC
- [ ] MSI support

### Deliverables
- [ ] Working IDT with all exception handlers
- [ ] IRQ handling system
- [ ] Timer support
- [ ] Keyboard interrupt support

---

## Phase 6: Device Drivers

**Status:** 📋 Planned  
**Priority:** Medium  
**Estimated Duration:** 6-8 weeks  
**Code Available:** `future/drivers/vga_display/`

### Goals
- Create driver framework
- Implement essential drivers
- Device enumeration
- Plug and play support

### Tasks

#### 6.1 Driver Framework
- [ ] Define driver trait
- [ ] Device registration system
- [ ] Driver lifecycle management
- [ ] Hot-plug support

#### 6.2 Essential Drivers

##### VGA Driver (Enhanced)
- [ ] Integrate `future/drivers/vga_display/`
- [ ] Graphics mode support (mode 13h)
- [ ] VESA support
- [ ] Hardware cursor
- [ ] Scrolling support

##### Keyboard Driver
- [ ] PS/2 keyboard support
- [ ] Scan code translation
- [ ] Key event queue
- [ ] Special key handling (Shift, Ctrl, Alt)
- [ ] Keyboard layouts

##### Timer Driver
- [ ] PIT (Programmable Interval Timer)
- [ ] HPET (High Precision Event Timer)
- [ ] RTC (Real-Time Clock)
- [ ] System uptime tracking

##### Serial Port Driver
- [ ] COM1/COM2 support
- [ ] Debug output via serial
- [ ] Serial console

#### 6.3 Storage Drivers
- [ ] ATA PIO mode
- [ ] ATA DMA mode
- [ ] AHCI (SATA)
- [ ] NVMe (optional)

#### 6.4 PCI/PCIe
- [ ] PCI configuration space access
- [ ] Device enumeration
- [ ] BAR mapping
- [ ] MSI/MSI-X support

### Deliverables
- [ ] Driver framework
- [ ] Working VGA, keyboard, timer drivers
- [ ] Storage driver (at least ATA)
- [ ] PCI enumeration

---

## Phase 7: File System

**Status:** 📋 Planned  
**Priority:** Medium  
**Estimated Duration:** 6-8 weeks

### Goals
- Implement Virtual File System (VFS)
- Support at least one file system
- File operations (open, read, write, close)
- Directory operations

### Tasks

#### 7.1 VFS Layer
- [ ] Define file system traits
- [ ] Inode abstraction
- [ ] File descriptor table
- [ ] Path resolution
- [ ] Mount points

#### 7.2 Simple File System (Custom)
- [ ] Design simple FS format
- [ ] Superblock structure
- [ ] Block allocation bitmap
- [ ] Directory entries
- [ ] File metadata

#### 7.3 FAT32 Support
- [ ] Boot sector parsing
- [ ] FAT table handling
- [ ] Directory traversal
- [ ] File read/write
- [ ] Long filename support

#### 7.4 File Operations
- [ ] open()
- [ ] read()
- [ ] write()
- [ ] close()
- [ ] seek()
- [ ] stat()

#### 7.5 Directory Operations
- [ ] opendir()
- [ ] readdir()
- [ ] closedir()
- [ ] mkdir()
- [ ] rmdir()

### Deliverables
- [ ] Working VFS
- [ ] At least one file system implementation
- [ ] File and directory operations
- [ ] Persistent storage

---

## Phase 8: Process Management

**Status:** 📋 Planned  
**Priority:** High  
**Estimated Duration:** 8-10 weeks

### Goals
- Implement multitasking
- Process creation and termination
- Context switching
- Basic scheduler

### Tasks

#### 8.1 Process Structure
- [ ] Define process control block (PCB)
- [ ] Process ID allocation
- [ ] Process states (Running, Ready, Blocked)
- [ ] Process tree

#### 8.2 Context Switching
- [ ] Save/restore CPU state
- [ ] Switch page tables
- [ ] Switch kernel stack
- [ ] FPU/SSE state handling

#### 8.3 Scheduler
- [ ] Round-robin scheduler
- [ ] Priority scheduling
- [ ] Scheduler tick handler
- [ ] Load balancing (for multi-core)

#### 8.4 Process Creation
- [ ] fork() system call
- [ ] exec() system call
- [ ] Process termination
- [ ] Wait for child process

#### 8.5 Threads
- [ ] Thread creation
- [ ] Thread local storage (TLS)
- [ ] Thread synchronization primitives

### Deliverables
- [ ] Working multitasking
- [ ] Process management
- [ ] Context switching
- [ ] Basic scheduler

---

## Phase 9: User Space

**Status:** 📋 Planned  
**Priority:** High  
**Estimated Duration:** 8-10 weeks

### Goals
- Separate kernel and user space
- System call interface
- User mode processes
- Basic shell

### Tasks

#### 9.1 System Calls
- [ ] System call entry/exit
- [ ] System call table
- [ ] Implement basic syscalls:
  - [ ] exit()
  - [ ] read()
  - [ ] write()
  - [ ] open()
  - [ ] close()
  - [ ] fork()
  - [ ] exec()
  - [ ] wait()

#### 9.2 User Space Setup
- [ ] User page tables
- [ ] User stack
- [ ] Program loader (ELF)
- [ ] Dynamic linking (optional)

#### 9.3 Standard Library
- [ ] libc implementation (minimal)
- [ ] stdio functions
- [ ] Memory functions
- [ ] String functions

#### 9.4 Shell
- [ ] Command parsing
- [ ] Built-in commands (cd, ls, etc.)
- [ ] External program execution
- [ ] Pipes (optional)
- [ ] Redirection (optional)

#### 9.5 User Programs
- [ ] init process
- [ ] Basic utilities (ls, cat, echo)
- [ ] Test programs

### Deliverables
- [ ] Working system call interface
- [ ] User mode execution
- [ ] Basic shell
- [ ] Simple user programs

---

## Phase 10: Advanced Features

**Status:** 📋 Planned  
**Priority:** Low  
**Estimated Duration:** Ongoing

### Goals
- Multi-core support
- Networking
- Advanced file systems
- GUI (optional)

### Tasks

#### 10.1 Multi-core (SMP)
- [ ] APIC/x2APIC setup
- [ ] AP (Application Processor) startup
- [ ] Per-CPU data structures
- [ ] Spinlocks and mutexes
- [ ] Load balancing

#### 10.2 Networking
- [ ] Network stack (TCP/IP)
- [ ] Ethernet driver
- [ ] Sockets API
- [ ] DNS client
- [ ] Basic network utilities

#### 10.3 Advanced File Systems
- [ ] ext2/ext3/ext4
- [ ] Read-only NTFS
- [ ] ISO9660 (CD-ROM)

#### 10.4 GUI (Optional)
- [ ] Framebuffer support
- [ ] Window manager
- [ ] Basic widgets
- [ ] Mouse support

#### 10.5 Security
- [ ] User permissions
- [ ] Access control
- [ ] Secure boot
- [ ] ASLR

#### 10.6 UEFI Boot
- [ ] UEFI bootloader
- [ ] UEFI runtime services
- [ ] GOP (Graphics Output Protocol)

### Deliverables
- [ ] Multi-core support
- [ ] Network stack
- [ ] Advanced drivers and file systems
- [ ] Optional GUI

---

## Timeline Estimate

```
Current: v1.2.0 - Foundation Complete

Quarter 1 (Months 1-3):
  - Phase 2: Protected Mode
  - Phase 3: Long Mode (start)

Quarter 2 (Months 4-6):
  - Phase 3: Long Mode (complete)
  - Phase 4: Memory Management
  - Phase 5: Interrupt Handling (start)

Quarter 3 (Months 7-9):
  - Phase 5: Interrupt Handling (complete)
  - Phase 6: Device Drivers

Quarter 4 (Months 10-12):
  - Phase 7: File System
  - Phase 8: Process Management (start)

Year 2:
  - Phase 8: Process Management (complete)
  - Phase 9: User Space
  - Phase 10: Advanced Features (start)

Year 3+:
  - Phase 10: Advanced Features (ongoing)
```

**Note:** Timeline is highly flexible and depends on:
- Developer availability
- Complexity of implementation
- Testing and debugging time
- Community contributions

---

## Integration Guide

### How to Integrate Future Code

The `future/` directory contains code ready for integration:

#### Step 1: Choose a Component
```bash
# Available components:
ls future/
# shared_libs/          - Common utilities
# advanced_bootloader/  - Multi-stage boot
# drivers/              - Advanced drivers
```

#### Step 2: Update Workspace
Edit `Cargo.toml`:
```toml
[workspace]
members = [
    "bootloader",
    "kernel",
    "future/shared_libs/common",    # Add this
]
```

#### Step 3: Add Dependency
Edit `kernel/Cargo.toml`:
```toml
[dependencies]
common = { path = "../future/shared_libs/common" }
```

#### Step 4: Update Makefile
Add build step for new component if needed.

#### Step 5: Test Integration
```bash
make check
make
make run
```

### Integration Priority

**High Priority (Do First):**
1. `future/shared_libs/cpu_utils/` - GDT and paging
2. `future/advanced_bootloader/first_stage/` - Protected mode
3. `future/advanced_bootloader/second_stage/` - Long mode

**Medium Priority:**
4. `future/shared_libs/common/` - Common types
5. `future/drivers/vga_display/` - Enhanced VGA

**Low Priority:**
- Other drivers as needed

---

## Success Metrics

### Phase 2 Success
- [ ] Boots to 32-bit protected mode
- [ ] Can run 32-bit code
- [ ] GDT properly configured
- [ ] No crashes on transition

### Phase 3 Success
- [ ] Boots to 64-bit long mode
- [ ] Paging enabled and working
- [ ] Can run 64-bit kernel
- [ ] Virtual memory functional

### Phase 4 Success
- [ ] Can allocate/free physical memory
- [ ] Can map/unmap virtual memory
- [ ] Heap allocator works
- [ ] Can use Vec, String, etc.

### Phase 5 Success
- [ ] All exceptions handled gracefully
- [ ] Timer interrupts working
- [ ] Keyboard interrupts working
- [ ] No spurious interrupts

### Phase 6 Success
- [ ] Can read from disk
- [ ] Keyboard input works
- [ ] Timer maintains accurate time
- [ ] VGA display enhanced

### Phase 7 Success
- [ ] Can create files
- [ ] Can read/write files
- [ ] Directory operations work
- [ ] Data persists across reboots

### Phase 8 Success
- [ ] Multiple processes run simultaneously
- [ ] Context switching works
- [ ] No race conditions
- [ ] Stable multitasking

### Phase 9 Success
- [ ] User programs execute
- [ ] System calls work correctly
- [ ] Shell is functional
- [ ] Process isolation maintained

---

## Resources

### Documentation
- [OSDev Wiki](https://wiki.osdev.org/)
- [Writing an OS in Rust](https://os.phil-opp.com/)
- [Intel Software Developer Manual](https://software.intel.com/content/www/us/en/develop/articles/intel-sdm.html)
- [AMD64 Architecture Programmer's Manual](https://www.amd.com/en/support/tech-docs)

### Books
- "Operating Systems: Three Easy Pieces" by Remzi Arpaci-Dusseau
- "Operating System Concepts" by Silberschatz, Galvin, Gagne
- "Modern Operating Systems" by Andrew Tanenbaum
- "The Rust Programming Language" by Steve Klabnik

### Communities
- OSDev Forum: https://forum.osdev.org/
- Reddit r/osdev
- Rust OS Dev Community

---

## Contributing

See `CONTRIBUTING.md` for guidelines on how to contribute to SimpleOS.

### Areas Needing Help
- Testing on real hardware
- Documentation improvements
- Driver development
- Bug fixes
- Performance optimization

---

## Notes

- This roadmap is a living document and will be updated as development progresses
- Phases may be reordered based on dependencies and priorities
- Some features may be skipped or postponed
- Community feedback is welcome and encouraged

---

**Remember:** The goal is learning and understanding OS concepts. It's okay if things take longer than planned. Quality and understanding are more important than speed.

**Happy OS Development!** 🚀
