/*
******************************************************************************
**
** @file        : LinkerScript.ld (debug in RAM dedicated)
**
** @author      : Auto-generated by STM32CubeIDE
**
** @brief       : Linker script for STM32F446RETx Device from STM32F4 series
**                      512KBytes FLASH
**                      128KBytes RAM
**
**                Set heap size, stack size and stack location according
**                to application requirements.
**
**                Set memory bank area and size if external memory is used
**
**  Target      : STMicroelectronics STM32
**
**  Distribution: The file is distributed as is, without any warranty
**                of any kind.
**
******************************************************************************
** @attention
**
** Copyright (c) 2024 STMicroelectronics.
** All rights reserved.
**
** This software is licensed under terms that can be found in the LICENSE file
** in the root directory of this software component.
** If no LICENSE file comes with this software, it is provided AS-IS.
**
******************************************************************************
*/

/* Entry Point */
ENTRY(Reset_Handler)

/* Highest address of the user mode stack */
_estack = ORIGIN(RAM) + LENGTH(RAM); /* end of "RAM" Ram type memory */

/* Memories definition */
MEMORY
/* {
  RAM    (xrw)    : ORIGIN = 0x20000000,   LENGTH = 128K
  FLASH    (rx)    : ORIGIN = 0x8000000,   LENGTH = 512K
} */

{
  FLASH  : ORIGIN = 0x00000000, LENGTH = 256K
  RAM   : ORIGIN = 0x20000000, LENGTH = 16K
}

/* Sections */
SECTIONS
{
  /* The program code and other data into "RAM" Ram type memory */
  .text :
  {
    . = ALIGN(4);
    LONG(ORIGIN(RAM) + LENGTH(RAM));
    KEEP(*(.isr_vector))
    *(.text)           /* .text sections (code) */
    *(.text*)          /* .text* sections (code) */
    *(.glue_7)         /* glue arm to thumb code */
    *(.glue_7t)        /* glue thumb to arm code */
    *(.eh_frame)
    *(.RamFunc)        /* .RamFunc sections */
    *(.RamFunc*)       /* .RamFunc* sections */

    . = ALIGN(4);
    _etext = .;        /* define a global symbols at end of code */
  } >RAM

  /* Constant data into "RAM" Ram type memory */

  /* Used by the startup to initialize data */

  /* Initialized data sections into "RAM" Ram type memory */
  

  /* Uninitialized data section into "RAM" Ram type memory */
  . = ALIGN(4);
  
  /* User_heap_stack section, used to check that there is enough "RAM" Ram  type memory left */

  /* Remove information from the compiler libraries */
  /DISCARD/ :
  {
    libc.a ( * )
    libm.a ( * )
    libgcc.a ( * )
  }

  .ARM.attributes 0 : { *(.ARM.attributes) }
}