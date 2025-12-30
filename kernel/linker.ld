OUTPUT_FORMAT(binary)
ENTRY(_start)

SECTIONS {
    /* Kernel loads at 1MB (0x100000) - standard location for x86 kernels */
    . = 0x100000;

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
