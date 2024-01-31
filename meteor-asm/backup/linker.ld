/* Entry Point */
/* ENTRY (Reset_Handler) */
ENTRY (Reset_Handler)

/* Memory layout */
MEMORY
{
  FLASH  : ORIGIN = 0x00000000, LENGTH = 256K
  RAM   : ORIGIN = 0x20000000, LENGTH = 16K
}

/* {
  FLASH  : ORIGIN = 0x00000000, LENGTH = 512K
  RAM   : ORIGIN = 0x20000000, LENGTH = 128K
} */


/* Output sections */
SECTIONS
{
  /* Vector table and program code */
  .text :
  {
    . = ALIGN(4);
    LONG(ORIGIN(RAM) + LENGTH(RAM))
    _stext = .;
    KEEP (*(.vtable)) /* Vector table */
    * (.text) /* the '*' means that all text sections of all files will be merged here */
    * (.text*) /* More code sections, in this case the ones which names start with .text and then have something else after */
    . = ALIGN(4);
    _etext = .;
  } > FLASH

  /* Initialized data */
  .data :
  {
    . = ALIGN(4);
    _sdata = .; /* Start of data section */
    * (.data) /* Data sections */
    * (.data*) /* More data sections */
    . = ALIGN(4);
    _edata = .; /* End of data section */
  } > RAM AT > FLASH

  /* Uninitialized data */
  .bss :
  {
    . = ALIGN(4);
    _sbss = .; /* Start of bss section */
    * (.bss) /* Bss sections */
    * (.bss*) /* More bss sections */
    * (COMMON) /* Common symbols */
    . = ALIGN(4);
    _ebss = .; /* End of bss section */
  } > RAM


  _estack = ORIGIN(RAM) + LENGTH(RAM);
}
