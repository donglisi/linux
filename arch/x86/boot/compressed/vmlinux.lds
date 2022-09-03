OUTPUT_FORMAT("elf64-x86-64")
OUTPUT_ARCH(i386:x86-64)
SECTIONS
{
	/* Be careful parts of head_64.S assume startup_32 is at
	 * address 0.
	 */
	. = 0;
	.head.text : {
		_head = . ;
		_ehead = . ;
	}
	.rodata..compressed : {
		*(.rodata..compressed)
	}
	.text : {
		_text = .;
		*(.text)
		*(.text.*)
		_etext = . ;
	}
	.data : {
		_data = . ;
		*(.data)
		*(.data.*)
		*(.bss.efistub)
		_edata = . ;
	}
	. = ALIGN((1 << (6)));
	.bss : {
		_bss = . ;
		*(.bss)
		*(.bss.*)
		*(COMMON)
		. = ALIGN(8);	/* For convenience during zeroing */
		_ebss = .;
	}
	. = ALIGN((1 << 12));
	.pgtable : {
		_pgtable = . ;
		*(.pgtable)
		_epgtable = . ;
	}
	. = ALIGN((1 << 12));	/* keep ZO size page aligned */
	_end = .;

	/DISCARD/ : {
		*(.note.gnu.property)
		*(.eh_frame)
		*(.comment)
	}
}
