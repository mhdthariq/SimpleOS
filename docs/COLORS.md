# Color System in SimpleOS

## Overview

SimpleOS uses VGA text mode colors for both the bootloader and kernel. The system displays colorful messages during boot and runtime.

## Bootloader Colors (16-bit Real Mode)

The bootloader uses BIOS INT 10h with color attributes for colored text output.

### Color Format
- Color attribute: 1 byte (8 bits)
- High nibble (bits 4-7): Background color
- Low nibble (bits 0-3): Foreground color
- Format: `0xBF` where B = background, F = foreground

### Bootloader Color Codes
```
0x0A = Light Green on Black (used for [OK] tags)
0x0B = Light Cyan on Black (used for brackets)
0x0E = Yellow on Black (used for [BOOT], [INFO] tags)
0x0F = White on Black (used for regular text)
```

### Example: Bootloader Output
```
[BOOT] Booting from Hard Disk...
[ OK ] Kernel loaded successfully
[INFO] Jumping to kernel...
```

Colors:
- `[BOOT]` - Yellow
- `[ OK ]` - Light Green
- `[INFO]` - Yellow
- Brackets `[]` - Light Cyan
- Regular text - White

## Kernel Colors (VGA Text Mode)

The kernel uses direct VGA memory writes at address 0xB8000 with 16-color palette.

### VGA Color Palette
```rust
Black       = 0   // 0x0
Blue        = 1   // 0x1
Green       = 2   // 0x2
Cyan        = 3   // 0x3
Red         = 4   // 0x4
Magenta     = 5   // 0x5
Brown       = 6   // 0x6
LightGray   = 7   // 0x7
DarkGray    = 8   // 0x8
LightBlue   = 9   // 0x9
LightGreen  = 10  // 0xA
LightCyan   = 11  // 0xB
LightRed    = 12  // 0xC
Pink        = 13  // 0xD
Yellow      = 14  // 0xE
White       = 15  // 0xF
```

### Color Code Format
```rust
color_code = (background << 4) | foreground
```

Examples:
- `0x0F` = White on Black (15 << 4 | 0 = 15)
- `0x2E` = Yellow on Green (14 << 4 | 2 = 46)
- `0x4F` = White on Red (15 << 4 | 4 = 79)

### Kernel Display Features

1. **Title Bar** (Row 0)
   - "SimpleOS" - Yellow on Blue
   - "A Rust Operating System" - White on Blue

2. **Status Messages** (Rows 2-4)
   - `[OK]` tags - Light Green on Black
   - Status text - Light Gray on Black

3. **Welcome Messages** (Rows 6-7)
   - "Hello, World!" - Light Cyan on Black
   - "Welcome to SimpleOS!" - Pink on Black

4. **Rainbow Bar** (Row 11)
   - Animated color gradient using all colors

5. **Status Bar** (Row 24, bottom)
   - "System Status: Running" - Black on Light Green
   - Exit instructions - Black on Light Gray

### Example Kernel Output
```
 SimpleOS - A Rust Operating System          (Yellow/White on Blue)

  [OK] Bootloader loaded successfully        (Green/Gray on Black)
  [OK] Kernel initialized                    (Green/Gray on Black)
  [OK] VGA text mode enabled                 (Green/Gray on Black)

  Hello, World!                              (Light Cyan on Black)
  Welcome to SimpleOS!                       (Pink on Black)

  ================================           (Yellow on Black)
  [Rainbow color bar]                        (Multi-color)

  System Status: Running | Press Ctrl+A...   (Black on Green/Gray)
```

## VGA Memory Layout

VGA text mode buffer is at physical address `0xB8000`:
- 80 columns × 25 rows = 2000 characters
- Each character takes 2 bytes:
  - Byte 0: ASCII character
  - Byte 1: Color attribute (background << 4 | foreground)

### Memory Map Example
```
Address     Character  Color
0xB8000     'H'        0x0F (White on Black)
0xB8001     (color)    
0xB8002     'e'        0x0F
0xB8003     (color)
...
```

## How to Change Colors

### In Bootloader (bootloader/src/main.rs)
```rust
// Print colored text using BIOS
print_string_colored(b"Text", 0x0E);  // Yellow on black

// Color codes:
// 0x0F = White on black
// 0x0A = Light green on black
// 0x0E = Yellow on black
// 0x0C = Light red on black
```

### In Kernel (kernel/src/main.rs)
```rust
// Print colored text using VGA memory
print_colored(b"Text", row, col, Color::Yellow, Color::Black);

// Available colors:
// Color::Black, Color::Blue, Color::Green, Color::Cyan
// Color::Red, Color::Magenta, Color::Brown, Color::LightGray
// Color::DarkGray, Color::LightBlue, Color::LightGreen, Color::LightCyan
// Color::LightRed, Color::Pink, Color::Yellow, Color::White
```

## Custom Color Schemes

### Dark Theme (Current Default)
```rust
clear_screen(Color::Black);  // Black background
print_colored(text, 0, 0, Color::White, Color::Black);
```

### Light Theme
```rust
clear_screen(Color::White);  // White background
print_colored(text, 0, 0, Color::Black, Color::White);
```

### Matrix Theme (Green on Black)
```rust
clear_screen(Color::Black);
print_colored(text, 0, 0, Color::LightGreen, Color::Black);
```

### Retro Theme (Amber on Black)
```rust
clear_screen(Color::Black);
print_colored(text, 0, 0, Color::Yellow, Color::Black);
```

### Blue Screen of Death Theme
```rust
clear_screen(Color::Blue);
print_colored(text, 0, 0, Color::White, Color::Blue);
```

## Panic Screen

When a kernel panic occurs, the screen changes to:
- Background: Red
- Title: "KERNEL PANIC!" - White on Red
- Details: Yellow on Red
- Message: Light Gray on Red

## Technical Details

### BIOS Colors vs VGA Colors
- **BIOS (Bootloader)**: Uses BIOS INT 10h, slower but simpler
- **VGA (Kernel)**: Direct memory writes, faster and more control

### Blinking Text (Advanced)
To enable blinking, set bit 7 of the color attribute:
```rust
let blink_color = color | 0x80;
```

### Color Limitations
- Text mode only supports 16 colors
- Graphics mode required for 256+ colors
- No RGB values, only palette indices

## Examples

### Creating a Status Line
```rust
// Green background for success
print_colored(b"  OK  ", 0, 0, Color::Black, Color::LightGreen);
print_colored(b" Operation successful", 0, 6, Color::White, Color::Black);
```

### Creating a Warning
```rust
// Yellow background for warning
print_colored(b" WARN ", 1, 0, Color::Black, Color::Yellow);
print_colored(b" Check configuration", 1, 7, Color::LightGray, Color::Black);
```

### Creating an Error
```rust
// Red background for error
print_colored(b"ERROR", 2, 0, Color::White, Color::Red);
print_colored(b" Failed to load module", 2, 6, Color::LightRed, Color::Black);
```

## Color Best Practices

1. **High Contrast**: Use light text on dark backgrounds or vice versa
2. **Consistency**: Use the same colors for similar messages (green = success, red = error)
3. **Readability**: Avoid yellow on white, blue on black combinations
4. **Accessibility**: Consider colorblind users (don't rely on color alone)
5. **Status Codes**: Use color + text symbols (`[OK]`, `[WARN]`, `[ERROR]`)

## References

- [OSDev VGA Text Mode](https://wiki.osdev.org/Text_mode)
- [BIOS INT 10h](http://www.ctyme.com/intr/rb-0087.htm)
- [VGA Color Palette](https://wiki.osdev.org/VGA_Hardware#Color_palette)