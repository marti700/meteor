/* common/nRF52833.ld */
/* Copyright (c) 2018-20 J. M. Spivey */

MEMORY {
    FLASH   (rx)  : ORIGIN = 0x00000000,      LENGTH = 512K
    RAM     (rwx) : ORIGIN = 0x20000000,      LENGTH = 124K
    /* CODERAM (rwx) : ORIGIN = 0x00800000+124K, LENGTH = 4K */
}

OUTPUT_FORMAT ("elf32-littlearm")

/* Setting the entry address helps GDB to find the stack bottom */
ENTRY(Reset_Handler)

SECTIONS {
    .text ALIGN(16) : SUBALIGN(16) {
        KEEP(*(.vectors))
        *(.text*)
        *(.rodata*)
        . = ALIGN(4);
        __etext = .;

    } > FLASH


    /* Set stack top to end of RAM, and move stack limit down by
       size of stack */
    __stack = ORIGIN(RAM) + LENGTH(RAM);
    __stack_limit = __stack - 2048;

}