/*----------------------------------------------------------------------*/
/* Setup                                                                */
/*----------------------------------------------------------------------*/

/* The OUTPUT_ARCH command specifies the machine architecture where the
   argument is one of the names used in the BFD library. More
   specifically one of the entires in bfd/cpu-mips.c */

OUTPUT_ARCH( "riscv" )

ENTRY( _start )


SECTIONS
{
    . = 0x80000000;

    .text : {
         KEEP(*(.text.init))
         KEEP(*(.text.main))
         /* constructors */
         . = ALIGN(4096);
         PROVIDE(__CTORS_START = .);
         KEEP (*(.ctors*))
         KEEP (*(.init_array*))
         PROVIDE(__CTORS_END = .);

         *(.text)
         *(.text.*)
         *(.gnu.linkonce.t.*)
    }

  . = ALIGN(16);
/* rodata: Read-only data */
  .rodata :
  {
    PROVIDE( _srodata = . );
    *(.rdata)
    *(.rodata)
    *(.rodata.*)
    *(.gnu.linkonce.r.*)
    PROVIDE( _erodata = . );
  }

  /*--------------------------------------------------------------------*/
  /* HTIF, isolated onto separate page                                  */
  /*--------------------------------------------------------------------*/
  /*. = ALIGN(0x1000);
  .htif :
  {
    PROVIDE( __htif_base = . );
    *(.htif)
  }
  . = ALIGN(0x1000);
  */

  /*--------------------------------------------------------------------*/
  /* Initialized data segment                                           */
  /*--------------------------------------------------------------------*/

  /* Start of initialized data segment */
  . = ALIGN(16);
   _fdata = .;

  /* data: Writable data */
  .data :
  {
  *(.data)
  *(.data.*)
  *(.srodata*)
  *(.gnu.linkonce.d.*)
  *(.comment)
  }

  /* End of initialized data segment */
  PROVIDE( edata = . );
  _edata = .;

  /* Have _gp point to middle of sdata/sbss to maximize displacement range */
  . = ALIGN(16);
  _gp = . + 0x800;

  /* Writable small data segment */
  .sdata :
  {
    *(.sdata)
    *(.sdata.*)
    *(.srodata.*)
    *(.gnu.linkonce.s.*)
  }

  /*--------------------------------------------------------------------*/
  /* Uninitialized data segment                                         */
  /*--------------------------------------------------------------------*/

  /* Start of uninitialized data segment */
  . = ALIGN(8);
  _fbss = .;

  /* Writable uninitialized small data segment */
  .sbss :
  {
    *(.sbss)
    *(.sbss.*)
    *(.gnu.linkonce.sb.*)
  }

  /* bss: Uninitialized writeable data section */
  . = .;
  _bss_start = .;
  .bss :
  {
    *(.bss)
    *(.bss.*)
    *(.gnu.linkonce.b.*)
    *(COMMON)
  }
  _bss_end = .;
  _ebss = .;


  /* End of uninitialized data segment (used by syscalls.c for heap) */
  PROVIDE( end = . );
  _end = ALIGN(8);
}
