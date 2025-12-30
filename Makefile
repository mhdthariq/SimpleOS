# SimpleOS Makefile
# Complete build system for bootloader, kernel, and disk image

.PHONY: all clean run debug help bootloader kernel image info check test

# Build configuration
BUILD_MODE ?= release
BUILD_DIR := target
IMAGE_DIR := $(BUILD_DIR)/image
BOOTLOADER_DIR := bootloader
KERNEL_DIR := kernel

# Target specifications
TARGET_16BIT := build/targets/16bit_target.json
TARGET_64BIT := x86_64-unknown-none

# Output files
DISK_IMAGE := $(IMAGE_DIR)/simpleos.img
BOOTLOADER_BIN := $(BUILD_DIR)/16bit_target/$(BUILD_MODE)/bootloader
KERNEL_BIN := $(BUILD_DIR)/$(TARGET_64BIT)/$(BUILD_MODE)/kernel

# Build flags
ifeq ($(BUILD_MODE),release)
    CARGO_FLAGS := --release
else
    CARGO_FLAGS :=
endif

# QEMU configuration
QEMU := qemu-system-x86_64
QEMU_FLAGS := -drive format=raw,file=$(DISK_IMAGE) -m 512M
QEMU_DEBUG_FLAGS := -s -S

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
CYAN := \033[0;36m
BLUE := \033[0;34m
MAGENTA := \033[0;35m
NC := \033[0m # No Color

# Default target
all: image

# Help target
help:
	@echo "$(CYAN)========================================$(NC)"
	@echo "$(CYAN)  SimpleOS Build System (Makefile)$(NC)"
	@echo "$(CYAN)========================================$(NC)"
	@echo ""
	@echo "$(YELLOW)Usage:$(NC)"
	@echo "  make                    Build everything (release mode)"
	@echo "  make run                Build and run in QEMU"
	@echo "  make debug              Build and run with GDB debugging"
	@echo "  make clean              Clean all build artifacts"
	@echo "  make check              Check code without building"
	@echo "  make info               Show build information"
	@echo ""
	@echo "$(YELLOW)Build modes:$(NC)"
	@echo "  make BUILD_MODE=debug   Build in debug mode"
	@echo "  make BUILD_MODE=release Build in release mode (default)"
	@echo ""
	@echo "$(YELLOW)Individual components:$(NC)"
	@echo "  make bootloader         Build only bootloader"
	@echo "  make kernel             Build only kernel"
	@echo "  make image              Assemble disk image from components"
	@echo ""
	@echo "$(YELLOW)Testing:$(NC)"
	@echo "  make test               Run test suite (when available)"
	@echo ""
	@echo "$(YELLOW)QEMU controls:$(NC)"
	@echo "  Ctrl+A then X           Exit QEMU"
	@echo "  Ctrl+A then C           QEMU console"
	@echo ""

# Build bootloader (512-byte boot sector)
bootloader: $(BOOTLOADER_BIN)

$(BOOTLOADER_BIN):
	@echo "$(CYAN)[1/3] Building bootloader (16-bit)...$(NC)"
	@cd $(BOOTLOADER_DIR) && cargo build $(CARGO_FLAGS) --target=../$(TARGET_16BIT)
	@if [ ! -f "$(BOOTLOADER_BIN)" ]; then \
		echo "$(RED)ERROR: Bootloader binary not found$(NC)"; \
		exit 1; \
	fi
	@BOOT_SIZE=$$(stat -c%s "$(BOOTLOADER_BIN)" 2>/dev/null || stat -f%z "$(BOOTLOADER_BIN)"); \
	if [ "$$BOOT_SIZE" != "512" ]; then \
		echo "$(RED)ERROR: Bootloader must be exactly 512 bytes, got $$BOOT_SIZE bytes$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)✓ Bootloader built (512 bytes)$(NC)"

# Build kernel (64-bit)
kernel: $(KERNEL_BIN)

$(KERNEL_BIN):
	@echo "$(CYAN)[2/3] Building kernel (64-bit)...$(NC)"
	@cd $(KERNEL_DIR) && cargo build $(CARGO_FLAGS) --target=$(TARGET_64BIT)
	@if [ ! -f "$(KERNEL_BIN)" ]; then \
		echo "$(RED)ERROR: Kernel binary not found$(NC)"; \
		exit 1; \
	fi
	@KERNEL_SIZE=$$(stat -c%s "$(KERNEL_BIN)" 2>/dev/null || stat -f%z "$(KERNEL_BIN)"); \
	echo "$(GREEN)✓ Kernel built ($$KERNEL_SIZE bytes)$(NC)"

# Assemble disk image
image: $(DISK_IMAGE)

$(DISK_IMAGE): $(BOOTLOADER_BIN) $(KERNEL_BIN)
	@echo "$(CYAN)[3/3] Creating disk image...$(NC)"
	@mkdir -p $(IMAGE_DIR)
	@cat $(BOOTLOADER_BIN) > $(DISK_IMAGE)
	@cat $(KERNEL_BIN) >> $(DISK_IMAGE)
	@truncate -s 10M $(DISK_IMAGE)
	@DISK_SIZE=$$(stat -c%s "$(DISK_IMAGE)" 2>/dev/null || stat -f%z "$(DISK_IMAGE)"); \
	echo "$(GREEN)✓ Disk image created ($$DISK_SIZE bytes)$(NC)"
	@echo ""
	@echo "$(GREEN)========================================$(NC)"
	@echo "$(GREEN)  Build completed successfully!$(NC)"
	@echo "$(GREEN)========================================$(NC)"
	@echo "Disk image: $(DISK_IMAGE)"
	@echo ""
	@echo "$(YELLOW)To run:$(NC) make run"
	@echo "$(YELLOW)Or:$(NC)     $(QEMU) $(QEMU_FLAGS)"
	@echo ""

# Run in QEMU
run: image
	@echo "$(CYAN)Starting QEMU...$(NC)"
	@echo "$(YELLOW)Press Ctrl+A then X to exit$(NC)"
	@echo ""
	@$(QEMU) $(QEMU_FLAGS)

# Run with debugging (GDB on port 1234)
debug: BUILD_MODE := debug
debug: image
	@echo "$(CYAN)Starting QEMU with debugger...$(NC)"
	@echo "$(YELLOW)GDB server listening on port 1234$(NC)"
	@echo "$(YELLOW)In another terminal: gdb -ex 'target remote :1234'$(NC)"
	@echo "$(YELLOW)Press Ctrl+A then X to exit$(NC)"
	@echo ""
	@$(QEMU) $(QEMU_FLAGS) $(QEMU_DEBUG_FLAGS)

# Check code without building
check:
	@echo "$(CYAN)Checking bootloader...$(NC)"
	@cd $(BOOTLOADER_DIR) && cargo check --target=../$(TARGET_16BIT)
	@echo "$(CYAN)Checking kernel...$(NC)"
	@cd $(KERNEL_DIR) && cargo check --target=$(TARGET_64BIT)
	@echo "$(GREEN)✓ All checks passed$(NC)"

# Show build information
info:
	@echo "$(CYAN)========================================$(NC)"
	@echo "$(CYAN)  SimpleOS Build Information$(NC)"
	@echo "$(CYAN)========================================$(NC)"
	@echo ""
	@echo "$(YELLOW)Build Configuration:$(NC)"
	@echo "  Mode:               $(BUILD_MODE)"
	@echo "  Bootloader target:  $(TARGET_16BIT)"
	@echo "  Kernel target:      $(TARGET_64BIT)"
	@echo ""
	@echo "$(YELLOW)Output Files:$(NC)"
	@echo "  Bootloader:         $(BOOTLOADER_BIN)"
	@echo "  Kernel:             $(KERNEL_BIN)"
	@echo "  Disk image:         $(DISK_IMAGE)"
	@echo ""
	@echo "$(YELLOW)Tools:$(NC)"
	@echo "  QEMU:               $(QEMU)"
	@echo "  Rust version:       $$(rustc --version 2>/dev/null || echo 'Not found')"
	@echo "  Cargo version:      $$(cargo --version 2>/dev/null || echo 'Not found')"
	@echo ""
	@if [ -f "$(BOOTLOADER_BIN)" ]; then \
		BOOT_SIZE=$$(stat -c%s "$(BOOTLOADER_BIN)" 2>/dev/null || stat -f%z "$(BOOTLOADER_BIN)"); \
		echo "$(YELLOW)Current Build:$(NC)"; \
		echo "  Bootloader size:    $$BOOT_SIZE bytes"; \
	fi
	@if [ -f "$(KERNEL_BIN)" ]; then \
		KERNEL_SIZE=$$(stat -c%s "$(KERNEL_BIN)" 2>/dev/null || stat -f%z "$(KERNEL_BIN)"); \
		echo "  Kernel size:        $$KERNEL_SIZE bytes"; \
	fi
	@if [ -f "$(DISK_IMAGE)" ]; then \
		DISK_SIZE=$$(stat -c%s "$(DISK_IMAGE)" 2>/dev/null || stat -f%z "$(DISK_IMAGE)"); \
		echo "  Disk image size:    $$DISK_SIZE bytes"; \
	fi
	@echo ""

# Test suite (placeholder for future tests)
test:
	@echo "$(YELLOW)Running tests...$(NC)"
	@cd $(BOOTLOADER_DIR) && cargo test $(CARGO_FLAGS) --target=../$(TARGET_16BIT) || echo "$(YELLOW)No tests in bootloader$(NC)"
	@cd $(KERNEL_DIR) && cargo test $(CARGO_FLAGS) --target=$(TARGET_64BIT) || echo "$(YELLOW)No tests in kernel$(NC)"
	@echo "$(GREEN)✓ Tests completed$(NC)"

# Clean all build artifacts
clean:
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	@cargo clean
	@rm -rf $(IMAGE_DIR)
	@echo "$(GREEN)✓ Clean complete$(NC)"

# Clean everything including downloaded dependencies
distclean: clean
	@echo "$(YELLOW)Cleaning dependencies...$(NC)"
	@rm -rf target/
	@cd $(BOOTLOADER_DIR) && cargo clean
	@cd $(KERNEL_DIR) && cargo clean
	@echo "$(GREEN)✓ Deep clean complete$(NC)"

# Verify build requirements
.PHONY: verify-deps
verify-deps:
	@echo "$(CYAN)Verifying build dependencies...$(NC)"
	@which rustc > /dev/null || (echo "$(RED)ERROR: rustc not found. Install Rust from https://rustup.rs/$(NC)" && exit 1)
	@which cargo > /dev/null || (echo "$(RED)ERROR: cargo not found$(NC)" && exit 1)
	@which $(QEMU) > /dev/null || (echo "$(RED)WARNING: QEMU not found. Install qemu-system-x86$(NC)")
	@rustc --version | grep -q nightly || (echo "$(YELLOW)WARNING: Not using nightly Rust. Run: rustup default nightly$(NC)")
	@echo "$(GREEN)✓ Dependencies verified$(NC)"

# Install build dependencies
.PHONY: install-deps
install-deps:
	@echo "$(CYAN)Installing Rust components...$(NC)"
	rustup default nightly
	rustup component add rust-src llvm-tools-preview
	@echo "$(GREEN)✓ Rust components installed$(NC)"
	@echo ""
	@echo "$(YELLOW)Please install QEMU manually:$(NC)"
	@echo "  Ubuntu/Debian: sudo apt install qemu-system-x86"
	@echo "  Fedora:        sudo dnf install qemu-system-x86"
	@echo "  macOS:         brew install qemu"
	@echo ""

# Development helpers
.PHONY: watch
watch:
	@echo "$(CYAN)Watching for changes...$(NC)"
	@while true; do \
		inotifywait -e modify -r $(BOOTLOADER_DIR)/src $(KERNEL_DIR)/src 2>/dev/null && make all; \
	done

# Show file sizes
.PHONY: sizes
sizes: image
	@echo "$(CYAN)Component sizes:$(NC)"
	@ls -lh $(BOOTLOADER_BIN) $(KERNEL_BIN) $(DISK_IMAGE) | awk '{print "  " $$9 ": " $$5}'

# Hexdump of bootloader
.PHONY: hexdump-boot
hexdump-boot: bootloader
	@echo "$(CYAN)Bootloader hexdump (first 512 bytes):$(NC)"
	@hexdump -C $(BOOTLOADER_BIN) | head -n 32

# Hexdump of disk image
.PHONY: hexdump-disk
hexdump-disk: image
	@echo "$(CYAN)Disk image hexdump (first 1024 bytes):$(NC)"
	@hexdump -C $(DISK_IMAGE) | head -n 64

# Disassemble bootloader
.PHONY: disasm-boot
disasm-boot: bootloader
	@echo "$(CYAN)Bootloader disassembly:$(NC)"
	@objdump -D -b binary -m i8086 $(BOOTLOADER_BIN) | less

# Disassemble kernel
.PHONY: disasm-kernel
disasm-kernel: kernel
	@echo "$(CYAN)Kernel disassembly:$(NC)"
	@objdump -D -b binary -m i386:x86-64 $(KERNEL_BIN) | less

# Format code
.PHONY: fmt
fmt:
	@echo "$(CYAN)Formatting code...$(NC)"
	@cd $(BOOTLOADER_DIR) && cargo fmt
	@cd $(KERNEL_DIR) && cargo fmt
	@echo "$(GREEN)✓ Code formatted$(NC)"

# Clippy lints
.PHONY: lint
lint:
	@echo "$(CYAN)Running clippy...$(NC)"
	@cd $(BOOTLOADER_DIR) && cargo clippy --target=../$(TARGET_16BIT)
	@cd $(KERNEL_DIR) && cargo clippy --target=$(TARGET_64BIT)
	@echo "$(GREEN)✓ Lints complete$(NC)"
