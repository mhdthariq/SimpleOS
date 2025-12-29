#!/bin/bash
# Binary examination helper script for SimpleOS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default binary path
BINARY="target/16bit_target/release/simpleos"

# Check if binary exists
if [ ! -f "$BINARY" ]; then
    echo -e "${RED}Error: Binary not found at $BINARY${NC}"
    echo "Please build the project first with:"
    echo "  cargo build --release --target=build/targets/16bit_target.json"
    exit 1
fi

echo -e "${GREEN}=== SimpleOS Binary Examination ===${NC}\n"

# Show file info
echo -e "${BLUE}File Information:${NC}"
file "$BINARY"
ls -lh "$BINARY"
echo ""

# Show size
echo -e "${BLUE}Binary Size:${NC}"
SIZE=$(stat -c %s "$BINARY")
SIZE_HEX=$(printf '%x' "$SIZE")
echo "Size: $SIZE bytes (0x$SIZE_HEX)"
echo ""

# Show sections
echo -e "${BLUE}Binary Sections:${NC}"
objdump -h "$BINARY"
echo ""

# Parse command line arguments
case "${1:-info}" in
    hex|hexdump)
        echo -e "${BLUE}Hexdump (first 512 bytes):${NC}"
        hexdump -C "$BINARY" | head -n 32
        echo ""
        echo "Use: hexdump -C $BINARY | less    (for full dump)"
        ;;

    full|fullhex)
        echo -e "${BLUE}Full Hexdump:${NC}"
        hexdump -C "$BINARY" | less
        ;;

    dis|disasm|disassemble)
        echo -e "${BLUE}Disassembly:${NC}"
        objdump -D -M intel "$BINARY" | less
        ;;

    xxd)
        echo -e "${BLUE}XXD output (first 512 bytes):${NC}"
        xxd "$BINARY" | head -n 32
        echo ""
        echo "Use: xxd $BINARY | less    (for full dump)"
        ;;

    strings)
        echo -e "${BLUE}Strings in binary:${NC}"
        strings "$BINARY"
        ;;

    symbols)
        echo -e "${BLUE}Symbol table:${NC}"
        nm "$BINARY"
        ;;

    readelf)
        echo -e "${BLUE}ELF Header:${NC}"
        readelf -h "$BINARY"
        echo ""
        echo -e "${BLUE}Program Headers:${NC}"
        readelf -l "$BINARY"
        echo ""
        echo -e "${BLUE}Section Headers:${NC}"
        readelf -S "$BINARY"
        ;;

    info)
        echo -e "${YELLOW}Available commands:${NC}"
        echo "  ./examine.sh hex         - Show hexdump (first 512 bytes)"
        echo "  ./examine.sh fullhex     - Show full hexdump with pager"
        echo "  ./examine.sh xxd         - Show xxd format (first 512 bytes)"
        echo "  ./examine.sh disasm      - Disassemble binary"
        echo "  ./examine.sh strings     - Extract strings from binary"
        echo "  ./examine.sh symbols     - Show symbol table"
        echo "  ./examine.sh readelf     - Show ELF headers and sections"
        echo "  ./examine.sh info        - Show this help"
        ;;

    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo "Use './examine.sh info' for available commands"
        exit 1
        ;;
esac
