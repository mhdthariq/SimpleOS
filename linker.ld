OUTPUT_FORMAT(binary)
ENTRY(_start)

SECTIONS {

    . = 0x7c00;

    /*
      Rust also mangles segment names.
      The "<segment_name>.*" syntax is used to also include all the mangles
    */

    .text : { *(.text .text.*) }
    .bss : { *(.bss .bss.*) }
    .rodata : { *(.rodata .rodata.*) }
    .data : { *(.data .data.*) }

    /*
      This segment is not relevant for us, because we use `panic = "abort"`,
      but to be sure that nothing unexpected happens, we discard it.
    */
    /DISCARD/ : {
        *(.eh_frame .eh_frame.*)
        *(.eh_frame_hdr .eh_frame_hdr.*)
    }

    . = 0x7c00 + 510;

    .magic_number : { SHORT(0xaa55) }
}
