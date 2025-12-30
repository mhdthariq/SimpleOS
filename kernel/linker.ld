OUTPUT_FORMAT(binary)
ENTRY(_start)

SECTIONS {
    /* Kernel loads at 64KB (0x10000) - where bootloader places it in real mode */
    . = 0x10000;

    .boot : {
        *(.multiboot)
    }

    .text ALIGN(4K) : {
        *(.text .text.*)
    }

    .rodata ALIGN(4K) : {
        *(.rodata .rodata.*)
    }

    .data ALIGN(4K) : {
        *(.data .data.*)
    }

    .bss ALIGN(4K) : {
        *(.bss .bss.*)
        *(COMMON)
    }

    /* Discard unwanted sections */
    /DISCARD/ : {
        *(.eh_frame .eh_frame.*)
        *(.eh_frame_hdr .eh_frame_hdr.*)
        *(.comment)
        *(.note*)
    }
}
